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
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import gearsandcogs.text.UndoTextFields;
	
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.MenuBar;
	import mx.controls.menuClasses.MenuBarItem;
	import mx.core.WindowedApplication;
	import mx.events.*;
	import mx.managers.*;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	

	public class WindowedApplication extends mx.core.WindowedApplication
	{
		// constances
		public static const UNSAVED_TITLE:String = "Unsaved Changes";
		public static const UNSAVED_MESSAGE:String = "You have unsaved changes in your document. If you proceed your changes will be lost.";
		public static const PATTERN_WORDS:RegExp = /\w+/g;
		public static const PATTERN_LINES:RegExp = /[\cM\cJ\n\r]+/g;
		public static const PATTERN_SENTENCES:RegExp = /[.!?]+/g;
		
		
		// variables
		private var isFullScreen:Boolean = false;
		private var isDirty:Boolean = false;
		private var currentFile:File; 							// The currentFile opened (and saved) by the application
		private var stream:FileStream = new FileStream(); 		// The FileStream object used for reading and writing the currentFile
		private var defaultDirectory:File; 						// The default directory
		private var autosaveTimer:Timer;
		private var undoTextFields:UndoTextFields;
		
		[Bindable]
		public var dataChanged:Boolean = false; 				// Whether the text data has changed (and should be saved)
		private var settingsFile:File;
		public var config:Configuration;
		public var settingsXml:XML; 							// The XML data
		public var settingsStream:FileStream; 					// The FileStream object used to read and write settings file data.

		// controls
		public var content:dr.TextArea;
		public var lblInformation:Label;
		public var mnuPsuedo:MenuBar;
		
		//public var menuBar:MenuBar;
		public var rootMenu:NativeMenu = new NativeMenu();
		
		// dialogs
		public var configDialog:ConfigurationDialog;
		
		// constructor
		public function WindowedApplication()
		{
			
		}
		
		public function init():void 
 		{	
 			// trap all our keys so we can make escape go to full scree
 			//fscommand("trapallkeys", "true");
 			
 			// hack to get us undo until flex 4
 			undoTextFields = new UndoTextFields();
			undoTextFields.target = this;
			
			// center window
			centerWindow();
 			
 			// load settings and then apply them
 			initSettings();
 			applySettings();
 			
 			// go to full screen if that's what the user wants
 			if(config.settings.launchFullScreen)
 			{
 				launchFullScreen();
 			}
 			
 			// start listeners and build menu
 			initListeners();
 			initMenu();
 			
 			// figure out where our base directory is
 			defaultDirectory = File.documentsDirectory;
 			
 			// reopen the last document if instructed to
 			if(config.settings.reopenLastDocument && config.settings.lastFileNativePath)
 			{
 				currentFile = new File(config.settings.lastFileNativePath);
 				if(currentFile.exists)
 				{
 					openCurrentFile();
 				}
 				else
 				{
 					currentFile = null;
 				}
 				
 			}
 			
			content.text = "Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n";
			//content.selectionBeginIndex = content.text.length;
			//content.selectionEndIndex = content.text.length;
		}
		
		public function initSettings():void
		{
			settingsFile = File.applicationStorageDirectory;
			settingsFile = settingsFile.resolvePath("settings.xml"); 
			
			config = new Configuration(settingsFile);
			
			config.read();
		}
		
		public function initAutosaveTimer():void
		{
			var autosaveInterval:int = int(config.settings.autosaveInterval);
			
			// stop the timer if we have one going
			if(autosaveTimer)
			{
				autosaveTimer.stop();
			}
			
			// init timer if auto save is enabled
			if(autosaveInterval > 0)
			{
				autosaveTimer = new Timer(autosaveInterval*1000, 0);
				
				// add event handler
				autosaveTimer.addEventListener(TimerEvent.TIMER, handleAutosaveTimerInterval);
				
				autosaveTimer.start();
			}
			else
			{
				autosaveTimer = null;
			}
		}
		
		public function centerWindow():void
		{
			// center the window on the screen
			var screenBounds:Rectangle = Screen.mainScreen.bounds;

            nativeWindow.x = (screenBounds.width - nativeWindow.width) / 2;
            nativeWindow.y = (screenBounds.height - nativeWindow.height) / 2;
		}
		
		private function applySettings():void
		{
			//config.save();
			
			// page settings
			
			
			// handle layout first
			applyLayoutSettings();
			
			if(config.settings.pageBackgroundOpacity)
			{
				content.setStyle('backgroundAlpha', config.settings.pageBackgroundOpacity);
			}
			
			if(config.settings.pageBackgroundColor)
			{
				content.setStyle('backgroundColor', config.settings.pageBackgroundColor);
			}
		
			// live scrolling
			content.liveScrolling = config.settings.liveScrolling;
			
			if(config.settings.backgroundColor)
			{
				this.setStyle('backgroundColor', config.settings.backgroundColor);
			}
			
			if(config.settings.backgroundOpacity)
			{
				this.setStyle('backgroundAlpha', config.settings.backgroundOpacity);
			}
			
			// formatting
			
			if(config.settings.fontFamily)
			{
				content.setStyle('fontFamily', config.settings.fontFamily);
			}
			
			if(config.settings.fontColor)
			{
				content.setStyle('color', config.settings.fontColor);
				lblInformation.setStyle('color', config.settings.fontColor);
			}
			
			if(config.settings.fontSize)
			{
				content.setStyle('fontSize', config.settings.fontSize);
			}
			
			if(config.settings.fontLetterSpacing)
			{
				content.setStyle('letterSpacing', config.settings.fontLetterSpacing);
			}
			
			if(config.settings.fontStyle)
			{
				content.setStyle('fontStyle', config.settings.fontStyle);
			}
			
			if(config.settings.fontWeight)
			{
				content.setStyle('fontWeight', config.settings.fontWeight);
			}
			
			if(config.settings.fontDecoration)
			{
				content.setStyle('textDecoration', config.settings.fontDecoration);
			}
			
			// paragraph
			setContentStyle('leading', config.settings.fontLeading);
			setContentStyle('textIndent', config.settings.fontIndent);
			setContentStyle('textAlign', config.settings.fontAlign);
			content.tabsToSpaces = Boolean(config.settings.tabsToSpaces);
			content.tabsToSpacesCount = int(config.settings.tabsToSpacesCount);
			content.autoIndent = Boolean(config.settings.autoIndent);
			content.wordWrap = Boolean(config.settings.wordWrap);
			
			// disable scrolls
			content.verticalScrollPolicy = (config.settings.scrollVerticalDisable) ? 'off' : 'auto';
			content.horizontalScrollPolicy = (config.settings.scrollHorizontalDisable) ? 'off' : 'auto';
			
			// scroll styles
			var scrollbarStyles:CSSStyleDeclaration = StyleManager.getStyleDeclaration('.scrollbar');
			scrollbarStyles.setStyle('cornerRadius', config.settings.scrollCornerRadius);
			scrollbarStyles.setStyle('highlightAlphas', [config.settings.scrollHighlightAlpha1, config.settings.scrollHighlightAlpha2]);
			scrollbarStyles.setStyle('fillAlphas', [config.settings.scrollFillAlpha1, config.settings.scrollFillAlpha2, 
													config.settings.scrollFillAlpha3, config.settings.scrollFillAlpha4]);
			scrollbarStyles.setStyle('fillColors', [config.settings.scrollFillColor1, config.settings.scrollFillColor2, 
													config.settings.scrollFillColor3, config.settings.scrollFillColor4]);
			scrollbarStyles.setStyle('trackColors', [config.settings.scrollTrackColor1, config.settings.scrollTrackColor2]);
			scrollbarStyles.setStyle('themeColor', config.settings.scrollThemeColor);
			scrollbarStyles.setStyle('borderColor', config.settings.scrollBorderColor);
			
			StyleManager.setStyleDeclaration(".scrollbar", scrollbarStyles, true);
			
			// auto save settings
			initAutosaveTimer();
		}
		
		private function processCurrentSettings():void
		{
			// page
			config.settings.pageWidth = content.width;
			config.settings.pageWidthAuto = (config.settings.pageWidthAuto) ? config.settings.pageWidthAuto : false;
			config.settings.pageHeight = content.height;
			config.settings.pageHeightAuto = (config.settings.pageHeightAuto) ? config.settings.pageHeightAuto : false;
			config.settings.pageMarginVertical = (config.settings.pageMarginVertical) ? config.settings.pageMarginVertical : this.getStyle('paddingTop');
			config.settings.pageMarginHorizontal = (config.settings.pageMarginHorizontal) ? config.settings.pageMarginHorizontal : this.getStyle('paddingLeft');
			config.settings.pagePaddingVerticalTop = content.getStyle('paddingTop');
			config.settings.pagePaddingVerticalBottom = content.getStyle('paddingBottom');
			config.settings.pagePaddingHorizontal = content.getStyle('paddingLeft');
			config.settings.pageBackgroundOpacity = content.getStyle('backgroundAlpha');
			config.settings.pageBackgroundColor = content.getStyle('backgroundColor');
			
			// general
			config.settings.launchFullScreen = (config.settings.launchFullScreen == '') ? config.settings.launchFullScreen : true;
			config.settings.liveScrolling = content.liveScrolling;
			config.settings.backgroundColor = this.getStyle('backgroundColor');
			config.settings.backgroundOpacity = this.getStyle('backgroundAlpha');
			
			// formatting
			config.settings.fontFamily = content.getStyle('fontFamily');
			config.settings.fontColor = content.getStyle('color');
			config.settings.fontSize = content.getStyle('fontSize');
			config.settings.fontLetterSpacing = content.getStyle('letterSpacing');
			config.settings.fontStyle = content.getStyle('fontStyle');
			config.settings.fontWeight = content.getStyle('fontWeight');
			config.settings.fontDecoration = content.getStyle('textDecoration');
			
			// paragraph
			config.settings.fontLeading = content.getStyle('leading');
			config.settings.fontIndent = content.getStyle('textIndent');
			config.settings.fontAlign = content.getStyle('textAlign');
			config.settings.tabsToSpaces = cardinalValue(config.settings.tabsToSpaces, false);
			config.settings.tabsToSpacesCount = cardinalValue(config.settings.tabsToSpacesCount, 0);
			config.settings.autoIndent = cardinalValue(config.settings.autoIndent, false);
			config.settings.wordWrap = content.wordWrap; //cardinalValue(config.settings.wordWrap, true);
			
			// disable scrolls
			config.settings.scrollVerticalDisable = (content.verticalScrollPolicy=='off') ? true : false;
			config.settings.scrollHorizontalDisable = (content.horizontalScrollPolicy=='off') ? true : false;
			
			// scroll styles
			var scrollbarStyles:CSSStyleDeclaration = StyleManager.getStyleDeclaration('.scrollbar');
			config.settings.scrollCornerRadius = scrollbarStyles.getStyle('cornerRadius');
			var highlightAlphas:Array = scrollbarStyles.getStyle('highlightAlphas');
			config.settings.scrollHighlightAlpha1 = highlightAlphas[0];
			config.settings.scrollHighlightAlpha2 = highlightAlphas[1];
			var fillAlphas:Array = scrollbarStyles.getStyle('fillAlphas');
			config.settings.scrollFillAlpha1 = fillAlphas[0];
			config.settings.scrollFillAlpha2 = fillAlphas[1];
			config.settings.scrollFillAlpha3 = fillAlphas[2];
			config.settings.scrollFillAlpha4 = fillAlphas[3];
			var fillColors:Array = scrollbarStyles.getStyle('fillColors');
			config.settings.scrollFillColor1 = fillColors[0];
			config.settings.scrollFillColor2 = fillColors[1];
			config.settings.scrollFillColor3 = fillColors[2];
			config.settings.scrollFillColor4 = fillColors[3];
			var trackColors:Array = scrollbarStyles.getStyle('trackColors');
			config.settings.scrollTrackColor1 = trackColors[0];
			config.settings.scrollTrackColor2 = trackColors[1];
			config.settings.scrollThemeColor = scrollbarStyles.getStyle('themeColor');
			config.settings.scrollBorderColor = scrollbarStyles.getStyle('borderColor');			
		}
		
		private function applyLayoutSettings():void
		{
			// temp variables
			var margin:int = 0;
			var value:int = 0;
			var offset:int = (Screen.mainScreen.bounds.height == this.height) ? 0 : 25;
			
			// page margin vertical
			if (config.settings.pageMarginVertical)
			{
				if (config.settings.pageMarginVertical > ((this.height/2)-100)) { config.settings.pageMarginVertical = ((this.height/2)-100) } // too much
				if (config.settings.pageMarginVertical < 0) { config.settings.pageMarginVertical = 0 } // too little
			}
			
			// page margin horizontal
			if (config.settings.pageMarginHorizontal)
			{
				if (config.settings.pageMarginHorizontal > ((this.width/2)-100)) { config.settings.pageMarginHorizontal = ((this.width/2)-100) } // too much
				if (config.settings.pageMarginHorizontal < 0) { config.settings.pageMarginHorizontal = 0 } // too little
			}
			
			//page width
			margin = (config.settings.pageMarginHorizontal) ? config.settings.pageMarginHorizontal : 0;
			if (config.settings.pageWidthAuto)
			{
				content.width = this.width - (margin * 2);
			}
			else if (config.settings.pageWidth)
			{
				value = config.settings.pageWidth;
				
				// adjust
				if (value > (this.width-(margin*2))) { value = (this.width-(margin*2)) } // too wide
				if (value < 100) { value = 100 } // too narrow
				
				content.width = value; //assign
			}
			
			// center horizontally
			if (((this.width-content.width)/2) > margin)
			{
				margin = (this.width-content.width)/2;
			}
			content.x = margin;
			
			// page height
			margin = (config.settings.pageMarginVertical) ? config.settings.pageMarginVertical : 0;
			if (config.settings.pageHeightAuto)
			{
				content.height = this.height - (margin * 2) - offset;
			}
			else if (config.settings.pageHeight)
			{
				// set a minimum margin
				value = config.settings.pageHeight;
				
				// adjust if necessary
				if (value > this.height-(margin*2) - offset)
				{
					value = this.height-(margin*2) - offset;
				}
				if (value < 100) { value = 100 } // too short
				
				content.height = value; // assign
			}
			
			// center vertically
			if ((this.height-(content.height+offset)/2) > margin)
			{
				margin = (this.height-(content.height+offset))/2;
			}
			content.y = margin;
			
			// page padding veritical
			if(config.settings.pagePaddingVerticalTop)
			{
				if (config.settings.pagePaddingVerticalTop > ((this.height/2)-100-config.settings.pageMarginVertical)) { config.settings.pagePaddingVerticalTop = ((this.height/2)-100-config.settings.pageMarginVertical) } // too much
				if (config.settings.pagePaddingVerticalTop < 0) { config.settings.pagePaddingVerticalTop = 0 } // too little
				
				value = int(config.settings.pagePaddingVerticalTop);
				
				content.setStyle('paddingTop', value);
			}
			
			if(config.settings.pagePaddingVerticalBottom)
			{
				if (config.settings.pagePaddingVerticalBottom > ((this.height/2)-100-config.settings.pageMarginVertical)) { config.settings.pagePaddingVerticalBottom = ((this.height/2)-100-config.settings.pageMarginVertical) } // too much
				if (config.settings.pagePaddingVerticalBottom < 0) { config.settings.pagePaddingVerticalBottom = 0 } // too little
				
				value = int(config.settings.pagePaddingVerticalBottom);
				
				content.setStyle('paddingBottom', value);
			}
			
			// page padding horizontal
			if(config.settings.pagePaddingHorizontal)
			{
				if (config.settings.pageMarginHorizontal > ((this.width/2)-100)) { config.settings.pageMarginHorizontal = ((this.width/2)-100) } // too much
				if (config.settings.pageMarginHorizontal < 0) { config.settings.pageMarginHorizontal = 0 } // too little
				
				value = int(config.settings.pagePaddingHorizontal);
				
				content.setStyle('paddingLeft', value);
				content.setStyle('paddingRight', value);
			}
			
			// information bar
			lblInformation.width = this.width - 20;
			lblInformation.y = this.height - 20 - offset;
		}
		
		
		
		private function saveSettings():void
		{
			serializeSettings();
		}
		
		private function serializeSettings():void
		{
			settingsXml = <settings/>;
			//prefsXML.windowState.@x = stage.nativeWindow.x;
			//prefsXML.windowState.@y = stage.nativeWindow.y;
			settingsXml.saveDate = new Date().toString();
		}
		
		private function writeSettings():void
		{
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			outputString += settingsXml.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);
			stream = new FileStream();
			stream.open(settingsFile, FileMode.WRITE);
			stream.writeUTFBytes(outputString);
			stream.close();
		}
		
		public function initMenu():void
		{
			// is mac?
			var isMac:Boolean = (Capabilities.os.substr(0, 3).toLowerCase() == "mac") ? true : false;
			
			// file menu options
			var fileNew:NativeMenuItem = new NativeMenuItem("New", false);
 			var fileOpen:NativeMenuItem = new NativeMenuItem("Open...", false);
 			var fileSep1:NativeMenuItem = new NativeMenuItem("1", true);
 			var fileClose:NativeMenuItem = new NativeMenuItem("Close", false);
 			var fileSep2:NativeMenuItem = new NativeMenuItem("2", true);
 			var fileSave:NativeMenuItem = new NativeMenuItem("Save", false);
 			var fileSaveAs:NativeMenuItem = new NativeMenuItem("Save As...", false);
 			var fileSep3:NativeMenuItem = new NativeMenuItem("3", true);
 			var fileExit:NativeMenuItem = new NativeMenuItem("Exit", false);
 			
 			// edit menu options
 			var editUndo:NativeMenuItem = new NativeMenuItem("Undo", false);
 			var editRedo:NativeMenuItem = new NativeMenuItem("Redo", false);
 			var editSep1:NativeMenuItem = new NativeMenuItem("1", true);
 			var editCut:NativeMenuItem = new NativeMenuItem("Cut", false);
 			var editCopy:NativeMenuItem = new NativeMenuItem("Copy", false);
 			var editPaste:NativeMenuItem = new NativeMenuItem("Paste", false);
 			var editSep2:NativeMenuItem = new NativeMenuItem("2", true);
 			var editSelectAll:NativeMenuItem = new NativeMenuItem("Select All", false);
 			var editSep3:NativeMenuItem = new NativeMenuItem("3", true);
 			var editSettings:NativeMenuItem = new NativeMenuItem("Preferences...", false);
 			
 			// view menu options
 			var viewInformation:NativeMenuItem = new NativeMenuItem("Information Bar, Toggle");
 			var viewScrollbars:NativeMenuItem = new NativeMenuItem("Scrollbars, Toggle");
 			
 			// build menu
 			
 			
 			// Mac OS X
		   	if (NativeApplication.supportsMenu)
		   	{
		   		NativeApplication.nativeApplication.menu = rootMenu;
		   	}
		    
		   	// Windows
		   	if (NativeWindow.supportsMenu)
		   	{
		   		stage.nativeWindow.menu = rootMenu;		   		
		  	}
		  
 			var fileMenuItem:NativeMenuItem = rootMenu.addSubmenu(new NativeMenu(), "File");
			fileMenuItem.submenu.addItem(fileNew);
			fileMenuItem.submenu.addItem(fileOpen);
			fileMenuItem.submenu.addItem(fileSep1);
			fileMenuItem.submenu.addItem(fileClose);
			fileMenuItem.submenu.addItem(fileSep2);
			fileMenuItem.submenu.addItem(fileSave);
			fileMenuItem.submenu.addItem(fileSaveAs);
			fileMenuItem.submenu.addItem(fileSep3);
			fileMenuItem.submenu.addItem(fileExit);
			
			var editMenuItem:NativeMenuItem = rootMenu.addSubmenu(new NativeMenu(), "Edit");
			//editMenuItem.submenu.addItem(editUndo);
			//editMenuItem.submenu.addItem(editRedo);
			//editMenuItem.submenu.addItem(editSep1);
			editMenuItem.submenu.addItem(editCut);
			editMenuItem.submenu.addItem(editCopy);
			editMenuItem.submenu.addItem(editPaste);
			editMenuItem.submenu.addItem(editSep2);
			editMenuItem.submenu.addItem(editSelectAll);
			editMenuItem.submenu.addItem(editSep3);
			editMenuItem.submenu.addItem(editSettings);
			
			var viewMenuItem:NativeMenuItem = rootMenu.addSubmenu(new NativeMenu(), "View");
			viewMenuItem.submenu.addItem(viewInformation);
			viewMenuItem.submenu.addItem(viewScrollbars);
			
			
			// bind events
			fileNew.addEventListener(Event.SELECT, handleFileNew);
 			fileOpen.addEventListener(Event.SELECT, handleFileOpen);
 			fileClose.addEventListener(Event.SELECT, handleFileClose);
 			fileSave.addEventListener(Event.SELECT, handleFileSave);
 			fileSaveAs.addEventListener(Event.SELECT, handleFileSaveAs);
 			fileExit.addEventListener(Event.SELECT, handleFileExit);

			//editUndo.addEventListener(Event.SELECT, handleEditUndo);
 			//editRedo.addEventListener(Event.SELECT, handleEditRedo);
 			editCut.addEventListener(Event.SELECT, handleEditCut);
 			editCopy.addEventListener(Event.SELECT, handleEditCopy);
 			editPaste.addEventListener(Event.SELECT, handleEditPaste);
 			editSelectAll.addEventListener(Event.SELECT, handleEditSelectAll);
 			editSettings.addEventListener(Event.SELECT, handleEditSettings);
 			
 			viewInformation.addEventListener(Event.SELECT, handleViewInformation);
 			viewScrollbars.addEventListener(Event.SELECT, handleViewScrollbars);
 			
 			// keyboard equivalents
 			fileNew.keyEquivalent = "n";
 			fileNew.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			fileOpen.keyEquivalent = "o";
 			fileOpen.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			fileClose.keyEquivalent = "w";
 			fileClose.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			fileSave.keyEquivalent = "s";
 			fileSave.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			fileSaveAs.keyEquivalent = "s";
 			fileSaveAs.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND, Keyboard.SHIFT] : [Keyboard.CONTROL, Keyboard.SHIFT];
 			fileExit.keyEquivalent = (isMac) ? "q" : "x";
 			fileExit.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			
 			//editUndo.keyEquivalent = "z";
 			//editUndo.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			//editRedo.keyEquivalent = "y";
 			//editRedo.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editCut.keyEquivalent = "x";
 			editCut.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editCopy.keyEquivalent = "c";
 			editCopy.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editPaste.keyEquivalent = "v";
 			editPaste.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editSelectAll.keyEquivalent = "a";
 			editSelectAll.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editSettings.keyEquivalent = ",";
 			editSettings.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			
 			viewInformation.keyEquivalent = "i";
 			viewInformation.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			viewScrollbars.keyEquivalent = "u";
 			viewScrollbars.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			
		}
		
		/* Handle Flipping Between View States */
		
		public function launchFullScreen():void
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			applyLayoutSettings();
			
			focusManager.setFocus(content);
		}
		
		public function toggleDisplayState(event:KeyboardEvent):void
		{
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				event.preventDefault();
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
			
			applyLayoutSettings();
			
			focusManager.setFocus(content);
		}
				
		/* Handle Events and Other Unholy Things */
		
		public function initListeners():void
		{
			// stage
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreen);
			stage.addEventListener(ResizeEvent.RESIZE, handleResize);
			
			// menu
			
			// content area
			
			this.addEventListener(Event.CLOSING, handleClosing);
		}
		
		public function handleSettingUpdate(event:Event):void
		{
			
		}
		
		public function handleFileNew(event:Event):void
		{
			preprocessNewFile();
		}
		
		public function handleFileOpen(event:Event):void
		{
			preprocessOpenFile();
		}
		
		public function handleFileClose(event:Event):void
		{
			preprocessNewFile();
		}
		
		public function handleFileSave(event:Event):void
		{
			saveFile();
		}
		
		public function handleFileSaveAs(event:Event):void
		{
			saveAs();
		}
		
		public function handleFileExit(event:Event):void
		{
			preprocessClose();
		}
		
		public function handleEditUndo(event:Event):void
		{
			//Alert.show("For some reason, undo and redo aren't working");
			//NativeApplication.nativeApplication.undo();
		}
		
		public function handleEditRedo(event:Event):void
		{
			//Alert.show("For some reason, undo and redo aren't working");
			//NativeApplication.nativeApplication.redo();
		}
		
		public function handleEditCut(event:Event):void
		{
			NativeApplication.nativeApplication.cut();
		}
		
		public function handleEditCopy(event:Event):void
		{
			NativeApplication.nativeApplication.copy();
		}
		
		public function handleEditPaste(event:Event):void
		{
			NativeApplication.nativeApplication.paste();
		}
		
		public function handleEditSelectAll(event:Event):void
		{
			content.setSelection(0,content.length);
		}
		
		public function handleAutosaveTimerInterval(event:TimerEvent):void
		{
			saveFile();
		}
		
		public function handleEditSettings(event:Event):void
		{
			processCurrentSettings();
			
			configDialog = PopUpManager.createPopUp(this, ConfigurationDialog, true) as ConfigurationDialog;
			configDialog["btnOk"].addEventListener("click", handleConfigDialogOk);
			
			configDialog.config = config;
			
			configDialog.updateFields();
			
			PopUpManager.centerPopUp(configDialog);
		}
		
		public function handleViewInformation(event:Event):void
		{
			lblInformation.visible = !lblInformation.visible;
		}
		
		public function handleViewScrollbars(event:Event):void
		{
			config.settings.scrollVerticalDisable = !config.settings.scrollVerticalDisable;
			config.settings.scrollHorizontalDisable = !config.settings.scrollHorizontalDisable;
			config.save();
			
			applySettings();
		}
		
		public function handleKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE)
			{
				toggleDisplayState(event);
			}
			
			updateStatistics();
		}
		
		public function handleFullScreen(event:FullScreenEvent):void
		{
			isFullScreen = event.fullScreen;
			isDirty = true;
			
			if (isFullScreen)
			{
				//menuBar.visible = false;
			}
			else
			{
				//menuBar.visible = true;
			}
			
			applyLayoutSettings();
		}
		
		public function handleResize(event:Event):void
		{
			applyLayoutSettings();
		}
		
		private function handleMenuItemClick(event:MenuEvent):void
		{
			switch(event.label)
			{
				case 'New':
					preprocessNewFile();
					break;
					
				case 'Open':
					preprocessOpenFile();
					break;
					
				case 'Save':
					saveFile();
					break;
						
				case 'Save As...':
					saveAs();
					break;
			}
		}
		
		public function handleConfigDialogOk(event:Event):void
		{
			config = configDialog.processSettings();
			config.save();
			
			applySettings();
		}
		
		private function preprocessOpenFile():void
		{
			if(content.isDirty)
			{
				Alert.show(UNSAVED_MESSAGE, UNSAVED_TITLE, Alert.OK | Alert.CANCEL, this, handlePreprocessOpenFile, null, Alert.OK);
			}
			else
			{
				openFile();
			}
		}
		
		private function handlePreprocessOpenFile(event:CloseEvent):void
		{
			if (event.detail==Alert.OK)
			{
				openFile();
			}
		}
		
		/**
		 * Called when the user clicks the Open button. Opens a file chooser dialog box, in which the 
		 * user selects a currentFile. 
		 */
		private function openFile():void 
		{	
			var fileChooser:File;
			if (currentFile) 
			{
				fileChooser = currentFile;
			}
			else
			{
				fileChooser = defaultDirectory;
			}
			fileChooser.browseForOpen("Open");
			fileChooser.addEventListener(Event.SELECT, fileOpenSelected);
		}
		
		/**
		 * Called when the user selects the currentFile in the FileOpenPanel control. The method passes 
	  	 * File object pointing to the selected currentFile, and opens a FileStream object in read mode (with a FileMode
		 * setting of READ), and modify's the title of the application window based on the filename.
		 */
		private function fileOpenSelected(event:Event):void 
		{
			currentFile = event.target as File;
			openCurrentFile();
		}
		
		private function openCurrentFile():void
		{
			stream = new FileStream();
			stream.openAsync(currentFile, FileMode.READ);
			stream.addEventListener(Event.COMPLETE, fileReadHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, readIOErrorHandler);
			content.isDirty = false;
			title = "Dark Room X - " + currentFile.name;
			currentFile.removeEventListener(Event.SELECT, fileOpenSelected);
		}
		
		/**
		 * Called when the stream object has finished reading the data from the currentFile (in the openFile()
		 * method). This method reads the data as UTF data, converts the system-specific line ending characters
		 * in the data to the "\n" character, and displays the data in the mainTextField Text component.
		 */
		private function fileReadHandler(event:Event):void 
		{
			var str:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			var lineEndPattern:RegExp = /(\cM\cJ)|\r]/g; // new RegExp(File.lineEnding, "g");
			str = str.replace(lineEndPattern, "\n");
			content.text = str; 
			stream.close();
			
			updateStatistics();
		}
		
		/**
		 * Called when the user clicks the "Save" button. The method sets up the stream object to point to
		 * the currentFile specified by the currentFile object, with save access. This method converts the "\r" and "\n" characters 
		 * in the mainTextField.text data to the system-specific line ending character, and writes the data to the currentFile.
		 */
		private function saveFile():void 
		{
			if (currentFile) {
				if (stream != null)	
				{
					stream.close();
				}
				stream = new FileStream();
				stream.openAsync(currentFile, FileMode.WRITE);
				stream.addEventListener(IOErrorEvent.IO_ERROR, writeIOErrorHandler);
				var str:String = content.text;
				str = str.replace(/\r/g, "\n");
				str = str.replace(/\n/g, File.lineEnding);
				stream.writeUTFBytes(str);
				stream.close();
				content.isDirty = false;
			} 
			else
			{
				saveAs();
			}
		}
		
		/**
		 * Called when the user clicks the "Save As" button. Opens a Save As dialog box, in which the 
		 * user selects a currentFile path. See the FileSavePanel.mxml currentFile.
		 */
		private function saveAs():void 
		{
			var fileChooser:File;
			if (currentFile)
			{
				fileChooser = currentFile;
			}
			else
			{
				fileChooser = defaultDirectory;
			}
			fileChooser.browseForSave("Save As");
			fileChooser.addEventListener(Event.SELECT, saveAsFileSelected);
		}
	
		/**
		 * Called when the user selects the file path in the Save As dialog box. The method passes the selected 
		 * currentFile to the File object and calls the saveFile() method, which saves the currentFile.
		 */
		private function saveAsFileSelected(event:Event):void 
		{
			currentFile = event.target as File;
			title = "Dark Room X - " + currentFile.name;
			saveFile();
			content.isDirty = false;
			currentFile.removeEventListener(Event.SELECT, saveAsFileSelected);
		}
		
		private function preprocessNewFile():void
		{
			if(content.isDirty)
			{
				Alert.show(UNSAVED_MESSAGE, UNSAVED_TITLE, Alert.OK | Alert.CANCEL, this, handlePreprocessNewFile, null, Alert.OK);
			}
			else
			{
				newFile();
			}
		}
		
		private function handlePreprocessNewFile(event:CloseEvent):void
		{
			if (event.detail==Alert.OK)
			{
				newFile();
			}
		}
		
		/**
		 * Called when the user clicks the "New" button. Initializes the state, with an undefined File object and a
		 * blank text entry field.
		 */
		private function newFile():void
		{
			currentFile = undefined;
			content.isDirty = false;
			content.text = "";
		}
		
		/**
		 * Handles I/O errors that may come about when opening the currentFile.
		 */
		private function readIOErrorHandler(event:Event):void 
		{
			Alert.show("The specified currentFile cannot be opened.", "Error", Alert.OK, this);
		}
		
		/**
		 * Handles I/O errors that may come about when writing the currentFile.
		 */
		private function writeIOErrorHandler(event:Event):void 
		{
			Alert.show("The specified currentFile cannot be saved.", "Error", Alert.OK, this);
		}
		
		private function preprocessClose():void
		{
			if(currentFile)
			{
				config.settings.lastFileNativePath = currentFile.nativePath;
			}
			
			if(content.isDirty)
			{
				Alert.show(UNSAVED_MESSAGE, UNSAVED_TITLE, Alert.OK | Alert.CANCEL, this, handlePreprocessClose, null, Alert.OK);
			}
			else
			{
				NativeApplication.nativeApplication.exit();
			}
		}
		
		private function handlePreprocessClose(event:CloseEvent):void
		{
			if (event.detail==Alert.OK)
			{
				config.save();
				
				NativeApplication.nativeApplication.exit();
			}
		}
		
		
		private function handleClosing(event:Event):void
		{
			event.preventDefault();
			
			preprocessClose();
		}
		
		
		private function setContentStyle(style:String,value:String):void
		{
			if(value)
			{
				content.setStyle(style, value);
			}
		}
		
		private function setThisStyle(style:String,value:String):void
		{
			if(value)
			{
				this.setStyle(style, value);
			}
		}
		
		private function cardinalValue(value:Object, alt:Object):Object
		{
			return (value) ? value : alt;
		}
		
		private function updateStatistics():void
		{
			if(lblInformation.visible)
			{
				lblInformation.text = (currentFile) ? currentFile.name : 'untitled';
			
				var stats:Array = new Array();
				
				if(config.settings.statisticsCharacters)
				{
					stats.push('characters: ' + content.text.length.toString());
				}
				
				if(config.settings.statisticsWords)
				{
					stats.push('words: ' + content.text.match(PATTERN_WORDS).length.toString());
				}
				
				if(config.settings.statisticsSentences)
				{
					
					stats.push('sentences: ' + content.text.split(PATTERN_SENTENCES).length.toString());
				}
				
				if(config.settings.statisticsLines)
				{
					
					stats.push('lines: ' + content.text.split(PATTERN_LINES).length.toString());
				}
				
				lblInformation.text += (stats.length > 0) ? ' (' + stats.join(', ') + ')' : '';
				this.title = "Dark Room X - " + lblInformation.text;
			}
		}
	}
}