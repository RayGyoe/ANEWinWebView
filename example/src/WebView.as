package 
{
	import com.greensock.layout.ScaleMode;
	import com.vsdevelop.air.extension.webview.ANECefWebView;
	import com.vsdevelop.air.extension.webview.ANEWebView;
	import com.vsdevelop.air.extension.webview.ANEWinWebView;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author eDoctor DSN - Ray.Lei
	 */
	public class WebView extends NativeWindow 
	{
		private var skinView:skin;
		private var webviewMain:ANEWebView;
		
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
			
			
			setTimeout(init, 200);
			
			addEventListener(Event.CLOSE, removeWebView);
		}
		
		private function init():void 
		{
			
			ANECefWebView.getInstance().CreateWebWindow(stage, 'https://meeting.talkmed.com', 0, 0, stage.stageWidth, stage.stageHeight);
			
			
			//webviewMain.wkeLoadURL('https://www.edoctor.cn');
			
			
		}
		
		private function removeWebView(e:Event):void 
		{
		
		}
		
	}

}