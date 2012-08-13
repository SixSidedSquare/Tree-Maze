package  
{
	import flash.geom.Point;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.FP;
	import GameSettings;
	
	/**
	 * ...
	 * @author Six
	 */
	public class GameWorld extends World
	{
		// World variables defined here
		private var hallwayTree:BetterTreeMaze;
		private var playerLocation:BetterHallwayTile;
		
		private var currentlyMoving:Boolean;
		private var tileSlideTime:Number = 0.15;

		public function GameWorld() 
		{
			GameSettings.setTileImage();
			GameSettings.setPlayerImage();
			currentlyMoving = false;
			
			GameSettings.tileOffsetTweener = new VarTween(doneMoving);
			addTween(GameSettings.tileOffsetTweener);
			
			trace("GameWorld created");
			makeNewMaze(10);
			trace("Maze created ");
		}
		
		override public function render():void 
		{
			// first render maze and contents. Need to make sure to override all of the entities update and renders
			// Rendering is recurrisve, so the tile called renders all the tiles it is connected to.
			playerLocation.renderTile(FP.halfWidth - 15, FP.halfHeight - 15);
			
			
			super.render();
		}
		
		override public function update():void
		{
			if (Input.pressed(Key.DIGIT_1))
			{
				makeNewMaze(10);
			}
			else if (Input.pressed(Key.DIGIT_2))
			{
				makeNewMaze(25);
			}
			else if (Input.pressed(Key.DIGIT_3))
			{
				makeNewMaze(50, 0.6);
			}
			else if (Input.pressed(Key.DIGIT_4))
			{
				makeNewMaze(10000, 0.6);
			}
			
			if (currentlyMoving)
			{
				// Could chain up moves here, but this works fine for now
			}
			else
			{
				// Handle the player movement.  This could be condensed and made 'prettier', but is easier to read expanded out like this
				if (Input.pressed(Key.UP))
				{
					if (playerLocation.exitBooleans[GameSettings.NORTH])
					{
						GameSettings.movingDirection = GameSettings.NORTH;
						playerLocation.playerInTile = false;
						playerLocation = playerLocation.exitReferences[GameSettings.NORTH];
						playerLocation.playerInTile = true;
						GameSettings.spriteStepper = (GameSettings.spriteStepper + 1) % 4;
						GameSettings.playerSprite.frame = 0 + GameSettings.spriteStepper;
						
						GameSettings.tileYOffset = -(GameSettings.tileHeight - 1);
						GameSettings.tileOffsetTweener.tween(GameSettings, "tileYOffset", 0, tileSlideTime, Ease.quadInOut);
						GameSettings.tileOffsetTweener.start();
						currentlyMoving = true;
					}
					else
					{
						GameSettings.spriteStepper = 0;
						GameSettings.playerSprite.frame = 0;
					}
				}
				else if (Input.pressed(Key.DOWN))
				{
					if (playerLocation.exitBooleans[GameSettings.SOUTH])
					{
						GameSettings.movingDirection = GameSettings.SOUTH;
						playerLocation.playerInTile = false;
						playerLocation = playerLocation.exitReferences[GameSettings.SOUTH];
						playerLocation.playerInTile = true;
						GameSettings.spriteStepper = (GameSettings.spriteStepper + 1) % 4;
						GameSettings.playerSprite.frame = 4 + GameSettings.spriteStepper;
						
						GameSettings.tileYOffset = GameSettings.tileHeight - 1;
						GameSettings.tileOffsetTweener.tween(GameSettings, "tileYOffset", 0, tileSlideTime, Ease.quadInOut);
						GameSettings.tileOffsetTweener.start();
						currentlyMoving = true;
					}
					else
					{
						GameSettings.spriteStepper = 0;
						GameSettings.playerSprite.frame = 4;
					}
				}
				else if (Input.pressed(Key.LEFT))
				{
					if (playerLocation.exitBooleans[GameSettings.WEST])
					{
						GameSettings.movingDirection = GameSettings.WEST;
						playerLocation.playerInTile = false;
						playerLocation = playerLocation.exitReferences[GameSettings.WEST];
						playerLocation.playerInTile = true;
						GameSettings.spriteStepper = (GameSettings.spriteStepper + 1) % 4;
						GameSettings.playerSprite.frame = 8 + GameSettings.spriteStepper;
						
						GameSettings.tileXOffset = -(GameSettings.tileWidth - 1);
						GameSettings.tileOffsetTweener.tween(GameSettings, "tileXOffset", 0, tileSlideTime, Ease.quadInOut);
						GameSettings.tileOffsetTweener.start();
						currentlyMoving = true;
					}
					else
					{
						GameSettings.spriteStepper = 0;
						GameSettings.playerSprite.frame = 8;
					}
				}
				else if (Input.pressed(Key.RIGHT))
				{
					if (playerLocation.exitBooleans[GameSettings.EAST])
					{
						GameSettings.movingDirection = GameSettings.EAST;
						playerLocation.playerInTile = false;
						playerLocation = playerLocation.exitReferences[GameSettings.EAST];
						playerLocation.playerInTile = true;
						GameSettings.spriteStepper = (GameSettings.spriteStepper + 1) % 4;
						GameSettings.playerSprite.frame = 12 + GameSettings.spriteStepper;
						
						GameSettings.tileXOffset = (GameSettings.tileWidth - 1);
						GameSettings.tileOffsetTweener.tween(GameSettings, "tileXOffset", 0, tileSlideTime, Ease.quadInOut);
						GameSettings.tileOffsetTweener.start();
						currentlyMoving = true;
					}
					else
					{
						GameSettings.spriteStepper = 0;
						GameSettings.playerSprite.frame = 12;
					}
				}
			}
			super.update();
		}
		
		// Generate a new maze using the given size and value to define how common it is for tiles to link in non-eucildian ways
		public function makeNewMaze(size:Number = 10, loopiness:Number = 0.5):void
		{
			hallwayTree =  new BetterTreeMaze();
			hallwayTree.makeMaze(size, loopiness);
			playerLocation = hallwayTree.baseNode;
			
			GameSettings.spriteStepper = 0;
			GameSettings.playerSprite.frame = 4;
		}
		
		// Method for the movement tween to call on completion
		private function doneMoving():void
		{
			currentlyMoving = false;
		}
		
	}

}