const builtin = @import("builtin");
const std = @import("std");
const avr = @import("avr_zig");
const pwm = avr.pwm;
const time = avr.time;

const pwm_pin: avr.gpio.Pin = if (std.mem.eql(u8, builtin.target.cpu.model.name, "atmega2560")) .D46 else .D9;

pub fn main() void {
    pwm.init(pwm_pin);

    var duty: u8 = 0;
    var rising = true;

    while (true) {
        pwm.write(pwm_pin, duty);
        time.sleep(4);

        if (rising) {
            if (duty == pwm.max_duty) {
                rising = false;
            } else {
                duty += 1;
            }
        } else {
            if (duty == 0) {
                rising = true;
            } else {
                duty -= 1;
            }
        }
    }
}
