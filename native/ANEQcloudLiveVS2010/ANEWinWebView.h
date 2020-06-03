#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#include "ANEUtils.h"

#include <windows.h>
#include <sstream>
#include <shlwapi.h>


#include "wke.h"
/*
#include <string>
#include <memory>
#include <stdio.h>
#include <assert.h>
*/

extern "C"
{
	__declspec(dllexport) void ANEWinWebViewExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void ANEWinWebViewExtFinalizer(void* extData);
}
