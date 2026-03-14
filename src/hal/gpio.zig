//! This is the GPIO (General Purpose Input/Output) module, providing utilities
//! for configuring, reading, and writing to pins.

const platform = @import("../platform/current.zig");

pub const Direction = enum { in, out };
pub const Pin = platform.Pin;

/// Sets a pin direction.
pub fn init(comptime pin: Pin, comptime dir: Direction) void {
    const ddr = platform.pinDirectionRegister(pin);
    const mask = platform.pinMask(pin);

    if (dir == .out) {
        ddr.* |= mask;
    } else {
        ddr.* &= ~mask;
    }
}

/// Toggles a pin output.
pub fn toggle(comptime pin: Pin) void {
    const port = platform.pinOutputRegister(pin);
    port.* ^= platform.pinMask(pin);
}

/// Writes a pin level.
pub fn write(comptime pin: Pin, high: bool) void {
    const port = platform.pinOutputRegister(pin);
    const mask = platform.pinMask(pin);

    if (high) {
        port.* |= mask;
    } else {
        port.* &= ~mask;
    }
}

/// Reads a pin level.
pub fn read(comptime pin: Pin) bool {
    return (platform.pinInputRegister(pin).* & platform.pinMask(pin)) != 0;
}

/// Enables or disables the pull-up.
pub fn setPullup(comptime pin: Pin, enabled: bool) void {
    write(pin, enabled);
}
