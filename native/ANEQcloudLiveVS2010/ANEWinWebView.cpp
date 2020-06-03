#include "ANEWinWebView.h"


using namespace std;

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


	std::map<int, wkeWebView>VectorWkeWebView;
	int webview_Index = 0;


	std::map<int, int>VectorWkeWebViewIndex;
	//events


	// 回调：文档加载成功
	void handleDocumentReady(wkeWebView webWindow, void * param, wkeWebFrameHandle frameId)
	{
		int indexId = *(int*)param;

		printf("\n%s,%s   = webviewid=%d    =  %d", TAG, "handleDocumentReady", indexId, frameId);


		if (wkeIsMainFrame(webWindow, frameId)) {
			ANEutils.dispatchEvent("COMPLETE", ANEutils.intToStdString(indexId) + "||" + ANEutils.intToStdString((int)frameId));
		}
		else {
			ANEutils.dispatchEvent("FRAME_COMPLETE", ANEutils.intToStdString(indexId) + "||" + ANEutils.intToStdString((int)frameId));
		}
	}



	//events



	//初始化
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
		wcscat(dllPath, L"\\MiniBlink\\");
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

	FREObject EnableHighDPISupport(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		wkeEnableHighDPISupport();

		int screenwidth_real = GetSystemMetrics(SM_CXSCREEN);
		int screenheight_real = GetSystemMetrics(SM_CYSCREEN);

		printf("\n%s,%s , %d = %d", TAG, "EnableHighDPISupport", screenwidth_real, screenheight_real);

		return ANEutils.getFREObject(screenwidth_real);
	}
	

	FREObject Version(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int value = wkeVersion();
		return ANEutils.getFREObject(value);
	}

	FREObject VersionString(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		const char *value = wkeVersionString();

		return ANEutils.getFREObject(value);
	}



	FREObject CreateWebWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		printf("\n%s,%s", TAG, "wkeCreateWebWindow");

		std::string windowTitle = ANEutils.getString(argv[0]);

		HWND window = FindWindow(NULL, ANEutils.stringToLPCWSTR(windowTitle));


		int x = ANEutils.getInt32(argv[1]);
		int y = ANEutils.getInt32(argv[2]);
		int width = ANEutils.getInt32(argv[3]);
		int height = ANEutils.getInt32(argv[4]);

		printf("\n%s,  window1 id=%d", TAG, window);
		if (window != NULL)
		{
			int index = webview_Index += 1;

			//WKE_WINDOW_TYPE_CONTROL
			wkeWebView webview = wkeCreateWebWindow(WKE_WINDOW_TYPE_CONTROL, window, x, y, width, height);
			wkeShowWindow(webview, true);

			VectorWkeWebView[webview_Index] = webview;
			VectorWkeWebViewIndex[webview_Index] = index;
			

			//传递引用
			//wkeOnDocumentReady(webview, handleDocumentReady, &VectorWkeWebViewIndex[webview_Index]);

			wkeOnDocumentReady2(webview,handleDocumentReady, &VectorWkeWebViewIndex[webview_Index]);

			return ANEutils.getFREObject(webview_Index);
		}

		return ANEutils.getFREObject(0);
	}



	FREObject ANEShowWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		auto value = ANEutils.getBool(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeShowWindow(webview, value);
		}
		return ANEutils.getFREObject(true);
	}
	


	FREObject LoadURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		std::string value = ANEutils.getString(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeLoadURL(webview, value.c_str());
		}
		return ANEutils.getFREObject(true);
	}


	FREObject LoadHTML(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		std::string value = ANEutils.getString(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeLoadHTML(webview, value.c_str());
		}
		return ANEutils.getFREObject(true);
	}


	FREObject GetUserAgent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			const char * value = wkeGetUserAgent(webview);
			return ANEutils.getFREObject(value);
		}
		return NULL;
	}

	FREObject GetTitle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			const char * value = wkeGetTitle(webview);
			return ANEutils.getFREObject(value);
		}
		return NULL;
	}

	FREObject GetURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			const char * value = wkeGetURL(webview);
			return ANEutils.getFREObject(value);
		}
		return NULL;
	}


	FREObject ANEMoveWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]); 
		int x = ANEutils.getInt32(argv[1]);
		int y = ANEutils.getInt32(argv[2]);
		int width = ANEutils.getInt32(argv[3]);
		int height = ANEutils.getInt32(argv[4]);


		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeMoveWindow(webview, x, y, width, height);
		}
		return NULL;
	}



	FREObject Reload(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeReload(webview);
		}
		return NULL;
	}


	FREObject StopLoading(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeStopLoading(webview);
		}
		return NULL;
	}

	

	FREObject SetZoomFactor(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		float value  = (float)ANEutils.getDouble(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetZoomFactor(webview, value);
		}
		return NULL;
	}

	FREObject GetZoomFactor(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			float value =  wkeGetZoomFactor(webview);
			return ANEutils.getFREObject(value);
		}
		return ANEutils.getFREObject(0);
	}



	FREObject ANESetFocus(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);


		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetFocus(webview);
		}
		return NULL;
	}
	


	FREObject CanGoBack(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			BOOL value = wkeCanGoBack(webview);

			printf("\n%s,  wkeCanGoBack %d", TAG, value);

			return ANEutils.getFREObject(value==1);
		}
		return ANEutils.getFREObject(false);
	}

	FREObject GoBack(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			BOOL value = wkeGoBack(webview);

			printf("\n%s,  wkeGoBack %d", TAG, value);
			return ANEutils.getFREObject(value == 1);
		}
		return ANEutils.getFREObject(false);
	}
	FREObject CanGoForward(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			BOOL value = wkeCanGoForward(webview);

			printf("\n%s,  wkeCanGoForward %d", TAG, value);
			return ANEutils.getFREObject(value == 1);
		}
		return ANEutils.getFREObject(false);
	}

	FREObject GoForward(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			BOOL value = wkeGoForward(webview);
			printf("\n%s,  wkeGoForward %d", TAG, value);
			return ANEutils.getFREObject(value == 1);
		}
		return ANEutils.getFREObject(false);
	}
	


	FREObject SetCookieEnabled(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		auto enable = ANEutils.getBool(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetCookieEnabled(webview, enable);
		}
		return NULL;
	}
	
	

	FREObject SetCookieJarFullPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::string path = ANEutils.getString(argv[1]);

		std::wstring spath = ANEutils.s2ws(path);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetCookieJarFullPath(webview, spath.c_str());
		}
		return NULL;
	}


	FREObject SetLocalStorageFullPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::string path = ANEutils.getString(argv[1]);

		std::wstring spath = ANEutils.s2ws(path);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetLocalStorageFullPath(webview, spath.c_str());
		}
		return NULL;
	}
	

	FREObject GC(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		long intervalSec = (long)ANEutils.getDouble(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeGC(webview,intervalSec);
		}
		return NULL;
	}
	

	FREObject DestroyWebWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		int x = ANEutils.getInt32(argv[1]);
		int y = ANEutils.getInt32(argv[2]);
		int width = ANEutils.getInt32(argv[3]);
		int height = ANEutils.getInt32(argv[4]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeDestroyWebWindow(webview);
			VectorWkeWebView[index] = nullptr;
		}
		return NULL;
	}
	
	// Flash Native Extensions stuff	
	void ANEWinWebViewContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {

		ANEutils.setFREContext(ctx);

		static FRENamedFunction extensionFunctions[] =
		{
			{ (const uint8_t*) "isSupported",     NULL, &isSupported },
			{ (const uint8_t*) "wkeInitialize",     NULL, &Initialize },
			{ (const uint8_t*) "wkeEnableHighDPISupport",     NULL, &EnableHighDPISupport },
			{ (const uint8_t*) "wkeVersion",     NULL, &Version },
			{ (const uint8_t*) "wkeVersionString",     NULL, &VersionString },



			{ (const uint8_t*) "wkeCreateWebWindow",     NULL, &CreateWebWindow },
			
			{ (const uint8_t*) "wkeShowWindow",     NULL, &ANEShowWindow },

			{ (const uint8_t*) "wkeLoadURL",     NULL, &LoadURL },
			{ (const uint8_t*) "wkeLoadHTML",     NULL, &LoadHTML },
			{ (const uint8_t*) "wkeGetUserAgent",     NULL, &GetUserAgent },
			{ (const uint8_t*) "wkeGetTitle",     NULL, &GetTitle },
			
			{ (const uint8_t*) "wkeGetURL",     NULL, &GetURL },
			{ (const uint8_t*) "wkeMoveWindow",     NULL, &ANEMoveWindow },
			{ (const uint8_t*) "wkeReload",     NULL, &Reload },
			{ (const uint8_t*) "wkeStopLoading",     NULL, &StopLoading },
			
			{ (const uint8_t*) "wkeSetFocus",     NULL, &ANESetFocus },
			{ (const uint8_t*) "wkeSetZoomFactor",     NULL, &SetZoomFactor },
			{ (const uint8_t*) "wkeGetZoomFactor",     NULL, &GetZoomFactor },
			
			{ (const uint8_t*) "wkeCanGoBack",     NULL, &CanGoBack },
			{ (const uint8_t*) "wkeGoBack",     NULL, &GoBack },
			{ (const uint8_t*) "wkeCanGoForward",     NULL, &CanGoForward },
			{ (const uint8_t*) "wkeGoForward",     NULL, &GoForward },


			{ (const uint8_t*) "wkeSetCookieEnabled",     NULL, &SetCookieEnabled },
			{ (const uint8_t*) "wkeSetCookieJarFullPath",     NULL, &SetCookieJarFullPath },
			{ (const uint8_t*) "wkeSetLocalStorageFullPath",     NULL, &SetLocalStorageFullPath },
			
			{ (const uint8_t*) "wkeGC",     NULL, &GC },
			
			

			{ (const uint8_t*) "wkeDestroyWebWindow",     NULL, &DestroyWebWindow },
			
		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
	}

	void ANEWinWebViewContextFinalizer(void * extData)
	{
		printf("\n%s,%s", TAG, "ANEWinWebViewContextFinalizer：release()");
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
