REM Get the path to the script and trim to get the directory.
@echo off
SET projectName=ANECefWebView
echo Setting path to current directory to:
SET pathtome=%~dp0


del ANEWinWebView.ane
call copydll.bat

copy /y library.swf default
copy /y library.swf Windows-x86

adt -package -tsa none -storetype pkcs12 -keystore cert.p12 -storepass fd -target ane ANECefWebView.ane extension.xml -swc ANEWinWebView.swc -platform Windows-x86 -C Windows-x86 . -platform default -C default .