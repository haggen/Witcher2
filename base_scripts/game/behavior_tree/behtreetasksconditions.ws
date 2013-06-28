/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree Machine Tasks: Conditions
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// ConditionRandom
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionRandom extends IBehTreeTask
{
	editable var probability : byte;
	default probability = 50;

	function OnBegin() : EBTNodeStatus
	{
		var val : byte;
		val = Rand( 101 );
		
		if( val <= probability )
			return BTNS_Completed;
		else			
			return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionInAttackRange
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionInAttackRange extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( npc.InAttackRange( target ) )
		{
			return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionIsRotatedTowardsTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionIsRotatedTowardsTarget extends IBehTreeTask
{
	editable var maxAngle : float;
	default maxAngle = 10.0f;

	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( npc.IsRotatedTowards( target, maxAngle ) )
		{
			return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionFarFromTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionFarFromTarget extends IBehTreeTask
{
	editable var minDistance : float;
	default minDistance = 3.0f;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();		
		var dist : float;

		if( target )
		{	
			dist = VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() );
			if( dist > minDistance )
				return BTNS_Completed;		
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionNearTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionNearTarget extends IBehTreeTask
{
	editable var distance : float;
	default distance = 3.0f;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();		
		var dist : float;

		if( target )
		{	
			dist = VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() );
			if( dist < distance )
				return BTNS_Completed;		
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionDistanceToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionDistanceToTarget extends IBehTreeTask
{
	editable var minDistance : float;
	editable var maxDistance : float;
	default minDistance = 3.0f;
	default maxDistance = 6.0f;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var dist : float;
		
		if( target )
		{	
			dist = VecDistance2D( GetNPC().GetWorldPosition(), target.GetWorldPosition() );
			if( dist > minDistance  && dist < maxDistance )
				return BTNS_Completed;		
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionDistanceToTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionDistanceToTarget3D extends IBehTreeTask
{
	editable var minDistance : float;
	editable var maxDistance : float;
	editable var maxVerticalDist : float;
	default minDistance = 3.0f;
	default maxDistance = 6.0f;
	default maxVerticalDist = 1.0f;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var mac : CMovingAgentComponent;
		var myPos, targetPos : Vector;
		var distH, distV : float;
		var posReachable : bool;

		if( !target )
		{
			return BTNS_Failed;
		}
		
		myPos = GetNPC().GetWorldPosition();
		targetPos = target.GetWorldPosition();
		
		distH = VecDistance2D( myPos, targetPos );
		distV = AbsF( myPos.Z - targetPos.Z );
		if( distH <= minDistance || distH >= maxDistance || distV >= maxVerticalDist  )
		{
			return BTNS_Failed;
		}
		
		mac = GetNPC().GetMovingAgentComponent();
		posReachable = mac.IsEndOfLinePositionValid( target.GetWorldPosition() );
		
		if ( posReachable )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Failed;
		}
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionDistanceToTargetWithRadius
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionDistanceToTargetWithRadius extends IBehTreeTask
{
	editable var minDistance	: float;
	editable var maxDistance	: float;
	editable var radius			: float;
	default minDistance = 3.0f;
	default maxDistance = 6.0f;
	default radius		= 1.0f;
	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var mac : CMovingAgentComponent;
		var myPos, targetPos : Vector;
		var dist : float;
		var posReachable : bool;

		if( !target )
		{
			return BTNS_Failed;
		}
		
		myPos = GetNPC().GetWorldPosition();
		targetPos = target.GetWorldPosition();
		
		dist = VecDistance2D( myPos, targetPos ) - radius;
		if( dist < 0 )
			dist = 0;
			
		if( dist <= minDistance || dist >= maxDistance )
		{
			return BTNS_Failed;
		}
		
		mac = GetNPC().GetMovingAgentComponent();
		posReachable = mac.IsEndOfLinePositionValid( target.GetWorldPosition() );
		
		if ( posReachable )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Failed;
		}
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionNearCombatSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionNearCombatSlot extends IBehTreeTask
{
	editable var distance : float;
	default distance = 6.0f;

	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		var index, subIndex : int;
		var dest : Vector;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		index = target.GetCombatSlots().GetCombatSlotIndex( npc, subIndex );
		if( index != -1 )
		{
			dest = target.GetCombatSlots().GetCombatSlotWorldPosition( npc, index, subIndex );
			if( VecDistance2D( GetNPC().GetWorldPosition(), dest ) < distance )
			{
				return BTNS_Completed;
			}
		}
		else
		{
			Log("ConditionNearCombatSlot no combat slot!");
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionNearFarSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionNearFarSlot extends IBehTreeTask
{
	editable var distance : float;
	default distance = 6.0f;

	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		var index : int;
		var dest : Vector;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		index = target.GetCombatSlots().GetFarSlotIndexForActor( npc );
		if( index != -1 )
		{
			dest = target.GetCombatSlots().GetFarSlotWorldPosition( index );
			if( VecDistance2D( GetNPC().GetWorldPosition(), dest ) < distance )
			{
				return BTNS_Completed;
			}
		}
		else
		{
			Log("ConditionNearCombatSlot no combat slot!");
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionNoValidFarSlots
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionNoValidFarSlots extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();		
		var target : CActor = npc.GetTarget();
		
		if( target.GetCombatSlots().AnyFarSlotPositionValid() )
			return BTNS_Failed;
		else
			return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionPlayerAttacking
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionPlayerAttacking extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var res : bool;
		var tm : EngineTime;
		var bb : CBlackboard;		
		var playerAttackingEntity : CEntity;
		bb = theGame.GetBlackboard();
				
		// If is attacked by player, wait
		res = bb.GetEntryEntity( 'playerAttacking', playerAttackingEntity );			
		if( res && ( playerAttackingEntity == GetActor() ) )
		{
			res = bb.GetEntryTime( 'playerAttacking', tm );
			if( res && ( theGame.GetEngineTime() - tm < 1.0f ) )
			{
				return BTNS_Completed;
			}
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionHasTargetInCombatSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionHasTargetInCombatSlot extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( npc.GetCombatSlots().HasActorInCombatSlot( target ) )
		{
			return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionHasTargetInCombatSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionOccupiedCombatSlots extends IBehTreeTask
{
	editable var maxOccupied : int;

	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		if( target.GetCombatSlots().GetNumOccupiedCombatSlots() <= maxOccupied )
			return BTNS_Completed;
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionIsMoving
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionIsMoving extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;	
		var target : CActor;
		npc = GetNPC();
		target = npc.GetTarget();
		if( npc.IsMoving() )
		{
			if(target == thePlayer && npc.GetMovingAgentComponent().GetMoveSpeedAbs() > 0)
			{
				//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje podazania za graczem w combat.
				//Dzieki wywolaniu tej metody tutaj, unikamy koniecznosci wstawienia sekwencji 
				//w kazdym drzewku (behtree) combatowym i wywolywania oddzielnej akcji podtrzymania
				//combat mode
				if(npc.GetCurrentCombatType()!=CT_Bow && npc.GetCurrentCombatType()!=CT_Bow_Walking)
					thePlayer.KeepCombatMode();
			}
			return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionBlackboard
/////////////////////////////////////////////////////////////////////
enum EBlackboardCondition
{	
	BC_FloatEqual,
	BC_FloatHigher,
	BC_TimePassed,
	BC_HasCooldownPassed,
};

class CBTTaskConditionBlackboard extends IBehTreeTask
{
	editable var globalBlackboard : bool;
	editable var entryName : name;
	editable var condition : EBlackboardCondition;
	editable var valueFloat : float;
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", entryName );
	}

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var bb : CBlackboard;
		var tempFloat : float;
		var currTime, tm : EngineTime;
		
		
		if( !IsNameValid( entryName ) )
			return BTNS_Failed;
		
		if( globalBlackboard )		
			bb = theGame.GetBlackboard();		
		else		
			bb = npc.GetLocalBlackboard();		
		
		if( condition == BC_TimePassed )
		{
			if( bb.GetEntryTime( entryName, tm ) )
			{
				currTime = theGame.GetEngineTime();
				if( tm != EngineTime() && currTime >= tm + valueFloat )
				{
					return BTNS_Completed;
				}
			}
		}
		else if( condition == BC_HasCooldownPassed )
		{
			if( bb.GetEntryTime( entryName, tm ) )
			{
				currTime = theGame.GetEngineTime();
				if( currTime >= tm + valueFloat )
				{
					return BTNS_Completed;
				}
			}
			else
			{
				return BTNS_Completed;
			}

		}
		else if( condition == BC_FloatEqual )
		{
			if( bb.GetEntryFloat(entryName, tempFloat ) )
			{
				if( tempFloat == valueFloat )
				{
					return BTNS_Completed;
				}
			}
		}
		else if( condition == BC_FloatHigher )
		{
			if( bb.GetEntryFloat(entryName, tempFloat ) )
			{
				if( tempFloat > valueFloat )
				{
					return BTNS_Completed;
				}
			}
		}		
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionHealthHigher
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionHealthHigher extends IBehTreeTask
{
	editable var percentage : float;
	
	default percentage = 50.0f;

	function OnBegin() : EBTNodeStatus
	{		
		var actor : CActor = GetActor();
		var h : float;
		h = 100.0 * actor.GetHealth() / actor.GetInitialHealth();
		if( h > percentage )
			return BTNS_Completed;
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionTargetHealthHigher
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionTargetHealthHigher extends IBehTreeTask
{
	editable var percentage : float;	
	default percentage = 50.0f;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var h : float;
		if( target )
		{
			h = 100.0 * target.GetHealth() / target.GetInitialHealth();
			if( h > percentage )
				return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionNearFocusedPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionNearFocusedPosition extends IBehTreeTask
{
	editable var distance : float;
	default distance = 1.0f;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var dist : float;
		var pos : Vector;
		
		pos = npc.GetFocusedPosition();
		
		dist = VecDistance2D( npc.GetWorldPosition(), pos );
		if( dist < distance )
			return BTNS_Completed;
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionTargetVisible
////////////////
/////////////////////////////////////////////////////
class CBTTaskConditionTargetVisible extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{	
		var npc : CNewNPC = GetNPC();		
		var target : CActor = npc.GetTarget();
		var res : bool;
		
		res = npc.VisibilityTest( VT_LineOfSight, target );
		
		if( res )
			return BTNS_Completed;
				
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionEvaluateCurrentPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionEvaluateCurrentPosition extends IBehTreeTask
{
	editable inlined var conditions : array< IAIPositionCondition >;
	editable var minScore : float;
	
	default minScore = 0;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var eval : CAIPositionEvaluator = theGame.GetAIPositionEvaluator();
		var dist : float;
		var pos : Vector;
		var score : float;
				
		pos = npc.GetWorldPosition();
		score = eval.TestPosition( pos, target, npc, conditions );
		if( score >= minScore )
		{
			return BTNS_Completed;
		}		
				
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionEvaluateMoveDestination
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionEvaluateMoveDestination extends IBehTreeTask
{
	editable inlined var conditions : array< IAIPositionCondition >;
	editable var minScore : float;
	
	default minScore = 0;

	function OnBegin() : EBTNodeStatus
	{		
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var eval : CAIPositionEvaluator = theGame.GetAIPositionEvaluator();
		var dist : float;
		var pos : Vector;
		var score : float;
		
		if( npc.IsMoving() )
		{
			pos = npc.GetPositionOrMoveDestination();
			score = eval.TestPosition( pos, target, npc, conditions );
			if( score >= minScore )
			{
				return BTNS_Completed;
			}
		}
				
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionHasTicket
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionHasTicket extends IBehTreeTask
{	
	function OnBegin() : EBTNodeStatus
	{
		if( thePlayer.GetTicketPool( TPT_Attack ).HasTicket( GetActor() ) )
			return BTNS_Completed;
		else
			return BTNS_Failed;
	}
}
// ConditionIsRotatedTowardsTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionShouldUseMagicShield extends IBehTreeTask
{
	editable var shieldCastCooldown : float;
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc = GetNPC();
	
		if( npc.HasMagicShield() || theGame.GetEngineTime() < npc.GetMagicShieldFinishedTime() + EngineTimeFromFloat(shieldCastCooldown))
		{
			return BTNS_Failed;
		}
			
		return BTNS_Completed;
	}
}
class CBTTaskConditionAimsThroughWalls extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc = GetNPC();
	
		if(npc.CanAimThroughWalls())
		{
			return BTNS_Completed;
		}
		return BTNS_Failed;	
		
	}
}
class CBTTaskConditionStartsFightWithCombatIdle extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc = GetNPC();
	
		if(npc.ShouldStartFightWithCombatIdle())
		{
			//this is the very begining of the fight, combat mode should be turned on
			thePlayer.KeepCombatMode();
						
			return BTNS_Completed;
		}
		return BTNS_Failed;	
		
	}
}
enum EActionCooldownSet
{
	Action_Set1,
	Action_Set2,
	Action_Set3,
	Action_Set4,
	Action_Set5
}
class CBTTaskConditionActionCooldown extends IBehTreeTask
{
	editable var actionSet : EActionCooldownSet;
	editable var actionCooldown : float;
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc = GetNPC();
	
		if( theGame.GetEngineTime() < npc.GetActionTime(actionSet) + EngineTimeFromFloat(actionCooldown))
		{
			return BTNS_Failed;
		}
		npc.SetActionTime(actionSet);	
		return BTNS_Completed;
	}
}
class CBTTaskConditionTargetIsBlocking extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;  
		var target : CActor;
		npc = GetNPC();
		target = npc.GetTarget();
		if(target == thePlayer && thePlayer.IsInGuardBlock())
		{
			return BTNS_Completed;
		}
		return BTNS_Failed;
	}
}


/////////////////////////////////////////////////////////////////////
// ConditionInSameRoomAsTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionInSameRoomAsTarget extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc 				: CNewNPC = GetNPC();
		var target 				: CActor = npc.GetTarget();
		var mac 				: CMovingAgentComponent;
		var posInSameRoom		: bool;
		
		if( !target )
		{
			return BTNS_Failed;
		}	
		
		mac = GetNPC().GetMovingAgentComponent();
		posInSameRoom = mac.IsInSameRoom( target.GetWorldPosition() );
		
		if ( posInSameRoom )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Failed;
		}
	}
}

/////////////////////////////////////////////////////////////////////
// ConditionCanUseCharge
/////////////////////////////////////////////////////////////////////
class CBTTaskConditionCanUseCharge extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		if( GetNPC().CanUseChargeAttack() )
			return BTNS_Completed;
		else			
			return BTNS_Failed;
	}
}
