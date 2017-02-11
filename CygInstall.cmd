@echo off

rem TODO proxy
rem TODO args

setlocal EnableDelayedExpansion

:init
    rem PATH might be different (e.g. cygwin).
    set bin="%SYSTEMROOT%\System32"

    set rootDir="C:\cygwin"
    set setupDir="%HOMEDRIVE%%HOMEPATH%\cygwin"
    set downloadSite="http://ftp.inf.tu-dresden.de/software/windows/cygwin"
    set pkgList="%~dp0\pkg-list"

    set pkgDir="%setupDir%\pkg"
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
    set installer="%setupDir%\setup-%arch%.exe"

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
    for /f "usebackq delims=" %%p in (%pkgList%) do (
        set pkgs=!pkgs!,%%p
    )
    rem Remove leading ','.
    set pkgs=%pkgs:~1%

    rem Run the installer.
    %installer% ^
        --site %downloadSite% ^
        --root %rootDir% ^
        --packages %pkgs% ^
        --categories base ^
        --arch %arch% ^
        --quiet-mode ^
        --local-package-dir %pkgDir% ^
        --no-desktop ^
        --upgrade-also
