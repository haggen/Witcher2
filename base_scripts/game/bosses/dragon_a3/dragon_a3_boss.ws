/*enum EDragonAction
{
	//Probability driven actions
	//ground actions
	DA_GroundActionsStart,
	DA_WalkRight,
	DA_WalkLeft,
	DA_WallWalkLeft,
	DA_WallWalkRight,
	DA_StartFlying,
	DA_StandUp,
	DA_FireSideAttack,
	DA_WingAttack,
	DA_GroundActionsEnd,
	
	//aerial actions
	DA_AerialActionsStart,
	DA_StopFlying,
	DA_FlyLeftShort,
	DA_FlyRightShort,
	DA_Fly180,
	DA_FlyAttack,
	DA_AerialActionsEnd,
	
	//up actions
	DA_UpActionsStart,
	DA_UpWalkRight,
	DA_UpWalkLeft,
	DA_UpToFly,
	DA_UpActionsEnd,
	
	//wallwalk actions
	DA_WallWalkActionsStart,
	DA_WallWalkEnd,
	DA_WallWalkActionsEnd,
	
	//fly side actions
	DA_FlySideActionsStart,
	DA_FlySideEnd,
	DA_FlySideFireAttack,
	DA_FlySideActionsEnd,
	
	//triggered attacks
	DA_TriggeredAttacksStart,
	DA_GroundAttackJawForward1,
	DA_GroundAttackJawForward2,
	DA_GroundAttackClawForward1,
	DA_GroundAttackClawForward2,
	DA_GroundLeftClawAttack,
	DA_GroundLeftJawAttack,
	DA_GroundRightClawAttack,
	DA_GroundRightJawAttack,
	DA_GroundFireAttack,
	DA_GroundFireUpAttack,
	DA_FlyFireAttack,
	DA_WallWalkClawAttack,
	DA_WallWalkTailAttack,
	DA_WallWalkCloseAttack,
	DA_UpAttackLeft,
	DA_UpAttackRight,
	DA_UpAttackFront,
	DA_TriggeredAttacksEnd,
		
	DA_DragonActionListEnd,

};
enum EDragonState
{
	DS_TowerTop,
	DS_Flying,
	DS_UpState,
	DS_WallWalkRight,
	DS_WallWalkLeft,
	DS_FlyLeft,
	DS_FlyRight
};
//MSZ CDragonA3 class used for dragon AI management
class CDragonA3a extends CDragonA3Base
{
	//Default actions' probability values (editable in dragon template). Used to store predefinied values while calculating actions probability
	//all probabilities are weights and take values from 0 to +inf.
	editable var 	
					//Ground Actions
					def_probability_WalkRight,
					def_probability_WalkLeft,
					def_probability_WallWalkLeft,
					def_probability_WallWalkRight,
					def_probability_StartFlying,
					def_probability_StandUp,
					def_probability_FireSideAttack,
					def_probability_WingAttack,			
										
					//Aerial Actions
					def_probability_StopFlying,
					def_probability_FlyLeftShort,
					def_probability_FlyRightShort,
					def_probability_Fly180,
					def_probability_FlyAttack,
					
					//Up Actions
					def_probability_UpWalkRight,
					def_probability_UpWalkLeft,
					def_probability_UpToFly,

					//Wallwalk Actions
					def_probability_WallWalkEnd,
					
					//FlySide Actions
					def_probability_FlySideEnd,
					def_probability_FlySideFireAttack,
 
					//Triggered Attacks Actions
					def_probability_JawForward1,
					def_probability_JawForward2,
					def_probability_ClawForward1,
					def_probability_ClawForward2,
					def_probability_LeftClawAttack,
					def_probability_LeftJawAttack,
					def_probability_RightClawAttack,
					def_probability_RightJawAttack, 
					def_probability_GroundFireAttack,
					def_probability_GroundUpFireAttack,	
					def_probability_FlyFireAttack,
					def_probability_WallWalkClawAttack,
					def_probability_WallWalkTailAttack,
					def_probability_WallWalkCloseAttack,
					def_probability_UpAttackLeft,	
					def_probability_UpAttackRight,
					def_probability_UpAttackFront	

														: int;
	
	//Ground Actions
	default def_probability_WalkRight 			= 10;
	default def_probability_WalkLeft 			= 10;
	default def_probability_WallWalkLeft 		= 20;
	default def_probability_WallWalkRight 		= 20;
	default def_probability_StartFlying 		= 15;
	default def_probability_StandUp 			= 10;
	default	def_probability_FireSideAttack 		= 20;
	default def_probability_WingAttack			= 15;
	
	//Aerial Actions
	default def_probability_StopFlying 			= 20;
	default def_probability_FlyLeftShort 		= 10;
	default def_probability_FlyRightShort 		= 10;
	default def_probability_Fly180 				= 10;
	default def_probability_FlyAttack			= 10;
	
	//Up Actions
	default def_probability_UpWalkRight 		= 10;
	default def_probability_UpWalkLeft 			= 10;
	default def_probability_UpToFly				= 10;
	
	//Wallwalk Actions
	
	default def_probability_WallWalkEnd			= 10;
	//FlySide Actions
	default def_probability_FlySideEnd			= 20;
	default def_probability_FlySideFireAttack	= 10;
	
	//Triggered Attacks Actions
	default def_probability_JawForward1			= 20;
	default def_probability_JawForward2			= 20;
	default def_probability_ClawForward1		= 20;
	default def_probability_ClawForward2		= 20;
	default def_probability_LeftClawAttack		= 20;
	default def_probability_LeftJawAttack		= 20;
	default def_probability_RightClawAttack		= 20;
	default def_probability_RightJawAttack		= 20;
	default	def_probability_GroundFireAttack 	= 10;
	default def_probability_GroundUpFireAttack 	= 10;
	default def_probability_FlyFireAttack		= 10;
	default def_probability_WallWalkClawAttack	= 10;
	default def_probability_WallWalkTailAttack	= 10;
	default def_probability_WallWalkCloseAttack	= 10; 
	default def_probability_UpAttackLeft		= 10;
	default def_probability_UpAttackRight		= 10;
	default def_probability_UpAttackFront		= 10;	
	
	var dragonDamageNormal, dragonDamageFirePerSecond : float;
	var dragonFireUpdate : float;
	
	default dragonFireUpdate = 0.3;
	
	var dragonState : EDragonState;
	var damageAnimsPlayed, minDamageAnimsToFly, maxDamageAnimsToFly : int;
	default dragonState = DS_TowerTop;
	
	default damageAnimsPlayed = 0;
	default minDamageAnimsToFly = 5;
	default maxDamageAnimsToFly = 6;
	
	var playerGrab : bool;
	var interaction : CDragonGrabEdge;
	default playerGrab = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var dragonHead : CDragonHead;
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		theHud.m_hud.SetBossName( "DRAGON" );
		theHud.HudTargetActorEx( dragonHead, true );
		theHud.m_hud.SetBossHealthPercent( dragonHead.dragonShowHealth );
		
		this.AddTimer('DragonInitialize', 2.0, false);
		//this.EnablePhysicalMovement(false);
		DragonUpdate();
	}
	function SetGrabInteraction(grabInteraction : CDragonGrabEdge)
	{
		interaction = grabInteraction;
	}
	function GetGrabInteraction() : CDragonGrabEdge
	{
		return interaction;
	}
	function SetWindGrabInteraction() : CDragonGrabEdge
	{
		var finalInteraction : CDragonGrabEdge;
		var interactionGrabPoint : CEffectDummyPoint;
		var allInteractionsNodes : array<CNode>;
		var allInteractions : array<CDragonGrabEdge>;
		var interactionDistances : array<float>;
		var dragonGrabPointPos, interactionGrabPointPos : Vector;
		var currentInteractionDistance, minInteractionDistance : float;
		var sizeInteractions, sizeDistances, i, j, minIndex : int;
		minIndex = 0;
		theGame.GetNodesByTag('dragon_edge_inter', allInteractionsNodes);
		sizeInteractions = allInteractionsNodes.Size();
		interactionDistances.Resize(sizeInteractions);
		allInteractions.Resize(sizeInteractions);
		for (i = 0; i < sizeInteractions; i+=1)
		{
			allInteractions[i] = (CDragonGrabEdge)allInteractionsNodes[i];
			interactionGrabPoint = (CEffectDummyPoint)allInteractions[i].GetComponent("GrabPoint");
			interactionDistances[i] = VecDistance2D(thePlayer.GetWorldPosition(), interactionGrabPoint.GetWorldPosition());
		}
		finalInteraction = allInteractions[0];
		for (i = 0; i < sizeInteractions; i += 1)
		{
			currentInteractionDistance = interactionDistances[i];
			minInteractionDistance = interactionDistances[minIndex];
			if(currentInteractionDistance < minInteractionDistance)
			{
				minIndex = i;
				finalInteraction = allInteractions[i];
			}
		}
		return finalInteraction;
	}
	function SetPlayerGrab(flag : bool)
	{
		playerGrab = flag;
	}
	function GetPlayerGrab() : bool
	{
		return playerGrab;
	}
	//ChangeDragonState - changes EDragonState, informs AI if dragon is flying or siting on the tower edge.
	function ChangeDragonState(newDragonState : EDragonState)
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
		
		if(dragonHead.dragonShowHealth <= 0)
		{
			dragonHead.dragonShowHealth = 0;
			dragonHead.EnterDead();
		}
	}
	function GetDragonHitEvent(canPlayDamageAnim : bool) : name
	{
		var eventName : name;
		if(canPlayDamageAnim)
		{
			if(PlayerInRange("LeftAttack1"))
			{
				eventName = 'hit_left_forced';
				return eventName;
			}
			else if(PlayerInRange("RightAttack1"))
			{
				eventName = 'hit_right_forced';
				return eventName;
			}
			else
			{
				eventName = 'hitforced1';
				return eventName;
			}
		}
		else
		{
			if(PlayerInRange("LeftAttack1"))
			{
				eventName = 'hit_left';
				return eventName;
			}
			else if(PlayerInRange("RightAttack1"))
			{
				eventName = 'hit_right';
				return eventName;
			}
			else
			{
				eventName = 'hit1';
				return eventName;
			}
		}
	}
	timer function DragonInitialize(timeDelta : float)
	{
		var dragonHead : CDragonHead;
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		thePlayer.EnablePhysicalMovement(true);
		//thePlayer.EnablePathEngineAgent(false);
		dragonDamageNormal = dragonHead.GetCharacterStats().GetAttribute('damage_attack');
		dragonDamageFirePerSecond = dragonHead.GetCharacterStats().GetAttribute('damage_fire_per_sec');
		DragonLookatOn();
	}
	//Timers used for looped fire attacks
	timer function FireCone(timeDelta : float)
	{
		//var damage : float;
		//damage = dragonDamageFirePerSecond * dragonFireUpdate;
		theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
		theCamera.RaiseEvent('Camera_ShakeHit');
		if(PlayerInRange("FireAttack1") && !playerGrab)
		{
			//TODO: what is the burn duration?? and what is the damage if in cone range.
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( dragonDamageFirePerSecond, dragonDamageFirePerSecond, 5, 5 ) );
			//thePlayer.DecreaseHealth(damage, true, NULL);
		}
	}
	timer function FireSector1(timeDelta : float)
	{
		//var damage : float;
		//damage = dragonDamageFirePerSecond*dragonFireUpdate;
		if(PlayerInRange("MiddleSector"))
		{
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( dragonDamageFirePerSecond, dragonDamageFirePerSecond, 5, 5 ) );
			//thePlayer.DecreaseHealth(damage, true, NULL);
		}
	}
	timer function FireSector2(timeDelta : float)
	{
		//var damage : float;
		//damage = dragonDamageFirePerSecond*dragonFireUpdate;
		if(PlayerInRange("CloseSector"))
		{
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( dragonDamageFirePerSecond, dragonDamageFirePerSecond, 5, 5 ) );
			//thePlayer.DecreaseHealth(damage, true, NULL);
			if( playerGrab)
			{
				if(interaction)
				{
					//Geralt falls down when hit while hanging on the tower edge
					interaction.FallDown();
				}
			}
		}
	}
	function RemoveAllDragonTimers()
	{
		RemoveTimer('FireCone');
		RemoveTimer('FireSector1');
		RemoveTimer('FireSector2');
	}
	function StopAllDragonEffects()
	{
		StopEffect('fire_breath_1');
		StopEffect('sector2_fire');
		StopEffect('sector1_fire');
		StopEffect('wind_attack');
	}
	/*function TestBehaviour()
	{
		thePlayer.AttachBehavior('witcher_wing');
	}*//*
}
state DragonDefault in CDragonA3a
{
	var dragonActionRand : EDragonAction;
	var actionDuration, maxActionDuration, minActionDuration, minFireAttackDuration, maxFireAttackDuration, minShortFireAttackDuration, maxShortFireAttackDuration, minWingAttackDuration, maxWingAttackDuration : float;
	var currentHitEventName : name;		
	var actionProbabilities : array<int>;
	var dragonActions : array<EDragonAction>;
	var dragonActionsToRandomize : array<EDragonAction>;
	var performedActionsNum, performedActionsNumReset: int;
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
	default performedActionsNumReset = 5;
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
		else if(animEventName == 'fly_attack_1' && animEventType == AET_Tick)
		{
			if(parent.PlayerInRange("CloseSector"))
			{
				DragonAttack('HeavyHitUp', true);
			}
		}
		else if(animEventName == 'fly_attack_2' && animEventType == AET_Tick)
		{
			if(parent.PlayerInRange("MiddleSector")&&!parent.PlayerInRange("CloseSector"))
			{
				DragonAttack('HeavyHitUp', true);
			}
		}
		else if(animEventName == 'fly_attack_3' && animEventType == AET_Tick)
		{
			if(parent.PlayerInRange("FarSector")&&!parent.PlayerInRange("MiddleSector"))
			{
				DragonAttack('HeavyHitUp', true);
			}
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
		else if(animEventName == 'fire_sector1_start' && animEventType == AET_Tick)
		{
			parent.AddTimer('FireSector1', parent.dragonFireUpdate, true);
			parent.PlayEffect('sector1_fire');
		}
		else if(animEventName == 'fire_sector2_start' && animEventType == AET_Tick)
		{
			parent.AddTimer('FireSector2', parent.dragonFireUpdate, true);
			parent.PlayEffect('sector2_fire');
		}
		else if(animEventName == 'fire_stop' && animEventType == AET_Tick)
		{
			parent.RemoveTimer('FireCone');
			parent.StopEffect('fire_breath_1');
		}
		else if(animEventName == 'wind_start' && animEventType == AET_Tick)
		{
			parent.PlayEffect('wind_attack');
			parent.interaction = parent.SetWindGrabInteraction();
			DragonAttack('Attack_boss_t1', false);
			//MSZ: Tymczasowo wylaczam wykonanie ataku - powoduje czasem bloker
			/*if(parent.PlayerInRange("WindAttack1"))
			{
				parent.interaction.FallFromTop();
			}
			else
			{
				parent.interaction.WindHit();
			}*//*
			
		}
		else if(animEventName == 'fire_sectors_stop' && animEventType == AET_Tick)
		{
			parent.RemoveTimer('FireSector1');
			parent.RemoveTimer('FireSector2');
			parent.StopEffect('sector2_fire');
			parent.StopEffect('sector1_fire');
		}
		else if(animEventName == 'wind_stop' && animEventType == AET_Tick)
		{
			parent.StopEffect('wind_attack');
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
		if(dragonActionRand == DA_GroundAttackJawForward1 && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundAttackJawForward2 && ( parent.PlayerInRange("ForwardAttack1") || parent.PlayerInRange("LeftAttack1") || parent.PlayerInRange("RightAttack1")))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundAttackClawForward1 && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundAttackClawForward2 && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundLeftClawAttack && parent.PlayerInRange("LeftAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundLeftClawAttack && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundLeftClawAttack && parent.PlayerInRange("CloseSector"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundLeftJawAttack && parent.PlayerInRange("LeftAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundRightClawAttack && parent.PlayerInRange("RightAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundRightClawAttack && parent.PlayerInRange("CloseSector"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundRightClawAttack && parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_GroundRightJawAttack && parent.PlayerInRange("RightAttack1"))
		{
			return true;
		}
		else if(dragonActionRand == DA_WallWalkClawAttack && parent.PlayerInRange("CloseSector"))
		{
			return true;
		}
		else if(dragonActionRand == DA_WallWalkCloseAttack && parent.PlayerInRange("CloseSector"))
		{
			return true;
		}
		else if(dragonActionRand == DA_WallWalkTailAttack && parent.PlayerInRange("MiddleSector"))
		{
			return true;
		}
		else if(dragonActionRand == DA_UpAttackLeft && parent.PlayerInRange("LeftAttack2"))
		{
			return true;
		}
		else if(dragonActionRand == DA_UpAttackRight && parent.PlayerInRange("RightAttack2"))
		{
			return true;
		}
		else if(dragonActionRand == DA_UpAttackFront && parent.PlayerInRange("FarSector"))
		{
			return true;
		}
		else if (dragonActionRand == DA_WingAttack && parent.PlayerInRange("FarSector"))
		{
			return true;
		}
		else if (dragonActionRand == DA_WingAttack && parent.PlayerInRange("MiddleSector"))
		{
			return true;
		}
		else if (dragonActionRand == DA_WingAttack && parent.PlayerInRange("CloseSector"))
		{
			return true;
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
				if( parent.playerGrab)
				{
					if(parent.interaction)
					{
						//Geralt falls down when hit while hanging on the tower edge
						parent.interaction.FallDown();
					}
				}
				else
				{
					thePlayer.HitPosition(dragonHeadPos, attackType, damage, true);
				}
			}
		}
	}
	//DragonUpdate - this is the primary AI update function
	entry function DragonUpdate()
	{
		while(true)
		{
			Sleep(0.1);
			dragonActionRand = ChooseDragonAction();
			if(TempIsActionAnAttack(dragonActionRand))
			{
				PerformDragonAttack(dragonActionRand);
			}
			else
			{
				PerformDragonAction(dragonActionRand);
			}
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
			randMaxDamageAnimPlayed = 1 + Rand(parent.maxDamageAnimsToFly) + parent.minDamageAnimsToFly;
			
			//Stop all attack's effects
			parent.StopAllDragonEffects();
			parent.RemoveAllDragonTimers();
		
			parent.SetIsPlayingDamageAnim(true);
			if(!parent.CheckCanPlayDamageAnim())
			{
				parent.SetBehaviorVariable("hit_weight", 6.0);
				Sleep(0.1);
				parent.RaiseEvent(hitEvent);
				parent.WaitForBehaviorNodeDeactivation('hit_end', 6.0);
				parent.SetBehaviorVariable("hit_weight", 0.0);
				parent.damageAnimsPlayed += 1;
			}
			else if(parent.CheckCanPlayDamageAnim() && parent.damageAnimsPlayed <= randMaxDamageAnimPlayed)
			{
				parent.RaiseForceEvent(hitEvent);
				parent.WaitForBehaviorNodeDeactivation('hit_end', 6.0);
				parent.ChangeDragonState(DS_TowerTop);
				parent.damageAnimsPlayed += 1;
			}
			else if(parent.CheckCanPlayDamageAnim() && parent.damageAnimsPlayed > randMaxDamageAnimPlayed)
			{
				parent.damageAnimsPlayed = 0;
				parent.RaiseForceEvent('hitforced_to_fly');
				parent.WaitForBehaviorNodeDeactivation('hit_end', 6.0);
				parent.ChangeDragonState(DS_Flying);
			}
			parent.SetIsPlayingDamageAnim(false);
		}
		Sleep(0.1);
		DragonUpdate();
	}
	//ChangeActionProbability - multiplies given dragonAction's probability by given probabilityMult
	function ChangeActionProbability(dragonAction : EDragonAction, probabilityMult : float)
	{
		var currentProbabilityIndex : int;
		currentProbabilityIndex = (int)dragonAction;
		actionProbabilities[currentProbabilityIndex] = RoundF((float)actionProbabilities[currentProbabilityIndex] * probabilityMult);
	}
	//DragonActionsInitialize - fills dragonActions array
	function DragonActionsInitialize()
	{
		dragonActions.Resize(DA_DragonActionListEnd);
		//ground actions
		dragonActions[(int)DA_GroundActionsStart] = DA_GroundActionsStart;
		dragonActions[(int)DA_WalkRight] = DA_WalkRight;
		dragonActions[(int)DA_WalkLeft] = DA_WalkLeft;
		dragonActions[(int)DA_WallWalkLeft] = DA_WallWalkLeft;
		dragonActions[(int)DA_WallWalkRight] = DA_WallWalkRight;
		dragonActions[(int)DA_StartFlying] = DA_StartFlying;
		dragonActions[(int)DA_StandUp] = DA_StandUp;
		dragonActions[(int)DA_FireSideAttack] = DA_FireSideAttack;
		dragonActions[(int)DA_WingAttack] = DA_WingAttack;
		dragonActions[(int)DA_GroundActionsEnd] = DA_GroundActionsEnd;
		
		//aerial actions
		dragonActions[(int)DA_AerialActionsStart] = DA_AerialActionsStart;
		dragonActions[(int)DA_StopFlying] = DA_StopFlying;
		dragonActions[(int)DA_FlyLeftShort] = DA_FlyLeftShort;
		dragonActions[(int)DA_FlyRightShort] = DA_FlyRightShort;
		dragonActions[(int)DA_Fly180] = DA_Fly180;
		dragonActions[(int)DA_FlyAttack] = DA_FlyAttack;
		dragonActions[(int)DA_AerialActionsEnd] = DA_AerialActionsEnd;
		
		//up actions
		dragonActions[(int)DA_UpActionsStart] = DA_UpActionsStart;
		dragonActions[(int)DA_UpWalkRight] = DA_UpWalkRight;
		dragonActions[(int)DA_UpWalkLeft] = DA_UpWalkLeft;
		dragonActions[(int)DA_UpToFly] = DA_UpToFly;
		dragonActions[(int)DA_UpActionsEnd] = DA_UpActionsEnd;
		
		//wallwalk actions
		dragonActions[(int)DA_WallWalkActionsStart] = DA_WallWalkActionsStart;
		dragonActions[(int)DA_WallWalkEnd] = DA_WallWalkEnd;
		dragonActions[(int)DA_WallWalkActionsEnd] = DA_WallWalkActionsEnd;
		
		//fly side actions
		dragonActions[(int)DA_FlySideActionsStart] = DA_FlySideActionsStart;
		dragonActions[(int)DA_FlySideEnd] = DA_FlySideEnd;
		dragonActions[(int)DA_FlySideFireAttack] = DA_FlySideFireAttack;
		dragonActions[(int)DA_FlySideActionsEnd] = DA_FlySideActionsEnd;
		
		//triggered attacks Actions
		dragonActions[(int)DA_TriggeredAttacksStart] = DA_TriggeredAttacksStart;
		dragonActions[(int)DA_GroundAttackJawForward1] = DA_GroundAttackJawForward1;
		dragonActions[(int)DA_GroundAttackJawForward2] = DA_GroundAttackJawForward2;
		dragonActions[(int)DA_GroundAttackClawForward1] = DA_GroundAttackClawForward1;
		dragonActions[(int)DA_GroundAttackClawForward2] = DA_GroundAttackClawForward2;
		dragonActions[(int)DA_GroundLeftClawAttack] = DA_GroundLeftClawAttack;
		dragonActions[(int)DA_GroundLeftJawAttack] = DA_GroundLeftJawAttack;
		dragonActions[(int)DA_GroundRightClawAttack] = DA_GroundRightClawAttack;
		dragonActions[(int)DA_GroundRightJawAttack] = DA_GroundRightJawAttack;
		dragonActions[(int)DA_GroundFireAttack] = DA_GroundFireAttack;
		dragonActions[(int)DA_GroundFireUpAttack] = DA_GroundFireUpAttack;
		dragonActions[(int)DA_FlyFireAttack] = DA_FlyFireAttack;
		dragonActions[(int)DA_WallWalkClawAttack] = DA_WallWalkClawAttack;
		dragonActions[(int)DA_WallWalkTailAttack] = DA_WallWalkTailAttack;
		dragonActions[(int)DA_WallWalkCloseAttack] = DA_WallWalkCloseAttack;
		dragonActions[(int)DA_UpAttackLeft] = DA_UpAttackLeft;
		dragonActions[(int)DA_UpAttackRight] = DA_UpAttackRight;
		dragonActions[(int)DA_UpAttackFront] = DA_UpAttackFront;
		dragonActions[(int)DA_TriggeredAttacksEnd] = DA_TriggeredAttacksEnd;
	}
	function ResetActionProbability()
	{
		actionProbabilities.Resize(DA_DragonActionListEnd);
		//ground actions probabilities
		actionProbabilities[(int)DA_GroundActionsStart] = 0;
		actionProbabilities[(int)DA_WalkRight] = parent.def_probability_WalkRight;
		actionProbabilities[(int)DA_WalkLeft] = parent.def_probability_WalkLeft;
		actionProbabilities[(int)DA_WallWalkLeft] = parent.def_probability_WallWalkLeft;
		actionProbabilities[(int)DA_WallWalkRight] = parent.def_probability_WallWalkRight;
		actionProbabilities[(int)DA_StartFlying] = parent.def_probability_StartFlying;
		actionProbabilities[(int)DA_StandUp] = parent.def_probability_StandUp;
		actionProbabilities[(int)DA_FireSideAttack] = parent.def_probability_FireSideAttack;
		actionProbabilities[(int)DA_WingAttack] = parent.def_probability_WingAttack;
		actionProbabilities[(int)DA_GroundActionsEnd] = 0;
				
		//aerial actions probabilities
		actionProbabilities[(int)DA_AerialActionsStart] = 0;
		actionProbabilities[(int)DA_StopFlying] = parent.def_probability_StopFlying;
		actionProbabilities[(int)DA_FlyLeftShort] = parent.def_probability_FlyLeftShort;
		actionProbabilities[(int)DA_FlyRightShort] = parent.def_probability_FlyRightShort;
		actionProbabilities[(int)DA_Fly180] = parent.def_probability_Fly180;
		actionProbabilities[(int)DA_FlyAttack] = parent.def_probability_FlyAttack;
		actionProbabilities[(int)DA_AerialActionsEnd] = 0;
		
		//up actions probabilities
		actionProbabilities[(int)DA_UpActionsStart] = 0;
		actionProbabilities[(int)DA_UpWalkRight] = parent.def_probability_UpWalkRight;
		actionProbabilities[(int)DA_UpWalkLeft] = parent.def_probability_UpWalkLeft;
		actionProbabilities[(int)DA_UpToFly] = parent.def_probability_UpToFly;
		actionProbabilities[(int)DA_UpActionsEnd] = 0;
		
		//wallwalk actions probabilities
		actionProbabilities[(int)DA_WallWalkActionsStart] = 0;
		actionProbabilities[(int)DA_WallWalkEnd] = parent.def_probability_WallWalkEnd;
		actionProbabilities[(int)DA_WallWalkActionsEnd] = 0;
		
		//fly side actions probabilities
		actionProbabilities[(int)DA_FlySideActionsStart] = 0;
		actionProbabilities[(int)DA_FlySideEnd] = parent.def_probability_FlySideEnd;
		actionProbabilities[(int)DA_FlySideFireAttack] = parent.def_probability_FlySideFireAttack;
		actionProbabilities[(int)DA_FlySideActionsEnd] = 0;
		
		//triggered attacks Actions
		actionProbabilities[(int)DA_TriggeredAttacksStart] = 0;
		actionProbabilities[(int)DA_GroundAttackJawForward1] = parent.def_probability_JawForward1;
		actionProbabilities[(int)DA_GroundAttackJawForward2] = parent.def_probability_JawForward2;
		actionProbabilities[(int)DA_GroundAttackClawForward1] = parent.def_probability_ClawForward1;
		actionProbabilities[(int)DA_GroundAttackClawForward2] = parent.def_probability_ClawForward2;
		actionProbabilities[(int)DA_GroundLeftClawAttack] = parent.def_probability_LeftClawAttack;
		actionProbabilities[(int)DA_GroundLeftJawAttack] = parent.def_probability_LeftJawAttack;
		actionProbabilities[(int)DA_GroundRightClawAttack] = parent.def_probability_RightClawAttack;
		actionProbabilities[(int)DA_GroundRightJawAttack] = parent.def_probability_RightJawAttack;
		actionProbabilities[(int)DA_GroundFireAttack] = parent.def_probability_GroundFireAttack;
		actionProbabilities[(int)DA_GroundFireUpAttack] = parent.def_probability_GroundUpFireAttack;
		actionProbabilities[(int)DA_FlyFireAttack] = parent.def_probability_FlyFireAttack;
		actionProbabilities[(int)DA_WallWalkClawAttack] = parent.def_probability_WallWalkClawAttack;
		actionProbabilities[(int)DA_WallWalkTailAttack] = parent.def_probability_WallWalkTailAttack;
		actionProbabilities[(int)DA_WallWalkCloseAttack] = parent.def_probability_WallWalkCloseAttack;
		actionProbabilities[(int)DA_UpAttackLeft] = parent.def_probability_UpAttackLeft;
		actionProbabilities[(int)DA_UpAttackRight] = parent.def_probability_UpAttackRight;
		actionProbabilities[(int)DA_UpAttackFront] = parent.def_probability_UpAttackFront;
		actionProbabilities[(int)DA_TriggeredAttacksEnd] = 0;

	}
	//PerformDragonAction - performs given EDragonAction, looped actions are performed for actionDuration time
	latent function PerformDragonAction(dragonAction: EDragonAction)
	{
		var actionDuration : float;
		actionDuration = 0;
		thePlayer.KeepCombatMode();
		//Ground Actions Performance
		/*switch(dragonAction)
		{
			case DA_WalkRight :
				break;
		}*//*
		if(dragonAction == DA_WalkRight)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('walk_right');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.SetCanPlayDamageAnim(true);
		}
		else if(dragonAction == DA_WalkLeft)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('walk_left');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.SetCanPlayDamageAnim(true);
		}
		else if(dragonAction == DA_WallWalkLeft)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minActionDuration, maxActionDuration);
			parent.RaiseEvent('wall_walk_left');
			parent.WaitForBehaviorNodeDeactivation('walk_loop', 6.0);
			parent.ChangeDragonState(DS_WallWalkLeft);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}
			ChangeActionProbability(DA_WallWalkLeft, probabilityDecreaseMult);
		}
		else if(dragonAction == DA_WallWalkRight)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minActionDuration, maxActionDuration);
			parent.RaiseEvent('wall_walk_right');
			parent.WaitForBehaviorNodeDeactivation('walk_loop', 6.0);
			parent.ChangeDragonState(DS_WallWalkRight);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}
			ChangeActionProbability(DA_WallWalkRight, probabilityDecreaseMult);
		}
		else if(dragonAction == DA_StartFlying)
		{
			parent.RaiseEvent('fly_start');
			parent.WaitForBehaviorNodeDeactivation('fly_state', 6.0);
			parent.ChangeDragonState(DS_Flying);
			ChangeActionProbability(DA_StopFlying, probabilityDecreaseMult);
		}
		else if(dragonAction == DA_StandUp)
		{
			parent.RaiseEvent('to_up');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
			parent.ChangeDragonState(DS_UpState);
		}
		else if(dragonAction == DA_FireSideAttack)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minFireAttackDuration, maxFireAttackDuration);
			parent.RaiseEvent('edge_fire_sides_start');
			parent.WaitForBehaviorNodeDeactivation('fire_sides_loop', 6.0);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('edge_fire_sides_stop');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_WingAttack)
		{
			parent.RaiseEvent('edge_wing_start');
			parent.WaitForBehaviorNodeDeactivation('wing_loop', 6.0);
			Sleep(5.0);
			parent.RaiseEvent('edge_wing_stop');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			Sleep(2.0);
		}
		//Aerial Actions Performance
		else if(dragonAction == DA_StopFlying)
		{
			parent.RaiseEvent('fly_end');
			parent.ChangeDragonState(DS_TowerTop);
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			
		}
		else if(dragonAction == DA_FlyLeftShort)
		{
			actionDuration = ChooseDragonActionDuration(minActionDuration, maxActionDuration);
			parent.RaiseEvent('fly_left_short');
			parent.WaitForBehaviorNodeDeactivation('fly_loop', 6.0);
			parent.ChangeDragonState(DS_FlyLeft);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}		
		}
		else if(dragonAction == DA_FlyRightShort)
		{
			actionDuration = ChooseDragonActionDuration(minActionDuration, maxActionDuration);
			parent.RaiseEvent('fly_right_short');
			parent.WaitForBehaviorNodeDeactivation('fly_loop', 6.0);
			parent.ChangeDragonState(DS_FlyRight);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}	
		}
		else if(dragonAction == DA_Fly180)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('fly_180');
			parent.WaitForBehaviorNodeDeactivation('fly_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_FlyAttack)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('fly_attack1');
			parent.WaitForBehaviorNodeDeactivation('fly_state', 6.0);
			parent.DragonLookatOn();
		}
		//Up Actions Performance
		else if(dragonAction == DA_UpWalkRight)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_UpWalkLeft)
		{
			parent.RaiseEvent('up_walk_left');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_UpToFly)
		{
			parent.RaiseEvent('up_end');
			parent.ChangeDragonState(DS_Flying);
			parent.WaitForBehaviorNodeDeactivation('fly_state', 6.0);
		}
		//Wallwalk Actions Performance
		else if(dragonAction == DA_WallWalkEnd)
		{	
			parent.RaiseEvent('wall_walk_end');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.ChangeDragonState(DS_TowerTop);
			parent.DragonLookatOn();
		}
		//Flyside Actions Performance
		else if(dragonAction == DA_FlySideEnd)
		{
			parent.RaiseEvent('fly_end');
			parent.WaitForBehaviorNodeDeactivation('fly_state', 6.0);
			parent.ChangeDragonState(DS_Flying);
			ChangeActionProbability(DA_FlyLeftShort, probabilityDecreaseMult);
			ChangeActionProbability(DA_FlyRightShort, probabilityDecreaseMult);
		}
		else if(dragonAction == DA_FlySideFireAttack)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minFireAttackDuration, maxFireAttackDuration);
			parent.RaiseEvent('fire_attack_start');
			parent.WaitForBehaviorNodeDeactivation('fire_sides_loop', 6.0);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('fire_attack_stop');
			parent.WaitForBehaviorNodeDeactivation('fire_end', 6.0);
			ChangeActionProbability(DA_FlySideEnd, probabilityIncreaseMult);
			ChangeActionProbability(DA_FlySideFireAttack, probabilityDecreaseMult);
			parent.DragonLookatOn();
			PerformDragonAction(DA_FlySideEnd);
		}
		//Deterministic Actions Performance
		/*
		else if(dragonAction == DA_GroundAttackJawForward1)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundAttackJawForward2)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundAttackClawForward1)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundAttackClawForward2)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundLeftClawAttack)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundLeftJawAttack)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundRightClawAttack)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}
		else if(dragonAction == DA_GroundRightJawAttack)
		{
			parent.RaiseEvent('up_walk_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
		}*//*
		performedActionsNum += 1;
		if(performedActionsNum >= performedActionsNumReset)
		{
			performedActionsNum = 0;
			ResetActionProbability();
		}
		Sleep(0.1);
		DragonUpdate();
	}
	//PerformDragonAttack - temporary function for performing attacks - should be a part of PerformDragonAction
	latent function PerformDragonAttack(dragonAction: EDragonAction)
	{
		var actionDuration : float;
		actionDuration = 0;
		thePlayer.KeepCombatMode();
		if(dragonAction == DA_GroundAttackJawForward1)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_jaw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_GroundAttackJawForward2)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_jaw_attack2');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_GroundAttackClawForward1)
		{
			parent.RaiseEvent('edge_claw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
		}
		else if(dragonAction == DA_GroundAttackClawForward2)
		{
			parent.RaiseEvent('edge_claw_attack2');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
		}
		else if(dragonAction == DA_GroundLeftClawAttack)
		{
			parent.RaiseEvent('edge_left_claw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
		}
		else if(dragonAction == DA_GroundLeftJawAttack)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_left_jaw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_GroundRightClawAttack)
		{
			parent.RaiseEvent('edge_right_claw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
		}
		else if(dragonAction == DA_GroundRightJawAttack)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('edge_right_jaw_attack1');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_GroundFireAttack)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minShortFireAttackDuration, maxShortFireAttackDuration);
			parent.RaiseEvent('fire_attack_start');
			parent.WaitForBehaviorNodeDeactivation('fire_loop', 6.0);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}
			parent.RaiseEvent('fire_attack_stop');
			parent.WaitForBehaviorNodeDeactivation('fire_end', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_GroundFireUpAttack)
		{
			parent.DragonLookatOff();
			//actionDuration = ChooseDragonActionDuration(minShortFireAttackDuration, maxShortFireAttackDuration);
			parent.RaiseEvent('edge_fire_up_start');
			parent.WaitForBehaviorNodeDeactivation('fire_up_loop', 6.0);
			/*if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}	*//*
			parent.RaiseEvent('edge_fire_up_stop');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_FlyFireAttack)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseDragonActionDuration(minShortFireAttackDuration, maxShortFireAttackDuration);
			parent.RaiseEvent('fire_attack_start');
			parent.WaitForBehaviorNodeDeactivation('fire_loop', 6.0);
			if(actionDuration > 0.0)
			{
				Sleep(actionDuration);
			}	
			parent.RaiseEvent('fire_attack_stop');
			parent.WaitForBehaviorNodeDeactivation('fire_end', 6.0);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_WallWalkClawAttack)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('wall_walk_claw_attack');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.ChangeDragonState(DS_TowerTop);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_WallWalkTailAttack)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('wall_walk_tail_attack');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.ChangeDragonState(DS_TowerTop);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_WallWalkCloseAttack)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.RaiseEvent('wall_walk_claw_close');
			parent.WaitForBehaviorNodeDeactivation('towertop_state', 6.0);
			parent.ChangeDragonState(DS_TowerTop);
			parent.DragonLookatOn();
		}
		else if(dragonAction == DA_UpAttackLeft)
		{
			parent.DragonLookatOn();
			parent.RaiseEvent('up_attack_left');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
			PerformDragonAction(DA_UpToFly);
		}
		else if(dragonAction == DA_UpAttackRight)
		{
			parent.DragonLookatOn();
			parent.RaiseEvent('up_attack_right');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
			PerformDragonAction(DA_UpToFly);
		}
		else if(dragonAction == DA_UpAttackFront)
		{
			parent.DragonLookatOff();
			parent.RaiseEvent('up_attack_front');
			parent.WaitForBehaviorNodeDeactivation('up_idle', 6.0);
			parent.DragonLookatOn();
			PerformDragonAction(DA_UpToFly);
		}
		performedActionsNum += 1;
		if(performedActionsNum >= performedActionsNumReset)
		{
			performedActionsNum = 0;
			ResetActionProbability();
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
	function RandomDragonActionArray( dragonActionsToRandomize : array<EDragonAction>)  : EDragonAction
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
	
	//RandomDragonAction - chooses random action from action "startAction" to action "endAction"
	function RandomDragonAction(startAction : EDragonAction, endAction : EDragonAction) : EDragonAction
	{
		var diceThrowResult, probabilitySum, currentActionProbability, i, startActionInt, endActionInt : int;
		
		startActionInt = (int)startAction + 1; //+1, because we always start from the action after start action marker in EDragonActions enum
		endActionInt = (int)endAction;
		for (i = startActionInt; i < endActionInt; i+=1)
		{
			probabilitySum += Max(actionProbabilities[i], 0);
		}
		diceThrowResult = Rand(probabilitySum) + 1;
		for (i = startActionInt; i < endActionInt; i+=1)
		{
			currentActionProbability = Max(actionProbabilities[i], 0);
			if(diceThrowResult <=  currentActionProbability)
			{
				return dragonActions[i];
				//break;
			}
			else
			{
				diceThrowResult -= currentActionProbability;
			}
		}
		
		
	}
	//ChooseDragonAction - chooses EDragonAction to perform 
	function ChooseDragonAction() : EDragonAction
	{
		var dragonAction : EDragonAction;
		
		//actions in dragon DS_TowerTop state
		if(parent.dragonState == DS_TowerTop)
		{
			parent.DragonLookatOn();
			parent.SetCanPlayDamageAnim(true);
			parent.SetCanBeAttacked(true);
			if( parent.playerGrab)
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_StartFlying);
				dragonActionsToRandomize.PushBack(DA_GroundFireUpAttack);
				dragonActionsToRandomize.PushBack(DA_FireSideAttack);
				dragonActionsToRandomize.PushBack(DA_StandUp);
				dragonAction = DA_StartFlying;//RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			if(parent.PlayerInRange("RightAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_WalkLeft);
				dragonActionsToRandomize.PushBack(DA_GroundRightClawAttack);
				dragonActionsToRandomize.PushBack(DA_GroundRightJawAttack);
				dragonActionsToRandomize.PushBack(DA_GroundAttackJawForward2);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else if(parent.PlayerInRange("LeftAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_WalkRight);
				dragonActionsToRandomize.PushBack(DA_GroundLeftClawAttack);
				dragonActionsToRandomize.PushBack(DA_GroundLeftJawAttack);
				dragonActionsToRandomize.PushBack(DA_GroundAttackJawForward2);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else if(parent.PlayerInRange("ForwardAttack1"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_GroundAttackClawForward1);
				dragonActionsToRandomize.PushBack(DA_GroundAttackClawForward2);
				dragonActionsToRandomize.PushBack(DA_GroundAttackJawForward1);
				dragonActionsToRandomize.PushBack(DA_GroundLeftClawAttack);
				dragonActionsToRandomize.PushBack(DA_GroundRightClawAttack);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else if(parent.PlayerInRange("MiddleSector"))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_GroundFireUpAttack);
				dragonActionsToRandomize.PushBack(DA_GroundFireAttack);
				dragonActionsToRandomize.PushBack(DA_WingAttack);
				dragonActionsToRandomize.PushBack(DA_WalkLeft);
				dragonActionsToRandomize.PushBack(DA_WalkRight);
				dragonActionsToRandomize.PushBack(DA_WallWalkLeft);
				dragonActionsToRandomize.PushBack(DA_WallWalkRight);
				dragonActionsToRandomize.PushBack(DA_StartFlying);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else
			{
				dragonAction = RandomDragonAction(DA_GroundActionsStart, DA_GroundActionsEnd);
				return dragonAction;	
			}
		}
		//actions in dragon DS_Flying state
		else if(parent.dragonState == DS_Flying)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.SetCanBeAttacked(false);
			if( parent.playerGrab)
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_FlyLeftShort);
				dragonActionsToRandomize.PushBack(DA_FlyRightShort);
				dragonActionsToRandomize.PushBack(DA_Fly180);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			if(parent.PlayerInRange( "MiddleSector" ))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_FlyFireAttack);
				dragonActionsToRandomize.PushBack(DA_FlyAttack);
				dragonActionsToRandomize.PushBack(DA_StopFlying);
				dragonActionsToRandomize.PushBack(DA_Fly180);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else
			{
				dragonAction = RandomDragonAction(DA_AerialActionsStart, DA_AerialActionsEnd);
				return dragonAction;
			}
		}
		//actions in dragon DS_WallWalkRight state
		else if(parent.dragonState == DS_WallWalkRight)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.SetCanBeAttacked(false);
			if(parent.PlayerInRange( "WalkRightAttack" ))
			{
				dragonAction = DA_WallWalkClawAttack;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "CloseSector" ))
			{
				dragonAction = DA_WallWalkCloseAttack;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "MiddleSector" ))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_WallWalkTailAttack);
				dragonActionsToRandomize.PushBack(DA_WallWalkEnd);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else
			{
				dragonAction = DA_WallWalkEnd;
				return dragonAction;
			}
		}
		//actions in dragon DS_WallWalkLeft state
		else if(parent.dragonState == DS_WallWalkLeft)
		{
			parent.SetCanPlayDamageAnim(false);
			parent.SetCanBeAttacked(false);
			if(parent.PlayerInRange( "WalkLeftAttack" ))
			{
				dragonAction = DA_WallWalkClawAttack;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "CloseSector" ))
			{
				dragonAction = DA_WallWalkCloseAttack;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "MiddleSector" ))
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_WallWalkTailAttack);
				dragonActionsToRandomize.PushBack(DA_WallWalkEnd);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			else
			{
				dragonAction = DA_WallWalkEnd;
				return dragonAction;
			}
		}
		//actions in dragon DS_FlyRight or  DS_FlyLeft state
		else if(parent.dragonState == DS_FlyLeft || parent.dragonState == DS_FlyRight)
		{
			if( parent.playerGrab)
			{
				ResetDragonRandomActionArray();
				dragonActionsToRandomize.PushBack(DA_FlySideFireAttack);
				dragonActionsToRandomize.PushBack(DA_FlySideEnd);
				dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
				return dragonAction;
			}
			parent.SetCanPlayDamageAnim(false);
			parent.SetCanBeAttacked(false);
			ResetDragonRandomActionArray();
			dragonActionsToRandomize.PushBack(DA_FlySideEnd);
			dragonActionsToRandomize.PushBack(DA_FlySideFireAttack);
			dragonAction = RandomDragonActionArray(dragonActionsToRandomize);
			return dragonAction;
		}
		else if(parent.dragonState == DS_UpState)
		{
			parent.SetCanPlayDamageAnim(true);
			parent.SetCanBeAttacked(true);
			if(parent.PlayerInRange( "LeftAttack2" ))
			{
				dragonAction = DA_UpAttackLeft;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "RightAttack2" ))
			{
				dragonAction = DA_UpAttackRight;
				return dragonAction;
			}
			else if(parent.PlayerInRange( "FarSector" ))
			{
				dragonAction = DA_UpAttackFront;
				return dragonAction;
			}
			else
			{
				dragonAction = RandomDragonAction(DA_UpActionsStart, DA_UpActionsEnd);
				return dragonAction;
			}
		}
		else
		{
			Log("RandomizeDragonAction ERROR: wrong dragon state (EDragonState)");
		}
	}
	function ChooseDragonActionDuration(minActionDuration : float, maxActionDuration : float) : float
	{
		var actionDuration : float;
		actionDuration = minActionDuration + RandF()*maxActionDuration;
		return actionDuration;
	}
	function TempIsActionAnAttack(dragonAction : EDragonAction) : bool
	{
		var dragonActionIndex : int;
		dragonActionIndex = (int)dragonAction;
		if(dragonActionIndex >= (int)DA_TriggeredAttacksStart + 1 && dragonActionIndex < (int)DA_TriggeredAttacksEnd)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
state DragonDeath in CDragonA3a
{
	entry function DragonDeath()
	{
		parent.RemoveAllDragonTimers();
		parent.StopAllDragonEffects();
		parent.RaiseForceEvent('to_cutscene');
		Sleep(4.0);
		FactsAdd( "q307_dragon_end", 1 );
		//parent.Destroy();
	}
}
class CDragonGrabEdge extends CEntity
{
	var interaction : CInteractionComponent;
	var dragon : CDragonA3a;
	var dragonHead : CDragonHead;
	var interactionPullUp : CInteractionComponent;
	var grabPoint, grabPointBack : CEffectDummyPoint;
	var grabCameraComp : CCameraComponent;
	editable var cameraTemplate : CEntityTemplate;
	var teleportPosition, teleportPositionBack, cameraPosition : Vector;
	var teleportRotation, teleportRotationBack, cameraRotation : EulerAngles;
	var grabCamera : CCamera;
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( actionName == 'Exploration' )
		{
			Log("Interaction used");
			//interaction.SetEnabled(false);
			//thePlayer.TeleportWithRotation(teleportPosition, teleportRotation);
			if(interaction.IsEnabled())
			{
				EdgeGrab();
			}
			else if(interactionPullUp.IsEnabled())
			{
				PullUp();
			}
		}
		
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		interaction = (CInteractionComponent)this.GetComponent("GrabEdge");
		interactionPullUp = (CInteractionComponent)this.GetComponent("PullUp");
		grabPoint = (CEffectDummyPoint)this.GetComponent("GrabPoint");
		grabPointBack = (CEffectDummyPoint)this.GetComponent("GrabPointBack");
		teleportPosition = grabPoint.GetWorldPosition();
		teleportRotation = grabPoint.GetWorldRotation();
		teleportPositionBack = grabPointBack.GetWorldPosition();
		teleportRotationBack = grabPointBack.GetWorldRotation();
		grabCameraComp = (CCameraComponent)this.GetComponent("GrabCamera");
		cameraPosition = grabCameraComp.GetWorldPosition();
		cameraRotation = grabCameraComp.GetWorldRotation();
		grabCamera = (CCamera)theGame.CreateEntity(cameraTemplate, cameraPosition, cameraRotation);
		dragon = (CDragonA3a)theGame.GetEntityByTag('dragon_a3');
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
	}
	function GetGrabCamera() : CCamera
	{
		return grabCamera;
	}
}
state Sliding in CDragonGrabEdge
{
	var gameCamera : CCamera;
	var hangDuration : float;
	var slideTime, slideTimeTowerRadius, distance, towerRadius : float;
	var playerPos, playerToGrabVec : Vector;
	default towerRadius = 7.0;
	default slideTimeTowerRadius = 2.0;
	event OnEnterState()
	{
		parent.dragon = (CDragonA3a)theGame.GetEntityByTag('dragon_a3');
	}
	function CalculateSlideTime() : float
	{
		var tempSlideTime : float;
		playerPos = thePlayer.GetWorldPosition();
		playerToGrabVec = parent.teleportPosition - playerPos;
		distance = VecLength( playerToGrabVec );
		tempSlideTime = slideTimeTowerRadius * (distance/towerRadius);
		return tempSlideTime;
	}
	entry function PullUp()
	{
		parent.dragon.SetPlayerGrab(false);
		thePlayer.RaiseEvent('climb_up');
		parent.interactionPullUp.SetEnabled(false);
		thePlayer.WaitForBehaviorNodeDeactivation('idle');
		thePlayer.SetManualControl(true, true);
		parent.interaction.SetEnabled(true);
		gameCamera.Reset();
		gameCamera.SetActive(true);
		parent.grabCamera.SetActive(false);
		
	}
	entry function EdgeGrab()
	{
		parent.dragon.SetGrabInteraction(parent);
		parent.dragon.SetPlayerGrab(true);
		//parent.dragon.DragonGrabReaction();
		hangDuration = 2.0;
		gameCamera = theCamera;
		parent.grabCamera.SetActive(true);
		parent.interaction.SetEnabled(false);
		thePlayer.AttachBehavior('witcher_wind');
		thePlayer.SetManualControl(false, true);
		slideTime = CalculateSlideTime();
		thePlayer.SetRotationTargetPos(parent.teleportPosition);
		thePlayer.ActionSlideTo(parent.teleportPosition, 0.1);
		thePlayer.ClearRotationTarget();
		thePlayer.TeleportWithRotation(parent.teleportPosition, parent.teleportRotation);
		thePlayer.RaiseEvent('edge_jump');
		thePlayer.WaitForBehaviorNodeDeactivation('climb_loop');
		parent.interactionPullUp.SetEnabled(true);
		Sleep(hangDuration);
		PullUp();
		//FallDown();
	}
	entry function FallDown()
	{
		thePlayer.RaiseEvent('fall_down');
		Sleep(2.0);
		theHud.m_fx.DeathStart();
	}
	entry function FallFromTop()
	{
		parent.interaction.SetEnabled(false);
		parent.dragon.SetGrabInteraction(parent);
		parent.dragon.SetPlayerGrab(true);
		thePlayer.AttachBehavior('witcher_wind');
		thePlayer.TeleportWithRotation(parent.teleportPosition, parent.teleportRotation);
		parent.grabCamera.SetActive(true);
		if(thePlayer.IsRotatedTowardsPoint(parent.dragonHead.GetWorldPosition() , 90 ))
		{
			thePlayer.RaiseEvent('fall_down');
		}
		else
		{
			thePlayer.RaiseEvent('fall_down_back');
		}
		Sleep(4.0);
		theHud.m_fx.DeathStart();
	}
	entry function WindHit()
	{
		parent.interaction.SetEnabled(false);
		parent.dragon.SetGrabInteraction(parent);
		parent.dragon.SetPlayerGrab(true);
		//parent.dragon.DragonGrabReaction();
		thePlayer.AttachBehavior('witcher_wind');
		thePlayer.TeleportWithRotation(parent.teleportPosition, parent.teleportRotation);
		parent.grabCamera.SetActive(true);
		if(thePlayer.IsRotatedTowardsPoint(parent.dragonHead.GetWorldPosition() , 90 ))
		{
			thePlayer.RaiseEvent('slide');
		}
		else
		{
			thePlayer.RaiseEvent('slide_back');
		}
		thePlayer.StartSinglePressQTEAsync( 'QTE2', 2.f ); 
		thePlayer.WaitForBehaviorNodeDeactivation('slide_end', 6.0);
		//Sleep(0.1);
		thePlayer.TeleportWithRotation(parent.teleportPosition, parent.teleportRotation);
		parent.grabCamera.SetActive(true);
		if(thePlayer.GetLastQTEResult() == QTER_Succeeded)
		{
			thePlayer.RaiseEvent('grab');
			thePlayer.WaitForBehaviorNodeDeactivation('climb_loop', 6.0);
			parent.interactionPullUp.SetEnabled(true);
			Sleep(3.0);
			PullUp();
			//FallDown();
		}
		else
		{
			FallDown();
		}
	}
}
*/