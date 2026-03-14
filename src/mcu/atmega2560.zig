// this file was generated from Microchip ATmega DFP data
// source: https://github.com/apcountryman/dfp-microchip-atmega/blob/main/dfp/atdf/ATmega2560.atdf
//
// vendor: Atmel
// device: ATmega2560
// cpu: AVR8

pub const VectorTable = extern struct {
    RESET: InterruptVector = unhandled,
    INT0: InterruptVector = unhandled,
    INT1: InterruptVector = unhandled,
    INT2: InterruptVector = unhandled,
    INT3: InterruptVector = unhandled,
    INT4: InterruptVector = unhandled,
    INT5: InterruptVector = unhandled,
    INT6: InterruptVector = unhandled,
    INT7: InterruptVector = unhandled,
    PCINT0: InterruptVector = unhandled,
    PCINT1: InterruptVector = unhandled,
    PCINT2: InterruptVector = unhandled,
    WDT: InterruptVector = unhandled,
    TIMER2_COMPA: InterruptVector = unhandled,
    TIMER2_COMPB: InterruptVector = unhandled,
    TIMER2_OVF: InterruptVector = unhandled,
    TIMER1_CAPT: InterruptVector = unhandled,
    TIMER1_COMPA: InterruptVector = unhandled,
    TIMER1_COMPB: InterruptVector = unhandled,
    TIMER1_COMPC: InterruptVector = unhandled,
    TIMER1_OVF: InterruptVector = unhandled,
    TIMER0_COMPA: InterruptVector = unhandled,
    TIMER0_COMPB: InterruptVector = unhandled,
    TIMER0_OVF: InterruptVector = unhandled,
    SPI_STC: InterruptVector = unhandled,
    USART0_RX: InterruptVector = unhandled,
    USART0_UDRE: InterruptVector = unhandled,
    USART0_TX: InterruptVector = unhandled,
    ANALOG_COMP: InterruptVector = unhandled,
    ADC: InterruptVector = unhandled,
    EE_READY: InterruptVector = unhandled,
    TIMER3_CAPT: InterruptVector = unhandled,
    TIMER3_COMPA: InterruptVector = unhandled,
    TIMER3_COMPB: InterruptVector = unhandled,
    TIMER3_COMPC: InterruptVector = unhandled,
    TIMER3_OVF: InterruptVector = unhandled,
    USART1_RX: InterruptVector = unhandled,
    USART1_UDRE: InterruptVector = unhandled,
    USART1_TX: InterruptVector = unhandled,
    TWI: InterruptVector = unhandled,
    SPM_READY: InterruptVector = unhandled,
    TIMER4_CAPT: InterruptVector = unhandled,
    TIMER4_COMPA: InterruptVector = unhandled,
    TIMER4_COMPB: InterruptVector = unhandled,
    TIMER4_COMPC: InterruptVector = unhandled,
    TIMER4_OVF: InterruptVector = unhandled,
    TIMER5_CAPT: InterruptVector = unhandled,
    TIMER5_COMPA: InterruptVector = unhandled,
    TIMER5_COMPB: InterruptVector = unhandled,
    TIMER5_COMPC: InterruptVector = unhandled,
    TIMER5_OVF: InterruptVector = unhandled,
    USART2_RX: InterruptVector = unhandled,
    USART2_UDRE: InterruptVector = unhandled,
    USART2_TX: InterruptVector = unhandled,
    USART3_RX: InterruptVector = unhandled,
    USART3_UDRE: InterruptVector = unhandled,
    USART3_TX: InterruptVector = unhandled,
};

pub const registers = struct {
    pub const PORTA = struct {
        pub const PINA = @as(*volatile u8, @ptrFromInt(0x20));
        pub const DDRA = @as(*volatile u8, @ptrFromInt(0x21));
        pub const PORTA = @as(*volatile u8, @ptrFromInt(0x22));
    };

    pub const PORTB = struct {
        pub const PINB = @as(*volatile u8, @ptrFromInt(0x23));
        pub const DDRB = @as(*volatile u8, @ptrFromInt(0x24));
        pub const PORTB = @as(*volatile u8, @ptrFromInt(0x25));
    };

    pub const PORTC = struct {
        pub const PINC = @as(*volatile u8, @ptrFromInt(0x26));
        pub const DDRC = @as(*volatile u8, @ptrFromInt(0x27));
        pub const PORTC = @as(*volatile u8, @ptrFromInt(0x28));
    };

    pub const PORTD = struct {
        pub const PIND = @as(*volatile u8, @ptrFromInt(0x29));
        pub const DDRD = @as(*volatile u8, @ptrFromInt(0x2a));
        pub const PORTD = @as(*volatile u8, @ptrFromInt(0x2b));
    };

    pub const PORTE = struct {
        pub const PINE = @as(*volatile u8, @ptrFromInt(0x2c));
        pub const DDRE = @as(*volatile u8, @ptrFromInt(0x2d));
        pub const PORTE = @as(*volatile u8, @ptrFromInt(0x2e));
    };

    pub const PORTF = struct {
        pub const PINF = @as(*volatile u8, @ptrFromInt(0x2f));
        pub const DDRF = @as(*volatile u8, @ptrFromInt(0x30));
        pub const PORTF = @as(*volatile u8, @ptrFromInt(0x31));
    };

    pub const PORTG = struct {
        pub const PING = @as(*volatile u8, @ptrFromInt(0x32));
        pub const DDRG = @as(*volatile u8, @ptrFromInt(0x33));
        pub const PORTG = @as(*volatile u8, @ptrFromInt(0x34));
    };

    pub const TC0 = struct {
        pub const TIFR0 = @as(*volatile Mmio(8, packed struct {
            TOV0: u1,
            OCF0A: u1,
            OCF0B: u1,
            padding0: u5,
        }), @ptrFromInt(0x35));

        pub const TCCR0A = @as(*volatile Mmio(8, packed struct {
            WGM0: u2,
            reserved0: u2,
            COM0B: u2,
            COM0A: u2,
        }), @ptrFromInt(0x44));

        pub const TCCR0B = @as(*volatile Mmio(8, packed struct {
            CS0: u3,
            WGM02: u1,
            reserved0: u2,
            FOC0B: u1,
            FOC0A: u1,
        }), @ptrFromInt(0x45));

        pub const TCNT0 = @as(*volatile u8, @ptrFromInt(0x46));
        pub const OCR0A = @as(*volatile u8, @ptrFromInt(0x47));
        pub const OCR0B = @as(*volatile u8, @ptrFromInt(0x48));

        pub const TIMSK0 = @as(*volatile Mmio(8, packed struct {
            TOIE0: u1,
            OCIE0A: u1,
            OCIE0B: u1,
            padding0: u5,
        }), @ptrFromInt(0x6e));
    };

    pub const CPU = struct {
        pub const SMCR = @as(*volatile Mmio(8, packed struct {
            SE: u1,
            SM: u3,
            padding0: u4,
        }), @ptrFromInt(0x53));

        pub const SREG = @as(*volatile Mmio(8, packed struct {
            C: u1,
            Z: u1,
            N: u1,
            V: u1,
            S: u1,
            H: u1,
            T: u1,
            I: u1,
        }), @ptrFromInt(0x5f));
    };

    pub const ADC = struct {
        pub const ADC = @as(*volatile u16, @ptrFromInt(0x78));

        pub const ADCSRA = @as(*volatile Mmio(8, packed struct {
            ADPS: u3,
            ADIE: u1,
            ADIF: u1,
            ADATE: u1,
            ADSC: u1,
            ADEN: u1,
        }), @ptrFromInt(0x7a));

        pub const ADCSRB = @as(*volatile Mmio(8, packed struct {
            ADTS: u3,
            MUX5: u1,
            reserved0: u2,
            ACME: u1,
            padding0: u1,
        }), @ptrFromInt(0x7b));

        pub const ADMUX = @as(*volatile Mmio(8, packed struct {
            MUX: u5,
            ADLAR: u1,
            REFS: u2,
        }), @ptrFromInt(0x7c));

        pub const DIDR2 = @as(*volatile Mmio(8, packed struct {
            ADC8D: u1,
            ADC9D: u1,
            ADC10D: u1,
            ADC11D: u1,
            ADC12D: u1,
            ADC13D: u1,
            ADC14D: u1,
            ADC15D: u1,
        }), @ptrFromInt(0x7d));

        pub const DIDR0 = @as(*volatile Mmio(8, packed struct {
            ADC0D: u1,
            ADC1D: u1,
            ADC2D: u1,
            ADC3D: u1,
            ADC4D: u1,
            ADC5D: u1,
            ADC6D: u1,
            ADC7D: u1,
        }), @ptrFromInt(0x7e));
    };

    pub const TC1 = struct {
        pub const TCCR1A = @as(*volatile Mmio(8, packed struct {
            WGM1: u2,
            COM1C: u2,
            COM1B: u2,
            COM1A: u2,
        }), @ptrFromInt(0x80));

        pub const TCCR1B = @as(*volatile Mmio(8, packed struct {
            CS1: u3,
            WGM1: u2,
            reserved0: u1,
            ICES1: u1,
            ICNC1: u1,
        }), @ptrFromInt(0x81));

        pub const TCCR1C = @as(*volatile Mmio(8, packed struct {
            reserved0: u5,
            FOC1C: u1,
            FOC1B: u1,
            FOC1A: u1,
        }), @ptrFromInt(0x82));

        pub const TCNT1 = @as(*volatile u16, @ptrFromInt(0x84));
        pub const ICR1 = @as(*volatile u16, @ptrFromInt(0x86));
        pub const OCR1A = @as(*volatile u16, @ptrFromInt(0x88));
        pub const OCR1B = @as(*volatile u16, @ptrFromInt(0x8a));
        pub const OCR1C = @as(*volatile u16, @ptrFromInt(0x8c));

        pub const TIFR1 = @as(*volatile Mmio(8, packed struct {
            TOV1: u1,
            OCF1A: u1,
            OCF1B: u1,
            OCF1C: u1,
            reserved0: u1,
            ICF1: u1,
            padding0: u2,
        }), @ptrFromInt(0x36));
    };

    pub const TC3 = struct {
        pub const TCCR3A = @as(*volatile Mmio(8, packed struct {
            WGM3: u2,
            COM3C: u2,
            COM3B: u2,
            COM3A: u2,
        }), @ptrFromInt(0x90));

        pub const TCCR3B = @as(*volatile Mmio(8, packed struct {
            CS3: u3,
            WGM3: u2,
            reserved0: u1,
            ICES3: u1,
            ICNC3: u1,
        }), @ptrFromInt(0x91));

        pub const TCCR3C = @as(*volatile Mmio(8, packed struct {
            reserved0: u5,
            FOC3C: u1,
            FOC3B: u1,
            FOC3A: u1,
        }), @ptrFromInt(0x92));

        pub const TCNT3 = @as(*volatile u16, @ptrFromInt(0x94));
        pub const ICR3 = @as(*volatile u16, @ptrFromInt(0x96));
        pub const OCR3A = @as(*volatile u16, @ptrFromInt(0x98));
        pub const OCR3B = @as(*volatile u16, @ptrFromInt(0x9a));
        pub const OCR3C = @as(*volatile u16, @ptrFromInt(0x9c));

        pub const TIFR3 = @as(*volatile Mmio(8, packed struct {
            TOV3: u1,
            OCF3A: u1,
            OCF3B: u1,
            OCF3C: u1,
            reserved0: u1,
            ICF3: u1,
            padding0: u2,
        }), @ptrFromInt(0x38));
    };

    pub const TC4 = struct {
        pub const TCCR4A = @as(*volatile Mmio(8, packed struct {
            WGM4: u2,
            COM4C: u2,
            COM4B: u2,
            COM4A: u2,
        }), @ptrFromInt(0xa0));

        pub const TCCR4B = @as(*volatile Mmio(8, packed struct {
            CS4: u3,
            WGM4: u2,
            reserved0: u1,
            ICES4: u1,
            ICNC4: u1,
        }), @ptrFromInt(0xa1));

        pub const TCCR4C = @as(*volatile Mmio(8, packed struct {
            reserved0: u5,
            FOC4C: u1,
            FOC4B: u1,
            FOC4A: u1,
        }), @ptrFromInt(0xa2));

        pub const TCNT4 = @as(*volatile u16, @ptrFromInt(0xa4));
        pub const ICR4 = @as(*volatile u16, @ptrFromInt(0xa6));
        pub const OCR4A = @as(*volatile u16, @ptrFromInt(0xa8));
        pub const OCR4B = @as(*volatile u16, @ptrFromInt(0xaa));
        pub const OCR4C = @as(*volatile u16, @ptrFromInt(0xac));

        pub const TIFR4 = @as(*volatile Mmio(8, packed struct {
            TOV4: u1,
            OCF4A: u1,
            OCF4B: u1,
            OCF4C: u1,
            reserved0: u1,
            ICF4: u1,
            padding0: u2,
        }), @ptrFromInt(0x39));
    };

    pub const TC2 = struct {
        pub const TCCR2A = @as(*volatile Mmio(8, packed struct {
            WGM2: u2,
            reserved0: u2,
            COM2B: u2,
            COM2A: u2,
        }), @ptrFromInt(0xb0));

        pub const TCCR2B = @as(*volatile Mmio(8, packed struct {
            CS2: u3,
            WGM22: u1,
            reserved0: u2,
            FOC2B: u1,
            FOC2A: u1,
        }), @ptrFromInt(0xb1));

        pub const TCNT2 = @as(*volatile u8, @ptrFromInt(0xb2));
        pub const OCR2A = @as(*volatile u8, @ptrFromInt(0xb3));
        pub const OCR2B = @as(*volatile u8, @ptrFromInt(0xb4));

        pub const ASSR = @as(*volatile Mmio(8, packed struct {
            TCR2BUB: u1,
            TCR2AUB: u1,
            OCR2BUB: u1,
            OCR2AUB: u1,
            TCN2UB: u1,
            AS2: u1,
            EXCLK: u1,
            padding0: u1,
        }), @ptrFromInt(0xb6));
    };

    pub const TWI = struct {
        pub const TWBR = @as(*volatile u8, @ptrFromInt(0xb8));

        pub const TWSR = @as(*volatile Mmio(8, packed struct {
            TWPS: u2,
            reserved0: u1,
            TWS: u5,
        }), @ptrFromInt(0xb9));

        pub const TWAR = @as(*volatile u8, @ptrFromInt(0xba));
        pub const TWDR = @as(*volatile u8, @ptrFromInt(0xbb));

        pub const TWCR = @as(*volatile Mmio(8, packed struct {
            TWIE: u1,
            reserved0: u1,
            TWEN: u1,
            TWWC: u1,
            TWSTO: u1,
            TWSTA: u1,
            TWEA: u1,
            TWINT: u1,
        }), @ptrFromInt(0xbc));
    };

    pub const USART0 = struct {
        pub const UCSR0A = @as(*volatile Mmio(8, packed struct {
            MPCM0: u1,
            U2X0: u1,
            UPE0: u1,
            DOR0: u1,
            FE0: u1,
            UDRE0: u1,
            TXC0: u1,
            RXC0: u1,
        }), @ptrFromInt(0xc0));

        pub const UCSR0B = @as(*volatile Mmio(8, packed struct {
            TXB80: u1,
            RXB80: u1,
            UCSZ02: u1,
            TXEN0: u1,
            RXEN0: u1,
            UDRIE0: u1,
            TXCIE0: u1,
            RXCIE0: u1,
        }), @ptrFromInt(0xc1));

        pub const UCSR0C = @as(*volatile Mmio(8, packed struct {
            UCPOL0: u1,
            UCSZ0: u2,
            USBS0: u1,
            UPM0: u2,
            UMSEL0: u2,
        }), @ptrFromInt(0xc2));

        pub const UBRR0 = @as(*volatile u16, @ptrFromInt(0xc4));
        pub const UDR0 = @as(*volatile u8, @ptrFromInt(0xc6));
    };

    pub const PORTH = struct {
        pub const PINH = @as(*volatile u8, @ptrFromInt(0x100));
        pub const DDRH = @as(*volatile u8, @ptrFromInt(0x101));
        pub const PORTH = @as(*volatile u8, @ptrFromInt(0x102));
    };

    pub const PORTJ = struct {
        pub const PINJ = @as(*volatile u8, @ptrFromInt(0x103));
        pub const DDRJ = @as(*volatile u8, @ptrFromInt(0x104));
        pub const PORTJ = @as(*volatile u8, @ptrFromInt(0x105));
    };

    pub const PORTK = struct {
        pub const PINK = @as(*volatile u8, @ptrFromInt(0x106));
        pub const DDRK = @as(*volatile u8, @ptrFromInt(0x107));
        pub const PORTK = @as(*volatile u8, @ptrFromInt(0x108));
    };

    pub const PORTL = struct {
        pub const PINL = @as(*volatile u8, @ptrFromInt(0x109));
        pub const DDRL = @as(*volatile u8, @ptrFromInt(0x10a));
        pub const PORTL = @as(*volatile u8, @ptrFromInt(0x10b));
    };

    pub const TC5 = struct {
        pub const TCCR5A = @as(*volatile Mmio(8, packed struct {
            WGM5: u2,
            COM5C: u2,
            COM5B: u2,
            COM5A: u2,
        }), @ptrFromInt(0x120));

        pub const TCCR5B = @as(*volatile Mmio(8, packed struct {
            CS5: u3,
            WGM5: u2,
            reserved0: u1,
            ICES5: u1,
            ICNC5: u1,
        }), @ptrFromInt(0x121));

        pub const TCCR5C = @as(*volatile Mmio(8, packed struct {
            reserved0: u5,
            FOC5C: u1,
            FOC5B: u1,
            FOC5A: u1,
        }), @ptrFromInt(0x122));

        pub const TCNT5 = @as(*volatile u16, @ptrFromInt(0x124));
        pub const ICR5 = @as(*volatile u16, @ptrFromInt(0x126));
        pub const OCR5A = @as(*volatile u16, @ptrFromInt(0x128));
        pub const OCR5B = @as(*volatile u16, @ptrFromInt(0x12a));
        pub const OCR5C = @as(*volatile u16, @ptrFromInt(0x12c));

        pub const TIFR5 = @as(*volatile Mmio(8, packed struct {
            TOV5: u1,
            OCF5A: u1,
            OCF5B: u1,
            OCF5C: u1,
            reserved0: u1,
            ICF5: u1,
            padding0: u2,
        }), @ptrFromInt(0x3a));
    };

    pub const SPI = struct {
        pub const SPCR = @as(*volatile Mmio(8, packed struct {
            SPR: u2,
            CPHA: u1,
            CPOL: u1,
            MSTR: u1,
            DORD: u1,
            SPE: u1,
            SPIE: u1,
        }), @ptrFromInt(0x4c));

        pub const SPSR = @as(*volatile Mmio(8, packed struct {
            SPI2X: u1,
            reserved0: u5,
            WCOL: u1,
            SPIF: u1,
        }), @ptrFromInt(0x4d));

        pub const SPDR = @as(*volatile u8, @ptrFromInt(0x4e));
    };
};

const std = @import("std");

pub fn mmio(addr: usize, comptime size: u8, comptime PackedT: type) *volatile Mmio(size, PackedT) {
    return @as(*volatile Mmio(size, PackedT), @ptrFromInt(addr));
}

pub fn Mmio(comptime size: u8, comptime PackedT: type) type {
    if ((size % 8) != 0) @compileError("size must be divisible by 8!");
    if (!std.math.isPowerOfTwo(size / 8)) @compileError("size must encode a power of two number of bytes!");

    const IntT = std.meta.Int(.unsigned, size);
    if (@sizeOf(PackedT) != (size / 8)) {
        @compileError(std.fmt.comptimePrint(
            "IntT and PackedT must have the same size!, they are {} and {} bytes respectively",
            .{ size / 8, @sizeOf(PackedT) },
        ));
    }

    return extern struct {
        const Self = @This();

        raw: IntT,

        pub const underlying_type = PackedT;

        pub inline fn read(addr: *volatile Self) PackedT {
            return @as(PackedT, @bitCast(addr.raw));
        }

        pub inline fn write(addr: *volatile Self, val: PackedT) void {
            const tmp = @as(IntT, @bitCast(val));
            addr.raw = tmp;
        }

        pub inline fn modify(addr: *volatile Self, fields: anytype) void {
            var val = read(addr);
            inline for (@typeInfo(@TypeOf(fields)).@"struct".fields) |field| {
                @field(val, field.name) = @field(fields, field.name);
            }
            write(addr, val);
        }

        pub inline fn toggle(addr: *volatile Self, fields: anytype) void {
            var val = read(addr);
            inline for (@typeInfo(@TypeOf(fields)).@"struct".fields) |field| {
                @field(val, @tagName(field.default_value.?)) = !@field(val, @tagName(field.default_value.?));
            }
            write(addr, val);
        }
    };
}

pub fn MmioInt(comptime size: u8, comptime T: type) type {
    return extern struct {
        const Self = @This();

        raw: std.meta.Int(.unsigned, size),

        pub inline fn read(addr: *volatile Self) T {
            return @as(T, @truncate(addr.raw));
        }

        pub inline fn modify(addr: *volatile Self, val: T) void {
            const Int = std.meta.Int(.unsigned, size);
            const mask = ~@as(Int, (1 << @bitSizeOf(T)) - 1);

            const tmp = addr.raw;
            addr.raw = (tmp & mask) | val;
        }
    };
}

pub fn mmioInt(addr: usize, comptime size: usize, comptime T: type) *volatile MmioInt(size, T) {
    return @as(*volatile MmioInt(size, T), @ptrFromInt(addr));
}

const InterruptVector = extern union {
    C: *const fn () callconv(.c) void,
    Naked: *const fn () callconv(.naked) void,
};

const unhandled = InterruptVector{
    .C = &(struct {
        fn tmp() callconv(.c) noreturn {
            @panic("unhandled interrupt");
        }
    }.tmp),
};
