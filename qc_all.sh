fastboot flash modem NON-HLOS.bin
fastboot flash sbl1 sbl1.mbn
fastboot flash sbl1bak sbl1.mbn
fastboot flash rpm rpm.mbn
fastboot flash rpmbak rpmbak.mbn
fastboot flash tz tz.mbn
fastboot flash tzbak tz.mbn
fastboot flash devcfg devcfg.mbn
fastboot flash devcfgbak devcfg.mbn
fastboot flash dsp adspso.bin
fastboot flash sec sec.dat
fastboot flash cmnlib cmnlib.mbn
fastboot flash cmnlibbak cmnlib.mbn
fastboot flash cmnlib64 cmnlib64.mbn
fastboot flash cmnlib64bak cmnlib64.mbn
fastboot flash keymaster keymaster.mbn
fastboot flash keymasterbak keymaster.mbn

fastboot flash aboot emmc_appsboot.mbn
fastboot flash abootbak emmc_appsboot.mbn
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash userdata userdata.img
fastboot flash recovery recovery.img
fastboot flash cache cache.img
fastboot flash persist persist.img
fastboot flash mdtp mdtp.img
fastboot reboot

$NOTIFY "======================================="
$NOTIFY "Flash All finished Time $(date +%H:%M:%S)"
$NOTIFY "======================================="
