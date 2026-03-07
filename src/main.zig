const uart = @import("uart.zig");
const gpio = @import("gpio.zig");
const i2c = @import("i2c.zig");
const ssd1306 = @import("ssd1306.zig");
const uno = @import("uno.zig");

const Display128x64 = ssd1306.Display(128, 64);

// This is put in the data section
var ch: u8 = '!';
var display: Display128x64 = .{};

// This ends up in the bss section
var bss_stuff: [9]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

// Put public functions here named after interrupts to instantiate them as
// interrupt handlers. If you name one incorrectly you'll get a compiler error
// with the full list of options.
pub const interrupts = struct {
    pub fn TIMER0_COMPA() void {
        uno.handleTimer0CompareA();
    }
};

pub fn main() void {
    uart.init(115200);

    i2c.init();
    scanI2cBus();
    initDisplay();

    if (bss_stuff[0] == 0)
        uart.write("Ahh its actually zero!\r\n");

    const hello = "\r\nhello\r\n";
    inline for (0..bss_stuff.len) |index| {
        bss_stuff[index] = hello[index];
    }
    uart.write(&bss_stuff);

    gpio.init(.D13, .out);
    gpio.init(.A0, .out);

    while (true) {
        uart.write_ch(ch);
        if (ch < '~') {
            ch += 1;
        } else {
            ch = '!';
            uart.write("\r\n");
        }

        gpio.toggle(.D13);
        gpio.toggle(.A0);
        uno.sleep(500);
    }
}

fn initDisplay() void {
    if (!display.init()) {
        uart.write("SSD1306 init failed\r\n");
        return;
    }

    display.clear(.off);
    display.drawPixel(64, 32, .on);
    display.drawLine(0, 0, 127, 63, .on);
    display.drawLine(0, 63, 127, 0, .on);
    display.drawLine(0, 0, 127, 0, .on);
    display.drawLine(0, 63, 127, 63, .on);
    display.drawLine(0, 0, 0, 63, .on);
    display.drawLine(127, 0, 127, 63, .on);

    if (display.present()) {
        uart.write("SSD1306 demo drawn\r\n");
    } else {
        uart.write("SSD1306 update failed\r\n");
    }
}

fn scanI2cBus() void {
    uart.write("I2C scan:\r\n");
    const count = i2c.scan(reportI2cDevice);
    if (count == 0) {
        uart.write("  no devices found\r\n");
    }
}

fn reportI2cDevice(address: u7) void {
    uart.write("  found device at 0x");
    writeHexByte(@as(u8, address));
    uart.write("\r\n");
}

fn writeHexByte(value: u8) void {
    writeHexNibble(value >> 4);
    writeHexNibble(value & 0x0f);
}

fn writeHexNibble(value: u8) void {
    const digit = if (value < 10) '0' + value else 'A' + (value - 10);
    uart.write_ch(digit);
}
