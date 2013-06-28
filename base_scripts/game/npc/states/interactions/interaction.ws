/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Base interaction state
/////////////////////////////////////////////
state BaseInteraction in CNewNPC extends Base
{
	var behName : name;

	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetLookAtMode( LM_GameplayLock );
	}

	event OnLeaveState()
	{
		// Pop custom behavior
		PopInteractionBehavior();
		
		parent.ResetLookAtMode( LM_GameplayLock );
		
		super.OnLeaveState();
	}
	
	// Push special custom interaction behavior
	final function PushInteractionBehavior( filename : name )
	{
		behName = filename;
		parent.ActivateBehavior( behName );
	}
	
	// Pop special custom interaction behavior
	final function PopInteractionBehavior()
	{
		//parent.GetRootAnimatedComponent().PopBehaviorGraph( behName );
	}
};

/////////////////////////////////////////////
// Master interaction state
/////////////////////////////////////////////
state MasterInteraction in CNewNPC extends BaseInteraction
{
	var slaves : array< CActor >;
	var action : IActorLatentAction;
	
	event OnLeaveState()
	{
		var i : int;
		var slavesNum : int;
		
		// Set slaves free
		slavesNum = slaves.Size();
		for ( i=0; i<slavesNum; i+=1 )
		{
			slaves[i].OnStopInteractionState( CTM_Instant );
		}
		slaves.Clear();
		
		if ( action )
		{
			action.Cancel( parent );
			action = NULL;
		}
		
		super.OnLeaveState();
	}
	
	event OnSpeedChanged( component : CAnimatedComponent, newSpeed : float )
	{
		var i : int;
		var slavesNum : int;
		
		if ( component == parent.GetRootAnimatedComponent() )
		{
			// Propagate speed to all slaves
			slavesNum = slaves.Size();
			for ( i=0; i<slavesNum; i+=1 )
				slaves[i].SetBehaviorVariable( "masterSpeed", newSpeed );
		}
	}
	
	latent function WaitForSlaves( inputSlaves : array<EntityHandle> ) : bool
	{
		var i : int;
		var slavesNum : int = inputSlaves.Size();		
		
		for ( i=0; i<slavesNum; i+=1 )
		{
			EntityHandleWaitGet( inputSlaves[i] );
		}
	}
	
	entry function StateInteractionMaster( inputSlaves : array<EntityHandle>, masterBehaviorName : name, slaveBehaviorName : name,
											latentAction : IActorLatentAction, nodeOfInterest : EntityHandle, instantStart : bool, goalId : int )
	{
		var i : int;
		var slavesNum : int;
		
		SetGoalId( goalId );
		
		WaitForSlaves( inputSlaves );
		
		action    = latentAction;
		slavesNum = inputSlaves.Size();
		slaves.Grow( slavesNum );				
		for( i=0; i<slavesNum; i+= 1 )
		{
			slaves[i] = (CActor)EntityHandleGet( inputSlaves[i] );
		}
		
		// Push custom behavior
		PushInteractionBehavior( masterBehaviorName );
		if( instantStart )
		{
			parent.RaiseForceEvent('InstantStart');
		}
		
		// Prepare slaves
		for ( i=0; i<slavesNum; i+=1 )
		{
			slaves[i].EnterSlaveState( parent, slaveBehaviorName, instantStart, 0.0 );
		}
		
		// Perform latent action
		if( action )
		{
			parent.SetFocusedNode( EntityHandleGet( nodeOfInterest ) );
			
			action.Perform( parent );
			action = NULL;
		}

		// Slaves will be released in OnLeaveState
		
		// Keep goal running
		//MarkGoalFinished();
	}
};

/////////////////////////////////////////////
// Slave interaction state
/////////////////////////////////////////////
state SlaveInteraction in CNewNPC extends BaseInteraction
{
	var master : CActor;
	var isStopping : bool;
	
	event OnLeavingState()
	{
		// Don't exit state if we are still someones slave
		return ! master;
	}
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnablePathEngineAgent( false );
		if( !parent.HasTag('Arjan') && !parent.HasTag('q212r_odrin') ) // PRE GC/ALPHA HACK
		{
			parent.TeleportWithRotation( parent.GetWorldPosition(), EulerAngles(0,0,0) );
		}
		isStopping = false;
	}
	
	event OnLeaveState()
	{
		parent.DeactivateAnimatedConstraint( 'shiftWeight' );
		parent.EnablePathEngineAgent( true );
		isStopping = false;
		super.OnLeaveState();
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventName == 'enableMAC' )
		{
			parent.EnablePathEngineAgent( true );
		}
	}
	
	entry function StateInteractionSlaveEnter( inputMaster : EntityHandle, slaveBehaviorName : name, instantStart : bool, initialSpeed : float, goalId : int  )
	{
		SetGoalId( goalId );
		
		isStopping = false;
				
		master = (CActor)EntityHandleGet( inputMaster );
		if ( master )
		{
			PushInteractionBehavior( slaveBehaviorName );
			if( instantStart )
			{
				parent.RaiseForceEvent('InstantStart');
			}
			
			if( ! parent.ActivateDynamicAnimatedConstraint( master, 'shiftWeight', 'shift' ) )
			{
				Log("ActivateDynamicAnimatedConstraint failed");
			}
			if ( ! parent.ActivateDynamicAnimatedConstraint( master, 'shiftWeight', 'shiftRot' ) )
			{
				Log("ActivateDynamicAnimatedConstraint failed");
			}
		}
		else		
		{
			Log("StateInteractionSlaveEnter ERROR - no master!!!");
		}

		parent.SetBehaviorVariable( "masterSpeed", initialSpeed );
		// Do nothing till StateInteractionSlaveFree() is called
	}
		
	event OnStopInteractionState( carryTransitionMode : W2CarryTransitionMode )
	{
		if( !isStopping )
		{
			if( carryTransitionMode == CTM_Instant )
			{
				StateInteractionSlaveStop();
			}
			else
			{
				StateInteractionSlaveStopAnimated( carryTransitionMode );
			}
		}
	}
	
	private entry function StateInteractionSlaveStop()
	{	
		isStopping = true;	
		if ( ! master )
		{
			Log("StateInteractionSlaveFree ERROR - no master!!!");
		}
		master = NULL;
		
		parent.DeactivateAnimatedConstraint( 'shiftWeight' );
		parent.SetBehaviorVectorVariable( "shift", Vector(0,0,0,0) );
		parent.SetBehaviorVectorVariable( "shiftRot", Vector(0,0,0,0) );
		
		MarkGoalFinished();
	}
	
	private entry function StateInteractionSlaveStopAnimated( carryTransitionMode : W2CarryTransitionMode )
	{
		var stopEvent : name;
		isStopping = true;		
		
		if( carryTransitionMode == CTM_Sit || carryTransitionMode == CTM_SitFast )
		{
			parent.GetArbitrator().AddGoalBehavior('arian_sitting');
		}
		else if( carryTransitionMode == CTM_Bats )
		{
			parent.GetArbitrator().AddGoalBehavior('q212r_odrin3');
		}
		
		if( carryTransitionMode == CTM_Sit )
		{			
			stopEvent = 'carryArianStop';		
		}
		else if( carryTransitionMode == CTM_SitFast )
		{
			stopEvent = 'carryArianPutdown';
		}
		else if( carryTransitionMode == CTM_Bats )
		{
			stopEvent = 'odrin_bats';
		}	
		
		parent.DeactivateAnimatedConstraint( 'shiftWeight' );
		parent.SetBehaviorVectorVariable( "shift", Vector(0,0,0,0) );
		parent.SetBehaviorVectorVariable( "shiftRot", Vector(0,0,0,0) );
		
		if( parent.RaiseForceEvent( stopEvent ) )
		{
			parent.WaitForBehaviorNodeDeactivation( 'CarryStopEnd' );
		}
		master = NULL;
		MarkGoalFinished();
	}
};
