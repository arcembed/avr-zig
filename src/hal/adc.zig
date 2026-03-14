const gpio = @import("gpio.zig");
const platform = @import("../platform/current.zig");
const regs = platform.registers;

pub const AnalogPin = platform.AnalogPin;

const avcc_reference: u2 = 0b01;
const adc_prescaler_128: u3 = 0b111;

var initialized = false;

/// Initializes the ADC.
pub fn init() void {
    if (initialized) return;

    startConversionConfig();
    resetAdcsrb();
    regs.ADC.ADMUX.modify(.{ .MUX = 0, .ADLAR = 0, .REFS = avcc_reference });

    initialized = true;
}

/// Reads one analog sample.
pub fn read(comptime pin: AnalogPin) u16 {
    init();

    const channel = comptime platform.analogChannel(pin);
    const gpio_pin = comptime platform.analogDigitalPin(pin);

    if (gpio_pin) |pin_desc| {
        gpio.init(pin_desc, .in);
        gpio.setPullup(pin_desc, false);
    }

    enableDigitalInputDisable(pin);

    setChannel(channel);
    startConversionConfig();
    regs.ADC.ADCSRA.modify(.{ .ADSC = 1 });

    while (regs.ADC.ADCSRA.read().ADSC == 1) {}

    return regs.ADC.ADC.*;
}

fn startConversionConfig() void {
    regs.ADC.ADCSRA.modify(.{
        .ADPS = adc_prescaler_128,
        .ADIE = 0,
        .ADIF = 1,
        .ADATE = 0,
        .ADSC = 0,
        .ADEN = 1,
    });
}

fn resetAdcsrb() void {
    switch (platform.current_board) {
        .uno, .nano => regs.ADC.ADCSRB.modify(.{ .ADTS = 0, .ACME = 0 }),
        .mega2560 => regs.ADC.ADCSRB.modify(.{ .ADTS = 0, .MUX5 = 0, .ACME = 0 }),
    }
}

fn setChannel(channel: u5) void {
    const mux_type = @TypeOf(regs.ADC.ADMUX.read().MUX);
    regs.ADC.ADMUX.modify(.{
        .MUX = @as(mux_type, @intCast(channel & 0x1f)),
        .ADLAR = 0,
        .REFS = avcc_reference,
    });

    if (platform.current_board == .mega2560) {
        regs.ADC.ADCSRB.modify(.{
            .ADTS = 0,
            .MUX5 = @intFromBool(channel >= 8),
            .ACME = 0,
        });
    }
}

fn enableDigitalInputDisable(comptime pin: AnalogPin) void {
    const disable = comptime platform.analogInputDisable(pin);

    switch (disable) {
        .none => {},
        .didr0 => |bit| {
            var val = regs.ADC.DIDR0.read();
            switch (bit) {
                0 => val.ADC0D = 1,
                1 => val.ADC1D = 1,
                2 => val.ADC2D = 1,
                3 => val.ADC3D = 1,
                4 => val.ADC4D = 1,
                5 => val.ADC5D = 1,
                6 => val.ADC6D = 1,
                7 => val.ADC7D = 1,
            }
            regs.ADC.DIDR0.write(val);
        },
        .didr2 => |bit| {
            var val = regs.ADC.DIDR2.read();
            switch (bit) {
                0 => val.ADC8D = 1,
                1 => val.ADC9D = 1,
                2 => val.ADC10D = 1,
                3 => val.ADC11D = 1,
                4 => val.ADC12D = 1,
                5 => val.ADC13D = 1,
                6 => val.ADC14D = 1,
                7 => val.ADC15D = 1,
            }
            regs.ADC.DIDR2.write(val);
        },
    }
}
