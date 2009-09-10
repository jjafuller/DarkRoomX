package dr
{
	import flash.filesystem.File;
	
	public class Configuration extends Object
	{
		private var settingsFile:File;
		
		public var settings:Object;
		
		public function Configuration(pSettingsFile:File)
		{
			settingsFile = pSettingsFile;
			
			settings = new Object();
			 
			//readXML();
		}

		
		
	}
}