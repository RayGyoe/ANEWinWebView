@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:tv-run
echo.
echo Starting AIR Debug Launcher

adl "%APP_XML%" "%APP_DIR%"
if errorlevel 1 goto error
goto end

:error
pause

:end
