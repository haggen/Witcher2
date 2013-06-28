
state Idle in W2Monster
{
	event OnMovementCollision( pusher : CMovingAgentComponent ) 
	{
		return ( pusher.GetEntity() != thePlayer );
	}
	
	entry function StateIdle()
	{
		var target   			: Vector;
		var waitTime 			: float;
		var apID     			: int  = 0;
		var category 			: name = 'None';
		var apMan 				: CActionPointManager = theGame.GetAPManager();
		var jobTree 			: CJobTree;
		var actionPointFound 	: bool;
		var wanderTrg 			: CMoveTRGWander;
		
		parent.ChangeNpcExplorationBehavior();
		
		while( 1 )
		{	
			if ( parent.IsActiveIdleEnabled() )			
			{
				actionPointFound = FindWork( apID, category );
				
				if( actionPointFound && parent.ReserveAP( apID, category ) )
				{					
					// try to start the job you found
					jobTree = apMan.GetJobTree( apID );
					
					parent.MoveToActionPoint( apID, false );				
					parent.ActionWorkJobTree( jobTree, category, false );												
				}
				else
				{
					if( parent.GetArea() )
					{
						AreaIdle();
					}
					else if( parent.mayWander )
					{					
						parent.GetMovingAgentComponent().SetMoveType( MT_Walk );
						parent.ActionMoveCustomAsync( new CMoveTRGWander in parent );
						Sleep( 2.0f );
					}
					
					waitTime = RandRangeF( 0.5f, 1.0f );
					Sleep( waitTime );
				}
			}
			
			Sleep(0.1);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Try to start actionpoint work
	private function FindWork( out apID : int, out category : name ) : bool
	{		
		var apMan : CActionPointManager = theGame.GetAPManager();
		var nextPrefApID : int;

		if ( apMan.HasPreferredNextAPs( apID ) )
		{
			nextPrefApID = apMan.GetSeqNextActionPoint( apID );
			if ( nextPrefApID )
			{
				apID = nextPrefApID;
			}
		}
		else
		{
			parent.FindActionPoint( apID, category );
		}

		if ( apID )
		{	
			// Try to reserve action point
			if ( apMan.IsFree( apID ) )
			{
				return true;
			}
		}

		return false;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	

}