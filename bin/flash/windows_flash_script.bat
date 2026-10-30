@echo off
cls
setlocal enabledelayedexpansion
cd /d "%~dp0"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\Language" /v InstallLanguage|find "0804">nul&& set LANG=Chinese
if "%LANG%"=="Chinese" (
    TITLE windows 刷机脚本 [请勿选中窗口，卡住按右键或回车或放大缩小窗口恢复]
) else (
    TITLE Short n Sweet Flash Script
)
color 3f
echo.
if exist "super.zst" (
    if "%LANG%"=="Chinese" (
        echo. 正在解压super镜像,耐心等待
    ) else (
        echo. Unpacking super.img... grab an espresso, this takes a sec
    )
    bin\windows\zstd.exe --rm -d super.zst -o super.img
    if not "%errorlevel%" == "0" (
        if "%LANG%"=="Chinese" (
            echo. 转换失败,按任意键退出
        ) else (
            echo. Conversion failed - that is not sweet. Press any key to exit
        )
        pause >nul 2>nul
        exit
    )
)

if "%LANG%"=="Chinese" (
    echo.
    echo. 1. 保留数据刷入
    echo.
    echo. 2. 双清刷入
    echo.
    set /p input=请选择-默认选择1,回车执行:
) else (
    echo.
    echo. 1. Keep your data - nonsense-free dirty flash
    echo.
    echo. 2. Wipe data - a clean slate, like it never happened
    echo.
    set /p input=Pick one, babe - Enter = 1: 
)

if "%LANG%"=="Chinese" (
    echo.
    echo. 机型验证中...请确保您的设备代号为device_code，并已经进入fastbootd模式 adb reboot fastboot。

    echo.
) else (
    echo.
    echo. Checking the device... boot into bootloader and make sure it is device_code
    echo.
)

:: 获取设备代码
set "product="
for /f "tokens=2 delims=: " %%i in ('bin\windows\fastboot.exe %* getvar product 2^>^&1 ^| findstr /r /c:"^product: "') do set "product=%%i"

:: 预期设备代码
set "expected_device=device_code"

:: 设置语言相关的消息
if "%LANG%"=="Chinese" (
    set "msg_mismatch= 设备device_code不匹配。请检查是否是进入fastbootd模式"
    set "msg_continue=你想继续吗？(y/n): "
    set "msg_abort= 操作已被用户中止。"
    set "msg_continue_process=继续操作..."
) else (
    set "msg_mismatch=Wrong phone, wrong package. Bed chem denied."
    set "msg_continue=Do you want to continue anyway? (y/n): "
    set "msg_abort=Called it off. Nothing was flashed."
    set "msg_continue_process=Your call, babe. Carrying on..."
)

:: 检查是否匹配
if not defined product (
    echo %msg_mismatch%
    echo %msg_abort%
    exit /B 1
)
if /i "!product!" neq "%expected_device%" (
    echo %msg_mismatch%
    echo %msg_abort%
    exit /B 1
)

if "%LANG%"=="Chinese" (
    echo.
    echo. 1. 刷入KSU内核
    echo.
    echo. 2. 刷入官方内核
    echo.
    set /p kernel=请选择-默认选择1,回车执行:
) else (
    echo.
    echo. 1. KernelSU boot.img - a little extra espresso
    echo.
    echo. 2. Stock boot.img - short n sweet
    echo.
    set /p kernel=Pick one, babe - Enter = 1: 
)

set "flash_boot=%~dp0boot_official.img"
set "flash_dtbo=%~dp0firmware-update\dtbo.img"
if "%kernel%"=="1" (
    if exist "%~dp0boot_ksu.img" (
        set "flash_boot=%~dp0boot_ksu.img"
        set "flash_dtbo=%~dp0firmware-update\dtbo_ksu.img"
    )
)
if not exist "%~dp0super.img" (
    echo super.img is missing. Taste - it is not in the package.
    exit /B 1
)
if not exist "!flash_boot!" (
    echo The boot image is missing - nothing to flash.
    exit /B 1
)
if not exist "!flash_dtbo!" (
    echo The dtbo image is missing - nothing to flash.
    exit /B 1
)
if "%kernel%"=="1" (
    if "%LANG%"=="Chinese" (
        echo. 刷入第三方boot_ksu.img
    ) else (
        echo. Flashing the custom kernel...
    )

    if exist "%~dp0boot_ksu.img" (
        bin\windows\fastboot.exe flash boot "%~dp0boot_ksu.img" || exit /B 1
        bin\windows\fastboot.exe flash dtbo "%~dp0firmware-update/dtbo_ksu.img" || exit /B 1
    ) else (
		if "%LANG%"=="Chinese" (
		echo. boot_ksu.img 不存在，刷入官方boot_official.img
			) else (
		echo. No boot_ksu.img in the package - flashing the stock kernel instead
			)

        bin\windows\fastboot.exe flash boot "%~dp0boot_official.img" || exit /B 1
        bin\windows\fastboot.exe flash dtbo "%~dp0firmware-update/dtbo.img" || exit /B 1
    )
) else (
    bin\windows\fastboot.exe flash boot "%~dp0boot_official.img" || exit /B 1
    bin\windows\fastboot.exe flash dtbo "%~dp0firmware-update/dtbo.img" || exit /B 1
)

REM firmware

bin\windows\fastboot.exe erase super || exit /B 1
bin\windows\fastboot.exe reboot bootloader || exit /B 1
ping 127.0.0.1 -n 5 >nul 2>nul
bin\windows\fastboot.exe flash super "%~dp0super.img" || exit /B 1
if "%input%" == "2" (
	if "%LANG%"=="Chinese" (
	    echo. 正在双清系统,耐心等待
    ) else (
        echo. Wiping data... out with the old, please wait
    )
	bin\windows\fastboot.exe erase userdata || exit /B 1
	bin\windows\fastboot.exe erase metadata || exit /B 1
)
REM SET_ACTION_SLOT_A_BEGIN
if "%LANG%"=="Chinese" (
	echo. 设置活动分区为 'a'。可能需要一些时间。请勿手动重新启动或拔掉数据线，否则可能导致设备变砖。
) else (
    echo. Setting slot A active. Please, please, please do not reboot or unplug the cable - it could brick the phone.
)
bin\windows\fastboot.exe set_active a || exit /B 1

REM SET_ACTION_SLOT_A_END

bin\windows\fastboot.exe reboot || exit /B 1

if "%LANG%"=="Chinese" (
    echo. 刷机完成,若手机长时间未重启请手动重启,按任意键退出
) else (
    echo. All done - that is that me espresso. If the phone does not reboot on its own, reboot it manually. Press any key to exit.
)
pause
exit
