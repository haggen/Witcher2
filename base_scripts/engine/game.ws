/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CGame
/** Copyright © 2009
/***********************************************************************/

import struct SGameInputMapping
{
	import var gameInputName : name;
	import var inputKey : string;
	import var activation : float;
}; 

import class CGame extends CObject
{

	private var tutorialenabled					: bool;
	private var tutorialStartingItems			: array< SItemUniqueId >;
	private var tutorialStartingItemsNames		: array< name >;
	private var tutorialText 					: string;
	private var tutorialText1 					: string;
	private var tutorialText2 					: string;
	private var tutorialText3 					: string;
	private var tutorialText4 					: string;
	private var tutorialIcon1 					: string;
	private var tutorialIcon2 					: string;
	private var tutorialIcon3 					: string;
	private var tutorialIcon4 					: string;
	private var tutorialImage 					: string;
	private var tutorialNewText 				: array< string >;
	private var tutorialNewIcon 				: array< string >;
	private var tutorialTask 					: string;
	
	private var oldTutorialId					: string;
	private var oldTutorialImg 					: string;
	private var oldTutorialTitle 				: string;
	private var oldTutorialText 				: string;
	
	private var tutorialOldPanelShown 			: bool;
	private var tutorialPanelHidden 			: bool;
	private var tutorialPanelShowIcons 			: bool;
	private var tutorialPanelByPlayer 			: bool;
	private var tutorialHideOldPanels 			: bool;
	private var tutorialPanelNew 				: bool;
	private var tutorialInvTrashBlocked 		: bool;
	private var newGameAfterTutorial 			: bool;
	private var isSleepToDawn 					: bool;
	private	var isPlayerResting 				: bool;
	private	var isPlayerMeditating 				: bool;
	private	var isPlayerInInventory 			: bool;
	private var isMeditationDrinkingBlocked 	: bool;
	private var	isMeditationRestingBlocked 		: bool;
	private var isMeditationAlchemyBlocked	 	: bool;
	private var isMeditationCharacterBlocked 	: bool;
	private var isMenuCharacterBlocked 			: bool;
	private var isMenuJournalBlocked 			: bool;	
	private var isMenuMapBlocked 				: bool;	
	private var isMenuInventoryBlocked 			: bool;	
	
	default tutorialenabled 					= false;
	default tutorialPanelHidden 				= true;
	default tutorialPanelNew 					= false;
	default newGameAfterTutorial 				= false;
	default tutorialPanelShowIcons 				= false;
	default tutorialPanelByPlayer 				= false;
	default tutorialHideOldPanels 				= false;
	default tutorialOldPanelShown 				= false;
	default tutorialInvTrashBlocked 			= false;
	default isSleepToDawn 						= false;
	default isPlayerResting 					= false;
	default isPlayerMeditating 					= false;
	default isPlayerInInventory 				= false;
	default isMeditationDrinkingBlocked 		= false;
	default isMeditationRestingBlocked 			= false;
	default isMeditationCharacterBlocked 		= false;
	default isMeditationAlchemyBlocked 			= false;
	default isMenuCharacterBlocked 				= false;
	default isMenuJournalBlocked	 			= false;
	default isMenuMapBlocked 					= false;
	default isMenuInventoryBlocked		 		= false;
		
	// Returns if build is final (no debug stuff present)
	import final function IsFinalBuild() : bool;
	
	// Returns if this is a demo build
	import final function IsDemoBuild() : bool;

	// Are we in game ?
	import final function IsActive() : bool;	

	// Is game paused
	import final function IsPaused() : bool;
	
	// Pause game
	import final function Pause();

	// Unpause game
	import final function Unpause();
	
	// Pause active cutscenes
	import final function PauseCutscenes();
	
	// Unpause active cutscenes
	import final function UnpauseCutscenes();
	
	// Exit game
	import final function ExitGame();
	
	// Is game actively paused
	import final function IsActivelyPaused() : bool;
	
	// Set active pause
	import final function SetActivePause( flag : bool );

	// Get engine time (real time counted when game is not paused)
	import final function GetEngineTime() : EngineTime;
	
	// Get engine time scale
	import final function GetTimeScale() : float;
	
	// Set engine time scale
	import final function SetTimeScale( timeScale : float );
	
	// Get game time (not counted when game paused, used for the gameplay not for micro timing)
	import final function GetGameTime() : GameTime;
	
	// Sets new game time
	import final function SetGameTime( time : GameTime, callEvents : bool );

	// Sets world time speed
	import final function SetHoursPerMinute( f : float );
	
	// Sets default world time speed
	function ResetHoursPerMinute()
	{
		SetHoursPerMinute( 0.25f );
	}
	
	///////////////////////////////////////
	function ShowOldTutorial( enabled : bool )
	{
		tutorialOldPanelShown = enabled;
	}
	// set tutorial big panel on / off
	function TutorialPanelHidden( is : bool )
	{
		tutorialPanelHidden = is;
	}

	function TutorialPanelOpenByPlayer( isByPlayer : bool )
	{
		tutorialPanelByPlayer = isByPlayer;
	}
	
	function HideOldTutorialPanels( hide : bool )
	{
		tutorialHideOldPanels = hide;
	}
	
	function SetOldTutorialData( img : string, title : string, text : string )
	{
		oldTutorialImg = img;
		oldTutorialTitle = title;
		oldTutorialText = text;
	}
	
	function SetOldTutorialDataNew( tutorialId : string, img : string )
	{
		oldTutorialImg = img;
		oldTutorialId = tutorialId;
	}

	// set tutorial big panel to new version
	function SetTutorialUseNew( is : bool )
	{
		tutorialPanelNew = is;
	}
	
	//enables tutorial
	function IsTutorialEnabled( ) : bool
	{
		return tutorialenabled;
	}	
	function TutorialEnabled( is : bool )
	{
		tutorialenabled = is;
	}
	
	function SetNewGameAfterTutorial( is : bool )
	{
		newGameAfterTutorial = is;
	}
	
	function TutorialIsPlayerResting( isResting : bool )
	{
		isPlayerResting = isResting;
	}	
	
	function TutorialPlayerInMeditation( isMeditating : bool )
	{
		isPlayerMeditating = isMeditating;
	}
	
	function TutorialPlayerInInventory( isInInventory : bool )
	{
		isPlayerInInventory = isInInventory;
	}	
	
	function TutorialGetItems()
	{
		var i, size 	: int;
		var itemName 	: name;
		var itemId 		: SItemUniqueId;
		var inv			: CInventoryComponent = thePlayer.GetInventory();
		
		thePlayer.GetInventory().GetAllItems( tutorialStartingItems );
		
		size = tutorialStartingItems.Size();
		
		if( tutorialStartingItemsNames.Size() > 0 )
		{
			tutorialStartingItemsNames.Clear();
		}
				
		for( i = 0; i < size; i += 1 )
		{
			itemId = tutorialStartingItems[ i ];
			itemName = inv.GetItemName( itemId );
			tutorialStartingItemsNames.PushBack( itemName );
		}
	}

	function TutorialSetItems()
	{
		var inv			: CInventoryComponent = thePlayer.GetInventory();
		var itemArray	: array< name > = tutorialStartingItemsNames;
		var i, size 	: int;
		var itemId		: SItemUniqueId;
		var itemName	: name;
		
		size = itemArray.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			inv.AddItem( itemArray[i] );
		}

		TutorialMountBestItemOfCategory( 'silversword' );
		TutorialMountBestItemOfCategory( 'steelsword' );
		TutorialMountBestItemOfCategory( 'armor' );
		TutorialMountBestItemOfCategory( 'boots' );
		TutorialMountBestItemOfCategory( 'pants' );
		TutorialMountBestItemOfCategory( 'gloves' );
		
		tutorialStartingItemsNames.Clear();
	}
	
	function TutorialMountBestItemOfCategory( itemCategory : name )
	{
		var itemId			: SItemUniqueId;
		var catArray		: array< SItemUniqueId >;
		var inv				: CInventoryComponent = thePlayer.GetInventory();
		var i, size, price	: int;
		
		catArray = inv.GetItemsByCategory( itemCategory );
		
		for( i = 0; i < catArray.Size(); i += 1 )
		{
			if( price < theHud.m_utils.GetItemPrice( catArray[i], inv ) )
			{
				price = theHud.m_utils.GetItemPrice( catArray[i], inv );
				itemId = catArray[i];
			}
		}
		inv.MountItem( itemId, false );
		Log( "======================= ITEM MOUNTED : "+inv.GetItemName( itemId ) +" ===================" );
	}
		
	
	//sets tutorial big panel text and image
	function SetTutorialId( text : string, img : string )
	{
		tutorialText = text;
		tutorialImage = img;
	}

	//sets tutorial ids array for panel text, image and icons
	function SetTutorialNewIds(	imageName : string,		firstField : string, 	firstIcon : string, 
														secondField : string, 	secondIcon : string,
														thirdField : string, 	thirdIcon : string,
														fourthField : string, 	fourthIcon : string )
	{
		var tutIds, iconIds : array< string >;
		
		tutIds.PushBack( firstField );
		tutIds.PushBack( secondField );
		tutIds.PushBack( thirdField );
		tutIds.PushBack( fourthField );
		
		iconIds.PushBack( firstIcon );
		iconIds.PushBack( secondIcon );
		iconIds.PushBack( thirdIcon );
		iconIds.PushBack( fourthIcon );
		
		tutorialImage = imageName;
		tutorialNewText = tutIds;
		tutorialNewIcon = iconIds;
	}
	
	//sets tutorial ids array for panel text, image and icons for new tutorial panel
	function SetTutorialNewIdsNew(	imageName : string,		firstField : string, 	firstIcon : string, 
															secondField : string, 	secondIcon : string,
															thirdField : string, 	thirdIcon : string,
															fourthField : string, 	fourthIcon : string )
	{
		tutorialText1 = firstField;
		tutorialText2 = secondField;
		tutorialText3 = thirdField;
		tutorialText4 = fourthField;
		
		tutorialIcon1 = firstIcon;
		tutorialIcon2 = secondIcon;
		tutorialIcon3 = thirdIcon;
		tutorialIcon4 = fourthIcon;
		
		tutorialImage = imageName;
	}
	
	//sets tutorial tesk text
	function SetTutorialTaskId( text : string )
	{
		tutorialTask = text;
	}	
	
	function TutorialDifficultyPrompt()
	{
		theHud.ShowTutorialFinish();
	}
	
	function TutorialInventoryTrashIsBlocked( isBlocked : bool )
	{	
		tutorialInvTrashBlocked = isBlocked;
	}
	
	function TutorialSetSleepToDawn( active : bool )
	{
		isSleepToDawn = active;
	}	

	function TutorialSetBlockMeditationInput( drinkPotions : bool, restUntil : bool, characterPanel : bool, alchemyPanel : bool )
	{
		isMeditationDrinkingBlocked = drinkPotions;
		isMeditationRestingBlocked = restUntil;
		isMeditationCharacterBlocked = characterPanel;
		isMeditationAlchemyBlocked = alchemyPanel;
	}

	function TutorialBlockGameInputsOnPanels( BlockInput : bool )
	{
		//Log( "**************************************" );
		//if( BlockInput )
			//Log( "Blocking input from TutorialBlockGameInputsOnPanels." );
		//else
			//Log( "Unblocking input from TutorialBlockGameInputsOnPanels." );
		IgnoreGameInput( 'GI_Holster', BlockInput );				//holster weapon
		//Log( "GI_Holster." );
		IgnoreGameInput( 'GI_Steel', BlockInput );					//draw steel sword
		//Log( "GI_Steel." );
		IgnoreGameInput( 'GI_Silver', BlockInput );					//draw silver sword
		//Log( "GI_Silver." );
		IgnoreGameInput( 'GI_Hotkey03', BlockInput );				//choose next sign
		//Log( "GI_Hotkey03." );
		IgnoreGameInput( 'GI_Hotkey04', BlockInput );				//choose next item
		//Log( "GI_Hotkey04." );
		IgnoreGameInput( 'GI_Hotkey05', BlockInput );				//choose aard
		//Log( "GI_Hotkey05." );
		IgnoreGameInput( 'GI_Hotkey06', BlockInput );				//choose yrden
		//Log( "GI_Hotkey06." );
		IgnoreGameInput( 'GI_Hotkey07', BlockInput );				//choose igni
		//Log( "GI_Hotkey07." );
		IgnoreGameInput( 'GI_Hotkey08', BlockInput );				//choose quen
		//Log( "GI_Hotkey08." );
		IgnoreGameInput( 'GI_Hotkey09', BlockInput );				//choose axii
		//Log( "GI_Hotkey09." );
		IgnoreGameInput( 'GI_FastMenu', BlockInput );				//open radial menu
		//Log( "GI_FastMenu." );

		//panele informacyjne	
		IgnoreGameInput( 'GI_Inventory', BlockInput );				//open inventory panel
		//Log( "GI_Inventory." );
		IgnoreGameInput( 'GI_Character', BlockInput );				//open character panel
		//Log( "GI_Character." );
		IgnoreGameInput( 'GI_Nav', BlockInput );					//open map panel
		//Log( "GI_Nav." );
		IgnoreGameInput( 'GI_Journal', BlockInput );				//open journal panel	
		//Log( "GI_Journal." );
		IgnoreGameInput( 'GI_ControlsHint', BlockInput );				//open control hints menu
		//Log( "GI_ControlsHint." );

		//dodatkowe
		IgnoreGameInput( 'GI_F5', BlockInput );						//save game in quickslot
		//Log( "GI_F5." );
		IgnoreGameInput( 'GI_H', BlockInput );						//hide GUI
		//Log( "GI_H." );
		//Log( "**********************************************" );
		if( BlockInput == true )
		{
			thePlayer.ResetPlayerMovement();
		}
	}

	function TutorialToggleInventoryBlock( isBlocked : bool )
	{
		isMenuInventoryBlocked = isBlocked;
	}

	function TutorialToggleCharacterBlock( isBlocked : bool )
	{
		isMenuCharacterBlocked = isBlocked;
	}
	
	function TutorialToggleJournalBlock( isBlocked : bool )
	{
		isMenuJournalBlocked = isBlocked;
	}	

	function TutorialToggleMapBlock( isBlocked : bool )
	{
		isMenuMapBlocked = isBlocked;
	}

	function ResetTutorialSettings()
	{
		tutorialenabled 				= false;
		newGameAfterTutorial			= false;
	}
	
	function ResetTutorialData()
	{
		tutorialOldPanelShown 			= false;
		tutorialPanelHidden 			= true;
		tutorialHideOldPanels 			= false;
		tutorialPanelNew 				= false;
		tutorialInvTrashBlocked 		= false;
		isSleepToDawn 					= false;
		isPlayerResting 				= false;
		isPlayerMeditating 				= false;
		isPlayerInInventory 			= false;
		isMeditationDrinkingBlocked 	= false;
		isMeditationRestingBlocked 		= false;
		isMeditationCharacterBlocked 	= false;
		isMeditationAlchemyBlocked 	 	= false;
		isMenuInventoryBlocked			= false;
		isMenuCharacterBlocked			= false;
		isMenuJournalBlocked			= false;
		isMenuMapBlocked				= false;
		
		ClearIgnoredInput();
		
		if( theHud.m_hud.m_fastMenu )
		{
			theHud.m_hud.m_fastMenu.TutorialClearFastMenuBlockedImputs();
		}	
	}
	
	// Get camera
	// DEPRECATED:
	// Use theCamera instead
	//import final function GetCamera() : CCamera;
	
	// Get active camera component
	import final function GetActiveCameraComponent() : CCameraComponent;
	
	// Is using pad
	import final function IsUsingPad() : bool;
	
	// Toggle using pad
	import final function TogglePad( usePad : bool );
	
	// Is pad connected
	import final function IsPadConnected() : bool;
	
	// Define what input mustn't be processed
	import final function IgnoreGameInput( gameInputName : name, ignore : bool );
	
	// Resets defined blocked inputs
	import final function ClearIgnoredInput();
	
	import final function GetInputIgnoreCount( input : name ) : int;

	// Create entity. There are a few persistance options one might use:
	// PM_DontPersist 	- 	creates an entity that will not be taken into consideration
	//						when the game state is saved
	// PM_SaveStateOnly - 	state of the entity will be saved when the entity gets streamed out,
	//						however when a game save is made and then loaded, the entity will not be
	//						automatically created
	// PM_Persist		-	entity will be automatically recreated when a saved game is restored,
	//						and its state will be saved as well when the entity gets streamed out
	import final function CreateEntity( entityTemplate : CEntityTemplate, pos : Vector, optional rot : EulerAngles,
										optional useAppearancesFromIncludes : bool, optional forceBehaviorPose : bool, 
										optional doNotAdjustPlacement : bool, optional persistanceMode : EPersistanceMode ) : CEntity;
	
	// Get node by tag
	import final function GetNodeByTag( tag : name ) : CNode;
	
	// Get entity by tag
	import final function GetEntityByTag( tag : name ) : CEntity;
	
	// Get nodes by tag
	import final function GetNodesByTag( tag : name, out nodes : array<CNode> );
	
	// Get default animation time multiplier used by animated components
	//import final function GetDefaultAnimationTimeMultiplier() : float;
	
	// Set animation time multiplier for all animated components (also newly created)
	//import final function SetDefaultAnimationTimeMultiplier( mult : float );
	
	// Returns the active world
	import final function GetWorld() : CWorld;
	
	// Is debug free enabled
	import final function IsFreeCameraEnabled() : bool;
	
	// Enable debug free camera
	import final function EnableFreeCamera( flag : bool );
	
	// Is given showFlag enabled
	import final function IsShowFlagEnabled( showFlag : EShowFlags ) : bool;
	
	// Set or clear given showFlag
	import final function SetShowFlag( showFlag : EShowFlags, enabled : bool );
	
	// Reset game camera
	import final function ResetGameCamera();
	
	// Play cutscene. If return false see log for warnings.
	import final function PlayCutsceneAsync( csName : string, actorNames : array<string>, actorEntities : array<CEntity>, csPos : Vector, csRot : EulerAngles, optional cameraNum : int ) : bool;

	// Is currently playing a non-gameplay scene
	import final function IsCurrentlyPlayingNonGameplayScene() : bool;
	
	// Get current GameInput value
	import final function GetGameInputValue( giName : name ) : float;
	
	// Transit to partition ( loading screen )
	import final function LoadWorldPartition( partition : string );

	// Transit to partition ( streaming )
	import final function StreamWorldPartition( partition : string );
	
	// Are we during streaming
	import final function IsStreaming() : bool;
	
	// collisionContextName : one of the following {npc, player, scene}
	import final function FindEmptyArea( searchRadius : float, areaRadius : float, collisionContextName : name, actualPosition : Vector, out outPosition : Vector ) : bool;

	// Latent functions
	
	// Play cutscene. If return false see log for warnings.
	import latent final function PlayCutscene( csName : string, actorNames : array<string>, actorEntities : array<CEntity>, csPos : Vector, csRot : EulerAngles, optional cameraNum : int ) : bool;
		
	// Fade out screen to given color
	import latent final function FadeOut( optional fadeTime : float /*=1.0*/, optional fadeColor : Color /*=Color::BLACK*/ );
	
	// Fade in screen
	import latent final function FadeIn( optional fadeTime : float /*=1.0*/ );
	
	// Fade out screen to given color
	import final function FadeOutAsync( optional fadeTime : float /*=1.0*/, optional fadeColor : Color /*=Color::BLACK*/ );
	
	// Fade in screen
	import final function FadeInAsync( optional fadeTime : float /*=1.0*/ );
	
	// Is screen fade in progress? (fade out or fade in)
	import final function IsFading() : bool;
	
	// Is blackscreen set?
	import final function IsBlackscreen() : bool;
	
	// Switch static camera
	import final function StaticCameraSwitch( currCameraTag, nextCameraTag : CStaticCamera ) : bool;
	
	// Switch static camera and wait
	import latent final function StaticCameraSwitchAndWait( currCameraTag, nextCameraTag : CStaticCamera, optional timeout : float ) : bool;
	
	// Run static cameras sequence
	import latent final function StaticCameraRunSequenceAndWait( cameras : array< CStaticCamera >, optional timeout : float ) : bool;
	
	// Is active camera blending
	import final function IsActiveCameraBlending() : bool;

	// Is any static camera active
	import final function IsAnyStaticCameraActive() : bool;

	// Disable all static cameras
	import final function DisableAllStaticCameras();
	
	////////////////////
	// Video player
	
	// Play video and wait for finishing
	import latent final function PlayVideo( fileName : string );
	
	// Play video and do not wait for finishing
	import final function PlayVideoAsync( fileName : string );
	
	// Stop current video
	import final function StopVideo();
	
	////////////////////
	// Achievement system
	import final function UnlockAchievement( achName : name );
	
	import final function LockAchievement( achName : name );
	
	import final function GetUnlockedAchievements( out unlockedAchievments : array< name > );
	
	import final function GetAllAchievements( out unlockedAchievments : array< name > );
	
	import final function IsAchievementUnlocked( achievement : name );
	
	///////////////////////////////////////////////////////////////////
	// Difficulty level 
	
	import final function GetDifficultyLevel() : int;
	
	import final function SetDifficultyLevel( amount : int );

	function GetDifficultyLevelMult() : float
	{
		var difficultyLevel : int;
		
		difficultyLevel = GetDifficultyLevel();
		if (difficultyLevel == 0) return 0.25;
		if (difficultyLevel == 1) return 1.0;
		if (difficultyLevel == 2) return 1.5;
		if (difficultyLevel == 3) return 1.25;
		if (difficultyLevel == 4) return 2.0;
		if (difficultyLevel == 5) return 0.15;
	}
	function GetCriticalDamageDifficultyLevelMult(defender : CActor) : float
	{
		var difficultyLevel : int;
		
		difficultyLevel = GetDifficultyLevel();
	
		if(defender == thePlayer)
		{
			if (difficultyLevel == 0) return 0.2;
			if (difficultyLevel == 1) return 1.0;
			if (difficultyLevel == 2) return 1.0;
			if (difficultyLevel == 3) return 1.0;
			if (difficultyLevel == 4) return 1.0;
			if (difficultyLevel == 5) return 0.1;
		}
		else 
		{
			return 1.0;
		}
	}
	function GetDamageDifficultyLevelMult(attacker : CActor, defender : CActor) : float
	{
		var difficultyLevel : int;
		
		difficultyLevel = GetDifficultyLevel();
		
		if(attacker == thePlayer)
		{
			if (difficultyLevel == 0) return 1.0;
			if (difficultyLevel == 1) return 1.0;
			if (difficultyLevel == 2) return 1.0;
			if (difficultyLevel == 3) return 1.0;
			if (difficultyLevel == 4) return 1.0;
			if (difficultyLevel == 5) return 1.0;
		}
		else if(defender == thePlayer)
		{
			if (difficultyLevel == 0) return 1.0;
			if (difficultyLevel == 1) return 1.5;
			if (difficultyLevel == 2) return 2.25;
			if (difficultyLevel == 3) return 2.25;
			if (difficultyLevel == 4) return 3.5;
			if (difficultyLevel == 5) return 0.7;
		}
		else
		{
			return 1.0;
		}
	}
	function GetArmorDifficultyLevelMult(attacker : CActor, defender : CActor) : float
	{
	
		var difficultyLevel : int;
		if(defender == thePlayer)
		{
			return 1.0;
		}
		else if(attacker == thePlayer)
		{
			difficultyLevel = GetDifficultyLevel();
			if (difficultyLevel == 0) return 1.0;
			if (difficultyLevel == 1) return 1.0;
			if (difficultyLevel == 2) return 1.0;
			if (difficultyLevel == 3) return 1.0;
			if (difficultyLevel == 4) return 1.0;
			if (difficultyLevel == 5) return 1.0;
		}
		else
		{
			return 1.0;
		}
	}
	///////////////////////////////////////////////////////////////////
	// Game save events
	//
	// The event is called whenever a game save attempt is made
	// The result code passed as an argument describes the outcome
	// of the attempt
	//
	// enum ESaveAttemptResult
	// {
	// 	  SAR_Success,
	// 	  SAR_SaveLock,
	//    SAR_WriteFailure,
	// };
	///////////////////////////////////////////////////////////////////
	event OnSaveAttempt( resultCode : ESaveAttemptResult )
	{
		if ( resultCode == SAR_Success )
		{
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "SaveGameDone" ) );
			thePlayer.AddTimer( 'clearHudTextFieldTimer', 1.5f, false );
			//theHud.m_hud.ShowTutorial("tut64", "", false);
			//theHud.ShowTutorialPanelOld("tut64", "");
		} else
		if ( resultCode == SAR_SaveLock )
		{
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "SaveGameLock" ) );
			thePlayer.AddTimer( 'clearHudTextFieldTimer', 1.5f, false );
		} else
		if ( resultCode == SAR_WriteFailure )
		{
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "SaveGameFailure" ) );
			thePlayer.AddTimer( 'clearHudTextFieldTimer', 1.5f, false );
		} 
	}

	///////////////////
	// Debug functions
	import final function QteAutoWin() : bool;
	
	import final function IsCheatEnabled( cheatFeature : ECheats ) : bool;
	
	import final function ReloadGameplayConfig();
	
	import final function GetGameplayChoice() : bool;
};

// Setup radial blur
import function RadialBlurSetup( blurSourcePos : Vector, blurAmount, sineWaveAmount, sineWaveSpeed, sineWaveFreq : float );

// Disable radius blur
import function RadialBlurDisable();

// Setup fullscreen blur
import function FullscreenBlurSetup( intensity : float );

/////////////////TUTORIAL FLASH CALLED FUNCTIONS /////////////////////////////////////////////////////////////

function TutorialTogglePause( isNew : bool )
{
	var res : bool;
	
	if( theGame.tutorialPanelHidden )
	{
		//if( isNew )
		//	theHud.m_hud.ShowNewTutorialNew( true, true );	
		//else	
		//	theHud.m_hud.ShowNewTutorial( true );
		
		if( isNew )
			theGame.SetTutorialUseNew( true );
		else
			theGame.SetTutorialUseNew( false );
		
		Log( " ======================= Flash Toggled Panel, theGame.tutorialPanelHidden == true, Showing Panel ====================" );
		theGame.TutorialPanelHidden( false );
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

		Log( " ======================= Flash Toggled Panel, theGame.tutorialPanelHidden == false, Hiding Panel ====================" );		
		theGame.TutorialPanelHidden( true );		
		theHud.HideTutorialPanel();
	}
}
