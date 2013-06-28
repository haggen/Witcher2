/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Rigid mesh component class exports
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

/////////////////////////////////////////////
// Rigid mesh component
/////////////////////////////////////////////

import class CPhysicsSystemComponent extends CComponent
{
	// Get index of named rigid body
	import final function GetRigidBodyIndex( rigidBody : string ) : int;
	
	// Is rigid body moving?
	import final function IsRigidBodyMoving( rigidBodyIndex : int ) : bool;
	
	// Deactivate body movement
	import final function StopRigidBodyMovement( rigidBodyIndex : int );
	
	// Teleport rigid body to given position
	import final function TeleportRigidBody( rigidBodyIndex : int, position : Vector, rotation : EulerAngles );
	
	// Applies given impulse to the center of mass
	import final function ApplyLinearImpulse( rigidBodyIndex : int, impulse : Vector );
	
	// Applies given impulse @ the given point in world space (so be careful!)
	import final function ApplyLinearImpulseAtPoint( rigidBodyIndex : int, impulse, point : Vector );

	// Applies force to the center of mass
	import final function ApplyForce( rigidBodyIndex : int, force : Vector, time : float );
	
	// Return first collision between startPoint and stopPoint. collidedRigidBodyIdx is >= 0 if collided component belongs to this physics system
	import final function TraceRay( startPoint, stopPoint : Vector, out collidedComponent : CComponent, out collidedRigidBodyIdx : int ) : bool;
	
	// Return first collision between startPoint and stopPoint. collidedRigidBodyIdx is >= 0 if collided component belongs to this physics system
	import final function TraceFatRay( startPoint, stopPoint : Vector, rayRadius : float, out collidedComponent : CComponent, out collidedRigidBodyIdx : int, collisionLayer : ECollisionLayerType ) : bool;
	
	// Resets component transform to original from physics system
	import final function ResetTransform( rigidBodyIndex : int );

	// Sets rigid body as keyframed (it won't be affected by physics)
	import final function SetBodyAsStatic( rigidBodyIndex : int );

	// Sets rigid body as dynamic (it will be affected by physics)
	import final function SetBodyAsDynamic( rigidBodyIndex : int );
}
