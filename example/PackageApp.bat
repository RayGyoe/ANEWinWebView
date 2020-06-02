@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:menu
echo.
echo Package for target
echo.
echo Android:
echo.
echo  [1] normal       (apk)
echo  [2] debug        (apk-debug)
echo  [21] debug-scout (apk-scout-debug)
echo  [3] captive-release      (apk-captive-runtime)
echo  [31] captive-sandbox      (apk-captive-runtime)
echo.
echo iOS:
echo.
echo  [4] fast test    (ipa-test-interpreter)
echo  [5] fast debug   (ipa-debug-interpreter)
echo  [6] slow test    (ipa-test)
echo  [7] slow debug   (ipa-debug)
echo  [8] "ad-hoc"     (ipa-ad-hoc)
echo  [9] App Store    (ipa-app-store)
echo  [10] App Store   (ipa-app-store-AOT)
echo.
echo Desktop:
echo  [a] native      (air)
echo  [e] window      (exe)
echo  [b] desktop     (bundle)
echo  [m] mac      	  (bundle)
echo.

:choice
set /P C=[Choice]: 
echo.


set PLATFORM=android
set OPTIONS=
if %C% GTR 3 set PLATFORM=ios
if %C% GTR 7 set PLATFORM=ios-dist

if "%C%"=="a" set TARGET=
if "%C%"=="a" set OPTIONS=-tsa none
if "%C%"=="a" set PLATFORM=native-air

if "%C%"=="e" set TARGET=native
if "%C%"=="e" set OPTIONS=-tsa none
if "%C%"=="e" set PLATFORM=desktop
if "%C%"=="e" set DIST_EXT=exe

if "%C%"=="b" set TARGET=bundle
if "%C%"=="b" set OPTIONS=-tsa none
if "%C%"=="b" set PLATFORM=desktop
if "%C%"=="b" set DIST_EXT=exe

if "%C%"=="m" set TARGET=bundle
if "%C%"=="m" set OPTIONS=-tsa none
if "%C%"=="m" set PLATFORM=desktop
if "%C%"=="m" set DIST_EXT=app


if "%C%"=="1" set TARGET=
if "%C%"=="2" set TARGET=-debug
if "%C%"=="2" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="21" set PLATFORM=android
if "%C%"=="21" set TARGET=-profile
if "%C%"=="21" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="3" set TARGET=-captive-runtime
if "%C%"=="31" set PLATFORM=android
if "%C%"=="31" set TARGET=-captive-runtime

if "%C%"=="4" set TARGET=-test-interpreter
if "%C%"=="5" set TARGET=-debug-interpreter
if "%C%"=="5" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="6" set TARGET=-test
if "%C%"=="7" set TARGET=-debug
if "%C%"=="7" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="8" set TARGET=-ad-hoc
if "%C%"=="9" set TARGET=-app-store
if "%C%"=="10" set TARGET=-app-store
if "%C%"=="10" set IOSAOT=-useLegacyAOT yes




call bat\Packager.bat
pause