/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatArachas in CArachas extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var aoe : CAreaOfEffect;
	var counterTime : EngineTime;
	var superblockLevels : array<int>;
	var superblockCounter : int;
	var hitCounter : int;
	var parryCounter : int;
	var target : CActor;
	var spitTime : EngineTime;
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
				
		if( parent.CreateCombatEventsProxy( CECT_Arachas ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Arachas Nekker Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			
			//Arachas nekker hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			
			//Combat special attacks
			combatEvents.specialAttackEnums1.PushBack(BCA_Special1);
			
			//Combat parry
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
		}		
			
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.StopEffect( 'smoke_curtain' );
		theCamera.StopEffect('fog_arachas');
		parent.ClearAttackTarget();
		
	}
	
	entry function TreeCombatArachas( params : SCombatParams )
	{
		LoadTree( params );
		//parent.GetBehTreeMachine().EnableDebugDumpRestart(true);
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\arachas";
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var target : CActor;
		
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if( animEventName == 'Spitting' )
		{
			if( theGame.GetEngineTime() - spitTime > 2.0 )
			{
				Spit();
				spitTime = theGame.GetEngineTime();
			}
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if( animEventName == 'Spit' )
		{
			parent.PlayEffect('attack_distance01');
		}
		else if ( animEventName == 'Smoke' && animEventType == AET_Tick )
		{
			Smoke();
		}
		else if ( animEventName == 'InCharge' )
		{
			parent.PlayEffect ('fx_attack01');
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if ( animEventName == 'stomp' )
		{
			parent.PlayEffect ('fx_attack01');
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if ( animEventName == 'DenyBlock' )
		{
		 	if( parent.GetTarget() == thePlayer )
			{
				thePlayer.OnBlockRelease();
			}
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}

	}
	
	function Smoke()
	{
		var itemId : SItemUniqueId;
		var inventory : CInventoryComponent = parent.GetInventory();
		
		itemId = inventory.GetItemId( 'Arachas Bomb' );
		if( itemId != GetInvalidUniqueId() )
		{
			aoe = (CAreaOfEffect) inventory.GetDeploymentItemEntity( itemId, parent.GetWorldPosition(), parent.GetWorldRotation() );
			parent.PlayEffect('smoke_curtain');
			theCamera.PlayEffect('fog_arachas');
			SetSmokeTimer();
		}
		else
		{
			Logf("ERROR Arachas %1 has no spit item!!!", parent.GetName() );
		}
	}
	
	function SetSmokeTimer()
	{
		parent.AddTimer( 'SmokeEnd', 5.0, false );
	}
	
	
	timer function SmokeEnd( timeDelta : float )
	{
		parent.StopEffect( 'smoke_curtain' );
		theCamera.StopEffect('fog_arachas');
		aoe.Destroy();
	}
	function TargetInRange( rangeNameString : string ) : bool
	{
		var TargetPosition : Vector;
		var range : CInteractionAreaComponent;
		TargetPosition = parent.GetTarget().GetWorldPosition();
		range = (CInteractionAreaComponent)parent.GetComponent( rangeNameString );
		if( range )
		{
			return range.ActivationTest( parent.GetTarget() );
		}
		else
		{
			Log( "ARACHAS ERROR: No -- "+ rangeNameString +" -- CInteractionAreaComponent in dragon entity" );
			return false;
		}			
	}
	function Spit()
	{
		var target : CActor;
		if(TargetInRange("SpitRange"))
		{
			target = parent.GetTarget();
			target.ApplyCriticalEffect(CET_Poison, NULL);
		}
	}
	entry function ArachasParry()
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
		rand = Rand(5);
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
			ArachasParry();
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
		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				HitStrongArachas();
			}
			else
			{
				HitFastArachas();
			}
		}
	}
	
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
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
		AardReactionArachas();
	}
	entry function AardReactionArachas()
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
	entry function HitFastArachas()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongArachas()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	private function DebugRot(angle: float)
	{
		parent.GetVisualDebug().AddText( 'rot', "Rotation "+angle, Vector(0,0,0.5), false, 0, Color(255,255,0), false, 2.0 );
	}
	
};
