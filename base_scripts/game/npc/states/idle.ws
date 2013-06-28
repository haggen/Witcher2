/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Idle state
/////////////////////////////////////////////

import state Idle in CNewNPC extends ReactingBase
{
	var pushingSendTime : float;

	event OnEnterState()
	{
		// Block base class (which calls ActionCancelAll)
		//super.OnEnterState();	
		parent.IssueRequiredItems( parent.carryItemLeft, parent.carryItemRight );
	}	
	
	event OnLeaveState()
	{
		Reset();
		parent.SetStartingInActionPoint( false );
		super.OnLeaveState();
	}
	

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Wander around the world
	entry function StateIdle()
	{
		var waitTime 						: float;
		var apID 							: int;
		var category 						: name;
		var apMan 							: CActionPointManager = theGame.GetAPManager();
		var jobTree 						: CJobTree;
		var actionPointFound 				: bool;
		var skipEntryAnimations 			: bool = false;
		var moveType 						: EMoveType;
		var absSpeed 						: float;
		var harpy							: CHarpie;
		
		parent.ChangeNpcExplorationBehavior();
		
		apID = 0;
		// Nicely end any work that is in progress
		parent.ActionExitWork();
		parent.ActionCancelAll();
	
		// Wander endlessly
		while ( true )
		{	
			apID = 0;
			category = 'None';
			actionPointFound = false;
			
			if ( parent.IsActiveIdleEnabled() )			
			{		
				// Try to find a job :)
				if ( parent.IsStartingInActionPoint() )
				{
					apID = parent.GetActiveActionPoint();
					category = parent.GetCurrentActionCategory();
					parent.SetStartingInActionPoint( false );
					skipEntryAnimations = true;
					actionPointFound = ( apID != 0 );
				}
				else
				{
					skipEntryAnimations = false;
					actionPointFound = FindWork( apID, category );
				}
				
				// try reserving the action point the job should be performed in
				if ( actionPointFound && parent.ReserveAP( apID, category ) )
				{
					// we have an action point we can work in
					jobTree = apMan.GetJobTree( apID );
					jobTree.GetMovementSpeed( moveType, absSpeed );
					if ( parent.IsStartingInActionPoint() )
					{
						skipEntryAnimations = true;
					}
					
					parent.MoveToActionPoint( apID, skipEntryAnimations, moveType, absSpeed );
					parent.ActionWorkJobTree( jobTree, category, skipEntryAnimations );
					parent.SetStartingInActionPoint( false );
				}
				else
				{
					// no job to perform ...
					// AREA
					if( parent.GetArea() )
					{
						AreaIdle();
					}
					
					// Wait for a while before retrying
					waitTime = RandRangeF( 0.5f, 1.0f );
					Sleep( waitTime );
				}
				Reset();
			}
			
			Sleep( 0.1 );	
		}
	}
	
	private function Reset()
	{
		var apMan : CActionPointManager = theGame.GetAPManager();
		
		// Free Action Point only if NPC has active set AP
		if ( parent.GetActiveActionPoint() )
		{
			apMan.SetFree( parent.GetName(), parent.GetActiveActionPoint() );
			parent.ClearActiveActionPoint();
			parent.SetCurrentlyWorkingInAP( false );
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Try to start actionpoint work
	private function FindWork( out apID : int, out category : name ) : bool
	{		
		var apMan : CActionPointManager = theGame.GetAPManager();
		var nextPrefApID : int;

		if ( parent.IsUsingLastActionPoint() )
		{
			category = parent.GetCurrentActionCategory();
			apID = parent.GetLastActionPoint();
			if ( apID && !parent.DoesAPMatchCurrentSchedule(apID, category) )
			{
				apID = 0;
			}
			else if ( !apMan.IsFree( apID ) )
			{
				apID = 0;
			}
		}
		if ( !apID || category == 'None' )
		{
			// First try to find a matching action point
			apID = parent.GetLastActionPoint(); // remember last AP, so we will not choose this one again
			category = parent.GetCurrentActionCategory();
			
			if ( apID && apMan.HasPreferredNextAPs( apID ) )
			{
				nextPrefApID = apMan.GetSeqNextActionPoint( apID );
				if ( nextPrefApID )
				{
					apID = nextPrefApID;
				}
				else
				{
					parent.SetErrorState( "Cannot find free next pref AP" );
				}
			}
			else
			{
				parent.FindActionPoint( apID, category );
			}
		}
		if ( apID )
		{	
			return true;
		}
		else
		{
			return false;
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////	

	private function TryDespawn()
	{
		var despawnPoint : Vector;
		
		// If we have a despawn point it means that a layer for our work is not loaded, despawn
		if ( parent.FindDespawnPoint( despawnPoint ) )
		{
			parent.EnterDespawnAtPlace( despawnPoint, false );
		}
	}
	
	private latent function AreaIdle()
	{
		var target 				: Vector;
		var guardArea 			: CGuardArea;		
		var npcPos 				: Vector = parent.GetWorldPosition();
		var distToFleePoint 	: float;
		var harpy				: CHarpie;
		harpy = (CHarpie)parent;
		if(harpy)
		{
			if(!harpy.IsGrounded())
			{
				harpy.SetGrounded(true);
				harpy.RaiseForceEvent('ToLand');
				Sleep(0.1);
				
				harpy.WaitForBehaviorNodeDeactivation('ToLand', 5.0);
				//harpy.SetSpawnAnim(SA_Idle);
				harpy.ActivateBehavior( 'grounded_harpie' );
				harpy.SetSpawnAnim(SA_Idle);
			}
		}
		while( true )
		{
			if ( parent.ShouldFlee() )
			{
				// Go back to area if needed
				target = parent.FindRandomPosition();
				distToFleePoint = VecLength( npcPos - target );
				if ( distToFleePoint > 0.1 )
				{
					parent.ActionMoveToAsync( target, MT_Run, 1.0, 2.0 );
					while( parent.IsMoving() )
					{
						Sleep( 1.0f );
					}
					Sleep( 2.0f );
				}		
			}
			else
			{
				guardArea = parent.GetGuardArea();
				
				// Wander inside area
				if( !guardArea || ( guardArea && guardArea.MayWander() ) )
				{
					if(virtual_parent.CanAct())
					{
						if(parent.PerformActingAction())
						{
							parent.WaitForBehaviorNodeDeactivation('ActingEnd', 5.0);
						}
					}
					parent.GetMovingAgentComponent().SetMoveType( MT_Walk );
					parent.ActionMoveCustomAsync( new CMoveTRGWander in parent );
					Sleep(2.0);
				}
				else
				{
					break;
				}
			}
			
			// give it some time to execute and replan
			Sleep( 2.0f );
		}
	}
	

	
	entry function StateIdleFreeze()
	{
		parent.ChangeNpcExplorationBehavior();
		parent.ActionCancelAll();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
		
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can always slide along
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		var apMan : CActionPointManager = theGame.GetAPManager();
		var caBePushed : bool = true;
		
		if ( parent.GetActiveActionPoint() != 0 && parent.GetCurrentActionType() == ActorAction_Working )
		{
			// verify with the active action point if we can get pushed away
			caBePushed = apMan.IsBreakable( parent.GetActiveActionPoint() ); 
		}
		
		if ( caBePushed )
		{
			parent.PushAway( pusher );
		
			if ( pusher.GetEntity() == thePlayer )
			{	
				if( theGame.GetEngineTime() > pushingSendTime )
				{
					theGame.GetReactionsMgr().SendDynamicInterestPoint( parent, thePlayer.pushingInterestPoint, thePlayer, 3.0f );
					pushingSendTime = EngineTimeToFloat( theGame.GetEngineTime() + 2.0 );
				}
			}
		}
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
}
