const regs = @import("atmega328p.zig").registers;

pub const CPU_FREQ = 16000000;

const TIMER0_PRESCALER = 64;
const TIMER0_COMPARE = (CPU_FREQ / TIMER0_PRESCALER / 1000) - 1;

comptime {
    if (TIMER0_COMPARE > 255) {
        @compileError("Timer0 compare value does not fit in 8 bits");
    }
}

const SleepMode = enum(u3) {
    idle = 0,
    adc_noise_reduction = 1,
    power_down = 2,
    power_save = 3,
    standby = 6,
    extended_standby = 7,
};

var timer0_initialized = false;
var tick_ms: u32 = 0;

pub fn sleep(ms: u32) void {
    if (ms == 0) return;

    ensureTimer0Tick();

    const start = millis();
    while (millis() -% start < ms) {
        sleepUntilInterrupt(.idle);
    }
}

pub fn millis() u32 {
    const interrupts_were_enabled = interruptsEnabled();
    cli();
    const now = tick_ms;
    if (interrupts_were_enabled) {
        sei();
    }
    return now;
}

pub fn handleTimer0CompareA() void {
    tick_ms +%= 1;
}

fn ensureTimer0Tick() void {
    if (timer0_initialized) return;

    const interrupts_were_enabled = interruptsEnabled();
    cli();

    if (!timer0_initialized) {
        regs.TC0.TCCR0B.modify(.{ .CS0 = 0, .WGM02 = 0 });
        regs.TC0.TCCR0A.modify(.{ .WGM0 = 0b10, .COM0A = 0, .COM0B = 0 });
        regs.TC0.TCNT0.* = 0;
        regs.TC0.OCR0A.* = TIMER0_COMPARE;
        regs.TC0.TIFR0.modify(.{ .OCF0A = 1 });
        regs.TC0.TIMSK0.modify(.{ .OCIE0A = 1 });
        regs.TC0.TCCR0B.modify(.{ .CS0 = 0b011, .WGM02 = 0 });
        timer0_initialized = true;
    }

    if (interrupts_were_enabled) {
        sei();
    }
}

fn sleepUntilInterrupt(mode: SleepMode) void {
    const interrupts_were_enabled = interruptsEnabled();

    cli();
    regs.CPU.SMCR.modify(.{ .SM = @intFromEnum(mode), .SE = 1 });

    asm volatile ("sei\nsleep\ncli");

    regs.CPU.SMCR.modify(.{ .SE = 0 });

    if (interrupts_were_enabled) {
        sei();
    }
}

fn interruptsEnabled() bool {
    return regs.CPU.SREG.read().I == 1;
}

fn cli() void {
    asm volatile ("cli");
}

fn sei() void {
    asm volatile ("sei");
}
