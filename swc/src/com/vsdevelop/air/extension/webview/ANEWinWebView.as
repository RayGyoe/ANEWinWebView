package com.vsdevelop.air.extension.webview
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.filesystem.File;
	
	/**
	 * https://weolar.github.io/miniblink/views/doc/api.html
	 */ 
	public class ANEWinWebView extends EventDispatcher
	{
		private static var _instance:ANEWinWebView;
		private var _extCtx:ExtensionContext;
		private var _isSupported:Boolean;
		private var initWke:Boolean;
		private var _scale:Number = 1;
		private var webViewObject:Object = {};
		
		public function ANEWinWebView()
		{
			if (!_instance)
			{
				_extCtx = ExtensionContext.createExtensionContext("com.vsdevelop.air.extension.winwebview", null);
				
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

		public static function getInstance() : ANEWinWebView
		{
			return _instance ? _instance : new ANEWinWebView();
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
			//trace(event.level,event.code);
			
			var array:Array = event.level.split("|-|");
			var webView:ANEWebView = webViewObject[int(array[0])];
			
			
			switch(event.code)
			{
				case ANEWebViewEvent.FRAME_COMPLETE:
					if(webView){
						webView.dispatchEvent(new ANEWebViewEvent(event.code,int(array[1])));
					}
					break;
				case ANEWebViewEvent.TITLE:
					if(webView){
						webView.dispatchEvent(new ANEWebViewEvent(event.code,String(array[1])));
					}
					break;
				
				case ANEWebViewEvent.JSCALLBACK:
					//
					if(webView && webView.callFunction[array[1]]){
						const fun:Function = webView.callFunction[array[1]];
						fun.apply(null,argArrayEncode(array));
					}
					break;
				
				default:					
					if(webView){
						webView.dispatchEvent(new ANEWebViewEvent(event.code));
					}	
					break;
			}
		}
		
		protected function argArrayEncode(array:Array):Array
		{
			var args:Array = [];
			if(array.length>2)
			{
				var il:int = array.length;
				for(var i:int = 2;i<il;i++)
				{
					var value:String = array[i];					
					switch(value)
					{
						case "false":
							args[args.length] = false;
							break;
						case "true":
							args[args.length] = true;
						case "null":
							args[args.length] = null;
							break;
						default:
							args[args.length] = value;
							break;
					}
					
				}
			}			
			return args;
		}		
		
		
		/**
		 * 初始化整个mb。此句必须在所有mb api前最先调用。并且所有mb api必须和调用wkeInit的线程为同个线程
		 * wkeInitialize
		 */		
		public function wkeInitialize():void
		{
			if(isSupported){
				initWke = _extCtx.call("wkeInitialize") as Boolean;
			}
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
		public function wkeCreateWebWindow(stage:Stage,x:int=0,y:int=0,width:int=200,height:int=200):ANEWebView
		{
			if(isSupported && initWke){
				
				var _x:int = x * _scale;
				var _y:int = y * _scale;
				var _width:int = width * _scale;
				var _height:int = height * _scale;
				var webviewId:int = _extCtx.call("wkeCreateWebWindow",stage.nativeWindow.title,_x,_y,_width,_height) as int;
				if(webviewId){
					var webview:ANEWebView = new ANEWebView(webviewId,_extCtx);
					webview.wkeMoveWindow(x,y,width,height);
					webViewObject[webviewId] = webview;
					return webview;
				}
			}else{
				throw Error( 'Wke is init:'+initWke+"isSupported"+isSupported);
			}
			return null;
		}
		
		
		/**
		 * 开启高分屏支持。注意，这个api内部是通过设置ZOOM，并且关闭系统默认放大来实现。所以再使用wkeGetZoomFactor会发现值可能不为1
		 */		
		public function wkeEnableHighDPISupport(stage:Stage):void{
			if(isSupported && initWke){
				
				var screenWidth:int = _extCtx.call("wkeEnableHighDPISupport") as int;
				_scale = screenWidth/stage.fullScreenWidth;
			}else{
				throw Error( 'Wke is init:'+initWke+"isSupported"+isSupported);
			}
		}
		
		
		/**
		 * wkeVersion
		 * 获取目前api版本号
		 * @return String
		 * 
		 */		
		public function wkeVersion():String{
			
			if(isSupported && initWke){
				return _extCtx.call("wkeVersion") as String;
			}
			return null;
		}
		/**
		 * wkeVersionString
		 * 获取版本字符串
		 * @return String
		 * 
		 */		
		public function wkeVersionString():String{
			if(isSupported && initWke){
				return _extCtx.call("wkeVersionString") as String;
			}
			return null;
		}
	}
}