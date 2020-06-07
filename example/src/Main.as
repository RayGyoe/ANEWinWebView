package
{
	//import flash.desktop.NativeApplication;
	import com.vsdevelop.air.extension.webview.ANEWebView;
	import com.vsdevelop.air.extension.webview.ANEWebViewEvent;
	import com.vsdevelop.air.extension.webview.ANEWinWebView;
	import com.vsdevelop.controls.Fps;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
			skinView.hidebtn.addEventListener(MouseEvent.CLICK, visibleClick);
			skinView.zoombtn.addEventListener(MouseEvent.CLICK, zoomClick);
			
			
			skinView.debug.addEventListener(MouseEvent.CLICK, devTools);
			skinView.localfile.addEventListener(MouseEvent.CLICK, localHtml);
			
			skinView.drawview.addEventListener(MouseEvent.CLICK, drawToBitmapData);
			
			
			skinView.jscall.addEventListener(MouseEvent.CLICK, astojs);
			skinView.setjs.addEventListener(MouseEvent.CLICK, astojs);
			skinView.getjs.addEventListener(MouseEvent.CLICK, astojs);
			
			skinView.path.text = 'https://www.talkmed.com';
			
			
			webviewMain = ANEWinWebView.getInstance().wkeCreateWebWindow(stage, 0, 60, stage.stageWidth, stage.stageHeight - 60);
			webviewMain.addEventListener(ANEWebViewEvent.COMPLETE, webViewEvents);
			webviewMain.addEventListener(ANEWebViewEvent.TITLE, webViewEvents);
			webviewMain.addEventListener(ANEWebViewEvent.FRAME_COMPLETE, webViewEvents);
			webviewMain.addEventListener(ANEWebViewEvent.JSCALLBACK, webViewEvents);
			webviewMain.addCallBack("asfunction", function(arg1:int,arg2:String):void{
				
				trace(arguments);
			});
			webviewMain.wkeShowWindow();
			
			
			goPath();
			
			stage.addEventListener(Event.RESIZE, resizeView);
			
			var a:int = 1;
			trace(typeof true)
		}
		
		private function drawToBitmapData(e:MouseEvent):void 
		{
			var bitmapdata:BitmapData = webviewMain.drawViewPortToBitmapData();
			trace(bitmapdata);
			
			var bitmap:Bitmap = new Bitmap(bitmapdata);			
			addChild(bitmap);
			bitmap.scaleX = bitmap.scaleY =  stage.stageWidth / bitmap.width;
			
			
			bitmap.y = 60;
			
			webviewMain.visible = false;
		}
		
		private function webViewEvents(e:ANEWebViewEvent):void 
		{
			trace("webViewEvents",e.type, e.data);
		}
		
		
		private function localHtml(e:MouseEvent):void 
		{
			//http://hook.test/
			var str:String = ""+File.applicationDirectory.nativePath + '/assets/index.html';
			
			trace(str);
			
			webviewMain.wkeLoadURL(str);
		}
		private function astojs(e:MouseEvent):void 
		{
			switch (e.target){
				case skinView.jscall:
					trace(webviewMain.jsCall("astojs",2,"string"));
					break;
				case skinView.setjs:
					trace(webviewMain.jsSet("jsValue","ANEWebView AS3 Set Value 2.0"));
					break;
					
				case skinView.getjs:
					trace(webviewMain.jsGet("jsValue"));
					break;
			}
			
		}
		
		
		private function devTools(e:MouseEvent):void 
		{
			var path:String = File.applicationDirectory.nativePath + '/devtools/inspector.html';
			trace(path);
			webviewMain.wkeSetDebugConfig(path);
		}
		
		
		private var zoomObject:Object = {1:1, 2:1.5, 3:2,4:3};
		private var zoomIndex:int = 1;
		private function zoomClick(e:MouseEvent):void 
		{
			trace('zoom', webviewMain.wkeGetZoomFactor());
			
			
			webviewMain.wkeSetZoomFactor(zoomObject[zoomIndex]);
			zoomIndex++;
			if (zoomIndex > 4) zoomIndex = 1;
		}
		
		private function visibleClick(e:MouseEvent):void 
		{
			webviewMain.visible = !webviewMain.visible;
		}
		
		private function addWindows(e:MouseEvent):void 
		{
			windowId++;
			
			new windowWebView("window-" + windowId);
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
			if (!webviewMain.visible)
			{
				webviewMain.visible = true;
			}
		}
		
		private function resizeView(e:Event):void 
		{
			//trace(Capabilities.screenDPI,Capabilities.screenDPI / 64);
			//trace(stage.stageWidth,stage.stageHeight,stage.fullScreenWidth,stage.fullScreenHeight);
			if (webviewMain)
			{
				webviewMain.wkeMoveWindow(0, 60, stage.stageWidth, stage.stageHeight-60);
			}
		}
		
		
		
		
	}
	
}