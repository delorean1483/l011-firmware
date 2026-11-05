# l011-firmware

Standalone L011 firmware source imported from `delorean1483/g0b1-firmware` commit `5d657284e42197968baf3eb8fdd33320d463ea74`.

## Build

With Arm GNU `arm-none-eabi-gcc` on PATH:

```sh
make -C heater-coproc/port/l011
```

On Windows PowerShell:

```powershell
./build-windows.ps1 -ToolchainBin 'C:/path/to/arm-toolchain/bin'
```

Build outputs are written to `heater-coproc/port/l011/build/`.
The Windows release build passed with GCC 14.3.1 and warnings treated as errors.

## Files

- `heater-coproc/`: firmware core and platform port.
- `heater-common/`: shared firmware definitions and codecs.
- `cube/Drivers/CMSIS/`: build dependencies, with their license notices.
- `releases/5d65728/`: original firmware image and debug artifacts, with checksums.
- `PROVENANCE.json`: import and artifact identities.
- `docs/heater-coprocessor.md`: bring-up documentation.
- `docs/superpowers/specs/2026-10-06-heater-coprocessor-design.md`: full hardware and firmware design specification.

The newly compiled output differs from the archived image because a different compiler was used. Archived release files are preserved unchanged. No hardware was modified or operated during this import.

Original copyright and vendor license notices are retained. This import grants no additional license to project-specific source code.

## Bench handoff snapshot — November 5, 2026, 16:10 Central

These are recorded handoff observations, not a new live hardware check.

- L011 firmware: source build `5d65728`; the 16 MHz clock and no-watchdog-reset M1 checks passed.
- Heater type was forced to VEVOR in EEPROM (G0B1 register 74 = 1). It survives reflashing; 255 restores auto-detection.
- The firmware sent STOP-only polls every second at 4800 baud, with run request zero. The heater was powered, its panel unplugged, and its data wire connected to HDR3.
- Heater RX (PA0) read low continuously: no valid replies, increasing echo errors, and line sense 0x00. Manually enabling the +5 V heater output did not restore a high RX idle level; it was then restored off.
- The shared I2C bus could jam when the lamp lit, disrupting both lamp and heater communication. Both SCL-low and SDA-low patterns were measured. The G0B1 firmware lacked bus recovery at handoff.
- The lamp was off; its channel mapping, polarity and zero-is-dark checks had passed.
- `gobi-agent` was deliberately stopped so bench scripts owned RS-485.
- M2 (scope PA6 MODE, PA7 nEN and PB1 PWR from power-on) and the `htr_board.h` schematic checklist were not completed; further bring-up remained pending.

Do not start the heater during diagnostic bring-up. Heater run request is G0B1 register 53; scope and wiring checks are documented in the bring-up and design documents. No flashing, service start, heater start or reset was performed for this documentation update.
