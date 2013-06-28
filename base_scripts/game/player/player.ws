/*
**********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

struct SEnemySelection
{
	var selectionAngleWeight			: float;
	var selectionDistanceWeight			: float;
	var selectionLastSelectedWeight		: float;
	var selectionLastAttackedWeight		: float;
	var selectionAngleThreshold			: float;
	var minSelectionAngleThreshold		: float;
	var lastTargetAttackedTimeout		: float;
	var lastTargetSelectedTimeout		: float;
	var finisherWeight					: float;
	var axiiWeight						: float;
	var closeAngleThreshold				: float;
	var secondaryTestMultiplicator		: float;
}

/////////////////////////////////////////////
// Input controls struct
/////////////////////////////////////////////
enum ESignPowerBonusType
{
	SPBT_Damage,
	SPBT_Range,
	SPBT_Time
};

/////////////////////////////////////////////
// Player state enum
/////////////////////////////////////////////
enum EPlayerState
{
	PS_None,
	PS_Exploration,
	PS_Sneak,
	PS_Scene,
	PS_Cutscene,
	PS_TraverseExploration,
	PS_CombatFistfightDynamic,
	PS_CombatFistfightStatic,
	PS_CombatSteel,
	PS_CombatSilver,	
	PS_CombatTakedown,
	PS_PlayerCarry,
	PS_PrepareForScene,
	PS_Prisoner,
	PS_PrisonerMovable,
	PS_AimedThrow,
	PS_Meditation,
	PS_Minigame,
	PS_UseDevice,
	PS_ZagnicaSpecial,
	PS_Investigate
};

enum EPlayerCombatStance
{
	PCS_Low,
	PCS_High
};

enum EPlayerEvadeType
{
	PET_Short,
	PET_Medium,
	PET_Long
};
enum EPlayerCombatAction
{
	PCA_None,
	PCA_GuardBlockStart,
	PCA_ThrowPetard,
	PCA_ThrowPetardFast,
	PCA_ThrowDagger,
	PCA_ThrowDaggerFast,
	PCA_StopAimingPetard,
	PCA_StopAimingDagger,
	PCA_FinishAimingDagger,
	PCA_FinishAimingPetard,
	PCA_SignAard,
	PCA_SignIgni,
	PCA_SignQuen,
	PCA_SignYrden,
	PCA_SignAxii,
	PCA_SignHeliotrop,
	PCA_AxiiFail,
	PCA_DeployTrap,
	PCA_LootGround,
	PCA_LootChest,
	PCA_UseMedalion
};
enum EPlayerActionUnbreakable
{
	PAU_None,
	PAU_Evade,
	PAU_RiposteFront1,
	PAU_RiposteFront2,
	PAU_RiposteFront3,
	PAU_RiposteBack1,
	PAU_RiposteBack2,
	PAU_RiposteBack3	
};

enum EPlayerCombatHit
{
	PCH_None,
	PCH_GuardFront,
	PCH_GuardBack,
	PCH_GuardRight,
	PCH_GuardLeft,
	PCH_Hit_0,
	PCH_Hit_1a,
	PCH_Hit_1b,
	PCH_Hit_2a,
	PCH_Hit_2b,
	PCH_Hit_3a,
	PCH_Hit_3b,
	PCH_Hit_4,
	PCH_HitHeavyFront,
	PCH_HitHeavyUp,
	PCH_HitHeavyFrontLong,
	PCH_HitHeavyBack,
	PCH_HitBack_1,
	PCH_HitBack_2,
	PCH_HitBack_3,
	PCH_ReflectedRight_1,
	PCH_ReflectedRight_2,
	PCH_ReflectedRight_3,
	PCH_ReflectedLeft_1,
	PCH_ReflectedLeft_2,
	PCH_ReflectedLeft_3
};

enum ESignTypes
{
	ST_Aard,
	ST_Yrden,
	ST_Igni,
	ST_Quen,
	ST_Axii,
	ST_Heliotrop,
	ST_LastSign //used only for array size
}

enum EWitcherType
{
	WitcherType_Unknown,
	WitcherType_Sword,
	WitcherType_Magic,
	WitcherType_Alchemy
}

enum EWitcherHairstyle
{
	WitcherHair_Default,
	WitcherHair_Dlc_01,
	WitcherHair_Dlc_02,
	WitcherHair_Dlc_03,
	WitcherHair_Dlc_04,
	WitcherHair_Dlc_05
	
}

/////////////////////////////////////////////
// Oils on weapon and elixirs on player
///////////////////////////////////////////// 
struct SBuff
{
	var m_item			: SItemUniqueId;
	var m_name			: name;
	var m_duration		: float;
	var m_maxDuration	: float;
	var m_abilities		: array < name >;
	var m_toxicity 		: int;
}

/////////////////////////////////////////////
// Directional events
///////////////////////////////////////////// 
struct W2DirectionalEvents
{
	var events : array<name>;
};

function CreateDirectionalEvents( eventFront, eventRight, eventBack, eventLeft : name ) : W2DirectionalEvents
{
	var e : W2DirectionalEvents;
	e.events.Grow(4);
	e.events[0]=eventFront;
	e.events[1]=eventRight;
	e.events[2]=eventBack;
	e.events[3]=eventLeft;
	return e;
};
enum EPlayerCombatStyle
{
	PCS_None,
	PCS_Steel,
	PCS_Silver,
	PCS_Fist
};
enum EPlayerCommentary
{
	PC_MedalionWarning,
	PC_MonsterReaction,
	PC_ToTeamNearEnemies,
	PC_ToTeamNearEnemiesWhisper
};
struct SKnowledgeAccum
{
	var m_category		: name;
	var m_level			: int;
	var m_experience	: float;
}

import struct SSinglePushQTEStartInfo
{
	import var action : name;
	import var timeOut : float;
	import var ignoreWrongInput : bool;
	import var isSkippable : bool;
	import var position : EQTEPosition;
}

import struct SMashQTEStartInfo
{
	import var action : name;
	import var initialValue : float;
	import var timeOut : float;
	import var decayPerSecond : float;
	import var increasePerMash : float;
	import var ignoreWrongInput : bool;
}

/////////////////////////////////////////////
// Player class
///////////////////////////////////////////// 
import class CPlayer extends CActor
{
	//////////////////////////////////////////////////////////////////////////////////////////
	editable inlined var attackInterestPoint	: CInterestPoint;
	editable inlined var monsterInterestPoint	: CInterestPoint;	
	editable inlined var npcCombatInterestPoint : CInterestPoint;
	editable inlined var pushingInterestPoint	: CInterestPoint;
	editable 		 var sparks 				: CEntityTemplate;
	editable var decalMaterials					: array< IMaterial >;
	
	// TALISMAN GUIDE
	editable var talismanGuideEntity 			: CEntityTemplate;
	private saved var m_talismanTargetTag		: name;
	private var m_talismanGuide 				: CTalismanGuide;
	
	// CAMERA
	import var isCameraVerticalSnapEnabled				: bool;
	private var cameraTick								: float;
	private var cameraFurther							: float;
	private var cameraFurtherCurrent					: float;	
	private saved var radialBlurValue					: float;
	private saved var radialBlurTarget					: CNode;
	private saved var turnOffCombatCamera				: bool;
	var	soundMaterials									: C2dArray;
	
	// MOVEMENT
	private				var rawPlayerSpeed 				: float;
	private 			var rawPlayerAngle		 		: float;
	private 			var rawPlayerHeading			: float;
	private 			var enteringObstacle			: bool;
	private 			var blockSpeedReset				: bool;
	import private 		var isMovable 					: bool;	
	
	// STATE MANAGEMENT
	private saved		var blockedStates				: array<EPlayerState>;
	private saved		var blockedAllStates			: bool;
	private 			var	sceneExitState				: EPlayerState;
	private 			var reloadingScriptsState		: EPlayerState;
	private	saved		var savedState 					: EPlayerState;
	private saved		var sneakMode 					: bool;
	
	private 			var	selectSignTime				: EngineTime;
	private				var selectSignCooldown			: float;
	
	private				var arrowSoundTime				: EngineTime;
	private 			var arrowSoundCooldown			: float;

	private 			var darkEffect					: bool;
	private 			var darkWeapon					: bool;
	private 			var darkWeaponAddVitality		: bool;
	private 			var darkWeaponSteel				: bool;
	private 			var darkWeaponSilver			: bool;
	
	// COMBAT
	import private		var combatMode					: int;
	private				var combatModeSaveLock			: int;
	private				var currentTakedownArea			: W2TakedownArea;
	private				var signBehaviorEvents			: array< EPlayerCombatAction >;
	private saved		var selectedSign				: ESignTypes;
	private				var oldSign						: ESignTypes;
	private				var restoreOldSign				: bool;
	private 			var thrownItemId				: SItemUniqueId;
	private	saved		var thrownItemName				: name; // for saving
	private				var ticketPools					: array<W2TicketPool>;
	private				var combatStance				: EPlayerCombatStance;
	private				var hitEnums_t2 				: array<EPlayerCombatHit>;
	private				var hitEnums_t3 				: array<EPlayerCombatHit>;
	
	private				var inDynamicFistfightArea		: bool;
						var lockEnemyFlag 				: bool;
						var canDisableBerserk			: bool;
	
	// GAMEPLAY
	private				var USMTitle					: CFlashValueScript;	
	private				var qteListener					: QTEListener;	
	private saved 		var interactionData				: W2PlayerInteractionData;
	private editable	var medalionEntity				: CEntityTemplate;
	private editable	var axiiMinigame				: CEntityTemplate;
	private saved		var m_activeOils				: array < SBuff >;
	private saved		var m_activeElixirs				: array < SBuff >;
	private editable saved		var m_knowledge					: SJournalKnowledge;		// journal knowledge
	private saved		var m_knowledgeAccum			: array< SKnowledgeAccum >;	// monster knowledge exp
	private saved		var canUseHUD					: bool;
	private saved		var isNotGeralt					: bool;
	private saved		var isAssasinReplacer			: bool;
	
	private saved		var dontRecalcStats				: bool;
	private 			var m_canUseMedallion			: bool;
	private saved		var m_canMeditate				: bool;
	private				var m_isInShadow				: bool;
	
	private				var staminaRegenerationCooldown	: float;
	
	private saved		var toxicity					: float;
	private saved		var adrenaline					: float;
	private saved		var experience	 				: int;
	private saved		var talents						: int;

	private				var m_trackedQuestEntities		: array< CEntity >;
	private	saved		var m_trackedQuestTags			: array< name >;
	private saved		var activeQuenSign				: CWitcherSignQuen;	
						var sourceDrainStaminaIncrease	: float;
						
	private				var m_itemsToAutoMount			: array< SItemUniqueId >;
	private				var m_autoMountWithBlackScreen	: bool;
	
	private saved		var currentAreaMapId			: string;
	private saved		var currentAreaMapShowAreaName	: bool;
	private saved		var currentMapId				: int;
	// This number will be treated as invalid map ID. ( -1 cannot be defaulted... what a pity )
	default currentMapId = 1234;
	
	private				var lastBribe					: int;
						var yrdenTrapsActive			: array<CWitcherSignYrden>;
						var yrdenTrapsSize				: int;
						var maxYrdenTraps				: int;
						
						var lastOverweightCheck			: EngineTime;
						var lastOverweightResult		: bool;
						var isOverweightTestRequired	: bool;
						
	private 			var shopowner 					: CActor;
	private 			var storageowner				: W2PlayerStorage;
	private				var lastboard					: CQuestBoard; // DO WYWALENIA JAK WEJDZIE FINALNE QUEST BOARD PANEL
	
	private				var lastBook					: SItemUniqueId;
	
	private		   		var m_areHotKeysBlocked			: bool;
	private		saved   var m_areCombatHotKeysBlocked	: bool;
	private		saved   var m_isCombatBlocked			: bool;

	private				var m_lowStanceCooldown			: float;
	
	private				var m_fistFightCooldown			: float;
	private				var hardlockOn					: bool;
	default 			hardlockOn						= false;
	
	private 			var m_TrackQuestIds				: array < string >;
	private 			var m_TrackQuestMax				: array < int >;

	
	private saved 		var lastCombatStyle				: EPlayerCombatStyle;
	
	private 			var commentaryCooldown		: float;
	private				var commentaryLastTime		: EngineTime;
	
	private				var isCastingAxii			: bool;
	private				var inAxiiLoop				: bool;
	
	private				var lastEncumberedMsg		: EngineTime;
	
	private				var m_isSpawned				: bool; // true after "OnSpawned", when player is attached, so AddTimer will be possible
	
	private saved		var m_isEnemyLocked 	: bool;
	
	private 			var ffLootInteractionEnabled : bool;	
	
	private				var useAnimInHeliotrop : bool;
	
	private	saved		var currentHairstyle : name;
	
	private saved 		var enableTutorialButton	: bool;
						var	tutHasBlocked			: bool;
	private saved 		var savedSlotItemsNames		: array< name >;
	private saved 		var savedSlotItemsQty		: array< int >;
	
		
	//ACHIEVEMENTS
	private	saved		var riposteInARow			: int;
	private saved		var insaneAchBlock			: bool;
	private saved		var killedWithoutHurt		: int;
	
	//Police intervention
	private editable	var interventionPointTemplate	: CEntityTemplate;
	private 			var interventionPointEntity		: CEntity;
	private				var beforeInterventionPosition	: Vector;
	private				var beforeInterventionRotation	: EulerAngles;
	public				var areGuardsHostile			: bool;
	
	//Traps cooldown
	private				var lastTrapTime				: EngineTime;
	private				var trapDeployCooldown			: float;
	
	private saved		var savedSilverSword			: SItemUniqueId;
	private saved		var savedSteelSword				: SItemUniqueId;
	private saved		var savedArmor					: SItemUniqueId;
	private saved		var savedGloves					: SItemUniqueId;
	private saved		var savedPants					: SItemUniqueId;
	private saved		var savedTrophy					: SItemUniqueId;
	private saved		var savedShoes					: SItemUniqueId;
	
	private 			var requestCombatEndAnim 		: bool;
						var enemySelection				: SEnemySelection;
						var usesCombatV2				: bool;
						var combatRotationAllowed		: bool;
						var cantRotateTime				: EngineTime;
						var cantRotateTimeOut			: float;
						var canPlayHit					: bool;
						var noHitsTime					: EngineTime;
						var noHitsTimeOut				: float;
						var isKnockedDown				: bool;
						var knockedDownTime				: EngineTime;
						var knockedDownTimeOut			: float;
						var lastLockedTarget			: CActor;
						var blockCombatArea				: CBlockCombatArea;
						var isBigBossFight				: bool;
						var gameEnded					: bool;
						var cantBlock					: bool;
						var cantBlockTime				: EngineTime;
						var cantBlockCooldown			: float;
	
						
						
	
	var arenaPoints : float;
	
	function SetGameEnded()
	{
		gameEnded = true;
	}
	
	function GetGameEnded() : bool
	{
		return gameEnded;
	}
	
	function IsBigBosFight() : bool
	{
		return isBigBossFight;
	}
	
	function SetBigBossFight( flag : bool )
	{
		isBigBossFight = flag;
	}
	
	function GetLastLockedTarget() : CActor
	{
		return lastLockedTarget;
	}
	function SetLastLockedTarget(target : CActor)
	{
		lastLockedTarget = target;
	}
	
	function CheckSet(item : SItemUniqueId, parentObject : CEntity)
	{
		var inv	: CInventoryComponent;
		var itemName : name;
		var conditionsArray : array<name>;
		var isDarkSet : bool;
		var i, size : int;
		
		inv	= thePlayer.GetInventory();
		itemName = inv.GetItemName(item);
			
		if(inv.ItemHasTag(item, 'DarkDiffA1'))
		{
			conditionsArray.Clear();
			conditionsArray.PushBack('Dark difficulty steelsword A1');
			conditionsArray.PushBack('DarkDifficultyArmorA1');
			conditionsArray.PushBack('DarkDifficultyBootsA1');
			conditionsArray.PushBack('DarkDifficultyGlovesA1');
			conditionsArray.PushBack('DarkDifficultyPantsA1');
			conditionsArray.PushBack('Dark difficulty silversword A1');
		
		}
		else if(inv.ItemHasTag(item, 'DarkDiffA2'))
		{
			conditionsArray.Clear();
			conditionsArray.PushBack('Dark difficulty steelsword A2');
			conditionsArray.PushBack('DarkDifficultyArmorA2');
			conditionsArray.PushBack('DarkDifficultyBootsA2');
			conditionsArray.PushBack('DarkDifficultyGlovesA2');
			conditionsArray.PushBack('DarkDifficultyPantsA2');
			conditionsArray.PushBack('Dark difficulty silversword A2');
		}
		else if(inv.ItemHasTag(item, 'DarkDiffA3'))
		{
			conditionsArray.Clear();
			conditionsArray.PushBack('Dark difficulty steelsword A3');
			conditionsArray.PushBack('DarkDifficultyArmorA3');
			conditionsArray.PushBack('DarkDifficultyBootsA3');
			conditionsArray.PushBack('DarkDifficultyGlovesA3');
			conditionsArray.PushBack('DarkDifficultyPantsA3');
			conditionsArray.PushBack('Dark difficulty silversword A3');
		}
		
		conditionsArray.Remove(itemName);
		
		isDarkSet = true;
		size = conditionsArray.Size();
		
		if(size <= 0)
		{
			thePlayer.SetDarkSet(false);
			return;
		}
		
		for(i = 0; i < size; i += 1)
		{
			if(!inv.IsItemMounted(inv.GetItemId(conditionsArray[i])))
			{
				if(!inv.IsItemHeld(inv.GetItemId(conditionsArray[i])))
				{
					isDarkSet = false;
					break;
				}
			}
		}
		
		thePlayer.SetDarkSet(isDarkSet);
		
	}
	
	function IsPlayerKnockedDown() : bool
	{
		if(theGame.GetEngineTime() > knockedDownTime + knockedDownTimeOut)
		{
			isKnockedDown = false;
		}
		return isKnockedDown;
	}
	function SetPlayerKnockedDown( flag : bool )
	{
		if(flag)
		{
			knockedDownTime = theGame.GetEngineTime();
			knockedDownTimeOut = 3.0;
		}
	
		isKnockedDown = flag;
		
	}
	
	function IsHeavyHit(hit : EPlayerCombatHit) : bool
	{
		var isHeavy : bool;
		
		isHeavy = false;
		
		switch( hit ) 
		{
			case PCH_HitHeavyFront :
			{
				isHeavy = true;
				break;
			}
			case PCH_HitHeavyUp :
			{
				isHeavy = true;
				break;
			}
			case PCH_HitHeavyFrontLong :
			{
				isHeavy = true;
				break;
			}
			case PCH_HitHeavyBack :
			{
				isHeavy = true;
				break;
			}
			case PCH_HitHeavyBack :
			{
				isHeavy = true;
				break;
			}
			case PCH_Hit_4 :
			{
				isHeavy = true;
				break;
			}
			case PCH_Hit_3a :
			{
				isHeavy = true;
				break;
			}
			case PCH_Hit_3b :
			{
				isHeavy = true;
				break;
			}
			case PCH_HitBack_3 :
			{
				isHeavy = true;
				break;
			}                
		}
		return isHeavy;
	}
	function IsMediumHit(hit : EPlayerCombatHit) : bool
	{
		var isMedium : bool;
		
		isMedium = false;
		
		switch( hit ) 
		{
			case PCH_HitBack_1 :
			{
				isMedium = true;
				break;
			}
			case PCH_HitBack_2 :
			{
				isMedium = true;
				break;
			}
			case PCH_Hit_1b :
			{
				isMedium = true;
				break;
			}                   
		}
		return isMedium;
	}
	function HasToPlayHit( hitParams : HitParams ) : bool
	{
		var hitEnum : EPlayerCombatHit;
		hitEnum = ChooseHitEnum( hitParams );
		
		if(IsHeavyHit( hitEnum ))
		{
			return true;
		}
		if(IsMediumHit( hitEnum ))
		{
			if(Rand(10) == 1)
			{
				return true;
			}
		}
		if( hitParams.attacker.IsBoss() || hitParams.attacker.IsHuge() )
		{
			return true;
		}
		
		return false;
	}
	function CanPlayHitAnim( hitParams : HitParams ) : bool
	{
		if(!GetCombatV2())
		{
			return true;
		}
		if(theGame.GetEngineTime() > noHitsTime + noHitsTimeOut || HasToPlayHit( hitParams ))
		{
			canPlayHit = true;
		}
		if(IsPlayerKnockedDown())
		{
			canPlayHit = false;
		}
		return canPlayHit;
	}
	function SetCanPlayHit( flag : bool )
	{
		canPlayHit = flag;
		if(!flag)
		{
			noHitsTime = theGame.GetEngineTime();
			noHitsTimeOut = 2.0;
		}
	}
	
	function SetCombatV2(usesNewCombat : bool)
	{
		usesCombatV2 = usesNewCombat;
	}
	
	function GetCombatV2() : bool
	{
		return usesCombatV2;
	}
	
	function SetEnemySelectionWeights(angleThreshold, minAngleThreshold, angle, distance, selected, attacked, selectedTimeOut, attackedTimeOut, finisher, axii, closeAngle, secondaryTestMult : float )
	{
		enemySelection.selectionAngleThreshold = angleThreshold;
		enemySelection.minSelectionAngleThreshold = minAngleThreshold;
		enemySelection.selectionAngleWeight = angle;
		enemySelection.selectionDistanceWeight = distance;
		enemySelection.selectionLastSelectedWeight = selected;
		enemySelection.selectionLastAttackedWeight = attacked;
		enemySelection.lastTargetSelectedTimeout = selectedTimeOut;
		enemySelection.lastTargetAttackedTimeout = attackedTimeOut;
		enemySelection.finisherWeight = finisher;
		enemySelection.axiiWeight = axii;
		enemySelection.closeAngleThreshold = closeAngle;
		enemySelection.secondaryTestMultiplicator = secondaryTestMult;
	}
	function GetEnemySelection() : SEnemySelection
	{
		return enemySelection;
	}
	
	function SetCombatEndAnimRequest(flag : bool)
	{
		requestCombatEndAnim = flag;
	}
	function GetCombatEndAnimRequest() : bool
	{
		return requestCombatEndAnim;
	}
	
	function GetInsaneAch() : bool
	{
		return !insaneAchBlock;
	}
	function SetInsaneAch( val : bool )
	{
		insaneAchBlock = !val;
	}
	
	function SetRiposteInRow(num : int)
	{
		riposteInARow = num;
	}
	function GetRiposteInRow() : int
	{
		return riposteInARow;
	}
	
	function SetGuardsHostile( areHostile : bool )
	{
		if( areHostile )
		{
			theGame.SetGlobalAttitude( 'player', 'flotsam_guards', AIA_Hostile );
			theGame.SetGlobalAttitude( 'player', 'vergen_guards', AIA_Hostile );
			theGame.SetGlobalAttitude( 'player', 'kaedwen_guards', AIA_Hostile );
			theGame.SetGlobalAttitude( 'player', 'a3_center_area_guards', AIA_Hostile );
			areGuardsHostile = true;
		}
		else
		{
			theGame.SetGlobalAttitude( 'player', 'flotsam_guards', AIA_Neutral );
			theGame.SetGlobalAttitude( 'player', 'vergen_guards', AIA_Neutral );
			theGame.SetGlobalAttitude( 'player', 'kaedwen_guards', AIA_Neutral );
			theGame.SetGlobalAttitude( 'player', 'a3_center_area_guards', AIA_Neutral );
			areGuardsHostile = false;
		}
	}
	
	function SetInterventionCSPosition()
	{
		var nodes : array< CNode >;
		var closestNode : CNode;
		var minDist, dist : float;
		var size, i : int;
		
		if( !interventionPointEntity )
		{
			interventionPointEntity = theGame.CreateEntity( interventionPointTemplate, GetWorldPosition() );
		}
		
		beforeInterventionPosition = GetWorldPosition();
		beforeInterventionRotation = GetWorldRotation();
		
		theGame.GetNodesByTag( 'ipoint', nodes );
		size = nodes.Size();
		if( size > 0 )
		{
			closestNode = nodes[0];
			minDist = VecDistance( beforeInterventionPosition, nodes[0].GetWorldPosition() );
			for( i = 1; i < size; i += 1 )
			{
				dist = VecDistance( beforeInterventionPosition, nodes[i].GetWorldPosition() );
				if( dist < minDist )
				{
					closestNode = nodes[i];
					minDist = dist;
				}
			}
			
			interventionPointEntity.TeleportToNode( closestNode, true );
		}
	}
	
	function TeleportToBeforeInterventionPoint()
	{
		thePlayer.TeleportWithRotation( beforeInterventionPosition, beforeInterventionRotation );
	}
	
	//Finisher areas
	
	private 			var playerInFinisherArea : EFinisherAreaNum;
	
	default m_isSpawned = false;
	
	default level = 1;
	
	var					isDodge						: bool;
	default				isDodge 					= false;
	var					lastDodgeTime				: EngineTime;
	
	var					hudFadeoutTimer				: float;
	var 				hudFadeoutTimerBlocked 		: bool;
	
	var 				playCameraVitEffect			: bool;
	
	var					meditationExitTime 			: EngineTime;
	var					meditationExitCooldown 		: float;
	
	var					lastContainer			    : CContainer;
	var					guardBlock					: bool;
	
	var					heliotropTime				: EngineTime;
	var					signAfterHeliotropCooldown	: float;
	
	default				meditationExitCooldown = 10.0;
	default 			playCameraVitEffect = false;
	
	private				var axiiNPCs				: array<CNewNPC>;
	
	private 			var drunkTimer				: float;
	
	default 			m_lowStanceCooldown 			= 0.0f;
	default 			m_fistFightCooldown 			= 0.0f;
	private 			var evadeType	: EPlayerEvadeType;
	
	private				var m_pendingBehaviorDeactivation	: name;
	
	private				var m_hideHudCount	 : int;
	default m_hideHudCount = 0;
	
	// A bit hacky way to pause cat effect for dialogs - it should be in state scene, but can not because scene embedded minigames can end state scene to early
	import private		var pausedCatEffectTime	: float;
	
	// FAST MENU
	private				var selectedSlotItem			: int;
	default selectedSlotItem = 0;
	
	private saved		var isWaitTimeAllowed : bool;
	
	private saved 		var combatBlockTriggerActive : bool;
	
	default isWaitTimeAllowed = true;
	
	var takeDownTime : EngineTime;
	var takeDownDuration : float;
	
	editable var guideEntity : CEntityTemplate;
	
	default adrenaline					= 0;
	default toxicity					= 0;
	default sourceDrainStaminaIncrease	= 1.0;
		
	default canUseHUD					= true;
	default m_canUseMedallion			= true;
	default m_canMeditate				= true;
	default m_isInShadow				= false;
	
	default m_autoMountWithBlackScreen	= false;
	
	var darkSet : bool;
	
	// Switch between run/walk
	import final function SwitchWalkFlag();
	
	// Set player's movement speed
	import final function SetMoveSpeed( value : float );
	
	// Get player's movement speed
	import final function GetMoveSpeed() : float;

	// Set player's rotation speed
	import final function SetRotationSpeed( value  : float );
	
	// Set player's movement direction ( world space )
	import final function SetMoveDirection( value  : float );
	
	// Get combat area rotation
	import final function GetCombatAreaAngle() : float;
	
	// Get combat area range
	import final function GetCombatAreaRange() : float;
	
	// Find enemies in combat area (hostile or neutral actors)
	import final function FindEnemiesInCombatArea() : array< CActor >;
	
	// Find enemies in combat area (hostile or neutral actors) we can target
	import final function FindEnemiesToTarget() : array< CActor >;
	
	// Reset player camera
	import final function ResetPlayerCamera();

	import final function ResetPlayerMovement();
	
	// Block/Unblock player camera rotation
	import final function BlockPlayerCameraRotation();
	import final function UnblockPlayerCameraRotation();
	import final function IsPlayerCameraBlocked() : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Returns the desired movement speed requested by the player
	import final function EvaluateMovement( timeDelta : float, out speed : float, out heading : float );
	
	// Returns the desired movement direction ( in camera relative space )
	import final function GetCameraRelativeHeading() : float;
	
	// Returns the horizontal camera movement speed
	import final function GetCameraHorizontalSpeed() : float;
	
	// Returns the vertical camera movement speed
	import final function GetCameraVerticalSpeed() : float;
	
	// Clamps the current movement speed to walk speed
	import final function SetWalkMode( enable : bool );
	
	// Sets the hardlock phase
	function SetHardlock( enable : bool )
	{
		hardlockOn = enable;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Lock player's button interaction - use in EnterState
	import final function LockButtonInteractions();
	
	// Unlock player's button interaction - use in LeaveState
	import final function UnlockButtonInteractions();
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	import final function GetAnimCombatSlots( combatSlotAnim : name, out outSlots : array< Matrix >, slotsNum : int,
											  attackerSlotNum : int, attackerMatrix : Matrix,
											  mainEnemySlotNum : int, mainEnemyMatrix : Matrix, optional rotateEnemies : bool /*=true*/ ) : bool;

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Start QTE with one key to press
	import latent final function StartSinglePressQTE( startInfo : SSinglePushQTEStartInfo ) : bool;
	import final function StartSinglePressQTEAsync( startInfo : SSinglePushQTEStartInfo ) : bool;
	
	// Start QTE with button mashing
	import latent final function StartMashFullQTE( startInfo : SMashQTEStartInfo ) : bool;
	import final function StartMashFullQTEAsync( startInfo : SMashQTEStartInfo ) : bool;
	
	// Start QTE with button mashing
	import latent final function StartMashSaveQTE( startInfo : SMashQTEStartInfo ) : bool;
	import final function StartMashSaveQTEAsync( startInfo : SMashQTEStartInfo ) : bool;
	
	// Break current QTE
	import final function BreakQTE();
	
	import final function GetLastQTEResult() : EQTEResult;	
	
	final function SetPlayerFinisherArea(finisherArea : EFinisherAreaNum)
	{
		playerInFinisherArea = finisherArea;
	}
	final function GetPlayerFinisherArea() : EFinisherAreaNum
	{
		return playerInFinisherArea;
	}
	final function GetIsEnemyLocked() : bool
	{
		return m_isEnemyLocked;
	}
	final function SetIsEnemyLocked( val : bool ) 
	{
		m_isEnemyLocked = val;
	}
	
	function GetLockedTarget() : CActor
	{
		var target : CActor = NULL;
		OnGetLockedTarget( target );
		
		return target;
	}
	
	event OnGetLockedTarget( out target : CActor ) {}
	
	final function IsInTakedownCutscene() : bool
	{
		if(theGame.GetEngineTime() < takeDownTime + takeDownDuration)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	final function SetTakedownCutscene(cutsceneDuration : float)
	{
		takeDownTime = theGame.GetEngineTime();
		takeDownDuration = cutsceneDuration;
		
	}
	
	function IsDarkEffect() : bool             		 { return darkEffect; }
	function SetDarkEffect( val : bool )       		 
	{ 
		darkEffect = val;
		if(val == true)
		{
			EnableDarkMode();
		}
		else
		{
			DisableDarkMode();
		}
	}
	function SetDarkWeaponSilver( val : bool ) 		 
	{ 
		darkWeaponSilver = val; 
		if(val)
		{
			//First we should turn off all effects
			//SetDarkEffect( false );
			//SetDarkWeaponAddVitality( false );
			theCamera.StopEffect('dark_difficulty');
			
			SetDarkWeaponAddVitality( true );
			if(!thePlayer.IsDarkEffect())
			{
				if ( !thePlayer.IsNotGeralt() ) theCamera.PlayEffect('dark_difficulty');
				SetDarkEffect( true );
			}
		}
		else
		{
			SetDarkEffect( false );
			SetDarkWeaponAddVitality( false );
			theCamera.StopEffect('dark_difficulty');
		}
	}
	function SetDarkWeaponSteel( val : bool )  		 
	{ 
		darkWeaponSteel = val; 
		if(val)
		{
			//First we should turn off all effects
			//SetDarkEffect( false );
			//SetDarkWeaponAddVitality( false );
			
			theCamera.StopEffect('dark_difficulty');
			
			SetDarkWeaponAddVitality( true );

			if(!thePlayer.IsDarkEffect())
			{
				if ( !thePlayer.IsNotGeralt() ) theCamera.PlayEffect('dark_difficulty');
				SetDarkEffect( true );
			}
		}
		else
		{
			SetDarkEffect( false );
			SetDarkWeaponAddVitality( false );
			theCamera.StopEffect('dark_difficulty');
		}
	}
	function SetDarkWeaponAddVitality( val : bool )  
	{ 
		darkWeaponAddVitality = val; 
	}
	function IsDarkWeaponAddVitality() : bool        
	{ 
		return darkWeaponAddVitality; 
	}
	function IsDarkWeaponSilver(): bool        		 
	{ 
		return darkWeaponSilver; 
	}
	function IsDarkWeaponSteel() : bool        		 
	{ 
		return darkWeaponSteel; 
	}
	function IsDarkWeapon() : bool 		       		 
	{ 
		if ( darkWeaponSteel || darkWeaponSilver ) 
		{ 
			return true; 
		} 
		else 
		{ 
			return false; 
		}  
	}
	
	function IsDarkSet() : bool
	{
		return darkSet;
	}
	function SetDarkSet(value : bool)
	{
		darkSet = value;
	}
	function SetQTEListener( listener : QTEListener ) { qteListener = listener; }
	
	// QTE mash button event
	event OnQTEMash( key : name, qteValue : float)
	{
		if ( qteListener )
		{
			qteListener.OnQTEMash( this, key, qteValue );
		}
	}
	// QTE success event
	event OnQTESuccess( resultData : SQTEResultData )
	{
		if ( qteListener )
		{
			qteListener.OnQTESuccess( this, resultData );
		}
		
		// TODO: Play GUI effect
	}
	// QTE failure event
	event OnQTEFailure( resultData : SQTEResultData)
	{
		if ( qteListener )
		{
			qteListener.OnQTEFailure( this, resultData );
		}
		
		// TODO: Play GUI effect
	}
	
	// combat blocking trigger additional logic


	
	// Try finding empty area of given radius
	import final function FindEmptyArea( searchRadius : float, areaRadius : float, out position : Vector ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get items in quick slots
	import final function GetItemsInQuickSlots() : array< SItemUniqueId >;
	
	// Get item in given quick slot
	import final function GetItemInQuickSlot( quickSlotIndex : int ) : SItemUniqueId;

	// Put item in first empty quick slot
	import final function AddItemToQuickSlots( itemId : SItemUniqueId ) : bool;
	
	// Put item in the specified quick slot, pass invalid item id to clear quick slot, return true on success
	import final function SetItemInQuickSlot( itemId : SItemUniqueId, slotNum : int ) : bool;

	// Remove item from quick slots bar
	import final function RemoveItemFromQuickSlots( itemId : SItemUniqueId ) : bool;
	
	// Remove all items from quick slots bar
	import final function ClearAllItemsInQuickSlots();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//  Is cat effect enabled
	import final function IsCatEffectEnabled() : bool;
	
	// Enable cat effect
	import final function EnableCatEffect( enable : bool, optional time : float );
	
	// Get cat effect time
	import final function GetCatEffectTime() : float;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	function CombatCameraSwich( turnedOn : bool )
	{
		turnOffCombatCamera = turnedOn;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	timer function clearHudTextFieldTimer( timeDelta : float )
	{
		clearHudTextField();
	}

	private function clearHudTextField()
	{
		theHud.m_hud.clearCSText();
		theHud.m_hud.SetTextField( 0, "", 1, 1 );
		theHud.m_hud.SetTextField( 1, "", 1, 1 );
	}
	
	final function GetTrackedQuestEntities() : array< CEntity >
	{
		return m_trackedQuestEntities;
	}
	
	import final function GetTrackedQuest() : CGUID;
	
	import final function SetTrackedQuest( entryGuid : CGUID );
	
	import final function GetQuestLogEntries( out entries : array< SJournalQuestEntry > );
	
	import final function GetQuestLogEntryDescription( entryGuid : CGUID ) : string;

	import final function UpdateLinksInDescription( out description : string );
	
	import final function MarkQuestLogEntryRead( entryGuid : CGUID );
	
	import final function HACKReenterExplorationAreas();
	
	function SetFFLootEnabled(flag : bool) 
	{
		ffLootInteractionEnabled = flag;
	}
	function GetFFLootEnabled() : bool
	{
		return ffLootInteractionEnabled;
	}
	
	function SetLastContainer( val : CContainer)
	{
		lastContainer=val;
	}
	function GetLastContainer() : CContainer
	{
		return lastContainer;
	}
	
	function SetKilledWithoutHurt( val : int )
	{
		killedWithoutHurt = val;
	}
	function GetKilledWithoutHurt() : int
	{
		return killedWithoutHurt;
	}
	
	function GetSignsPowerBonus(signBonusType : ESignPowerBonusType) : float
	{
		var signsPower : float;
		signsPower = thePlayer.GetCharacterStats().GetFinalAttribute('signs_power');

		if(signBonusType == SPBT_Range && signsPower > 1)
		{
			signsPower = 1 + 0.5 * signsPower;
		}
		if(signBonusType == SPBT_Time)
		{
			signsPower = 1 + 0.3*signsPower;
		}
		if(signsPower < 1.0f)
			signsPower = 1.0f;
		return signsPower; 
	}
	function GetIsInDynamicFFArea() : bool
	{
		return inDynamicFistfightArea;
	}
	function SetIsInDynamicFFArea(flag : bool)
	{
		inDynamicFistfightArea = flag;
	}
	final function PushAwayFromPlayer(pushRange : float, pushSpeed : float)
	{
		var playerMAC 					: CMovingAgentComponent = thePlayer.GetMovingAgentComponent();
		var playerPos 					: Vector;
		var dirFromPlayer 				: Vector;
		var playerHeading 				: Vector;
		var distToPlayer 				: float;
		var pushDir 					: Vector;
		var pushAngle 					: float;
		var nearbyAgents 				: array< CActor >;
		var i, count					: int;
		var actor 						: CActor;
		var npc							: CNewNPC;
		//	push nearby characters away
		ActorsStorageGetClosestByActor( thePlayer, nearbyAgents, Vector( -pushRange, -pushRange, -1 ), Vector( pushRange, pushRange, 1 ), thePlayer, true, true );
			
		playerPos = thePlayer.GetWorldPosition();
		playerHeading = VecFromHeading( playerMAC.GetHeading() );
			
		count = nearbyAgents.Size();
		for ( i = 0; i < count; i += 1 )
		{
			actor = nearbyAgents[i];
			dirFromPlayer = actor.GetWorldPosition() - playerPos;
			distToPlayer = VecLength( dirFromPlayer );
			dirFromPlayer = VecNormalize( dirFromPlayer );
			pushAngle = VecDot( dirFromPlayer, playerHeading );
		
			if ( distToPlayer < pushRange && pushAngle > 0.0f )
			{
				pushDir = actor.GetWorldPosition() - ( playerPos + playerHeading * pushAngle );
				pushDir = VecNormalize( pushDir ) * ( pushRange - distToPlayer );
				pushDir.Z = 0;
				npc = (CNewNPC)actor;
				if(npc && npc.GetAttitude(thePlayer) == AIA_Hostile && !npc.IsHuge() && !npc.IsBoss() && !npc.IsCriticalEffectApplied(CET_Stun) && !npc.IsCriticalEffectApplied(CET_Knockdown))
					actor.PushInDirection( playerPos, pushDir, pushSpeed, false, false );
			}
		}
	}
	// Called when the player is dodging, and inflicts certain dodge-related effects ( such as nearby opponents being thrown away )
	private var isDodgeTimerOn : bool;
	default isDodgeTimerOn = false;
	final function ActivateDodging()
	{
		// push enemies away from player
		PushAwayFromPlayer(3.0, 1.0);
		if ( isDodgeTimerOn == false )
		{
			isDodgeTimerOn = true;
			theGame.EnableButtonInteractions( false );
			AddTimer( 'DodgingTimer', 2.0f );
		}
		
		// modify dodge flag
		isDodge = true;
		lastDodgeTime = theGame.GetEngineTime();
	}
	
	timer function DodgingTimer( timeDelta : float )
	{
		theGame.EnableButtonInteractions( true );
		RemoveTimer( 'DodgingTimer' );
		isDodgeTimerOn = false;
	}
	
	timer function ClearAchievement( timeDelta : float )
	{
		theHud.m_hud.HideAchievement();
	}
	timer function ClearTutorial( timeDelta : float )
	{
		theHud.m_hud.HideTutorial();
	}
	timer function UnlockTutorial( timeDelta : float )
	{
		theHud.m_hud.UnlockTutorial();
	}

///////////////// NEW TUTORIAL //////////////////////////////////////////////////////////////////////
	
	private function EnableTutButton( isEnabled : bool )
	{
		enableTutorialButton = isEnabled;
	}
	
	private function TutorialResetPlayerBlocked()
	{
		tutHasBlocked = false;
	}

	function ToggleTutorialPanel( isNew : bool )
	{
		var res : bool;
		
		if( theGame.tutorialPanelHidden )
		{
			if( isNew )
				theGame.SetTutorialUseNew( true );
			else
				theGame.SetTutorialUseNew( false );
			
			Log( " ====================== Player Toggled Panel theGame.tutorialPanelHidden == true, Showing Panel ====================" );
			theGame.TutorialPanelHidden( false );
			theHud.ShowTutorialPanel();
		}
		else
		{
			if( isNew )
				theGame.SetTutorialUseNew( true );
			else
				theGame.SetTutorialUseNew( false );
			Log( " ======================= Player Toggled Panel, theGame.tutorialPanelHidden == false, Hiding Panel ====================" );
			theGame.TutorialPanelHidden( true );
			theHud.HideTutorialPanel();
		}
	}
	
	private function ShowTutorialQuestPanel( isNew : bool )
	{
		var res : bool;
		
		if( theGame.tutorialPanelHidden )
		{
			//if( isNew )
			//	theHud.m_hud.ShowNewTutorialNew( false, true );
			//else
			//	theHud.m_hud.ShowNewTutorial( false );
			
			if( isNew )
				theGame.SetTutorialUseNew( true );
			else
				theGame.SetTutorialUseNew( false );			
			
			Log( " ========================= Quest Toggled Panel, theGame.tutorialPanelHidden == true, Showing Panel ====================" );
			theGame.TutorialPanelHidden( false );
			theHud.m_hud.KillTutorialTask();
			theHud.ShowTutorialPanel();
		}
		else
		{
			//if( isNew )
			//	theHud.m_hud.HideNewTutorial( true );
			//else
			//	theHud.m_hud.HideNewTutorial( false );

			if( isNew )
				theGame.SetTutorialUseNew( true );
			else
				theGame.SetTutorialUseNew( false );			
			Log( " ========================= Quest Toggled Panel, theGame.tutorialPanelHidden == false, Hiding Panel ====================" );			
			theGame.TutorialPanelHidden( true );
			theHud.HideTutorialPanel();
		}
	}
	
	timer function TutorialDisableActiveInteractions( timeDelta : float )
	{
		thePlayer.RemoveTimer( 'TutorialDisableActiveInteractions' );		
		theGame.EnableButtonInteractions( false );
		thePlayer.AddTimer( 'TutorialEnableActiveInteractions', 0.001f, false, false );
	}
	
	timer function TutorialEnableActiveInteractions( timeDelta : float )
	{
		thePlayer.RemoveTimer( 'TutorialEnableActiveInteractions' );		
		theGame.EnableButtonInteractions( true );
	}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	final function IsDodgeing() : bool
	{
		var cooldown, lastDodge  : EngineTime;
		var dodgeFlag : bool;
		dodgeFlag = isDodge;
		lastDodge = lastDodgeTime;
		cooldown = theGame.GetEngineTime();
		if(!dodgeFlag || cooldown > lastDodge + 1.5)
		{
			isDodge = false;
			return false;
		}
		else 
		{
			return true;
		}
	}
	function SetCombatBlockTriggerActive( val : bool, trigger : CBlockCombatArea )
	{
		combatBlockTriggerActive = val;
		blockCombatArea = trigger;
		
		if(val && trigger)
		{
			AddTimer('InsideBlockAreaCheck', 0.5, true);
		}
	}
	function GetCombatBlockTriggerActive( ) : bool
	{
		return combatBlockTriggerActive;
	}
	timer function combatBlocked( timeDelta : float )
	{
		if (  GetCurrentPlayerState() == PS_CombatSteel || GetCurrentPlayerState() == PS_CombatSilver )
		{
			ChangePlayerState( PS_Exploration );
			SetCombatHotKeysBlocked( false );
			SetCombatBlocked(false);
		}
	}
	
	timer function InsideBlockAreaCheck( timeDelta : float )
	{
		if(blockCombatArea)
		{
			if( !blockCombatArea.blockArea.TestPointOverlap( GetWorldPosition()) || !m_isCombatBlocked)
			{
				SetCombatBlockTriggerActive( false, NULL );
				SetCombatHotKeysBlocked( false );
				SetCombatBlocked(false);
				RemoveTimer('KeepBlockOnIfInsideArea');
				RemoveTimer('InsideBlockAreaCheck');
				RemoveTimer('combatBlocked');
			}
		}
		else
		{
			SetCombatBlockTriggerActive( false, NULL );
			SetCombatHotKeysBlocked( false );
			SetCombatBlocked(false);
			RemoveTimer('KeepBlockOnIfInsideArea');
			RemoveTimer('InsideBlockAreaCheck');
			RemoveTimer('combatBlocked');
		}
		
	}
	
	timer function KeepBlockOnIfInsideArea( timeDelta : float )
	{
		SetGuardBlock(false, true);
		if(  GetCurrentPlayerState() == PS_CombatSteel || GetCurrentPlayerState() == PS_CombatSilver )
		{
			if(blockCombatArea)
			{
				SetCombatBlockTriggerActive( true, blockCombatArea );
			}
			
			ChangePlayerState( PS_Exploration );
			SetCombatHotKeysBlocked( true );
			SetCombatBlocked(true);
			//Log( " 1============= Combat Block Active ============ " );
		}	
		//else
			//Log( " 0============= Combat Block Deactived ============ " );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MANAGING QUICK SLOT ITEMS
	
	function SavePlayerSlotItemsNames()
	{
		var itemSlots : array< SItemUniqueId >;
		var i, itemQty : int;
		var itemName : name;
		
		savedSlotItemsNames.Clear();
		savedSlotItemsQty.Clear();
		
		itemSlots = thePlayer.GetItemsInQuickSlots();
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			itemName = thePlayer.GetInventory().GetItemName( itemSlots[i] );
			itemQty = thePlayer.GetInventory().GetItemQuantity( itemSlots[i] );
			savedSlotItemsNames.PushBack( itemName );
			savedSlotItemsQty.PushBack( itemQty );
		}
	}
	
	function RestorePlayerSlotItemsNames( shouldEquipInQuickSlot : bool )
	{
		var itemId	: SItemUniqueId;
		var currItemQty : int;
		var itemQty : int;
		var size, i : int;
		var itemName : name;
		
		size = savedSlotItemsNames.Size();
		
		for( i=0; i<size; i+=1 )
		{
			itemName = savedSlotItemsNames[i];
			
			if( thePlayer.GetInventory().HasItem( itemName ) )
			{
				itemId = thePlayer.GetInventory().GetItemId( itemName );
				currItemQty = thePlayer.GetInventory().GetItemQuantity( itemId );
				
				if( currItemQty <= 0 )
				{
					currItemQty = savedSlotItemsQty[i];
				}
				if( shouldEquipInQuickSlot )
				{
					thePlayer.SetItemInQuickSlot( itemId, i );
				}
				else
				{
					thePlayer.GetInventory().RemoveItem( itemId, currItemQty );
					thePlayer.GetInventory().AddItem( itemName, currItemQty, false );
				}
			}
		}
		SelectNextSlotItem( true );
	}
	
	
	public function SetJournalEntryAsRead( groupIdx : int, itemIdx : int, isRead : bool )
	{
		m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ].m_isRead = isRead;
	}
	
	
	public function IncHUDTimer()
	{
		if ( thePlayer.hudFadeoutTimerBlocked )
		{
			hudFadeoutTimer = 0.0;
		}
		else
		{
			hudFadeoutTimer = hudFadeoutTimer + 0.2;
		}
	}
	
	public function ResetHUDTimer()
	{
		hudFadeoutTimer = 0;
	}
	
	public function setHUDTimerBlock( val : bool)
	{
		hudFadeoutTimerBlocked = val;
	}
	
	function setHudFadeoutTimerBlocked( val : bool )
	{
		hudFadeoutTimerBlocked = val;
	}
	
	
	public function HandleHUDTimer()
	{
		/*if ( ( ( thePlayer.GetCurrentPlayerState() != PS_Exploration ) && ( thePlayer.GetCurrentPlayerState() != PS_CombatSteel ) && ( thePlayer.GetCurrentPlayerState() != PS_CombatSilver ) ) || thePlayer.hudFadeoutTimerBlocked )
		{
			theHud.SetHudVisibility("false");
		} else
		if ( hudFadeoutTimer > 100)
		{
			theHud.SetHudVisibility("false");
		} else
		if ( hudFadeoutTimer <= 0 )
		{
			if ( thePlayer.GetCurrentPlayerState() != PS_Cutscene )	theHud.SetHudVisibility("true");
		}*/
	}
	
	// Called by quest manager
	event OnTrackedQuestChanged( questTag : name, mapPinTag : array< name > )
	{
		// set quest short todo
		theHud.m_hud.SetTestTrack( questTag );
	}
	
	event OnTrackedQuestMappinChanged( mapPinTag : array< name > )
	{
		var prevEntities : array< CEntity > = m_trackedQuestEntities;
		var mapPin : CMapPin;
		var trackedQuestNpc : CNewNPC;
		var i : int;
		var tmpEntity : CEntity;
		
		m_trackedQuestEntities.Clear();
		m_trackedQuestTags.Clear();
		
		for ( i = 0; i < mapPinTag.Size(); i += 1 )
		{
			m_trackedQuestTags.PushBack( mapPinTag[i] );
			
			tmpEntity = theGame.GetEntityByTag( mapPinTag[i] );
			if ( tmpEntity )
			{
				m_trackedQuestEntities.PushBack( tmpEntity );
			}
		}

		// Remove old pins
		for ( i = 0; i < prevEntities.Size(); i += 1 )
		{
			theHud.m_map.MapPinSet( prevEntities[i], NULL );
			
			trackedQuestNpc = (CNewNPC)prevEntities[i];
			// Restore NPC mappin
			if ( trackedQuestNpc )
			{
				trackedQuestNpc.m_isQuestTracked = false;
				trackedQuestNpc.InitMappin();
			}
		}

		// Add pin
		if ( mapPinTag.Size() > 0 )
		{
			for ( i = 0; i < m_trackedQuestEntities.Size(); i += 1 )
			{
				trackedQuestNpc = (CNewNPC)m_trackedQuestEntities[i];
				// Remove NPC mappin, as from now it has a quest mappin
				if ( trackedQuestNpc )
				{
					trackedQuestNpc.RemoveMappin();
					trackedQuestNpc.m_isQuestTracked = true;
				}
				else
				{
					// create static quest mappin for entities that are not NPCs
					mapPin = theHud.m_map.CreateMapPin( m_trackedQuestEntities[i], "Quest", MapPinType_Quest, MapPinDisplay_Both );
					theHud.m_map.MapPinSet( m_trackedQuestEntities[i], mapPin );
				}
			}
		}
	}
	
	public function ShouldBeTracked( npc : CNewNPC ) : bool
	{
		var i : int;
		for ( i = 0; i < m_trackedQuestTags.Size(); i += 1 )
		{
			if ( npc.HasTag( m_trackedQuestTags[i] ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function AddTrackedEntity( trackedEntity : CEntity )
	{
		if ( !m_trackedQuestEntities.Contains(trackedEntity) )
		{
			m_trackedQuestEntities.PushBack( trackedEntity );
		}
	}
	
	public function RemoveTrackedEntity( trackedEntity : CEntity )
	{
		if ( trackedEntity )
		{
			theHud.m_map.MapPinSet( trackedEntity, NULL );
			m_trackedQuestEntities.Remove( trackedEntity );
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetLastBook( book : SItemUniqueId)
	{
		lastBook = book;
	}
	function GetLastBook( ) : SItemUniqueId
	{
		return lastBook;
	}
	
	function SetLastBoard( ent : CQuestBoard)
	{
		lastboard = ent;
	}
	
	function GetLastBoard() : CQuestBoard
	{
		return lastboard;
	}
	
	function GetShopOwner(  ) : CActor
	{
		return shopowner;
	}
	
	function SetShopOwner( aktor : CActor )
	{
		shopowner = aktor;
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetStorageOwner( storage : W2PlayerStorage )
	{
		storageowner = storage;
	}
	
	function GetStorageOwner(  ) : W2PlayerStorage
	{
		return storageowner;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetLastBribe( amount : int )
	{
		lastBribe = amount;
	}
	
	function GetLastBribe( ) : int
	{
		return lastBribe;
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetCurrentAreaMapId( id : string, showAreaName : bool )
	{
		currentAreaMapId = id;
		currentAreaMapShowAreaName = showAreaName;
	}
	
	function GetCurrentAreaMapId() : string
	{
		return currentAreaMapId;
	}
	
	function GetCurrentAreaMapShowName() : bool
	{
		return currentAreaMapShowAreaName;
	}
	
	function SetCurrentMapId( id : int )
	{
		currentMapId = id;
	}
	
	function GetCurrentMapId() : int
	{
		return currentMapId;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	latent function StartAxiiMinigame() : bool
	{
		var minigame : CMinigame;
		var players  : array< CActor >;
		var playerWins : bool;
		
		minigame = (CMinigame) theGame.CreateEntity( axiiMinigame, GetWorldPosition() );
		if ( minigame )
		{
			players.PushBack( thePlayer );
			if ( ! minigame.StartGameWaitForResult( players, playerWins ) )
			{
				return true;
			}
		
			return playerWins;
		}
		else
		{
			return true;
		}
	}
	function GetAxiiTargetsNum() : int
	{
		return axiiNPCs.Size();
	}
	function GetFirstAxiiTarget() : CNewNPC
	{
		if(axiiNPCs.Size() > 0 && axiiNPCs[0])
		{
			return axiiNPCs[0];
		}
		else
		{
			return NULL;
		}
	}
	function RemoveAxiiTarget(npc : CNewNPC)
	{
		if(npc && axiiNPCs.Contains(npc))
			axiiNPCs.Remove(npc);
	}
	function AddAxiiTarget(npc : CNewNPC)
	{
		if(npc)
			axiiNPCs.PushBack(npc);
	}
	function GetIsCastingAxii() : bool
	{
		return isCastingAxii;
	}
	function SetIsCastingAxii(castingFlag : bool)
	{
		isCastingAxii = castingFlag;
	}
	function GetIsInAxiiLoop() : bool
	{
		return inAxiiLoop;
	}
	function SetAxiiLoop(loopFlag : bool)
	{
		inAxiiLoop = loopFlag;
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	function GetCurrentTakedownArea() : W2TakedownArea
	{
		return currentTakedownArea;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	private function GetEnemy() : CActor
	{
		var enemy : CActor;
		OnGetEnemy( enemy );
		return enemy;
	}
	
	event OnGetEnemy( out outEnemy : CActor );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	function SetDontRecalcStats( val : bool ) // umozliwia wylaczenie przeliczania statsow geralta w czasie - np. wylaczyc auto regen zywotnosci
	{
		dontRecalcStats = val;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	final function GetRawMoveSpeed() : float { return rawPlayerSpeed; }
	
	final function IsPlayerMoving() : bool { return rawPlayerSpeed > 0.0; }

	final function ResetMovment()
	{
		SetWalkMode( false );
		//ResetPlayerCamera();	
		OnResetMovement();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// MT: functions for radial blur
	
	timer function RadialBlurFade( timeDelta : float )
	{
		if( radialBlurValue >= 0 )
		{
			radialBlurValue -= 0.025;
			RadialBlurSetup( radialBlurTarget.GetWorldPosition(), radialBlurValue, radialBlurValue, radialBlurValue, radialBlurValue );
		}
		else
		{
			radialBlurValue = 0;
			RadialBlurDisable();
			RemoveTimer( 'RadialBlurFade' );
		}
	}
	
	private function activateRadialBlur( newRadialBlurTarget : CNode, radialBlurInitialValue : float )
	{
		radialBlurTarget = newRadialBlurTarget;
		radialBlurValue = radialBlurInitialValue;
		RadialBlurSetup( radialBlurTarget.GetWorldPosition(), radialBlurInitialValue, radialBlurInitialValue, radialBlurInitialValue, radialBlurInitialValue );
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////
	
	event OnResetMovement();
	
	function SetManualControl( movement : bool , camera : bool )
	{
		var behMovable 			: float;
		var currRotation 		: EulerAngles;
		
		if ( movement )
		{
			isMovable = true;
		}
		else 
		{
			isMovable = false;
		}
		
		if ( camera )
		{
			UnblockPlayerCameraRotation();
		}
		else
		{
			ResetPlayerCamera();
			BlockPlayerCameraRotation();
		}	
	}
	
	function IsManualControl() : bool
	{
		return OnIsManualControl();
	}
	
	event OnIsManualControl()
	{
		return false;
	}
	
	// Sets active Quen Sign instance
	function setActiveQuen( quen : CWitcherSignQuen )
	{
		activeQuenSign = quen;
		
		theHud.m_hud.UpdateBuffs();
	}
	function getActiveQuen() : CWitcherSignQuen
	{
		return activeQuenSign;
	}
	
	function SetSneakMode( flag : bool )
	{
		sneakMode = flag;
	}
	
	function SetIsInShadow( flag : bool )
	{
		if ( m_isInShadow != flag )
		{
			m_isInShadow = flag;
			
			if ( flag )
				theHud.m_fx.StealthAlphaStart();
			else
				theHud.m_fx.StealthAlphaStop();
		}
	}
	function GetIsInShadow() : bool
	{
		return m_isInShadow;
	}
	
	function IsInSneakMode() : bool
	{
		return sneakMode;
	}
	
	function IsEnteringObstacle() : bool
	{
		return enteringObstacle;
	}
	
	// on npc death
    event OnNPCDeath( deadNPC : CActor );
    
    // on npc death
    event OnNPCStunned( stunnedNPC : CActor );
	
	event OnActionStarted( actionType : EActorActionType )
	{
	}
	
	event OnActionEnded( actionType : EActorActionType, result : bool )
	{
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	function HostilesAround() : bool
	{
		var enemies : array< CActor >;
		var npc : CNewNPC;
		var i : int;
		var mac : CMovingAgentComponent = thePlayer.GetMovingAgentComponent();
		var npcPos : Vector;
		
		enemies = FindEnemiesInCombatArea();
		for( i=0; i<enemies.Size(); i+=1 )
		{
			npc = (CNewNPC)enemies[i];
			if( npc && npc.IsAlive() && npc.GetAttitude(this) == AIA_Hostile )
			{
				npcPos = npc.GetWorldPosition();
				if ( mac.CanGoStraightToDestination( npcPos ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	timer function TickCombatSlots( timeDelta : float )
	{
		combatSlots.Tick( timeDelta );
	}
	
	timer function UpdateFarSlots( timeDelta : float )
	{
		combatSlots.UpdateFarSlots();
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	
	function EnableMeditation( enabled : bool )
	{
		m_canMeditate = enabled;
	}
	
	function CanMeditate() : bool
	{
		var i, size : int;
		var actors : array<CActor>;
		var npc : CNewNPC;
		GetActorsInRange(actors, 30.0, '', thePlayer);
		size = actors.Size();
		
		for(i = 0; i < size; i += 1)
		{
			npc = (CNewNPC)actors[i];
			if(npc)
			{
				if(npc.GetAttitude(thePlayer) == AIA_Hostile)
				{
					if(npc.ZDifferenceTest(3.0, npc.GetWorldPosition(), thePlayer.GetWorldPosition()))
						return false;
				}
			}
		}
		
		//Log( "===================== Meditate : "+m_canMeditate +" combat : " +IsInCombat() +" hud : " +CanUseHud() );
		
		return m_canMeditate && ! IsInCombat() && CanUseHud();
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Player state management
	
	final function GetCurrentPlayerState() : EPlayerState
	{
		var stateName : name;
		stateName = GetCurrentStateName();
		return NameToState( stateName );
	}
	
	final function NameToState( stateName : name ) : EPlayerState
	{
		if( stateName == 'Exploration' )
		{
			return PS_Exploration;
		}
		else if( stateName == 'Scene' )
		{
			return PS_Scene;
		}
		else if( stateName == 'TraverseExploration' )
		{
			return PS_TraverseExploration;
		}
		else if( stateName == 'Meditation' )
		{
			return PS_Meditation;
		}
		else if( stateName == 'CombatFistfightDynamic' )
		{
			return PS_CombatFistfightDynamic;
		}
		else if( stateName == 'CombatFistfightStatic' )
		{
			return PS_CombatFistfightStatic;
		}
		else if( stateName == 'CombatSilver' )
		{
			return PS_CombatSilver;
		}
		else if( stateName == 'CombatSteel' )
		{
			return PS_CombatSteel;
		}
		else if( stateName == 'CombatTakedown' )
		{
			return PS_CombatTakedown;
		}
		else if ( stateName == 'Sneak' )
		{
			return PS_Sneak;
		}
		else if( stateName == 'Cutscene' || stateName == 'ZgnCS' )
		{
			return PS_Cutscene;
		}
		else if( stateName == 'MasterInteraction' )
		{
			return PS_PlayerCarry;
		}
		else if( stateName == 'PrepareForScene' )
		{
			return PS_PrepareForScene;
		}
		else if ( stateName == 'AimedThrow' )
		{
			return PS_AimedThrow;
		}
		else if ( stateName == 'Prisoner' )
		{
			return PS_Prisoner;
		}
		else if ( stateName =='PrisonerMovable' )
		{
			return PS_PrisonerMovable;
		}
		else if( stateName == 'Minigame' )
		{
			return PS_Minigame;
		}
		else if( stateName == 'UseDevice' )
		{
			return PS_UseDevice;
		}
		else if( stateName == 'ZgnSpitQTE' || stateName == 'SpitFinisherHit' || stateName == 'ZgnRodeoQTE' )
		{
			return PS_ZagnicaSpecial;
		}
		else if ( stateName == 'PlayerInvestigate' )
		{
			return PS_Investigate;
		}
		
		Log("GetCurrentPlayerState error, unsupported state: "+stateName);
		return PS_None;
	}
	
	final function IsPlayerStateBlocked( playerState : EPlayerState ) : bool
	{
		if( IsSceneRelatedState( playerState ) || playerState == PS_TraverseExploration )
		{
			return false;
		}
		
		if( blockedAllStates )
		{
			return true;
		}
	
		return blockedStates.Contains( playerState );
	}
	
	final function BlockPlayerState( playerState : EPlayerState )
	{
		if( !blockedStates.Contains( playerState ) )
		{
			blockedStates.PushBack( playerState );
		}
	}
	
	final function UnblockPlayerState( playerState : EPlayerState )
	{
		blockedStates.Remove( playerState );
	}
	
	final function UnblockAllPlayerStates()
	{
		blockedStates.Clear();
	}
	
	final function SetAllPlayerStatesBlocked( flag : bool )
	{
		blockedAllStates = flag;
		//Log("SetAllPlayerStatesBlocked "+flag);
		//Trace();
	}
	
	final function GetProperExplorationState() : EPlayerState
	{
		if( IsInSneakMode() )
		{
			return PS_Sneak;
		}
		else
		{
			return PS_Exploration;
		}
	}
	
	final function IsAnExplorationState( playerState : EPlayerState ) : bool
	{
		return ( playerState == PS_Exploration || playerState == PS_Sneak );
	}
	
	final function IsSceneRelatedState( playerState : EPlayerState ) : bool
	{
		return ( playerState == PS_Scene
				|| playerState == PS_Cutscene
				|| playerState == PS_PrepareForScene );
	}
		
	final function IsCombatState( playerState : EPlayerState ) : bool
	{
		return ( StrFindFirst(playerState, "Combat") >= 0 );
	}
	
	final function SetFistFightCooldown()
	{
		this.m_fistFightCooldown = 3.0;
	}
	final function GetLastCombatStyle() : EPlayerState
	{
		if(lastCombatStyle == PCS_Silver && HasSilverSword())
		{
			return PS_CombatSilver;
		}
		else if(lastCombatStyle == PCS_Steel && HasSteelSword() )
		{
			return PS_CombatSteel;
		}
		else 
		{
			if( HasSteelSword() )
			{
				return PS_CombatSteel;
			}
			else if(HasSilverSword())
			{
				return PS_CombatSilver;
			}
			else
			{
				return PS_CombatFistfightDynamic;
			}
		}		
	}
	final function SetLastCombatStyle(combatStyle : EPlayerCombatStyle)
	{
		lastCombatStyle = combatStyle;
	}
	final function SetCombatStyleFromWeaponState(weaponState : EPlayerState)
	{
		if(weaponState == PS_CombatSilver)
		{
			lastCombatStyle = PCS_Silver;
		}
		else
		{
			lastCombatStyle = PCS_Steel;
		}
	}

	final function ChangePlayerState( newState : EPlayerState ) : bool
	{
		var currentState 				: EPlayerState;
		var canDefferSwitch				: bool;
		currentState = GetCurrentPlayerState();
		canDefferSwitch = false;
		
		// If dead state change not allowed
		if( !IsAlive() )
		{
			return false;
		}
		
		// If going to exploration get proper exploration state
		if( newState == PS_Exploration )
		{
			newState = GetProperExplorationState();
			canDefferSwitch = true;
		}
		if(newState == PS_CombatSilver)
		{
			SetLastCombatStyle(PCS_Silver);
			canDefferSwitch = true;
		}
		if(newState == PS_CombatSteel)
		{
			SetLastCombatStyle(PCS_Steel);
			canDefferSwitch = true;
		}
		if ( newState == PS_TraverseExploration || newState == PS_Investigate || newState == PS_Meditation )
		{
			canDefferSwitch = true;
		}

		// If no sword use combat fist
		if( newState == PS_CombatSteel && !HasSteelSword() )
		{
			if(HasSilverSword())
			{
				newState = PS_CombatSilver;
				SetLastCombatStyle(PCS_Silver);
			}
			else
			{
				newState = PS_CombatFistfightDynamic;
				SetLastCombatStyle(PCS_Fist);
			}
		}
		else if( newState == PS_CombatSilver && !HasSilverSword() )
		{
			if(HasSteelSword())
			{
				newState = PS_CombatSteel;
				SetLastCombatStyle(PCS_Steel);
			}
			else
			{
				newState = PS_CombatFistfightDynamic;
				SetLastCombatStyle(PCS_Fist);
			}
		}
		
		// Already in state
		if( currentState == newState )
		{
			return true;
		}
		
		// If fistfight request in progress, must not leave static fistfight state
		if( currentState == PS_CombatFistfightStatic && theGame.GetFistfightManager().OnIsRequestInProgress() )
		{
			if( !IsSceneRelatedState( newState ) )
			{
				return false;
			}
		}
		
		if( currentState == PS_None || IsPlayerStateBlocked( newState ) )
		{
			return false;
		}
		
		// there are states that need to be switched to right away, and
		// there are those that can wait...
		if ( canDefferSwitch )
		{
			OnChangePlayerState( newState );
		}
		else
		{
			ExecutePlayerStateChange( newState );
		}
		return true;
	}
	
	
	event OnChangePlayerState( newState : EPlayerState )
	{
		OnExitPlayerState( newState );
	}
	
	final function ExecutePlayerStateChange( newState : EPlayerState )
	{
		OnExitPlayerState( newState );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		PlayerStateCallEntryFunction( newState, "" );
	}
	
	// Shoud not be called directly (use in OnExitPlayerState handlers)
	private final function PlayerStateCallEntryFunction( newState : EPlayerState, behStateName : string )
	{
		var oldState : EPlayerState;
		oldState = GetCurrentPlayerState();
		
		if( oldState == newState )
		{
			Logf( "ERROR: PlayerStateCallEntryFunction oldState == newState (%1)", GetCurrentStateName() );
			oldState = GetProperExplorationState();
		}
		
		if ( newState == PS_PrepareForScene )
		{
			newState = PS_Exploration;
		}
	
		if ( newState == PS_Exploration )
		{
			SetLastLockedTarget(NULL);
			EntryExploration( oldState, behStateName );		
		}
		else if( newState == PS_Sneak )
		{
			SetLastLockedTarget(NULL);
			EntrySneak( oldState, behStateName );
		}
		else if( newState == PS_Scene )
		{
			SetLastLockedTarget(NULL);
			StartScene( oldState, behStateName );
		}
		else if( newState == PS_Cutscene )
		{
			SetLastLockedTarget(NULL);
			EnterCutsceneState( oldState, behStateName );
		}
		else if ( newState == PS_CombatFistfightDynamic )
		{
			EntryCombatFistfight( oldState, behStateName );
		}
		else if ( newState == PS_CombatFistfightStatic )
		{
			SetLastLockedTarget(NULL);
			EntryCombatFistfightStatic( oldState, behStateName );
		}
		else if ( newState == PS_CombatSteel )
		{
			EntryCombatSteel( oldState, behStateName );
		}
		else if( newState == PS_CombatSilver )
		{
			EntryCombatSilver( oldState, behStateName );
		}
		else if( newState == PS_Prisoner )
		{ 
			SetLastLockedTarget(NULL);
			Q002_prisoner( oldState );
		}
		else if ( newState == PS_Meditation )
		{
			SetLastLockedTarget(NULL);
			StateMeditation( oldState );
		}
		else if( newState == PS_PrisonerMovable )
		{ 
			SetLastLockedTarget(NULL);
			Q302_prisoner( oldState );
		}
		else if( newState == PS_AimedThrow )
		{ 
			EntryAimedThrow( oldState, behStateName );
		}
		else if( newState == PS_PlayerCarry )
		{
			if( interactionData )
			{
				SetLastLockedTarget(NULL);
				StateInteractionMasterInternal();				
			}
		}
		else if ( newState == PS_TraverseExploration )
		{
			SetLastLockedTarget(NULL);
			EntryTraverseExploration( oldState, "", m_explorationAreaToTraverse );	
		}
		else if ( newState == PS_Investigate )
		{
			SetLastLockedTarget(NULL);
			EntryInvestigation( oldState, behStateName, m_itemToInvestigate );
		}
		else if( newState == PS_ZagnicaSpecial )
		{
			Log( "ERROR: Can not enter PS_ZagnicaSpecial directly!" );
		}
		else
		{
			Log( "ERROR: PlayerStateCallEntryFunction unknown new state" );		
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	
	function ToggleCarry( npcToCarry : CNewNPC )
	{
		var slaves : array<CActor>;
		
		if( GetCurrentPlayerState() == PS_PlayerCarry )
		{
			OnManualCarryStopRequest();
		}
		else if( npcToCarry.OnManualCarry() && !HostilesAround() )
		{
			if( IsAnExplorationState( GetCurrentPlayerState() ) == false )
			{	
				ChangePlayerState( GetProperExplorationState() );
			}
			else
			{
				slaves.PushBack( npcToCarry );
				StateInteractionMasterAnimated( slaves, CTM_Sit );
			}
		}
		else
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("ActionBlockedHere") );
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	private var m_explorationAreaToTraverse		: CActionAreaComponent;
	event OnUseExploration( explorationArea : CActionAreaComponent )
	{
		m_explorationAreaToTraverse = explorationArea;
		ChangePlayerState( PS_TraverseExploration );
		return true;
	}
	
	event OnStartTraversingExploration() { return false; }
	event OnFinishTraversingExploration();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnRiposteAllowedStart( attacker : CActor );
	event OnRiposteAllowedEnd( attacker : CActor );
	
	event OnCameraComboAttack();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Interactions

	function EnterSlaveState( master : CActor, slaveBehaviorName : name, instantStart : bool, initialSpeed : float )
	{
		StateInteractionSlave( master, slaveBehaviorName );
	}
	
	function EnterMinigameState( wp : CNode, behavior : name )
	{
		StateMinigame( wp, behavior );
	}
	function ExitMinigameState()
	{
		if ( GetCurrentStateName() == 'Minigame' ) ChangePlayerState( PS_Exploration );
			//LoopExploration();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Scenes
	
	function GoToScenePosition( desiredPlacement : Matrix, distance : float, priority : int, run : bool )
	{
		var moveType : EMoveType;
		var desiredPosition : Vector;
		var desiredRotation : EulerAngles;
		
		LockEntryFunction( false );
		
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
		
		StatePrepareForScene( desiredPosition, desiredRotation.Yaw, distance, moveType );
	}
	function GetCanExitMeditation() : bool
	{
		if(theGame.GetEngineTime() >  meditationExitTime + meditationExitCooldown)
		{
			return true;
		}
	}
	function SetExitMeditationCooldown()
	{
		meditationExitTime = theGame.GetEngineTime();
	}
	event OnInteractionTalkTest()
	{
		return false;
	}
	
	// Actor will take part in blocking scene - this event happens when fade out is beginning
	event OnBlockingScenePrepare()
	{	
		var quenSign : CWitcherSignQuen;
		var catEffectTime : float;
		var i : int;
	
		LockEntryFunction( false );
		
		// Stop movement
		SetManualControl( false, false );
		
		// Disable quen effect
		quenSign = getActiveQuen();
		if ( quenSign )
		{
			quenSign.OnBlockingSceneStarted();
		}
		
		// Disable cat effect
		// A bit hacky way to pause cat effect for dialogs - it should be in state scene, but can not because scene embedded minigames can end state scene to early
		if ( IsCatEffectEnabled() == true )
		{
			catEffectTime = GetCatEffectTime();
			
			// NOTE: This resets pausedCatEffectTime
			EnableCatEffect( false );
			
			pausedCatEffectTime = catEffectTime;
		}
		
		HideLootWindow( true );
		
		theHud.ReleaseWaitingForKeyPressed();
		
		for( i=criticalEffects.Size()-1; i>=0; i-=1 )
		{
			criticalEffects[i].EndEffect();
		}

		// Begin changing state
		ChangePlayerState( PS_Scene );
	}
	
	event OnBlockingSceneEnded()
	{				
		var quenSign : CWitcherSignQuen;
		
		// Reapply quen effect
		quenSign = getActiveQuen();
		if ( quenSign )
		{
			quenSign.OnBlockingSceneEnded();
		}
		
		// Reapply cat effect
		if ( pausedCatEffectTime > 0.0f )
		{
			EnableCatEffect( true, pausedCatEffectTime );
			pausedCatEffectTime = pausedCatEffectTime - 2.0f;
		}
		else
		{
			thePlayer.RemoveElixirByName('Cat');
		}
		
		// Restore movement
		SetManualControl( true, true );
		
		// Restore previous state
		ExitScene( sceneExitState );
	}

	event OnSceneStarted( activeIdleFlag : bool, invulnerable : bool )
	{		
		HideHud();
		
		if( invulnerable )
		{
			immortalityModeScene = AIM_Invulnerable;
		}
		else
		{
			immortalityModeScene = AIM_None;
		}
	}

	event OnSceneEnded()
	{
		this.DisableLookAt();
		this.SetBehaviorVariable( "dialog", 0.0f );		
		immortalityModeScene = AIM_None;
		
		ShowHud();
	}
	
	event OnCutsceneStarted()
	{
		HideHud();
		LockEntryFunction( false );
		ChangePlayerState( PS_Cutscene );		
	}
	
	event OnCutsceneEnded()
	{
		ShowHud();
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////

	function ShowGui()
	{
		theHud.ShowGui();
	}
	
	function HideGui()
	{
		theHud.HideGui();
	}
	
	function ShowHud()
	{
		m_hideHudCount -= 1;
		AddTimer( 'RestoreHudVisibilityTimer', 1, false );
	}
	
	function HideHud()
	{
		m_hideHudCount += 1;
		theHud.HideHud();
	}
	
	timer function RestoreHudVisibilityTimer( timeDelta : float )
	{
		if ( m_hideHudCount <= 0 )
		{
			m_hideHudCount = 0;
			theHud.ShowHud();
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	// Sets scene exit state
	event OnSetSceneExitState( exitState : EPlayerState )
	{
		sceneExitState = exitState;
	}
	
	function TurnOffCombatCamera( turnedOff : bool )
	{
		//turnOffCombatCamera = turnedOff;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function AreHotKeysBlocked() : bool
	{
		if(theGame.GetIsPlayerOnArena())
		{
			return m_areHotKeysBlocked;
		}
		else
		{
			return m_areHotKeysBlocked || theGame.IsActiveCameraBlending() || theGame.IsAnyStaticCameraActive();
		}
	}
	
	public function SetHotKeysBlocked( isLockEnabled : bool )
	{
		m_areHotKeysBlocked = isLockEnabled;
	}
	
	public function AreCombatHotKeysBlocked() : bool
	{
		return m_areCombatHotKeysBlocked;
	}
	public function IsCombatBlocked() : bool
	{
		return m_isCombatBlocked;
	}
	
	public function SetCombatHotKeysBlocked( isLockEnabled : bool )
	{
		m_areCombatHotKeysBlocked = isLockEnabled;
	}	
	public function SetCombatBlocked( isLockEnabled : bool )
	{
		m_isCombatBlocked = isLockEnabled;
		m_areCombatHotKeysBlocked = isLockEnabled;
	}	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// returns the maximum load (max weight that player can carry)
	import function GetMaxWeight() : float;
	
	// returns the current player load (the sum of all carried items weights)
	import function GetCurrentWeight() : float;
	
	public function SetOverweightTestRequired(required : bool)
	{
		isOverweightTestRequired = required;
	}
	
	public function IsOverweightInMovement() : bool
	{
		//if(theGame.GetEngineTime() > lastOverweightCheck + EngineTimeFromFloat(5.0))
		if(isOverweightTestRequired)
		{
			SetOverweightTestRequired(false);
			lastOverweightResult = IsOverweight();
		}
		return lastOverweightResult;
	}
	
	public function IsOverweight() : bool
	{
		var playerState : EPlayerState;
		if(IsNotGeralt())
		{
			return false;
		}
		if(GetCurrentWeight() > GetMaxWeight() )
		{
			if(lastEncumberedMsg + 5.0 < theGame.GetEngineTime())
			{ 
				playerState = thePlayer.GetCurrentPlayerState();
				if(playerState == PS_Exploration || playerState == PS_CombatSteel || playerState == PS_CombatSilver || playerState == PS_CombatFistfightDynamic || playerState == PS_Sneak)
					theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "Encumbered" ));
				lastEncumberedMsg = theGame.GetEngineTime();
			}
			
			return true;
		}
		return false;
	}
	
	public function AddOrens( orensCount : int )
	{
		GetInventory().AddItem( 'Orens', orensCount );
		if(theGame.GetIsPlayerOnArena())
		{
			theGame.GetArenaManager().UpdateArenaHUD(false);
		}
	}
	
	public function RemoveOrens( orensCount : int )
	{
		var currentOrensCount : int = GetOrensCount();
		var toRemoveOrensCount : int;
		var orensId : SItemUniqueId = GetInventory().GetItemId('Orens');
		if ( currentOrensCount < orensCount )
		{
			toRemoveOrensCount = currentOrensCount;
		}
		else
		{
			toRemoveOrensCount = orensCount;
		}
		GetInventory().RemoveItem( orensId, toRemoveOrensCount );
		if(theGame.GetIsPlayerOnArena())
		{
			theGame.GetArenaManager().UpdateArenaHUD(false);
		}
	}
	
	public function GetOrensCount() : int
	{
		return GetInventory().GetItemQuantityByName( 'Orens' );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnItemAdded( itemId : SItemUniqueId, informGui : bool )
	{
		var inv		  : CInventoryComponent = GetInventory();

		Log("Journal " + NameToString( inv.GetItemName( itemId ) ));
		
		// DM: HACK: FALLBACK: Autoequip items till new Inventory is available
		//if ( inv.ItemHasTag( itemId, 'QuickSlot' ) ) 
		//{
			// equip item to quickslot
//			AddItemToQuickSlots( itemId );
		//}
		if ( inv.ItemHasTag( itemId, 'Recipe' ) && ( inv.GetCraftedItemName( itemId ) != 'None' ) && ( inv.GetItemName( itemId ) != 'None' ) && ( inv.GetItemName( itemId ) != 'Recipe Healing Concoction' ) )
		{
			AddJournalEntry(JournalGroup_Alchemy, "Journal " + NameToString( inv.GetCraftedItemName( itemId ) ), "Journal " + NameToString(inv.GetCraftedItemName( itemId ) ) + " 0", "JournalTypeRecipe" );
			Log("Journal " + NameToString( inv.GetCraftedItemName( itemId ) ));
		}
		//if ( inv.ItemHasTag( itemId, 'Elixir' ) ) 
		//{
		//	AddJournalEntry(JournalGroup_Alchemy, "Journal " + NameToString( thePlayer.GetInventory().GetItemName( itemId ) ), "Journal " + NameToString( thePlayer.GetInventory().GetItemName( itemId ) ) + " 0" , GetLocStringByKeyExt("JournalTypeElixir") );
		//}
		if ( inv.ItemHasTag( itemId, 'Schematic' ) && ( inv.GetItemName( itemId ) != 'None' ) ) 
		{
			AddJournalEntry(JournalGroup_Crafting, NameToString( inv.GetCraftedItemName( itemId ) ), "[[" + NameToString( inv.GetCraftedItemName( itemId ) ) + "]]", "JournalTypeSchematic" );
		}
		
		// Show in hud that item was added
		if ( informGui )
		{
			InformGuiAboutAddedItem( itemId, inv.GetItemQuantity( itemId ) );
		}
		
		if ( itemId == GetThrownItem() )
		{
			UpdateThrownItemGui();
		}
	}
	
	// called when item is added but in inventory there is already that item, so only quantity has changed
	event OnItemQuantityChanged( itemId : SItemUniqueId, addedItemQuantity : int, informGui : bool )
	{
		if ( informGui )
		{
			InformGuiAboutAddedItem( itemId, addedItemQuantity );
		}
		
		if ( itemId == GetThrownItem() )
		{
			UpdateThrownItemGui();
		}
	}
	
	// Not used any more.
	//event OnItemTooHeavy( itemName : name )
	//{
		//theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "This item is to heavy" ));
	//}
	
	private function InformGuiAboutAddedItem( itemId : SItemUniqueId, addedItemQuantity : int )
	{
		var inv 		: CInventoryComponent = GetInventory();
		var itemTags	: array< name >;
		var itemName  	: name = inv.GetItemName( itemId );
		var arrayData 	: array < CFlashValueScript >;
		
		if ( !theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			inv.GetItemTags( itemId, itemTags );
			if ( ( inv.GetItemName(itemId) == 'Orens' ) || ( ! itemTags.Contains( 'NoShow' ) && ! itemTags.Contains( 'NoDrop' ) ) )
			{
				arrayData.PushBack( FlashValueFromString( "<span class='orange'>" + StrUpperUTF( GetLocStringByKeyExt( "ItemLooted" ) ) + ": " + GetLocStringByKeyExt( itemName ) + " x" + addedItemQuantity ) );
				arrayData.PushBack( FlashValueFromBoolean( true ) );	
				theHud.InvokeManyArgs("pHUD.addRecievedList", arrayData );
				if ( m_isSpawned )
				{
					AddTimer( 'GuiClearReceivedList', 3, false );
				}
			}
		}
	}

	final function SetAutoMountWithBlackScreen( enable : bool )
	{
		m_autoMountWithBlackScreen = enable;
	}
	
	timer function GuiClearReceivedList( timeDelta : float )
	{
		theHud.Invoke("pHUD.clearRecievedList");
	}
	
	timer function AutoMount( timeDelta : float )
	{
		var i		: int;
		var size	: int					= m_itemsToAutoMount.Size();
		var inv		: CInventoryComponent	= GetInventory();
		
		for ( i = 0; i < size; i += 1 )
		{
			inv.MountItem( m_itemsToAutoMount[ i ], false );
		}
		m_itemsToAutoMount.Clear();
		AddTimer( 'AutoMountDone', 1.f, false );
	}
	
	timer function AutoMountDone( timeDelta : float )
	{
		theGame.FadeInAsync( 0.5f );
	}
	
	timer function ElixirTutorial( timeDelta : float )
	{
		if( thePlayer.IsOutsideElixirMenu() )
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut79", "", true);
			//theHud.ShowTutorialPanelOld( "tut79", "" );
		}
	}
	
	function IsOutsideElixirMenu() : bool
	{
		return true;
	}
	
	event OnItemRemoved( itemId : SItemUniqueId )
	{
		var inv			 : CInventoryComponent	= GetInventory();
		var items		 : array< SItemUniqueId >;
		var i			 : int;
		var itemQuantity : int;
		
		itemQuantity = inv.GetItemQuantity( itemId );
		
		if ( itemQuantity == 0 )
		{
			if ( thrownItemId == itemId )
			{
				ClearThrownItem();
			}
		}
		
		// DM: HACK: FALLBACK: Autoequip items to quick slots till new Inventory is available
		if ( inv.ItemHasTag( itemId, 'QuickSlot' ) ) 
		{
			// try to unequip item from quickslot
			if ( RemoveItemFromQuickSlots( itemId ) )
			{
				// try to equip other item to this quick slot
				/*
				items = inv.GetItemsByTag( 'QuickSlot' );
				for ( i = items.Size()-1; i >= 0; i -= 1 )
				{
					if ( items[ i ] != itemId && AddItemToQuickSlots( items[ i ] ) )
					{
						break;
					}
				}
				*/
			}
		}
		
		if ( itemId == GetThrownItem() )
		{
			UpdateThrownItemGui();
		}
	}
	timer function ShowTutorialPackage( timeDelta : float )
	{
		//Log("----> TICK1");
		if ( thePlayer.GetMovingAgentComponent().GetSpeed() > 0 )
		//if ( thePlayer.GetCurrentPlayerState() == PS_Exploration ) 
		{
			if( !theGame.tutorialenabled )
			{
				AddTimer( 'ShowWelcomeTutorials', 1.5f, true );
			}	
		}
	}
	
	timer function CheckTutorial( timeDelta : float )
	{
	
	}
		
	timer function ShowRefillTutorial( timeDelta : float )
	{
		theHud.m_hud.ShowTutorial("tut71", "", false);
		//theHud.ShowTutorialPanelOld( "tut71", "" );
	}
	
	timer function ShowWelcomeTutorials( timeDelta : float )
	{
		//Log("----> TICK1");
		if ( thePlayer.GetMovingAgentComponent().GetSpeed() > 0 )
		{
			//if(thePlayer.GetCurrentPlayerState() == PS_Exploration )
		if (!IsInCombat())
		{
			if( IsAlive() )
			{
				if(thePlayer.GetCurrentPlayerState() == PS_Exploration && thePlayer.GetMovingAgentComponent().GetSpeed() > 0 )
				{
					if ( !theHud.m_hud.ShowTutorial("tut00", "tut00_333x166", false) )
					//if ( !theHud.ShowTutorialPanelOld( "tut00", "tut00_333x166" ) )
					{
					}

				}
				if ( theGame.IsUsingPad() )
				{ 
					//if ( !theHud.m_hud.ShowTutorial("tut163", "", false) ) // <-- tutorial content is present in external tutorial - disabled
					//if ( !theHud.ShowTutorialPanelOld( "tut163", "" ) )
					if ( !theHud.m_hud.ShowTutorial("tut164", "", false) )
					//if ( !theHud.ShowTutorialPanelOld( "tut164", "" ) )
					//if ( !theHud.m_hud.ShowTutorial("tut10", "tut10_333x166", false) ) // <-- tutorial content is present in external tutorial - disabled
					//if ( !theHud.ShowTutorialPanelOld( "tut10", "tut10_333x166" ) )
					{
					}
				}
				else
				{
					//if ( !theHud.m_hud.ShowTutorial("tut63", "", false, 5) ) // <-- tutorial content is present in external tutorial - disabled
					//if ( !theHud.ShowTutorialPanelOld( "tut63", "" ) )
					if ( !theHud.m_hud.ShowTutorial("tut64", "", false) )
					//if ( !theHud.ShowTutorialPanelOld( "tut64", "" ) )
					//if ( !theHud.m_hud.ShowTutorial("tut10", "tut10_333x166", false) ) // <-- tutorial content is present in external tutorial - disabled
					//if ( !theHud.ShowTutorialPanelOld( "tut10", "tut10_333x166" ) )
					{
					}
				}
			}
		}
		}
		else
		{
		}
	}	
/*	timer function ShowTutorialExplanation( timeDelta : float )
	{
		Log("----> TICK2");
		if ( thePlayer.GetCurrentPlayerState() == PS_Exploration && theHud.m_hud.ShowTutorial("tut63", "", false) ) 
		//if ( thePlayer.GetCurrentPlayerState() == PS_Exploration && theHud.ShowTutorialPanelOld( "tut63", "" ) ) 
		{
			RemoveTimer( 'ShowTutorialExplanation' );
			Log("----> REMOVEEEEEEEEEEEED2");
		}
	}*/
	
	timer function ShowMovementTutorial( timeDelta : float )
	{	
		/*
		if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
		{
			if ( !FactsDoesExist("movement_tutorial") ) theHud.m_hud.ShowTutorial("tut103", "", false);
			//if ( !FactsDoesExist("movement_tutorial") ) theHud.ShowTutorialPanelOld( "tut103", "" );
		}
		else
		{
			if ( !FactsDoesExist("movement_tutorial") )theHud.m_hud.ShowTutorial("tut03", "", false);
			//if ( !FactsDoesExist("movement_tutorial") )theHud.ShowTutorialPanelOld( "tut03", "" );
		}
		*/
	}
	
	timer function PCheckAchievements( timeDelta : float)
	{
		CheckAchievements();
	}
	
	timer function CheckforTutorials( timeDelta : float)
	{
				
		//if ( !theHud.m_hud.ShowTutorial("tut43", "", false) ) // <-- tutorial content is present in external tutorial - disabled
		//if ( !theHud.ShowTutorialPanelOld("tut43", "" ) )
		//{
		//	theHud.m_hud.ShowTutorial("tut43", "", false);
			//theHud.ShowTutorialPanelOld("tut43", "" );
		//}
		//else
		//{
		//	thePlayer.RemoveTimer( 'CheckforTutorials' );
		//}
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Game started
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var args, arguments : array< CFlashValueScript >;
		var intSignsSize : int;
		var lastSign : ESignTypes;
		
		combatModeSaveLock	= -1;
		lastSign = ST_LastSign;
		soundMaterials = LoadCSV("globals/sound_materials.csv");
		
		SetEnemySelectionWeights(75.0, 20.0, 1.0, 1.25, 0.2, 0.75, 0.2, 0.6, 1.0, -1.0, 160, 0.1);
		SetCombatV2(true);
		AllowCombatRotation(true);
		super.OnSpawned( spawnData );		
		
		m_isSpawned = true;
		
	/*thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut200_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut200_text")), "PODSTAWY", "");
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut201_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut201_text")), "PODSTAWY", "");		
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut202_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut202_text")), "PODSTAWY", "");	
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut203_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut203_text")), "PODSTAWY", "");	
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut204_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut204_text")), "PODSTAWY", "");	
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut205_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut205_text")), "PODSTAWY", "");	
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut206_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut206_text")), "PODSTAWY", "");		
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut207_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut207_text")), "PODSTAWY", "");
	thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut208_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut208_text")), "PODSTAWY", "");*/
	
		AddTimer( 'StatsTimer', 1.0f, true );
		AddTimer( 'TimerBuffs', 1.0f, true );
		AddTimer( 'CombatModeTimer', 1.0f, true );
		AddTimer( 'TicketPoolTimer', 1.0f, true );

		if( !theGame.tutorialenabled )
		{
			AddTimer( 'ShowMovementTutorial', 30.0f, false );
			AddTimer( 'ShowTutorialPackage', 2.0f, true );
		}	
		AddTimer( 'PCheckAchievements', 10.0f, true );
		
		// Drey: Caused level reset everytime, looks like unnecessary
		//level = 0;
		SetCombatHitEnums();
		
		FillDefaultKnowledge();
		FillDefaultQuestTrack();
		//AddStoryAbility("story_s1", 1);
		//AddStoryAbility("story_s2", 1);
		//AddStoryAbility("story_s3", 1);
		
		FullscreenBlurSetup(0.0);
		
		// initialize the signs behavior events names
		intSignsSize = (int)lastSign;
		signBehaviorEvents.Resize(intSignsSize);
		signBehaviorEvents[ST_Aard] = PCA_SignAard;
		signBehaviorEvents[ST_Yrden] = PCA_SignYrden;
		signBehaviorEvents[ST_Igni] = PCA_SignIgni;
		signBehaviorEvents[ST_Quen] = PCA_SignQuen;
		signBehaviorEvents[ST_Axii] = PCA_SignAxii;
		signBehaviorEvents[ST_Heliotrop] = PCA_SignHeliotrop;

		SendStatsToGui();
		
		theGame.SetTimeScale( 1.0 );
		
		cameraFurther = 0.0;
		
		arguments.PushBack( FlashValueFromString("ui_panelbg.swf") );
		theHud.InvokeManyArgs( "vCustomPanel.loadMovie", arguments );		
		
		// FakeBuildSNoLevel(18);
		// Signs1();
		
		// set the initial state
		if( spawnData.restored )
		{			
			ReapplyElixirs();
			PlayerStateCallEntryFunction( savedState, '' );
		}
		else
		{
			PlayerStateCallEntryFunction( PS_Exploration, '' );
			theGame.ApplyImportedOldSave();
		}
			
		//args.Clear();
		//args.PushBack(FlashValueFromString( 	"img://globals/gui/icons/signs/aard_64x64.dds" ));
		//args.PushBack(FlashValueFromString( GetLocStringByKeyExt( "Aard" ) ) ) ;
		//theHud.InvokeManyArgs("vHUD.setItemSign", args );
		SelectSign( selectedSign, false );
		
		clearHudTextField();
		
		SelectThrownItem( thrownItemId );
		
		// There is no need to save 'm_areHotKeysBlocked'
		m_areHotKeysBlocked = false;

		if ( currentHairstyle == 'default_geralt_hair' )
		{
			FactsAdd("Witcher_Default_Hair", 0 );
		}

		if( theGame.tutorialenabled )
		{
			enableTutorialButton = true;
			theGame.TutorialPanelHidden( true );
			theHud.Invoke("pHUD.clearRecievedList");
		}
	
		if ( theGame.GetIsPlayerOnArena() ) 
		{
			if( !theGame.tutorialenabled )
			{
				theGame.GetArenaManager().UpdateArenaHUD(false);
			}
		}
	}
	
	event OnScriptReloading()
	{
		Log("CPlayer::OnScriptReloading");
		reloadingScriptsState = GetCurrentPlayerState();
	}
	
	event OnScriptReloaded()
	{
		PlayerStateCallEntryFunction( reloadingScriptsState, '' );
	}
	
	event OnSaveGameplayState()
	{
		savedState = GetCurrentPlayerState();
	}
	
	event OnLoadGameplayState()
	{
		var inventory : CInventoryComponent;
		
		inventory = GetInventory();

		// restore thrown item
		thrownItemId = inventory.GetItemId( thrownItemName );
		
		if ( inventory.GetItemByCategory( 'armor', true, false ) == GetInvalidUniqueId() )
		{
			inventory.MountItem( inventory.GetDefaultItemForCategory( 'armor' ), false );
			inventory.MountItem ( inventory.GetItemByCategory( 'hair', false ), false );
		}
		if ( inventory.GetItemByCategory( 'gloves', true, false ) == GetInvalidUniqueId() )
		{
			inventory.MountItem( inventory.GetDefaultItemForCategory( 'gloves' ), false );
		}
		if ( inventory.GetItemByCategory( 'pants', true, false ) == GetInvalidUniqueId() )
		{
			inventory.MountItem( inventory.GetDefaultItemForCategory( 'pants' ), false );
		}
		if ( inventory.GetItemByCategory( 'boots', true, false ) == GetInvalidUniqueId() )
		{
			inventory.MountItem( inventory.GetDefaultItemForCategory( 'boots' ), false );
		}
		
	}
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	// Combat mode
	
	function SetCombatHitEnums()
	{
		hitEnums_t2.Clear();
		hitEnums_t3.Clear();
		hitEnums_t2.PushBack(PCH_Hit_2a);
		hitEnums_t2.PushBack(PCH_Hit_2b);

		hitEnums_t2.PushBack(PCH_Hit_3a);
		hitEnums_t2.PushBack(PCH_Hit_3b);
	}

	var wasInCombatMode : bool;
	
	timer function CombatModeTimer( timeDelta : float )
	{
		
		this.DecreaseCombatMode();
		
		if (IsInCombat())
		{
			//if ( !theHud.m_hud.ShowTutorial( "tut01", "tut01_333x166", true ) ) // <-- tutorial content is present in external tutorial - disabled
			//if ( !theHud.ShowTutorialPanelOld( "tut01", "tut01_333x166" ) ) 
			//if ( !theHud.m_hud.ShowTutorial( "tut07", "", true ) ) // <-- tutorial content is present in external tutorial - disabled
			//if ( !theHud.ShowTutorialPanelOld( "tut07", "" ) ) 
			//if ( !theHud.m_hud.ShowTutorial("tut05", "tut05_333x166", false) ) // <-- tutorial content is present in external tutorial - disabled
			//if ( !theHud.ShowTutorialPanelOld("tut05", "tut05_333x166" ) )
			if ( thePlayer.GetEnemy() && thePlayer.GetEnemy().IsMonster() ) theHud.m_hud.ShowTutorial( "tut19", "", true );
			//if ( thePlayer.GetEnemy() && thePlayer.GetEnemy().IsMonster() ) theHud.ShowTutorialPanelOld( "tut19", "" );
			
			if ( !wasInCombatMode )
			{
				this.ShowCombatMode();
			}
		}
		else
		{
			if ( wasInCombatMode )
			{
				//theHud.m_hud.HideTutorial();
				//theHud.m_hud.UnlockTutorial();
				//if( !theGame.tutorialenabled )
				//{
					//theHud.m_hud.ShowTutorial("tut78", "", true, 10); // <-- tutorial content is present in external tutorial - disabled
					//theHud.ShowTutorialPanelOld( "tut78", "" );
				//}	
				this.HideCombatMode();
			}
		}
	}	
	
	function KeepCombatMode()
	{
		combatMode = 7;
		theGame.CreateNoSaveLock( 'PlayerInCombat', combatModeSaveLock );
		
		if ( thePlayer.AreCombatHotKeysBlocked() ) thePlayer.SetCombatHotKeysBlocked( false );
		
		theSound.TriggerCombatMusic( 10.0f );
		
		//WTF!? when Geralt is attacked by someone he shouldn't broadcast this!!!
		//theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( attackInterestPoint, this, 2.0 );
	}
	
	function DecreaseCombatMode()
	{
		combatMode = combatMode - 1;
		if ( combatMode<0 )
		{
			theGame.ReleaseNoSaveLock( combatModeSaveLock );
			combatModeSaveLock = -1;
			combatMode = 0;
			
			// Press build hack, allowing activation of exploration areas that we already stand on
			HACKReenterExplorationAreas();
			
			if( areGuardsHostile )
			{
				SetGuardsHostile( false );
			}
		}
	}
	function PlayLowHealthEffect()
	{
		if(!playCameraVitEffect)
		{
			playCameraVitEffect = true;
			//theCamera.PlayEffect('caution');
		}
	}
		
	timer function StatsTimer( timeDelta : float )
	{
		var vitalityCombatRegen : float;
		var vitalityNonCombatRegen : float;
		var staminaCombatRegen : float;
		var staminaNonCombatRegen : float;
		var adrenalineDeRegen : float;
		var adrenalineRegen : float;
		var toxicityDeRegen : float;
		var staminaToxRegenMult : float;
		var adrenalineToxRegenBonus : float;
		var vitality : float;
		var toxicityTreshold : float;
		var nightVitRegen : float;
		var playerState : EPlayerState;
		var decreaseHealth : float;
		var darkItem : SItemUniqueId;
		var inv : CInventoryComponent;
		
		
		
		
		if(!IsAlive() || GetHealth() <= 0.0f)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Exploration || playerState == PS_CombatSteel || playerState == PS_CombatSilver || playerState == PS_CombatFistfightDynamic || playerState == PS_Sneak)
			{
				thePlayer.Kill(true, NULL);
			}
			return;
		}
		
		//checking dark items
		PlayerRemoveDarkDiffItemsIfNotDarkDiff( );
		
		darkItem = GetCurrentWeapon();
		
		if(darkItem == GetInvalidUniqueId())
		{
			SetDarkWeaponSilver(false);
			SetDarkWeaponSteel(false);
			SetDarkSet(false);		
		}
		else
		{
			if(GetInventory().ItemHasTag(darkItem, 'DarkDiffA1') || GetInventory().ItemHasTag(darkItem, 'DarkDiffA2') || GetInventory().ItemHasTag(darkItem, 'DarkDiffA3') )
			{
				if( thePlayer.GetCurrentPlayerState() != PS_Cutscene && !IsDarkEffect() )
				{
					if(GetInventory().ItemHasTag(darkItem, 'SteelSword'))
					{
						SetDarkWeaponSteel(true);
						CheckSet(darkItem, thePlayer);
					}
					else if(GetInventory().ItemHasTag(darkItem, 'SilverSword'))
					{
						SetDarkWeaponSilver(true);
						CheckSet(darkItem, thePlayer);
					}
				}
			}
			else
			{
				SetDarkWeaponSilver(false);
				SetDarkWeaponSteel(false);
				SetDarkSet(false);
			}
		}
		// --------------------------------------------------
		
		CheckAbilityTutorial();
		
	if ( GetCurrentPlayerState() != PS_Cutscene )
		if ( GetInventory().IsItemMounted( GetInventory().GetItemId('Cutscene Sword') ) || GetInventory().IsItemHeld( GetInventory().GetItemId('Cutscene Sword') ) ) 
			{ 
				GetInventory().MountItem( GetBestSteelSword() ); 
				if ( GetInventory().IsItemMounted( GetInventory().GetItemId('Cutscene Sword') ) || GetInventory().IsItemHeld( GetInventory().GetItemId('Cutscene Sword') ) )
				{
					thePlayer.GetInventory().UnmountItem( GetInventory().GetItemId('Cutscene Sword') );
					thePlayer.ChangePlayerState( PS_CombatFistfightDynamic );
				}
			};
		
		if ( theGame.GetDifficultyLevel() < 3 ) SetInsaneAch( false );
				
		toxicityTreshold = GetCharacterStats().GetFinalAttribute('toxicity_threshold');
		if(toxicityTreshold <= 0.0)
		{	
			toxicityTreshold = 1.0;
		}
		staminaToxRegenMult = GetCharacterStats().GetFinalAttribute('endurance_regen_toxbonus');
		if(staminaToxRegenMult < 0.0f)
		{
			staminaToxRegenMult = 0.0f;
		}
		vitality = GetCharacterStats().GetFinalAttribute('vitality');
		
 		toxicityDeRegen = GetCharacterStats().GetFinalAttribute('toxicity_degeneration');
		vitalityCombatRegen = GetCharacterStats().GetFinalAttribute('vitality_combat_regen');
		vitalityNonCombatRegen = GetCharacterStats().GetFinalAttribute('vitality_regen');
		if(theGame.GetDifficultyLevel() == 0)
		{
			vitalityCombatRegen = vitalityCombatRegen + GetCharacterStats().GetFinalAttribute('vitality_regen_combat_easy');
		}
		if(theGame.GetDifficultyLevel() == 0)
		{
			vitalityNonCombatRegen = vitalityNonCombatRegen + GetCharacterStats().GetFinalAttribute('vitality_regen_easy');
		}
		staminaCombatRegen = GetCharacterStats().GetFinalAttribute('endurance_combat_regen');
		staminaNonCombatRegen = GetCharacterStats().GetFinalAttribute('endurance_noncombat_regen');
		adrenalineDeRegen = GetCharacterStats().GetFinalAttribute('adrenaline_degeneration');
		adrenalineRegen =GetCharacterStats().GetFinalAttribute('adrenaline_toxgeneration');
		
		if(thePlayer.getActiveQuen())
		{
			staminaCombatRegen = 0.0f;
			staminaNonCombatRegen = 0.0f;
		}
		if(GetToxicity()>toxicityTreshold)
		{
			staminaCombatRegen = staminaCombatRegen*(1+staminaToxRegenMult);
			staminaNonCombatRegen = staminaNonCombatRegen*(1+staminaToxRegenMult);
		}
		if( GetCurrentPlayerState() == PS_CombatFistfightStatic )
		{
			return;
		}
		if(staminaRegenerationCooldown > 0.0)
		{
			staminaRegenerationCooldown -= timeDelta;
			staminaCombatRegen = 0.0f;
			staminaNonCombatRegen = 0.0f;
		}
		else
		{
			staminaRegenerationCooldown = 0.0;
		}
		if(thePlayer.GetCharacterStats().HasAbility('story_s22_1'))	
		{
			nightVitRegen = GetCharacterStats().GetFinalAttribute('night_vitality_regen');
			//vitalityCombatRegen = vitalityCombatRegen + nightVitRegen;
			vitalityNonCombatRegen = vitalityCombatRegen + nightVitRegen;
		}
		
			//SetToxicity( GetToxicity() - toxicityDeRegen );
			if(thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
			{
				adrenalineRegen = 0;
			}
			if ( IsInCombat() )
			{
				if ( GetWitcherType(WitcherType_Alchemy) && GetToxicity() > toxicityTreshold ) 
				{
					if ( adrenalineRegen != 0 ) SetAdrenaline( GetAdrenaline() + ( adrenalineRegen*thePlayer.GetAdrenalineMult() ) );
				}
				
				
				IncreaseStamina( staminaCombatRegen );
				// in combat mode stamin regen in time only if not in sword type build
				//if ( GetWitcherType() != WitcherType_Sword )
				//{
					if ( staminaCombatRegen != 0 ) IncreaseStamina( staminaCombatRegen );
					// add toxicity level regen bonus here later!!!
				//}
				if (!dontRecalcStats) IncreaseHealth( 0.1 + vitalityCombatRegen );
			}
			else
			{
				SetAdrenaline( GetAdrenaline() - ( adrenalineDeRegen ) );
				// outside combat faster endurance regen
				IncreaseStamina( staminaNonCombatRegen );
				// and vitality regen
				IncreaseHealth( vitalityNonCombatRegen );
			}
		
		if(GetHealth() < 0.3*vitality && !playCameraVitEffect)
		{
			playCameraVitEffect = true;
			//theCamera.PlayEffect('caution');
		}
		else if(GetHealth() > 0.3*vitality && playCameraVitEffect)
		{
			playCameraVitEffect = false;
			//theCamera.StopEffect('caution');
		}
		SetInitialHealth( GetCharacterStats().GetFinalAttribute( 'vitality' ) );
		SetInitialStamina( GetCharacterStats().GetFinalAttribute( 'endurance' ) );
		
		//Log("----------------");
		//Log("Vitality : " + thePlayer.GetHealth() );
		//Log("Endurance: " + thePlayer.GetStamina() );
		//Log("----------------");
		theHud.InvokeOneArg("vHUD.setExpBar", FlashValueFromInt( RoundF( 1 + ( ( thePlayer.GetExp() - ( ( thePlayer.GetLevel() - 1 ) * 1000 ) ) ) / 10 ) ) );
		/*if ( thePlayer.isNotGeralt )
		{
			theHud.InvokeOneArg("vHUD.hideItemSlots", FlashValueFromBoolean( false ) );
		} else
		{
			theHud.InvokeOneArg("vHUD.hideItemSlots", FlashValueFro
mBoolean( true ) );
		}*/
		if ( talents > 0 ) 
		{
			theHud.Invoke("vHUD.showTalent");
		} else
		{
			theHud.Invoke("vHUD.hideTalent");
		}
		
		if ( !this.AreCombatHotKeysBlocked() ) SetCombatBlockTriggerActive( false, NULL );
		
		if ( IsDarkWeapon() )
		{
			if ( GetCurrentPlayerState() == PS_CombatSteel || GetCurrentPlayerState() == PS_CombatSilver ) 
			{
				if(!IsDarkSet())
				{
					//tracimy zycie procentowo
					if(IsInCombat())
					{
						decreaseHealth = 0.01*(GetCharacterStats().GetAttribute('dark_rem_vitality')*GetInitialHealth()) + vitalityCombatRegen;
					}
					else
					{
						decreaseHealth = 0.01*(GetCharacterStats().GetAttribute('dark_rem_vitality')*GetInitialHealth()) + vitalityNonCombatRegen;
					}
				}
				DecreaseHealth(decreaseHealth, true, NULL);
				if ( !IsDarkEffect() ) PlayEffect('dark_difficulty');		
			}
				
		}	
		//Checking if the player's in dark difficulty mode, and if not taking away all da/rk dif schematics
		/*if ( theGame.GetDifficultyLevel() != 4 )
		{
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA3' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA3' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA3' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA3' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A3' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A1' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A2' ) );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A3' ) );
		}*/


	}
	
	private function SendStatsToGui()
	{
		theHud.m_hud.SetPCHealth( health, initialHealth );
		theHud.m_hud.SetPCAdrenalinePercent( adrenaline );
		theHud.m_hud.SetIsAdrenalineActive( adrenaline == 100 );
		theHud.m_hud.SetPCToxicityPercent( toxicity );
		theHud.m_hud.SetPCStaminaCurrentLevel( stamina );
		theHud.m_hud.SetPCStaminaMaximumLevel( initialStamina );
		theHud.m_hud.SetIsMedallionActive( m_canUseMedallion );
		theHud.InvokeOneArg("vHUD.setExpBar", FlashValueFromInt( RoundF( 1 + ( ( thePlayer.GetExp() - ( ( thePlayer.GetLevel() - 1 ) * 1000 ) ) ) / 10 ) ) );
		if ( talents > 0 ) 
		{
			theHud.Invoke("vHUD.showTalent");
		} else
		{
			theHud.Invoke("vHUD.hideTalent");
		}		
	}
			
	private function SetInitialHealth( amount : float )
	{
		if ( amount != initialHealth )
		{
			super.SetInitialHealth( amount );
			theHud.m_hud.SetPCHealth( health, initialHealth );
		}
	}

	private function SetHealth( value: float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData  )
	{
		var oldValue : float = thePlayer.GetHealth();
	
		super.SetHealth( value, lethal, attacker );
		
		if ( oldValue > value )
		{ 
			//theHud.m_hud.ShowTutorial("tut20", "", false); // <-- tutorial content is present in external tutorial - disabled
		//if ( oldValue > value ) { theHud.ShowTutorialPanelOld( "tut20", "" ); 		
			thePlayer.SetKilledWithoutHurt( 0 );
		}


	
		//if ( oldValue > value )
		//{
			theHud.m_hud.SetPCHealth( health, initialHealth );
		//}
		
		value = thePlayer.GetHealth();
		
		if( value != oldValue )
		{
			theSound.UpdateParameter( "health_sts", value / initialHealth );
		}

	}	
	
	private function SetAdrenaline( amount : float )
	{
		if ( thePlayer.IsNotGeralt() || thePlayer.GetEnemy().IsBoss() || IsBigBosFight() )
		{
			amount = 0;
		}
		if ( amount > 100 ) amount = 100;
		if ( amount < 0 ) amount = 0;
		
		if ( adrenaline != amount )
		{
			adrenaline = amount;
		
			theHud.m_hud.SetPCAdrenalinePercent( adrenaline );
			theHud.m_hud.SetIsAdrenalineActive( adrenaline == 100 );
			if ( adrenaline == 100 ) 
			{
				if ( thePlayer.GetWitcherType(WitcherType_Magic) ) { theHud.m_hud.ShowTutorial("tut41", "tut39_333x166", false); } else
				//if ( thePlayer.GetWitcherType(WitcherType_Magic) ) { theHud.ShowTutorialPanelOld( "tut41", "tut39_333x166" ); } else
				if ( thePlayer.GetWitcherType(WitcherType_Sword) ) { theHud.m_hud.ShowTutorial("tut40", "tut39_333x166", false); } else
				//if ( thePlayer.GetWitcherType(WitcherType_Sword) ) { theHud.ShowTutorialPanelOld( "tut40", "tut39_333x166" ); } else
				if ( thePlayer.GetWitcherType(WitcherType_Alchemy) ) { theHud.m_hud.ShowTutorial("tut39", "tut39_333x166", false); };
				//if ( thePlayer.GetWitcherType(WitcherType_Alchemy) ) { theHud.ShowTutorialPanelOld( "tut39", "tut39_333x166" ); };
			}	
		}
	}
	
	private function GetAdrenaline() : float
	{
		return adrenaline;
	}
	
	// Enter dead state
	private function EnterDead( optional deathData : SActorDeathData )
	{
		StateDead( deathData );
	}
	
	// Enter stun
	private function EnterUnconscious( optional deathData : SActorDeathData )
	{
		// no stun state in player
		EnterDead( deathData );
	}
	
	// COMBAT MODE FUNCTIONS
	
	function ShowCombatMode()
	{
		if(!theGame.GetIsPlayerOnArena() && !theGame.tutorialenabled )
		{
			theHud.m_fx.CombatModeStart();
			this.wasInCombatMode = true; // HUD OPT by Dex
		}
	}
	
	function HideCombatMode()
	{
		if(!theGame.GetIsPlayerOnArena() && !theGame.tutorialenabled )
		{
			theHud.m_fx.CombatModeStop();
		}
		theHud.m_hud.CombatLogClear();	
		this.combatMode = -1;
		this.wasInCombatMode = false; // HUD OPT by Dex
		theGame.ReleaseNoSaveLock( combatModeSaveLock );
		combatModeSaveLock = -1;
	}	
	
	// TOXICITY FUNCTIONS
	
	// Get toxicity
	function GetToxicity() : float
	{	
		return toxicity;
	}

	// Set toxicity
	function SetToxicity( amount : float, optional force : bool ) 
	{		
		if ( toxicity != amount || force )
		{
			toxicity = amount;
			theGame.GetCamera().StopEffect('overdose');
			theGame.GetCamera().StopEffect('overdose_1');
			theGame.GetCamera().StopEffect('overdose_2');
			if (toxicity < 0) toxicity = 0;
			/*if ( toxicity >= thePlayer.GetCharacterStats().GetAttribute('toxicity_light') ) theGame.GetCamera().PlayEffect('overdose', theGame.GetCamera());
			if ( toxicity >= thePlayer.GetCharacterStats().GetAttribute('toxicity_medium') ) theGame.GetCamera().PlayEffect('overdose_1', theGame.GetCamera());
			if ( toxicity >= thePlayer.GetCharacterStats().GetAttribute('toxicity_high') ) theGame.GetCamera().PlayEffect('overdose_2', theGame.GetCamera());*/
			theHud.m_hud.SetPCToxicityPercent( toxicity );
		}
	}
	
	// STAMINA FUNCTIONS OVERRIDES
	
	private function SetInitialStamina( amount: float )
	{
		if ( amount != initialStamina )
		{
			super.SetInitialStamina( amount );
			theHud.m_hud.SetPCStaminaMaximumLevel( initialStamina );
		}
	}
	
	// Decrease actor's stamina
	private function DecreaseStamina( amount: float )
	{
		var oldStamina : float = stamina;
		super.DecreaseStamina( amount );
		
		//if( !theGame.tutorialenabled )
		//{
			//theHud.m_hud.ShowTutorial("tut09", "", false); // <-- tutorial content is present in external tutorial - disabled
			//theHud.ShowTutorialPanelOld( "tut09", "" );
		//}
		if( oldStamina != stamina )
		{	
			theHud.m_hud.SetPCStaminaCurrentLevel( stamina );
		}
	}
	
	// Increase actor's stamina
	private function IncreaseStamina( amount: float )
	{
		var oldStamina : float = stamina;
		super.IncreaseStamina( amount );
			
		if( oldStamina != stamina )
		{
			theHud.m_hud.SetPCStaminaCurrentLevel( stamina );
		}
	}

	function GetStaminaBlockMult() : float
	{
		//Stamina was decreased, so it has to be increased to check the initial stamina.
		var stamina		: float			= GetStamina() + thePlayer.GetCharacterStats().GetAttribute('endurance_on_block_mult');
		var staminaInt	: int;
		var maxStamina	: float			= GetMaxStamina();
		var staminaToMaxStamina : float;
		var minStaminaBlockMult : float = 0.5;
		var staminaMult : float;
		
		if(stamina < 0 )
		{
			stamina = 0;
		}
		
		staminaInt = (int)stamina; 
		
		stamina = staminaInt;
		
		staminaToMaxStamina = stamina / maxStamina;
		
		staminaMult = minStaminaBlockMult + (1-minStaminaBlockMult)*staminaToMaxStamina;
		
		return staminaMult;
	}
	function GetStaminaDamageMult() : float
	{
		var stamina		: float			= GetStamina();
		var staminaInt	: int;
		var maxStamina	: float			= GetMaxStamina();
		var staminaToMaxStamina : float;
		
		staminaInt = (int)stamina;
		stamina = staminaInt;
		
		if(stamina < 0)
		{
			stamina = 0;
		}
		
		staminaToMaxStamina = stamina / maxStamina;
		
		return 0.5 + 0.5*staminaToMaxStamina;
	}
	function IncreaseStaminaBuild()
	{
		// If witcher sword build is active - regenerate Endurance on every hit
		if ( GetWitcherType(WitcherType_Sword) )
		{
			//IncreaseStamina( GetCharacterStats().GetAttribute('endurance_swordhit_regen') );
		}
		// If witcher magic build is active - regenerate Endurance on every hit
		if ( GetWitcherType(WitcherType_Magic) )
		{
			//IncreaseStamina( GetCharacterStats().GetAttribute('endurance_signhit_regen') );
		}
	}
	
	function GetWitcherType( type : EWitcherType ) : bool
	{
		if ( type == WitcherType_Sword && GetCharacterStats().HasAbility('sword_s14') ) return true;
		if ( type == WitcherType_Magic && GetCharacterStats().HasAbility('magic_s14') ) return true;
		if ( type == WitcherType_Alchemy && GetCharacterStats().HasAbility('alchemy_s14') ) return true;
		return false;
	}
	
	function SetWitcherType( witcherType : EWitcherType )
	{
		if ( witcherType == WitcherType_Sword )
		{
			GetCharacterStats().AddAbility('witcher_type_sword');
		}
		else if ( witcherType == WitcherType_Magic )
		{
			GetCharacterStats().AddAbility('witcher_type_magic');
		}
		else if ( witcherType == WitcherType_Alchemy )
		{
			GetCharacterStats().AddAbility('witcher_type_alchemy');
		}
	}

	function SetBasicAbility()
	{
		GetCharacterStats().AddAbility('Witcher Default');
	}
	
	// EXPERIENCE AND TALENT POINTS
	function ResetLevel()
	{
		level = 0;
	}
	// Levelup
	function SetLevelUp()
	{		
		var levelname : name;
		var talents : int;
		
		if (level < 35)
		{
			level = level + 1;
			
			talents = GetTalentPoints();
			SetTalentPoints( talents + 1 );
			
			levelname = StringToName("Level" + level);
			GetCharacterStats().AddAbility( levelname );
			theSound.PlaySound("gui/other/levelup");
			theHud.m_hud.NotifyLevelUp( level );
			thePlayer.SendStatsToGui();
			
		}
		
		if ( level > 9 ) theGame.UnlockAchievement('ACH_LEVEL_10');
		if ( level > 34 ) theGame.UnlockAchievement('ACH_LEVEL_35');
		
		ResetStats();
		thePlayer.SendStatsToGui();

		/*
		if( !theGame.tutorialenabled ) // <-- tutorial content is present in external tutorial - disabled	
		{
			if ( theGame.IsUsingPad() )
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				if  ( !theHud.m_hud.ShowTutorial("tut113", "", false, 5) ) theHud.m_hud.ShowTutorial("tut81", "", false, 5);		
				//if  ( !theHud.ShowTutorialPanelOld( "tut113", "" ) ) theHud.ShowTutorialPanelOld("tut81", "" );		
			}
			else
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				if  ( !theHud.m_hud.ShowTutorial("tut13", "", false, 5) ) theHud.m_hud.ShowTutorial("tut81", "", false, 5);			
				//if  ( !theHud.ShowTutorialPanelOld("tut13", "" ) ) theHud.ShowTutorialPanelOld("tut81", "" );			
				
			}
		}
		*/
	}

	// Get Experience
	function GetExp() : int
	{		
		return experience;
	}

	// Increase Experience
	function IncreaseExp(amount : int)
	{		
		var max_experience : int; 
		var x  : int;
		var i : int;
		
		if (thePlayer.isNotGeralt) return;
		/*
		if( !theGame.tutorialenabled ) // <-- tutorial content is present in external tutorial - disabled
		{
			if ( theGame.IsUsingPad() )
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				theHud.m_hud.ShowTutorial("tut165", "tut65_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut165", "tut65_333x166" );
			}
			else
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				theHud.m_hud.ShowTutorial("tut65", "tut65_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut65", "tut65_333x166" );
			}
		}
		*/
		
		experience = experience + amount;
	
	for( i=1; i<4; i+=1 )
	{		
		max_experience = GetExperienceForNextLevel( level ); //- GetExperienceForNextLevel( level - 1);
		x = experience / level;
		//if (x> (1000 * level) ) x = ( 1000 * level );
		
		Log("----------------------------------------");
		Log("Experience max : " + max_experience);
		Log("Experience : " + experience);
		Log("X : " + x);
		Log("----------------------------------------");
		
		// is level up?
		if (experience >= (max_experience))
		{
			SetLevelUp();
			//experience = 0;
			//x = 0;
		}
	}
		
		thePlayer.SendStatsToGui();
		
		
	}
	
	// Get actor' talent points
	function GetTalentPoints() : int
	{		
		return talents;
	}

	// Set actor' talent points
	function SetTalentPoints(talent_points : int) 
	{	
		talents = talent_points;
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Wait Time
	///////////////////////////////////////////////////////////////////////////////////	
	public function IsWaitTimeAllowed() : bool
	{
		return isWaitTimeAllowed;
	}
	
	public function SetWaitTimeAllowed( isAllowed : bool )
	{
		isWaitTimeAllowed = isAllowed;
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Signs management
	///////////////////////////////////////////////////////////////////////////////////	
	private var lastSignCastTime 	: float;
	private var signTarget 			: CEntity;
	private var axiiRandomChance	: bool;
	
	function FindPowerPlaces()
	{
	 var nodes : array <CNode>;
	 var powerplace : CPowerSource;
	 var i : int;
	 theGame.GetNodesByTag('powerplace', nodes);
	 	for ( i = 0; i < nodes.Size(); i += 1 )
		{
			powerplace = (CPowerSource) nodes[i];
			if ( ( !powerplace.wasUsed ) && ( VecDistance2D( powerplace.GetWorldPosition(), thePlayer.GetWorldPosition() ) < 20 ) )
			{
				powerplace.onMedalionGlow();
			}
		}
	}
	
	function TriggerMedalionFX()
	{
		var rot : EulerAngles;
		var pos : Vector;
		var entity : CEntityTemplate;
		var fogGuide : FogGuideQ214;
		var draugirs : array<CActor>;
		var draugirLife, draugirHalfHP : float;
		var i : int;
		
		if ( m_canUseMedallion )
		{
			entity = medalionEntity;
			pos = GetWorldPosition();
			theGame.CreateEntity(entity, pos, rot, true, false);
			
			m_canUseMedallion = false;
			theHud.m_hud.SetIsMedallionActive( false );
			AddTimer( 'OnEnableMedallion', 10.f, false );
			
			FindPowerPlaces();
			
			if( FactsQuerySum('q214_medallion_to_vergen') == 1)
			{				
				theHud.EnableTrackedMapPinTag( 'q214_medallion_target_to_vergen' );
				
				draugirs = this.FindEnemiesInCombatArea();
				
				for ( i = 0; i < draugirs.Size(); i += 1 )
				{
					draugirHalfHP = (draugirs[i].GetInitialHealth()) * 0.5;
					draugirLife = draugirs[i].GetHealth();
					draugirs[i].SetHealth((draugirLife - draugirHalfHP), true, NULL);
				}
				
				thePlayer.AddTimer('Q214DisableVergenMappin', 4.0f, false);
				
			}
			
			if( FactsQuerySum('q214_medallion_to_camp') == 1)
			{
				theHud.EnableTrackedMapPinTag( 'q214_medallion_target_to_camp' );
				
				draugirs = this.FindEnemiesInCombatArea();
				
				for ( i = 0; i < draugirs.Size(); i += 1 )
				{
					draugirHalfHP = (draugirs[i].GetInitialHealth()) * 0.5;
					draugirLife = draugirs[i].GetHealth();
					draugirs[i].PlayEffect('electric_shield_fx');
					draugirs[i].SetHealth((draugirLife - draugirHalfHP), true, NULL);
				}
				
				thePlayer.AddTimer('Q214DisableCampMappin', 4.0f, false);
			}
			
		}
	}
	
	timer function OnEnableMedallion( timeDelta : float )
	{
		m_canUseMedallion = true;
		theHud.m_hud.SetIsMedallionActive( true );
	}
	
	timer function Q214DisableCampMappin( timeDelta : float )
	{
		theHud.DisableTrackedMapPinTag('q214_medallion_target_to_camp');
	}
	
	timer function Q214DisableVergenMappin( timeDelta : float )
	{
		theHud.DisableTrackedMapPinTag('q214_medallion_target_to_vergen');
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if ( animEventName == 'deploy_trap' )
		{
			if( GetInventory().GetItemCategory( thrownItemId ) == 'trap' )
				DeployTrap(thrownItemId);
			else
				DeployLure(thrownItemId);
		}
		else if( animEventName == 'SignHit' )
		{
			if(!CheckIsCastingHeliotrop())
			{
				SpawnSelectedSign();
			}
			else
			{
				SetIsCastingHeliotrop(0.0f);
			}
		} 
		else if ( animEventName == 'medalion_fx' )
		{
			TriggerMedalionFX();
		}
	}

	function SignsStaminaDegeneration()
	{
		staminaRegenerationCooldown = thePlayer.GetCharacterStats().GetAttribute('stamina_regen_cooldown_time');
		
		if(staminaRegenerationCooldown <= 0.0f)
			staminaRegenerationCooldown = 3.0;
	}
	
	private function SpawnSelectedSign()
	{
		var aard					: CWitcherSignAard;
		var yrden					: CWitcherSignYrden;
		var igni					: CWitcherSignIgni;
		var quen					: CWitcherSignQuen;
		var axii					: CWitcherSignAxii;
		var heliotrop				: CWitcherSignHeliotrop;
		
		SetNewSignSelectionCooldown(0.0f);
		if ( selectedSign == ST_Aard )
		{
			aard = (CWitcherSignAard)SpawnSignItem( 'Aard' );
			aard.Initialize( this, signTarget );
		}
		else if ( selectedSign == ST_Yrden )
		{
			yrden = (CWitcherSignYrden)SpawnSignItem( 'Yrden' );
			yrden.Init( this );
		}
		else if ( selectedSign == ST_Igni )
		{
			igni = (CWitcherSignIgni)SpawnSignItem( 'Igni' );
			igni.Initialize( this, signTarget );
		}
		else if ( selectedSign == ST_Quen )
		{
			quen = (CWitcherSignQuen)SpawnSignItem( 'Quen' );
			quen.Init();
		}
		else if ( selectedSign == ST_Axii )
		{
			//if ( !signTarget || signTarget.IsA( 'CNewNPC' ) )
			//{
				axii = (CWitcherSignAxii)SpawnSignItem( 'Axii' );
				axii.Init( (CNewNPC)signTarget, axiiRandomChance );
			//}
			//else
			//{
			//	Log( "Selected axii target is not a CNewNPC" );
			//}
		}
		/*else if ( selectedSign == ST_Heliotrop )
		{
			SelectSign( oldSign, false ); // always for heliotrop
			heliotrop = (CWitcherSignHeliotrop)SpawnSignItem( 'Heliotrop' );
			heliotrop.Init();
		}*/
		
		if( restoreOldSign )
		{
			SelectSign( oldSign, false );
		}
	}
	
	function CheckQuenPresent()
	{
		if(!activeQuenSign)
		{
			thePlayer.StopEffect('Quen_level1');
			thePlayer.StopEffect('Quen_level0');
		}
	}
	
	timer function SignCooldownTimer( timeDelta : float )
	{
		var val : float;
		var currTime 	: float = EngineTimeToFloat( theGame.GetEngineTime() );
		var signsCooldown : float;
		
		if ( CanThrowNextSign() ) 
		{
			thePlayer.RemoveTimer( 'SignCooldownTimer' );
		} else
		{
		
			signsCooldown = thePlayer.GetCharacterStats().GetFinalAttribute('signs_cooldown');		
		
			val = ( ( lastSignCastTime - currTime ) / signsCooldown ) * 100;
		
			theHud.m_hud.SetItemAlpha( true,  RoundF( val ) );
			Log(" ------------>> " + val );
		}
	}
	
	private function CanThrowNextSign() : bool
	{
		
		var currTime 	: float = EngineTimeToFloat( theGame.GetEngineTime() );
		if(currTime > lastSignCastTime)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	private function OnThrowSign()
	{
		var signsCooldown : float;
		signsCooldown = thePlayer.GetCharacterStats().GetFinalAttribute('signs_cooldown');
		
		lastSignCastTime = EngineTimeToFloat( theGame.GetEngineTime() ) + signsCooldown;
		
		thePlayer.AddTimer('SignCooldownTimer', 0.2, true );
		
	}
		//Funkcja uzywana do obracania Geralta przed rzuceniem Aarda. 
	function CombatRotateToPosition(position : Vector)
	{
		if(IsCombatRotationAllowed())
		{
			if(thePlayer.GetCurrentPlayerState() == PS_CombatSteel)
			{
				thePlayer.CombatRotateToPositionSteel(position);
			}
			else if(thePlayer.GetCurrentPlayerState() == PS_CombatSilver)
			{
				thePlayer.CombatRotateToPositionSilver(position);
			}
			else if(thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
			{
				thePlayer.CombatRotateToPositionFF(position);
			}
			else
			{
				thePlayer.ChangePlayerState(PS_Exploration);
			}
		}
	}
	// triggers the sign selected in the player
	function TriggerSelectedSign( target : CEntity ) : bool
	{
		var result 		: bool = false;
		var currTime 	: float = EngineTimeToFloat( theGame.GetEngineTime() );		
		var dir : EDirection;
		var actor : CActor;
		SetRiposteInRow(0);
		restoreOldSign = false;
		if ( GetStamina() >= 1.0 && CanThrowNextSign() )
		{
			SignsStaminaDegeneration();
			SetPlayerCombatStance(PCS_High);
			if(thePlayer.GetCurrentPlayerState() == PS_CombatSteel || thePlayer.GetCurrentPlayerState() == PS_CombatSilver || thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
			{
				if(selectedSign == ST_Quen && getActiveQuen())
				{
					getActiveQuen().FadeOut();
				}
				if ( target )
				{
					signTarget = target;
					actor = (CActor)target;
					dir = CalculateRelativeDirection( this, signTarget );
					//result = RaiseForceEvent( signBehaviorEvents[ selectedSign ].events[dir] );
					result = PlayerCombatAction(signBehaviorEvents[selectedSign]);
				}
				else
				{
					actor = NULL;
					signTarget = NULL;
					result = PlayerCombatAction(signBehaviorEvents[selectedSign]);
				}
				SetNewSignSelectionCooldown(2.0);
				if(selectedSign == ST_Aard || selectedSign == ST_Igni || selectedSign == ST_Axii)
					CombatRotateToPosition(CalculateSignTarget(signTarget));
			}
			else
			{
				ChangePlayerState(GetLastCombatStyle());
			}
		} 
		else
		{
			if ( GetStamina() < 0.5 ) 
			{ 
				theHud.m_hud.SetPCStaminaBlink();
			} 
			else
			{
				if ( !CanThrowNextSign() ) theHud.m_hud.setItemBlink( true );
			}
			
			theSound.PlaySound( "gui/hud/cannotcastsign" );
		}
		if ( result )
		{
			OnThrowSign();
		}
		return result;
	}
	function CalculateSignTarget(target : CEntity) : Vector
	{
		var position, playerPosition : Vector;
		var positionOnGound : Vector;
		var traceStopPosition, traceStartPosition : Vector;
		var cameraToTracePositionVector : Vector;
		var cameraPosition : Vector;
		var cameraDirection : Vector;
		var normal : Vector;
		var color : Color;
		var actor : CActor;
		
		actor = (CActor)target;

		if(actor && actor.IsAlive())
		{
			position = actor.GetWorldPosition();
			if(actor.GetMonsterType() == MT_Nekker)
			{
				position.Z += 1.0f;
			}
			else if(!actor.IsMonster())
			{
				position.Z += 1.5f;
			}
			else if(actor.IsHuge())
			{
				position.Z += 2.0f;
			}
			else
			{
				position.Z += 1.0f;
			}
		}
		else if(!actor && target)
		{
			position = target.GetWorldPosition();
			position.Z += target.GetSignTargetZ();
		}
		else
		{
			actor = NULL;
			cameraDirection = theCamera.GetCameraDirection();
			cameraDirection.Z += 0.05;
			playerPosition = thePlayer.GetWorldPosition();
			traceStopPosition = playerPosition + 20*cameraDirection;
			cameraPosition = theCamera.GetCameraPosition();
			cameraToTracePositionVector = VecNormalize(traceStopPosition - cameraPosition);
			traceStartPosition = cameraPosition;// + 1.5*cameraToTracePositionVector;
			/*if(theGame.GetWorld().PointProjectionTest(position, normal, 2.0))
			{
				position.Z += 1.0f;
			}
			else
			{*/
				position = playerPosition + 100*cameraDirection;
				positionOnGound = position;
				theGame.GetWorld().StaticTrace(traceStartPosition, traceStopPosition, positionOnGound, normal);
				if(theGame.GetWorld().StaticTrace(traceStartPosition, traceStopPosition, positionOnGound, normal))
				{
					
					if(VecDistance(positionOnGound, playerPosition) < 5.0)
					{
						//positionOnGound.Z = playerPosition.Z;
						position = playerPosition + 10*VecNormalize(positionOnGound - playerPosition);
						position.Z = positionOnGound.Z - 1;
					}
					color = Color(255,0,0);
					thePlayer.GetVisualDebug().AddSphere('tracestartpos', 0.3, cameraPosition, true, color, 10.0);
					thePlayer.GetVisualDebug().AddSphere('tracestoppos', 0.3, traceStopPosition, true, color, 10.0);
					color = Color(255,255,255);
					thePlayer.GetVisualDebug().AddSphere('tracestoppos', 0.3, positionOnGound, true, color, 10.0);

				}
				//position.Z = playerPosition.Z + 1.0f;
				
			//}
		}
		return position;
	}
	function GetSelectedSign() : ESignTypes
	{
		return selectedSign;
	}
	function UseAnimationWithHeliotrop(flag : bool)
	{
		useAnimInHeliotrop = flag;
	}
	// triggers the sign heliotrop in the player
	timer function TriggerHeliotropTimer(td : float)
	{
		TriggerHeliotropSign( NULL, useAnimInHeliotrop );
	}
	function CheckIsCastingHeliotrop() : bool
	{
		if(theGame.GetEngineTime() < heliotropTime + signAfterHeliotropCooldown)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function SetIsCastingHeliotrop(castingTime : float)
	{
		heliotropTime = theGame.GetEngineTime();
		signAfterHeliotropCooldown = castingTime;
	}
	function TriggerHeliotropSign( target : CEntity, playAnim : bool )
	{
		var result 		: bool = false;
		var currTime 	: float = EngineTimeToFloat( theGame.GetEngineTime() );		
		var dir : EDirection;
		var heliotrop : CWitcherSignHeliotrop;
		//thePlayer.SelectSign( ST_Heliotrop, true ); 
		heliotrop = (CWitcherSignHeliotrop)SpawnSignItem( 'Heliotrop' );
		heliotrop.Init();
		SetIsCastingHeliotrop(3.0);
		if(playAnim)
		{
			result = PlayerCombatAction(PCA_SignHeliotrop);
		}
		else
		{
			result = true;
		}
			/*if ( target )
			{
				signTarget = target;
				dir = CalculateRelativeDirection( this, signTarget );
				result = RaiseForceEvent( signBehaviorEvents[ ST_Heliotrop ].events[dir] );
			}
			else
			{
				RaiseForceEvent( signBehaviorEvents[ ST_Heliotrop ].events[D_Front] );
			}*/
		
		if ( result )
		{
			OnThrowSign();
		}
		
	}		
	
	// makes the player throw an Aard sign at the selected target
	final function UseAard( target : CEntity, optional behEvent : name ) : bool
	{

		SelectSign( ST_Aard, false );
		thePlayer.TriggerSelectedSign(target);
		
	}
	final function UpdateYrdenTrap(newYrdenTrap : CWitcherSignYrden)
	{
		yrdenTrapsSize = yrdenTrapsActive.Size();
		maxYrdenTraps = (int)thePlayer.GetCharacterStats().GetFinalAttribute('yrden_max_concurrent_traps');
		if(maxYrdenTraps == 0)
		{
			maxYrdenTraps = 1;
		}
		if(yrdenTrapsSize < maxYrdenTraps)
		{
			yrdenTrapsActive.PushBack(newYrdenTrap);
		}
		else
		{
			if(yrdenTrapsActive[0])
			{
				yrdenTrapsActive.PushBack(newYrdenTrap);
				yrdenTrapsActive[0].FadeOut();
			}
		}
	}
	final function RemoveYrdenTrap(oldYrdenTrap : CWitcherSignYrden)
	{
		if(yrdenTrapsActive.Contains(oldYrdenTrap))
		{
			yrdenTrapsActive.Remove(oldYrdenTrap);
		}
		else
		{
			Log("YRDEN ERROR : trying to remove non existing yrden sign");
		}
	}
	final function GetActiveYrdenTraps() : array<CWitcherSignYrden>
	{
		return yrdenTrapsActive;
	}
	final function GetAdrenalineMult() : float
	{
		var mult : float;
		mult = 0;
		if ( thePlayer.GetWitcherType(WitcherType_Magic) )
		{
			mult += 1.1;
		}
		if ( thePlayer.GetWitcherType(WitcherType_Sword) )
		{
			mult += 1.2;
		}
		if ( thePlayer.GetWitcherType(WitcherType_Alchemy) )
		{
			mult += 1;
		}
		if(mult < 1)
		{
			return 0;
		}
		else
		{
			return 1 / mult;
		}
	}
	// makes the player throw an Igni fireball at the selected target
	final function UseIgni( target : CEntity, optional behEvent : name ) : bool
	{
		SelectSign(ST_Igni, false);
		TriggerSelectedSign(target);
	}
	
	// makes the player wear a Quen protective sign
	
	final function CanSelectNewSign() : bool
	{
		if(theGame.GetEngineTime() < selectSignTime + selectSignCooldown)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	final function SetNewSignSelectionCooldown(cooldown : float)
	{
		selectSignTime = theGame.GetEngineTime();
		selectSignCooldown = cooldown;
	}
	//Selects a sign to be used using the name defined in its factory. 
	private final function SelectSign( type : ESignTypes, restoreOldSignAfterUse : bool )
	{
		var spellName : string;
		var args : array <CFlashValueScript>;
		if(selectedSign != ST_Heliotrop)
			oldSign = selectedSign;
		selectedSign = type;
		restoreOldSign = restoreOldSignAfterUse;
		
		spellName = "None" ;
		
		if ( selectedSign == ST_Aard ) { spellName = "Aard"; }
		else if ( selectedSign == ST_Yrden ) { spellName = "Yrden"; }
		else if ( selectedSign == ST_Igni ) { spellName = "Igni"; }
		else if ( selectedSign == ST_Quen ) { spellName = "Quen"; }
		else if ( selectedSign == ST_Axii ) { spellName = "Axii"; }

		if ( spellName != "None" ) 
		{
			theHud.PreloadIcon( "img://globals/gui/icons/signs/" + spellName + "_64x64.dds" );
			args.Clear();
			args.PushBack(FlashValueFromString( 	"img://globals/gui/icons/signs/" + spellName + "_64x64.dds" ));
			args.PushBack(FlashValueFromString( GetLocStringByKeyExt( spellName ) ) );
			theHud.InvokeManyArgs("vHUD.setItemSign", args );
		}		
	}
	
	private final function SelectSlotItem( itemNum : int )
	{
		if ( itemNum >= 0 && itemNum <= 5)
		{
			selectedSlotItem = itemNum;
		}
		else
		{
			LogChannel( 'GUI', "SelectSlotItem(): bad itemNum " + itemNum );
		}
	}
	
	public final function SelectNextSlotItem( omitEmptySlots : bool )
	{
		var slotItems : array< SItemUniqueId > = thePlayer.GetItemsInQuickSlots();
		var itemId : SItemUniqueId;
		var maxSlotItems : int = 5; // TODO: Somewhere in the code should be info about max slot items - use it
		var i, originalSlotItem : int;
		var itemName : string;
		var args : array <CFlashValueScript>;
		
		if ( !omitEmptySlots )
		{
			selectedSlotItem += 1;
			if ( selectedSlotItem >= maxSlotItems )
			{
				selectedSlotItem = 0;
			}
		}
		else
		{
			originalSlotItem = selectedSlotItem;
			do
			{
				// Advance in slot number
				selectedSlotItem += 1;
				if ( selectedSlotItem >= maxSlotItems )
				{
					selectedSlotItem = 0;
				}
				
				if ( selectedSlotItem == originalSlotItem )
				{
					// no items at other slots or no items at all
					return;
				}
				
				itemId = slotItems[ selectedSlotItem ];
				
			} while( itemId == GetInvalidUniqueId() )
		}
		
	 	if ( itemId != GetInvalidUniqueId() ) 
		{
		
			itemId = slotItems[ selectedSlotItem ];
			thePlayer.UseItem( itemId );

			itemName = thePlayer.GetInventory().GetItemName( itemId );
			theHud.PreloadIcon( "img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds" );
			args.PushBack(FlashValueFromString( "img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds" ));
			if ( itemId != GetInvalidUniqueId() )
			{			
				args.PushBack(FlashValueFromString( GetLocStringByKeyExt(itemName) ));
			} else
			{
				args.PushBack(FlashValueFromString( "" ));
			}
			args.PushBack( FlashValueFromInt( thePlayer.GetInventory().GetItemQuantity( itemId ) ) );
			theHud.InvokeManyArgs("vHUD.setItemQuickslot", args );
		}
	}
	
	public final function GetSelectedSlotItemNum() : int
	{
		return selectedSlotItem;
	}
	
	private final function SpawnSignItem( itemName : name ) : CEntity
	{
		var spawnPositioningResult 	: bool = false;
		var spawnPosition 			: Vector;
		var spawnRotation 			: EulerAngles;
		var ent 					: CEntity				= NULL;
		var inventory 				: CInventoryComponent 	= thePlayer.GetInventory();
		var itemId 					: SItemUniqueId 		= inventory.GetItemId( itemName );
		var itemHoldSlotName		: name 					= inventory.GetItemHoldSlot( itemId );
		
		// first find the spawning position & rotation
		if( itemHoldSlotName != '' )
		{
			spawnPositioningResult = GetSituationFromBone( itemHoldSlotName, spawnPosition, spawnRotation );
		}
		else if ( itemHoldSlotName == '' )
		{
			spawnPositioningResult = GetSituationFromEntity( spawnPosition, spawnRotation );
		}

		if ( spawnPositioningResult )
		{
			if( itemName == 'Heliotrop' )
				ent = inventory.GetDeploymentItemEntity( itemId, spawnPosition, spawnRotation, true );
			else
				ent = inventory.GetDeploymentItemEntity( itemId, spawnPosition, spawnRotation );
		}
		return ent;
	}
	
	private final function GetSituationFromBone( boneName : name, out outPosition : Vector, out outRotation : EulerAngles ) : bool
	{
		var ac 				: CAnimatedComponent;
		var boneMtx			: Matrix;

		ac = thePlayer.GetRootAnimatedComponent();
		if ( !ac )
		{
			Log( "Caster doesn't have an animated component" );
			return false;
		}
		
		boneMtx = ac.GetBoneMatrixWorldSpace( boneName );
		outPosition = MatrixGetTranslation( boneMtx );
		outRotation = MatrixGetRotation( boneMtx );
		return true;
	}

	private final function GetSituationFromEntity( out outPosition : Vector, out outRotation : EulerAngles ) : bool
	{
		outPosition = thePlayer.GetWorldPosition();
		outRotation = thePlayer.GetWorldRotation();

		return true;
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Witcher's Hair
	///////////////////////////////////////////////////////////////////////////////////
	
	public function SetCurrentHair( hairstyle : EWitcherHairstyle )
	{
		var inv : CInventoryComponent = GetInventory();
		var wasMounted : bool;
		var itemsHair : array< SItemUniqueId >;
		var i : int;
		var hairItemName : name;
		var hairId : SItemUniqueId;
		
		wasMounted = inv.GetItemByCategory( 'hair', true ) != GetInvalidUniqueId();
		
		// remove all hair items
		itemsHair = inv.GetItemsByCategory( 'hair' );
		for ( i = 0; i < itemsHair.Size(); i += 1 )
		{
			inv.RemoveItem( itemsHair[i] );
		}

		switch( hairstyle )
		{
			case WitcherHair_Default:
				hairItemName = 'default_geralt_hair';
				break;
			case WitcherHair_Dlc_01:
				hairItemName = 'dlc_geralt_hair_01';
				break;
			case WitcherHair_Dlc_02:
				hairItemName = 'dlc_geralt_hair_02';
				break;
			case WitcherHair_Dlc_03:
				hairItemName = 'dlc_geralt_hair_03';
				break;
			case WitcherHair_Dlc_04:
				hairItemName = 'dlc_geralt_hair_04';
				break;
			case WitcherHair_Dlc_05:
				hairItemName = 'dlc_geralt_hair_05';
				break;
		}
		
		hairId = inv.AddItem( hairItemName );
		if ( wasMounted )
		{
			inv.MountItem( hairId, false );
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function IsInCombatState() : bool
	{
		var playerState : EPlayerState;
		playerState = thePlayer.GetCurrentPlayerState();
		if(thePlayer.IsAlive())
		{
			if(playerState == PS_CombatSteel || playerState == PS_CombatSilver || playerState == PS_CombatFistfightDynamic)
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
	
	final function ShowFastMenu()
	{
		if ( canUseHUD && !isNotGeralt )
		{
			theHud.m_hud.ShowFastMenu();
		}
	}
	
	final function HideFastMenu()
	{
		theHud.m_hud.HideFastMenu();
	}
	
	final function TriggerMedallion()
	{
		if ( !thePlayer.IsNotGeralt() ) 
		{
			thePlayer.PlayerCombatAction(PCA_UseMedalion);
			thePlayer.UseTalismanGuide();
		}
	}
	
	event OnCSTakedown( target : CActor );
	final function TriggerKillingSpell(target : CActor)
	{
		if ( GetWitcherType( WitcherType_Magic ) )
		{
			TriggerHeliotropSign( NULL, true );
		}
		SetAdrenaline(0);
	}
	function ShowArenaPoints(points : float)
	{
		if(theGame.GetIsPlayerOnArena())
		{
			arenaPoints = points;
			AddTimer('TimerShowArenaPoints', 0.5, false);
		}
	}
	timer function TimerShowArenaPoints(td : float)
	{
		if(theGame.GetIsPlayerOnArena())
		{
			theGame.GetArenaManager().AddBonusPoints(arenaPoints);
		}
	}
	final function TriggerAdrenalineBoost()
	{
		var enemiesNotSorted : array < CActor >;
		var enemies : array < CActor >;
		var enemiesClose : array < CActor >;
		var oldSign : ESignTypes;
		var i, size : int;
		var targetPos, playerPos : Vector;
		var enemy : CActor;
		if(thePlayer.GetCurrentPlayerState() == PS_CombatSteel || thePlayer.GetCurrentPlayerState() == PS_CombatSilver)
		{
			if ( GetAdrenaline() >= 99 )
			{
				theSound.PlaySound( "gui/hud/adrenalinetriggered" );
			
				if ( GetWitcherType( WitcherType_Alchemy ) ) 
				{ 
					GetInventory().AddItem( 'AlchemyAdrenaline', 1 );
					thePlayer.UseItem( thePlayer.GetInventory().GetItemId('AlchemyAdrenaline') );
					SetAdrenaline( 0 );
				}
				if ( GetWitcherType( WitcherType_Sword ) )
				{
					
					enemy = thePlayer.GetEnemy();
					if(enemy && enemy.CanBeFinishedOff(thePlayer))
					{
						if(enemy.IsMonster())
						{
							theGame.GetCSTakedown().OnCSTakedown_1Man( enemy , true );
						}
						else
						{
							if( enemy.finisherType == 0 )//FT_None )
							{
								if ( GetWitcherType( WitcherType_Magic ) )
								{
									TriggerHeliotropSign( NULL, true );
								}
								return;
							}
							if( enemy.finisherType == 1 )//FT_Single )
							{
								if(!enemy.IsInvulnerable() && !enemy.IsImmortal() && enemy.CanBeFinishedOff(thePlayer) && enemy.CanPlayFinisherCutscene())
									enemies.PushBack( enemy );
							}
							else
							{
								enemiesNotSorted = thePlayer.FindEnemiesInCombatArea();
								
								size = enemiesNotSorted.Size();
								for( i=0; i < size; i+=1 )
								{
									if( enemiesNotSorted[i].finisherType == 2 )//FT_Multi )
									{
										if(!enemiesNotSorted[i].IsInvulnerable() && !enemiesNotSorted[i].IsImmortal() && enemiesNotSorted[i].CanBeFinishedOff(thePlayer)&&enemiesNotSorted[i].CanPlayFinisherCutscene())
										{
											targetPos = enemiesNotSorted[i].GetWorldPosition();
											playerPos = thePlayer.GetWorldPosition();
											if(AbsF( targetPos.Z - playerPos.Z ) < 2.0 && !enemiesNotSorted[i].IsMonster())
												enemies.PushBack( enemiesNotSorted[i] );
										}
									}
								}
							}
							size = enemies.Size();
							for( i=0; i < enemies.Size(); i+=1 )
							{
								enemies[i].GetBehTreeMachine().Stop();
							}
							if( size == 1 )
							{
								theGame.GetCSTakedown().OnCSTakedown_1Man(  enemies[0], true );
							}
							else if( size == 2 )
							{
								theGame.GetCSTakedown().OnCSTakedown_2Man(  enemies[0], enemies[1], true );
							}
							else if( size > 2 )
							{
								theGame.GetCSTakedown().OnCSTakedown_3Man(  enemies[0], enemies[1], enemies[2], true );
							}
							else if ( GetWitcherType( WitcherType_Magic ) )
							{
								TriggerHeliotropSign( NULL, true );
							}
						}
					}
					else if ( GetWitcherType( WitcherType_Magic ) )
					{
						TriggerHeliotropSign( NULL, true );
					}
					
				}
				else if ( GetWitcherType( WitcherType_Magic ) )
				{
					TriggerHeliotropSign( NULL, true );
				}
			}
			else if(GetAdrenaline() > 0)
			{
				theSound.PlaySound( "gui/hud/cannottriggeradrenaline" );
			}
		}
		else if(thePlayer.GetCurrentPlayerState() == PS_Exploration || thePlayer.GetCurrentPlayerState() == PS_Sneak)
		{
			thePlayer.ChangePlayerState(thePlayer.GetLastCombatStyle());
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Called by C++
	event OnItemUse( itemId : SItemUniqueId )
	{
		var inv			: CInventoryComponent	= GetInventory();
		var itemName	: name					= inv.GetItemName(  itemId );
		var itemCat		: name					= inv.GetItemCategory( itemId );
		var i			: int;
		var potionTimeBonus : float;
		
		potionTimeBonus = GetCharacterStats().GetAttribute('potions_time_bonus');
		
		if(potionTimeBonus < 1.0f)
		{
			potionTimeBonus = 1.0f;
		}
		
		Log( this + " is using item " + itemName );

		// perform any item specific stuff
		if ( itemCat == 'petard' || itemCat == 'rangedweapon' || itemCat == 'trap' || itemCat == 'lure' )
		{
			SelectThrownItem( itemId );
		}
		else if ( itemCat == 'elixir' )
		{	
			if ( IsElixirActive( itemName ) )
			{
				// update time
				for ( i = 0; i < m_activeElixirs.Size(); i += 1 )
				{
					if ( m_activeElixirs[i].m_name == itemName )
					{
						m_activeElixirs[i].m_duration = RoundF( GetInventory().GetItemAttributeAdditive( itemId, 'durration' )
							* potionTimeBonus ) ;
						m_activeElixirs[i].m_maxDuration = m_activeElixirs[i].m_duration;
						break;
					}
				}
				
				inv.RemoveItem( itemId, 1 );
			}
			else
			{
				AddElixir( itemId );
				inv.RemoveItem( itemId, 1 );
			}
		}
		/*else if ( thePlayer.GetInventory().ItemHasTag(itemId, 'Usable') ) 
		{
			AddJournalEntry( JournalGroup_Other, thePlayer.GetInventory().GetItemName( itemId ), thePlayer.GetInventory().GetItemName( itemId ) + "_entry", 'Books');
			theHud.ShowJournal();
		}*/
	}
	
	final function UpgradeItem( itemId, upgrId : SItemUniqueId ) : bool
	{
		var inv		       : CInventoryComponent = GetInventory();
		var buff	       : SBuff;
		var wasItemMounted : bool = false;
		var wasItemHeld	   : bool = false;
		
		var itemCat	: name = inv.GetItemCategory( itemId );
		var upgrCat : name = inv.GetItemCategory( upgrId );
	
		if ( itemCat != 'silversword' && itemCat != 'steelsword' && itemCat != 'armor' )
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("Only swords and armors may be upgraded!") );
			return false;
		}
		if ( ( itemCat == 'silversword' || itemCat == 'steelsword' ) && ( upgrCat != 'weaponupgrade' && upgrCat != 'rune' ) )
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("Cannot upgrade sword with this item!") );
			return false;
		}
		if ( itemCat == 'armor' && upgrCat != 'armorupgrade' )
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("Cannot upgrade armor with this item!") );
			return false;
		}
	
		if ( upgrCat == 'weaponupgrade' ) // oil
		{
			buff.m_name			= inv.GetItemName( upgrId );
			buff.m_duration		= RoundF( inv.GetItemAttributeAdditive( upgrId, 'durration' ) );
			buff.m_maxDuration	= buff.m_duration;
			buff.m_item			= itemId;
			
			wasItemMounted = inv.IsItemMounted( itemId );
			wasItemHeld = inv.IsItemHeld( itemId );
			
			if ( wasItemMounted || wasItemHeld )
			{
				inv.UnmountItem( itemId, true );
			}
			
			AddOil( upgrId, buff, itemId );
			inv.RemoveItem( upgrId, 1 );
			
			if ( wasItemMounted || wasItemHeld )
			{
				inv.MountItem( itemId, wasItemHeld ); // Assumption: ( wasItemMounted && wasItemHeld ) == false
			}
		}
		else // enhancement
		{
			if ( inv.GetItemEnhancementCount( itemId ) >= inv.GetItemEnhancementSlotsCount( itemId ) )
			{
				theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("This item has no free slots!") );
				return false;
			}
			
			wasItemMounted = inv.IsItemMounted( itemId );
			wasItemHeld = inv.IsItemHeld( itemId );
			
			if ( wasItemMounted || wasItemHeld )
			{
				inv.UnmountItem( itemId, true );
			}
			inv.EnhanceItem( itemId, upgrId );
			if ( wasItemMounted || wasItemHeld )
			{
				inv.MountItem( itemId, wasItemHeld ); // Assumption: ( wasItemMounted && wasItemHeld ) == false
			}
		}
		
		return true;
	}
	
	event OnQuestRewardItemGranted( itemId : SItemUniqueId, quantity : int )
	{
		Log( "Nagroda " + GetInventory().GetItemName( itemId ) + " w ilosci " + quantity );
	}
	
	event OnQuestItemTaken( itemId : SItemUniqueId, quantity : int )
	{
		Log( "Zabrano " + GetInventory().GetItemName( itemId ) + " w ilosci " + quantity );
	}
	
	function EquipArmor( itemId : SItemUniqueId )
	{
	}
	function CannotDeployTrap(cooldown : float)
	{
		lastTrapTime = theGame.GetEngineTime();
		trapDeployCooldown = cooldown;
	}
	function CanDeployTrap() : bool
	{
		if(theGame.GetEngineTime() > lastTrapTime + trapDeployCooldown)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function DeployTrap( itemId : SItemUniqueId )
	{
		var PlayerPosition : Vector; 
		var PlayerRotation : EulerAngles;
		var ObjectDestination : Vector;
		var trapSet : CBaseTrap;
		var dmgMinMult, dmgMaxMult : float;
		var dispPerc, dispAdd : bool;
		var minDmg, maxDmg, crtChance : float;
		
		if(!CanDeployTrap())
		{
			return;
		}
		// Compute position for trap
		PlayerPosition = GetWorldPosition();
		PlayerRotation = GetWorldRotation();
		ObjectDestination = ( ( RotForward( PlayerRotation ) ) * 1.0 ) + PlayerPosition;

		trapSet = ( CBaseTrap )GetInventory().GetDeploymentItemEntity( itemId, ObjectDestination, PlayerRotation, true );
		if( !trapSet )
		{
			Log("ERROR: DeployTrap no entity");
		}		
		else
		{
			//trapSet.ApplyAppearance( '1_trap_set' );
			trapSet.affectsWitcher = false;
			trapSet.affectsHostiles = true;
			thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(itemId, 'damage_min', minDmg, dmgMinMult, dispPerc, dispAdd);
			thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(itemId, 'damage_max', maxDmg, dmgMaxMult, dispPerc, dispAdd);
			crtChance = CalculateTrapCriticalEffectChance(itemId, trapSet.GetTrapCriticalEffect());
			trapSet.InitTrapStats(minDmg, maxDmg, crtChance);
			GetInventory().RemoveItem( itemId, 1 );	
			theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_trap") + ".</span>");
		}
	}
	
	function CalculateTrapCriticalEffectChance(item : SItemUniqueId, criticalEffectType : ECriticalEffectType) : float
	{
		var criticalEffectChance, criticalEffectChanceMult : float;
		var dispPerc, dispAdd : bool;
			if(criticalEffectType == CET_Stun)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_stun', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Poison)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_poison', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Burn)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_burn', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Freeze)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_freeze', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
		return criticalEffectChance;
	}
	
	function DeployLure( itemId : SItemUniqueId )
	{
		var nodes : array<CNode>;
		var attachedNode : CNode;
		var attachedToTrap : bool;
		var size, i : int;
		var minDist, dist : float;
		
		var lureSet : CLure;
		var objectDestination : Vector;
		var objectRotation : EulerAngles;

		theGame.GetNodesByTag('trap', nodes);
		size = nodes.Size();
		
		if( size > 0 )
		{
			attachedNode = nodes[0];
			minDist = VecLength( attachedNode.GetWorldPosition() - GetWorldPosition() );
		}
		
		for( i = 1; i < size; i += 1 )
		{
			dist = VecLength( nodes[i].GetWorldPosition() - GetWorldPosition() );
			if( dist < minDist )
			{
				minDist = dist;
				attachedNode = nodes[i];
			}
		}
		
		/*if( minDist < 1.5f && size > 0 )
		{
			attachedToTrap = true;
			objectRotation.Yaw = ((CBaseTrap)attachedNode).GetLuresAmount() * 45;
			
			if( objectRotation.Yaw <= 360 )
			{
				objectDestination = attachedNode.GetWorldPosition();
				objectRotation.Roll = 40;
			}
			else
			{
				objectRotation.Yaw = 0;
				objectDestination = ( ( RotForward( GetWorldRotation() ) ) * 1.0 ) + GetWorldPosition();
			}
		}
		else
		{
			objectDestination = ( ( RotForward( GetWorldRotation() ) ) * 1.0 ) + GetWorldPosition();
		}*/
		objectDestination = ( ( RotForward( GetWorldRotation() ) ) * 1.0 ) + GetWorldPosition();
		lureSet = ( CLure )GetInventory().GetDeploymentItemEntity( itemId, objectDestination, objectRotation );
		if( !lureSet )
		{
			Log("ERROR: DeployLure no entity");
			return;
		}
		
		if( attachedToTrap )
			((CBaseTrap)attachedNode).AttachLure( lureSet );
			
		GetInventory().RemoveItem( itemId, 1 );	
		theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_lure") + ".</span>");
	}
	
	//////////////////////////////////////////////////////////////////
	// Throwing
	
	// makes the witcher enter the aiming mode
	function AimedThrow()
	{
		ChangePlayerState( PS_AimedThrow );
	}
	
	// selects a new item to throw
	function SelectThrownItem( itemId : SItemUniqueId )
	{
		var args : array <CFlashValueScript>;
		thrownItemId = itemId;
		thrownItemName = GetInventory().GetItemName( itemId );
		UpdateThrownItemGui();
	}
	
	function ClearThrownItem()
	{
		var args : array <CFlashValueScript>;
		thrownItemId = GetInvalidUniqueId();
		thrownItemName = '';
		UpdateThrownItemGui();
	}
	
	function UpdateThrownItemGui()
	{
		var args : array <CFlashValueScript>;
		var itemCount : int = 0;
		if ( thrownItemId != GetInvalidUniqueId() )
		{
			itemCount = GetInventory().GetItemQuantity( thrownItemId );
		}
		if ( itemCount > 0 )
		{
			args.PushBack( FlashValueFromString( "img://globals/gui/icons/items/" + StrReplaceAll(thePlayer.GetInventory().GetItemName( thrownItemId ), " ", "") + "_64x64.dds" ) );
			args.PushBack( FlashValueFromString( GetLocStringByKeyExt(thePlayer.GetInventory().GetItemName( thrownItemId )) ) );
			args.PushBack( FlashValueFromInt( thePlayer.GetInventory().GetItemQuantity( thrownItemId ) ) );
		}
		else
		{
			args.PushBack( FlashValueFromString( "" ) );
			args.PushBack( FlashValueFromString( "" ) );
			args.PushBack( FlashValueFromInt( 0 ) );
		}
		theHud.InvokeManyArgs("vHUD.setItemQuickslot", args );
	}
	
	public function GetThrownItem() : SItemUniqueId
	{
		return thrownItemId;
	}
	
	///////////////////////////////////////////////////////////////////
	// Journal
	// entryType - JournalGroup_Characters, JournalGroup_Monsters, JournalGroup_Places, JournalGroup_Knowledge,
	//             JournalGroup_Other, JournalGroup_Tutorial
	// entryId - string ID for header
	// entrySubId - string ID for content
	// entryCategory - header title (any text)
	function AddJournalEntry( entryType : EJournalKnowledgeGroup, entryId : string, 
		entrySubId : string, entryCategory : string, optional entryImageName : string ) : bool
	{
		var foundIdx	: int = -1;
		var i			: int;
		var newEntry	: SJournalKnowledgeEntry;
		
		if ( entryType >= m_knowledge.m_groups.Size() )
			m_knowledge.m_groups.Resize( entryType+1 );
		
		for ( i = 0; i < m_knowledge.m_groups[ entryType ].m_entries.Size(); i += 1 )
		{
			if ( m_knowledge.m_groups[ entryType ].m_entries[ i ].m_id == entryId )
			{
				newEntry = m_knowledge.m_groups[ entryType ].m_entries[ i ];
				foundIdx = i;
				break;
			}
		}
		
		if ( foundIdx >= 0 )
		{
			if ( ! newEntry.m_subIds.Contains( entrySubId ) )
			{
				newEntry.m_subIds.PushBack( entrySubId );
				newEntry.m_isRead = false;
				
				// There is no posibility to change array element directly in script so hack it:
				//m_knowledge.m_groups[ entryType ].m_entries[ foundIdx ] = elem;
				m_knowledge.m_groups[ entryType ].m_entries.Erase( foundIdx );
				m_knowledge.m_groups[ entryType ].m_entries.Insert( foundIdx, newEntry );
			}
			else
			{
				// udpate entry image only
				if ( entryImageName != "" )
				{
					m_knowledge.m_groups[ entryType ].m_entries[ foundIdx ].m_imageUrl = "img://globals/gui/icons/journal/" + entryImageName + ".dds";
				}
			}
		}
		else
		{
			//sort by category
			for ( foundIdx = 0; foundIdx < m_knowledge.m_groups[ entryType ].m_entries.Size(); foundIdx += 1 )
			{
				if ( StrCmp( entryCategory, m_knowledge.m_groups[ entryType ].m_entries[ foundIdx ].m_category ) < 0 )
				{					
					break;
				}
			}
			newEntry.m_id		= entryId;
			newEntry.m_category	= entryCategory;
			newEntry.m_isRead	= false;
			newEntry.m_subIds.PushBack( entrySubId );
			if ( entryImageName != "" )
			{
				newEntry.m_imageUrl = "img://globals/gui/icons/journal/" + entryImageName + ".dds";
			} else
			{
				newEntry.m_imageUrl = "";
			}
			
			m_knowledge.m_groups[ entryType ].m_entries.Insert( foundIdx, newEntry );
		}
		/*
		if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
		{
			if ( entryType == JournalGroup_Characters && thePlayer.GetLevel() > 1 ) theHud.m_hud.ShowTutorial("tut132", "", false);
			//if ( entryType == JournalGroup_Characters && thePlayer.GetLevel() > 1 ) theHud.ShowTutorialPanelOld( "tut132", "" );
		}
		else
		{
			if ( entryType == JournalGroup_Characters && thePlayer.GetLevel() > 1 ) theHud.m_hud.ShowTutorial("tut32", "", false);
			//if ( entryType == JournalGroup_Characters && thePlayer.GetLevel() > 1 ) theHud.ShowTutorialPanelOld( "tut32", "" );
		}
		*/
	
		Log( "AddJournalEntry: Adding entryid " + entryId );
		//theHud.m_hud.SetTextField( 0, GetLocStringByKeyExt( "New Journal Entry Added" ), 50, 600 );
		if ( !FactsDoesExist("AddJournalEntry_entryid_" + entryId) && !FactsDoesExist("AddJournalEntry_entrysubid_" + entrySubId ) )
		{
			theHud.m_hud.setJournalEntryText( GetLocStringByKeyExt( "New Journal Entry Added" ), GetLocStringByKeyExt( entryId )  );
		}		
		if ( m_isSpawned )
		{
			//AddTimer( 'clearHudTextFieldTimer', 2.0f, false );
		}
		
		
		FactsAdd("AddJournalEntry_entryid_" + entryId );
		FactsAdd("AddJournalEntry_entrysubid_" + entrySubId );
	}	
	
	function AddTutorialEntry( tutorialTitle : string, tutorialText : string, tutorialImage : string ) : bool
	{
		var newEntry	: SJournalKnowledgeEntry;
		var i			: int;
		
		//sort by category
		for ( i = 0; i < m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries.Size(); i += 1 )
		{
			if ( StrCmp( "[[locale.jou.TUTORIAL]]", m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries[ i ].m_category ) < 0 )
			{					
				break;
			}
		}

		newEntry.m_id		= tutorialTitle;
		newEntry.m_category	= "[[locale.jou.TUTORIAL]]";
		newEntry.m_isRead	= true;
		newEntry.m_subIds.PushBack( tutorialText );
		newEntry.m_imageUrl = tutorialImage;
		
		m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries.Insert( i, newEntry );
	}	

	//New tutorial journal entries
	function AddNewTutorialEntry( 	tutorialTitle, tutorialText1, tutorialText2, tutorialText3, tutorialText4, 
									tutorialIcon1, tutorialIcon2, tutorialIcon3, tutorialIcon4, tutorialImage : string ) : bool
	{
		var newEntry	: SJournalKnowledgeEntry;
		var i			: int;
		
		//sort by category
		for ( i = 0; i < m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries.Size(); i += 1 )
		{
			if ( StrCmp( "[[locale.jou.TUTORIAL]]", m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries[ i ].m_category ) < 0 )
			{					
				break;
			}
		}
		newEntry.m_id		= tutorialTitle;
		newEntry.m_category	= "[[locale.jou.TUTORIAL]]";
		newEntry.m_isRead	= true;
		newEntry.m_textIds.PushBack( tutorialText1 );
		newEntry.m_textIds.PushBack( tutorialText2 );
		newEntry.m_textIds.PushBack( tutorialText3 );
		newEntry.m_textIds.PushBack( tutorialText4 );
		newEntry.m_iconIds.PushBack( tutorialIcon1 );
		newEntry.m_iconIds.PushBack( tutorialIcon2 );
		newEntry.m_iconIds.PushBack( tutorialIcon3 );
		newEntry.m_iconIds.PushBack( tutorialIcon4 );
		newEntry.m_imageUrl = tutorialImage;
		
		m_knowledge.m_groups[ JournalGroup_Tutorial ].m_entries.Insert( i, newEntry );
	}
	
	//////////////////////////////////////////////////
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{
		HideLootWindow();
		/* var damagePercentage : float;
		damagePercentage = 100.0 * hitParams.damage / initialHealth;

		if( damagePercentage < 5 )
		{
			this.PlaySound('Play_code_damage_geralt_small');
		}
		else if( damagePercentage < 15 )
		{
			this.PlaySound('Play_code_damage_geralt_medium');
		}
		else if( damagePercentage )
		{
			this.PlaySound('Play_code_damage_geralt_big');
		}*/
	}
	
	private function HitBlocked( out hitParams : HitParams )
	{
		if ( activeQuenSign )
		{
			if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
			{
				if ( thePlayer.GetWitcherType(WitcherType_Magic) )	thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
			}		
		}
		else
		{
			super.HitBlocked( hitParams );
		}
	}
	
	// Can respond to block (overriden in player and npc)
	function CanRespondToBlock() : bool { return true; }
	
	// Can perform responded block (overriden in player and npc)
	function CanPerformRespondedBlock() : bool { return true; }
	
	//Zagnica Hits Player // FOR ZAGNICA COMBAT ONLY //
	
	function ZgnHit( attacker : Zagnica, attackType : name, optional hitPos : Vector ) 
	{	
		var hitParams : HitParams;
		
		hitParams.attacker = attacker;
		hitParams.attackType = attackType;
		hitParams.hitPosition = hitPos;
		hitParams.impossibleToBlock = true;
		hitParams.forceHitEvent = true;
		
		if( hitParams.attackType == 'vertical' ) //HeavyHit
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.0f;
		}
		else if( hitParams.attackType == 'horizontal' && !IsDodgeing() ) //HeavyHit
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.0f;
		}
		else if( !theGame.zagnica.ArenaHolderHasHit && hitParams.attackType == 'arenaHolder' ) //HeavyHitLong
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.0f;
		}
		else if( !theGame.zagnica.ArenaHolderHasHit && hitParams.attackType == 'arenaHolderBig' ) //HeavyHitLong
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.5f;
		}
		else if( hitParams.attackType == 'thrash' )
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.0f;
		}
		else if( hitParams.attackType == 'finisher' ) //HeavyHitBack
		{
			ResetMovment();
			BreakQTE();
			hitParams.outDamageMultiplier = 2.0f;
		}
		else if( hitParams.attackType == 'roar' ) //HeavyHitLong
		{
			ResetMovment();
			hitParams.outDamageMultiplier = 1.0f;
		}
		else
		{
			return;
		}
		
		if( thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic )
		{
			hitParams.outDamageMultiplier *= 7.0f;
		}
		
		//hitParams.damage = CalculateDamage(hitParams.attacker, this, false, false, false, true, hitParams.outDamageMultiplier);
		//GetVisualDebug().AddText( 'dbgHit', "Hit damage: " + hitParams.damage , Vector(0.0, 0.0, 3.4), false, 12, Color(255, 0, 0, 255), false, 3);
		if(activeQuenSign)
		{
			hitParams.damage = CalculateDamage(hitParams.attacker, this, false, false, false, true, hitParams.outDamageMultiplier);
			activeQuenSign.QuenHit(hitParams.damage, hitParams);
		}
		HitDamage( hitParams );
	}
	
	//////////////////////////////////////////////
	
	function GetHitEnum_t2() : EPlayerCombatHit
	{
		var s : int;
		s = hitEnums_t2.Size();
		if( s == 0 )
		{
			return PCH_Hit_2a;
		}
		else
		{	
			return hitEnums_t2[Rand(s)];
		}
	}
	
	function GetHitEnum_t3() : EPlayerCombatHit
	{
		var s : int;
		s = hitEnums_t3.Size();
		if( s == 0 )
		{
			return PCH_Hit_3a;
		}
		else
		{	
			return hitEnums_t3[Rand(s)];
		}
	}
	
	private function ChooseHitEnum(hitParams : HitParams) : EPlayerCombatHit
	{
		var isFrontToSource : bool;
		
		isFrontToSource = IsRotatedTowardsPoint( hitParams.hitPosition, 90 );
		
		if( hitParams.attackType == 'Attack' )
		{
			if( isFrontToSource )
			{	
				return PCH_Hit_0;
			}
			else
			{
				return PCH_HitBack_1;
			}
		}
		
		else if( hitParams.attackType == 'Attack_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return PCH_Hit_1a;
			}
			else
			{
				return PCH_Hit_1b;
			}
		}
		else if( hitParams.attackType == 'Attack_t2' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return GetHitEnum_t2();
			}
			else  
			{
				return PCH_HitBack_2;
			}
		}
		else if( hitParams.attackType == 'Attack_t3' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return GetHitEnum_t3();
			}
			else
			{
				return PCH_HitBack_3;
			}
		}
		else if( hitParams.attackType == 'Attack_t4' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return PCH_Hit_4;
			}
			else
			{
				return PCH_HitBack_3;
			}
		}
		
		else if( hitParams.attackType == 'Attack_boss_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return PCH_HitHeavyFront;
			}
			else
			{
				return PCH_HitHeavyBack;
			}
		}
		else if( hitParams.attackType == 'FistFightAttack_t1' )
		{
			if( isFrontToSource )
			{	
				return PCH_Hit_1a;
			}
			else
			{
				return PCH_Hit_1b;
			}
		}
		else if( hitParams.attackType == 'vertical' || hitParams.attackType == 'horizontal' || hitParams.attackType == 'thrash' )
		{
			if( isFrontToSource )
			{
				return PCH_HitHeavyFront;
			}
			else
			{
				return PCH_HitHeavyBack;
			}
		}
		else if( hitParams.attackType == 'arenaHolder' || hitParams.attackType == 'arenaHolderBig' || hitParams.attackType == 'roar' )
		{
			if( isFrontToSource )
			{
				return PCH_HitHeavyFrontLong;
			}
			else
			{
				return PCH_HitHeavyBack;
			}
		}
		else if( hitParams.attackType == 'finisher' )
		{
			return PCH_HitHeavyBack;
		}
		else
			Log( "ChooseHitEvent: unknown attackType parameter." );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function CanAttackEntity( entity : CEntity ) : bool
	{
		var npc : CNewNPC;
		npc = (CNewNPC)entity;
		if( npc && npc.GetAttitude(this) != AIA_Hostile )
		{
			return false;
		}
		
		return true;
	}
	function SetCantBlock( flag : bool )
	{
		cantBlock = flag;
		if( flag )
		{
			cantBlockTime = theGame.GetEngineTime();
		}
	}
	function GetCantBlock() : bool
	{
		cantBlockCooldown = 2.0;
		
		if( theGame.GetEngineTime() < cantBlockTime +  cantBlockCooldown )
		{
			return cantBlock;
		}
		else
		{
			cantBlock = false;
			return false;
		}
	}
	function SetGuardBlock( flag : bool, updateBehaviorVariable : bool )
	{
		if( updateBehaviorVariable )
		{
			if( flag )
			{
				this.SetBehaviorVariable('guard', 1.0 );
			}
			else
			{
				this.SetBehaviorVariable('guard', 0.0 );
			}
		}
		
		guardBlock = flag;
		this.SetBlockingHit( flag, 10000000 );
	}
	function IsInGuardBlock() : bool
	{
		if( GetCantBlock() )
		{
			return false;
		}
		if(IsDodgeing())
		{
			return false;
		}
		else
		{
			return guardBlock;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function HasSilverSword() : bool
	{
		var itemId : SItemUniqueId;		
			
		itemId = GetInventory().GetItemByCategory('silversword'); 
			
		return ( itemId != GetInvalidUniqueId() );
	}
	
	function HasSteelSword() : bool
	{
		var itemId : SItemUniqueId;		

		itemId = GetInventory().GetItemByCategory('steelsword');
		
		return ( itemId != GetInvalidUniqueId() );
	}

	event OnTakedownActor( target : CActor ) { return false; }
	event OnStealthKillActor( target : CActor ) { return false; }
		
	event OnKickObject( heading : float, kickObject : CKickAbleObject );
	
	function GetKnowledgeAccumSize() : int
	{
		return m_knowledgeAccum.Size();
	}
	
	function GetKnowledgeAccum( id : int ) : SKnowledgeAccum
	{
		if ( id >= m_knowledgeAccum.Size() )
			return SKnowledgeAccum( '', 0, 0 );
		return m_knowledgeAccum[id];
	}
	
	// fill knowledge skills names
	function FillDefaultKnowledge()
	{
		var knowledgeList	: C2dArray = LoadCSV("globals/knowledge_list.csv");
		var knowledgeEntry	: SKnowledgeAccum;
		var i : int;
		
		Log( " ------------------------------------------------------ " );
		for ( i=0; i<knowledgeList.GetNumRows(); i+=1 )
		{
			knowledgeEntry.m_category	= StringToName( knowledgeList.GetValueAt(1, i) );
			knowledgeEntry.m_experience	= 0;
			knowledgeEntry.m_level		= 0;
			Log( " adding knowledge : " + knowledgeEntry.m_category );
			m_knowledgeAccum.PushBack( knowledgeEntry );
		}	
		Log( " ------------------------------------------------------ " );
	}
	// fill quest id's to track 
	function FillDefaultQuestTrack()
	{
		var list	: C2dArray = LoadCSV("globals/quest_tracking.csv");
		var str : string;
		var i : int;
		
		Log( " ------------------------------------------------------ " );
		this.m_TrackQuestIds.Clear();
		this.m_TrackQuestMax.Clear();
		for ( i=0; i<list.GetNumRows(); i+=1 )
		{
			str	= list.GetValueAt(0, i);
			Log( " adding quest id : " + str + " at index " + i + " its quest -> " + list.GetValueAt(1, i));
			m_TrackQuestIds.PushBack( str );
			m_TrackQuestMax.PushBack( StringToInt( list.GetValueAt(2, i) ) );
		}	
		Log( " ------------------------------------------------------ " );
	}
	
	
	function AddKnowledgeItemReward( categoryId  : int )
	{
		if(!theGame.GetIsPlayerOnArena())
		{
			/*if ( categoryId == 0 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // trupojady
			if ( categoryId == 1 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // trolle
			if ( categoryId == 2 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // krabopajaki*/
			if ( categoryId == 3 ) thePlayer.GetInventory().AddItem('Schematic Endriag Armor Enhancement', 1); // endriagi
			/*if ( categoryId == 4 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // nekkery
			if ( categoryId == 5 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // bulwory
			if ( categoryId == 6 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // harpie*/
			if ( categoryId == 7 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // upiory
			/*if ( categoryId == 8 ) thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap', 1); // gargulce*/
			if ( categoryId == 9) thePlayer.GetCharacterStats().AddAbility('knowledge_alchemy'); // alchemia
			if ( categoryId == 10) thePlayer.GetCharacterStats().AddAbility('knowledge_herbalism'); // herbalism
			if ( categoryId == 11) thePlayer.GetInventory().AddItem('Schematic Diamond Armor Enhancement', 1); // rzemieslnictwo
		}
	}
	
	function MaxKnowledgeAccumulator ( categoryId : int, expAmount : float )
	{
		IncreaseKnowledgeAccumulator( categoryId , expAmount );
		IncreaseKnowledgeAccumulator( categoryId , expAmount + 10 );
		IncreaseKnowledgeAccumulator( categoryId , expAmount + 20 );
	}
	
	function IncreaseKnowledgeAccumulator( categoryId : int, expAmount : float ) : bool
	{
		var knowledgeEntry	: SKnowledgeAccum;
		var entryId			: string;
		
		if ( categoryId >= 0 && categoryId < m_knowledgeAccum.Size() )
		{
			knowledgeEntry = m_knowledgeAccum[ categoryId ];

			knowledgeEntry.m_experience += expAmount; // BETA HACK docelowo /10
			
			
			if ( knowledgeEntry.m_experience > 9 )
			{
				knowledgeEntry.m_experience = 0;
				
				if ( knowledgeEntry.m_level < 3 || ( categoryId == 9 || categoryId == 10 || categoryId == 11 && knowledgeEntry.m_level < 1 ) )
				{
					if ( categoryId == 9 || categoryId == 10 || categoryId == 11 ) 
					{
						knowledgeEntry.m_level = 1;
						AddKnowledgeItemReward(categoryId);
					} else
					{
						knowledgeEntry.m_level += 1;
						if ( knowledgeEntry.m_level == 2 ) AddKnowledgeItemReward(categoryId);
					}
					
					if( !theGame.tutorialenabled )
					{
						theHud.m_hud.ShowTutorial("tut30", "", false);
						//theHud.ShowTutorialPanelOld( "tut30", "" );
					}	
	
					entryId = "Knowledge_" + (categoryId + 1);
					//AddJournalEntry( JournalGroup_Monsters, entryId, knowledgeEntry.m_level, knowledgeEntry.m_category );
					if ( !FactsDoesExist( entryId + "_" + knowledgeEntry.m_level ) )
					{
						if ( categoryId == 9 || categoryId == 10 || categoryId == 11 ) 
						{
							theHud.m_hud.setKnowledgeEntryText( GetLocStringByKeyExt( "New Knowledge Added" ), GetLocStringByKeyExt( entryId ) + " (" + knowledgeEntry.m_level + "/" + "1)" );
						}
							else
						{
							theHud.m_hud.setKnowledgeEntryText( GetLocStringByKeyExt( "New Knowledge Added" ), GetLocStringByKeyExt( entryId ) + " (" + knowledgeEntry.m_level + "/" + "3)" );
						}
						//theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_journ_16x16.dds'> " + GetLocStringByKeyExt( "New Knowledge Added" ) + ": " + GetLocStringByKeyExt( entryId ) + " (" + knowledgeEntry.m_level + "/" + "3)" );
						//AddTimer( 'clearHudTextFieldTimer', 2.0f, false );
						FactsAdd( entryId + "_" + knowledgeEntry.m_level, 1 );
					}
				}
			}
			
			m_knowledgeAccum[ categoryId ] = knowledgeEntry;
		}
	}
	
	///////////////////////////////////////////////////////////////////
	// Weapon upgrades - oils
	
	function AddOil( itemId : SItemUniqueId, buff : SBuff, usedOnItem : SItemUniqueId )
	{
		var i : int;
		var oilName : name;
		var durationBonus : float;
		
		var oils : array<SBuff>;
		buff.m_abilities.Clear();
		oils = GetActiveOils();
		for(i = 0; i < oils.Size(); i += 1)
		{
			if(oils[i].m_item == usedOnItem)
			{
				RemoveOil(i);
				theHud.m_hud.UpdateBuffs();
			}
		}
		GetInventory().GetItemAbilities( itemId, buff.m_abilities );
		GetCharacterStats().FilterAbilitiesByPrerequisites( buff.m_abilities );
		oilName = GetInventory().GetItemName( itemId );
		
		/*for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
		{
			GetCharacterStats().AddAbility( buff.m_abilities[i] );
		}*/
		durationBonus = thePlayer.GetCharacterStats().GetFinalAttribute('oils_time_bonus');
		if(durationBonus < 1)
		{
			durationBonus = 1;
		}
		buff.m_duration = buff.m_duration * durationBonus;
		m_activeOils.PushBack( buff );
		
		theHud.m_hud.UpdateBuffs();
	}
	
	private function RemoveOil( oilIndex : int )
	{
		var buff	: SBuff = m_activeOils[ oilIndex ];
		var i		: int;
		for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
		{
			GetCharacterStats().RemoveAbility( buff.m_abilities[i] );
		}
		
		if ( buff.m_name == 'Hangman Venom' ) GetInventory().StopItemEffect( buff.m_item, 'oil_hangman_venom' );
		if ( buff.m_name == 'Cinfrid Oil' ) GetInventory().StopItemEffect( buff.m_item, 'oil_cinfrid' );
		if ( buff.m_name == 'Specter Grease' ) GetInventory().StopItemEffect( buff.m_item, 'oil_specter_grease' );
		if ( buff.m_name == 'Caelm' ) GetInventory().StopItemEffect( buff.m_item, 'oil_caelm' );
		if ( buff.m_name == 'Cerbin Blath' ) GetInventory().StopItemEffect( buff.m_item, 'oil_cerbin_blath' );
		if ( buff.m_name == 'Argentia' ) GetInventory().StopItemEffect( buff.m_item, 'oil_argentia' );
		if ( buff.m_name == 'Brown Oil' ) GetInventory().StopItemEffect( buff.m_item, 'oil_brown' );
		if ( buff.m_name == 'Surge' ) GetInventory().StopItemEffect( buff.m_item, 'oil_surge' );
		
		m_activeOils.Erase( oilIndex );
	}

	final function GetActiveOils() : array< SBuff >
	{
		return m_activeOils;
	}
	
	final function GetActiveOilsForItem( itemId : SItemUniqueId, out oils : array< SBuff > )
	{
		var i : int;
		for ( i = m_activeOils.Size() - 1; i >= 0; i -= 1 )
		{
			if ( m_activeOils[ i ].m_item == itemId )
				oils.PushBack( m_activeOils[ i ] );
		}
	}
	function RemoveCriticalEffects()
	{
		var i, size : int;
		var criticalEffect : W2CriticalEffectBase;
		size = criticalEffects.Size();
		for(i = 0; i < size; i += 1)
		{
			criticalEffect = criticalEffects[i];
			criticalEffect.EndEffect();
		}
	}
	function RemoveQuen()
	{
		var quen : CWitcherSignQuen;
		quen = thePlayer.getActiveQuen();
		quen.FadeOut();
		
	}
	function RemoveAllBuffs()
	{
		RemoveQuen();
		thePlayer.RemoveAllOils();
		thePlayer.RemoveAllElixirs();
	}
	function RemoveAllOils()
	{
		var buff	: SBuff;
		var i, j, size		: int;
		
		size = m_activeOils.Size();
		for(j = 0; j < size; j += 1)
		{
			buff = m_activeOils[j];
			for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
			{
				GetCharacterStats().RemoveAbility( buff.m_abilities[i] );
			}
			
			GetInventory().StopItemEffect( buff.m_item, 'oil_hangman_venom' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_cinfrid' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_specter_grease' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_caelm' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_cerbin_blath' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_argentia' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_brown' );
			GetInventory().StopItemEffect( buff.m_item, 'oil_surge' );
		}
		m_activeOils.Clear();
		theHud.m_hud.UpdateBuffs();
	}
	function RemoveAllElixirs()
	{
		var i, j, size : int;
		var buff	: SBuff;
		
		size = m_activeElixirs.Size();
		for(i = 0; i < size; i += 1)
		{
			buff = m_activeElixirs[ i ];
			for ( j = 0; j < buff.m_abilities.Size(); j += 1 )
			{
				GetCharacterStats().RemoveAbility( buff.m_abilities[j] );
			}
			
			// Non standard effects
			if ( buff.m_name == 'Cat' )
			{
				EnableCatEffect( false );
			}
		
			thePlayer.SetToxicity( thePlayer.GetToxicity() - buff.m_toxicity );
		}
		m_activeElixirs.Clear();
		theHud.m_hud.UpdateBuffs();
	}
	///////////////////////////////////////////////////////////////////
	// Elixirs
	
	function AddElixir( itemId : SItemUniqueId )
	{
		var buff	: SBuff;
		var i		: int;
		var potionTimeBonus : float;
		
		potionTimeBonus = GetCharacterStats().GetAttribute('potions_time_bonus');
		if(potionTimeBonus < 1.0f)
		{
			potionTimeBonus = 1.0f;
		}
		
		GetInventory().GetItemAbilities( itemId, buff.m_abilities );
		GetCharacterStats().FilterAbilitiesByPrerequisites( buff.m_abilities );
		for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
		{
			GetCharacterStats().AddAbility( buff.m_abilities[i] );
		}
		
		buff.m_name			= GetInventory().GetItemName( itemId );
		buff.m_duration		= RoundF( GetInventory().GetItemAttributeAdditive( itemId, 'durration' ) * potionTimeBonus ) ;
		buff.m_maxDuration	= buff.m_duration;
		buff.m_toxicity     = RoundF( GetInventory().GetItemAttributeAdditive( itemId, 'tox_level' ) );
		
		thePlayer.SetToxicity( thePlayer.GetToxicity() + GetInventory().GetItemAttributeAdditive( itemId, 'tox_level' ) );
		
		// Non standard effects
		if ( buff.m_name == 'White Gull' )
		{
			for( i = m_activeElixirs.Size()-1 ; i >= 0 ; i -= 1 )
			{
				RemoveElixir( i );
			}
			thePlayer.SetToxicity(0);
		}
		else if ( buff.m_name == 'Cat' )
		{
			EnableCatEffect( true );
		}
	
		m_activeElixirs.PushBack( buff );
		
		theHud.m_hud.UpdateBuffs();
	}
	
	private function RemoveElixir( elixirIndex : int )
	{
		var buff	: SBuff = m_activeElixirs[ elixirIndex ];
		var i : int;
		for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
		{
			GetCharacterStats().RemoveAbility( buff.m_abilities[i] );
		}
		
		// Non standard effects
		if ( buff.m_name == 'Cat' )
		{
			EnableCatEffect( false );
		}
		
		thePlayer.SetToxicity( thePlayer.GetToxicity() - buff.m_toxicity );
		
		m_activeElixirs.Erase( elixirIndex );
		
		theHud.m_hud.UpdateBuffs();
	}
	
	final function RemoveElixirByName(elixirName : name) 
	{
	
		var elixirIndex : int;
		var buff	: SBuff;
		var i : int;
		
		elixirIndex = -1;
		for(i = 0; i < m_activeElixirs.Size(); i += 1)
		{
			if(m_activeElixirs[i].m_name == elixirName)
				elixirIndex = i;

		}
		if(elixirIndex != -1)
		{
			buff = m_activeElixirs[ elixirIndex ];
			
			for ( i = 0; i < buff.m_abilities.Size(); i += 1 )
			{
				GetCharacterStats().RemoveAbility( buff.m_abilities[i] );
			}
			
			// Non standard effects
			if ( buff.m_name == 'Cat' )
			{
				EnableCatEffect( false );
			}
			
			thePlayer.SetToxicity( thePlayer.GetToxicity() - buff.m_toxicity );
			
			m_activeElixirs.Erase( elixirIndex );
			
			theHud.m_hud.UpdateBuffs();
		}
	
	}
	
	final function GetActiveElixirs() : array< SBuff >
	{
		return m_activeElixirs;
	}
	
	final function IsElixirActive( itemName : name ) : bool // check if there is active elixir effect on player right now
	{
		var i : int;
		for( i = 0; i < m_activeElixirs.Size(); i += 1 )
		{
			if ( m_activeElixirs[i].m_name == itemName )
			{
				return true;
			}
		}
		return false;
	}
	
	final function ReapplyElixirs()
	{
		var i,s : int = m_activeElixirs.Size();
		SetToxicity( toxicity, true );
		theHud.m_hud.UpdateBuffs();
		for( i=0; i<s; i+=1 )
		{
			if( m_activeElixirs[i].m_name == 'Cat' )
			{
				EnableCatEffect(true);
			}
		}
	}
	
	///////////////////////////////////////////////////////////////////
	// Buffs
	
	event OnCriticalEffectsChanged() { theHud.m_hud.UpdateBuffs(); }
	
	timer function TimerBuffs( timeDelta : float )
	{
		ApplyTimerBuffs( timeDelta );
	}
	
	function ApplyTimerBuffs( timeDelta : float )
	{
		var i,s : int;
		
		var guiNeedsFullUpdate	: bool = false;
		var hasBuffs			: bool = false;
		var AS_buffTimesArray	: int  = theHud.CreateAnonymousArray();
		
		// OILS
		s = m_activeOils.Size();
		for ( i = s - 1; i >= 0; i -= 1 ) // countdown so RemoveOil() will work
		{
			m_activeOils[i].m_duration = m_activeOils[i].m_duration - timeDelta;
			
			if ( m_activeOils[i].m_duration < 0 )
			{
				RemoveOil( i );
				guiNeedsFullUpdate = true;
			}
			else
			{
				hasBuffs = true;
			}
		}
		s = m_activeOils.Size();
		for ( i = 0; i < s; i += 1 ) // update timers and effects (the ascending order is the key to success)
		{
			theHud.PushFloat( AS_buffTimesArray, ( 100.f * m_activeOils[i].m_duration ) / m_activeOils[i].m_maxDuration );
			theHud.PushFloat( AS_buffTimesArray, m_activeOils[i].m_duration );
			
			if ( m_activeOils[i].m_name == 'Hangman Venom' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_hangman_venom' );
			if ( m_activeOils[i].m_name == 'Cinfrid Oil' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_cinfrid' );
			if ( m_activeOils[i].m_name == 'Specter Grease' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_specter_grease' );
			if ( m_activeOils[i].m_name == 'Caelm' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_caelm' );
			if ( m_activeOils[i].m_name == 'Cerbin Blath' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_cerbin_blath' );
			if ( m_activeOils[i].m_name == 'Argentia' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_argentia' );
			if ( m_activeOils[i].m_name == 'Brown Oil' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_brown' );
			if ( m_activeOils[i].m_name == 'Surge' ) GetInventory().PlayItemEffect( m_activeOils[i].m_item, 'oil_surge' );
			
		}

		// ELIXIRS
		s = m_activeElixirs.Size();
		// Update timers
		for ( i = s - 1; i >= 0; i -= 1 ) // countdown so RemoveOil() will work
		{
			m_activeElixirs[i].m_duration = m_activeElixirs[i].m_duration - timeDelta;
			//LogChannel( 'elixirs', "i = " + i + " duration: " + m_activeElixirs[i].m_duration + " dur percent: " + ( 100.f * m_activeElixirs[i].m_duration ) / m_activeElixirs[i].m_maxDuration );
			
			if ( m_activeElixirs[i].m_duration < 0 )
			{	
				RemoveElixir( i );
				guiNeedsFullUpdate = true;
			}
			else
			{
				hasBuffs = true;
			}
		}
		s = m_activeElixirs.Size();
		for ( i = 0; i < s; i += 1 ) // update timers (the ascending order is the key to success)
		{
			theHud.PushFloat( AS_buffTimesArray, ( 100.f * m_activeElixirs[i].m_duration ) / m_activeElixirs[i].m_maxDuration );
			theHud.PushFloat( AS_buffTimesArray, m_activeElixirs[i].m_duration );
		}
		
		// Pass critical effects
		s = criticalEffects.Size();
		for ( i = 0; i < s; i += 1 )
		{
			hasBuffs = true;
			theHud.PushFloat( AS_buffTimesArray, ( 100.f * criticalEffects[i].GetTTL() ) / criticalEffects[i].GetDuration() );
			theHud.PushFloat( AS_buffTimesArray, criticalEffects[i].GetTTL() );
		}
		
		if ( activeQuenSign )
		{
			hasBuffs = true;
			theHud.PushFloat( AS_buffTimesArray, ( 100.f * activeQuenSign.GetTTL() ) / activeQuenSign.GetTotalDuration() );
			theHud.PushFloat( AS_buffTimesArray, activeQuenSign.GetTTL() );
		}
		
		if ( guiNeedsFullUpdate )
		{
			theHud.m_hud.UpdateBuffs();
		}
		else
		if ( hasBuffs )
		{
			theHud.m_hud.UpdateBuffsTimes( AS_buffTimesArray );
		}
		
		theHud.ForgetObject( AS_buffTimesArray );
	}

	function CanUseHud() : bool
	{
		return canUseHUD && !isNotGeralt;// && !IsInCombat();
	}
	
		function StopAdrenalineBuff(duration : float)
	{
		SetAdrenalineBuffFlag( true );
		AddTimer('StopAdrenalineEffect', duration);
	}
	
	timer function StopAdrenalineEffect( duration : float )
	{
		buff_adrenaline_end();
	}
	
	function SetAdrenalineBuffFlag( flag : bool )
	{
		if( flag)
		{
			canDisableBerserk = true;
		}
		else
		{
			canDisableBerserk = false;
		}
	}
	
	function CanDisableAdrenalineBuff() : bool
	{
		return canDisableBerserk;
	}
	
	
	event OnReplacerEnabled( enabled : bool, appearance : name )
	{
		var i, size : int;
		var items : array <SItemUniqueId>;
		
		isNotGeralt = enabled;
		isAssasinReplacer = false;
		
		if( enabled )
		{
			
thePlayer.RemoveAllBuffs();
		}

		// HUD
		theHud.SetItemSlotsVisibility( !enabled );
		
		if ( appearance != 'default' )
		{
			thePlayer.SaveEquip();
			
			thePlayer.GetInventory().UnmountItem ( thePlayer.GetInventory().GetItemByCategory( 'hair', true ), true ); //HACK
			thePlayer.GetInventory().UnmountItem ( thePlayer.GetInventory().GetItemByCategory( 'geralt_tatoo', true ), true ); 
			
			thePlayer.GetInventory().UnmountItem ( thePlayer.GetInventory().GetItemByCategory( 'steelsword' ) );
			thePlayer.GetInventory().UnmountItem ( thePlayer.GetInventory().GetItemByCategory( 'silversword' ) );
			
			theCamera.StopEffect('dark_difficulty');		
			
			if ( appearance == 'stennis' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Stennis');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Stennis') );
			}
			if ( appearance == 'roche_replacer' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Roche_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H') );
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Roche_1H2');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H2') );
				thePlayer.GetInventory().UnmountItem ( thePlayer.GetInventory().GetItemByCategory( 'silversword' ) );
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Roche_2H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_2H') );
			}
			if ( appearance == 'dandelion' )
			{
				thePlayer.GetInventory().AddItem( 'Lute 01' );
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Lute 01') );
			}
			if ( appearance == 'aedrin_knight_replacer' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Aedirn_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Aedirn_1H') );
			}
			if ( appearance == 'iorweth' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Iorweth_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H') );
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Iorweth_Bow');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_Bow') );
				//thePlayer.GetInventory().AddItem( 'Replacer_Sword_Iorweth_1H2');
				//thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H2') ); NIE MA ANIMACJI WYCIAGANIA WIEC WYWALAM NARAZIE
			}
			if ( appearance == 'egan' )
			{
				//thePlayer.GetInventory().AddItem( 'Replacer_Sword_Priest_2H');
				//thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_2H') );
				//thePlayer.GetInventory().AddItem( 'Replacer_Sword_Priest_1H');
				//thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_1H') );
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Egan_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Egan_1H') );
				isAssasinReplacer = true;
			}
			if ( appearance == 'henselt_replacer' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Henselt_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Henselt_1H') );
			}
			if ( appearance == 'kaedwen_guard_replacer' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Kaedwen_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Kaedwen_1H') );
			}
			if ( appearance == 'seltkirk_replacer' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Seltkirk_1H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Seltkirk_1H') );
			}
			if ( appearance == 'priest__replace' )
			{
				thePlayer.GetInventory().AddItem( 'Replacer_Sword_Priest_2H');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_2H') );
			}
			
			theCamera.StopEffect('dark_difficulty');		
			
		} else
		{
			if ( thePlayer.IsDarkSet() ) theCamera.PlayEffect('dark_difficulty');		
			
			if ( FactsDoesExist("sq102_got_tatoo") ) thePlayer.GetInventory().MountItem ( thePlayer.GetInventory().GetItemByCategory( 'geralt_tatoo', true ) ); 
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Lute 01'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Lute 01') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_2H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_2H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Kaedwen_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Kaedwen_1H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Seltkirk_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Seltkirk_1H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Priest_1H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Egan_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Egan_1H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Henselt_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Henselt_1H') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Aedirn_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Aedirn_1H') );

			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Stennis'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Stennis') );
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H') );
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_Bow'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_Bow') );
			//thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H2'), true );
			//thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Iorweth_1H2') );
			
			
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H') );
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H2'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_1H2') );
			thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_2H'), true );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Replacer_Sword_Roche_2H') );
			
			thePlayer.GetInventory().MountItem ( thePlayer.GetInventory().GetItemByCategory( 'steelsword', false, true ) );
			thePlayer.GetInventory().MountItem ( thePlayer.GetInventory().GetItemByCategory( 'silversword', false, true ) );
			
			items = thePlayer.GetInventory().GetItemsByTag('ReplacerItem');
			size = items.Size();
			
			for(i = 0; i < size; i += 1)
			{
				thePlayer.GetInventory().UnmountItem(items[i]);
				thePlayer.GetInventory().RemoveItem(items[i]);
			}
			
			thePlayer.GetInventory().MountItem ( thePlayer.GetInventory().GetItemByCategory( 'hair', false ) ); //HACK
			thePlayer.RestoreEquip();

		}
		
	}
	
	function IsNotGeralt() : bool
	{
		return isNotGeralt;
	}
	
	function SetCanUseHud( val : bool )
	{
		canUseHUD = val;
	}
	
	function SetIsNotGeralt( val : bool )
	{
		isNotGeralt = val;
	}
	function IsAssasinReplacer() : bool
	{
		return isAssasinReplacer;
	}
	function SetIsAssasinReplacer( val : bool )
	{
		isAssasinReplacer = val;
	}
	event OnActorKilled( actor : CActor )
	{
		CalculateGainedExperienceAfterKill(actor, true, true, false);		
		IncreaseKnowledgeAccumulator( actor.knowledge.knowledgeId - 1, actor.knowledge.knowledgeAmount );
		if ( actor.killingCauseGuardDialog )
		{
			FactsAdd( "gameplay_catch_by_guard", 1 );
		}
	}
	
	event OnActorStunned( actor : CActor )
	{
		CalculateGainedExperienceAfterKill(actor, true, true, true);
	}
	event OnArenaResurect();
	event OnResurect();
	
	function GetRandomDecalMaterial() : IMaterial
	{
		var s : int = decalMaterials.Size();
		if( s > 0 )
		{
			return decalMaterials[ Rand( s ) ];
		}
		
		return NULL;
	}
	
	latent function WarpToAnimSlotPosition( actor : CActor, anim : name, time : float )
	{
		var slots : array< Matrix >;
		var posPlayer, posActor : Vector;
		var rotPlayer, rotActor : EulerAngles;
		
		if( GetAnimCombatSlots( anim, slots, 3, 1, GetLocalToWorld(), 2, actor.GetLocalToWorld() ) )
		{			
			posPlayer = MatrixGetTranslation( slots[1] );
			rotPlayer = MatrixGetRotation( slots[1] );
			
			posActor = MatrixGetTranslation( slots[2] );
			rotActor = MatrixGetRotation( slots[2] );		
			
			//GetVisualDebug().AddSphere( 'tdPlayer', 0.5f, posPlayer, true, Color(255,0,0) );
			//parent.GetVisualDebug().AddSphere( 'tdRoot', 0.5f, posRoot, true, Color(0,0,255) );
			//GetVisualDebug().AddSphere( 'tdEnemy', 0.5f, posNPC, true, Color(0,255,0) );
			
			if( time < 0.01 )
			{
				actor.TeleportWithRotation( posActor, rotActor );
				TeleportWithRotation( posPlayer, rotPlayer );												
			}
			else
			{				
				actor.ActionSlideToWithHeadingAsync( posActor, rotActor.Yaw, time );
				ActionSlideToWithHeading( posPlayer, rotPlayer.Yaw, time );
			}
		}	
	}
	
	event OnCheckPlayerCarryJoined()
	{
		return false;
	}
	
	event OnManualCarryStopRequest();
	
		
	///////////////////////////////////////////////////////////////////
	// Quest events
	///////////////////////////////////////////////////////////////////
	event OnQuestSuccessEntry()
	{
	}
	
	event OnQuestSuccessPhase()
	{
	}
	
	event OnQuestFailEntry()
	{
	}

	event OnQuestFailPhase()
	{
	}
	function DeselectAllAttacked(enemies : array<CActor>)
	{
		var i, size : int;
		
		size = enemies.Size();
		
		for(i = 0; i < size; i += 1)
		{
			enemies[i].SetLastAttackedByPlayer(false);
		}
	}
	function DeselectAllEnemies(enemies : array<CActor>)
	{
		var i, size : int;
		
		size = enemies.Size();
		
		for(i = 0; i < size; i += 1)
		{
			enemies[i].SetLastSelectedInCombat(false);
		}
	}
	
	event OnShowQuestInfo( questInfoType : int )
	{
		switch( questInfoType )
		{
			case QLPS_Active:
				theSound.PlaySound( "gui/hud/questupdate" );
				break;
			case QLPS_Success:
				theSound.PlaySound( "gui/hud/questfinished" );
				break;
			case QLPS_Failed:
				theSound.PlaySound( "gui/hud/questfailed" );
				break;
		}
	}
	
	///////////////////////////////////////////////////////////////////
	// Combat slots management
	///////////////////////////////////////////////////////////////////
	timer function TicketPoolTimer( timeDelta : float )
	{
		var i, count : int;
		count = ticketPools.Size();
		
		for ( i = 0; i < count; i += 1 )
		{
			ticketPools[ i ].UpdateAgents();
		}
	}
	

	function GetTicketPool( poolType : W2TicketPoolType ) : W2TicketPool
	{	
		var maxTickets : int;
		
		if(theGame.GetDifficultyLevel() >= 2)
		{
			maxTickets = 5;
		}
		else if(theGame.GetDifficultyLevel() == 1)
		{
			maxTickets = 3;
		}
		else
		{
			maxTickets = 2;
		}
		
		if( ticketPools.Size() == 0 )
		{	
			ticketPools.Grow(1);
			
			ticketPools[ TPT_Attack ] = new W2TicketPool in this;
			ticketPools[ TPT_Attack ].Init( TPT_Attack, maxTickets );
			
			//ticketPools[ TPT_SecondaryAttack ] = new W2TicketPool in this;
			//ticketPools[ TPT_SecondaryAttack ].Init( TPT_SecondaryAttack, 3 );
		}
		
		return ticketPools[ poolType ];
	}
	///////////////////////////////////////////////////////////////////
	// Combat Actions
	///////////////////////////////////////////////////////////////////
	function GetPlayerEvadeType() : EPlayerEvadeType
	{
		if(thePlayer.GetCharacterStats().HasAbility('sword_s3_2'))
		{
			evadeType = PET_Long;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('sword_s3'))
		{
			evadeType = PET_Medium;
		}
		else
		{
			evadeType = PET_Short;
		}
		return evadeType;
	}

	final function SetPlayerEvadeType(evade : EPlayerEvadeType)
	{
		var evadeInt : int;
		evadeInt = (int)evade;
		SetBehaviorVariable("PlayerEvadeType", (float)evadeInt);
	}


	final function SetPlayerCombatStance(stance : EPlayerCombatStance)
	{
		var stanceInt : int;
		combatStance = stance;
		stanceInt = (int)stance;
		if(stance == PCS_High)
		{
			SetPlayerCombatStanceCooldown();
		}
		else
		{
			m_lowStanceCooldown = 0.0;
		}
		SetBehaviorVariable("StanceEnum", (float)stanceInt);
	}
	final function GetPlayerCombatStance() : EPlayerCombatStance
	{
		return combatStance;
	}
	final function SetPlayerCombatStanceCooldown()
	{
		m_lowStanceCooldown = 15.0;
	}
	final function PlayerCombatAction(action : EPlayerCombatAction) : bool
	{
		var actionInt : int;
		var result : bool;
		
		actionInt = (int)action;
		SetBehaviorVariable("CombatActionEnum", (float)actionInt);
		result = this.RaiseForceEvent('CombatAction');
		if ( result )
		{
				RegisterActiveAction( 'CombatActionEnd' );
		}
		return result;
	}
	final function PlayerActionForced(action : EPlayerCombatAction) : bool
	{
		var actionInt : int;
		var result : bool;
		actionInt = (int)action;
		SetBehaviorVariable("CombatActionEnum", (float)actionInt);
		result = this.RaiseForceEvent('ActionForced');
		return result;
	}
	final function PlayerCombatHit(hitEnum : EPlayerCombatHit) : bool
	{
		var hitInt : int;
		var result : bool;
		if(!thePlayer.GetIsCastingAxii())
		{
			hitInt = (int)hitEnum;
			SetBehaviorVariable("CombatHitEnum", (float)hitInt);
			result = this.RaiseForceEvent('CombatHit');
			if ( result )
			{
				RegisterActiveAction( 'CombatHitEnd' );
			}
		}
		
		return result;
	}
	final function PlayerCombatHitForced(hitEnum : EPlayerCombatHit) : bool
	{
		var hitInt : int;
		var result : bool;
		if(!thePlayer.GetIsCastingAxii())
		{
			hitInt = (int)hitEnum;
			SetBehaviorVariable("CombatHitEnum", (float)hitInt);
			result = this.RaiseForceEvent('CombatHitForced');
			if ( result )
			{
				RegisterActiveAction( 'CombatHitEnd' );
			}
		}
		return result;
	}		
	final function PlayerActionUnbreakable(action : EPlayerActionUnbreakable) : bool
	{
		var actionInt : int;
		var result : bool;
		actionInt = (int)action;
		SetBehaviorVariable("ActionUnbreakableEnum", (float)actionInt);
		result = this.RaiseForceEvent('ActionUnbreakable');
		if ( result )
		{
			if(action == PAU_Evade)
			ActivateDodging();
			RegisterActiveAction( 'UnbreakableActionEnd' );
		}
		return result;
	}
	final function PlayerActionUnbreakableForced(action : EPlayerActionUnbreakable) : bool
	{
		var actionInt : int;
		var result : bool;
		actionInt = (int)action;
		SetBehaviorVariable("ActionUnbreakableEnum", (float)actionInt);
		result = this.RaiseForceEvent('ActionUnbreakableFroced');
		if(action == PAU_Evade)
			ActivateDodging();
		return result;
	}
	
	final function RegisterActiveAction( deactivationNotification : name )
	{
		m_pendingBehaviorDeactivation = deactivationNotification;
		AddTimer( 'ActionDeactivation', 0.0f, false );
		Log( "Registered action deactivation: " + m_pendingBehaviorDeactivation );
	}
	
	final function GetPendingBehaviorDeact() : name
	{
		return m_pendingBehaviorDeactivation;
	}
	
	final function IsActionActive() : bool
	{
		if ( m_pendingBehaviorDeactivation != 'None' )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	timer function ActionDeactivation( timeDelta : float )
	{
		if ( m_pendingBehaviorDeactivation )
		{
			if ( !BehaviorNodeDeactivationNotificationReceived( m_pendingBehaviorDeactivation ) )
			{
				// Not yet received, start timer again
				AddTimer( 'ActionDeactivation', 0.0f, false );
			}
			else
			{
				// Received, clear pending deactivation field
				Log( "Unregistering action: " + m_pendingBehaviorDeactivation );
				m_pendingBehaviorDeactivation = 'None';
			}
		}
		else
		{
			Log( "ActionDeactivation timer triggered without pending behavior deactivation" );
		}
	}
	
	///////////////////////////////////////////////////////////////////
	// Finishers
	///////////////////////////////////////////////////////////////////
	public function IsFinisherEnabled( enemy : CActor ) : bool
	{
		var npc : CActor;
		var currStateName : name;
		
		npc = (CNewNPC)enemy;
		
		if ( !npc ) return false;
		
		currStateName = npc.GetCurrentStateName();

		if ( currStateName == 'Falter' || currStateName == 'Stun' )
		{
			return true;
		}

		return false;
	}

	public function DoFinisher( enemy : CActor ) : bool
	{
		var npc : CActor;
		var currStateName : name;
		var takedownParams : STakedownParams;
		
		npc = (CNewNPC)enemy;
		
		if ( !npc ) return false;
		
		currStateName = npc.GetCurrentStateName();

		if ( currStateName == 'Falter' )
		{
			// TODO
			//SetupTakedownParamsDefault( enemy, takedownParams );
			//ChangePlayerState( PS_CombatTakedown );
			return true;
		}
		else if ( currStateName == 'Stun' )
		{
			// TODO
			return true;
		}
		
		return false;
	}

	//////////////////////////////////////////////////////////////////////////////
	// Update visual debug information
	//////////////////////////////////////////////////////////////////////////////
	function UpdateVisualDebug()
	{	
		var vd : CVisualDebug;
		var pos : Vector;				
		var displayMode : name;
		var i,s : int;
		var str : string;
		vd = GetVisualDebug();
		pos = GetVisualDebugPos();		

		super.UpdateVisualDebug();				
		
		displayMode = theGame.aiInfoDisplayMode ;
		
		if( displayMode == 'all' || displayMode == 'player' )
		{	
			s = blockedStates.Size();
			if( s > 0 || blockedAllStates )
			{	
				if( blockedAllStates )
				{
					str+="ALL, ";
				}
			
				for( i=0; i<s; i+=1 )
				{
					str += blockedStates[i];
					str += ", ";
				}
				
				vd.AddText( 'dbgBlocked', "Blockes states: "+str, pos, false, 13, Color(255,128,0), false, 1.0 );
			}	
		
			GetCombatSlots().UpdateVisualDebug(vd);
			s = ticketPools.Size();
			for( i=0; i<s; i+=1 )
			{
				ticketPools[i].UpdateVisualDebug( vd );
			}
			
			OnUpdateVisualDebug();

			if( currentTakedownArea )			
				vd.AddText('dbgTakedownArea', "In takedown area", pos, true, 14, GetVisualDebugColor(), false, 1.0 );			
			else
				vd.RemoveText('dbgTakedownArea');
		}
	}
	
	event OnUpdateVisualDebug();
	
	function GetVisualDebugColor() : Color
	{
		return Color(255, 255, 128);
	}
	function GetSparksName(row : int) : name
	{
		if(soundMaterials && row != -1)
			return StringToName(soundMaterials.GetValue("SparksFXName", row));
	}
	function GetSparks() : CEntityTemplate
	{
		return sparks;
	}
	function HideNearbyEnemies(position : Vector, range : float, playerTargets : array<CActor>)
	{
		var enemiesClose : array < CActor >;
		var i, size : int;
		var boundMin, boundMax : Vector;
		var npc : CNewNPC;
		boundMin = Vector(-range, -range, 0);
		boundMax = Vector(range, range, 0);
		ActorsStorageGetClosestByPos(position, enemiesClose, boundMin, boundMax, thePlayer, false, true);
		size = playerTargets.Size();
		for(i = 0; i < size; i += 1)
		{
			if(enemiesClose.Contains(playerTargets[i]))
				enemiesClose.Remove(playerTargets[i]);
		}
		size = enemiesClose.Size();
		for(i = 0; i < size; i += 1)
		{
			npc = (CNewNPC)enemiesClose[i];
			if(npc && npc.GetAttitude(thePlayer) == AIA_Hostile)
			{
				enemiesClose[i].ActionCancelAll();
				enemiesClose[i].GetBehTreeMachine().Stop();
			}
			enemiesClose[i].SetHideInGame(true);
		}
	}
	function ShowNearbyEnemies(position : Vector, range : float)
	{
		var enemiesClose : array < CActor >;
		var i, size : int;
		var npc : CNewNPC;
		var boundMin, boundMax : Vector;
		boundMin = Vector(-range, -range, 0);
		boundMax = Vector(range, range, 0);
		ActorsStorageGetClosestByPos(position, enemiesClose, boundMin, boundMax, thePlayer, false, true);
		size = enemiesClose.Size();
		for(i = 0; i < size; i += 1)
		{
			npc = (CNewNPC)enemiesClose[i];
			if(npc && npc.GetAttitude(thePlayer) == AIA_Hostile)
			{
				enemiesClose[i].GetBehTreeMachine().Restart();
			}
			enemiesClose[i].SetHideInGame(false);
		}
	}
	final function PlayerCanPlayCommentary() : bool
	{
		var time : EngineTime;
		time = commentaryLastTime + commentaryCooldown;
		if(theGame.GetEngineTime() > time)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	final function PlayerCanPlayMonsterCommentary() : bool
	{
		var time : EngineTime;
		var commentaryMonsterCooldown : float;
		commentaryMonsterCooldown = 120.0f;
		time = commentaryLastTime + commentaryMonsterCooldown;
		if(theGame.GetEngineTime() > time)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	final function PlayerCommentary(commentaryType : EPlayerCommentary, optional newCommentaryCooldown : float)
	{
		commentaryLastTime = theGame.GetEngineTime();
		if(newCommentaryCooldown > 0.0f)
		{
			commentaryCooldown = newCommentaryCooldown;
		}
		else
		{
			commentaryCooldown = 20.0;
		}
		if(commentaryType == PC_MedalionWarning && !thePlayer.IsNotGeralt())
		{
			theHud.Invoke("vHUD.blinkMed");
			PlayVoiceset(1, "witcher_medalion_oneliners");
			theSound.PlaySound( "gui/hud/medalionwarning" );
		}
		else if(commentaryType == PC_MonsterReaction && !thePlayer.IsNotGeralt())
		{
			PlayVoiceset(1, "witcher_alone_enemies_oneliners");
		}
		else if(commentaryType == PC_ToTeamNearEnemies && !thePlayer.IsNotGeralt())
		{
			PlayVoiceset(1, "witcher_team_enemies_oneliners");
		}
		else if(commentaryType == PC_ToTeamNearEnemiesWhisper && !thePlayer.IsNotGeralt())
		{
			PlayVoiceset(1, "witcher_team_hush_oneliners");
		}
		
	}
	///////////////////////////////////////////////////////////////////
	// Picie woody

	timer function DrunkTimer( timerDelta : float )
	{
		drunkTimer = RandRangeF(0.5, 1.0);
		if (drunkTimer > 1) drunkTimer = 0.5;
		//RadialBlurSetup( this.GetWorldPosition(), drunkTimer, drunkTimer, drunkTimer, drunkTimer );
		theCamera.ChangeState('CS_Drunk');
	}
	timer function DrunkTimerRemove( timerDelta : float )
	{
		theCamera.SetCameraPermamentShake(CShakeState_Invalid, 0.0);
		thePlayer.StopEffect('drunk_fx');
	}

	///////////////////////////////////////////////////////////////////
	// Quest track stuff here
	
	function IsQuestTrackId( id : string ) : bool
	{
		var isAny : bool = false;
		var i : int;
		
		for( i=0; i< m_TrackQuestIds.Size(); i+=1 )
		{
			if ( m_TrackQuestIds[i] ==  id ) isAny = true;
		}		
		
		return isAny;
	}
	function GetQuestTrackIdIndex( id : string ) : int
	{
		var index : int = -1;
		var i : int;
		
		for( i=0; i< m_TrackQuestIds.Size(); i+=1 )
		{
			if ( m_TrackQuestIds[i] ==  id ) index = i;
		}		
		
		return index;
	}	
	function GetQuestTrackIdNumber() : int
	{
		return m_TrackQuestIds.Size();
	}	
	function GetQuestTrackId( id : int) : string
	{
		return m_TrackQuestIds[id];
	}		
	function GetQuestTrackMax( id : int) : int
	{
		return m_TrackQuestMax[id];
	}			
	
	// ---------------------------------
	// Clear player's build logic
	
	function ClearBuild()
	{
		var i : int;
		var itemName : name;
			for( i=1; i<7; i+=1 )
			{
				itemName = StringToName("training_s" + i );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
				itemName = StringToName("training_s" + i + "_2" );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
			}
			for( i=1; i<16; i+=1 )
			{
				itemName = StringToName("sword_s" + i );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
				itemName = StringToName("sword_s" + i + "_2" );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
			}
			for( i=1; i<16; i+=1 )
			{
				itemName = StringToName("alchemy_s" + i );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
				itemName = StringToName("alchemy_s" + i + "_2" );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
			}
			for( i=1; i<16; i+=1 )
			{
				itemName = StringToName("magic_s" + i );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
				itemName = StringToName("magic_s" + i + "_2" );
				if ( thePlayer.GetCharacterStats().HasAbility(itemName) ) thePlayer.GetCharacterStats().RemoveAbility(itemName);
			}
		talents = level - 1;
	}	
	function AllowCombatRotation(flag : bool)
	{
		if(!flag)
		{
			cantRotateTime = theGame.GetEngineTime();
			cantRotateTimeOut = 1.5;
		}
		combatRotationAllowed = flag;
	}
	function IsCombatRotationAllowed() : bool
	{
		if(theGame.GetEngineTime() > cantRotateTime + cantRotateTimeOut)
		{
			combatRotationAllowed = true;
		}
		return combatRotationAllowed;
	}
	function RevivePlayer()
	{
		var i, size : int;
		var abilities : array<name>;
		
		/*thePlayer.GetCharacterStats().GetAbilities(abilities);
		
		size = abilities.Size();
		for( i = 0; i < size; i += 1)
		{
			thePlayer.GetCharacterStats().RemoveAbility(abilities[i]);
		}
		thePlayer.SetBasicAbility();
		thePlayer.SetLevel(1);
		talents = 0;
		*/
		thePlayer.SetAlive( true );
		thePlayer.SetInitialHealth(thePlayer.GetCharacterStats().GetAttribute('vitality'));
		thePlayer.SetInitialStamina(thePlayer.GetCharacterStats().GetAttribute('endurance'));
		
		thePlayer.SetHealth(thePlayer.GetInitialHealth(), false, NULL);
		thePlayer.SetAllPlayerStatesBlocked( false );
		thePlayer.PlayerStateCallEntryFunction(PS_Exploration, '' );
		//parent.ChangePlayerState(PS_Exploration);
		thePlayer.ResetPlayerCamera();
		thePlayer.ResetPlayerMovement();
		thePlayer.RaiseForceEvent('Idle');	
		theGame.EnableButtonInteractions(true);
		thePlayer.RemoveAllBuffs();
		thePlayer.RemoveCriticalEffects();
		thePlayer.SetAdrenaline(0.0f);
		
		
	}
	// Player Import methods
	event OnImportSkills( skillList : array< string > )
	{
		var size, i : int;
		var skill : string;
		var wariorSkills, mageSkills, alchemistSkills : int;

		size = skillList.Size();
	
		Log( "Processing imported skills - " + size );
		
		wariorSkills = 0;
		mageSkills = 0;
		alchemistSkills = 0;
		
		for ( i = 0; i < size; i += 1 )
		{
			skill = skillList[ i ];
			
			if ( StrBeginsWith( skill, "Strength" ) || StrBeginsWith( skill, "Style" ) )
			{
				wariorSkills = wariorSkills + 1;
			}
			
			if ( StrBeginsWith( skill, "Inteligence" ) || StrBeginsWith( skill, "Aard" ) || StrBeginsWith( skill, "Igni" )|| StrBeginsWith( skill, "Quen" ) || StrBeginsWith( skill, "Yrden" ) || StrBeginsWith( skill, "Axii" ) )
			{
				mageSkills = mageSkills + 1;
			}
			
			if ( StrBeginsWith( skill, "Endurance" ) || StrBeginsWith( skill, "Dexterity" ) )
			{
				alchemistSkills = alchemistSkills + 1;
			}
		}
		
		if ( wariorSkills > mageSkills && wariorSkills > alchemistSkills )
		{
			Log( "Importing warior character" );
			FactsAdd( 'import_char_warior', 1 );
		}
		if ( mageSkills > wariorSkills && mageSkills > alchemistSkills )
		{
			Log( "Importing mage character" );
			FactsAdd( 'import_char_mage', 1 );
		}
		if ( alchemistSkills > mageSkills && alchemistSkills > wariorSkills )
		{
			Log( "Importing alchemist character" );
			FactsAdd( 'import_char_alchemist', 1 );
		}
	}
	
	event OnImportItems( itemList : array< string >, gold : int )
	{
		var size, i : int;
		var item : string;
	
		size = itemList.Size();
		Log( "Processing imported items - " + size );
		
		thePlayer.GetInventory().AddItem( 'Orens', RoundF( gold / 100 ) );
		
		for ( i = 0; i < size; i += 1 )
		{
			item = itemList[ i ];
			if ( StrFindFirst( item, "it_witcharm_004" ) != -1 || StrFindFirst( item, "it_witcharm_005" ) != -1 || StrFindFirst( item, "it_witcharm_006" ) != -1)
			{
				if ( !FactsDoesExist('import_item_ravenarmor') )
				{
					FactsAdd( 'import_item_ravenarmor', 1 );
					Log( "Importing equipped item: Raven Armor " );
					thePlayer.GetInventory().AddItem('ImportedRavenArmor', 1);
				}
			} else
			if ( StrFindFirst( item, "it_stlswd_015" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_gwalhir') )
				{
					FactsAdd( 'import_item_gwalhir', 1 );
					Log( "Importing equipped item: Gwalhir " );
					thePlayer.GetInventory().AddItem('Gwalhir', 1);
				}
			}
			else if ( StrFindFirst( item, "it_stlswd_016" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_dyaebl') )
				{
					FactsAdd( 'import_item_dyaebl', 1 );
					Log( "Importing equipped item: D’yaebl " );
					thePlayer.GetInventory().AddItem(StringToName("Dyaebl"), 1);
				}
			}
			else if ( StrFindFirst( item, "it_stlswd_017" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_ardaenye') )
				{
					FactsAdd( 'import_item_ardaenye', 1 );
					Log( "Importing equipped item: Ard’aenye " );
					thePlayer.GetInventory().AddItem(StringToName("Ardaenye"), 1);
				}
			}
			else if ( StrFindFirst( item, "it_svswd_005" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_aerondight') )
				{
					FactsAdd( 'import_item_aerondight', 1 );
					Log( "Importing equipped item: Aerondight " );
					thePlayer.GetInventory().AddItem('Aerondight', 1);
				}
			}
			else if ( StrFindFirst( item, "it_svswd_006" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_moonblade') )
				{
					FactsAdd( 'import_item_moonblade', 1 );
					Log( "Importing equipped item: Moonblade " );
					thePlayer.GetInventory().AddItem('Moonblade', 1);
				}
			}
			else if ( StrFindFirst( item, "it_stlswd_012" ) != -1 || StrFindFirst( item, "m0_it_stlswd05" ))
			{
				if ( !FactsDoesExist('import_item_mahakamanrunesihil') )
				{
					FactsAdd( 'import_item_mahakamanrunesihil', 1 );
					Log( "Importing equipped item: Mahakaman rune sihil" );
					thePlayer.GetInventory().AddItem('ImportedMahakamRuneSihil', 1);
				}
			}
			else if ( StrFindFirst( item, "it_stlswd_010" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_elvensword') )
				{
					FactsAdd( 'import_item_elvensword', 1 );
					Log( "Importing equipped item: Elven sword of the Blue Mountains" );
					thePlayer.GetInventory().AddItem('Sword of Blue Mountains', 1);
				}
			}
			else if ( StrFindFirst( item, "it_stlswd_005" ) != -1 )
			{
				if ( !FactsDoesExist('import_item_temeriansword') )
				{
					FactsAdd( 'import_item_temeriansword', 1 );
					Log( "Importing equipped item: Temerian steel sword" );
					thePlayer.GetInventory().AddItem('Temerian Steel Sword', 1);
				
				}
			}
		}
	}
	
	event OnImportJournal( journalList : array< string > )
	{
		var size, i : int;
		var journalEntry : string;
	
		size = journalList.Size();
		Log( "Processing imported journal - " + size );
		
		if( size > 0 )
		{
			FactsAdd( 'w1_save_imported', 1 );
			
			for ( i = 0; i < size; i += 1 )
			{
				journalEntry = journalList[ i ];
				
				if ( StrFindFirst( StrLower( journalEntry ), StrLower( "striga_dead" ) ) != -1 )
				{
					FactsAdd( 'witcher1_adda_dead', 1 );
					Log( "Importing fact: witcher1_adda_dead");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "q4004_order" ) ) != -1 )
				{
					FactsAdd( 'import_ending_order', 1 );
					Log( "Importing fact: q4004_order");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "q4004_neutral" ) ) != -1 )
				{
					FactsAdd( 'import_ending_neutral', 1 );
					Log( "Importing fact: q4004_neutral");
					FactsAdd( 'sigfried is dead', 1 );
					Log( "Importing fact: sigfried is dead");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "q4004_elves" ) ) != -1 )
				{
					FactsAdd( 'import_ending_elves', 1 );
					Log( "Importing fact: q4004_elves");
					FactsAdd( 'sigfried is dead', 1 );
					Log( "Importing fact: sigfried is dead");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "yaevin/killed" ) ) != -1 )
				{
					FactsAdd( 'import_yaevin_killed', 1 );
					Log( "Importing fact: yaevin/killed");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "talar/killed" ) ) != -1 )
				{
					FactsAdd( 'import_talar_killed', 1 );
					Log( "Importing fact: talar/killed");
				}
				else if ( StrFindFirst( StrLower( journalEntry ), StrLower( "Q3043_for_shani" ) ) != -1 )
				{
					FactsAdd( 'import_chosen_shani', 1 );
					Log( "Importing fact: Q3043_for_shani");
				}
			}
			
			if( !FactsDoesExist("witcher1_adda_dead") )
			{
				FactsAdd( 'witcher1_adda_lives', 1 );
			}
		}
	}
	event OnMovementCollision( pusher : CMovingAgentComponent ) 
	{
		// can't slide along others - ever
		return false;
	}
	
	// --------------------------------------------------------------------------
	// Talisman guide API
	// --------------------------------------------------------------------------
	private function UseTalismanGuide()
	{
		var cameraRotation 				: float = theGame.GetActiveCameraComponent().GetHeading();
		var spawnDir, spawnPosition		: Vector;
		var spawnDist					: float	= 3.0f;

		if ( m_talismanGuide == (CTalismanGuide)NULL && m_talismanTargetTag != '' )
		{
			spawnDir = VecFromHeading( cameraRotation );
			spawnPosition = GetWorldPosition() + spawnDir * spawnDist;
			
			m_talismanGuide = (CTalismanGuide)theGame.CreateEntity( talismanGuideEntity, spawnPosition, EulerAngles() );
			if ( m_talismanGuide )
			{
				m_talismanGuide.m_targetTag = m_talismanTargetTag;
			}
		}
	}
	
	function DestroyTalismanGuide()
	{
		var tg 		: CTalismanGuide;
		
		if ( m_talismanGuide != (CTalismanGuide)NULL )
		{
			tg = m_talismanGuide;
			m_talismanGuide = (CTalismanGuide)NULL;
			tg.Destroy();
		}
	}
	
	function SetTalismanTargetTag( targetTag : name )
	{
		m_talismanTargetTag = targetTag;
	}
	
	///////////////////
	
	event OnTargetLockActivated();
	
	event OnTargetLockDeactivated();
	
	///////////////////
	// functions controling sounds for groups of arrows
	function CanPlayArrowSound() : bool
	{
		if(theGame.GetEngineTime() > arrowSoundTime + arrowSoundCooldown)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function SetArrowSoundCooldown(cooldown : float)
	{
		arrowSoundCooldown = cooldown;
		arrowSoundTime = theGame.GetEngineTime();
	}
	
	// An event that decides whether a rapid turn is supported
	event OnDoesSupportRapidTurns( speedVal : float );

	////////////////////////////////////////////////////////////////////////
	
	private var m_itemToInvestigate : CInvestigationItem;
	final function InvestigateObject( item : CInvestigationItem )
	{
		m_itemToInvestigate = item;
		ChangePlayerState( PS_Investigate );
	}

/////////////////////// DLC ///////////////////////////////////

	event OnDlc_roche_jacket()
	{
		GetInventory().AddItem( 'Roche Commando Jacket', 1, true );
	}
	
	event OnDlc_alchemy_suit()
	{
		GetInventory().AddItem( 'Herbalist Gloves', 1, true );
		
		//GetInventory().AddItem( 'White Myrtle Petals', 15, true ); jaskolcze ziele, przestep, tegoskor
		//GetInventory().AddItem( 'Hellebore Petals', 15, true );
		//GetInventory().AddItem( 'Celandine', 15, true );
		GetInventory().AddItem( 'Beggartick Blossoms', 8, true );
		GetInventory().AddItem( 'Mandrake Root', 8, true );
		GetInventory().AddItem( 'Wolfsbane', 8, true );
		//GetInventory().AddItem( 'Bryony', 10, true );
		GetInventory().AddItem( 'Verbena', 8, true );
		GetInventory().AddItem( 'Balisse', 8, true );
	}

	event OnDlc_magical_suit()
	{
		GetInventory().AddItem( 'Unique Essenced Pants', 1, true );
		
		GetInventory().AddItem( 'Rune of Sun', 1, true );
		GetInventory().AddItem( 'Rune of Earth', 1, true );
		GetInventory().AddItem( 'Rune of Moon', 1, true );
		GetInventory().AddItem( 'Rune of Fire', 1, true );
	}
	
	event OnDlc_swordsman_suit()
	{
		GetInventory().AddItem( 'Unique Whetstone', 10, true );
		
		GetInventory().AddItem( 'Brown Oil', 4, true );
		GetInventory().AddItem( 'Hangman Venom', 4, true );
		GetInventory().AddItem( 'Crinfrid Oil', 4, true );
		GetInventory().AddItem( 'Specter Grease', 4, true );
		GetInventory().AddItem( 'Caelm', 4, true );
		GetInventory().AddItem( 'Cerbin Blath', 4, true );
		GetInventory().AddItem( 'Surge', 4, true );
		//GetInventory().AddItem( 'Argentia', 4, true );
	}
	
	event OnDlc_troll()
	{
		FactsAdd("Troll_fact", 1);
	}
	
	event OnDlc_succubuss()
	{
		FactsAdd("Succubuss_dlc_fact", 1);
	}
	
	event OnDlc_elf_flotsam()
	{
		FactsAdd("Elf_flotsam_dlc", 1);
	}
	
	event OnDlc_hairdresser()
	{
		FactsAdd("Hairdresser_fact", 1);
	}

///////////////////////////////////////////////////////////////	

	function SaveEquip()
	{
		var allItems : array < SItemUniqueId >;
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var i : int;
		
		inv.GetAllItems( allItems );
		
		for( i=1; i < allItems.Size(); i+=1 )
		{
			if ( inv.IsItemMounted( allItems[i] ) )
			{
				if ( inv.ItemHasTag( allItems[i], 'SteelSword' ) && !inv.ItemHasTag( allItems[i], 'NoShow') )	savedSteelSword	= allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'SilverSword' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) savedSilverSword = allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'Jacket' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) 		savedArmor = allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'Pants' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) 		savedPants = allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'Gloves' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) 		savedGloves = allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'Boots' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) 		savedShoes = allItems[i];
				if ( inv.ItemHasTag( allItems[i], 'Trophy' ) && !inv.ItemHasTag( allItems[i], 'NoShow')) 		savedTrophy = allItems[i];
			}
		}
	}
	
	function GetBestSteelSword() : SItemUniqueId
	{
		var allItems : array < SItemUniqueId >;
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var resultId : SItemUniqueId;
		var resultPrice : int;
		var i : int;
				
		inv.GetAllItems( allItems );
		
		for( i=1; i < allItems.Size(); i+=1 )
		{
			if ( inv.GetItemName( allItems[i] ) != 'Cutscene Sword' && inv.ItemHasTag( allItems[i], 'SteelSword') )
			{
				if ( resultPrice < theHud.m_utils.GetItemPrice( allItems[i], inv ) )
				{
					resultPrice = theHud.m_utils.GetItemPrice( allItems[i], inv );
					resultId = allItems[i];
				}
			}
		}
		
		return resultId;
	}

	function RestoreEquip()
	{
		var inv : CInventoryComponent = thePlayer.GetInventory();
		if ( savedSteelSword != GetInvalidUniqueId() && !inv.ItemHasTag( savedSteelSword, 'NoShow') ) {	inv.MountItem( savedSteelSword ); }
		else { inv.MountItem( GetBestSteelSword() ); }
		if ( savedSilverSword != GetInvalidUniqueId() && !inv.ItemHasTag( savedSilverSword, 'NoShow') ) inv.MountItem( savedSilverSword );
		if ( savedArmor != GetInvalidUniqueId() && !inv.ItemHasTag( savedArmor, 'NoShow') ) 		inv.MountItem( savedArmor );
		if ( savedPants != GetInvalidUniqueId() && !inv.ItemHasTag( savedPants, 'NoShow') ) 		inv.MountItem( savedPants );
		if ( savedGloves != GetInvalidUniqueId() && !inv.ItemHasTag( savedGloves, 'NoShow') ) 		inv.MountItem( savedGloves );
		if ( savedShoes != GetInvalidUniqueId() && !inv.ItemHasTag( savedShoes, 'NoShow') ) 		inv.MountItem( savedShoes );
		if ( savedTrophy != GetInvalidUniqueId() && !inv.ItemHasTag( savedTrophy, 'NoShow') ) 		inv.MountItem( savedTrophy );
	}

	function SetUSMTitle( arg : CFlashValueScript )
	{
		USMTitle = arg;
	}
	timer function ShowUSMTitle( timedelta : float )
	{
		theHud.InvokeOneArg( "USMSubtitles2", USMTitle );
	}

///////////////////////////////////////////////////////////////	
}

	

///////////////////////////////////////////////////////////////////
// Player brix
brix function PlayerWalkMode( flag : bool )
{
	thePlayer.SetWalkMode( flag );
}

function EquipDefaultItems()
{
	//EquipItem( 'Rusty Steel Sword' );
	//EquipItem( 'Witcher Silver Sword' );
	
}

function SetDLCImportEquip()
{
	var inv : CInventoryComponent = thePlayer.GetInventory();
	inv.MountItem( inv.GetItemId( 'ImportedRavenArmor' ) );
	inv.MountItem( inv.GetItemId( 'Roche Commando Jacket' ) );
	inv.MountItem( inv.GetItemId( 'Temerian Steel Sword' ) );
	inv.MountItem( inv.GetItemId( 'Sword of Blue Mountains') );
	inv.MountItem( inv.GetItemId( 'ImportedMahakamRuneSihil') );
	inv.MountItem( inv.GetItemId( 'Gwalhir' ) );
	inv.MountItem( inv.GetItemId( 'Dyaebl' ) );
	inv.MountItem( inv.GetItemId( 'Ardaenye' ) );
	inv.MountItem( inv.GetItemId( 'Aerondight' ) );
	inv.MountItem( inv.GetItemId( 'Moonblade') );
	inv.MountItem( inv.GetItemId( 'Unique Essenced Pants' ) );
	inv.MountItem( inv.GetItemId( 'Herbalist Gloves' ) );
}

//////////////////////////////////////////////////////////////////

// States from C++
import state Base in CPlayer 
{
	// Create no save lock for state
	import final function CreateNoSaveLock();

	final function IsKeyAttackFast( key : name ) : bool
	{
		return key == 'GI_AttackFast';
	}
	
	final function IsKeyAttackStrong( key : name ) : bool
	{
		return key == 'GI_AttackStrong';
	}
};
