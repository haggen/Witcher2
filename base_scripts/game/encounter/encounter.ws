/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Encounter System
/** Copyright © 2010
/***********************************************************************/

class AreaType
{
	// Interface

	function InitSpawnedMonster( npc : CNewNPC )
	{
	}
	
	// The lower value, the higher priorty for the area type (across other area types)
	function GetPriority() : int
	{
		return -1;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function IsSpawningNearPlayer() : bool
	{
		return true;
	}
	
	function IsInitialSpawnEnabled() : bool
	{
		return false;
	}

	function IsSpawnWave( timeDelta : float ) : bool
	{
		spawnIntervalTimer += timeDelta;
		if ( spawnIntervalTimer >= spawnIntervalFactor )
		{
			spawnIntervalTimer = 0;
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function GetTypeNameByPriority( priority : int ) : string
	{
		if ( priority == 0 )
		{
			return "Nesting";
		}
		else if ( priority == 1 )
		{
			return "Territorial";
		}
		else if ( priority == 2 )
		{
			return "Patrol";
		}
		else
		{
			return "UnknownTypeName";
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	function InitVariables()
	{
		spawnIntervalTimer = 0;
	}

	editable var spawnIntervalFactor : float; // spawn attempt frequency in seconds
	         var spawnIntervalTimer  : float;

	default spawnIntervalTimer  = 0;
	default spawnIntervalFactor = 10;
}

class PatrolingArea extends AreaType
{
	function InitSpawnedMonster( npc : CNewNPC )
	{		
	}
	
	function IsSpawningNearPlayer() : bool
	{
		return false;
	}
	
	function IsInitialSpawnEnabled() : bool
	{
		return true;
	}

	function GetPriority() : int
	{
		return 2;
	}
}

class TerritorialArea extends AreaType
{
	function InitSpawnedMonster( npc : CNewNPC )
	{
		if( !thePlayer.IsHidden() )
		{
			npc.NoticeActor( thePlayer );
		}
	}

	function GetPriority() : int
	{
		return 1;
	}
	
	function IsInitialSpawnEnabled() : bool
	{
		return true;
	}
}

class NestingArea extends AreaType
{
	function InitSpawnedMonster( npc : CNewNPC )
	{
		if( !thePlayer.IsHidden() )
		{
			npc.NoticeActor( thePlayer );
		}
	}

	function GetPriority() : int
	{
		return 0;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

enum EEncounterSpawnType
{
	EST_APPEAR,
	EST_HIDDEN,
	EST_DONT_CARE
};

//enum ENpcSenseType
//{
//	NST_ABSOLUTE,
//	NST_MEET,
//	NST_HEARING,
//	NST_VISION
//};

//////////////////////////////////////////////////////////////////////////////////////////

import struct SMonsterTimetableEntry
{
	import public var actionCategory : name;
	import public var weight         : float;
	import public var tags           : array< name >;
};

struct SMonsterEntryData
{
	var npc                 : CNewNPC;
	var despawnTimer        : float;
	var despawnSquaredRange : float;
	var isDespawning        : bool;
};

class MonsterEntry
{
	// Monster will be spawned based on this entity template.
	editable         var entityTemplate          : CEntityTemplate;
	
	// On spawn wave the number of monsters to spawn will be a random number
	// between 'quantityMin' and 'quantityMax'.
	editable         var quantityMin             : int;
	editable         var quantityMax             : int;
	
	// Every monster that is about to spawn has a random spawn delay timer, so every monster
	// will not spawn at the same time. If encounter wants to spawn 5 monsters and
	// 'spawnDelay' is set to 6 seconds than every monster will have random spawn delay between 0 and 6.
	editable         var spawnDelay                   : float; // in seconds
	
	// When player gets out of the encounter every spawned monster will despawn after ('despawnDelayMin', 'despawnDelay') seconds.
	editable         var despawnDelayMin              : float; // in seconds
	editable         var despawnDelay                 : float; // in seconds
	
	
	// Every monster has despawn timer set to 'despawnTimer' value. If player is far away from
	// a monster than this timer is decreased and once it reaches 0, the monster is despawned.
	editable         var despawnTimer                 : float; // in seconds >0
	
	// This it the maximum number of monsters that can be at the same time in encounter.
	editable         var maxCreatures                 : int;
	
	// Maximum creatures that can be spawned, negative numer means unlimited total creatures.
	editable         var totalCreatures               : int;
	
	// Decides if monster will be spawned in the camera view, outside camera view or that we don't care.
	editable         var spawnType                    : EEncounterSpawnType;
	
	// Decides if monster will be spawned with rotation to player (takesRotationFromSpawnPoint = false) or with spawn point rotation (true)
	editable         var takesRotationFromSpawnPoint  : bool;
	
	// Used only if area type is 'patrolling' and there are custom spawn points available
	// Spawn point will not be used again for 'spawnPointTTL' real time seconds.
	editable         var spawnPointTTL                : float;
	
	// Monster will be spawned within the distance (spawnRangeMin, spawnRangeMax) from player.
	editable         var spawnRangeMin                : float;
	editable         var spawnRangeMax                : float;
	
	// If 'spawnCenterTag' is set, then monsters will spawn around entity with this tag
	// (not around player).
	editable         var spawnCenterTag               : name;
	
	// If 'spawnPointTag' is set, then monsters will be spawned in encounter spawnpoints with this tag set only.
	// Of course it will work only on encounter types that uses user placed encounter spawnpoints.
	editable         var spawnPointTag                : name;
	
	// Monsters will try to pursuit player even if he leaves encounter but not farther than 'pursuitRange'.
	editable         var pursuitRange                 : float;
	
	// Spawn Point Shifting
	// If player is moving then spawn points will be shifted according to the player velocity vector,
	// so monsters will be spawned before player. This option applies only for Nesting and Territorial areas.
	// This is useful when monster spawn time is greater than zero (e.g. monster has to unbury or get down from a tree).
	// This value should be the greater the greater is monster's spawn time.
	// Value 0 disables Spawn Point Shifting.
	editable         var playerVelocityShiftMultipier : float; // >= 0

	// Monsters, when they are not fighting, will work on action points if 'defaultBehavior' is defined.
	// If 'defaultBehavior' is empty - monsters will wander inside encounter.
	editable inlined var defaultBehavior         : array< SMonsterTimetableEntry >;
	
	// remove despawned or killed monsters
	function RemoveKilledMonsters() : int
	{
		var removedMonstersCount : int = 0;
		var i : int;
		for ( i = spawnedMonsters.Size() - 1; i >= 0; i -= 1 )
		{
			if ( ! spawnedMonsters[i].npc )
			{
				spawnedMonsters.Erase( i );
				removedMonstersCount += 1;
			}
			else if ( spawnedMonsters[i].npc.IsDead() )
			{
				spawnedMonsters.Erase( i );
				removedMonstersCount += 1;
			}
		}
		
		return removedMonstersCount;
	}
	
	function InitRandomDespawnTimers()
	{
		var i : int;

		for ( i = spawnedMonsters.Size() - 1; i >= 0; i -= 1 )
		{
			spawnedMonsters[i].despawnTimer = RandRangeF( despawnDelayMin, despawnDelay );
		}
	}
	function InitFixedDespawnTimers()
	{
		var i : int;

		// When the encounter is disabled, every spawned monster will despawn after (1, 3) seconds
		for ( i = spawnedMonsters.Size() - 1; i >= 0; i -= 1 )
		{
			spawnedMonsters[i].despawnTimer = RandRangeF( 0.0, 3.0 );
		}
	}

	function DespawnMonstersTick( playerPos : Vector, despawnDist : float, timeDelta : float )
	{
		var i : int;
		var encounter : CEncounter;
		
		//var squaredDespawnDist : float;
		
		//squaredDespawnDist = despawnDist * despawnDist;
		
		for ( i = spawnedMonsters.Size() - 1; i >= 0; i -= 1 )
		{
			if ( spawnedMonsters[i].npc )
			{
				encounter = (CEncounter)this.GetParent();
				// if one of the many despawn conditions is true, than decrease despawn timer
				// else set despawn timer to the default value (i.e. reset timer)
				if (VecDistanceSquared( playerPos, spawnedMonsters[i].npc.GetWorldPosition() ) > spawnedMonsters[i].despawnSquaredRange || !encounter.IsPlayerInEncounter() || !encounter.IsEnabled())
				{
					spawnedMonsters[i].despawnTimer -= timeDelta;
				}
				else 
				{
					if(encounter.IsEnabled())
					{
						if(encounter.IsPlayerInEncounter())
						{
							// reset despawn timer
							spawnedMonsters[i].despawnTimer = despawnTimer;
						}
						else
						{
							// set despawn timer to random value from despawnDelayMin to despawnDelay
							spawnedMonsters[i].despawnTimer = RandRangeF(despawnDelayMin, despawnDelay);
						}
					}
					else
					{
						spawnedMonsters[i].despawnTimer = RandRangeF(0.0f, 2.0f);
					}
				}
			
				//if ( VecDistanceSquared( playerPos, spawnedMonsters[i].npc.GetWorldPosition() ) > squaredDespawnDist )
				if ( spawnedMonsters[i].despawnTimer <= 0 )
				{
					spawnedMonsters[i].despawnTimer = 0;

					if ( totalMonstersSpawned > 0 ) // should always be true
					{
						totalMonstersSpawned -= 1;
					}
					
					if ( ! spawnedMonsters[i].isDespawning )
					{
						spawnedMonsters[i].isDespawning = true;
						spawnedMonsters[i].npc.GetArbitrator().AddGoalDespawn();
					}
				}
			}
		}
	}
	
	function DespawnAllMonsters( timeDelta : float, forceDespawn : bool )
	{
		var i : int;
		
		for ( i = spawnedMonsters.Size() - 1; i >= 0; i -= 1 )
		{
			if ( spawnedMonsters[i].npc )
			{
				spawnedMonsters[i].despawnTimer -= timeDelta;

				if ( spawnedMonsters[i].despawnTimer <= 0 )
				{
					spawnedMonsters[i].despawnTimer = 0;
					
					if ( totalMonstersSpawned > 0 ) // should always be true
					{
						totalMonstersSpawned -= 1;
					}
				
					// Do not despawn monsters that are despawning and that are fighting
					if ( ! spawnedMonsters[i].isDespawning && 
                        (! spawnedMonsters[i].npc.IsInCombat() || forceDespawn ) )
					{
						spawnedMonsters[i].isDespawning = true;
						spawnedMonsters[i].npc.GetArbitrator().AddGoalDespawn();
					}
				}
			}
		}
	}

	function AddSpawnedMonster( npc : CNewNPC )
	{
		var monsterEntry : SMonsterEntryData;
		
		totalMonstersSpawned += 1;
		
		monsterEntry.npc = npc;
		monsterEntry.despawnTimer = despawnTimer;
		monsterEntry.despawnSquaredRange = npc.GetPerceptionRange();
		monsterEntry.despawnSquaredRange = monsterEntry.despawnSquaredRange * monsterEntry.despawnSquaredRange;
		monsterEntry.isDespawning = false;
		spawnedMonsters.PushBack( monsterEntry );
	}
	
	function GetSpawnCenter() : Vector
	{
		if ( spawnCenterTag == '' )
		{
			return thePlayer.GetWorldPosition();
		}
		else
		{
			if ( !spawnCenterNode )
			{
				spawnCenterNode = theGame.GetNodeByTag( spawnCenterTag );
			}
			if ( spawnCenterNode )
			{
				return spawnCenterNode.GetWorldPosition();
			}
			else
			{
				LogChannel( 'encounter', "Cannot find spawn center node with tag " + spawnCenterTag );
				return thePlayer.GetWorldPosition();
			}
		}
	}
	
	function InitVariables()
	{
		totalMonstersSpawned = 0;
		spawnedMonsters.Clear();
	}

	var totalMonstersSpawned : int;
	var spawnedMonsters      : array < SMonsterEntryData >;
	var spawnCenterNode : CNode;

	default totalMonstersSpawned = 0;
	default despawnTimer = 5;
}

struct MonsterEntrySpawn
{
	var monsterEntryIndex : int;
	var delay             : float;

	default monsterEntryIndex = 0;
	default delay = 0;
}

struct MonsterEntrySave
{
	saved var killedMonstersCount : int;
	
	default killedMonstersCount = 0;
}

/////////////////////////////////////////////
// Encounter class
/////////////////////////////////////////////
import class CEncounter extends CGameplayEntity
{	
	import final function FindSpawnPoint( spawnType : EEncounterSpawnType, center : Vector, radiusMin : float, radiusMax : float,
										  playerVelocityShiftMultipier : float, out spawnPoint : Vector ) : bool;
	import final function FindSpawnPointsInArea( spawnType : EEncounterSpawnType, spawnPointsNum : int, spawnRangeMin : float, spawnRangeMax : float, 
												 spawnPointTag : name, out spawnPoints : array< Vector >, out spawnRots : array< EulerAngles > ) : int;
	import final function AddSpawnStrafe( yawAngle : float );
	import final function SetScheduleForNPC( npc : CNewNPC, timetable : array< SMonsterTimetableEntry > );
	import final function GetPlayerDistFromArea() : float;
	import final function GetEncounterArea() : CTriggerAreaComponent;
	import final function IsPlayerInEncounterArea() : bool;
	import final function SetDebugStatus( status : string );
	import final function AddDebugStatus( status : string );
	import final function ClearDebugStatus();
	import final function SetSpawnPointTTL( spawnPointTTL : float );

	// Returns 'true' if encounter is enabled and working (includes time disactivation)
	public function IsEnabled() : bool
	{
		return IsEncounterActive();
	}

	// Enables/disables encounter
	public function SetEnableState( enable : bool )
	{
		isEnabled = enable;
		
		// Do initialization on enabling
		if ( IsEncounterActive() )
		{
			if ( IsPlayerInEncounterArea() )
			{
				// Initial spawn
				if ( areaType.IsInitialSpawnEnabled() )
				{
					InitialAreaSpawn();
				}
			}
		}
		// Do deinitialization on disabling
		else
		{
			// When the encounter is disabled, every spawned monster will despawn after (1, 3) seconds
			SetSpawnEnable(false);
			monstersToSpawn.Clear();
			InitFixedDespawnTimersForAllMonsters();
			DespawnAllMonsters( 0.0, true );
		}
	}
	
	public function SetSpawnEnable( enable : bool )
	{
		if ( enable )
		{
			CheckForResetMonstersSpawnedCounter();
		}
		isEncounterSpawnEnabled = enable;
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var k              : int;
		var spawnPos       : Vector;
		var spawnRot       : EulerAngles;
		var affectedEntity : CEntity;

		if ( !isInitialized )
		{
			// We can safely return if encounter wasn't initialized,
			// as on initialization encounter will check if player is inside area
			return false;
		}

		// Remember trigger area
		currentArea = area; // deprecated: currentArea is set on game started event

		// Only player can activate area
		affectedEntity = activator.GetEntity();
		if ( ! affectedEntity.IsA( 'CPlayer' ) )
		{
			return false;
		}
		
		EnterArea();
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity = activator.GetEntity();
		
		if ( !isInitialized )
		{
			return false;
		}

		// Only player can activate area
		if ( ! affectedEntity.IsA( 'CPlayer' ) )
		{
			return false;
		}
		
		LeaveArea();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		isInitialized = false;

		// We have to wait until player is created and then initialize Encounter
		if ( thePlayer )
		{
			InitOnSpawned();
		}
		else
		{
			AddTimer( 'SpawnedTimer', 0.1f, true );
		}
	}
	
	timer function SpawnedTimer( timeDelta : float )
	{
		if ( thePlayer )
		{
			InitOnSpawned();
			RemoveTimer( 'SpawnedTimer' );
		}
	}

	private function InitOnSpawned()
	{
		var i,s : int;
		var slotPos : Vector;
		var slotAngles : EulerAngles;
		var combatSlots : CCombatSlots;

		currentArea = GetEncounterArea();
		
		if ( !IsEncounterValid() )
		{
			LogErr( "Invalid configuration data - encounter will be disabled." );
			return;
		}
		
		InitVariables();
		
		// Set spawn strafes based on combat slots
		combatSlots = thePlayer.GetCombatSlots();
		s = combatSlots.GetNumAllCombatSlots();
		for ( i = 0; i < s; i += 1 )
		{
			slotPos = combatSlots.GetCombatSlotRawLocalPosition( i, 0 );
			slotAngles = VecToRotation( slotPos );
			AddSpawnStrafe( slotAngles.Yaw );
		}
		
		// Check if player started game in area
		if ( IsPlayerInEncounterArea() )
		{
			EnterArea();
		}
		
		AddTimer( 'EncounterTimer', 3.0f, true );
		
		isInitialized = true;
	}

	timer function EncounterTimer( timeDelta : float )
	{
		if ( ! IsEncounterActive() )
		{
			monstersToSpawn.Clear();
			DespawnAllMonsters( timeDelta, forceDespawn );
			return;
		}

		// Update encounter active time
		if ( !wasResetedMonstersCounterAfterReEnter && (isPlayerInArea || isEncounterSpawnEnabled) )
		{
			lastTimeActive = GameTimeToSeconds( theGame.GetGameTime() );
		}
		
		CheckForResetMonstersSpawnedCounter();

		// Spawn monsters
		if ( (isPlayerInArea || isEncounterSpawnEnabled ) && areaType.IsSpawnWave( timeDelta ) )
		{
			SpawnMonsters();
		}
		
		// Despawn monsters
		DespawnMonstersTick( timeDelta );

		UpdateDebugStatus();
	}

	timer function SpawnTimer( timeDelta : float )
	{
		var i : int;
		var isSpawned : bool; // true if at least one monster has been spawned (optimization)
		
		isSpawned = false;
		
		// Don't spawn monsters if player is outside area
		if ( !isPlayerInArea && !isEncounterSpawnEnabled )
		{
			monstersToSpawn.Clear();
		}

		// Update monsters spawn delay and spawn one at tick
		for ( i = monstersToSpawn.Size() - 1; i >= 0; i -= 1 )
		{
			monstersToSpawn[i].delay -= timeDelta;
			if ( !isSpawned && monstersToSpawn[i].delay <= 0 )
			{
				isSpawned = SpawnMonster( monstersToSpawn[i].monsterEntryIndex );
				monstersToSpawn.Erase( i );
			}
		}

		// If none monsters to spawn are left, than remove this timer
		if ( monstersToSpawn.Size() == 0 )
		{
			RemoveTimer( 'SpawnTimer' );
		}
	}

	// Utility methods

	private function ToPlayer() : EulerAngles
	{
		return EulerAngles( 0, theCamera.GetHeading() + 180.0f, 0 );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function EnterArea()
	{
		isPlayerInArea = true;

		// Reset monsters counter
		if ( resetMonstersCounterOnAreaEnter )
		{
			ResetMonstersSpawnedCounter();
		}

		CheckForResetMonstersSpawnedCounter();
		
		// Initial spawn
		if ( IsEncounterActive() && firstPlayerEntry && areaType.IsInitialSpawnEnabled() )
		{
			InitialAreaSpawn();
		}
		
		firstPlayerEntry = false;
	}
	function IsPlayerInEncounter() : bool
	{
		return isPlayerInArea;
	}
	private function LeaveArea()
	{
		isPlayerInArea = false;
		InitRandomDespawnTimersForAllMonsters();
		if ( !resetMonstersCounterAfterReEnter )
		{
			lastTimeActive = GameTimeToSeconds( theGame.GetGameTime() );
			wasResetedMonstersCounterAfterReEnter = true;
		}
	}
	
	private function SpawnMonsters()
	{
		var monsterEntryIndex  : int;
		var monsterQuantity    : int;
		var numMonstersToSpawn : int;
		var i                  : int;
		var npc                : CNewNPC;
		var monEntrySpawn      : MonsterEntrySpawn;
		var shouldAddTimer     : bool;

		// Init values
		numMonstersToSpawn = 0;

		// Only area with the highest priority can spawn monsters
		//if ( ! IsSpawningByAreaTypePriorityEnabled() ) return;

		if ( monstersToSpawn.Size() > 0 )
		{
			shouldAddTimer = false;
		}
		else
		{
			shouldAddTimer = true;
		}

		for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
		{
			RemoveKilledMonsters( monsterEntryIndex );

			monsterQuantity = Rand( monsterEntries[ monsterEntryIndex ].quantityMax - monsterEntries[ monsterEntryIndex ].quantityMin );
			monsterQuantity += monsterEntries[ monsterEntryIndex ].quantityMin;
			
			if ( IsTotalCreaturesReached( monsterEntryIndex ) ) continue;
			
			logSpawnTrials += monsterQuantity;

			for ( i = 0; i < monsterQuantity; i += 1 )
			{
				if ( RollSpawnChance() )
				{
					monEntrySpawn.delay = RandRangeF( 0, monsterEntries[ monsterEntryIndex ].spawnDelay );
					monEntrySpawn.monsterEntryIndex = monsterEntryIndex;

					monstersToSpawn.PushBack( monEntrySpawn );
					numMonstersToSpawn += 1;
				}
			}
			
			logSpawnFailsRollChance += monsterQuantity - numMonstersToSpawn;
			
			LogNotice( "Trying to spawn " + numMonstersToSpawn + " monsters" );
		}
		
		if ( shouldAddTimer && monstersToSpawn.Size() > 0 )
		{
			AddTimer( 'SpawnTimer', 0.1f, true );
		}
	}
	
	// Returns 'true' if monster was spawned
	private function SpawnMonster( monsterEntryIndex : int ) : bool
	{
		var spawnPoint 		: Vector;
		var spawnRot 		: EulerAngles;
		var npc 			: CNewNPC;
		var fleeArea 		: CAreaComponent; 
		
		if ( IsTotalCreaturesReached( monsterEntryIndex ) ) return false;
		
		// do not spawn monsters if player is in scene
		if  ( thePlayer.GetCurrentStateName() == 'Scene' ) return false;

		if ( GetSpawnPoint( monsterEntryIndex, spawnPoint, spawnRot ) )
		{
			npc = (CNewNPC) theGame.CreateEntity( monsterEntries[monsterEntryIndex].entityTemplate, spawnPoint, spawnRot, false, true, true );
			
			if ( npc )
			{
				this.RegisterOwnedEntity(npc);
				fleeArea = GetFleeArea();
				if ( fleeArea )
				{
					npc.SetFleeArea( fleeArea );
				}
			
				npc.SetArea( currentArea, monsterEntries[monsterEntryIndex].pursuitRange );
				areaType.InitSpawnedMonster( npc );
				monsterEntries[monsterEntryIndex].AddSpawnedMonster( npc );
				SetScheduleForNPC( npc, monsterEntries[monsterEntryIndex].defaultBehavior );
				logSpawnedMonsters += 1;
				return true;
			}
			else
			{
				LogErr("SpawnMonster() : Cannot spawn NPC.");
			}
		}
		else
		{
			logSpawnFailsNoSP += 1;
			LogWarn("SpawnMonster() : Spawn point not found.");
		}

		return false;
	}
	
	private function InitialAreaSpawn()
	{
		SpawnMonsters();
	}
	
	// If this method returns false, then we shouldn't spawn more monsters
	private function IsTotalCreaturesReached( monsterEntryIndex : int ) : bool
	{
		if ( monsterEntries[ monsterEntryIndex ].spawnedMonsters.Size() >= monsterEntries[ monsterEntryIndex ].maxCreatures )
		{
			return true;
		}
		
		if ( monsterEntries[ monsterEntryIndex ].totalCreatures < 0 ) // unlimited monster spawn
		{
			return false;
		}
		else if ( monsterEntries[ monsterEntryIndex ].totalMonstersSpawned >= monsterEntries[ monsterEntryIndex ].totalCreatures )
		{
			return true;
		}
		
		return false;
	}
	
	private function GetSpawnPoint( monsterEntryIndex : int, out spawnPoint : Vector, out spawnRot : EulerAngles ) : bool
	{
		var spawnPoints   : array< Vector >;
		var spawnRots     : array< EulerAngles >;
		var spawnType     : EEncounterSpawnType;
		var spawnRangeMin : float;
		var spawnRangeMax : float;
		var playerVelocityShiftMultipier : float;
		var spawnCenter   : Vector;

		// Set spawn type
		spawnType = monsterEntries[ monsterEntryIndex ].spawnType;
		
		playerVelocityShiftMultipier = monsterEntries[ monsterEntryIndex ].playerVelocityShiftMultipier;
		
		// Set spawn range
		GetSpawnRange( monsterEntryIndex, spawnRangeMin, spawnRangeMax );

		if ( areaType.IsSpawningNearPlayer() )
		{
			spawnCenter = monsterEntries[ monsterEntryIndex ].GetSpawnCenter();
			// TODO: check if spawn center is within encounter area
			spawnRot = ToPlayer();
			return FindSpawnPoint( spawnType, spawnCenter, spawnRangeMin, spawnRangeMax, playerVelocityShiftMultipier, spawnPoint );
		}
		else
		{
			SetSpawnPointTTL( monsterEntries[ monsterEntryIndex ].spawnPointTTL );
			if ( FindSpawnPointsInArea( spawnType, 1, monsterEntries[ monsterEntryIndex ].spawnRangeMin,
				 monsterEntries[ monsterEntryIndex ].spawnRangeMax, monsterEntries[ monsterEntryIndex ].spawnPointTag,
				 spawnPoints, spawnRots ) == 1 )
			{
				spawnPoint = spawnPoints[0];
				if ( monsterEntries[ monsterEntryIndex ].takesRotationFromSpawnPoint )
				{
					spawnRot = spawnRots[0];
				}
				else
				{
					spawnRot = ToPlayer();
				}
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	private function GetSpawnRange( monsterEntryIndex : int, out spawnRangeMin : float, out spawnRangeMax : float )
	{
		var tmp : float;
		
		spawnRangeMin = monsterEntries[monsterEntryIndex].spawnRangeMin;
		spawnRangeMax = monsterEntries[monsterEntryIndex].spawnRangeMax;

		if ( spawnRangeMin > spawnRangeMax )
		{
			tmp = spawnRangeMin;
			spawnRangeMin = spawnRangeMax;
			spawnRangeMax = tmp;
		}

		// spawn range cap
		if ( spawnRangeMin < 2 ) spawnRangeMin = 2;
		if ( spawnRangeMax < 2 ) spawnRangeMax = 2;
	}

	private function DespawnMonstersTick( timeDelta : float )
	{
		var i : int;
		var monsterEntryIndex : int;
		var totalMonsterSpawnedNum : int = 0;
		var playerPos : Vector = thePlayer.GetWorldPosition();
		
		if ( !isEncounterSpawnEnabled )
		{
			for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
			{
				monsterEntries[ monsterEntryIndex ].DespawnMonstersTick( playerPos, despawnDist, timeDelta );
				RemoveKilledMonsters( monsterEntryIndex );
			
				totalMonsterSpawnedNum += monsterEntries[ monsterEntryIndex ].totalMonstersSpawned;
			}
		}
		
		// Renew first player entry variable, so when player enters encounter again,
		// encounter will be initialized (e.g. monsters will spawn)
		if ( totalMonsterSpawnedNum == 0 )
		{
			firstPlayerEntry = true;
		}
	}
	private function InitFixedDespawnTimersForAllMonsters()
	{
		var monsterEntryIndex : int;

		for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
		{
			monsterEntries[ monsterEntryIndex ].InitFixedDespawnTimers();
		}
	}
	private function InitRandomDespawnTimersForAllMonsters()
	{
		var monsterEntryIndex : int;

		for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
		{
			monsterEntries[ monsterEntryIndex ].InitRandomDespawnTimers();
		}
	}
	
	private function DespawnAllMonsters( timeDelta : float, forceDespawn : bool )
	{
		var monsterEntryIndex : int;
		var totalMonsterSpawnedNum : int;
		totalMonsterSpawnedNum = 0;

		for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
		{
			monsterEntries[ monsterEntryIndex ].DespawnAllMonsters( timeDelta, forceDespawn );
			RemoveKilledMonsters( monsterEntryIndex );
			
			totalMonsterSpawnedNum += monsterEntries[ monsterEntryIndex ].totalMonstersSpawned;
		}
		
		// Renew first player entry variable, so when player enters encounter again,
		// encounter will be initialized (e.g. monsters will spawn)
		if ( totalMonsterSpawnedNum == 0 )
		{
			firstPlayerEntry = true;
		}
	}
	
	private function RemoveKilledMonsters( monsterEntryIndex : int )
	{
		var killedMonstersCount : int;
		killedMonstersCount = monsterEntries[ monsterEntryIndex ].RemoveKilledMonsters();
		
		// InitEmptySaveData();
		monsterEntriesSave[ monsterEntryIndex ].killedMonstersCount += killedMonstersCount;
	}
	
	private function IsEncounterValid() : bool
	{
		var isValid : bool;
		
		isValid = true;
		
		if ( !areaType )
		{
			LogErr( "Empty area type." );
			isValid = false;
		}
		
		if ( monsterEntries.Size() == 0 )
		{
			LogErr( "Empty monster entries." );
			isValid = false;
		}

		return isValid;
	}

	// If this method returns true, then encounter system should stop working.
	private function IsEncounterActive() : bool
	{
		var i : int;
		var currentGameTime : GameTime;

		if ( !isEnabled ) return false;
		
		if ( timeActive.Size() == 0 ) return true;

		currentGameTime = theGame.GetGameTime();

		for ( i = 0; i < timeActive.Size(); i += 1 )
		{
			if ( GameTimeIntervalContainsTime( currentGameTime, timeActive[i], true ) )
			{
				return true;
			}
		}
		
		// Spawn enabled
		if ( isEncounterSpawnEnabled ) return true;

		return false;
	}
	
	// Returns true if the monster should be spawned
	private function RollSpawnChance() : bool
	{
		return true;
	}
	
	// Returns true if the monster should be spawned with appear type
	private function RollAppearSpawnChance() : bool
	{
		return false;
	}
	
	private function InitVariables()
	{
		var i : int;

		isPlayerInArea      = false;
		monstersToSpawn.Clear();
		despawnTimer = 0;
		firstPlayerEntry = true;
		isEncounterSpawnEnabled = false;
		resetMonstersCounterAfterSeconds = GameTimeToSeconds(GameTimeCreate( 0, resetMonstersCounterAfterHours, resetMonstersCounterAfterMinutes, 0 ));
		
		// clear logs
		logErrors.Clear();
		logWarnings.Clear();
		logNotice.Clear();
		logSpawnTrials = 0;
		logSpawnedMonsters = 0;
		logSpawnFailsNoSP = 0;
		logSpawnFailsRollChance = 0;
		
		// Init area
		areaType.InitVariables();

		InitEmptySaveData();

		for ( i = 0; i < monsterEntries.Size(); i += 1 )
		{
			monsterEntries[ i ].InitVariables();
			monsterEntries[ i ].totalMonstersSpawned = monsterEntriesSave[ i ].killedMonstersCount;
		}
	}
	
	private function InitEmptySaveData()
	{
		var i : int;

		if ( monsterEntriesSave.Size() != monsterEntries.Size() )
		{
			monsterEntriesSave.Clear();
			for ( i = 0; i < monsterEntries.Size(); i += 1 )
			{
				monsterEntriesSave.PushBack( MonsterEntrySave() );
			}
		}
	}
	
	private function CheckForResetMonstersSpawnedCounter()
	{
		if ( lastTimeActive > 0 &&
			 resetMonstersCounterAfterSeconds > 0 && 
            (GameTimeToSeconds(theGame.GetGameTime()) >= lastTimeActive + resetMonstersCounterAfterSeconds) )
		{
			ResetMonstersSpawnedCounter();
		}
	}
	
	private function ResetMonstersSpawnedCounter()
	{
		var i : int;
		for ( i = 0; i < monsterEntries.Size(); i += 1 )
		{
			monsterEntries[ i ].totalMonstersSpawned = 0;
		}
		
		wasResetedMonstersCounterAfterReEnter = false;
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// Debug methods
	//////////////////////////////////////////////////////////////////////////////////////////

	function LogErr( msg : string )
	{
		if ( logPrintLevel >= 0 )
		{
			LogChannel( 'encounter', "Encounter system error " + GetName() + " : " + msg );
		}
		logErrors.PushBack( msg );
	}

	function LogWarn( msg : string )
	{
		if ( logPrintLevel >= 1 )
		{
			Log( "Encounter system warning " + GetName() + " : " + msg );
		}
		logWarnings.PushBack( msg );
	}

	function LogNotice( msg : string )
	{
		if ( logPrintLevel >= 2 )
		{
			Log( "Encounter system notice " + GetName() + " : " + msg );
		}
		logNotice.PushBack( msg );
	}
	
	function UpdateDebugStatus()
	{
		var timeToSpawnWave           : float;
		var timeToDespawnWave         : float;
		var monsterEntryIndex         : int;
		var encounterTypeFriendlyName : string;
		
		timeToSpawnWave = areaType.spawnIntervalFactor - areaType.spawnIntervalTimer;
		timeToDespawnWave = despawnInterval - despawnTimer;
		
		if ( areaType.IsA( 'PatrolingArea' ) ) encounterTypeFriendlyName = "Patroling Area";
		else if ( areaType.IsA( 'TerritorialArea' ) ) encounterTypeFriendlyName = "Territorial Area";
		else if ( areaType.IsA( 'NestingArea' ) ) encounterTypeFriendlyName = "Nesting Area";

		ClearDebugStatus();
		AddDebugStatus( "Encounter name: " + GetName() );
		AddDebugStatus( "Encounter type: " + encounterTypeFriendlyName );
		AddDebugStatus( "Is player in area: " + isPlayerInArea );
		AddDebugStatus( "Time to spawn wave: " + timeToSpawnWave );
		AddDebugStatus( "Time to despawn wave: " + timeToDespawnWave );
		
		AddDebugStatus( "" );
		
		AddDebugStatus( "Spawning stats" );
		AddDebugStatus( "Spawn trials: " + logSpawnTrials );
		AddDebugStatus( "Total spawned monsters: " + logSpawnedMonsters );
		AddDebugStatus( "Spawn fails no SP: " + logSpawnFailsNoSP );
        AddDebugStatus( "Spawn fails roll chance: " + logSpawnFailsRollChance );
        
        AddDebugStatus( "" );
        
		for ( monsterEntryIndex = 0; monsterEntryIndex < monsterEntries.Size(); monsterEntryIndex += 1 )
		{
			AddDebugStatus( "<b>Monster entry number " + monsterEntryIndex + "</b>" );
			AddDebugStatus( "Current spawned monsters num: " + monsterEntries[monsterEntryIndex].spawnedMonsters.Size() );
			AddDebugStatus( "Total monsters spawned num: " + monsterEntries[monsterEntryIndex].totalMonstersSpawned );
		}
	}
	
	function GetFleeArea() : CAreaComponent
	{
		var node : CNode;
		var ga : CGuardArea;
		if( fleeAreaTag!='' && fleeAreaTag!='None' )
		{
			node = theGame.GetNodeByTag( fleeAreaTag );
			ga = (CGuardArea)node;
			if( ga )
			{
				return ga.GetArea();
			}
			else
			{
				Logf("ERROR: CGuardArea '%1' invalid flee area tag '%2'", this.GetName(), fleeAreaTag );
			}
		}
		
		return NULL;
	}

	//////////////////////////////////////////////////////////////////////////////////////////

	// public data - user configuration
	editable         var timeActive                       : array< GameTimeInterval >;
	editable inlined var areaType                         : AreaType;
	editable inlined var monsterEntries                   : array< MonsterEntry >;
	editable         var resetMonstersCounterOnAreaEnter  : bool;
	editable         var resetMonstersCounterAfterHours   : int;  // resets monsters limit when player is outside encounter and x gameplay hours passed, 0 - disabled
	editable         var resetMonstersCounterAfterMinutes : int;  // resets monsters limit when player is outside encounter and x gameplay minutes passed, 0 - disabled
	editable         var resetMonstersCounterAfterReEnter : bool;
	editable         var forceDespawn                     : bool; // monsters will be despawned even if they are in combat mode
	saved editable   var isEnabled                        : bool; // is encounter enabled
	private editable var fleeAreaTag 					  : name; // flee area tag
	
	// General data
	var isPlayerInArea : bool;                  // 'true' if player is within this encounter
	var currentArea    : CTriggerAreaComponent; // trigger area component associated with this encounter (only one area per encounter)
	var isInitialized  : bool;                  // 'true' if encounter has been initialized (if it is false, then no operation should be done)

	// Spawn data
	var isEncounterSpawnEnabled          : bool;
	var monstersToSpawn                  : array< MonsterEntrySpawn >;
	var despawnDist                      : float; // the distance from player to the area after which monsters will be despawned
	var despawnTimer                     : float; // if it reaches 'despawnInterval' value, then despawn tick will occur
	var despawnInterval                  : float; // time intervals in which encounter will do despawn monsters tick
	var firstPlayerEntry                 : bool;  // player has entered area for the first time
	var resetMonstersCounterAfterSeconds : int;   // created from 'resetMonstersCounterAfter{Hours,Minutes}' - for optimization only
	
	// Save data
	saved var monsterEntriesSave : array< MonsterEntrySave >;
	saved var lastTimeActive     : int;
	saved var wasResetedMonstersCounterAfterReEnter : bool;
	default lastTimeActive = 0;
	default wasResetedMonstersCounterAfterReEnter = false;
	
	// Debug data
	var logPrintLevel           : int;             // the higher value, the more elaborate logging
	var logErrors               : array< string >; // the encounter system will not work properly for sure - this should naver happen
	var logWarnings             : array< string >; // some bad happened, but encounter system will probably work fine - this can happen
	var logNotice               : array< string >; // information message, encounter system works fine
	var logSpawnTrials          : int;             // the number of monsters that encounter tried to spawn
	var logSpawnedMonsters      : int;             // the number of spawned monsters
	var logSpawnFailsNoSP       : int;             // spawn fails due to spawn point not found
	var logSpawnFailsRollChance : int;             // spawn fails due to spawn roll chance
	

	default isPlayerInArea                   = false;
	default isEnabled                        = true;
	default despawnTimer                     = 0;
	default logSpawnTrials                   = 0;
	default logSpawnedMonsters               = 0;
	default logSpawnFailsNoSP                = 0;
	default firstPlayerEntry                 = true;
	default isInitialized		             = false;
	default resetMonstersCounterOnAreaEnter  = false;
	default resetMonstersCounterAfterHours   = 0;
	default resetMonstersCounterAfterMinutes = 0;
	default forceDespawn                     = false;
	default resetMonstersCounterAfterReEnter = true;
	
	// configuration
	default logPrintLevel    = 0;  // 2 - notice, warn, error; 1 - warn, error; 0 - error
	default despawnDist      = 20;
	default despawnInterval  = 10;
}


/////////////////////////////////////////////
// Encounter Actiwation class
/////////////////////////////////////////////
class CEncounterActivator extends CGameplayEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;

		// Only player can activate area
		affectedEntity = activator.GetEntity();
		if ( ! affectedEntity.IsA( 'CPlayer' ) )
		{
			return false;
		}
		
		isPlayerInArea = true;
		ActivateEncounter();
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity = activator.GetEntity();

		// Only player can activate area
		if ( ! affectedEntity.IsA( 'CPlayer' ) )
		{
			return false;
		}
		
		isPlayerInArea = false;
		DeactivateEncounter();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		if ( isPlayerInArea )
		{
			ActivateEncounter();
		}
	}
	
	private function FindEncounter()
	{
		if ( !encounter && encounterAreaTag != '' )
		{
			encounter = (CEncounter)theGame.GetEntityByTag( encounterAreaTag );
		}
	}
	
	private function ActivateEncounter()
	{
		ChangeEncounterActiveState( true );
	}
	
	private function DeactivateEncounter()
	{
		ChangeEncounterActiveState( false );
	}
	
	private function ChangeEncounterActiveState( isEncounterEnabled : bool )
	{
		if ( !encounter )
		{
			FindEncounter();
		}
		if ( encounter )
		{
			encounter.SetSpawnEnable( isEncounterEnabled );
		}
		else
		{
			LogChannel( 'encounter', "Cannot find encounter with specified tag: " + encounterAreaTag );
		}
	}
	
	public editable var encounterAreaTag : name;
	
	var encounter : CEncounter;
	
	saved var isPlayerInArea : bool;
	default isPlayerInArea = false;
}

///////////////////////////////////////////////////////////////////

class CEncounterStateRequest extends CScriptedEntityStateChangeRequest
{
	saved var enable		: bool;
	default enable 			= true;
	
	function Execute( entity : CGameplayEntity )
	{
		var encounter : CEncounter;
		encounter = (CEncounter)entity;
	
		if ( encounter )
		{
			encounter.SetEnableState( enable );
		}
	}
};