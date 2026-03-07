const avr = @import("avr_zig");
const adc = avr.adc;
const time = avr.time;
const uart = avr.uart;

pub fn main() void {
    uart.init(115200);
    uart.write("Analog input example on A0\r\n");

    while (true) {
        const sample = adc.read(.A0);
        uart.write("A0=0x");
        writeHexWord(sample);
        uart.write("\r\n");
        time.sleep(250);
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
