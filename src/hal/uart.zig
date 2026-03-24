const std = @import("std");
const platform = @import("../platform/current.zig");
const regs = platform.registers;

const ubrr0_value = blk: {
    const oversample = 8;
    break :blk @as(u16, (platform.CPU_FREQ / (oversample * baud_rate)) - 1);
};

const baud_rate = 115200;

/// Initializes UART output.
pub fn init(comptime baud: comptime_int) void {
    if (baud != baud_rate) {
        @compileError("uart.init currently supports only 115200 baud on this Zig toolchain");
    }

    // Set baudrate
    regs.USART0.UBRR0.* = ubrr0_value;

    // Default uart settings are 8n1, so no need to change them!
    writeStatusRegister(1);

    // Enable transmitter!
    regs.USART0.UCSR0B.modify(.{ .TXEN0 = 1 });
}

/// Writes a supported scalar or byte string.
pub fn write(value: anytype) void {
    const T = @TypeOf(value);

    if (comptime isByteStringType(T)) {
        writeByteString(value);
        return;
    }

    switch (@typeInfo(T)) {
        .bool => writeBool(value),
        .int => |int_info| switch (int_info.signedness) {
            .signed => writeSigned(value),
            .unsigned => writeUnsigned(value),
        },
        .comptime_int => {
            if (value < 0) {
                writeSigned(@as(i128, value));
            } else {
                writeUnsigned(@as(u128, value));
            }
        },
        .float, .comptime_float => writeFloatFixed2(value),
        else => @compileError(std.fmt.comptimePrint(
            "uart.write does not support values of type '{s}'; supported types are byte strings, bools, ints, and floats",
            .{ @typeName(T) },
        )),
    }
}

/// Writes one byte.
pub fn write_ch(ch: u8) void {
    // Wait till the transmit buffer is empty
    while (regs.USART0.UCSR0A.read().UDRE0 != 1) {}

    regs.USART0.UDR0.* = ch;
}

fn writeBytes(data: []const u8) void {
    if (data.len == 0) return;

    clearTransmitComplete();

    for (data) |ch| {
        write_ch(ch);
    }

    // Wait till we are actually done sending
    while (regs.USART0.UCSR0A.read().TXC0 != 1) {}
}

fn writeByteString(value: anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .array => {
            if (value.len == 0) return;

            clearTransmitComplete();

            for (value) |ch| {
                write_ch(ch);
            }

            while (regs.USART0.UCSR0A.read().TXC0 != 1) {}
        },
        .pointer => |pointer_info| switch (pointer_info.size) {
            .slice, .one => writeBytes(value),
            else => unreachable,
        },
        else => unreachable,
    }
}

fn writeBool(value: bool) void {
    writeBytes(if (value) "true" else "false");
}

fn writeUnsigned(value: anytype) void {
    const T = @TypeOf(value);
    const places = comptime decimalPlaces(T);
    var remaining = value;
    var wrote_digit = false;

    inline for (places) |place| {
        var digit: u8 = 0;

        inline for (0..9) |_| {
            if (remaining >= place) {
                remaining -= place;
                digit += 1;
            }
        }

        if (digit != 0 or wrote_digit or place == 1) {
            wrote_digit = true;
            write_ch('0' + digit);
        }
    }
}

fn writeSigned(value: anytype) void {
    const T = @TypeOf(value);
    const int_info = @typeInfo(T).int;
    const UnsignedT = std.meta.Int(.unsigned, int_info.bits);

    if (value < 0) {
        write_ch('-');

        const bits: UnsignedT = @bitCast(value);
        writeUnsigned((~bits) +% 1);
        return;
    }

    writeUnsigned(@as(UnsignedT, @intCast(value)));
}

fn writeFloatFixed2(value: anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .comptime_float => writeComptimeFloatFixed2(value),
        .float => |float_info| switch (float_info.bits) {
            16 => @call(.never_inline, writeFloat16Fixed2, .{value}),
            32 => @call(.never_inline, writeFloat32Fixed2, .{value}),
            else => @compileError(std.fmt.comptimePrint(
                "uart.write currently supports runtime f16/f32 values on AVR; got '{s}'",
                .{ @typeName(@TypeOf(value)) },
            )),
        },
        else => unreachable,
    }
}

fn isByteStringType(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .array => |array_info| array_info.child == u8,
        .pointer => |pointer_info| switch (pointer_info.size) {
            .slice => pointer_info.child == u8,
            .one => switch (@typeInfo(pointer_info.child)) {
                .array => |array_info| array_info.child == u8,
                else => false,
            },
            else => false,
        },
        else => false,
    };
}

fn clearTransmitComplete() void {
    writeStatusRegister(1);
}

fn decimalPlaces(comptime T: type) [decimalDigitCount(T)]T {
    const count = comptime decimalDigitCount(T);
    var places: [count]T = undefined;
    var place: T = 1;
    var index = count;

    while (index > 0) : (index -= 1) {
        places[index - 1] = place;
        if (index > 1) {
            place *= 10;
        }
    }

    return places;
}

fn decimalDigitCount(comptime T: type) usize {
    comptime var digits: usize = 1;
    comptime var max_value: T = std.math.maxInt(T);

    while (max_value >= 10) : (digits += 1) {
        max_value /= 10;
    }

    return digits;
}

fn writeScaledFixed2(scaled: anytype) void {
    const T = @TypeOf(scaled);
    const places = comptime decimalPlaces(T);
    var remaining = scaled;
    var wrote_integer = false;

    inline for (places) |place| {
        var digit: u8 = 0;

        inline for (0..9) |_| {
            if (remaining >= place) {
                remaining -= place;
                digit += 1;
            }
        }

        if (place >= 100) {
            if (digit != 0 or wrote_integer) {
                wrote_integer = true;
                write_ch('0' + digit);
            }
            continue;
        }

        if (!wrote_integer) {
            write_ch('0');
            wrote_integer = true;
        }

        if (place == 10) {
            write_ch('.');
        }

        write_ch('0' + digit);
    }
}

fn writeComptimeFloatFixed2(value: comptime_float) void {
    if (value != value) {
        writeBytes("nan");
        return;
    }
    if (value == std.math.inf(f64)) {
        writeBytes("inf");
        return;
    }
    if (value == -std.math.inf(f64)) {
        writeBytes("-inf");
        return;
    }

    const negative = std.math.signbit(@as(f64, value));
    const scaled: u128 = @intFromFloat(@abs(value) * 100.0 + 0.5);

    if (negative) {
        write_ch('-');
    }

    writeScaledFixed2(scaled);
}

fn writeFloat16Fixed2(value: f16) void {
    writeBinaryFloatFixed2(value, u16, 5, 10);
}

fn writeFloat32Fixed2(value: f32) void {
    writeBinaryFloatFixed2(value, u32, 8, 23);
}

fn writeBinaryFloatFixed2(
    value: anytype,
    comptime BitsT: type,
    comptime exponent_bits: comptime_int,
    comptime mantissa_bits: comptime_int,
) void {
    const bits: BitsT = @bitCast(value);
    const total_bits = @bitSizeOf(BitsT);
    const exponent_bias = (1 << (exponent_bits - 1)) - 1;
    const sign_mask = @as(BitsT, 1) << (total_bits - 1);
    const mantissa_mask = (@as(BitsT, 1) << mantissa_bits) - 1;
    const exponent_mask = (@as(BitsT, 1) << exponent_bits) - 1;
    const raw_exponent: BitsT = (bits >> mantissa_bits) & exponent_mask;
    const mantissa: BitsT = bits & mantissa_mask;
    const negative = (bits & sign_mask) != 0;

    if (raw_exponent == exponent_mask) {
        if (mantissa != 0) {
            writeBytes("nan");
        } else if (negative) {
            writeBytes("-inf");
        } else {
            writeBytes("inf");
        }
        return;
    }

    const scaled = scaledFloatMagnitude(
        BitsT,
        raw_exponent,
        mantissa,
        mantissa_bits,
        exponent_bias,
    ) orelse {
        writeBytes(if (negative) "-overflow" else "overflow");
        return;
    };

    if (negative) {
        write_ch('-');
    }

    writeScaledFixed2(scaled);
}

fn scaledFloatMagnitude(
    comptime BitsT: type,
    raw_exponent: BitsT,
    mantissa: BitsT,
    comptime mantissa_bits: comptime_int,
    comptime exponent_bias: comptime_int,
) ?u32 {
    const exponent: i32 = if (raw_exponent == 0)
        1 - exponent_bias - mantissa_bits
    else
        @as(i32, @intCast(raw_exponent)) - exponent_bias - mantissa_bits;
    const significand: u32 = if (raw_exponent == 0)
        mantissa
    else
        (@as(u32, 1) << mantissa_bits) | mantissa;
    var scaled_significand: u32 = 0;
    var scale_count: u8 = 0;
    var scale_limit: u8 = 100;
    const limit: *volatile u8 = &scale_limit;

    while (scale_count != limit.*) : (scale_count += 1) {
        scaled_significand += significand;
    }

    if (exponent >= 0) {
        const shift: u8 = @intCast(exponent);
        if (shift >= 32) return null;
        const runtime_shift: u5 = @intCast(shift);
        if (scaled_significand > (@as(u32, std.math.maxInt(u32)) >> runtime_shift)) return null;
        return scaled_significand << runtime_shift;
    }

    const shift: u8 = @intCast(-exponent);
    if (shift >= 32) return 0;

    const rounded_shift: u5 = @intCast(shift);
    const rounding = @as(u32, 1) << @as(u5, @intCast(shift - 1));
    return (scaled_significand + rounding) >> rounded_shift;
}

fn writeStatusRegister(txc0: u1) void {
    regs.USART0.UCSR0A.write(.{
        .MPCM0 = 0,
        .U2X0 = 1,
        .UPE0 = 0,
        .DOR0 = 0,
        .FE0 = 0,
        .UDRE0 = 0,
        .TXC0 = txc0,
        .RXC0 = 0,
    });
}
