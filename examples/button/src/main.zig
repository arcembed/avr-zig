const avr = @import("avr_zig");
const gpio = avr.gpio;
const time = avr.time;
const uart = avr.uart;

const button_pin: avr.gpio.Pin = .D2;
const led_pin: avr.gpio.Pin = .D13;

pub fn main() void {
    uart.init(115200);
    gpio.init(button_pin, .in);
    gpio.setPullup(button_pin, true);
    gpio.init(led_pin, .out);

    var pressed = gpio.read(button_pin);
    gpio.write(led_pin, pressed);
    reportState(pressed);

    while (true) {
        const sample = gpio.read(button_pin);
        if (sample != pressed) {
            time.sleep(20);
            const confirmed = gpio.read(button_pin);
            if (confirmed != pressed) {
                pressed = confirmed;
                gpio.write(led_pin, pressed);
                reportState(pressed);
            }
        }
        time.sleep(10);
    }
}

fn reportState(pressed: bool) void {
    uart.write("button=");
    uart.write(if (pressed) "pressed" else "released");
    uart.write("\r\n");
}
