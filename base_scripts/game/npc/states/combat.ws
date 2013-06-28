/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Base Combat state
/////////////////////////////////////////////
/*import state Combat in CNewNPC extends Base
{
	var combatParams : SCombatParams;
	
	event OnEnterState()
	{
		//super.OnEnterState(); avoid ActionCancelAll
		
		parent.StopAllScenes();
		
		parent.AddTimer('ChangeCombatType', 1.0, true, true );
		if( parent.broadcastCombatInterestPoint )
		{
			parent.AddTimer('InterestPointTimer', 1.5, true, true );
		}
		//parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 180.0f );
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 360.0f );
		parent.GetMovingAgentComponent().EnableCombatMode( true );
		parent.SetCombatSlotOffset(1.9);
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.RemoveTimer('ChangeCombatType');
		parent.RemoveTimer('InterestPointTimer');
		parent.HolsterWeaponAsync();
				
		DebugMarkAnimationEnd();
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec( 720.f );
		parent.GetMovingAgentComponent().EnableCombatMode( false );
	}
	
	event OnReenterCombat()
	{
		virtual_parent.EnterCombat(combatParams);
	}
	
	timer function ChangeCombatType( timeDelta : float )
	{
		parent.ChangeCombatIfNeeded( combatParams );
	}
	
	timer function InterestPointTimer( td : float )
	{
		theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( thePlayer.npcCombatInterestPoint, parent, 2.0 );
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{			
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'FistFightAttack_t1')
		{						
			Attack( animEventName );			
		}
		else if( animEventType == AET_DurationStart && animEventName == 'attack_tell' )
		{						
			theHud.m_fx.PlayerIsAttackedStart( parent );
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
	}
	
	private final function Attack( attackType : name )
	{
		if( parent.GetAttackTarget() )
		{
			if ( AttackRangeTest( parent.attackTarget )  )
			{
				parent.attackTarget.Hit( parent, attackType );
			}
		}
		else
		{
			Log(parent.GetName()+" NPC Combat OnAttackEvent: attackTarget is NULL!!!");
		}
	}
	
	private function AttackRangeTest( target : CActor ) : bool
	{
		return parent.InAttackRange( target );
	}
	
	latent function RotateToTarget( time : float )
	{
		var target : CActor;
		var vec : Vector;
		var rot, curRot : EulerAngles;
		target = parent.GetTarget();
		if( target )
		{
			vec = target.GetWorldPosition() - parent.GetWorldPosition();
			rot = VecToRotation( vec );
			
			curRot = parent.GetWorldRotation();
			if( AbsF( AngleDistance( curRot.Yaw, rot.Yaw )) > 1.0 )
			{			
				parent.RaiseForceEvent( 'FakeRotation' );
				parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time );
				parent.RaiseForceEvent( 'Idle' );
			}
		}
	}
	
	private latent function CombatSleep( time : float, reason : name )
	{		
		parent.GetVisualDebug().AddText( 'combatSleep', StrFormat("CombatSleep: %1 %2", reason, time), Vector(0,0,1.4), false, 0, Color(0, 255, 128), false, time );
		Sleep( time );
	}
	
	private function DebugMarkAnimationStart( info : string, eventName : name )
	{
		parent.GetVisualDebug().AddText('actionAnim', StrFormat("%1: %2", info, eventName), Vector(0,0,1.4), false, 0, Color(0, 255, 128) );
	}
	
	private function DebugMarkAnimationEnd()
	{
		parent.GetVisualDebug().RemoveText('actionAnim');
	}
}*/

