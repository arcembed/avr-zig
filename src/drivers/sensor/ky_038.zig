const adc = @import("../../hal/adc.zig");
const gpio = @import("../../hal/gpio.zig");

pub const ActiveLevel = enum {
    low,
    high,
};

pub const DigitalState = enum {
    quiet,
    sound_detected,
};

/// Configures the comparator output pin.
pub fn initDigital(comptime pin: gpio.Pin, enable_pullup: bool) void {
    gpio.init(pin, .in);
    gpio.setPullup(pin, enable_pullup);
}

/// Returns the raw comparator output level.
pub fn readDigitalRaw(comptime pin: gpio.Pin) bool {
    return gpio.read(pin);
}

/// Returns the comparator output interpreted with the chosen active level.
pub fn readDigital(comptime pin: gpio.Pin, comptime active_level: ActiveLevel) DigitalState {
    const raw = readDigitalRaw(pin);
    const detected = switch (active_level) {
        .low => !raw,
        .high => raw,
    };

    return if (detected) .sound_detected else .quiet;
}

pub fn isSoundDetected(comptime pin: gpio.Pin, comptime active_level: ActiveLevel) bool {
    return readDigital(pin, active_level) == .sound_detected;
}

/// Reads the analog microphone output.
pub fn readAnalog(comptime pin: adc.AnalogPin) u16 {
    return adc.read(pin);
}
