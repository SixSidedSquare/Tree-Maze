package  
{
	/**
	 * ...
	 * @author Six
	 * 
	 * class only used in the construction of a maze, to keep track of loose exits
	 */
	public class HallwayTileConnector
	{
		public var fromHallway:BetterHallwayTile;
		public var direction:Number; // for north, east, south or west, from GameSettings numbers
		
		public function HallwayTileConnector(_fromHallway:BetterHallwayTile, _direction:Number) 
		{
			fromHallway = _fromHallway;
			direction = _direction;
		}
		
	}

}