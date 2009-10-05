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
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.controls.textClasses.TextRange;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class FindAndReplaceWindow extends mx.containers.TitleWindow
	{
		// controls
		public var txtFind:TextInput;
		public var txtReplace:TextInput;
		public var chkIgnoreCase:CheckBox;
		public var chkWrap:CheckBox;
		public var chkRegularExpression:CheckBox;
		public var btnFind:Button;
		public var btnReplace:Button;
		public var btnFindReplace:Button;
		public var btnReplaceAll:Button;
		public var lblStatus:Label;
		
		// variables
		[Bindable]
		public var content:dr.TextArea;
		
		private var pattern:RegExp;
		private var flags:String;
		private var match:String;
		private var beginIndex:int;
		private var endIndex:int;
		private var selection:TextRange;
		private var searchWrapped:Boolean;
		
		public function FindAndReplaceWindow()
		{
			// global events
			this.addEventListener(CloseEvent.CLOSE, handleClose);
		}
		
		public function init():void
		{
			searchWrapped = false;
			
			initListeners();
			
			this.defaultButton = btnFind;
			txtFind.setFocus();
		}
		
		public function initListeners():void
		{
			// buttons
			btnFind.addEventListener(MouseEvent.CLICK, handleFindClick);
			btnReplace.addEventListener(MouseEvent.CLICK, handleReplaceClick);
			btnFindReplace.addEventListener(MouseEvent.CLICK, handleFindReplaceClick);
			btnReplaceAll.addEventListener(MouseEvent.CLICK, handleReplaceAllClick);
		}
		
		private function handleClose(event:CloseEvent):void
		{
			removePopup();
		}
		
		private function handleFindClick(event:MouseEvent):void
		{
			find();
		}
		
		private function handleReplaceClick(event:MouseEvent):void
		{
			replace();	
		}
		
		private function handleFindReplaceClick(event:MouseEvent):void
		{
			replace();
			find();
		}
		
		private function handleReplaceAllClick(event:MouseEvent):void
		{
			replaceAll();
		}
		
		private function find():void
		{
			lblStatus.text = (searchWrapped) ? lblStatus.text : '';
			
			if(txtFind.text.length > 0)
			{
				flags = "g" + ((chkIgnoreCase.selected) ? "i" : "");
				pattern = new RegExp(((chkRegularExpression.selected) ? txtFind.text : this.escape(txtFind.text)), flags); 
				
				switch(true)
				{
					case (searchWrapped):
						pattern.lastIndex = 0;
						break;
						
					case (content.selectionEndIndex > 0):
						pattern.lastIndex = content.selectionEndIndex;
						break;
						
					default:
						pattern.lastIndex = content.getCaretPosition();
				}
				
				match = pattern.exec(content.text);
				if(match)
				{
					endIndex = pattern.lastIndex;
					beginIndex = endIndex - match.length;
				
					content.setSelection(beginIndex, endIndex);
				}
				else
				{
					if(chkWrap.selected && !searchWrapped)
					{
						searchWrapped = true;
						lblStatus.text = "Restarting Search at Top";
						find();
					}
					else
					{
						lblStatus.text = "No Matches Found";	
					}
				}
				
				searchWrapped = false;
			}
		}
		
		private function replace():void
		{
			if(content.selectionBeginIndex != content.selectionEndIndex)
			{
				selection = new TextRange(content, true);
				selection.text = txtReplace.text;
				content.isDirty = true;
			}
		}
		
		private function replaceAll():void
		{
			lblStatus.text = '';
			
			if(txtFind.text.length > 0)
			{
				flags = "g" + ((chkIgnoreCase.selected) ? "i" : "");
				pattern = new RegExp(((chkRegularExpression.selected) ? txtFind.text : this.escape(txtFind.text)), flags); 
				
				var count:int = content.text.match(pattern).length;
				
				if (count > 0)
				{
					content.text = content.text.replace(pattern, txtReplace.text);
					content.isDirty = true;
					
					lblStatus.text = count + " Occurances Replaced";
				}
				else
				{
					lblStatus.text = "No Matches Found";
				}	
			}
		}
		
		private function escape(str:String):String
		{
			// \, *, +, ?, |, {, [, (,), ^, $,., #, and white space
			var operators:Array = new Array("\\", '*', '+', '?', '|', '{', '[', '(', ')', '^', '$', '.', '#', ' ', "\n", "\t");
			var escaped:String = '';
			var char:String = '';
			
			for (var i:int = 0; i < str.length; i++)
			{
				char = str.charAt(i);
				escaped += ((operators.indexOf(char) > -1) ? '\\' : '') + char;
			}
			
			return escaped;
		}
		
		public function removePopup():void
		{
			PopUpManager.removePopUp(this);
		}


		/*
		
		var pattern:RegExp = /\w\d/g; 
		var str:String = "a1 b2 c3 d4";
		pattern.lastIndex = 2; 
		trace(pattern.exec(str)); // b2
		trace(pattern.lastIndex); // 5
		trace(pattern.exec(str)); // c3
		trace(pattern.lastIndex); // 8
		trace(pattern.exec(str)); // d4
		trace(pattern.lastIndex); // 11
		trace(pattern.exec(str)); // null
		
		*/
	}
}