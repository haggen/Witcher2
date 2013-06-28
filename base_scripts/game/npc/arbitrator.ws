/*enum EAIPriority
{
	AIP_Lowest,
	AIP_Low,
	AIP_Normal,
	AIP_High,
	AIP_Highest,
	AIP_BlockingScene,
	AIP_Cutscene,
	AIP_Combat,
	AIP_Custom,
	AIP_Minigame,
	AIP_Audience,
	AIP_Unconscious,
};*/

/*enum EAICombatCurvesType
{
	AICCT_Standard,
	AICCT_Follower,
	AICCT_Battle,
};*/

/////////////////////////////////////////////////////////////////////
// CAIArbitrator
/////////////////////////////////////////////////////////////////////
import class CAIArbitrator extends CObject
{
	// TODO: native
	final function GetOwner() : CNewNPC
	{
		return (CNewNPC)GetParent();
	}

	// Clear all goals
	import final function ClearAllGoals();
	
	// Clear goal with given priority
	import final function ClearGoal( optional priority : EAIPriority /*= AIP_Normal*/ );

	// Add goal (returns goal id)
	import final function AddGoal( goal : CAIGoal, priority : EAIPriority, optional priorityValue : int /* = 0 */, optional notUniqueAllowed : bool /* = false */ ) : int;
	
	// Change goal priority
	import final function ChangeGoalPriority( goalId : int, priority : EAIPriority, optional priorityValue : int /* = 0 */ );
	
	// Mark goal finished
	import final function MarkGoalFinished( goalId : int );
	
	// Get array of goals of given class, returns true if anything found
	import final function GetGoalIdsByClassName( className : name, out outArray : array<int> ) : bool;
	
	// Has any goals
	import final function HasGoals() : bool;

	// Has goals of given class?
	import final function HasGoalsOfClass( className : name ) : bool;
	
	// Has current goal of a given class?
	import final function HasCurrentGoalOfClass( className : name ) : bool;
	
	// Has reaction goals?
	import final function HasReactionGoals() : bool;
	
	// Has goals with given priority?
	import final function HasGoalsWithPriority( priority : EAIPriority, optional priorityValue : int, optional reactionGoalsOnly : bool ) : bool;
	
	// Load combat curve by resource definition alias
	import final function LoadCombatCurves( type : EAICombatCurvesType, alias : string );
	
	// Standard combat goals creation and priority update will be blocked for given time
	import final function PostponeCombatUpdate( time : float );
	
	// Map priority to priority value
	import final function MapPriority( priority : EAIPriority ) : int; 
	
	// Mark goals finished by class name
	final function MarkGoalsFinishedByClassName( className : name )
	{
		var goals : array<int>;
		var i : int;
		if( GetGoalIdsByClassName( className, goals ) )
		{
			for( i=0; i<goals.Size(); i+=1 )
			{
				MarkGoalFinished( goals[i] );
			}
		}
	}
		
	final function AddGoalIdle( immediate : bool )
	{
		var goal : CAIGoalIdle;
		goal = new CAIGoalIdle in this;
		goal.breakActions = immediate;
		AddGoal( goal, AIP_Lowest );
	}
	
	final function AddGoalUnconscious( deathData : SActorDeathData )
	{
		var goal : CAIGoalUnconscious;
		goal = new CAIGoalUnconscious in this;
		goal.deathData = deathData;
		AddGoal( goal, AIP_Unconscious );
	}
	
	final function AddGoalIdleAfterCombat( time : float )
	{
		var goal : CAIGoalIdleAfterCombat;
		goal = new CAIGoalIdleAfterCombat in this;
		goal.time = time;
		AddGoal( goal, AIP_Low );
	}
	
	final function AddGoalStaticCombat( enemy : CActor, position : Vector )
	{
		var goal : CAIGoalStaticCombat;	
		goal = new CAIGoalStaticCombat in this;
		EntityHandleSet( goal.enemy, enemy );
		goal.position = position;
		goal.combatParams.dynamicsType = CDT_Static;		
		goal.combatParams.forcedDistanceType = CDT_CloseCombat;
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalFistfightAreaCombat( enemy : CActor, position : Vector, fistfightArea : W2FistfightArea )
	{
		var goal : CAIGoalFistfightAreaCombat;
		goal = new CAIGoalFistfightAreaCombat in this;
		goal.enemy = enemy;
		goal.position = position;
		goal.combatParams.dynamicsType = CDT_Static;		
		goal.combatParams.forcedDistanceType = CDT_CloseCombat;
		goal.combatParams.fistfightArea = fistfightArea;		
		AddGoal( goal, AIP_High );
	}

	final function AddGoalFistfightAreaEnter( fistfightArea : W2FistfightArea, position : Vector, rotation : EulerAngles, moveType : EMoveType )
	{
		var goal : CAIGoalFistfightAreaEnter;	
		goal = new CAIGoalFistfightAreaEnter in this;
		goal.fistfightArea = fistfightArea;
		goal.pos = position;
		goal.rot = rotation;
		goal.moveType = moveType;
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalDespawn( optional forced : bool, optional usePoint : bool, optional isHiddenDespawn : bool, optional despawnPoint : Vector )
	{	
		var goal : CAIGoalDespawn;
		goal = new CAIGoalDespawn in this;
		goal.forced = forced;
		goal.usePoint = usePoint;
		goal.despawnPoint = despawnPoint;
		goal.isHiddenDespawn = isHiddenDespawn;
		AddGoal( goal, AIP_Highest );
	}
			
	final function AddGoalScene( scene : CStoryScene )
	{
		var goal : CAIGoalScene;
		goal = new CAIGoalScene in this;
		goal.scene = scene;
		AddGoal( goal, AIP_BlockingScene );
		MarkGoalsFinishedByClassName( 'CAIGoalPrepareForScene' );
		MarkGoalsFinishedByClassName( 'CAIGoalWorkInScene' );
	}
	
	final function AddGoalPrepareForScene( scenePosition : Vector, heading : float, distance : float, priority : int, moveType : EMoveType )
	{
		var goal : CAIGoalPrepareForScene;
		goal = new CAIGoalPrepareForScene in this;		
		goal.scenePosition = scenePosition;
		goal.heading = heading;
		goal.distance = distance;
		goal.moveType = moveType;
		AddGoal( goal, AIP_Custom, priority );
	}
	
	final function AddGoalWorkInScene( apID : int, category : name, priorityValue : int, moveType : EMoveType )
	{
		var goal : CAIGoalWorkInScene;
		goal = new CAIGoalWorkInScene in this;
		goal.apID = apID;
		goal.category = category;
		goal.moveType = moveType;
		AddGoal( goal, AIP_Custom, priorityValue );
	}
	
	final function AddGoalCutscene()
	{
		var goal : CAIGoalCutscene;
		goal = new CAIGoalCutscene in this;
		AddGoal( goal, AIP_Cutscene );
		MarkGoalsFinishedByClassName( 'CAIGoalPrepareForScene' );
		MarkGoalsFinishedByClassName( 'CAIGoalWorkInScene' );
	}
	
	final function AddGoalReactionTree( treeRes : string, interestPoint : CInterestPointInstance, staticPosition : bool, processOnce : bool, timeout : float,
		priority : EAIPriority, priorityValue : int, exitWorkMode : EExitWorkMode, canBePushed : bool )
	{
		var goal : CAIGoalTree;
		var node : CNode = interestPoint.GetNode();
		goal = new CAIGoalTree in this;
		goal.treeRes = treeRes;
		
		if( node && !staticPosition )
		{
			PersistentRefSetNode( goal.persistentRef, node );
		}
		else
		{
			PersistentRefSetOrientation( goal.persistentRef, interestPoint.GetWorldPosition(), EulerAngles(0,0,0) );
		}
		
		goal.processOnce = processOnce;
		goal.timeout = timeout;		
		goal.exitWorkMode = exitWorkMode;		
		goal.canBePushed = canBePushed;
		goal.SetReactionFlag( true );				
		goal.SetTTLInactive( 1.5 );		
		AddGoal( goal, priority, priorityValue, true );
	}
	
	final function AddGoalReaction( reactionIndex : int, interestPoint : CInterestPointInstance, staticPosition : bool, timeout : float, priority : EAIPriority, priorityValue : int )
	{
		var goal : CAIGoalReaction;
		var node : CNode = interestPoint.GetNode();
		goal = new CAIGoalReaction in this;
		goal.reactionIndex = reactionIndex;
		
		if( node && !staticPosition )
		{
			PersistentRefSetNode( goal.persistentRef, node );
		}
		else
		{
			PersistentRefSetOrientation( goal.persistentRef, interestPoint.GetWorldPosition(), EulerAngles(0,0,0) );
		}
			
		goal.SetReactionFlag( true );
		goal.SetTTLInactive( 1.5 );		
		AddGoal( goal, priority, priorityValue, true );
	}
	
	final function AddGoalMoveToTarget( target : CNode, moveType : EMoveType, speed : float, distance : float, exitWorkMode : EExitWorkMode, optional priority : EAIPriority, optional ttlInactive : float )
	{
		var goal : CAIGoalMoveToTarget;
		goal = new CAIGoalMoveToTarget in this;
		goal.targetPosition = target.GetWorldPosition();
		goal.targetHeading = target.GetHeading();
		goal.moveType = moveType;
		goal.speed = speed;
		goal.distance = distance;
		goal.exitWorkMode = exitWorkMode;
		
		if( priority == AIP_Lowest ) //override default
		{
			priority = AIP_Normal;
		}
		
		if( ttlInactive != 0.0f )
		{
			goal.SetTTLInactive( ttlInactive );
		}
		
		AddGoal( goal, priority );
	}
	
	final function AddGoalPointOfInterest(mode : EPointOfInterestType, referencePoint : CNode, desiredDistance : float, timeout : float, observePOI : bool )
	{
		var goal : CAIGoalPointOfInterest;
		goal = new CAIGoalPointOfInterest in this;
		goal.mode = mode;
		PersistentRefSetNode( goal.referencePoint, referencePoint );
		goal.desiredDistance = desiredDistance;
		goal.timeout = timeout;
		goal.observePOI = observePOI;
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalPointOfInterestWithPriority(mode : EPointOfInterestType, referencePoint : CNode, desiredDistance : float, timeout : float, observePOI : bool, priority : int )
	{
		var goal : CAIGoalPointOfInterest;
		goal = new CAIGoalPointOfInterest in this;
		goal.mode = mode;
		PersistentRefSetNode( goal.referencePoint, referencePoint );
		goal.desiredDistance = desiredDistance;
		goal.timeout = timeout;
		goal.observePOI = observePOI;
		AddGoal( goal, AIP_Custom, priority );
	}
	
	final function AddGoalWalkWithActor( actor : CActor, desiredDistanceMin : float, desiredDistanceMax : float, timeout, observeDelay : float,
									observeTargetTag : name, defaultSpeed : EMoveType, walkBehind : bool )
	{
		var goal : CAIGoalWalkWithActor;
		goal = new CAIGoalWalkWithActor in this;
		EntityHandleSet( goal.actor, actor );
		goal.desiredDistanceMin = desiredDistanceMin;
		goal.desiredDistanceMax = desiredDistanceMax;
		goal.timeout = timeout;
		goal.observeDelay = observeDelay;
		goal.observeTargetTag = observeTargetTag;
		goal.defaultSpeed = defaultSpeed;
		goal.walkBehind = walkBehind;
		AddGoal( goal, AIP_Normal );
	}

	final function AddGoalActing( actions : array< IActorLatentAction >, focusedNode : CEntity )
	{
		var goal : CAIGoalActing;
		goal = new CAIGoalActing in this;
		goal.actions   = actions;
		EntityHandleSet( goal.focusedNode, focusedNode );
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalWalkToTargetWaitForPlayer( target : CNode, distanceToStop : float, distanceToGo : float,
			moveType : EMoveType, optional absSpeed : float, optional stopOnCombat : bool )
	{
		var goal : CAIGoalWalkToTargetWaitForPlayer;
		goal = new CAIGoalWalkToTargetWaitForPlayer in this;
		PersistentRefSetNode( goal.target, target );
		goal.distanceToStop = distanceToStop;
		goal.distanceToGo = distanceToGo;
		goal.moveType = moveType;
		goal.absSpeed = absSpeed;
		goal.stopOnCombat = stopOnCombat;
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalWalkAlongPathWaitForPlayer( path : CPathComponent, upThePath : bool, fromBegining : bool,
		distanceToStop : float, distanceToGo : float, distanceToChangeSpeed : float, moveType : EMoveType, optional absSpeed : float )
	{
		var goal : CAIGoalWalkAlongPathWaitForPlayer;
		goal = new CAIGoalWalkAlongPathWaitForPlayer in this;
		EntityHandleSet( goal.path, path.GetEntity() );
		goal.upThePath = upThePath;
		goal.fromBegining = fromBegining;
		goal.distanceToStop = distanceToStop;
		goal.distanceToGo = distanceToGo;
		goal.distanceToChangeSpeed = distanceToChangeSpeed;
		goal.moveType = moveType;
		goal.absSpeed = absSpeed;
		AddGoal( goal, AIP_Normal ); 
	
	}
	
	final function AddGoalWalkAlongPath( path : CPathComponent, upThePath : bool, fromBegining : bool, margin : float, moveType : EMoveType, optional speed : float )
	{
		var goal : CAIGoalWalkAlongPath;
		goal = new CAIGoalWalkAlongPath in this;
		EntityHandleSet( goal.path, path.GetEntity() );
		goal.upThePath = upThePath;
		goal.fromBegining = fromBegining;
		goal.margin = margin;
		goal.moveType = moveType;
		goal.speed = speed;
		AddGoal( goal, AIP_Normal );  
	}
	
	final function AddGoalMinigame( position : CNode, behavior : name )
	{
		var goal : CAIGoalMinigame;
		goal = new CAIGoalMinigame in this;
		goal.position = position;
		goal.behavior = behavior;
		AddGoal( goal, AIP_Minigame );
	}
	
	final function AddGoalAudience( node : CNode, audience : CAudience )
	{
		var goal : CAIGoalAudience;
		goal = new CAIGoalAudience in this;
		EntityHandleSet( goal.audience, audience );
		goal.position = node.GetWorldPosition();
		goal.rotation = node.GetWorldRotation();
		AddGoal( goal, AIP_Audience );
	}
	
	// INTERACTION
	final function AddGoalInteractionMaster( inputSlaves : array<CActor>, masterBehaviorName : name, slaveBehaviorName : name,
                                             latentAction : IActorLatentAction, nodeOfInterest : CEntity )
	{
		var goal : CAIGoalInteractionMaster;
		var i : int;
		goal = new CAIGoalInteractionMaster in this;	
		goal.slaves.Grow(inputSlaves.Size());
		for( i=0; i<inputSlaves.Size(); i+= 1 )
		{
			EntityHandleSet( goal.slaves[i], inputSlaves[i] );
		}
		
		goal.masterBehaviorName = masterBehaviorName;
		goal.slaveBehaviorName  = slaveBehaviorName;
		EntityHandleSet( goal.nodeOfInterest, nodeOfInterest );
		
		if ( latentAction )
			goal.latentAction = (IActorLatentAction) latentAction.Clone( goal );
		
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalInteractionSlave( master : CActor, slaveBehaviorName : name, instantStart : bool, initialSpeed : float )
	{
		var goal : CAIGoalInteractionSlave;
		goal = new CAIGoalInteractionSlave in this;			
		EntityHandleSet( goal.master, master );
		goal.slaveBehaviorName = slaveBehaviorName;
		goal.instantStart = instantStart;
		goal.initialSpeed = initialSpeed;
		AddGoal( goal, AIP_High );
	}
	
	// TAKEDOWN
	final function AddGoalTakedown()
	{
		var goal : CAIGoalTakedown;
		goal = new CAIGoalTakedown in this;
		goal.SetTTLInactive( 2.0 );
		ClearGoal( AIP_Highest );
		AddGoal( goal, AIP_Highest );
	}
	
	// TAKEDOWN OBSERVE
	final function AddGoalTakedownObserve()
	{
		var goal : CAIGoalTakedownObserve;
		goal = new CAIGoalTakedownObserve in this;
		goal.SetTTLInactive( 2.0 );
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalBurn()
	{
		var goal : CAIGoalBurn;
		goal = new CAIGoalBurn in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Custom, MapPriority( AIP_Highest ) - 10 );
	}
	
	final function AddGoalIncapacitate( duration : float, isWanderEnable : bool )
	{
		var goal : CAIGoalIncapacitate;
		goal = new CAIGoalIncapacitate in this;
		goal.duration = duration;
		goal.wandering = isWanderEnable;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalKnockdown()
	{
		var goal : CAIGoalKnockdown;
		goal = new CAIGoalKnockdown in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalFalter()
	{
		var goal : CAIGoalFalter;
		goal = new CAIGoalFalter in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalBlind()
	{
		var goal : CAIGoalBlind;
		goal = new CAIGoalBlind in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalUnbalance()
	{
		var goal : CAIGoalUnbalance;
		goal = new CAIGoalUnbalance in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalDrunk()
	{
		var goal : CAIGoalDrunk;
		goal = new CAIGoalDrunk in this;
		goal.SetTTLInactive( 10.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalStun()
	{
		var goal : CAIGoalStun;
		goal = new CAIGoalStun in this;
		//goal.SetTTLInactive( 3.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalImmobile()
	{
		var goal : CAIGoalImmobile;
		goal = new CAIGoalImmobile in this;
		//goal.SetTTLInactive( 3.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalFear()
	{
		var goal : CAIGoalFear;
		goal = new CAIGoalFear in this;
		//goal.SetTTLInactive( 3.0 );
		goal.inCombat = GetOwner().IsInCombat();
		AddGoal( goal, AIP_Highest );
	}

	final function AddGoalBehavior( behaviorName : name )
	{
		var goal : CAIGoalBehavior;
		goal = new CAIGoalBehavior in this;
		goal.behaviorName = behaviorName;
		AddGoal( goal, AIP_Normal );	
	}
	
	final function AddGoalKeepAwayFromScene( sceneCenter : Vector, sceneRadius : float )
	{
		var goal : CAIGoalKeepAwayFromScene;
		goal = new CAIGoalKeepAwayFromScene in this;
		goal.sceneCenter = sceneCenter;
		goal.sceneRadius = sceneRadius;
		goal.SetTTLInactive( 3.0 );
		AddGoal( goal, AIP_Highest );
	}
	
	final function AddGoalGuardWithReaction( left : bool )
	{
		var goal : CAIGoalGuardWithReaction;
		goal = new CAIGoalGuardWithReaction in this;		
		goal.left = left;
		AddGoal( goal, AIP_Normal );
	}

	final function AddGoalAttractedByLure( lure : CLure )
	{
		var goal : CAIGoalAttractedByLure;
		goal = new CAIGoalAttractedByLure in this;
		EntityHandleSet( goal.lure, lure );
		//goal.SetTTLInactive( 1.0f );
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalTalk()
	{
		var goal : CAIGoalTalk;
		goal = new CAIGoalTalk in this;
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalUseDevice( device : CGameplayDevice )
	{
		var goal : CAIGoalUseDevice;
		goal = new CAIGoalUseDevice in this;
		EntityHandleSet( goal.device, device );
		AddGoal( goal, AIP_Highest );
	}
	
	// QUEST GOALS
	final function AddGoalQ002Torturer()
	{
		var goal : CAIGoalScriptedState;
		goal = new CAIGoalScriptedState in this;
		goal.entryFunctionName = 'StateQ002Torturer';
		goal.stateName = 'Q002Torturer';
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalQ002Arjan()
	{
		var goal : CAIGoalScriptedState;
		goal = new CAIGoalScriptedState in this;
		goal.entryFunctionName = 'StateQ002Arjan';
		goal.stateName = 'Q002Arjan';
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalQ109Arnolt()
	{
		var goal : CAIGoalScriptedState;
		goal = new CAIGoalScriptedState in this;
		goal.entryFunctionName = 'StateQ109Arnolt';
		goal.stateName = 'Q109Arnolt';
		AddGoal( goal, AIP_High );
	}
	
	final function AddGoalGetWorkItem( take_item : bool )
	{
		var goal : CAIGoalGetWorkItem;
		goal = new CAIGoalGetWorkItem in this;
		goal.take_item = take_item;		
		AddGoal( goal, AIP_Normal );
	}
	
	final function AddGoalHandleCityLights()
	{
		var goal : CAIGoalHandleCityLights;
		goal = new CAIGoalHandleCityLights in this;
		AddGoal( goal, AIP_Normal );
	}	
};

/////////////////////////////////////////////////////////////////////
// CAIGoal
/////////////////////////////////////////////////////////////////////
import class CAIGoal extends CObject
{
	// Get owner
	import final function GetOwner() : CNewNPC;
	
	// Get goal Id
	import final function GetGoalId() : int;
	
	// Set time to live counted when not active
	import final function SetTTLInactive( timeToLive : float );
	
	// Set reaction flag
	import final function SetReactionFlag( set : bool );
	
	// Mark goal finished
	import final function MarkGoalFinished();

	// Start goal callback
	function Start() : bool { return true; }
	
	// Pause goal callback
	function Pause() : bool { return true; }
	
	// Restart goal callback
	function Restart( restored : bool ) : bool { return Start(); }
	
	// On goal added
	event OnAdded();
	
	// On goal removed
	event OnRemoved();
	
	// Get debug info string (append text to result)
	function GetInfo( out result : string );
	
	private function AddIdleAfterCombat()
	{
		var owner : CNewNPC = GetOwner();
		var arbitrator : CAIArbitrator = owner.GetArbitrator();		
				
		if( !arbitrator.HasGoalsOfClass( 'CAIGoalFormation' ) )
		{
			arbitrator.AddGoalIdleAfterCombat( RandRangeF( 3.0, 5.0 ) );
		}
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalSavable
/////////////////////////////////////////////////////////////////////
import class CAIGoalSavable extends CAIGoal
{
}

/////////////////////////////////////////////////////////////////////
// CAIGoalCombat
/////////////////////////////////////////////////////////////////////
import class CAIGoalCombat extends CAIGoal
{
	// Get goal enemy
	import final function GetEnemy() : CActor;

	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		AddIdleAfterCombat();
		owner.EnterCombat( SCombatParams( GetGoalId(), CDT_Regular ) );
		return true;
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalStaticCombat
/////////////////////////////////////////////////////////////////////
import class CAIGoalStaticCombat extends CAIGoalSavable
{
	private import saved var enemy : EntityHandle;
	private import saved var position : Vector;
	private saved var combatParams : SCombatParams;

	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();	
		AddIdleAfterCombat();	
		owner.SetFocusedPostion( position );
		combatParams.goalId = GetGoalId();		
		owner.EnterCombat( combatParams );		
		return true;
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalFistfightAreaCombat
/////////////////////////////////////////////////////////////////////
import class CAIGoalFistfightAreaCombat extends CAIGoal
{
	private import var enemy : CActor;
	private import var position : Vector;
	private var combatParams : SCombatParams;

	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();

		owner.SetFocusedPostion( position );
		combatParams.goalId = GetGoalId();
		owner.EnterCombat( combatParams );		
		return true;
	}
	
	function Pause() : bool
	{
		combatParams.fistfightArea.OnBreakCombat( GetOwner() );	
		return true;
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalBattleAreaCombat
/////////////////////////////////////////////////////////////////////
import class CAIGoalBattleAreaCombat extends CAIGoal
{		
	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		var combatParams : SCombatParams;
		
		combatParams.goalId = GetGoalId();
		combatParams.forcedDistanceType = CDT_CloseCombat;
		combatParams.dynamicsType = CDT_BattleArea;
		owner.EnterCombat( combatParams );
		return true;
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalFistfightAreaEnter
/////////////////////////////////////////////////////////////////////
class CAIGoalFistfightAreaEnter extends CAIGoal
{
	var fistfightArea : W2FistfightArea;
	var pos : Vector;
	var rot : EulerAngles;
	var moveType : EMoveType;

	function Start() : bool
	{
		return GetOwner().StateFistfightAreaEnter( fistfightArea, pos, rot, moveType, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalScriptedState
/////////////////////////////////////////////////////////////////////
import class CAIGoalScriptedState extends CAIGoalSavable
{
	import saved var stateName : name;
	import saved var entryFunctionName : name; /* entry function must have no params, goalId is set automatically in state */
};

/////////////////////////////////////////////////////////////////////
// CAIGoalIdle
/////////////////////////////////////////////////////////////////////
class CAIGoalIdle extends CAIGoalSavable
{
	saved var breakActions : bool;
	
	function Start() : bool
	{
		if ( breakActions )
		{
			GetOwner().ActionCancelAll();
		}
		return GetOwner().StateIdle();
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalIdleAfterCombat
/////////////////////////////////////////////////////////////////////
class CAIGoalIdleAfterCombat extends CAIGoal
{	
	var time : float;

	function Start() : bool
	{
		return GetOwner().StateIdleAfterCombat( time, GetGoalId() );
	}
	
	function Restart( restored : bool ) : bool
	{
		MarkGoalFinished();
		return true;
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalIdle
/////////////////////////////////////////////////////////////////////
class CAIGoalUnconscious extends CAIGoalSavable
{
	saved var deathData : SActorDeathData;

	function Start() : bool
	{
		return GetOwner().StateUnconscious( deathData, false, GetGoalId() );
	}
	
	function Restart( restored : bool ) : bool
	{
		return GetOwner().StateUnconscious( deathData, restored, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalDespawn
/////////////////////////////////////////////////////////////////////
class CAIGoalDespawn extends CAIGoalSavable
{
	saved var despawnPoint : Vector;
	saved var usePoint : bool;
	saved var forced : bool;
	saved var isHiddenDespawn : bool;

	function Start() : bool
	{
		GetOwner().StopEffect('cat_fx');
		if( forced )
		{
			return GetOwner().StateForceDespawn( GetGoalId() );
		}
		else
		{	
			if( usePoint )
				return GetOwner().StateDespawnAtPlace( despawnPoint, isHiddenDespawn, GetGoalId() );
			else
				return GetOwner().StateDespawn( GetGoalId(), isHiddenDespawn );
		}
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalScene
/////////////////////////////////////////////////////////////////////
class CAIGoalScene extends CAIGoal
{
	 var scene : CStoryScene;
	 
	function Start() : bool
	{
		return GetOwner().StateScene( scene, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalPrepareForScene
/////////////////////////////////////////////////////////////////////
class CAIGoalPrepareForScene extends CAIGoal
{
	var scenePosition : Vector;
	var heading : float;
	var distance : float;
	var moveType : EMoveType;
	 
	function Start() : bool
	{
		return GetOwner().StatePrepareForScene( scenePosition, heading, distance, moveType, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalWorkInScene
/////////////////////////////////////////////////////////////////////
class CAIGoalWorkInScene extends CAIGoal
{
	var apID : int;
	var category : name;
	var moveType : EMoveType;
	 
	function Start() : bool
	{
		return GetOwner().StateWorkInScene( apID, category, moveType, GetGoalId());
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalCutscene
/////////////////////////////////////////////////////////////////////
class CAIGoalCutscene extends CAIGoal
{	 
	function Start() : bool
	{
		return GetOwner().StateCutscene( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalTree
/////////////////////////////////////////////////////////////////////
class CAIGoalTree extends CAIGoalSavable
{
	saved var treeRes		: string;
	saved var persistentRef : PersistentRef;
	saved var processOnce	: bool;
	saved var timeout		: float;	
	saved var exitWorkMode : EExitWorkMode;
	saved var canBePushed	: bool;
 
	function Start() : bool
	{
		return GetOwner().StateTree( treeRes, persistentRef, processOnce, timeout, exitWorkMode, canBePushed, GetGoalId() );
	}
	
	function Restart( restored : bool ) : bool
	{
		if( restored )
		{
			return Start();			
		}
		else
		{
			// No restart, end goal
			MarkGoalFinished();
			return false;
		}
	}
	
	function GetInfo( out result : string )
	{
		result += StrFormat(", Tree: %1", treeRes );
	}	
}

/////////////////////////////////////////////////////////////////////
// CAIGoalReaction
/////////////////////////////////////////////////////////////////////
class CAIGoalReaction extends CAIGoalSavable
{
	saved var reactionIndex : int;
	saved var persistentRef : PersistentRef;	
	 
	function Start() : bool
	{
		return GetOwner().StateReaction( reactionIndex, persistentRef, GetGoalId() );
	}
	
	function Restart( restored : bool ) : bool
	{
		if( restored )
		{	
			return Start();
		}
		else
		{
			// No restart, end goal
			MarkGoalFinished();
			return false;
		}
	}
	
	event OnRemoved()
	{
		GetOwner().RemoveTimer( 'TimerKeepPlayerCombatMode' );
	}
	
	function GetInfo( out result : string )
	{
		result += StrFormat(", Script: %1", GetOwner().GetReactionScript( reactionIndex ) );
	}	
}

/////////////////////////////////////////////////////////////////////
// CAIGoalMoveToTarget
/////////////////////////////////////////////////////////////////////
class CAIGoalMoveToTarget extends CAIGoalSavable
{
	saved var targetPosition : Vector;
	saved var targetHeading : float;
	saved var moveType : EMoveType;
	saved var speed : float;
	saved var distance : float;
	saved var exitWorkMode : EExitWorkMode;
	 
	function Start() : bool
	{
		return GetOwner().StateMoveToTarget( targetPosition, targetHeading, moveType, speed, distance, exitWorkMode, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalPointOfInterest
/////////////////////////////////////////////////////////////////////
class CAIGoalPointOfInterest extends CAIGoalSavable
{
	saved var mode : EPointOfInterestType;
	saved var referencePoint : PersistentRef;
	saved var desiredDistance : float;
	saved var timeout : float;
	saved var observePOI : bool;
	 
	function Start() : bool
	{
		return GetOwner().StatePointOfInterest( mode, referencePoint, desiredDistance, timeout, observePOI, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalWalkWithActor
/////////////////////////////////////////////////////////////////////
class CAIGoalWalkWithActor extends CAIGoalSavable
{
	saved var actor : EntityHandle;
	saved var desiredDistanceMin : float;
	saved var desiredDistanceMax : float;
	saved var timeout: float;
	saved var observeDelay : float;
	saved var observeTargetTag : name;
	saved var defaultSpeed : EMoveType;
	saved var walkBehind : bool;
	 
	function Start() : bool
	{
		return GetOwner().StateWalkWithActor( actor, desiredDistanceMin, desiredDistanceMax, timeout, observeDelay,
			observeTargetTag, defaultSpeed, walkBehind, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalActing
/////////////////////////////////////////////////////////////////////
class CAIGoalActing extends CAIGoalSavable
{
	saved var actions		: array< IActorLatentAction >;
	saved var focusedNode	: EntityHandle;

	function Start() : bool
	{
		return GetOwner().StateActing( actions, focusedNode, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalWalkToTargetWaitForPlayer
/////////////////////////////////////////////////////////////////////
class CAIGoalWalkToTargetWaitForPlayer extends CAIGoalSavable
{
	saved var target : PersistentRef;
	saved var distanceToStop : float;
	saved var distanceToGo : float;
	saved var moveType : EMoveType;
	saved var absSpeed : float;
	saved var stopOnCombat : bool;

	function Start() : bool
	{
		return GetOwner().StateWalkToTargetWaitForPlayer( target, distanceToStop, distanceToGo, moveType, absSpeed, stopOnCombat, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalWalkAlongPathWaitForPlayer
/////////////////////////////////////////////////////////////////////
class CAIGoalWalkAlongPathWaitForPlayer extends CAIGoalSavable
{
	saved var path : EntityHandle;
	saved var upThePath : bool;
	saved var fromBegining : bool;
	saved var distanceToStop : float;
	saved var distanceToGo : float;
	saved var distanceToChangeSpeed : float;
	saved var moveType : EMoveType;
	saved var absSpeed : float;

	function Start() : bool
	{	
		return StartInternal( fromBegining );
	}

	function Restart( restored : bool ) : bool
	{
		return StartInternal( false );		
	}

	private function StartInternal( _fromBegining : bool ) : bool
	{
		return GetOwner().StateWalkAlongPathWaitForPlayer( path, upThePath, _fromBegining, distanceToStop, distanceToGo, distanceToChangeSpeed, moveType, absSpeed, GetGoalId() );
	}					
}

/////////////////////////////////////////////////////////////////////
// CAIGoalWalkAlongPath
/////////////////////////////////////////////////////////////////////
class CAIGoalWalkAlongPath extends CAIGoalSavable
{
	saved var path : EntityHandle;
	saved var upThePath : bool;
	saved var fromBegining : bool;
	saved var	margin : float;
	saved var moveType : EMoveType;
	saved var speed : float;

	function Start() : bool
	{
		return StartInternal( fromBegining );
	}												
	
	function Restart( restored : bool ) : bool
	{
		return StartInternal( false );
	}
	
	private function StartInternal( _fromBegining : bool ) : bool
	{
		return GetOwner().StateWalkAlongPath( path, upThePath, _fromBegining, margin, moveType, speed, GetGoalId() );
	}	
}

/////////////////////////////////////////////////////////////////////
// CAIGoalMinigame
/////////////////////////////////////////////////////////////////////
class CAIGoalMinigame extends CAIGoal
{
	var position : CNode;
	var behavior : name;
	
	function Start() : bool
	{
		return GetOwner().StateMinigame( position, behavior, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalMinigame
/////////////////////////////////////////////////////////////////////
class CAIGoalAudience extends CAIGoalSavable
{
	saved var position : Vector;
	saved var rotation : EulerAngles;
	saved var audience : EntityHandle;

	function Start() : bool
	{
		return GetOwner().StateAudience( position, rotation, audience, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalFormation
/////////////////////////////////////////////////////////////////////

import class CAIGoalFormation extends CAIGoal
{	
	import var formation : CFormation;
	
	import final function Init( formation : CFormation );
	
	event OnAdded()
	{
		var owner : CNewNPC = GetOwner();
		super.OnAdded();
		if( formation.HasPlayer() )
		{
			owner.externalAttitudeSourcePlayer = true;
		}
	}
	
	event OnRemoved()
	{
		var owner : CNewNPC = GetOwner();
		super.OnRemoved();
		formation.RemoveMember( GetOwner() );
		owner.externalAttitudeSourcePlayer = false;
	}
		
	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		
		return owner.StateFollowFormation( formation, GetGoalId() );
	}
	
	function Pause() : bool
	{
		formation.RemoveMember( GetOwner() );
		return super.Pause();
	}
	
	function Restart( restored : bool ) : bool
	{
		formation.AddMember( GetOwner() );
		return super.Restart(restored);
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalInteractionMaster
/////////////////////////////////////////////////////////////////////
class CAIGoalInteractionMaster extends CAIGoalSavable
{
	saved var slaves             : array<EntityHandle>;
	saved var masterBehaviorName : name;
	saved var slaveBehaviorName  : name;
	saved var latentAction       : IActorLatentAction;
	saved var nodeOfInterest     : EntityHandle;
	
	function Start() : bool
	{
		return StartInternal( false );
	}
	
	function Restart( restored : bool ) : bool
	{
		return StartInternal( true );
	}
	
	private function StartInternal( instantStart : bool ) : bool
	{
		var owner : CNewNPC;
		owner = GetOwner();
		return owner.StateInteractionMaster( slaves, masterBehaviorName, slaveBehaviorName, latentAction, nodeOfInterest, instantStart, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalInteractionSlave
/////////////////////////////////////////////////////////////////////
class CAIGoalInteractionSlave extends CAIGoal
{
	var master				: EntityHandle;	
	var slaveBehaviorName	: name;		
	var initialSpeed		: float;
	var instantStart		: bool;
	
	function Start() : bool
	{
		var owner : CNewNPC;
		owner = GetOwner();
		return owner.StateInteractionSlaveEnter( master, slaveBehaviorName, instantStart, initialSpeed, GetGoalId() );	
	}
};

/////////////////////////////////////////////////////////////////////
// CAIGoalTakedown
/////////////////////////////////////////////////////////////////////
class CAIGoalTakedown extends CAIGoal
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateTakedownEntry( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalTakedownObserve
/////////////////////////////////////////////////////////////////////
class CAIGoalTakedownObserve extends CAIGoal
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateTakedownObserve( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalBehavior
/////////////////////////////////////////////////////////////////////
class CAIGoalBehavior extends CAIGoalSavable
{
	saved var behaviorName : name;

	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		return owner.StateBehavior( behaviorName, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalCriticalEffect
/////////////////////////////////////////////////////////////////////
class CAIGoalCriticalEffect extends CAIGoal
{
	var inCombat : bool;
}

/////////////////////////////////////////////////////////////////////
// CAIGoalBurn
/////////////////////////////////////////////////////////////////////
class CAIGoalBurn extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateBurn( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalIncapacitate
/////////////////////////////////////////////////////////////////////
class CAIGoalIncapacitate extends CAIGoalCriticalEffect
{
	var duration : float;
	var wandering : bool;
	
	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		return owner.StateIncapacitated( duration, wandering, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalKnockdown
/////////////////////////////////////////////////////////////////////
class CAIGoalKnockdown extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		return owner.StateKnockdown( GetGoalId(), inCombat );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalFalter
/////////////////////////////////////////////////////////////////////
class CAIGoalFalter extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = GetOwner();
		return owner.StateFalter( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalBlind
/////////////////////////////////////////////////////////////////////
class CAIGoalBlind extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateBlind( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalUnbalance
/////////////////////////////////////////////////////////////////////
class CAIGoalUnbalance extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateUnbalance( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalDisorientation
/////////////////////////////////////////////////////////////////////
class CAIGoalDrunk extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		//return owner.StateDrunk( GetGoalId() );
		return true;
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalStun
/////////////////////////////////////////////////////////////////////
class CAIGoalStun extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateStun( GetGoalId(), inCombat );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalImmobile
/////////////////////////////////////////////////////////////////////
class CAIGoalImmobile extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateImmobile( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalFear
/////////////////////////////////////////////////////////////////////
class CAIGoalFear extends CAIGoalCriticalEffect
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateFear( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalGuardWithReaction
/////////////////////////////////////////////////////////////////////
class CAIGoalGuardWithReaction extends CAIGoalSavable
{
	saved var left : bool;

	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.SetGuardingStateAware( left, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalKeepAwayFromScene
/////////////////////////////////////////////////////////////////////
class CAIGoalKeepAwayFromScene extends CAIGoal
{
	var sceneCenter : Vector;
	var sceneRadius : float;

	function Start() : bool
	{
		var owner : W2Monster;
		owner = (W2Monster)GetOwner();
		if ( owner )
		{
			return owner.StateKeepAwayFromScene( GetGoalId(), sceneCenter, sceneRadius );
		}
		else
		{
			return false;
		}
	}
}
/////////////////////////////////////////////////////////////////////
// CAIGoalQuestActing
/////////////////////////////////////////////////////////////////////
import class CAIGoalQuestActing extends CAIGoal
{
	import var actions 		: array< IActorLatentAction >;
	import var focusedNode	: CNode;
	
	function Start() : bool
	{		
		var owner : CNewNPC = owner = GetOwner();		
		var focusedHandle : EntityHandle;
		EntityHandleSet( focusedHandle, (CEntity)focusedNode );
		return owner.StateActing( actions, focusedHandle, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalAttractedByLure
/////////////////////////////////////////////////////////////////////
class CAIGoalAttractedByLure extends CAIGoalSavable
{
	saved var lure : EntityHandle;
	
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateAttractedByLure( lure, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalAttractedByLure
/////////////////////////////////////////////////////////////////////
class CAIGoalTalk extends CAIGoalSavable
{	
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateTalk( GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalUseDevice
/////////////////////////////////////////////////////////////////////
class CAIGoalUseDevice extends CAIGoalSavable
{	
	saved var device : EntityHandle;
	
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		return owner.StateUseDevice( device, GetGoalId() );
	}
}

/////////////////////////////////////////////////////////////////////
// CAIGoalAddGetWorkItem
/////////////////////////////////////////////////////////////////////
class CAIGoalGetWorkItem extends CAIGoalSavable
{
	saved var take_item : bool;

	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		var worker : W2Worker;
		
		worker = (W2Worker)owner;
		
		if( take_item )
		{
			return worker.PickUpTool( GetGoalId() );
		}
		else 
		{
			return worker.PutDownTool( GetGoalId() );
		}
	}
}
/////////////////////////////////////////////////////////////////////
//CAIGoalHandleCityLights
/////////////////////////////////////////////////////////////////////
class CAIGoalHandleCityLights extends CAIGoalSavable
{
	function Start() : bool
	{
		var owner : CNewNPC = owner = GetOwner();
		var keeper : W2LightsKeeper;
		
		keeper = (W2LightsKeeper)owner;
		
		return keeper.StartWorking( GetGoalId() );
	}
}
