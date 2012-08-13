package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author Six
	 */
	public class Main extends Engine 
	{
		
		public function Main():void 
		{
			super(240, 240, 60);
			FP.world = new MenuWorld();
			FP.screen.scale = 2.0;
			//FP.console.enable();
		}
		
	}	
}