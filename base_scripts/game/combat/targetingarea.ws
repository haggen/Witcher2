enum W2TargetingTestResult
{
	TTR_PlayerOutside,
	TTR_PlayerInsideTargetOutside,
	TTR_PlayerInsideTargetInside,
};

class W2TargetingArea extends CItemEntity
{
	editable var radius : float;
	default radius = 8.0f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		theGame.RegisterTargetingArea( this );		
		super.OnSpawned( spawnData );
	}
	
	event OnDestroyed()
	{
		theGame.UnregisterTargetingArea( this );
		super.OnDestroyed();
	}
	
	function TargetingTest( entity : CEntity ) : W2TargetingTestResult
	{
		var pos : Vector = GetParentEntity().GetWorldPosition();
		var dist : float;
		dist = VecDistance2D( thePlayer.GetWorldPosition(), pos );
		
		//thePlayer.GetVisualDebug().AddSphere( 'W2TargetingArea', radius, pos, true, Color(0,0,128) );
		
		if( dist < radius )
		{
			// Player inside: test entity
			dist = VecDistance2D( entity.GetWorldPosition(), pos );
			if( dist < radius )
			{
				return TTR_PlayerInsideTargetInside;
			}
			else
			{
				return TTR_PlayerInsideTargetOutside;
			}
		}
		else
		{
			// Player outside: always true
			return TTR_PlayerOutside;
		}
	}
};