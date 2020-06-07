package com.vsdevelop.air.extension.webview
{
	import flash.events.Event;

	public class ANEWebViewEvent extends Event
	{
		public static var COMPLETE:String = "complete";
		
		public static var FRAME_COMPLETE:String = "frame_complete";
		
		public static var TITLE:String = "title";
		
		
		public static var JSCALLBACK:String = "jscallback";
		
		public var data:*;
		
		public function ANEWebViewEvent(type:String,DispatchData:*=null) {
			super(type);
			data=DispatchData;
		}
		
		override public function clone():Event 
		{
			return new ANEWebViewEvent(type,data);
		}
	}
}