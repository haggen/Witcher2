enum ECriticalEffectForArea
{
	Burn,
	Bleeding,
	Poison
}
//Applies chosen critical effect to player and / or other NPCs.
class CCriticalEffectArea extends CGameplayEntity
{
	editable var playsDamageAnimation : bool;				//if true, characters will play damage animation on entering area
	editable var criticalEffect : ECriticalEffectForArea;	//critical effect to apply
	editable var isPlayerOnly : bool;						//if true, applies effects only for player character
	editable var excludeNPCsWithTags : array<name>;			//excludes NPCs with given tags
	default playsDamageAnimation = false;
	default isPlayerOnly = true;
	var i, size : int;
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		var applyEffect : bool;
		size = excludeNPCsWithTags.Size();
		activatorActor = (CActor) activator.GetEntity();
		if(isPlayerOnly && activatorActor == thePlayer)
		{
			applyEffect = true;
		}
		else if(!isPlayerOnly)
		{
			applyEffect = true;
			for(i = 0; i < size; i += 1)
			{
				if(activatorActor.HasTag(excludeNPCsWithTags[i]))
				{
					applyEffect = false;
				}
			}
		}
		if( applyEffect )
		{
			if(playsDamageAnimation)
			{
				activatorActor.HitPosition(this.GetWorldPosition(), 'Attack', 1.0, true, NULL, true, true);
			}
			if(criticalEffect == Burn)
			{
				activatorActor.AddTimer('TimerBurnCheck', 0.1, true);
			}
			else if(criticalEffect == Poison)
			{
				activatorActor.AddTimer('TimerPoisonCheck', 0.1, true);
			}
			else if(criticalEffect == Bleeding)
			{
				activatorActor.AddTimer('TimerBleedingCheck', 0.1, true);
			}
			
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		if( activatorActor)
		{
			if(criticalEffect == Burn)
			{
				activatorActor.RemoveTimer('TimerBurnCheck');
			}
			else if(criticalEffect == Poison)
			{
				activatorActor.RemoveTimer('TimerPoisonCheck');
			}
			else if(criticalEffect == Bleeding)
			{
				activatorActor.RemoveTimer('TimerBleedingCheck');
			}
		}
	}
}


class CFireTrigger extends CSneakLights
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		
		if( activatorActor == thePlayer && super.IsOn())
		{
			thePlayer.HitPosition(this.GetWorldPosition(), 'Attack', 20.0, true, NULL, true, true);
			thePlayer.AddTimer('TimerBurnCheck', 0.1, true);
		}
	}	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		if( activatorActor == thePlayer)
		{
			thePlayer.RemoveTimer('TimerBurnCheck');
		}
	}
}
class CCombatModeTrigger extends CGameplayEntity
{
	saved var trigger : CTriggerAreaComponent;
	editable var drawSword : bool;
	editable var swordType : EWitcherSwordType;
	default drawSword = false;
	
	timer function CombatModeKeep(td : float)
	{
		if(trigger.IsEnabled())
		{
			if(drawSword)
			{
				if(swordType == WST_Silver && thePlayer.HasSilverSword() && thePlayer.GetCurrentPlayerState() != PS_Cutscene && thePlayer.GetCurrentPlayerState() != PS_Meditation && thePlayer.GetCurrentPlayerState() != PS_CombatSilver && thePlayer.GetCurrentPlayerState() != PS_AimedThrow )
				{
					if(!thePlayer.AreCombatHotKeysBlocked())
						thePlayer.ChangePlayerState(PS_CombatSilver);
				}
				else if(swordType == WST_Steel && thePlayer.HasSteelSword() && thePlayer.GetCurrentPlayerState() != PS_Cutscene && thePlayer.GetCurrentPlayerState() != PS_Meditation && thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_AimedThrow  )
				{
					if(!thePlayer.AreCombatHotKeysBlocked())
						thePlayer.ChangePlayerState(PS_CombatSteel);
				}
			}
			thePlayer.KeepCombatMode();
		}
		else
		{
			this.RemoveTimer('CombatModeKeep');
		}
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		
		if( activatorActor == thePlayer && area.IsEnabled())
		{
			trigger = area;
			this.AddTimer('CombatModeKeep', 1.0, true);
		}
	}	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		if( activatorActor == thePlayer)
		{
			this.RemoveTimer('CombatModeKeep');
		}
	}
}