fastboot flash modem NON-HLOS.bin
fastboot flash sbl1 sbl1.mbn
fastboot flash sbl1bak sbl1.mbn
fastboot flash rpm rpm.mbn
fastboot flash rpmbak rpm.mbn
fastboot flash tz tz.mbn
fastboot flash tzbak tz.mbn
fastboot flash sec sec.dat
fastboot flash devcfg devcfg.mbn
fastboot flash cmnlib cmnlib.mbn
fastboot flash cmnlibbak cmnlib.mbn
fastboot flash keymaster keymaster64.mbn
fastboot flash keymasterbak keymaster64.mbn

fastboot flash aboot emmc_appsboot.mbn
fastboot flash abootbak emmc_appsboot.mbn
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash recovery recovery.img
fastboot flash cache cache.img
fastboot flash persist persist.img
fastboot flash userdata userdata.img
fastboot flash vendor vendor.img
fastboot reboot

$NOTIFY "======================================="
$NOTIFY "Flash All finished Time $(date +%H:%M:%S)"
$NOTIFY "======================================="
