
////////////////////////////////////////////////////////////////////////////////
////		This entity is spawned after a frozen target gets killed		////
////////////////////////////////////////////////////////////////////////////////

class CFrozenDestruction extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		AddTimer( 'Delay', 0.01f, false );
		AddTimer( 'DelayDestroy', 5.0f, false );
	}
	
	timer function Delay( time : float )
	{
		PlayEffect('destraction_fx');
	}
	
	timer function DelayDestroy( time : float )
	{
		Destroy();
	}
}