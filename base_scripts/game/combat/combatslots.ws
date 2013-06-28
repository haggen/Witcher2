/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CCombatSlots
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Combat slot struct
/////////////////////////////////////////////
import struct SCombatSlot
{
	import var position : Vector;
	import var secondaryPosition : Vector;
	import var actor : CActor;
	import var subIndex : int;
};


/////////////////////////////////////////////
// Combat slot index
/////////////////////////////////////////////
struct SCombatSlotIndex
{
	var index, subIndex : int;
}

/////////////////////////////////////////////
// Idle slot struct
/////////////////////////////////////////////
struct SCombatIdleSlot
{
	var actor : CActor;
	var position : Vector;	// relative position
};

/////////////////////////////////////////////
// Combat Idle group
/////////////////////////////////////////////
class CCombatIdleGroup extends CObject
{
	var position : Vector;
	var slots : array< SCombatIdleSlot >;
	
	function GetSlotIdx( actor : CActor ) : int
	{
		var s : int = slots.Size();
		var i : int;
		
		for( i=0; i<s; i+=1 )
		{
			if( slots[i].actor == actor )
			return i;
		}
		
		return -1;
	}
};

/////////////////////////////////////////////
// Combat slots
/////////////////////////////////////////////
import class CCombatSlots extends CObject 
{
	import private var combatSlots	: array< SCombatSlot >;	
	private var farSlots	: array< SCombatSlot >;	
	private var combatIdleGroups : array< CCombatIdleGroup >;
	private var owner : CActor;
	private var globalPosition : Vector;
	private var anyFarSlotValid : bool;
	
	// Get number of all combat slots
	import final function GetNumAllCombatSlots() : int;
	
	// Get number of free combat slots
	import final function GetNumFreeCombatSlots() : int;
	
	// Get number of occupied combat slots
	import final function GetNumOccupiedCombatSlots() : int;
	
	// Setup all combat slots
	function Initialize()
	{
		var i,s : int;
		var r, angle : float;
		var angles : array<float>;
		var pos, pos2 : Vector;
		var NUM_FAR_SLOTS : int = 8;
		var FAR_SLOT_RADIUS : float = 5.0f;
		
		owner = (CActor)GetParent();
		
		combatSlots.Clear();
		
		angles.PushBack( 0.0 );
		angles.PushBack( 120 );
		angles.PushBack( -120 );
		
		s = angles.Size();
		combatSlots.Grow( s );
		for ( i=0; i<s; i+=1 )
		{
			angle = Deg2Rad( angles[i] );
			pos = Vector( SinF( angle ), CosF( angle ), 0.0, 0.0 );
			//secondary position rotated by 60 deg
			angle = Deg2Rad( angles[i] + 60 );
			pos2 = Vector( SinF( angle ), CosF( angle ), 0.0, 0.0 );			
			combatSlots[i] = SCombatSlot( pos, pos2, NULL, -1 );
		}
				
		combatIdleGroups.Grow(s);		
		for ( i=0; i<s; i+=1 )
		{
			combatIdleGroups[i] = new CCombatIdleGroup in this;
			angle = Deg2Rad( angles[i] );
			pos = Vector( SinF( angle ), CosF( angle ), 0.0, 0.0 );
			if( UseNewCombat() )
				combatIdleGroups[i].position = pos * 9.0;
			else
				combatIdleGroups[i].position = pos * 7.0;
		}
				
		// Far slots (player only)
		/*if( UseNewCombat() )
		{
			if( owner == thePlayer )
			{
				farSlots.Grow( NUM_FAR_SLOTS );
				for( i=0; i<NUM_FAR_SLOTS; i+=1 )
				{
					angle = 360.0 * ( (float)i/(float)NUM_FAR_SLOTS );
					angle = Deg2Rad( angle );
					pos = Vector( SinF( angle ), CosF( angle ), 0.0, 0.0 ) * FAR_SLOT_RADIUS;
					farSlots[i] = SCombatSlot( pos, Vector(0,0,0), NULL, -1 );
				}
				
				owner.AddTimer( 'TickCombatSlots', 1.0, true, true );
				
				UpdateGlobalPosition();
			}
		}*/
	}
	
	function GetGlobalPosition() : Vector
	{
		/*if( UseNewCombat() )
		{
			return globalPosition;
		}
		else
		{*/
			return owner.GetWorldPosition();
		//}
	}
	
	function UpdateGlobalPosition()
	{
		var ownerPos : Vector = owner.GetWorldPosition();
		if( VecDistance2D( ownerPos, globalPosition ) > VecLength2D( farSlots[0].position ) + 1.0 )
		{
			globalPosition = ownerPos;
		}
	}
	
	function Tick( td : float )
	{
		UpdateGlobalPosition();
	}
	
	function CalculateValueDistance( actor : CActor, index, subIndex : int ) : float
	{
		var actorPos : Vector = actor.GetWorldPosition();
		var dist : float = VecDistance( actorPos, GetCombatSlotWorldPosition( actor, index, subIndex ) );
		var normalized : float = ( 4.0 - dist ) / 4.0;
		return MaxF( normalized, 0.0 );
	}
	
	function CalculateValueFrontBack( actor : CActor, index, subIndex : int ) : float
	{
		var mat : Matrix = owner.GetLocalToWorld();
		var ownerToSlot : Vector;
		var dot,angle : float;
				
		if( GetNumFreeCombatSlots() > 1 )
		{
			return 0.0f;
		}
		
		ownerToSlot = GetCombatSlotRawLocalPosition( index, subIndex );
		dot = VecDot( ownerToSlot, mat.Y );
		angle = AcosF( dot ) / Pi();
		if( actor.GetAttackPriority() > 2 )
		{
			// Preffer back
			return angle;
		}
		else
		{
			// Preffer front
			return 1.0 - angle;
		}
	}
	
	function CalculateValueFree( index : int ) : float
	{
		if( combatSlots[index].actor )
		{
			return 0.0;
		}
		else
		{
			return 1.0;
		}
	}
	
	function CalculateValueCurrent( actor : CActor, index : int ) : float
	{
		if( combatSlots[index].actor == actor )
		{
			return 1.0;
		}
		else
		{
			return 0.0;
		}
	}
	
	function ComputeValueForSlot( actor : CActor, index, subIndex : int, out outValue : float ) : bool
	{
		var slotActor : CActor = combatSlots[index].actor;
		var betterPrio : bool = true;
		var samePrio : bool = true;
		var goodTime : bool = true;		
		var actorAttackedRecently : bool;
		var slotActorAttackedRecently : bool;
		var closerThanOwner : bool;
		var value : float;
		var slotActorPrio, actorPrio : int;
		var currentTime : EngineTime = theGame.GetEngineTime();
		var d1, d2 : float;
		var slotWorldPos : Vector;
		
		if( slotActor )
		{
			slotActorPrio = slotActor.GetAttackPriority();
			actorPrio = actor.GetAttackPriority();
			betterPrio = ( slotActorPrio < actorPrio );
			samePrio = ( slotActorPrio == actorPrio );
		
			if( slotActor.lastTimeAttacked != EngineTime() )
			{
				if( currentTime - slotActor.lastTimeAttacked < 6.0 )
				{				
					slotActorAttackedRecently = true;
				}
			}
			
			slotWorldPos = GetCombatSlotWorldPosition( slotActor, index, subIndex ); 
			d1 = VecDistance( slotActor.GetWorldPosition(), slotWorldPos );
			d2 = VecDistance( actor.GetWorldPosition(), slotWorldPos );
			if( ( d2 < d1 ) && ( d2 < 2.0 ) && AbsF(d2-d1) > 1.0 )
			{
				closerThanOwner = true;
			}
		}
		
		if( actor.lastTimeAttacked != EngineTime() )
		{
			if( currentTime - actor.lastTimeAttacked < 6.0 )
			{				
				actorAttackedRecently = true;
			}
		}
		
		if( ( betterPrio || (!betterPrio && closerThanOwner )/*|| samePrio*/ || actorAttackedRecently ) && !slotActorAttackedRecently )
		{
			if( slotActor )
			{
				goodTime = currentTime - slotActor.combatSlotTakeTime > 10.0;
				goodTime =  goodTime || ( slotActor.combatSlotTakeTime == EngineTime() );
				goodTime = goodTime || ( actor.combatSlotTakeTime == EngineTime() );
			}
			
			if( goodTime || actorAttackedRecently )
			{			
				value =  10.0 * CalculateValueFree( index );
				value += 10.0 * CalculateValueCurrent( actor, index );
				value += 1.0 *	CalculateValueDistance( actor, index, subIndex );
				value += 5.0 *	CalculateValueFrontBack( actor, index, subIndex );	
				outValue = value;
				return true;
			}
		}
		
		return false;
	}
	
	function AssignBestCombatSlot( actor : CActor, out subIndex : int ) : int
	{
		var i,s,j, bestIdx, bestSubIdx, bestValueIdx : int;
		var actorPos : Vector;
		var values : array<float>;
		var indices : array<SCombatSlotIndex>;
		var found : bool;		
		var value : float;
		var slotActor : CActor;
		
		s = combatSlots.Size();		
		actorPos = actor.GetWorldPosition();
				
		// Compute values
		for( i=0; i<s; i+=1 )
		{			
			for( j=0; j<2; j+=1 )
			{
				if( IsCombatSlotPostionValid( actor, i, j ) )
				{
					if( ComputeValueForSlot( actor, i, j, value ) )
					{					
						values.PushBack(value);
						indices.PushBack( SCombatSlotIndex(i,j) );
					}
					
					break;
				}
			}
		}
		
		bestValueIdx = ArrayFindMaxF(values);
		
		if( bestValueIdx != -1 )
		{
			bestIdx = indices[bestValueIdx].index;
			bestSubIdx = indices[bestValueIdx].subIndex;
			slotActor = combatSlots[bestIdx].actor;
			if( slotActor && ( slotActor != actor ) )
			{
				slotActor.OnCombatSlotLost();
			}
			
			combatSlots[bestIdx].actor = actor;			
			combatSlots[bestIdx].subIndex = bestSubIdx;
			
			subIndex = bestSubIdx;
			return bestIdx;
		}
		else
		{			
			return -1;
		}
	}
		
	function GetCombatSlotRawLocalPosition( index : int, subIndex : int ) : Vector
	{
		if( subIndex == 1 )		
			return combatSlots[index].secondaryPosition;		
		else		
			return combatSlots[index].position;		
	}
	
	function GetCombatSlotLocalPosition( actor : CActor, index : int, subIndex : int ) : Vector
	{
		if( subIndex == 1 )		
			return combatSlots[index].secondaryPosition*actor.GetCombatSlotOffset();		
		else		
			return combatSlots[index].position*actor.GetCombatSlotOffset();		
	}
	
	function GetCombatSlotWorldPosition( actor : CActor, index : int, subIndex : int ) : Vector
	{
		if( subIndex == 1 )		
			return owner.GetWorldPosition() + combatSlots[index].secondaryPosition*actor.GetCombatSlotOffset();		
		else		
			return owner.GetWorldPosition() + combatSlots[index].position*actor.GetCombatSlotOffset();		
	}
	
	function GetCombatSlotNavMeshPosition( actor : CActor, index : int, subIndex : int, out outPos : Vector ) : bool
	{
		var endPos : Vector;		
			
		if( subIndex == 1 )		
			endPos = owner.GetWorldPosition() + combatSlots[index].secondaryPosition*actor.GetCombatSlotOffset();
		else		
			endPos = owner.GetWorldPosition() + combatSlots[index].position*actor.GetCombatSlotOffset();		
				
		return owner.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( endPos, outPos );		
	}
	
	function GetCombatSlotNavMeshPositionForActor( actor : CActor, out outPos : Vector ) : bool
	{
		var idx, subIdx : int;
		idx = GetCombatSlotIndex( actor, subIdx );
		if( idx != -1 )	
		{
			return GetCombatSlotNavMeshPosition( actor, idx, subIdx, outPos );		
		}
		else
		{
			return false;
		}
	}
	
	function IsCombatSlotPostionValid( actor : CActor, index : int, subIndex : int ) : bool
	{
		var pos : Vector;
		pos = GetCombatSlotWorldPosition( actor, index, subIndex );		
		return owner.GetMovingAgentComponent().IsEndOfLinePositionValid( pos );
	}
	
	function FindCombatSlotNoPosition( actor : CActor, exclusive : bool ) : bool
	{
		var i,s, free: int;
		s = combatSlots.Size();
		
		// Search for already allocated slot
		for( i=0; i<s; i+=1 )
		{
			if( combatSlots[i].actor == actor )
			{
				return true;		
			}
		}
		
		if( exclusive )
		{
			for( i=0; i<s; i+=1 )
			{
				if( !combatSlots[i].actor )
				{
					free+=1;
				}
			}
			
			if( free == s )
			{
				combatSlots[0].actor=actor;
				combatSlots[0].subIndex = 0;
				owner.AddTimer( 'UpdateCombatSlots', 1.0, true );
				return true;
			}
			else
				return false;
		}
		else
		{		
			for( i=0; i<s; i+=1 )
			{
				if( !combatSlots[i].actor )
				{
					combatSlots[i].actor = actor;					
					combatSlots[i].subIndex = 0;
					owner.AddTimer( 'UpdateCombatSlots', 1.0, true );
					return true;
				}
			}
			
			return false;
		}
	}
	
	private function AttachTest() : bool
	{
		var ownerNPC : CNewNPC;
		var targetNPC : CNewNPC;
		
		if( owner.IsA( 'CNewNPC' ) )
		{
			ownerNPC = (CNewNPC)owner;
			targetNPC = (CNewNPC)ownerNPC.GetTarget();
			if( targetNPC )
			{
				if( targetNPC.GetCombatSlots().HasActorInCombatSlot( ownerNPC ) )
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	function LoadCombatSlotPosition( actor : CActor, exclusive : bool, out outPosition : Vector) : bool
	{
		var i,s,j,subIndex : int;
		var found, free : int;
		var wasInSlot : bool;
		
		s = combatSlots.Size();
		found = -1;
		
		/*if( !AttachTest() )
		{
			return false;
		}*/
		
		// Search for already allocated slot
		for( i=0; i<s; i+=1 )
		{
			if( combatSlots[i].actor == actor )
			{
				found = i;
				wasInSlot = true;
				break;				
			}
		}
				
		if( found != -1 )
		{			
			combatSlots[found].actor = NULL;
			combatSlots[found].subIndex = -1;
			found = -1;
		}

		// If not found, try allocate new slot
		free = GetNumFreeCombatSlots();
		
		if( exclusive )
		{
			// Some slots occupied, no go!
			if( free != s )
			{
				return false;
			}			
		}
		
		found = AssignBestCombatSlot( actor, subIndex );								
		if( found >= 0 )
		{
			//Logf("Actor %1 taking slot %2", actor.GetName(), found );
			owner.AddTimer( 'UpdateCombatSlots', 1.0, true );
			outPosition = GetCombatSlotWorldPosition( actor, found, subIndex );
			if( !wasInSlot )
			{
				actor.combatSlotTakeTime = theGame.GetEngineTime();
			}
			LeaveCombatIdle( actor );
			return true;
		}
						
		return false;		
	}
	
	function UpdateCombatSlots()
	{
		var i,s,free : int;
		var actor : CActor;
		var npc : CNewNPC;
		var clear : bool;
		
		s = combatSlots.Size();
		free = 0;
				
		for( i=0; i<s; i+=1 )
		{
			actor = combatSlots[i].actor;
			if( actor )
			{
				clear = false;
			
				// If actor dead or has changed target clear slot
				if( actor.IsAlive() == false )
				{
					clear = true;
				}
				else if( actor.IsA( 'CNewNPC' ) )
				{
					npc = (CNewNPC)actor;
					if( npc.GetTarget() != owner )
					{
						clear = true;
					}
				}
				
				if( clear )
				{
					combatSlots[i].actor = NULL;
					combatSlots[i].subIndex = -1;
					free+=1;
				}
			}
			else
			{
				free+=1;
			}
		}
		
		// if all free remove timer
		if( free == s )
		{
			owner.RemoveTimer( 'UpdateCombatSlots' );
		}
	}
	
	function HasActorInCombatSlot( actor : CActor ) : bool
	{
		var i,s : int;
		
		s = combatSlots.Size();
		for( i=0; i<s; i+=1 )
		{
			if( combatSlots[i].actor == actor )
			{
				return true;
			}
		}
		
		return false;
	}
	
	function GetCombatSlotIndex( actor : CActor, out subIndex : int ) : int
	{
		var i,s : int;
		
		s = combatSlots.Size();
		for( i=0; i<s; i+=1 )
		{
			if( combatSlots[i].actor == actor )
			{
				subIndex = combatSlots[i].subIndex;
				return i;
			}
		}
		
		subIndex = -1;
		return -1;
	}
	
	//////////////////////////////////////////////////////////////////////////////////
	// COMBAT IDLE SLOTS	
	//////////////////////////////////////////////////////////////////////////////////
	
	function LoadCombatIdlePosition( actor : CActor, canChangeGroup : bool, out outPos : Vector ) : bool
	{
		/*var i,s : int;		
		var actorPos, ownerPos, dest, lastToOwner, lastPos, offset : Vector;		
		var mac : CMovingAgentComponent;
		var valid : bool;*/
		var slotIdx : int;
		var group : CCombatIdleGroup;
		var pos, groupPos : Vector;
		
		
		// If group assigned		
		if( actor.combatIdleGroupIdx != -1 )
		{
			group = combatIdleGroups[ actor.combatIdleGroupIdx ];			
			slotIdx = group.GetSlotIdx( actor );
			if( slotIdx == -1 )
			{
				// actor not found, set invalid group
				actor.combatIdleGroupIdx = -1;				
			}
			else
			{
				groupPos = GetGlobalPosition() + group.position;
				if( !canChangeGroup || IsPositionValid( groupPos, actor.GetWorldPosition() ) )
				{
					outPos = groupPos + group.slots[slotIdx].position;
					return true;
				}
				else
				{
					// wrong group position, set invalid group
					actor.combatIdleGroupIdx = -1;	
				}
			}
		}
		
		// No group assigned
		if( actor.combatIdleGroupIdx == -1 )
		{			
			actor.combatIdleGroupIdx = FindBestCombatIdleGroup( actor );			
			group = combatIdleGroups[ actor.combatIdleGroupIdx ];
			pos = VecRingRand( 0, 2 );
			group.slots.PushBack( SCombatIdleSlot( actor, pos ) );
			
			owner.AddTimer( 'UpdateCombatIdleSlots', 1.0, true );
			
			// Return
			outPos = owner.GetWorldPosition() + group.position + pos;
			return true;
		}
	}
	
	private function FindBestCombatIdleGroup( actor : CActor ) : int
	{
		var s,i, idx : int;
		var ownerPos, groupPos, actorPos : Vector;
		var mac : CMovingAgentComponent = owner.GetMovingAgentComponent();
		s = combatIdleGroups.Size();
		
		actorPos = actor.GetWorldPosition();
		ownerPos = GetGlobalPosition();
		
		idx = Rand(s);
		
		for( i=0; i<s; i+=1 )
		{						
			groupPos = combatIdleGroups[idx].position + ownerPos;			
			if( IsPositionValid( groupPos, actorPos ) )
			{
				return idx;			
			}
			
			idx = ( idx + 1 ) % s;
		}
		
		return Rand(s);
	}
	
	private function IsPositionValid( testedPos, actorPos : Vector ) : bool
	{
		var mac : CMovingAgentComponent = owner.GetMovingAgentComponent();
		var ownerPos : Vector = owner.GetPositionOrMoveDestination();
		var a,b : Vector;
		
		if( VecDistanceToEdge( ownerPos, actorPos, testedPos ) > 3.5 )
		{
			a = actorPos - ownerPos; a.Z = 0.0;
			a = VecNormalize2D( a );
			b = testedPos - ownerPos; b.Z = 0.0;
			b = VecNormalize2D( b );
			
			if( VecDot( a, b ) > -0.5 )
			{
				if( mac.IsEndOfLinePositionValid( testedPos ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	private function LeaveCombatIdle( actor : CActor )
	{
		var group : CCombatIdleGroup;
		var idx : int;
		if( actor.combatIdleGroupIdx != -1 )
		{
			group = combatIdleGroups[actor.combatIdleGroupIdx];
			idx = group.GetSlotIdx( actor );
			if( idx != -1 )
			{
				group.slots.Erase( idx );
			}
			
			actor.combatIdleGroupIdx = -1;
		}
	}
	
	function UpdateCombatIdleSlots()
	{
		var g,s,i,free : int;
		var gs : int = combatIdleGroups.Size();
		var group : CCombatIdleGroup;
		var actor : CActor;
		var npc : CNewNPC;
		var clear : bool;
		
		free = 0;
		
		for( g=0; g<gs; g+=1 )
		{
			group = combatIdleGroups[g];
			s = group.slots.Size();
			
			for( i=s-1; i>=0; i-=1 )
			{
				clear =  false;
				actor = group.slots[i].actor;
				if( !actor )
				{
					clear = true;				
				}				
				else if ( actor.combatIdleGroupIdx != -1 )
				{
					if( !actor.IsAlive() )
					{
						clear = true;
					}
					else if( actor.IsA( 'CNewNPC' ) )				
					{
						npc = (CNewNPC)actor;
						if( npc.GetTarget() != owner )
						{
							clear = true;			
						}
					}
				}
				
				if( clear )
				{					
					group.slots.Erase( i );	
					if( actor )
						actor.combatIdleGroupIdx = -1;
				}
			}
			
			if( group.slots.Size() == 0 )
			{
				free +=1;
			}
		}
		
		// All slots free, remove timer
		if( free == gs )
		{
			owner.RemoveTimer( 'UpdateCombatIdleSlots' );
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// FAR SLOTS
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function AssignFarSlot( actor : CActor ) : bool
	{
		var total : int = GetNumFarSlots();
		var free : int;
		var currentIdx, foundIdx : int;
		var tmp : Vector;
		
		currentIdx = GetFarSlotIndexForActor( actor );
		if( currentIdx != -1 )
		{
			if( GetFarSlotNavMeshPosition( currentIdx, tmp ) )
			{
				return true;
			}
			else
			{
				farSlots[currentIdx].actor = NULL;
			}
		}
		
		free = GetNumFreeFarSlots();
		if( free == 0 )
		{
			return false;
		}
		
		foundIdx = AssignBestFarSlot( actor );
		if( foundIdx != -1 )
		{
			LeaveCombatIdle( actor );
			owner.AddTimer( 'UpdateFarSlots', 1.0, true );
			return true;
		}
		
		return false;
	}
	
	function AssignBestFarSlot( actor : CActor ) : int
	{
		var i, cnt, bestIdx : int;
		var s : int = farSlots.Size();
		var ownerPos : Vector;
		var actorLocalPos : Vector;
		var dist, bestDist : float;
		
		actorLocalPos = actor.GetWorldPosition() - GetGlobalPosition();
		
		bestDist = 100000000;
		bestIdx = -1;
		
		for( i = 0; i < s; i += 1 )
		{
			if( !farSlots[i].actor )
			{
				if( IsFarSlotPostionValid( i ) )
				{
					dist = VecDistance( actorLocalPos, farSlots[i].position );
					if( dist < bestDist )
					{
						bestDist = dist;
						bestIdx = i;
					}
				}
			}
		}
		
		if( bestIdx != -1 )
		{
			farSlots[bestIdx].actor = actor;
		}
		
		return bestIdx;
	}
	
	function GetNumFarSlots() : int
	{
		return farSlots.Size();
	}
	
	function GetNumFreeFarSlots() : int
	{
		var i, cnt : int;
		var s : int = farSlots.Size();
		
		for( i = 0; i < s; i += 1 )
		{
			if( !farSlots[i].actor )
			{
				cnt += 1;
			}
		}
		
		return cnt;
	}
	
	function GetFarSlotLocalPosition( index : int ) : Vector
	{
		return farSlots[index].position;
	}
	
	function GetFarSlotWorldPosition( index : int ) : Vector
	{
		return farSlots[index].position + GetGlobalPosition();
	}
	
	function GetFarSlotNavMeshPosition( index : int, out outPos : Vector ) : bool
	{
		var endPos : Vector = GetFarSlotWorldPosition( index );				
		return owner.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( endPos, outPos );		
	}
	
	function GetFarSlotNavMeshPositionForActor( actor : CActor, out outPos : Vector ) : bool
	{
		var idx : int;
		idx = GetFarSlotIndexForActor( actor );
		if( idx != -1 )	
		{
			return GetFarSlotNavMeshPosition( idx, outPos );		
		}
		else
		{
			return false;
		}
	}
	
	function IsFarSlotPostionValid( index : int ) : bool
	{
		var pos : Vector = GetFarSlotWorldPosition( index );		
		return owner.GetMovingAgentComponent().IsEndOfLinePositionValid( pos );
	}
	
	function GetFarSlotIndexForActor( actor : CActor ) : int
	{
		var i, cnt : int;
		var s : int = farSlots.Size();
		
		for( i = 0; i < s; i += 1 )
		{
			if( farSlots[i].actor == actor )
			{
				return i;
			}
		}
		
		return -1;
	}
	
	function AnyFarSlotPositionValid() : bool
	{
		return anyFarSlotValid;
	}
	
	function UpdateFarSlots()
	{
		var i,s,free : int;
		var actor : CActor;
		var npc : CNewNPC;
		var clear : bool;
		
		s = farSlots.Size();
		free = 0;
		
		anyFarSlotValid = false;
				
		for( i=0; i<s; i+=1 )
		{
			if( !anyFarSlotValid && IsFarSlotPostionValid( i ) )
			{
				anyFarSlotValid = true;
			}
		
			actor = farSlots[i].actor;
			if( actor )
			{
				clear = false;
			
				// If actor dead or has changed target clear slot
				if( actor.IsAlive() == false )
				{
					clear = true;
				}
				else if( actor.IsA( 'CNewNPC' ) )
				{
					npc = (CNewNPC)actor;
					if( npc.GetTarget() != owner )
					{
						clear = true;
					}
				}
				
				if( clear )
				{
					farSlots[i].actor = NULL;
					farSlots[i].subIndex = -1;
					free+=1;
				}
			}
			else
			{
				free+=1;
			}
		}
		
		// if all free remove timer
		if( free == s )
		{
			owner.RemoveTimer( 'UpdateFarSlots' );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// VISUAL DEBUG
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function UpdateVisualDebug( vd : CVisualDebug )
	{	
		var slotPos : Vector;
		var slotOwner : CActor;
		var dbgName : name;
		var i, s : int;
	
		slotOwner = combatSlots[0].actor; if( !slotOwner ) slotOwner = owner;
		slotPos = GetCombatSlotLocalPosition(slotOwner, 0, 0);
		vd.AddSphere( 'combatSlot0', 0.3, slotPos, false, Color( 255, 255, 0) );
		vd.AddText('combatSlot0', "s0", slotPos, false, 0, Color( 255, 255, 0) );
		
		slotOwner = combatSlots[1].actor; if( !slotOwner ) slotOwner = owner;
		slotPos = GetCombatSlotLocalPosition(slotOwner, 1, 0);
		vd.AddSphere( 'combatSlot1', 0.3, slotPos, false, Color( 255, 255, 0) );
		vd.AddText('combatSlot1', "s1", slotPos, false, 0, Color( 255, 255, 0) );
		
		slotOwner = combatSlots[2].actor; if( !slotOwner ) slotOwner = owner;
		slotPos = GetCombatSlotLocalPosition(slotOwner, 2, 0);
		vd.AddSphere( 'combatSlot2', 0.3, slotPos, false, Color( 255, 255, 0) );
		vd.AddText('combatSlot2', "s2", slotPos, false, 0, Color( 255, 255, 0) );
		
		/*if( UseNewCombat() )
		{
			s = farSlots.Size();
			for( i = 0; i < s; i += 1 )
			{
				dbgName = StringToName( StrFormat( "farSlot%1", i ) );
				slotPos = GetFarSlotWorldPosition( i );
				vd.AddSphere( dbgName, 0.3, slotPos, true, Color( 255, 128, 0) );
				vd.AddText( dbgName, dbgName, slotPos, true, 0, Color( 255, 128, 0) );
			}
		}*/
	}
}