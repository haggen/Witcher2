/*enum EDragonFloorAction
{
	//Probability driven actions
	//ground actions
	DFA_DragonActionListStart,
	
	DFA_EdgeActionsStart,
	DFA_EdgeJawAttack1,
	DFA_EdgeJawAttack2,
	DFA_EdgeClawAttackLeft1,
	DFA_EdgeClawAttackRight1,
	DFA_EdgeFireStart,
	DFA_EdgeFireSides,
	DFA_EdgeActionsEnd,
	
	DFA_HeadActionsStart,
	DFA_Head_AttackJaw,
	DFA_Head_AttackClaw,
	DFA_HeadFireStart,
	DFA_HeadToEdge,
	DFA_HeadActionsEnd,
	
	DFA_DragonActionListEnd
};
enum EDragonFloorState
{
	DFS_Head,
	DFS_Edge
};


//MSZ CDragonA3Floor class used for dragon AI management on the 1st floor tower stage 
class CDragonA3Floorr extends CDragonA3Base
{
	//Default actions' probability values (editable in dragon template). Used to store predefinied values while calculating actions probability
	//all probabilities are weights and take values from 0 to +inf.
	editable var 	
					//Edge Actions
					def_probability_EdgeJawAttack1,
					def_probability_EdgeJawAttack2,
					def_probability_EdgeFireStart,
					def_probability_EdgeFireSides,
					def_probability_EdgeClawAttackLeft1,
					def_probability_EdgeClawAttackRight1,
					
					//Head Actions
					def_probability_HeadJawAttack1,
					def_probability_HeadClawAttack1,
					def_probability_HeadFireStart,
					def_probability_HeadToEdge
					
														: int;
	
	//Edge Actions
	default def_probability_EdgeJawAttack1 			= 10;
	default def_probability_EdgeJawAttack2 			= 10;
	default def_probability_EdgeFireStart 			= 10;
	default def_probability_EdgeFireSides 			= 10;
	default def_probability_EdgeClawAttackLeft1 	= 10;
	default def_probability_EdgeClawAttackRight1 	= 10;
	
	//Head Actions
	default def_probability_HeadJawAttack1 			= 10;
	default def_probability_HeadClawAttack1 		= 10;
	default def_probability_HeadFireStart 			= 10;
	default def_probability_HeadToEdge 				= 10;

	var dragonDamageNormal, dragonDamageFirePerSecond : float;
	var dragonFireUpdate : float;
	var dragonBorderHealth : int;
	
	default dragonBorderHealth = 70;
	default dragonFireUpdate = 0.3;
	
	var dragonState : EDragonFloorState;
	default dragonState = DFS_Head;
	default canPlayDamageAnim = false;
	default isPlayingDamageAnim = false;
	default canBeAttacked = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var dragonHead : CDragonHead;
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		theHud.m_hud.SetBossName( "DRAGON" );
		theHud.HudTargetActorEx( dragonHead, true );
		theHud.m_hud.SetBossHealthPercent( dragonHead.dragonShowHealth );
		
		this.AddTimer('DragonInitialize', 2.0, false);
		//this.EnablePhysicalMovement(false);
	}	
	//ChangeDragonFloorState - changes EDragonFloorState, informs AI if dragon is flying or siting on the tower edge.
	function ChangeDragonFloorState(newDragonState : EDragonFloorState)
	{
		dragonState = newDragonState;
	}
	function HitDragon()
	{
		var finalDamage : float;
		var dragonHead : CDragonHead;
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		finalDamage =  CalculateDamage(thePlayer, dragonHead, true, false, true, true);
		dragonHead.dragonHealth -= finalDamage;
		dragonHead.dragonShowHealth = dragonHead.ComputeDisplayedBossHealth();
		
		theHud.m_hud.SetBossHealthPercent( dragonHead.dragonShowHealth );
		
		if(dragonHead.dragonShowHealth <= dragonBorderHealth)
		{
			dragonHead.dragonShowHealth = dragonBorderHealth;
			DragonTopStage();
		}
	}
	function GetDragonHitEvent(canPlayDamageAnim : bool) : name
	{
		var eventName : name;
		if(dragonState == DFS_Head)
		{
			if(Rand(2) == 1)
			{
				eventName = 'head_hit_front1';
				return eventName;
			}
			else
			{
				eventName = 'head_hit_front2';
				return eventName;
			}
		}
		else if(dragonState == DFS_Edge)
		{
			if(PlayerInRange("RightAttack1"))
			{
				eventName = 'edge_hit_right1';
				return eventName;
			}
			else if(PlayerInRange("LeftAttack1"))
			{
				eventName = 'edge_hit_left1';
				return eventName;
			}
			else 
			{
				if(Rand(2) == 1)
				{
					eventName = 'edge_hit_front1';
					return eventName;
				}
				else
				{
					eventName = 'edge_hit_front2';
					return eventName;
				}
			}
		}
	}
	timer function DragonInitialize(timeDelta : float)
	{
		var dragonHead : CDragonHead;
		thePlayer.EnablePhysicalMovement(true);
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		dragonDamageNormal = dragonHead.GetCharacterStats().GetAttribute('damage_attack');
		dragonDamageFirePerSecond = dragonHead.GetCharacterStats().GetAttribute('damage_fire_per_sec');
		DragonLookatOn();
		DragonUpdate();
	}
	//Timers used for looped fire attacks
	timer function FireCone(timeDelta : float)
	{
		//var damage : float;
		//damage = dragonDamageFirePerSecond * dragonFireUpdate;
		theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
		theCamera.RaiseEvent('Camera_ShakeHit');
		if(PlayerInRange("FireAttack1"))
		{
			//TODO: what is the burn duration?? and what is the damage if in cone range.
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( dragonDamageFirePerSecond, dragonDamageFirePerSecond, 5, 5 ) );
			//thePlayer.DecreaseHealth(damage, true, NULL);
		}
	}
	
	function RemoveAllDragonTimers()
	{
		RemoveTimer('FireCone');
	}
	function StopAllDragonEffects()
	{
		StopEffect('fire_breath_1');
	}
}
state DragonDefault in CDragonA3Floorr
{
	var dragonActionRand : EDragonFloorAction;
	var actionDuration, maxActionDuration, minActionDuration, minFireAttackDuration, maxFireAttackDuration, minShortFireAttackDuration, maxShortFireAttackDuration, minWingAttackDuration, maxWingAttackDuration : float;
	var currentHitEventName : name;		
	var actionProbabilities : array<int>;
	var dragonActions : array<EDragonFloorAction>;
	var dragonActionsToRandomize : array<EDragonFloorAction>;
	var performedActionsNum, performedActionsNumMax: int;
	var probabilityDecreaseMult, probabilityIncreaseMult : float;
	
	default actionDuration = 0.0;
	default minActionDuration = 0.0;
	default maxActionDuration = 5.0;
	default minFireAttackDuration = 2.0;
	default maxFireAttackDuration = 6.0;
	default minShortFireAttackDuration = 0.0;
	default maxShortFireAttackDuration = 2.0;
	default minWingAttackDuration = 3.0;
	default maxWingAttackDuration = 6.0;	
	default performedActionsNum = 0;
	default performedActionsNumMax = 10;
	default probabilityDecreaseMult = 0.5;
	default probabilityIncreaseMult = 1.5;
	
	event OnEnterState()
	{
		DragonActionsInitialize();
		ResetActionProbability();
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		Log("Processing anim events...");
		/* 	--------------------------
			List of possible events:
				Effects:
					fire_start
					fire_stop
					fire_sector1_start
					fire_sector2_start
					fire_sectors_stop
					wind_start
					wind_stop
				
				Attacks:
					attack
					attack_strong
					attack_strong_up
					attack_fly_1
					attack_fly_2
					attack_fly_3
					attack_wind
					
					Immortal
				AI:
					
			--------------------------	*//*
		if(animEventName == 'fire_start' && animEventType == AET_Tick)
		{
			parent.AddTimer('FireCone', parent.dragonFireUpdate, true);
			parent.PlayEffect('fire_breath_1');
		}
		else if(animEventName == 'attack' && animEventType == AET_Tick)
		{
			DragonAttack('Attack_t1', false);
		}
		else if(animEventName == 'attack_strong' && animEventType == AET_Tick)
		{
			DragonAttack('Attack_boss_t1', false);
		}
		else if(animEventName == 'attack_strong_up' && animEventType == AET_Tick)
		{
			DragonAttack('HeavyHitUp', false);
		}
		else if(animEventName == 'camera_shake' && animEventType == AET_Tick)
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if(animEventName == 'camera_shake_light' && animEventType == AET_Tick)
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if(animEventName == 'fire_stop' && animEventType == AET_Tick)
		{
			parent.RemoveAllDragonTimers();
			parent.StopAllDragonEffects();
		}
		else if( animEventName == 'immortal' )
		{
			if ( animEventType == AET_DurationStart )
			{								
				parent.SetCanBeAttacked(false);
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.SetCanBeAttacked(true);		
			}
		}
	}
	function DragonAttackHitCheck() : bool
	{
		if(dragonActionRand == DFA_EdgeJawAttack1 )
		{
			if(parent.PlayerInRange("ForwardAttack1") || parent.PlayerInRange("LeftAttack1") || parent.PlayerInRange("RightAttack1"))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else if(dragonActionRand == DFA_EdgeClawAttackLeft1)
		{
			if(parent.PlayerInRange("ForwardAttack1") || parent.PlayerInRange("LeftAttack1"))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else if(dragonActionRand == DFA_EdgeClawAttackRight1)
		{
			if(parent.PlayerInRange("ForwardAttack1") || parent.PlayerInRange("RightAttack1"))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else if(dragonActionRand == DFA_EdgeJawAttack2 && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DFA_Head_AttackJaw && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DFA_Head_AttackClaw && parent.PlayerInRange("CloseAttack"))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	//DragonAttack - handles dragon attacks
	function DragonAttack(dragonAttackType : name, overideAttackHitCheck : bool)
	{
		//HeavyHitUp
		var dragonHead : CDragonHead;
		var dragonHeadPos : Vector;
		var damage : float;
		var attackType : name;
		var hitParams : HitParams;
		damage = parent.ComputeDragonDamage(parent.dragonDamageNormal);
		if(DragonAttackHitCheck() || overideAttackHitCheck)
		{
			if(dragonAttackType == 'HeavyHitUp')
			{
				thePlayer.RaiseForceEvent('HeavyHitUp');
				thePlayer.DecreaseHealth(damage, true, NULL);
			}
			else
			{
				dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
				dragonHeadPos = dragonHead.GetWorldPosition();
				
				attackType = dragonAttackType;
				hitParams.outDamageMultiplier = 1.0f;
				//thePlayer.SetRotationTarget(dragonHead);
				thePlayer.HitPosition(dragonHeadPos, attackType, damage, true);
			}
		}
	}
	//DragonUpdate - this is the primary AI update function
	entry function DragonUpdate()
	{
		while(true)
		{
			Sleep(0.1);			
			dragonActionRand = ChoosEDragonFloorAction();
			PerformDragonAction(dragonActionRand);
			Sleep( 0.1 );
		}
	}
	entry function PlayHitAnim(hitEvent : name)
	{
		var randMaxDamageAnimPlayed : int;
		
		if(hitEvent == '')
		{
			Log("Dragon A3 ERROR: PlayHitAnim function has empty hit event name");
		}
		else
		{
			//Stop all attack's effects
			parent.StopAllDragonEffects();
			parent.RemoveAllDragonTimers();
		
			parent.SetIsPlayingDamageAnim(true);
			if(parent.CheckCanPlayDamageAnim())
			{
				parent.RaiseForceEvent(hitEvent);
				parent.WaitForBehaviorNodeDeactivation('hit_end', 6.0);
			}
			parent.SetIsPlayingDamageAnim(false);
		}
		Sleep(0.1);
		DragonUpdate();
	}
	//ChangeActionProbability - multiplies given dragonAction's probability by given probabilityMult
	function ChangeActionProbability(dragonAction : EDragonFloorAction, probabilityMult : float)
	{
		var currentProbabilityIndex : int;
		currentProbabilityIndex = (int)dragonAction;
		actionProbabilities[currentProbabilityIndex] = RoundF((float)actionProbabilities[currentProbabilityIndex] * probabilityMult);
	}
	//DragonActionsInitialize - fills dragonActions array
	function DragonActionsInitialize()
	{
		dragonActions.Resize(DFA_DragonActionListEnd);
		
		//edge actions
		dragonActions[(int)DFA_EdgeActionsStart] = DFA_EdgeActionsStart;
		dragonActions[(int)DFA_EdgeJawAttack1] = DFA_EdgeJawAttack1;
		dragonActions[(int)DFA_EdgeJawAttack2] = DFA_EdgeJawAttack2;
		dragonActions[(int)DFA_EdgeClawAttackLeft1] = DFA_EdgeClawAttackLeft1;
		dragonActions[(int)DFA_EdgeClawAttackRight1] = DFA_EdgeClawAttackRight1;
		dragonActions[(int)DFA_EdgeFireStart] = DFA_EdgeFireStart;
		dragonActions[(int)DFA_EdgeFireSides] = DFA_EdgeFireSides;
		dragonActions[(int)DFA_EdgeActionsEnd] = DFA_EdgeActionsEnd;
		
		//head actions
		dragonActions[(int)DFA_HeadActionsStart] = DFA_HeadActionsStart;
		dragonActions[(int)DFA_Head_AttackJaw] = DFA_Head_AttackJaw;
		dragonActions[(int)DFA_Head_AttackClaw] = DFA_Head_AttackClaw;
		dragonActions[(int)DFA_HeadFireStart] = DFA_HeadFireStart;
		dragonActions[(int)DFA_HeadToEdge] = DFA_HeadToEdge;
		dragonActions[(int)DFA_HeadActionsEnd] = DFA_HeadActionsEnd;

	}
	function ResetActionProbability()
	{
		actionProbabilities.Resize(DFA_DragonActionListEnd);
		//edge actions probabilities
		actionProbabilities[(int)DFA_EdgeActionsStart] = 0;
		actionProbabilities[(int)DFA_EdgeJawAttack1] = parent.def_probability_EdgeJawAttack1;
		actionProbabilities[(int)DFA_EdgeJawAttack2] = parent.def_probability_EdgeJawAttack2;
		actionProbabilities[(int)DFA_EdgeClawAttackLeft1] = parent.def_probability_EdgeClawAttackLeft1;
		actionProbabilities[(int)DFA_EdgeClawAttackRight1] = parent.def_probability_EdgeClawAttackRight1;
		actionProbabilities[(int)DFA_EdgeFireStart] = parent.def_probability_EdgeFireStart;
		actionProbabilities[(int)DFA_EdgeFireSides] = parent.def_probability_EdgeFireSides;
		actionProbabilities[(int)DFA_EdgeActionsEnd] = 0;
		
		//head actions probabilities
		actionProbabilities[(int)DFA_HeadActionsStart] = 0;
		actionProbabilities[(int)DFA_Head_AttackJaw] = parent.def_probability_HeadJawAttack1;
		actionProbabilities[(int)DFA_Head_AttackClaw] = parent.def_probability_HeadClawAttack1;
		actionProbabilities[(int)DFA_HeadFireStart] = parent.def_probability_HeadFireStart;
		actionProbabilities[(int)DFA_HeadToEdge] = parent.def_probability_HeadToEdge;
		actionProbabilities[(int)DFA_HeadActionsEnd] = 0;

	}
	//PerformDragonAction - performs given EDragonFloorAction, looped actions are performed for actionDuration time
	latent function PerformDragonAction(dragonAction: EDragonFloorAction)
	{
		var actionDuration : float;
		actionDuration = 0;
		thePlayer.KeepCombatMode();
		
		//Edge actions performance
		if(dragonAction == DFA_EdgeJawAttack1)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_attack_jaw1');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DFA_EdgeJawAttack2)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_attack_jaw2');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DFA_EdgeClawAttackLeft1)
		{
			parent.RaiseEvent('edge_attack_left_claw1');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
		}
		else if(dragonAction == DFA_EdgeClawAttackRight1)
		{
			parent.RaiseEvent('edge_attack_right_claw2');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
		}
		else if(dragonAction == DFA_EdgeFireStart)
		{
			parent.DragonLookatOff();
			actionDuration = ChoosEDragonFloorActionDuration(minFireAttackDuration, maxFireAttackDuration);
			parent.RaiseEvent('fire_start');
			parent.WaitForBehaviorNodeDeactivation('fire_loop', 6.0);
			if (actionDuration > 0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('fire_end');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DFA_EdgeFireSides)
		{
			parent.DragonLookatOff();
			actionDuration = ChoosEDragonFloorActionDuration(minFireAttackDuration, maxFireAttackDuration);
			parent.RaiseEvent('fire_sides');
			parent.WaitForBehaviorNodeDeactivation('fire_loop', 6.0);
			if (actionDuration > 0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('fire_end');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
			parent.DragonLookatOn();
		}
		
		//Head actions performance
		if(dragonAction == DFA_Head_AttackJaw)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('floor_attack_jaw');
			parent.WaitForBehaviorNodeDeactivation('head_idle', 6.0);
			parent.DragonLookatOn();
		}
		if(dragonAction == DFA_Head_AttackClaw)
		{
			parent.RaiseEvent('floor_attack_claw');
			parent.WaitForBehaviorNodeDeactivation('head_idle', 6.0);
		}
		if(dragonAction == DFA_HeadFireStart)
		{
			parent.DragonLookatOff();
			actionDuration = ChoosEDragonFloorActionDuration(minFireAttackDuration, maxFireAttackDuration);
			parent.RaiseEvent('fire_start');
			parent.WaitForBehaviorNodeDeactivation('fire_loop', 6.0);
			if (actionDuration > 0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('fire_end');
			parent.WaitForBehaviorNodeDeactivation('head_idle', 6.0);
			parent.DragonLookatOn();
		}
		if(dragonAction == DFA_HeadToEdge)
		{
			parent.ChangeDragonFloorState(DFS_Edge);
			parent.DragonLookatOff();
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('head_to_edge');
			parent.WaitForBehaviorNodeDeactivation('edge_idle', 6.0);
			parent.SetCanPlayDamageAnim(true);
			parent.DragonLookatOn();
		}
		Sleep(0.1);
		DragonUpdate();
	}
	//ResetDragonRandomActionArray - clears dragonActionsToRandomize array and sets it's size to 0
	function ResetDragonRandomActionArray()
	{
		dragonActionsToRandomize.Clear();
		dragonActionsToRandomize.Resize(0);
	}
	//RandomDragonActionArray - chooses random action from given array of actions
	function RandomDragonActionArray( dragonActionsToRandomize : array<EDragonFloorAction>)  : EDragonFloorAction
	{
		var dragonProbabilities : array<int>;
		var diceThrowResult, probabilitySum, currentActionProbability, i, arraySize : int;
		
		arraySize = dragonActionsToRandomize.Size();
		for (i = 0; i < arraySize; i+=1)
		{
			if((int)dragonActionsToRandomize[i] == 0)
			{
				Log("DRAGON BOSS ERROR: RandomDragonActionArray - invalid dragonActionsToRandomize[] action with index: " + i);
			}
			else
			{
				currentActionProbability = Max(actionProbabilities[(int)dragonActionsToRandomize[i]], 0);
				probabilitySum += currentActionProbability;
			}
		}
		diceThrowResult = Rand(probabilitySum) + 1;
		for (i = 0; i < arraySize; i+=1)
		{
			currentActionProbability = Max(actionProbabilities[(int)dragonActionsToRandomize[i]],0);
			if(diceThrowResult <=  currentActionProbability)
			{
				return dragonActionsToRandomize[i];
				//break;
			}
			else
			{
				diceThrowResult -= currentActionProbability;
			}
		}
	}
	//ChoosEDragonFloorAction - chooses EDragonFloorAction to perform 
	function ChoosEDragonFloorAction() : EDragonFloorAction
	{
		var dragonAction : EDragonFloorAction;
		
		//actions in dragon DS_TowerTop state
		if(parent.dragonState == DFS_Head)
		{
			parent.SetCanBeAttacked(true);
			parent.SetCanPlayDamageAnim(true);
			if(performedActionsNum > performedActionsNumMax)
			{
				performedActionsNum = 0;
				dragonAction = DFA_HeadToEdge;
				return dragonAction;
			}
			else
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DFA_Head_AttackJaw);
				dragonActionsToRandomize.PushBack(DFA_Head_AttackClaw);
				dragonActionsToRandomize.PushBack(DFA_HeadFireStart);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				performedActionsNum += 1;
				return dragonAction;
			}
		}
		if(parent.dragonState == DFS_Edge)
		{
			parent.SetCanBeAttacked(true);
			parent.SetCanPlayDamageAnim(true);
			if(parent.PlayerInRange("RightAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DFA_EdgeJawAttack1);
				dragonActionsToRandomize.PushBack(DFA_EdgeClawAttackRight1);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else if(parent.PlayerInRange("LeftAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DFA_EdgeClawAttackLeft1);
				dragonActionsToRandomize.PushBack(DFA_EdgeJawAttack1);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else if(parent.PlayerInRange("ForwardAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DFA_EdgeJawAttack2);
				dragonActionsToRandomize.PushBack(DFA_EdgeClawAttackLeft1);
				dragonActionsToRandomize.PushBack(DFA_EdgeClawAttackRight1);
				dragonActionsToRandomize.PushBack(DFA_EdgeFireStart);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DFA_EdgeFireSides);
				dragonActionsToRandomize.PushBack(DFA_EdgeFireStart);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
		}
		else
		{
			Log("RandomizEDragonFloorAction ERROR: wrong dragon state (EDragonFloorState)");
		}
	}
	function ChoosEDragonFloorActionDuration(minActionDuration : float, maxActionDuration : float) : float
	{
		var actionDuration : float;
		actionDuration = minActionDuration + RandF()*maxActionDuration;
		return actionDuration;
	}
	entry function DragonDeath()
	{
		FactsAdd( "q307_dragon_end", 1 );
	}
}
state EdgeFightEnd in CDragonA3Floorr
{
	entry function DragonTopStage()
	{
		theHud.m_hud.HideBossHealth();
		
		FactsAdd( "q307_dragon_top", 1 );
	}
}
*/