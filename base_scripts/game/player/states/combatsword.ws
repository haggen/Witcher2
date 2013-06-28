/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// CombatSword - base state for CombatSteel and CombatSilver
/////////////////////////////////////////////
state CombatSword in CPlayer extends Combat
{
	private var riposteAllowedTime : EngineTime;
	private var guardBlock : bool;
	private var riposteActor : CActor;
	
	private var riposteFrontEvents : array<name>;
	private var riposteBackEvents  : array<name>;
	private var reflectedEventsLeft : array<EPlayerCombatHit>;
	private var reflectedEventsRight : array<EPlayerCombatHit>;	

	private var reflectedRightFlag : bool;
	
	private var riposteFrontEnums : array<EPlayerActionUnbreakable>;
	private var riposteBackEnums  : array<EPlayerActionUnbreakable>;
	
	default reflectedRightFlag = true;
	function DrawSteelSword()
	{
		var weaponUid : SItemUniqueId;
		weaponUid = parent.GetInventory().GetItemByCategory('steelsword', true);
		
		if ( weaponUid != GetInvalidUniqueId() )
		{
			if( parent.GetCurrentWeapon() != weaponUid )
			{
				parent.DrawWeaponInstant( weaponUid );
			}
		}
	}
	function DrawSilverSword()
	{
		var weaponUid : SItemUniqueId;
		weaponUid = parent.GetInventory().GetItemByCategory('silversword', true);
		
		if ( weaponUid != GetInvalidUniqueId() )
		{
			if( parent.GetCurrentWeapon() != weaponUid )
			{
				parent.DrawWeaponInstant( weaponUid );
			}
		}
	}
	event OnEnterState()
	{		
		super.OnEnterState();
	
		riposteAllowedTime = EngineTime();
		riposteInProgressTime = EngineTime();
		riposteActor = NULL;
		guardBlock = false;		
		

		thePlayer.SetIsInShadow( false );
				
		SetReflectedEvents();
		SetRiposteEvents();

	}
	function HasEnoughStaminaForGuardBlock() : bool
	{
		return ( thePlayer.GetStamina() >= 1.0 );
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var hitParams : HitParams;
		var witcherSword : CWitcherSword;
		var witcherWeapon : CWitcherSecondaryWeapon;
		var component : CRigidMeshComponent;
		
		if ( animEventName == 'CantRotate' )
		{
			if ( animEventType == AET_DurationStart )
			{
				parent.AllowCombatRotation(false);
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.AllowCombatRotation(true);
			}
		}
		
		if ( animEventName == 'Knocked' )
		{
			if ( animEventType == AET_DurationStart )
			{
				parent.SetPlayerKnockedDown( true );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.SetPlayerKnockedDown( false );
			}
		}
		
		if ( animEventName == 'NoHits' )
		{
			if ( animEventType == AET_DurationStart )
			{
				parent.SetCanPlayHit( false );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.SetCanPlayHit( true );
			}
		}
		if ( animEventName == 'AllowBlock' )
		{
			if ( animEventType == AET_DurationStart )
			{
				parent.SetCantBlock(false);
			}
		}
		if ( animEventType == AET_Tick && animEventName == 'guard_block_on')
		{
			if( HasEnoughStaminaForGuardBlock() && parent.isMovable == true )
			{
				parent.SetGuardBlock(true, false);
			}
			else if(!thePlayer.GetCombatV2())
			{
				parent.SetGuardBlock(false, true);
				theHud.m_fx.StaminaBlinkStart(); // no stamina to block the attack
			}
		}
		else if(animEventType == AET_Tick && animEventName == 'sparks')
		{
			witcherSword = (CWitcherSword)parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon());
			witcherWeapon = (CWitcherSecondaryWeapon)parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon());
			if(witcherSword)
			{
				component = (CRigidMeshComponent)witcherSword.GetComponentByClassName('CRigidMeshComponent');
				if(component)
				{
					witcherSword.EnableCollisionInfoReportingForComponent(component, true, true);
					witcherSword.AddTimer('CollisionReportingOff', 0.2, false);
				}
			}
			else if(witcherWeapon)
			{
				component = (CRigidMeshComponent)witcherWeapon.GetComponentByClassName('CRigidMeshComponent');
				if(component)
				{
					witcherWeapon.EnableCollisionInfoReportingForComponent(component, true, true);
					witcherWeapon.AddTimer('CollisionReportingOff', 0.2, false);
				}
			}
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game inputs
	event OnGameInputEvent( key : name, value : float )
	{
		var target : CActor;
		target = GetEnemy();
		if ( key == 'GI_Block' )
		{
			if( parent.isMovable && value > 0.5 && !parent.IsInGuardBlock() )
			{
				if(HasEnoughStaminaForGuardBlock() || thePlayer.GetCombatV2())
				{
					if( parent.isMovable == true && !parent.GetIsCastingAxii() && !parent.HasLatentItemAction())
					{
						parent.SetGuardBlock(true, true);
						parent.SetPlayerCombatStance(PCS_High);
						if(target)
						{
							parent.CombatRotateToPosition(target.GetWorldPosition());
						}
						else if(!target)
						{
							parent.CombatRotateToPosition(parent.GetWorldPosition() + theCamera.GetCameraDirection());
						}
						//parent.PlayerCombatAction(PCA_GuardBlockStart);
					}
				}
				else if(!HasEnoughStaminaForGuardBlock())
				{
					theSound.PlaySound( "gui/hud/cannotcastsign" );
					theHud.m_fx.StaminaBlinkStart(); // no stamina to block the attack
				}
				return true;
			}
			else if( value < 0.5 )
			{
				parent.SetGuardBlock(false, true);
				//parent.ActionRotateTo( GetEnemy(), false );
				return false;
			}
			return false;
		}
		/*else if ( key == 'GI_AxisLeftX' && theGame.IsUsingPad() )
		{
			if( IsInGuardBlock() && !IsRiposteInProgress() )
			{
				if ( value < -0.2 )
				{							
					Evade( D_Left );
				}
				else if ( value > 0.2 )
				{						
					Evade( D_Right );
				}
		//	}
		//	else			
				return super.OnGameInputEvent( key, value );
		}
		else if ( key == 'GI_AxisLeftY' && theGame.IsUsingPad() )
		{	
			//if( IsInGuardBlock() && !IsRiposteInProgress() )
			//{
				if ( value < -0.2 )
				{						
					Evade( D_Back );
				}
				else if ( value > 0.2 )
				{
					Evade( D_Front );
				}
			//}
			//else 
				return super.OnGameInputEvent( key, value );
		}*/
		
		return super.OnGameInputEvent( key, value );
	}
	
	event OnGameInputDoubleTap( key : name, value : float )
	{
		if( theGame.IsUsingPad() || thePlayer.GetIsCastingAxii() ||  thePlayer.isMovable == false || !thePlayer.IsManualControl() || thePlayer.AreCombatHotKeysBlocked() || thePlayer.AreHotKeysBlocked())
			return false;
			
		if( theGame.tutorialenabled )
			return false;
			
		if ( key == 'GI_AxisLeftX' )
		{
			//parent.GetVisualDebug().AddSphere('dd', 2.0, Vector(0,0,0), false, Color(255,0,0),0.3);
			if( !thePlayer.isNotGeralt || thePlayer.IsAssasinReplacer())
		//	{
				if ( value < -0.2 )
				{						
					Evade( D_Left );
					//Evade( D_Front );
					return true;
				}
				else if ( value > 0.2 )
				{
					Evade( D_Right );
					//Evade( D_Front );
					return true;
		//		}
			}
		}
		else if ( key == 'GI_AxisLeftY' )
		{	
			//parent.GetVisualDebug().AddSphere('dd', 2.0, Vector(0,0,0), false, Color(255,0,0),0.3);
			if( !thePlayer.isNotGeralt || thePlayer.IsAssasinReplacer())
		//	{
				if ( value < -0.2 )
				{					
					Evade( D_Back );
					//Evade( D_Front );
					return true;
				}
				else if ( value > 0.2 )
				{
					Evade( D_Front );
					return true;
				}
		//	}
		}
	}
	
	function Evade( dir : EDirection )
	{
		if(parent.IsOverweight())
		{
			return;
		}
		if(parent.AreCombatHotKeysBlocked())
		{
			return;
		}
		switch( dir )
		{
			case D_Front:
				//parent.SetBehaviorVariable("EvadeDir", 0 );
				parent.SetPlayerEvadeType(parent.GetPlayerEvadeType());
				parent.PlayerActionUnbreakable(PAU_Evade);
				parent.SetPlayerCombatStance(PCS_High);
				//parent.SetBehaviorVariable( 'roll', 1.0 );
				break;
				
			case D_Back:
				//parent.SetBehaviorVariable("EvadeDir", 1 );
				parent.SetPlayerEvadeType(parent.GetPlayerEvadeType());
				parent.PlayerActionUnbreakable(PAU_Evade);
				parent.SetPlayerCombatStance(PCS_High);
				//parent.SetBehaviorVariable( 'roll', 1.0 );
				break;
				
			case D_Left:
				//parent.SetBehaviorVariable("EvadeDir", 0.5 );
				parent.SetPlayerEvadeType(parent.GetPlayerEvadeType());
				parent.PlayerActionUnbreakable(PAU_Evade);
				parent.SetPlayerCombatStance(PCS_High);
				//parent.SetBehaviorVariable( 'roll', 1.0 );
				break;
				
			case D_Right:
				//parent.SetBehaviorVariable("EvadeDir", -0.5 );
				parent.SetPlayerEvadeType(parent.GetPlayerEvadeType());
				parent.PlayerActionUnbreakable(PAU_Evade);
				parent.SetPlayerCombatStance(PCS_High);
				//parent.SetBehaviorVariable( 'roll', 1.0 );
				break;	
		};
		
		//parent.SetGuardBlock( false, false );		
		//parent.RaiseForceEvent( 'EvadeRelative' );
	}
	event OnArrowHit(hitParams : HitParams, projectile : CRegularProjectile)
	{
		var dirVec, targetPosition, vecToTarget : Vector;
		var dir : EDirection;
		var mat : Matrix;
		var randRing, randRingMin, distanceToTarget : float;
		var attacker : CActor;
		var normal : EulerAngles;
		var angle, speed, speedMult : float;
		
		attacker = hitParams.attacker;
		if(attacker == thePlayer)
		{
			projectile.Destroy();
		}
		if(parent.IsInGuardBlock() && thePlayer.GetCharacterStats().HasAbility('training_s5'))
		{
			//thePlayer.KeepCombatMode();
			dirVec = hitParams.hitPosition - parent.GetWorldPosition();
			mat = parent.GetWorldToLocal();			
			//if( AbsF( dirVec.Z ) < 2.0 )
			//{
				dirVec = VecTransformDir( mat, dirVec );
				dir = VectorToDirection( dirVec );					
				
				if(dir == D_Front)// && thePlayer.GetStamina() >= 1.0 )
				{
				
					if(theGame.GetIsPlayerOnArena())
					{
						//theGame.GetArenaManager().AddBonusPoints(thePlayer.GetCharacterStats().GetAttribute('arena_reflect_bonus'));
						theGame.GetArenaManager().ArenaCrowdReaction(ACR_Sign);
					}
					//parent.RaiseForceEvent( 'Guard_front' );
					thePlayer.PlayerCombatHit(PCH_GuardFront);
					projectile.Init(thePlayer);
					projectile.SetTargetWasHit(false);
					if(hitParams.attacker)
					{
						parent.PlaySparksOnHit(parent, hitParams);	
						targetPosition = attacker.GetWorldPosition();
						distanceToTarget = VecDistance2D(targetPosition, thePlayer.GetWorldPosition());
						
						if(thePlayer.GetCharacterStats().HasAbility('training_s5_2'))
						{
							if(FactsQuerySum("arrows_deflected") < 10.0)
							{
								FactsAdd("arrows_deflected", 1);
							}
							else if(!thePlayer.GetCharacterStats().HasAbility('story_s27_1'))
							{
								AddStoryAbility("story_s27", 1);
							}
							randRing = 0.0f;
							angle = 2.0 + 3.0*RandF();
							speedMult = 0.5;
							vecToTarget = 10.0*VecNormalize2D(targetPosition - thePlayer.GetWorldPosition());
						}
						else
						{
							angle = 20.0 + 30.0*RandF();
							speedMult = 0.3;
							randRing = 30.0;
							randRingMin = 10.0;
							targetPosition = thePlayer.GetWorldPosition();
							vecToTarget = 10.0*VecNormalize2D(targetPosition - thePlayer.GetWorldPosition());
						}
						
						targetPosition += VecRingRand(randRingMin, randRing) + vecToTarget;
						speed = projectile.GetProjectileSpeed()*speedMult;
						projectile.SetProjectileSpeed(speed);
						
						theGame.GetWorld().PointProjectionTest(targetPosition, normal, 3.0);
						projectile.Start( NULL, targetPosition, false, angle);
						thePlayer.DecreaseStamina(1.0);
					}
				}
				else
				{
					parent.OnArrowHit(hitParams, projectile);
				}

			//}
		}
		else
		{
			parent.OnArrowHit(hitParams, projectile);
			//projectile.Destroy();
		}
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var dirVec : Vector;
		var dir : EDirection;
		var mat : Matrix;
		var quenDamage : float;
		var blockAllSides : bool;
		var distanceSquared : float;
		if(parent.IsDodgeing())
		{
			distanceSquared = VecDistanceSquared(hitParams.attacker.GetNearestPointInPersonalSpace(thePlayer.GetWorldPosition()), parent.GetWorldPosition());
			if(distanceSquared > 1.5)
			{
				hitParams.attackDodged = true;
				return false;
			}
		}
		if(thePlayer.GetCharacterStats().HasAbility('training_s3'))
		{
			blockAllSides = true;
		}
		else
		{	
			blockAllSides = false;
		}
		// if the player activated Quen protective shield, no damage can be dealt
		if( parent.activeQuenSign )
		{
			//przeniesione do quena
			//theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_quen" ) );	
			quenDamage = hitParams.attacker.GetCharacterStats().ComputeDamageOutputPhysical(false);
			parent.activeQuenSign.QuenHit(quenDamage, hitParams);
			//hitParams.damage = 0;
			if(parent.IsInGuardBlock())
			{
				hitParams.attackReflected = true;
				hitParams.attacker.OnAttackBlocked(hitParams);
			}
			return false;

		}	
		// check if the player is blocking the hit
		if( parent.IsInGuardBlock() && !hitParams.impossibleToBlock)
		{
			hitParams.attackReflected = true;
			
			if( IsRiposteInProgress() )
			{
				return false;
			}
			else
			{
				dirVec = hitParams.hitPosition - parent.GetWorldPosition();
				mat = parent.GetWorldToLocal();			
				if( AbsF( dirVec.Z ) < 2.0 )
				{
					dirVec = VecTransformDir( mat, dirVec );
					dir = VectorToDirection( dirVec );					
					
					if( dir == D_Front )
					{
						parent.PlayerCombatHit(PCH_GuardFront);
						parent.DecreaseStamina(thePlayer.GetCharacterStats().GetAttribute('endurance_on_block_mult') );
						if(thePlayer.GetCombatV2())
						{
							thePlayer.SignsStaminaDegeneration();
						}
						parent.tutHasBlocked = true;
						return false;
					}
					else if(blockAllSides)
					{
						if( dir == D_Left)
						{	
							parent.PlayerCombatHit(PCH_GuardLeft);

						}
						else if( dir == D_Right)
						{
							parent.PlayerCombatHit(PCH_GuardRight);

						}
						else
						{
							parent.PlayerCombatHit(PCH_GuardBack);

						}
						parent.DecreaseStamina(thePlayer.GetCharacterStats().GetAttribute('endurance_on_block_mult') );
						parent.tutHasBlocked = true;						
						return false;
						
					}
					else
					{
						//parent.SetGuardBlock(false, true);
						hitParams.impossibleToBlock = true;
						return true;
					}
					
				}
			}
		}
		/*if(!parent.IsRotatedTowardsPoint( hitParams.hitPosition, 100 ))
		{
			hitParams.outDamageMultiplier = thePlayer.GetCharacterStats().GetFinalAttribute('back_damage_mult');
			if(hitParams.outDamageMultiplier == 0.0)
			{
				hitParams.outDamageMultiplier = 1.0;
			}
		}*/
		return true;
	}
	
	private function PlayAttackHitSound()
	{
//		parent.PlaySound('Play_code_sword_cut_geralt');
	}
	
	////////////////////////////////////////////////////////////////////////////////////
	event OnBlockRelease()
	{
		parent.SetGuardBlock(false, true);
	}
	
	////////////////////////////////////////////////////////////////////////////////////
	
	function SetRiposteEvents()
	{
	
		riposteFrontEvents.Clear();
		riposteBackEvents.Clear();
		riposteFrontEnums.Clear();
		riposteBackEnums.Clear();
		riposteFrontEvents.Resize(0);
		riposteBackEvents.Resize(0);

		// ADDITIONAL EVENTS
		
		riposteFrontEvents.PushBack('RiposteFront_1');
		riposteFrontEvents.PushBack('RiposteFront_2');
		riposteFrontEvents.PushBack('RiposteFront_3');
		
		riposteBackEvents.PushBack('RiposteBack_1');
		riposteBackEvents.PushBack('RiposteBack_2');
		riposteBackEvents.PushBack('RiposteBack_3');
		
		riposteFrontEnums.PushBack(PAU_RiposteFront1);
		riposteFrontEnums.PushBack(PAU_RiposteFront2);
		riposteFrontEnums.PushBack(PAU_RiposteFront3);
		
		riposteBackEnums.PushBack(PAU_RiposteBack1);
		riposteBackEnums.PushBack(PAU_RiposteBack2);
		riposteBackEnums.PushBack(PAU_RiposteBack3);
	}
	function AutoRiposte(riposteActor : CActor) : bool
	{
		var autoRiposteChance, diceThrow : float;
		autoRiposteChance = thePlayer.GetCharacterStats().GetFinalAttribute('auto_riposte_chance');
		diceThrow = RandRangeF(0.01f, 1.0f);
		if(diceThrow<=autoRiposteChance && HasEnoughStaminaForGuardBlock())
		{
			DoRiposte(riposteActor);
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnRiposteAllowedStart( attacker : CActor )
	{
		if( !IsRiposteInProgress() )
		{
			if( parent.IsBlockingHit() && attacker == enemy && HasEnoughStaminaForGuardBlock())
			{
				if(!AutoRiposte(attacker))
					theHud.m_hud.EnableRiposte( true );
			
			
				riposteActor = attacker;
				riposteAllowedTime = theGame.GetEngineTime() + 1.0;
			}
		}
	}
	
	event OnRiposteAllowedEnd( attacker : CActor )
	{
		if( attacker == riposteActor )
		{
			theHud.m_hud.EnableRiposte( false );
			riposteActor = NULL;
			riposteAllowedTime = EngineTime();
		}
	}
	
	function Riposte() : bool
	{	
		if( theGame.GetEngineTime() < riposteAllowedTime )
		{
		//if ( HasAbility ( "ability_u3_riposte", 0 ) )
		//{			
		
			// Find enemy
			theHud.m_hud.EnableRiposte( false );
			DoRiposte( riposteActor );
			return true;
							
		//}
		}
		
		return false;
	}
	entry function DoRiposte( attacker : CActor )
	{	
		var eventEnum : EPlayerActionUnbreakable;
		//Adding story "Parry" ability for performing a certain number of riposte attacks
				
		if(FactsQuerySum("riposte_num") < 50)
		{
			FactsAdd("riposte_num", 1);
		}
		else if(!parent.GetCharacterStats().HasAbility('story_s30_1'))
		{
			AddStoryAbility('story_s30', 1);
		}
		if(parent.GetStamina() >= 1.0f)
		{
			parent.DecreaseStamina(1.0f);
		}
		UpdateCamera();

		// Find enemy
		ResetEnemy();
		//attacker.SetLastAttackedByPlayer(true);
		CacheEnemy( attacker );
		//enemy.ActionCancelAll();			
		
		riposteInProgressTime = theGame.GetEngineTime() + 10;

		if( parent.IsRotatedTowards (attacker) )
		{
			eventEnum = GetRipostedFrontEnums();
		}
		else
		{
			eventEnum = GetRipostedBackEnums();
		}
		
		if(eventEnum != PAU_None)
		{
			parent.SetRiposteInRow(parent.GetRiposteInRow() + 1);
			parent.PlayerActionUnbreakableForced(eventEnum);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation( 'UnbreakableActionEnd' );
		if(parent.GetRiposteInRow() >= 3)
		{
			Log("Achievement unlocked : ACH_CONCENTRATION");
			theGame.UnlockAchievement('ACH_CONCENTRATION');
		}
		riposteInProgressTime = EngineTime();
				
		UpdateCamera();			
	}
	
	event OnTakedownActor( target : CActor )
	{
		if( target.GetImmortalityMode() == AIM_None )
		{
			SetupTakedownParamsDefault( target, takedownParams );		
			parent.blockSpeedReset = true;
			parent.ChangePlayerState( PS_CombatTakedown );
			return true;
		}
		
		return false;
	}
	
	function GetRipostedFrontEvents() : name
	{
		var s : int;
		s = riposteFrontEvents.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return riposteFrontEvents[Rand(s)];
		}
	}
	function GetRipostedFrontEnums() : EPlayerActionUnbreakable
	{
		var s : int;
		s = riposteFrontEnums.Size();
		if( s == 0 )
		{
			return PAU_None;
		}
		else
		{	
			return riposteFrontEnums[Rand(s)];
		}
	}
	function GetRipostedBackEnums() : EPlayerActionUnbreakable
	{
		var s : int;
		s = riposteBackEnums.Size();
		if( s == 0 )
		{
			return PAU_None;
		}
		else
		{	
			return riposteBackEnums[Rand(s)];
		}
	}
	function GetRipostedBackEvents() : name
	{
		var s : int;
		s = riposteBackEvents.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return riposteBackEvents[Rand(s)];
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	function SetReflectedEvents()
	{
		reflectedEventsLeft.Clear();
		reflectedEventsRight.Clear();
		reflectedEventsLeft.Resize(0);
		reflectedEventsRight.Resize(0);
		
		//Eventy do animacji reflected left
		reflectedEventsLeft.PushBack(PCH_ReflectedLeft_1);
		reflectedEventsLeft.PushBack(PCH_ReflectedLeft_2);
		reflectedEventsLeft.PushBack(PCH_ReflectedLeft_3);
		
		//Eventy do animacji reflected right
		reflectedEventsRight.PushBack(PCH_ReflectedRight_1);
		reflectedEventsRight.PushBack(PCH_ReflectedRight_1);
		reflectedEventsRight.PushBack(PCH_ReflectedRight_1);
	}
	function GetReflectedEvent() : EPlayerCombatHit
	{
		var size : int;
		var reflectedEnum : EPlayerCombatHit;
		if(reflectedRightFlag)
		{
			reflectedRightFlag = false;
			size = reflectedEventsRight.Size();
			if(size > 0)
			{
				reflectedEnum = reflectedEventsRight[Rand(size)];
			}
			else
			{
				reflectedEnum = PCH_None;
			}
		}
		else
		{
			reflectedRightFlag = true;
			size = reflectedEventsLeft.Size();
			if(size > 0)
			{
				reflectedEnum = reflectedEventsLeft[Rand(size)];
			}
			else
			{
				reflectedEnum = PCH_None;
			}
		}
		return reflectedEnum;
	}
	
	event OnAttackBlocked( hitParams : HitParams )
	{
		var reflectedEnum : EPlayerCombatHit;
		reflectedEnum = GetReflectedEvent();
		if(reflectedEnum != PCH_None)
		{
			parent.PlayerCombatHit(reflectedEnum);
		}
	}
};
