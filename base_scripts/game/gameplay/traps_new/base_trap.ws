
//////////////////////////////////////////////////
//			Base class for all traps			//
//////////////////////////////////////////////////

class CBaseTrap extends CGameplayEntity
{
	editable saved var	affectsWitcher		:	bool;
	editable saved var	affectsHostiles		:	bool;
	editable var	timeToAutodisarm	:	float;	//Trap will be self-disarming after time. 0 if never disarmed.
	editable var	hasCriticalEffect	:	bool;	//Does trap apply critical effect.
	editable var	criticalEffectType	:	ECriticalEffectType;
	editable var	inventoryName		:	name;
	editable var	usedInventoryName	:	name;
	editable var	isRearmable			:	bool;	//Can trap be armed after being triggered.
	editable var 	range				: 	float;
	
	saved var wasTriggered	:	bool;
	saved var isArmed		:	bool;
	
	saved var criticalEffectChance : float;
	saved var minimumDamage : 	float;
	saved var maximumDamage :	float;
	saved var wasInitialized : bool;
	var	dissarming			:	bool;
	var interupted			:	bool;
	var affected			:	CActor;
	
	private var attachedLures	:	int;
	private var luresArray		: array<CLure>;

	default wasTriggered = false;
	default isArmed = true;
	
	function InitTrapStats(minDmg, maxDmg, crtChance : float)
	{
		var tags : array<name>;
		criticalEffectChance = crtChance;
		minimumDamage = minDmg;
		maximumDamage = maxDmg;
		wasInitialized = true;
		tags = GetTags();
		tags.PushBack('trap');
		SetTags(tags);
	}
	function GetTrapCriticalEffect() : ECriticalEffectType
	{
		return criticalEffectType;
	}
	function AttachLure( lure : CLure )
	{
		attachedLures += 1;
		luresArray.PushBack( lure );
	}
	
	function GetLuresAmount() : int
	{
		return attachedLures;
	}
	
	function DestroyAttachedLures()
	{
		var size, i : int;
		
		size = luresArray.Size();
		for( i = 0; i < size; i += 1 )
		{
			luresArray[i].MarkAsDestroyed();
		}
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//range = GetCharacterStats().GetFinalAttribute( 'range' );
		
		if( wasTriggered )
			DeployTriggeredTrap();
		else if( isArmed )
			DeployTrap();
		else
			DeployDisarmedTrap();
		
		super.OnSpawned( spawnData );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var npc : CNewNPC;
		
		if( !isArmed )
			return false;
		
		if( activator.GetEntity().IsA( 'CNewNPC' ) )
		{
			npc = (CNewNPC)activator.GetEntity();
			if( npc.GetAttitude( thePlayer ) == AIA_Hostile && (affectsHostiles || npc.IsMonster()) )
			{
				TriggerTrap(npc);
			}
			//Currently do not trigger on friendly units.
			//else if( npc.GetAttitude( thePlayer ) == AIA_Friendly && affectsWitcher )
			//	TriggerTrap(npc);
		}
		else if( activator.GetEntity().HasTag( 'PLAYER' ) && affectsWitcher )
			TriggerTrap(thePlayer);
		theHud.m_hud.ShowTutorial("tut70", "", false);	
		//theHud.ShowTutorialPanelOld("tut70", "");	
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( actionName == 'DisarmTrap' )
		{
			StartDisarmimgTrap(false);
		}
		else if( actionName == 'ArmTrap' )
		{
			StartArmingTrap();
		}
		else if( actionName == 'PickupTrap' )
		{
			StartPickingupTrap();
		}
	}
	
	// Function that is supposed to be overriden by extended classes
	private function ApplyAdditionalEffect( target : CActor )
	{
		if( target.HasTag( 'PLAYER' ) )
			target.HitPosition( GetWorldPosition(), 'Attack', 0, true );
		else
			target.HitPosition( GetWorldPosition(), 'FastAttack_t1', 0, true );
	}
	
	private function ApplyAdditionalGlobalEffect(){}
	
	private function GetAffectedActors() : array< CActor >
	{
		var i, size							: int;
		var actors							: array< CActor >;
		var casulties						: array< CActor >;
		var position, boundMin, boundMax	: Vector;
		var npc								: CNewNPC;
		
		position = GetWorldPosition();
		boundMin.X = -range;
		boundMin.Y = -range;
		boundMin.Z = -range;
		boundMax.X = range;
		boundMax.Y = range;
		boundMax.Z = range;
		
		ActorsStorageGetClosestByPos( position, actors, boundMin, boundMax, NULL, true );
		
		size = actors.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( actors[i].IsAlive() )
			{
				if( actors[i].IsA( 'CNewNPC' ) )
				{
					npc = (CNewNPC)actors[i];
					if( npc.GetAttitude( thePlayer ) == AIA_Hostile )
					{
						casulties.PushBack(actors[i]);
					}
					//Currently friendly units are not affected.
					//else if( npc.GetAttitude( thePlayer ) == AIA_Friendly && affectsWitcher )
					//{
					//	casulties.PushBack(actors[i]);
					//}
				}
				else if( actors[i].HasTag( 'PLAYER' ) )
					casulties.PushBack(actors[i]);
			}
		}
		
		return casulties;
	}
	
	private function HarmMultipleTargets()
	{
		var i, size	:	int;
		var targets	:	array< CActor >;
		
		targets = GetAffectedActors();
		size = targets.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			HarmSingleTarget( targets[i] );
		}
	}
	function CriticalEffectTest(target : CActor, effectType : ECriticalEffectType) : bool
	{
		var res : float;
		var chanceBasic : float;
		var chance : float;
		var diceThrow : float = RandRangeF(0.0, 1.0);
		chanceBasic = criticalEffectChance;
		if(criticalEffectType == CET_Stun)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_stun' );
		}
		else if(criticalEffectType == CET_Poison)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_poison' );
		}
		else if(criticalEffectType == CET_Burn)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_burn' );
		}
		else if(criticalEffectType == CET_Freeze)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_freeze' );
		}
		chance = chanceBasic - res;
		if(diceThrow < chance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function CalculateCriticalEffectChance() : float
	{
		if(hasCriticalEffect)
		{
			if(criticalEffectType == CET_Stun)
			{
				return GetCharacterStats().GetFinalAttribute('crt_knockdown');
			}
			else if(criticalEffectType == CET_Poison)
			{
				return GetCharacterStats().GetFinalAttribute('crt_poison');
			}
			else if(criticalEffectType == CET_Burn)
			{
				return GetCharacterStats().GetFinalAttribute('crt_burn');
			}
			else if(criticalEffectType == CET_Freeze)
			{
				return GetCharacterStats().GetFinalAttribute('crt_freeze');
			}
			else
			{
				return 0.0f;
			}
		}
		else
		{
			return 0.0f;
		}

	}
	private function HarmSingleTarget( target : CActor )
	{
		var	minInitialDmg		:	float;
		var	maxInitialDmg		:	float;
		var	minDmgOnTick		:	float;
		var	maxDmgOnTick		:	float;
		var	effectDuration		:	float;
		var diceThrow			: 	float;
		var damageAvoidChance	: 	float;
		var damage				: 	float;
		var damageInt, damageBaseInt, resInt : int;
		
		var finalDmg, damageSkillMult	:	float;
		
		
		if(wasInitialized)
		{
			minInitialDmg = minimumDamage;
			maxInitialDmg = maximumDamage;
			criticalEffectChance = criticalEffectChance;
		}
		else
		{
			minInitialDmg	= GetCharacterStats().GetFinalAttribute( 'damage_min' );
			maxInitialDmg	= GetCharacterStats().GetFinalAttribute( 'damage_max' );
			criticalEffectChance = CalculateCriticalEffectChance();
		}
		
		minDmgOnTick	= 0.0;
		maxDmgOnTick	= 0.0;
		effectDuration	= 0.0;
		if(target == thePlayer)
		{
			if(thePlayer.GetCharacterStats().HasAbility('story_s19_1'))
			{
				damageAvoidChance = thePlayer.GetCharacterStats().GetFinalAttribute('trap_avoid_chance');
				diceThrow = RandRangeF(0.01, 1.0);
				if(diceThrow < damageAvoidChance)
					return;
			}
		}
		if( hasCriticalEffect && CriticalEffectTest(target, criticalEffectType))
		{
			target.ForceCriticalEffect(criticalEffectType, W2CriticalEffectParams(0,0,0,0), false);
		}
		damage = RandRangeF( minInitialDmg, maxInitialDmg );
		finalDmg =  damage - target.GetCharacterStats().GetFinalAttribute( 'damage_reduction' );
		if( finalDmg < 1 )
			finalDmg = 1;
		
		damageBaseInt = RoundF(damage);
		resInt = RoundF(target.GetCharacterStats().GetFinalAttribute( 'damage_reduction' ));
		damageInt = damageBaseInt - resInt;
		if(damageInt <=0)
		{
			damageInt = 0;
		}
		if(VecDistance(target.GetWorldPosition(), thePlayer.GetWorldPosition()) < 30.0)
		theHud.m_hud.CombatLogAdd("<span class='white'> " + GetLocStringByKeyExt("cl_trapdmg") + " </span><span class='red'>" + damageInt + " (" + AddDamageIcon() + damageBaseInt + " - " + AddArmorIcon() + resInt + ")</span>. ");
		target.DecreaseHealth( finalDmg, true, NULL );
	
		ApplyAdditionalEffect( target );
	}
	
	timer function AutoDisarm( time : float )
	{
		if( isArmed )
			DisarmTrap(true);
	}
	
	event OnTrapInteractAnimEvent();
	
	function HandleAardHit( aard : CWitcherSignAard )
	{
		if( isArmed )
			TriggerTrap( NULL );
	}
	
	function OnTriggerTrap( target : CActor )
	{
		TriggerTrap( target );
	}
}

state Deployed in CBaseTrap
{
	event OnEnterState()
	{
		parent.isArmed = true;
		
		parent.GetComponent( "ArmTrap" ).SetEnabled( false );
		parent.GetComponent( "PickupTrap" ).SetEnabled( false );
	}
	
	entry function DeployTrap()
	{
		parent.RaiseEvent( 'idle' );
		
		parent.GetComponent( "DisarmTrap" ).SetEnabled( true );
		
		if( parent.timeToAutodisarm > 0 )
			parent.AddTimer( 'AutoDisarm', parent.timeToAutodisarm, false );
	}
	
	entry function ArmTrap()
	{
		if( parent.timeToAutodisarm > 0 )
			parent.AddTimer( 'AutoDisarm', parent.timeToAutodisarm, false );
			
		parent.RaiseEvent( 'idle' );
		parent.ApplyAppearance( 'default' );
		parent.affectsHostiles = true;
		parent.affectsWitcher = false;
		Sleep(1.5);
		parent.GetComponent( "DisarmTrap" ).SetEnabled( true );
	}
	
	entry function StartDisarmimgTrap( isAuto : bool )
	{
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
		
		parent.dissarming = true;
		parent.interupted = false;
		theGame.GetBlackboard().AddEntryEntity( 'currentTrap', parent );
		if(thePlayer.PlayerActionForced(PCA_LootGround))
		{
			//thePlayer.SetManualControl( false, false );
			thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
			parent.dissarming = false;
			thePlayer.SetPlayerCombatStance(PCS_Low);
			Sleep(0.1);
			thePlayer.WaitForBehaviorNodeDeactivation( 'LootStop', 5.0f );
		}
		//thePlayer.SetManualControl( true, true );
		
		//we have not exited the Deployed state so action was interupted.
		//Sleep(3.0);
		parent.GetComponent( "DisarmTrap" ).SetEnabled( true );
		AddStoryAbilityCounter("story_s19", 1, 5);
	}
	
	event OnTrapInteractAnimEvent()
	{
		parent.dissarming = false;
		parent.DisarmTrap( false );
	}
}

state Disarmed in CBaseTrap
{
	var isArmInteraction : bool;
	
	event OnEnterState()
	{
		parent.isArmed = false;
		
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
	}
	
	entry function DisarmTrap( isAuto : bool )
	{
		parent.RaiseForceEvent( 'trap' );
		
		if( parent.isRearmable )
			parent.ApplyAppearance( 'triggered' );
		
		if( !isAuto )
		{
			Sleep(1.5);
		}
		
		parent.GetComponent( "ArmTrap" ).SetEnabled( true );
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	
	entry function DeployDisarmedTrap()
	{
		parent.RaiseForceEvent( 'trap' );
		
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
		parent.GetComponent( "ArmTrap" ).SetEnabled( true );
		
		if( parent.isRearmable )
		{
			parent.ApplyAppearance( 'triggered' );
		}
	}
	
	entry function DeployTriggeredTrap()
	{
		parent.RaiseForceEvent( 'trap' );
		
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
		
		if( parent.isRearmable )
			parent.GetComponent( "ArmTrap" ).SetEnabled( true );
			
		parent.ApplyAppearance( 'triggered' );
	}
	
	entry function TriggerTrap( affected : CActor )
	{
		if( parent.dissarming )
		{
			parent.interupted = true;
			parent.dissarming = false;
			thePlayer.RaiseEvent( 'Idle' );
			thePlayer.SetManualControl( true, true );
		}
		
		parent.wasTriggered = true;
		parent.RaiseForceEvent( 'trap' );
		
		parent.affected = affected;
		parent.PlayEffect( 'trap_effect' );
		parent.ApplyAppearance( 'triggered' );
		
		if( parent.range > 0 )
		{
			parent.HarmMultipleTargets();
		}
		else
		{
			parent.HarmSingleTarget( affected );
		}
		
		virtual_parent.ApplyAdditionalGlobalEffect();
		
		parent.DestroyAttachedLures();
		
		if( parent.isRearmable )
			parent.GetComponent( "ArmTrap" ).SetEnabled( true );
		
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	
	entry function RemoteTriggerTrap( delay : float )
	{
		Sleep( delay );
		
		if( parent.wasTriggered )
			return;
		
		if( parent.dissarming )
		{
			parent.interupted = true;
			parent.dissarming = false;
			thePlayer.RaiseEvent( 'Idle' );
			thePlayer.SetManualControl( true, true );
		}
		
		parent.wasTriggered = true;
		parent.RaiseForceEvent( 'trap' );
		parent.PlayEffect( 'trap_effect' );
		parent.ApplyAppearance( 'triggered' );
		
		if( parent.range > 0 )
			parent.HarmMultipleTargets();
			
		virtual_parent.ApplyAdditionalGlobalEffect();
			
		if( parent.isRearmable )
			parent.GetComponent( "ArmTrap" ).SetEnabled( true );
			
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	
	latent function InteractTrap()
	{
		
		parent.GetComponent( "ArmTrap" ).SetEnabled( false );
		parent.GetComponent( "PickupTrap" ).SetEnabled( false );
		
		theGame.GetBlackboard().AddEntryEntity( 'currentTrap', parent );
		if(thePlayer.PlayerActionForced(PCA_LootGround))
		{
			//thePlayer.SetManualControl( false, false );
			thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
			//thePlayer.RaiseForceEvent('loot_floor');
			
			thePlayer.SetPlayerCombatStance(PCS_Low);
			Sleep(0.1);
			thePlayer.WaitForBehaviorNodeDeactivation( 'LootStop', 5.0f );
			
		}
		//thePlayer.SetManualControl( true, true );
		//we have not exited the Disarmed state so action was interupted.
		//Sleep(3.0);
		parent.GetComponent( "ArmTrap" ).SetEnabled( true );
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	
	entry function StartArmingTrap()
	{
		parent.interupted = false;
		isArmInteraction = true;
		InteractTrap();
	}
	
	entry function StartPickingupTrap()
	{
		parent.interupted = false;
		isArmInteraction = false;
		InteractTrap();
	}
	
	event OnTrapInteractAnimEvent()
	{
		if( parent.interupted )
		{
			return false;
		}
	
		if( isArmInteraction )
			parent.ArmTrap();
		else
			parent.PickupTrap();
	}
}

state Pickedup in CBaseTrap
{
	entry function PickupTrap()
	{
		if( parent.wasTriggered )
			thePlayer.GetInventory().AddItem( parent.usedInventoryName, 1 );
		else
			thePlayer.GetInventory().AddItem( parent.inventoryName, 1 );
			
		parent.GetComponent( "ArmTrap" ).SetEnabled( false );
		parent.GetComponent( "PickupTrap" ).SetEnabled( false );
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
		parent.RemoveTimers();
		parent.Destroy();
	}
}



//////////////////////////////////////////////////
//			Spawner class for all traps			//
//////////////////////////////////////////////////

class CTrapSpawner extends CGameplayEntity
{
	editable 	var	trapEntity			:	CEntityTemplate;
	editable 	var	trapInventoryName	:	name;
	editable 	var	usedTrapInventoryName :	name;
	editable 	var	affectsWitcher		:	bool;
	editable 	var	affectsHostiles		:	bool;
	saved 		var	hasBeenSpawned		:	bool;
	default	hasBeenSpawned				= false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var trap : CBaseTrap;

		if ( hasBeenSpawned == false )
		{
			trap = (CBaseTrap)theGame.CreateEntity( trapEntity, GetWorldPosition(), GetWorldRotation(), true, false, false, PM_Persist );
			trap.affectsWitcher		= affectsWitcher;
			trap.affectsHostiles	= affectsHostiles;
			trap.inventoryName		= trapInventoryName;
			trap.usedInventoryName	= usedTrapInventoryName;
			
			if( trap )
			{
				hasBeenSpawned = true;
			}
			else
			{
				Log( "Trap not spawned" );
			}
		}
	}
}