/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/*enum EAIAttitude
{
	AIA_Neutral,
	AIA_Friendly,
	AIA_Hostile,
};*/

/*enum EVisibilityTest
{
	VT_None,
	VT_LineOfSight,
	VT_RangeAndLineOfSight,
};*/

enum ECombatType
{	
	CT_None,
	CT_Fists,
	CT_Sword,
	CT_Sword_Skilled,
	CT_Bow,	
	CT_Bow_Walking,
	CT_ShieldSword,
	CT_TwoHanded,
	CT_Dual,
	CT_Dual_Assasin,
	CT_Mage,
	CT_Halberd,
	CT_TwoHandedBomb,
	CT_TwoHandedDagger
};

enum ECombatDistanceType
{
	CDT_Any,
	CDT_CloseCombat,
	CDT_RangedCombat,
};
enum ECombatDynamicsType
{
	CDT_Regular,
	CDT_Static,
	CDT_BattleArea,
};
struct SDeathExplosionParams
{
	var explosionTemplate : CEntityTemplate;
	var explosionRange : float;
	var explosionDamage : float;
	var attackType : name;
	var criticalEffectType : ECriticalEffectType;
}
struct SCombatParams
{
	var goalId : int;
	var dynamicsType : ECombatDynamicsType;
	var forcedDistanceType : ECombatDistanceType;
	var fistfightArea : W2FistfightArea;
};

enum EOffSlot
{
	OS_None,
	OS_Left,
	OS_Right
};

enum EDicePokerLevel
{
	DicePoker_Master,
	DicePoker_Hard,
	DicePoker_Normal,
	DicePoker_Easy,
};

/*
	not used because of broken serializing :/
	
	struct SDicePokerPlayer
{
	editable var difficultyLevel : EDicePokerLevel;
	editable var minimumBet		: int;
	
	default difficultyLevel = DicePoker_Normal;
	default minimumBet = 10;
}*/

/////////////////////////////////////////////
// NPC class
/////////////////////////////////////////////

import class CNewNPC extends CActor
{
	import var externalAttitudeSourcePlayer : bool;
	private editable var mappinAlwaysVisible : bool;
	private editable var broadcastCombatInterestPoint : bool;
	private editable var combatExitWorkMode : EExitWorkMode;	
	private editable saved var primaryCombatType : ECombatType;
	private editable saved var secondaryCombatType : ECombatType;
	private editable var closeCombatDistance : float;
	private editable var deadlyFists : bool;
	private editable var combatBlock : bool;
	private editable var combatDodge : bool;
	private editable var takedownEnabled : bool;
	private editable var guardAreaTag : name;
	private editable var lootTable : string;
	private editable var priceMultiplicator : float;
	private editable var unconciousTime : float;
	private editable var dropLootWhenUnconcious : bool;
	private editable var diceDifficultyLevel : EDicePokerLevel;
	private editable var diceMinimumBet	     : int;
	private editable var diceMaximumBet	     : int;
	private editable var usesMageTeleport	 : bool;
	private editable saved var carryItemLeft	: name;
	private editable saved var carryItemRight	: name;
	private editable var attackReactionRange : float;
	
	private var falltestResult : bool;
	
	default attackReactionRange = 20.0;
	
	private var conversationBlocked : bool;
	private var combatEventsProxy : W2CombatEventsProxy;
	private var localBlackboard : CBlackboard;
	//private var attackTarget : CActor;
	//private var attackTargetSetTime : EngineTime;
	private var attackPriority : byte;
	private var activeIdle : bool;
	private var offSlot : EOffSlot;
	
	//private editable var ragdollDeath : bool;
	private editable var explorationState : EExplorationState;	
	private var deadDestructDist : float; // the squared distance from player that is required to despawn NPC if he is dead
	import private var berserkTime : EngineTime;
	private var berserkAttacker : CActor;
	private var yrdenDamage : float;
	private var yrdenDamageTime : EngineTime;
	private var yrdenDamageCooldown : float;
	private var isKnockedDown : bool;
	private saved var m_isQuestTracked : bool; // true if this NPC is being tracked on minimap
	
	var shieldEffectName : name;
	
	editable saved var aimsThroughWalls : bool;
	
	default aimsThroughWalls = false;
	default m_isQuestTracked = false;

	// Dice statistics
	private saved var diceWins : int;
	private saved var diceLosses : int;
	
	private var startsWithIdleTime : EngineTime;
	
	var hasMagicShield : bool;
	var magicShieldDuration : float;
	var magicShieldLastUsed : EngineTime;
	var magicShieldFinishedTime : EngineTime;
	
	var actionSet1Time : EngineTime;
	var actionSet2Time : EngineTime;
	var actionSet3Time : EngineTime;
	var actionSet4Time : EngineTime;
	var actionSet5Time : EngineTime;
	
	
	var axiiTemporaryFriends : array<CNewNPC>;
	var axiiTemporaryEnemies : array<CNewNPC>;
	
	var wasInitializedBySpawner : bool;
		
	//override default value from actor
	//temporary cast to int because default values dont work while being an enum
	default finisherType	= 2;//FT_Multi;
	
	default carryItemLeft = 'Any';
	default carryItemRight = 'Any';
	default conversationBlocked = false;
	default explorationState = EX_Normal;
	default unconciousTime = 10.0;
	default combatExitWorkMode = EWM_Break;
	default primaryCombatType = CT_Fists;
	default secondaryCombatType = CT_None;
	default closeCombatDistance = 5.0;
	default deadlyFists	= true;
	default combatBlock = false;
	default combatDodge = false;
	default takedownEnabled = true;
	default activeIdle = true;
	default priceMultiplicator = 1;
	default offSlot = OS_None;
	default deadDestructDist = 0;
	//default dicePokerParams = { difficultyLevel = DicePoker_Normal, minimumBet = 10 };
	default diceDifficultyLevel = DicePoker_Normal;
	default diceMinimumBet = 5;
	default diceMaximumBet = 10;
	default usesMageTeleport = true;
	private var pushingCooldown : float;
	default pushingCooldown = 0;
	
	private var startsWithCombatIdle : bool;

	var cantBlockTime : EngineTime;
	var isTeleporting : bool;
	var unlimitedMagicShield : bool; //hack fix for q303 mage that has unlimited magic shield 
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Is AI enabled
	import final function IsAIEnabled() : bool;
	
	// Get current target
	import final function GetTarget() : CActor;
	
	// Get random position near NPC, position is valid movement target
	import final function FindRandomPosition() : Vector;
	
	// Find best action point
	import final function FindActionPoint( out apID : int, out category : name );
	
	// Tells if NPC should be spawned in action point and starts work immediatelly
	import final function IsStartingInActionPoint() : bool;

	// Sets if NPC should be spawned in action point and starts work immediatelly
	import final function SetStartingInActionPoint( isStartingInAP : bool );

	// Should NPC work on the last Action Point?
	import final function IsUsingLastActionPoint() : bool;
	
	// Find despawn point for current timetable layers
	import final function FindDespawnPoint( out spawnPoint : Vector ) : bool;
	
	// Get default despawn point for this NPC
	import final function GetDefaultDespawnPoint( out spawnPoint : Vector ) : bool;
	
	// Override daily schedule, hacky but helps with debugging crap...
	import final function OverrideSchedule( layerName, categoryName : name );	
	
	// Return items carried by this NPC to their original owners
	import final function GiveBackItemsToOrgOwner();	
	
	// Makes actor noticed by NPC
	import final function NoticeActor( actor : CActor );
	
	// If actor is noticed, forces it to be forgotten
	import final function ForgetActor( actor : CActor );
	
	// Forces to forget all noticed actors
	import final function ForgetAllActors();
	
	final function SetUseMageTeleport( useTeleport : bool )
	{
		usesMageTeleport = useTeleport;
	}
	final function CanTeleport() : bool
	{
		return usesMageTeleport;
	}
	function ShouldStartFightWithCombatIdle() : bool
	{
		if(theGame.GetEngineTime() > startsWithIdleTime + 2.0)
		{
			return false;
		}
		return startsWithCombatIdle;
	}
	function StartsWithCombatIdle(flag : bool)
	{
		startsWithIdleTime = theGame.GetEngineTime();
		startsWithCombatIdle = flag;
	}
	function AimsThroughWalls(flag : bool)
	{
		aimsThroughWalls = flag;
	}
	function CanAimThroughWalls() : bool
	{
		return aimsThroughWalls;
	}
	function GetActionTime(actionSet : EActionCooldownSet) : EngineTime
	{
		if(actionSet == Action_Set1)
		{
			return actionSet1Time;
		}
		else if(actionSet == Action_Set2)
		{
			return actionSet2Time;
		}
		else if(actionSet == Action_Set3)
		{
			return actionSet3Time;
		}
		else if(actionSet == Action_Set4)
		{
			return actionSet4Time;
		}
		else if(actionSet == Action_Set5)
		{
			return actionSet5Time;
		}
	}
	function SetActionTime(actionSet : EActionCooldownSet)
	{
		if(actionSet == Action_Set1)
		{
			actionSet1Time = theGame.GetEngineTime();
		}
		else if(actionSet == Action_Set2)
		{
			actionSet2Time = theGame.GetEngineTime();
		}
		else if(actionSet == Action_Set3)
		{
			actionSet3Time = theGame.GetEngineTime();
		}
		else if(actionSet == Action_Set4)
		{
			actionSet4Time = theGame.GetEngineTime();
		}
		else if(actionSet == Action_Set5)
		{
			actionSet5Time = theGame.GetEngineTime();
		}
	}
	
	//Despawn if encounter is gone
	event OnOwnerEntityLost()
	{
		this.GetArbitrator().AddGoalDespawn(false, false, false, this.GetWorldPosition());
	}
	
	function ChangeCarryItemLeftValue( itemName : name )
	{
		carryItemLeft = itemName;
	}
	
	function ChangeCarryItemRightValue( itemName : name )
	{
		carryItemRight = itemName;
	}
	
	function ExplodesOnDeath() : bool
	{
		return false;
	}
	
	function IsActiveIdleEnabled() : bool
	{
		return activeIdle;
	}
	
	function SetActiveIdle( flag : bool )
	{
		activeIdle = flag;
	}
	function IsKnockedDown() : bool
	{
		return isKnockedDown;
	}
	function SetKnockedDown(knockedDown : bool)
	{
		isKnockedDown = knockedDown;
	}
	latent function DestroyedOnFreeze() : bool
	{
		var templ : CEntityTemplate;
		var ent : CEntity;
		
		templ = (CEntityTemplate)LoadResource("gameplay\freeze_destruction");
		ent = theGame.CreateEntity( templ, GetWorldPosition(), GetWorldRotation() );
		
		if( ent )
			return true;
		else
			return false;
	}

	import final function IsCurrentlyWorkingInAP() : bool;
	import final function SetCurrentlyWorkingInAP( isWorking : bool );
	import final function SetActiveActionPoint( apID : int, actionCategory : name );
	import final function GetActiveActionPoint() : int;
	import final function GetLastActionPoint() : int;
	import final function ClearLastActionPoint();
	import final function ClearActiveActionPoint();
	import final function GetCurrentActionCategory() : name;
	import final function IsWorkingWithOldSchedule() : bool; // DEPRECATED
	import final function DoesAPMatchCurrentSchedule( apID : int, out matchedCategory : name ) : bool;
	
	function ReserveAP( apID : int, category : name ) : bool
	{
		var apMan : CActionPointManager = theGame.GetAPManager();
		
		// Try to reserve action point
		if ( apMan.IsFree( apID ) == false )
		{
			return false;
		}
		
		if ( apMan.TryReserve( GetName(), apID ) )
		{
			// Store ap info in npc
			SetActiveActionPoint( apID, category );
			return true;
		}
		else
		{
			ClearActiveActionPoint();
			return false;
		}
	}
		
	latent function MoveToActionPoint( apID : int, teleport : bool, optional moveType : EMoveType, optional absSpeed : float ) : bool
	{
		var apMan : CActionPointManager = theGame.GetAPManager();
		var workPlaceGoToPos, jobExecutionPos : Vector;
		var workPlaceOrientation : float;
		var orientAngle : EulerAngles;
		var distance : float;
		var placementImportance : EWorkPlacementImportance = apMan.GetPlacementImportance( apID );
		var actorMoveType : EMoveType;
		
		// set the movement type
		actorMoveType = GetModifiedMoveType( moveType );
		
		// check if we've got a place to go to
		if ( apMan.GetGoToPosition( apID, workPlaceGoToPos, workPlaceOrientation ) == false )
		{
			return false;
		}
		
		apMan.GetActionExecutionPosition( apID, jobExecutionPos, workPlaceOrientation );
		
		// move
		orientAngle.Yaw = workPlaceOrientation;
		if ( teleport )
		{
			TeleportWithRotation( jobExecutionPos, orientAngle );
		}
		else
		{
			distance = VecDistance( GetWorldPosition(), workPlaceGoToPos );
			if ( distance >= 0.1 )
			{
				// we're too far away from the destination - move there
				if ( placementImportance == WPI_Anywhere )
				{
					ActionMoveToWithHeading( workPlaceGoToPos, workPlaceOrientation, actorMoveType, absSpeed, 10.0, MFA_EXIT );
				}
				else if ( placementImportance == WPI_Nearby )
				{
					ActionMoveToWithHeading( workPlaceGoToPos, workPlaceOrientation, actorMoveType, absSpeed, 2.0, MFA_EXIT );
				}
				else
				{
					ActionMoveToWithHeading( workPlaceGoToPos, workPlaceOrientation, actorMoveType, absSpeed, 0.1, MFA_REPLAN );
				}
			}
			else
			{
				ActionSlideToWithHeading( jobExecutionPos, workPlaceOrientation, 0.1f );
			}
		}
			
		return true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import final function SetArea( area : CAreaComponent, maxDistance : float );
	
	import final function GetArea() : CAreaComponent;
	
	import final function SetFleeArea( area : CAreaComponent );
	
	import final function ShouldFlee() : bool;

	import final function FindFleePosition() : Vector;
	
	import final function GetBattleArea() : CBattleArea;
	
	import final function SetBattleArea( battleArea : CBattleArea ); 
	
	import final function GetPerceptionRange() : float;
	
	// Latent visibility test (uses vision sense), to test position pass NULL node
	import latent final function VisibilityTest( mode : EVisibilityTest, node : CNode, optional position : Vector ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import final function SetVisibility( isVisible : bool );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get attitude towards actor
	import final function GetAttitude( actor : CActor ) : EAIAttitude;

	// Set attitude towards actor
	import final function SetAttitude( actor : CActor , attitude : EAIAttitude);
	
	// Clear given attitudes
	import final function ClearAttitudes( hostile, neutral, friendly : bool );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Get AI Arbitrator
	import final function GetArbitrator() : CAIArbitrator;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import final function PlayDialog( optional forceSpawnedActors : bool ) : bool;
 
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import final function SetWristWrestlingParams( hotSpotMinWidth : int, hotSpotMaxWidth : int, 
		gameDifficulty : EAIMinigameDifficulty ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get reaction script by index
	import final function GetReactionScript( index : int ) : CReactionScript;
	
	// Gat reain reaction time ( 0.0 == rain reaction started )
	import final function GetRainReactionTime() : float;

	//////////////////////////////////////////////////////////////////////////////////////////
	
	final function GetDicePokerLevel() : EDicePokerLevel
	{
		return diceDifficultyLevel;
	}
	
	final function GetDicePokerMinBet() : int
	{
		return diceMinimumBet;
	}
	
	final function GetDicePokerMaxBet() : int
	{
		return diceMaximumBet;
	}

	final function GetDiceWins() : int
	{
		return diceWins;
	}
	
	final function GetDiceLosses() : int
	{
		return diceLosses;
	}

	final function DiceWinsIncrease()
	{
		diceWins += 1;
	}
	
	final function DiceLossesIncrease()
	{
		diceLosses += 1;
	}
	
	timer function StatsTimer( timeDelta : float )
	{
		var combatRegenV : float;
		var noncombatRegenV : float;
		
		if( IsAlive() )
		{		
		
			combatRegenV = GetCharacterStats().GetFinalAttribute('vitality_combat_regen');
			noncombatRegenV = GetCharacterStats().GetFinalAttribute('vitality_regen') ;
			
			if (this.IsInCombat())
			{
				if (combatRegenV != 0) IncreaseHealth( combatRegenV );
			}
			else
			{
				if (noncombatRegenV != 0) IncreaseHealth( noncombatRegenV );
			}
			if(GetHealth() < 0.4*GetInitialHealth())
			{
				if(!GetCharacterStats().HasAbility('OppE_Wounded') && this.GetAttitude(thePlayer) != AIA_Friendly)
				{
					GetCharacterStats().AddAbility('OppE_Wounded');
				}		
			}
			else
			{
				if(GetCharacterStats().HasAbility('OppE_Wounded'))
				{
					GetCharacterStats().RemoveAbility('OppE_Wounded');
				}	
			}
		}
	}
	
	public function IsOnSpawnedMapPinEnabled() : bool
	{
		return false;
	}
	
	// Set Mappin
	public function InitMappin()
	{
		if ( thePlayer.ShouldBeTracked( this ) )
		{
			m_isQuestTracked = true;
			//thePlayer.AddTrackedEntity( this );
		}
		else
		{
			m_isQuestTracked = false;
		}
		// TODO: m_isQuestTracked - is probably not needed any more as thePlayer.ShouldBeTracked() is better and sufficient
		if ( m_isQuestTracked )
		{
			// Restore (savagame) quest map pin
			//theHud.m_map.MapPinSet( this, theHud.m_map.CreateMapPin( this, "Quest", MapPinType_Quest, MapPinDisplay_Both ) );
			return;
		}

		if ( mapPin )
		{
			mapPin.Name = GetDisplayName();
		}
		else
		{	
			if ( GetAttitude( thePlayer ) == AIA_Hostile )	
			{
				mapPin = new CMapPin in this;
				mapPin.Enabled = true;
				mapPin.Name = GetDisplayName();
				mapPin.Description = "";//GetLocStringByKeyExt("Enemy");
				if ( GetAttitude( thePlayer ) == AIA_Hostile ) mapPin.Type = MapPinType_NpcHostile;
				if ( GetAttitude( thePlayer ) == AIA_Neutral )	mapPin.Type = MapPinType_NpcNeutral;
				if ( GetAttitude( thePlayer ) == AIA_Friendly )	mapPin.Type = MapPinType_NpcFriendly;
				mapPin.DisplayMode = MapPinDisplay_MiniMap;
			}
		}
		if ( mapPin )
		{
			MapPinSet( mapPin.Enabled, mapPin.Name, mapPin.Description,  mapPin.Type, mapPin.DisplayMode );
		}
	}
	// Remove Mappin
	public function RemoveMappin()
	{
		if ( !m_isQuestTracked )
		{
			if ( !mappinAlwaysVisible )
			{	
				MapPinClear();
			}
		}
	}
	
	// Initialize NPC
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		var myHandler : string;
		var movingAgent : CMovingAgentComponent;
		var arbitrator : CAIArbitrator = GetArbitrator();
		myHandler = CreateFlashEntityHandle ( this );
		
		super.OnSpawned(spawnData);
		
		if( IsAIEnabled() )
		{					
			// Set guard area
			if( IsNameValid( guardAreaTag ) )
			{
				SetGuardArea( guardAreaTag );
			}
			
			// Load curves
			arbitrator.LoadCombatCurves( AICCT_Standard, "goalcurves\default" );
			/*if( HasTag('Triss') )
			{
				arbitrator.LoadCombatCurves( AICCT_Follower, "goalcurves\triss" );
			}
			else
			{*/
				arbitrator.LoadCombatCurves( AICCT_Follower, "goalcurves\follower_default" );
			//}
			
			arbitrator.LoadCombatCurves( AICCT_Battle, "goalcurves\battle_default" );
			
			// Add idle goal
			if ( !spawnData.restored || !arbitrator.HasGoalsOfClass( 'CAIGoalIdle' ) ) // the safer version of below if
			{
			//if( !arbitrator.HasGoalsOfClass( 'CAIGoal' ) ) // this should be good, but I don't know why it was commented
			//{
				arbitrator.AddGoalIdle( false );
			//}
			}
		}
		
		movingAgent = GetMovingAgentComponent();;
		if ( movingAgent )
		{
			movingAgent.SetMaxMoveRotationPerSec( 720.f );
		}
		SetMovementType( explorationState );
		
		if (lootTable != "")
		{
			//Log("Generating loot for " + this + " from " + lootTable);
			//FillRandomLootActor( (CActor)this , lootTable );
		}
			
		AddTimer( 'StatsTimer', 1.0f, true );	
		
		if ( mappinAlwaysVisible ) InitMappin();		
	}
	
	event OnDestroyed()
	{
		super.OnDestroyed();
		
		thePlayer.RemoveTrackedEntity( this );
	}
	
	event OnDeath();
	
	/////////////////////////////////////////////////////////////////////////////////////////
	function SetGuardArea( areaTag : name ) : bool
	{
		var guardAreaNode : CNode;
		var guardArea : CGuardArea;
		var areaComponent : CAreaComponent;
		var fleeAreaComponent : CAreaComponent;
	
		if( IsNameValid( areaTag ) )
		{
			guardAreaNode = theGame.GetNodeByTag( areaTag );
			guardArea = (CGuardArea)guardAreaNode;
			if( guardArea )
			{
				areaComponent = guardArea.GetArea();
				if( areaComponent )
				{
					SetArea( areaComponent, guardArea.GetMaxDistance() );
					fleeAreaComponent = guardArea.GetFleeArea();
					SetFleeArea( fleeAreaComponent );
					return true;
				}
				else
				{
					Logf("ERROR: guard area with tag '%1' hasn't got CGuardAreaComponent, npc: '%2'", guardAreaTag, GetName() );
				}
			}
			else
			{
				Logf("ERROR: guard area with tag '%1' not found, npc: '%2'", guardAreaTag, GetName() );
			}
		}
		else
		{
			SetArea( NULL, 0.0f );
			SetFleeArea( NULL );
		}
		
		return false;
	}
	
	function ClearGuardArea()
	{
		SetArea( NULL, 0.0f );
	}
	
	function GetGuardArea() : CGuardArea
	{
		return (CGuardArea)GetArea().GetParent();
	}
		
	/////////////////////////////////////////////////////////////////////////////////////////
	// Can actor act as takedown victim
	function CanBeTakedowned( attacker : CActor, primary : bool ) : bool
	{	
		return false;
	}
	
	function MustBeTakedowned() : bool
	{
		return HasTag( 'AlwaysTakedown' );
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////
	//Price multiplier setup
	
	function GetPriceMult() : float
	{
		return this.priceMultiplicator;
	}

	function SetPriceMult(amount : float)
	{
		this.priceMultiplicator = amount;
	}	
	
	// Actor will take part in any non-parallel scene
	event OnSceneStarted( activeIdleFlag : bool, invulnerable : bool )
	{
		SetActiveIdle( activeIdleFlag );
		if( invulnerable )
		{
			immortalityModeScene = AIM_Invulnerable;
		}
		else
		{
			immortalityModeScene = AIM_None;
		}
	}

	// Actor will take part in blocking scene - this event happens when fade out is beginning
	event OnBlockingScenePrepare()
	{
		immortalityModeScene = AIM_Invulnerable;
	}

	// Actor will take part in blocking scene - this event happens on blackscreen
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		this.DisableLookAt();
		if ( GetCurrentStateName() != 'Scene' )
		{
			//ActionExitWork();
			
			if ( GetCurrentActionType() != ActorAction_Working )
			{
				// if npc is working then stopping working action will properly empty its hands - so we don't do it here
				EmptyHands();
			}
			
			GetArbitrator().AddGoalScene( scene );
		}
	}
	// Actor finished taking part in blocking scene
	event OnBlockingSceneEnded()
	{
		GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalScene' );
	}
	
	// Actor finished taking part in any non-parallel scene
	event OnSceneEnded()
	{	
		this.DisableLookAt();
		this.SetBehaviorVariable( "dialog", 0.0f );		
		SetActiveIdle( true );
		immortalityModeScene = AIM_None;
	}
	
	event OnCutsceneStarted()
	{
		ActionCancelAll();		
		GetArbitrator().AddGoalCutscene();
	}
	
	event OnCutsceneEnded()
	{
		//mayWander = true;
		//ActionExitWork();
	}
	
	event OnNearbySceneStarted( sceneCenter : Vector, sceneRadius : float )
	{
		return false;
	}
	
	event OnNearbySceneEnded()
	{
	}
	
	event OnInteractionTalkTest()
	{
		return false;
	}
	
	event OnTimetableChanged()
	{
		var category : name;
		
		if ( GetCurrentStateName() == 'Idle' && GetCurrentActionType() != ActorAction_Working )
		{
			// Walking to work
			if ( ! DoesAPMatchCurrentSchedule(GetActiveActionPoint(), category) )
			{
				ClearLastActionPoint();
				StateIdle();
			}
		}
		else if ( GetCurrentActionType() == ActorAction_Working )
		{
			// Leave current AP only if it doesn't match new timetable
			if ( ! DoesAPMatchCurrentSchedule(GetActiveActionPoint(), category) )
			{
				ClearLastActionPoint();
				ActionExitWorkAsync();
			}
			else
			{
				// TODO: Check if we are working on our AP with category
				// that is available in the current timetable, if not
				// than exit work and start work on the same AP but with
				// category that matches new timetable
			}
		}
		else
		{
			ClearLastActionPoint();
		}
	}
	
	timer function SetTalkInteractionVisible( timeDelta: float )
	{
		this.GetComponent("talk").SetEnabled( true );						
	}

	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( actionName == 'Talk' )
		{
			// By default, play dialog
			if ( !PlayDialog() )
			{
				// No main dialog found, play greeting
				if ( thePlayer.GetCurrentStateName() == 'Exploration' || thePlayer.GetCurrentStateName() == 'CombatSteel' || thePlayer.GetCurrentStateName() == 'CombatSilver' )
				{
					if( !IsConversationBlocked() )
					{
						this.GetComponent("talk").SetEnabled( false );
						this.PlayVoiceset(100, "greeting_reply" );	
						this.AddTimer('SetTalkInteractionVisible', 4.0, false);
					}	
				}
			}
		}	
		else if( actionName == 'Use' && activator.IsA( 'CPlayer' ) )
		{
			thePlayer.ToggleCarry( this );
		}
	}

	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if ( interactionName == 'MappinGenerator' && activator.IsA( 'CPlayer' ) && IsInteractionMappinType() )
		{
			if ( !mappinAlwaysVisible ) InitMappin();
		}
		else if( interactionName == 'talk' && activator.IsA( 'CPlayer' ) )
		{
			if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) )
			{
				theHud.m_hud.SetNPCName( this.GetDisplayName() );
				theHud.m_hud.SetNPCHealthPercent( this.GetHealthPercentage() );
				theHud.HudTargetActorEx( this, false );
			}
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( interactionName == 'MappinGenerator' && activator.IsA( 'CPlayer' ) && IsInteractionMappinType() )
		{
			RemoveMappin();
		}
		else if( interactionName == 'talk' && activator.IsA( 'CPlayer' ) )
		{
			if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) )
			{		
				theHud.m_hud.SetNPCName( "" );		
				theHud.HudTargetActorEx( NULL, false );	
			}
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	function EnableCarryStartInteraction( flag : bool )
	{
		var c : CComponent = this.GetComponent("CarryInteraction");
		if( c )
		{
			c.SetEnabled(flag);		
		}
	}
	
	function EnableCarryStopInteraction( flag : bool )
	{
		var c : CComponent = this.GetComponent("CarryInteractionOff");
		if( c )
		{
			c.SetEnabled(flag);		
		}	
	}
	
	event OnManualCarry();
	
	//////////////////////////////////////////////////////////////////////////////////////////

	event OnScriptReloaded()
	{
		Log( "OnScriptReloaded called on " + this );
		// Arbitrator restart in code
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	latent function ChangeNpcExplorationBehavior()
	{
		var currType : EExplorationState;
		currType = GetMovementType();
		
		ActivateAndSyncBehavior( 'npc_exploration' );
		SetMovementType( currType );
	}

		
	//////////////////////////////////////////////////////////////////////////////////////////
	function WorkAtScenePosition( apID : int, category : name, priority : int, run : bool )
	{
		var moveType : EMoveType;
		
		if ( run == true )
		{
			moveType = MT_Run;
		}
		else
		{
			moveType = MT_Walk;
		}
		
		GetArbitrator().AddGoalWorkInScene( apID, category, priority, moveType );
	}
	
	function GoToScenePosition( desiredPlacement : Matrix, distance : float, priority : int, run : bool )
	{
		var moveType : EMoveType;
		var desiredPosition : Vector;
		var desiredRotation : EulerAngles;
				
		if ( run == true )
		{
			moveType = MT_Run;
		}
		else
		{
			moveType = MT_Walk;
		}
		
		desiredPosition = MatrixGetTranslation( desiredPlacement );
		//desiredPosition.Z = desiredPosition.Z + 1.0f;
		
		desiredRotation = MatrixGetRotation( desiredPlacement );
	
		GetArbitrator().AddGoalPrepareForScene( desiredPosition, desiredRotation.Yaw, distance, priority, moveType );
	}
	
	function EnterIdle( immediate : bool, optional blockWander : bool )
	{
		if ( blockWander == true )
		{
			SetActiveIdle(false); 
		}
		
		GetArbitrator().ClearAllGoals();
		GetArbitrator().AddGoalIdle( immediate );
	}
	
	function ForceTargetToDrawWeapon( target : CActor )
	{
		var currentState : EPlayerState;
		
		if( target == thePlayer )
		{
			currentState = thePlayer.GetCurrentPlayerState();
			
			if( currentState == PS_Exploration || currentState == PS_Sneak)
			{
			//if( this.IsSwordfighter() )
			//{
				if ( !this.IsMonster() )
				{
					if( thePlayer.HasSteelSword() )
						thePlayer.ChangePlayerState( PS_CombatSteel );
					else
						thePlayer.ChangePlayerState( PS_CombatSilver );
				} else
				{
					if( thePlayer.HasSilverSword() )
						thePlayer.ChangePlayerState( PS_CombatSilver );	
					else
						thePlayer.ChangePlayerState( PS_CombatSteel );
				}
			//}
			}
			else if(currentState == PS_Meditation)
			{
				if(thePlayer.GetCanExitMeditation())
				{
					thePlayer.SetExitMeditationCooldown();
					thePlayer.StateMeditationExit();
					theHud.m_messages.ShowInformationText( StrUpperUTF( GetLocStringByKeyExt( 'meditationBreak' ) ) );
				}
			}
		}
	}
	function SetMagicShield(shieldTime : float, optional effectName : name)
	{
		magicShieldDuration = shieldTime;
		magicShieldLastUsed = theGame.GetEngineTime();
		hasMagicShield = true;
		if(effectName != '')
		{
			shieldEffectName = effectName;
		}
		else
		{
			shieldEffectName = 'magic_shield';
		}
		if(shieldTime > 0)
		{
			this.PlayEffect(shieldEffectName);
			this.AddTimer('TimerResetMagicShield', shieldTime, false);
		}
	}
	function GetMagicShieldFinishedTime() : EngineTime
	{
		return magicShieldFinishedTime;
	}
	
	event OnPlayerThrowBomb();
	
	timer function TimerResetMagicShield(td : float)
	{
		hasMagicShield = false;
		magicShieldFinishedTime = theGame.GetEngineTime();
		this.StopEffect(shieldEffectName);
	}
	function HasMagicShield() : bool
	{
		if((hasMagicShield && theGame.GetEngineTime() <= magicShieldLastUsed + EngineTimeFromFloat(magicShieldDuration)) || unlimitedMagicShield )
		{
			return true;
		}
		else
		{
			hasMagicShield = false;
			//magicShieldFinishedTime = theGame.GetEngineTime();
			this.StopEffect('magic_shield');
			return false;
		}
	}
	function GetAttackTarget() : CActor
	{
		// attack target is valid only for 5 sec.
		if( theGame.GetEngineTime() - attackTargetSetTime < 5.0 )
		{
			return attackTarget;
		}
		else
		{
			return NULL;
		}
	}

	// Set attack target
	function SetAttackTarget( target : CActor )
	{
		var tm : EngineTime;
		tm = theGame.GetEngineTime();
		
		attackTarget = target;		
		attackTargetSetTime = tm;
		
		if ( target == thePlayer && !IsInCloseCombat() )
		{
			if( GetCurrentStateName() == 'TreeCombatFist' )
				thePlayer.ChangePlayerState( PS_CombatFistfightDynamic );			
			else
				ForceTargetToDrawWeapon( target );
		}
		else
			ForceTargetToDrawWeapon( target );
	}
	
	// Clear target being attacked
	function ClearAttackTarget()
	{		
		attackTarget = NULL;
	}
	
	timer function RemoveBerserkAttackerAttitude(td : float )
	{
		if( berserkAttacker )
		{
			SetAttitude( berserkAttacker, AIA_Neutral );
			berserkAttacker = NULL;
		}
	}
	function ReactToHit( source : CActor )
	{
		var surroundingActors : array<CActor>;
		var npc : CNewNPC;
		var i, size : int;
		npc = (CNewNPC)source;
		if(GetIsAxiiControled())
		{
			if(source == thePlayer)
			{
				CalmDown();
				return;
			}
		}
		if ( source == thePlayer && !killingCauseGuardDialog && GetAttitude( source ) == AIA_Neutral )
		{
			SetAttitude( source, AIA_Hostile );
		}
		
		if( source.IsA('CNewNPC') && ((CNewNPC)source).IsBerserkActive() )
		{
			if( berserkAttacker )
			{
				SetAttitude( berserkAttacker, AIA_Neutral );
				berserkAttacker = NULL;
			}
			
			if( GetAttitude( source ) != AIA_Hostile )
			{
				SetAttitude( source, AIA_Hostile );
				berserkAttacker = source;
				AddTimer('RemoveBerserkAttackerAttitude', 5.0f, false );
			}
		}
	
		NoticeActor( source );	
		if(lastNotifyActorTime + EngineTimeFromFloat(5.0) < theGame.GetEngineTime())
		{
			lastNotifyActorTime = theGame.GetEngineTime();
			GetActorsInRange(surroundingActors, attackReactionRange, '', this);
			size = surroundingActors.Size();
			for(i = 0; i < size; i += 1)
			{
				npc = (CNewNPC)surroundingActors[i];
				if(npc)
				{
					if(ZDifferenceTest(3.0, this.GetWorldPosition(), npc.GetWorldPosition()) && npc.GetCurrentCombatType() != CT_Bow && npc.GetCurrentCombatType() != CT_Bow_Walking )
					{
						npc.NoticeActor( source );
					}
				}
			}
		}
	}

	// Actor has been hit
	function Hit( source : CActor, attackType : name, optional impossibleToBlock : bool, optional groupAttack : bool, optional killsTarget : bool, optional forceHitAnim : bool )
	{
		ReactToHit( source );
		
		if( source == thePlayer && killingCauseGuardDialog )
		{
			thePlayer.SetGuardsHostile( true );
		}
		
		super.Hit( source, attackType, impossibleToBlock, groupAttack, killsTarget, forceHitAnim );
	}
	
	function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{
		if( source )
			ReactToHit( source );
		super.HitPosition( hitPosition, attackType, damage, lethal, source, forceHitEvent );
	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		var eventName : name;		
		super.OnHit( hitParams );
		AddTimer('removeYrdenFX', 0.5);	
		if( IsAlive() )
		{
			eventName = GetHitEventName( hitParams.hitPosition, hitParams.attackType );
			this.RaiseForceEvent( eventName );
		}
	}
	
	event OnHitAdditional( hitParams : HitParams ) {}
	
	// Get proper behavior hit event name
	function GetHitEventName( hitPosition : Vector, attackType : name ) : name
	{
		if( attackType == 'FastAttack_t1' )
		{
			if( IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				return 'hit_front_t1';
			}
			else
			{
				return 'hit_back';
				ActionRotateToAsync( hitPosition );
			}
		}
		
		if( attackType == 'FastAttack_t2' )
		{
			if( IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				return 'hit_front_t2';
			}
			else
			{
				return 'hit_back';
				ActionRotateToAsync( hitPosition );
			}
		}
		
		else if( attackType == 'FastAttack_t3' )
		{
			if( IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				return 'hit_front_t3';
			}
			else
			{
				return 'hit_back';
				ActionRotateToAsync( hitPosition );
			}		
	    }	
	    
	    else if( attackType == 'FistFightAttack_t1' )
		{
			if( IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				return 'hit_front_t1';
			}
			else
			{
				return 'hit_back';
				ActionRotateToAsync( hitPosition );
			}		
	    }	
	}
	
	// Can respond to block (overriden in player and npc)
	function CanRespondToBlock() : bool
	{		
		return ( HasCombatType(CT_ShieldSword) || HasCombatType(CT_TwoHanded) || HasCombatType(CT_Dual) || HasCombatType(CT_Dual_Assasin) || HasCombatType(CT_Sword) || HasCombatType(CT_Sword_Skilled));
	}
	
	// Can perform responded block (overriden in player and npc)
	function CanPerformRespondedBlock() : bool
	{	
		return ( HasCombatType(CT_ShieldSword) || HasCombatType(CT_TwoHanded) || HasCombatType(CT_Dual) || HasCombatType(CT_Dual_Assasin)|| HasCombatType(CT_Sword) || HasCombatType(CT_Sword_Skilled)|| HasCombatType(CT_Mage));
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////

	function ShouldBendBodyTowardsAvoidedObstacle( otherActor : CActor ) : bool
	{
		return GetAttitude( otherActor ) == AIA_Friendly;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
		
	function EnterDespawn( isHiddenDespawn : bool )
	{	
		var goalIds : array<int>;
		// Try to despawn
		OnDespawn( false );
		if( GetArbitrator().GetGoalIdsByClassName( 'CAIGoalDespawn', goalIds ) == false )
		{
			GetArbitrator().AddGoalDespawn( false, false, isHiddenDespawn );
		}
	}
	
	function EnterDespawnAtPlace( despawnPoint : Vector, isHiddenDespawn : bool )
	{
		var goalIds : array<int>;
		// Try to despawn in requested place
		OnDespawn( false );
		if( GetArbitrator().GetGoalIdsByClassName( 'CAIGoalDespawn', goalIds ) == false )
		{
			GetArbitrator().AddGoalDespawn( false, true, isHiddenDespawn, despawnPoint );
		}
	}
	
	function ForceDespawn()
	{
		OnDespawn( true );
		GetArbitrator().AddGoalDespawn( true );		
	}
 
	event OnDespawn( forced : bool );	
	
	latent function OnBeforeDestroy()
	{
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function EnterSlaveState( master : CActor, slaveBehaviorName : name, instantStart : bool, initialSpeed : float )
	{
		GetArbitrator().ClearAllGoals();
		GetArbitrator().AddGoalInteractionSlave( master, slaveBehaviorName, instantStart, initialSpeed );
	}
	
	function EnterMinigameState( wp : CNode, behavior : name )
	{
		//GetArbitrator().ClearAllGoals();
		GetArbitrator().AddGoalMinigame( wp, behavior );
	}

	function ExitMinigameState()
	{
		if ( GetCurrentStateName() == 'Minigame' )
		{
			StateMinigameExit();
			GetArbitrator().AddGoalIdle( true );
		}
	}
	
	function EnterAudienceState( wp : CNode, audience : CAudience )
	{
		//GetArbitrator().ClearAllGoals();
		GetArbitrator().AddGoalAudience( wp, audience );
	}
	
	function ExitAudienceState()
	{
		GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalAudience' );
	}
	
	event OnForceAudienceAnim();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Enter dead state
	private function EnterDead( optional deathData : SActorDeathData )
	{
		LockEntryFunction(false);
		GetArbitrator().ClearAllGoals();
		if ( deathData.onlyDestruct )
		{
			StateDestruct( deathData );
		}
		else
		{
			StateDead( deathData );
		}
		OnDeath();
		//UnregisterEntity();
	}
	
	/*private function EnterPreDeath()
	{
		LockEntryFunction(false);
		ActionCancelAll();
		GetArbitrator().ClearAllGoals();		
		StatePreDeath();
		UnregisterEntity();
	}*/
	
	// Enter stun
	private function EnterUnconscious( optional deathData : SActorDeathData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		LockEntryFunction(false);
		arbitrator.ClearAllGoals();
		arbitrator.AddGoalUnconscious( deathData );
	}

	latent function UnconsciousStarted();
	latent function UnconsciousEnded();
	
	public function SetDeadDestructDistance( distFromPlayer : float )
	{
		deadDestructDist = distFromPlayer * distFromPlayer;
	}
	
	public function CanBeDesctructed() : bool
	{
		if ( deadDestructDist > 0 )
		{
			if ( VecDistanceSquared( thePlayer.GetWorldPosition(), GetWorldPosition() ) < deadDestructDist )
			{
				return false;
			}
		}
		
		// away from camera, NPC is invisible
		if ( !WasVisibleLastFrame() )
		{
			// more tests not required
			return true;
		}
		
		return !WasVisibleLastFrame();
	}

	/////////////////////////////////////////////////////////////////////////////////////////
	
	// berserk state
	
	function IsBerserkActive() : bool
	{
		return theGame.GetEngineTime() < berserkTime;
	}
	
	function EnterBerserk( time : float )
	{		
		SetIsAxiiControled(time);
		
		this.PlayEffect('axii_level1');
		this.PlayEffect('axii_fx');
		
		this.AddTimer('TimerKeepPlayerCombatMode', 1.0, true);
		this.AddTimer( 'Raging', time );
		berserkTime = theGame.GetEngineTime() + time;
	}	
	timer function TimerKeepPlayerCombatMode(td : float)
	{
		if(this.IsAlive())
		{
			thePlayer.KeepCombatMode();
		}
		else
		{
			this.RemoveTimer('TimerKeepPlayerCombatMode');
		}
	}
	function CalmDown()
	{
	
		SetIsAxiiControled(0.0f);
		
		this.StopEffect('axii_level1');
		this.StopEffect('axii_fx');
		
		this.RemoveTimer( 'Raging' );
		this.RemoveTimer('TimerKeepPlayerCombatMode');
		this.GetCharacterStats().RemoveAbility('axii_debuf1');
		this.GetCharacterStats().RemoveAbility('axii_debuf2');
		this.SetInitialHealth(this.GetCharacterStats().GetFinalAttribute('vitality'));
		
		berserkTime = EngineTime();
		thePlayer.RemoveAxiiTarget(this);
	}
	
	// Tells if the NPC is under AXII sign influence
	import function GetIsAxiiControled() : bool;

	// Sets an AXII sign influence over this NPC
	import function SetIsAxiiControled( duration : float );
	
	function ZDifferenceTest(maxDif : float, position1 : Vector, position2 : Vector) : bool
	{
		var z1, z2 : float;
		
		z1 = position1.Z;
		z2 = position2.Z;
		
		if(AbsF(z1 - z2) <= maxDif)
		{
			return true;
		}
		else return false;
	}
	// timer for calming down
	timer function Raging( time : float )
	{
		CalmDown();
	}
	latent function HandleItemsOnDeath() : bool { return false; }

	//////////////////////////////////////////////////////////////////////////////////////////
	function IsInCloseCombat() : bool
	{
		if ( GetCurrentCombatType() == CT_Bow || GetCurrentCombatType() == CT_Bow_Walking )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	function HasCombatType( ct : ECombatType ) : bool
	{
		return ( primaryCombatType == ct || secondaryCombatType == ct );
	}
	
	function HasAnyCombatType() : bool
	{
		return !( primaryCombatType == CT_None && secondaryCombatType == CT_None );
	}
	
	function SwapCombatType( currentCombatType : ECombatType, newCombatType : ECombatType, optional reenterCombat : bool )
	{	
		if( primaryCombatType == currentCombatType )
		{
			primaryCombatType = newCombatType;
			if( reenterCombat )
			{
				OnReenterCombat();
			}
		}
		else if( secondaryCombatType == currentCombatType )
		{
			secondaryCombatType = newCombatType;			
			if( reenterCombat )
			{
				OnReenterCombat();
			}
		}
		else
		{
			Log("ERROR SwapCombatType currentCombatType not found");
		}
	}
	
	function SetCombatType( primary, secondary : ECombatType, optional reenterCombat : bool )
	{	
		primaryCombatType = primary;
		secondaryCombatType = secondary;
		if( reenterCombat )
		{
			OnReenterCombat();
		}
	}

	function SetCombatTypes( primary, secondary : ECombatType )
	{
		primaryCombatType = primary;
		secondaryCombatType = secondary;
	}
	
	function DisableCombatType( combatType : ECombatType, reenterCombat : bool, attacker : CActor )
	{
		var critEffectParams : W2CriticalEffectParams;
	
		if( primaryCombatType == combatType )
		{
			primaryCombatType = secondaryCombatType;
			//if ( primaryCombatType == CT_Bow )
			//{
				//secondaryCombatType = CT_Fists;
			//}
			//else
			//{
				secondaryCombatType = CT_None;
			//}
		}
		else if( secondaryCombatType == combatType )
		{
			secondaryCombatType = primaryCombatType;			
			secondaryCombatType = CT_None;
		}
		else
		{
			//Log("ERROR SwapCombatType currentCombatType not found");
			return;
		}
		
		if ( primaryCombatType == CT_None && secondaryCombatType == CT_None )
		{
			// do not fight, as we cannot fight without weapons
			// IMHO: NPC should enter in new state - run away from the attacker
			//SetAttitude( GetAttackTarget(), AIA_Neutral );
			//SetAttackableByPlayer( true );
			
			SetHealth( 1.0, false, attacker );
			
			// Apply fear effect
			critEffectParams.damageMin = 0;
			critEffectParams.damageMax = 0;
			critEffectParams.durationMin = 1024;
			critEffectParams.durationMax = 1024;
			ForceCriticalEffect( CET_Fear, critEffectParams );
		}
		else if( reenterCombat )
		{
			OnReenterCombat();
		}
	}
	
	function GetCurrentCombatType() : ECombatType
	{
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		if ( currentStateName == 'TreeCombatFist' )
		{
			return CT_Fists;
		}
		else if ( currentStateName == 'TreeCombatSword' )
		{
			return CT_Sword;
		}
		else if ( currentStateName == 'TreeCombatDual' )
		{
			return CT_Dual;
		}
		else if ( currentStateName == 'TreeCombatShieldSword' )
		{
			return CT_ShieldSword;
		}
		else if ( currentStateName == 'TreeCombatTwoHanded' )
		{
			return CT_TwoHanded;
		}
		else if ( currentStateName == 'TreeCombatBow' )
		{
			return CT_Bow;
		}
		else if ( currentStateName == 'CombatFistStatic' )
		{
			return CT_Fists;
		}
		else
		{
			return CT_None;
		}
	}

	function IsCommoner() : bool
	{
		return ( !HasAnyCombatType() );
	}
	
	function IsFistfighter() : bool
	{
		return ( this.HasCombatType(CT_Fists) );
	}

	function IsSwordfighter() : bool
	{
		return ( this.HasCombatType(CT_Sword) || this.HasCombatType(CT_Dual) );
	}
	
	function IsShielded() : bool
	{
		return ( this.HasCombatType(CT_ShieldSword) );
	}
	
	function IsOnlyDistanceFighter() : bool
	{
		if ( ( primaryCombatType == CT_Bow && secondaryCombatType == CT_None ) ||
		     ( primaryCombatType == CT_None && secondaryCombatType == CT_Bow ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function InstantDeath() : bool
	{
		var deathData : SActorDeathData;
		var attacker : CActor;
		
		this.RaiseForceEvent( 'DeadState' );
		deathData.silent = true;
		Kill(true, attacker, deathData);
		return true;
	}
	
	// returns true if ow
	function CloseCombatDistanceTest() : bool
	{
		var dist : float = VecDistance( GetTarget().GetWorldPosition(), GetWorldPosition() );
		if ( IsInCloseCombat() )
		{
			if( dist > closeCombatDistance + 3.0 )			
				return false;			
			else
				return true;
		}
		else
		{
			if( dist < closeCombatDistance )
				return true;
			else
				return false;				
		}
	}
	
	// a function called periodically to establish whether the enemy's gotten
	// so close to us that we should switch to close combat
	function ChangeCombatIfNeeded( combatParams : SCombatParams )
	{
		var newCloseCombat : bool;
		
		// do not change combat type if we don't have ability to fight
		// from the distance (i.e. NPC can do only close combat)
		if( !HasCombatType( CT_Bow ) && !HasCombatType( CT_Bow_Walking ) )
		{
			return;
		}
		
		// if we don't have ability to fight in close combat
		// do not change combat type
		if ( IsOnlyDistanceFighter() )
		{
			return;
		}
		
		if( combatParams.forcedDistanceType == CDT_Any )
		{
			newCloseCombat = CloseCombatDistanceTest();
		}
		else if( combatParams.forcedDistanceType == CDT_CloseCombat )
		{
			newCloseCombat = true;
		}
		else if( combatParams.forcedDistanceType == CDT_RangedCombat )
		{
			newCloseCombat = false;
		}
		
		if( newCloseCombat != IsInCloseCombat() )
		{			
			EnterCombat( combatParams );		
		}
	}
	
	function TryEnterCustomCombat( params : SCombatParams ) : bool
	{
		/*if( HasTag('Triss') || HasTag('sq202_succubus') )
		{
			CombatTriss( params );
			return true;
		}*/
		if( HasTag('Riszon') )
		{
			CombatRiszon( params );
			return true;
		}
		return false;
	}
	
	event OnReenterCombat();
	
	function EnterCombat( params : SCombatParams )
	{	
		var closeCombatDistanceResult : bool;
		var enterCloseCombat : bool = true;
		attackPriority = 0;
		combatIdleGroupIdx = -1;

		// In fistfight area only fists
		if( params.fistfightArea )
		{
			if ( HasCombatType( CT_Fists ) )
			{
				TreeCombatFist(params);
				OnEnteringCombat();
				return;
			}			
			else
			{
				SetErrorState("EnterCombat error: fistfight area set but no CT_Fists");
				Log( "EnterCombat error: fistfight area set but no CT_Fists" );			
			}
		}
		
		if( !TryEnterCustomCombat( params ) )
		{	
			if( HasCombatType( CT_Bow ) || HasCombatType( CT_Bow_Walking ))
			{
				// Only bow so must enter
				closeCombatDistanceResult = CloseCombatDistanceTest();
				if( HasCombatType( CT_None ) )
				{
					enterCloseCombat = false;
					TreeCombatBow(params);
				}
				else if( ( closeCombatDistanceResult == false && params.forcedDistanceType == CDT_Any ) || params.forcedDistanceType == CDT_RangedCombat )
				{
					enterCloseCombat = false;
					TreeCombatBow(params);			
				}
			}
			
			if( enterCloseCombat )
			{
				if ( HasCombatType( CT_Fists ) && HasCombatType( CT_Sword ) )
				{
					if( GetTarget() == thePlayer && UseStaticFistfight() )
						CombatFistStatic(params);
					else
						TreeCombatFist(params);
				}		
				else if ( HasCombatType( CT_Sword ) || HasCombatType(CT_Sword_Skilled) )
				{
					attackPriority = 1;
					TreeCombatSword(params);			
				}		
				else if ( HasCombatType( CT_Dual ) || HasCombatType( CT_Dual_Assasin ))
				{
					attackPriority = 2;
					TreeCombatDual(params);
				}
				else if ( HasCombatType( CT_TwoHanded ) )
				{
					attackPriority = 3;
					TreeCombatTwoHanded(params);
				}
				else if ( HasCombatType( CT_Halberd ) )
				{
					attackPriority = 5;
					TreeCombatPoleArm(params);
				}
				else if ( HasCombatType( CT_ShieldSword ) )
				{
					attackPriority = 4;
					TreeCombatShieldSword(params);
				}
				else if ( HasCombatType( CT_Mage ) )
				{
					attackPriority = 5;
					TreeCombatMage(params);
				}
				else if ( HasCombatType( CT_TwoHandedBomb ) )
				{
					attackPriority = 5;
					TreeCombatTwoHandedBomb(params);
				}
				else if ( HasCombatType( CT_TwoHandedDagger ) )
				{
					attackPriority = 5;
					TreeCombatTwoHandedDagger(params);
				}
				else if ( HasCombatType( CT_Fists ) )
				{
					if( GetTarget() == thePlayer && UseStaticFistfight() )
						CombatFistStatic(params);
					else
						TreeCombatFist(params);
				}
				else
				{
					SetErrorState("EnterCombat error: unsupported weapon type");
					Log( "EnterCombat error: unsupported weapon type" );			
				}
			}
		}
		
		OnEnteringCombat();
	}
	
	// Get attack priority
	function GetAttackPriority() : int
	{
		return attackPriority;
	}
	
	function SetIsTeleporting(flag : bool)
	{
		isTeleporting = flag;
	}
	
	function HasUnlimitedMagicShield() : bool
	{
		return unlimitedMagicShield;
	}
	
	function SetDamageReaction( flag : bool )
	{
		if (flag)
		MagePostTeleport();
		else
		MagePreTeleport();
	}
	

	function IsTeleporting() : bool
	{
		return isTeleporting;
	}
	
	event OnEnteringCombat()
	{
		var tags : array < name >;
		var i : int;
		if ( GetTarget() == thePlayer )
		{
			//thePlayer.KeepCombatMode();
			//if ( GetTarget().GetCurrentStateName() == 'Sneak' ) 
			// FACTS DB
			tags = this.GetTags();
			for( i=0; i<tags.Size(); i+=1 )
			{
				FactsAdd( "actor_" + tags[i] + "_spotted_geralt", 1, 1 );
			}
		}
		
		if( GetMovementType() == EX_CarryTorch )
		{
			GetInventory().DropItem( GetInventory().GetItemId( 'Torch' ) );
		}
	}
	
	function GetNpcPrimaryCombatType() : ECombatType
	{
		return primaryCombatType;
	}
	
	latent function BeforeCombat() {}
	
	function CanBlock() : bool
	{
		return combatBlock;
	}
	
	function CanDodge() : bool
	{
		return combatDodge;		
	}
	
	timer function CombatModeTimer( timeDelta : float )
	{
		if (GetTarget() == thePlayer) theSound.TriggerCombatMusic( 5.0 );
	}
	
	function GetCombatEventsProxy() : W2CombatEventsProxy
	{		
		return combatEventsProxy;
	}
	
	// Returns true if combat events must be filled
	function CreateCombatEventsProxy( type : W2CombatEventsType ) : bool
	{
		var mgr : W2CombatEventsManager = theGame.GetCombatEventsManager();
		combatEventsProxy = new W2CombatEventsProxy in this;
		combatEventsProxy.combatEvents = mgr.GetCombatEvents( type );
		if( combatEventsProxy.combatEvents )
		{
			return false;
		}
		else
		{
			combatEventsProxy.combatEvents = mgr.CreateCombatEvents( type );
			return true;
		}
	}
	
	function GetLocalBlackboard() : CBlackboard
	{
		if( !localBlackboard )
		{
			localBlackboard = new CBlackboard in this;
		}
		
		return localBlackboard;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	public function ForceDisarm()
	{
		var params : W2CriticalEffectParams;

		params.damageMin = 0;
		params.damageMax = 0;
		params.durationMin = 3;
		params.durationMax = 3;
	
		ForceCriticalEffect( CET_Disarm, params );
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	function AardKnockdownChance() : bool
	{
		var aardKnockdownChance : float;
		var diceThrow : float;
		diceThrow = RandRangeF(0.0, 1.0);
		aardKnockdownChance = thePlayer.GetCharacterStats().GetFinalAttribute('aard_knockdown_chance');
		if(this.IsBoss() || this.IsImmortal() || this.IsInvulnerable())
		{
			return false;
		}
		if(diceThrow < aardKnockdownChance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function ResTest(resname : name) : bool
	{
		var diceThrow : float;
		var res : float;
		
		diceThrow = RandRangeF(0.01f, 1.0f);
		res = this.GetCharacterStats().GetFinalAttribute(resname);
		if(diceThrow > res)
		{
			return false;
		}
		return true;
	}
	function CheckIfCanFallDownOnAard() : bool
	{
		if(!this.CanBeFinishedOff(thePlayer))
		{
			return false;
		}
		if(this.GetAttitude(thePlayer) == AIA_Friendly)
		{
			return false;
		}
		if(this.IsMonster())
		{
			if(this.GetMonsterType() != MT_Drowner && this.GetMonsterType() != MT_Nekker && this.GetMonsterType() != MT_Rotfiend)
			{ 
				return false;
			}
		}

		if(!this.IsImmortal() && !this.IsInvulnerable())
		{
			if(!FallRes())
			{
				return true;
			}
			else if(this.GetHealthPercentage() < 50.0)
			{
				return true;
			}
		}
		return false;

	}
	function FallRes() : bool
	{
		var diceThrow : float;
		var res : float;
		if(falltestResult)
		{
			return true;
		}
		diceThrow = RandRangeF(0.01f, 1.0f);
		res = this.GetCharacterStats().GetFinalAttribute('res_falldown');
		if(diceThrow > res)
		{
			return false;
		}
		falltestResult = true;
		return true;
	}
	function HandleFallingDownOnAard() : bool
	{
		// tweak this function using those constants:
		var distanceBehindActorToTestAltitude : float = 6.0;
		var minimalAltitudeToKill : float = 5.0;
		var impulseMultiplier : float = 500.0;
		var impulseZComponent : float = 0.8;
		
		var direction, testPoint, traceStart, impulse : Vector;
		var normal : EulerAngles;
		var deathData : SActorDeathData;
		var animComponent : CAnimatedComponent;
		var soundEventToPlay : string;
		var boneName : name;
		var i : int;
			
		// calculate normal direction from player
		direction = GetWorldPosition() - thePlayer.GetWorldPosition();
		direction.Z = 0.0;
		direction = VecNormalize( direction );
		
		// compute the test point and trace down to see if the altitude is high enough for believable death
		testPoint = GetWorldPosition() + ( direction * distanceBehindActorToTestAltitude ) + Vector( 0.0, 0.0, 1.0, 0.0 );
		
		// first, trace for obstacles behind us
		traceStart = GetWorldPosition() + Vector( 0.0, 0.0, 0.5, 0.0 );
		
		if ( 	theGame.GetWorld().StaticTrace( traceStart, testPoint, impulse, impulse ) == false && // just ignore 'impulse' here, used as output variables we don't need
				theGame.GetWorld().PointProjectionTest( testPoint, normal, minimalAltitudeToKill ) == false )
		{	
			if(CheckIfCanFallDownOnAard())
			{
				// we are going to kill the bastard...
				
				// get required components
				animComponent = (CAnimatedComponent) GetComponent( "Character" );
				
				// calculate the impulse
				direction.Z = impulseZComponent;
				impulse = direction * impulseMultiplier;
			
				// set the ragdoll and kill
				ClearImmortality();
				SetRagdoll( true );
				animComponent.SetRootBoneImpulse( impulse );
				deathData.ragDollAfterDeath = true;
				deathData.fallDownDeath = true;
				Kill( false, thePlayer, deathData );

				// play some sound
				soundEventToPlay = GetFallTauntEvent();
				if(theGame.GetIsPlayerOnArena())
				{
					theGame.GetArenaManager().AddBonusPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fall_bonus'));
					theGame.GetArenaManager().ArenaCrowdReaction(ACR_Sign);
				}
				if ( soundEventToPlay != "" )
				{
					if(this.GetBoneIndex('head') != -1)
					{
						boneName = 'head';
					}
					theSound.PlaySoundOnActor(this, boneName, soundEventToPlay );
				}
			
				return true;
			}
		}
		
		return false;
	}
	
	function AardIce()
	{
		var freezeChance : float;
		
		freezeChance = thePlayer.GetCharacterStats().GetAttribute( 'aard_freeze_chance' );
		
		if( thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) )
		{
			if( RandF() < freezeChance )
			{
				ApplyCriticalEffect( CET_Freeze, NULL );
			}
			else
			{
				PlayEffect( 'aard_hit_fx' );
				//StopEffect( 'freezing_fx' );
			}
		}
	}
	
	function HandleAardHit( aard : CWitcherSignAard )
	{
		var ta : W2TakedownArea = thePlayer.GetCurrentTakedownArea();
		var level : int;
		var damage : float;
		var aardDamage, signsPower, resAard, signDamageBonus, basicDamage : float;
		var resistance : int;
		var basicDmgInt : int;
		var damageInt : int;
		if ( HandleFallingDownOnAard() )
		{
			// aard hit is 100% handled, there is no need to do anything more
			return;
		}
		
		AardIce();
		
		level = aard.GetAardLevel();
		aardDamage = thePlayer.GetCharacterStats().GetAttribute('aard_damage');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
		resAard = GetCharacterStats().GetAttribute('res_aard');
		resAard = resAard;
		if(resAard > 1.0f)
			resAard = 1.0;
		damage =  ( ( aardDamage * signsPower ) + signDamageBonus ) * ( 1 - resAard );
		if(damage <= 0)
		{
			damage = 0.0;
		}
		if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic && this.GetAttitude(thePlayer) != AIA_Friendly)
		{
			if ( thePlayer.GetWitcherType(WitcherType_Magic) )	thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
		}	
		if( !IsMonster() && ta && ta.AardTakedownTest( this ) )
		{
			//Log("HandleAardHit takedown");			
			StateTakedown( ta.GetDestination(), false, ta );
			OnAardHitReaction( aard );
		}
		else
		{
			if(this.GetAttitude(thePlayer) != AIA_Friendly)
			{
			
				basicDamage = (aardDamage * signsPower)  + signDamageBonus;
				
				basicDmgInt = RoundF(basicDamage);
				damageInt = RoundF(damage);
				resistance = basicDmgInt - damageInt;
				
				theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_aard") + " </span><span class='red'>" + damageInt + " (" + AddDamageIcon() + basicDmgInt + " - " + AddArmorIcon() + resistance + ")</span>. ");
				
				if(AardResTest(this))
				{
					this.ActionCancelAll();
					
					if( !this.IsImmortal() && !this.IsInvulnerable())
					{
						HitPosition(aard.GetWorldPosition(), 'Attack', damage, true, thePlayer, false, true);
						if(damage > 0)
						{
							PlayBloodOnHit();
						}
					}
					
					OnAardHitReaction( aard );
				}
			}
		}
	}
	function AardResTest(npc : CNewNPC) : bool
	{
		/*var res : float;
		var throw : float;
		throw = RandRangeF(0.01, 0.99);
		res = npc.GetCharacterStats().GetFinalAttribute('res_aard');
		if(throw > res)
		{
			return true;
		}
		else
		{
			return false;
		}*/
		return true;
	}
	function HandleIgniHit( igni : CWitcherSignIgni )
	{		
		var igniDamage : float;
		var signsPower : float;
		var signDamageBonus : float;
		var resIgni : float;
		var params : W2CriticalEffectParams;
		var damage : float;
		var stats : CCharacterStats;
		var basicDamage : float;
		var resistance : int;
		var basicDmgInt : int;
		var damageInt : int;
		
		igniDamage = thePlayer.GetCharacterStats().GetAttribute('igni_damage');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
		resIgni = GetCharacterStats().GetAttribute('res_igni');
		resIgni = resIgni;
		if(resIgni > 1.0f)
			resIgni = 1.0f;
		damage =  ( ( igniDamage * signsPower ) + signDamageBonus ) * ( 1 - resIgni );
		basicDamage = (igniDamage * signsPower)  + signDamageBonus;

		basicDmgInt = RoundF(basicDamage);
		damageInt = RoundF(damage);
		resistance = basicDmgInt - damageInt;
		
		if( GetAttitude(thePlayer) != AIA_Friendly )
		{
		theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_igni") + " </span><span class='red'>" + damageInt + " (" + AddDamageIcon() + basicDmgInt + " - " + AddArmorIcon() + resistance + ")</span>. ");
			
			HitPosition( igni.GetWorldPosition(), 'Attack', damage, true, thePlayer,  false, true);
			if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
			{
				if ( thePlayer.GetWitcherType(WitcherType_Magic) )	thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
			}	
			if ( thePlayer.GetCharacterStats().HasAbility( 'magic_s9' ) )
			{
				stats = thePlayer.GetCharacterStats();
				
				if(IgniResTest(this) && !this.IsBoss())
				{
					params = igni.GetCriticalEffectParams();
					this.ForceCriticalEffect(CET_Burn, params, true);
				}
				else
				{
					this.PlayEffect('fireball_hit_fx');
				}
				
			}
			else
			{
				this.PlayEffect('fireball_hit_fx');
			}
		}
	}
	function IgniResTest(npc : CNewNPC) : bool
	{
		var res : float;
		var throw : float;
		var burnChance : float;
		throw = RandRangeF(0.01, 0.99);
		res = npc.GetCharacterStats().GetFinalAttribute('res_igni');
		burnChance = thePlayer.GetCharacterStats().GetFinalAttribute('igni_burn_chance');
		if(throw < burnChance)
		{
			if(throw > res)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	function YrdenResTest(npc : CNewNPC) : bool
	{
		var res : float;
		var throw : float;
		throw = RandRangeF(0.01, 0.99);
		res = npc.GetCharacterStats().GetFinalAttribute('res_yrden');
		if(throw > res)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	// Called when an NPC gets hit with Yrden
	function CheckYrdenDamageCooldown() : bool
	{
		if(theGame.GetEngineTime() > yrdenDamageTime)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function HandleYrdenHit( yrden : CWitcherSignYrden )
	{
		if(YrdenResTest(this))
		{
			theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_yrden" ) );
			this.ActionCancelAll();
			yrdenDamageCooldown = yrden.GetImmobileTime();
			yrdenDamageTime = theGame.GetEngineTime() + yrdenDamageCooldown;
			if(thePlayer.GetCharacterStats().HasAbility('magic_s10_2'))
			{
				yrdenDamage = yrden.GetYrdenDamage(this);
				
				AddTimer('YrdenDamageTimer', 1.0, true);
			}
			// Increase stamina on hit if geralt is in magic build
			if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
			{
				if ( thePlayer.GetWitcherType(WitcherType_Magic) )	thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
			}	
			thePlayer.IncreaseStaminaBuild();
			AddTimer('removeYrdenFX', yrden.GetImmobileTime());	
			OnYrdenHitReaction(yrden);
		}
		else
		{
			this.HitPosition(yrden.GetWorldPosition(), 'Attack', 0.0, true, thePlayer, false, true);
			AddTimer('removeYrdenFX', 1.0);	
		}
	}
	event OnYrdenHitReaction(yrden : CWitcherSignYrden)
	{
		ApplyCriticalEffect( CET_Immobile, NULL, yrden.GetImmobileTime() );	
	}	
	// Called when an entity gets hit with Axii
	function HandleAxiiHit( axii : CWitcherSignAxii )
	{
		var player :CPlayer;
		var vect : Vector;
		var rot : EulerAngles;
		var berserkDuration : float;
				var previousVitality, currentVitality, vitalityChange : float;
		
		previousVitality = GetInitialHealth();
		if(thePlayer.GetCharacterStats().HasAbility('magic_s3_2'))
		{
			if(!GetCharacterStats().HasAbility('axii_debuf2'))
				GetCharacterStats().AddAbility('axii_debuf2');
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s3'))
		{
			if(!GetCharacterStats().HasAbility('axii_debuf1'))
				GetCharacterStats().AddAbility('axii_debuf1');
			
		}
		currentVitality = this.GetCharacterStats().GetFinalAttribute('vitality');
		this.SetInitialHealth(currentVitality);
		
		vitalityChange = currentVitality - previousVitality;
		if(vitalityChange > 0.0f)
		{
			this.SetHealth(this.GetHealth() + vitalityChange, false, NULL);
		}
		
		thePlayer.AddAxiiTarget(this);
		berserkDuration = thePlayer.GetCharacterStats().GetFinalAttribute('axii_control_duration')*thePlayer.GetSignsPowerBonus(SPBT_Time);
		if(berserkDuration <= 0)
		{
			berserkDuration = 15.0;
		}
		EnterBerserk(berserkDuration);
		if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
		{
			if ( thePlayer.GetWitcherType(WitcherType_Magic) )	thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
		}	
	}	
	//Signs and critical effects events - for animations handling in various combat states
	event OnAardHitReaction( aard : CWitcherSignAard );
	event OnAxiiHitReaction()
	{
		this.ActionCancelAll();
		this.GetArbitrator().AddGoalIncapacitate(3.0, false );
		this.AddTimer('AxiiIncapacitateAnim', 0.1, false);
	}
	
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
	}
	timer function YrdenDamageTimer(td : float)
	{
		if(CheckYrdenDamageCooldown())
		{
			this.RemoveTimer('YrdenDamageTimer');
		}
		else
		{
			this.DecreaseHealth(yrdenDamage, true, thePlayer);
		}
	}
	timer function AxiiIncapacitateAnim(td : float)
	{
	//	this.RaiseForceEvent( 'Axii_front' );
	}

	//////////////////////////////////////////////////////////////////////////////////////////
		
	//Removes Yrden FX from NPC. 	
	timer function removeYrdenFX(timeDelta : float)
	{
		this.StopEffect('yrden_lv0_fx');
		this.StopEffect('yrden_lv1_fx');
		this.StopEffect('yrden_lv2_fx');
	}
	
	function CantBlockCooldown(cooldown : float)
	{
		cantBlockTime = theGame.GetEngineTime() + cooldown;
	}
	function CheckCanBlock() : bool
	{
		if(cantBlockTime > theGame.GetEngineTime())
		{
			return false;
		}
		else
		{
			return true;
		}
	} 	
	//Explosion on death (used in monsters mainly)
	latent function GetExplosionParams() : SDeathExplosionParams
	{
		var explosionParams : SDeathExplosionParams;
		return explosionParams;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnHeliotropEnter()
	{
		SetAnimationTimeMultiplier( 0.25f );
	}
	
	event OnHeliotropExit()
	{
		if(!IsCriticalEffectApplied(CET_Freeze))
		{
			SetAnimationTimeMultiplier( 1.0f);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	event OnCommunityGuardingAreaEnter( area : CCommunityGuardingArea );
	event OnCommunityGuardingAreaExit( area : CCommunityGuardingArea );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function IsConversationBlocked() : bool
	{	
		var apID 							: int;
		var apMan 							: CActionPointManager = theGame.GetAPManager();
		var apString 						: string;
		var searchedStr						: string;
		var isMatch_1						: int;
		var isMatch_2						: int;
		var isMatch_3						: int;
		
		apID = GetActiveActionPoint();
		apString = apMan.GetFriendlyAPName( apID );
		searchedStr = StrAfterFirst( apString, "::" );
		
		isMatch_1 = StrFindFirst( searchedStr, "bed" );
		isMatch_2 = StrFindFirst( searchedStr, "sleep" );
		isMatch_3 = StrFindFirst( searchedStr, "no_sleep" );
				
		if( isMatch_1 >= 0 || isMatch_2 >= 0 )
		{
			if( isMatch_3 == -1 )
			{
				return true;
			}	
		}	
		else
		{
			return false;
		}	
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		var fire : CSneakLights;
		
		if( animEventName == 'start_fire' )
		{
			fire = GetNearbyFirePlace();
			if( fire.light_status == false )
			{
				fire.PlayEffect( 'fire' );
				fire.light_status = true;
			}	
		}
	}	
	
	private function GetNearbyFirePlace() : CSneakLights // pobiera entity ognia w promieniu 3 metrow
	{
		var node : CNode;
		var fire : CSneakLights;
		var i, r, size : int;
		var fire_pos, npc_pos : Vector;
		var dist : float;
		var fire_nodes : array< CNode>;
		var dist_arr : array< float >;
		
		theGame.GetNodesByTag( 'bonfire', fire_nodes );
		size = fire_nodes.Size();
		
		for( i=0; i<size; i+=1 )
		{
			fire_pos = fire_nodes[i].GetWorldPosition();
			npc_pos = this.GetWorldPosition();
			dist = VecDistance( fire_pos, npc_pos );
			dist_arr.PushBack( dist );
		}
		r = ArrayFindMinF( dist_arr );
		node = fire_nodes[r];
		fire = (CSneakLights)node;	
	
		return fire;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Update visual debug information
	//////////////////////////////////////////////////////////////////////////////////////////
	function UpdateVisualDebug()
	{	
		var vd : CVisualDebug;
		var pos : Vector;
		var col : Color;
		var att : EAIAttitude;
		var target : CActor;
		var idx, subIndex : int;
		var displayMode : name;
		
		super.UpdateVisualDebug();
	
		displayMode = theGame.aiInfoDisplayMode;		
		if( displayMode == 'all' || displayMode == 'npc' )
		{	
			vd = GetVisualDebug();
			pos = GetVisualDebugPos();
			col = GetVisualDebugColor();
			
			vd.AddText( 'dbgBehTree', GetBehTreeMachine().GetInfo(), pos, false, 12, col, false, 1.0 );
		
			att = GetAttitude( thePlayer );			
			vd.AddText( 'attitude', "Attitude to player: "+att, pos, false, 13, col, false, 1.0 );
			
			target = GetTarget();
			if( target && target.combatSlots && target.combatSlots.HasActorInCombatSlot( this ) )
			{
				idx = target.combatSlots.GetCombatSlotIndex( this, subIndex );
				if( idx != -1 )
				{
					vd.AddText('inSlot', "IN COMBAT SLOT "+idx+", "+subIndex, pos, false, 14, Color(0, 255, 0), false, 1.0 );
					vd.AddText('offSlot', "OffSlot: "+offSlot, pos, false, 15, Color(0, 255, 0), false, 1.0 );					
				}
				else
				{
					vd.RemoveText('inSlot');
					vd.RemoveText('offSlot');
				}
			}
			else
			{
				vd.RemoveText('inSlot');
				vd.RemoveText('offSlot');
			}
			
			if( combatIdleGroupIdx != -1 )
			{
				vd.AddText('inIdleSlot', "IN COMBAT IDLE GROUP "+combatIdleGroupIdx, pos, false, 14, Color(0, 255, 255), false, 1.0 );
			}
			else
			{
				vd.RemoveText('inIdleSlot');
			}
		}
	}

	event OnPushEffects( animDirection : EPushingDirection );
	
	function ForceTargetPlayer( time : float )
	{
		if( GetAttitude( thePlayer ) != AIA_Hostile )
		{
			SetAttitude( thePlayer, AIA_Hostile );
		}
		NoticeActor( thePlayer );
		GetArbitrator().LoadCombatCurves( AICCT_Standard, "goalcurves\attack_player" );
		AddTimer('ForceAttackPlayerTimer', time, false );
	}
	
	function StopTargetPlayer()
	{
		GetArbitrator().LoadCombatCurves( AICCT_Standard, "goalcurves\default" );
	}
	
	timer function ForceAttackPlayerTimer( td : float )
	{
		StopTargetPlayer();
	}
	timer function KeepCombatTimer(td : float)
	{
		thePlayer.KeepCombatMode();
	}
	
	function PlayDeathSounds()
	{
		var monsterType : EMonsterType;
		
		
		theSound.PlaySoundOnActor( this, '', "combat/weapons/hits/sword_hit" );
		if(IsMonster())
		{
			monsterType = GetMonsterType();
			
			switch (monsterType)
			{
				case MT_HumanGhost:
				{
					theSound.PlaySoundOnActor( this, '', "ghost1/combat_man/damage/anim_man_die_taunt" );
					break;
				}
				case MT_Rotfiend:
				{
					theSound.PlaySoundOnActor( this, '', "rotfiend/rotfiend/taunt/anim_rotf_die_taunt" );
					break;
				}
				case MT_Drowner:
				{
					theSound.PlaySoundOnActor( this, '', "drowner/drowner/taunt/anim_drw_die_taunt" );
					break;
				}
				case MT_Bullvore:
				{
					theSound.PlaySoundOnActor( this, '', "bullvore/bullvore/taunt/anim_bullvr_die_taunt" );
					break;
				}
				case MT_Troll:
				{
					theSound.PlaySoundOnActor( this, '', "troll/troll/taunt/anim_troll_die_taunt" );
					break;
				}
				case MT_Gargoyle:
				{
					theSound.PlaySoundOnActor( this, '', "gargoyle/gargoyle/taunt/anim_gargoyle_die_taunt" );
					break;
				}
				case MT_Golem:
				{
					theSound.PlaySoundOnActor( this, '', "golem/golem/taunt/anim_golem_die_taunt" );
					break;
				}
				case MT_Elemental:
				{
					theSound.PlaySoundOnActor( this, '', "elemental/elemental/taunt/anim_ele_die_taunt" );
					break;
				}
				case MT_Harpie:
				{
					theSound.PlaySoundOnActor( this, '', "harpy/harpy/taunt/anim_harpy_die_taunt" );
					break;
				}
				case MT_Nekker:
				{
					theSound.PlaySoundOnActor( this, '', "nekker/nekker/taunt/anim_nekk_die_taunt" );
					break;
				}
				case MT_KnightWraith:
				{
					theSound.PlaySoundOnActor( this, '', "wraith_knight/wraith_knight/damage/anim_death_taunt" );
					break;
				}
				case MT_Wraith:
				{
					theSound.PlaySoundOnActor( this, '', "wraith/wraith/taunt/anim_wraith_die_taunt" );
					break;
				}
				case MT_Bruxa:
				{
					theSound.PlaySoundOnActor( this, '', "bruxa/bruxa/taunt/anim_bruxa_die_taunt" );
					break;
				}
				case MT_Arachas:
				{
					theSound.PlaySoundOnActor( this, '', "arachas/arachas/taunt/anim_arachas_die_taunt" );
					break;
				}
				case MT_Endriaga:
				{
					theSound.PlaySoundOnActor( this, '', "endriaga/endriaga/taunt/anim_endriaga_die_taunt" );
					break;
				}
			}
		}
		else
		{
			if(IsDwarf())
			{
				theSound.PlaySoundOnActor( this, '', "combat/combat_dwarf/damage/anim_dwarf_die_taunt" );
			}
			else if(IsWoman())
			{
				theSound.PlaySoundOnActor( this, '', "combat/combat_woman/damage/anim_woman_die_taunt" );
			}
			else
			{
				theSound.PlaySoundOnActor( this, '', "combat/combat_man/damage/anim_man_die_taunt" );
			}
		}
		/////
	}
	
	function CanUseChargeAttack() : bool
	{
		return true;
	}
}
// States from C++
import state Base in CNewNPC
{
	import private var goalId : int;
	import final function MarkGoalFinished();
	
	final function SetGoalId( newGoalId : int ) { goalId = newGoalId; }
	final function GetGoalId() : int { return goalId; }
	
	event OnEnterState()
	{	
		parent.ActionCancelAll();
	}
};

// Base state supporting reactions
import state ReactingBase in CNewNPC extends Base
{	
};
