/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree Machine Tasks
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// RotateToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskRotateToTarget extends IBehTreeTask
{
	editable var rotationTime : float;	
	default rotationTime = 0.2;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		if( npc.IsRotatedTowardsPoint( GetTargetPosition() ) )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var npcPos, vec : Vector;
		var curRot, rot : EulerAngles;
		
		npc = GetNPC();
		
		npcPos = npc.GetWorldPosition();
				
		vec = GetTargetPosition() - npcPos;
		rot = VecToRotation( vec );
		
		curRot = npc.GetWorldRotation();
		if( AbsF( AngleDistance( curRot.Yaw, rot.Yaw )) > 1.0 )
		{		
			npc.ActionSlideToWithHeading( npcPos, rot.Yaw, rotationTime );			
		}
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// AnimatedRotateToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskAnimatedRotateToTarget extends IBehTreeTask
{
	editable var noRotateAngle : float;
	editable var rotationTime180 : float;
	
	default noRotateAngle = 10.0;
	default rotationTime180 = 1;	

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		if( npc.IsRotatedTowardsPoint( GetTargetPosition(), noRotateAngle ) )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var res : bool;
		
		res = AnimatedRotateToTarget(GetTargetPosition(), rotationTime180);
		return BTNS_Completed;
	}
	
	latent function AnimatedRotateToTarget( target : Vector, time180 : float ) : bool
	{
		var npc : CNewNPC = GetNPC();		
		var vec : Vector;
		var rot, curRot : EulerAngles;
		var angleDistance, r, time : float;	
		var res : bool = true;
		
		vec = target - npc.GetWorldPosition();
		rot = VecToRotation( vec );
		
		curRot = npc.GetWorldRotation();
		angleDistance = AngleDistance( curRot.Yaw, rot.Yaw );
		
		time = time180 * AbsF( angleDistance )/180.0;
		if( AbsF( angleDistance ) < 1 )
		{				
		}
		/*if( AbsF( angleDistance ) < 30 )
		{
			ActionSlideToWithHeading( GetWorldPosition(), rot.Yaw, time );				
		}*/
		else if( angleDistance > 0 )
		{				
			if( AbsF( angleDistance ) > 110 )
			{
				npc.RaiseForceEvent( 'TurnRight' );
				Sleep( time180/2 );
			}
			
			npc.RaiseForceEvent( 'TurnRight' );
			Sleep( time );				
			//res = npc.ActionSlideToWithHeading( npc.GetWorldPosition(), rot.Yaw, time );				
		}
		else
		{
			if( AbsF( angleDistance ) > 110 )
			{
				npc.RaiseForceEvent( 'TurnLeft' );
				Sleep( time180/2 );
			}
			
			npc.RaiseForceEvent( 'TurnLeft' );
			Sleep( time );
			//res = npc.ActionSlideToWithHeading( npc.GetWorldPosition(), rot.Yaw, time );				
		}

		npc.RaiseForceEvent( 'Idle' );
		return res;
	}
}

/////////////////////////////////////////////////////////////////////
// LocomotionRotateToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskLocomotionRotateToTarget extends IBehTreeTask
{
	editable var noRotateAngle : float;
	default noRotateAngle = 10.0;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( npc.IsRotatedTowardsPoint( GetTargetPosition(), noRotateAngle ) )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}	
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var pos : Vector = GetTargetPosition();
		var res : bool;
		
		res = npc.ActionRotateTo( pos );
		if( res )
			return BTNS_Completed;
		else
			return BTNS_Failed;
	}
}
