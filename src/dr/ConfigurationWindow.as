package dr
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.Font;
	
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.controls.*;
	import mx.controls.sliderClasses.Slider;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class ConfigurationWindow extends mx.containers.TitleWindow
	{
		public var btnCancel:Button;
		public var btnOk:Button;
		
		private var settingsFile:File;
		private var fonts:Array; 
		
		[Bindable]
		public var config:Configuration;
		
		public var txtPageWidth:TextInput;
		public var txtPageHeight:TextInput;
		public var txtPageMarginVertical:TextInput;
		public var txtPageMarginHorizontal:TextInput;
		public var txtPagePaddingHorizontal:TextInput;
		public var txtPagePaddingVertical:TextInput;
		public var chkPageHeightAuto:CheckBox;
		public var chkPageWidthAuto:CheckBox;
		public var sldPageBackgroundOpacity:Slider;
		public var clrPageBackgroundColor:ColorPicker;
		public var cnvPageBackgroundColor:Canvas;
		
		public var chkLaunchFullScreen:CheckBox;
		public var chkLiveScrolling:CheckBox;
		public var clrBackgroundColor:ColorPicker;
		public var cnvBackgroundColor:Canvas;
		public var sldBackgroundOpacity:Slider;
		
		public var cboFont:ComboBox;
		public var txtFontSize:TextInput;
		
		
		public function ConfigurationWindow()
		{
			// global events
			this.addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		public function init():void
		{
			// assign fonts
			fonts = Font.enumerateFonts(true);
			fonts.sortOn("fontName", Array.CASEINSENSITIVE);
			
			// button events
			btnCancel.addEventListener("click", handleCancel);
			btnOk.addEventListener("click", handleOk);
		}
		
		public function processSettings():Configuration
		{
			// page
			config.settings.pageWidth = txtPageWidth.text;
			config.settings.pageWidthAuto = chkPageWidthAuto.selected;
			config.settings.pageHeight = txtPageHeight.text;
			config.settings.pageHeightAuto = chkPageHeightAuto.selected;
			config.settings.pageMarginVertical = txtPageMarginVertical.text;
			config.settings.pageMarginHorizontal = txtPageMarginHorizontal.text;
			config.settings.pagePaddingVertical = txtPagePaddingVertical.text;
			config.settings.pageBackgroundOpacity = sldPageBackgroundOpacity.value;
			config.settings.pageBackgroundColor = clrPageBackgroundColor.value;
			
			// general
			config.settings.launchFullScreen = chkLaunchFullScreen.selected;
			config.settings.liveScrolling = chkLiveScrolling.selected;
			config.settings.backgroundColor = clrBackgroundColor.value;
			config.settings.backgroundOpacity = sldBackgroundOpacity.value;
			
			// formatting
			
			config.settings.fontSize = txtFontSize.text;
			
			return config;
		}
		
		public function updateFields():void
		{
			// page
			txtPageWidth.text = config.settings.pageWidth;
			chkPageWidthAuto.selected = config.settings.pageWidthAuto;
			txtPageHeight.text = config.settings.pageHeight;
			chkPageHeightAuto.selected = config.settings.pageHeightAuto;
			txtPageMarginVertical.text = config.settings.pageMarginVertical;
			txtPageMarginHorizontal.text = config.settings.pageMarginHorizontal;
			txtPagePaddingVertical.text = config.settings.pagePaddingVertical;
			sldPageBackgroundOpacity.value = config.settings.pageBackgroundOpacity;
			cnvPageBackgroundColor.setStyle('backgroundColor', config.settings.pageBackgroundColor);
			
			// general
			chkLaunchFullScreen.selected = config.settings.launchFullScreen;
			chkLiveScrolling.selected = config.settings.liveScrolling;
			cnvBackgroundColor.setStyle('backgroundColor', config.settings.backgroundColor);
			sldBackgroundOpacity.value = config.settings.backgroundOpacity
			
			// formatting
			//cboFont.labelField = 'fontName';
			//cboFont.dataProvider = fonts;
			//txtFontSize.text = config.settings.fontSize;
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