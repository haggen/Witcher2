/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** W2FistfightArea
/** Copyright © 2010
/***********************************************************************/

struct W2FistfightAreaTimetableEntry
{
	editable var interval : GameTimeInterval;
	editable var npcTag : name;
};

class W2FistfightArea extends CGameplayEntity
{	
	private saved editable var areaActive : bool;
	editable var timetable : array< W2FistfightAreaTimetableEntry >;
	editable var waypointTag : name;
	private var activeEntryIdx : int;
	private var fighter0 : CNewNPC;
	private var fighter1 : CNewNPC;

	default areaActive = true;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		activeEntryIdx = -1;
		if( areaActive )
		{
			AddTimer( 'Tick', 5.0, true, true );		
		}
	}
	
	public function SetAreaActive( flag : bool )
	{
		areaActive = flag;
		Tick( 0.0 );
		if( areaActive )
		{
			AddTimer( 'Tick', 5.0, true, true );
		}
		else
		{
			RemoveTimer('Tick');
		}
	}
	
	public function GetOtherNPC( npc : CNewNPC ) : CNewNPC
	{
		if( npc == fighter0 )
			return fighter1;
		else if( npc == fighter1 )
			return fighter0;
		else 
			return NULL;
	}

	private function ShowError( text : string )
	{
		thePlayer.GetVisualDebug().AddText(
			'combatAreaError',
			StrFormat("W2CombatArea %1: %2", GetName(), text),
			GetWorldPosition() + Vector(0,0,1),
			true,
			0,
			Color(255, 0, 0), 
			true
		);
	}
		
	private timer function Tick( td : float )
	{
		var i,s, newEntryIdx : int;
		var gt : GameTime;
		var tag : name;
		s = timetable.Size();
		gt = theGame.GetGameTime();
		
		newEntryIdx = -1;
		
		if( areaActive )
		{		
			for( i=0; i<s; i+=1 )
			{
				if( GameTimeIntervalContainsTime( gt, timetable[i].interval, true ) )
				{
					newEntryIdx = i;				
					break;
				}
			}
		}
		
		if( newEntryIdx >= 0 )
		{
			if( newEntryIdx != activeEntryIdx )
			{
				if( activeEntryIdx >= 0 )
				{
					//Stop current combat
					RemoveGoals();
					activeEntryIdx = -1;
				}
			
				//Start new combat
				tag = timetable[newEntryIdx].npcTag;
				
				if( !IsNameValid( tag ) )
				{
					ShowError( "npcTag not defined" );	
				}
				
				if( StartCombat( tag ) )
				{
					activeEntryIdx = newEntryIdx;
				}
				else
				{
					activeEntryIdx = -1;
				}
			}
			else
			{
				if( !fighter0 || !fighter1 )
				{
					//Stop current combat
					RemoveGoals();
					activeEntryIdx = -1;
				}
			}
		}
		else
		{
			if( activeEntryIdx >= 0 )
			{
				//Stop current combat
				RemoveGoals();
				activeEntryIdx = -1;
			}
		}
	}
		
	private function GetArea() : CAreaComponent
	{
		return (CAreaComponent)GetComponentByClassName( 'CAreaComponent' );
	}
	
	private function StartCombat( npcTag : name ) : bool
	{
		var npcs : array<CNewNPC>;
		var npc : CNewNPC;
		var i,s : int;
		var area : CAreaComponent = GetArea();
		var overlap : bool;
		var npcPos : Vector;
		
		theGame.GetNPCsByTag( npcTag, npcs );
		s = npcs.Size();
		
		if( s > 1 )
		{
			for( i=s-1; i>=0; i-=1 )
			{
				npc = npcs[i];
				npcPos = npc.GetWorldPosition();
				npcPos.Z += 0.3;
				overlap = area.TestPointOverlap( npcPos );
				if( overlap == false || npc.GetCurrentStateName() != 'Idle' )
				{
					npcs.Erase( i );
				}
			}
			
			s = npcs.Size();			
			if( s > 1 )
			{
				fighter0 = npcs[0];
				fighter1 = npcs[1];				
				AddGoals();
				return true;
			}
		}
		
		return false;
	}
		
	private function AddGoals()
	{
		var pos, dir : Vector;
		var rot : EulerAngles;
		var offset : Vector;
		var pos0, pos1 : Vector;
		var rot0, rot1 : EulerAngles;
		
		if( !GetCombatOrientation( pos, rot ) )
		{
			pos = GetWorldPosition();
			rot = GetWorldRotation();
			ShowError( "waypoint not defined" );
		}
		
		dir = RotForward( rot );
		offset = dir * 0.6;
		
		pos0 = pos - offset;
		pos1 = pos + offset;		
		
		rot0 = rot;
		rot1 = rot;
		rot1.Yaw += 180.0;
		
		fighter0.GetArbitrator().AddGoalFistfightAreaEnter( this, pos0, rot0, MT_Run );
		fighter1.GetArbitrator().AddGoalFistfightAreaEnter( this, pos1, rot1, MT_Run );
		fighter0.GetArbitrator().AddGoalFistfightAreaCombat( fighter1, pos0, this );		
		fighter1.GetArbitrator().AddGoalFistfightAreaCombat( fighter0, pos1, this );
		
		fighter0.NoticeActor( fighter1 );
		fighter1.NoticeActor( fighter0 );
	}
	
	private function RemoveGoals()
	{
		if( fighter0 )
		{
			fighter0.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalFistfightAreaCombat' );
			fighter0.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalFistfightAreaEnter' );	
			fighter0 = NULL;
		}
		
		if( fighter1 )
		{
			fighter1.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalFistfightAreaCombat' );		
			fighter1.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalFistfightAreaEnter' );
			fighter1 = NULL;
		}
	}
	
	private function GetCombatOrientation( out pos : Vector, out rot : EulerAngles ) : bool
	{
		var node : CNode;
		if( IsNameValid( waypointTag ) )
		{
			node = theGame.GetNodeByTag( waypointTag );
			if( node )
			{
				pos = node.GetWorldPosition();
				rot = node.GetWorldRotation();
				return true;
			}
		}
		
		pos = GetWorldPosition();
		rot = GetWorldRotation();
		return false;
	}
	
	event OnBreakCombat( npc : CNewNPC )
	{
		if( activeEntryIdx >= 0 && ( npc == fighter0 || npc == fighter1 ) )
		{
			RemoveGoals();
			activeEntryIdx = -1;
		}
	}
};