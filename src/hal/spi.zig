const gpio = @import("gpio.zig");
const platform = @import("../platform/current.zig");
const regs = platform.registers;

pub const ClockDiv = enum {
    f2,
    f4,
    f8,
    f16,
    f32,
    f64,
    f128,
};

/// Initializes SPI master mode.
pub fn init(comptime clock_div: ClockDiv) void {
    gpio.init(platform.spi_pins.ss, .out);
    gpio.init(platform.spi_pins.mosi, .out);
    gpio.init(platform.spi_pins.sck, .out);
    gpio.init(platform.spi_pins.miso, .in);

    // Keeping the hardware SS pin as an output prevents the AVR from
    // dropping back into slave mode while the MFRC522 uses a separate chip select pin.
    gpio.write(platform.spi_pins.ss, true);

    const config = divConfig(clock_div);
    regs.SPI.SPSR.modify(.{ .SPI2X = config.spi2x });
    regs.SPI.SPCR.modify(.{
        .SPR = config.spr,
        .CPHA = 0,
        .CPOL = 0,
        .MSTR = 1,
        .DORD = 0,
        .SPE = 1,
        .SPIE = 0,
    });
}

/// Transfers one SPI byte.
pub fn transfer(byte: u8) u8 {
    regs.SPI.SPDR.* = byte;
    while (regs.SPI.SPSR.read().SPIF != 1) {}
    return regs.SPI.SPDR.*;
}

fn divConfig(comptime clock_div: ClockDiv) struct { spr: u2, spi2x: u1 } {
    return switch (clock_div) {
        .f2 => .{ .spr = 0b00, .spi2x = 1 },
        .f4 => .{ .spr = 0b00, .spi2x = 0 },
        .f8 => .{ .spr = 0b01, .spi2x = 1 },
        .f16 => .{ .spr = 0b01, .spi2x = 0 },
        .f32 => .{ .spr = 0b10, .spi2x = 1 },
        .f64 => .{ .spr = 0b10, .spi2x = 0 },
        .f128 => .{ .spr = 0b11, .spi2x = 0 },
    };
}
