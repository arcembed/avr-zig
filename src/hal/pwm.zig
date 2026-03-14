const gpio = @import("gpio.zig");
const platform = @import("../platform/current.zig");
const regs = platform.registers;

pub const max_duty = 255;

const timer_prescaler = 64;
const timer1_clock_select = 0b011;
const timer2_clock_select = 0b100;
const non_inverting_compare_output = 0b10;
pub const default_frequency_hz = platform.CPU_FREQ / timer_prescaler / 256;

var timer1_initialized = false;
var timer2_initialized = false;
var timer3_initialized = false;
var timer4_initialized = false;
var timer5_initialized = false;

/// Returns whether PWM is supported.
pub fn supports(comptime pin: gpio.Pin) bool {
    return platform.pwmChannel(pin) != null;
}

/// Initializes PWM on a pin.
pub fn init(comptime pin: gpio.Pin) void {
    const channel = comptime channelForPin(pin);

    if (platform.current_board != .mega2560) {
        switch (channel) {
            .timer1_a, .timer1_b => ensureTimer1(),
            .timer2_a, .timer2_b => ensureTimer2(),
            else => unreachable,
        }
    } else {
        switch (channel) {
            .timer1_a, .timer1_b, .timer1_c => ensureTimer1(),
            .timer2_a, .timer2_b => ensureTimer2(),
            .timer3_a, .timer3_b, .timer3_c => ensureTimer3(),
            .timer4_a, .timer4_b, .timer4_c => ensureTimer4(),
            .timer5_a, .timer5_b, .timer5_c => ensureTimer5(),
        }
    }

    gpio.init(pin, .out);
    enableChannel(channel);
    write(pin, 0);
}

/// Sets the PWM duty cycle.
pub fn write(comptime pin: gpio.Pin, duty: u8) void {
    const channel = comptime channelForPin(pin);

    if (platform.current_board != .mega2560) {
        switch (channel) {
            .timer1_a => regs.TC1.OCR1A.* = duty,
            .timer1_b => regs.TC1.OCR1B.* = duty,
            .timer2_a => regs.TC2.OCR2A.* = duty,
            .timer2_b => regs.TC2.OCR2B.* = duty,
            else => unreachable,
        }
    } else {
        switch (channel) {
            .timer1_a => regs.TC1.OCR1A.* = duty,
            .timer1_b => regs.TC1.OCR1B.* = duty,
            .timer1_c => regs.TC1.OCR1C.* = duty,
            .timer2_a => regs.TC2.OCR2A.* = duty,
            .timer2_b => regs.TC2.OCR2B.* = duty,
            .timer3_a => regs.TC3.OCR3A.* = duty,
            .timer3_b => regs.TC3.OCR3B.* = duty,
            .timer3_c => regs.TC3.OCR3C.* = duty,
            .timer4_a => regs.TC4.OCR4A.* = duty,
            .timer4_b => regs.TC4.OCR4B.* = duty,
            .timer4_c => regs.TC4.OCR4C.* = duty,
            .timer5_a => regs.TC5.OCR5A.* = duty,
            .timer5_b => regs.TC5.OCR5B.* = duty,
            .timer5_c => regs.TC5.OCR5C.* = duty,
        }
    }
}

fn channelForPin(comptime pin: gpio.Pin) platform.PwmChannel {
    if (platform.pwmChannel(pin)) |channel| {
        return channel;
    }

    if (platform.usesReservedTimer0Pwm(pin)) {
        @compileError("pwm: selected pin uses Timer0, which is reserved by hal.time");
    }

    @compileError("pwm: unsupported pin for the selected board");
}

fn ensureTimer1() void {
    if (timer1_initialized) return;

    regs.TC1.TCCR1B.modify(.{ .CS1 = 0, .WGM1 = 0b01 });
    regs.TC1.TCCR1A.modify(.{ .WGM1 = 0b01 });
    regs.TC1.TCNT1.* = 0;
    regs.TC1.OCR1A.* = 0;
    regs.TC1.OCR1B.* = 0;
    if (comptime platform.current_board == .mega2560) {
        regs.TC1.OCR1C.* = 0;
    }
    regs.TC1.TCCR1B.modify(.{ .CS1 = timer1_clock_select, .WGM1 = 0b01 });
    timer1_initialized = true;
}

fn ensureTimer3() void {
    if (timer3_initialized) return;

    regs.TC3.TCCR3B.modify(.{ .CS3 = 0, .WGM3 = 0b01 });
    regs.TC3.TCCR3A.modify(.{ .WGM3 = 0b01 });
    regs.TC3.TCNT3.* = 0;
    regs.TC3.OCR3A.* = 0;
    regs.TC3.OCR3B.* = 0;
    regs.TC3.OCR3C.* = 0;
    regs.TC3.TCCR3B.modify(.{ .CS3 = timer1_clock_select, .WGM3 = 0b01 });
    timer3_initialized = true;
}

fn ensureTimer4() void {
    if (timer4_initialized) return;

    regs.TC4.TCCR4B.modify(.{ .CS4 = 0, .WGM4 = 0b01 });
    regs.TC4.TCCR4A.modify(.{ .WGM4 = 0b01 });
    regs.TC4.TCNT4.* = 0;
    regs.TC4.OCR4A.* = 0;
    regs.TC4.OCR4B.* = 0;
    regs.TC4.OCR4C.* = 0;
    regs.TC4.TCCR4B.modify(.{ .CS4 = timer1_clock_select, .WGM4 = 0b01 });
    timer4_initialized = true;
}

fn ensureTimer5() void {
    if (timer5_initialized) return;

    regs.TC5.TCCR5B.modify(.{ .CS5 = 0, .WGM5 = 0b01 });
    regs.TC5.TCCR5A.modify(.{ .WGM5 = 0b01 });
    regs.TC5.TCNT5.* = 0;
    regs.TC5.OCR5A.* = 0;
    regs.TC5.OCR5B.* = 0;
    regs.TC5.OCR5C.* = 0;
    regs.TC5.TCCR5B.modify(.{ .CS5 = timer1_clock_select, .WGM5 = 0b01 });
    timer5_initialized = true;
}

fn ensureTimer2() void {
    if (timer2_initialized) return;

    regs.TC2.ASSR.modify(.{ .AS2 = 0, .EXCLK = 0 });
    regs.TC2.TCCR2B.modify(.{ .CS2 = 0, .WGM22 = 0 });
    regs.TC2.TCCR2A.modify(.{ .WGM2 = 0b11 });
    regs.TC2.TCNT2.* = 0;
    regs.TC2.OCR2A.* = 0;
    regs.TC2.OCR2B.* = 0;
    regs.TC2.TCCR2B.modify(.{ .CS2 = timer2_clock_select, .WGM22 = 0 });
    timer2_initialized = true;
}

fn enableChannel(channel: platform.PwmChannel) void {
    if (platform.current_board != .mega2560) {
        switch (channel) {
            .timer1_a => regs.TC1.TCCR1A.modify(.{ .COM1A = non_inverting_compare_output }),
            .timer1_b => regs.TC1.TCCR1A.modify(.{ .COM1B = non_inverting_compare_output }),
            .timer2_a => regs.TC2.TCCR2A.modify(.{ .COM2A = non_inverting_compare_output }),
            .timer2_b => regs.TC2.TCCR2A.modify(.{ .COM2B = non_inverting_compare_output }),
            else => unreachable,
        }
    } else {
        switch (channel) {
            .timer1_a => regs.TC1.TCCR1A.modify(.{ .COM1A = non_inverting_compare_output }),
            .timer1_b => regs.TC1.TCCR1A.modify(.{ .COM1B = non_inverting_compare_output }),
            .timer1_c => regs.TC1.TCCR1A.modify(.{ .COM1C = non_inverting_compare_output }),
            .timer2_a => regs.TC2.TCCR2A.modify(.{ .COM2A = non_inverting_compare_output }),
            .timer2_b => regs.TC2.TCCR2A.modify(.{ .COM2B = non_inverting_compare_output }),
            .timer3_a => regs.TC3.TCCR3A.modify(.{ .COM3A = non_inverting_compare_output }),
            .timer3_b => regs.TC3.TCCR3A.modify(.{ .COM3B = non_inverting_compare_output }),
            .timer3_c => regs.TC3.TCCR3A.modify(.{ .COM3C = non_inverting_compare_output }),
            .timer4_a => regs.TC4.TCCR4A.modify(.{ .COM4A = non_inverting_compare_output }),
            .timer4_b => regs.TC4.TCCR4A.modify(.{ .COM4B = non_inverting_compare_output }),
            .timer4_c => regs.TC4.TCCR4A.modify(.{ .COM4C = non_inverting_compare_output }),
            .timer5_a => regs.TC5.TCCR5A.modify(.{ .COM5A = non_inverting_compare_output }),
            .timer5_b => regs.TC5.TCCR5A.modify(.{ .COM5B = non_inverting_compare_output }),
            .timer5_c => regs.TC5.TCCR5A.modify(.{ .COM5C = non_inverting_compare_output }),
        }
    }
}
