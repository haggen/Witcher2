/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Tick group
/////////////////////////////////////////////

enum ETickGroup
{
	TICK_PrePhysics,					
	TICK_Main,
	TICK_Main_Parallel,
	TICK_PostPhysics,
	TICK_PostUpdateTransform,
};

/////////////////////////////////////////////
// Entity spawn data
/////////////////////////////////////////////
import struct SEntitySpawnData
{
	import public var restored : bool;
}

/////////////////////////////////////////////
// Entity class
/////////////////////////////////////////////
import class CEntity extends CNode
{	
	// Entity was dynamically spawned
	event OnSpawned( spawnData : SEntitySpawnData ) {}

	// Entity was destroyed
	event OnDestroyed() {}
	
	// Something has entered trigger area owned by this entity
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent );

	// Something has exited trigger area owned by this entity
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent );
	
	// Animated component speed changed
	event OnSpeedChanged( component : CAnimatedComponent, newSpeed : float );
	
	// Interaction component has been activated
	event OnInteractionActivated( interactionName : name, activator : CEntity );
	
	// Interaction component has been deactivated
	event OnInteractionDeactivated( interactionName : name, activator : CEntity );
	
	// An event called when a phantom component detects a collision with an entity.
	event OnPhantomCollision( otherEntity : CEntity, collisionPoint : Vector, collisionNormal : Vector );

	//////////////////////////////////////////////////////////////////////////////////////////

	// An event called when owning entity is lost ( destroyed, unloaded, etc )
	event OnOwnerEntityLost();

	// An event called when this entity is registered as owned by specified gameplay entity
	event OnRegisteredInOwner( owner : CGameplayEntity );

	// An event called when this entity is unregistered from owning gameplay entity
	event OnUnregisteredFromOwner( owner : CGameplayEntity );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Add named timer to entity
	import final function AddTimer( timerName : name, period : float, optional repeats : bool, optional scatter : bool, optional group : ETickGroup );
	
	// Remove named timer from entity
	import final function RemoveTimer( timerName : name, optional group : ETickGroup );
	
	// Remove all timers from entity
	import final function RemoveTimers();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Find waypoint from this entity
	import final function FindWaypoint( waypointName : string ) : CWayPointComponent;
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Destroy this entity
	import final function Destroy();

	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Teleport entity to new location
	import final function Teleport( position : Vector );

	// Teleport entity to new location
	import final function TeleportWithRotation(position : Vector, rotation : EulerAngles );
	
	// Teleport entity to node (for CActor TeleportToWaypoint is used if possible)
	import final function TeleportToNode( node : CNode, optional applyRotation : bool /*= true */ ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get root animated component
	import final function GetRootAnimatedComponent() : CAnimatedComponent;
	
	// Rise behavior event, returns true if event was processed
	import final function RaiseEvent( eventName : name ) : bool;
	
	// Rise behavior force event, returns true if event was processed
	import final function RaiseForceEvent( eventName : name ) : bool;
	
	// Wait for behavior event processing. Default timeout is 10s. Return false if timeout occurred.
	import latent final function WaitForEventProcessing( eventName : name, optional timeout : float ) : bool;

	// Wait for behavior node activation. Default timeout is 10s. Return false if timeout occurred.
	import latent final function WaitForBehaviorNodeActivation( activationName : name, optional timeout : float ) : bool;
	
	// Wait for behavior node deactivation. Default timeout is 10s. Return false if timeout occurred.
	import latent final function WaitForBehaviorNodeDeactivation( deactivationName : name, optional timeout : float ) : bool;
	
	// Check if node deactivation notification was received last frame
	import final function BehaviorNodeDeactivationNotificationReceived( deactivationName : name ) : bool;
	
	// Get behavior graphs as one string
	import final function GetBehaviorInstancesAsString() : string;
	
	// Event called when animation event has occured
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType );

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get bone world matrix by name
	import final function GetBoneWorldMatrix( bone : name ) : Matrix;
	
	// Get bone world matrix by index
	import final function GetBoneWorldMatrixByIndex( boneIndex : int ) : Matrix;
	
	// Get bone index, -1 if didn't find
	import final function GetBoneIndex( bone : name ) : int;
	
	// Get move target
	import final function GetMoveTarget() : Vector;
	
	// Get move final heading
	import final function GetMoveHeading() : float;
	
	// Activate behavior graph instances
	import final function ActivateBehaviors( names : array< name > ) : bool;
	
	// Activate and sync behavior graph instances
	import latent final function ActivateAndSyncBehaviors( names : array< name >, optional timeout : float ) : bool;
	
	// Activate and sync behavior graph instances
	import latent final function ActivateAndSyncBehavior( names : name, optional timeout : float ) : bool;
	
	// Attach behavior graph
	import final function AttachBehavior( instanceName : name ) : bool;
	
	// Detach behavior graph
	import final function DetachBehavior( instanceName : name ) : bool;
	
	// Activate behavior animation constraint with dynamic target, return true if activation was success
	import final function ActivateDynamicAnimatedConstraint( target : CNode, activationVariableName : string, variableToControlName : string, optional timeout : float ) : bool;
	
	// Activate behavior animation constraint with static target, return true if activation was success
	import final function ActivateStaticAnimatedConstraint( target : Vector, activationVariableName :  string, variableToControlName : string, optional timeout : float ) : bool;
	
	// Activate behavior animation constraint with entity's bone target, return true if activation was success
	import final function ActivateBoneAnimatedConstraint( target : CEntity, bone : string, activationVariableName : string, variableToControlName : string,
							optional useOffset : bool /* = false */, optional offsetMatrix : Matrix /* = IDENTITY */, optional timeout : float /* = 0.0f */ ) : bool;
	
	// Deactivate behavior animation constraint
	import final function DeactivateAnimatedConstraint( activationVariableName : string ) : bool;
	
	// Has behavior animation constraint
	import final function HasAnimatedConstraint( activationVariableName : string ) : bool;
	
	// Get behavior float variable
	import final function GetBehaviorVariable( varName : string ) : float;
	
	// Get behavior vector variable
	import final function GetBehaviorVectorVariable( varName : string ) : Vector;
	
	// Set behavior float variable
	import final function SetBehaviorVariable( varName : string, varValue : float ) : bool;
	
	// Set behavior vector variable
	import final function SetBehaviorVectorVariable( varName : string, varValue : Vector ) : bool;
	
	// Enable or disable collision events for a component.
	// Optionally restrict reporting to collisions with given otherComponent.
	import final function EnableCollisionInfoReportingForComponent( component : CComponent, enable : bool, ignoreInternalCollisions : bool, optional otherComponent : CComponent ); 
	
	// Notify the code
	// import final function OnAardHit(); // deprecated
	
	// Fade
	import final function Fade( fadeIn : bool );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get path component from entity
	import function GetPathComponent() : CPathComponent;
	
	// Get component by name
	import function GetComponent( compName : string ) : CComponent;

	// Get first component of given class
	import function GetComponentByClassName( className : name ) : CComponent;
	
	// Get first component of given class
	import function GetComponentsByClassName( className : name ) : array< CComponent >;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Selects a different appearance for the entity.
	import function ApplyAppearance( appearanceName : string );
	
	// Sets body part state
	import function SetBodyPartState( bodyPartName : name, bodyPartState : name, optional applyNow : bool );
	
	// Gets body part state (default state is 'Default')
	import function GetBodyPartState( bodyPartState : name ) : name;
	
	// Sets body parts state
	import function SetBodyState( bodyPartState : name, optional applyNow : bool );
	
	// Get appearance
	import function GetAppearance() : name;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import function SetAutoEffect( effectName : name ) : bool; 
	import function PlayEffect( effectName : name, optional target : CNode  ) : bool;
	import function PlayEffectOnBone( effectName : name, boneName : name, optional target : CNode ) : bool;
	import function StopEffect( effectName : name ) : bool;
	import function StopAllEffects();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Activate behavior graph instance
	final function ActivateBehavior( names : name ) : bool
	{
		var inst : array< name >;
		inst.PushBack( names );
		
		return ActivateBehaviors( inst );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Spells hit statistics
	//////////////////////////////////////////////////////////////////////////////////////////
		
	private function NotifySpellHit( spellName : name ) 
	{
		var count, i : int;
		var tags : array<name>;
				
		// Add an entry to the facts DB
		tags = GetTags();
		count = tags.Size();
		for ( i = 0; i < count; i += 1 )
		{
			FactsAdd( "object_" + tags[i] + "_was_hit_by_" + spellName, 1, 5 );
		}
	}
	
	// Called when an entity gets hit with Aard
	abstract function HandleAardHit( aard : CWitcherSignAard );
	
	// Called when an entity gets hit with Igni
	abstract function HandleIgniHit( igni : CWitcherSignIgni );
	
	// Called when an entity gets hit with Yrden
	abstract function HandleYrdenHit( yrden : CWitcherSignYrden );
	
	function GetSignTargetZ() : float
	{
		return 0.0;
	}
}

// Throw given entity with balistic trajectory
import function ThrowEntity( entity : CEntity, angleInDegrees : float, destPos : Vector, optional multiplier : float ) : bool;
// Throw given entity with balistic trajectory
import function ThrowEntityWithHorizontalVelocity( entity : CEntity, velocity : float, destPos : Vector ) : bool;

