/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatTroll in W2MonsterTroll extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var counterTime : EngineTime;
	var superblockLevels : array<int>;
	var superblockCounter : int;
	var rock, destructionRock : CEntityTemplate;
	var rockEnt : CEntity;
	var hitCounter : int;
	var parryCounter : int;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		super.OnEnterState();
		parent.noragdollDeath = true;
		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		if( parent.CreateCombatEventsProxy( CECT_Troll ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Troll Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			
			//Troll hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			
			//Troll Throw
			combatEvents.throwEnums.PushBack(BCA_Throw1);
			//Combat parry
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
		}
						
		parent.SetCombatSlotOffset(1.9);
	
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearAttackTarget();
		rockEnt.Destroy();
	}
	
	entry function TreeCombatTroll( params : SCombatParams )
	{
		ActivateCombatBehavior(params, 'npc_exploration');
		LoadTree( params );
		rock = (CEntityTemplate)LoadResource("fx\troll\troll_rock");
		destructionRock = (CEntityTemplate)LoadResource("fx\troll\troll_rock_dest");
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\troll";
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3' )
		{						
			Attack( animEventName, true );			
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if ( animEventName == 'ground_hit' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
		}	
		else if ( animEventName == 'step' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
		}
		else if ( animEventName == 'take_rock' && animEventType == AET_Tick )
		{
			TakeRock();
		}
		else if ( animEventName == 'throw_rock' && animEventType == AET_Tick )
		{
			ThrowRock(rockEnt);
		}
		else if ( animEventName == 'stomp' && animEventType == AET_Tick )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 64.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}
		else if ( animEventName == 'bomb' && animEventType == AET_Tick )
		{
			BombCheck();
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	function TakeRock()
	{
		var boneMtx	: Matrix;
		var position : Vector;
		var rotation : EulerAngles;
		boneMtx = parent.GetRootAnimatedComponent().GetBoneMatrixWorldSpace( 'r_weapon' );
		position = MatrixGetTranslation(boneMtx);
		rotation = MatrixGetRotation(boneMtx);
		rockEnt = theGame.CreateEntity(rock, position, rotation);
		parent.AttachEntityToBone(rockEnt, 'r_weapon');
		rockEnt.PlayEffect('destruction_fx');
	}
	function ThrowRock(takenRock : CEntity)
	{
		var trollRock : CTrollRock;
		var actorTarget : CActor;
		var targetPos : Vector;
		var headingVec : Vector;
		var normal : EulerAngles;
		var rockPos : Vector;
		var rockRot : EulerAngles;
		var boneMatrix : Matrix;
		if(takenRock)
		{
			boneMatrix = parent.GetRootAnimatedComponent().GetBoneMatrixWorldSpace( 'r_weapon' );
			rockPos = MatrixGetTranslation(boneMatrix);
			rockRot = MatrixGetRotation(boneMatrix);
			parent.DetachEntityFromSkeleton(takenRock);
			trollRock = (CTrollRock)theGame.CreateEntity(rock, rockPos, rockRot);
			actorTarget = parent.GetTarget();
			if(actorTarget && VecDistance(actorTarget.GetWorldPosition(), parent.GetWorldPosition()) > 3.0)
			{
				targetPos = actorTarget.GetWorldPosition();
				theGame.GetWorld().PointProjectionTest(targetPos, normal, 2.0);
			}
			else
			{
				headingVec = VecFromHeading(parent.GetHeading());
				targetPos = parent.GetWorldPosition() + 15.0*headingVec;
				theGame.GetWorld().PointProjectionTest(targetPos, normal, 2.0);
			}
			//takenRock.Destroy();
			trollRock.PlayEffect('trail_fx');
			trollRock.Init(parent);
			trollRock.Start(NULL, targetPos, false, 10.0);
			//trollRock.PlayEffect('destruction_fx');
			parent.AddTimer('DestroyRock', 0.1, false);
		}
	}
	timer function DestroyRock(td : float)
	{
		rockEnt.Destroy();
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Bomb
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function BombCheck()
	{
		if ( parent.bombRetryTimer <= 0 && parent.bombHitCount >= parent.hitCountCapForBomb && parent.health <= parent.bombLowHealthValue )
		{
			SetOffPetard();
		}
	}

	private function SetOffPetard()
	{
		var itemId : SItemUniqueId;
		var inventory : CInventoryComponent = parent.GetInventory();
		var petardEntity : CAreaOfEffect;
		var petardPosition : Vector = parent.GetWorldPosition();
		
		itemId = inventory.GetItemId( 'Troll Bomb' );
		if( itemId != GetInvalidUniqueId() )
		{
			petardEntity = (CAreaOfEffect) inventory.GetDeploymentItemEntity( itemId, petardPosition + Vector(0,0,-1), parent.GetWorldRotation() );
			petardEntity.SetOwner( parent );
			GetActorsInRange( petardEntity.affected, petardEntity.EffectRadius, '', petardEntity );
			petardEntity.ApplyDamage( true );
		}
		else
		{
			Logf("ERROR Troll % 1 has no Troll Bomb item!!!", parent.GetName() );
		}
		
		// Reset bomb triggers
		parent.bombRetryTimer = parent.retryBombTime;
		parent.bombHitCount = 0;
	}
	entry function TrollParry()
	{
		var rand : int; 
		rand = Rand(3);
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget(parent.GetTarget());
		if( parryCounter < rand)
		{
			parryCounter += 1;
			HitEvent(GetHitParryEnum());
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
			Sleep(2.0);
		}
		parryCounter = 0;
		if(Rand(2) == 1)
		{
			AttackEvent(BCA_CounterParry1);
		}
		else
		{
			AttackEvent(BCA_CounterParry2);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var rand : int;
		rockEnt.Destroy();
		rand = Rand(5) + 3;
		if(theGame.GetDifficultyLevel() <= 0)
		{	
			return true;
		}
		if( !parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )			
		{
			//hitParams.outDamageMultiplier = 4.0;
			return true;
		}
		hitCounter += 1;
		if(parent.CheckCanBlock() && hitCounter > rand)
		{
			hitCounter = 0;
			TrollParry();
			hitParams.attackReflected = true;
			hitParams.attacker.PlaySparksOnHit(hitParams.attacker, hitParams);
			return false;
		}
		
		return true;
	}
	event OnAttackTell( hitParams : HitParams )
	{

	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{
		rockEnt.Destroy();
		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				HitStrongTroll();
			}
			else
			{
				HitFastTroll();
			}
		}
	}
	
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
		rockEnt.Destroy();
		if(effectType == CET_Burn)
		{
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		rockEnt.Destroy();
		if(parent.AardKnockdownChance())
		{
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				AardReactionTroll();
			}
		}
		else
		{
			AardReactionTroll();
		}
		
	}
	entry function AardReactionTroll()
	{

			parent.SetBlockingHit(false);
			parent.SetBlock(false);
			parent.CantBlockCooldown(3.0);
			parent.ActionCancelAll();
			parent.SetRotationTarget( parent.GetTarget() );
			parent.GetBehTreeMachine().Stop();	
			HitEvent(BCH_AardHit1);
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
			parent.GetBehTreeMachine().Restart();
		
	}	
	entry function HitFastTroll()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongTroll()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
};
