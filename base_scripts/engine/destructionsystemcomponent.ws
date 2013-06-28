/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher signs
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

// You can pass -1 as the rigid body index to every method in here to act on all rigid bodies.

import class CDestructionSystemComponent extends CDrawableComponent
{
	// Find rigid body index by name
	import final function FindRigidBodyIndex( node : name ) : int;
	
	// Get the current number of rigid bodies
	import final function GetRigidBodyCount() : int;

	// Apply damage to node. 
	import final function ApplyScriptedDamage( rigidBodyIndex : int, damage : float );
	
	// Applies given impulse to the center of mass
	import final function ApplyLinearImpulse( rigidBodyIndex : int, impulse : Vector );
	
	// Applies given impulse @ the given point in world space (so be careful!)
	import final function ApplyLinearImpulseAtPoint( rigidBodyIndex : int, impulse, point : Vector );

	// Applies force to the center of mass
	import final function ApplyForce( rigidBodyIndex : int, force : Vector, time : float );

	// Get current linear velocity
	import final function GetLinearVelocity( rigidBodyIndex : int ) : Vector;

	// Get current angular velocity
	import final function GetAngularVelocity( rigidBodyIndex : int ) : Vector;

	// Set new linear velocity (rigid mesh must be dynamic)
	import final function SetLinearVelocity(  rigidBodyIndex : int, velocity : Vector );

	// Set new angular velocity (rigid mesh must be dynamic)
	import final function SetAngularVelocity(  rigidBodyIndex : int, velocity : Vector );
	
	// Get the center of mass in world space
	import final function GetCenterOfMassInWorld( rigidBodyIndex : int ) : Vector;
	
	// Set the damage taking flag
	import final function SetTakesDamage( flag : bool );
	
	// Destroy all rigid bodies
	import final function DestroyRigidBodies();
}

exec function DestroyPhysicalComponent( objectTag : name, damage : float )
{
	var target : CEntity;
	var destructionComponent : CDestructionSystemComponent;
	
	target = theGame.GetEntityByTag( objectTag );
	
	destructionComponent = (CDestructionSystemComponent) target.GetComponentByClassName( 'CDestructionSystemComponent' );
	
	destructionComponent.ApplyScriptedDamage( -1, damage );

}
