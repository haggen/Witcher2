///////////////////////////////////////////////////////////////////////////////
// Entity that emmits point of interest

class CInterestingEntity extends CEntity
{
	editable inlined	var interestPoint	: CInterestPoint;
	editable			var iterestDuration	: float;
	editable			var cooldown		: float;
	
	default cooldown = 5.f; 
	default iterestDuration = 1.f;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		if ( interestPoint )
		{
			AddTimer( 'GenerateInterst', cooldown, true );
		}
	}
	
	timer function GenerateInterst( timeDelta : float )
	{
		theGame.GetReactionsMgr().BroadcastStaticInterestPoint( interestPoint, GetWorldPosition(), iterestDuration );
	}
}
