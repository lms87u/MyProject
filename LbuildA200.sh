#!/bin/bash
main() {
	cleanVars
	parseArgs $@
	configUtils
	configBuildVars

	# Provide the build selection menu to the user
	displayBuildOptionsMenuAndGetSelection

	mkBinDirs
	mkLogsDir

	# Execute the build targets based on user's selection
	for num in $SELECTED; do
		case "$num" in
			"1" )
			  build_a_boot
			  $NOTIFY "======================================="
			  $NOTIFY "Build a-boot finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
			"2" )
			  # Building the kernel depends on mkimage which is built as part of u-boot
			  if [ -z $(which mkimage) ]; then
			    echo "Can't find mkimage. Have you built u-boot?"
			    exit -1
			  fi

			  build_kernel			# Also builds kernel modules
			  $NOTIFY "======================================="
			  $NOTIFY "Build Kernel finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
			"3" )
			  build_android
			  $NOTIFY "======================================="
			  $NOTIFY "Build Android finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
			"5" )
			  flash_kernel
			  $NOTIFY "======================================="
			  $NOTIFY "Flash Kernel finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
			"6" )
			  flash_android
			  $NOTIFY "======================================="
			  $NOTIFY "Flash Android finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
			"7" )
			  flash_all
			  $NOTIFY "======================================="
			  $NOTIFY "Flash All finished Time $(date +%H:%M:%S)"
			  $NOTIFY "======================================="
			  ;;
		esac
	done
}

displayBuildOptionsMenuAndGetSelection() {
	#OPT_1="a-boot"
	OPT_2="kernel"
	OPT_3="android"
	OPT_5="<flash>kernel"
	OPT_6="<flash>android"
	OPT_7="<flash>all"

	if [ -z $DIALOG ]; then
		printf "2 %s\n3 %s\n5 %s\n6 %s\n7 %s\n" \
			 $OPT_2 $OPT_3 $OPT_5 $OPT_6 $OPT_7
		printf "Please choose (You can enter several number, separated by space):\n" 
		read SELECTED
	else
		CMD="dialog --separate-output --stdout --checklist OMAP 24 80 20 \
		2 $OPT_2 off \
		3 $OPT_3 off \
		5 $OPT_5 off \
		6 $OPT_6 off \
		7 $OPT_7 off "
		SELECTED=$($CMD)
	fi
}

getProcessorCount() {
    echo $(cat /proc/cpuinfo | grep processor | wc -l)
}

cleanVars() {
	# Reset build variables which are used in previous build 
	unset CLEAN
	unset NODDK
	unset NODSP
	unset PRODUCT_NAME
}

parseArgs() {
	for arg in $*
	do
		case "$arg" in
			"--clean" )
				CLEAN="yes"
				;;
			"--release" )
				export RELEASE="rel"
				;;
			"--preburn" )
				export RELEASE="pre"
				;;
			"--noddk" )
				NODDK="yes"
				;;
			"--nodsp" )
				NODSP="yes"
				;;
			"--help" )
				echo "Usage: $0 [--release] [--preburn] [--clean] [--help]"
				echo "  --release Build release version, default is debug version."
				echo "  --preburn Build preburn version, for manufacture test"
				echo "  --clean   Clean before build.  It will take more time."
				echo "  --help    Show this help message."
				exit 0
				;;
		esac
	done
}

configUtils() {
	DIALOG=`which dialog`

	NOTIFY=`which notify-send`
	if [ -z $NOTIFY ]; then
		NOTIFY="echo"
	fi
}

configBuildVars() {	
	YOUR_PATH=.

	if [ -z "$RELEASE" ]; then
	    export RELEASE="dbg"
	fi
	# The arguments for make.
	if [ -z "$MAKEARGS" ]; then
	    MAKEARGS="-j $(getProcessorCount)"
	fi
	EMMC_MAKEARGS="-j $(getProcessorCount)"

	if [ -z "$PRODUCT_NAME" ]; then
		PRODUCT_NAME=sdm660_64
	fi

	PRODUCT_OUT=$YOUR_PATH/out/target/product/$PRODUCT_NAME
	KERNEL_OUT=$PRODUCT_OUT/obj/KERNEL_OBJ	
}

mkBinDirs() {
	BIN_PATH=$YOUR_PATH/../bin
	mkdir -p $BIN_PATH	
	BACKUP_PATH=$BIN_PATH/backup
	mkdir -p $BACKUP_PATH	
}

mkLogsDir() {
    export LOG_PATH=$BIN_PATH/log;
    mkdir -p $LOG_PATH;
}

setup_build_mode() {
	#Build type - 1:release 2:debug
	#Variant - user userdebug eng
	
	if [ "$RELEASE" == "rel" ]; then
		lunch sdm660_64-userdebug 
	else
		lunch sdm660_64-userdebug 
	fi
}

configEmmcKernelArgs() {
	if [ "$DDR512M" == "yes" ]; then
		export CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0  mem=456M@0x80000000 init=/init vram=10M omapfb.vram=0:6M"
	else
		export CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0 init=/init vram=64M omapfb.vram=0:16M omapdss.def_disp=hdmi "
		export REC_CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0 init=/init vram=32M omapfb.vram=0:16M omapdss.def_disp=hdmi omapdss.hdmi_options=1280x720"
	fi
}

configEmmcKernelArgs() {
	if [ "$DDR512M" == "yes" ]; then
		export CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0  mem=456M@0x80000000 init=/init vram=10M omapfb.vram=0:6M"
	else
		export CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0 init=/init vram=64M omapfb.vram=0:16M omapdss.def_disp=hdmi "
		export REC_CMDLINE="console=ttyO2,115200n8 androidboot.console=ttyO2 vt.global_cursor_default=0 init=/init vram=32M omapfb.vram=0:16M omapdss.def_disp=hdmi omapdss.hdmi_options=1280x720"
	fi
}

build_a_boot() {
	if [ -e $PRODUCT_OUT/emmc_appsboot.mbn ]; then
	    rm $PRODUCT_OUT/emmc_appsboot.mbn	
    fi

	if [ -e $BIN_PATH/emmc_appsboot.mbn ]; then
	    mv -u $BIN_PATH/emmc_appsboot.mbn $BACKUP_PATH	
    fi
	
    if [ -e $LOG_PATH/a-boot_make.log ]; then
        rm -f $LOG_PATH/a-boot_make.log
    fi

    source build/envsetup.sh
    setup_build_mode
	
    if [ "$CLEAN" == "yes" ]; then
	    echo "======================================="
	    echo "a-boot clean "
	    echo "======================================="
	    make $MAKEARGS aboot clean > $LOG_PATH/a-boot_make.log
    else
	    make $MAKEARGS aboot > $LOG_PATH/a-boot_make.log
    fi
     
	if [ -e $PRODUCT_OUT/emmc_appsboot.mbn ]; then
	    # Copy binary to output directory
	    cp $PRODUCT_OUT/emmc_appsboot.mbn $BIN_PATH/
    else
        echo "XXXXXX [ Build A-BOOT Failed !! ] XXXXXX"
    fi    
}

build_kernel() {
	if [ -e $PRODUCT_OUT/boot.img ]; then
	    rm $PRODUCT_OUT/boot.img	
    fi 
	
	if [ -e $BIN_PATH/boot.img ]; then
	    mv -u $BIN_PATH/boot.img $BACKUP_PATH	
    fi 

    if [ -e $LOG_PATH/kernel_make.log ]; then
        rm -f $LOG_PATH/kernel_make.log
    fi
	
    source build/envsetup.sh
    setup_build_mode

    pushd $KERNEL_OUT
    if [ "$CLEAN" == "yes" ]; then
	    echo "======================================="
	    echo "kernel clean "
	    echo "======================================="
        make distclean
        make mrproper		# Make things double-clean... also cleans .config
		time
    fi
    popd	

	make -j4 kernel
	#make -j4 kernel > $LOG_PATH/kernel_make.log
    
	if [ -e $PRODUCT_OUT/boot.img ]; then
	    # Copy binary to output directory
	    cp $PRODUCT_OUT/boot.img $BIN_PATH/
    else
        echo "XXXXXX [ Build KERNEL Failed !! ] XXXXXX"
    fi    
}

build_android() {
	if [ -e $PRODUCT_OUT/boot.img ]; then
	    rm $PRODUCT_OUT/boot.img	
    fi 
	
	if [ -e $BIN_PATH/boot.img ]; then
	    mv -u $BIN_PATH/boot.img $BACKUP_PATH	
    fi 

	if [ -e $PRODUCT_OUT/system.img ]; then
	    rm $PRODUCT_OUT/system.img	
    fi 

	if [ -e $BIN_PATH/system.img ]; then
	    mv -u $BIN_PATH/system.img $BACKUP_PATH	
    fi 
		
	if [ -e $BIN_PATH/userdata.img ]; then
	    mv -u $BIN_PATH/userdata.img $BACKUP_PATH	
    fi    

	if [ -e $BIN_PATH/persist.img ]; then
	    mv -u $BIN_PATH/persist.img $BACKUP_PATH	
    fi    

	if [ -e $BIN_PATH/recovery.img ]; then
	    mv -u $BIN_PATH/recovery.img $BACKUP_PATH	
    fi    

	if [ -e $BIN_PATH/cache.img ]; then
	    mv -u $BIN_PATH/cache.img $BACKUP_PATH	
    fi    
	
    if [ -e $LOG_PATH/android_make.log ]; then
        rm -f $LOG_PATH/android_make.log
    fi
	
    source build/envsetup.sh
    setup_build_mode

    if [ "$CLEAN" == "yes" ]; then
	    echo "======================================="
	    echo "android clean "
	    echo "======================================="
	    make -j4 clean
	    #make -j4 clean > $LOG_PATH/android_make.log
		time
    else
	    make -j4
	    #make -j4 > $LOG_PATH/android_make.log
		time
    fi    
    
	if [ -e $PRODUCT_OUT/system.img ]; then
        # make $MAKEARGS >> $LOG_PATH/android_make2.log
        # Copy binary to output directory
        cp $PRODUCT_OUT/system.img $BIN_PATH/
        cp -u $PRODUCT_OUT/emmc_appsboot.mbn $BIN_PATH/
        cp -u $PRODUCT_OUT/userdata.img $BIN_PATH/
        cp -u $PRODUCT_OUT/persist.img $BIN_PATH/
        cp -u $PRODUCT_OUT/recovery.img $BIN_PATH/	
        cp -u $PRODUCT_OUT/cache.img $BIN_PATH/	
        cp -u $PRODUCT_OUT/boot.img $BIN_PATH/
        cp -u $PRODUCT_OUT/vendor.img $BIN_PATH/
    else
        echo "XXXXXX [ Build ANDROID Failed !! ] XXXXXX"
    fi    
}

setAdbEnableIfNotRelease() {
    if [ "$RELEASE" != "rel" ]; then
      sed -i -e "s/persist.service.adb.enable=0/persist.service.adb.enable=1/" $1
    else
      sed -i -e "s/persist.service.adb.enable=1/persist.service.adb.enable=0/" $1
    fi
}

flash_a_boot() {
	if [ -e $BIN_PATH/emmc_appsboot.mbn ]; then
        echo "> fastboot flash aboot emmc_appsboot.mbn"
	    fastboot flash aboot $BIN_PATH/emmc_appsboot.mbn
    else
        echo "XXXXXX [ error: cannot load 'emmc_appsboot.mbn' !! ] XXXXXX"
    fi
	if [ -e $BIN_PATH/emmc_appsboot.mbn ]; then
        echo "> fastboot flash abootbak emmc_appsboot.mbn"
	    fastboot flash abootbak $BIN_PATH/emmc_appsboot.mbn
	    fastboot reboot		
    else
        echo "XXXXXX [ error: cannot load 'emmc_appsboot.mbn' !! ] XXXXXX"
    fi
}

flash_kernel() {
	if [ -e $BIN_PATH/boot.img ]; then
        echo "> fastboot flash boot boot.img"
	    fastboot flash boot $BIN_PATH/boot.img	
	    fastboot reboot		
    else
        echo "XXXXXX [ error: cannot load 'boot.img' !! ] XXXXXX"
    fi
}

flash_android() {
	if [ -e $BIN_PATH/system.img ]; then
        echo "> fastboot flash system system.img"
	    fastboot flash system $BIN_PATH/system.img	
    else
        echo "XXXXXX [ error: cannot load 'system.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/userdata.img ]; then
        echo "> fastboot flash userdata userdata.img"
	    fastboot flash userdata $BIN_PATH/userdata.img	
    else
        echo "XXXXXX [ error: cannot load 'userdata.img' !! ] XXXXXX"
    fi

	
	if [ -e $BIN_PATH/recovery.img ]; then
        echo "> fastboot flash recovery recovery.img"
	    fastboot flash recovery $BIN_PATH/recovery.img	
    else
        echo "XXXXXX [ error: cannot load 'recovery.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/cache.img ]; then
        echo "> fastboot flash cache cache.img"
	    fastboot flash cache $BIN_PATH/cache.img	
    else
        echo "XXXXXX [ error: cannot load 'cache.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/persist.img ]; then
        echo "> fastboot flash persist persist.img"
	    fastboot flash persist $BIN_PATH/persist.img	
    else
        echo "XXXXXX [ error: cannot load 'persist.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/vendor.img ]; then
        echo "> fastboot flash vendor vendor.img"
	    fastboot flash vendor $BIN_PATH/vendor.img	
    else
        echo "XXXXXX [ error: cannot load 'vendor.img' !! ] XXXXXX"
    fi
	
    fastboot reboot		
}

flash_all() {
	if [ -e $BIN_PATH/emmc_appsboot.mbn ]; then
        echo "> fastboot flash aboot emmc_appsboot.mbn"
	    fastboot flash aboot $BIN_PATH/emmc_appsboot.mbn
	    fastboot flash abootbak $BIN_PATH/emmc_appsboot.mbn
    else
        echo "XXXXXX [ error: cannot load 'emmc_appsboot.mbn' !! ] XXXXXX"
    fi
	
	if [ -e $BIN_PATH/boot.img ]; then
        echo "> fastboot flash boot boot.img"
	    fastboot flash boot $BIN_PATH/boot.img	
    else
        echo "XXXXXX [ error: cannot load 'boot.img' !! ] XXXXXX"
    fi
	
	if [ -e $BIN_PATH/system.img ]; then
        echo "> fastboot flash system system.img"
	    fastboot flash system $BIN_PATH/system.img	
    else
        echo "XXXXXX [ error: cannot load 'system.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/userdata.img ]; then
        echo "> fastboot flash userdata userdata.img"
	    fastboot flash userdata $BIN_PATH/userdata.img	
    else
        echo "XXXXXX [ error: cannot load 'userdata.img' !! ] XXXXXX"
    fi
	
	if [ -e $BIN_PATH/recovery.img ]; then
        echo "> fastboot flash recovery recovery.img"
	    fastboot flash recovery $BIN_PATH/recovery.img	
    else
        echo "XXXXXX [ error: cannot load 'recovery.img' !! ] XXXXXX"
    fi
	
	if [ -e $BIN_PATH/cache.img ]; then
        echo "> fastboot flash cache cache.img"
	    fastboot flash cache $BIN_PATH/cache.img	
    else
        echo "XXXXXX [ error: cannot load 'cache.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/persist.img ]; then
        echo "> fastboot flash persist persist.img"
	    fastboot flash persist $BIN_PATH/persist.img	
    else
        echo "XXXXXX [ error: cannot load 'persist.img' !! ] XXXXXX"
    fi

	if [ -e $BIN_PATH/vendor.img ]; then
        echo "> fastboot flash vendor vendor.img"
	    fastboot flash vendor $BIN_PATH/vendor.img	
    else
        echo "XXXXXX [ error: cannot load 'vendor.img' !! ] XXXXXX"
    fi
	
    fastboot reboot		
}

# Execute the script
main $@
