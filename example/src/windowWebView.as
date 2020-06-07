package 
{
	import com.greensock.layout.ScaleMode;
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
	
	/**
	 * ...
	 * @author eDoctor DSN - Ray.Lei
	 */
	public class windowWebView extends NativeWindow 
	{
		private var skinView:skin;
		private var webviewMain:ANEWebView;
		
		public function windowWebView(windowTitle:String) 
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
			
			skinView.debug.addEventListener(MouseEvent.CLICK, devTools);
			skinView.localfile.addEventListener(MouseEvent.CLICK, localHtml);
			
			
			
			webviewMain = ANEWinWebView.getInstance().wkeCreateWebWindow(stage,0,60,bounds.width,bounds.height);
			webviewMain.wkeLoadURL('https://www.talkmed.com');
			
			webviewMain.addCallBack("asfunction2", function(arg1:String,arg2:String,arg3:String):void{
				trace(arguments);
				
			});
			
			webviewMain.wkeShowWindow();
			
			
			addEventListener(Event.CLOSE, removeWebView);
		}
		
		private function removeWebView(e:Event):void 
		{
			webviewMain.wkeDestroyWebWindow();
		}
		
		private function localHtml(e:MouseEvent):void 
		{
			//http://hook.test/
			var str:String = ""+File.applicationDirectory.nativePath + '/assets/index.html';
			
			trace(str);
			
			webviewMain.wkeLoadURL(str);
		}
		
		private function devTools(e:MouseEvent):void 
		{
			var path:String = File.applicationDirectory.nativePath + '/devtools/inspector.html';
			trace(path);
			webviewMain.wkeSetDebugConfig(path);
		}
	}

}