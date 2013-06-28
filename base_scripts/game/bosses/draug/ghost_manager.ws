
class CGhostManager extends CEntity
{
	var allWaypoints : CNodesBinaryStorage;
	var activeNodes : array< CNode >;
	
	editable var enemyGhostTemplate : CEntityTemplate;
	var allGhosts : array< CEntity >;
	//var draug : CDraugBossBase;
	var npc : CNewNPC;
	var ghostEnemies : array<CNode>;
	var freeGhosts : array< CEntity >;
	var ghostsTotalNum, maxGhostEnemies : int;
	var safePos : Vector;
	var squareR1, squareR2, queryBounds : float;
	var queryBoundsMin, queryBoundsMax : Vector;
	editable var ghostTemplate : CEntityTemplate;
	
	default ghostsTotalNum = 100;
	default queryBounds = 20.0;
	default squareR1 = 64.0;
	default squareR2 = 64.0;
	default maxGhostEnemies = 5;
	
	
	// ------------------------------------------------------------
	// Manager management
	// ------------------------------------------------------------
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//StartManager();
		AddTimer('StartManager', 1.0, false );
	}
	
	event OnDestroyed()
	{
		EndManager();
	}
	
	final timer function StartManager( td : float )
	{
		CollectWaypoints();
		safePos = this.GetWorldPosition();
		safePos.Z -= 100.0;
		
		queryBoundsMin = Vector( -queryBounds, -queryBounds, 0 );
		queryBoundsMax = Vector( queryBounds, queryBounds, 0 );
		
		SpawnGhosts();
		
		AddTimer( 'UpdateManager', 0.1, true );
	}
	
	final function EndManager()
	{
		RemoveTimer( 'UpdateManager' );
		
	}
	
	final function CollectWaypoints()
	{
		var nodes : array< CNode >;
		var waypoint : CGhostWaypoint;
		var i, size : int;
		//draug = (CDraugBossBase)theGame.GetEntityByTag('draug_boss');
		theGame.GetNodesByTag( 'q208_ghost_wp', nodes );
		allWaypoints = new CNodesBinaryStorage in this;
		size = allWaypoints.InitializeWithNodes( nodes );
		
		size = nodes.Size();
		for ( i = 0; i < size; i += 1 )
		{
			waypoint = (CGhostWaypoint)nodes[i];
			if ( waypoint )
			{
				waypoint.Initialize( this );
			}
		}
	}
	
	final function SpawnGhosts()
	{
		var i : int;
		var ent : CEntity;
		for(i=0; i<ghostsTotalNum; i+=1)
		{
			ent = theGame.CreateEntity(ghostTemplate, safePos, EulerAngles(0,0,0));
			allGhosts.PushBack( ent );
			freeGhosts.PushBack( ent );
		}
	}
	
	// ------------------------------------------------------------
	// Waypoints management
	// ------------------------------------------------------------
	
	timer function UpdateManager( timeDelta : float )
	{
		var i, j, size : int;
		var fogGuides : array<CNode>;
		var fogGuide : CNode;
		var populate : bool;
		var fogGuidesSize : int;
		var playerPosition, draugPosition : Vector;
		var currentWaypoint : CGhostWaypoint;
		var wayToPlayerDist, wayToDraugDist, wayToFogGuideDist : float;
		var nearbyWaypoints : array< CNode >;
		var newWaypoints : array< CNode >;
		
		populate = true;
		// query new nodes in the vicinity
		playerPosition = thePlayer.GetWorldPosition();
		/*if(draug)
		{
			draugPosition = draug.GetWorldPosition();
		}*/
		allWaypoints.GetClosestToPosition( playerPosition, nearbyWaypoints, queryBoundsMin, queryBoundsMax, false );
		
		// go through them, marking the ones that need activation
		size = nearbyWaypoints.Size();
		fogGuides.Clear();
		fogGuides.Resize(0);
		theGame.GetNodesByTag('fog_guide', fogGuides);
		fogGuidesSize = fogGuides.Size();
		for( i = 0; i < size; i += 1 )
		{
			currentWaypoint = (CGhostWaypoint)nearbyWaypoints[i];
			if ( !currentWaypoint )
			{
				continue;
			}
			
			// only the ghost inside a ring ( squareR1, squareR2 ) may appear
			/*if(draug)
			{
				wayToDraugDist = VecDistance2DSquared( currentWaypoint.GetWorldPosition(), draugPosition );
			}*/
			wayToPlayerDist = VecDistance2DSquared( currentWaypoint.GetWorldPosition(), playerPosition );
			/*if(draug)
			{
				if( wayToPlayerDist > squareR1 &&  wayToDraugDist > squareR2)
				{
					if(fogGuidesSize > 0)
					{
						for(j = 0; j<fogGuidesSize; j+=1)
						{
							fogGuide = fogGuides[j];
							wayToFogGuideDist = VecDistance2DSquared( currentWaypoint.GetWorldPosition(), fogGuide.GetWorldPosition() );
							if(wayToFogGuideDist < squareR2)
							{
								populate = false;
								break;
							}
						}
					}
					if(populate)
					{
						currentWaypoint.PopulateWaypoint();
						activeNodes.Remove( currentWaypoint );
						newWaypoints.PushBack( currentWaypoint );
					}
				}
			}*/
			//else
			//{
				if( wayToPlayerDist > squareR1 )
				{
					if(fogGuidesSize > 0)
					{
						for(j = 0; j<fogGuidesSize; j+=1)
						{
							fogGuide = fogGuides[j];
							wayToFogGuideDist = VecDistance2DSquared( currentWaypoint.GetWorldPosition(), fogGuide.GetWorldPosition() );
							if(wayToFogGuideDist < squareR2)
							{
								populate = false;
								break;
							}
						}
					}
					if(populate)
					{
						currentWaypoint.PopulateWaypoint();
						activeNodes.Remove( currentWaypoint );
						newWaypoints.PushBack( currentWaypoint );
					}
				}
			//}
		}
		
		// for all previously active nodes as eligible for freeing
		size = activeNodes.Size();
		for ( i = 0; i < size; i += 1 )
		{
			((CGhostWaypoint)activeNodes[i]).FreeWaypoint();
		}
		activeNodes = newWaypoints;
	}
	
	// a helper method that populates the specified waypoint with a ghost
	final function GetFreeGhost() : CEntity
	{
		var tempGhost : CEntity;
		
		if( freeGhosts.Size() > 0 )
		{
			tempGhost = freeGhosts.Last();
			freeGhosts.Erase(freeGhosts.Size()-1);
		}
		else
		{
			Log("za malo duchow");
		}
		
		return tempGhost;
	}
	
	// a helper method that despawns a ghost from a waypoint
	final function DespawnGhost( waypoint : CGhostWaypoint, ghost : CEntity )
	{
		if ( !ghost )
		{
			Log( "There's no ghost at the specified waypoint, although one was expected" );
			return;
		}
		// hide the ghost
		ghost.Teleport( safePos ); 
		freeGhosts.PushBack( ghost );
	}
	
	final function VecDistance2DSquared( from, to : Vector ) : float
	{
		return (to.X-from.X)*(to.X-from.X) + (to.Y-from.Y)*(to.Y-from.Y);
	}
	
	// ------------------------------------------------------------
	// Scene management
	// ------------------------------------------------------------
	
}