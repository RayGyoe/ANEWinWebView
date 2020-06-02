package com.vsdevelop.air.extension.webview
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExtensionContext;
	import flash.geom.Rectangle;
	import flash.net.dns.AAAARecord;
	
	public class ANEWebView extends EventDispatcher
	{
		private var webViewId:int;
		
		private var _extCtx:ExtensionContext;
		
		public function ANEWebView(webviewId:int=0,extCtx:ExtensionContext = null)
		{
			if(!webviewId || !extCtx)
			{
				throw Error( 'webview is not init');
			}
			
			this.webViewId = webviewId;	
			this._extCtx = extCtx;
		}
		
		
		/**
		 * 加载url。url必须是网络路径，如http://qq.com/
		 * @param str
		 * 
		 */		
		public function wkeLoadURL(path:String):void
		{
			if(_extCtx)_extCtx.call("wkeLoadURL",webViewId,path);
		}
		
		/**
		 * 加载一段html
		 * @param str
		 * 
		 */		
		public function wkeLoadHTML(str:String):void
		{
			if(_extCtx)_extCtx.call("wkeLoadHTML",webViewId,str);
		}
		
		
		/**
		 *  获取webview的UA
		 * @param str
		 * @return String
		 * 
		 */		
		public function wkeGetUserAgent():String
		{
			if(_extCtx)return _extCtx.call("wkeGetUserAgent",webViewId) as String;
			
			return null;
		}
		
		
		/**
		 * 获取webview主frame的url 
		 * @param str
		 * @return String
		 * 
		 */		
		public function wkeGetURL():String
		{
			if(_extCtx)return _extCtx.call("wkeGetURL",webViewId) as String;
			
			return null;
		}
		
		
		/**
		 * 调整webview大小位置
		 * @param rect
		 * 
		 */		
		public function wkeMoveWindow(x:int=0,y:int=0,width:int=200,height:int=200):void
		{
			var _scale:Number= ANEWinWebView.getInstance().scale;
			if(_extCtx)_extCtx.call("wkeMoveWindow",webViewId,int(x * _scale),int(y * _scale),int(width*_scale),int(height*_scale));
		}
		
		
		/**
		 *  销毁wkeWebView对应的所有数据结构，包括真实窗口等
		 */		
		public function wkeDestroyWebWindow():void
		{
			if(_extCtx)_extCtx.call("wkeDestroyWebWindow",webViewId);
		}
		
		
	}
}