package dr
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.containers.TitleWindow;
	import mx.controls.*;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class ConfigurationWindow extends mx.containers.TitleWindow
	{
		public var btnCancel:Button;
		public var btnOk:Button;
		
		private var settingsFile:File;
		
		[Bindable]
		public var config:Configuration;
		public var txtPageWidth:TextInput;
		
		public function ConfigurationWindow()
		{
			// global events
			this.addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		public function init():void
		{
			initSettings();
			
			// button events
			btnCancel.addEventListener("click", handleCancel);
			btnOk.addEventListener("click", handleOk);
		}
		
		public function initSettings():void
		{
			settingsFile = File.applicationStorageDirectory;
			settingsFile = settingsFile.resolvePath("settings.xml"); 
			
			config = new Configuration(settingsFile);
		}
		
		public function processSettings():Configuration
		{
			config.settings.page_width = txtPageWidth.text;
			
			return config;
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
			removePopup();
		}
	}
}