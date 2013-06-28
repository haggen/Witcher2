/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

//This class spawns and starts the first rock (the very begining of the GC presentation).
/*class CDraugBallManager extends CEntity
{
	var load : bool;
	var ball : CDraugStartProjectile;
	editable var ballToSpawn : CEntityTemplate;
	var startNode, targetNode : CNode;
	default load = false;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		BallInitialize();
	}
	function BallInitialize()
	{
		startNode = theGame.GetNodeByTag('gc_ball');
		targetNode = theGame.GetNodeByTag('gc_ball_tr');
		ball = (CDraugStartProjectile)theGame.CreateEntity(ballToSpawn, startNode.GetWorldPosition(), startNode.GetWorldRotation());
	}
	timer function BallStart(rd : float)
	{
		ball.StartRock(targetNode.GetWorldPosition());
		AddTimer('ShotEffect', 0.02, false);
	}
	timer function ShotEffect(td : float)
	{
		ball.PlayEffect('trails');
	}
	event OnLoadingScreenFadeStarted()
	{
		FactsAdd("GG_CutsceneStart", 1);
		AddTimer('BallStart', 0.2, false);
	}
}
//This class starts draug combat
class CDraugStartTrigger extends CEntity
{
	var draug : CDraugBossGC;
	var actor : CActor;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.AddTimer('StartAreaInitialize', 2.0, false);
	}
	timer function StartAreaInitialize(td:float)
	{
		draug = (CDraugBossGC)theGame.GetEntityByTag('draug_boss');
		actor = (CActor)thePlayer;
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var isCharging : bool;
		var activatorEntity : CActor;
		activatorEntity = (CActor)activator.GetEntity();
		if(activatorEntity == actor)
		{
			draug.StartGCBattle();
			area.SetEnabled(false);
		}
	}
}

//This class is used for draug GC AI.
class CDraugBossGC extends CDraugBossBase
{
	var shieldStage : int;
	var gcBattle : bool;
	var arrows : bool;
	var demoEnded : bool;
	var phase : int;
	var tornadoSound : SSoundEventHandle;	
	default demoEnded = false;
	default phase = 0;
	default gcBattle = false;
	default arrows = false;
	default shieldStage = 0;
	
	function DraugInitialize()
	{
		if(!GetCharacterStats().HasAbility('draug_boss_base'))
		{
			GetCharacterStats().AddAbility ('draug_boss_base');
		}
		maxHealth = this.GetCharacterStats().GetAttribute('vitality');
		maxShield = this.GetCharacterStats().GetAttribute('shield');
		currentHealth = maxHealth;
		currentShield = maxShield;
		
		//theHud.m_hud.SetBossName("DRAUG");
		//theHud.HudTargetActorEx( this, true );
		//theHud.m_hud.SetBossHealthPercent(100.f);
		//theHud.m_hud.SetBossArmorPercent(100.f);
		
		//DraugEquipItems();
		PlayEffect('draug_fire');
		DraugUpdate();
		SpecialAttackForceCooldown(specialAttackCooldownDefault);
	}
	timer function EndDemo(td : float)
	{
		demoEnded = true;
		theGame.SetActivePause(true);
		theGame.Pause();
	}
	function GetDemoEnded() : bool
	{
		return demoEnded;
	}
	function StartGCBattle()
	{
		gcBattle = true;
		//TEMP
		DraugEquipItems();
		DraugUpdate();
	}
	function StopGCBattle()
	{
		gcBattle = false;
		//TEMP
		DraugUpdate();
	}
	function DraugEquipItems()
	{
		var sword : SItemUniqueId;
		var swordEntity : CItemEntity;
		sword = GetInventory().GetItemId('DraugSword');
		GetInventory().MountItem(sword, true);
		GetInventory().PlayItemEffect( sword, 'default_sword_fx' );
	}
	function StopCharge()
	{
		StopChargeEntry();
	}
}
state DraugShieldCombat in CDraugBossGC
{
	var args : array < string >;
	event OnEnterState()
	{
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec(360.0);
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if(animEventName == 'Attack' && animEventType == AET_Tick)
		{
			parent.DraugAttack(DA_Strong, thePlayer);
		}
		else if(animEventName == 'Shake' && animEventType == AET_Tick)
		{
			theCamera.ExecuteCameraShake( CShake_Hit, 0.1 );
		}
		else if(animEventName == 'Attack_strong' && animEventType == AET_Tick)
		{
			parent.DraugAttack(DA_Strong, thePlayer);
		}
		else if(animEventName == 'TornadoStart' && animEventType == AET_Tick)
		{
			parent.tornadoSound = theSound.PlaySoundOnActorWithFade(parent, '', "draug/draug/weapon/attacks/anim_draug_tornado_loop");
		}
		else if(animEventName == 'TornadoStop' && animEventType == AET_Tick)
		{
			theSound.StopSoundWithFade(parent.tornadoSound);
		}
		else if( animEventName == 'Hardlock' )
		{
			if ( animEventType == AET_DurationStart )
			{								
				parent.SetRotationTarget( thePlayer );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.ClearRotationTarget();				
			}
		}
	}
	event OnLeaveState()
	{
		parent.RemoveAllTimers();
	}
	entry function ChangeDraugState(newState : EDraugState)
	{
		parent.DraugUnequipShield();
		parent.currentDraugState = newState;
		parent.RaiseForceEvent('ChangeState');
		parent.WaitForBehaviorNodeDeactivation('Idle');
	}
	entry function DraugUpdate()
	{
		var deathData : SActorDeathData;
		while(true)
		{
			if(parent.health <=0)
			{
				parent.StateDead(deathData);
			}
			Sleep(0.1);
			ChooseDraugAction();
		}
	}
	latent function ChooseDraugAction()
	{
		if(parent.gcBattle)
		{
			if(parent.phase >= 3)
			{
				ActionAttackDistant(20.0);
				//ActionAttackTornado(30.0);
			}
			else if(parent.phase >= 2 && parent.phase < 3 && parent.PlayerInRange("CLOSE_COMBAT_RANGE"))
			{
				ActionAttackTornado(25.0);
			}
			else if(parent.InAttackRange(thePlayer))
			{
				ActionAttackNormal();
			}
			else
			{
				DraugMoveToPlayer();
			}
			/*
			if(!parent.PlayerInRange("CLOSE_COMBAT_RANGE")&&!parent.distantAttackCooldown)
			{
				ActionAttackDistant(10.0);
			}
			else if(parent.PlayerInRange("CHARGE_TRIGGER")&&Rand(2) == 1)
			{
				if(Rand(2) == 1 && !parent.tornadoCooldown)
				{
					ActionAttackTornado(10.0);
				}
				else if(!parent.chargeCooldown)
				{
					ActionAttackCharge(15.0, 5.0);
				}
				else
				{
					DraugMoveToPlayer();
				}
			}
			else if(parent.InAttackRange(thePlayer))
			{
				if(Rand(10) == 1)
				{
					ActionSpecialAttack();
				}
				else
				{
					ActionAttackNormal();
				}
			}
			else if(parent.specialAttackForce)
			{
				ActionSpecialAttack();
			}
			else if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) > parent.attackDistance + 0.5)
			{
				DraugMoveToPlayer();
				Sleep(0.1);
				DraugUpdate();
			}
			else
			{
				DraugRotateToTarget();
				DraugUpdate();
			}*//*
		}
		else
		{
			Sleep(1.0);
			DraugUpdate();
		}
	}
	function ActionSpecialAttack()
	{
		var rand : int;
		rand = Rand(6);
		if(rand == 2)
		{
			ActionAttackTornado(10.0);
		}
		else if(rand == 1)
		{
			ActionAttackCharge(15.0, 5.0);
		}
		else
		{
			ActionAttackDistant(10.0);
		}
	}
	entry function ActionCounterAttack()
	{
		parent.arrows = true;
		ActionAttackDistant(10.0);
	}
	entry function ActionAttackDistant(arrowsAttackTime : float)
	{
		var projectileShooter : CDraugProjectilesShooter;
		var random : int;
		var rocksAttack : bool;
		parent.DistantAttackCooldown(parent.distantAttackCooldownDefault);
		rocksAttack = false;
		projectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
		if(true)
		{
			parent.DraugSetImmortal(true);
			if(parent.InAttackRange(thePlayer))
			{
				parent.RaiseForceEvent( 'ArrowsStartClose' );
			}
			else
			{
				parent.RaiseForceEvent( 'ArrowsStart' );
			}
			if(parent.arrows)
			{
				parent.PlayLineByStringKey( "Archers!", true );
				theSound.PlaySoundOnActor(parent, 'head', "draug/draug/taunts/anim_draug_archers_taunt");
			}
			else
			{
				parent.PlayLineByStringKey( "Artillery!", true );
				theSound.PlaySoundOnActor(parent, 'head', "draug/draug/taunts/anim_draug_artillery_taunt");
			}
			parent.WaitForBehaviorNodeDeactivation('CoverLoop');
			random = Rand(2);
			if(parent.arrows)
			{
				//rocksAttack = true;
				//projectileShooter.DraugRocks(10);
				parent.arrows = false;
				parent.phase = 2;
				rocksAttack = false;
				projectileShooter.DraugArrows();
			}
			else
			{
				rocksAttack = true;
				projectileShooter.DraugRocks(10);
			}
			parent.distantAttackSwitch = true;
			parent.StartTimeCounting();
			while(parent.distantAttackSwitch)
			{
				Sleep(0.1);
				if(parent.PlayerInRange("CLOSE_ATTACK"))
				{
					parent.RaiseEvent('CoverAttack');
					parent.WaitForBehaviorNodeDeactivation('AttackEnd');
				}
				if(parent.CheckTimePassed(arrowsAttackTime))
				{
						parent.distantAttackSwitch = false;
				}
			}
			parent.RaiseEvent( 'ArrowsStop' );
			parent.WaitForBehaviorNodeDeactivation ( 'ArrowsEnd' );	
			if(rocksAttack)
			{
				parent.RocksAttackCooldown(parent.rockCooldownDefault);
			}
			else
			{
				parent.ArrowsAttackCooldown(parent.arrowsCooldownDefault);
			}
			parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
			parent.DistantAttackCooldown(parent.distantAttackCooldownDefault);
			parent.DraugSetImmortal(false);
			Sleep(0.5);
			DraugUpdate();
		}
		else
		{
			DraugMoveToPlayer();
		}
	}
	entry function ActionAttackTornado(tornadoAttackTime : float)
	{
		parent.DraugSetImmortal(true);
		parent.ApplyAppearance("draug_tornado");
		parent.StopEffect('draug_fire');
		parent.PlayEffect('tornado');
		theCamera.SetCameraShakeState( CShakeState_Tower, 1.0 );
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseForceEvent('TornadoStart2H');
		}
		else
		{
			parent.RaiseForceEvent('TornadoStart');
		}
		parent.WaitForBehaviorNodeDeactivation('TornadoLoop', 10.0);
		parent.StartTimeCounting();
		parent.tornadoSwitch = true;
		
		
		//parent.DraugUnequipItems();

		while(parent.tornadoSwitch)
		{
			Sleep(0.1);
			if(parent.PlayerInRange("TORNADO_ATTACK"))
			{
				parent.DraugAttack(DA_Tornado, thePlayer);
				DraugTornadoMoveAwayFromPlayer();
				Sleep(4.0);
			}
			else
			{
				DraugTornadoMoveToPlayer();
			}
			if(parent.CheckTimePassed(tornadoAttackTime))
			{
				parent.tornadoSwitch = false;
			}
		}
		//parent.DraugEquipItems();
		parent.StopEffect('tornado'); 
		theCamera.SetCameraShakeState(CShakeState_Invalid, 0.0);
		parent.SetRotationTarget(thePlayer);
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseEvent('TornadoStop');
		}
		else
		{
			parent.RaiseEvent('TornadoStop');
		}
		parent.WaitForBehaviorNodeDeactivation('TornadoEnd', 15.0);
		parent.ApplyAppearance("draug");
		
		parent.PlayEffect('draug_fire');
		
		parent.DraugSetImmortal(false);
		parent.TornadoCooldown(parent.actionCooldownDefault);
		parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
		parent.phase = 4;
		DraugUpdate();
	}
	entry function ActionAttackNormal()
	{		
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseForceEvent('AttackNormal2H');
		}
		else
		{
			parent.RaiseForceEvent('AttackNormal');
		}
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
		Sleep(1.0);
		DraugUpdate();
	}
	latent function DraugRotateToTarget()
	{
		var rotationTime : float;
		var draugToTargetVec, draugPosition, targetPos : Vector;
		var draugRotation : EulerAngles;
		rotationTime = 0.25;
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseForceEvent('Rotation2H');
		}
		else
		{
			parent.RaiseForceEvent('Rotation');
		}
		parent.RotateToNode( thePlayer, rotationTime );
	}
	entry function ActionAttackCharge(chargeDistance : float, chargeTimeout : float)
	{
		parent.DraugSetImmortal(true);
		parent.ClearRotationTarget();
		parent.StartTimeCounting();
		parent.StartDistanceMeasurement();
		parent.chargeSwitch = true;
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseForceEvent('AttackCharge2H');
		}
		else
		{
			parent.RaiseForceEvent('AttackCharge');
		}
		parent.WaitForBehaviorNodeDeactivation('ChargeLoop', 10.0);
		while(parent.chargeSwitch)
		{
			Sleep(0.1);
			if(parent.PlayerInRange("CLOSE_ATTACK"))
			{
				parent.DraugAttack(DA_Charge, thePlayer);
			}
			if( parent.CheckDistanceGreaterThen(chargeDistance))
			{
				parent.chargeSwitch = false;
			}
			if(parent.CheckTimePassed(chargeTimeout))
			{
				parent.chargeSwitch = false;
			}
		}
		parent.RaiseEvent('ChargeStop');
		parent.WaitForBehaviorNodeDeactivation('ChargeEnd', 10.0);
		DraugRotateToTarget();
		parent.DraugSetImmortal(false);
		parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
		parent.ChargeCooldown(parent.actionCooldownDefault);
		DraugUpdate();
	}
	entry function StopChargeEntry()
	{
		parent.chargeSwitch = false;
		parent.RaiseForceEvent('ChargeObstacle');
		parent.WaitForBehaviorNodeDeactivation('ChargeEnd', 10.0);
		DraugRotateToTarget();
		parent.DraugSetImmortal(false);
		parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
		parent.ChargeCooldown(parent.actionCooldownDefault);
		DraugUpdate();
	}
	function DraugMoveToPlayer()
	{
			var targetPos : Vector;
			var playerPostition, playerToDraugVec, walkTargetPosition, draugPosition : Vector;
			draugPosition = parent.GetWorldPosition();
			playerPostition = thePlayer.GetWorldPosition();
			playerToDraugVec = draugPosition - playerPostition;
			playerToDraugVec = VecNormalize(playerToDraugVec);
			walkTargetPosition = parent.attackDistance*playerToDraugVec;
			thePlayer.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( walkTargetPosition + playerPostition, targetPos);
			parent.SetRotationTarget(thePlayer);
			parent.ActionMoveToAsync(walkTargetPosition + playerPostition, MT_Walk, 1.0, 0.0 );
			DraugUpdate();
	}
	function DraugTornadoMoveToPlayer()
	{
			var targetPos : Vector;
			var playerPostition, playerToDraugVec, walkTargetPosition, draugPosition : Vector;
			draugPosition = parent.GetWorldPosition();
			playerPostition = thePlayer.GetWorldPosition();
			thePlayer.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( playerPostition, targetPos);
			parent.SetRotationTarget(thePlayer);
			//parent.ActionMoveToAsync(walkTargetPosition + playerPostition, MT_Run, 1.5, 0.0 );
			parent.ActionSlideToAsync(targetPos, 5.0);
	}
	function DraugTornadoMoveAwayFromPlayer()
	{
			var targetPos : Vector;
			var playerPostition, playerToDraugVec, walkTargetPosition, draugPosition : Vector;
			draugPosition = parent.GetWorldPosition();
			playerPostition = thePlayer.GetWorldPosition();
			playerToDraugVec = draugPosition - playerPostition;
			playerToDraugVec = VecNormalize(playerToDraugVec);
			walkTargetPosition = 6.0*playerToDraugVec;
			thePlayer.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( walkTargetPosition + draugPosition, targetPos);
			//parent.ActionMoveToAsync(walkTargetPosition + playerPostition, MT_Run, 1.5, 0.0 );
			parent.ActionSlideToAsync(targetPos, 3.0);
	}
	function DraugDamage()
	{
		var finalDamage : float;
		finalDamage =  CalculateDamage(thePlayer, parent, true, false, true, true);
		
		if(parent.currentShield <= 0)
		{
			parent.currentHealth -= finalDamage;
		}
		else
		{
			parent.currentShield -= finalDamage;
		}
		parent.UpdateBossHealth();
		parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
	}
	entry function DraugPlayDamageAnim()
	{
		parent.canPlayDamageAnim = false;
		if(parent.currentDraugState == DS_TwoHanded)
		{
			parent.RaiseForceEvent('Hit2H');
		}
		else
		{
			parent.RaiseForceEvent('HitBlock');
		}
		if(parent.shieldStage == 0)
		{
			parent.CutBodyPart("", "", 'shield1_02');
			parent.CutBodyPart("", "", 'shield1_00');
			parent.CutBodyPart("", "", 'shield1_01');
			parent.shieldStage +=1;
		}
		else if(parent.shieldStage == 1)
		{
			parent.CutBodyPart("", "", 'shield2_01');
			parent.CutBodyPart("", "", 'shield2_00');
			parent.PlayEffect('shield_destroy_fx');
			parent.shieldStage +=1;
		}
		else if(parent.shieldStage == 3)
		{
			parent.CutBodyPart("", "", 'shield3_01');
			parent.CutBodyPart("", "", 'shield3_00');
			parent.PlayEffect('shield_destroy_fx');

			parent.shieldStage +=1;
		}
		else if(parent.shieldStage == 4)
		{
			parent.CutBodyPart("", "", 'shield4_01');
			parent.CutBodyPart("", "", 'shield4_00');
			parent.PlayEffect('shield_destroy_fx');
			parent.shieldStage +=1;
		}
		Sleep(0.2);
		parent.canPlayDamageAnim = true;
		parent.WaitForBehaviorNodeDeactivation('HitEnd');		

		//Sleep(0.2);
		DraugUpdate();
	}
	
	event OnBeingHit(out hitParams : HitParams)
	{
		var deathData : SActorDeathData;
		if(parent.canBeHit)
		{
			//parent.health = parent.
			parent.PlayEffect('shield_hit');
			DraugDamage();
			parent.counterAttackMeter += 1;
			if(parent.currentHealth <= 0)
			{
				parent.StateDead(deathData);
			}
			else if(parent.currentShield <= 0 && parent.currentDraugState == DS_Shield)
			{
				parent.currentShield = 0;
				//ChangeDraugState(DS_TwoHanded);
			}
			else if(parent.counterAttackMeter >= 5)
			{
				parent.counterAttackMeter  = 0;
				ActionCounterAttack();
			}
			else if(parent.canPlayDamageAnim)
			{
				DraugPlayDamageAnim();
			}
		}
	}
	event OnHit(hitParams : HitParams);
	event OnCutsceneStarted()
	{
		parent.CutsceneStart();
	}
}
state DraugDeath in CDraugBossGC
{		
	var tags : array< name >;
	var i : int;
	entry function StateDead(deathData : SActorDeathData)
	{
		parent.SetAlive(false);
		parent.ClearRotationTarget();	
		parent.EnablePathEngineAgent( false );
		tags = parent.GetTags();
		for( i=0; i<tags.Size(); i+=1 )
		{
			FactsAdd( "actor_" + tags[i] + "_was_killed", 1 );
			
		}
		FactsAdd("DraugDeath", 1);
		parent.RaiseForceEvent('Death');
		Sleep(5.0);
		parent.StopEffect('draug_fire');
	}
	event OnBeingHit(hitParams : HitParams)
	{

	}
}
state Cutscene in CDraugBossGC
{
	event OnCutsceneEnded()
	{
		parent.DraugUpdate();
	}
	entry function CutsceneStart()
	{

	}
}
*/