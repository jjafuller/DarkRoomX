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
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	
	public class Menu
	{
		//private var target:dr.WindowedApplication;
		
		public function Menu()
		{
		}
		
		public static function build(menu:ArrayCollection, target:WindowedApplication):void
		{
			// Mac OS X
		   	if (NativeApplication.supportsMenu)
		   	{
		   		buildNativeApplicationMenu(menu, target);
		   	}
		    
		   	// Windows / Linux
		   	if (NativeWindow.supportsMenu)
		   	{
		   		//stage.nativeWindow.menu = rootMenu;		   		
		  	}
		}
		
		public static function buildNativeApplicationMenu(menu:ArrayCollection, target:WindowedApplication):void
		{
			NativeApplication.nativeApplication.menu = new NativeMenu();
			
			for each (var item:Object in menu)
			{
				var top:NativeMenuItem = NativeApplication.nativeApplication.menu.addSubmenu(new NativeMenu(), item.label);
				
				for each (var child:Object in item.children)
				{
					// build an item for child
					var leaf:NativeMenuItem = new NativeMenuItem(child.label, ((child.separator) ? child.separator : false));
					
					// add child to menu
					top.submenu.addItem(leaf);
					
					if (child.separator != true)
					{
						// add listener
						leaf.addEventListener(Event.SELECT, child.action);
						
						// add shortcuts
						var keyEq:String = (child.keyEquivalent == Keyboard.COMMA) ? ',' : String.fromCharCode(child.keyEquivalent).toLowerCase();
						leaf.keyEquivalent = keyEq;
						leaf.keyEquivalentModifiers = child.keyEquivalentModifiers;
					}	
				}
			}
			
			/*
			// is mac?
			//var isMac:Boolean = (Capabilities.os.substr(0, 3).toLowerCase() == "mac") ? true : false;
			
			// file menu options
			var tmp:NativeMenuItem;
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
		   		//stage.nativeWindow.menu = rootMenu;		   		
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
 			
 			*/
		}
		
		public static function buildPsuedoMenu(menu:ArrayCollection, target:WindowedApplication):void
		{
			
		}
	}
}