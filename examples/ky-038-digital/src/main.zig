const avr = @import("avr_zig");
const gpio = avr.gpio;
const ky_038 = avr.drivers.sensor.ky_038;
const time = avr.time;
const uart = avr.uart;

const digital_pin: avr.gpio.Pin = .D2;
const led_pin: avr.gpio.Pin = .D13;
// Common KY-038 breakout boards drive DO low when the sound threshold trips.
const digital_active_level: ky_038.ActiveLevel = .low;

pub fn main() void {
    uart.init(115200);
    uart.write("KY-038 digital example DO=D2 LED=D13\r\n");

    ky_038.initDigital(digital_pin, false);
    gpio.init(led_pin, .out);

    var detected = ky_038.isSoundDetected(digital_pin, digital_active_level);
    gpio.write(led_pin, detected);
    reportState(detected);

    while (true) {
        const sample = ky_038.isSoundDetected(digital_pin, digital_active_level);
        if (sample != detected) {
            detected = sample;
            gpio.write(led_pin, detected);
            reportState(detected);
        }
        time.sleep(10);
    }
}

fn reportState(detected: bool) void {
    uart.write("digital=");
    uart.write(if (detected) "sound" else "quiet");
    uart.write("\r\n");
}
