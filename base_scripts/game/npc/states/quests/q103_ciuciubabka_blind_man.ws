state CiuciuBabka in CNewNPC extends Base 
{	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
		parent.ActivateBehavior( 'npc_exploration' );
	}
	
	entry function PlayCiuciuBabka( actorTag : name, playRange : float, centerPoint : CNode )
	{
		var actors			: array<CActor>;
		var isReturning		: bool;
		var i : int;
		
		while ( true )
		{
			// Give new orders to blind man
			if ( ! isReturning )
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) > playRange -1.5 )
				{
					parent.ActionMoveToNodeAsync( centerPoint, MT_Walk, 1.f, 1.5 ); 
					isReturning = true;
				}
				else
				// Give new orders to blind man
				if ( !parent.IsCurrentActionInProgress() )
				{
					theGame.GetActorsByTag( actorTag, actors );
					if( actors.Size() > 0 )
					{
						i = Rand( actors.Size() );
						parent.ActionMoveToNodeAsync( actors[i] );
					}
				}
			}
			else
			// Test if blind man has returned to game area
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) < playRange -1.5 )
				{
					isReturning = false;
					parent.ActionCancelAll();
				}
			}
			
			Sleep ( 0.5 );
		}
	}
}