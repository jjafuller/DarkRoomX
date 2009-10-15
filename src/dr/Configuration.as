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
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class Configuration extends Object
	{
		private var stream:FileStream;
		private var settingsFile:File;
		[Bindable] private var settingsXml:XML;
		public var settings:Object;
		
		public function Configuration(pSettingsFile:File)
		{
			settingsFile = pSettingsFile;
			
			settings = new Object();
			 
			//readXML();
		}

		public function read():void
		{
			stream = new FileStream();
			if (settingsFile.exists) {
				loadDefaults();
    			stream.open(settingsFile, FileMode.READ);
			    processXml();
			}
			else
			{
				loadDefaults();
			    save();
			}
		}
		
		public function loadDefaults():void
		{			
			// page
			settings.pageWidth = 600;
			settings.pageWidthAuto = false;
			settings.pageHeight = 600;
			settings.pageHeightAuto = true;
			settings.pageMarginVertical = 0;
			settings.pageMarginHorizontal = 0;
			settings.pagePaddingVerticalTop = 10;
			settings.pagePaddingVerticalBottom = 10;
			settings.pagePaddingHorizontal = 10;
			settings.pageBackgroundOpacity = 0.9;
			settings.pageBackgroundColor = 0;
			
			// general
			settings.launchFullScreen = true;
			settings.liveScrolling = false;
			settings.backgroundColor = 0;
			settings.backgroundOpacity = 1;
			
			// formatting
			settings.fontFamily = 'Courier New';
			settings.fontColor = 65280;
			settings.fontSize = 14;
			settings.fontLetterSpacing = 0;
			settings.fontStyle = 'normal';
			settings.fontWeight = 'normal';
			settings.fontDecoration = 'normal';
			
			// paragraph
			settings.fontLeading = 6;
			settings.fontIndent = 0;
			settings.fontAlign = 'left';
			settings.tabsToSpaces = false;
			settings.tabsToSpacesCount = 2;
			settings.autoIndent = false;
			settings.wordWrap = true;
			
			// info bar
			settings.infoFontFamily = 'Courier New';
			settings.infoFontColor = 65280;
			settings.infoFontSize = 11;
			settings.infoFontLetterSpacing = 0;
			settings.infoPadding = 3;
			settings.infoFontStyle = 'normal';
			settings.infoFontWeight = 'normal';
			settings.infoFontDecoration = 'normal';
			settings.infoBackgroundOpacity = 0.9;
			settings.infoBackgroundColor = 0;
			
			// disable scrolls
			settings.scrollVerticalDisable = false;
			settings.scrollHorizontalDisable = false;
			
			// scroll styles
			settings.scrollCornerRadius = 0;
			settings.scrollHighlightAlpha1 = 0;
			settings.scrollHighlightAlpha2 = 0;
			settings.scrollFillAlpha1 = 1;
			settings.scrollFillAlpha2 = 1;
			settings.scrollFillAlpha3 = 1;
			settings.scrollFillAlpha4 = 1;
			settings.scrollFillColor1 = 13056;
			settings.scrollFillColor2 = 13056;
			settings.scrollFillColor3 = 39168;
			settings.scrollFillColor4 = 39168;
			settings.scrollTrackColor1 = 0;
			settings.scrollTrackColor2 = 0;
			settings.scrollThemeColor = 39168;
			settings.scrollBorderColor = 13056;
			
			// auto save
			settings.autosaveInterval = -1;
			
			// reopen
			settings.reopenLastDocument = false;
			
			// statistics
			settings.statisticsCharacters = false;
			settings.statisticsLines = false;
			settings.statisticsWords = false;
			settings.statisticsSentences = false;
		}
		
		public function processXml():void
		{
			settingsXml = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			// page
			settings.pageWidth = int(settingsXml.pageWidth);
			settings.pageWidthAuto = (settingsXml.pageWidthAuto=='true') ? true : false;
			settings.pageHeight = int(settingsXml.pageHeight);
			settings.pageHeightAuto = (settingsXml.pageHeightAuto=='true') ? true : false;
			settings.pageMarginVertical = int(settingsXml.pageMarginVertical);
			settings.pageMarginHorizontal = int(settingsXml.pageMarginHorizontal);
			settings.pagePaddingVerticalTop = int(settingsXml.pagePaddingVerticalTop);
			settings.pagePaddingVerticalBottom = int(settingsXml.pagePaddingVerticalBottom);
			settings.pagePaddingHorizontal = int(settingsXml.pagePaddingHorizontal);
			settings.pageBackgroundOpacity = settingsXml.pageBackgroundOpacity;
			settings.pageBackgroundColor = uint(settingsXml.pageBackgroundColor);
			
			// general
			settings.launchFullScreen = (settingsXml.launchFullScreen=='true') ? true : false;
			settings.liveScrolling = (settingsXml.liveScrolling=='true') ? true : false;
			settings.backgroundColor = settingsXml.backgroundColor;
			settings.backgroundOpacity = settingsXml.backgroundOpacity;
			
			// formatting
			settings.fontFamily = settingsXml.fontFamily;
			settings.fontColor = settingsXml.fontColor;
			settings.fontSize = settingsXml.fontSize;
			settings.fontLetterSpacing = settingsXml.fontLetterSpacing;
			settings.fontStyle = settingsXml.fontStyle;
			settings.fontWeight = settingsXml.fontWeight;
			settings.fontDecoration = settingsXml.fontDecoration;
			
			// paragraph
			settings.fontLeading = settingsXml.fontLeading;
			settings.fontIndent = settingsXml.fontIndent;
			settings.fontAlign = settingsXml.fontAlign;
			settings.tabsToSpaces = (settingsXml.tabsToSpaces=='true') ? true : false;
			settings.tabsToSpacesCount = int(settingsXml.tabsToSpacesCount);
			settings.autoIndent = (settingsXml.autoIndent=='true') ? true : false;
			settings.wordWrap = (settingsXml.wordWrap=='true') ? true : false;
			
			// info bar
			settings.infoFontFamily = settingsXml.infoFontFamily;
			settings.infoFontColor = settingsXml.infoFontColor;
			settings.infoFontSize = settingsXml.infoFontSize;
			settings.infoFontLetterSpacing = settingsXml.infoFontLetterSpacing;
			settings.infoFontStyle = settingsXml.infoFontStyle;
			settings.infoFontWeight = settingsXml.infoFontWeight;
			settings.infoFontDecoration = settingsXml.infoFontDecoration;
			settings.infoBackgroundOpacity = settingsXml.infoBackgroundOpacity;
			settings.infoBackgroundColor = uint(settingsXml.infoBackgroundColor);
			
			// disable scrolls
			settings.scrollVerticalDisable = (settingsXml.scrollVerticalDisable=='true') ? true : false;
			settings.scrollHorizontalDisable = (settingsXml.scrollHorizontalDisable=='true') ? true : false;
			
			// scroll styles
			settings.scrollCornerRadius = settingsXml.scrollCornerRadius;
			settings.scrollHighlightAlpha1 = settingsXml.scrollHighlightAlpha1;
			settings.scrollHighlightAlpha2 = settingsXml.scrollHighlightAlpha2;
			settings.scrollFillAlpha1 = settingsXml.scrollFillAlpha1;
			settings.scrollFillAlpha2 = settingsXml.scrollFillAlpha2;
			settings.scrollFillAlpha3 = settingsXml.scrollFillAlpha3;
			settings.scrollFillAlpha4 = settingsXml.scrollFillAlpha4;
			settings.scrollFillColor1 = settingsXml.scrollFillColor1;
			settings.scrollFillColor2 = settingsXml.scrollFillColor2;
			settings.scrollFillColor3 = settingsXml.scrollFillColor3;
			settings.scrollFillColor4 = settingsXml.scrollFillColor4;
			settings.scrollTrackColor1 = settingsXml.scrollTrackColor1;
			settings.scrollTrackColor2 = settingsXml.scrollTrackColor2;
			settings.scrollThemeColor = settingsXml.scrollThemeColor;
			settings.scrollBorderColor = settingsXml.scrollBorderColor;
			
			// auto save
			settings.autosaveInterval = settingsXml.autosaveInterval;
			
			// reopen
			settings.reopenLastDocument = (settingsXml.reopenLastDocument=='true') ? true : false;
			settings.lastFileNativePath = String(settingsXml.lastFileNativePath);
			
			// statistics
			settings.statisticsCharacters = (settingsXml.statisticsCharacters=='true') ? true : false;
			settings.statisticsLines = (settingsXml.statisticsLines=='true') ? true : false;
			settings.statisticsWords = (settingsXml.statisticsWords=='true') ? true : false;
			settings.statisticsSentences = (settingsXml.statisticsSentences=='true') ? true : false;
			
		}
		
		public function save():void
		{
			createXml(); 
			writeXml();
		}
		
		private function createXml():void 
		{
			settingsXml = <settings/>;
			
			// page
			settingsXml.pageWidth = settings.pageWidth;
			settingsXml.pageWidthAuto = settings.pageWidthAuto;
			settingsXml.pageHeight = settings.pageHeight;
			settingsXml.pageHeightAuto = settings.pageHeightAuto;
			settingsXml.pageMarginVertical = settings.pageMarginVertical;
			settingsXml.pageMarginHorizontal = settings.pageMarginHorizontal;
			settingsXml.pagePaddingVerticalTop = settings.pagePaddingVerticalTop;
			settingsXml.pagePaddingVerticalBottom = settings.pagePaddingVerticalBottom;
			settingsXml.pagePaddingHorizontal = settings.pagePaddingHorizontal;
			settingsXml.pageBackgroundOpacity = settings.pageBackgroundOpacity;
			settingsXml.pageBackgroundColor = settings.pageBackgroundColor;
			
			// general
			settingsXml.launchFullScreen = settings.launchFullScreen;
			settingsXml.liveScrolling = settings.liveScrolling;
			settingsXml.backgroundColor = settings.backgroundColor;
			settingsXml.backgroundOpacity = settings.backgroundOpacity;
			
			// formatting
			settingsXml.fontFamily = settings.fontFamily;
			settingsXml.fontColor = settings.fontColor;
			settingsXml.fontSize = settings.fontSize;
			settingsXml.fontLetterSpacing = settings.fontLetterSpacing;
			settingsXml.fontStyle = settings.fontStyle;
			settingsXml.fontWeight = settings.fontWeight;
			settingsXml.fontDecoration = settings.fontDecoration;
			
			// paragraph
			settingsXml.fontLeading = settings.fontLeading;
			settingsXml.fontIndent = settings.fontIndent;
			settingsXml.fontAlign = settings.fontAlign;
			settingsXml.tabsToSpaces = settings.tabsToSpaces;
			settingsXml.tabsToSpacesCount = settings.tabsToSpacesCount;
			settingsXml.autoIndent = settings.autoIndent;
			settingsXml.wordWrap = settings.wordWrap;
			
			// info bar
			settingsXml.infoFontFamily = settings.infoFontFamily;
			settingsXml.infoFontColor = settings.infoFontColor;
			settingsXml.infoFontSize = settings.infoFontSize;
			settingsXml.infoFontLetterSpacing = settings.infoFontLetterSpacing;
			settingsXml.infoPadding = settings.infoPadding;
			settingsXml.infoFontStyle = settings.infoFontStyle;
			settingsXml.infoFontWeight = settings.infoFontWeight;
			settingsXml.infoFontDecoration = settings.infoFontDecoration;
			settingsXml.infoBackgroundOpacity = settings.infoBackgroundOpacity;
			settingsXml.infoBackgroundColor = settings.infoBackgroundColor;
			
			// disable scrolls
			settingsXml.scrollVerticalDisable = settings.scrollVerticalDisable;
			settingsXml.scrollHorizontalDisable = settings.scrollHorizontalDisable;
			
			// scroll styles
			settingsXml.scrollCornerRadius = settings.scrollCornerRadius;
			settingsXml.scrollHighlightAlpha1 = settings.scrollHighlightAlpha1;
			settingsXml.scrollHighlightAlpha2 = settings.scrollHighlightAlpha2;
			settingsXml.scrollFillAlpha1 = settings.scrollFillAlpha1;
			settingsXml.scrollFillAlpha2 = settings.scrollFillAlpha2;
			settingsXml.scrollFillAlpha3 = settings.scrollFillAlpha3;
			settingsXml.scrollFillAlpha4 = settings.scrollFillAlpha4;
			settingsXml.scrollFillColor1 = settings.scrollFillColor1;
			settingsXml.scrollFillColor2 = settings.scrollFillColor2;
			settingsXml.scrollFillColor3 = settings.scrollFillColor3;
			settingsXml.scrollFillColor4 = settings.scrollFillColor4;
			settingsXml.scrollTrackColor1 = settings.scrollTrackColor1;
			settingsXml.scrollTrackColor2 = settings.scrollTrackColor2;
			settingsXml.scrollThemeColor = settings.scrollThemeColor;
			settingsXml.scrollBorderColor = settings.scrollBorderColor;
			
			// auto save
			settingsXml.autosaveInterval = settings.autosaveInterval
			
			// reopen
			settingsXml.reopenLastDocument = settings.reopenLastDocument;
			settingsXml.lastFileNativePath = settings.lastFileNativePath;
			
			// statistics
			settingsXml.statisticsCharacters = settings.statisticsCharacters;
			settingsXml.statisticsLines = settings.statisticsLines;
			settingsXml.statisticsWords = settings.statisticsWords;
			settingsXml.statisticsSentences = settings.statisticsSentences;
			
			settingsXml.saveDate = new Date().toString();
		}
		
		private function writeXml():void 
		{
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			
			outputString += settingsXml.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);
			
			stream = new FileStream();
			stream.open(settingsFile, FileMode.WRITE);
			stream.writeUTFBytes(outputString);
			stream.close();
		}
		
	}
}