/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Rigid mesh component class exports
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

/////////////////////////////////////////////
// Rigid mesh component
/////////////////////////////////////////////

import class CRigidMeshComponent extends CStaticMeshComponent
{
	// Applies given impulse to the center of mass
	import final function ApplyLinearImpulse( impulse : Vector );
	
	// Applies given impulse @ the given point in world space (so be careful!)
	import final function ApplyLinearImpulseAtPoint( impulse, point : Vector );

	// Applies force to the center of mass
	import final function ApplyForce( force : Vector, time : float );

	// Get current linear velocity
	import final function GetLinearVelocity() : Vector;

	// Get current angular velocity
	import final function GetAngularVelocity() : Vector;

	// Set new linear velocity (rigid mesh must be dynamic)
	import final function SetLinearVelocity( velocity : Vector );

	// Set new angular velocity (rigid mesh must be dynamic)
	import final function SetAngularVelocity( velocity : Vector );
	
	// Get the center of mass in world space
	import final function GetCenterOfMassInWorld() : Vector;
	
	// Restore initial position and rotation
	import final function ResetPositionAndRotation();
	
	// Restore initial position and rotation
	import final function IsMoving() : bool;
	
	// Deactivate body movement
	import final function StopMovement();

	// Enable physics simulation on mesh ( toggle movetype dynamic )
	import final function EnablePhysics();

	// Disable physics simulation on mesh ( toggle movetype dynamic )
	import final function DisablePhysics();
	
	// Change collision layer type ( returns previous layer type )
	import final function SetCollisionLayer( layer : ECollisionLayerType ) : ECollisionLayerType;
	
}	

/////////////////////////////////////////////
// Phantom component
/////////////////////////////////////////////

import class CPhantomComponent extends CComponent
{
	// Activates phantom if not active
	import final function Activate();
	
	// Deactivates phantom if active
	import final function Deactivate();
};
				
	
					
			
			
			
			
