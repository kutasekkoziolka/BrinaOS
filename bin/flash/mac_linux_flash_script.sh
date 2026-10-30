#!/bin/bash

clear
cd "$(dirname "$0")" || exit 1
if [ "$LANG" = "C.UTF-8" ];then
	echo
	echo 1.保留数据刷入
	echo
	echo 2.双清刷入
	echo
	read -p "请选择(默认选择1,回车执行):" input
elif [ "$LANG" = "zh_CN.UTF-8" ];then
	echo
	echo 1.保留数据刷入
	echo
	echo 2.双清刷入
	echo
	read -p "请选择(默认选择1,回车执行):" input
elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	echo
	echo 1.保留數據刷入
	echo
	echo 2.雙清刷入
	echo
	read -p "請選擇(默認選擇1,回車執行):" input
else
	echo
	echo "1. Keep your data   (nonsense-free dirty flash)"
	echo
	echo "2. Wipe data        (a clean slate, like it never happened)"
	echo
	read -p "Pick one, babe (Enter = 1): " input
fi
pdapt=$(command -v apt | grep "apt")
if [ -n "$pdapt" ];then
	echo -n "]0;mac_linux_flash_script"
fi
pdfastboot=$(command -v fastboot | grep "fastboot")
if [ ! -n "$pdfastboot" ];then
	if [ ! -n "$pdapt" ];then
		sudo brew install android-platform-tools
	else
		sudo apt install fastboot -y
	fi
else
	if [ "$LANG" = "C.UTF-8" ];then
	    echo fastboot已安装
	elif [ "$LANG" = "zh_CN.UTF-8" ];then
	    echo fastboot已安装
	elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	    echo fastboot已安裝
	else
	    echo "fastboot is already here - feather light, let us go"
  fi
fi

fastboot_path=$(which fastboot)
if [ -n "$fastboot_path" ]; then
  export ANDROID_PRODUCT_OUT=$(dirname "$fastboot_path")
fi

pdzstd=$(command -v zstd | grep "zstd")
if [ ! -n "$pdzstd" ];then
	if [ ! -n "$pdapt" ];then
		sudo brew install zstd
	else
		sudo apt install zstd -y
	fi
else
	if [ "$LANG" = "C.UTF-8" ];then
	    echo zstd已安装
	elif [ "$LANG" = "zh_CN.UTF-8" ];then
	    echo zstd已安装
	elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	    echo zstd已安裝
	else
	    echo "zstd is already here"
	fi
fi
 
if [ -f "super.zst" ];then
	if [ "$LANG" = "C.UTF-8" ];then
	    echo 正在解压super镜像,耐心等待
	elif [ "$LANG" = "zh_CN.UTF-8" ];then
	    echo 正在解压super镜像,耐心等待
	elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	    echo 正在解壓super鏡像，耐心等待
	else
	    echo "Unpacking super.img... grab an espresso, this takes a sec"
	fi
	zstd --rm -d super.zst -o super.img
	if [ $? -ne 0 ]; then
		if [ "$LANG" = "C.UTF-8" ];then
		    echo 转换失败,2s后退出程序
		elif [ "$LANG" = "zh_CN.UTF-8" ];then
		    echo 转换失败,2s后退出程序
		elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
		    echo 轉換失敗，2s後退出程式
		else
		    echo "Conversion failed - that is not sweet. Exiting in 2s"
		fi
		exit 1
	fi
fi

if [ ! -f "super.img" ]; then
	echo "super.img is missing. Taste - it is not in the package."
	exit 1
fi

if [ "$LANG" = "C.UTF-8" ];then
	echo "机型验证中...请确保您的设备代号为device_code，并已经进入bootloader模式。"
elif [ "$LANG" = "zh_CN.UTF-8" ];then
	echo "机型验证中...请确保您的设备代号为device_code，并已经进入bootloader模式。"
elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	echo "機型驗證中...請確保您的設備代號為device_code，並已進入bootloader模式。"
else
	echo "Checking the device... boot into bootloader and make sure it is device_code"
fi

if ! device_info="$(fastboot "$@" getvar product 2>&1)"; then
	device_info=""
fi
device_product="$(printf '%s\n' "$device_info" | sed -n 's/^product:[[:space:]]*//p' | head -n 1)"
if [ "$device_product" != "device_code" ]; then
	if [ "$LANG" = "C.UTF-8" ];then
		    echo 机型device_code校验失败，检查包是否匹配
		elif [ "$LANG" = "zh_CN.UTF-8" ];then
		    echo 机型device_code校验失败，检查包是否匹配
		elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
		    echo 機型device_code校驗失敗，檢查包是否匹配
		else
		    echo "Wrong phone, wrong package - this build is only for device_code. Bed chem denied."
		fi
	exit 1 
fi

if [ -f "boot_tv.img" ]; then
	if [ ! -f "firmware-update/dtbo_tv.img" ]; then
		echo "Custom dtbo image is missing - cannot flash the custom kernel."
		exit 1
	fi
else
	if [ ! -f "boot_official.img" ] || [ ! -f "firmware-update/dtbo.img" ]; then
		echo "Stock boot or dtbo image is missing - nothing to flash."
		exit 1
	fi
fi

# firmware
set -e

fastboot reboot bootloader
fastboot erase super
sleep 5

if [ -f "boot_tv.img" ]; then
	if [ "$LANG" = "C.UTF-8" ];then
		    echo 刷入第三方内核中...
		elif [ "$LANG" = "zh_CN.UTF-8" ];then
		    echo 刷入第三方内核中...
		elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
		    echo 刷入第三方内核中...
		else
		    echo "Flashing the custom kernel..."
		fi
	fastboot flash boot_a boot_tv.img
	fastboot flash boot_b boot_tv.img
	fastboot flash dtbo_a firmware-update/dtbo_tv.img
	fastboot flash dtbo_b firmware-update/dtbo_tv.img
else
	if [ "$LANG" = "C.UTF-8" ];then
		    echo 刷入官方内核中...
		elif [ "$LANG" = "zh_CN.UTF-8" ];then
		    echo 刷入官方内核中...
		elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
		    echo 刷入官方内核中...
		else
		    echo "Flashing the stock kernel..."
		fi
	fastboot flash boot_a boot_official.img
	fastboot flash boot_b boot_official.img
	fastboot flash dtbo_a firmware-update/dtbo.img
	fastboot flash dtbo_b firmware-update/dtbo.img
fi
fastboot flash super super.img
if [ ! -n "$input" ];then
	echo
elif [ "$input" -eq "2" ];then
	if [ "$LANG" = "C.UTF-8" ];then
	    echo 正在双清系统,耐心等待
	elif [ "$LANG" = "zh_CN.UTF-8" ];then
	    echo 正在双清系统,耐心等待
	elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	    echo 正在雙清系統，耐心等待
	else
	    echo "Wiping data... out with the old, please wait"
	fi
	fastboot erase userdata
	fastboot erase metadata
elif [ "$input" -eq "1" ];then
	echo
fi
# SET_ACTION_SLOT_A_BEGIN
if [ "$LANG" = "C.UTF-8" ];then
	echo 设置活动分区为 'a'。可能需要一些时间。请勿手动重新启动或拔掉数据线，否则可能导致设备变砖。
elif [ "$LANG" = "zh_CN.UTF-8" ];then
	echo 设置活动分区为 'a'。可能需要一些时间。请勿手动重新启动或拔掉数据线，否则可能导致设备变砖。
elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	echo 開始將活動分區設置為 'a'。這可能需要一些時間。請勿手動重新啟動或拔掉數據線，否則可能導致設備無法響應。
else
	echo "Setting slot A active. Please, please, please do not reboot or unplug the cable - it could brick the phone."
fi
fastboot set_active a
# SET_ACTION_SLOT_A_END

fastboot reboot

if [ "$LANG" = "C.UTF-8" ];then
	echo 刷机完成,若手机长时间未重启请手动重启,按任意键退出
elif [ "$LANG" = "zh_CN.UTF-8" ];then
	echo 刷机完成,若手机长时间未重启请手动重启,按任意键退出
elif [[ "$LANG" =~ ^zh_.*\.UTF-8$ ]]; then
	echo 刷機完成，若手機長時間未重啓請手動重啓，按任意鍵退出
else
	echo "All done - that is that me espresso. If the phone does not reboot on its own after a while, reboot it manually."
fi
echo 若手机长时间未重启请手动重启
exit 0
