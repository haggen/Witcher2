/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Base combat state
/////////////////////////////////////////////
state Combat in CPlayer extends ExtendedMovable
{	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	var eventAllowHitTime : EngineTime;
	var lockingDisabled : bool;
	var hitEventNames_t2 : array<name>;
	var hitEventNames_t3 : array<name>;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private var enemy : CActor;
	private var takedownParams : STakedownParams;
	private var softlockDeltaMax, softlockDeltaThreshold : float;
	private var attackShiftDeltaMax, attackShiftDeltaThreshold : float;
	private var moveTime : EngineTime;
	private var combatAreaMaxRange : float;
	private var selectionDenyTime : EngineTime;
	private var animEventName : name;
	private var requestLowState : bool;
	private var requestExplorationState : bool;
	default requestLowState = false;
	default requestExplorationState = false;
	
	private var riposteInProgressTime : EngineTime;
	private	var target_lock				: CActor;
	private var targetLockActive 			: bool;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{	
		var areaL : CInteractionAreaComponent;
		var lockedTarget : CActor;
		
		lockedTarget = thePlayer.GetLastLockedTarget();
		
		super.OnEnterState();
		
		riposteInProgressTime = EngineTime();
		
		parent.GetMovingAgentComponent().EnableCombatMode( true );
		
		combatAreaMaxRange = 8.0f;
		
		takedownParams = STakedownParams();
		
		AddMarkEnemyTimer();
		
		hitEventNames_t2.Clear();
		hitEventNames_t2.PushBack('Hit_t2a');
		hitEventNames_t2.PushBack('Hit_t2b');
		
		hitEventNames_t3.Clear();
		hitEventNames_t3.PushBack('Hit_t3a');
		hitEventNames_t3.PushBack('Hit_t3b');
		
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 1800.0 );
		parent.SetBehaviorVariable( 'InCombat', 1.0 );
		
		if(lockedTarget && lockedTarget.IsAlive() && !lockedTarget.IsBoss())
		{
			enemy = lockedTarget;
			SetTargetLock(enemy);
		}
		else
		{
			parent.SetLastLockedTarget(NULL);
			targetLockActive = false;
			SetTargetLock( (CActor)NULL );
		}
		
	}
	event OnLeaveState()
	{
		var lockedTarget : CActor;
		
		parent.GetMovingAgentComponent().EnableCombatMode( false );
		
		//parent.SetAllPlayerStatesBlocked( false ); // Emergency unblock

		//targetLockActive = false;
		
		lockedTarget = thePlayer.GetLastLockedTarget();
		
		if(lockedTarget && lockedTarget.IsAlive() && !lockedTarget.IsBoss())
		{
			enemy = lockedTarget;
			SetTargetLock(enemy);
		}
		else
		{
		
			parent.SetLastLockedTarget(NULL);
			targetLockActive = false;
			SetTargetLock( (CActor)NULL );
		}
		parent.RemoveTimer('MarkEnemyTimer' );
		ResetEnemy();
		super.OnLeaveState();	
	}
	
	function AddMarkEnemyTimer()
	{
		parent.AddTimer('MarkEnemyTimer', 0.2, true );	
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Continuous selecting
	timer function MarkEnemyTimer( timeDelta : float )
	{
		var localEnemy : CActor;
		if( IsSelectionAllowed() )
		{
			localEnemy = FindEnemy();
			
			if ( !localEnemy )
			{
				
			}
			if( localEnemy != GetEnemy() )
			{
				ResetEnemy();				
			}

			if( localEnemy )
			{
				CacheEnemy( localEnemy, true );
				parent.SetBehaviorVariable( 'InCombat', 1.0 );
				//parent.SetPlayerCombatStance(PCS_High);
				parent.SetFistFightCooldown();
				if(localEnemy.IsMonster())
				{
					if(thePlayer.PlayerCanPlayMonsterCommentary() && Rand(10) == 1)
						thePlayer.PlayerCommentary(PC_MonsterReaction, 0.1);
				}
			}
			else
			{
				parent.SetBehaviorVariable( 'InCombat', 0.0 );
			}
			if (parent.m_fistFightCooldown > 0)
			{
				parent.m_fistFightCooldown -= timeDelta;
			}
			else if(!parent.IsInCombat())
			{
				if(parent.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
				{
					requestExplorationState = true;
				}
			}
			if ( parent.m_lowStanceCooldown > 0 )
			{
				parent.m_lowStanceCooldown -= timeDelta;
			}
			else if(!parent.IsInCombat())
			{
				if(parent.GetPlayerCombatStance() == PCS_High && requestLowState == false)
				{
					requestLowState = true;
				}
			}
			
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Anim events
	function DamageEnemiesInDirection(direction : EDirection, animEvent : name, optional roundAttack : bool)
	{
		var enemiesInRange : array<CActor>;
		var enemyInRange : CActor;
		var i, size : int;
		var squareDist : float;
		var playerPos : Vector = thePlayer.GetWorldPosition();
		var passed : bool;
		
		if( !thePlayer.GetCharacterStats().HasAbility('sword_s4') )
		{
			if(direction != D_Front || roundAttack)
				return;
		}

		if(parent.GetInventory().ItemHasTag(parent.GetCurrentWeapon(), 'RangeLong'))
		{
			squareDist = 25.0;
		}
		else
		{
			squareDist = 9.0;
		}
		
		enemiesInRange = thePlayer.FindEnemiesInCombatArea();
		size = enemiesInRange.Size();
		if(size > 0)
		{
			for(i = 0; i < size; i += 1)
			{
				enemyInRange = enemiesInRange[i];
				if(enemyInRange != enemy)
				{
					if(CalculateRelativeDirection(thePlayer, enemyInRange) == direction || roundAttack)
					{
						if(VecDistanceSquared2D(enemyInRange.GetWorldPosition(), playerPos) < squareDist)
						{
							passed = true;
							if( IsNormalMACEnabled() )
							{
								passed = NavmeshLineTest( playerPos, enemyInRange );
							}
							
							if( passed )
							{
								enemyInRange.Hit( thePlayer, animEvent, false, true );
							}
						}
						
					}
				}
			}
		}
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var hitParams : HitParams;
		var trap : CEntity;
		if( animEventName == 'StrongSwing' )
		{
			if ( HasEnemy() && VecDistance(parent.GetEnemy().GetWorldPosition(), parent.GetWorldPosition()) < 5.0)
			{	
				hitParams.attackType = animEventName;
				hitParams.attacker = parent;
				hitParams.hitPosition = parent.GetWorldPosition();			
				GetEnemy().OnAttackTell( hitParams );
			}
		}
		if ( ( animEventType == AET_Tick )  && IsAttackEvent( animEventName ))
		{
			//broadcast interest point only if we carry a weapon
			if( thePlayer.GetCurrentWeapon() != GetInvalidUniqueId() )
				theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( parent.attackInterestPoint, parent, 2.0 );
			DamageEnemy( animEventName );
		}
		if ( ( animEventType == AET_Tick )  && animEventName == 'InAxiiLoop')
		{
			thePlayer.SetAxiiLoop(true);
		}
		else if(( animEventType == AET_Tick )  && animEventName == 'RiposteBlock')
		{
			RiposteBlock();
		}
		else if(animEventName == 'RoundAttack')
		{
			DamageEnemiesInDirection(D_Front, animEventName, true);
		}
		else if(animEventName == 'FrontAttack')
		{
			DamageEnemiesInDirection(D_Front, animEventName);
		}
		else if(animEventName == 'LeftAttack')
		{
			DamageEnemiesInDirection(D_Left, animEventName);
		}
		else if(animEventName == 'RightAttack')
		{
			DamageEnemiesInDirection(D_Right, animEventName);
		}
		else if(animEventName == 'BackAttack')
		{
			DamageEnemiesInDirection(D_Back, animEventName);
		}
		else if ( animEventName == 'AllowHit' )
		{
			eventAllowHitTime = theGame.GetEngineTime();
		}
		else if ( animEventName == 'Softlock' && lockingDisabled == false )
		{
			if ( animEventType == AET_DurationStart )
			{
				SoftLockOn( 0.f, 0.f );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				SoftLockOff();
			}
		}
		else if ( animEventName == 'Hardlock' && lockingDisabled == false )
		{
			if ( animEventType == AET_DurationStart )
			{
				if ( IsSoftLock() )
				{
					SoftLockOff();
				}
				
				parent.SetHardlock( true );
				parent.SetRotationTarget( GetEnemy(), true );
				parent.AddTimer( 'EmergencyHardlockClear', 0.3 );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.SetHardlock( false );
				parent.RemoveTimer( 'EmergencyHardlockClear' );
				parent.ClearRotationTarget();
			}
			else if( animEventType == AET_Duration )
			{
				parent.AddTimer( 'EmergencyHardlockClear', 0.3 );
			}
		}
		else if ( animEventName == 'AttackAllowShift' && lockingDisabled == false )
		{
			if ( animEventType == AET_DurationStart )
			{
				AttackShiftOn( 0.f, 0.f );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				AttackShiftOff();
			}
		}
		else if( animEventName == 'DenySelection' )
		{
			selectionDenyTime = theGame.GetEngineTime() + 0.1;
		}
		else if( animEventName == 'Cut_LeftArm' || animEventName == 'Cut_RightArm' || animEventName == 'Cut_Torso' || animEventName == 'Cut_Head' )
		{
			SetAllowToCut( animEventName );
		}
		else if ( animEventName == 'InteractTrap' )
		{
			if( theGame.GetBlackboard().GetEntryEntity( 'currentTrap', trap ) )
			{
				if( trap )
				{
					((CBaseTrap)trap).OnTrapInteractAnimEvent();
				}
			}
		}
		else if( animEventName == 'Bomb_Prep' && animEventType == AET_Tick )
		{
			InformEnemyOfBomb();	
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	function InformEnemyOfBomb()
	{
		var  enemyArray : array<CActor>;
		var searchRadius : float;
		var i : int;
		
		searchRadius  = 30;
		GetActorsInRange(enemyArray, searchRadius, '', thePlayer);
		for (i = 0;i < enemyArray.Size(); i+=1)
		{
			enemyArray[i].OnPlayerThrowBomb();
		}
	}
	
	
	timer function EmergencyHardlockClear( timeDelta : float )
	{
		parent.ClearRotationTarget();
		parent.SetHardlock( false );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combo attack inputs
	
	event OnComboAttack( canBeBlocked : bool, comboAttack : SBehaviorComboAttack )
	{
		parent.OnComboAttack( canBeBlocked, comboAttack );
		
		if ( enemy )
		{
			if ( enemy.OnRespondToComboAttack( parent, canBeBlocked, comboAttack ) == true )
			{
				Log( "*** Combat attack will be blocked!!! ***" );
				return true;
			}
			else
			{
				return false;
			}
		}

		return false;
	}
	
	event OnRespondToComboAttack( attacker : CActor, canBeBlocked : bool, comboAttack : SBehaviorComboAttack )
	{
		// Return true if attack will be blocked
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game inputs
	
	event OnGameInputEvent( key : name, value : float )
	{
		var attacker : CActor;
		var hitPosition : Vector;
		var attackType : name;
		var player : CActor;
		var cooldown : EngineTime;
		

		if ( parent.isMovable )
		{			
			if ( key == 'GI_UseItem' && !thePlayer.AreCombatHotKeysBlocked() )
			{
				if( value > 0.5 )
				{
					if( parent.thrownItemId != GetInvalidUniqueId() && !thePlayer.GetIsCastingAxii() && !thePlayer.IsNotGeralt() )
					{
						if( parent.GetInventory().GetItemQuantity( parent.thrownItemId ) > 0 )
						{
							theGame.GetBlackboard().GetEntryTime( 'witcherAbilityCooldown', cooldown );
							if( theGame.GetEngineTime() - cooldown < 0.5 ) return true;
								
							if( parent.GetInventory().GetItemCategory( parent.thrownItemId ) == 'trap' || parent.GetInventory().GetItemCategory( parent.thrownItemId ) == 'lure' )
							{
								parent.PlayerCombatAction(PCA_DeployTrap);
								parent.SetPlayerCombatStance(PCS_High);
								return true;
							}
							else
							{
								if( parent.GetInventory().GetItemCategory( parent.thrownItemId ) == 'rangedweapon' && !parent.GetCharacterStats().HasAbility('training_s4') )
								{
									theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("Cannot use that item") );
									return true;
								}
								
								theGame.GetBlackboard().AddEntryEntity( 'currentEnemy', enemy );
								parent.AimedThrow();
								return true;
							}
						}
					}
					return true;
				}
				return false;
			}
			else if ( key == 'GI_Accept_Evade' )
			{
				if( value > 0.5f && !thePlayer.IsOverweight() )
				{
					if(!thePlayer.isNotGeralt || thePlayer.IsAssasinReplacer())
					{
						//parent.RaiseForceEvent ( 'Evade' );
						//parent.SetGuardBlock(false, true);
						parent.SetPlayerEvadeType(parent.GetPlayerEvadeType());
						parent.PlayerActionUnbreakable(PAU_Evade);
						parent.SetPlayerCombatStance(PCS_High);
						//parent.SetBehaviorVariable( 'roll', 1.0 );
						return true;
					}
					return false;
					
				}
				return false;
			}
			else if ( key == 'GI_LockTarget' )
			{
				if( parent.GetEnemy() && !parent.AreCombatHotKeysBlocked() && value > 0.5f )
				{
					TriggerTargetLock();
					return true;
				}
				return false;
			}
		}

		return super.OnGameInputEvent( key, value );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Attacks
	
	private function SetAllowToCut( animEventName : name )
	{
		if (!enemy) return;
		
		if ( animEventName == 'Cut_LeftArm' )
		{
			enemy.readyToCut.LeftArm = true;
			enemy.AddCutResetTimer();
		} else
		if ( animEventName == 'Cut_RightArm' )
		{
			enemy.readyToCut.RightArm = true;
			enemy.AddCutResetTimer();
		} else		
		if ( animEventName == 'Cut_Torso' )
		{
			enemy.readyToCut.Torso = true;
			enemy.AddCutResetTimer();
		} else	
		if ( animEventName == 'Cut_Head' )
		{
			enemy.readyToCut.Head = true;
			enemy.AddCutResetTimer();
		}		
	}

	private function IsAttackEvent( animEventName : name ) : bool
	{
		if ( animEventName == 'FistFightAttack_t1' || animEventName == 'JumpAttack_t1' || animEventName == 'FastAttack_t0' || animEventName == 'FastAttack_t1' || animEventName == 'FastAttack_t2' || animEventName == 'FastAttack_t3' || animEventName == 'MagicAttack_t1' ||animEventName == 'StrongAttack_t0' ||animEventName == 'StrongAttack_t1' || animEventName == 'StrongAttack_t2' || animEventName == 'StrongAttack_t3' || animEventName == 'RiposteAttack')
			return true;
		else 
			return false;
		UpdateCamera();
	}
	
	private function IsSelectionAllowed() : bool
	{
		return theGame.GetEngineTime() > selectionDenyTime;
	}
	
	private final function IsAttacking() : bool
	{
		return enemy;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Shifts
	private final function GetAttackShift() : Vector
	{
		var bonePos, enemyPos, shift : Vector;

		bonePos = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'l_IK_FootBall' ) );
		thePlayer.GetVisualDebug().AddSphere('mieczshpere', 0.3, bonePos, true, Color(0,255,0), 10.0);
		//enemyPos = GetEnemyTargetPointPosWithShift( 0 );
		enemyPos = GetEnemyTargetPointPos();
		
		thePlayer.GetVisualDebug().AddSphere('mieczshpere2', 0.3, enemyPos, true, Color(0,0,255), 10.0);
		
		shift = enemyPos - bonePos;
		
		// Convert to MS from WS
		shift = VecTransformDir( parent.GetWorldToLocal(), shift );
				
		return shift;
	}
	
	private final function AttackShiftOn( deltaMax : float, deltaThreshold : float )
	{
		var shift : Vector;
		
		attackShiftDeltaMax = deltaMax;
		attackShiftDeltaThreshold = deltaThreshold;
		
		if ( !IsAttackShift() && VecDistance(enemy.GetWorldPosition(), thePlayer.GetWorldPosition()) < 10.0)
		{
			shift = GetAttackShift();
			
			// Add timer
			parent.AddTimer( 'AttackShiftUpdate', 0.f, true, false, TICK_PrePhysics );
		
			// Set behavior variables
			parent.SetBehaviorVectorVariable( "attackShift", shift );
			parent.SetBehaviorVariable( "attackShiftWeight", 0.5f );
			
			DebugMarkAttackShift( true );
		}
		else
		{
			Log("PlayerCombat AttackShiftOn error!");
		}
	}
	
	private final function IsAttackShift() : bool
	{
		if ( parent.GetBehaviorVariable( "attackShiftWeight" ) == 0.5f )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	timer function AttackShiftUpdate( timeDelta : float )
	{
		var shift, prevShift : Vector;
		var delta : float;
		var color : Color;
		if( !enemy )
		{
			AttackShiftOff();
			return;
		}
		else if(!enemy.IsBoss())
		{
			if(VecDistance(enemy.GetWorldPosition(), thePlayer.GetWorldPosition()) > 10.0)
			{
				AttackShiftOff();
				return;
			}
		}

		shift = GetAttackShift();
		
		DebugMarkAttackShift( true );
		
		prevShift = parent.GetBehaviorVectorVariable( "attackShift" );
		
		delta = VecDistance( shift, prevShift );

		if ( attackShiftDeltaThreshold > 0.f && delta > attackShiftDeltaThreshold )
		{
			parent.SetBehaviorVectorVariable( "attackShift", shift );
			color = Color(0,255,0);
			thePlayer.GetVisualDebug().AddSphere('shiftDebugSphere', 0.3, shift, true, color, 2.0);
			return;
		}
		else
		{
			parent.SetBehaviorVectorVariable( "attackShift", shift );
			color = Color(0,255,0);
			thePlayer.GetVisualDebug().AddSphere('shiftDebugSphere', 0.3, shift, true, color, 2.0);
			return;
		}
	}
	
	private final function AttackShiftOff()
	{
		if ( IsAttackShift() )
		{
			// Rermove timer for soft lock
			parent.RemoveTimer( 'AttackShiftUpdate', TICK_PrePhysics );
			
			// Infom behavior
			parent.SetBehaviorVectorVariable( "attackShift", Vector(0,0,0) );
			parent.SetBehaviorVariable( "attackShiftWeight", 0.f );
		}
		
		DebugMarkAttackShift( false );
	}
	
	private final function DebugMarkAttackShift( flag : bool )
	{
		if ( HasEnemy() && flag )
		{
			parent.GetVisualDebug().AddSphere( 'attackShift', 0.4, GetEnemyTargetPointPosWithShift( 1.f ) , true, Color( 128, 0, 128 ), 10.f );
		}
		else
		{
			parent.GetVisualDebug().RemoveSphere( 'attackShift' );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Locks
	
	private final function LocksOff()
	{
		SoftLockOff();
		parent.ClearRotationTarget();
	}
	
	private final function SoftLockOn( deltaMax : float, deltaThreshold : float )
	{
		var angleToRot : float;
		
		softlockDeltaMax = deltaMax;
		softlockDeltaThreshold = deltaThreshold;
		
		if ( !IsSoftLock() )
		{
			angleToRot = -GetAngleToEnemy();
			
			// Add timer for soft lock
			parent.AddTimer( 'SoftLockUpdate', 0.f, true, false, TICK_PrePhysics );
		
			// Set behavior variables
			parent.SetBehaviorVariable( "softlockAngle", angleToRot );
			parent.SetBehaviorVariable( "softlockWeight", 1.f );
			
			DebugMarkSoftLock( true );
		}
		else
		{
			Log("PlayerCombat SoftLockOn error!");
		}
	}
	
	timer function SoftLockUpdate( timeDelta : float )
	{
		var angleToRot : float;
		var prevAngle : float;
		var delta : float;
		
		/*if ( IsHardLock() )
		{
			return;
		}*/
		
		angleToRot = -GetAngleToEnemy();
		
		DebugMarkSoftLock( true );
		
		prevAngle = parent.GetBehaviorVariable( "softlockAngle" );
		
		delta = AbsF( angleToRot - prevAngle );
		
		if ( softlockDeltaThreshold > 0.f && delta > softlockDeltaThreshold )
		{
			// Deactivate soft lock
			SoftLockOff();
			return;
		}
		else if ( softlockDeltaMax > 0.f && delta > softlockDeltaMax )
		{
			// Delta is too big
			if ( angleToRot > 0.f )
			{
				angleToRot = softlockDeltaMax;
			}
			else
			{
				angleToRot = -softlockDeltaMax;
			}
		}
		
		parent.SetBehaviorVariable( "softlockAngle", angleToRot );
	}
	
	private final function SoftLockOff()
	{
		if ( IsSoftLock() )
		{
			// Rermove timer for soft lock
			parent.RemoveTimer( 'SoftLockUpdate', TICK_PrePhysics );
			
			// Infom behavior
			parent.SetBehaviorVariable( "softlockWeight", 0.f );
			parent.SetBehaviorVariable( "softlockAngle", 0.f );
		}
		
		DebugMarkSoftLock( false );
	}
	
	private final function IsSoftLock() : bool
	{
		if ( parent.GetBehaviorVariable( "softlockWeight" ) == 1.f )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	private final function DebugMarkSoftLock( flag : bool )
	{
		if ( HasEnemy() && flag )
		{
			parent.GetVisualDebug().AddSphere( 'softLock', 0.4, GetEnemyTargetPointPos(), true, Color( 255, 0, 0 ), 10.f );
		}
		else
		{
			parent.GetVisualDebug().RemoveSphere( 'softLock' );
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Damage enemy
	
	function IsRiposteInProgress() : bool
	{
		return theGame.GetEngineTime() < riposteInProgressTime;
	}
	function RiposteKillsTarget(target : CActor) : bool
	{
		var diceThrow : float;
		var riposteKillChance : float;
		if(target.IsInvulnerable() || target.IsImmortal() || !target.CanBeFinishedOff(thePlayer) || target.IsBoss() || target.IsHuge())
			return false;
		diceThrow = RandRangeF(0.01f, 1.0f);
		riposteKillChance = thePlayer.GetCharacterStats().GetFinalAttribute('riposte_killchance');
		if(diceThrow <= riposteKillChance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function InstantKillChance(target : CActor) : bool
	{
		var chance, diceThrow : float;
		var chanceTox, chanceBasic : float;
		var toxicityThreshold : float;
		if(target.IsInvulnerable() || target.IsImmortal() || !target.CanBeFinishedOff(thePlayer) || target.IsBoss() || target.IsHuge())
			return false;
		toxicityThreshold = thePlayer.GetCharacterStats().GetFinalAttribute('toxicity_threshold');
		if(toxicityThreshold <= 0.0f)
		{
			toxicityThreshold = 1.0f;
		}
		diceThrow = RandRangeF(0.01, 0.99);
		
		chanceBasic = thePlayer.GetCharacterStats().GetFinalAttribute('instant_kill_chance');
		chanceTox = thePlayer.GetCharacterStats().GetFinalAttribute('instant_kill_toxbonus');
		if(chanceTox < 0.0)
		{
			chanceTox = 0.0;
		}
		if(thePlayer.GetToxicity()>toxicityThreshold)
		{
			chanceBasic + chanceTox;
		}
		chance = chanceBasic;
		if(diceThrow <= chance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	private function RiposteBlock( )
	{
		var localEnemy : CActor;
		var hitParams : HitParams;
		if ( HasEnemy() && AttackRangeTest( GetEnemy() ) )
		{			
			localEnemy = GetEnemy();
			// Remember player target
			parent.attackTarget = localEnemy;
			parent.attackTargetSetTime = theGame.GetEngineTime();
			if(localEnemy.CanPerformRespondedBlock())
			{
				localEnemy.OnAttackBlocked(hitParams);
				localEnemy.PlaySparksOnHit(localEnemy, hitParams);
			}
		}
		else
		{
			DamageEnemy('Attack');
		}
	}
	private function BossTest(boss : CActor) : bool
	{
		var dragon : CDragonHead;
		if(!boss.IsBoss())
		{	
			return false;
		}
		dragon = (CDragonHead)boss;
		if(dragon)
		{
			if(VecDistance(dragon.GetWorldPosition(), thePlayer.GetWorldPosition()) < 6.0)
			{
				return true;
			}
		}
		return false;
	}
	private function DamageEnemy( attackType : name )
	{
		var localEnemy : CActor;
		localEnemy = enemy;
																			//MSZ: dragon bossfight range test
		if ( (localEnemy != (CActor)NULL && AttackRangeTest( localEnemy )) || BossTest(localEnemy))
		{			
			// Remember player target
			parent.attackTarget = localEnemy;
			parent.attackTargetSetTime = theGame.GetEngineTime();
			
			localEnemy.SetLastAttackedByPlayer(true);
			
			if(attackType == 'RiposteAttack' && RiposteKillsTarget(localEnemy))
			{
				localEnemy.Hit ( parent, attackType, false, false, true );
				localEnemy.PlayEffect('instant_kill_fx');
			}
			else if( InstantKillChance(localEnemy))
			{
				/*if(theGame.GetIsPlayerOnArena())
				{
					theGame.GetArenaManager().AddBonusPoints(thePlayer.GetCharacterStats().GetAttribute('arena_instant_bonus'));
				}*/
				localEnemy.Hit( parent, attackType, false, false, true );
				localEnemy.PlayEffect('instant_kill_fx');
			}
			else
			{
				localEnemy.Hit( parent, attackType );
			}
			PlayAttackHitSound();
		}
	}
	
	private function AttackRangeTest( target : CActor ) : bool
	{
		return parent.InAttackRange( target );
	}
	
	private function PlayAttackHitSound();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enemies
	
	private final function GetDistanceToEnemy() : float
	{
		if ( HasEnemy() )
		{
			return VecDistance( parent.GetWorldPosition(), GetEnemyTargetPointPos() );
		}
		else
		{
			return 0.f;
		}
	}
	
	private final function GetAngleToEnemy() : float
	{
		var dir : Vector;
		var yaw, angle : float;
		
		angle = 0.f;
		
		if ( HasEnemy() )
		{
			dir	=  GetEnemyTargetPointPos() - parent.GetWorldPosition();
			dir.Z = 0.0;
			
			yaw = Rad2Deg( AtanF( dir.Y, dir.X ) ) - 90.0f;
			
			if ( yaw > 180.f )
			{
				yaw -= 360.f;
			}
			else if ( yaw < -180 )
			{
				yaw += 360.f;
			}
 
			angle = AngleDistance( parent.GetHeading(), yaw );
			
		}
		
		return angle;
	}
	
	private final function GetAngleToActor( actor : CActor ) : float
	{
		var dir : Vector;
		var yaw, angle : float;
		
		angle = 0.f;
		
		if ( actor )
		{
			dir	=  actor.GetWorldPosition() - parent.GetWorldPosition();
			dir.Z = 0.0;
			
			yaw = Rad2Deg( AtanF( dir.Y, dir.X ) ) - 90.0f;
			
			if ( yaw > 180.f )
			{
				yaw -= 360.f;
			}
			else if ( yaw < -180 )
			{
				yaw += 360.f;
			}
 
			
			angle = AngleDistance( parent.GetHeading(), yaw );
						
		}
		
		return angle;
	}
	
	function GetLockedTarget() : CActor
	{
		return target_lock;
	}
	
	function TriggerTargetLock()
	{
		var enemy : CActor;
		
		if ( target_lock )
		{
			SetTargetLock( (CActor)NULL );
		}
		else
		{
			enemy = GetEnemy();
			if ( ! enemy.IsBoss() )
			{
				SetTargetLock( enemy );
			}
		}
	}
	
	event OnGetLockedTarget( out target : CActor )
	{
		target = target_lock;
	}
	
	private function SetTargetLock( target : CActor )
	{
		target_lock = target;
		if ( target )
		{
			thePlayer.SetIsEnemyLocked( true );
			theHud.HudTargetActorEx( target_lock );
			thePlayer.SetLastLockedTarget(target);
		}
		else
		{
			thePlayer.SetIsEnemyLocked( false );
			theHud.HudTargetActorEx( GetEnemy() );
			thePlayer.SetLastLockedTarget(NULL);
		}
	}

	private function EvaluateLockedTarget()
	{
		var currPos, enemyPos				: Vector;
		var distToEnemy, verticalDist		: float;
		var invalidateTargetLock			: bool = false;
		
		if ( target_lock )
		{
			// we have a target lock - check if the enemy we're currently
			// targetting meets the enemy requirements, and if so - return it
			if ( target_lock && target_lock.IsAlive() && !((CNewNPC)target_lock).IsTeleporting() )
			{
				invalidateTargetLock = false;
			}
			else
			{
				// invalidate the target lock - it's no good any more
				invalidateTargetLock = true;
			}
		}
		else
		{
			if ( targetLockActive )
			{
				// invalidate the target lock only if there used to be a target lock there
				invalidateTargetLock = true;
			}
		}
		
		if ( invalidateTargetLock )
		{
			// perform the target lock invalidation
			SetTargetLock( (CActor)NULL );
			
			// notify about a target lock deactivation
			OnTargetLockDeactivated();
		}
		
		
		if ( target_lock && !targetLockActive )
		{
			// notify about a target lock activation
			OnTargetLockActivated();
		}
		
		// memorize the target lock
		targetLockActive = target_lock;
	}
	
	event OnTargetLockActivated() 
	{
	}
	
	event OnTargetLockDeactivated()
	{
	}
		
	private function FindEnemy() : CActor
	{
		var enemies 						: array< CActor >;
		var currPos, enemyPos				: Vector;
		var distToEnemy, verticalDist		: float;
		var invalidateTargetLock			: bool = false;
		var currCameraRotation				: EulerAngles;
		
		EvaluateLockedTarget();
		
		// return the proper enemy
		if ( target_lock )
		{
			return target_lock;	
		}
		else
		{		
			// select a new enemy - the current enemy is no good
			enemies = parent.FindEnemiesToTarget();
			return SelectEnemy( enemies );
		}
	}
	
	private function SelectEnemy( enemies : array< CActor > ) : CActor
	{
		var i, size : int;
		var target, result : CActor;
		var angleArray : array< float >;		
		var distanceArray : array< float >;
		var points : array< float >;
		var vecToTarget, playerPos : Vector;
		var rotYaw, yaw : float;
		var angleWeight, distanceWeight, angleThreshold, lastSelectedWeight, minAngleThreshold, attackedWeight, finisherWeight, axiiWeight : float;
		var minimumDistance : float;
		var value : float;
		var INVALID_WEIGHT : float = 1000000;
		var enemySelection : SEnemySelection;
		var calculatedAngleThreshold : float;
		var distanceFactor, distance : float;
		var npc : CNewNPC;
		var maxAngleThreshold 		: float;
		var secondaryTestMult		: float;
		
		if(theGame.IsUsingPad())
		{
			thePlayer.SetEnemySelectionWeights(90.0, 20.0, 1.0, 1.25, 0.7, 0.75, 0.6, 0.8, 1.0, -1.0, 160, 0.1);
		}
		
		enemySelection = thePlayer.GetEnemySelection();
		
		playerPos = parent.GetWorldPosition();
			
		size = enemies.Size();
		if( size == 0 )
		{
			return NULL;
		}
		
		rotYaw = parent.GetCombatAreaAngle();
				
		angleArray.Resize( size );
		distanceArray.Resize( size );
		angleWeight = enemySelection.selectionAngleWeight;
		distanceWeight = enemySelection.selectionDistanceWeight;
		lastSelectedWeight = enemySelection.selectionLastSelectedWeight;
		angleThreshold = enemySelection.selectionAngleThreshold;
		minAngleThreshold = enemySelection.minSelectionAngleThreshold;
		attackedWeight = enemySelection.selectionLastAttackedWeight;
		finisherWeight = enemySelection.finisherWeight;
		axiiWeight = enemySelection.axiiWeight;
		maxAngleThreshold = enemySelection.closeAngleThreshold;
		secondaryTestMult = enemySelection.secondaryTestMultiplicator;
		minimumDistance = 2.0;
		
	
		
		for ( i = 0; i < size; i += 1 )
		{
			target = enemies[ i ];
			
			if ( target == parent )
			{
				Log("SelectEnemy error: target == parent");
			}
			
			vecToTarget	= target.GetWorldPosition() - playerPos;
			vecToTarget.Z = 0.0;
			
			yaw = Rad2Deg( AtanF( vecToTarget.Y, vecToTarget.X ) ) - 90.0f;
			angleArray[i] = AbsF( AngleDistance( rotYaw, yaw ) );
			distanceArray[i] = VecLength2D( vecToTarget );
		}

		points.Resize( size );
		
		if( combatAreaMaxRange <= 0.0f )
		{
			Log("SelectEnemy error: combatAreaMaxRange not set");
		}
		
		for ( i = 0; i < size; i += 1 )
		{
			distance = MinF(distanceArray[i], combatAreaMaxRange);
			
			distance = MaxF(distanceArray[i], minimumDistance);
			
			
			distanceFactor = (combatAreaMaxRange - distance)/(combatAreaMaxRange - minimumDistance);
			
			calculatedAngleThreshold = (angleThreshold - minAngleThreshold)*distanceFactor + minAngleThreshold;
			
			
			
			// verify whether the NPC can be targeted at all
			if ( angleArray[i] <= calculatedAngleThreshold )//|| ( angleArray[i] > angleThreshold && distanceArray[i] < 2.0f ) )
			{
				value = angleWeight * ( ( calculatedAngleThreshold - angleArray[i] ) / calculatedAngleThreshold );
				value += distanceWeight *  ( ( combatAreaMaxRange - distanceArray[i] ) / combatAreaMaxRange );
				if(enemies[i].GetLastSelectedInCombat())
				{
					value += lastSelectedWeight;
				}
				if(enemies[i].GetLastAttackedByPlayer())
				{
					value += attackedWeight;
				}
				if(enemies[i].IsCriticalEffectApplied(CET_Stun) || enemies[i].IsCriticalEffectApplied(CET_Knockdown))
				{
					value += finisherWeight;
				}
				npc = (CNewNPC)enemies[i];
				if(npc && npc.IsBerserkActive())
				{
					value += axiiWeight;
				}
				points[i] = value;
			}
			else if ( angleArray[i] <= maxAngleThreshold )//|| ( angleArray[i] > angleThreshold && distanceArray[i] < 2.0f ) )
			{
				value = angleWeight * ( ( maxAngleThreshold - angleArray[i] ) / maxAngleThreshold );
				value += distanceWeight *  ( ( combatAreaMaxRange - distanceArray[i] ) / combatAreaMaxRange );
				if(enemies[i].GetLastSelectedInCombat())
				{
					value += lastSelectedWeight;
				}
				if(enemies[i].GetLastAttackedByPlayer())
				{
					value += attackedWeight;
				}
				if(enemies[i].IsCriticalEffectApplied(CET_Stun) || enemies[i].IsCriticalEffectApplied(CET_Knockdown))
				{
					value += finisherWeight;
				}
				npc = (CNewNPC)enemies[i];
				if(npc && npc.IsBerserkActive())
				{
					value += axiiWeight;
				}
				
				value = value * secondaryTestMult;
				
				points[i] = value;
			}
			else
			{
				points[i] = INVALID_WEIGHT;
			}
		}
		
		
		i = ArrayMaskedFindMaxF( points, INVALID_WEIGHT );
		if ( i >= 0 )
		{
			if(!enemies[i].GetLastSelectedInCombat())
			{
				thePlayer.DeselectAllEnemies(enemies);
				enemies[i].SetLastSelectedInCombat(true);
			}
			return enemies[i];
		}
		else
		{
			return NULL;
		}
	}
	
	private final function CacheEnemy( actor : CActor, optional noAttack : bool )
	{
		var bb : CBlackboard;	
		var args : array <string>;
		
		if ( enemy != actor && ! actor.IsBoss() )
		{
			theHud.m_hud.SetNPCHealthPercent( actor.GetHealthPercentage() );
			theHud.HudTargetActorEx( actor, false );
		}
		
		theHud.m_hud.SetNPCName( actor.GetDisplayName() );
		
		enemy = actor;		
		
		// Add blackboard entry
		if( noAttack == false )
		{
			bb = theGame.GetBlackboard();
			bb.AddEntryEntity( 'playerAttacking', actor );
			bb.AddEntryTime( 'playerAttacking', theGame.GetEngineTime() );
		}
		
		DebugMarkEnemy( true );
		
		//enemy.Highlight( true );
		
		enemy.SetCombatHighlight( true );
		enemy.AddTimer('RemoveCombatSelection', 1.0, false );
	}
	
	event OnNPCDeath( deadNPC : CActor)
	{
		if ( deadNPC == enemy ) ResetEnemy();
	}
	
    // on npc death
    event OnNPCStunned( stunnedNPC : CActor )
    {
		if ( stunnedNPC == enemy ) ResetEnemy();
    }
	
	private final function ResetEnemy()
	{	
		if ( enemy )
		{
			//enemy.Highlight( false );
			
			enemy.SetCombatHighlight( false );
			
			if ( ! enemy.IsDead() )
			{				
				enemy.RemoveTimer('RemoveCombatSelection');
			}
			
			if ( ! enemy.IsBoss() )
				theHud.m_hud.HideNPCHealth();

			enemy = NULL;
		
			LocksOff();
		
			AttackShiftOff();
		
			DebugMarkEnemy( false );
		}
	}
	
	private function GetEnemy() : CActor
	{
		return enemy;
	}
	
	private function GetEnemyNPC() : CNewNPC
	{
		return (CNewNPC)enemy;
	}
	
	event OnGetEnemy( out outEnemy : CActor )
	{
		outEnemy = enemy;
	}
	
	private final function IsEnemyNeutral() : bool
	{
		var npc : CNewNPC;
		npc = (CNewNPC)enemy;
		if( npc && npc.GetAttitude( parent ) == AIA_Neutral )
		{
			return true;
		}
		
		return false;
	}
	
	private final function HasEnemy() : bool
	{
		if ( enemy ) return true;
		else return false;
	}
	
	private function GetEnemyTargetPointPos() : Vector
	{	
		//return enemy.GetWorldPosition();
		return enemy.GetNearestPointInPersonalSpace( parent.GetWorldPosition() );
	}
	
	private function GetEnemyTargetPointRot() : EulerAngles
	{
		if ( enemy ) return enemy.GetWorldRotation();
		else return EulerAngles(0,0,0);
	}
	
	private function GetEnemyTargetPointPosWithShift( distShift : float ) : Vector
	{
		var target, dir : Vector;
		
		target = GetEnemyTargetPointPos();
		
		dir = target - parent.GetWorldPosition();
		dir.Z = 0.f;
		VecNormalize2D( dir );
		
		return target - dir*distShift;
	}
	
	private function GetAttackDirection() : EAttackDirection
	{
		var angle : float;
		
		angle = GetAngleToEnemy();
			
		if ( angle <= 45.f && angle >= -45.f )
		{
			return AD_Front;
		}
		else if ( angle > 45.f && angle <= 135.f )
		{
			return AD_Right;
		}
		else if ( angle < -45.f && angle >= -135.f )
		{
			return AD_Left;
		}
		else
		{
			return AD_Back;
		}
	}
	
	private final function DebugMarkEnemy( flag : bool )
	{
		if ( enemy && flag )
		{
			parent.GetVisualDebug().AddSphere( 'enemy', 0.6, enemy.GetWorldPosition(), true, Color( 0, 0, 0 ), 10.f );
		}
		else
		{
			parent.GetVisualDebug().RemoveSphere( 'enemy' );
		}
	}
	
	private function NavmeshLineTest( playerPos : Vector, target : CActor ) : bool
	{
		var mac : CMovingAgentComponent = parent.GetMovingAgentComponent();
		var targetPos : Vector = target.GetWorldPosition();
		var rad2 : float = 1.0f;
		var offset : Vector;
		
		if( mac.IsEndOfLinePositionValid(targetPos ) )
		{					
			offset = playerPos - targetPos;
			offset.Z = 0.0f;
			if( VecLength2D( offset ) < rad2 )
				return true;
				
			offset = VecNormalize2D( offset );
			offset *= rad2;
			
			if( mac.CanGoStraightToDestination( targetPos + offset ) )			
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function IsNormalMACEnabled() : bool
	{
		var mac : CMovingPhysicalAgentComponent;
		mac = (CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent();	
		return mac.IsEnabled() && !mac.IsPhysicalMovementEnabled();
	}
	
	// Try enter takedown
	private function TryStartTakedown( actor : CActor )
	{
		var RandI : int;
		var npc : CNewNPC;
		var lastTakedownStart, currentTime : EngineTime;
		var lastTakedownCount, timeDiff : float;
		var res1, res2 : bool;
		var enemiesClose : array < CActor >;
		var i : int;
		
		// Actor must be npc!!!
		if( !actor.IsA('CNewNPC') )
		{
			return;
		}
	
		if( actor.CanBeTakedowned( parent, true ) )
		{
			currentTime = theGame.GetEngineTime();
			res1 = theGame.GetBlackboard().GetEntryTime('takedownStart', lastTakedownStart );
			res2 = theGame.GetBlackboard().GetEntryFloat('takedownCount', lastTakedownCount );
			
			timeDiff = EngineTimeToFloat( currentTime - lastTakedownStart );
			
			if( actor.MustBeTakedowned() || !res1 || ( lastTakedownCount == 1 && timeDiff > 30.0 )
					|| ( lastTakedownCount == 2 && timeDiff > 60.0 ) )
			{				
				if( VecDistance( parent.GetWorldPosition(), actor.GetWorldPosition() ) < 3.0 )
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>" + actor.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_finisher") + "!</span>");
					SetupTakedownParamsDefault( actor, takedownParams );
					parent.ChangePlayerState( PS_CombatTakedown );
					parent.TakedownReady = false;			
				}
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	function GetHitEventName_t2() : name
	{
		var s : int;
		s = hitEventNames_t2.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return hitEventNames_t2[Rand(s)];
		}
	}
	
	function GetHitEventName_t3() : name
	{
		var s : int;
		s = hitEventNames_t3.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return hitEventNames_t3[Rand(s)];
		}
	}
	/*private function ChooseHitEvent( hitParams : HitParams ) : name
	{
		var isFrontToSource : bool;
		
		isFrontToSource = parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 );
		
		if( hitParams.attackType == 'Attack' )
		{
			if( isFrontToSource )
			{	
				return 'Hit';
			}
			else
			{
				return 'HitBack';
			}
		}
		
		else if( hitParams.attackType == 'Attack_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return 'Hit_t1';
			}
			else
			{
				return 'Hit_t1b';
			}
		}
		else if( hitParams.attackType == 'Attack_t2' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return GetHitEventName_t2();
			}
			else  
			{
				return 'Hit_t2back';
			}
		}
		else if( hitParams.attackType == 'Attack_t3' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return GetHitEventName_t3();
			}
			else
			{
				return 'Hit_t3back';
			}
		}
		else if( hitParams.attackType == 'Attack_t4' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return 'Hit_t4';
			}
			else
			{
				return 'Hit_t3back';
			}
		}
		
		else if( hitParams.attackType == 'Attack_boss_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return 'HeavyHitFront';
			}
			else
			{
				return 'HeavyHitBack';
			}
		}
		else if( hitParams.attackType == 'FistFightAttack_t1' )
		{
			if( isFrontToSource )
			{	
				return 'Hit';
			}
			else
			{
				return 'HitBack';
			}
		}
		else
			Log( "ChooseHitEvent: unknown attackType parameter." );
	}*/
	event OnBeingHitPosition(hitParams : HitParams)
	{
		var quenDamage : float;
		if(parent.activeQuenSign)
		{
			//przeniesione do quena
			//theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_quen" ) );	
			quenDamage = hitParams.damage;
			parent.activeQuenSign.QuenHit(quenDamage, hitParams);
			
			if( hitParams.forceHitEvent )
			{
				hitParams.damage = 0;
				return true;
			}
			
			return false;
		}
		else
		{
			return true;
		}
	}
	event OnHit( hitParams : HitParams )
	{
		var currTime, deltaTime : EngineTime;
		var hitEvent : name;

		// Check allow hit flag
		currTime = theGame.GetEngineTime();
		deltaTime = currTime - eventAllowHitTime;
		
		//Log( EngineTimeToString( deltaTime ) );
	
		//if ( deltaTime < 0.1f )
		//{		
			PlayHit( hitParams );
			//parent.KeepCombatMode();
			
			UpdateCamera();
		//}
			
			parent.OnHit( hitParams );
		
	}
	
	private function PlayHit( hitParams : HitParams );

	/*entry function JumpEnd()
	{
		parent.RaiseEvent('CombatJumpEnd');
		parent.WaitForBehaviorNodeActivation( 'DodgeEnd' );
	}*/
	
	function UpdateCamera()
	{
		var Enemies : array <CActor>;
		var i : int;
		
		// Dynamic zoom in/out camera in combat
			Enemies = parent.FindEnemiesInCombatArea();
			if (Enemies.Size() < 1)
			{
				parent.cameraFurther = 0.0;
			} else
			{	
				parent.cameraFurther = Enemies.Size();
				Enemies.Clear();
				Enemies = parent.FindEnemiesInCombatArea();
				parent.cameraFurther = parent.cameraFurther + ( ( Enemies.Size() ) * 2 ) / 3.5;
				if (parent.cameraFurther > 3.0) parent.cameraFurther = 3.0;
			}

	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Base combat logic
	
	private latent function CombatLogic()
	{
		parent.cameraTick = parent.cameraTick - 0.1;
		if ( parent.cameraTick < 0 )
		{
			parent.cameraTick = 0.2;
			UpdateCamera();
		}
		if(theGame.GetIsPlayerOnArena())
		{
			if(thePlayer.GetCombatEndAnimRequest() && thePlayer.GetPlayerCombatStance() == PCS_High && !thePlayer.IsDodgeing())
			{
				thePlayer.SetCombatEndAnimRequest(false);
				requestLowState = false;
				
				if(parent.RaiseForceEvent('CombatEnding'))
				{
					thePlayer.SetGuardBlock(false, true);
					parent.WaitForBehaviorNodeActivation('CombatEndAnim');
					parent.SetPlayerCombatStance(PCS_Low);	
					thePlayer.SetGuardBlock(false, true);
				}
			}
		}
		if(requestLowState && parent.GetPlayerCombatStance() == PCS_High)
		{
			requestLowState = false;
			if(parent.RaiseEvent('HighToLow'))
			{
				parent.WaitForBehaviorNodeDeactivation('IdleOut');
				parent.SetPlayerCombatStance(PCS_Low);	
			}
		}
		parent.ProcessRequiredItems();
	}
	
	event OnItemUse( itemId : SItemUniqueId )
	{
		parent.OnItemUse( itemId );
	}
}
