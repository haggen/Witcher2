class CBlockCombatArea extends CGameplayEntity
{
	saved var wasVisited : bool;
	editable var stopAtEnter : bool;
	var blockArea : CTriggerAreaComponent;
	default stopAtEnter = true;
	
	/*event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		if ( ! spawnData.restored )
		{
			//shouldSave = false;
		}
	}*/
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		this.blockArea = area;
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			if(thePlayer.GetCurrentPlayerState() != PS_Exploration )
			{
				if ( stopAtEnter ) thePlayer.RaiseForceEvent('GlobalEnd');
			}
			wasVisited = true;
			//shouldSave = true;
			thePlayer.SetGuardBlock(false, true);
			thePlayer.SetCombatBlockTriggerActive( true, this );
			thePlayer.ChangePlayerState( PS_Exploration );
			thePlayer.SetCombatHotKeysBlocked( true );
			thePlayer.SetCombatBlocked(true);
			thePlayer.AddTimer('combatBlocked', 6, false);
			thePlayer.AddTimer('KeepBlockOnIfInsideArea', 0.5f, true, false);	
			//this.AddTimer('InsideBlockAreaCheck', 0.5f, true, false);
		}
	}	

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			thePlayer.SetCombatBlockTriggerActive( false, NULL );
			thePlayer.ChangePlayerState( PS_Exploration );
			thePlayer.SetCombatHotKeysBlocked( false );
			thePlayer.SetCombatBlocked(false);
			thePlayer.RemoveTimer('combatBlocked');
			thePlayer.RemoveTimer('KeepBlockOnIfInsideArea');
			//this.RemoveTimer('InsideBlockAreaCheck');
		}
	}
}

quest function SetBlockCombatForPlayer( blockCombat : bool, stopAtEnter : bool )
{
	if ( thePlayer.AreCombatHotKeysBlocked() && thePlayer.IsCombatBlocked() ) return;
	if( blockCombat )
	{
		if(thePlayer.GetCurrentPlayerState() != PS_Exploration )
		{
			if ( stopAtEnter ) thePlayer.RaiseForceEvent('GlobalEnd');
		}
		//thePlayer.SetCombatBlockTriggerActive( true );
		if(thePlayer.GetCurrentPlayerState() == PS_CombatSilver || thePlayer.GetCurrentPlayerState() == PS_CombatSteel)
		{
			thePlayer.ChangePlayerState( PS_Exploration );
		}
		thePlayer.SetCombatHotKeysBlocked( true );
		thePlayer.SetCombatBlocked(true);
		thePlayer.AddTimer('combatBlocked', 6, false);
		thePlayer.AddTimer('KeepBlockOnIfInsideArea', 0.5f, true, false);		
	}
	else
	{
		thePlayer.SetCombatBlockTriggerActive( false, NULL );
		if(thePlayer.GetCurrentPlayerState() == PS_CombatSilver || thePlayer.GetCurrentPlayerState() == PS_CombatSteel)
		{
			thePlayer.ChangePlayerState( PS_Exploration );
		}
		thePlayer.SetCombatHotKeysBlocked( false );
		thePlayer.SetCombatBlocked(false);
		thePlayer.RemoveTimer('combatBlocked');
		thePlayer.RemoveTimer('KeepBlockOnIfInsideArea');
	}	
}
