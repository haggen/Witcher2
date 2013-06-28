/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions - CActorLatentActionWalkToTargetWaitForPlayer
/** Copyright © 2010
/***********************************************************************/

class CActorLatentActionWalkToTargetWaitForPlayer extends IActorLatentAction
{
	editable saved var distanceToStop : float;
	editable saved var distanceToGo : float;
	editable saved var moveType : EMoveType;
	editable saved var absSpeed : float;
	editable saved var stopOnCombat : bool;
	
	default distanceToStop = 6.0;
	default distanceToGo = 3.0;
	default moveType = MT_Walk;
	default absSpeed = 1.0;
	
	latent public function Perform( actor : CActor )
	{
		var hasReachedDestination : bool;
		var isMoving     : bool;
		var distToPlayer : float;
		var distToTarget : float;
		var target : CNode;		
		
		target = actor.GetFocusedNode();
		
		while ( true )
		{
			distToPlayer          = VecDistance( thePlayer.GetWorldPosition(), actor.GetWorldPosition() );
			distToTarget          = VecDistance( target.GetWorldPosition(), actor.GetWorldPosition() );
			hasReachedDestination = distToTarget < 1.5f;
				
			if ( hasReachedDestination )
				break;
			
			if( stopOnCombat && thePlayer.IsInCombat() )
			{
				if( actor.IsMoving() )
				{
					actor.ActionCancelAll();
					isMoving = false;
				}
			}
			else
			{
				// Wait for player			
				if ( distToPlayer > distanceToStop )
				{
					actor.ActionRotateToAsync( thePlayer.GetWorldPosition() );
					isMoving = false;
				}
				else
				// Move to destination
				if ( ! isMoving && distToPlayer <= distanceToGo )
				{
					isMoving = actor.ActionMoveToNodeAsync( target, moveType, absSpeed );
				}			
			}
			
			Sleep( 1.f );
		}	
	}
}