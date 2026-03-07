const std = @import("std");
const builtin = std.builtin;
const atmega328p = @import("../mcu/atmega328p.zig");
const time = @import("../hal/time.zig");
const uart = @import("../hal/uart.zig");

fn validateInterruptNamespace(comptime Namespace: type, comptime namespace_name: []const u8) void {
    if (@hasDecl(Namespace, "RESET")) {
        @compileError("Not allowed to overload the reset vector in '" ++ namespace_name ++ "'");
    }

    for (std.meta.declarations(Namespace)) |decl| {
        if (!@hasField(atmega328p.VectorTable, decl.name)) {
            var msg: []const u8 = "There is no such interrupt as '" ++ decl.name ++ "'. ISRs in '" ++ namespace_name ++ "' must be one of:\n";
            for (std.meta.fields(atmega328p.VectorTable)) |field| {
                if (!std.mem.eql(u8, "RESET", field.name)) {
                    msg = msg ++ "    " ++ field.name ++ "\n";
                }
            }

            @compileError(msg);
        }
    }
}

fn exportInterruptHandler(comptime Namespace: type, comptime name: []const u8) void {
    const handler = @field(Namespace, name);
    const calling_convention = switch (@typeInfo(@TypeOf(handler))) {
        .@"fn" => |info| info.calling_convention,
        else => @compileError("Declarations in the interrupt namespace must all be functions. '" ++ name ++ "' is not a function"),
    };

    const exported_fn = switch (calling_convention) {
        .auto => struct {
            fn wrapper() callconv(.avr_interrupt) void {
                @call(.always_inline, handler, .{});
            }
        }.wrapper,
        else => @compileError("Leave interrupt handlers with an unspecified calling convention"),
    };

    const options: builtin.ExportOptions = .{ .name = name, .linkage = .strong };
    @export(&exported_fn, options);
}

pub fn Entry(comptime App: type) type {
    comptime {
        if (!@hasDecl(App, "main")) {
            @compileError("Applications using avr_zig.runtime.Entry must provide App.main()");
        }
    }

    return struct {
        comptime {
            std.debug.assert(std.mem.eql(u8, "RESET", std.meta.fields(atmega328p.VectorTable)[0].name));

            var asm_str: []const u8 = ".section .vectors\njmp _start\n";
            const has_interrupts = @hasDecl(App, "interrupts");
            const runtime_interrupts = time.runtime_interrupts;

            validateInterruptNamespace(runtime_interrupts, "runtime_interrupts");

            if (has_interrupts) {
                validateInterruptNamespace(App.interrupts, "interrupts");
            }

            for (std.meta.fields(atmega328p.VectorTable)[1..]) |field| {
                const new_instruction = if (has_interrupts) overload: {
                    if (@hasDecl(App.interrupts, field.name)) {
                        exportInterruptHandler(App.interrupts, field.name);
                        break :overload "jmp " ++ field.name;
                    }

                    if (@hasDecl(runtime_interrupts, field.name)) {
                        exportInterruptHandler(runtime_interrupts, field.name);
                        break :overload "jmp " ++ field.name;
                    }

                    break :overload "jmp _unhandled_vector";
                } else if (@hasDecl(runtime_interrupts, field.name)) runtime_default: {
                    exportInterruptHandler(runtime_interrupts, field.name);
                    break :runtime_default "jmp " ++ field.name;
                } else "jmp _unhandled_vector";

                asm_str = asm_str ++ new_instruction ++ "\n";
            }

            asm (asm_str);
        }

        pub fn unhandledVector() void {
            while (true) {}
        }

        pub fn start() noreturn {
            copy_data_to_ram();
            clear_bss();

            App.main();
            while (true) {}
        }

        fn copy_data_to_ram() void {
            asm volatile (
                \\  ldi r30, lo8(__data_load_start)
                \\  ldi r31, hi8(__data_load_start)
                \\  ldi r26, lo8(__data_start)
                \\  ldi r27, hi8(__data_start)
                \\  ldi r24, lo8(__data_end)
                \\  ldi r25, hi8(__data_end)
                \\  rjmp .L2
                \\
                \\.L1:
                \\  lpm r18, Z+
                \\  st X+, r18
                \\
                \\.L2:
                \\  cp r26, r24
                \\  cpc r27, r25
                \\  brne .L1
            );
        }

        fn clear_bss() void {
            asm volatile (
                \\  ldi r26, lo8(__bss_start)
                \\  ldi r27, hi8(__bss_start)
                \\  ldi r24, lo8(__bss_end)
                \\  ldi r25, hi8(__bss_end)
                \\  ldi r18, 0x00
                \\  rjmp .L4
                \\
                \\.L3:
                \\  st X+, r18
                \\
                \\.L4:
                \\  cp r26, r24
                \\  cpc r27, r25
                \\  brne .L3
            );
        }

        pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace, _: ?usize) noreturn {
            uart.write("PANIC: ");
            uart.write(msg);

            _ = error_return_trace;
            while (true) {}
        }
    };
}
