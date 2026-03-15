const avr = @import("avr_zig");
const ky_038 = avr.drivers.sensor.ky_038;
const time = avr.time;
const uart = avr.uart;

const analog_pin: avr.adc.AnalogPin = .A0;

pub fn main() void {
    uart.init(115200);
    uart.write("KY-038 analog example AO=A0\r\n");

    while (true) {
        const sample = ky_038.readAnalog(analog_pin);
        uart.write("analog=0x");
        writeHexWord(sample);
        uart.write("\r\n");
        time.sleep(100);
    }
}

fn writeHexWord(value: u16) void {
    writeHexNibble(@as(u8, @intCast((value >> 12) & 0x0F)));
    writeHexNibble(@as(u8, @intCast((value >> 8) & 0x0F)));
    writeHexNibble(@as(u8, @intCast((value >> 4) & 0x0F)));
    writeHexNibble(@as(u8, @intCast(value & 0x0F)));
}

fn writeHexNibble(value: u8) void {
    const digit = if (value < 10) '0' + value else 'A' + (value - 10);
    uart.write_ch(digit);
}
