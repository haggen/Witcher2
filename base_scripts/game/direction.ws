/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

enum EDirection
{
	D_Front,
	D_Right,
	D_Back,
	D_Left
};

// Converts angle to direction
function AngleToDirection( angle : float ) : EDirection
{
	angle = AngleNormalize( angle );
	if( angle >= 180.0f)
	{
		angle -= 360.0f;
	}

	if ( angle <= 45.f && angle >= -45.f )
	{
		return D_Front;
	}
	else if ( angle > 45.f && angle <= 135.f )
	{
		return D_Right;
	}
	else if ( angle < -45.f && angle >= -135.f )
	{
		return D_Left;
	}
	else
	{
		return D_Back;
	}
}

// Converts direction vector to direction
function VectorToDirection( vec : Vector ) : EDirection
{			
	var rot : EulerAngles;
	vec.Z = 0.0f;
	rot = VecToRotation( vec );
	return AngleToDirection( -rot.Yaw );		
}

function CalculateRelativeDirection( node : CNode, target : CNode ) : EDirection
{
	var mat : Matrix;
	var vec, vecLocal : Vector;
	mat = node.GetWorldToLocal();
	vec = target.GetWorldPosition() - node.GetWorldPosition();
	vecLocal = VecTransformDir( mat, vec );
	return VectorToDirection( vecLocal );
}