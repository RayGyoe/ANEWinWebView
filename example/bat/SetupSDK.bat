:user_configuration

:: Path to Flex SDK
set FLEX_SDK=C:\AIR

:: Path to Android SDK
set ANDROID_SDK=C:\Program Files (x86)\FlashDevelop\Tools\android

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin
set PATH=%PATH%;%ANDROID_SDK%\platform-tools

