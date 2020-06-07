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

	//call back
	std::map<std::string, std::string>VectorWkeJsCallBack;


	std::string PARTITION = "|-|";

	// 回调：文档加载成功
	void handleDocumentReady(wkeWebView webWindow, void * param, wkeWebFrameHandle frameId)
	{
		int indexId = *(int*)param;

		printf("\n%s,%s   = webviewid=%d    =  %d", TAG, "handleDocumentReady", indexId, frameId);


		if (wkeIsMainFrame(webWindow, frameId)) {
			ANEutils.dispatchEvent("complete", ANEutils.intToStdString(indexId) + PARTITION + ANEutils.intToStdString((int)frameId));
		}
		else {
			ANEutils.dispatchEvent("frame_complete", ANEutils.intToStdString(indexId) + PARTITION + ANEutils.intToStdString((int)frameId));
		}
	}
	void handleTitleChanged(wkeWebView webWindow, void* param, const wkeString title)
	{
		int indexId = *(int*)param;


		std::string wstr = ANEutils.ws2s(wkeGetStringW(title));

		std::string str= ANEutils.string_To_UTF8(wstr);


		ANEutils.dispatchEvent("title", ANEutils.intToStdString(indexId) + PARTITION + str);
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
			

			VectorWkeWebView[webview_Index] = webview;
			VectorWkeWebViewIndex[webview_Index] = index;
			

			//传递引用
			//wkeOnDocumentReady(webview, handleDocumentReady, &VectorWkeWebViewIndex[webview_Index]);

			wkeOnDocumentReady2(webview,handleDocumentReady, &VectorWkeWebViewIndex[webview_Index]);
			wkeOnTitleChanged(webview, handleTitleChanged, &VectorWkeWebViewIndex[webview_Index]);
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
	

	FREObject drawViewPortToBitmapData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		printf("\n%s,  drawViewPortToBitmapData %i", TAG, index);
		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			int w = wkeGetContentWidth(webview);
			int h = wkeGetContentHeight(webview);

			int cw = wkeGetWidth(webview);
			int ch = wkeGetHeight(webview);
			//wkeResize(webview, w, h);
			//wkeUpdate();

			int pixels_length = cw * ch * 4;
			void * bits = malloc(pixels_length);
			wkePaint(webview, bits, 0);

			printf("\n%s,  bitmapdata  w=%i  h=%i length= %i", TAG, cw, ch, pixels_length);

			FREObject objectByteArray = argv[1];
			FREByteArray byteArray;
			FREObject length;
			FRENewObjectFromUint32(pixels_length, &length);
			FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
			FREAcquireByteArray(objectByteArray, &byteArray);
			//copyMutex.lock();
			memcpy(byteArray.bytes, bits, pixels_length);
			//copyMutex.unlock();
			FREReleaseByteArray(objectByteArray);

			printf("\n%s,  copy finish", TAG);
			//not work
			/*
			FREObject freArguments[4] = { ANEutils.getFREObject(cw), ANEutils.getFREObject(ch), ANEutils.getFREObject(0), ANEutils.getFREObject(uint32_t(0xFF0000)) };
			FREObject bitmap_data_object;
			FRENewObject((uint8_t *)"flash.display.BitmapData", 4, freArguments, &bitmap_data_object, NULL);
			FREBitmapData bitmapData;
			FREAcquireBitmapData(bitmap_data_object, &bitmapData);
			memcpy(bitmapData.bits32, pixels, length);
			FREReleaseBitmapData(bitmap_data_object);*/

			free(bits);


			//return bitmap_data_object;

			return ANEutils.getFREObject(std::to_string(cw)+ PARTITION +std::to_string(ch));
		}

		return NULL;
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
	

	jsValue jsBindCallParam(jsExecState es, void* param)
	{
		std::string toAir = *(std::string*)param;
		int argCount = jsArgCount(es);

		int valueCount = 0;
		if (argCount)
		{
			for (int i = 0; i < argCount; i++)
			{
				jsType type = jsArgType(es, i);
				jsValue value = jsArg(es, i);

				switch (type)
				{
					case JSTYPE_NUMBER:
						toAir += PARTITION + std::to_string(jsToFloat(es, value));
						++valueCount;
						break;
					case JSTYPE_STRING:
						toAir += PARTITION + jsToString(es, value);
						++valueCount;
						break;
					case JSTYPE_BOOLEAN:						
						toAir += PARTITION + (jsIsTrue(value) ? "true" : "false");
						++valueCount;
						break;
					case JSTYPE_OBJECT:
						jsEvalExW(es, L"alert('object  type not supported')", true);
						break;
					case JSTYPE_FUNCTION:
						jsEvalExW(es, L"alert('function  type not supported')", true);
						break;
					case JSTYPE_UNDEFINED:
						toAir += PARTITION + "null";
						++valueCount;
						break;
					case JSTYPE_ARRAY:
						jsEvalExW(es, L"alert('array  type not supported')", true);
						break;
				}
			}
		}
		printf("\n%s,%s   = toAir=%s      argCount=%d", TAG, "jsBindCallParam", toAir, argCount);
		if (valueCount == argCount)
		{
			ANEutils.dispatchEvent("jscallback",toAir);
		}
		else {

		}

		
		return jsUndefined();
	}

	FREObject JsBindFunction(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::string functionName = ANEutils.getString(argv[1]);
		int argCount = ANEutils.getInt32(argv[2]);


		printf("\n%s,  JsBindFunction %s   = %i", TAG, functionName.c_str(), argCount);
		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {

			std::string bind = std::to_string(index) + PARTITION + functionName;
			VectorWkeJsCallBack[bind] = bind;

			wkeJsBindFunction(functionName.c_str(), jsBindCallParam, &VectorWkeJsCallBack[bind],argCount);
			return ANEutils.getFREObject(true);
		}
		return ANEutils.getFREObject(false);
	}

	
	FREObject EvalExW(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::wstring js = ANEutils.s2ws(ANEutils.getString(argv[1]));
		bool isInClosure = ANEutils.getBool(argv[2]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			jsExecState es = wkeGlobalExec(webview);
			jsEvalExW(es, js.c_str(), isInClosure);
			return ANEutils.getFREObject(true);
		}
		return ANEutils.getFREObject(false);
	}

	FREObject Call(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		
		std::string funcName = ANEutils.getString(argv[1]);

		printf("\n=====%i", argc);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			jsExecState es = wkeGlobalExec(webview);

			jsValue fun = jsGetGlobal(es, funcName.c_str());
			jsType type = jsTypeOf(fun);

			printf("\n%s,  Call %i", TAG, type);

			if (type == JSTYPE_FUNCTION) 
			{
				int args_count = argc - 2;

				jsValue *args =  new jsValue[args_count]();

				for (uint32_t i = 2; i < argc; i++) {
					args[i-2] = jsString(es,ANEutils.getString(argv[i]).c_str());
				}
				//args[0] = jsInt(1);
				//jsCall(es, fun, thisValue,args, sizeof(args));

				jsValue value = jsCallGlobal(es, fun, args, args_count);
				type = jsTypeOf(value);
				printf("\n%s,  jsCallGlobal %i", TAG, type);
				
				switch (type)
				{
				case JSTYPE_NUMBER:
					return ANEutils.getFREObject(std::to_string(jsToFloat(es, value)));
					break;
				case JSTYPE_STRING:
					return ANEutils.getFREObject(jsToString(es, value));
					break;
				case JSTYPE_BOOLEAN:
					return ANEutils.getFREObject(jsIsTrue(value));
					break;
				case JSTYPE_OBJECT:
					jsEvalExW(es, L"alert('object  type not supported')", true);
					break;
				case JSTYPE_FUNCTION:
					jsEvalExW(es, L"alert('function  type not supported')", true);
					break;
				case JSTYPE_UNDEFINED:
					break;
				case JSTYPE_ARRAY:
					jsEvalExW(es, L"alert('array  type not supported')", true);
					break;
				}
			}
			
			
		}
		return NULL;
	}


	FREObject SetGlobal(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::string funcName = ANEutils.getString(argv[1]);
		std::string value = ANEutils.getString(argv[2]);


		wkeWebView webview = VectorWkeWebView[index];

		if (webview) {
			jsExecState es = wkeGlobalExec(webview);

			jsSetGlobal(es, funcName.c_str(), jsString(es, value.c_str()));
			return ANEutils.getFREObject(true);
		}

		return ANEutils.getFREObject(false);
	}
	FREObject GetGlobal(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);
		wkeWebView webview = VectorWkeWebView[index];

		std::string funcName = ANEutils.getString(argv[1]);

		if (webview) {
			jsExecState es = wkeGlobalExec(webview);
			jsValue value = jsGetGlobal(es, funcName.c_str());

			jsType type = jsTypeOf(value);
			printf("\n%s,  jsGetGlobal %i", TAG, type);

			switch (type)
			{
			case JSTYPE_NUMBER:
				return ANEutils.getFREObject(std::to_string(jsToFloat(es, value)));
				break;
			case JSTYPE_STRING:
				return ANEutils.getFREObject(jsToString(es, value));
				break;
			case JSTYPE_BOOLEAN:
				return ANEutils.getFREObject(jsIsTrue(value));
				break;
			case JSTYPE_OBJECT:
				jsEvalExW(es, L"alert('object  type not supported')", true);
				break;
			case JSTYPE_FUNCTION:
				jsEvalExW(es, L"alert('function  type not supported')", true);
				break;
			case JSTYPE_UNDEFINED:
				break;
			case JSTYPE_ARRAY:
				jsEvalExW(es, L"alert('array  type not supported')", true);
				break;
			}
		}

		return NULL;
	}


	FREObject SetDebugConfig(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		int index = ANEutils.getInt32(argv[0]);

		std::string devPath = ANEutils.getString(argv[1]);

		wkeWebView webview = VectorWkeWebView[index];
		if (webview) {
			wkeSetDebugConfig(webview, "showDevTools",devPath.c_str());
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
		printf("\n%s,  DestroyWebWindow = %i", TAG, index);
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

			{ (const uint8_t*) "drawViewPortToBitmapData",     NULL, &drawViewPortToBitmapData },


			{ (const uint8_t*) "wkeSetCookieEnabled",     NULL, &SetCookieEnabled },
			{ (const uint8_t*) "wkeSetCookieJarFullPath",     NULL, &SetCookieJarFullPath },
			{ (const uint8_t*) "wkeSetLocalStorageFullPath",     NULL, &SetLocalStorageFullPath },


			{ (const uint8_t*) "wkeJsBindFunction",     NULL, &JsBindFunction },
			{ (const uint8_t*) "jsEvalExW",     NULL, &EvalExW },
			{ (const uint8_t*) "jsCall",     NULL, &Call },
			{ (const uint8_t*) "jsSet",     NULL, &SetGlobal },
			{ (const uint8_t*) "jsGet",     NULL, &GetGlobal },
			

			{ (const uint8_t*) "wkeSetDebugConfig",     NULL, &SetDebugConfig },
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
