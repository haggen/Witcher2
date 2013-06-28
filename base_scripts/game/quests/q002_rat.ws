class q002_rat extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
	}

	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		RaiseEvent( 'Escape' );
	}
}