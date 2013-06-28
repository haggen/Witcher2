/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/


/////////////////////////////////////////////
// Movable interaction state
/////////////////////////////////////////////

state MovableInteraction in CPlayer extends Movable
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
		if ( !parent.ActivateBehavior( behName ) )
		{
			Log( "PushInteractionBehavior activation failed" );
		}
	}
	
	// Pop special custom interaction behavior
	final function PopInteractionBehavior()
	{
		//parent.GetRootAnimatedComponent().PopBehaviorGraph( behName );
	}
};
