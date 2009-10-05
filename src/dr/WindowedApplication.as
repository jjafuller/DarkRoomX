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
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import gearsandcogs.text.UndoTextFields;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.MenuBar;
	import mx.core.WindowedApplication;
	import mx.events.*;
	import mx.managers.*;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	

	public class WindowedApplication extends mx.core.WindowedApplication
	{
		// constances
		public static const FRAME_RATE:int = 12;
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
		public var menuKeyBindings:ArrayCollection;
		public var menuSkeleton:ArrayCollection;
		public var stats:Array;
		public var information:String;

		// controls
		public var content:dr.TextArea;
		public var lblInformation:Label;
		public var virtualMenu:MenuBar;
		
		//public var menuBar:MenuBar;
		public var rootMenu:NativeMenu = new NativeMenu();
		
		// dialogs
		public var configDialog:ConfigurationDialog;
		public var findDialog:FindAndReplaceDialog;
		
		// constructor
		public function WindowedApplication()
		{
			
		}
		
		public function init():void 
 		{	
 			virtualMenu.visible = false;
 			
 			stage.frameRate = FRAME_RATE;
 			
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
 			trace(config.settings.reopenLastDocument);
 			trace(config.settings.lastFileNativePath);
 			
 			if(config.settings.reopenLastDocument && config.settings.lastFileNativePath.length > 0)
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
 			
			//content.text = "Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n";
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
			
			if(!isNaN(config.settings.pageBackgroundColor))
			{
				content.setStyle('backgroundColor', config.settings.pageBackgroundColor);
			}
		
			// live scrolling
			content.liveScrolling = config.settings.liveScrolling;
			
			if(!isNaN(config.settings.backgroundColor))
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
			
			if(!isNaN(config.settings.fontColor))
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
			var offsetMenu:int = (virtualMenu.visible) ? virtualMenu.height : 0;
			var offset:int = (Screen.mainScreen.bounds.height == this.height) ? 0 : 25 + offsetMenu;
			
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
			content.y = margin + offsetMenu;
			
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
			lblInformation.y = this.height - 20;
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
			menuKeyBindings = new ArrayCollection([{keyEquivalent:Keyboard.N,action:preprocessNewFile}]);
			
			var ctrlKey:int = (NativeWindow.supportsMenu) ? Keyboard.CONTROL : Keyboard.COMMAND;
		
			menuSkeleton = new ArrayCollection([
											{label:'File', children: new ArrayCollection([
												{label:"New", keyEquivalent:Keyboard.N, keyEquivalentModifiers:[ctrlKey], action:handleFileNew},
												{label:"Open..", keyEquivalent:Keyboard.O, keyEquivalentModifiers:[ctrlKey], action:handleFileOpen},
												{label:"1",separator:true},
												{label:"Close",keyEquivalent:Keyboard.W, keyEquivalentModifiers:[ctrlKey], action:handleFileClose},
												{label:"2",separator:true},
												{label:"Save",keyEquivalent:Keyboard.S, keyEquivalentModifiers:[ctrlKey], action:handleFileSave},
												{label:"Save As..",keyEquivalent:Keyboard.S, keyEquivalentModifiers:[ctrlKey,Keyboard.SHIFT], action:handleFileSaveAs},
												{label:"3",separator:true},
												{label:"Exit",keyEquivalent:((NativeWindow.supportsMenu) ? Keyboard.X : Keyboard.Q), keyEquivalentModifiers:[ctrlKey], action:handleFileExit},
											])},
											{label:'Edit', children: new ArrayCollection([
												{label:"Cut", keyEquivalent:Keyboard.X, keyEquivalentModifiers:[ctrlKey], action:handleEditCut},
												{label:"Copy", keyEquivalent:Keyboard.C, keyEquivalentModifiers:[ctrlKey], action:handleEditCopy},
												{label:"Paste", keyEquivalent:Keyboard.V, keyEquivalentModifiers:[ctrlKey], action:handleEditPaste},
												{label:"1",separator:true},
												{label:"Select All",keyEquivalent:Keyboard.A, keyEquivalentModifiers:[ctrlKey], action:handleEditSelectAll},
												{label:"2",separator:true},
												{label:"Find...",keyEquivalent:Keyboard.F, keyEquivalentModifiers:[ctrlKey], action:handleEditFind},
												{label:"3",separator:true},
												{label:"Preferences..",keyEquivalent:Keyboard.COMMA, keyEquivalentModifiers:[ctrlKey], action:handleEditSettings},
											])},
											{label:'View', children: new ArrayCollection([
												{label:"Information Bar, Toggle",keyEquivalent:Keyboard.I, keyEquivalentModifiers:[ctrlKey], action:handleViewInformation},
												{label:"Scrollbars, Toggle",keyEquivalent:Keyboard.U, keyEquivalentModifiers:[ctrlKey], action:handleViewScrollbars},
											])}
										]);
										
			Menu.build(menuSkeleton, this);
			
			if (stage.displayState == StageDisplayState.NORMAL && NativeWindow.supportsMenu)
			{
				virtualMenu.visible = true;
			}	
			
		}
		
		/* Handle Flipping Between View States */
		
		public function launchFullScreen():void
		{
			virtualMenu.visible = false;
			lblInformation.visible = true;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			applyLayoutSettings();
			
			focusManager.setFocus(content);
		}
		
		public function toggleDisplayState(event:KeyboardEvent):void
		{
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				event.preventDefault();
				virtualMenu.visible = false;
				lblInformation.visible = true;
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
				virtualMenu.visible = NativeWindow.supportsMenu;
				lblInformation.visible = false;
			}
			
			applyLayoutSettings();
			
			if(configDialog)
			{
				PopUpManager.centerPopUp(configDialog);
				focusManager.setFocus(configDialog.navigator);
			}
			else
			{
				focusManager.setFocus(content);	
			}
		}
				
		/* Handle Events and Other Unholy Things */
		
		public function initListeners():void
		{
			// stage
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreen);
			stage.addEventListener(ResizeEvent.RESIZE, handleResize);
			
			// text area
			content.addEventListener(Event.CHANGE, handleChange);
			
			// menu
			
			// application
			this.addEventListener(Event.CLOSING, handleClosing);
			this.addEventListener(AIREvent.APPLICATION_DEACTIVATE, handleApplicationDeactivate);
			this.addEventListener(AIREvent.APPLICATION_ACTIVATE, handleApplicationActivate);
			this.nativeApplication.addEventListener(InvokeEvent.INVOKE, handleInvoke);
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
			// only set focus if the content area is selected
			if (focusManager.getFocus() == content)
			{
				content.setSelection(0,content.length);	
			}
		}
		
		public function handleEditFind(event:Event):void
		{
			findDialog = PopUpManager.createPopUp(this, FindAndReplaceDialog, false) as FindAndReplaceDialog;
			
			findDialog.content = content;
			
			PopUpManager.centerPopUp(findDialog);
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
			focusManager.setFocus(configDialog.navigator);
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
		
		public function handleMenuItemClick(event:MenuEvent):void
		{
			// hack to emulate native menu item action
			for each (var item:Object in menuSkeleton)
			{
				for each (var child:Object in item.children)
				{
					if(event.item.label == child.label)
					{
						child.action(new Event(Event.SELECT));
					}
				}
			}
		}
		
		public function handleChange(event:Event):void
		{
			updateStatistics();
		}
		
		public function handleKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE)
			{
				if (focusManager.getFocus() == content)
				{
					toggleDisplayState(event);	
				}
				else
				{
					if(configDialog)
					{
						PopUpManager.removePopUp(configDialog);
					}
					else if(findDialog)
					{
						PopUpManager.removePopUp(findDialog);
					}
					else
					{
						focusManager.setFocus(content);	
					}
				}
			}
			
			// hack to emulate menu bar shortcut keys, but only look if user is at least hold down ctrl key
			if (event.ctrlKey)
			{
				for each (var item:Object in menuSkeleton)
				{
					for each (var child:Object in item.children)
					{
						if((event.keyCode == child.keyEquivalent) && processKeyEquivalentModifiers(event,child.keyEquivalentModifiers))
						{
							event.preventDefault();
							child.action(new Event(Event.SELECT));
						}
					}
				}
			}
	
			
		}
		
		public function processKeyEquivalentModifiers(event:KeyboardEvent, modifiers:Array):Boolean
		{
			for each(var i:int in modifiers)
			{
				if	(
						((i == Keyboard.COMMAND || i == Keyboard.CONTROL) && !event.ctrlKey) ||
						((i == Keyboard.SHIFT) && !event.shiftKey)
					)
				{
					return false;
				}
			}
			
			return true;
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
		 * Trigger a file chooser, and open selected file.
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
		 * Set the selected file to the current file, then open current file
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
			
			currentFile.removeEventListener(Event.SELECT, fileOpenSelected);
		}
		
		/**
		 * Read in the file, and update statistics
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
		 * Save file, and replace line breaks with system line breaks
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
				updateInformation();
			} 
			else
			{
				saveAs();
			}
		}
		
		/**
		 * Trigger a save as file dialog
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
		 * Update information, and save file
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
		 * Zero out the document, and start a fresh one
		 */
		private function newFile():void
		{
			currentFile = undefined;
			content.isDirty = false;
			content.text = "";
			updateStatistics();
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
				config.save();
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
		
		private function handleInvoke(event:InvokeEvent):void
		{
			// open the file if we were opened for one
			if(event.reason == InvokeEventReason.STANDARD && event.arguments.length > 0 && String(event.arguments[0]).length > 0)
			{
				currentFile = new File(event.arguments[0]);
				if(currentFile.exists)
				{
					openCurrentFile();
				}
			}
		}
		
		
		private function handleApplicationDeactivate(event:Event):void {
		    //this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		    stage.frameRate = 0.1;
		}
		
		private function handleApplicationActivate(event:Event):void {
		    //this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		    stage.frameRate = FRAME_RATE;
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
		
		private function updateInformation():void
		{
			if(lblInformation.visible || stage.displayState == StageDisplayState.NORMAL)
			{
				information  = (content.isDirty) ? '*' : '';
				
				information += (currentFile) ? currentFile.name : 'untitled';
				
				information += (stats.length > 0) ? ' (' + stats.join(', ') + ')' : '';
				
				lblInformation.text = information
				this.title = "Dark Room X - " + information;
			}
		}
		
		private function updateStatistics():void
		{
			if(lblInformation.visible || stage.displayState == StageDisplayState.NORMAL)
			{
				stats = null;
				stats = new Array();
				
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
				
				updateInformation();
			}
		}
	}
}