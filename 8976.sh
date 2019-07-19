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
