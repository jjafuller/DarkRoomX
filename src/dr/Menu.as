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
	import mx.events.MenuEvent;
	
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
		   	
		   	buildPsuedoMenu(menu, target);
		    
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
		}
		
		public static function buildPsuedoMenu(menu:ArrayCollection, target:WindowedApplication):void
		{
			var data:ArrayCollection = new ArrayCollection();
			
			for each (var item:Object in menu)
			{
				var children:ArrayCollection = new ArrayCollection();
				
				for each (var child:Object in item.children)
				{
					var leaf:Object;
					
					if(child.separator == true)
					{
						leaf = {type:'separator'};
					}
					else
					{
						leaf = {label:child.label};
					}
					
					if (child.separator != true)
					{
						// add listener
						//leaf.addEventListener(Event.SELECT, child.action);
						
						// add shortcuts
						//var keyEq:String = (child.keyEquivalent == Keyboard.COMMA) ? ',' : String.fromCharCode(child.keyEquivalent).toLowerCase();
						//leaf.keyEquivalent = keyEq;
						//leaf.keyEquivalentModifiers = child.keyEquivalentModifiers;
					}
					
					children.source.push(leaf);
				}
				
				data.source.push({label: item.label, children: children});
				
			}
			
			target.virtualMenu.dataProvider = data;
			target.virtualMenu.addEventListener(MenuEvent.ITEM_CLICK, target.handleMenuItemClick);
		}
		
		
	}
}