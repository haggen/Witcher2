class CGhostsQ214 extends CNekker
{
	var stake : CEntity;
	var machineNeedsRestart : bool;
	
	default machineNeedsRestart = false;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		stake = (CEntity) theGame.GetNodeByTag('q214r_stake');
		AddTimer('GhostEnemyUpdate', 0.1, true);
		//this.ActionMoveToAsync(thePlayer.GetWorldPosition());
		super.OnSpawned(spawnData);
	}
	timer function GhostEnemyUpdate(timeDelta : float)
	{
		
		var distanceToStake : float;
		var fact : bool;
		
		distanceToStake = VecDistanceSquared(this.GetWorldPosition(), stake.GetWorldPosition());
		
		if(FactsQuerySum( 'q214r_barrier_weaken' ) == 1)
			fact = true;
			
		if(FactsQuerySum( 'q214r_barrier_weaken' ) == 0)
			fact = false;
		
		if(distanceToStake < 64.0 && !machineNeedsRestart)
		{
			this.GetBehTreeMachine().Stop();
			machineNeedsRestart = true;
			this.ActionCancelAll();
			this.ActionMoveAwayFromNodeAsync(stake, 8.0);
		}
		else if(machineNeedsRestart && distanceToStake >= 64.0 && !fact)
		{
			this.GetBehTreeMachine().Restart();
			machineNeedsRestart = false;
		}
		
		else if(machineNeedsRestart && distanceToStake >= 64.0 && fact)
		{
			this.GetBehTreeMachine().Restart();
			machineNeedsRestart = true;
		}
	}
	
}