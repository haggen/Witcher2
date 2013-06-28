
class CBannerGhostRunning extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.AddTimer('PlayAppear', 0.2, false);
		super.OnSpawned(spawnData);
	}
	timer function PlayAppear(timeDelta : float)
	{
		this.PlayEffect('appear');
		this.AddTimer('PlayDisappear', 7.0, false);
	}
	timer function PlayDisappear(timeDelta : float)
	{
		this.PlayEffect('disappear');
	}
}