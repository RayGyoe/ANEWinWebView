@echo off

if "%PLATFORM%"=="android" goto android-config
if "%PLATFORM%"=="ios" goto ios-config
if "%PLATFORM%"=="ios-dist" goto ios-dist-config
if "%PLATFORM%"=="desktop" goto desktop-config
if "%PLATFORM%"=="native-air" goto air-config
goto start


:air-config
:: AIR output
::adt -package -tsa none -storetype pkcs12 -keystore "bat\TV.p12" -storepass fd air\TV.air application.xml -C bin .
::adt -package -target   -tsa none -storetype pkcs12 -keystore "cert\ScaleTest.p12" -storepass fd "bin-release\ScaleTest1.0.air" "application.xml" -C bin . -extdir "lib"
set CERT_FILE=%AND_CERT_FILE%
set SIGNING_OPTIONS=%AND_SIGNING_OPTIONS%
set ICONS=%IOS_ICONS%
set DIST_EXT=air
set TYPE=
goto start

:android-config
set CERT_FILE=%AND_CERT_FILE%
set SIGNING_OPTIONS=%AND_SIGNING_OPTIONS%
set ICONS=%AND_ICONS%
set DIST_EXT=apk
set TYPE=apk
goto start

:ios-config
set CERT_FILE=%IOS_DEV_CERT_FILE%
set SIGNING_OPTIONS=%IOS_DEV_SIGNING_OPTIONS%
set ICONS=%IOS_ICONS%
set DIST_EXT=ipa
set TYPE=ipa
goto start

:ios-dist-config
set CERT_FILE=%IOS_DIST_CERT_FILE%
set SIGNING_OPTIONS=%IOS_DIST_SIGNING_OPTIONS%
set ICONS=%IOS_ICONS%
set DIST_EXT=ipa
set TYPE=ipa
goto start

:desktop-config
set CERT_FILE=%AND_CERT_FILE%
set SIGNING_OPTIONS=%AND_SIGNING_OPTIONS%
set ICONS=%AND_ICONS%
::set DIST_EXT=exe
set TYPE=air
goto start


:start
if not exist "%CERT_FILE%" goto certificate
:: Output file
set EXTDIR=-extdir lib
if not exist "%DIST_PATH%" md "%DIST_PATH%"
if "%IOSAOT%"=="" set OUTPUT=%DIST_PATH%\%DIST_NAME%%TARGET%%VERSION%.%DIST_EXT%
if not "%IOSAOT%"=="" set OUTPUT=%DIST_PATH%\%DIST_NAME%%TARGET%-AOT%VERSION%.%DIST_EXT%
:: Package
echo Packaging: %OUTPUT%
echo using certificate: %CERT_FILE%...
echo.

if "%PLATFORM%"=="native-air" (
echo call adt -package %TYPE%%TARGET% %IOSAOT% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%"
call adt -package %TYPE%%TARGET% %IOSAOT% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%")
if not "%PLATFORM%"=="native-air" (goto desktop-app)

if errorlevel 1 goto failed
goto end


:desktop-app
if "%PLATFORM%"=="desktop" (
echo call adt -package %OPTIONS%  %SIGNING_OPTIONS% -target %TARGET%  "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%"
if not "%DIST_EXT%"=="app" (call adt -package %OPTIONS% %SIGNING_OPTIONS%  -target %TARGET%  "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%"))

if not "%PLATFORM%"=="desktop" (
echo call adt -package -target %TYPE%%TARGET% %IOSAOT% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%"
call adt -package -target %TYPE%%TARGET% %IOSAOT% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir "%EXT_DIR%")

if errorlevel 1 goto failed
goto set-up

:set-up
if "%PLATFORM%"=="android" set PLAT=android
if "%PLATFORM%"=="ios" set PLAT=ios
if "%PLATFORM%"=="ios-dist" set PLAT=ios
if "%PLATFORM%"=="desktop" (start %OUTPUT%  
goto end)
echo uninstalling...
call adt -uninstallApp -platform %PLAT% -appid %APP_ID%
echo installing...
call adt -installApp -platform %PLAT% -package %OUTPUT%
echo launchApp...
call adt -launchApp -platform %PLAT% -appid %APP_ID%
goto end


:certificate
echo Certificate not found: %CERT_FILE%
echo.
echo Android: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo   or configure a specific certificate in 'bat\SetupApplication.bat'.
echo.
echo iOS: 
echo - configure your developer key and project's Provisioning Profile
echo   in 'bat\SetupApplication.bat'.
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo APK setup creation FAILED.
echo.
echo Troubleshooting: 
echo - did you build your project in FlashDevelop?
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
