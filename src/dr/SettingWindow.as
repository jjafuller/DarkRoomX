package dr
{
	import flash.events.Event;
	import flash.text.TextField;
	
	import mx.containers.TitleWindow;
	import mx.controls.*;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class SettingWindow extends mx.containers.TitleWindow
	{
		public var btnCancel:Button;
		public var btnOk:Button;
		
		[Bindable]
		public var txtPageWidth:TextInput;
		
		public function SettingWindow()
		{
			// global events
			this.addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		public function init():void
		{
			// button events
			btnCancel.addEventListener("click", handleCancel);
			//btnOk.addEventListener("click", handleOk);
		}
		
		public function removePopup():void
		{
			PopUpManager.removePopUp(this);
		}

		public function handleCancel(event:Event):void
		{
			removePopup();
		}

		public function handleClose(event:CloseEvent):void
		{
			removePopup();
		}
		
		public function handleOk(event:Event):void
		{
			//removePopup();
		}
	}
}