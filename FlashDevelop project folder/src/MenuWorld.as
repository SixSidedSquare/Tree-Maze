package  
{
	import net.flashpunk.graphics.Text;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.FP;
	import GameSettings;
	
	/**
	 * ...
	 * @author Six
	 */
	public class MenuWorld extends World
	{
		// World variables defined here
		
		public function MenuWorld() 
		{
			addGraphic(new Text("Click to start.", 60, 120));
			trace("MenuWorld created");
		}
		
		override public function update():void
		{
			if (Input.mousePressed)
			{
				FP.world = new GameWorld();
			}
			super.update();
		}
		
	}

}