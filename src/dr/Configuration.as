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
    			stream.open(settingsFile, FileMode.READ);
			    processXml();
			}
			else
			{
			    save();
			}
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
			
			// disable scrolls
			settings.scrollVerticalDisable = settingsXml.scrollVerticalDisable;
			settings.scrollHorizontalDisable = settingsXml.scrollHorizontalDisable;
			
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