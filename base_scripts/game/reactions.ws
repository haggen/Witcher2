/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for Reactions
/** Copyright © 2009
/***********************************************************************/

enum W2BehaviorReactions
{
	RA_RainCover01,
	RA_RainCover02,
};


////////////////////////////////////////////////////////////////////////

struct SNodeReserveEntry
{
	var node : CNode;
	var time : float;
	var npc  : CNewNPC;
}

import class CReactionsManager
{
	private var reservedNodes : array<SNodeReserveEntry>;

	// Broadcasts a static interest point to the interested actors
	import final function BroadcastStaticInterestPoint( interestPoint : CInterestPoint, position : Vector, optional timeout : float );
	
	// Broadcasts a dynamic interest point to the interested actors
	import final function BroadcastDynamicInterestPoint( interestPoint : CInterestPoint, node : CNode, optional timeout : float );
	
	// Sends a static interest point to the interested actors
	import final function SendStaticInterestPoint( target : CNewNPC, interestPoint : CInterestPoint, position : Vector, optional timeout : float );
	
	// Sends a dynamic interest point to the interested actors
	import final function SendDynamicInterestPoint( target : CNewNPC, interestPoint : CInterestPoint, node : CNode, optional timeout : float );
	
	// Is rain active
	import final function IsRainActive() : bool;
	
	// Debug force rain
	import final function DebugForceRain() : bool;
	
	public function IsNodeReserved( node : CNode, npc : CNewNPC ) : bool
	{
		var i : int;
		for( i = reservedNodes.Size() - 1; i>=0; i-=1 )
		{
			if( reservedNodes[i].node == node )
			{
				if( theGame.GetEngineTime() < reservedNodes[i].time )
				{
					if( reservedNodes[i].npc != npc )
					{
						return true;
					}
				}
			}
		}
		return false;
	}
	
	public function ReserveNode( node : CNode, time : float, npc : CNewNPC )
	{
		var i : int;
		var reserveTime : float = EngineTimeToFloat( theGame.GetEngineTime() + time );
		
		UpdateReserved();
		
		for( i = reservedNodes.Size() - 1; i>=0; i-=1 )
		{
			if( reservedNodes[i].node == node )
			{
				reservedNodes[i].time = reserveTime;
				reservedNodes[i].npc = npc;
				return;
			}
		}
		
		reservedNodes.PushBack( SNodeReserveEntry( node, reserveTime, npc ) );		
	}
	
	private function UpdateReserved()
	{
		var i : int;
		var currentTime : EngineTime = theGame.GetEngineTime();
		for( i = reservedNodes.Size() - 1; i>=0; i-=1 )
		{
			if( !reservedNodes[i].node )
			{
				reservedNodes.Erase(i);
				continue;
			}
			
			if( currentTime > reservedNodes[i].time )
			{
				reservedNodes.Erase(i);
				continue;
			}
			
			if( !reservedNodes[i].npc )
			{
				reservedNodes.Erase(i);
				continue;
			}			
		}	
	}
}

////////////////////////////////////////////////////////////////////////

// An interest point definition. Interest points have a feature of 'being interesting'
// to NPCs which contain a reaction to the field the point is emitting.
import class CInterestPoint
{	
};

////////////////////////////////////////////////////////////////////////

// An instance of the interest point, located somewhere in the game world.
import class CInterestPointInstance
{
	// Returns the parent point of this instance
	import final function GetParentPoint() : CInterestPoint;
	
	// Returns the present world position of the interest point instance
	import final function GetWorldPosition() : Vector;
	
	// Returns the node the point is attached to (if there's one)
	import final function GetNode() : CNode;
	
	// Returns the name of the field the point emits
	import final function GetGeneratedFieldName() : name;
	
};

////////////////////////////////////////////////////////////////////////
// A reaction one can define in scripts
import class CReactionScript extends IReactionAction
{
	editable var timeout : float;	
	editable var exitWorkMode : EExitWorkMode;
	editable var staticPosition : bool;
	
	default exitWorkMode = EWM_Exit;
	
	// Custom test
	function StartTest( npc : CNewNPC, interestPoint : CInterestPointInstance ) : bool { return true; }

	function Perform( npc : CNewNPC, interestPoint : CInterestPointInstance, reactionIndex, priorityValue : int )
	{		
		if( StartTest( npc, interestPoint ) )
		{
			npc.GetArbitrator().AddGoalReaction(reactionIndex, interestPoint, staticPosition, timeout, AIP_Custom, priorityValue );	
		}
	}
		
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef ) {}
	
	// Passed from reaction state
	event OnAnimEvent( npc : CNewNPC, animEventName : name, animEventTime : float, animEventType : EAnimationEventType );
	
	// Passed from reaction state
	event OnPushed( npc : CNewNPC, pusher : CMovingAgentComponent )
	{
		npc.PushAway( pusher );
	}
};

////////////////////////////////////////////////////////////////////////
// Tree reaction
enum EReactionBehaviorTree
{
	RBT_WalkToSource,
	RBT_RunToSource,
	RBT_Q002GuardAlarmed,
	RBT_Q002GuardBack,
	RBT_Q103RunToSource,
};

class CReactionTree extends CReactionScript
{
	editable var reactionTree : EReactionBehaviorTree;
	editable var processOnce : bool;	
	editable var canBePushed : bool;
	
	default canBePushed = true;
	default processOnce = true;	

	function Perform( npc : CNewNPC, interestPoint : CInterestPointInstance, reactionIndex, priorityValue : int )
	{
		var treeAlias : string = GetTreeAlias();				
		if( treeAlias != "" )
		{
			
			if( StartTest( npc, interestPoint ) )
			{
				npc.GetArbitrator().AddGoalReactionTree( treeAlias, interestPoint, staticPosition, processOnce, timeout, AIP_Custom, priorityValue, exitWorkMode, canBePushed );			
			}
		}		
	}
	
	function GetTreeAlias() : string
	{
		if( reactionTree == RBT_WalkToSource )
			return "behtree\reactions\walk_to_source";		
		else if( reactionTree == RBT_RunToSource )
			return "behtree\reactions\run_to_source";		
		else if( reactionTree == RBT_Q002GuardAlarmed )
			return "behtree\reactions\q002_guard_alarmed";
		else if( reactionTree == RBT_Q002GuardBack )
			return "behtree\reactions\q002_guard_back";
		else if( reactionTree == RBT_Q103RunToSource )
			return "behtree\reactions\q103_run_to_source_and_shout";			
		else
		{
			Logf("ERROR CReactionTree unknown reactionTree: %1", reactionTree);		
			return "";
		}
	}
};

////////////////////////////////////////////////////////////////////////
// Run to waypoint
class CReactionRunToWaypoint extends CReactionScript
{
	editable var moveType : EMoveType;	
	editable var waypointTag : name;
	editable var reserve : bool;
	
	default moveType = MT_Run;
	
	latent function BeforeMove( npc : CNewNPC ) : bool {}
	latent function AfterMove( npc : CNewNPC ) : bool {}
	latent function NoMove( npc : CNewNPC ) : bool {}
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{	
		var node : CNode;
		if( IsNameValid( waypointTag ) )
		{			
			node = SelectNode( npc );			
			if( node )
			{
				if( VecDistance( node.GetWorldPosition(), npc.GetWorldPosition() ) > 1.0 )
				{
					BeforeMove( npc );
					npc.ActionMoveToNodeWithHeading( node, moveType, 1.0, 2.0 );
					AfterMove( npc );
				}
				else
				{	
					NoMove( npc );				
				}

				Sleep(0.5);
			}
			else
			{
				npc.SetErrorStatef( "CReactionRunToWaypoint no waypoint '%1'", waypointTag );
			}
		}
		else
		{
			npc.SetErrorState( "CReactionRunToWaypoint no waypoint defined" );
		}
	}
		
	function SelectNode( npc : CNewNPC ) : CNode
	{
		var nodes : array<CNode>;
		var node : CNode;
		var i,s : int; 
		
		theGame.GetNodesByTag( waypointTag, nodes );		
		s = nodes.Size();
		if( s > 0 )
		{
			if( reserve )
			{
				SortNodesByDistance( npc.GetWorldPosition(), nodes );				
				for( i=0; i<s; i+=1 )
				{
					node = nodes[i];
					if( !theGame.GetReactionsMgr().IsNodeReserved( node, npc ) )
					{
						theGame.GetReactionsMgr().ReserveNode( node, 10.0, npc );
						return node;
					}
				}
				
				return nodes[0];
			}
			else
			{
				return FindClosestNode( npc.GetWorldPosition(), nodes );
			}			
		}		
		
		return NULL;
	}
};

////////////////////////////////////////////////////////////////////////
// Run to waypoint
class CReactionMoveToWaypointPlayAnimations extends CReactionRunToWaypoint
{
	editable var animationsAtStart : array<name>;
	editable var animationsAtEnd : array<name>;
	
	latent function BeforeMove( npc : CNewNPC ) : bool { PlayStartAnimation( npc ); }
	latent function AfterMove( npc : CNewNPC ) : bool { PlayEndAnimation( npc ); }
	latent function NoMove( npc : CNewNPC ) : bool { PlayEndAnimation( npc ); }	
	
	latent function PlayStartAnimation( npc : CNewNPC ) : bool
	{
		var i : int;
		var s : int = animationsAtStart.Size();
		var anim : name;
		var res : bool;
		if( s > 0 )
		{
			i = Rand( s );
			anim = animationsAtStart[i];
			res = npc.ActionPlaySlotAnimation( 'REACTION_SLOT', anim );			
		}
		
		return res;
	}
	
	latent function PlayEndAnimation( npc : CNewNPC ) : bool
	{
		var i : int;
		var s : int = animationsAtEnd.Size();
		var anim : name;
		var res : bool;
		if( s > 0 )
		{
			i = Rand( s );
			anim = animationsAtEnd[i];
			res = npc.ActionPlaySlotAnimation( 'REACTION_SLOT', anim );			
		}
		
		return res;
	}
}

////////////////////////////////////////////////////////////////////////
// Rain reaction
class CReactionRain extends CReactionRunToWaypoint
{
	editable var voicesets : array<string>;
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{	
		var node : CNode;
		var lastVoiceset : int;
		var vs : int = voicesets.Size();
		var pos : Vector;
		var nextSpeakTime : EngineTime;
		
		if( IsNameValid( waypointTag ) )
		{			
			node = SelectNode( npc );
			if( !node )
			{
				npc.SetErrorStatef( "CReactionRain no waypoint '%1'", waypointTag );
				Sleep(1.0);
				return;
			}
		}
		else
		{
			npc.SetErrorState( "CReactionRain no waypoint defined" );
			Sleep(1.0);
			return;
		}
					
		npc.SetFocusedNode( node );
		
		while( theGame.GetReactionsMgr().IsRainActive() )
		{				
			if( npc.GetRainReactionTime() == 0.0 )
			{								
				// emergency start move
				npc.ActionMoveToNodeWithHeading( npc.GetFocusedNode(), MT_Run, 1.0, 5.0, MFA_REPLAN );
			}
			
			if( vs > 0 ) 
			{
				if( theGame.GetEngineTime() > nextSpeakTime )
				{
					lastVoiceset = RandDifferent( vs, lastVoiceset );
					npc.PlayVoiceset(100, voicesets[lastVoiceset] );
					npc.WaitForEndOfSpeach();
					nextSpeakTime = theGame.GetEngineTime() + RandRangeF( 10.0f, 15.0f );
				}
			}
			Sleep( 0.5f );
		}
	}
}

////////////////////////////////////////////////////////////////////////
// Rotate to reaction
class CReactionRotateTo extends CReactionScript
{
	editable var rotationTime : float;
	editable var minWaitTime : float;
	editable var maxWaitTime : float;
	
	default rotationTime = 0.2;
	default minWaitTime = 2.5;
	default maxWaitTime = 3.5;
	
	function StartTest( npc : CNewNPC, interestPoint : CInterestPointInstance ) : bool
	{
		return !npc.IsRotatedTowardsPoint( interestPoint.GetWorldPosition(), 10.0f );
	}

	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var pos : Vector = PersistentRefGetWorldPosition( interestPoint );
		var t : float = RandRangeF( minWaitTime, maxWaitTime );
		
		npc.RotateTo( pos, 0.5 );
		//npc.ActionRotateTo( pos );
		Sleep(t);
	}
};

////////////////////////////////////////////////////////////////////////
// Play slot animation
class CReactionPlaySlotAnimation extends CReactionScript
{
	editable var animation : name;

	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		npc.ChangeNpcExplorationBehavior();
		npc.ActionPlaySlotAnimation( 'REACTION_SLOT', animation );
	}
};

////////////////////////////////////////////////////////////////////////
// Q207 reaction
class CQ207GuardSeesGeralt extends CReactionScript
{
	editable var voicesetName	: string;
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{		
		FactsAdd('q207_GeraltCatched', 1);
		npc.PlayVoiceset( 100, voicesetName );
	}
}	
///////////////////////////////////////////////////////////////////////////
// Community Script - Walk to waypoint and play random slot animation	

class CReactionGoToIntrestPointAndReact extends CReactionScript
{
	editable var moveType : EMoveType;	
	editable var waypointTag : name;
	editable var reactionTimeDelay : float;
	var random_anim : int;
	
	default moveType = MT_Walk;
	default reactionTimeDelay = 5.0f;

	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var waypoint : CNode;
	
		if( IsNameValid( waypointTag ) )
		{
			waypoint = theGame.GetNodeByTag( waypointTag );
			if( waypoint )
			{
				npc.ActionMoveToNode( waypoint, moveType, 1.0, 2.0 );
			}
			else
			{
				npc.SetErrorStatef( "CReactionRunToWaypoint no waypoint '%1'", waypointTag );
			}
		}
		else
		{
			npc.SetErrorState( "CReactionRunToWaypoint no waypoint defined" );
		}
		Sleep(reactionTimeDelay);
		
		npc.ChangeNpcExplorationBehavior();
		
		random_anim = CeilF( RandRangeF(1.f,6.f) );
		
		if ( random_anim == 1 )
		{
			// reakcja neutralna - wzruszenie ramionami
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest03_02'  );
		}
		if ( random_anim == 2 )
		{
			// reakcja pozytywna - brawo
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest60_bravo' );
		}	
		if ( random_anim == 3 )
		{
			// reakcja negatywna - odejscie i powrot
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest52l' );
		}
		if ( random_anim == 4 )
		{
			// reakcja niezdecydowana - dlon na brodzie i zaduma
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest31r'  );
		}
		if ( random_anim == 5 )
		{
			// reakcja pozytywna - przytakniecie
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest05_yes'  );	
		}				
		if ( random_anim == 6 )
		{
			// reakcja niezdecydowana - uniesione rece
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'D_StandNeutral01__dialog_gest10'  );
		}	
	}
}

/////////////////////////////////////////////////////////////////////////////
//	New reactions on new moving agent system
/////////////////////////////////////////////////////////////////////////////

// Run away reaction
class CMoveTRGRunAway extends CMoveTRGScript
{
	var speed : float;
	var maxDist : float;
	var targetEnt : CEntity;
	var rRes	: RunResult;
	
	private var target : Vector;
	
	final function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var dir		: Vector;
		var heading : float;
		var currPos	: Vector;
		var dist	: float;
		var modifiedSpeed : float;
		var a : float;
		
		modifiedSpeed = speed;
		
		currPos = agent.GetAgentPosition();
		dir = currPos - targetEnt.GetWorldPosition();
		dist = VecLength( dir );
		dir = VecNormalize2D( dir );
		
		if ( dist > maxDist )
		{
			target = currPos;
			heading = VecHeading(dir) + 180;
			SetOrientationGoal( goal, heading );
			SetSpeedGoal( goal, 0.0f );
			rRes.isAtSafeDistance = true;
			rRes.blockedByCollision = false;
			
			a = agent.GetHeading();
			if( a < 0 )
				a += 360;
			else if( a > 360 )
				a -= 360;
				
			if( heading < 0 )
				heading += 360;
			else if( heading > 360 )
				heading -= 360;
			
			if( AbsF( heading - a ) < 5 )
				SetFulfilled( goal, true );
			else
				SetFulfilled( goal, false );
		}
		else
		{
			rRes.isAtSafeDistance = false;
			rRes.blockedByCollision = false;
			
			/*
			actor = (CActor)agent.GetEntity();
			actor.GetVisualDebug().AddLine( 'dbgFleeDirection', currPos, currPos + dir * 2, true, Color( 255, 0, 0 ) );
			actor.GetVisualDebug().AddSphere( 'dbgELNMPFleeDirection', 0.3f, currPos + dir * 2, true, Color( 255, 0, 0 ) );
			actor.GetVisualDebug().AddLine( 'dbgVelocity', currPos, currPos + realDirection * 2, true, Color( 0, 0, 255 ) );
			actor.GetVisualDebug().AddSphere( 'dbgELNMPVel', 0.3f, currPos + realDirection * 2, true, Color( 0, 0, 255 ) );
			*/
			
			if( !agent.CanGoStraightToDestination( currPos + dir * 2 ) )
			{
				target = currPos;
				modifiedSpeed = 0.0f;
				heading = VecHeading(dir) + 180;
				SetOrientationGoal( goal, heading );
				
				rRes.blockedByCollision = true;
				
				a = agent.GetHeading();
				if( a < 0 )
					a += 360;
				else if( a > 360 )
					a -= 360;
					
				if( heading < 0 )
					heading += 360;
				else if( heading > 360 )
					heading -= 360;
				
				if( AbsF( heading - a ) < 5 )
					SetFulfilled( goal, true );
				else
					SetFulfilled( goal, false );
			}
			else
			{
				SetFulfilled( goal, false );
				SetOrientationGoal( goal, VecHeading(dir) );
				target = currPos + dir * 2;
			}
			
			SetSpeedGoal( goal, modifiedSpeed );
		}
		SetHeadingGoal( goal, dir );
	}
}

class RunResult extends CObject
{
	var isAtSafeDistance : bool;
	var blockedByCollision : bool;
}

class CReactionRunAway extends CReactionScript
{
	editable var moveSpeed : float;
	editable var safeDistance : float;
	editable var voiceset : string;
	editable var MaxAnimationDelay : float;
	editable var isSoldier : bool;
	var delay : float;
	
	private var res : bool;
	private var rRes : RunResult;
	private var animation : name;
	
	default moveSpeed = 5.0f;
	default safeDistance = 10.0f;
	default MaxAnimationDelay = 1.5f;
	default isSoldier = false;

	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var tgrScript : CMoveTRGRunAway;
		var mac : CMovingAgentComponent = npc.GetMovingAgentComponent();
		var isVisible : bool;
		var rand : int;
		
		rRes = new RunResult in this;
		mac.SetMoveType( MT_Run );
		
		if( !npc.IsRotatedTowards( PersistentRefGetEntity( interestPoint ) ) )
		{
			npc.ActionRotateToAsync( PersistentRefGetWorldPosition( interestPoint ) );
			Sleep( 0.5f );
		}
		
		while( true )
		{
			while( VecDistance( npc.GetWorldPosition(), PersistentRefGetWorldPosition(interestPoint) ) < safeDistance )
			{
				tgrScript = new CMoveTRGRunAway in npc;
				tgrScript.speed = moveSpeed;
				tgrScript.maxDist = safeDistance;
				tgrScript.targetEnt = PersistentRefGetEntity( interestPoint );
				tgrScript.rRes = rRes;
				npc.ActionMoveCustom(tgrScript);
				
				//That should be changed!!!!!!!!!! NPC can run away not only from Geralt!!!!!!!
				if( PersistentRefGetEntity( interestPoint ) == thePlayer )
				{
					if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) )
						break;
				}
				
				if( !rRes.isAtSafeDistance && rRes.blockedByCollision )
				{
					if( npc.IsMan() )
					{
						if( isSoldier )
						{
							rand = Rand( 5 );
							
							if( rand == 0 )
							{
								animation = 'D_StandAgressive01__dialog_gest42r';
							}	
							else if( rand == 1 )
							{
								animation = 'D_StandAgressive01__dialog_gest40';
							}
							else if( rand == 2 )
							{
								animation = 'D_StandAgressive01__dialog_gest45';
							}
							else if( rand == 3 )
							{
								animation = 'D_StandAgressive01__dialog_gest43r';
							}
							else if( rand == 4 )
							{
								animation = 'D_StandAgressive01__dialog_gest41';
							}	
						}
						else
						{
							animation = 'rct_fright_afraid_01';
						}	
					}
					else if( npc.IsWoman() )
					{
						animation = 'work_fear';
					}
					else if( npc.IsDwarf() )
					{
						animation = 'reaction_hostility_warning_01';
					}
					else if( npc.IsChild() )
					{
						animation = 'work_frightened';
					}
					delay = RandRangeF(0, MaxAnimationDelay );
					npc.ChangeNpcExplorationBehavior();
					Sleep( delay );
					npc.PlayVoiceset( 100, voiceset );
					npc.ActionPlaySlotAnimation( 'REACTION_SLOT', animation, 0.2f, 0.2f );
				}
				else
				{
					Sleep( 1.0f );
				}
			}
			
			isVisible = npc.VisibilityTest( VT_LineOfSight, PersistentRefGetEntity( interestPoint ) );
			if( !isVisible )
			{
				break;
			}
			//That should be changed!!!!!!!!!! NPC can run away not only from Geralt!!!!!!!
			else if( PersistentRefGetEntity( interestPoint ) == thePlayer )
			{
				if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) )
					break;
			}
			else
				break;
			
			npc.ActionRotateToAsync( PersistentRefGetWorldPosition( interestPoint ) );
			Sleep( 1.0f );
		}
	}
	
	// Passed from reaction state
	event OnPushed( npc : CNewNPC, pusher : CMovingAgentComponent )
	{
		// we don't want NPCs to be pushable when they are running away
	}
};

// Monster??
/*class CReactionMonster extends CReactionScript
{
	function StartTest( npc : CNewNPC, interestPoint : CInterestPointInstance ) : bool
	{
		if( interestPoint.GetNode().IsA( 'CActor' ) )
		{
			return ((CActor)interestPoint.GetNode()).IsAlive();
		}
		
		return false;
	}
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		Log( "monster" );
	}
}*/

// Warn and attack reaction
class CMoveTRGFollow extends CMoveTRGScript
{
	var speed : float;
	var minDist : float;
	var maxDist : float;
	var stopOnTargetReached : bool;
	var fRes	: FollowResult;
	var targetEnt : CEntity;
	
	private var lastValidPosition : Vector;
	private var target : Vector;
	
	final function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var currPos : Vector;
		var heading : Vector;
		var dir		: Vector;
		var dist	: float;
		
		currPos = agent.GetAgentPosition();
		target = targetEnt.GetWorldPosition();
		dir = target - currPos;
		
		SetOrientationGoal( goal, VecHeading(dir) );
		SetHeadingGoal( goal, dir );
		
		dist = VecLength( currPos - target );
		if( dist < minDist )
		{
			if( stopOnTargetReached )
			{
				fRes.SetTargetReached( true );
				target = currPos;
				SetFulfilled( goal, true );
			}
			else
				SetFulfilled( goal, false );
				
			SetSpeedGoal( goal, 0.0f );
		}
		else if( dist > maxDist )
		{
			fRes.SetTargetLost( true );
			target = currPos;
			SetSpeedGoal( goal, 0.0f );
			SetFulfilled( goal, true );
		}
		else if( agent.IsEndOfLinePositionValid( target ) )
		{
			lastValidPosition = target;
			SetSpeedGoal( goal, speed );
			SetFulfilled( goal, false );
		}
		else
		{
			if( VecLength( lastValidPosition ) == 0 )
			{
				fRes.SetFailedAtBeginning( true );
				SetFulfilled( goal, true );
				lastValidPosition = currPos;
			}
			
			target = lastValidPosition;
			dist = VecLength( currPos - target );
			if( dist < 0.5f )
			{
				fRes.SetTargetLost( true );
				target = currPos;
				SetSpeedGoal( goal, 0.0f );
				SetFulfilled( goal, true );
			}
			else
			{
				SetSpeedGoal( goal, speed );
				SetFulfilled( goal, false );
			}
		}
	}
}

class FollowResult extends CObject
{
	private var targetReached : bool;
	private var targetLost : bool;
	private var failedAtBeginning : bool;
	
	function SetTargetReached( isReached : bool )
	{
		targetReached = isReached;
	}
	
	function IsTargetReached() : bool
	{
		return targetReached;
	}
	
	function SetTargetLost( isLost : bool )
	{
		targetLost = isLost;
	}
	
	function IsTargetLost() : bool
	{
		return targetLost;
	}
	
	function SetFailedAtBeginning( hasFailed : bool )
	{
		failedAtBeginning = hasFailed;
	}
	
	function HasFailedAtBeginning() : bool
	{
		return failedAtBeginning;
	}
	
	function Reset()
	{
		targetReached = false;
		targetLost = false;
		failedAtBeginning = false;
	}
}

class CReactionWarnAndAttack extends CReactionScript
{
	editable var warningVoiceset : string;
	editable var endVoiceset : string;
	editable var attackVoiceset : string;
	editable var warningTime : float;
	editable var forgetDistance : float;
	
	default warningTime = 10.0f;
	default forgetDistance = 15.0f;
	
	private var followTimeout : float;
	private var warningDistance : float;
	
	default followTimeout = 20.0f;
	default warningDistance = 5.0f;
	
	function StartTest( npc : CNewNPC, interestPoint : CInterestPointInstance ) : bool
	{
		if(	!thePlayer.IsInCombat() && !thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) && FactsQuerySum('act1_police_off') == 0 )
		{
			thePlayer.KeepCombatMode();
			return true;
		}
		else
			return false;
	}
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var totalTime : float = 0.f;
		var wasWarned : bool;
		
		theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "HideTheSword" ));
		npc.AddTimer('TimerKeepPlayerCombatMode', 1.0, true);
		
		if( npc.GetNpcPrimaryCombatType() == CT_Sword || npc.GetNpcPrimaryCombatType() == CT_Sword_Skilled )
		{
			npc.ActivateAndSyncBehavior( 'npc_sword' );
			npc.IssueRequiredItems( 'None', 'opponent_weapon' );
		}
		else if ( npc.GetNpcPrimaryCombatType() == CT_Halberd )
		{
			npc.ActivateAndSyncBehavior( 'npc_polearm' );
			npc.IssueRequiredItems( 'None', 'opponent_weapon_polearm' );
		}
		/*
		else if ( npc.GetNpcPrimaryCombatType() == CT_Bow )
		{
			npc.ActivateAndSyncBehavior( 'npc_bow' );
			npc.IssueRequiredItems( 'None', 'opponent_bow' );
		}
		*/
		npc.RaiseForceEvent('Idle');

		while( true )
		{
			//After initialization we try to reach our target
			npc.ActionMoveToDynamicNodeAsync( thePlayer, MT_Run, 5.0f, 2.0f, true, MFA_REPLAN );
			
			//While moving check for quiting conditions
			while( npc.IsMoving() )
			{
				//First of all we check if player still holds a sword.
				if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) )
				{
					npc.PlayVoiceset( 100, endVoiceset );
					return;
				}
				
				//The guard is close enough to warn us.
				if( !wasWarned && VecLength( thePlayer.GetWorldPosition() - npc.GetWorldPosition() ) < warningDistance )
				{
					npc.PlayVoiceset( 100, warningVoiceset );
					wasWarned = true;
					totalTime = 0.f;
				}
				//We got out of following range, stop chasing.
				else if( VecLength( thePlayer.GetWorldPosition() - npc.GetWorldPosition() ) > forgetDistance )
				{
					return;
				}
				
				//The guard was following us for too long without warning, just stop chasing.
				if( !wasWarned && totalTime > followTimeout )
				{
					return;
				}
				
				//The guard warned us and we didn't listen. Enter combat!
				if( wasWarned && totalTime > warningTime )
				{
					npc.PlayVoiceset( 100, attackVoiceset );
					thePlayer.SetGuardsHostile( true );
					
					return;
				}
				
				Sleep( 0.5f );
				totalTime += 0.5f;
			}
		}
	}
}

// Play animation and voiceset toward interest point
class CPushedReaction extends CReactionScript
{
	editable var animation : name;
	editable var voiceset : string;
	editable var usePredefinedAnim : bool;
	
	default usePredefinedAnim = true;
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		npc.WaitForBehaviorNodeDeactivation( 'PushEnded', 3.0f );
		
		npc.ActionRotateTo( PersistentRefGetWorldPosition( interestPoint ) );
		
		npc.PlayVoiceset( 100, voiceset );
		
		if( usePredefinedAnim == true )
		{
			if( npc.IsMan() )
			{
				animation = 'rct_salute_split_02';
			}
			else if( npc.IsWoman() )
			{
				animation = 'D_StandNeutral01__dialog_gest29l';
			}
			else if( npc.IsDwarf() )
			{
				animation = 'D_StandNeutral01__dialog_gest10';
			}
		}
		else
		{
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', animation );
		}	
	}
	
	event OnPushed( npc : CNewNPC, pusher : CMovingAgentComponent )
	{
		// do nothing - NPCs can't be pushed in this state - because they already
		// have been pushed
	}
}

// Just follow reaction
class CFollowReaction extends CReactionScript
{
	editable var forgetDistance : float;
	default forgetDistance = 15.0f;
	
	private var fRes : FollowResult;
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var tgrScript : CMoveTRGFollow;
		var res : bool;
		
		fRes = new FollowResult in this;
		
		while( !res )
		{
			tgrScript = GenerateNewMoveTRG( npc, PersistentRefGetEntity(interestPoint) );
			res = npc.ActionMoveCustom( tgrScript );
		}
		
		if( fRes.HasFailedAtBeginning() )
		{
			while( !npc.GetMovingAgentComponent().IsEndOfLinePositionValid( PersistentRefGetWorldPosition(interestPoint) ) )
			{
				npc.ActionMoveToAsync( PersistentRefGetWorldPosition(interestPoint), MT_Run, 5.0f, 2.0f, MFA_EXIT );
				Sleep( 0.5 );
				if( VecLength( PersistentRefGetWorldPosition(interestPoint) - npc.GetWorldPosition() ) > forgetDistance )
				{
					return;
				}
			}
			
			res = false;
			while( !res )
			{
				tgrScript = GenerateNewMoveTRG( npc, PersistentRefGetEntity(interestPoint) );
				res = npc.ActionMoveCustom( tgrScript );
			}
		}
	}
	
	function GenerateNewMoveTRG( npc : CNewNPC, target : CEntity, optional stopOnTargetReached : bool ) : CMoveTRGFollow
	{
		var tgrScript : CMoveTRGFollow;
		
		tgrScript = new CMoveTRGFollow in npc;
		tgrScript.speed = 5.0f;
		tgrScript.minDist = 3.0f;
		tgrScript.maxDist = forgetDistance;
		tgrScript.stopOnTargetReached = stopOnTargetReached;
		tgrScript.targetEnt = target;
		
		fRes.Reset();
		tgrScript.fRes = fRes;
		
		return tgrScript;
	}
}

////////////////////////////////////////////////////////////////////////
// Play animation of trembling in fear
class CReactionCowerInFear extends CReactionScript
{
	var animation : name;
	editable var MaxAnimationDelay : float;
	var delay : float;
	var rand : int;
	editable var isSoldier : bool;
	
	default MaxAnimationDelay = 1.5f;
	default isSoldier = false;

	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		if( npc.IsMan() )
		{
			if( isSoldier )
			{
				rand = Rand( 5 );
				
				if( rand == 0 )
				{
					animation = 'D_StandAgressive01__dialog_gest42r';
				}	
				else if( rand == 1 )
				{
					animation = 'D_StandAgressive01__dialog_gest40';
				}
				else if( rand == 2 )
				{
					animation = 'D_StandAgressive01__dialog_gest45';
				}
				else if( rand == 3 )
				{
					animation = 'D_StandAgressive01__dialog_gest43r';
				}
				else if( rand == 4 )
				{
					animation = 'D_StandAgressive01__dialog_gest41';
				}	
			}
			else
			{
				animation = 'rct_fright_afraid_01';
			}
		}
		else if( npc.IsWoman() )
		{
			animation = 'work_fear';
		}
		else if( npc.IsDwarf() )
		{
			animation = 'reaction_hostility_warning_01';
		}
		else if( npc.IsChild() )
		{
			animation = 'work_frightened';
		}
		delay = RandRangeF(0, MaxAnimationDelay );
		npc.ActionRotateToAsync( PersistentRefGetWorldPosition( interestPoint ) );
		Sleep( delay );
		npc.ActionPlaySlotAnimation( 'REACTION_SLOT', animation, 0.2f, 0.2f );
		npc.PlayVoiceset( 100, "afraid" );
	}
	
	event OnPushed( npc : CNewNPC, pusher : CMovingAgentComponent )
	{
		// we don't want NPCs to be pushable when they are running away
	}
}

class CReactionPickFight extends CReactionScript // used for goon incident only - fistfight provoked by leader of thugs from under crane passage.
{
	editable var tauntVoiceset : string;
	editable var bragVoiceset : string;
	editable var backoffVoiceset : string;
	editable var attackVoiceset : string;
	editable var warningTime : float;
	editable var forgetDistance : float;
	
	default warningTime = 5.0f;
	default forgetDistance = 5.0f;
	
	private var fRes : FollowResult;
	
	latent function DoAction( npc : CNewNPC, interestPoint : PersistentRef )
	{
		var totalTime : float;
		
		var tgrScript : CMoveTRGFollow;
		
		fRes = new FollowResult in this;
		
		if( npc.GetNpcPrimaryCombatType() != CT_Fists )
		{
			return;
		}

		npc.RaiseForceEvent('Idle');

		while( !fRes.IsTargetLost() && !fRes.IsTargetReached() && !fRes.failedAtBeginning )
		{
			tgrScript = GenerateNewMoveTRG( npc, true );
			npc.ActionMoveCustom( tgrScript );
			Sleep( 1.0f );
		}
		
		if( fRes.HasFailedAtBeginning() )
		{
			while( !npc.GetMovingAgentComponent().IsEndOfLinePositionValid( thePlayer.GetWorldPosition() ) )
			{
				npc.ActionMoveToAsync( thePlayer.GetWorldPosition(), MT_Run, 5.0f, 2.0f, MFA_EXIT );
				Sleep( 0.5 );
				if( VecLength( thePlayer.GetWorldPosition() - npc.GetWorldPosition() ) > forgetDistance )
				{
					return;
				}
			}
			
			while( !fRes.IsTargetLost() && !fRes.IsTargetReached() )
			{
				tgrScript = GenerateNewMoveTRG( npc, true );
				npc.ActionMoveCustom( tgrScript );
				Sleep( 1.0f );
			}
		}
		
		if( !fRes.IsTargetReached() )
		{
			return;
		}
		npc.PlayVoiceset(100, tauntVoiceset );
		npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'rct_fierce_02', 0.2f, 0.2f );
		FactsAdd( "no_chatting_while_fistfight", 1);
		
		npc.ActionMoveCustomAsync( GenerateNewMoveTRG( npc ) );

		while( !fRes.IsTargetLost() && totalTime < warningTime )
		{
			if( thePlayer.IsCombatState( thePlayer.GetCurrentPlayerState() ) )
			{
				npc.PlayVoiceset( 100, backoffVoiceset );
				FactsAdd( "witcher_won_fight_with_pier_goon", 1 );
				FactsAdd( "no_chatting_while_fistfight", -1 );
				return;
			}
			
			Sleep( 0.2f );
			totalTime += 0.2f;
		}

		if( fRes.IsTargetLost() )
		{
			npc.PlayVoiceset( 100, bragVoiceset ); 
			npc.ActionPlaySlotAnimation( 'REACTION_SLOT', 'rct_salute_split_03', 0.2f, 0.2f );
			FactsAdd( "no_chatting_while_fistfight", -1 );
			return;
		}
		FactsAdd( "pier_goon_fight_starts", 1);
		npc.PlayVoiceset(100, attackVoiceset );
		Sleep( 4.f );
		theGame.SetGlobalAttitude( 'flotsam_goon_leader', 'player', AIA_Hostile);
	}
	
	function GenerateNewMoveTRG( npc : CNewNPC, optional stopOnTargetReached : bool ) : CMoveTRGFollow
	{
		var tgrScript : CMoveTRGFollow;
		
		tgrScript = new CMoveTRGFollow in npc;
		tgrScript.speed = 10.0f;
		tgrScript.minDist = 3.0f;
		tgrScript.maxDist = forgetDistance;
		tgrScript.stopOnTargetReached = stopOnTargetReached;
		tgrScript.targetEnt = thePlayer;
		
		fRes.Reset();
		tgrScript.fRes = fRes;
		
		return tgrScript;
	}
};


exec function VoiceToPlay( tag : name, voiceset : string )
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( tag );
	npc.PlayVoiceset( 100, voiceset );
}