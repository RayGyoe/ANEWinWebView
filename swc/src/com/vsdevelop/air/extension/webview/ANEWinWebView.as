package com.vsdevelop.air.extension.webview
{
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
		protected function onStatus(event:Event):void
		{
			
			
			
		}
		
		public function wkeInitialize():void
		{
			if(isSupported){				
				initWke = _extCtx.call("wkeInitialize") as Boolean;
			}
		}
		
		public function wkeCreateWebWindow(title:String):void
		{
			if(isSupported && initWke){
				
				_extCtx.call("wkeCreateWebWindow",title);
			}else{
				throw Error( 'Wke is init:'+initWke+"isSupported"+isSupported);
			}
		}
		
	}
}