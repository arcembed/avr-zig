const std = @import("std");
const avr_board = struct {
    const Board = enum { uno, mega2560 };
    const Spec = struct {
        target_query: std.Target.Query,
        linker_script: []const u8,
    };

    pub fn resolveBoard(b: *std.Build) Board {
        const value = b.option([]const u8, "board", "Target board: uno or mega2560") orelse "uno";
        if (std.mem.eql(u8, value, "uno")) return .uno;
        if (std.mem.eql(u8, value, "mega2560")) return .mega2560;
        std.debug.panic("unsupported -Dboard={s}; use 'uno' or 'mega2560'", .{value});
    }

    pub fn spec(board: Board) Spec {
        return switch (board) {
            .uno => .{ .target_query = .{ .cpu_arch = .avr, .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p }, .os_tag = .freestanding, .abi = .none }, .linker_script = "src/runtime/atmega328p.ld" },
            .mega2560 => .{ .target_query = .{ .cpu_arch = .avr, .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega2560 }, .os_tag = .freestanding, .abi = .none }, .linker_script = "src/runtime/atmega2560.ld" },
        };
    }

    pub fn defaultTty(_: Board) []const u8 { return "/dev/ttyACM0"; }

    pub fn addUploadStep(b: *std.Build, board: Board, tty: []const u8, description: []const u8, bin_path: []const u8) void {
        const upload = b.step("upload", description);
        const avrdude = switch (board) {
            .uno => b.addSystemCommand(&.{ "avrdude", "-carduino", "-patmega328p", "-D", "-P", tty, b.fmt("-Uflash:w:{s}:e", .{bin_path}) }),
            .mega2560 => b.addSystemCommand(&.{ "avrdude", "-cwiring", "-patmega2560", "-b115200", "-D", "-P", tty, b.fmt("-Uflash:w:{s}:e", .{bin_path}) }),
        };
        avrdude.step.dependOn(b.getInstallStep());
        upload.dependOn(&avrdude.step);
    }

    pub fn addObjdumpStep(b: *std.Build, description: []const u8, bin_path: []const u8) void {
        const objdump = b.step("objdump", description);
        const avr_objdump = b.addSystemCommand(&.{ "avr-objdump", "-dh", bin_path });
        avr_objdump.step.dependOn(b.getInstallStep());
        objdump.dependOn(&avr_objdump.step);
    }
};

pub fn build(b: *std.Build) void {
    const optimize: std.builtin.OptimizeMode = .ReleaseSafe;
    const board = avr_board.resolveBoard(b);
    const spec = avr_board.spec(board);
    const tty = b.option([]const u8, "tty", "Serial device for avrdude and screen") orelse avr_board.defaultTty(board);

    const avr_dep = b.dependency("avr_zig", .{});
    const avr_mod = avr_dep.module("avr_zig");
    const target = b.resolveTargetQuery(spec.target_query);
    const app_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "avr_zig", .module = avr_mod }},
    });

    const exe = b.addExecutable(.{
        .name = "servo",
        .root_module = b.createModule(.{
            .root_source_file = avr_dep.path("src/runtime/app_root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "avr_zig", .module = avr_mod },
                .{ .name = "app", .module = app_mod },
            },
        }),
    });
    exe.bundle_compiler_rt = false;
    exe.bundle_ubsan_rt = false;
    exe.linker_script = avr_dep.path(spec.linker_script);

    b.installArtifact(exe);

    const bin_path = b.getInstallPath(.bin, exe.out_filename);
    avr_board.addUploadStep(b, board, tty, "Flash the servo example with avrdude", bin_path);
    avr_board.addObjdumpStep(b, "Disassemble the servo firmware", bin_path);
}
