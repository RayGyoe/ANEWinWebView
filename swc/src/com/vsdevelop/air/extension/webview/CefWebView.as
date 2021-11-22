package com.vsdevelop.air.extension.webview
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExtensionContext;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class CefWebView extends EventDispatcher
	{
		private var webViewId:int;
		
		private var _extCtx:ExtensionContext;
		private var _x:int;
		private var _y:int;
		private var _width:int;
		private var _height:int;
		
		private var _visible:Boolean = true;
		
		
		
		public function CefWebView(webviewId:int=0,extCtx:ExtensionContext = null)
		{
			if(!webviewId || !extCtx)
			{
				throw Error( 'webview is not init');
			}
			
			this.webViewId = webviewId;	
			this._extCtx = extCtx;
		}
		
		
		
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			if(_extCtx)_extCtx.call("showWebView",webViewId,value);
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
			this.rect(_x,_y,_width,_height);
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
			this.rect(_x,_y,_width,_height);
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function set y(value:int):void
		{
			_y = value;
			this.rect(_x,_y,_width,_height);
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set x(value:int):void
		{
			_x = value;
			
			this.rect(_x,_y,_width,_height);
		}
		
		
		/**
		 * 调整webview大小位置
		 * @param rect
		 */		
		public function rect(x:int=0,y:int=0,width:int=200,height:int=200):void
		{
			var _scale:Number= ANECefWebView.getInstance().scale;
			
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			if(_extCtx)_extCtx.call("moveWindow",webViewId,int(x * _scale),int(y * _scale),int(width*_scale),int(height*_scale));
		}
		
		
		/**
		 * 加载url。url必须是网络路径，如http://qq.com/
		 * @param str
		 * 
		 */		
		public function loadURL(path:String):void
		{
			if(_extCtx)_extCtx.call("loadURL",webViewId,path);
		}
		
		
		/**
		 * 加载一段html
		 * @param str
		 * 
		 */		
		public function loadHTML(str:String):void
		{
			if(_extCtx)_extCtx.call("loadHTML",webViewId,str);
		}
		
		
		
		/**
		 * 重新加载 
		 * wkeReload
		 */		
		public function reload():void
		{
			if(_extCtx)_extCtx.call("reload",webViewId);
		}
		
		
		/**
		 * 停止加载 
		 * wkeStopLoading
		 */		
		public function stopLoading():void
		{
			if(_extCtx)_extCtx.call("stopLoading",webViewId);
		}
		
		
		/**
		 * 是否可以返回上一页 
		 * @return 
		 * 
		 */		
		public function canBack():Boolean
		{
			if(_extCtx) return _extCtx.call("canBack",webViewId) as Boolean;
			
			return false;
		}
		
		/**
		 * 在浏览历史记录中导航到上一个页面。
		 * historyBack
		 */
		public function historyBack():void
		{
			if(_extCtx)_extCtx.call("historyBack",webViewId);
		}
		
		
		/**
		 * 是否能导航到下一页 
		 * @return 
		 * 
		 */		
		public function canForward():Boolean
		{
			if(_extCtx) return _extCtx.call("canForward",webViewId) as Boolean;
			
			return false;
		}
		
		/**
		 * 在浏览历史记录中导航到下一个页面。
		 * historyBack
		 */
		public function historyForward():void
		{
			if(_extCtx)_extCtx.call("historyForward",webViewId);
		}
		
		
		/**
		 *  销毁wkeWebView对应的所有数据结构，包括真实窗口等
		 */		
		public function destroy():void
		{
			if(_extCtx)_extCtx.call("destroyWebView",webViewId);
		}
		
		
	}
}