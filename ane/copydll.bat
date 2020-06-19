
del Windows-x86\ANEWinWebView.dll
del Windows-x86-64\ANEWinWebView.dll

copy /y %pathtome%..\native\x86\Release\ANEWinWebView.dll "./Windows-x86"
copy /y %pathtome%..\native\x64\Release\ANEWinWebView.dll "./Windows-x86-64"