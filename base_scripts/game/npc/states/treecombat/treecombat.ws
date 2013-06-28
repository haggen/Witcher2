/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Combat
/** Copyright © 2010
/***********************************************************************/

function UseNewCombat() : bool
{
	return true;
}

/////////////////////////////////////////////
// Base Tree Combat state
/////////////////////////////////////////////
state TreeCombat in CNewNPC extends Base
{
	var chargeAttackTime : EngineTime;
	var combatParams : SCombatParams;
	var holsterOnExit : bool;
	var canPlayDamageAnim : bool;
	var cantPlayDamageTime : EngineTime;
	
	default canPlayDamageAnim = true;
	default holsterOnExit = true;
	event OnEnterState()
	{
		//super.OnEnterState(); avoid ActionCancelAll
		parent.StopAllScenes();
		
		parent.AddTimer('ChangeCombatType', 1.0, true, true );
		if( parent.broadcastCombatInterestPoint )
		{
			parent.AddTimer('InterestPointTimer', 1.5, true, true );
		}
		
		parent.AddTimer('CombatModeTimer', 0.2, true );

		//parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 180.0f );
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 360.0f );
		parent.GetMovingAgentComponent().EnableCombatMode( true );
		parent.SetCombatSlotOffset(1.9);
		chargeAttackTime = EngineTime();
		parent.offSlot = OS_None;
	}
	
	event OnLeaveState()
	{	
		var mageStaff : SItemUniqueId;
		parent.RemoveTimer('ChangeCombatType');	
		parent.RemoveTimer('InterestPointTimer');
		/*if( thePlayer.GetCurrentPlayerState() != PS_CombatTakedown && !parent.IsCriticalEffectApplied( CET_Knockdown ) && !parent.IsCriticalEffectApplied( CET_Burn ) && !parent.IsCriticalEffectApplied( CET_Stun ))
		{
			if( holsterOnExit && !parent.GetArbitrator().HasCurrentGoalOfClass( 'CAIGoalIdleAfterCombat' ) )
			{
				if(parent.HasCombatType(CT_Mage) && !parent.GetArbitrator().HasCurrentGoalOfClass( 'CAIGoalQuestActing' ))
				{
					mageStaff = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
					if(mageStaff == GetInvalidUniqueId())
					mageStaff = parent.GetInventory().GetItemByCategory('steelsword', true);
					parent.GetInventory().UnmountItem(mageStaff, true);
				}
				//parent.HolsterWeaponInstant( parent.GetCurrentWeapon() );
			}
		}*/
		parent.GetBehTreeMachine().Stop(); // stop for not silent uninitialization
		parent.GetBehTreeMachine().Uninitialize();
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 720.f );
		parent.GetMovingAgentComponent().EnableCombatMode( false );
		parent.ClearRotationTarget();
		super.OnLeaveState();
		
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
	}
	
	event OnReenterCombat()
	{
		virtual_parent.EnterCombat(combatParams);
	}
	
	timer function ChangeCombatType( timeDelta : float )
	{
		if(!parent.IsAnyCriticalEffectApplied())
			parent.ChangeCombatIfNeeded( combatParams );
	}
	
	timer function InterestPointTimer( td : float )
	{
		theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( thePlayer.npcCombatInterestPoint, parent, 2.0 );
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{			
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3' || animEventName == 'FistFightAttack_t1')
		{						
			Attack( animEventName );			
		}
		else if( animEventType == AET_DurationStart && animEventName == 'attack_tell' )
		{			
			theHud.m_fx.PlayerIsAttackedStart( parent );
			parent.GetVisualDebug().AddText('attack_tell', "attack_tell", Vector(0,0,2), false, 0, Color(255,0,255), true, 3.0 );			
			if( parent.attackTarget == thePlayer )
			{
				//Character skills check
				if(thePlayer.GetCharacterStats().HasAbility('sword_s2'))
				{
					thePlayer.OnRiposteAllowedStart( parent );
				}
			}
		}
		else if( animEventType == AET_DurationEnd && animEventName == 'attack_tell' )
		{
			parent.GetVisualDebug().RemoveText('attack_tell');
			if( parent.attackTarget == thePlayer )
			{
				thePlayer.OnRiposteAllowedEnd( parent );
			}
		}
		else if( animEventName == 'Hardlock' )
		{
			if ( parent.GetTarget() && animEventType == AET_DurationStart )
			{								
				parent.SetRotationTarget( parent.GetTarget(), false );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.ClearRotationTarget();				
			}
		}
		else if( animEventName == 'Charging' )
		{
			if( theGame.GetEngineTime() - chargeAttackTime > 2.0 )
			{
				if( Attack( 'Attack_t4' ) )
				{
					chargeAttackTime = theGame.GetEngineTime();
				}
			}
		}
		else if( animEventName == 'Spitting' )
		{
			if( theGame.GetEngineTime() - chargeAttackTime > 2.0 )
			{
				if( Attack( 'Attack_t3' ) )
				{
					chargeAttackTime = theGame.GetEngineTime();
				}
			}
		}
		else if( animEventName == 'crt_poison' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Poison, parent);
		}
		else if( animEventName == 'crt_laming' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Laming, parent);
		}
		else if( animEventName == 'crt_bleed' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Bleed, parent);
		}
		else if( animEventName == 'crt_burn' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Burn, parent);
		}
		else if( animEventName == 'crt_knockdown' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Knockdown, parent);
		}
		else if( animEventName == 'crt_disarm' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Disarm, parent);
		}
		else if( animEventName == 'crt_immobile' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Immobile, parent);
		}
		else if( animEventName == 'crt_fear' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Fear, parent);
		}
		else if( animEventName == 'crt_stun' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Stun, parent);
		}
		else if( animEventName == 'crt_unbalance' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Unbalance, parent);
		}
		else if( animEventName == 'crt_falter' )
		{
			parent.GetTarget().ApplyCriticalEffect(CET_Falter, parent);
		}
		else if( animEventType == AET_Tick && animEventName == 'ClearEnemyRotation' )
		{
			parent.GetTarget().ClearRotationTarget();
		}
	}
	
	private entry function TreeDelayedCombatRestart()
	{
		parent.GetBehTreeMachine().Stop();
		CombatSleep( 1.0, 'DelayedCombatRestart' );
		parent.GetBehTreeMachine().Restart();
	}
	
	event OnBeforeAttack()
	{
		if( !parent.GetBehTreeMachine().IsStopped() )
		{
			parent.GetBehTreeMachine().Stop();
			parent.ActionCancelAll();
			TreeDelayedCombatRestart();
		}
	}
	
	event OnCombatSlotLost()
	{
		if( !parent.GetBehTreeMachine().IsStopped() )
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	event OnTicketChanged( poolType : W2TicketPoolType )
	{
		if( !parent.GetBehTreeMachine().IsStopped() )
		{
			parent.GetBehTreeMachine().Restart();
		}	
	}
	
	private final function Attack( attackType : name, optional impossibleToBlock : bool, optional forceHitAnim : bool ) : bool
	{
		if( parent.GetAttackTarget() )
		{
			if ( AttackRangeTest( parent.attackTarget )  )
			{
				parent.attackTarget.Hit( parent, attackType, impossibleToBlock, false, false, forceHitAnim );
				return true;
			}
		}
		else
		{
			Log(parent.GetName()+" NPC Combat OnAttackEvent: attackTarget is NULL!!!");
		}
		
		return false;
	}
	
	private function AttackRangeTest( target : CActor ) : bool
	{
		return parent.InAttackRange( target );
	}
	
	private latent function CombatSleep( time : float, reason : name )
	{		
		parent.GetVisualDebug().AddText( 'combatSleep', StrFormat("CombatSleep: %1 %2", reason, time), Vector(0,0,1.4), false, 0, Color(0, 255, 128), false, time );
		Sleep( time );
	}
	
	private latent function LoadTree( params : SCombatParams, optional noRestart : bool )
	{
		var machine : CBehTreeMachine;
		var tree : CBehTree;
		machine = parent.GetBehTreeMachine();
		tree = (CBehTree)LoadResource( GetTreeAlias( params ) );
		machine.Initialize( tree );		
		if( !noRestart )
		{
			machine.Restart();
		}
	}
	
	private function GetTreeAlias( params : SCombatParams ) : string
	{
		if( params.dynamicsType == CDT_BattleArea )
			return "behtree\combat_battlearea";
		if( params.dynamicsType == CDT_Static )
			return "behtree\combat_static";
		else
			return GetDefaultTreeAlias();
	}
	
	private function GetDefaultTreeAlias() : string {}
	
	private latent function ExitWork()
	{
		parent.ExitWork( parent.combatExitWorkMode );
	}
	
	private function RequestTicketIfNeeded( params : SCombatParams )
	{
		if( !UseNewCombat() )
			return;
	
		// Release ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
	
		// Does this kind of fight require the use of tickets?	
		if( parent.GetTarget() != thePlayer )
			return;
			
		if( params.fistfightArea )
			return;
			
		if( params.dynamicsType != CDT_Regular )
			return;

		// acquire a ticket
		thePlayer.GetTicketPool( TPT_Attack ).RequestTicket( parent );		
	}

	private final function GetHitEventName_t0() : name
	{		
		return parent.GetCombatEventsProxy().GetHitEventName_t0();
	}
	
	private final function GetHitEventName_t1() : name
	{
		return parent.GetCombatEventsProxy().GetHitEventName_t1();
	}
	private final function GetHitLightEnum() : W2BehaviorCombatHit
	{
		return parent.GetCombatEventsProxy().GetHitLightEnum();
	}
	private final function GetHitHeavyEnum() : W2BehaviorCombatHit
	{
		return parent.GetCombatEventsProxy().GetHitHeavyEnum();
	}
	private final function GetHitParryEnum() : W2BehaviorCombatHit
	{
		return parent.GetCombatEventsProxy().GetHitParryEnum();
	}
	private final function GetHitReflectedEnum() : W2BehaviorCombatHit
	{
		return parent.GetCombatEventsProxy().GetHitReflectedEnum();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can't slide along other agents
		return false;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		var pusherNPC : CActor;
		var attitude : EAIAttitude;
		pusherNPC = (CActor)pusher.GetEntity();
		
		if ( pusherNPC != thePlayer )
		{
			return false;
		}
		if(parent.IsBoss() || parent.IsHuge())
		{
			return false;
		}
		attitude = parent.GetAttitude( thePlayer );
		if ( attitude != AIA_Hostile )
		{
			parent.PushAway( pusher );
		}
		else
		{
			if(thePlayer.IsDodgeing())
			{
			
				//thePlayer.PushAwayFromPlayer(3.0, 1.0);
			}
		}
	}
}

/////////////////////////////////////////////
// TreeCombatStandard state
/////////////////////////////////////////////
state TreeCombatStandard in CNewNPC extends TreeCombat
{	
	
	event OnLeaveState()
	{
		parent.SetBehaviorVariable( 'EnableStaticCombat', 0.0 );
		parent.RemoveTimer('CombatModeTimer');
		super.OnLeaveState();
	}
	
	event OnHit( hitParams : HitParams )
	{
		parent.OnHit( hitParams );		
		TreeDelayedCombatRestart();
	}
	final function HitEvent(hitEvent : W2BehaviorCombatHit) : bool
	{
		var hitEventInt : int;
		parent.StartsWithCombatIdle(false);
		hitEventInt = (int)hitEvent;
		if(hitEventInt <= 0 || parent.SetBehaviorVariable("HitEnum", (float)hitEventInt) == false)
		{
			Log("dupsko blade");
		}
		//parent.SetBehaviorVariable("HitEnum", (float)hitEventInt);
		return parent.RaiseForceEvent('Hit');
	}
	final function SetCanPlayDamageAnim(canPlayDamage : bool, cooldown : float)
	{
		canPlayDamageAnim = canPlayDamage;
		cantPlayDamageTime = theGame.GetEngineTime() + cooldown;
	}
	final function CanPlayDamageAnim() : bool
	{
		var engineTime : EngineTime;
		engineTime = theGame.GetEngineTime();
		if(engineTime > cantPlayDamageTime || canPlayDamageAnim)
		{
			canPlayDamageAnim = true;
			return true;
		}
		else
		{
			return false;
		}
	}
	final function AttackEvent(attackEvent : W2BehaviorCombatAttack) : bool
	{
		var attackEventInt : int;
		attackEventInt = (int)attackEvent;
		parent.SetBehaviorVariable("AttackEnum", (float)attackEventInt);
		return parent.RaiseForceEvent('Attack');
	}
	final function ParryEnd(attackEvent : W2BehaviorCombatAttack) : bool
	{
		var attackEventInt : int;
		attackEventInt = (int)attackEvent;
		parent.SetBehaviorVariable("AttackEnum", (float)attackEventInt);
		return parent.RaiseEvent('ParryEnd');
	}
	latent final function ActivateCombatBehavior( params : SCombatParams, behaviorName : name )
	{
		parent.ActivateAndSyncBehavior( behaviorName );
		if ( params.dynamicsType != CDT_Regular )
		{
			parent.SetBehaviorVariable( 'EnableStaticCombat', 1.0 );
		}
		else
		{
			parent.SetBehaviorVariable( 'EnableStaticCombat', 0.0 );
		}
		parent.ProcessRequiredItems();
	}
}
