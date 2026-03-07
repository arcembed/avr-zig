const avr = @import("avr_zig");
const dht11 = avr.dht11;
const time = avr.time;
const uart = avr.uart;

pub fn main() void {
    uart.init(115200);
    uart.write("DHT11 example on D4\r\n");

    while (true) {
        const reading = dht11.read(.D4) catch |err| {
            uart.write("read failed: ");
            uart.write(@errorName(err));
            uart.write("\r\n");
            time.sleep(2000);
            continue;
        };

        uart.write("humidity=");
        writeDecimal(reading.humidity);
        uart.write(".");
        writeTwoDigits(reading.humidity_decimal);
        uart.write("% temperature=");
        writeDecimal(reading.temperature);
        uart.write(".");
        writeTwoDigits(reading.temperature_decimal);
        uart.write("C\r\n");
        time.sleep(2000);
    }
}

fn writeDecimal(value: u8) void {
    var hundreds: u8 = 0;
    var tens: u8 = 0;
    var ones = value;

    while (ones >= 100) : (hundreds += 1) {
        ones -= 100;
    }
    while (ones >= 10) : (tens += 1) {
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

    while (ones >= 10) : (tens += 1) {
        ones -= 10;
    }

    uart.write_ch('0' + tens);
    uart.write_ch('0' + ones);
}
