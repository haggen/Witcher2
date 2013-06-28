class CCoverManager extends CStateMachine
{
	private var covers : array<CCoverGroup>;
	
	private var tempCover : CCoverGroup;
	private var timerOwner : CActor;
	
	function GetCover( coverNumber : int ) : CCoverGroup
	{
		if( coverNumber < 1 || coverNumber > 9 )
		{
			Log( "----------------------ERROR-----------------------" );
			Log( "CCoverManager::GetCover(coverNumber) - doesn't fullfill specified condition ( 1 <= coverNumber <= 9 )." );
			Log( "--------------------------------------------------" );
		}
		
		return covers[coverNumber - 1];
	}
	
	function Initialize()
	{
		var nodes : array<CNode>;
		var i, arraySize : int;
		var cov : CDragonCover;
		var cg : CCoverGroup;
		
		covers.Clear();
		covers.Resize(8);
		
		theGame.GetNodesByTag( 'q001_fire_cover', nodes );
		arraySize = nodes.Size();
		
		for( i = 0; i < arraySize; i += 1 )
		{
			cov = (CDragonCover)nodes[i];
			
			if( cov.coverNumber < 1 || cov.coverNumber > 8 )
			{
				Log( "----------------------WARNING-----------------------" );
				Log( "One or more cover doesn't fullfill specified condition ( 1 <= coverNumber <= 8 )." );
				Log( "This could cause the system to not work properly." );
				Log( "Check if all covers are properly numbered and if there are any redundant covers on the level." );
				Log( "----------------------------------------------------" );
			}
			
			if( !covers[cov.coverNumber - 1] )
				covers[cov.coverNumber - 1] = new CCoverGroup in this;
				
			GetCover(cov.coverNumber).AddCoverToGroup( (CDragonCover)nodes[i] );
		}
		
		covers[0].guardAreaTag = 'q001_dragon_guard_area_1_2';
		covers[0].singleGuardAreaTag = 'q001_dragon_guard_area_1';
		covers[0].attachedCoverGroup = covers[1];
		covers[1].guardAreaTag = 'q001_dragon_guard_area_1_2';
		covers[1].singleGuardAreaTag = 'q001_dragon_guard_area_2';
		covers[1].attachedCoverGroup = covers[0];
		covers[2].guardAreaTag = 'q001_dragon_guard_area_3_4';
		covers[2].singleGuardAreaTag = 'q001_dragon_guard_area_3';
		covers[2].attachedCoverGroup = covers[3];
		covers[3].guardAreaTag = 'q001_dragon_guard_area_3_4';
		covers[3].singleGuardAreaTag = 'q001_dragon_guard_area_4';
		covers[3].attachedCoverGroup = covers[2];
		covers[4].guardAreaTag = 'q001_dragon_guard_area_5_6';
		covers[4].singleGuardAreaTag = 'q001_dragon_guard_area_5';
		covers[4].attachedCoverGroup = covers[5];
		covers[4].alwaysSafeTransfer = true;
		covers[5].guardAreaTag = 'q001_dragon_guard_area_5_6';
		covers[5].singleGuardAreaTag = 'q001_dragon_guard_area_6';
		covers[5].attachedCoverGroup = covers[4];
		covers[4].alwaysSafeTransfer = true;
		covers[6].guardAreaTag = 'q001_dragon_guard_area_7_8';
		covers[6].singleGuardAreaTag = 'q001_dragon_guard_area_7';
		covers[6].attachedCoverGroup = covers[7];
		covers[4].alwaysSafeTransfer = true;
		covers[7].guardAreaTag = 'q001_dragon_guard_area_7_8';
		covers[7].singleGuardAreaTag = 'q001_dragon_guard_area_8';
		covers[7].attachedCoverGroup = covers[6];
		covers[4].alwaysSafeTransfer = true;
		
		cg = new CCoverGroup in this;
		cg.guardAreaTag = 'q001_guard_area_gate';
		cg.singleGuardAreaTag = 'q001_guard_area_gate';
		covers.PushBack( cg );
	}
	
	function AddNewSoldierGroup( groupTag : name, startingCover : CCoverGroup ) : bool
	{
		var nodes : array<CNode>;
		var soldier : CCoverSoldier;
		var size, i : int;
		
		theGame.GetNodesByTag( groupTag, nodes );
		size = nodes.Size();
		
		if( size < 1 )
		{
			Log( "----------------------WARNING-----------------------" );
			Log( "CCoverManager::AddNewSoldierGroup - No nodes with tag '" + groupTag + "' have been found!" );
			Log( "----------------------------------------------------" );
			return false;
		}
		
		for( i = 0; i < size; i += 1 )
		{
			soldier = (CCoverSoldier)nodes[i];
			soldier.currentCover = startingCover;
			soldier.coverManager = this;
			soldier.GetArbitrator().AddGoalIdleAfterCombat(10.0f);
			startingCover.soldiers.PushBack( soldier );
		}
		startingCover.UpdateGuardAreas( false );
		
		return true;
	}
	
	function AddNewMajorNPCs( npcTags : array<name>, startingCover : CCoverGroup ) : bool
	{
		var size, i : int;
		var npc : CNewNPC;
		
		size = npcTags.Size();
		for( i = 0; i < size; i += 1 )
		{
			npc = (CNewNPC)theGame.GetNodeByTag( npcTags[i] );
			if( !npc )
			{
				Log( "----------------------WARNING-----------------------" );
				Log( "CCoverManager::AddNewMajorNPC - No CNewNPC with tag '" + npcTags[i] + "' have been found!" );
				Log( "----------------------------------------------------" );
				return false;
			}
			
			startingCover.majorNPCs.PushBack( npc );
		}
		startingCover.UpdateGuardAreas( true );
		
		return true;
	}
	
	function ProgressTowardGate( fromCoverNumber : int ) : CCoverGroup
	{
		switch( fromCoverNumber )
		{
			case 1:
			{
				if( !covers[1].burned && covers[1].HasSoldiersLeft() )
				{
					return covers[1];
				}
				else if( !covers[4].burned && covers[4].HasSoldiersLeft() )
				{
					return covers[4];
				}
				else if( !covers[5].burned && covers[5].HasSoldiersLeft() )
				{
					return covers[5];
				}
				else if( !covers[6].burned && covers[6].HasSoldiersLeft() )
				{
					return covers[6];
				}
				else
					return covers[8];
			}
			case 2:
			{
				if( !covers[4].burned && covers[4].HasSoldiersLeft() )
				{
					return covers[4];
				}
				else if( !covers[5].burned && covers[5].HasSoldiersLeft() )
				{
					return covers[5];
				}
				else if( !covers[6].burned && covers[6].HasSoldiersLeft() )
				{
					return covers[6];
				}
				else
					return covers[8];
			}
			case 3:
			{
				if( !covers[3].burned && covers[3].HasSoldiersLeft() )
				{
					return covers[3];
				}
				else if( !covers[6].burned && covers[6].HasSoldiersLeft() )
				{
					return covers[6];
				}
				else if( !covers[7].burned && covers[7].HasSoldiersLeft() )
				{
					return covers[7];
				}
				else if( !covers[4].burned && covers[4].HasSoldiersLeft() )
				{
					return covers[4];
				}
				else
					return covers[8];
			}
			case 4:
			{
				if( !covers[6].burned && covers[6].HasSoldiersLeft() )
				{
					return covers[6];
				}
				else if( !covers[7].burned && covers[7].HasSoldiersLeft() )
				{
					return covers[7];
				}
				else if( !covers[4].burned && covers[4].HasSoldiersLeft() )
				{
					return covers[4];
				}
				else
					return covers[8];
			}
			case 5:
			{
				if( !covers[5].burned && covers[5].HasSoldiersLeft() )
				{
					return covers[5];
				}
				else
					return covers[8];
			}
			case 6:
			{
				return covers[8];
			}
			case 7:
			{
				if( !covers[7].burned && covers[7].HasSoldiersLeft() )
				{
					return covers[7];
				}
				else
					return covers[8];
			}
			case 8:
			{
				return covers[8];
			}
		}
	}
	
	function FindNextSafeCover( burnedCoverNumber : int ) : CCoverGroup
	{		
		switch( burnedCoverNumber )
		{
			case 1:
			{
				if( !covers[1].burned )
				{
					return covers[1];
				}
				else if( !covers[2].burned )
				{
					return covers[2];
				}
				else if( !covers[4].burned )
				{
					return covers[4];
				}
				else if( !covers[3].burned )
				{
					return covers[3];
				}
				else if( !covers[5].burned )
				{
					return covers[5];
				}
				else if( !covers[6].burned )
				{
					return covers[6];
				}
				else if( !covers[7].burned )
				{
					return covers[7];
				}
				else
					return covers[8];
				break;
			}
			case 2:
			{
				if( !covers[0].burned )
				{
					return covers[0];
				}
				else if( !covers[4].burned )
				{
					return covers[4];
				}
				else if( !covers[3].burned )
				{
					return covers[3];
				}
				else if( !covers[5].burned )
				{
					return covers[5];
				}
				else if( !covers[6].burned )
				{
					return covers[6];
				}
				else if( !covers[7].burned )
				{
					return covers[7];
				}
				else
					return covers[8];
				break;
			}
			case 3:
			{
				if( !covers[3].burned )
				{
					return covers[3];
				}
				else if( !covers[0].burned )
				{
					return covers[0];
				}
				else if( !covers[6].burned )
				{
					return covers[6];
				}
				else if( !covers[1].burned )
				{
					return covers[1];
				}
				else if( !covers[7].burned )
				{
					return covers[7];
				}
				else if( !covers[4].burned )
				{
					return covers[4];
				}
				else if( !covers[5].burned )
				{
					return covers[5];
				}
				else
					return covers[8];
				break;
			}
			case 4:
			{
				if( !covers[2].burned )
				{
					return covers[2];
				}
				else if( !covers[6].burned )
				{
					return covers[6];
				}
				else if( !covers[7].burned )
				{
					return covers[7];
				}
				else if( !covers[1].burned )
				{
					return covers[1];
				}
				else if( !covers[4].burned )
				{
					return covers[4];
				}
				else if( !covers[5].burned )
				{
					return covers[5];
				}
				else
					return covers[8];
				break;
			}
			case 5:
			{
				if( !covers[5].burned )
				{
					return covers[5];
				}
				else
					return covers[8];
				break;
			}
			case 6:
			{
				if( !covers[4].burned )
				{
					return covers[4];
				}
				else
					return covers[8];
				break;
			}
			case 7:
			{
				if( !covers[7].burned )
				{
					return covers[7];
				}
				else
					return covers[8];
				break;
			}
			case 8:
			{
				if( !covers[6].burned )
				{
					return covers[6];
				}
				else
					return covers[8];
				break;
			}
		}
		
		return NULL;
	}
	
	function CheckIfPhaseEnded()
	{
		if( !covers[4].HasSoldiersLeft() && !covers[6].HasSoldiersLeft() && !covers[8].HasSoldiersLeft() )
		{
			FactsAdd( 'q001_first_phase_ended', 1 );
			theGame.dragon.OnFirstPhaseEnded();
		}
	}
	
	event OnPlayerAtGate()
	{
		var i, j, size : int;
		
		for( i = 0; i < 4; i += 1 )
		{
			size = covers[i].soldiers.Size();
			for( j = size - 1; j >= 0; j -= 1 )
			{
				covers[i].soldiers[j].Kill();//.EnterDead();
			}
		}
		
		for( i = 4; i < 8; i += 1 )
		{
			covers[i].TransferNPCToNewCover( covers[8], false );
		}
		
		for( i = 0; i < 8; i += 1 )
		{
			covers[i].TransferNPCToNewCover( covers[8], true );
		}
	}
	
	event OnSoldierDeath( soldier : CCoverSoldier )
	{
		soldier.currentCover.soldiers.Remove( soldier );
		
		if( !soldier.currentCover.HasSoldiersLeft() )
		{
			if( soldier.currentCover.majorNPCs.Size() > 0 )
			{
				DelayedTransfer( soldier.currentCover );
			}
			CheckIfPhaseEnded();
		}
		/*else if( soldier.currentCover.attachedCoverGroup.majorNPCs.Size() > 0 )
		{
			if( soldier.currentCover.attachedCoverGroup.soldiers.Size() == 0 )
			{
				soldier.currentCover.attachedCoverGroup.TransferNPCToNewCover( ProgressTowardGate( soldier.currentCover.attachedCoverGroup.covers[0].coverNumber ), true );
			}
		}*/
	}
	
	event OnCoverStartBurning( cover : CDragonCover )
	{
		var cg : CCoverGroup;
		var size, i : int;
		
		cg = GetCover( cover.coverNumber );
		
		size = cg.covers.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( cg.covers[i] != cover )
			{
				cg.covers[i].burnCover();
			}
		}
	}
	
	event OnCoverBurned( coverNumber : int )
	{
		var cg : CCoverGroup;
		
		cg = GetCover(coverNumber);
		if( !cg || cg.burned )
			return false;
		
		cg.burned = true;
		cg.EraseDeadNPCs();
		
		if( cg.soldiers.Size() > 0 )
			cg.TransferNPCToNewCover( FindNextSafeCover( coverNumber ), false );
		
		if( cg.majorNPCs.Size() > 0 )
			cg.TransferNPCToNewCover( ProgressTowardGate( coverNumber ), true );
		else if( cg.attachedCoverGroup.majorNPCs.Size() > 0 )
			cg.attachedCoverGroup.UpdateGuardAreas( true );
	}
	
	event OnCoverAttacked( coverNumber : int )
	{
		var cg : CCoverGroup;
		
		cg = GetCover( coverNumber );
		cg.safeExit = false;
		cg.attachedCoverGroup.safeExit = false;
	}
	
	event OnCoverAttackStopped( coverNumber : int )
	{
		var cg : CCoverGroup;
		
		cg = GetCover( coverNumber );
		cg.safeExit = true;
		cg.attachedCoverGroup.safeExit = true;
	}
}

state Default in CCoverManager
{
	entry function DelayedTransfer( fromCover : CCoverGroup )
	{
		while( true )
		{
			if( fromCover.burned )
			{
				break;
			}
			else if( fromCover.alwaysSafeTransfer || (fromCover.safeExit && !fromCover.IsPlayerInside()) )
			{
				fromCover.TransferNPCToNewCover( parent.ProgressTowardGate( fromCover.covers[0].coverNumber ), true );
				break;
			}
			Sleep( 0.5f );
		}
	}
	
	entry function BreakAll()
	{
	}
}

class CCoverGroup
{
	var covers : array<CDragonCover>;
	var soldiers : array<CCoverSoldier>;
	var majorNPCs : array<CNewNPC>;
	var guardAreaTag : name;
	var singleGuardAreaTag : name;
	var attachedCoverGroup : CCoverGroup;
	var burned : bool;
	var safeExit : bool;
	var alwaysSafeTransfer : bool;
	
	default safeExit = true;
	default alwaysSafeTransfer = false;
	
	function IsPlayerInside( optional dontCheckAttached : bool ) : bool
	{
		var sizeI, sizeJ, i, j : int;
		
		sizeI = covers.Size();
		for( i = 0; i < sizeI; i += 1 )
		{
			sizeJ = covers[i].BreathCoveringActors.Size();
			for( j = 0; j < sizeJ; j += 1 )
			{
				if( covers[i].BreathCoveringActors[j] == thePlayer )
					return true;
			}
		}
		
		if( dontCheckAttached )
			return false;
		else
			return attachedCoverGroup.IsPlayerInside( true );
	}
	
	function HasSoldiersLeft() : bool
	{
		if( !burned && soldiers.Size() > 0 )
			return true;
		else return (!attachedCoverGroup.burned && attachedCoverGroup.soldiers.Size() > 0);
	}
	
	function AddCoverToGroup( cover : CDragonCover )
	{
		covers.PushBack( cover );
		
		if( covers.Size() > 2 )
		{
			Log( "----------------------WARNING-----------------------" );
			Log( "The number of covers in one group have exeeded 2 which is inconsistent with current design." );
			Log( "This could cause the system to not work properly." );
			Log( "Check if there are any redundant covers on the level (objects with tag 'q001_fire_cover' should count 16)." );
			Log( "----------------------------------------------------" );
		}
	}
	
	function UpdateGuardAreas( updateMajor : bool )
	{
		var size, i : int;
		var tag : name;
		
		if( attachedCoverGroup.burned )
			tag = singleGuardAreaTag;
		else
			tag = guardAreaTag;
			
		if( updateMajor )
		{
			size = majorNPCs.Size();
			for( i = 0; i < size; i += 1 )
			{
				majorNPCs[i].SetGuardArea( tag );
			}
		}
		else
		{
			size = soldiers.Size();
			for( i = 0; i < size; i += 1 )
			{
				soldiers[i].SetGuardArea( tag );
			}
		}
	}
	
	function TransferNPCToNewCover( newCover : CCoverGroup, transferMajor : bool )
	{
		var size, i : int;
		
		if( transferMajor )
			size = majorNPCs.Size();
		else
			size = soldiers.Size();
			
		if( size == 0 )
			return;
		
		for( i = 0; i < size; i += 1 )
		{
			if( !newCover )
			{
				if( transferMajor )
					majorNPCs[i].ClearGuardArea();
				else
				{
					soldiers[i].currentCover = NULL;
					soldiers[i].ClearGuardArea();
				}
			}
			else
			{
				if( transferMajor )
					newCover.majorNPCs.PushBack( majorNPCs[i] );
				else
				{
					soldiers[i].currentCover = newCover;
					newCover.soldiers.PushBack( soldiers[i] );
				}
			}
		}
		
		if( transferMajor )
			majorNPCs.Clear();
		else
			soldiers.Clear();
			
		newCover.UpdateGuardAreas( transferMajor );
	}
	
	function EraseDeadNPCs()
	{
		var size, i : int;
		
		size = soldiers.Size();
		for( i = size - 1; i >= 0; i -= 1 )
		{
			if( !soldiers[i].IsAlive() )
				soldiers.Erase(i);
		}
	}
}

class CCoverSoldier extends CNewNPC
{
	var coverManager : CCoverManager;
	var currentCover : CCoverGroup;
	
	private function EnterDead( optional deathData : SActorDeathData )
	{
		super.EnterDead(deathData);
		coverManager.OnSoldierDeath( this );
	}
}

quest function Q001_AddSoldierGroupToManager( groupTag : name, startingCoverNumber : int ) : bool
{
	var startingCover : CCoverGroup;
	
	if( startingCoverNumber < 1 || startingCoverNumber > 9 )
	{
		Log( "----------------------WRONG INPUT-----------------------" );
		Log( "AddNPCGroupToManager - Starting cover number should be a number between 1 and 9 inclusive." );
		Log( "--------------------------------------------------------" );
		return false;
	}
	
	if( !theGame.dragon )
	{
		Log( "----------------------ERROR-----------------------" );
		Log( "AddNPCGroupToManager - Must be called after the dragon spawn." );
		Log( "--------------------------------------------------" );
		return false;
	}
	
	startingCover = theGame.dragon.GetCoverManager().GetCover( startingCoverNumber );
	if( !startingCover )
	{
		Log( "----------------------WRONG INPUT-----------------------" );
		Log( "AddNPCGroupToManager - startingCoverNumber is invalid, no cover with that number(" + startingCoverNumber + ")." );
		Log( "--------------------------------------------------------" );
		return false;
	}
	
	return theGame.dragon.GetCoverManager().AddNewSoldierGroup( groupTag, startingCover );
}

quest function Q001_AddMajorNPCsToManager( npcTags : array<name>, startingCoverNumber : int ) : bool
{
	var startingCover : CCoverGroup;
	
	if( startingCoverNumber < 1 || startingCoverNumber > 9 )
	{
		Log( "----------------------WRONG INPUT-----------------------" );
		Log( "AddMajorNPCToManager - Starting cover number should be a number between 1 and 9 inclusive." );
		Log( "--------------------------------------------------------" );
		return false;
	}
	
	if( !theGame.dragon )
	{
		Log( "----------------------ERROR-----------------------" );
		Log( "AddMajorNPCToManager - Must be called after the dragon spawn." );
		Log( "--------------------------------------------------" );
		return false;
	}
	
	startingCover = theGame.dragon.GetCoverManager().GetCover( startingCoverNumber );
	if( !startingCover )
	{
		Log( "----------------------WRONG INPUT-----------------------" );
		Log( "AddMajorNPCToManager - startingCoverNumber is invalid, no cover with that number(" + startingCoverNumber + ")." );
		Log( "--------------------------------------------------------" );
		return false;
	}
	
	return theGame.dragon.GetCoverManager().AddNewMajorNPCs( npcTags, startingCover );
}

quest function Q001_NotifyPlayerAtGate()
{
	theGame.dragon.GetCoverManager().OnPlayerAtGate();
	theGame.dragon.RemoveTimer( 'KeepPlayerCombatMode' );
}

exec function BurnBaby( num : int )
{
	var cover : CCoverGroup;
	
	cover = theGame.dragon.GetCoverManager().GetCover( num );
	cover.covers[0].burnCover();
	cover.covers[1].burnCover();
}