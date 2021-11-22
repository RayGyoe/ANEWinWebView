package com.vsdevelop.air.extension.webview
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.filesystem.File;
	
	/**
	 */ 
	public class ANECefWebView extends EventDispatcher
	{
		private static var _instance:ANECefWebView;
		private var _extCtx:ExtensionContext;
		private var _isSupported:Boolean;
		private var _scale:Number = 1;
		private var webViewObject:Object = {};
		
		public function ANECefWebView()
		{
			if (!_instance)
			{
				_extCtx = ExtensionContext.createExtensionContext("com.vsdevelop.air.extension.cefwebview", null);
				
				if (_extCtx != null)
				{
					_isSupported = _extCtx.call("isSupported") as Boolean;
					_extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				} else
				{
					trace('extCtx is null.'); 
				}
				_instance = this;
			}
			else
			{
				throw Error( 'This is a singleton, use getInstance, do not call the constructor directly');
			}
		}

		public function set scale(value:Number):void
		{
			_scale = value;
		}

		public function get scale():Number
		{
			return _scale;
		}

		public static function getInstance() : ANECefWebView
		{
			return _instance ? _instance : new ANECefWebView();
		}
		
		public function get isSupported():Boolean
		{
			return _isSupported;
		}

		/**
		 * 事件 
		 * @param event
		 * 
		 */		
		protected function onStatus(event:StatusEvent):void
		{
			trace(event.level,event.code);
			
		}
		
		/**
		 * 创建一个带真实窗口的wkeWebView
		 * @param stage Stage
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @return ANEWebView
		 * 
		 */		
		public function CreateWebWindow(stage:Stage,url:String,x:int=0,y:int=0,width:int=200,height:int=200):CefWebView
		{
			if(_isSupported){
				
				var _x:int = x * _scale;
				var _y:int = y * _scale;
				var _width:int = width * _scale;
				var _height:int = height * _scale;
				var webviewId:int = _extCtx.call("CreateWebWindow",stage.nativeWindow.title,url,_x,_y,_width,_height) as int;
				if(webviewId){
					return new CefWebView(webviewId,_extCtx);
				}
			}else{
				throw Error( 'Cef not isSupported');
			}
			return null;
		}
		
		
		/**
		 * 开启高分屏支持。
		 */		
		public function EnableHighDPISupport(stage:Stage):void{
			if(_isSupported){
				
				var screenWidth:int = _extCtx.call("EnableHighDPISupport") as int;
				_scale = screenWidth/stage.fullScreenWidth;
			}else{
				throw Error( 'Cef is not isSupported');
			}
		}
		
		public function destroy():void{
			if(_isSupported){
				
				_extCtx.call("destroy");
			}else{
				throw Error( 'Cef is not isSupported');
			}
		}
		
	}
}