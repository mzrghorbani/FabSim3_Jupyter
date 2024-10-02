@echo OFF

REM Configuring Windows 11 for Windows Subsystem for Linux (WSL2)
echo Setup of Windows Subsystem for Linux (WSL) and installing a Linux distro.
echo If there is any problems during the automation, please execute the commands manually.

@echo off
REM Check for administrative privileges
echo Checking for administrative permissions...

NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo You need to run this script as an administrator.
    echo Press Ctrl + C to exit and then right-click the script to 'Run as administrator'.
    pause >nul
    exit /b
)

echo Administrative permissions confirmed.

REM Detect if running on a 64-bit machine
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    echo Supported processor architecture.
) else if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
    echo Supported processor architecture.
) else (
    echo Unsupported processor architecture. WSL requires a 64-bit machine.
    pause >nul
    exit /b
)

REM Check if ARM64 architecture
echo Checking ARM64 architecture...
wmic cpu get Caption, Architecture | findstr /i "ARM64" > NUL
if errorlevel 1 (
    echo This is an x64-bit operating system running on a %PROCESSOR_ARCHITECTURE% processor.
) else (
    echo This is an ARM64 operating system running on a %PROCESSOR_ARCHITECTURE% processor.
)

REM Check if WSL is already enabled
echo Checking if WSL is already enabled...
powershell.exe -Command "Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' | Select-Object -ExpandProperty State" | find /i "enabled" >nul
if errorlevel 1 (
    REM Enable Windows Subsystem for Linux
    echo Enabling Windows Subsystem for Linux...
    powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' -All -NoRestart"
) else (
    echo WSL is already enabled. Skipping the enabling process.
)

REM Check if Virtual Machine Platform is already enabled
echo Checking if Virtual Machine Platform is already enabled...
powershell.exe -Command "Get-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' | Select-Object -ExpandProperty State" | find /i "enabled" >nul
if errorlevel 1 (
    echo Enabling Virtual Machine Platform...
    powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' -All -NoRestart"
) else (
    echo Virtual Machine Platform is already enabled. Skipping the enabling process.
)

REM Check if the BIOS manufacturer matches a virtual machine
echo If your machine is a Virtual Machine, enable Virtualisation by:
echo Turning on Hyper-V on Host Machine (e.g., Windows 11)
echo Open Settings on Windows 11.
echo Click on Apps.
echo Click the Optional features tab.
echo Under the “Related settings” section, click the “More Windows features” setting.
echo Check the Hyper-V option to enable the virtual machine platform on Windows 11.
echo Click the OK button.
echo Restart the host.

REM Prompt the user for restart confirmation
set /p restart=Do you want to restart your machine? (y/n): If this is the first time you are installing WSL, please restart Windows and Run the script again. This time you can skip the restart. 
if /i "%restart%"=="y" (
    echo Restarting your machine...
    shutdown /r /t 0
    exit /b
) else (
    echo Skipping the restart process. You can manually restart your machine later.
    echo Continuing with the installation...
    timeout 2 >nul
)

REM Download and install the WSL Linux kernel package

REM Define the kernel package URLs for different architectures
set "x64_kernel_url=https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
set "arm64_kernel_url=https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi"

REM Choose the appropriate kernel URL based on the processor architecture
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "kernel_url=%arm64_kernel_url%"
) else (
    set "kernel_url=%x64_kernel_url%"
)

REM Check if the WSL Linux kernel package is already installed
echo Checking if the WSL Linux kernel package is already installed...
if exist wsl_kernel.msi (
    echo WSL Linux kernel package is already installed. Skipping the installation process.
) else (
    REM Download and install the WSL Linux kernel package
    echo Downloading the WSL Linux kernel package...
    powershell.exe -Command "Invoke-WebRequest -Uri '%kernel_url%' -OutFile 'wsl_kernel.msi'"

    echo Installing the WSL Linux kernel package...
    start /wait msiexec /i wsl_kernel.msi /qn

    echo Cleaning up the temporary files...
    @REM del wsl_kernel.msi >nul 2>&1

    REM Check if the WSL Linux kernel package is installed after installation
    echo Checking if the WSL Linux kernel package is installed after installation...
    if errorlevel 1 (
        echo Failed to install the WSL Linux kernel package.
        exit /b
    ) else (
        echo WSL Linux kernel package is installed.
    )
)

REM Check status of installed WSL
echo Checking status of installed WSL:
wsl --status

REM Set the default version of WSL to 2
echo Setting the default version of WSL to 1...
wsl --set-default-version 1

REM List the available Linux distros online
echo - List the available Linux distros online:
wsl --list --online

REM Replace Linux distro with a distro from online list
echo Linux distro is set to desired Linux distro (e.g., Ubuntu-22.04)
set "linux_distro=Ubuntu-22.04"

REM Check if the Linux distro is installed
echo Checking if the Linux distro is installed on system
wsl --list | findstr \c:"%linux_distro%" > nul
if errorlevel 1 (
    echo Linux distro is not installed. Choosing and installing...
    (
        REM Install the Linux distro
        echo Installing the Linux distro...
        wsl --install -d %linux_distro%

        REM Set the installed Linux distro to default
        echo Setting the installed Linux distro to default:
        wsl --set-default %linux_distro%
    )
) else (
    echo Linux distro is already installed. Skipping the installation process.
)

REM Prompt the user to exit the script
echo All commands executed successfully. Press any key to exit.

pause >nul
