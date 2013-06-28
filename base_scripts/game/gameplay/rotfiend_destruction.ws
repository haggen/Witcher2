
////////////////////////////////////////////////////////////////////////////////
////		This entity is spawned after a frozen target gets killed		////
////////////////////////////////////////////////////////////////////////////////

class CRotfiendDestruction extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		AddTimer( 'Delay', 0.01, false );
	}
	
	timer function Delay( time : float )
	{
		PlayEffect('destruction_fx');
		PlayEffect('trail_fx');
	}
}