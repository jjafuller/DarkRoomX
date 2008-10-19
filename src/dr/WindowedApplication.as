package dr
{
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.system.Capabilities;
	import flash.system.fscommand;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.controls.TextArea;
	import mx.core.WindowedApplication;
	import mx.events.*;
	import mx.managers.*;
	
	
	
	public class WindowedApplication extends mx.core.WindowedApplication
	{
		// variables
		private var isFullScreen:Boolean = false;
		private var isDirty:Boolean = false;
		private var currentFile:File; 							// The currentFile opened (and saved) by the application
		private var stream:FileStream = new FileStream(); 		// The FileStream object used for reading and writing the currentFile
		private var defaultDirectory:File; 						// The default directory
		
		[Bindable]
		public var dataChanged:Boolean = false; 		// Whether the text data has changed (and should be saved)
		private var settingsFile:File;
		public var config:Configuration;
		public var settingsXml:XML; 					// The XML data
		public var settingsStream:FileStream; 					// The FileStream object used to read and write settings file data.

		// controls
		public var content:TextArea;
		public var menuBar:MenuBar;
		public var rootMenu:NativeMenu = new NativeMenu();
		
		// dialogs
		public var configDialog:ConfigurationDialog;
		
		// constructor
		public function WindowedApplication()
		{
			
		}
		
		public function init():void 
 		{	
 			fscommand("trapallkeys", "true");
 			
 			initSettings();
 			
 			toggleDisplayState();
 			
 			initListeners();
 			initMenu();
 			
 			defaultDirectory = File.documentsDirectory;
 			
			content.text = "Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n\nDonec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.\n";
			content.selectionBeginIndex = content.text.length;
			content.selectionEndIndex = content.text.length;
		}
		
		public function initSettings():void
		{
			settingsFile = File.applicationStorageDirectory;
			settingsFile = settingsFile.resolvePath("settings.xml"); 
			
			config = new Configuration(settingsFile);
		}
		
		
		private function readSettings():void
		{
			settingsStream = new FileStream();
			if (settingsFile.exists) {
    			settingsStream.open(settingsFile, FileMode.READ);
    			settingsXml = XML(settingsStream.readUTFBytes(stream.bytesAvailable));
				settingsStream.close();
			    applySettings();
			}
			else
			{
			    saveSettings();
			}
		}
		
		private function applySettings():void
		{
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
			
			if(config.settings.fontSize)
			{
				content.setStyle('fontSize', config.settings.fontSize);
			}
		}
		
		private function applyLayoutSettings():void
		{
			// temp variables
			var margin:int = 0;
			var value:int = 0;
			
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
				content.height = this.height - (margin * 2);
			}
			else if (config.settings.pageHeight)
			{
				// set a minimum margin
				value = config.settings.pageHeight;
				
				// adjust if necessary
				if (value > (this.height-(margin*2))) { value = (this.height-(margin*2)) } // too tall
				if (value < 100) { value = 100 } // too short
				
				content.height = value; // assign
			}
			
			// center vertically
			if (((this.height-content.height)/2) > margin)
			{
				margin = (this.height-content.height)/2;
			}
			content.y = margin;
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
			config.settings.pagePaddingVertical = content.getStyle('paddingTop');
			config.settings.pageBackgroundOpacity = content.getStyle('backgroundAlpha');
			config.settings.pageBackgroundColor = content.getStyle('backgroundColor');
			
			// general
			config.settings.launchFullScreen = (config.settings.launchFullScreen == '') ? config.settings.launchFullScreen : true;
			config.settings.liveScrolling = content.liveScrolling;
			config.settings.backgroundColor = this.getStyle('backgroundColor');
			config.settings.backgroundOpacity = this.getStyle('backgroundAlpha');
			
			// formatting
			
			config.settings.fontSize = content.getStyle('fontSize');
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
			
			// init submenus
			var fileNew:NativeMenuItem = new NativeMenuItem("New", false);
 			var fileOpen:NativeMenuItem = new NativeMenuItem("Open...", false);
 			var fileSep1:NativeMenuItem = new NativeMenuItem("1", true);
 			var fileClose:NativeMenuItem = new NativeMenuItem("Close", false);
 			var fileSep2:NativeMenuItem = new NativeMenuItem("2", true);
 			var fileSave:NativeMenuItem = new NativeMenuItem("Save", false);
 			var fileSaveAs:NativeMenuItem = new NativeMenuItem("Save As...", false);
 			var fileSep3:NativeMenuItem = new NativeMenuItem("3", true);
 			var fileExit:NativeMenuItem = new NativeMenuItem("Exit", false);
 			
 			var editUndo:NativeMenuItem = new NativeMenuItem("Undo", false);
 			var editRedo:NativeMenuItem = new NativeMenuItem("Redo", false);
 			var editSep1:NativeMenuItem = new NativeMenuItem("1", true);
 			var editCut:NativeMenuItem = new NativeMenuItem("Cut", false);
 			var editCopy:NativeMenuItem = new NativeMenuItem("Copy", false);
 			var editPaste:NativeMenuItem = new NativeMenuItem("Paste", false);
 			var editSep2:NativeMenuItem = new NativeMenuItem("2", true);
 			var editSettings:NativeMenuItem = new NativeMenuItem("Preferences...", false);
 			
 			// build menu
 			NativeApplication.nativeApplication.menu = rootMenu;
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
			editMenuItem.submenu.addItem(editUndo);
			editMenuItem.submenu.addItem(editRedo);
			editMenuItem.submenu.addItem(editSep1);
			editMenuItem.submenu.addItem(editCut);
			editMenuItem.submenu.addItem(editCopy);
			editMenuItem.submenu.addItem(editPaste);
			editMenuItem.submenu.addItem(editSettings);
			
			// bind events
			fileNew.addEventListener(Event.SELECT, handleFileNew);
 			fileOpen.addEventListener(Event.SELECT, handleFileOpen);
 			fileClose.addEventListener(Event.SELECT, handleFileClose);
 			fileSave.addEventListener(Event.SELECT, handleFileSave);
 			fileSaveAs.addEventListener(Event.SELECT, handleFileSaveAs);
 			fileExit.addEventListener(Event.SELECT, handleFileExit);

			editUndo.addEventListener(Event.SELECT, handleEditUndo);
 			editRedo.addEventListener(Event.SELECT, handleEditRedo);
 			editCut.addEventListener(Event.SELECT, handleEditCut);
 			editCopy.addEventListener(Event.SELECT, handleEditCopy);
 			editPaste.addEventListener(Event.SELECT, handleEditPaste);
 			editSettings.addEventListener(Event.SELECT, handleEditSettings);
 			
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
 			
 			editUndo.keyEquivalent = "z";
 			editUndo.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editRedo.keyEquivalent = "y";
 			editRedo.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editCut.keyEquivalent = "x";
 			editCut.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editCopy.keyEquivalent = "c";
 			editCopy.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editPaste.keyEquivalent = "v";
 			editPaste.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			editSettings.keyEquivalent = ",";
 			editSettings.keyEquivalentModifiers = (isMac) ? [Keyboard.COMMAND] : [Keyboard.CONTROL];
 			
		}
		
		/* Handle Flipping Between View States */
		
		public function toggleDisplayState():void
		{
			if(!isFullScreen)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				menuBar.visible = false;
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
			
		}
		
		public function handleSettingUpdate(event:Event):void
		{
			
		}
		
		public function handleFileNew(event:Event):void
		{
			newFile();
		}
		
		public function handleFileOpen(event:Event):void
		{
			openFile();
		}
		
		public function handleFileClose(event:Event):void
		{
			
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
			NativeApplication.nativeApplication.exit();
		}
		
		public function handleEditUndo(event:Event):void
		{
			Alert.show("For some reason, undo and redo aren't working");
			NativeApplication.nativeApplication.undo();
		}
		
		public function handleEditRedo(event:Event):void
		{
			Alert.show("For some reason, undo and redo aren't working");
			NativeApplication.nativeApplication.redo();
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
		
		public function handleEditSettings(event:Event):void
		{
			processCurrentSettings();
			
			configDialog = PopUpManager.createPopUp(this, ConfigurationDialog, true) as ConfigurationDialog;
			configDialog["btnOk"].addEventListener("click", handleConfigDialogOk);
			
			configDialog.config = config;
			
			configDialog.updateFields();
			
			PopUpManager.centerPopUp(configDialog);
		}
		
		public function handleKeyDown(event:KeyboardEvent):void
		{
			/* 	we use the isDirty toggle to prevent automatically flipping back to fullscreen
				since the escape out of full screen is handled by the flash player, not us */
			if (event.charCode == 27 && !isFullScreen && !isDirty)
			{
				toggleDisplayState();
			}
			else if (event.charCode == 27 && !isFullScreen && isDirty)
			{
				isDirty = false;
			}
			else if ((event.commandKey || event.ctrlKey) && event.keyCode == 83)
			{
				Alert.show('save');
			}
		}
		
		public function handleFullScreen(event:FullScreenEvent):void
		{
			isFullScreen = event.fullScreen;
			isDirty = true;
			
			if (isFullScreen)
			{
				menuBar.visible = false;
			}
			else
			{
				menuBar.visible = true;
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
					newFile();
					break;
					
				case 'Open':
					openFile();
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
			
			applySettings();
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
			stream = new FileStream();
			stream.openAsync(currentFile, FileMode.READ);
			stream.addEventListener(Event.COMPLETE, fileReadHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, readIOErrorHandler);
			dataChanged = false;
			title = "Text Editor - " + currentFile.name;
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
			var lineEndPattern:RegExp = new RegExp(File.lineEnding, "g");
			str = str.replace(lineEndPattern, "\n");
			content.text = str; 
			stream.close();
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
				dataChanged = false;
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
			title = "Text Editor - " + currentFile.name;
			saveFile();
			dataChanged = false;
			currentFile.removeEventListener(Event.SELECT, saveAsFileSelected);
		}
		
		/**
		 * Called when the user clicks the "New" button. Initializes the state, with an undefined File object and a
		 * blank text entry field.
		 */
		private function newFile():void
		{
			currentFile = undefined;
			dataChanged = false;
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
	}
}