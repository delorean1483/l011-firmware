param([Parameter(Mandatory=$true)][string]$ToolchainBin)
$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$portRoot = Join-Path $repoRoot 'heater-coproc/port/l011'
$buildRoot = Join-Path $portRoot 'build'
New-Item -ItemType Directory -Force "$buildRoot/obj" | Out-Null
$cc = Join-Path $ToolchainBin 'arm-none-eabi-gcc.exe'
$copy = Join-Path $ToolchainBin 'arm-none-eabi-objcopy.exe'
$size = Join-Path $ToolchainBin 'arm-none-eabi-size.exe'
$arch = @('-mcpu=cortex-m0plus','-mthumb','-mfloat-abi=soft')
$includes = @('-I.','-I../../../heater-common','-I../../core','-Ivendor/cmsis_device','-I../../../cube/Drivers/CMSIS/Include')
$sources = @('main.c','port_sys.c','port_gpio.c','port_uart.c','port_i2c_slave.c','port_nv.c','vendor/cmsis_device/system_stm32l0xx.c','../../../heater-common/crc16_modbus.c','../../../heater-common/vevor_proto.c','../../../heater-common/autoterm_proto.c','../../core/drv_vevor.c','../../core/drv_autoterm.c','../../core/htr_iface.c','../../core/htr_fsm.c','../../core/htr_regs.c')
$objects = @()
Push-Location $portRoot
try {
  foreach($source in $sources) {
    $obj = "$buildRoot/obj/$([IO.Path]::GetFileNameWithoutExtension($source)).o"
    & $cc @arch -DSTM32L011xx @includes -std=gnu11 -Os -g3 -Wall -Wextra -Werror -funsigned-char -ffunction-sections -fdata-sections -c $source -o $obj
    if($LASTEXITCODE -ne 0){throw "Compilation failed: $source"}
    $objects += $obj
  }
  $startup = "$buildRoot/obj/startup_stm32l011xx.o"
  & $cc @arch -x assembler-with-cpp -g3 -c vendor/cmsis_device/startup_stm32l011xx.s -o $startup
  if($LASTEXITCODE -ne 0){throw 'Startup compilation failed'}
  $objects += $startup
  $elf = "$buildRoot/heater-l011.elf"
  & $cc @objects @arch -T l011.ld --specs=nano.specs --specs=nosys.specs -nostartfiles '-Wl,--gc-sections' "-Wl,-Map=$buildRoot/heater-l011.map" '-Wl,--print-memory-usage' '-Wl,--no-warn-rwx-segments' -o $elf
  if($LASTEXITCODE -ne 0){throw 'Link failed'}
  & $copy -O binary $elf "$buildRoot/heater-l011.bin"
  if($LASTEXITCODE -ne 0){throw 'Binary conversion failed'}
  & $copy -O ihex $elf "$buildRoot/heater-l011.hex"
  if($LASTEXITCODE -ne 0){throw 'HEX conversion failed'}
  $sections = & $size -A $elf
  $flashBytes=0; $ramBytes=0
  foreach($line in $sections) {
    if($line -match '^\.(isr_vector|text|rodata|data|ARM.exidx|preinit_array|init_array|fini_array)\s+(\d+)'){$flashBytes += [int]$matches[2]}
    if($line -match '^\.(data|bss|_user_stack)\s+(\d+)'){$ramBytes += [int]$matches[2]}
  }
  if($flashBytes -gt 16384 -or $ramBytes -gt 2048){throw 'Memory budget exceeded'}
  Write-Output "Flash $flashBytes / 16384 bytes; RAM (including stack) $ramBytes / 2048 bytes"
} finally { Pop-Location }
