# Embedded Rust Patterns

## no_std Environment

```rust
#![no_std]
#![no_main]

use cortex_m_rt::entry;
use panic_halt as _; // halt on panic (no unwinding in embedded)

#[entry]
fn main() -> ! {
    let peripherals = pac::Peripherals::take().unwrap();
    // setup...
    loop {
        // main loop
    }
}
```

## Embassy Async Framework

```rust
use embassy_executor::Spawner;
use embassy_time::{Duration, Timer};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_stm32::init(Default::default());
    spawner.spawn(telemetry_task(p.ADC1)).unwrap();
    spawner.spawn(mqtt_task(p.USART1)).unwrap();
}

#[embassy_executor::task]
async fn telemetry_task(adc: ADC1) {
    loop {
        let reading = adc.read().await;
        TELEMETRY_CHANNEL.send(reading).await;
        Timer::after(Duration::from_secs(30)).await;
    }
}
```

## PAC / HAL Layers

```
PAC (Peripheral Access Crate)  — raw register access, auto-generated
  ↓
HAL (Hardware Abstraction Layer) — safe Rust API over PAC
  ↓
BSP (Board Support Package)    — board-specific pin mappings
```

Use HAL, not PAC directly. PAC is for HAL implementors.

## Sensor Reading Pattern

```rust
use embedded_hal::i2c::I2c;

struct Bme280<I2C> { i2c: I2C, addr: u8 }

impl<I2C: I2c> Bme280<I2C> {
    fn read_temperature(&mut self) -> Result<f32, I2C::Error> {
        let mut buf = [0u8; 3];
        self.i2c.write_read(self.addr, &[0xFA], &mut buf)?;
        let raw = ((buf[0] as u32) << 12) | ((buf[1] as u32) << 4) | ((buf[2] as u32) >> 4);
        Ok(self.compensate_temperature(raw))
    }
}
```

## Communication Patterns

```rust
// UART (serial)
let mut uart = Uart::new(p.USART1, p.PA10, p.PA9, config);
uart.write(b"AT+MQTT\r\n").await?;

// SPI
let mut spi = Spi::new(p.SPI1, sck, mosi, miso, config);
let mut cs = Output::new(p.PA4, Level::High);
cs.set_low();
spi.transfer(&mut buf).await?;
cs.set_high();

// I2C
let mut i2c = I2c::new(p.I2C1, scl, sda, config);
i2c.write_read(0x76, &[0xD0], &mut chip_id).await?;
```

## RTIC (Real-Time Interrupt-driven Concurrency)

```rust
#[rtic::app(device = stm32f4xx_hal::pac)]
mod app {
    #[shared] struct Shared { buffer: Buffer }
    #[local] struct Local { led: Pin }

    #[init]
    fn init(ctx: init::Context) -> (Shared, Local) { ... }

    #[task(binds = TIM2, shared = [buffer])]
    fn timer_tick(mut ctx: timer_tick::Context) {
        ctx.shared.buffer.lock(|buf| buf.push(reading));
    }
}
```

## Key Rules

- **No heap allocation** unless absolutely necessary (use `heapless` crate)
- **No unwrap in production** — handle every error
- **Power management:** sleep between operations, wake on interrupt
- **Watchdog timer:** always enabled, reset in main loop
