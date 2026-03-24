const avr = @import("avr_zig");
const time = avr.hal.time;
const uart = avr.hal.uart;

pub fn main() void {
    var current: u8 = 'A';
    var counter: u16 = 0;
    uart.init(115200);

    while (true) {
        uart.write("UART example: ");
        uart.write_ch(current);
        uart.write(" code=");
        uart.write(current);
        uart.write(" count=");
        uart.write(counter);
        uart.write(" upper_half=");
        uart.write(current > 'M');
        uart.write(" volts=");
        uart.write(@as(f32, 3.14));
        uart.write("\r\n");

        current = if (current == 'Z') 'A' else current + 1;
        counter +%= 1;
        time.sleep(1000);
    }
}
