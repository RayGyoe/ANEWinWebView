package
{
	import com.vsdevelop.air.extension.webview.ANECefWebView;
	import com.vsdevelop.controls.Fps;
	import com.vsdevelop.utils.StringCore;
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
	public class MainCefWebView extends Sprite 
	{
		
		private var windowId:int = 0;
		private var skinView:skin;
		
		private var i:int;
		
		public function MainCefWebView():void 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// touch or gesture?
			// entry point
			stage.align = StageAlign.TOP_LEFT;
			
			
			//NativeApplication.nativeApplication
			
			
			skinView = new skin();
			addChild(skinView);
			//trace(Capabilities.cpuArchitecture.toString());
			//skinView._platform.text = Capabilities.cpuAddressSize.toString();
			
			addChild(new Fps());
			
			skinView.go.addEventListener(MouseEvent.CLICK, goPath);
			skinView.cache.addEventListener(MouseEvent.CLICK, openCachePath);
			skinView.prev.addEventListener(MouseEvent.CLICK, prevPage);
			skinView.next.addEventListener(MouseEvent.CLICK, nextPage);
			skinView.addwind.addEventListener(MouseEvent.CLICK, addWindows);
			skinView.hidebtn.addEventListener(MouseEvent.CLICK, visibleClick);
			skinView.zoombtn.addEventListener(MouseEvent.CLICK, zoomClick);
			
			
			skinView.localfile.addEventListener(MouseEvent.CLICK, localHtml);
			
			skinView.drawview.addEventListener(MouseEvent.CLICK, drawToBitmapData);
			
			skinView.path.text = 'https://meeting.talkmed.com';
			stage.addEventListener(Event.RESIZE, resizeView);
			
			if (ANECefWebView.getInstance().isSupported){
				ANECefWebView.getInstance().EnableHighDPISupport(stage);
			}
		}
		
		private function goPath(e:MouseEvent):void 
		{	
			var cefheight:int = 400;
			if (ANECefWebView.getInstance().isSupported)
			{
				ANECefWebView.getInstance().CreateWebWindow(stage, skinView.path.text, 0, i*cefheight+100, stage.stageWidth, cefheight);
				i++;			
			}

		}
		
		private function drawToBitmapData(e:MouseEvent):void 
		{
			
		}
		
		
		private function localHtml(e:MouseEvent):void 
		{
			//http://hook.test/
			var str:String = ""+File.applicationDirectory.nativePath + '/assets/index.html';
			trace(str);
		}
		
		
		
		private var zoomObject:Object = {1:1, 2:1.5, 3:2,4:3};
		private var zoomIndex:int = 1;
		private function zoomClick(e:MouseEvent):void 
		{
			zoomIndex++;
			if (zoomIndex > 4) zoomIndex = 1;
		}
		
		private function visibleClick(e:MouseEvent):void 
		{
			
		}
		
		private function addWindows(e:MouseEvent):void 
		{
			windowId++;
			new  WebView("window-" + windowId);
			//new windowWebView("window-" + windowId);
		}
		
		private function nextPage(e:MouseEvent):void 
		{
			
		}
		
		private function prevPage(e:MouseEvent):void 
		{
			
		}
		
		private function openCachePath(e:MouseEvent):void 
		{
			File.applicationStorageDirectory.openWithDefaultApplication();
		}
		
		private function resizeView(e:Event):void 
		{
		}
		
	}
	
}