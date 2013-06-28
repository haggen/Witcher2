/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions - point of interest
/** Copyright © 2009
/***********************************************************************/

/*
enum EPointOfInterestType
{
	POIT_Chase,
	POIT_Follow,
	POIT_Waver,
	POIT_Retreat,
	POIT_MoveAside,
	POIT_LookAt
};
*/

class CActorLatentActionPointOfInterest extends IActorLatentAction
{
	editable saved var mode				: EPointOfInterestType;
	editable saved var desiredDistance	: float;
	editable saved var timeout			: float;
	editable saved var observePOI			: bool;
	editable saved var stopWhenReached	: bool;
	
	default mode			= POIT_Follow;
	default desiredDistance	= 3;
	default timeout			= 20;
	default observePOI		= true;
	default stopWhenReached	= false;
	
	public function Cancel( actor : CActor )
	{
		if ( mode == POIT_LookAt )
		{
			actor.DisableLookAt();
		}
		if ( mode == POIT_Waver )
		{
			actor.RaiseForceEvent( 'Idle' );
		}
	}
	
	latent public function Perform( actor : CActor )
	{
		var sleepTime     : float;
		var speed         : EMoveType;
		var move          : bool;
		
		var pntTargetPrev : Vector;
		var pntTarget     : Vector;
		var vecToTarget   : Vector;
		var pntCasted     : Vector;
		var vecPOIFront   : Vector;
		var vecCross      : Vector;
		var distanceDelta : float;
		var rotation      : EulerAngles;
		var timeTillEnd   : float;
		var careAboutZ    : bool;
		var properDistance : float; // clamped distance
		var targetMoved   : bool;
		var weHaveMoved   : bool;
		var subject       : CNode;
		
		sleepTime = RandRangeF( 0.1, 1.0 );
		Sleep( sleepTime );
		
		subject = actor.GetFocusedNode();
		if ( ! subject )
			return;
		
		careAboutZ = mode == POIT_Chase || mode == POIT_Follow;
		
		if ( mode == POIT_Chase || mode == POIT_Retreat )
			speed = MT_Run;
		else
			speed = MT_Walk;
			
		if ( mode == POIT_Waver )
		{
			actor.RaiseForceEvent( 'waver' );
		}
		
		if ( mode == POIT_Waver || mode == POIT_Retreat )
			properDistance = MinF( desiredDistance, 30 );
		else
			properDistance = desiredDistance;
		
		if ( mode == POIT_LookAt && subject.IsA( 'CActor' ) )
			actor.EnableDynamicLookAt( (CActor)subject, 10.f );
		
		sleepTime     = 1.f;
		timeTillEnd   = timeout;
		pntTarget     = subject.GetWorldPosition();
		pntTargetPrev = pntTarget;
		targetMoved   = true;
		weHaveMoved   = true;
		
		while ( timeout <= 0.f || timeTillEnd > 0.f )
		{
			if ( mode == POIT_LookAt )
			{
				timeTillEnd -= sleepTime;
			}
			else
			{
				vecToTarget = pntTarget - actor.GetWorldPosition();

				distanceDelta = properDistance - VecLength2D( vecToTarget );
				// Timeout is decreased only if we are outside the properDistance (both for following and retreating)
				if ( distanceDelta < 0.f )
				{
					timeTillEnd -= sleepTime;
				}
				// If chasing or following, move towards the target
				if ( mode == POIT_Chase || mode == POIT_Follow )
				{
					distanceDelta = - distanceDelta;
				}
				if ( mode == POIT_MoveAside )
				{
					rotation    = subject.GetWorldRotation();
					vecPOIFront = VecFromHeading( rotation.Yaw );
					
					if ( VecDot2D( vecToTarget, vecPOIFront ) < 0.f ) // don't care if we are behind the POI
					{
						vecCross = VecCross( vecPOIFront, vecToTarget );
						pntCasted = pntTarget - vecPOIFront * VecDot2D( vecPOIFront, vecToTarget );
						distanceDelta = properDistance - VecDistance2D( pntCasted, actor.GetWorldPosition() );
					}
				}
			}

			if ( targetMoved || weHaveMoved )
			{
				// We move till the destination is reached
				weHaveMoved = mode != POIT_LookAt && ( ( careAboutZ && AbsF( vecToTarget.Z ) > 2.f ) || distanceDelta > properDistance * 0.1f );
				if ( weHaveMoved )
				{
					// Update target only if POI subject has moved
					if ( targetMoved )
					{
						if ( mode == POIT_MoveAside )
							actor.ActionMoveAwayFromLineAsync( pntTarget, pntTarget + vecPOIFront * 10.f, properDistance * 1.1f , true, speed, 0.f, 1.f );
						else
						if ( mode == POIT_Retreat || mode == POIT_Waver )
							actor.ActionMoveAwayFromNodeAsync( subject, properDistance * 1.1f, speed, 0.f, 1.f );
						else
							actor.ActionMoveToNodeAsync( subject, speed, 0.f, properDistance * 1.1f );
						pntTargetPrev = pntTarget;
					}
				}
				else if ( observePOI && ! actor.IsRotatedTowardsPoint( pntTarget, 5.f ) )
				{
					actor.ActionRotateToAsync( pntTarget );
					weHaveMoved = true;
				}
				else if ( stopWhenReached )
				{
					break;
				}
			}
			
			sleepTime = 1.f;
			if ( distanceDelta > 0.f )
				sleepTime = MinF( 5.f, distanceDelta * 0.25f );
			Sleep( sleepTime );
			
			if ( ! subject )
				break;
			
			pntTarget     = subject.GetWorldPosition();
			// Do not react to target position changes too often
			targetMoved   = VecDistanceSquared( pntTarget, pntTargetPrev ) > properDistance * properDistance * 0.04f;
		}
		
		Cancel( actor );
	}
}
