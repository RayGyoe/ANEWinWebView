package
{
	//import flash.desktop.NativeApplication;
	import com.vsdevelop.air.extension.webview.ANEWinWebView;
	import com.vsdevelop.controls.Fps;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author Ray.eDoctor
	 */
	public class Main extends Sprite 
	{
		
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
			}
			
			
			addChild(new Fps());
			
			stage.addEventListener(MouseEvent.CLICK, addWebView);
		}
		
		private function addWebView(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.CLICK, addWebView);
			
			ANEWinWebView.getInstance().wkeCreateWebWindow(stage.nativeWindow.title);
		}
		
		
		
	}
	
}