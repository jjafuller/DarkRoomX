/*
 * Dark Room X
 *
 * NOTICE OF LICENSE
 *
 * All project source files are subject to the Open Software License (OSL 3.0)
 * that is included with this applciation in the file LICENSE.txt.
 * The license is also available online at the following URL:
 * http://opensource.org/licenses/osl-3.0.php
 * If you did not receive a copy of the license, please send
 * an email to contact@getdarkroom.com so we can send a copy to you.
 *
 * @package    dr
 * @copyright  Copyright (c) 2009 Jeffrey Fuller (http://getdarkroom.com)
 * @license    Open Software License (OSL 3.0), http://opensource.org/licenses/osl-3.0.php  
 */
 
package dr
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.Font;
	
	import mx.containers.Canvas;
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.controls.*;
	import mx.controls.sliderClasses.Slider;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class ConfigurationWindow extends mx.containers.TitleWindow
	{
		private var colors:Object;
		
		public var btnCancel:Button;
		public var btnOk:Button;
		
		private var settingsFile:File;
		private var fonts:Array; 
		private var textAlignments:Array;
		private var autosaveInterval:Array;
		private var tabUpdated:Array;
		
		[Bindable]
		public var config:Configuration;
		
		public var navigator:TabNavigator;
		
		public var txtPageWidth:TextInput;
		public var txtPageHeight:TextInput;
		public var txtPageMarginVertical:TextInput;
		public var txtPageMarginHorizontal:TextInput;
		public var txtPagePaddingHorizontal:TextInput;
		public var txtPagePaddingVerticalTop:TextInput;
		public var txtPagePaddingVerticalBottom:TextInput;
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
		
		public var cboFontFamily:ComboBox;
		public var txtFontSize:TextInput;
		public var clrFontColor:ColorPicker;
		public var cnvFontColor:Canvas;
		public var txtFontLetterSpacing:TextInput;
		public var chkFontStyle:CheckBox;
		public var chkFontWeight:CheckBox;
		public var chkFontDecoration:CheckBox;
		
		public var txtFontLeading:TextInput;
		public var txtFontIndent:TextInput;
		public var cboFontAlign:ComboBox;
		public var chkTabsToSpaces:CheckBox;
		public var txtTabsToSpacesCount:TextInput;
		public var chkAutoIndent:CheckBox;
		public var chkWrapToPage:CheckBox;
		
		public var cboInfoFontFamily:ComboBox;
		public var txtInfoFontSize:TextInput;
		public var clrInfoFontColor:ColorPicker;
		public var cnvInfoFontColor:Canvas;
		public var txtInfoFontLetterSpacing:TextInput;
		public var txtInfoPadding:TextInput;
		public var chkInfoFontStyle:CheckBox;
		public var chkInfoFontWeight:CheckBox;
		public var chkInfoFontDecoration:CheckBox;
		public var clrInfoBackgroundColor:ColorPicker;
		public var cnvInfoBackgroundColor:Canvas;
		public var sldInfoBackgroundOpacity:Slider;
		
		public var chkStatisticsCharacters:CheckBox;
		public var chkStatisticsLines:CheckBox;
		public var chkStatisticsWords:CheckBox;
		public var chkStatisticsSentences:CheckBox;
		
		public var chkDisableVerticalScroll:CheckBox;
		public var chkDisableHorizontalScroll:CheckBox;
		
		public var sldScrollCornerRadius:Slider;
		public var sldScrollHighlightAlpha1:Slider;
		public var sldScrollHighlightAlpha2:Slider;
		public var sldScrollFillAlpha1:Slider;
		public var sldScrollFillAlpha2:Slider;
		public var sldScrollFillAlpha3:Slider;
		public var sldScrollFillAlpha4:Slider;
		public var clrScrollFillColor1:ColorPicker;
		public var cnvScrollFillColor1:Canvas;
		public var clrScrollFillColor2:ColorPicker;
		public var cnvScrollFillColor2:Canvas;
		public var clrScrollFillColor3:ColorPicker;
		public var cnvScrollFillColor3:Canvas;
		public var clrScrollFillColor4:ColorPicker;
		public var cnvScrollFillColor4:Canvas;
		public var clrScrollTrackColor1:ColorPicker;
		public var cnvScrollTrackColor1:Canvas;
		public var clrScrollTrackColor2:ColorPicker;
		public var cnvScrollTrackColor2:Canvas;
		public var clrScrollThemeColor:ColorPicker;
		public var cnvScrollThemeColor:Canvas;
		public var clrScrollBorderColor:ColorPicker;
		public var cnvScrollBorderColor:Canvas;
		
		public var cboAutosave:ComboBox;
		public var chkReopenLastDocument:CheckBox;
		
		
		
		public function ConfigurationWindow()
		{
			tabUpdated = new Array();
			
			colors = new Object();
			
			// global events
			this.addEventListener(CloseEvent.CLOSE, handleClose);
			
		}
		
		public function init():void
		{
			// assign fonts
			fonts = Font.enumerateFonts(true);
			fonts.sortOn("fontName", Array.CASEINSENSITIVE);
			
			// text alignments
			textAlignments = new Array({label:'Left', data:'left'},{label:'Right', data:'right'},{label:'Center', data: 'center'},{label:'Justify', data:'justify'});
			
			// auto save time intervals
			autosaveInterval = new Array({label:'Never', data:-1},{label:'30 seconds', data:30},{label:'1 minute', data:60},{label:'5 minutes', data:300},{label:'10 minutes', data:600});
			
			// button events
			btnCancel.addEventListener("click", handleCancel);
			btnOk.addEventListener("click", handleOk);
			
			// navigator events
			navigator.addEventListener(Event.CHANGE, handleTabChange);
		}
		
		public function processSettings():Configuration
		{
			// first tab
			if(txtPageWidth)
			{
				// page
				config.settings.pageWidth = txtPageWidth.text;
				config.settings.pageWidthAuto = chkPageWidthAuto.selected;
				config.settings.pageHeight = txtPageHeight.text;
				config.settings.pageHeightAuto = chkPageHeightAuto.selected;
				config.settings.pageMarginVertical = txtPageMarginVertical.text;
				config.settings.pageMarginHorizontal = txtPageMarginHorizontal.text;
				config.settings.pagePaddingVerticalTop = txtPagePaddingVerticalTop.text;
				config.settings.pagePaddingVerticalBottom = txtPagePaddingVerticalBottom.text;
				config.settings.pagePaddingHorizontal = txtPagePaddingHorizontal.text;
				config.settings.pageBackgroundOpacity = sldPageBackgroundOpacity.value;
				config.settings.pageBackgroundColor = (colors.pageBackgroundColor) ? clrPageBackgroundColor.value : config.settings.pageBackgroundColor;
				
				// general
				config.settings.launchFullScreen = chkLaunchFullScreen.selected;
				config.settings.liveScrolling = chkLiveScrolling.selected;
				config.settings.backgroundColor = (colors.backgroundColor) ? clrBackgroundColor.value : config.settings.backgroundColor;
				config.settings.backgroundOpacity = sldBackgroundOpacity.value;
			}
			
			// second tab
			if(cboFontFamily)
			{
				// formatting
				config.settings.fontFamily = cboFontFamily.selectedItem.fontName;
				config.settings.fontColor = (colors.fontColor) ? clrFontColor.value : config.settings.fontColor;
				config.settings.fontSize = txtFontSize.text;
				config.settings.fontLetterSpacing = txtFontLetterSpacing.text;
				config.settings.fontStyle = (chkFontStyle.selected) ? 'italic' : 'normal';
				config.settings.fontWeight = (chkFontWeight.selected) ? 'bold' : 'normal';
				config.settings.fontDecoration = (chkFontDecoration.selected) ? 'underline' : 'normal';
				
				// paragraph
				config.settings.fontLeading = txtFontLeading.text;
				config.settings.fontIndent = txtFontIndent.text;
				config.settings.fontAlign = cboFontAlign.selectedItem.data;
				config.settings.tabsToSpaces = chkTabsToSpaces.selected;
				config.settings.tabsToSpacesCount = txtTabsToSpacesCount.text;
				config.settings.autoIndent = chkAutoIndent.selected;
				config.settings.wordWrap = chkWrapToPage.selected;
			}
			
			// third tab
			if(cboInfoFontFamily)
			{
				// formatting
				config.settings.infoFontFamily = cboInfoFontFamily.selectedItem.fontName;
				config.settings.infoFontColor = (colors.infoFontColor) ? clrInfoFontColor.value : config.settings.infoFontColor;
				config.settings.infoFontSize = txtInfoFontSize.text;
				config.settings.infoFontLetterSpacing = txtInfoFontLetterSpacing.text;
				config.settings.infoPadding = txtInfoPadding.text;
				config.settings.infoFontStyle = (chkInfoFontStyle.selected) ? 'italic' : 'normal';
				config.settings.infoFontWeight = (chkInfoFontWeight.selected) ? 'bold' : 'normal';
				config.settings.infoFontDecoration = (chkInfoFontDecoration.selected) ? 'underline' : 'normal';
				config.settings.infoBackgroundOpacity = sldInfoBackgroundOpacity.value;
				config.settings.infoBackgroundColor = (colors.infoBackgroundColor) ? clrInfoBackgroundColor.value : config.settings.infoBackgroundColor;
				
				// statistics
				config.settings.statisticsCharacters = chkStatisticsCharacters.selected;
				config.settings.statisticsLines = chkStatisticsLines.selected;
				config.settings.statisticsWords = chkStatisticsWords.selected;
				config.settings.statisticsSentences = chkStatisticsSentences.selected;
			}
			
			// fourth tab
			if(chkDisableVerticalScroll!=null)
			{
				// disable scroll
				config.settings.scrollVerticalDisable = chkDisableVerticalScroll.selected;
				config.settings.scrollHorizontalDisable = chkDisableHorizontalScroll.selected;
				
				// style
				config.settings.scrollCornerRadius = sldScrollCornerRadius.value;
				config.settings.scrollHighlightAlpha1 = sldScrollHighlightAlpha1.value;
				config.settings.scrollHighlightAlpha2 = sldScrollHighlightAlpha2.value;
				config.settings.scrollFillAlpha1 = sldScrollFillAlpha1.value;
				config.settings.scrollFillAlpha2 = sldScrollFillAlpha2.value;
				config.settings.scrollFillAlpha3 = sldScrollFillAlpha3.value;
				config.settings.scrollFillAlpha4 = sldScrollFillAlpha4.value;
				config.settings.scrollFillColor1 = (colors.scrollFillColor1) ? clrScrollFillColor1.value : config.settings.scrollFillColor1;
				config.settings.scrollFillColor2 = (colors.scrollFillColor2) ? clrScrollFillColor2.value : config.settings.scrollFillColor2;
				config.settings.scrollFillColor3 = (colors.scrollFillColor3) ? clrScrollFillColor3.value : config.settings.scrollFillColor3;
				config.settings.scrollFillColor4 = (colors.scrollFillColor4) ? clrScrollFillColor4.value : config.settings.scrollFillColor4;
				config.settings.scrollTrackColor1 = (colors.scrollTrackColor1) ? clrScrollTrackColor1.value : config.settings.scrollTrackColor1;
				config.settings.scrollTrackColor2 = (colors.scrollTrackColor2) ? clrScrollTrackColor2.value : config.settings.scrollTrackColor2;
				config.settings.scrollThemeColor = (colors.scrollThemeColor) ? clrScrollThemeColor.value : config.settings.scrollThemeColor;
				config.settings.scrollBorderColor = (colors.scrollBorderColor) ? clrScrollBorderColor.value : config.settings.scrollBorderColor;
				
			}
			
			// fifth tab
			if(cboAutosave!=null)
			{
				config.settings.autosaveInterval = cboAutosave.selectedItem.data;
				config.settings.reopenLastDocument = chkReopenLastDocument.selected;
			}
			
			return config;
		}
		
		public function updateFields():void
		{
			switch(navigator.selectedIndex)
			{
				case 0:
					// page
					txtPageWidth.text = config.settings.pageWidth;
					chkPageWidthAuto.selected = config.settings.pageWidthAuto;
					txtPageHeight.text = config.settings.pageHeight;
					chkPageHeightAuto.selected = config.settings.pageHeightAuto;
					txtPageMarginVertical.text = config.settings.pageMarginVertical;
					txtPageMarginHorizontal.text = config.settings.pageMarginHorizontal;
					txtPagePaddingVerticalTop.text = config.settings.pagePaddingVerticalTop;
					txtPagePaddingVerticalBottom.text = config.settings.pagePaddingVerticalBottom;
					txtPagePaddingHorizontal.text = config.settings.pagePaddingHorizontal;
					sldPageBackgroundOpacity.value = config.settings.pageBackgroundOpacity;
					cnvPageBackgroundColor.setStyle('backgroundColor', config.settings.pageBackgroundColor);
				
					// general
					chkLaunchFullScreen.selected = config.settings.launchFullScreen;
					chkLiveScrolling.selected = config.settings.liveScrolling;
					cnvBackgroundColor.setStyle('backgroundColor', config.settings.backgroundColor);
					sldBackgroundOpacity.value = config.settings.backgroundOpacity
					
					// color picker events
					if(!clrPageBackgroundColor.hasEventListener(Event.CHANGE))
					{
						clrPageBackgroundColor.addEventListener(Event.CHANGE, handleColorChange);
						clrBackgroundColor.addEventListener(Event.CHANGE, handleColorChange);
					}
					
					break;
					
				case 1:
					// formatting
					cboFontFamily.dataProvider = fonts;
					cboFontFamily.selectedIndex = getFontIndex(config.settings.fontFamily);
					cnvFontColor.setStyle('backgroundColor', config.settings.fontColor);
					txtFontSize.text = config.settings.fontSize;
					txtFontLetterSpacing.text = config.settings.fontLetterSpacing;
					chkFontStyle.selected = (config.settings.fontStyle=='italic') ? true : false;
					chkFontWeight.selected = (config.settings.fontWeight=='bold') ? true : false;
					chkFontDecoration.selected = (config.settings.fontDecoration=='underline') ? true : false;
					
					// paragraph
					txtFontLeading.text = config.settings.fontLeading;
					txtFontIndent.text = config.settings.fontIndent;
					cboFontAlign.dataProvider = textAlignments;
					cboFontAlign.selectedIndex = getFontAlignIndex(config.settings.fontAlign);
					chkTabsToSpaces.selected = config.settings.tabsToSpaces;
					txtTabsToSpacesCount.text = config.settings.tabsToSpacesCount;
					chkAutoIndent.selected = config.settings.autoIndent;
					chkWrapToPage.selected = config.settings.wordWrap;
					
					// color picker events
					if(!clrFontColor.hasEventListener(Event.CHANGE))
					{
						clrFontColor.addEventListener(Event.CHANGE, handleColorChange);
					}
					
					break;
					
				case 2:
					// formatting
					cboInfoFontFamily.dataProvider = fonts;
					cboInfoFontFamily.selectedIndex = getFontIndex(config.settings.infoFontFamily);
					cnvInfoFontColor.setStyle('backgroundColor', config.settings.infoFontColor);
					txtInfoFontSize.text = config.settings.infoFontSize;
					txtInfoFontLetterSpacing.text = config.settings.infoFontLetterSpacing;
					txtInfoPadding.text = config.settings.infoPadding;
					chkInfoFontStyle.selected = (config.settings.infoFontStyle=='italic') ? true : false;
					chkInfoFontWeight.selected = (config.settings.infoFontWeight=='bold') ? true : false;
					chkInfoFontDecoration.selected = (config.settings.infoFontDecoration=='underline') ? true : false;
					sldInfoBackgroundOpacity.value = config.settings.infoBackgroundOpacity;
					cnvInfoBackgroundColor.setStyle('backgroundColor', config.settings.infoBackgroundColor);
					
					//stats
					chkStatisticsCharacters.selected = config.settings.statisticsCharacters;
					chkStatisticsLines.selected = config.settings.statisticsLines;
					chkStatisticsWords.selected = config.settings.statisticsWords;
					chkStatisticsSentences.selected = config.settings.statisticsSentences;
					
					// color picker events
					if(!clrInfoBackgroundColor.hasEventListener(Event.CHANGE))
					{
						clrInfoFontColor.addEventListener(Event.CHANGE, handleColorChange);
						clrInfoBackgroundColor.addEventListener(Event.CHANGE, handleColorChange);
					}
					
					break;
					
				case 3:
					// disable scrolls
					chkDisableVerticalScroll.selected = config.settings.scrollVerticalDisable;
					chkDisableHorizontalScroll.selected = config.settings.scrollHorizontalDisable;
					
					// styles
					sldScrollCornerRadius.value = config.settings.scrollCornerRadius;
					sldScrollHighlightAlpha1.value = config.settings.scrollHighlightAlpha1;
					sldScrollHighlightAlpha2.value = config.settings.scrollHighlightAlpha2;
					sldScrollFillAlpha1.value = config.settings.scrollFillAlpha1;
					sldScrollFillAlpha2.value = config.settings.scrollFillAlpha2;
					sldScrollFillAlpha3.value = config.settings.scrollFillAlpha3;
					sldScrollFillAlpha4.value = config.settings.scrollFillAlpha4;
					cnvScrollFillColor1.setStyle('backgroundColor', config.settings.scrollFillColor1);
					cnvScrollFillColor2.setStyle('backgroundColor', config.settings.scrollFillColor2);
					cnvScrollFillColor3.setStyle('backgroundColor', config.settings.scrollFillColor3);
					cnvScrollFillColor4.setStyle('backgroundColor', config.settings.scrollFillColor4);
					cnvScrollTrackColor1.setStyle('backgroundColor', config.settings.scrollTrackColor1);
					cnvScrollTrackColor2.setStyle('backgroundColor', config.settings.scrollTrackColor2);
					cnvScrollThemeColor.setStyle('backgroundColor', config.settings.scrollThemeColor);
					cnvScrollBorderColor.setStyle('backgroundColor', config.settings.scrollBorderColor);
					
					// color picker events
					if(!clrScrollFillColor1.hasEventListener(Event.CHANGE))
					{
						clrScrollFillColor1.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollFillColor2.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollFillColor3.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollFillColor4.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollTrackColor1.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollTrackColor2.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollThemeColor.addEventListener(Event.CHANGE, handleColorChange);
						clrScrollBorderColor.addEventListener(Event.CHANGE, handleColorChange);
					}
					
					break;
					
				case 4:
					// setup
					cboAutosave.dataProvider = autosaveInterval;
					cboAutosave.selectedIndex = getAutosaveIndex(config.settings.autosaveInterval);
					chkReopenLastDocument.selected = config.settings.reopenLastDocument;
					
					
			}
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
		
		public function handleTabChange(event:Event):void
		{
			if(!tabUpdated[navigator.selectedIndex])
			{
				tabUpdated[navigator.selectedIndex] = true;
				updateFields();
			}
		}
		
		public function getAutosaveIndex(value:int):int
		{
			var index:int = 0;
			
			for (var i:uint = 0; i < autosaveInterval.length; i++)
			{
                if (autosaveInterval[i].data == value)
                {
                	index = i;
                }
        	}
        	
        	return index;
		}
		
		public function getFontIndex(font:String):int
		{
			var index:int = 0;
			
			for (var i:uint = 0; i < fonts.length; i++)
			{
                if (fonts[i].fontName == font)
                {
                	index = i;
                }
        	}
        	
        	return index;
		}
		
		public function getFontAlignIndex(value:String):int
		{
			var index:int = 0;
			
			for (var i:uint = 0; i < textAlignments.length; i++)
			{
                if (textAlignments[i].label == value)
                {
                	index = i;
                }
        	}
        	
        	return index;
		}
		
		private function handleColorChange(event:Event):void
		{
			var id:String = event.target.toString().split('.').pop().toString();
			
			switch (id)
			{
				case 'clrPageBackgroundColor':
					colors.pageBackgroundColor = true;
					cnvPageBackgroundColor.setStyle('backgroundColor', clrPageBackgroundColor.value);
					break;
					
				case 'clrBackgroundColor':
					colors.backgroundColor = true;
					cnvBackgroundColor.setStyle('backgroundColor', clrBackgroundColor.value);
					break;
					
				case 'clrFontColor':
					colors.fontColor = true;
					cnvFontColor.setStyle('backgroundColor', clrFontColor.value);
					break;
					
				case 'clrInfoFontColor':
					colors.infoFontColor = true;
					cnvInfoFontColor.setStyle('backgroundColor', clrInfoFontColor.value);
					break;
					
				case 'clrInfoBackgroundColor':
					colors.infoBackgroundColor = true;
					cnvInfoBackgroundColor.setStyle('backgroundColor', clrInfoBackgroundColor.value);
					break;
					
				case 'clrScrollFillColor1':
					colors.scrollFillColor1 = true;
					cnvScrollFillColor1.setStyle('backgroundColor', clrScrollFillColor1.value);
					break;
					
				case 'clrScrollFillColor2':
					colors.scrollFillColor2 = true;
					cnvScrollFillColor2.setStyle('backgroundColor', clrScrollFillColor2.value);
					break;
					
				case 'clrScrollFillColor3':
					colors.scrollFillColor3 = true;
					cnvScrollFillColor3.setStyle('backgroundColor', clrScrollFillColor3.value);
					break;

				case 'clrScrollFillColor4':
					colors.scrollFillColor4 = true;
					cnvScrollFillColor4.setStyle('backgroundColor', clrScrollFillColor4.value);
					break;
					
				case 'clrScrollTrackColor1':
					colors.scrollTrackColor1 = true;
					cnvScrollTrackColor1.setStyle('backgroundColor', clrScrollTrackColor1.value);
					break;
					
				case 'clrScrollTrackColor2':
					colors.scrollTrackColor2 = true;
					cnvScrollTrackColor2.setStyle('backgroundColor', clrScrollTrackColor2.value);
					break;
					
				case 'clrScrollThemeColor':
					colors.scrollThemeColor = true;
					cnvScrollThemeColor.setStyle('backgroundColor', clrScrollThemeColor.value);
					break;
					
				case 'clrScrollBorderColor':
					colors.scrollBorderColor = true;
					cnvScrollBorderColor.setStyle('backgroundColor', clrScrollBorderColor.value);
					break;
			}		
		}
		
	}
}	