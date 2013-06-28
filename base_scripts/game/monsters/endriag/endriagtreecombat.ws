/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatEndriaga in CEndriag extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	//var bombEntity : CBomb;
	var counterTime : EngineTime;
	var superblockLevels : array<int>;
	var superblockCounter : int;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		
		if( parent.CreateCombatEventsProxy( CECT_Endriag ) )
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
			combatEvents.idleEnums.PushBack(BCI_Idle3);
			combatEvents.idleEnums.PushBack(BCI_Idle4);
			combatEvents.idleEnums.PushBack(BCI_Idle5);
			
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
		theCamera.StopEffect('fog_Endriag');
		parent.ClearAttackTarget();
	}
	
	entry function TreeCombatEndriag( params : SCombatParams )
	{
		LoadTree( params );
		//parent.GetBehTreeMachine().EnableDebugDumpRestart(true);
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\endriag";
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if ( animEventName == 'Spit' && animEventType == AET_Tick )
		{
			Spit();
		}
		//else if ( animEventName == 'Smoke' && animEventType == AET_Tick )
		//{
		//	Smoke();
		//}
		else if ( animEventName == 'InCharge' )
		{
			parent.PlayEffect ('fx_attack01');
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
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
	
	function Spit()
	{
		var itemId : SItemUniqueId;
		var projectile : CEndriagSpit;
		var inventory : CInventoryComponent = parent.GetInventory();
				
		itemId = inventory.GetItemId( 'Endriag Spit' );
		if( itemId != GetInvalidUniqueId() )
		{
			projectile = (CEndriagSpit)inventory.GetDeploymentItemEntity( itemId, parent.GetWorldPosition() + Vector(0,0,1), parent.GetWorldRotation() );								
			projectile.Init( parent );
			parent.PlayEffect( 'attack_distance01' );
			
			projectile.ShootProjectileAtNode( 10.0, 20.0, 6.0, NULL );
		}
		else
		{
			Logf("ERROR Endriag %1 has no spit item!!!", parent.GetName() );
		}
	}
	
	event OnBeingHit( out hitParams : HitParams )
	{
		if(theGame.GetDifficultyLevel() <= 0)
		{	
			return true;
		}
		if( !parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )			
		{
			//hitParams.outDamageMultiplier = 4.0;
			return true;
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
				HitStrongEndriaga();
			}
			else
			{
				HitFastEndriaga();
			}
			
		}
	}
	entry function AardReactionEndriaga()
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
	entry function HitFastEndriaga()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongEndriaga()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
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
		AardReactionEndriaga();
	}
		
	private function DebugRot(angle: float)
	{
		parent.GetVisualDebug().AddText( 'rot', "Rotation "+angle, Vector(0,0,0.5), false, 0, Color(255,255,0), false, 2.0 );
	}
	
};
