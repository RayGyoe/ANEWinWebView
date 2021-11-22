package 
{
	import com.greensock.layout.ScaleMode;
	import com.vsdevelop.air.extension.webview.ANECefWebView;
	import com.vsdevelop.air.extension.webview.CefWebView;
	import com.vsdevelop.air.filesystem.FileCore;
	import com.vsdevelop.events.Events;
	import com.vsdevelop.net.XMLLoader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author eDoctor DSN - Ray.Lei
	 */
	public class WebView extends NativeWindow 
	{
		private var skinView:skin;
		private var webiew:CefWebView;
		
		public function WebView(windowTitle:String) 
		{
			var windowinit:NativeWindowInitOptions = new NativeWindowInitOptions();
			super(windowinit);
			
			bounds = new Rectangle((stage.fullScreenWidth-1100)*0.5, (stage.fullScreenHeight-600) * 0.5, 1100, 600);
			activate();
			title = windowTitle;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// touch or gesture?
			// entry point
			stage.align = StageAlign.TOP_LEFT;
			
			
			skinView = new skin();
			stage.addChild(skinView);
			skinView.go.addEventListener(MouseEvent.CLICK, goPath);
			skinView.localfile.addEventListener(MouseEvent.CLICK, localHtml);
			skinView.prev.addEventListener(MouseEvent.CLICK, prevPage);
			skinView.next.addEventListener(MouseEvent.CLICK, nextPage);
			skinView.addwind.addEventListener(MouseEvent.CLICK, reloadview);
			skinView.hidebtn.addEventListener(MouseEvent.CLICK, visibleClick);
			
			skinView.path.text = "https://www.edoctor.cn"
			
			init();
			
			stage.addEventListener(Event.RESIZE, resizeView);
			addEventListener(Event.CLOSE, removeWebView);
		}
		
		private function localHtml(e:MouseEvent):void 
		{
			trace("eee");
			
			var load:XMLLoader = new XMLLoader();
			load.addEventListener(Events.COMPLETE, loadComplete);
			load.loadXML('/assets/index.html');
		}
		
		private function loadComplete(e:Events):void 
		{
			var load:XMLLoader = e.target as XMLLoader;
			trace(load.getData)
			
			if (webiew)
			{
				webiew.loadHTML(load.getData);
			}
			
			load.dispose();
		}
		
		private function nextPage(e:MouseEvent):void 
		{
			if (webiew)
			{
				if (webiew.canForward()) webiew.historyForward();
				else trace("没有下一页");
			}
		}
		
		private function prevPage(e:MouseEvent):void 
		{
			if (webiew)
			{
				if (webiew.canBack()) webiew.historyBack();
				else trace("没有上一页");
			}
		}
		
		private function visibleClick(e:MouseEvent):void 
		{
			if (webiew) webiew.visible = !webiew.visible;
		}
		
		private function reloadview(e:MouseEvent):void 
		{
			if (webiew)
			{
				webiew.reload();
			}
		}
		
		private function goPath(e:MouseEvent):void 
		{
			if (webiew)
			{
				webiew.loadURL(skinView.path.text);
			}
		}
		
		private function resizeView(e:Event):void 
		{
			if (webiew)
			{
				webiew.rect(0, 60, stage.stageWidth, stage.stageHeight - 60);
			}
		}
		
		private function init():void 
		{
			if (ANECefWebView.getInstance().isSupported)
			{
				webiew = ANECefWebView.getInstance().CreateWebWindow(stage, 'https://meeting.talkmed.com', 0, 60, stage.stageWidth, stage.stageHeight- 60);
			}
			//webviewMain.wkeLoadURL('https://www.edoctor.cn');
		}
		
		private function removeWebView(e:Event):void 
		{
			if(stage)stage.removeEventListener(Event.RESIZE, resizeView);
			webiew.destroy();
		}
		
	}

}