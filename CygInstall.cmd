@echo off
setlocal EnableDelayedExpansion

:init
    rem Path to this script.
    set dir="%~dp0"

    rem PATH might be different (e.g. cygwin).
    set bin="%SYSTEMROOT%\System32"

    set cygDir="%HOMEDRIVE%%HOMEPATH%\cygwin"

    set pkgDir="%cygDir%\pkg"
    md %pkgDir% >nul 2>&1

    rem Get Windows system type.
    reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" ^
        | %bin%\find /i "x86" >nul
    if errorlevel 1 (
        set arch=x86_64
    ) else (
        set arch=x86
    )

    set cygUrl="https://www.cygwin.com/setup-%arch%.exe"
    set installer="%cygDir%\setup-%arch%.exe"

    if exist %installer% goto install

:downloadInstaller
    echo Downloading installer...
    powershell -Command "Invoke-WebRequest %cygUrl% -OutFile %installer%" >nul 2>&1
    if errorlevel 1 (
        echo Error: Failed to download %cygUrl% 1>&2
    ) else (
        goto install
    )

:readInstaller
    set /p installer="Path to installer: "
    if not exist %installer% goto readInstaller

:install
    rem Read package list comma seperated in 'pkgs'.
    for /f "delims=" %%p in ("%dir%pkg-list") do (
        set pkgs=!pkgs!,%%p
    )
    rem Remove leading ','.
    set pkgs=%pkgs:~1%

    rem Run the installer.
    rem TODO figure out extra packages (put in file)
    %installer% ^
    --quiet-mode ^
    --local-package-dir %pkgDir% ^
    --packages %pkgs% ^
    --upgrade-also ^
    --no-desktop
