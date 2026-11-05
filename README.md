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

The newly compiled output differs from the archived image because a different compiler was used. Archived release files are preserved unchanged. No hardware was modified or operated during this import.

Original copyright and vendor license notices are retained. This import grants no additional license to project-specific source code.
