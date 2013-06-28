enum EGuardingReaction
{
	GR_Aware,
	GR_Attention,
	GR_Blocking	
};

class CCommunityGuardingArea extends CGameplayEntity
{
	editable var GuardsReactionOnAproacher 			: EGuardingReaction;
	editable var BlockWithDeniedAreaWithTag 		: name;
	editable var LeftGuardTag 						: name;
	editable var RightGuardTag 						: name;
	editable var ReactOnlyOnPlayer 					: bool;
	var lastLeftGuardAP								:int;
	var lastRightGuardAP							:int;
	
	
	private var isDisabled : bool;

	default ReactOnlyOnPlayer = true;

	function SetEnabled( enable : bool )
	{
		var area : CTriggerAreaComponent;
		var guard_left				: CNewNPC;
		var guard_right				: CNewNPC;
		
		area = (CTriggerAreaComponent)GetComponentByClassName('CTriggerAreaComponent');
		area.SetEnabled( enable );
		
		if( !enable )
		{
			guard_left = ( CNewNPC )theGame.GetEntityByTag( this.LeftGuardTag );
			guard_right = ( CNewNPC )theGame.GetEntityByTag( this.RightGuardTag );
			
			if( guard_left )
				guard_left.OnCommunityGuardingAreaExit( this );
			
			if( guard_right )
				guard_right.OnCommunityGuardingAreaExit( this );
		}
	}
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var aproacher 				: CEntity;
		var guard_left				: CNewNPC;
		var guard_right				: CNewNPC;
				
		guard_left = ( CNewNPC )theGame.GetEntityByTag( this.LeftGuardTag );
		guard_right = ( CNewNPC )theGame.GetEntityByTag( this.RightGuardTag );
		aproacher = activator.GetEntity();
		
		lastLeftGuardAP = guard_left.GetLastActionPoint();
		lastRightGuardAP = guard_right.GetLastActionPoint();
		
		if( aproacher.HasTag( this.LeftGuardTag ) || aproacher.HasTag( this.RightGuardTag ) )
		{
			return false;
		}
	
		if( this.ReactOnlyOnPlayer == true )
		{
			if( ! aproacher.IsA( 'CPlayer' ) )
			{ 
				return false;
			}
		}
		
		if( this.GuardsReactionOnAproacher == GR_Aware )
		{			
			guard_left.GetArbitrator().AddGoalGuardWithReaction(true);
			guard_right.GetArbitrator().AddGoalGuardWithReaction(false);
		}
		else
		{		
			if( guard_left )
				guard_left.OnCommunityGuardingAreaEnter( this );
				
			if( guard_right )
				guard_right.OnCommunityGuardingAreaEnter( this );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var aproacher 				: CEntity;
		var guard_left 				: CNewNPC;
		var guard_right 			: CNewNPC;
		var denied_area 			: CEntity;
				
		guard_left = ( CNewNPC )theGame.GetEntityByTag( this.LeftGuardTag );
		guard_right = ( CNewNPC )theGame.GetEntityByTag( this.RightGuardTag );
		aproacher = activator.GetEntity();
	
		if( this.ReactOnlyOnPlayer == true )
		{
			if( !aproacher.IsA( 'CPlayer' ) )
			{ 
				return false;
			}
		}

		if( guard_left )
			guard_left.OnCommunityGuardingAreaExit( this );
			
		if( guard_right )
			guard_right.OnCommunityGuardingAreaExit( this );
	}
}

state StateGuardReacting in CNewNPC extends Base
{
	var failedEventName : name;
	
	event OnEnterState()
	{
		//super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		parent.DetachBehavior( 'npc_guarding_reaction' );
	/*	
		if ( !parent.RaiseForceEvent( 'freezeMe' ) )
		{
			Log( "ERROR in StateGuardReacting");
		}
	*/	
		super.OnLeaveState();
	}

	entry function SetGuardingStateAware( left : bool, goalId : int )
	{
		var pos : Vector;
		var dir : float;
		
		theGame.GetAPManager().GetActionExecutionPosition( parent.GetLastActionPoint(), pos, dir );
		if( VecDistance2D( parent.GetWorldPosition(), pos ) > 0.1f )
			parent.MoveToActionPoint( parent.GetLastActionPoint(), false );

		// set goal id first
		SetGoalId( goalId );
		
		parent.ExitWork( EWM_ExitFast );
		
		parent.AttachBehavior( 'npc_guarding_reaction' );
		
		if ( !parent.RaiseForceEvent( 'freezeMe' ) )
		{
			Log( "ERROR in StateGuardReacting");
		}
		
		if( left )
		{
			parent.SetBehaviorVariable( "GuardSide", 0.f );
		}
		else
		{
			parent.SetBehaviorVariable( "GuardSide", 1.f );		
		}
	}
	
	entry function ExitGuardingState()
	{
		parent.RaiseForceEvent( 'forceIdle' );
		parent.WaitForBehaviorNodeDeactivation( 'IdleFinished' );
		MarkGoalFinished();
	}

	event OnCommunityGuardingAreaEnter( area : CCommunityGuardingArea )
	{
		var denied_area				: CEntity;
		var request 				: CEnableDeniedAreaRequest;
		
		if( area.GuardsReactionOnAproacher == GR_Attention )
		{
			parent.RaiseForceEvent('attention_start');
		}	

		else if( area.GuardsReactionOnAproacher == GR_Blocking )
		{
			if( !parent.RaiseEvent('blocking_start') )
			{
				failedEventName = 'blocking_start';
				parent.AddTimer( 'ReriseFailedEvent', 0.01, true );
			}
			else
				parent.RemoveTimer( 'ReriseFailedEvent' );
		
			if ( IsNameValid( area.BlockWithDeniedAreaWithTag ) ) 		
			{
				request = new CEnableDeniedAreaRequest in theGame;
				request.enable = true;
				theGame.AddStateChangeRequest( area.BlockWithDeniedAreaWithTag, request );
			}
		}	
	}
	
	event OnCommunityGuardingAreaExit( area : CCommunityGuardingArea )
	{
		var denied_area				: CEntity;
		var request 				: CEnableDeniedAreaRequest;
	
		if( area.GuardsReactionOnAproacher == GR_Aware )
		{
			ExitGuardingState();
		}
		if( area.GuardsReactionOnAproacher == GR_Attention )
		{
			parent.RaiseForceEvent('attention_stop');
		}
		else if( area.GuardsReactionOnAproacher == GR_Blocking )
		{
			if( !parent.RaiseEvent('blocking_stop') )
			{
				failedEventName = 'blocking_stop';
				parent.AddTimer( 'ReriseFailedEvent', 0.01, true );
			}
			else
				parent.RemoveTimer( 'ReriseFailedEvent' );
			
			if ( IsNameValid( area.BlockWithDeniedAreaWithTag ) ) 		
			{
				request = new CEnableDeniedAreaRequest in theGame;
				request.enable = false;
				theGame.AddStateChangeRequest( area.BlockWithDeniedAreaWithTag, request );
			}
		}
	}
	
	timer function ReriseFailedEvent( time : float )
	{
		if( parent.RaiseEvent( failedEventName ) )
			parent.RemoveTimer( 'ReriseFailedEvent' );
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
}

exec function et( triggerTag : name, enable : bool ) : bool
{
	var triggers : array<CNode>;
	var size, i : int;
	
	theGame.GetNodesByTag( triggerTag, triggers );
	size = triggers.Size();
	
	if( size == 0 )
	{
		Log( "function QEnableGuardingTrigger: Couldn't find CCommunityGuardingArea with tag '" + triggerTag + "'." );
		return false;
	}
	
	for( i = 0; i < size; i += 1 )
	{
		((CCommunityGuardingArea)triggers[i]).SetEnabled( enable );
	}
	return true;
}
