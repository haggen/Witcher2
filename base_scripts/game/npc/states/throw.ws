/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Idle state
/////////////////////////////////////////////

/*state Throw in CNewNPC extends Base
{	
	private var pushDone : bool;
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}
	
	entry function EnterThrow()
	{	
		var i : int;
		
		 parent.GetBehTreeMachine().Stop();
		parent.GetArbitrator().ClearAllGoals();
		
		
		pushDone = false;
		i = 2;
		parent.SetRagdoll( true );
		parent.Kill( true );
		parent.SetAlive( false );
		while( (i > 0) && (pushDone == false) )
		{
			Sleep(2.00);
			i-=1;
		}
		
		parent.SetAlive( true );
						
		parent.Kill( false );
		parent.SetAlive( true );
		parent.SetRagdoll( false );
		parent.GetBehTreeMachine().Restart(); 
		
	}
	
	event OnRagdollStateChanged( newState : ERagdollState )
	{
		if ( newState != RS_KeyFramed )
		{		
			pushDone = true;
		}
	}
	
}*/
