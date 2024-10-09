@echo OFF

REM Configuring Windows 11 for Windows Subsystem for Linux (WSL2)
echo Setting up Windows Subsystem for Linux (WSL) and installing a Linux distro.

REM Check for administrative privileges
NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo You need to run this script as an administrator.
    echo Right-click the script and select 'Run as administrator'.
    pause >nul
    exit /b
)
echo Administrative permissions confirmed.

REM Detect if running on a 64-bit machine
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    echo 64-bit architecture confirmed.
) else (
    echo Unsupported architecture. WSL requires a 64-bit machine.
    pause >nul
    exit /b
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

REM Check if Hyper-V is enabled
echo Checking if Hyper-V is enabled...
powershell.exe -Command "Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All' | Select-Object -ExpandProperty State" | find /i "enabled" >nul
if errorlevel 1 (
    REM Enable Hyper-V
    echo Enabling Hyper-V...
    DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V
    echo Hyper-V is now enabled. A restart may be required for changes to take effect.
) else (
    echo Hyper-V is already enabled. Skipping the enabling process.
)

REM Prompt the user for restart confirmation
echo Restarting is recommended to complete the WSL installation.
set /p restart=Do you want to restart your machine now? (y/n): 
if /i "%restart%"=="y" (
    echo Restarting your machine...
    shutdown /r /t 0
    exit /b
) else (
    echo Skipping restart...
    echo Continuing with the installation...
    timeout 2 >nul
)

REM Install WSL Kernel Package if not installed
set "kernel_url=https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
echo Checking if WSL Kernel package is installed...
if not exist "wsl_kernel.msi" (
    echo Downloading and installing the WSL kernel package...
    powershell.exe -Command "Invoke-WebRequest -Uri '%kernel_url%' -OutFile 'wsl_kernel.msi'"
    start /wait msiexec /i wsl_kernel.msi /qn
    echo WSL kernel package installed.
)

REM Set WSL default version to 2
wsl --set-default-version 2

REM List available distros and install Ubuntu 22.04
set "linux_distro=Ubuntu-22.04"
echo Installing %linux_distro%...
wsl --install -d %linux_distro%

REM Exit message
echo WSL and %linux_distro% installation complete. The system will exit in 5 seconds.
timeout /t 5 >nul
exit
