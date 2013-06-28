/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exports
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Point of interest state
/////////////////////////////////////////////

enum EPointOfInterestType
{
	POIT_Chase,
	POIT_Follow,
	POIT_Waver,
	POIT_Retreat,
	POIT_MoveAside,
	POIT_LookAt
};

import state PointOfInterest in CNewNPC extends Base
{
	var poiAction : CActorLatentActionPointOfInterest;
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();		
	}
	
	event OnLeaveState()
	{
		if ( poiAction )
		{
			poiAction.Cancel( parent );
			poiAction = NULL;
		}
	}

	// Set point of interest action, give timeout <= 0.f for infinite timeout
	entry function StatePointOfInterest(mode : EPointOfInterestType, referencePoint : PersistentRef, desiredDistance : float, timeout : float, observePOI : bool, goalId : int )
	{
		var entity : CEntity;
		var pos : Vector;
	
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		entity = PersistentRefGetEntity( referencePoint );		
		if( entity )
		{
			parent.SetFocusedNode( entity );
		}
		else
		{
			pos = PersistentRefGetWorldPosition( referencePoint );
			parent.SetFocusedPostion( pos );
		}
		
		poiAction = new CActorLatentActionPointOfInterest in this;
		poiAction.mode = mode;
		poiAction.desiredDistance	= desiredDistance;
		poiAction.timeout			= timeout;
		poiAction.observePOI		= observePOI;
		
		poiAction.Perform( parent );
		
		// Go back to wandering around
		MarkGoalFinished();		
	}
}