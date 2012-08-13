package  
{
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.VarTween;
	
	/**
	 * ...
	 * @author Six
	 */
	public class GameSettings
	{
		// Giving NSEW numbers so they can be used to index arrays an be more readable
		public static const NORTH:Number = 0;
		public static const EAST:Number = 1;
		public static const SOUTH:Number = 2;
		public static const WEST:Number = 3;
		
		
		// Constants defining all the different types of hallways tiles for easy array indexing
		public static const N_E:Number = 0;		// L
		public static const E_S:Number = 1;		// r
		public static const S_W:Number = 2;		// 7
		public static const N_W:Number = 3;		// j
		
		public static const N_S:Number = 4;		// |
		public static const E_W:Number = 5;		// -
		
		public static const N_E_W:Number = 6;	// _|_
		public static const N_E_S:Number = 7;	//  |-
		public static const E_S_W:Number = 8;	// 	T
		public static const N_S_W:Number = 9;	// -|
		
		public static const N_E_S_W:Number = 10;// +
		
		public static const HOME_SHAPE:Number = 11;// i
		
		[Embed(source = '/images/simpleTiles.png')]
		private static const TILE_IMAGE:Class;
		public static var tileImages:Spritemap;
		
		
		[Embed(source = 'images/simpleSprite.png')]
		private static const PLAYER_IMAGE:Class;
		public static var playerSprite:Spritemap;
		public static var spriteStepper:Number = 0;
		
		// width and height in pixels
		public static var tileWidth:Number = 30;
		public static var tileHeight:Number = 30;
		
		public static var tileChoiceArray:Vector.<Number> = new <Number>[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3 ];
		//public static var tileChoiceArray:Array = new Array(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3 );
		
		public static var tileXOffset:Number = 0;
		public static var tileYOffset:Number = 0;
		public static var tileOffsetTweener:VarTween;
		public static var previousTile:BetterHallwayTile;
		public static var movingDirection:Number = -1;
		
		public static function setTileImage():void
		{
			tileImages = new Spritemap(TILE_IMAGE, 30, 30);
			tileImages.centerOrigin();
		}
		
		public static function setPlayerImage():void
		{
			playerSprite = new Spritemap(PLAYER_IMAGE, 13, 19);
			playerSprite.centerOrigin();
		}
		
		public static function getShapeNumber(exitBooleans:Vector.<Boolean>):Number
		{
			if ( exitBooleans[0] &&  exitBooleans[1] &&  exitBooleans[2] &&  exitBooleans[3]) return N_E_S_W;
			
			if ( exitBooleans[0] &&  exitBooleans[1] && !exitBooleans[2] && !exitBooleans[3]) return N_E;
			if (!exitBooleans[0] &&  exitBooleans[1] &&  exitBooleans[2] && !exitBooleans[3]) return E_S;
			if (!exitBooleans[0] && !exitBooleans[1] &&  exitBooleans[2] &&  exitBooleans[3]) return S_W;
			if ( exitBooleans[0] && !exitBooleans[1] && !exitBooleans[2] &&  exitBooleans[3]) return N_W;
			
			if ( exitBooleans[0] && !exitBooleans[1] &&  exitBooleans[2] && !exitBooleans[3]) return N_S;
			if (!exitBooleans[0] &&  exitBooleans[1] && !exitBooleans[2] &&  exitBooleans[3]) return E_W;
			
			if ( exitBooleans[0] &&  exitBooleans[1] && !exitBooleans[2] &&  exitBooleans[3]) return N_E_W;
			if ( exitBooleans[0] &&  exitBooleans[1] &&  exitBooleans[2] && !exitBooleans[3]) return N_E_S;
			if (!exitBooleans[0] &&  exitBooleans[1] &&  exitBooleans[2] &&  exitBooleans[3]) return E_S_W;
			if ( exitBooleans[0] && !exitBooleans[1] &&  exitBooleans[2] &&  exitBooleans[3]) return N_S_W;
			
			if (!exitBooleans[0] && !exitBooleans[1] &&  exitBooleans[2] && !exitBooleans[3]) return HOME_SHAPE;
			
			throw new Error("Unallowed Shape");
			return -1; // Never gets here
		}
	}

}