package  
{
	import net.flashpunk.FP;
	
	/**d
	 * ...
	 * @author Six
	 */
	public class BetterTreeMaze
	{
		public var baseNode:BetterHallwayTile;
		private var loopCreationChance:Number = 0.5; // probability that a loop is created during tunneling
		private var fewestExitsToBeAbleToCreateLoop:Number = 4;
		private var totalNumberOfTiles:Number;
		
		
		public function BetterTreeMaze() 
		{
			
		}
		
		
		public function makeMaze(limitingSize:Number = 10, loopingChance:Number = 0.5):void
		{
			
			// start at base node, 
			//  add on a four way,
			//  fill out breadth first
			
			totalNumberOfTiles = 0;
			loopCreationChance = loopingChance;
			var tileNumberToBreakLoopOn:Number = limitingSize;
			
			// list to keep track of all current unfinished exits
			var currentFreeExits:Vector.<HallwayTileConnector> = new Vector.<HallwayTileConnector>();
			// lists to keep track of different directional unfinished exits
			var currentFreeDirectionalExits:Vector.<Vector.<HallwayTileConnector>> = new Vector.<Vector.<HallwayTileConnector>>();
			currentFreeDirectionalExits.push(new Vector.<HallwayTileConnector>());
			currentFreeDirectionalExits.push(new Vector.<HallwayTileConnector>());
			currentFreeDirectionalExits.push(new Vector.<HallwayTileConnector>());
			currentFreeDirectionalExits.push(new Vector.<HallwayTileConnector>());
			
			// make the base node
			baseNode = new BetterHallwayTile(null, GameSettings.NORTH, true);
			baseNode.makeHomeTile(); // make it the base tile
			totalNumberOfTiles++;
			
			// make a 4 way tile, connect it to the base node and grab the exit connectors
			var newTile:BetterHallwayTile = new BetterHallwayTile(baseNode, GameSettings.NORTH);
			var newConnections:Vector.<HallwayTileConnector> = newTile.makeFourWayTile();
			totalNumberOfTiles++;
			
			// put the new connections into the free lists
			for each(var connection:HallwayTileConnector in newConnections) 
			{
				currentFreeExits.push(connection);
				currentFreeDirectionalExits[connection.direction].push(connection);
			}
			
			// start up the loop to get to the limiting size
			while (totalNumberOfTiles < tileNumberToBreakLoopOn)
			{
				// pick a random loose exit
				var randomConnectionIndex:Number = FP.rand(currentFreeExits.length);
				var connectionToUse:HallwayTileConnector = currentFreeExits[randomConnectionIndex];
				var directionalIndex:Number = currentFreeDirectionalExits[connectionToUse.direction].indexOf(connectionToUse);
				
				// remove picked exit from the lists
				currentFreeExits.splice(randomConnectionIndex, 1);
				currentFreeDirectionalExits[connectionToUse.direction].splice(directionalIndex, 1);
				
				//if there are more than 3 exits at the moment, take a percentage chance of creating a loop.
				if (currentFreeExits.length > fewestExitsToBeAbleToCreateLoop && FP.random < loopCreationChance)
				{
					//would love to method this, but needs lots of the local vars, would be annoying to pass them all
					//createALoop();
					
					//first check if there is anything this node can connect to
					// while there are no opposite nodes in the lists of exits, add right turns until there is
					while (currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4].length == 0)
					{
						// add right anlge
						newTile = new BetterHallwayTile(connectionToUse.fromHallway, (connectionToUse.direction + 2) % 4);
						newConnections = newTile.makeRightTurnTile();
						totalNumberOfTiles++;
						
						//don't bother to add new connections to the lists, instead just change the connection to use variable
						connectionToUse = newConnections[0];
						//trace("Turned Right");
					}
					
					//now we should have a node in the lists to connect to
					// pick a random tile to connect to
					var toAttachDirectionalIndex:Number = FP.rand(currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4].length);
					var connectionToAttachTo:HallwayTileConnector = currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4][toAttachDirectionalIndex];
					var toAttachToIndex:Number = currentFreeExits.indexOf(connectionToAttachTo);
					
					//connect the two halls together
					connectionToUse.fromHallway.connectToTile(connectionToAttachTo.fromHallway, connectionToUse.direction);
					connectionToAttachTo.fromHallway.connectToTile(connectionToUse.fromHallway, connectionToAttachTo.direction);
					
					//and remove the attached tiles exit from the lists
					currentFreeExits.splice(toAttachToIndex, 1);
					currentFreeDirectionalExits[connectionToAttachTo.direction].splice(toAttachDirectionalIndex, 1);
					
					//trace("Loop created");
					
				}
				else // otherwise just addd a normal new tile
				{
					newTile = new BetterHallwayTile(connectionToUse.fromHallway, (connectionToUse.direction + 2) % 4);
					newConnections = newTile.makeRandomNumberOfExitsTile();
					totalNumberOfTiles++;
					
					//add new connections to the lists				
					for each(connection in newConnections) 
					{
						currentFreeExits.push(connection);
						currentFreeDirectionalExits[connection.direction].push(connection);
					}
				}
				//trace("Loose ends: " + currentFreeExits.length );
			}
			//trace("Loose ends: " + currentFreeExits.length );
			trace("Main generation complete, tieing up " + currentFreeExits.length + " loose ends");
			
			// clean up loose exits by tieing them together
			//first, if there is an odd number of loose ends, make one of them break into two	
			if (currentFreeExits.length % 2 == 1)
			{
				// grab the first free exit
				connectionToUse = currentFreeExits[0];
				directionalIndex = currentFreeDirectionalExits[connectionToUse.direction].indexOf(connectionToUse);
				// remove from lists
				currentFreeExits.splice(0, 1);
				currentFreeDirectionalExits[connectionToUse.direction].splice(directionalIndex, 1);
				
				// make a new tile, then make it a T junction
				newTile = new BetterHallwayTile(connectionToUse.fromHallway, (connectionToUse.direction + 2) % 4);
				newConnections = newTile.makeTJunctionTile();
				totalNumberOfTiles++;
				
				// put the new connections into the free lists
				for each(connection in newConnections) 
				{
					currentFreeExits.push(connection);
					currentFreeDirectionalExits[connection.direction].push(connection);
				}
				//trace("T Junction created");
			}
			
			//next, while there is still a loose end dangling, tie it to another
			while (currentFreeExits.length > 1)
			{
				//grab the first free exit
				connectionToUse = currentFreeExits[0];
				directionalIndex = currentFreeDirectionalExits[connectionToUse.direction].indexOf(connectionToUse);
				// remove from lists
				currentFreeExits.splice(0, 1);
				currentFreeDirectionalExits[connectionToUse.direction].splice(directionalIndex, 1);
				
				// ----------------------------
				// ----repeated from above-----
				// while there are no opposite nodes in the lists of exits, add right turns until there is
				while (currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4].length == 0)
				{
					// add right anlge
					newTile = new BetterHallwayTile(connectionToUse.fromHallway, (connectionToUse.direction + 2) % 4);
					newConnections = newTile.makeRightTurnTile();
					totalNumberOfTiles++;
					
					//don't bother to add new connections to the lists, instead just change the connection to use variable
					connectionToUse = newConnections[0];
					//trace("Turned Right");
				}
				
				//now we should have a node in the lists to connect to
				// pick a random tile to connect to
				toAttachDirectionalIndex = FP.rand(currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4].length);
				connectionToAttachTo = currentFreeDirectionalExits[(connectionToUse.direction + 2) % 4][toAttachDirectionalIndex];
				toAttachToIndex = currentFreeExits.indexOf(connectionToAttachTo);
				
				//connect the two halls together
				connectionToUse.fromHallway.connectToTile(connectionToAttachTo.fromHallway, connectionToUse.direction);
				connectionToAttachTo.fromHallway.connectToTile(connectionToUse.fromHallway, connectionToAttachTo.direction);
				
				//and remove the attached tiles exit from the lists
				currentFreeExits.splice(toAttachToIndex, 1);
				currentFreeDirectionalExits[connectionToAttachTo.direction].splice(toAttachDirectionalIndex, 1);
				
				//trace("Loop created");
				
				
				// ----repeated from above-----
				// ----------------------------
				
			}
			
			//step through whole graph again and give tiles their distance from the root
			
			//trace("Loose ends final: " + currentFreeExits.length);
			trace("Tile number final: " + totalNumberOfTiles);
			
		}
		
		private function createALoop():void
		{
			//*sadface*
		}
	}

}