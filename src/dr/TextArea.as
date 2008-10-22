package dr
{
	import flash.events.*;
	
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.controls.textClasses.TextRange;
	import mx.core.UITextField;
	import mx.events.FlexEvent;

	
	public class TextArea extends mx.controls.TextArea
	{
		public var tabsToSpaces:Boolean;
		public var tabsToSpacesCount:int;
		public var autoIndent:Boolean;
		
		
		public function TextArea()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, init);
		}
		
		private function init(event:Event):void
		{
			initListeners();
		}

		private function initListeners():void
		{
			this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if(event.charCode == 9)
			{
				event.preventDefault(); // capture focus
				handleTab();
			}
			else if(event.charCode == 13 && autoIndent)
			{
				event.preventDefault();
				handleAutoIndent();
			}
		}
		
		private function handleAutoIndent():void
		{
			var pStart:int = this.textField.getFirstCharInParagraph(this.textField.caretIndex); 
			
			var buffer:String = ''; 
			
			// build buffer, tab = 9; space = 32
			var charCode:int;
			var charTab:int = 9;
			var charSpace:int = 32;
			var char:String = '';
			do
			{
				buffer += char; 
				char = this.text.charAt(pStart);
				charCode = char.charCodeAt(0);
				
				pStart++;
			}
			while (charCode == charTab || charCode == charSpace); 
			
			var range:TextRange = new TextRange(this,true,this.textField.caretIndex,this.textField.caretIndex);
			range.text = '\n';
			if(buffer.length>0)
			{
				range.text = '\n'+buffer;
			}
			this.setSelection(this.textField.caretIndex, this.textField.caretIndex);
		}
		
		private function handleTab():void
		{
			var range:TextRange = new TextRange(this,true,this.selectionBeginIndex,this.selectionEndIndex);
				
			if(tabsToSpaces)
			{
				var count:int = (tabsToSpacesCount) ? tabsToSpacesCount : 3;
				var buffer:String = '';
				for (var i:int = 0; i < count; i++)
				{
				    buffer += ' ';
				}
				range.text = buffer;
			}
			else
			{
				range.text = '\t';
			}
			
			this.setSelection(this.selectionEndIndex, this.selectionEndIndex);
		}
	}
}