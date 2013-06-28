
enum ELethoBomb
{
	LB_Puffball,
	LB_Grapeshot
}
state TreeCombatRiszon in CNewNPC extends TreeCombatTwoHanded
{
	var lethoAard : CEntityTemplate;
	var lethoIgni : CEntityTemplate;
	var lethoPuffBall : CEntityTemplate;
	var lethoPuffBall_Grab : CEntityTemplate;
	var lethoGrapeShot : CEntityTemplate;
	var lethoGrapeShot_Grab : CEntityTemplate;
	var lethoBomb : ELethoBomb;
	var lethoBombTaken : CAttachedEntity;
	var parryToAardCounter : int;
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;
		
		hitCounter = 0;
		
		super.OnEnterState();
		
		parent.IssueRequiredItems( 'None', 'opponent_weapon' );
	
		parent.SetSuperblock( false );
		
		if( parent.CreateCombatEventsProxy( CECT_Riszon ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence4);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot1);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot2);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot3);
			
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected3);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected4);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected5);
			
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			
			combatEvents.specialAttackEnums1.PushBack(BCA_Throw1);
			
			combatEvents.specialAttackEnums2.PushBack(BCA_Special2);
			
			combatEvents.specialAttackEnums3.PushBack(BCA_Special3);
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
		}
	}
	entry function CombatRiszon( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		lethoAard = (CEntityTemplate)LoadResource("fx\lethoaard");
		lethoIgni = (CEntityTemplate)LoadResource("fx\lethoigni");
		lethoPuffBall = (CEntityTemplate)LoadResource("fx\puffball");;
		lethoPuffBall_Grab = (CEntityTemplate)LoadResource("fx\puffball_grab");;
		lethoGrapeShot = (CEntityTemplate)LoadResource("fx\lethograpeshot");;
		lethoGrapeShot_Grab = (CEntityTemplate)LoadResource("fx\lethograpeshot_grab");;
		SetCanPlayDamageAnim(false, 2.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_twohanded' );
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
		parent.LockEntryFunction(false);
	}
	private function GetDefaultTreeAlias() : string
	{	
		return "behtree\letho";
	}
	function CastLethoSign()
	{
		var sign : CMagicProjectile;
		var signPos : Vector;
		var signRot : EulerAngles;
		var boneMtx	: Matrix;
		var targetPosition : Vector;
		var ac 	: CAnimatedComponent = parent.GetRootAnimatedComponent();
		targetPosition = parent.GetTarget().GetWorldPosition();
		targetPosition.Z += 1.5;
		
		boneMtx = ac.GetBoneMatrixWorldSpace( 'l_weapon' );
		signPos = MatrixGetTranslation(boneMtx);
		signRot = MatrixGetRotation(boneMtx);
		if(VecDistance(parent.GetWorldPosition(), targetPosition) < 5.0)
		{
			sign = (CMagicProjectile)theGame.CreateEntity(lethoAard, signPos, signRot);
		}
		else
		{
			if(Rand(3) == 1)
			{
				sign = (CMagicProjectile)theGame.CreateEntity(lethoAard, signPos, signRot);
			}
			else
			{
				sign = (CMagicProjectile)theGame.CreateEntity(lethoIgni, signPos, signRot);
				
			}
		}
		sign.Init(parent);
		sign.Start(NULL, targetPosition, false, 1.0);
	}
	function CastLethoQuen()
	{
		parent.SetMagicShield(10.0);
	}
	function ThrowLethoBomb()
	{
		var lethoBombProj : CMagicProjectile;
		var lethoBombProjTMPL : CEntityTemplate;
		var targetPos : Vector;
		var target : CActor;
		var bombPos : Vector;
		var bombRot : EulerAngles;
		var boneMtx	: Matrix;
		var ac 	: CAnimatedComponent = parent.GetRootAnimatedComponent();
		if(lethoBomb == LB_Puffball)
		{
			lethoBombProjTMPL = lethoPuffBall;
		}
		else
		{
			lethoBombProjTMPL = lethoGrapeShot;
		}
		if(lethoBombTaken)
		{
			target = parent.GetTarget();
			if(target)
			{
				boneMtx = ac.GetBoneMatrixWorldSpace( 'l_weapon' );
				bombPos = MatrixGetTranslation(boneMtx);
				bombRot = MatrixGetRotation(boneMtx);				
				lethoBombProj = (CMagicProjectile)theGame.CreateEntity(lethoBombProjTMPL, bombPos, bombRot);
				lethoBombTaken.Destroy();
				lethoBombProj.Init(parent);
				targetPos = target.GetWorldPosition();
				lethoBombProj.Start(NULL, targetPos, false, 20.0, 1000.0);
			}

		}
	}
	function GetParryAttackEnum() : W2BehaviorCombatAttack
	{
		var rand : int;
		if(parryToAardCounter >= 6)
		{
			parryToAardCounter = 0;
			return BCA_CounterParry5;
		}
		rand = Rand(5) + 1;
		if(rand == 1)
		{
			return BCA_CounterParry1;
		}
		else if(rand == 2)
		{
			return BCA_CounterParry2;
		}
		else if(rand == 3)
		{
			return BCA_CounterParry3;
		}
		else if(rand == 4)
		{
			return BCA_CounterParry4;
		}
		else
		{
			return BCA_CounterParry5;
		}
	}
	event OnBeingHitPosition(hitParams : HitParams)
	{
		/*if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}*/
		if(parent.HasMagicShield())
		{
			parent.PlayEffect('electric_shield_hit');
			return false;
		}
		return true;
	}
	entry function LethoParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parryHitCounter = 0;
		parryToAardCounter += 1;
		parent.GetBehTreeMachine().Stop();
		parent.SetBlock(false);
		parent.SetAttackTarget(parent.GetTarget());
		parryAttack = GetParryAttackEnum();
		AttackEvent(parryAttack);
		parent.SetBlockingHit(false, 0.0);
		parent.WaitForBehaviorNodeDeactivation('ParryAttackEnd');
		if(parryAttack == BCA_CounterParry5 && !parent.HasMagicShield() && GetMagicShieldCooldown(15)&&theGame.GetDifficultyLevel()!=0)
		{
			LethoCastQuenSign();
		}
		parent.GetBehTreeMachine().Restart();
	}
	function GetMagicShieldCooldown(cooldown : float) : bool
	{
		var finishedTime : EngineTime;
		var engineTm : EngineTime;
		finishedTime = parent.GetMagicShieldFinishedTime();
		engineTm = theGame.GetEngineTime();
		if(parent.GetMagicShieldFinishedTime() + EngineTimeFromFloat(cooldown) < theGame.GetEngineTime())
		{
			return true;
		}
		return false;
	}
	
	event OnPlayerThrowBomb()
	{
		
		if(!parent.HasMagicShield())
		{
			if(Rand(3) > 0)
			{
				SetCanPlayDamageAnim(false, 1.5);
				LethoCastQuenSign();
			}
		}	
	}
	
	entry function LethoCastQuenSign()
	{
		var quen : W2BehaviorCombatAttack;
		parryHitCounter = 0;
		parent.GetBehTreeMachine().Stop();
		parent.SetBlock(false);
		parent.SetAttackTarget(parent.GetTarget());
		quen = BCA_Special3;
		AttackEvent(quen);
		parent.SetBlockingHit(false, 0.0);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function LethoParryQuick()
	{
		var parryAttack : W2BehaviorCombatAttack;
		if(parent.GetHealth()< 0.5*parent.GetCharacterStats().GetFinalAttribute('vitality') && Rand(2) == 1)
		{
			TwoHandedBerserk();
		}
		else
		{
			LethoParryAttack();
		}
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var isnlockinghit : bool = false;

		hitCounter += 1;

		if(parent.HasMagicShield())
		{
			parent.PlayEffect('electric_shield_hit');
			hitParams.attackReflected = true;
			return false;
		}
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			if((Rand(3) < hitCounter || parent.IsBlockingHit())&& parent.CheckCanBlock())
			{
				parent.SetBlock(true);
				parent.SetBlockingHit(true, 2.0);
				hitParams.attackReflected = true;
				hitCounter = 0;
				LethoParryQuick();
				return false;
			}
			else
			{
				return true;
			}
		}
		else
		{
			return true;
		}
			
	}
	function TakeBomb()
	{
		var bombPos : Vector;
		var bombRot : EulerAngles;
		var boneMtx	: Matrix;
		var ac 	: CAnimatedComponent = parent.GetRootAnimatedComponent();
		var lethoBombToTake : CEntityTemplate;
		
		boneMtx = ac.GetBoneMatrixWorldSpace( 'l_weapon' );
		bombPos = MatrixGetTranslation(boneMtx);
		bombRot = MatrixGetRotation(boneMtx);
		if(lethoBomb == LB_Puffball)
		{
			lethoBombToTake = lethoGrapeShot_Grab;
			lethoBomb = LB_Grapeshot;
		}
		else
		{
			lethoBombToTake = lethoPuffBall_Grab;
			lethoBomb = LB_Puffball;
		}
		lethoBombTaken = (CAttachedEntity)theGame.CreateEntity(lethoBombToTake, bombPos, bombRot);
		lethoBombTaken.Init(parent, "l_weapon");
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'CastSign')
		{						
			CastLethoSign();		
		}
		else if( animEventType == AET_Tick && animEventName == 'CastQuen')
		{						
			CastLethoQuen();		
		}
		else if( animEventType == AET_Tick && animEventName == 'TakeBomb')
		{						
			TakeBomb();	
		}
		else if( animEventType == AET_Tick && animEventName == 'ThrowBomb')
		{						
			ThrowLethoBomb();		
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
}