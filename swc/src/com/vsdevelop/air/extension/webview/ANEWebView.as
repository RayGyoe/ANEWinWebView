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
	
	public class ANEWebView extends EventDispatcher
	{
		private var webViewId:int;
		
		private var _extCtx:ExtensionContext;
		private var _x:int;
		private var _y:int;
		private var _width:int;
		private var _height:int;
		
		private var _visible:Boolean = true;
		
		
		//存储绑定js的回调
		private var _callFunction:Object = {};
		
		public function ANEWebView(webviewId:int=0,extCtx:ExtensionContext = null)
		{
			if(!webviewId || !extCtx)
			{
				throw Error( 'webview is not init');
			}
			
			this.webViewId = webviewId;	
			this._extCtx = extCtx;
			
			wkeSetCookieJarFullPath();
			wkeSetLocalStorageFullPath();
		}
		
		
		
		
		public function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(value:Boolean):void
		{
			_visible = value;			
			this.wkeShowWindow(_visible);
		}

		public function get height():int
		{
			return _height;
		}

		public function set height(value:int):void
		{
			_height = value;
			this.wkeMoveWindow(_x,_y,_width,_height);
		}

		public function get width():int
		{
			return _width;
		}

		public function set width(value:int):void
		{
			_width = value;
			this.wkeMoveWindow(_x,_y,_width,_height);
		}

		public function get y():int
		{
			return _y;
		}

		public function set y(value:int):void
		{
			_y = value;
			this.wkeMoveWindow(_x,_y,_width,_height);
		}

		public function get x():int
		{
			return _x;
		}

		public function set x(value:int):void
		{
			_x = value;
			this.wkeMoveWindow(_x,_y,_width,_height);
		}

		
		/**
		 * addCallBack function
		 * @return 
		 * 
		 */		
		public function get callFunction():Object
		{
			return _callFunction;
		}

		
		/**
		 * 控制窗口是否显示
		 * @param value
		 * @return 
		 * 
		 */		
		public function wkeShowWindow(value:Boolean = true):void
		{
			_visible = value;
			if(_extCtx)_extCtx.call("wkeShowWindow",webViewId,value);
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
		 * 获取网页标题
		 * wkeGetTitle 
		 * @return String
		 * 
		 */		
		public function wkeGetTitle():String
		{
			if(_extCtx)return _extCtx.call("wkeGetTitle",webViewId) as String;
			
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
			
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			if(_extCtx)_extCtx.call("wkeMoveWindow",webViewId,int(x * _scale),int(y * _scale),int(width*_scale),int(height*_scale));
		}
		
		
		/**
		 * 重新加载 
		 * wkeReload
		 */		
		public function wkeReload():void
		{
			if(_extCtx)_extCtx.call("wkeReload",webViewId);
		}
		
		
		/**
		 * 停止加载 
		 * wkeStopLoading
		 */		
		public function wkeStopLoading():void
		{
			if(_extCtx)_extCtx.call("wkeStopLoading",webViewId);
		}
		
		
		/**
		 * 设置焦点
		 * 
		 */		
		public function wkeSetFocus():void
		{
			if(_extCtx)_extCtx.call("wkeSetFocus",webViewId);
		}
		
		
		/**
		 * 设置zoom缩放值 
		 * @param value Number(1)
		 * 
		 */		
		public function wkeSetZoomFactor(value:Number = 1):void
		{
			if(_extCtx)_extCtx.call("wkeSetZoomFactor",webViewId,value);			
		}
		
		/**
		 * 获取zoom缩放值 
		 * @return Number
		 * 
		 */		
		public function wkeGetZoomFactor():Number
		{
			if(_extCtx)return _extCtx.call("wkeGetZoomFactor",webViewId) as Number;
			return 1;
		}
		
		/**
		 * 页面是否可以后退 
		 * @return Boolean
		 * 
		 */		
		public function wkeCanGoBack():Boolean
		{
			if(_extCtx)return _extCtx.call("wkeCanGoBack",webViewId) as Boolean;
			return false;
		}
		
		
		/**
		 * 强制让页面后退
		 * @return Boolean
		 * 
		 */	
		public function wkeGoBack():Boolean
		{
			if(_extCtx)return _extCtx.call("wkeGoBack",webViewId) as Boolean;
			return false;
		}
		
		
		/**
		 * 页面是否可以前进
		 * @return Boolean
		 * 
		 */	
		public function wkeCanGoForward():Boolean
		{
			if(_extCtx)return _extCtx.call("wkeCanGoForward",webViewId) as Boolean;
			return false;
		}
		
		
		/**
		 * 强制让页面前进
		 * @return Boolean
		 * 
		 */	
		public function wkeGoForward():Boolean
		{
			if(_extCtx)return _extCtx.call("wkeGoForward",webViewId) as Boolean;
			return false;
		}
		
		
		/**
		 * 绘制浏览器 
		 * @return BitmapData
		 * 
		 */		
		public function drawViewPortToBitmapData () : BitmapData
		{
			if(_extCtx){
				var darwByteArray:ByteArray = new ByteArray();
				var rect:String = _extCtx.call("drawViewPortToBitmapData",webViewId,darwByteArray) as String;
				trace(rect);
				if(rect){
					darwByteArray.position = 0;
					darwByteArray.endian = Endian.LITTLE_ENDIAN;
					var whArr:Array = rect.split("|-|");
					var bitmapdata:BitmapData = new BitmapData(int(whArr[0]),int(whArr[1]));
					
					if (darwByteArray.bytesAvailable)
					{
						bitmapdata.setPixels(bitmapdata.rect, darwByteArray);
					}
					return bitmapdata;
				}
				
			}
			return null;
		}
		
		
		/**
		 *  开启或关闭cookie
		 * @param enable Boolean
		 * @return 
		 * 
		 */		
		public function wkeSetCookieEnabled(enable:Boolean=true):void
		{
			if(_extCtx)_extCtx.call("wkeSetCookieEnabled",webViewId,enable);
		}
		
		/**
		 * 设置cookie缓存文件绝对地址
		 * @param path
		 * defualt 
		 */		
		public function wkeSetCookieJarFullPath(path:String = null):void
		{
			if(_extCtx){
				
				if(!path)
				{
					var file:File = new File(File.applicationStorageDirectory.nativePath + "/webview/cookie/cache.dat");
					file.parent.createDirectory();
					
					path = file.nativePath;
					
					trace('wkeSetCookieJarFullPath',path);
				}
				
				_extCtx.call("wkeSetCookieJarFullPath",webViewId,path);
			}
		}
		
		
		/**
		 * 设置LocalStorage缓存文件绝对目录
		 * @param path
		 * 
		 */
		public function wkeSetLocalStorageFullPath(path:String = null):void
		{
			if(_extCtx){
				
				
				if(!path)
				{
					var file:File = new File(File.applicationStorageDirectory.nativePath + "/webview/localstorage/");
					file.createDirectory();
					
					path = file.nativePath;
					
					trace('wkeSetLocalStorageFullPath',path);
				}
				_extCtx.call("wkeSetLocalStorageFullPath",webViewId,path);
			}
		}
		
		
		
		
		/**
		 * JS 相关
		 * 
		 */ 
		
		
		/**
		 * 增加js回调 
		 * @param functionName
		 * @param closure
		 * 
		 */		
		public function addCallBack (functionName:String, closure:Function) : void
		{
			if(_extCtx){
				if(_extCtx.call("wkeJsBindFunction",webViewId,functionName,closure.length))
				{
					_callFunction[functionName] = closure;
				}
			}
		}
		/**
		 * 移除某个方法回调 
		 * @param functionName
		 * @param closure
		 * 
		 */		
		public function removeCallBack (functionName:String, closure:Function) : void
		{
			if(_extCtx){
				if(_callFunction[functionName])delete _callFunction[functionName];
			}
		}
		
		
		
		
		/**
		 * 运行js
		 * @param JSString
		 * @param isInClosure
		 * @return 
		 * 
		 */
		public function jsEval(JSString:String,isInClosure:Boolean=false):Boolean
		{
			if(_extCtx)
			{
				return _extCtx.call("jsEvalExW",webViewId,JSString,isInClosure) as Boolean;
			}
			return false;
		}
		
		
		/**
		 * 调用js方法 
		 * @param fun
		 * @param args int,number,string,boolean
		 * @return 
		 * 
		 */		
		public function jsCall(fun:String,...args):Object
		{
			if(_extCtx)
			{
				var il:int  = args.length;
				
				for(var i:int=0;i<il;i++)
				{
					var type:String = (typeof args[i]);
					if(type=="boolean" || type=="number" || type=="int" || type=="string"){
						
					}else{
						throw Error( type+' type is not support');
					}
				}
				
				
				switch(il){
					case 1:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0])) as Object;
						break;
					case 2:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1])) as Object;
						break;
					case 3:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2])) as Object;
						break;
					case 4:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3])) as Object;
						break;
					case 5:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4])) as Object;
						break;
					case 6:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4]),valToString(args[5])) as Object;
						break;
					case 7:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4]),valToString(args[5]),valToString(args[6])) as Object;
						break;
					case 8:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4]),valToString(args[5]),valToString(args[6]),valToString(args[7])) as Object;
						break;
					case 9:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4]),valToString(args[5]),valToString(args[6]),valToString(args[7]),valToString(args[8])) as Object;
						break;
					case 10:
						return _extCtx.call("jsCall",webViewId,fun,valToString(args[0]),valToString(args[1]),valToString(args[2]),valToString(args[3]),valToString(args[4]),valToString(args[5]),valToString(args[6]),valToString(args[7]),valToString(args[8]),valToString(args[9])) as Object;
						break;
				}
			}
			return null;
		}
		
		/**
		 * 设置js中的参数值 
		 * @param key
		 * @param value int,number,string,boolean
		 * @return 
		 * 
		 */		
		public function jsSet(key:String,value:Object):Boolean
		{
			if(_extCtx)
			{
				return _extCtx.call("jsSet",webViewId,key,valToString(value)) as Boolean;
			}
			return false;
		}
		
		/**
		 * 获取js中的参数值
		 * @param key
		 * @param value  int,number,string,boolean
		 * @return 
		 * 
		 */		
		public function jsGet(key:String):Object
		{
			if(_extCtx)
			{
				return _extCtx.call("jsGet",webViewId,key) as Object;
			}			
			return null;
		}
		
		
		private function valToString(value:*):String
		{
			return String(value);	
		}
		
		
		
		/**
		 * DevTools
		 * @param devToolsHtml	file:///c:/miniblink/front_end/inspector.html
		 * 
		 */		
		public function wkeSetDebugConfig(devToolsHtml:String = null):void
		{
			if(_extCtx && devToolsHtml)_extCtx.call("wkeSetDebugConfig",webViewId,devToolsHtml);
		}
		
		
		/**
		 * 延迟让miniblink垃圾回收 
		 * @param delayMs
		 * 
		 */		
		public function wkeGC(delayMs:Number = 500):void
		{
			if(_extCtx)_extCtx.call("wkeGC",webViewId,delayMs);
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