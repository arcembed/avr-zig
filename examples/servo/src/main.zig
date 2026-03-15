const avr = @import("avr_zig");
const servo = avr.drivers.actuator.servo;
const time = avr.time;

const positions = [_]u8{ 0, 90, 180, 90 };

pub fn main() void {
    servo.init(.D9);

    while (true) {
        inline for (positions) |position| {
            servo.writeDegrees(.D9, position);
            time.sleep(900);
        }
    }
}
