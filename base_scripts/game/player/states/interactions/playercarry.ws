/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

enum W2CarryTransitionMode
{
	CTM_Sit,
	CTM_SitFast,
	CTM_Bats,
	CTM_Instant
};

class W2PlayerInteractionData extends CObject
{
	saved var slaves : array< EntityHandle >;
	saved var masterBehaviorName : name;
	saved var slaveBehaviorName : name;
	saved var drawWeapon : bool;
};

/////////////////////////////////////////////
// Player master interaction
/////////////////////////////////////////////
state MasterInteraction in CPlayer extends MovableInteraction
{
	var isStopping 						: bool;	
	var ready 							: bool;
	private var noSaveLock 				: int;
	private var traversingExploration	: bool;
	default		traversingExploration	= false;

	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetManualControl( true, true );
		isStopping = false;
		ready = false;
		noSaveLock = -1;
		FactsAdd( "PlayerCarry", 1 );

		traversingExploration = false;
		ProcessMovement( 0.0 );
	}
	
	event OnGameInputEvent( key : name, value : float )
	{		
		if ( theGame.IsBlackscreen() )
		{
			return true;
		}
		if ( key == 'GI_Journal' )
		{
			if( !thePlayer.AreHotKeysBlocked() && value > 0.5f )
			{
				theHud.ShowJournal();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Nav' )
		{
			if( !thePlayer.AreHotKeysBlocked() && value > 0.5f )
			{
				theHud.ShowNav();
				return true;
			}
			return false;
		}
		return super.OnGameInputEvent( key, value );
	}
	
	event OnLeaveState()
	{
		var i : int;
		var slavesNum : int = GetSlaveCount();		
		
		parent.RemoveTimer( 'CarryingTimer' );
		
		// Set slaves free
		for ( i=0; i<slavesNum; i+=1 )
		{			
			GetSlave(i).OnStopInteractionState( CTM_Instant );
		}		
		
		ClearInteractionData();
		
		FactsRemove( "PlayerCarry" );
		
		// release a possible save lock that was created when the player was in this state
		if ( noSaveLock >= 0 )
		{
			theGame.ReleaseNoSaveLock( noSaveLock );
			noSaveLock = -1;
		}
		
		// agent may have been traversing an exploration - clean up just in case
		if ( traversingExploration )
		{
			CleanupAfterExplorationTraversal();
		}
		
		if( parent.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponInstant( parent.GetCurrentWeapon() );
		}
		
		super.OnLeaveState();
	}
	
	event OnUseExploration( explorationArea : CActionAreaComponent )
	{
		parent.ActionSlideThroughAsync( explorationArea );
		return true;
	}

	event OnStartTraversingExploration() 
	{
		traversingExploration = true;
		theGame.CreateNoSaveLock( "TraversingExplorationWhenCarrying", noSaveLock );
		parent.SetManualControl( false, true );
		theGame.EnableButtonInteractions( false );
		return true;
	}
	
	event OnFinishTraversingExploration()
	{
		CleanupAfterExplorationTraversal();
	}
	
	private function CleanupAfterExplorationTraversal()
	{
		parent.SetManualControl( true, true );
		theGame.EnableButtonInteractions( true );
		if ( noSaveLock >= 0 )
		{
			theGame.ReleaseNoSaveLock( noSaveLock );
			noSaveLock = -1;
		}
		traversingExploration = false;
	}
	
	event OnCheckPlayerCarryJoined()
	{
		return ready;
	}
	
	event OnSpeedChanged( component : CAnimatedComponent, newSpeed : float )
	{
		var i : int;
		var slavesNum : int = GetSlaveCount();
		
		if ( component == parent.GetRootAnimatedComponent() )
		{
			// Propagate speed to all slaves
			for ( i=0; i<slavesNum; i+=1 )
			{
				GetSlave(i).SetBehaviorVariable( "masterSpeed", newSpeed );
			}
			
			LogChannel('speed', newSpeed );
		}
	}
	
	function ClearInteractionData()
	{
		parent.interactionData = NULL;
	}
	
	function GetSlaveCount() : int
	{
		return parent.interactionData.slaves.Size();
	}
	
	function GetSlave( i : int ) : CActor
	{
		return (CActor)EntityHandleGet( parent.interactionData.slaves[i] );	
	}
	
	function SetInteractionData( inputSlaves : array<CActor>, masterBehaviorName : name, slaveBehaviorName : name, drawWeapon : bool )
	{
		var i : int;
		var slavesNum : int = inputSlaves.Size();
		
		parent.interactionData = new W2PlayerInteractionData in parent;
		parent.interactionData.masterBehaviorName = masterBehaviorName;
		parent.interactionData.slaveBehaviorName = slaveBehaviorName;
		parent.interactionData.drawWeapon = drawWeapon;
		parent.interactionData.slaves.Grow(slavesNum);
		
		for ( i=0; i<slavesNum; i+=1 )
		{
			EntityHandleSet( parent.interactionData.slaves[i], inputSlaves[i] );
		}
		
	}
	
	function DrawSteelSword()
	{
		var weaponUid : SItemUniqueId;
		weaponUid = parent.GetInventory().GetItemByCategory('steelsword', true);
		
		if ( weaponUid != GetInvalidUniqueId() )
		{
			//parent.HolsterWeaponInstant( GetInvalidUniqueId() );
			//parent.DrawWeaponInstant( weaponUid );	
			parent.GetInventory().MountItem( weaponUid, true );
		}
	}
	
	latent function WaitForSlaves() : bool
	{
		var i : int;
		var slavesNum : int = GetSlaveCount();
		
		for ( i=0; i<slavesNum; i+=1 )
		{
			EntityHandleWaitGet( parent.interactionData.slaves[i] );
		}			
	}
	
	entry function StateInteractionMasterInternal()
	{
		var i : int;
		var slavesNum : int = GetSlaveCount();
		var initialSpeed : float;
		isStopping = false;
		
		// Push custom behavior
		PushInteractionBehavior( parent.interactionData.masterBehaviorName );
		
		// Wait for slaves to spawn
		WaitForSlaves();
		
		((CNewNPC)GetSlave(0)).EnableCarryStopInteraction( true );
		
		// Set initial speed
		if( parent.GetRawMoveSpeed() > 0.1f )
		{
			initialSpeed = 1.0;			
		}
		
		// Prepare slaves
		for ( i=0; i<slavesNum; i+=1 )
		{
			GetSlave(i).EnterSlaveState( parent, parent.interactionData.slaveBehaviorName, false, initialSpeed );
		}
		
		// Slaves will be released in OnLeaveState
		
		if( parent.interactionData.drawWeapon )
		{
			//parent.SetRequiredItems( 'Any', 'steelsword' );
			parent.ProcessRequiredItems();
			parent.IssueRequiredItems( 'Any', 'steelsword');
			//DrawSteelSword();
		}
		
		// add a hostiles watchdog timer
		parent.AddTimer( 'CarryingTimer', 0.5, true );
		
		ready = true;		
	}
		
	entry function StateInteractionMaster( inputSlaves : array<CActor>, masterBehaviorName : name, slaveBehaviorName : name, drawWeapon : bool )
	{		
		SetInteractionData( inputSlaves, masterBehaviorName, slaveBehaviorName, drawWeapon );
		StateInteractionMasterInternal();

	}
	
	entry function StateInteractionMasterAnimated( inputSlaves : array<CActor>, carryTransitionMode : W2CarryTransitionMode )
	{	
		var i : int;
		var slots : array< Matrix >;
		var posPlayer, posNpc : Vector;
		var rotPlayer, rotNpc : EulerAngles;
		var startEvent, startAnim : name;
		var masterBehaviorName, slaveBehaviorName : name;
		
		isStopping = false;
		
		((CNewNPC)inputSlaves[0]).EnableCarryStartInteraction( false );
		
		if( carryTransitionMode == CTM_Sit )
		{
			startEvent = 'carryArianStart';
			startAnim = 'carry_arian_start';
			masterBehaviorName = 'carry_arian_master';
			slaveBehaviorName = 'carry_arian';
		}
		
		SetInteractionData( inputSlaves, masterBehaviorName, slaveBehaviorName, false );
		
		parent.SetManualControl( false, true );
		parent.ResetMovment();
		
		if( parent.GetAnimCombatSlots( startAnim, slots, 3, 1, parent.GetLocalToWorld(), 2, inputSlaves[0].GetLocalToWorld(), false ) )
		{
			posPlayer = MatrixGetTranslation( slots[1] );
			posNpc = MatrixGetTranslation( slots[2] );
			
			rotPlayer = MatrixGetRotation( slots[1] );
			rotNpc = MatrixGetRotation( slots[2] );
					
			inputSlaves[0].ActionSlideToWithHeadingAsync( posNpc, rotNpc.Yaw, 0.2 );			
			parent.ActionMoveToWithHeading(posPlayer, rotPlayer.Yaw, MT_Walk, 1.0, 0.0);
			parent.ActionSlideToWithHeading( posPlayer, rotPlayer.Yaw, 0.2 );			
		}
		
		if( parent.RaiseForceEvent(startEvent) )
		{
			for ( i=0; i<inputSlaves.Size(); i+=1 )
			{	
				inputSlaves[i].EnablePathEngineAgent( false );
				inputSlaves[i].RaiseEvent( startEvent );
			}
			
			parent.WaitForBehaviorNodeDeactivation('CarryStartEnd');
		}
						
		parent.SetManualControl( true, true );		
		StateInteractionMasterInternal();
	}

	event OnExitPlayerState( newState : EPlayerState )
	{
		if( parent.IsAnExplorationState( newState ) || newState == PS_Scene || newState == PS_Cutscene )
		{
			parent.PlayerStateCallEntryFunction( newState, "" );
		}
	}
	
	event OnStopInteractionState( carryTransitionMode : W2CarryTransitionMode )
	{
		var i : int;		
		if( !isStopping && ready )
		{
			isStopping = true;
			if( carryTransitionMode == CTM_Instant )
			{
				parent.ChangePlayerState( PS_Exploration );
			}
			else
			{
				StateInteractionMasterStop( carryTransitionMode );			
			}
		}
	}
		
	private entry function StateInteractionMasterStop( carryTransitionMode : W2CarryTransitionMode )
	{
		var stopEvent : name;
		var enemies : array< CActor >;
		var i : int;
		var slaveNum : int = GetSlaveCount();
		
		// this function can't be interrupted
		parent.LockEntryFunction( true );
		
		// disconnect from the slave
		((CNewNPC)GetSlave(0)).EnableCarryStopInteraction( false );

		if( carryTransitionMode == CTM_Sit )
		{			
			if( parent.IsInSneakMode() )
			{
				stopEvent = 'carryArianStop';		
			}
			else
			{
				stopEvent = 'carryArianStop_to_ex';
			}
		}
		else if( carryTransitionMode == CTM_SitFast )
		{
			if( parent.IsInSneakMode() )
			{
				stopEvent = 'carryArianPutdown';
			}
			else
			{
				stopEvent = 'carryArianStop_to_ex';
			}
		}
		else if( carryTransitionMode == CTM_Bats )
		{
			stopEvent = 'odrin_bats';
		}		
				
		for( i=0; i<slaveNum; i+=1 )
		{
			GetSlave(i).OnStopInteractionState( carryTransitionMode );
		}
		
		parent.SetManualControl( false, true );
		parent.ResetMovment();
			
		if( parent.RaiseForceEvent( stopEvent ) )
		{
			parent.WaitForBehaviorNodeDeactivation('CarryStopEnd');
		}
		
		parent.SetManualControl( true, true );
		
		((CNewNPC)GetSlave(0)).EnableCarryStartInteraction( true );	
		
		// reallow entry functions to be interrupted
		parent.LockEntryFunction( false );
		
		// change player's state
		isStopping = false;
		parent.ChangePlayerState(PS_Exploration);		
	}
	
	event OnManualCarryStopRequest()
	{
		if( !isStopping && ready )
		{		
			TryManualCarryStop();
		}
	}
	
	private entry function TryManualCarryStop()
	{
		var res : bool;
		var slaveNPC : CNewNPC;
		res = CarryStopPositionTest();
		if( res )
		{
			slaveNPC = (CNewNPC)GetSlave(0);
			slaveNPC.EnableCarryStartInteraction( true );
			slaveNPC.EnableCarryStopInteraction( false );
		
			if( parent.HostilesAround() )
			{
				OnStopInteractionState(CTM_SitFast);
			}
			else
			{
				OnStopInteractionState(CTM_Sit);			
			}			
		}
		else
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "InteractionCannotPlaceActor" ) );
		}
	}
	
	latent function CarryStopPositionTest() : bool
	{
		var mac : CMovingAgentComponent = thePlayer.GetMovingAgentComponent();	
		var params : SPathEngineEmptySpaceQuery;	
		var pos : Vector;
		var yaw, res : float;
		
		params.width = 1.5f;
		params.height = 2.5f;		
		params.yaw = -1.0;
		params.searchRadius = 2.0f;
		params.localSearchRadius = 1.0f;		
		params.maxPathLen = 2.0f;
		params.maxCenterLevelDifference = 1.0f;
		params.maxAreaLevelDifference = 0.5f;
		params.numTests = 0;
		params.checkObstaclesLevel = PEESC_PlayerObstaclesNonActors;
		params.debug = true;
		
		res = mac.FindEmptySpace( params, pos, yaw );
		return res > params.width * 0.9;
	}
	
	timer function CarryingTimer( timeDelta : float )
	{
		if ( parent.HostilesAround() )
		{
			OnManualCarryStopRequest();
		}
	}
};

/////////////////////////////////////////////
// Player slave interaction
/////////////////////////////////////////////
state SlaveInteraction in CPlayer extends MovableInteraction
{
	var master : CActor;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnablePathEngineAgent( false );
		parent.SetManualControl( false, true );
	}
	
	event OnLeaveState()
	{
		parent.DeactivateAnimatedConstraint( 'shiftWeight' );
		parent.EnablePathEngineAgent( true );
		
		theCamera.Follow( parent );
			
		super.OnLeaveState();
	}
	
	entry function StateInteractionSlave( inputMaster : CActor, slaveBehaviorName : name )
	{
		master = inputMaster;
		
		// Push custom behavior
		PushInteractionBehavior( slaveBehaviorName );
		
		// Prepare
		parent.ActivateDynamicAnimatedConstraint( master, 'shiftWeight', 'shift' );
		parent.ActivateDynamicAnimatedConstraint( master, 'shiftWeight', 'shiftRot' );
		
		theCamera.Follow( master );
	}
	
	private function ProcessCamera( timeDelta : float )
	{
		if ( theCamera )
		{
			theHud.m_hud.SendNavigationDataToGUI( master );
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if ( key == 'GI_AttackStrong' )
		{
			if( value > 0.5 )
			{
				// Go to idle state
				master.ActionCancelAll();
				return true;
			}
			return false;
		}
		
		// Pass to base class
		return super.OnGameInputEvent( key, value );
	}
};