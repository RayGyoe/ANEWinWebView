package
{
	//import flash.desktop.NativeApplication;
	import com.vsdevelop.air.extension.webview.ANEWebView;
	import com.vsdevelop.air.extension.webview.ANEWinWebView;
	import com.vsdevelop.controls.Fps;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Ray.eDoctor
	 */
	public class Main extends Sprite 
	{
		
		private var windowId:int = 0;
		private var webviewMain:ANEWebView;
		private var skinView:skin;
		
		public function Main():void 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			stage.align = StageAlign.TOP_LEFT;
			
			
			if (ANEWinWebView.getInstance().isSupported)
			{
				ANEWinWebView.getInstance().wkeInitialize();
				ANEWinWebView.getInstance().wkeEnableHighDPISupport(stage);
			}
			
			//NativeApplication.nativeApplication
			
			
			//addChild(new Fps());
			
			skinView = new skin();
			addChild(skinView);
			
			
			skinView.go.addEventListener(MouseEvent.CLICK, goPath);
			skinView.cache.addEventListener(MouseEvent.CLICK, openCachePath);
			skinView.prev.addEventListener(MouseEvent.CLICK, prevPage);
			skinView.next.addEventListener(MouseEvent.CLICK, nextPage);
			skinView.addwind.addEventListener(MouseEvent.CLICK, addWindows);
			
			
			skinView.path.text = 'https://www.talkmed.com';
			
			
			webviewMain = ANEWinWebView.getInstance().wkeCreateWebWindow(stage,0,60,stage.stageWidth,stage.stageHeight-100);
			goPath();
			
			stage.addEventListener(Event.RESIZE, resizeView);
		}
		
		private function addWindows(e:MouseEvent):void 
		{
			windowId++;
				
			
			var windowinit:NativeWindowInitOptions = new NativeWindowInitOptions();
			var newWindow:NativeWindow = new NativeWindow(windowinit);
			
			var ws:int = stage.fullScreenWidth * 0.5;
			var hs:int = stage.fullScreenHeight * 0.5;
			newWindow.bounds = new Rectangle(ws*0.5, hs*0.5, ws, hs);
			newWindow.activate();
		
			var windowTitle:String = "window-" + windowId;
			
			newWindow.title = windowTitle;
			
			var webview:ANEWebView = ANEWinWebView.getInstance().wkeCreateWebWindow(newWindow.stage,0,0,ws-20,hs-20);
			webview.wkeLoadURL('https://www.talkmed.com');
		}
		
		private function nextPage(e:MouseEvent):void 
		{
			if (webviewMain.wkeCanGoForward())
			{
				webviewMain.wkeGoForward();
			}
		}
		
		private function prevPage(e:MouseEvent):void 
		{
			if (webviewMain.wkeCanGoBack())
			{
				webviewMain.wkeGoBack();
			}
		}
		
		private function openCachePath(e:MouseEvent):void 
		{
			File.applicationStorageDirectory.openWithDefaultApplication();
		}
		
		private function goPath(e:MouseEvent = null):void 
		{
			webviewMain.wkeLoadURL(skinView.path.text);
		}
		
		private function resizeView(e:Event):void 
		{
			//trace(Capabilities.screenDPI,Capabilities.screenDPI / 64);
			//trace(stage.stageWidth,stage.stageHeight,stage.fullScreenWidth,stage.fullScreenHeight);
			if (webviewMain)
			{
				webviewMain.wkeMoveWindow(0, webviewMain.y, stage.stageWidth, stage.stageHeight-webviewMain.y);
			}
		}
		
		
		
		
	}
	
}