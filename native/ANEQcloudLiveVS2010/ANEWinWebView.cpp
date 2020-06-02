#include "ANEWinWebView.h"
#include <sstream>
#include <shlwapi.h>

#include "ANEUtils.h"
#include "wke.h"

std::string intToStdString(int value)
{
	std::stringstream str_stream;
	str_stream << value;
	std::string str = str_stream.str();

	return str;
}

extern "C" {

	const char *TAG = "ANEWinWebView:1.0";

	ANEUtils ANEutils;

	bool isCrateCrashDump = false;

	//³õÊ¼»¯
	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("\n%s,%s", TAG, "isSupport");

		FREObject result;
		auto status = FRENewObjectFromBool(true, &result);
		return result;
	}

	FREObject  Initialize(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{


		TCHAR dllPath[MAX_PATH];
		GetModuleFileName(nullptr, dllPath, MAX_PATH);
		PathRemoveFileSpec(dllPath);
		wcscat(dllPath, L"\\wke\\");
		printf("\n%s---%ls", TAG, dllPath);
		SetDllDirectory(dllPath);

		HMODULE hWke = LoadLibrary(L"node.dll");
		wkeSetWkeDllHandle(hWke);

		int init = wkeInitialize();

		printf("\n%s,%s , %d", TAG, "Initialize", init);

		FREObject result;
		auto status = FRENewObjectFromBool(init == 1, &result);
		return result;
	}

	FREObject CreateWebWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("\n%s,%s", TAG, "wkeCreateWebWindow");

		std::string windowTitle  = ANEutils.getString(argv[0]);
		
		HWND window = FindWindow(NULL, ANEutils.stringToLPCWSTR(windowTitle));

		printf("\n%s,  window1 id=%d", TAG, window);
		if (window != NULL) 
		{
			//WKE_WINDOW_TYPE_CONTROL
			wkeWebView webview = wkeCreateWebWindow(WKE_WINDOW_TYPE_CONTROL, window, 0, 100, 640, 480);
			wkeLoadURL(webview, "https://www.talkmed.com");
			wkeShowWindow(webview, true);

			return ANEutils.getFREObject(true);
		}

		return ANEutils.getFREObject(false);
	}
	


	// Flash Native Extensions stuff	
	void ANEWinWebViewContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "isSupported",     NULL, &isSupported },
			{ (const uint8_t*) "wkeInitialize",     NULL, &Initialize },
		{ (const uint8_t*) "wkeCreateWebWindow",     NULL, &CreateWebWindow },
		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
	}

	void ANEWinWebViewContextFinalizer(void * extData)
	{
		printf("\n%s,%s", TAG, "ANEWinWebViewContextFinalizer£ºrelease()");
	}


	void ANEWinWebViewExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
	{
		*ctxInitializer = &ANEWinWebViewContextInitializer;
		*ctxFinalizer = &ANEWinWebViewContextFinalizer;
	}

	void ANEWinWebViewExtFinalizer(void* extData)
	{
		return;
	}
}

