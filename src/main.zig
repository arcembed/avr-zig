const uart = @import("uart.zig");
const gpio = @import("gpio.zig");
const uno = @import("uno.zig");

// This is put in the data section
var ch: u8 = '!';

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
    uart.write("All your codebase are belong to us!\r\n\r\n");

    if (bss_stuff[0] == 0)
        uart.write("Ahh its actually zero!\r\n");

    const hello = "\r\nhello\r\n";
    inline for (0..bss_stuff.len) |index| {
        bss_stuff[index] = hello[index];
    }
    uart.write(&bss_stuff);

    gpio.init(.D13, .out);
    gpio.init(.D5, .out);

    while (true) {
        uart.write_ch(ch);
        if (ch < '~') {
            ch += 1;
        } else {
            ch = '!';
            uart.write("\r\n");
        }

        gpio.toggle(.D13);
        gpio.toggle(.D5);
        uno.sleep(500);
    }
}
