package  
{
	import adobe.utils.CustomActions;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Draw;
	/**
	 * ...
	 * @author Six
	 */
	public class BetterHallwayTile
	{
		// vectors for keeping track of which sides have exits, and the references to those tiles
		public var exitBooleans:Vector.<Boolean>;
		public var exitReferences:Vector.<BetterHallwayTile>;
		
		public var parentTile:BetterHallwayTile;
		public var parentDirection:Number;
		
		// flag for if this is the entry tile?
		public var isHomeTile:Boolean;
		
		// count of total exits
		public var numberOfExits:Number;
		
		// flag for if the player is currently in the tile
		public var playerInTile:Boolean;
		
		// number to represent what shape the tile is
		public var tileShape:Number;
		
		// count saying how far a tile is from the entry
		public var tilesToHome:Number;
		
		// list of entities in the tile
		public var entitiesInTile:Vector.<Entity>;
		
		// drop off in opacity between tiles
		private var opacityDrop:Number = 0.27;
		
		// on declaration, should initialize things, then methods are called to set possible sides, and actually connect them
		public function BetterHallwayTile(_parentTile:BetterHallwayTile, enteredFrom:Number, _isHomeTile:Boolean = false)
		{
			initializeThings();
			isHomeTile = _isHomeTile;
			
			parentTile = _parentTile;
			parentDirection = enteredFrom;
			
			if ( isHomeTile)
			{
				
			}
			else
			{
				
				exitReferences[parentDirection] = parentTile;
				exitBooleans[parentDirection] = true;
				
				parentTile.connectToTile(this, (parentDirection + 2) % 4);
				numberOfExits++;
				
			}
			
		}
		
		public function renderTile(xLocation:Number, yLocation:Number, opacity:Number = 1, enteredRenderDirection:Number = -1, renderedDistance:Number = 0 ):void
		{
			
			// render the player with the right opacity
			if (playerInTile)
			{				
				GameSettings.playerSprite.alpha = 1 - renderedDistance * opacityDrop;
				GameSettings.playerSprite.color = 0x010100 * int(0xFF * GameSettings.playerSprite.alpha) + 0xFF;
				GameSettings.playerSprite.render(FP.buffer, new Point(xLocation + 8, yLocation + 6), new Point());
				
				if (enteredRenderDirection == -1 && GameSettings.tileOffsetTweener.percent < 1)
				{
					opacity = 1 - (1 - GameSettings.tileOffsetTweener.percent) * opacityDrop;
				}
			}
			
			// render this tile at the given x, y
			var drawColour:Number = 0xFFFFFF;
			if (isHomeTile)
				drawColour = 0xFF8888;
			//Draw.rect(xLocation, yLocation, tileWidth, tileHeight, drawColour, opacity);
			GameSettings.tileImages.frame = tileShape;
			GameSettings.tileImages.color = drawColour;
			GameSettings.tileImages.alpha = opacity;
			GameSettings.tileImages.render(FP.buffer, new Point(xLocation + GameSettings.tileXOffset, yLocation + GameSettings.tileYOffset), new Point());
			
			
			
			// call the tile rendering on every tile except the one entered from, checking opacities won't be <= 0
			for (var newDirection:Number = GameSettings.NORTH; newDirection < 4; newDirection++)
			{
				// check that the new direction wasn't the tile that called this render, that there is a tile in that direction
				if (newDirection != enteredRenderDirection && exitReferences[newDirection] != null)
				{
					if (1 - renderedDistance * opacityDrop > 0)
					{
						var xOffset:Number = 0;
						var yOffset:Number = 0;
						switch(newDirection)
						{
							case GameSettings.NORTH:
							yOffset -= GameSettings.tileHeight;
							break;
							
							case GameSettings.EAST:
							xOffset += GameSettings.tileWidth
							break;
							
							case GameSettings.SOUTH:
							yOffset += GameSettings.tileHeight;
							break;
							
							case GameSettings.WEST:
							xOffset -= GameSettings.tileWidth
							break;
							
							default:
							//trace("None of the above were met");
						}
						// probably move this to the switch, with opacity drop off based on turns or straights
						if ( enteredRenderDirection == -1 && newDirection == (GameSettings.movingDirection + 2) % 4)
						{
							exitReferences[newDirection].renderTile(xLocation + xOffset, yLocation + yOffset, 1 + (1 - GameSettings.tileOffsetTweener.percent) * opacityDrop - opacityDrop, (newDirection + 2) % 4, renderedDistance + 1);;
						}
						else
						{
							exitReferences[newDirection].renderTile(xLocation + xOffset, yLocation + yOffset, opacity - opacityDrop, (newDirection + 2) % 4, renderedDistance + 1);
						}
					}
				}
			}
			
		}
		
		private function initializeThings():void
		{
			//make the directional vectors initialized to length 4
			//make sure this is the only use of .push!
			exitBooleans = new Vector.<Boolean>();
			exitBooleans.push(false); exitBooleans.push(false); exitBooleans.push(false); exitBooleans.push(false); 
			
			exitReferences = new Vector.<BetterHallwayTile>()
			exitReferences.push(null); exitReferences.push(null); exitReferences.push(null); exitReferences.push(null); 
			
			numberOfExits = 0;
			
			playerInTile = false;
		}
		
		public function openExitInDirection(newDirection:Number):HallwayTileConnector
		{
			exitBooleans[newDirection] = true;
			numberOfExits++;
			
			return new HallwayTileConnector(this, newDirection)
		}
		
		public function makeRandomNumberOfExitsTile():Vector.<HallwayTileConnector>
		{
			// THIS LARGELY DEFINES BRANCHYNESS OF MAZE
			// first choose the random number of exits, between 1 and 3 (as there is already the entry)
			//var numberOfExitsToAdd:Number = FP.rand(2) + 1;
			//var numberOfExitsToAdd:Number = FP.rand(FP.rand(3)) + 1;
			
			var numberOfExitsToAdd:Number = GameSettings.tileChoiceArray[FP.rand(GameSettings.tileChoiceArray.length)];
			//trace("Adding " + numberOfExitsToAdd + " exits.");
			
			// if the total will be four, then just make it a 4 way
			if (numberOfExitsToAdd == 3) return makeFourWayTile(); // 4 total
			
			
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			// add the first onto one of the random empty 3
			var newDirection:Number = (parentDirection + 1 + FP.rand(3)) % 4;
			returnVector.push(openExitInDirection(newDirection));
			
			if (numberOfExitsToAdd == 2) // 3 total
			{
				while (exitBooleans[newDirection]) newDirection = (parentDirection + 1 + FP.rand(3)) % 4; // BAAAAD MEDICINE.
				
				returnVector.push(openExitInDirection(newDirection));
			}
			
			return returnVector;
		}
		
		public function makeHomeTile():Vector.<HallwayTileConnector>
		{
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			returnVector.push(openExitInDirection(GameSettings.SOUTH));
			exitBooleans[parentDirection] = false;
			playerInTile = true;
			
			return returnVector;
		}
		
		public function makeRightTurnTile():Vector.<HallwayTileConnector>
		{
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			returnVector.push(openExitInDirection((parentDirection + 1) % 4));
			
			return returnVector;
		}
		
		public function makeStraightTile():Vector.<HallwayTileConnector>
		{
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			returnVector.push(openExitInDirection((parentDirection + 2) % 4));
			
			return returnVector;
		}
		
		public function makeFourWayTile():Vector.<HallwayTileConnector>
		{
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			for (var offset:Number = 1; offset < 4; offset++)
			{
				returnVector.push(openExitInDirection((parentDirection + offset) % 4));
			}
			
			return returnVector;
		}
		
		public function makeTJunctionTile():Vector.<HallwayTileConnector>
		{
			var returnVector:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			
			returnVector.push(openExitInDirection((parentDirection + 1) % 4));
			returnVector.push(openExitInDirection((parentDirection + 3) % 4));
			
			return returnVector;			
		}
		
		public function connectToTile(toConnectTo:BetterHallwayTile, direction:Number):void
		{
			// catch if the tile in said direction is already set
			if ( exitReferences[direction] != null ) throw new Error("Tried attaching tile where a tile is already attached");
			// catch if there is not meant to be an exit in that direction
			if ( !exitBooleans[direction] ) throw new Error("Tried attaching tile where there is no exit");
			
			//seems safe to attach
			exitReferences[direction] = toConnectTo;
			
			//if ( this == toConnectTo) trace("Tile connected to itself! Awesome!");
			
			// check if all exits are filled, and if so set the shape value
			if (checkNumberOfUnfilledExits() == 0)
			{
				tileShape = GameSettings.getShapeNumber(exitBooleans);
			}
		}
		
		public function checkNumberOfUnfilledExits():Number
		{
			var unfilledExits:Number = 0;
			
			for (var i:Number = 0; i < 4; i++)
			{
				if (exitBooleans[i] && exitReferences[i] == null) unfilledExits++; // for every side which is true for having an exit, but has a null reference, add to count
			}
			
			return unfilledExits;
		}
		
	}

}