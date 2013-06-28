/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree Machine Tasks
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// MoveTo
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToTarget extends IBehTreeTask
{
	editable var maxDistance : float;
	editable var moveType : EMoveType;
	editable var useRawPosition : bool;
	
	default maxDistance = 1.0;
	default moveType = MT_Run;

	latent function Main() : EBTNodeStatus
	{
		var target : CNode;
		var npc : CNewNPC;
		var pos, navMeshPos : Vector;
		var res : bool;
		var playerState : EPlayerState;
		
		npc = GetNPC();
		if( useRawPosition )
		{
			pos = npc.GetFocusedPositionRaw();

		}
		else
		{
			pos = GetTargetPosition();
		}
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
		
		
		res = npc.ActionMoveTo( pos, moveType, 1.0, maxDistance, MFA_EXIT );
		if( res )
		{
			return BTNS_Completed;
		}
				
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// PursueTarget 
/////////////////////////////////////////////////////////////////////
class CBTTaskPursueTarget extends IBehTreeTask
{
	editable var moveType : EMoveType;
	editable var minDistance	: float;
	editable var keepDistance	: bool;

	
	//Actor will attept to move until minDistance is reached, but will not move is closer than maxDistance
	default moveType = MT_Run;
	default minDistance = 2.0f;
	default keepDistance = false;

	latent function Main() : EBTNodeStatus
	{
		var target : CNode;
		var npc : CNewNPC;
		var playerState : EPlayerState;
		
		npc = GetNPC();
		target = GetTargetNode();
		
		if(target == thePlayer || npc.GetTarget() == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
				
		npc.ActionMoveToDynamicNode( target, moveType, 5.0f, minDistance, keepDistance, MFA_EXIT );
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// MoveAwayFromTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveAwayFromTarget extends IBehTreeTask
{
	editable var minDistance : float;
	editable var maxDistance : float;
	editable var moveType : EMoveType;
	
	default minDistance = 3.0;
	default maxDistance = 5.0;
	default moveType = MT_Run;

	latent function Main() : EBTNodeStatus
	{
		var node : CNode;
		var pos : Vector;
		var npc : CNewNPC = GetNPC();
		var dist : float;
		var res : bool;
		
		node = GetTargetNode();		
		dist = RandRangeF( minDistance, maxDistance );		
		if( node )
		{
			res = npc.ActionMoveAwayFromNode( node, dist, moveType, 1.0, 2.0, MFA_EXIT );
			if( res )
			{
				return BTNS_Completed;
			}			
		}
		else
		{
			pos = GetTargetPosition();
			res = npc.ActionMoveAwayFromLine( pos, pos+Vector(1,0,0), dist, true, moveType, 2.0, 1.0, MFA_EXIT );
			if( res )
				return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToRandomPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToRandomPosition extends IBehTreeTask
{	
	editable var minDistance : float;
	editable var maxDistance : float;
	editable var minCrossDistance : float;
	
	default minDistance = 3.0;
	default maxDistance = 7.0;
	
	default minCrossDistance = 5.0;

	private var targetPos : Vector;
	
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		var curDist : float;
		var thMin, thMax : float;
		
		npc = GetNPC();		
		target = npc.GetTarget();
		
		targetPos = target.GetPositionOrMoveDestination();
		
		curDist = VecDistance2D( targetPos, npc.GetWorldPosition() );
		
		thMin = MaxF( minDistance - 0.5, 0.0 );
		thMax = maxDistance + 0.5;
		
		if( curDist < thMin  || curDist > thMax ) 
		{
			return BTNS_Active;
		}
		else
		{
			return BTNS_Completed;
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		var npcPos, bestDest, dest, destNavMesh : Vector;
		var bestDist, dist : float;
		var iter : int;
		var mac : CMovingAgentComponent;
		var res : bool;
	
		npc = GetNPC();		
		target = npc.GetTarget();
		
		npcPos = npc.GetWorldPosition();	
		
		mac = npc.GetMovingAgentComponent();
			
		// Selected position should not cross battlefield around target
		
		bestDest = targetPos + VecRingRand( minDistance, maxDistance );		
		bestDist = VecDistanceToEdge( targetPos, npcPos, dest );
		
		iter = 0;
		while ( ( bestDist < minCrossDistance ) && ( iter < 10 ) )
		{					
			dest = targetPos + VecRingRand( minDistance, maxDistance );
			dist = VecDistanceToEdge( targetPos, npcPos, dest );
			
			if( dist > bestDist && mac.GetEndOfLineNavMeshPosition( dest, destNavMesh ) )
			{
				bestDist = dist;
				bestDest = destNavMesh;
			}
			iter += 1;
		}
				
		if( bestDist < minCrossDistance )
		{
			res = npc.ActionMoveAwayFromNode( target, 6.0, MFA_EXIT );
			if( !res )
			{
				return BTNS_Failed;
			}
		}
		else
		{	
			res = npc.ActionMoveTo( bestDest, MT_Run, 1.0, 2.0, MFA_EXIT );
			if( !res )
			{
				return BTNS_Failed;
			}
		}
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToCombatIdlePosition
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToCombatIdlePosition extends IBehTreeTask
{
	private var dest : Vector;	
	
	function OnBegin() : EBTNodeStatus
	{			
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var cs : CCombatSlots = target.GetCombatSlots();
		var res : bool;
		
		res = cs.LoadCombatIdlePosition( npc, true, dest );
		if( res )
		{
			if( VecDistance2D( dest, npc.GetWorldPosition() ) > 2.1 )			
				return BTNS_Active;			
			else			
				return BTNS_Completed;			
		}		
		
		return BTNS_Failed;		
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var cs : CCombatSlots = target.GetCombatSlots();			
		var res : bool;

		do
		{
			if( !npc.ActionMoveToAsync( dest, npc.GetModifiedMoveType( MT_Run ), 1.0, 2.0, MFA_EXIT ) )
			{
				return BTNS_Failed;
			}
			
			Sleep( 1.0 );
			
			res = cs.LoadCombatIdlePosition( npc, false, dest );			
			if( !res )
			{
				return BTNS_Failed;
			}
		}
		while( npc.IsMoving() );
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToSlotBase
/////////////////////////////////////////////////////////////////////
class IBTTaskMoveToSlotBase extends IBehTreeTask
{
	editable var async : bool;
	editable var moveType : EMoveType;
	private var dest : Vector;
		
	default async = true;
	default moveType = MT_Run;
	
	function GetDestination( out outPosition : Vector ) : bool { return false; }
	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();		
		
		if( GetDestination( dest ) )
		{		
			npc.offSlot = OS_None;
						
			if( async )
			{			
				// If already moving to position near destination return completed
				if( npc.IsMoving() && VecDistance2D( npc.GetMoveDestination(), dest ) < 3.0 )
				{
					return BTNS_Completed;
				}
				
				if( npc.ActionMoveToAsync( dest, npc.GetModifiedMoveType( moveType ), 5.0, 0.5, MFA_EXIT ) )
					return BTNS_Completed;
			}
			else
			{
				return BTNS_Active;
			}
		}
		
		return BTNS_Failed;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var res : bool;		
		
		res = npc.ActionMoveTo( dest, npc.GetModifiedMoveType( moveType ), 1.0, 0.5, MFA_EXIT );
		if( res )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
	
	function OnAbort()
	{
		GetActor().ActionCancelAll();
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToSlot extends IBTTaskMoveToSlotBase
{	
	function GetDestination( out outPosition : Vector ) : bool
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();		
		return target.GetCombatSlots().GetCombatSlotNavMeshPositionForActor( npc, outPosition );
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToFarSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToFarSlot extends IBTTaskMoveToSlotBase
{
	editable var randomRadius : float;

	function GetDestination( out outPosition : Vector ) : bool
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var pos, posOffset : Vector;
		var res : bool = target.GetCombatSlots().GetFarSlotNavMeshPositionForActor( npc, pos );
		if( res )
		{
			posOffset = pos + VecRingRandStatic( CalcSeed(npc) + (int)(pos.X), 0.0, randomRadius );
			if( !target.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( posOffset, outPosition ) )
			{
				// fallback
				outPosition = pos;
			}
			
			return true;
		}
		
		return false;
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToSlotShort
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToSlotShort extends IBehTreeTask
{
	editable var maxDistToSlot : float;
	editable var radius : float;
	default maxDistToSlot = 0.7;
	default radius = 0.5;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC;		
		var target : CActor;
		var dist : float;
		var idx, subIdx : int;
		var cs : CCombatSlots;
		var pos : Vector;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( npc.IsRotatedTowards(target) && !npc.InAttackRange( target ) )
		{
			return BTNS_Active;
		}
				
		if( npc.offSlot == OS_None )
		{
			cs = target.GetCombatSlots();
			idx = cs.GetCombatSlotIndex( npc, subIdx );
			if( idx != -1 )
			{
				pos = cs.GetCombatSlotWorldPosition( npc, idx, subIdx );
				if( VecDistance2D( pos, npc.GetWorldPosition() ) > maxDistToSlot )
				{
					return BTNS_Active;
				}
			}
			else
			{
				return BTNS_Failed;
			}
		}
		
		return BTNS_Completed;
	}
				
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var dest : Vector;
		var res : bool;
		var radius : float;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( target.GetCombatSlots().GetCombatSlotNavMeshPositionForActor( npc, dest ) )
		{	
			npc.SetRotationTarget( target );
			res	= npc.ActionMoveTo( dest, MT_Walk, 5.0, radius, MFA_EXIT );
			npc.offSlot = OS_None;
			npc.ClearRotationTarget();
			if( res )
				return BTNS_Completed;			
		}

		return BTNS_Failed;
	}
	
	function OnAbort()
	{
		var npc : CNewNPC;
		npc = GetNPC();
		npc.ActionCancelAll();
		npc.ClearRotationTarget();
	}
}

/////////////////////////////////////////////////////////////////////
// CombatMoveToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskCombatMoveToTarget extends IBehTreeTask
{	
	editable var async : bool;
	editable var moveType : EMoveType;
	editable var offset : float;
	editable var radius : float;
	private var dest : Vector;
	
	default moveType = MT_Walk;
	default offset = 2.0;
	default radius = 1.0;	
	function DrawWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawShield()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_shield', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawSecondaryWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon_secondary', false);
		npc.DrawItemInstant(weapon);
	}
	private function ComputeDestination( out navMeshDest : Vector ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var mac : CMovingAgentComponent = target.GetMovingAgentComponent();
		var cs : CCombatSlots = target.GetCombatSlots();
		var npcPos, targetPos, offsetVec, dest, weightPos : Vector;
		var iter,i,s,c : int;
		var yaw,yaw2 : float;
		var actor : CActor;		
		var rot : EulerAngles;
		
		npcPos = npc.GetWorldPosition();
		targetPos = target.GetWorldPosition();		
		
		if( target.GetCombatSlots().GetNumOccupiedCombatSlots() > 1 )
		{
			s = cs.combatSlots.Size();
			for( i=0; i<s; i+=1 )
			{
				actor = cs.combatSlots[i].actor;
				if( actor && actor != npc )
				{
					weightPos += actor.GetPositionOrMoveDestination();
					c+=1;
				}
			}
			
			weightPos /= c;
			
			offsetVec = weightPos - targetPos;
			offsetVec.Z = 0.0;
			offsetVec = -VecNormalize2D( offsetVec );	
		}
		else
		{
			offsetVec = npcPos - targetPos;
			offsetVec.Z = 0.0;
			offsetVec = VecNormalize2D( offsetVec );		
		}		
		
		dest = targetPos + offsetVec * offset;
		
		yaw = VecHeading( offsetVec ); 
		
		while( iter < 9 )
		{		
			if( mac.GetEndOfLineNavMeshPosition( dest, navMeshDest ) )
			{
				return true;
			}
			
			if( Rand(2) == 1 )
			{			
				yaw2 = yaw + 20 * iter;
			}
			else
			{
				yaw2 = yaw - 20 * iter;
			}
			
			offsetVec = RotForward( EulerAngles(0, yaw2, 0 ) );
			dest = targetPos + offsetVec * offset;		 			
			
			iter += 1;
		}
		
		return false;
	}
	
	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
				//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.
		if(npc.HasCombatType(CT_ShieldSword))
		{
			if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawShield();
			}
		}
		else if(npc.HasCombatType(CT_Dual) || npc.HasCombatType(CT_Dual_Assasin))
		{
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawSecondaryWeapon();
			}
		}
		else if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId() && !npc.IsMonster()&& !npc.HasCombatType(CT_Bow) && !npc.HasCombatType(CT_Bow_Walking))
		{
			DrawWeapon();
		}
		if( ComputeDestination( dest ) )
		{	
			npc.offSlot = OS_None;
						
			if( async )
			{				
				if( npc.ActionMoveToAsync( dest, npc.GetModifiedMoveType( moveType ), 1.0, radius, MFA_EXIT ) )
				{
					return BTNS_Completed;
				}
			}
			else
			{
				return BTNS_Active;
			}
		}
		
		return BTNS_Failed;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var res : bool;			
		
		res = npc.ActionMoveTo( dest, npc.GetModifiedMoveType( moveType ), 1.0, radius, MFA_EXIT );
		if( res )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
	
	function OnAbort()
	{
		GetActor().ActionCancelAll();
	}
}

/////////////////////////////////////////////////////////////////////
// MoveToEvaluatedPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskMoveToEvaluatedPosition extends IBehTreeTask
{
	editable var moveType : EMoveType;
	editable var async : bool;
	editable inlined var provider : IAIPositionProvider;
	editable inlined var conditions : array< IAIPositionCondition >;
	editable var maxTests : int;
	editable var baseScore : float;
	editable var minScore : float;
	
	default moveType = MT_Run;
	default maxTests = 10;
	default minScore = 0;
	
	// runtime
	var dest : Vector;
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", maxTests );
	}
	

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();	
		var target : CActor = npc.GetTarget();
		var score : float;
		var eval : CAIPositionEvaluator = theGame.GetAIPositionEvaluator();
		score = eval.FindPosition( target, npc, provider, conditions, maxTests, baseScore, dest );
		
		if( score >= minScore )
		{
			if( async )
			{
				if( npc.ActionMoveToAsync( dest, npc.GetModifiedMoveType( moveType ), 1.0, 1.0, MFA_EXIT ) )
					return BTNS_Completed;
				else
					return BTNS_Failed;
			}
			else
				return BTNS_Active;
		}
		else
			return BTNS_Failed;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();	
		var target : CActor = npc.GetTarget();
		var res : bool;
		
		res = npc.ActionMoveTo( dest, npc.GetModifiedMoveType( moveType ), 1.0, 1.0, MFA_EXIT );
		if( res )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
}	


