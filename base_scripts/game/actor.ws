/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Behavior graph notification type 
/////////////////////////////////////////////
enum EActAction
{
	AA_None,
	AA_Act1,
	AA_Act2,
	AA_Act3,
	AA_Act4,
	AA_Act5
}
enum EBehaviorGraphNotificationType
{
	BGNT_Activation,
	BGNT_Deactivation,
	BGNT_Update,	
};

enum EActorButtonType
{
	ABT_wall_lever,
	ABT_wall_button,

}

struct SCutParts
{
	editable var LeftArm : bool;
	editable var RightArm : bool;
	editable var Torso : bool;
	editable var Head : bool;
	default LeftArm = true;
	default RightArm = true;
	default Torso = true;
	default Head = true;
}

/////////////////////////////////////////////
// EAnimationEventType 
/////////////////////////////////////////////
/*
enum EAnimationEventType
{
	AET_Tick,
	AET_DurationStart,
	AET_DurationEnd,
	AET_Duration,
};*/

/////////////////////////////////////////////
// Move type
// AbsSpeed is absolute speed in [m/s]
/////////////////////////////////////////////

/*enum EMoveType
{
	MT_Walk,
	MT_Run,
	MT_AbsSpeed
};*/


/////////////////////////////////////////////
// Move type modification
/////////////////////////////////////////////

/*enum EMoveTypeModification
{
	MTM_None,
	MTM_AlwaysWalk,
	MTM_AlwaysRun,
};*/

/////////////////////////////////////////////
// Slide rotation
/////////////////////////////////////////////

/*enum ESlideRotation
{
	SR_Nearest,
	SR_Right,
	SR_Left,
};*/

/////////////////////////////////////////////
// Move failure action
/////////////////////////////////////////////

/*enum EMoveFailureAction
{
	MFA_REPLAN,
	MFA_EXIT
};*

/////////////////////////////////////////////
// Character hand
/////////////////////////////////////////////
/*enum ECharacterHand
{
	CH_None,
	CH_Right,
	CH_Left,
	CH_RightWrist,
	CH_Any,
};*/

/////////////////////////////////////////////
// Character skeleton
/////////////////////////////////////////////

/*enum ESkeletonType
{
	Man,
	Woman,
	Witcher,
	Dwarf,
	Elf,
	Child,
	Monster,
};
*/

/////////////////////////////////////////////
// Draw/holster mode
enum EDrawHolsterItemMode
{
	DHIM_Normal = 0,
}

/////////////////////////////////////////////
// HitParams struct
/////////////////////////////////////////////

struct HitParams
{
	var attacker : CActor;
	var hitPosition : Vector;
	var attackType : name;
	var damage : float;
	var lethal : bool;
	var attackReflected : bool;
	var attackDodged : bool;
	var impossibleToBlock : bool;
	var groupAttack : bool;
	var killsTarget : bool;
	var forceHitEvent : bool;
	var rangedAttack : bool;
	var outDamageMultiplier : float;
	var backAttack : bool;

};

/////////////////////////////////////////////
// EActorImmortalityMode
/////////////////////////////////////////////
enum EActorImmortalityMode
{
	AIM_None,
	AIM_Immortal,
	AIM_Invulnerable,
};

/////////////////////////////////////////////
// EExitWorkMode
/////////////////////////////////////////////
enum EExitWorkMode
{	
	EWM_Exit,
	EWM_ExitFast,
	EWM_Break,
	EWM_None
};

/////////////////////////////////////////////
// SActorDeathData
/////////////////////////////////////////////
struct SActorDeathData
{
	var silent : bool;
	var onlyDestruct : bool;
	var noActionCancelling : bool;
	var deadState : bool;
	var ragDollAfterDeath : bool;
	var fallDownDeath : bool;
};

enum EMonsterType
{
	MT_NotAMonster,
	MT_Arachas,
	MT_Bruxa,
	MT_Bullvore,
	MT_Drowner,
	MT_Endriaga,
	MT_Gargoyle,
	MT_Golem,
	MT_Harpie,
	MT_KnightWraith,
	MT_Nekker,
	MT_Rotfiend,
	MT_Troll,
	MT_Wraith,
	MT_HumanGhost,
	MT_Elemental,
	MT_Warewolf
};

/////////////////////////////////////////////
// SKnowledge
/////////////////////////////////////////////
struct SKnowledge
{
	editable var knowledgeId   : int;
	editable var knowledgeAmount : float;
}
enum EReplacerAttackType
{
	RAT_OneHanded,
	RAT_TwoHanded
}

/////////////////////////////////////////////
// EFinisherType - defines in what type of finishers can actor take part
/////////////////////////////////////////////
//temporary cast to int because default values dont work while being an enum
enum EFinisherType
{
	FT_None, // = 0
	FT_Single, // = 1
	FT_Multi // = 2
};

/////////////////////////////////////////////
// Actor class
/////////////////////////////////////////////
import class CActor extends CGameplayEntity
{
	private saved var health			: float; // hit points
	private saved var initialHealth		: float;
	private saved var stamina			: float;
	private saved var initialStamina	: float;
	private editable saved var immortalityMode	: EActorImmortalityMode;	// changed in entity and quests
	private var immortalityModeScene			: EActorImmortalityMode;	// changed by scene
	private var immortalityModeRuntime			: EActorImmortalityMode;	// changed by other systems eg. combat
	private var immortalityTimeRuntime			: EngineTime;				// time of runtime immortality validity
	import private var combatSlots	: CCombatSlots;
	import private var attackTarget : CActor;
	import private var attackTargetSetTime : EngineTime;
	private var combatSlotOffset	: float;
	private var combatSlotTakeTime	: EngineTime;
	private var combatIdleGroupIdx	: int;
	private var lastTimeAttacked	: EngineTime;
	private var blockHitTime		: EngineTime;
	private var superblockTime		: EngineTime;
	private var weakened			: bool;	
	private saved var level			: int;
	private var TakedownReady		: bool;
	private var Stamina_DamageMult  : float;	
	private import var isHidden     : int;
	private var execute_dismember   : bool;
	private var noragdollDeath		: bool;
	private var gesturesLocked		: bool;
	private var lookatLocked		: bool;
	private var focusedNode			: CNode;
	private var focusedPos			: Vector;
	private var bloodOnSword        : int;
	private saved var criticalEffects		: array< W2CriticalEffectBase >;
	private var readyToCut : SCutParts;
	private editable var killingCauseGuardDialog : bool;
	
	private editable saved var canBeFinishedOff : bool;
	private editable saved var canPlayFinisherCutscene : bool;
	default canBeFinishedOff = true;
	default canPlayFinisherCutscene = true;
	private saved var failedPerswazja : bool;
	private saved var failedAksjacja : bool;
	private saved var failedZastraszenie : bool;
	
	var actActions : array<EActAction>;
	
	var lastNotifyActorTime : EngineTime; //time when other actors were informed about this actor attacker position
	
    private editable var knowledge : SKnowledge;
	private editable var allowToCut : SCutParts;
	var lastCollisionBoneIndex		: int;
	
	var lastSelectedInCombat 		: bool;
	var lastSelectedTime			: EngineTime;
	
	var lastAttackedByPlayer 		: bool;
	var lastAttackedByPlayerTime	: EngineTime;
	
	//temporary cast to int because default values dont work while being an enum
	//editable var finisherType		: EFinisherType;
	editable var finisherType		: int;
	
	default health			= 100.0;
	default initialHealth	= 100.0;
	default stamina			= 5.0;
	default initialStamina	= 2.0; // 8 is max value
	default level 			= 0;
	default combatIdleGroupIdx = 0;
	
	default gesturesLocked	= false;
	default lookatLocked	= false;
	
	//temporary cast to int because default values dont work while being an enum
	default finisherType	= 0;//FT_None;
	
	var blockActive : bool;
	var storedHitParams : HitParams;
	default blockActive = false;
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Is actor in combat? (for player checks combat mode, for npc checks current goal)
	import final function IsInCombat() : bool;
	
	// Is actor ready for new action
	import final function IsReadyForNewAction() : bool;
	
	// Cancel all actions in progress
	import final function ActionCancelAll();
	
	import final function IsCurrentActionInProgress() : bool;
	import final function IsCurrentActionSucceded() : bool;
	import final function IsCurrentActionFailed() : bool;
	
	import final function IsInNonGameplayCutscene() : bool;
	import final function PlayScene( input : string ) : bool;
	import final function StopAllScenes();
	// Get current action priority
	import final function GetCurrentActionPriority() : int;

	import final function GetCurrentActionType() : EActorActionType;
	// Is actor doing something more important?
	import final function IsDoingSomethingMoreImportant( priority : int ) : bool;
	
	import final function WasVisibleLastFrame() : bool;
	
	import final function CanPlayQuestScene() : bool;
	import final function HasInteractionScene() : bool;
	
	import final function SetHideInGame( hide : bool );
	
	import final function GetActorAnimState() : int;
	
	// Is actor in camera view?
	import final function IsInView() : bool;
	
	// Is actor using exploration
	import final function IsUsingExploration() : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Move to target, returns true if movement succeeded. Default moveType is MT_Walk.
	import latent final function ActionMoveToNode( target : CNode, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	// Move to target, returns true if movement succeeded, don't wait till finishing the action. Default moveType is MT_Walk.
	import final function ActionMoveToNodeAsync( target : CNode, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	
	// Move to target, returns true if movement succeeded. Default moveType is MT_Walk.
	import latent final function ActionMoveToNodeWithHeading( target : CNode, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	// Move to target, returns true if movement succeeded, don't wait till finishing the action. Default moveType is MT_Walk.
	import final function ActionMoveToNodeWithHeadingAsync( target : CNode, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	
	// Move to target, returns true if movement succeeded. Default moveType is MT_Walk.
	import latent final function ActionMoveTo( target : Vector, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	// Move to target, returns true if movement succeeded, don't wait till finishing the action. Default moveType is MT_Walk.
	import final function ActionMoveToAsync( target : Vector, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	

	// Move to target and face given heading, returns true if movement succeeded. Default moveType is MT_Walk.
	import latent final function ActionMoveToWithHeading( target : Vector, heading : float, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	// Move to target and face given heading, returns true if movement succeeded, don't wait till finishing the action. Default moveType is MT_Walk.
	import final function ActionMoveToWithHeadingAsync( target : Vector, heading : float, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;	
	
	// Move towards a dynamic node.
	import latent final function ActionMoveToDynamicNode( target : CNode, moveType : EMoveType, absSpeed : float, range : float, optional keepDistance : bool, optional failureAction : EMoveFailureAction ) : bool;	
	// Move towards a dynamic node (asynchronous version ).
	import final function ActionMoveToDynamicNodeAsync( target : CNode, moveType : EMoveType, absSpeed : float, range : float, optional keepDistance : bool, optional failureAction : EMoveFailureAction ) : bool;	
	
	// Move using a custom locomotion targeter.
	import latent final function ActionMoveCustom( targeter : CMoveTRGScript ) : bool;	
	// Asynchronous version of the move function using a custom locomotion targeter.
	import final function ActionMoveCustomAsync( targeter : CMoveTRGScript ) : bool;	
	
	// Slides through an action area, returns true when movement was successfull
	import latent final function ActionSlideThrough( explorationAreaToUse : CActionAreaComponent ) : bool;	
	// Slides through an action area
	import final function ActionSlideThroughAsync( explorationAreaToUse : CActionAreaComponent ) : bool;	
	
	// Slide to target, returns true if movement succeeded
	import latent final function ActionSlideTo( target : Vector, duration : float ) : bool;	
	// Slide to target, returns true if movement succeeded, don't wait till finishing the action
	import final function ActionSlideToAsync( target : Vector, duration : float ) : bool;	

	// Slide to target and face given heading, returns true if movement succeeded
	import latent final function ActionSlideToWithHeading( target : Vector, heading : float, duration : float, optional rotation : ESlideRotation /* = SR_Nearest */ ) : bool;	
	// Slide to target and face given heading, returns true if movement succeeded, don't wait till finishing the action
	import final function ActionSlideToWithHeadingAsync( target : Vector, heading : float, duration : float, optional rotation : ESlideRotation /* = SR_Nearest */ ) : bool;
	
	// Move away from position, returns true if movement succeeded. Default moveType is MT_Walk.
	import latent final function ActionMoveAwayFromNode( position : CNode, distance : float, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction ) : bool;	
	// Move away from position, returns true if movement succeeded, don't wait till finishing the action
	import final function ActionMoveAwayFromNodeAsync( position : CNode, distance : float, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction ) : bool;	
	
	// Move away from line segment, returns true if movement succeeded. Default moveType is MT_Walk.
	// makeMinimalMovement - try to make minimal movement aside from line (distance may be smaller than passed in the argument)
	import latent final function ActionMoveAwayFromLine( positionA : Vector, positionB : Vector, distance : float, makeMinimalMovement : bool, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction ) : bool;	
	// Move away from line segment, returns true if movement succeeded, don't wait till finishing the action. Default moveType is MT_Walk.
	// makeMinimalMovement - try to make minimal movement aside from line (distance may be smaller than passed in the argument)	
	import final function ActionMoveAwayFromLineAsync( positionA : Vector, positionB : Vector, distance : float, makeMinimalMovement : bool, optional moveType : EMoveType, optional absSpeed : float, optional radius : float, optional failureAction : EMoveFailureAction ) : bool;	
	
	// Move along the given path. Default moveType is MT_Walk.
	import final function ActionMoveAlongPath( path : CPathComponent, upThePath : bool, fromBeginning : bool, pathMargin : float, optional moveType : EMoveType, optional absSpeed : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;
	// Move along the given path, don't wait till finishing the action. Default moveType is MT_Walk.
	import final function ActionMoveAlongPathAsync( path : CPathComponent, upThePath : bool, fromBeginning : bool, pathMargin : float, optional moveType : EMoveType, optional absSpeed : float, optional failureAction : EMoveFailureAction, optional modifiers : array< IMoveParamModifier > ) : bool;

	// Rotate to face given target, returns true if movement succeeded
	import latent final function ActionRotateTo( target : Vector ) : bool;	
	// Rotate to face given target, returns true if movement succeeded, don't wait till finishing the action
	import final function ActionRotateToAsync( target : Vector ) : bool;
	
	// Rotate to match the specified orientation, returns true if movement succeeded
	import latent final function ActionSetOrientation( orientation : float ) : bool;	

	// Play animation on slot, returns true if animation was played, default: blendIn 0.2s, blendOut 0.2s, continuePlaying false
	import latent final function ActionPlaySlotAnimation( slotName : name, animationName : name, optional blendIn : float, optional blendOut : float, optional continuePlaying : bool ) : bool;
	
	// Work using the specified job tree
	import latent final function ActionWorkJobTree( jobTree : CJobTree, category : name, skipEntryAnimations : bool ) : bool;
	
	// Exit working in given AP, returns false if wasn't working anyway
	import latent final function ActionExitWork( optional fast : bool ) : bool;
	// Exit working in given AP, returns false if wasn't working anyway, don't wait till end
	import final function ActionExitWorkAsync( optional fast : bool ) : bool;
	
	// Action use device
	import latent final function ActionUseDevice( device : CGameplayDevice ) : bool;
	
	import final function SetMovementType( type : EExplorationState ) : bool;
	import final function GetMovementType() : EExplorationState;
	
	import final function GetSkeletonType() : ESkeletonType;
	
	import final function GetFallTauntEvent() : string;
	
	// Event called when action has started
	event OnActionStarted( actionType : EActorActionType );
	
	// Event called when action has ended
	event OnActionEnded( actionType : EActorActionType, result : bool );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	function IsAnimal() : bool
	{
		return false;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	function SetIsFailedAksjacja( )
	{
		failedAksjacja = true;
	}
	function GetLastAttackedByPlayer() : bool
	{
		var selectedTimeOut : float;
		var enemySelected : SEnemySelection;
		enemySelected = thePlayer.GetEnemySelection();
		selectedTimeOut = enemySelected.lastTargetAttackedTimeout;
		
		if(theGame.GetEngineTime() < lastAttackedByPlayerTime + selectedTimeOut )
		{
			return lastAttackedByPlayer;
		}
		else
		{
			SetLastAttackedByPlayer(false);
			return false;
		}
	}
	function SetLastAttackedByPlayer(wasAttackedByPlayer : bool)
	{
		if(wasAttackedByPlayer)
		{
			thePlayer.DeselectAllAttacked(thePlayer.FindEnemiesToTarget());
			lastAttackedByPlayerTime = theGame.GetEngineTime();
		}
		lastAttackedByPlayer = wasAttackedByPlayer;
	}
	function GetLastSelectedInCombat() : bool
	{
		var selectedTimeOut : float;
		
		var enemySelected : SEnemySelection;
		enemySelected = thePlayer.GetEnemySelection();
		selectedTimeOut = enemySelected.lastTargetSelectedTimeout;
		
		if(theGame.GetEngineTime() < lastSelectedTime + selectedTimeOut )
		{
			return lastSelectedInCombat;
		}
		else
		{
			SetLastSelectedInCombat(false);
			return false;
		}
	}
	function SetLastSelectedInCombat(wasLastSelectedInCombat : bool)
	{
		if(wasLastSelectedInCombat)
		{
			lastSelectedTime = theGame.GetEngineTime();
		}
		lastSelectedInCombat = wasLastSelectedInCombat;
	}
	function SetIsFailedZastraszenie( )
	{
		failedZastraszenie = true;
	}
	function SetIsFailedPerswazja( )
	{
		failedPerswazja = true;
	}
	function CanPlayFinisherCutscene() : bool
	{
		if(this.IsWoman())
		{
			return false;
		}
		if(this.IsDwarf())
		{
			return false;
		}
		return canPlayFinisherCutscene;
	}
	function CanBeFinishedOff(attacker : CActor) : bool
	{
		var playerState : EPlayerState;
		playerState = thePlayer.GetCurrentPlayerState();
		
		if(this.IsImmortal() || this.IsInvulnerable())
		{
			return false;
		}
		if(attacker == thePlayer && playerState != PS_CombatSteel && playerState != PS_CombatSilver)
			return false;
		return canBeFinishedOff;
	}
	function CanAct() : bool
	{
		return false;
	}
	function GetActingAction() : EActAction
	{
		var size, i : int;
		size = actActions.Size();
		if(size <= 0)
		{
			return AA_None;
		}
		else
		{
			i = Rand(size);
			return actActions[i];
		}
	}
	function PerformActingAction() : bool
	{

		var result : bool;
		var actInt : int;
		var actEnum : EActAction;
		actEnum = GetActingAction();
		if(actEnum == AA_None)
		{
			return false;
		}
		actInt = (int)actEnum;
		SetBehaviorVariable("ActEnum", (float)actInt);
		result = this.RaiseForceEvent('PerformActing');
		
		return result;
	}
	function IsBoss() : bool
	{
		return false;
	}
	
	function IsDummy() : bool
	{
		return false;
	}

	function GetMonsterType() : EMonsterType
	{
		return MT_NotAMonster;
	}
	
	function IsMan() : bool
	{
		if(this.GetSkeletonType() == Man)
			return true;
		else
			return false;
	}

	function IsWoman() : bool
	{
		if(this.GetSkeletonType() == Woman)
			return true;
		else
			return false;
	}
	function IsDwarf() : bool
	{
		if(this.GetSkeletonType() == Dwarf)
			return true;
		else
			return false;
	}
	function IsChild() : bool
	{
		if(this.GetSkeletonType() == Child)
			return true;
		else
			return false;
	}
	function IsHuge() : bool
	{
		var monsterType : EMonsterType;
		monsterType = this.GetMonsterType();		
		switch(monsterType)
		{
			case MT_Troll : 
			{
				return true;
				break;
			}
			case MT_Golem :
			{
				return true;
				break;
			}
			case MT_Elemental :
			{
				return true;
				break;
			}
			case MT_Bullvore :
			{
				return true;
				break;
			}
		}
		return false;
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	latent function ExitWork( mode : EExitWorkMode )
	{
		if( mode == EWM_Break )
			ActionCancelAll();
		else if( mode == EWM_Exit )
			ActionExitWork( false );
		else if( mode == EWM_ExitFast )
			ActionExitWork( true );
		else if( mode == EWM_None )
		{
		}
		else
			Log("ERROR: ExitWork unknown mode" );
	}
	
	// Rotate towards given position
	latent function RotateTo( target : Vector, optional duration : float ) : bool
	{
		var vec, pos : Vector;
		var heading : float;
		var res : bool;
		
		if( duration <= 0.0 )
			duration = 0.2;
		
		pos = GetWorldPosition();
		vec = target - GetWorldPosition();
		heading = VecHeading( vec );
		res = ActionSlideToWithHeading( pos, heading, duration );
		return res;
	}
	
	// Rotate towards given node
	latent function RotateToNode( node : CNode, optional duration : float ) : bool
	{
		var res : bool;
		res = RotateTo( node.GetWorldPosition(), duration );
		return res;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Set actor error state
	import final function SetErrorState( description : string ); 
	
	// Set actor error state
	import final function SetErrorStatef( description : string, optional a,b,c,d : string  ); 
	
	// Get moving agent radius
	import final function GetRadius() : float;
	
	// Get visual debug (can be NULL)
	import final function GetVisualDebug() : CVisualDebug;
	
	// Get Behavior Tree machine
	import final function GetBehTreeMachine() : CBehTreeMachine;

	// Behavior tree execution has ended (for tree started with oneExecution=true)
	event OnBehTreeEnded();

	// Play given voiceset of this actor
	import final function PlayVoiceset( priority : int, voiceset : string ) : bool;
	
	// Returns the index of an inventory item corresponding to the currently equipped weapon.
	import final function GetCurrentWeapon( optional hand : ECharacterHand /*= CH_Any*/ ) : SItemUniqueId;
	
	// Tells whether currently used weapon can cause lethal wounds.
	import final function IsCurrentWeaponLethal( optional hand : ECharacterHand /*= CH_Any*/ ) : bool;
	
	// Get name of current weapon, or error message if not found
	import final function GetCurrentWeaponDebugName( optional hand : ECharacterHand /*= CH_Any*/ ) : string;
	
	// Check if NPC is rotated towards given entity
	import final function IsRotatedTowards( node : CNode, optional maxAngle : float /* 10.0f */ ) : bool;
	
	// Check if NPC is rotated towards given point
	import final function IsRotatedTowardsPoint( point : Vector, optional maxAngle : float /* 10.0f */ ) : bool;
	
	// Is actor alive (not dead and not unconscious)
	import final function IsAlive() : bool;
	
	// Set actor alive
	import final function SetAlive( flag : bool );
	
	// Is externaly controlled
	import final function IsExternalyControlled() : bool;
	
	// Is actor moving (by Action...)
	import final function IsMoving() : bool;
	
	// Get actor's move destination
	import final function GetMoveDestination() : Vector;
	
	// Get actor current position or move destination if moving
	import final function GetPositionOrMoveDestination() : Vector;
	
	// Get move type modification
	import final function GetMoveTypeModification() : EMoveTypeModification;
	
	// Set move type modification
	import final function SetMoveTypeModification( modification : EMoveTypeModification );
	
	// Get move type with modification applied
	import final function GetModifiedMoveType( moveType : EMoveType ) : EMoveType;
	
	import final function GetVoicetag() : name;
	
	// Get head horizontal angle
	import final function GetHeadAngleHorizontal() : float;
	
	// Get head vertical angle
	import final function GetHeadAngleVertical() : float;
	
	import final function GetMovingAgentComponent() : CMovingAgentComponent;
	
	import final function EnablePathEngineAgent( flag : bool );
	
	import final function EnableCollisionInfoReportingForItem( itemId : SItemUniqueId, enable : bool );
	
	import final function EnablePhysicalMovement( enable : bool );
	
	import final function EnableProxyCollisions( enable : bool );
	
	import final function PushInDirection( pusherPos : Vector, direction : Vector, optional speed : float, optional playAnimation : bool, optional applyRotation : bool );
	
	import final function PushAway( pusher : CMovingAgentComponent, optional strength : float, optional speed : float );
	
	// Returns true if actor radgall is an obstacle
	import final function IsRagdollObstacle() : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	import final function LoadDynamicTemplate( template : CEntityTemplate );
	import final function UnloadDynamicTemplate();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Clear rotation target
	import final function ClearRotationTarget();
	
	// Set entity as rotation target
	import final function SetRotationTarget( node : CNode, optional clamping : bool /* =true */ );
	
	// Set position as rotation target
	import final function SetRotationTargetPos( position : Vector, optional clamping : bool /* =true */ );
	
	final function SetRotationTargetWithTimeout( node : CNode, clamping : bool, optional timeout : float )
	{
		if( timeout == 0.0 )
		{
			timeout = 10.0;
		}
	
		SetRotationTarget( node, clamping );
		AddTimer('ClearRotationTargetTimer', timeout, false );
	}
	
	final function ClearRotationTargetWithTimeout()
	{
		ClearRotationTarget();
		RemoveTimer('ClearRotationTargetTimer');
	}
	
	timer function ClearRotationTargetTimer( td : float )
	{
		ClearRotationTarget();
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Is position in attack range
	import final function InAttackRangePos( targetPos : Vector ) : bool;
	
	// Checks if the specified target actor is in the attack range.
	import final function InAttackRange( target : CActor ) : bool;
	
	// Returns the attack range parameters
	import final function GetAttackRangeParams( out rangeMin, rangeMax, rangeAngle, height : float, out position : Vector ) : bool;
	
	// Get nearest point in personal space
	import final function GetNearestPointInPersonalSpace( position : Vector ) : Vector;
	
	//////////////////////////////////////////////////////////////////////////////////////////s
	
	// Is attackable by player
	import final function IsAttackableByPlayer() : bool;
	
	// Set attackable by player persistent (savable)
	import final function SetAttackableByPlayerPersistent( flag : bool );
	
	// Set attackable by player runtime (not savable, with timeout)
	import final function SetAttackableByPlayerRuntime( flag : bool, optional timeout : float /*= 10.0f */ );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Add animation set
	import final function AddAnimset( animset : CSkeletalAnimationSet );
	
	// Sets actor appearance
	import final function SetAppearance( appearanceName : CName );

	// Check if given interaction is active or not
	import final function CheckInteraction( interactionName : string ) : bool;
	
	import final function CheckInteractionPlayerOnly( interactionName : string ) : bool;
	
	// Attaches an entity to a specified bone
	import final function AttachEntityToBone( entity : CEntity, boneName : string ) : bool;
	
	// Detaches entity from the actor's skeleton
	import final function DetachEntityFromSkeleton( entity : CEntity );

	// Get animation time multiplier of this actor
	import final function GetAnimationTimeMultiplier() : float;
	// Set animation time multiplier of this actor
	import final function SetAnimationTimeMultiplier( mult : float );
	
	// Teleport to waypoint
	import final function TeleportToWayPoint( wayPoint : CWayPointComponent, optional useRotation : bool /*=true*/ ) : bool;
	
	// Calculate height over the terrain / static meshes
	import final function CalculateHeight() : float;
	
	// Set AI light radius
	import final function SetAILightRadius( radius : float );
	
	// Set behavior mimic float variable
	import final function SetBehaviorMimicVariable( varName : string, varValue : float ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Items and weapons
	
	import final function 			DrawItemInstant( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import final function 			HolsterItemInstant( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import final function 			DrawTwoItemsInstant( itemId1 : SItemUniqueId, itemId2 : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import final function 			HolsterTwoItemsInstant( itemId1 : SItemUniqueId, itemId2 : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import final function 			DrawWeaponInstant( itemId : SItemUniqueId , optional mode : EDrawHolsterItemMode ) : bool;
	import final function 			HolsterWeaponInstant( itemId : SItemUniqueId , optional mode : EDrawHolsterItemMode ) : bool;
	
	import final function 			DrawTwoWeaponsInstant( itemId : SItemUniqueId , optional mode : EDrawHolsterItemMode ) : bool;
	import final function 			HolsterTwoWeaponsInstant( itemId : SItemUniqueId , optional mode : EDrawHolsterItemMode ) : bool;
	
	import latent final function 	DrawItemLatent( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import latent final function 	HolsterItemLatent( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import latent final function 	DrawTwoItemsLatent( firstItemId : SItemUniqueId, secItemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import latent final function 	HolsterTwoItemsLatent( firstItemId : SItemUniqueId, secItemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import latent final function 	DrawWeaponLatent( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import latent final function 	DrawWeaponAndAttackLatent( itemId : SItemUniqueId ) : bool;
	import latent final function 	HolsterWeaponLatent( itemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import latent final function 	DrawTwoWeaponsLatent( firstItemId : SItemUniqueId, secItemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	import latent final function 	HolsterTwoWeaponsLatent( firstItemId : SItemUniqueId, secItemId : SItemUniqueId, optional mode : EDrawHolsterItemMode ) : bool;
	
	import final function 			HolsterItemsInHandsInstant() : bool;
	import latent final function	HolsterItemsInHandsLatent() : bool;
	
	import function 				HasLatentItemAction() : bool;
	import latent function 			WaitForFinishedAllLatentItemActions() : bool;
	
	import final function			IssueRequiredItems( leftItem : name, rightItem : name );
	import final function			SetRequiredItems( leftItem : name, rightItem : name );
	import latent final function	ProcessRequiredItems();
	
	import latent final function 	ActivateAndSyncBehaviorWithItemsParallel( names : name, optional timeout : float ) : bool;
	import latent final function 	ActivateAndSyncBehaviorWithItemsSequence( names : name, optional timeout : float ) : bool;
	
	// Equip inventory item on actor
	import final function EquipItem( itemId : SItemUniqueId, optional toHand : bool ) : bool;
	
	// Unequip inventory item
	import final function UnEquipItem( itemId : SItemUniqueId, optional destroyEntity : bool ) : bool;
	
	// Use inventory item
	import final function UseItem( itemId : SItemUniqueId ) : bool;
	
	// Put out anything
	import final function EmptyHands();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	import final function PlayLine( stringId : int, subtitle : bool );
	
	import final function PlayLineByStringKey( stringKey : string, subtitle : bool );
	
	import final function EndLine();
	
	import final function IsSpeaking( optional stringId : int ) : bool;

	import final function PlayMimicAnimationAsync( animation : name ) : bool;
	
	import final function EnableRagdoll( enable : bool );
	
	latent final function WaitForEndOfSpeach()
	{
		Sleep(0.001); // Skip one frame
		while( IsSpeaking() )
		{
			Sleep(0.1);
		}
	}
	
	// Sets actor in dying state
	import final function SetDyingState();
	
	//////////////////////////////////////////////////////////////////////////////////////////

	// Plays a push animation on an NPC
	import final function PlayPushAnimation( pushDirection : EPushingDirection );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function IsHidden() : bool
	{
		return (isHidden > 0);
	}

	function SetIsHidden( flag : bool )
	{
		if( flag )
		{
			isHidden +=1;
		}
		else
		{
			isHidden -= 1;
			if( isHidden < 0 )
			{
				Log( "CActor::SetIsHidden error isHidden < 0" );				
			}
		}	
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get node this Actor is currently thinking about
	function GetFocusedNode() : CNode
	{
		return focusedNode;
	}
	
	function GetFocusedPositionRaw() : Vector
	{		
		return focusedPos;
	}
	
	function GetFocusedPosition() : Vector
	{		
		if( focusedNode )
			return focusedNode.GetWorldPosition();
		else
			return focusedPos;
	}
	
	// Set node this Actor is currently thinking about
	function SetFocusedNode( node : CNode )
	{
		focusedNode = node;
		if( node )
		{
			focusedPos = node.GetWorldPosition();
		}
		else
		{
			focusedPos = Vector(0,0,0);
		}
	}
	
	function SetFocusedPostion( pos : Vector )
	{
		focusedNode = NULL;
		focusedPos = pos;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetRagdoll( enable : bool )
	{
		EnableRagdoll( enable );
		if (enable)
		{
			/*if( !IsMonster() && this != thePlayer )
			{
				//ActivateBehavior( 'npc_combat' );
			}*/
			SetBehaviorVariable('Ragdoll_Weight', 0.5);
			SetBehaviorVariable('CollisionOff', 1.0);
			EnableProxyCollisions( false );
		}
		else
		{
			SetBehaviorVariable('Ragdoll_Weight', 0.0);
			SetBehaviorVariable('CollisionOff', 0.0);
			EnableProxyCollisions( true );
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Stop carrying
	event OnStopInteractionState( carryTransitionMode : W2CarryTransitionMode );

	//////////////////////////////////////////////////////////////////////////////////////////
	
	function SetCombatHighlight( flag : bool )
	{
		//SetGameplayParameter( 0, flag, 0.f );		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function EnterSlaveState( master : CActor, slaveBehaviorName : name, instantStart : bool, initialSpeed : float ) {}
	
	function EnterMinigameState( position : CNode, behavior : name ) {}
	function ExitMinigameState() {}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get attack priority
	function GetAttackPriority() : int { return 0; }
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	final function GetItemAttrib( itemId : SItemUniqueId, attribName : name ) : float
	{
		var val : float;
		var inventory : CInventoryComponent;
		inventory = GetInventory();
		
		if ( inventory && inventory.IsIdValid( itemId ) )
		{
			val = inventory.GetItemAttributeAdditive( itemId, attribName );
		}
		
		return val;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get last time when actor was attacked
	function GetLastTimeAttacked() : EngineTime
	{
		return lastTimeAttacked;
	}
	
	// is ready to be takendown?
	function ReadyToTakedown() : bool
	{	
		return TakedownReady;
	}
	
	// Can actor act as takedown victim
	function CanBeTakedowned( attacker : CActor, primary : bool ) : bool
	{		
		return false;
	}
	function MustBeTakedowned() : bool
	{		
		return false;
	}
	event OnBeingHitPosition(hitParams : HitParams)
	{
		return true;
	}
	//////////////////////////////////////////////////////////////////////////////////////////

	// Play bloody effect on weapon
	function PlayBloodyFXOnWeapon(actor : CActor, optional target : CActor)
	{
		var item : SItemUniqueId;
		var inventory : CInventoryComponent;
		
		if( !actor )
			return;
		
		inventory = actor.GetInventory();
		item = actor.GetCurrentWeapon();
		
		if(item == GetInvalidUniqueId())
			return;
		if(target.GetMonsterType() == MT_Gargoyle)
		{
			inventory.StopItemEffect( item, 'blood_weapon_stage1');
			inventory.StopItemEffect( item, 'blood_weapon_stage2');
			inventory.StopItemEffect( item, 'blood_weapon_stage3');
			inventory.StopItemEffect( item, 'blood_weapon_wraith');
			inventory.StopItemEffect( item, 'blood_weapon_k_wraith');
			inventory.PlayItemEffect( item, 'blood_weapon_gargoyle');

		}
		else if(target.GetMonsterType() == MT_Wraith || target.GetMonsterType() == MT_Bruxa || target.GetMonsterType() == MT_HumanGhost)
		{
			inventory.StopItemEffect( item, 'blood_weapon_stage1');
			inventory.StopItemEffect( item, 'blood_weapon_stage2');
			inventory.StopItemEffect( item, 'blood_weapon_stage3');
			inventory.StopItemEffect( item, 'blood_weapon_gargoyle');
			inventory.StopItemEffect( item, 'blood_weapon_k_wraith');
			inventory.PlayItemEffect( item, 'blood_weapon_wraith');

		}
		else if(target.GetMonsterType() == MT_KnightWraith )
		{
			inventory.StopItemEffect( item, 'blood_weapon_stage1');
			inventory.StopItemEffect( item, 'blood_weapon_stage2');
			inventory.StopItemEffect( item, 'blood_weapon_stage3');
			inventory.StopItemEffect( item, 'blood_weapon_gargoyle');
			inventory.StopItemEffect( item, 'blood_weapon_wraith');
			inventory.PlayItemEffect( item, 'blood_weapon_k_wraith');

		}
		else
		{
			actor.bloodOnSword += 1;
			if (actor.bloodOnSword==2)
			{
				inventory.StopItemEffect( item, 'blood_weapon_stage2');
				inventory.StopItemEffect( item, 'blood_weapon_stage3');
				inventory.PlayItemEffect( item, 'blood_weapon_stage1');
			} else
			if (actor.bloodOnSword==5)
			{
				inventory.StopItemEffect( item, 'blood_weapon_stage1');
				inventory.StopItemEffect( item, 'blood_weapon_stage3');
				inventory.PlayItemEffect( item, 'blood_weapon_stage2');
			} else
			if (actor.bloodOnSword==10)
			{
				inventory.StopItemEffect( item, 'blood_weapon_stage1');
				inventory.StopItemEffect( item, 'blood_weapon_stage2');
				inventory.PlayItemEffect( item, 'blood_weapon_stage3');
			}
		}
	}
	
	// Play blood on hit
	function GetLastCollisionBone() : int
	{
		return lastCollisionBoneIndex;
	}
	function SetLastCollisionBone(boneIndex : int)
	{
		lastCollisionBoneIndex;
	}
	function PlayBloodOnHit ()
	{		
		PlayEffect('standard_hit_fx');
	}
	
	function PlayStrongBloodOnHit ()
	{
		PlayEffect('super_strong_hit');
	}
	
	// Play sparks on hit
	function PlaySparksOnHit(actor : CActor, hitParams : HitParams)
	{
		var shield : SItemUniqueId;
		var actorNPC : CNewNPC;
		if(actor == thePlayer)
		{
			if(thePlayer.IsDodgeing())
			{
				return;
			}
		}
		actorNPC = (CNewNPC)actor;
		actor.GetInventory().StopItemEffect( actor.GetCurrentWeapon(), 'block_standard' );
				
		if( IsStrongAttack( hitParams.attackType ) ) 
		{
			if(actorNPC &&  actorNPC.HasCombatType(CT_ShieldSword))
			{
				shield = actor.GetInventory().GetItemByCategory('opponent_shield', true);
				actor.GetInventory().StopItemEffect( shield, 'super_strong_block' );
				actor.GetInventory().PlayItemEffect(shield, 'super_strong_block' );
				
			}
			else
			{
				actor.GetInventory().PlayItemEffect( actor.GetCurrentWeapon(), 'super_strong_block' );
			}
		}
		else
		{
			if(actorNPC && actorNPC.HasCombatType(CT_ShieldSword))
			{
				
				shield = actor.GetInventory().GetItemByCategory('opponent_shield', true);
				actor.GetInventory().StopItemEffect( shield, 'standard_block' );
				actor.GetInventory().PlayItemEffect(shield, 'standard_block' );
				
			}
			else
			{
				actor.GetInventory().PlayItemEffect( actor.GetCurrentWeapon(), 'block_standard' );
			}
			
		}
	}
	
	// Play camera shake
	function PlayShakeOnHit(animEventName : name)
	{
		var camera : CCamera;
		camera = theCamera;
		
		if ( animEventName == 'FastAttack_t0' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.1);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'FastAttack_t1' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.2);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'FastAttack_t2' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.3);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'FastAttack_t3' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.3);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'StrongAttack_t1' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'StrongAttack_t2' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.6);
			camera.RaiseEvent('Camera_ShakeHit');
		} else
		if ( animEventName == 'StringAttack_t3' ) 
		{
			camera.SetBehaviorVariable('cameraShakeStrength', 0.7);
 			camera.RaiseEvent('Camera_ShakeHit');
		}
	}
	
	function SpawnBloodDecalOnHit()
	{
		/*var mat : IMaterial = thePlayer.GetRandomDecalMaterial();
		var orign,dirFront, dirUp : Vector;
		var angle : float;
		var size : float;
		var matrix : Matrix;
		if( mat )
		{
			dirFront.X = RandRangeF( -1.0, 1.0 );
			dirFront.Y = RandRangeF( -1.0, 1.0 );
			dirFront.Z = -1.0;
			dirFront.W = 1.0;
			
			angle = RandRangeF( 0, 2*Pi() );
			
			dirUp.X = CosF( angle );
			dirUp.Y = SinF( angle );
			dirUp.Z = 0.0f;
			dirUp.W = 1.0f;
			
			size = RandRangeF( 0.7, 1.2 );
			
			matrix = GetLocalToWorld();
			orign = GetWorldPosition();
			orign.Z += 1.0f;
			orign += matrix.Y;
			
			RendererDecalSpawn( orign, dirFront, dirUp, size, size, 2.0, 20.0, 10.0, mat );
		}*/
	}
	
	//////////////////////////////////////////////////////////// //////////////
	// Actor was hit by another actor
	function NotifyAttackedByPlayer()
	{
		var tags : array< name >;
		var i, count : int;
		tags = GetTags();
		
		count = tags.Size();
		for ( i = 0; i < count; i += 1 )
		{
			FactsAdd( tags[i] + "_attacked_by_PLAYER", 1, 180 ); 
		}
	}
	function NotifyPlayerAttackedByActor(attacker : CActor)
	{
		var tags : array< name >;
		var surroundingActors : array<CActor>;
		var i, size, count : int;
		var npc : CNewNPC;
		
		tags = attacker.GetTags();
		
		count = tags.Size();
		for ( i = 0; i < count; i += 1 )
		{
			FactsAdd( tags[i] + "_PLAYER_attacked_by", 1, 150 ); 
		}
		if(lastNotifyActorTime + EngineTimeFromFloat(5.0) < theGame.GetEngineTime())
		{
			lastNotifyActorTime = theGame.GetEngineTime();
			GetActorsInRange(surroundingActors, 10.0, '', this);
			size = surroundingActors.Size();
			for(i = 0; i < size; i += 1)
			{
				npc = (CNewNPC)surroundingActors[i];
				if(npc)
				{
					npc.NoticeActor( attacker );	
				}
			}
		}
	}
	function PoisonCheck(poisonBaseChance : float, target : CActor) : bool
	{
		var diceThrow : float;
		var actorPoisonRes : float;
		var chance : float;
		actorPoisonRes = target.GetCharacterStats().GetFinalAttribute('res_poison');
		chance = poisonBaseChance - actorPoisonRes;
		diceThrow = RandRangeF(0.01, 0.99);
		if(diceThrow < chance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function Hit( attacker : CActor, attackType : name, optional impossibleToBlock : bool, optional groupAttack : bool, optional killsTarget : bool, optional forceHitAnim : bool ) 
	{
		var currentWeaponId : SItemUniqueId;	
		var hitParams : HitParams;		
		var subjects : array<CActor>;
		var temp : float;
		var player : CPlayer;
		var damageMul : float;
		var args : array <string>;
		var isPlayer : bool;
		var playerBackHitBonus : float;
		var playerBackHitDamage : float;
		var onBeingHitResult : bool;
		var toxicityThreshold, poisonToxChance : float;
		var effectParams : W2CriticalEffectParams;
		var distanceToTarget : float;
		var arena : CArenaManager;

		isPlayer = ( this == thePlayer );

		if( attacker == thePlayer && !IsDummy() )// isPlayer || attacker == thePlayer)
		{
			thePlayer.KeepCombatMode();
			if(theGame.GetIsPlayerOnArena())
			{
				arena = theGame.GetArenaManager();
				arena.SetLastPlayerAttack();
			}
		}
		if(attacker == thePlayer)
		{
			NotifyAttackedByPlayer();
		}
		if(this == thePlayer && attacker != thePlayer)
		{	
			NotifyPlayerAttackedByActor(attacker);
			if(thePlayer.GetCharacterStats().HasAbility('story_s18_1'))
			{
				toxicityThreshold = thePlayer.GetCharacterStats().GetFinalAttribute('toxicity_threshold');
				if(toxicityThreshold <= 0.0f)
				{
					toxicityThreshold = 1.0f;
				}
				if(thePlayer.GetToxicity() > toxicityThreshold)
				{
					distanceToTarget = VecDistanceSquared(thePlayer.GetWorldPosition(), attacker.GetWorldPosition());
					if(distanceToTarget <= 25.0)
					{
						poisonToxChance = thePlayer.GetCharacterStats().GetFinalAttribute('hit_poison_chance');
						if(PoisonCheck(poisonToxChance, attacker))
						{
							effectParams.damageMax = thePlayer.GetCharacterStats().GetFinalAttribute('poison_damage');
							effectParams.damageMin = 0.7 * effectParams.damageMax;
							effectParams.durationMax = thePlayer.GetCharacterStats().GetFinalAttribute('poison_time');
							effectParams.durationMin = 0.7 * effectParams.durationMax;
							attacker.ForceCriticalEffect(CET_Poison, effectParams);
						}
					}
				}
			}
		}

		this.lastTimeAttacked = theGame.GetEngineTime();

		
		currentWeaponId = attacker.GetCurrentWeapon();
		
		hitParams.attacker = attacker;
		hitParams.attackType = attackType;
		hitParams.hitPosition = attacker.GetWorldPosition();
		hitParams.lethal = attacker.IsCurrentWeaponLethal();
		hitParams.impossibleToBlock = impossibleToBlock;
		hitParams.outDamageMultiplier = 1.0f;
		hitParams.forceHitEvent = forceHitAnim;
		if(attackType == 'RiposteAttack' && attacker == thePlayer)
		{
			if(theGame.GetIsPlayerOnArena())
			{
				theGame.GetArenaManager().AddBonusPoints(thePlayer.GetCharacterStats().GetAttribute('arena_riposte_bonus'));
			}
			hitParams.outDamageMultiplier = hitParams.outDamageMultiplier * thePlayer.GetCharacterStats().GetFinalAttribute('riposte_damage_mult');
		}
		if(!this.IsRotatedTowardsPoint( hitParams.hitPosition, 130 )&& !IsBoss())
		{
			hitParams.backAttack = true;
			if(attacker == thePlayer)
			{
				playerBackHitBonus = thePlayer.GetCharacterStats().GetFinalAttribute('hit_back_bonus');
				if(playerBackHitBonus <= 0)
				{
					playerBackHitBonus = 0.0;
				}
		
				hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + playerBackHitBonus;
				
			}
			else if(this == thePlayer)
			{
				playerBackHitDamage = thePlayer.GetCharacterStats().GetFinalAttribute('back_damage_mult');
				if(playerBackHitDamage <= 0)
				{
					playerBackHitDamage = 0.0;
				}
				if(theGame.GetDifficultyLevel() > 0)
				{
					hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + playerBackHitDamage;
				}
			}	
		}
		if(groupAttack)
		{
			hitParams.groupAttack = true;
		}
		if ( !isPlayer && hitParams.attacker == thePlayer )
		{
			if(thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
			{
				if ( thePlayer.GetWitcherType(WitcherType_Sword) )
				{
					thePlayer.SetAdrenaline( thePlayer.GetAdrenaline() + (thePlayer.GetCharacterStats().GetFinalAttribute('adrenaline_on_hit')*thePlayer.GetAdrenalineMult()) );		
				}	
			}
				
		}
		
		// No weapon - lethal = true
		if( currentWeaponId == GetInvalidUniqueId() )
		{
			Logf("ERROR: CActor::Hit attacker %1 has no weapon!", attacker.GetName());
			hitParams.lethal = true;
		}
		
		if( IsAnyCriticalEffectApplied() )
		{
			onBeingHitResult = OnBeingHitCriticalEffect( hitParams );
		}
		else
		{
			onBeingHitResult = OnBeingHit( hitParams );
		}
		
		if( onBeingHitResult || hitParams.impossibleToBlock)
		{	
			if(killsTarget)
				hitParams.killsTarget = true;
			HitDamage( hitParams );
		}
		else
		{
			if(!hitParams.attackDodged)
			{
				HitBlocked( hitParams );
			}
			else
			{
				return;
			}
		}
	}
	//Triggery critical effects
	timer function TimerBurnCheck(td : float)
	{
		var params : W2CriticalEffectParams;
		var playerState : EPlayerState;
		if(!this.IsCriticalEffectApplied(CET_Burn))
		{
			if(this == thePlayer)
			{
				playerState = thePlayer.GetCurrentPlayerState();
				if(playerState != PS_Exploration && playerState != PS_CombatFistfightDynamic && playerState != PS_CombatSteel && playerState != PS_CombatSilver && playerState != PS_Sneak)
				{
					return;
				}
			}
			params.durationMin = 4;
			params.durationMax = 6;
			this.ForceCriticalEffect(CET_Burn, params);
		}
	}
	timer function TimerPoisonCheck(td : float)
	{
		var params : W2CriticalEffectParams;
		if(!this.IsCriticalEffectApplied(CET_Poison))
		{
			this.ForceCriticalEffect(CET_Poison, params);
		}
	}
	timer function TimerBleedingCheck(td : float)
	{
		var params : W2CriticalEffectParams;
		if(!this.IsCriticalEffectApplied(CET_Bleed))
		{
			this.ForceCriticalEffect(CET_Bleed, params);
		}
	}
	function PlayLowHealthEffect();
	// What happens when the actor fails to block the hit
	private function HitDamage( hitParams : HitParams )
	{
		var vitality : float;
		var damageInt : int;
		if( IsStrongAttack( hitParams.attackType ) ) 
		{
			hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + 1.0;
		}
		if(hitParams.killsTarget && !IsBoss() && !IsInvulnerable() && !IsImmortal())
		{
			if(hitParams.attacker == thePlayer)
			{
				damageInt = RoundF(this.GetInitialHealth());
				theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_deadly") + " </span><span class='red'>" + damageInt + "</span>. ");
			}
			hitParams.damage = this.GetHealth() + 100.0f;	
		}
		else
		{
			if(hitParams.groupAttack)
			{
				//Check character development skills
				hitParams.outDamageMultiplier =  hitParams.outDamageMultiplier*thePlayer.GetCharacterStats().GetFinalAttribute('group_hit_mult');
			}
			hitParams.damage = CalculateDamage(hitParams.attacker, this, false, false, false, true, hitParams.outDamageMultiplier, false, false, hitParams.impossibleToBlock, hitParams.backAttack);
		}
		GetVisualDebug().AddText( 'dbgHit', "Hit damage: " + hitParams.damage , Vector(0.0, 0.0, 3.4), false, 12, Color(255, 0, 0, 255), false, 3);
		TryToApplyAllCritEffectsOnHit(this, hitParams.attacker, true);
							
		if (hitParams.damage > 0 || hitParams.killsTarget)  
		{
			if (hitParams.attacker == thePlayer)
			{
				thePlayer.IncreaseStaminaBuild();
				PlayShakeOnHit(hitParams.attackType);
			}
			if(this != thePlayer || !thePlayer.getActiveQuen() || hitParams.forceHitEvent)
			{
				NotifySpellHit( 'weapon' );
				if( IsAnyCriticalEffectApplied() )
				{
					OnHitCriticalEffect( hitParams ); 
				}
				else
				{
					OnHit( hitParams ); 
				}
			}			
		
			if ( hitParams.attackType != 'MagicAttack_t1' && hitParams.attackType != 'FistFightAttack_t1' ) // Magical attack do not cast blood at hit
			{
				if(this != thePlayer || !thePlayer.getActiveQuen() )
				{
					if( IsStrongAttack( hitParams.attackType ) ) 
					{
						PlayStrongBloodOnHit();
						
					}
					else
					{
						PlayBloodOnHit();
					}
					
					SpawnBloodDecalOnHit();
				}
			}
			PlayBloodyFXOnWeapon(hitParams.attacker, this);											
		}
		else
		{	
			//TryToPerformBlockResponse( hitParams );
			PlaySparksOnHit(this, hitParams);	
		}
		if(this == thePlayer && thePlayer.getActiveQuen())
		{
			theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_absorbs") + "</span>. ");
			return;
		}			
		DecreaseHealth( hitParams.damage, hitParams.lethal, hitParams.attacker ); 
		if(this == thePlayer)
		{
			vitality = this.GetCharacterStats().GetFinalAttribute('vitality');
			if(GetHealth() < 0.3*vitality)
			{
				PlayLowHealthEffect();
			}
		}
	}
	
	// What happens when actor manages to block the hit
	private function HitBlocked( hitParams : HitParams )
	{		
		if ( !IsCriticalEffectApplied( CET_Knockdown ) )
		{
			if(hitParams.attackReflected && !hitParams.groupAttack)
			{
				TryToPerformBlockResponse( hitParams );
			}
			PlaySparksOnHit(this, hitParams);	
		}
		//Geralt is protected by quen sign
		if(this == thePlayer)
		{
			if(thePlayer.getActiveQuen())
			{
				return;
			}
		}
		hitParams.damage = CalculateDamage(hitParams.attacker, this, false, false, false, true, 0, false, true, hitParams.impossibleToBlock);
		if (hitParams.damage > 0) 
		{	
			PlayBloodOnHit();
			PlayBloodyFXOnWeapon(hitParams.attacker, this);
		}
		DecreaseHealth( hitParams.damage, hitParams.lethal, hitParams.attacker );  // f calculatedamage uwzglednia redukcje pancerza od bloku, jesli przeciwnik ma redukowac caly inc damage 
		//DecreaseStamina( 0.25 );                               // blokiem musi miec duzy attrybut <damage_reduction_block> ustawiony w ability
		if (GetStamina() < 0.5)
		{
			if(this != thePlayer || !thePlayer.GetCombatV2())
			OnBlockRelease();
		}
	}
	
	// Actor is hit from position
	function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{	
		var hitParams : HitParams;
		var npc : CNewNPC;
		var damageReduction : float;
		var damageInt : int;
		var damageBasic : int;
		var reduction : int;
		var criticalMiss : bool;
		var arena : CArenaManager;
		npc = (CNewNPC)source;
		hitParams.attacker = source;
		hitParams.attackType = attackType;
		hitParams.hitPosition = hitPosition;
		hitParams.damage = damage;
		hitParams.lethal = lethal;
		hitParams.outDamageMultiplier = 1.0f;
		hitParams.forceHitEvent = forceHitEvent;
		hitParams.rangedAttack = rangedAttack;
		hitParams.damage = hitParams.damage*theGame.GetDamageDifficultyLevelMult(source, this);
		//Logf( GetName() + " has been hit from " + VecToString(hitPosition) + " damage: " + damage + " attackType" + attackType);
		GetVisualDebug().AddText( 'dbgHit', "Hit damage: " + hitParams.damage , Vector(0.0, 0.0, 3.4), false, 10, Color(255, 0, 0, 255), false, 3);
		if(source == thePlayer)
		{
			thePlayer.KeepCombatMode();
			NotifyAttackedByPlayer();
			if(theGame.GetIsPlayerOnArena())
			{
				arena = theGame.GetArenaManager();
				arena.SetLastPlayerAttack();
			}
		}
		if(this == thePlayer && source != thePlayer)
		{	
			NotifyPlayerAttackedByActor(source);
		}
		if(OnBeingHitPosition(hitParams))
		{
			if(this == thePlayer)
			{
				if( thePlayer.getActiveQuen())
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_absorbs") + "</span>. ");
					hitParams.damage = 0;
					if(hitParams.forceHitEvent)
					{
						OnHit( hitParams );
					}
				}
				else
				{
					if(magicAttack)
					{
						damageReduction = thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction_magicbonus');
						if(damageReduction > 1.0)
						{
							damageReduction = 1.0;
						}
						if(damageReduction < 0.0)
						{
							damageReduction = 0.0;
						}
						damageBasic = RoundF(hitParams.damage);
						hitParams.damage = hitParams.damage*(1-damageReduction);
						if(hitParams.damage < 5.0)
						{
							criticalMiss = true;
							hitParams.damage = 5.0;
						}
						damageInt = RoundF(hitParams.damage);
						reduction = damageBasic - damageInt;	
					}
					else
					{
						damageReduction = thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction');
						if(damageReduction < 0.0)
						{
							damageReduction = 0.0;
						}
						damageBasic = RoundF(hitParams.damage);
						hitParams.damage = hitParams.damage - damageReduction;
						if(hitParams.damage < 5.0)
						{
							criticalMiss = true;
							hitParams.damage = 5.0;
						}
						damageInt = RoundF(hitParams.damage);
						reduction = damageBasic - damageInt;
					}
					DecreaseHealth( hitParams.damage, hitParams.lethal, hitParams.attacker );	
					OnHit( hitParams );
					if(source)
					{
						if(criticalMiss)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ source.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_crtmiss") + "</span>. ");
						}
						else
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ source.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + damageInt + " (" + damageBasic + " - " + reduction + ")</span>. ");
						}
					}
				}
			}
			else
			{
				DecreaseHealth( hitParams.damage, hitParams.lethal, hitParams.attacker );	
				OnHit( hitParams );
			}
			
		}
		else
		{
			if(this == thePlayer && !thePlayer.getActiveQuen())
			{
				theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_absorbs") + "</span>. ");
			}
			HitBlocked(hitParams);
		}
	}
	
	// Perform block response if supported
	function TryToPerformBlockResponse( hitParams : HitParams )
	{

		if(this.CanPerformRespondedBlock() && hitParams.attacker.CanRespondToBlock())
		{	
			hitParams.attacker.OnAttackBlocked(hitParams);					
		}
		
	}
	
	// Can respond to block (overriden in player and npc)
	function CanRespondToBlock() : bool { return false; }
	
	// Can perform responded block (overriden in player and npc)
	function CanPerformRespondedBlock() : bool { return false; }
	
	// Hit event
	event OnHit( hitParams : HitParams );	
	
	// Hit event
	event OnHitCriticalEffect( hitParams : HitParams ) { OnHit( hitParams ); }
	
	// Being hit event - return false to reject hit
	event OnBeingHit( out hitParams : HitParams ) { return !IsBlockingHit(); }
	
	// Being hit with critical effect applied event
	event OnBeingHitCriticalEffect( out hitParams : HitParams ) { return OnBeingHit( hitParams ); }
	
	// Called when actor is about to being attacked
	event OnAttackTell( hitParams : HitParams );
	
	// Block should be released
	event OnBlockRelease();
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams );
	
	// Is strong attack
	function IsStrongAttack( attackType : name ) : bool
	{
		if( attackType == 'StrongAttack_t0' || attackType == 'StrongAttack_t1' || attackType == 'StrongAttack_t2' || attackType == 'StrongAttack_t3' || attackType == 'RiposteAttack' )
		{
			return true;
		}
		
		return false;
	}
	
	function IsFastAttack( attackType : name ) : bool
	{
		if( attackType == 'FastAttack_t0' || attackType == 'FastAttack_t1' || attackType == 'FastAttack_t2' || attackType == 'FastAttack_t3' )
		{
			return true;
		}
		
		return false;
	}
	function IsJumpAttack( attackType : name ) : bool
	{
		if( attackType == 'JumpAttack_t1' )
		{
			return true;
		}
		
		return false;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function ComboAttack( attackType : int, attackDir : EAttackDirection, attackDist : EAttackDistance ) : bool
	{
		var intAttackDir, intAttackDist : int;
		var res : bool;
		
		intAttackDir = (int)attackDir;
		intAttackDist = (int)attackDist;
	
		//MSZ : reset riposte achieviement counter
		if(this == thePlayer)
		{
			thePlayer.SetRiposteInRow(0);
		}
		SetBehaviorVariable( "comboAttackType", (float)attackType );
		SetBehaviorVariable( "comboAttackDir", (float)intAttackDir );
		SetBehaviorVariable( "comboAttackDist", (float)intAttackDist );
		
		LogChannel( 'states', "Combo attack: comboAttackType{ " + attackType + "}; comboAttackDir{ " + intAttackDir + "}; comboAttackDist{ " + intAttackDist + "};" );
		res = RaiseForceEvent( 'combo_attack' );
		
		if( !res )
		{
			Logf("ComboAttack failed %1", GetName() );
		}
		
		return res;
	}
	function GetReplacerAttackType() : EReplacerAttackType
	{
		if(this.GetInventory().ItemHasTag(this.GetCurrentWeapon(), 'ShortWeapon'))
		{
			return RAT_OneHanded;
		}
		else
		{
			return RAT_TwoHanded;
		}
	}
	function ComboAttackReplacer(attackTypeReplacer : EReplacerAttackType) : bool
	{
		var intAttackDir, intAttackDist : int;
		var attackType : int;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var res : bool;
		//Log( "*** Combo attack ***");
		attackType = (int)attackTypeReplacer;
		attackDir = AD_Front;
		attackDist = ADIST_Small;
		intAttackDir = (int)attackDir;
		intAttackDist = (int)attackDist;
		
		//MSZ : reset riposte achieviement counter
		if(this == thePlayer)
		{
			thePlayer.SetRiposteInRow(0);
		}
		
		SetBehaviorVariable( "comboAttackType", (float)attackType );
		SetBehaviorVariable( "comboAttackDir", (float)intAttackDir );
		SetBehaviorVariable( "comboAttackDist", (float)intAttackDist );
		
		res = RaiseForceEvent( 'standard_attack' );
		
		if( !res )
		{
			Logf("ComboAttack failed %1", GetName() );
		}
		
		return res;
	}
	
	function ComboBlock( comboAttack : SBehaviorComboAttack ) : bool
	{
		var intBlockDir, intBlockDist, intBlockType : int;
		var res : bool;
		
		//Log( "*** Combo block ***");
		
		intBlockDir = (int)comboAttack.direction;
		intBlockDist = (int)comboAttack.distance;
		intBlockType = comboAttack.type;
		
		SetBehaviorVariable( "comboBlockType", (float)intBlockType );
		SetBehaviorVariable( "comboBlockDir", (float)intBlockDir );
		SetBehaviorVariable( "comboBlockDist", (float)intBlockDist );
		SetBehaviorVariable( "comboBlockHitTime", comboAttack.parryHitTime );
		SetBehaviorVariable( "comboBlockLevel", (float)comboAttack.level );
		
		// Block
		SetBehaviorVariable( "comboBlockParry", 1.f );
		
		res = RaiseForceEvent( 'combo_block' );
		
		if( !res )
		{
			Logf("ComboBlock failed %1", GetName() );
		}
		
		return res;
	}
	
	function ComboHit( comboAttack : SBehaviorComboAttack ) : bool
	{
		/* NEW 
		var varBlockResponse : float;
		var hitTime, hitLevel : Vector;
		
		Log( "*** Combo hit ***");
		
		varBlockResponse = (float)(int)CAR_HitFront;
		
		hitTime = Vector( comboAttack.attackHitTime0, comboAttack.attackHitTime1, comboAttack.attackHitTime2, comboAttack.attackHitTime3 );
		hitLevel = Vector( comboAttack.attackHitLevel0, comboAttack.attackHitLevel1, comboAttack.attackHitLevel2, comboAttack.attackHitLevel3 );
				
		SetBehaviorVariable( "comboBlockResponse", varBlockResponse );
		
		SetBehaviorVectorVariable( "comboBlockHitTime", hitTime );
		SetBehaviorVectorVariable( "comboBlockHitLevel", hitLevel );

		// Hit
		SetBehaviorVariable( "comboBlockParry", 0.f );
		
		return RaiseForceEvent( 'combo_block' );
		
		return false; */
		
		/* OLD */
		var intBlockDir, intBlockDist, intBlockType : int;
		var res : bool;
		
		Log( "*** Combo hit ***");
		
		intBlockDir = (int)comboAttack.direction;
		intBlockDist = (int)comboAttack.distance;
		intBlockType = comboAttack.type;
				
		SetBehaviorVariable( "comboBlockType", (float)intBlockType );
		SetBehaviorVariable( "comboBlockDir", (float)intBlockDir );
		SetBehaviorVariable( "comboBlockDist", (float)intBlockDist );
		SetBehaviorVariable( "comboBlockHitTime", comboAttack.attackHitTime );
		SetBehaviorVariable( "comboBlockLevel", (float)comboAttack.level );
		
		// Hit
		SetBehaviorVariable( "comboBlockParry", 0.f );
		
		res = RaiseForceEvent( 'combo_block' );
		
		if( !res )
		{
			Logf("ComboHit failed %1", GetName() );
		}
		
		return res;
	}
	
	event OnComboAttack( canBeBlocked : bool, comboAttack : SBehaviorComboAttack )
	{
		/*Log( "*** On Combo attack ***");
		Log( "level	 " + comboAttack.level );
		Log( "attack " + comboAttack.attackAnimation );
		Log( "parry  " + comboAttack.parryAnimation );
		Log( "a time " + comboAttack.attackTime );
		Log( "p time " + comboAttack.parryTime );
		Log( "a hit  " + comboAttack.attackHitTime );
		Log( "p hit  " + comboAttack.parryHitTime );
		Log( "a h le " + comboAttack.attackHitLevel );
		Log( "p h le " + comboAttack.parryHitLevel );
		Log( "********************");*/
	}
	
	event OnRespondToComboAttack( attacker : CActor, canBeBlocked : bool, comboAttack : SBehaviorComboAttack );
	event OnBeforeAttack();
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnArrowHit(hitParams : HitParams, projectile : CRegularProjectile)
	{
		var reduction, damage, health : float;
		if(hitParams.attacker == thePlayer && this != thePlayer)
		{
			reduction = GetCharacterStats().GetFinalAttribute('damage_reduction');
			damage = hitParams.damage - reduction;
			health = GetHealth();
			if(damage >= health)
			{
				Log("Achievement unlocked : ACH_RICOCHET");
				theGame.UnlockAchievement('ACH_RICOCHET');
			}
		}
		//HitDamage(hitParams);
		HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal, hitParams.attacker, false, true);
		//projectile.Destroy();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
			
	// On spawned
	event OnSpawned( spawnData : SEntitySpawnData )
	{

		super.OnSpawned(spawnData);
		SetCombatSlotOffset( 1.9 );
		combatIdleGroupIdx = -1;

		GetVisualDebug().AddAxis( 'actor' );
		
		ResetAllowCutParts();
		if(this.GetCharacterStats().HasAbility('Stinker _Debuf'))
		{
			this.GetCharacterStats().RemoveAbility('Stinker _Debuf');
		}
		if( spawnData.restored )
		{			
			RestoreCriticalEffects();
		}
		else
		{
			ResetStats();
		}
	}
	
	function ResetAllowCutParts()
	{
		readyToCut.Head = false;
		readyToCut.LeftArm = false;
		readyToCut.RightArm = false;
		readyToCut.Torso = false;
	}

	timer function CutResetTimer( timeDelta : float )
	{
		ResetAllowCutParts();
	}
	private function AddCutResetTimer()
	{
		AddTimer('CutResetTimer', 2.0, false);
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnAbilityAdded( abilityName : name )
	{
		Log( this + " has ability " + abilityName + " added" );
	}
	
	event OnItemUse( itemId : SItemUniqueId )
	{
		Log( "Item was used : " + GetInventory().GetItemName( itemId ) );
	}
	
	function GetPriceMult() : float
	{
		return 1.f;
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//	// Get actor's health
	function GetHealth() : float
	{		
		return health;
	} 
	
	//Get actor's initial health
	function GetInitialHealth() : float
	{		
		return initialHealth;
	}
	
	// Get actor's health percentage
	function GetHealthPercentage() : float
	{
		return 100.0*health/initialHealth;
	}

	// Get actor's stamina
	function GetStamina() : float
	{		
		return stamina;
	}
	function GetMaxStamina() : float
	{		
		return initialStamina;
	}
	

	// Get actor's level
	function GetLevel() : int
	{		
		return level;
	}

	// Set actor's level
	function SetLevel(set_level : int)
	{		
		level = set_level;
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	private final function GetImmortalityModeRuntime() : EActorImmortalityMode
	{
		if( theGame.GetEngineTime() > immortalityTimeRuntime )		
			return AIM_None;		
		else
			return immortalityModeRuntime;
	}
	
	private final function GetImmortalityModePersistent() : EActorImmortalityMode
	{
		return immortalityMode;
	}
	
	// Get actor's imortalitgy mode
	final function GetImmortalityMode() : EActorImmortalityMode
	{
		if( immortalityModeScene != AIM_None )
			return immortalityModeScene;
		else if( immortalityMode != AIM_None )
			return immortalityMode;
		else
			return GetImmortalityModeRuntime();
	}
	
	// Get actor's invulnerability
	final function IsInvulnerable() : bool
	{
		return immortalityModeScene == AIM_Invulnerable || immortalityMode == AIM_Invulnerable || GetImmortalityModeRuntime() == AIM_Invulnerable;
	}
	
	// Get actor's invulnerability
	final function IsImmortal() : bool
	{
		return immortalityModeScene == AIM_Immortal || immortalityMode == AIM_Immortal || GetImmortalityModeRuntime() == AIM_Immortal;
	}
	
	// Set actor's imortalitgy mode
	final function SetImmortalityModePersistent( mode : EActorImmortalityMode )
	{
		immortalityMode = mode;
	}
	
	// Set actor's invulnerability with timout
	final function SetImmortalityModeRuntime( mode : EActorImmortalityMode, optional timeout : float )
	{
		if( timeout <= 0.0 )
			timeout = 10.0f;
		
		immortalityModeRuntime = mode;
		if( mode == AIM_None )
			immortalityTimeRuntime = EngineTime();
		else
			immortalityTimeRuntime = theGame.GetEngineTime() + timeout;
	}
	
	// Actor will be mortal
	final function ClearImmortality()
	{
		immortalityMode = AIM_None;
		immortalityModeRuntime = AIM_None;
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Is actor dead
	final function IsDead() : bool
	{
		return ( GetCurrentStateName() == 'Dead' );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Is actor unconscious
	final function IsUnconscious() : bool
	{
		return ( GetCurrentStateName() == 'Unconscious' );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Reset actors stats to initial value
	function ResetStats()
	{
		var args : array<string>;
		
		if ( this == thePlayer ) thePlayer.SetBasicAbility(); // set def ability 

		health = GetCharacterStats().GetFinalAttribute( 'vitality' );
		initialHealth = health;
		if( health == 0.0 && this != thePlayer )
		{
			GetCharacterStats().AddAbility('Default NPC');
			Log("Warning: Vitality is 0, adding ability 'Default NPC' "+GetName() );			
			health = GetCharacterStats().GetFinalAttribute( 'vitality' );
		}
		SetInitialHealth( health );
		SetInitialStamina( GetCharacterStats().GetFinalAttribute( 'endurance' ) );
		IncreaseStamina( initialStamina );
		
		
		SetAlive( true );

		if (this.GetCharacterStats().HasAbility('type_invulnerable'))
		{
			Log(this.GetName() + " set to Invulnerable - cant be killed");
			SetImmortalityModePersistent( AIM_Invulnerable );
		}
		
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////
	timer function StinkerDebufRemove(td : float)
	{
		if(this.GetCharacterStats().HasAbility('Stinker _Debuf'))
		{
			this.GetCharacterStats().RemoveAbility('Stinker _Debuf');
		}
	}	
	// Kill actor
	function Kill( optional force : bool, optional attacker : CActor, optional deathData : SActorDeathData )
	{
		if( force )
		{
			SetAlive(true);
		}
		DecreaseHealth( health + 1, true, attacker, deathData );
	}
	
	// called from code
	private function InterfaceKill( force : bool, attacker : CActor )
	{
		Kill( force, attacker );
	}
	
	// Stun actor
	function Stun( optional force : bool, optional attacker : CActor, optional deathData : SActorDeathData )
	{
		if( force )
		{
			SetAlive(true);
		}
		DecreaseHealth( health + 1, false, attacker, deathData );
	}
	
	// called from code
	private function InterfaceStun( force : bool, attacker : CActor )
	{
		Stun( force, attacker );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	
	// Check if actor should be dead
	function DeathCheck(lethal : bool, attacker : CActor, deathData : SActorDeathData )
	{
		if ( health <= 0.0 && IsAlive() )
		{
			if( !IsImmortal() )
			{
				if( lethal )
				{	
					SetAlive( false );					
					EnterDead( deathData );
					
					// Inform player
					if( attacker == thePlayer )
					{
						thePlayer.OnActorKilled( this );
					}
				}
				else
				{
					SetAlive( false );
					EnterUnconscious( deathData );
					
					// Inform player
					if( attacker == thePlayer )
					{
						thePlayer.OnActorStunned( this );						
					}
				}
			}
		}
	}
	
	function SetInitialHealth( amount : float )
	{
		if ( initialHealth != amount )
		{
			initialHealth = amount;
	
			if ( ! IsBoss() && this == thePlayer.GetEnemy() )
			{
				theHud.m_hud.SetNPCHealthPercent( 100 * health / initialHealth );
			}
		}
	}
	
	private function SetHealthToMax()
	{
		health = initialHealth;
		
		if ( this == thePlayer )
		{		
			theHud.m_hud.SetPCHealth( health, initialHealth );
		}		
		if ( ! IsBoss() && this == thePlayer.GetEnemy() )
		{		
			theHud.m_hud.SetNPCHealthPercent( 100 * health / initialHealth );
		}
	}	
	// Set health to given value
	function SetHealth( value : float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData  )
	{
		value = MinF( MaxF( value, 0.f ), initialHealth );
		if ( health != value || value == 0.0 )
		{
			health = value;
			
			DeathCheck( lethal, attacker, deathData );
	
			if ( ! IsBoss() && this == thePlayer.GetEnemy() )
			{		
				theHud.m_hud.SetNPCHealthPercent( 100 * health / initialHealth );
			}
		}
	}
	
	// Decrease actor's health
	function DecreaseHealth( amount : float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData )
	{
		if( IsAlive() )
		{
			if( amount < 0 || ! IsInvulnerable() )
			{	
					SetHealth( health - amount, lethal, attacker, deathData );
			}
		}
	}
				
	// Increase actor's health
	function IncreaseHealth( amount : float )
	{
		if( IsAlive() )
		{
			if( amount > 0 || ! IsInvulnerable() )
			{
				SetHealth( health + amount, true, NULL );
			}			
		}			
	}

	function SetInitialStamina( amount: float )
	{
		initialStamina = amount;
	}

	// Decrease actor's stamina
	function DecreaseStamina( amount: float )
	{
		var previousStamina : float;
		
		previousStamina = stamina;
		
		if( amount != 0.0 )
		{
			stamina = stamina - amount;
			
			if(previousStamina <= stamina)
			{
				if(theGame.GetIsPlayerOnArena() && this == thePlayer)
				{
					theGame.GetArenaManager().SetPlayerCheated(true);
				}
			}
			
			if ( stamina < -1.0 ) stamina = -0.9;
			
			CalculateStaminaDamageMult();
		}
	}
	
	// Increase actor's stamina
	function IncreaseStamina( amount: float )
	{
		if( amount != 0.0 )
		{
			stamina = stamina + amount;
			if ( stamina > initialStamina ) stamina = initialStamina;
			
			CalculateStaminaDamageMult();
		}
	}
	
	event OnCutsceneDeath()
	{
		var deathData : SActorDeathData;
		deathData.onlyDestruct = true;
		EnterDead( deathData );
	}
	
	///////////////////////////////////////////////////////////////////
	// stamina - damage mult

	function GetStaminaDamageMult() : float
	{
		return Stamina_DamageMult;
	}

	function CalculateStaminaDamageMult()
	{
		Stamina_DamageMult = 1.f;
	}	
	
	//////////////////////////////////////////////////////////////////////////////////////////

	// Enter dead state (must be overridden in derived class!)
	private function EnterDead( optional deathData : SActorDeathData );
		
	// Enter uncoscious state (must be overridden in derived class!)
	private function EnterUnconscious( optional deathData : SActorDeathData );
		
	function BreakUnconscious()
	{
		OnBreakUncoscious();
	}
	
	event OnBreakUncoscious();
	
	// Enter uncoscious state (must be overridden in derived class!)
	//private function EnterPreDeath();
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	final function GetCombatSlots() : CCombatSlots
	{
		if( !combatSlots )
		{
			combatSlots = new CCombatSlots in this;
			combatSlots.Initialize();
		}
		
		return combatSlots;

	}
	
	timer function UpdateCombatSlots( timeDelta : float )
	{
		combatSlots.UpdateCombatSlots();
	}
	
	timer function UpdateCombatIdleSlots( timeDelta : float )
	{
		combatSlots.UpdateCombatIdleSlots();
	}
	
	function GetCombatSlotOffset() : float
	{
		return combatSlotOffset;
	}
	
	function SetCombatSlotOffset( val : float )
	{
		combatSlotOffset = val;
	}
	
	event OnCombatSlotLost();
	
	event OnTicketChanged( poolType : W2TicketPoolType );
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	event OnStaticFistfightWon();
	
	event OnStaticFistfightRequest() { return false; }
	
	//////////////////////////////////////////////////////////////////////////////////////////	

	// Is monser	
	function IsMonster() : bool
	{
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////////	
	
	// enables a static LookAt
	import function EnableStaticLookAt( point : Vector, duration : float );

	// enables a dynamic LookAt
	import function EnableDynamicLookAt( node : CNode, duration : float );
	
	// Disables a LookAt
	import function DisableLookAt();
	
	// Set look at mode - don't forget to call ResetLookAtMode. The best place for it is OnEnterState.
	import function SetLookAtMode( mode : ELookAtMode );
	
	// Reset look at mode. The best place for it is OnLeaveState.
	import function ResetLookAtMode( mode : ELookAtMode );
	
	// Cut body part if possible
	// bodyPartNamePrefixA and bodyPartNamePrefixB are the names of body parts to be switched into 'cut' state
	// ( bodyPartNamePrefixA is required, but you can pass empty string as bodyPartNamePrefixB )
	// boneName is the name of first bone in the cut hierarchy ( 'l_forearm' for example )
	// it must be one of the bones directly mapped onto a ragdoll bones ( simple mapping ).
	// Returns true if succeded.
	import function CutBodyPart( bodyPartNamePrefixA, bodyPartNamePrefixB : string, boneName : name ) : bool;
	
	//MSZ "parry" block flag
	function SetBlock(blockingHitFlag : bool)
	{
		blockActive = blockingHitFlag;

	}
	// Block
	//
	function IsBlockingHit () : bool
	{	
		if(blockActive)
		{
			return true;
		}
		else
		{
			return ( blockHitTime > theGame.GetEngineTime() ); 
		}
	}
	
	function SetBlockingHit( value : bool, optional timeout : float )
	{	
		if( value )
		{
			if( timeout > 0.0 )
				blockHitTime = theGame.GetEngineTime() + timeout;
			else		
				blockHitTime = theGame.GetEngineTime() + 10.0f;
		}
		else
		{
			blockHitTime = EngineTime();
		}
	}
	
	//Weakened
	function IsWeakened () : bool
	{	
		return weakened; 
	}
	
	function SetWeakened (value:bool)
	{	
		weakened = value;	
	}
	
	//SuperBlock
	function Issuperblock() : bool
	{	
		return theGame.GetEngineTime() < superblockTime;
	}
	
	function SetSuperblock (value:bool)
	{	
		if( value )
			superblockTime =  theGame.GetEngineTime() + 10.0;
		else
			superblockTime = EngineTime();
	}
	
	function LockGestures( lock : bool )
	{
		gesturesLocked = lock;
	}
	
	function LockLookat( lock : bool )
	{
		lookatLocked = lock;
	}
	
	event OnTalkingActorChanged( talkingActor : CActor, optional isChoice : bool, optional isGameplay : bool )
	{
		if ( isGameplay == true )
		{
			this.DisableLookAt();
		}
		if ( talkingActor == this && isChoice == false && gesturesLocked == false )
		{
		}
		else
		{	
			//Sleep( RandF() );
			if ( isGameplay == true && lookatLocked == false )
			{
				this.EnableDynamicLookAt( talkingActor, 10.f );
			}
			LockGestures( false );
			LockLookat( false );
		}
	}
	
	function ShowHealthBar()
	{
		theHud.m_hud.SetNPCName( GetDisplayName() );
		theHud.m_hud.SetNPCHealthPercent( GetHealthPercentage() );
		theHud.m_hud.SetNPCBarPos( this.GetWorldPosition() );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	timer function RemoveCombatSelection( timeDelta : float )
	{
		SetCombatHighlight( false );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	final function IsCriticalEffectApplied( effectType : ECriticalEffectType ) : bool
	{
		var i : int;
		for( i=criticalEffects.Size()-1; i>=0; i-=1 )
		{
			if( criticalEffects[i] && criticalEffects[i].GetType() == effectType )
			{
				return true;
			}	
		}
		
		return false;
	}
	
	final function IsAnyCriticalEffectApplied() : bool
	{
		return criticalEffects.Size() > 0;
	}
	
	final function ApplyCriticalEffect( effectType : ECriticalEffectType, attacker : CActor, optional duration : float, optional playerIsSource : bool ) : bool
	{	
		var res : bool;
		var s : int;
		s = criticalEffects.Size();
		if(this.IsInvulnerable() || this.IsImmortal())
			return false;
		res = theGame.GetCriticalEffectsMgr().ApplyEffect( effectType, this, attacker, duration, playerIsSource );
		if( s==0 && criticalEffects.Size() > 0 )
		{
			AddTimer('UpdateCriticalEffects', 0.5, true, true );
		}
		return res;		
	}
	
	final function ForceCriticalEffect( effectType : ECriticalEffectType, params : W2CriticalEffectParams, optional playerIsSource : bool ) : bool
	{	
		var res : bool;
		var s : int;
		if(this.IsInvulnerable() || this.IsImmortal())
			return false;
		s = criticalEffects.Size();
		res = theGame.GetCriticalEffectsMgr().ForceEffect( effectType, this, params, playerIsSource );
		if( s==0 && criticalEffects.Size() > 0 )
		{
			AddTimer('UpdateCriticalEffects', 0.5, true, true );
		}
		return res;		
	}
	
	final function RestoreCriticalEffects()
	{
		var i,s : int;
		s = criticalEffects.Size();
		for( i=0; i<s; i+=1 )
		{
			criticalEffects[i].StartEffect();
		}
		
		if( s > 0 )
		{
			AddTimer('UpdateCriticalEffects', 0.5, true, true );
		}
	}
	
	function IsCriticalEffectAppliedPriority() : bool
	{
		if(IsCriticalEffectApplied(CET_Stun))
			return true;
		if(IsCriticalEffectApplied(CET_Knockdown))
			return true;
		return false;
	}
	
	timer function UpdateCriticalEffects( timeDelta : float )
	{
		var i : int;
		var erased : bool = false;
		
		for( i=criticalEffects.Size()-1; i>=0; i-=1 )
		{
			if( criticalEffects[i].Update( timeDelta ) )
			{
				criticalEffects.Erase(i);				
				erased = true;
			}
		}
		
		if ( erased )
		{
			OnCriticalEffectsChanged();
		}
		
		if( criticalEffects.Size() == 0 )
		{
			RemoveTimer('UpdateCriticalEffects');
		}
	}
			
	event OnCriticalEffectsChanged() {}
	
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float ) { return false; }
	event OnCriticalEffectRestart( effectType : ECriticalEffectType, duration : float ) { return false; }
	event OnCriticalEffectStop( effectType : ECriticalEffectType ) { return false; }
	
	// Checks if actor resists defined critical effect
	function TestRes( effectType : ECriticalEffectType ) : bool
	{
		var effectResName : name;
		
		switch( effectType )
		{
			case CET_Poison:
				effectResName = 'res_poison';
				break;
			case CET_Laming:
				effectResName = 'res_laming';
				break;
			case CET_Bleed:
				effectResName = 'res_bleed';
				break;
			case CET_Burn:
				effectResName = 'res_burn';
				break;
			case CET_Knockdown:
				effectResName = 'res_knockdown';
				break;
			case CET_Disarm:
				effectResName = 'res_disarm';
				break;
			case CET_Drunk:
				effectResName = 'res_drunk';
				break;
			case CET_Stun:
				effectResName = 'res_stun';
				break;
			case CET_Unbalance:
				effectResName = 'res_unbalance';
				break;
			case CET_Falter:
				effectResName = 'res_falter';
				break;
			case CET_Freeze:
				effectResName = 'res_freeze';
				break;
			case CET_Blind:
				effectResName = 'res_blind';
				break;
			case CET_Immobile:
				effectResName = 'res_immobile';
				break;
			case CET_Fear:
				effectResName = 'res_fear';
				break;
			default:
				Log( "CActor::TestRes(ECriticalEffectType) - tested critical effect type doesn't exist!" );
				return false;
		}
		
		return Rand(100) > 100 * GetCharacterStats().GetFinalAttribute( effectResName );
	}
	
	function TestResByName( resistName : name ) : bool
	{
		return Rand(100) > 100 * GetCharacterStats().GetFinalAttribute( resistName );
	}
			
	//////////////////////////////////////////////////////////////////////////////////////////	
	// Collision handling
	
	// Collision between two components has occured
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		//var vd : CVisualDebug = GetVisualDebug();
		//vd.AddText( 'collision', "Collision", collisionInfo.firstContactPoint );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	// Exploration traversing
	
	event OnStartTraversingExploration() 
	{
		return true;
	}
	
	event OnFinishTraversingExploration()
	{
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////	
	// Update visual debug information
	function UpdateVisualDebug()
	{
		var vd : CVisualDebug;
		var pos : Vector;
		var col : Color;
		var displayMode : name;
		var isPlayer : bool;
		var p0,p1 : Vector;
		var str : string;
		var immMode : EActorImmortalityMode;
		var i : int;
		
		displayMode = theGame.aiInfoDisplayMode;
		isPlayer = this == thePlayer;
				
		if(displayMode == 'all' || (!isPlayer && displayMode == 'npc')  || ( isPlayer && displayMode == 'player' ) )
		{
			vd = GetVisualDebug();
			pos = GetVisualDebugPos();
			col = GetVisualDebugColor();
		
			vd.AddText( 'dbgName'	, "Name: "+GetName()				, pos, false, 0, col, false, 1.0 );
			vd.AddText( 'dbgVoiceTag', "Voicetag: " + GetVoicetag()		, pos, false, 1, col, false, 1.0 );
			vd.AddText( 'dbgState'	, "State: "+GetCurrentStateName()	, pos, false, 2, col, false, 1.0 );
			vd.AddText( 'dbgBeh'	, "Behavior: "+GetBehaviorInstancesAsString(), pos, false, 3, col, false, 1.0 );
			vd.AddText( 'dbgHealth'	, "Health: "+CeilF(GetHealth())		, pos, false, 4, col, false, 1.0 );
			vd.AddText( 'dbgAlive'	, "Alive: "+IsAlive()				, pos, false, 5, col, false, 1.0 );
			
			immMode = GetImmortalityMode();
			if( immMode != AIM_None )
			{
				if( immortalityModeScene != AIM_None )
					str = " (Scene)";
				else if( immortalityMode != AIM_None )
					str = " (Persistent)";
				else if( immortalityModeRuntime != AIM_None )
					str = " (Runtime)";
			}
			vd.AddText( 'dbgImmortality'	, "Immortality: "+immMode+str	, pos, false, 6, col, false, 1.0 );				
			vd.AddText( 'dbgHidden'	, StrFormat("Hidden: %1 (%2)", IsHidden(), isHidden ), pos, false, 7, col, false, 1.0 );
			vd.AddText( 'dbgWeapon'	, "Current weapon: "+GetCurrentWeaponDebugName()+" (lethal: "+IsCurrentWeaponLethal()+")", pos, false, 8, col, false, 1.0);			
			if( combatSlots )
			{
				vd.AddText( 'dbgFreeCombatSlots', "FreeCombatSlots: "+combatSlots.GetNumFreeCombatSlots(), pos, false, 10, col, false, 1.0 );
			}
			else
			{
				vd.AddText( 'dbgFreeCombatSlots', "FreeCombatSlots: combatSlots NULL", pos, false, 10, col, false, 1.0 );
			}
			
			if( criticalEffects.Size() > 0 )
			{
				for( i=criticalEffects.Size()-1; i>=0; i-=1 )
				{
					str+=criticalEffects[i].GetType()+" ";
				}
				vd.AddText('dbgCritical', str, pos, false, 11, col, false, 1.0 );
			}
			else
			{	
				vd.RemoveText('dbgCritical');
			}
						
			if( IsExternalyControlled() )
			{
				vd.AddText( 'dbgExtCtrl', "ExternalyControlled", pos, false, 15, Color(0, 255, 0), false, 1.0 );
			}
			else
			{
				vd.RemoveText( 'dbgExtCtrl' );
			}
		}
		else if( displayMode == 'name' )
		{		
			vd = GetVisualDebug();
			pos = GetVisualDebugPos();
			col = GetVisualDebugColor();			
			pos.Z -= 1.0;
			vd.AddText( 'dbgName'	, "Name: "+GetName()				, pos, false, 0, col, false, 1.0 );	
		}
	}
	
	function GetVisualDebugPos() : Vector
	{
		return Vector(0.0, 0.0, 3.6);
	}
	
	function GetVisualDebugColor() : Color
	{
		return Color(255, 255, 255);
	}
	
	///////////////////////////////////////////////////////////////////
	// Debug
	
	//...

	event OnPlayerThrowBomb();
	

}
