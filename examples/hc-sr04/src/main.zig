const avr = @import("avr_zig");
const hc_sr04 = avr.hc_sr04;
const time = avr.time;
const uart = avr.uart;

const echo_pin: avr.gpio.Pin = .D6;
const trig_pin: avr.gpio.Pin = .D7;

pub fn main() void {
    uart.init(115200);
    hc_sr04.init(echo_pin, trig_pin);
    uart.write("HC-SR04 example echo=D6 trig=D7\r\n");

    while (true) {
        const reading = hc_sr04.read(echo_pin, trig_pin) catch |err| {
            uart.write("read failed: ");
            uart.write(@errorName(err));
            uart.write("\r\n");
            time.sleep(250);
            continue;
        };

        uart.write("distance=");
        writeDistanceCm(reading.distance_cm);
        uart.write("cm\r\n");
        time.sleep(250);
    }
}

fn writeDistanceCm(value: u16) void {
    if (value >= 400) {
        uart.write("400");
        return;
    }

    if (value >= 300) {
        uart.write_ch('3');
        writeTwoDigits(@as(u8, @intCast(value - 300)));
        return;
    }

    if (value >= 200) {
        uart.write_ch('2');
        writeTwoDigits(@as(u8, @intCast(value - 200)));
        return;
    }

    if (value >= 100) {
        uart.write_ch('1');
        writeTwoDigits(@as(u8, @intCast(value - 100)));
        return;
    }

    writeDecimal(@as(u8, @intCast(value)));
}

fn writeDecimal(value: u8) void {
    var hundreds: u8 = 0;
    var tens: u8 = 0;
    var ones = value;

    while (ones >= 100) {
        hundreds +%= 1;
        ones -= 100;
    }
    while (ones >= 10) {
        tens +%= 1;
        ones -= 10;
    }

    if (hundreds != 0) {
        uart.write_ch('0' + hundreds);
        uart.write_ch('0' + tens);
        uart.write_ch('0' + ones);
        return;
    }

    if (tens != 0) {
        uart.write_ch('0' + tens);
        uart.write_ch('0' + ones);
        return;
    }

    uart.write_ch('0' + ones);
}

fn writeTwoDigits(value: u8) void {
    var tens: u8 = 0;
    var ones = value;

    while (ones >= 10) {
        tens +%= 1;
        ones -= 10;
    }

    uart.write_ch('0' + tens);
    uart.write_ch('0' + ones);
}
