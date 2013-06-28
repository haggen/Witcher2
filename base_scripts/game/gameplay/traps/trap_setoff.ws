/*function CanILayDownTrap() : bool
{
	var TrapPosition : Vector;
	var PlayerPosition : Vector; 
	var nodes : array< CNode >;
	var i : int;
	var count : int;
	var range : float;
	var trap : CWitcherTrap;
	var near : int;
	var tm : EngineTime;
	var nodeAppearance : name; 
		
	// safeguard for multiple triggered trap laying animation
	
	theGame.GetBlackboard().GetEntryTime( 'witcherDeployTrap', tm );
	if( theGame.GetEngineTime() - tm < 2.0 ) return;
	theGame.GetBlackboard().AddEntryTime( 'witcherDeployTrap', theGame.GetEngineTime() );
	
	//check for traps in range
	
	theGame.GetNodesByTag( 'witcher_trap', nodes );
	count = nodes.Size();
	PlayerPosition = thePlayer.GetWorldPosition();
	//Log ( "Pulapek w okolicy = " +count );
	
	if (count == 0)
	{
		Log ("Nic innego nie le¿y");
		return true;
	}
	else if ( count > 0 )
	{
		near = 0;
		for ( i = 0; i < count; i += 1 )		
		{
			TrapPosition = nodes[i].GetWorldPosition();
			trap = (CWitcherTrap)nodes[i];
			range = VecDistanceSquared( PlayerPosition, TrapPosition );
			nodeAppearance = ((CEntity)nodes[i]).GetAppearance(); 
			Log( "range = " + range );
			
			if( trap.TrapName != T_TrapLinker )
			{
				if ( range < 8.0f )
				{
					Log ("Pulapka jest za blisko");
					if ( nodeAppearance != '3_trap_explode' ) 
					{	
						Log ("I pulapka nie jest wysadzona");
						near += 1;
					}
				}
			}	
			else
			{
				Log( "Pu³apki s¹ dostatecznie daleko" );
			}
		}
		//Log( "Near = " +near);
		if (near == 0 )
		{
			return true;
		}
		else if ( near > 0 )
		{
			return false;
		}
	}
}
*/