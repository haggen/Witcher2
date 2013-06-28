
class CThunderEntity extends CEntity
{
	var timeSpawnMin : float;
	var timeSpawnMax : float;
	
	default timeSpawnMin = 1.0f;
	default timeSpawnMax = 10.0f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.AddTimer('SpawnThunder', RandRangeF( timeSpawnMin, timeSpawnMax), false);
	}
	timer function SpawnThunder(td:float)
	{
		PlayEffect( 'thunder' );
		this.AddTimer('SpawnThunder', RandRangeF( timeSpawnMin, timeSpawnMax), false);
	}
}