/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatTwoHandedBomb state
/////////////////////////////////////////////

state TreeCombatTwoHandedDagger in CNewNPC extends TreeCombatTwoHanded
{
	var lethoGrapeShot : CEntityTemplate;
	var lethoGrapeShot_Grab : CEntityTemplate;
	var lethoBomb : ELethoBomb;
	var lethoBombTaken : CAttachedEntity;

	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;
		
		hitCounter = 0;
		
		super.OnEnterState();
		
		parent.IssueRequiredItems( 'None', 'opponent_weapon' );
	
		parent.SetSuperblock( false );
		
		if( parent.CreateCombatEventsProxy( CECT_NPCTwoHandedThrow ) )
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
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
		}
	}	
	entry function TreeCombatTwoHandedDagger( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		
		lethoGrapeShot = (CEntityTemplate)LoadResource("fx\dagger");
		lethoGrapeShot_Grab = (CEntityTemplate)LoadResource("fx\lethograpeshot_grab");
		
		SetCanPlayDamageAnim(false, 6.0);
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
		if( parent.GetTarget() == thePlayer )
		{
			return "behtree\player_combat_twohandeddagger";
		}
		else
		{	
			return "behtree\combat_twohandeddagger";			
		}
	}
		

	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'TakeBomb')
		{						
			TwoHandedTakeDagger();	
		}
		else if( animEventType == AET_Tick && animEventName == 'ThrowBomb')
		{						
			TwoHandedThrowDagger();		
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	
	function TwoHandedTakeDagger()
	{
		var bombPos : Vector;
		var bombRot : EulerAngles;
		var boneMtx	: Matrix;
		var ac 	: CAnimatedComponent = parent.GetRootAnimatedComponent();
		var lethoBombToTake : CEntityTemplate;
		
		boneMtx = ac.GetBoneMatrixWorldSpace( 'l_weapon' );
		bombPos = MatrixGetTranslation(boneMtx);
		bombRot = MatrixGetRotation(boneMtx);
		
		lethoBombToTake = lethoGrapeShot_Grab;
		lethoBomb = LB_Grapeshot;
		
		lethoBombTaken = (CAttachedEntity)theGame.CreateEntity(lethoBombToTake, bombPos, bombRot);
		lethoBombTaken.Init(parent, "l_weapon");
	}
	
	function TwoHandedThrowDagger()
	{
		var lethoBombProj : CRegularProjectile;
		var lethoBombProjTMPL : CEntityTemplate;
		var targetPos : Vector;
		var target : CActor;
		var bombPos : Vector;
		var bombRot : EulerAngles;
		var boneMtx	: Matrix;
		var ac 	: CAnimatedComponent = parent.GetRootAnimatedComponent();
		var sourceToTarget : Vector;
		var sourceToTargetDist : float;
		var newTargetPos : Vector;
		var norm : EulerAngles;
		var distMult : float = 5;
		
		lethoBombProjTMPL = lethoGrapeShot;

		if(lethoBombTaken)
		{
			target = parent.GetTarget();
			if(target)
			{
				boneMtx = ac.GetBoneMatrixWorldSpace( 'l_weapon' );
				bombPos = MatrixGetTranslation(boneMtx);
				bombRot = MatrixGetRotation(boneMtx);
				lethoBombProj = (CRegularProjectile)theGame.CreateEntity(lethoBombProjTMPL, bombPos, bombRot);
				lethoBombTaken.Destroy();
				lethoBombProj.Init(parent);
				targetPos = target.GetWorldPosition();
				
				
				
				sourceToTarget = targetPos - parent.GetWorldPosition();
				
				sourceToTargetDist = VecLength(sourceToTarget);
				
				sourceToTarget = VecNormalize(sourceToTarget);
				
				newTargetPos =  targetPos + sourceToTarget * distMult;
				
				if(!theGame.GetWorld().PointProjectionTest( newTargetPos, norm, 2 ))
				{
					newTargetPos = targetPos;
				}
				
				lethoBombProj.Start(NULL, newTargetPos, false, 5.0, 1000.0);
			}

		}
	}
}