/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions - walk with actor action
/** Copyright © 2009
/***********************************************************************/

class CActorLatentActionWalkWithActor extends IActorLatentAction
{
	editable saved var minDistance	: float;
	editable saved var maxDistance	: float;
	editable saved var timeout		: float;
	editable saved var observeTargetTag	: name;
	editable saved var observeDelay	: float; // delay till starting target observation
	editable saved var defaultSpeed	: EMoveType;
	editable saved var walkBehind		: bool;
	
	default minDistance		= 1.5f;
	default maxDistance		= 3.0f;
	default timeout			= 0.0f;
	default defaultSpeed	= MT_Walk;
	default walkBehind		= false;
	
	latent public function Perform( actor : CActor )
	{
		var dotFrontTarget	: float;
		var dotSideTarget	: float;
		var distanceDelta	: float;
		var pntTarget		: Vector;
		var position		: Vector;
		var vecToTarget		: Vector;
		var frontTarget		: Vector;
		var sideTarget		: Vector;
		var timeTillEnd		: float;
		var medDistance     : float;
		var targetMAC		: CMovingAgentComponent;
		var curTarget		: Vector;
		var leaderSpeed		: float;
		var leaderIsAPlayer : bool;
		var observeTimeout	: float;
		var sleepTime		: float;
		var weHaveMoved   	: bool;
		var firstOrder		: bool;
		var subject			: CNode;
		var observeTarget	: CNode;
		
		if( IsNameValid( observeTargetTag ) )
		{
			observeTarget = theGame.GetNodeByTag( observeTargetTag );
		}
		
		// Random sleep to scatter move calls when multiple actors act at the same time
		sleepTime = RandRangeF( 0.0f, 0.2f );
		Sleep( sleepTime );
		
		subject = actor.GetFocusedNode();
		if ( ! subject )
			return;
		
		observeTimeout	= observeDelay;
		timeTillEnd		= timeout;
		targetMAC		= ((CActor) subject).GetMovingAgentComponent();
		medDistance		= ( minDistance + maxDistance ) * 0.5f;
		leaderIsAPlayer	= subject == thePlayer;
		
		firstOrder = true;
		
		while ( timeout <= 0.f || timeTillEnd > 0.f )
		{
			leaderSpeed = targetMAC.GetCurrentMoveSpeedAbs();
		
			pntTarget   = subject.GetWorldPosition();
			frontTarget = RotForward( subject.GetWorldRotation() );
			if ( walkBehind )
			{
				frontTarget = - frontTarget;
			}
			
			position       = actor.GetWorldPosition();
			vecToTarget    = pntTarget - position;
			dotFrontTarget = VecDot2D( vecToTarget, frontTarget );
			distanceDelta  = VecLength2D( vecToTarget );
			
			if ( leaderIsAPlayer && distanceDelta > 25.f )
			{
				actor.GetMovingAgentComponent().TeleportBehindCamera( true );
			}
			else
			{
				if ( leaderSpeed > 0.2f || AbsF( vecToTarget.Z ) > 2.f || dotFrontTarget > 0.f || distanceDelta < minDistance || distanceDelta > maxDistance + 0.5f )
				{
					sideTarget = Vector( - frontTarget.Y, frontTarget.X, 0.f );
					
					dotSideTarget = VecDot2D( vecToTarget, sideTarget );
					if ( dotSideTarget > 0.f )
						sideTarget = - sideTarget;
						
					vecToTarget = VecNormalize( sideTarget * 1.5f + frontTarget ) * medDistance;
					if ( leaderSpeed > 1.f )
					{
						if ( walkBehind )
							vecToTarget = vecToTarget - frontTarget * 0.8f;
						else
							vecToTarget = vecToTarget + frontTarget;
					}
					
					if ( firstOrder || VecDistance2D( pntTarget + vecToTarget, curTarget ) > 0.25f )
					{
						firstOrder     = false;
						observeTimeout = observeDelay;
						
						// If follower is far away, just move to leader
						if ( distanceDelta > 4.f * maxDistance )
						{
							curTarget = pntTarget;
							actor.ActionMoveToNodeAsync( subject, MT_Run, 0.f, 1.f );
						}
						
						// If we may find proper position, walk to it
						else if ( targetMAC.GetEndOfLineNavMeshPosition( pntTarget + vecToTarget, curTarget ) )
						{
							if ( leaderSpeed > 1.f )
							{
								distanceDelta = VecDistance2D( curTarget, position );
								leaderSpeed = leaderSpeed * MinF( 1.5f, 0.7f + distanceDelta * 0.18f );

								actor.ActionMoveToAsync( curTarget, MT_AbsSpeed, MaxF(leaderSpeed, 1.f), 1.f );
							}
							else
								actor.ActionMoveToAsync( curTarget, defaultSpeed, 0.f, 1.f );
						}
						
						// Fallback - move directly to leader
						else
						{
							curTarget = pntTarget + vecToTarget;
							
							if ( leaderSpeed > 1.f )
							{
								if ( distanceDelta < minDistance )
									actor.ActionMoveAwayFromNodeAsync( subject, medDistance, MT_AbsSpeed, leaderSpeed, 2.f );
								else
									actor.ActionMoveToNodeAsync( subject, MT_AbsSpeed, leaderSpeed * 1.3f, 1.f );
							}
							else
							{
								if ( distanceDelta < minDistance )
									actor.ActionMoveAwayFromNodeAsync( subject, medDistance, defaultSpeed, 0.f, 2.f );
								else
									actor.ActionMoveToNodeAsync( subject, defaultSpeed, 0.f, 1.f );
							}
						}
					}
				}
				else
				if ( observeTarget )
				{
					if ( observeTimeout > 0.2f )
						observeTimeout -= 0.2f;
					else
					{
						if ( observeTarget == subject )
							actor.ActionRotateToAsync( pntTarget );
						else
							actor.ActionRotateToAsync( observeTarget.GetWorldPosition() );
					}
				}
			}
		
			Sleep( 0.2f );
			
			if ( ! subject )
				break;
			
			timeTillEnd -= 0.2f;
		}
		
		Cancel( actor );
	}
}
