state GeraltCiuciubabka in CPlayer extends Exploration
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetWalkMode(true);
	}
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.SetWalkMode(false);
	}

	entry function GeraltPlayCiuciuBabka(playRange : float, centerPoint : CNode )
	{
		var i : int;
		var isReturning: bool;
		
		
	
		while ( true )
		{
			// Give new orders to blind man
			if ( ! isReturning )
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) > playRange -1 )
				{
					theCamera.LookAt( centerPoint );
					//parent.ActionRotateTo(centerPoint.GetWorldPosition());
					isReturning = true;
				}
				
			}
			else
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) < playRange -1 )
				{
					isReturning = false;
					theCamera.LookAtDeactivation();
					parent.ActionCancelAll();
				}
			}
			
			
			Sleep ( 0.5 );
		}
	}
}