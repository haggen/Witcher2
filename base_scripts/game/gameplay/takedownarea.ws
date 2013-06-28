/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** W2TakedownArea
/** Copyright © 2010
/***********************************************************************/

enum W2TakedownAreaType
{
	TAT_Aard,
};

class W2TakedownArea extends CEntity
{	
	private editable var takedownAreaType : W2TakedownAreaType;
	private var npcsInside : array<CNewNPC>;	
	private var disabled : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		npcsInside.Clear();
		disabled = false;
	}
	
	function GetTakedownAreaType() : W2TakedownAreaType
	{
		return takedownAreaType;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity = activator.GetEntity();
		var player : CPlayer = thePlayer; // compiler hack
		var npc : CNewNPC;
		
		if( entity.IsA('CNewNPC') )
		{
			npc = (CNewNPC)entity;
			if( npc.IsAlive() && !npcsInside.Contains(npc) )
			{
				npcsInside.PushBack(npc);
			}
		}
		else if( entity.IsA('CPlayer') )
		{
			player.currentTakedownArea = this;
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity = activator.GetEntity();
		var player : CPlayer = thePlayer; // compiler hack
		var npc : CNewNPC;
		var idx : int;
		
		if( entity.IsA('CNewNPC') )
		{
			npc = (CNewNPC)entity;
			npcsInside.Remove(npc);
		}
		else if( entity.IsA('CPlayer') )
		{
			player.currentTakedownArea = NULL;
		}
	}
	
	final function AardTakedownTest( npc : CNewNPC ) : bool
	{
		var destPos, playerPos, npcPos : Vector;
		var playerDist : float;
		
		if( !disabled && takedownAreaType == TAT_Aard )
		{	
			if( IsNPCInside( npc ) && GetDestination() )
			{
				destPos = GetDestination().GetWorldPosition();
				playerPos = thePlayer.GetWorldPosition();
				npcPos = npc.GetWorldPosition();
				
				playerDist = VecDistance( destPos, playerPos );
				
				if( VecDistance( npcPos, destPos ) + 0.7 < playerDist )
				{
					if( VecDistanceToEdge( npcPos, destPos, playerPos ) < 1.0 )
					{
						disabled = true;
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	final function IsNPCInside( npc : CNewNPC ) : bool
	{
		return npcsInside.Contains( npc );
	}
	
	final function IsAnyNPCInside() : bool
	{
		return npcsInside.Size() > 0;
	}
	
	private final function RemoveDeadNPCs()
	{
		var i : int;
		for( i = npcsInside.Size() - 1; i>=0; i-=1 )
		{
			if( !npcsInside[i].IsAlive() )
			{
				npcsInside.Erase(i);
			}
		}
	}
		
	final function SelectNPC() : CNewNPC
	{
		var npcList : array<CNewNPC>;
		var i,s : int;
		var destPos : Vector = GetDestination().GetWorldPosition();
		var playerDist : float;
		playerDist = VecDistance( destPos, thePlayer.GetWorldPosition() );
		
		RemoveDeadNPCs();
		
		s = npcsInside.Size();
		for( i = 0; i<s; i += 1 )
		{
			if( VecDistance( npcsInside[i].GetWorldPosition(), destPos ) + 0.5 < playerDist )
			{
				npcList.PushBack( npcsInside[i] );
			}
		}
		
		if( npcList.Size() > 0 )
		{
			return npcList[0];
		}
		
		return NULL;
	}
	
	final function GetDestination() : CNode
	{
		return this;
	}
	
	final function PerformEndAction()
	{
		RaiseEvent('close');
	}
};
