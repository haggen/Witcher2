/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** W2BattleArea
/** Copyright © 2010
/***********************************************************************/

import class CBattleArea extends CEntity
{
	import final function EnterArea( npc : CNewNPC, teleport : bool );
	
	import final function ClearArea( npc : CNewNPC );
	
	import final function GetCenterOfMass() : Vector;
	
	import final function GetSlotPositionForNPC( npc : CNewNPC ) : Vector;
};

/////////////////////////////////////////////////////////////////////
// Task[ MoveToBattleAreaSlot ]
/////////////////////////////////////////////////////////////////////

class CBTTaskMoveToBattleAreaSlot extends IBehTreeTask
{
	editable var maxDistance : float;
	editable var moveType : EMoveType;
	
	default maxDistance = 1.0;
	default moveType = MT_Run;

	latent function Main() : EBTNodeStatus
	{
		var target : CNode;
		var npc : CNewNPC;
		var battleArea : CBattleArea;
		var pos : Vector;
		var res : bool;
		
		npc = GetNPC();
		battleArea = npc.GetBattleArea();
		if ( !battleArea )
		{
			return BTNS_Failed;
		}
		
		pos = battleArea.GetSlotPositionForNPC( npc );
		res = npc.ActionMoveTo( pos, moveType, 1.0, maxDistance, MFA_EXIT );
		if( res )
		{
			return BTNS_Completed;
		}
				
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// Condition[ DistanceToBattleAreaSlot ]
/////////////////////////////////////////////////////////////////////

class CBTTaskConditionDistanceToBattleAreaSlot extends IBehTreeTask
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
		var mac : CMovingAgentComponent;
		var battleArea : CBattleArea;
		var myPos, targetPos : Vector;
		var distH, distV : float;
		var posReachable : bool;
		var pos : Vector;
		
		battleArea = npc.GetBattleArea();
		if ( !battleArea )
		{
			return BTNS_Failed;
		}
		
		myPos = npc.GetWorldPosition();
		targetPos = battleArea.GetSlotPositionForNPC( npc );
		
		distH = VecDistance2D( myPos, targetPos );
		distV = AbsF( myPos.Z - targetPos.Z );
		if( distH <= minDistance || distH >= maxDistance || distV >= maxVerticalDist  )
		{
			return BTNS_Failed;
		}
		
		mac = GetNPC().GetMovingAgentComponent();
		posReachable = mac.CanGoStraightToDestination( targetPos );
		
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

quest function QBattleAreaEnter( battleAreaTag : name, npcTags : array< name >, teleport : bool ) : bool
{
	var battleArea : CBattleArea;
	var npcs : array< CNewNPC >;
	var i,t,s : int;
	battleArea = (CBattleArea)theGame.GetNodeByTag( battleAreaTag );
	if( battleArea )
	{
		for( t=0; t<npcTags.Size(); t+=1 )
		{
			npcs.Clear();
			theGame.GetNPCsByTag( npcTags[t], npcs );
			s = npcs.Size();
			for( i=0; i<s; i+=1 )
			{
				battleArea.EnterArea( npcs[i], teleport );
			}
		}
		
		return true;
	}
	else
	{
		return false;
	}
}

/////////////////////////////////////////////////////////////////////

quest function QBattleAreaClear( battleAreaTag : name, npcTags : array< name > ) : bool
{
	var battleArea : CBattleArea;
	var npcs : array< CNewNPC >;
	var i,t,s : int;
	battleArea = (CBattleArea)theGame.GetNodeByTag( battleAreaTag );
	if( battleArea )
	{
		for( t=0; t<npcTags.Size(); t+=1 )
		{	
			npcs.Clear();
			theGame.GetNPCsByTag( npcTags[t], npcs );
			s = npcs.Size();
			for( i=0; i<s; i+=1 )
			{
				battleArea.ClearArea( npcs[i] );
			}	
		}
		
		return true;
	}
	else
	{
		return false;
	}	
}

/////////////////////////////////////////////////////////////////////
