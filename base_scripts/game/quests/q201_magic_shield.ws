// Klasa obslugujaca interakcje zabijajaca potwory i gracza w swiecie duchow w akcie 2

class q201_magic_shield extends W2TargetingArea
{
	var enable : bool;
	var encounter : CEncounter;
	var fogGuide : CNewNPC;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		encounter = (CEncounter) theGame.GetNodeByTag('quest_fog_main_encounter');
		enable = true;
		fogGuide = theGame.GetNPCByTag('fog_guide');
		if(FactsQuerySum('owl_stopped') != 1)
		{
			Log("q201_shield fx <<<--------------------");
			PlayEffect('shield_area__fx', this);
		}		
	}
	function MagicLightning(target : CActor, owner : CNewNPC)
	{
		var component : CComponent;
		var boneMtx	: Matrix;
		var node : CNode;
		var magicBolt : CMagicBolt;
		var hitEffectPosition : Vector;
		var damage : float;
		var item : SItemUniqueId;
		damage = RandRangeF(owner.GetCharacterStats().GetFinalAttribute('ranged_damage_min'), owner.GetCharacterStats().GetFinalAttribute('ranged_damage_max'));
		component = target.GetComponent("fx point1");
		if(!component)
		{
			component = target.GetComponent("hit_point_fx");
		}
		if(component)
		{
			node = (CNode)component;
		}
		else
		{
			node = (CNode)target;
		}
		if(target.GetBoneIndex('pelvis') == -1)
		{
			hitEffectPosition = target.GetWorldPosition();
			hitEffectPosition.Z += 1.0;
		}
		else
		{
			boneMtx = target.GetBoneWorldMatrix('pelvis');
			hitEffectPosition = MatrixGetTranslation(boneMtx);
		}
		item = owner.GetInventory().GetItemByCategory('magic_bolts', false);
		magicBolt = (CMagicBolt)owner.GetInventory().GetDeploymentItemEntity(item, hitEffectPosition, owner.GetWorldRotation());
		if(owner.HasTag('Detmold') == true)
		{	
			owner.GetInventory().GetItemEntityUnsafe(owner.GetCurrentWeapon()).PlayEffect('lightning_bolt', target);
		}
		else
		{
			owner.PlayEffect( magicBolt.GetBoltFXName(), node );
		}
		
		target.HitPosition(owner.GetWorldPosition(), 'Attack', damage, true);
	}
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var actor : CActor;
		
		actor = (CActor)activator;
		encounter = (CEncounter) theGame.GetNodeByTag('quest_fog_main_encounter');
		
		if(activator.HasTag('monster') && enable)
		{
			if (((CActor)activator).GetCharacterStats().HasAbility('q201 lethal dmg ability'))
			{
				actor.GetCharacterStats().RemoveAbility( 'q201 lethal dmg ability' );
				actor.DecreaseHealth(((CActor)activator).initialHealth * 0.7 , true, NULL );
				actor.PlayEffect('medalion_detection_fx', actor);
				if(FactsQuerySum('owl_stopped') != 1)
				{
					actor.GetCharacterStats().AddAbility( 'q201 damage on time for monster' );
					actor.PlayEffect('magic_shield_hit', actor);
					MagicLightning(actor, fogGuide);
				}
				
			}
			else
			{
				actor.DecreaseHealth(((CActor)activator).initialHealth * 0.7 , true, NULL );
				actor.PlayEffect('medalion_detection_fx',actor);
				if(FactsQuerySum('owl_stopped') != 1)
				{
					actor.GetCharacterStats().AddAbility( 'q201 damage on time for monster' );
					actor.PlayEffect('magic_shield_hit', actor);
					MagicLightning(actor, fogGuide);
				}
				
			}
		}
		else if(activator == thePlayer && enable)
		{
			AreaEnvironmentDeactivate("AreaEnvironment_boss_out");
			AreaEnvironmentActivate("AreaEnvironment_boss1");
		
			if (thePlayer.GetCharacterStats().HasAbility('q201 damage on time for player'))
			{
				thePlayer.GetCharacterStats().RemoveAbility( 'q201 damage on time for player' );
			}
			if(FactsQuerySum('owl_stopped') == 1)
			{
				encounter.SetEnableState(false);
				Log("MAIN FOG ENCOUNTER" + encounter + " IS ENABLED = " + encounter.IsEncounterActive() );
			}
			
		}
	}
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
	
		var actor : CActor;
		actor = (CActor)activator;
		encounter = (CEncounter) theGame.GetNodeByTag('quest_fog_main_encounter');
		
		if(activator.HasTag('monster')&& enable)
		{
			//actor.GetCharacterStats().AddAbility( 'q201 lethal dmg ability' );
			actor.GetCharacterStats().RemoveAbility( 'q201 damage on time for monster' );
			actor.StopEffect('medalion_detection_fx');
			actor.StopEffect('magic_shield_hit');
		}
		else if(activator == thePlayer && enable)
		{
			thePlayer.GetCharacterStats().AddAbility( 'q201 damage on time for player' );
			AreaEnvironmentDeactivate("AreaEnvironment_boss1");
			AreaEnvironmentActivate("AreaEnvironment_boss_out");
			
			if(FactsQuerySum('owl_stopped') == 1)
			{
				encounter.SetEnableState(true);
				Log("MAIN FOG ENCOUNTER" + encounter + " IS ENABLED = " + encounter.IsEncounterActive() );
			}
			
		}
	}
	event OnDestroyed()
	{
		thePlayer.GetCharacterStats().RemoveAbility( 'q201 damage on time for player' );
		
		if(FactsQuerySum('owl_stopped') != 1)
		{
			AreaEnvironmentDeactivate("AreaEnvironment_boss1");
			AreaEnvironmentDeactivate("AreaEnvironment_boss_out");
		}
		enable = false;
	}
}
