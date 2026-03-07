const gpio = @import("gpio.zig");
const regs = @import("../mcu/atmega328p.zig").registers;

pub const AnalogPin = enum {
    A0,
    A1,
    A2,
    A3,
    A4,
    A5,
};

const avcc_reference: u2 = 0b01;
const adc_prescaler_128: u3 = 0b111;

var initialized = false;

pub fn init() void {
    if (initialized) return;

    regs.ADC.ADCSRA.modify(.{
        .ADPS = adc_prescaler_128,
        .ADIE = 0,
        .ADIF = 1,
        .ADATE = 0,
        .ADSC = 0,
        .ADEN = 1,
    });
    regs.ADC.ADCSRB.modify(.{ .ADTS = 0, .ACME = 0 });
    regs.ADC.ADMUX.modify(.{ .MUX = 0, .ADLAR = 0, .REFS = avcc_reference });

    initialized = true;
}

pub fn read(comptime pin: AnalogPin) u16 {
    init();

    const channel = comptime channelOf(pin);
    const gpio_pin = comptime gpioPinOf(pin);

    gpio.init(gpio_pin, .in);
    gpio.setPullup(gpio_pin, false);
    enableDigitalInputDisable(pin);

    regs.ADC.ADMUX.modify(.{ .MUX = channel, .ADLAR = 0, .REFS = avcc_reference });
    regs.ADC.ADCSRA.modify(.{
        .ADPS = adc_prescaler_128,
        .ADIE = 0,
        .ADIF = 1,
        .ADATE = 0,
        .ADSC = 1,
        .ADEN = 1,
    });

    while (regs.ADC.ADCSRA.read().ADSC == 1) {}

    return regs.ADC.ADC.*;
}

fn channelOf(comptime pin: AnalogPin) u4 {
    return switch (pin) {
        .A0 => 0,
        .A1 => 1,
        .A2 => 2,
        .A3 => 3,
        .A4 => 4,
        .A5 => 5,
    };
}

fn gpioPinOf(comptime pin: AnalogPin) gpio.Pin {
    return switch (pin) {
        .A0 => .A0,
        .A1 => .A1,
        .A2 => .A2,
        .A3 => .A3,
        .A4 => .A4,
        .A5 => .A5,
    };
}

fn enableDigitalInputDisable(comptime pin: AnalogPin) void {
    switch (pin) {
        .A0 => regs.ADC.DIDR0.modify(.{ .ADC0D = 1 }),
        .A1 => regs.ADC.DIDR0.modify(.{ .ADC1D = 1 }),
        .A2 => regs.ADC.DIDR0.modify(.{ .ADC2D = 1 }),
        .A3 => regs.ADC.DIDR0.modify(.{ .ADC3D = 1 }),
        .A4 => regs.ADC.DIDR0.modify(.{ .ADC4D = 1 }),
        .A5 => regs.ADC.DIDR0.modify(.{ .ADC5D = 1 }),
    }
}
