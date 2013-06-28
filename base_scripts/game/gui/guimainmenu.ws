/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Main Menu
/** Copyright © 2011
/***********************************************************************/
exec function DiffChanged()
{
	var inventory : CInventoryComponent;
	theGame.SetDifficultyLevel(theHud.m_mainMenu.GetDiffValue());
	theHud.m_mainMenu.Refill();
	FactsAdd("diff_changed", 1);
	
	inventory = thePlayer.GetInventory();
	//schematy
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyArmorA1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyArmorA2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyArmorA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyBootsA1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyBootsA2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyBootsA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyGlovesA1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyGlovesA2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyGlovesA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyPantsA1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyPantsA2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic DarkDifficultyPantsA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty steelsword A1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty steelsword A2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty steelsword A3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty silversword A1'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty silversword A2'));
	inventory.RemoveItem(inventory.GetItemId( 'Schematic Dark difficulty silversword A3'));
	
	//itemy
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty silversword A1'));
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty silversword A2'));
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty silversword A3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty steelsword A1'));
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty steelsword A2'));
	inventory.RemoveItem(inventory.GetItemId( 'Dark difficulty steelsword A3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyArmorA1'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyArmorA2'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyArmorA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyBootsA1'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyBootsA2'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyBootsA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyGlovesA1'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyGlovesA2'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyGlovesA3'));
	
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyPantsA1'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyPantsA2'));
	inventory.RemoveItem(inventory.GetItemId( 'DarkDifficultyPantsA3'));
	
	thePlayer.SetDarkWeaponAddVitality(false);
	thePlayer.SetDarkWeaponSilver(false);
	thePlayer.SetDarkWeaponSteel(false);
	thePlayer.SetDarkEffect(false);
	thePlayer.SetDarkSet(false);

}

import struct SGuiGameSaveInfo
{
	import var fileName 	: string;
	import var world 		: string;
	import var displayName	: string;
	import var description	: string;
	import var difficulty	: int;
	import var screenshot	: string;
	import var playerAlive  : bool;
}

import struct SGuiQuestionInfo
{
	import var question		: string;
	import var textAnswers	: array< string >;
	import var factAnswers	: array< string >;
}

import struct SGuiChapterInfo
{
	import var chapterName	: string;
	import var questions	: array< SGuiQuestionInfo >;
}

enum EMainMenuState
{
	MM_MAIN,
	MM_TUTORIAL,
	MM_TUTORIAL_BEFORE_GAME,
	MM_ARENA,
	MM_NEW_GAME,
	MM_TUTORIAL_SELECT_DIFFICULTY,
	MM_LOAD_GAME,
	MM_LOAD_CHAPTER,
	MM_OPTIONS,
	MM_EXTRAS,
	MM_FLASHBACKS,
	MM_PLAYING_FLASHBACK,
	MM_PLAYING_EXTRAS_VID,
	MM_IMPORT_OR_NEW,
	MM_SELECT_W1_SAVE,
	
	// OPTIONS
	MM_BTN_OPTIONS_STEAMCLOUD,
	MM_OPTIONS_SOUND,
	MM_OPTIONS_GAMEPLAY,
	MM_OPTIONS_GRAPHICS,
	MM_OPTIONS_GAMEPLAY_CONTROLS,
	
	// DEBUG
	MM_QUESTIONS,
	
	//dex++: user content
	MM_USER_CONTENT,
	MM_USER_CONTENT_DIFF,
	//dex--
}

enum EMenuButtons
{
	MM_BTN_BACK = -1,
	
	MM_BTN_NEW_GAME = 0,
	//MM_BTN_CASUAL,
	MM_BTN_EASY,
	MM_BTN_MEDIUM,
	MM_BTN_HARD,
	MM_BTN_DARK,
	MM_BTN_INSANE,
	
	MM_BTN_ARENA,
	MM_BTN_TUTORIAL,

	MM_BTN_LOAD_GAME,
	MM_BTN_SAVE,
	MM_BTN_LOAD_CHAPTER,
	MM_BTN_OPTIONS,
	MM_BTN_QUIT,
	MM_BTN_EXIT_GAME,
	MM_BTN_CLOSE,
	
	MM_BTN_EXTRAS,
	MM_BTN_CREDITS,
	MM_BTN_GOG_MINIGAME,
	MM_BTN_FLASHBACKS,
	MM_BTN_RECAP,
	MM_BTN_INTRO,
	
	// OPTIONS
	MM_BTN_OPTIONS_SOUND,
	MM_BTN_OPTIONS_GRAPHICS,
	MM_BTN_OPTIONS_GAMEPLAY,
	MM_BTN_OPTIONS_GAMEPLAY_CONTROLS,
	MM_SLID_MUSIC_VOLUME,
	MM_SLID_FX_VOLUME,
	MM_SLID_MASTER_VOLUME,
	MM_SLID_VOICE_VOLUME,
	MM_SLID_GAMMA,
	MM_SLID_BRIGHTNESS,
	MM_SLID_CONTRAST,
	MM_SEL_DIFFICULTY,
	MM_ONOFF_COMBAT_LOG,
	MM_SEL_AUDIO_LANG,
	MM_SEL_TEXT_LANG,
	MM_ONOFF_AUTOCENTER_CAMERA,
	MM_ONOFF_TUTORIAL,
	MM_ONOFF_RPG_QTE,
	MM_SEL_CONTROLLER,
	MM_ONOFF_INVERTX,
	MM_ONOFF_INVERTY,
	MM_SLID_MOUSE_SENSITIVITY,
	MM_ONOFF_SUBTITLES,
	
	MM_BTN_IMPORT_W1_SAVE,
	MM_BTN_SKIP_W1_SAVE,
	
	// GUI Panels Selector
	
	MM_BTN_SHOW_INVENTORY,
	MM_BTN_SHOW_JOURNAL,  
	MM_BTN_SHOW_CHARACTER,
	MM_BTN_SHOW_NAV,     

	MM_BTN_SUGGESTED_DIFF_LEVEL,
	MM_BTN_ACCEPT,
	MM_BTN_DECLINE,
	
	//dex++
	MM_BTN_USER_CONTENT_MENU,
	//dex--
} 

// Must be the same in Flash
enum EMenuItems
{
	MM_BUTTON = 0,
	MM_SLIDER = 1,
	MM_SELECTOR = 2,
	MM_ONOFF = 3,
}

import class CGuiMainMenu extends CGuiPanel
{
	////////////////// IMPORTS //////////////////////
	
	import public  var inGame 	: bool;	
	
	import private var saves 	: array< SGuiGameSaveInfo >;
	import private var w1saves 	: array< SGuiGameSaveInfo >;
	import private var chapters	: array< SGuiChapterInfo >;

	import private function RefreshSaveData();
	import private function RefreshChaptersData();
	
	import private function LoadGame( id : int );
	import private function LoadLevel( worldName : string );
	import final function DeleteGameSave( id : int );
	import private function AddFact( fact : string );
	import private function QuitApplication();
	import private function SaveGame();
	import private function ShowMenuBeforeGame();
	import private function LoadW1Save( id : int );
	
	import private function GetMusicVolume() : float;
	import private function SetMusicVolume( value : float );
	import private function GetFxVolume() : float;
	import private function SetFxVolume( value : float );
	import private function GetVoiceVolume() : float;
	import private function SetVoiceVolume( value : float );
	//import private function SetMasterVolume( value : float );
	
	import private function GetBrightness() : float;
	import private function SetBrightness( gamma : float );
	import private function GetContrast() : float;
	import private function SetContrast( gamma : float );
	import private function GetGamma() : float;
	import private function SetGamma( gamma : float );
	
	import private function GetMouseSensitivity() : float;
	import private function SetMouseSensitivity( value : float );
	
	import private function SetTextLanguage( id : int );
	import private function SetAudioLanguage( id : int );
	
	import private function CanSaveRightNow() : bool;
	
	import private final function HaveAccessToGOGMinigame() : bool;
	import private final function GoToGOG( link : string );
	
	import private final function ClosePanelOnMenuBeforeGame();
	
	import private final function PlayVideo( videoName : string );
	import private final function ReadFlashbacks();

	import private final function IsSteamBuild() : bool;
	import private final function IsSteamCloudEnabled() : bool;
	import private final function EnableSteamCloud( enabled : bool );
	import private final function CopySavesToSteamCloud() : bool;
	
	//dex++: user content
	import private final function GetNumUserPackages() : int;
	import private final function GetNumUserPackagesWithLevels() : int;
	import private final function GetUserPackageName( index : int ) : string;
	import private final function GetUserPackageDescription( index : int ) : string;
	import private final function GetUserPackageLevelPath( index : int ) : string;
	import private final function GetUserPackageScreenshotPath( index : int ) : string;
	//dex--
	
	//////////////////////////////////////////////////

	private var AS_menuData 			: int;
	private var menuState				: EMainMenuState;
	private var menuButton				: EMenuButtons;
	private var areHotKeyPanelsBlocked 	: bool;
	private var m_allowToUseTutorial	: bool;
	private var isDiffSelAfterTutorial	: bool;
	private var blockProcessingInput	: bool;
	default m_allowToUseTutorial = true;
	default isDiffSelAfterTutorial = false;
	
	// For flashbacks
	import private var fbVideoNames		: array< string >;
	import private var fbDescriptions	: array< string >;
	private var m_startingMenuState		: EMainMenuState;
	default m_startingMenuState = MM_MAIN;
	
	// DEBUG
	private var currChapter		: int;
	private var currQuestion	: int;

	private var music : CSound; 

	var diffValue : int;
	
	default menuState = MM_MAIN;
	
	public var mainMenuMusic : CSound;
	
	//dex++: user content
	private var userContentLevelPath : string;
	//dex--

	////////////////////////////////////////////////////

	function SetDiffValue(value : int)
	{
		diffValue = value;
	}
	function GetDiffValue() : int
	{
		return diffValue;
	}
	
	function SetInputBlocked( value : bool )
	{
		blockProcessingInput = value;
	}

	// Panel
	function GetPanelPath() : string { return "ui_mainmenu.swf"; }
	
	public function SetStartingMenuState( startingMenuState : EMainMenuState )
	{
		m_startingMenuState = startingMenuState;
	}
	
	event OnOpenPanel()
	{
		var i : int;
		menuState = m_startingMenuState;

		m_startingMenuState = MM_MAIN; // restore default value
		
		if( ! inGame )
		{
			// Little hack for making sure everything is created even game is not started
			theHud.OnGameStarting();
		}

		areHotKeyPanelsBlocked = thePlayer.AreHotKeysBlocked() || thePlayer.IsInNonGameplayCutscene() || thePlayer.GetCurrentStateName() == 'Scene';

		super.OnOpenPanel();
		
		if ( inGame )
		{
			theGame.PauseCutscenes();
		} 
		else
		{
			theHud.startMainMenuMusicMcinekHack( "gui/main_menu_music/main_menu_theme" );
		}
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
			
		RefreshChaptersData();
	}
	
	event OnClosePanel()
	{
		theHud.ForgetObject( AS_menuData );
		
		theSound.RestoreAllSounds();
		
		if ( inGame )
		{
			theGame.UnpauseCutscenes();
		}

		super.OnClosePanel();
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if( blockProcessingInput )
		{
			return true;
		}
		
		if( key == 'GI_Exit' && value > 0.5f )
		{
			return Exit();
		}
		
		if ( menuState == MM_PLAYING_FLASHBACK || menuState == MM_PLAYING_EXTRAS_VID )
		{
			if ( key == 'GI_AttackFast' && value > 0.5f )
			{
				return Exit();
			}
		}
		
		return true;
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float )
	{
		if( blockProcessingInput )
		{
			return true;
		}
		
		if( (key == 137 /* IK_Pad_B_CIRCLE */ || key == 140 /* IK_Pad_Start */ ) && action == IACT_Press )
		{
			return Exit();
		} 
		
		return false;
	}
	
	private final function Exit() : bool
	{
		switch( menuState )
		{
			case MM_MAIN:
			{
				if( inGame )
				{
					ClosePanel();
					return true;
				}
				return false;
			}
			case MM_TUTORIAL:
			case MM_ARENA:
			case MM_NEW_GAME:
			case MM_LOAD_GAME:
			case MM_LOAD_CHAPTER:
			case MM_QUESTIONS:
			case MM_OPTIONS:
			case MM_EXTRAS:
			case MM_IMPORT_OR_NEW:
			{
				menuState = MM_MAIN;
				Refill();
				return true;
			}
			//dex++
			case MM_USER_CONTENT:
			{
				menuState = MM_IMPORT_OR_NEW;
				Refill();
				return true;
			}			
			case MM_USER_CONTENT_DIFF:
			{
				menuState = MM_USER_CONTENT;
				Refill();
				return true;
			}
			//dex--
			case MM_OPTIONS_SOUND:
			case MM_OPTIONS_GAMEPLAY:
			case MM_OPTIONS_GAMEPLAY_CONTROLS:
			case MM_OPTIONS_GRAPHICS:
			{
				menuState = MM_OPTIONS;
				Refill();
				return true;
			}
			case MM_SELECT_W1_SAVE:
			{
				menuState = MM_IMPORT_OR_NEW;
				Refill();
				return true;
			}
			case MM_FLASHBACKS:
			{
				menuState = MM_EXTRAS;
				Refill();
				return true;
			}
			case MM_PLAYING_FLASHBACK:
			{
				menuState = MM_FLASHBACKS;
				theHud.Invoke( "pPanelClass.StopVideo" );
				theHud.ShowMenuBeforeGame( MM_FLASHBACKS );
				return true;
			}
			case MM_PLAYING_EXTRAS_VID:
			{
				menuState = MM_EXTRAS;
				theHud.Invoke( "pPanelClass.StopVideo" );
				theHud.ShowMenuBeforeGame( MM_EXTRAS );
				return true;
			}
		}
	}
	
	private final function MovieStopped()
	{
		if ( menuState == MM_PLAYING_FLASHBACK )
		{
			theHud.ShowMenuBeforeGame( MM_FLASHBACKS );
		}
		else if( menuState == MM_PLAYING_EXTRAS_VID )
		{
			theHud.ShowMenuBeforeGame( MM_EXTRAS );
		}
	}
	
	private final function InsertMenuButton( AS_MenuItems : int, id : int, text : string, description : string, optional additional : string )
	{
		var AS_Item : int;
	
		// Create flash array
		AS_Item = theHud.CreateAnonymousArray();
		
		// Fill parameters
		theHud.PushFloat( AS_Item, ( float )( int ) MM_BUTTON );
		theHud.PushFloat( AS_Item, id );
		theHud.PushString( AS_Item, text );
		theHud.PushString( AS_Item, description );
		theHud.PushString( AS_Item, additional );
		
		// Insert into items
		theHud.PushObject( AS_MenuItems, AS_Item );
		theHud.ForgetObject( AS_Item );
	}
	private final function InsertMenuSlider( AS_MenuItems : int, id : int, text : string, min, max, initial : float )
	{
		var AS_Item : int;
	
		// Create flash array
		AS_Item = theHud.CreateAnonymousArray();
		
		// Fill parameters
		theHud.PushFloat( AS_Item, ( float )( int ) MM_SLIDER );
		theHud.PushFloat( AS_Item, id );
		theHud.PushString( AS_Item, text );
		theHud.PushFloat( AS_Item, min );
		theHud.PushFloat( AS_Item, max );
		theHud.PushFloat( AS_Item, initial );
		
		// Insert into items
		theHud.PushObject( AS_MenuItems, AS_Item );
		theHud.ForgetObject( AS_Item );
	}

	private final function InsertMenuSelector( AS_MenuItems : int, id : int, text : string, items : array< string >, initialIdx : int )
	{
		var AS_Item 	: int;
		var AS_Values	: int;
		var i			: int;
	
		// Create flash array
		AS_Item = theHud.CreateAnonymousArray();
		
		// Create array for values
		AS_Values = theHud.CreateAnonymousArray();
		
		// Fill values array
		for( i = 0; i < items.Size(); i += 1 )
		{
			theHud.PushString( AS_Values, items[ i ] );
		}
		
		// Fill parameters
		theHud.PushFloat( AS_Item, ( float )( int ) MM_SELECTOR );
		theHud.PushFloat( AS_Item, id );
		theHud.PushString( AS_Item, text );
		theHud.PushObject( AS_Item, AS_Values );
		theHud.ForgetObject( AS_Values );
		theHud.PushFloat( AS_Item, ( float ) initialIdx );
		
		// Insert into items
		theHud.PushObject( AS_MenuItems, AS_Item );
		theHud.ForgetObject( AS_Item );
	}

	private final function InsertMenuOnOff( AS_MenuItems : int, id : int, text : string, initialState : bool )
	{
		var AS_Item : int;
	
		// Create flash array
		AS_Item = theHud.CreateAnonymousArray();
		
		// Fill parameters
		theHud.PushFloat( AS_Item, ( float )( int ) MM_ONOFF );
		theHud.PushFloat( AS_Item, id );
		theHud.PushString( AS_Item, text );
		theHud.PushBool( AS_Item, initialState );
		
		// Insert into items
		theHud.PushObject( AS_MenuItems, AS_Item );
		theHud.ForgetObject( AS_Item );
	}

	// DATA FILL
	
	private final function Refill()
	{
		var AS_menuItems : int;
		var keyboard : string;
		var pad : string;

		if ( ! theHud.GetObject( "MainItems", AS_menuItems, AS_menuData ) )
		{
			LogChannel( 'GUI', "MainMenu: cannot find mMainMenu.MainItems at scaleform side." );
			return;
		}

		// Clear
		theHud.ClearElements( AS_menuItems );
		
		

		// Fill with data
		switch( menuState )
		{
			case MM_MAIN:
			{
				if( inGame )
				{
					FillMainInGame( AS_menuItems );
				}
				else
				{
					FillMainMenu( AS_menuItems );
				}
				break;
			}
			case MM_NEW_GAME:
			{
				FillNewGame( AS_menuItems );
				break;
			}			
			case MM_TUTORIAL_SELECT_DIFFICULTY:
			{
				FillTutDiffSelection( AS_menuItems );
				break;
			}			
			case MM_TUTORIAL_BEFORE_GAME:
			{
				FillTutBeforeGame( AS_menuItems );
				break;
			}
			case MM_LOAD_GAME:
			{
				keyboard = theHud.m_hud.GetImagePathForIK( "IK_Delete" );
				pad = theHud.m_hud.GetImagePathForIK( "IK_Pad_Y_TRIANGLE" );
				
				theHud.SetString( "sDelKeyboard", keyboard, AS_menuData );
				theHud.SetString( "sDelPad", pad, AS_menuData );
				
				FillLoadGame( AS_menuItems );
				break;
			}
			//dex++:
			case MM_USER_CONTENT:
			{
				FillUserContent( AS_menuItems );
				break;
			}
			case MM_USER_CONTENT_DIFF:
			{
				FillUserContentDifficultySelection( AS_menuItems );
				break;
			}
			//dex--
			case MM_LOAD_CHAPTER:
			{
				FillLoadChapter( AS_menuItems );
				break;
			}
			case MM_OPTIONS:
			{
				FillOptions( AS_menuItems );
				break;
			}
			case MM_QUESTIONS:
			{
				FillQuestions( AS_menuItems );
				break;
			}
			case MM_EXTRAS:
			{
				FillExtras( AS_menuItems );
				break;
			}
			case MM_FLASHBACKS:
			{
				FillFlashbacks( AS_menuItems );
				break;
			}
			case MM_OPTIONS_SOUND:
			{
				FillOptionsSound( AS_menuItems );
				break;
			}
			case MM_OPTIONS_GAMEPLAY:
			{
				FillOptionsGameplay( AS_menuItems );
				break;
			}
			case MM_OPTIONS_GAMEPLAY_CONTROLS:
			{
				FillOptionsGameplayControls( AS_menuItems );
				break;
			}
			case MM_OPTIONS_GRAPHICS:
			{
				FillOptionsGraphics( AS_menuItems );
				break;
			}
			case MM_SELECT_W1_SAVE:
			{
				FillSelectW1Save( AS_menuItems );
				break;
			}
			case MM_IMPORT_OR_NEW:
			{
				FillImportOrNew( AS_menuItems );
				break;
			}
		}
		
		if ( menuState != MM_LOAD_GAME )
		{
			theHud.InvokeOneArg( "pPanelClass.CanDeleteSaves", FlashValueFromBoolean( false ) );
		}
		else
		{
			if (saves.Size() == 0 ) //you can't delete "Back" button
			{
				theHud.InvokeOneArg( "pPanelClass.CanDeleteSaves", FlashValueFromBoolean( false ) );
			}
			else if (saves.Size() >0)
			{
				theHud.InvokeOneArg( "pPanelClass.CanDeleteSaves", FlashValueFromBoolean( true ) );
			}
		}
		
		theHud.ForgetObject( AS_menuItems );

		theHud.Invoke( "Commit", AS_menuData );
	}

	private final function FillMainInGame( AS_MenuItems : int )
	{
		InsertMenuButton( AS_MenuItems, MM_BTN_CLOSE, StrUpperUTF( GetLocStringByKeyExt( "menuClose" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuClose_t" ) ) );

		// Fill GUI panels selector
		if ( theGame.IsUsingPad() && !areHotKeyPanelsBlocked )
		{
			InsertMenuButton( AS_MenuItems, MM_BTN_SHOW_INVENTORY, StrUpperUTF( GetLocStringByKeyExt( "panelSelector1" ) ), StrUpperUTF( GetLocStringByKeyExt( "panelSelector1t" ) ) );
			InsertMenuButton( AS_MenuItems, MM_BTN_SHOW_JOURNAL,   StrUpperUTF( GetLocStringByKeyExt( "panelSelector2" ) ), StrUpperUTF( GetLocStringByKeyExt( "panelSelector2t" ) ) );
			InsertMenuButton( AS_MenuItems, MM_BTN_SHOW_CHARACTER, StrUpperUTF( GetLocStringByKeyExt( "panelSelector3" ) ), StrUpperUTF( GetLocStringByKeyExt( "panelSelector3t" ) ) );
			InsertMenuButton( AS_MenuItems, MM_BTN_SHOW_NAV,       StrUpperUTF( GetLocStringByKeyExt( "panelSelector4" ) ), StrUpperUTF( GetLocStringByKeyExt( "panelSelector4t" ) ) );
		}
		
		if( CanSaveRightNow() )
		{
			InsertMenuButton( AS_MenuItems, MM_BTN_SAVE, StrUpperUTF( GetLocStringByKeyExt( "menuSave" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSave_t" ) ) );
		}
		InsertMenuButton( AS_MenuItems, MM_BTN_LOAD_GAME, StrUpperUTF( GetLocStringByKeyExt( "menuLoad" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuLoad_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS, StrUpperUTF( GetLocStringByKeyExt( "menuSettings" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSettings_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_EXIT_GAME, StrUpperUTF( GetLocStringByKeyExt( "menuExitCurrentGame" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuExitCurrentGame_t" ) ) );
	}
	
	private final function FillMainMenu( AS_MenuItems : int )
	{
		//Tutorial should be only enabled from "New Game" option
		//InsertMenuButton( AS_MenuItems, MM_BTN_TUTORIAL, GetLocStringByKeyExt( "tutorial" ), GetLocStringByKeyExt( "tutorial_t" ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_ARENA, StrUpperUTF( GetLocStringByKeyExt( "arena" ) ), StrUpperUTF( GetLocStringByKeyExt( "arena_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_NEW_GAME, StrUpperUTF( GetLocStringByKeyExt( "menuNew" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuNew_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_LOAD_GAME, StrUpperUTF( GetLocStringByKeyExt( "menuLoad" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuLoad_t" ) ) );
		if( ! theGame.IsFinalBuild() && ! theGame.IsDemoBuild() )
		{
			InsertMenuButton( AS_MenuItems, MM_BTN_LOAD_CHAPTER, "< DEBUG > Chapters", "Not in final game" );
		}
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS, StrUpperUTF( GetLocStringByKeyExt( "menuSettings" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSettings_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_EXTRAS, StrUpperUTF( GetLocStringByKeyExt( "menuExtras" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuExtras_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_QUIT, StrUpperUTF( GetLocStringByKeyExt( "menuQuit" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuQuit_t" ) ) );
	}

	private final function FillNewGame( AS_MenuItems : int )
	{
		//MR - Future DLC
		//InsertMenuButton( AS_MenuItems, MM_BTN_VERY_EASY, GetLocStringByKeyExt( "menuDifficultyVeryEasy" ), GetLocStringByKeyExt( "menuDifficultyVeryEasy_t" ) );
		//InsertMenuButton( AS_MenuItems, MM_BTN_CASUAL, GetLocStringByKeyExt( "menuDifficultyVeryEasy" ), GetLocStringByKeyExt( "menuDifficultyVeryEasy_t" ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_EASY, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_MEDIUM, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_HARD, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard_t" ) ) );
		//MR - Future DLC
		//InsertMenuButton( AS_MenuItems, MM_BTN_VERY_HARD, GetLocStringByKeyExt( "menuDifficultyVeryHard" ), GetLocStringByKeyExt( "menuDifficultyVeryHard_t" ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_DARK, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_INSANE, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillTutDiffSelection( AS_MenuItems : int )
	{
		InsertMenuButton( AS_MenuItems, MM_BTN_EASY, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_MEDIUM, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_HARD, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_DARK, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_INSANE, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane_t" ) ) );
	}	
	
	//dex++: user content
	private final function FillUserContentDifficultySelection( AS_MenuItems : int )
	{
		InsertMenuButton( AS_MenuItems, MM_BTN_EASY, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_MEDIUM, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_HARD, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_DARK, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_INSANE, StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	//dex--
	
	private final function FillTutBeforeGame( AS_MenuItems : int )
	{
	}
			
	private final function FillLoadGame( AS_MenuItems : int )
	{
		// Fill saves
		var i 				: int;
		var saveDescr 		: string;
		var id				: int;
		var additionalData	: string;
		
		// Trigger data retrieving
		RefreshSaveData();
			
		for( i = 0; i < saves.Size(); i += 1 )
		{
			id = i;
			additionalData = saves[ i ].screenshot;
			
			// Set button id, negative number means player is dead
			if( saves[ i ].playerAlive == false )
			{
				additionalData += ";dead";
			}
			
			// Add save game to the menu
			InsertMenuButton( AS_MenuItems, i, StrUpperUTF( saves[ i ].displayName ), StrUpperUTF( saves[ i ].description ), additionalData );
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillImportOrNew( AS_MenuItems : int )
	{
	var audioLang : string;
	var textLang : string;
	
	theGame.GetGameLanguageName(audioLang, textLang);
	
		if( w1saves.Size() == 0 )
		{
			InsertMenuButton( AS_MenuItems, -999, StrUpperUTF( GetLocStringByKeyExt( "menuNoW1SavesFound" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuNoW1SavesFound_t" ) ) );
		}
		else
		{
			InsertMenuButton( AS_MenuItems, MM_BTN_IMPORT_W1_SAVE, StrUpperUTF( GetLocStringByKeyExt( "menuSelectW1Save" ) ), /* GetLocStringByKeyExt( "menuSelectW1Save_t" ) - no localized string */ "" );
		}

		InsertMenuButton( AS_MenuItems, MM_BTN_SKIP_W1_SAVE, StrUpperUTF( GetLocStringByKeyExt( "menuPlayWithoutW1Save" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuPlayWithoutW1Save_t" ) ) );
		
		//dex++: user content menu
		if ( GetNumUserPackagesWithLevels() > 0 )
		{
			if (textLang == "EN")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", "Play user content packages" );
			}
			else if (textLang == "PL")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "DE")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "FR")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "ES")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "IT")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "CZ")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "HU")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "TR")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "BR")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "ZH")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "KR")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "JP")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
			else if (textLang == "RU")
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_USER_CONTENT_MENU, "User Content", " " );
			}
		}
		//dex--
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillSelectW1Save( AS_MenuItems : int )
	{
		var i : int;

		// Fill w1saves
		for( i = 0; i < w1saves.Size(); i += 1 )
		{
			InsertMenuButton( AS_MenuItems, i, StrUpperUTF( w1saves[ i ].description ), "" );
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillLoadChapter( AS_MenuItems : int )
	{
		// Fill chapters
		var i : int;
		for( i = 0; i < chapters.Size(); i += 1 )
		{
			InsertMenuButton( AS_MenuItems, i, StrUpperUTF( chapters[ i ].chapterName ), "Not in final game" );
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF(  GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	
	//dex++: user content
	private final function FillUserContent( AS_MenuItems : int )
	{
		// Fill chapters
		var i,count : int;
		count = GetNumUserPackages();
		for( i = 0; i < count; i += 1 )
		{
			if ( GetUserPackageLevelPath(i) != "" )
			{			
				InsertMenuButton( AS_MenuItems, i, GetUserPackageName(i), GetUserPackageDescription(i), GetUserPackageScreenshotPath(i) );
			}
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF(  GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	} 
	//dex--

	private final function FillOptions( AS_MenuItems : int )
	{
		if( IsSteamBuild() )
		{
			if( IsSteamCloudEnabled() )
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_STEAMCLOUD, StrUpperUTF( GetLocStringByKeyExt( "disable.steam.cloud" ) ), StrUpperUTF( GetLocStringByKeyExt( "disable.steam.cloud_t" ) ) );
			}
			else
			{
				InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_STEAMCLOUD, StrUpperUTF( GetLocStringByKeyExt( "enable.steam.cloud" ) ), StrUpperUTF( GetLocStringByKeyExt( "enable.steam.cloud_t" ) ) );
			}
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_SOUND, StrUpperUTF( GetLocStringByKeyExt( "menuSettingsSound" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSettingsSound_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_GAMEPLAY, StrUpperUTF( GetLocStringByKeyExt( "menuSettingsGameplay" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSettingsGameplay_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_GAMEPLAY_CONTROLS, StrUpperUTF( GetLocStringByKeyExt( "menuControlOptions" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuControlOptions_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_OPTIONS_GRAPHICS, StrUpperUTF( GetLocStringByKeyExt( "menuSettingsGraphics" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuSettingsGraphics_t" ) ) );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	
	private final function FillOptionsSound( AS_MenuItems : int )
	{
		InsertMenuSlider( AS_MenuItems, MM_SLID_MUSIC_VOLUME, StrUpperUTF( GetLocStringByKeyExt( "menu_m_music" ) ), 0.0f, 1.0f, GetMusicVolume() );
		InsertMenuSlider( AS_MenuItems, MM_SLID_FX_VOLUME, StrUpperUTF( GetLocStringByKeyExt( "menu_m_sound" ) ), 0.0f, 1.0f, GetFxVolume() );
		InsertMenuSlider( AS_MenuItems, MM_SLID_VOICE_VOLUME, StrUpperUTF( GetLocStringByKeyExt( "menu_m_voice" ) ), 0.0f, 1.0f, GetVoiceVolume() );
		//InsertMenuSlider( AS_MenuItems, MM_SLID_MASTER_VOLUME, GetLocStringByKeyExt( "menu_m_master" ), 0.0f, 1.0f, 0.5f );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillOptionsGameplay( AS_MenuItems : int )
	{
		var difficulties 			: array< string >;
		var availableTextLangs		: array< string >;
		var availableAudioLangs		: array< string >;
		var currentDiff				: int;

		var index : int;
		//MR - Future DLC
		//difficulties.PushBack( GetLocStringByKeyExt( "menuDifficultyVeryEasy" ) );
		difficulties.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy" ) ) );
		difficulties.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium" ) ) );
		difficulties.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard" ) ) );
		//MR - Future DLC
		
		difficulties.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) ) );
		difficulties.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" ) ) );
		
		//difficulties.PushBack( GetLocStringByKeyExt( "menuDifficultyVeryEasy" ) );
		//difficulties.PushBack( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) );
		
		availableTextLangs.PushBack( "en" );
		availableTextLangs.PushBack( "pl" );
		
		availableAudioLangs.PushBack( "de" );
		availableAudioLangs.PushBack( "jp" );
		
		if( inGame )
		{
			currentDiff = theGame.GetDifficultyLevel();
			//MR - Future DLC
			/*currentDiff += 1;
			if( currentDiff == 4 )
				currentDiff = 3;
			else if( currentDiff == 3 )
				currentDiff = 4;*/
			if(currentDiff != 4)
			{
				difficulties.Remove( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" )));
			}
			if(currentDiff != 3)
			{
				difficulties.Remove( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" )));
			}
			
			//Seting correct start index value (we don't want to show Dark or Insane diff if we don't have to)
			if(currentDiff == 4 )
			{
				index = currentDiff - 1;
			}
			else
			{
				index = currentDiff;
			}
			
			InsertMenuSelector( AS_MenuItems, MM_SEL_DIFFICULTY, StrUpperUTF( GetLocStringByKeyExt( "menu_difficulty" ) ), difficulties, index );
		}
		
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_COMBAT_LOG, StrUpperUTF( GetLocStringByKeyExt( "menu_combatlog" ) ), theHud.m_hud.combatLogEnabled );
//		InsertMenuSelector( AS_MenuItems, MM_SEL_TEXT_LANG, GetLocStringByKeyExt( "menu_textlang" ), availableTextLangs, 0 );
//		InsertMenuSelector( AS_MenuItems, MM_SEL_AUDIO_LANG, GetLocStringByKeyExt( "menu_audiolang" ), availableAudioLangs, 0 );
//		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_AUTOCENTER_CAMERA, GetLocStringByKeyExt( "menu_center" ), true );
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_TUTORIAL, StrUpperUTF( GetLocStringByKeyExt( "menu_tutorial" ) ), theHud.m_hud.tutorialEnabled );
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_RPG_QTE, StrUpperUTF( GetLocStringByKeyExt( "menu_qte" ) ), theGame.hardQte );
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_SUBTITLES, StrUpperUTF( GetLocStringByKeyExt( "menu_subtitles" ) ), theGame.subtitlesEnabled );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	
	private final function FillOptionsGameplayControls( AS_MenuItems : int )
	{
		
		var controllers				: array< string >;
		var	controllerId			: int; /* 0 - keyboard, 1 - gamepad */
		
		controllers.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuInputKeyboard" ) ) );
		if( theGame.IsPadConnected() )
		{
			controllers.PushBack( StrUpperUTF( GetLocStringByKeyExt( "menuInputGamepad" ) ) );
		}
		
		if( theGame.IsPadConnected() && theGame.IsUsingPad() )
		{
			controllerId = 1;
		}
		else
		{
			controllerId = 0;
		}

		InsertMenuSelector( AS_MenuItems, MM_SEL_CONTROLLER, StrUpperUTF( GetLocStringByKeyExt( "menuController" ) ), controllers, controllerId );
		InsertMenuSlider( AS_MenuItems, MM_SLID_MOUSE_SENSITIVITY, StrUpperUTF( GetLocStringByKeyExt( "menuMouseSensitivity" ) ), 0.1f, 1.0f, GetMouseSensitivity() );
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_INVERTX, StrUpperUTF( GetLocStringByKeyExt( "menuInvertX" ) ), theGame.IsInvertCameraX() );
		InsertMenuOnOff( AS_MenuItems, MM_ONOFF_INVERTY, StrUpperUTF( GetLocStringByKeyExt( "menuInvertY" ) ), theGame.IsInvertCameraY() );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	
	private final function FillOptionsGraphics( AS_MenuItems : int )
	{
		InsertMenuSlider( AS_MenuItems, MM_SLID_BRIGHTNESS, StrUpperUTF( GetLocStringByKeyExt( "menu_gamma" ) ), 0.0f, 1.0f, GetBrightness() );
		//InsertMenuSlider( AS_MenuItems, MM_SLID_CONTRAST, GetLocStringByKeyExt( "menu_contrast" ), 0.0f, 1.0f, GetContrast() );
		InsertMenuSlider( AS_MenuItems, MM_SLID_GAMMA, StrUpperUTF( GetLocStringByKeyExt( "menu_REAL_gamma" ) ), 0.0f, 1.0f, GetGamma() );
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillQuestions( AS_MenuItems : int )
	{
		var i : int;
		
		// Display question
		InsertMenuButton( AS_MenuItems, -2, chapters[ currChapter ].questions[ currQuestion ].question, "" );
		
		// Display answers
		for( i = 0; i < chapters[ currChapter ].questions[ currQuestion ].textAnswers.Size(); i += 1 )
		{
			InsertMenuButton( AS_MenuItems, i, chapters[ currChapter ].questions[ currQuestion ].textAnswers[ i ], "" );
		}
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}

	private final function FillExtras( AS_MenuItems : int )
	{
		InsertMenuButton( AS_MenuItems, MM_BTN_CREDITS, StrUpperUTF( GetLocStringByKeyExt( "menuCredits" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuCredits_t" ) ) );
		
		/*if( HaveAccessToGOGMinigame() )
		{
			InsertMenuButton( AS_MenuItems, MM_BTN_GOG_MINIGAME, GetLocStringByKeyExt( "menuGOG" ), GetLocStringByKeyExt( "menuGOG_t" ) );
		}*/
		
		InsertMenuButton( AS_MenuItems, MM_BTN_RECAP, StrUpperUTF( GetLocStringByKeyExt( "menuRecap" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuRecap_t" ) ) );
		
		InsertMenuButton( AS_MenuItems, MM_BTN_INTRO, StrUpperUTF( GetLocStringByKeyExt( "menuIntro" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuIntro_t" ) ) );
		
		InsertMenuButton( AS_MenuItems, MM_BTN_FLASHBACKS, StrUpperUTF( GetLocStringByKeyExt( "menuFlashbacks" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuFlashbacks_t" ) ) );
		
		InsertMenuButton( AS_MenuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
	}
	
	private final function FillFlashbacks( AS_MenuItems : int )
	{
		var i				: int;

		theHud.InvokeOneArg( "pPanelClass.ShowText", FlashValueFromString( StrUpperUTF(  GetLocStringByKeyExt("Flashback_menu_loading") ) ) );
		
		theHud.EnableInput( false, false, false, false );
		if(theHud.CanShowMainMenu())
		{
			theHud.ForbidOpeningMainMenu();
		}
		ReadFlashbacks();
	}
		
	event OnFlashbacksLoaded()
	{
		var i			 : int;
		var AS_menuItems : int;
		
		//theHud.InvokeOneArg( "pPanelClass.ShowText", FlashValueFromString( "" ) );
		theHud.Invoke( "pPanelClass.HideText" );

		if ( ! theHud.GetObject( "MainItems", AS_menuItems, AS_menuData ) )
		{
			LogChannel( 'GUI', "MainMenu: cannot find mMainMenu.MainItems at scaleform side." );
			return true;
		}

		theHud.ClearElements( AS_menuItems );

		for ( i = 0; i < fbDescriptions.Size(); i += 1 )
		{
			InsertMenuButton( AS_menuItems, i, StrUpperUTF(  GetLocStringByKeyExt( fbDescriptions[i] ) ), StrUpperUTF( GetLocStringByKeyExt( fbDescriptions[i] + "_t" ) ) );
		}
		
		InsertMenuButton( AS_menuItems, MM_BTN_BACK, StrUpperUTF( GetLocStringByKeyExt( "menuBack" ) ), StrUpperUTF( GetLocStringByKeyExt( "menuBack_t" ) ) );
		
		theHud.ForgetObject( AS_menuItems );

		theHud.Invoke( "Commit", AS_menuData );
		
		theHud.EnableInput( true, true, true, false );
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
		
		return true;
	}

	// INPUTS

	private final function InputMainInGame( button : int )
	{
		switch( button )
		{
			// GUI Panel Selector
			
			case MM_BTN_SHOW_INVENTORY:
			{
				theHud.ShowInventory();
				break;
			}
			case MM_BTN_SHOW_JOURNAL:
			{
				theHud.ShowJournal();
				break;
			}
			case MM_BTN_SHOW_CHARACTER:
			{
				theHud.ShowCharacter( false );
				break;
			}
			case MM_BTN_SHOW_NAV:
			{
				theHud.ShowNav();
				break;
			}
			case MM_BTN_LOAD_GAME:
			{
				menuState = MM_LOAD_GAME;
				Refill();
				break;
			}
			case MM_BTN_SAVE:
			{
				SaveGame();
				ClosePanel();
				break;
			}
			case MM_BTN_OPTIONS:
			{
				menuState = MM_OPTIONS;
				Refill();
				break;
			}
			//dex++: user content
			case MM_BTN_USER_CONTENT_MENU:
			{
				menuState = MM_USER_CONTENT;
				Refill();
				break;
			}
			//dex--
			case MM_BTN_EXIT_GAME:
			{
				ExitGame();
				break;
			}
			case MM_BTN_CLOSE:
			{
				ClosePanel();
				break;
			}
		}
	}
	
	private final function InputMainMenu( button : int )
	{
		switch( button )
		{
			case MM_BTN_TUTORIAL:
			{
				Tutorial( false );
				break;
			}
			
			case MM_BTN_ARENA:
			{
				Arena();
				break;
			}
			case MM_BTN_NEW_GAME:
			{
				menuState = MM_IMPORT_OR_NEW;
				Refill();
				break;
			}
			case MM_BTN_LOAD_GAME:
			{
				menuState = MM_LOAD_GAME;
				Refill();
				break;
			}
			case MM_BTN_LOAD_CHAPTER:
			{
				menuState = MM_LOAD_CHAPTER;
				Refill();
				break;
			}
			//dex++
			case MM_BTN_USER_CONTENT_MENU:
			{
				menuState = MM_USER_CONTENT;
				Refill();
				break;
			}
			//dex--				
			case MM_BTN_OPTIONS:
			{
				menuState = MM_OPTIONS;
				Refill();
				break;
			}
			case MM_BTN_EXTRAS:
			{
				menuState = MM_EXTRAS;
				Refill();
				break;
			}
			case MM_BTN_QUIT:
			{
				QuitApplication();
				break;
			}
		}
	}

	private final function InputNewGame( button : int )
	{
		var difficulty : int;
		
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_IMPORT_OR_NEW;
				Refill();
				return;
			}
			// Difficulties
			//MR - Future DLC
			/*case MM_BTN_VERY_EASY:
				difficulty = -1;
				break;*/
			case MM_BTN_EASY:
				difficulty = 0;
				break;
			case MM_BTN_MEDIUM:
				difficulty = 1;
				break;
			case MM_BTN_HARD:
				difficulty = 2;
				break;
			case MM_BTN_DARK:
				difficulty = 4;
				break;
//			case MM_BTN_CASUAL:
			//	difficulty = 5;
			//	break;
			//MR - Future DLC
			/*case MM_BTN_VERY_HARD:
				difficulty = 4;
				break;*/
			case MM_BTN_INSANE:
				difficulty = 3;
				break;
		}
		// Set difficulty
		theGame.SetDifficultyLevel( difficulty );
		NewGame();

	}	
	
	//dex++: difficulty setting for user content
	private final function InputUserContentDifficulty( button : int )
	{
		var difficulty : int;
		
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_USER_CONTENT;
				Refill();
				return;
			}
			// Difficulties
			//MR - Future DLC
			/*case MM_BTN_VERY_EASY:
				difficulty = -1;
				break;*/
			case MM_BTN_EASY:
				difficulty = 0;
				break;
			case MM_BTN_MEDIUM:
				difficulty = 1;
				break;
			case MM_BTN_HARD:
				difficulty = 2;
				break;
			case MM_BTN_DARK:
				difficulty = 4;
				break;
//			case MM_BTN_CASUAL:
			//	difficulty = 5;
			//	break;
			//MR - Future DLC
			/*case MM_BTN_VERY_HARD:
				difficulty = 4;
				break;*/
			case MM_BTN_INSANE:
				difficulty = 3;
				break;
		}
		// Set difficulty
		theGame.SetDifficultyLevel( difficulty );
		LoadLevel(userContentLevelPath);

	}	

	private final function InputTutBeforeGame( button : int )
	{
		var value : float;
		

		//	theHud.Invoke( "pPanelClass.TutorialPopup" );
		//}	
	}
	
	private final function InputTutorial( button : int )
	{
		Tutorial( false );
	}
	
	private final function InputArena( button : int )
	{
		Arena();
	}	

	private final function InputLoadGame( button : int )
	{
		var message : CGuiCannotLoadSave;
		var hud : CHudInstance;
		
		if ( button == MM_BTN_BACK )
		{
			menuState = MM_MAIN;
			Refill();
		}
		else if ( button >= 0 && button < saves.Size() )
		{
			if ( saves[ button ].playerAlive == false )
			{
				// Player is dead in this save (insane difficulty)
				message = new CGuiCannotLoadSave in theHud.m_messages;
				theHud.m_messages.ShowConfirmationBox( message );
			}
			else
			{
				ClosePanel();
				theGame.ResetTutorialSettings();
				LoadGame( button );
			}
		}			
	}
	
	//dex++: user content
	private final function InputUserContent( button : int )
	{
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
			
			default:
			{
				menuState = MM_USER_CONTENT_DIFF;
				userContentLevelPath = GetUserPackageLevelPath( button );
				Refill();
			}
		}
	}
	//dex--

	private final function InputLoadChapter( button : int )
	{
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
			default:
			{
				if( chapters[ button ].questions.Size() == 0 )
				{
					// Just load level
					LoadLevel( chapters[ button ].chapterName );
				}
				else
				{
					// Ask questions
					currChapter = button;
					currQuestion = 0;
					menuState = MM_QUESTIONS;
					Refill();
				}
			}
		}
	}

	private final function InputOptions( button : int )
	{
		var message : CGuiCopyLocalSavesToSteamCloud;
		
		switch( button )
		{
			case MM_BTN_OPTIONS_STEAMCLOUD:
			{
				EnableSteamCloud( !IsSteamCloudEnabled() );
				
				if( IsSteamCloudEnabled() )
				{
					message = new CGuiCopyLocalSavesToSteamCloud in theHud.m_messages;
					message.menu = this;
					theHud.m_messages.ShowConfirmationBox( message );
				}
				
				Refill();
				break;
			}
			case MM_BTN_OPTIONS_SOUND:
			{
				menuState = MM_OPTIONS_SOUND;
				Refill();
				break;
			}
			case MM_BTN_OPTIONS_GAMEPLAY:
			{
				menuState = MM_OPTIONS_GAMEPLAY;
				Refill();
				break;
			}
			case MM_BTN_OPTIONS_GAMEPLAY_CONTROLS:
			{
				menuState = MM_OPTIONS_GAMEPLAY_CONTROLS;
				Refill();
				break;
			}
			case MM_BTN_OPTIONS_GRAPHICS:
			{
				menuState = MM_OPTIONS_GRAPHICS;
				Refill();
				break;
			}
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
		}
	}
	
	private final function InputQuestions( button : int )
	{
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
			default:
			{
				if( button >= 0 ) // Skip clicking in question
				{
					// Add initial fact
					AddFact( chapters[ currChapter ].questions[ currQuestion ].factAnswers[ button ] );
					
					// Move to next question
					currQuestion += 1;
					
					// Check if end
					if( currQuestion >= chapters[ currChapter ].questions.Size() )
					{
						// Load the level
						LoadLevel( chapters[ currChapter ].chapterName );
					}
					else
					{
						// Update menu
						Refill();
					}
				}
			}
		}
	}
	
	private final function InputExtras( button : int )
	{
		switch( button )
		{
			case MM_BTN_CREDITS:
			{
				ClosePanelOnMenuBeforeGame();
				theHud.ShowCredits();
				break;
			}
			case MM_BTN_GOG_MINIGAME:
			{
				GoToGOG( "http://www.goodoldmonk.com/" );
				break;
			}
			case MM_BTN_RECAP:
			{
				StartExtrasVideo( "recap" );
				break;
			}
			case MM_BTN_INTRO:
			{
				StartExtrasVideo( "intro" );
				break;
			}
			case MM_BTN_FLASHBACKS:
			{
				menuState = MM_FLASHBACKS;
				Refill();
				break;
			}
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
		}
	}
	
	private final function InputFlashbacks( button : int )
	{
		// standard buttons
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_EXTRAS;
				Refill();
				return;
			}
		}
		
		theHud.stopMainMenuMusicMcinekHack();
		menuState = MM_PLAYING_FLASHBACK;
		PlayVideo( fbVideoNames[button] );
	}
	
	// theHud.PlayVideo( m_fbVideoNames[button] );
	
	final function TutorialCompleted()
	{
		m_allowToUseTutorial = false;
	}
	
	function GetImportOrNewMenu()
	{
		menuState = MM_IMPORT_OR_NEW;
		Refill();
		return;
	}
	
	private final function InputSelectW1Save( button : int )
	{
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_IMPORT_OR_NEW;
				Refill();
				break;
			}
			case MM_BTN_SKIP_W1_SAVE:
			{
				menuState = MM_NEW_GAME;
				TutBeforeGame();				
				Refill();
				break;
			}
			default:
			{
				if( button >= 0 ) // Skip clicking in question
				{
					LoadW1Save( button );
					menuState = MM_NEW_GAME;
					TutBeforeGame();
					Refill();
					break;
				}
			}
		}
	}

	private final function InputImportOrNew( button : int )
	{
		switch( button )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_MAIN;
				Refill();
				break;
			}
			case MM_BTN_SKIP_W1_SAVE:
			{
				menuState = MM_NEW_GAME;
				TutBeforeGame();
				Refill();
				break;
			}
			case MM_BTN_IMPORT_W1_SAVE:
			{
				menuState = MM_SELECT_W1_SAVE;
				Refill();
				break;
			}
			//dex++: user content
			case MM_BTN_USER_CONTENT_MENU:
			{
				menuState = MM_USER_CONTENT;
				Refill();
				break;
			}	
			//dex--
		}
	}

	private final function InputOptionsSound( item : int, value : float )
	{
		switch( item )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_OPTIONS;
				Refill();
				return;
			}
			case MM_SLID_MUSIC_VOLUME:
			{
				SetMusicVolume( value );
				
				return;
			}
			case MM_SLID_FX_VOLUME:
			{
				SetFxVolume( value );
				return;
			}
			case MM_SLID_MASTER_VOLUME:
			{
				//SetMasterVolume( value );
				return;
			}
			case MM_SLID_VOICE_VOLUME:
			{
				SetVoiceVolume( value );
				return;
			}
		}
	}
		
	final function AskForDiffChange(diff : int)
	{
		var text : string;
		var textToFlash : CFlashValueScript;
		
		if(diff == 3)
		{
			text = StrUpperUTF( GetLocStringByKeyExt("DiffChangeInsane") );
		}
		else
		{
			text = StrUpperUTF( GetLocStringByKeyExt("DiffChangeDark") );
		}
		textToFlash = FlashValueFromString(text);
		theHud.InvokeOneArg("pPanelClass.PopupSelesctDiff", textToFlash);
		Refill();
	}
	final function BlockArenaDiffChange()
	{
		var text : string;
		var textToFlash : CFlashValueScript;
		text = StrUpperUTF( GetLocStringByKeyExt("ArenaDiffChange") );
		textToFlash = FlashValueFromString(text);
		theHud.InvokeOneArg("pPanelClass.InfoPopup", textToFlash);
		Refill();
	}
	final function BlockDiffChange()
	{
		var text : string;
		var textToFlash : CFlashValueScript;
		text = StrUpperUTF( GetLocStringByKeyExt("ActionBlockedNow") );
		textToFlash = FlashValueFromString(text);
		theHud.InvokeOneArg("pPanelClass.InfoPopup", textToFlash);
		Refill();
	}
	private final function InputOptionsGameplay( item : int, value : float )
	{
		var message : CGuiConfirmChangeDifficulty;
		var hud     : CHudInstance;
		var game	: CWitcherGame;
		
		hud = theHud;
		game = theGame;
	
		switch( item )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_OPTIONS;
				Refill();
				return;
			}
			case MM_SEL_DIFFICULTY:
			{
				// Player is dead in this save (insane difficulty)
				/*message = new CGuiConfirmChangeDifficulty in theHud.m_messages;
				message.difficulty = ( int ) value;
				theHud.m_messages.ShowConfirmationBox( message );*/
				
				//MR - Future DLC
				/*value -= 1;
				if( value == 4 )
					value = 3;
				else if( value == 3 )
					value = 4;*/
				if(thePlayer.IsNotGeralt())
				{
					if(theGame.GetDifficultyLevel() == 4)
					{
						BlockDiffChange();
						return;
					}
					
				}
					
				if(theGame.GetIsPlayerOnArena())
				{
					if(theGame.GetArenaManager().GetIsFighting())
					{
						BlockArenaDiffChange();
						return;
					}
				}
				
				if( theGame.tutorialenabled )
				{
					BlockArenaDiffChange();
					return;
				}
								
				if(theGame.GetDifficultyLevel() == 4 || theGame.GetDifficultyLevel() == 3)
				{
					//Refill();
					SetDiffValue( ( int ) value );
					AskForDiffChange(theGame.GetDifficultyLevel());
					Log("Diffuculty changed from " + theGame.GetDifficultyLevel());
				}
				else
				{
					SetDiffValue( ( int ) value );
					theGame.SetDifficultyLevel( ( int ) value );
				}
				return;
			}
			case MM_ONOFF_COMBAT_LOG:
			{
				hud.m_hud.combatLogEnabled = ( value == 1.0f );
				
				// Save to ini
				theGame.WriteConfigParamFloat( "User", "Gameplay", "ShowCombatLog", value );

				return;
			}
			case MM_SEL_AUDIO_LANG:
			{
				// TODO: show info about restarting game
				SetAudioLanguage( ( int ) value );
				return;
			}
			case MM_SEL_TEXT_LANG:
			{
				// TODO: show info about restarting game
				SetTextLanguage( ( int ) value );
				return;
			}
			case MM_ONOFF_AUTOCENTER_CAMERA:
			{
				// TODO: AUTOCENTER CAMERA
				return;
			}
			case MM_ONOFF_TUTORIAL:
			{
				hud.m_hud.tutorialEnabled = ( value == 1.0f );
				
				// Save to ini
				theGame.WriteConfigParamFloat( "User", "Gameplay", "ShowTutorial", value );

				return;
			}
			case MM_ONOFF_RPG_QTE:
			{
				game.hardQte = ( value == 1.0f );
				
				// Save to ini
				theGame.WriteConfigParamFloat( "User", "Gameplay", "HardQte", value );

				return;
			}
			case MM_ONOFF_SUBTITLES:
			{
				game.subtitlesEnabled = ( value == 1.0f );
				
				// Save to ini
				theGame.WriteConfigParamFloat( "User", "Gameplay", "ShowSubtitles", value );

				return;
			}
		}
	}
	
	private final function InputOptionsGameplayControls( item : int, value : float )
	{
		switch( item )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_OPTIONS;
				Refill();
				return;
			}
			case MM_SEL_CONTROLLER:
			{
				theGame.TogglePad( value == 1.0f );
				
				// Save to ini
				theGame.WriteConfigParamFloat( "User", "Gameplay", "UsePad", value );

				return;
			}
			case MM_ONOFF_INVERTX:
			{
				theGame.SetInvertCameraX( value == 1.0f );
				
				theGame.WriteConfigParamFloat( "User", "Input", "InvertCameraX", value );
				
				return;
			}
			case MM_ONOFF_INVERTY:
			{
				theGame.SetInvertCameraY( value == 1.0f );
				
				theGame.WriteConfigParamFloat( "User", "Input", "InvertCameraY", value );
				
				return;
			}
			case MM_SLID_MOUSE_SENSITIVITY:
			{
				SetMouseSensitivity( value );
				return;
			}
		}
	}

	private final function InputOptionsGraphics( item : int, value : float )
	{
		switch( item )
		{
			case MM_BTN_BACK:
			{
				menuState = MM_OPTIONS;
				Refill();
				return;
			}
			case MM_SLID_BRIGHTNESS:
			{
				SetBrightness( value );
				return;
			}
			case MM_SLID_CONTRAST:
			{
				SetContrast( value );
				return;
			}
			case MM_SLID_GAMMA:
			{
				SetGamma( value );
				return;
			}
		}
	}

	////////////////// ACTUATORS ///////////////////////////
	
	private final function ExitGame()
	{
		theGame.ExitGame();
	}
	
	private final function NewGame()
	{
		this.SetDiffSelAfterTutorial( false );
		theGame.ResetTutorialSettings();
		
		if( theGame.IsDemoBuild() )
		{
			LoadLevel( "levels\\03_camp\\world.w2w" );
		}
		else
		{
			LoadLevel( "levels\l01-keep\l01-keep.w2w" );
		}
	}	
	
	function SetDiffSelAfterTutorial( is : bool )
	{
		isDiffSelAfterTutorial = is;
	}
	
	private final function Tutorial( beforeNewGame : bool )
	{
		if( beforeNewGame )
			theGame.SetNewGameAfterTutorial( true );
	
		theGame.TutorialEnabled( true );
		thePlayer.SetManualControl( true, true );
		theGame.SetDifficultyLevel( 0 );
		LoadLevel( "levels\arena\world.w2w" );
	}

	private final function TutBeforeGame()
	{
		theHud.Invoke( "pPanelClass.TutorialPopup" ); // w odpowiedzi we flashu wywolac metode NewGame albo Tutorial
	}
	
	private final function Arena()
	{
		theGame.TutorialEnabled( false );
		LoadLevel( "levels\arena\world.w2w" );		
	}	
	
	// Called by code
	private latent final function PlayVideos()
	{
		var release : string;
		release = theGame.GetGameRelease();
		
		if ( release == "EFIGS" || release == "ROW" || release == "TW" )
		{
			theHud.PlayVideo( "namco" );
		}
		else if ( release == "GOG" )
		{
			theHud.PlayVideo( "gog" );
		}
		else if ( release == "ATARI" )
		{
			theHud.PlayVideo( "atari" );
		}
		else if ( release == "PL" || release == "HU" )
		{
			theHud.PlayVideo( "cdp" );
		}
		else if ( release == "RU" )
		{
			theHud.PlayVideo( "1c" );
		}
		else if ( release == "CZ" )
		{
			theHud.PlayVideo( "comgad" );
		}
		else if ( release == "JA" )
		{
			theHud.PlayVideo( "cf" );
		}
		
		theHud.PlayVideo( "nvidia" );
		
		if ( release == "PL" )
		{
			theHud.PlayVideo( "pl_middleware" );
		}
		else
		{
			theHud.PlayVideo( "middleware" );
		}
		
		theHud.PlayVideo( "redengine" );
		theHud.PlayVideo( "cdpr" );
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	private final function FillData()
	{
		// Find global variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mMainMenu", AS_menuData ) )
		{
			LogChannel( 'GUI', "No mMainMenu found at the Scaleform side!" );
			return;
		}
		
		// Fill menu
		Refill();
	}

	private final function GetLanguage() : string
	{
		var audio, text : string;
		theGame.GetGameLanguageName( audio, text );
		
		return text;
	}
	
	private final function IsBackgroundShown() : bool
	{
		return inGame;
	}
	
	private final function ItemRemoved( item : float )
	{		
		DeleteGameSave( ( int ) item );	
		Refill();
	}
	
	function StartExtrasVideo( videoName : string )
	{
		theHud.stopMainMenuMusicMcinekHack();
		menuState = MM_PLAYING_EXTRAS_VID;
		PlayVideo( videoName );
	}	
	
	private final function ItemChanged( item : float, value : float )
	{
		switch( menuState )
		{
			case MM_MAIN:
			{
				if( inGame )
				{
					InputMainInGame( ( int ) item );
				}
				else
				{
					InputMainMenu( ( int ) item );
				}
				break;
			}
			case MM_TUTORIAL:
			{
				InputTutorial( ( int ) item );
				break;
			}
			case MM_ARENA:
			{
				InputArena( ( int ) item );
				break;
			}
			case MM_NEW_GAME:
			{
				InputNewGame( ( int ) item );
				break;
			}			
			case MM_TUTORIAL_BEFORE_GAME:
			{
				InputTutBeforeGame( ( int ) item );
				break;
			}
			case MM_TUTORIAL_SELECT_DIFFICULTY:
			{
				InputNewGame( ( int ) item );
				break;
			}
			case MM_LOAD_GAME:
			{
				InputLoadGame( ( int ) item );
				break;
			}
			case MM_LOAD_CHAPTER:
			{
				InputLoadChapter( ( int ) item );
				break;
			}
			//dex++: user cotent
			case MM_USER_CONTENT:
			{
				InputUserContent( ( int ) item );
				break;
			}
			case MM_USER_CONTENT_DIFF:
			{
				InputUserContentDifficulty( (int)item );
				break;
			}				
			//dex--
			case MM_OPTIONS:
			{
				InputOptions( ( int ) item );
				break;
			}
			case MM_QUESTIONS:
			{
				InputQuestions( ( int ) item );
				break;
			}
			case MM_EXTRAS:
			{
				InputExtras( ( int ) item );
				break;
			}
			case MM_FLASHBACKS:
			{
				InputFlashbacks( ( int ) item );
				break;
			}
			case MM_OPTIONS_SOUND:
			{
				InputOptionsSound( ( int ) item, value );
				break;
			}
			case MM_OPTIONS_GAMEPLAY:
			{
				InputOptionsGameplay( ( int ) item, value );
				break;
			}
			case MM_OPTIONS_GAMEPLAY_CONTROLS:
			{
				InputOptionsGameplayControls( ( int ) item, value );
				break;
			}
			case MM_OPTIONS_GRAPHICS:
			{
				InputOptionsGraphics( ( int ) item, value );
				break;
			}
			case MM_SELECT_W1_SAVE:
			{
				InputSelectW1Save( ( int ) item );
				break;
			}
			case MM_IMPORT_OR_NEW:
			{
				InputImportOrNew( ( int ) item );
				break;
			}
		}
	}
}	

	
////////////////// TUTORIAL CALLED FUNCTIONS ///////////
	
	
function StartNewGame()
{
	theGame.SetNewGameAfterTutorial( false );
	theGame.TutorialEnabled( false );
	theGame.SetActivePause( false );
	FactsAdd( "load_prologue_after_tutorial", 1 );
}

function SelectDifficultyAfterTutorial()
{
	var args : array< CFlashValueScript> ; 

	theGame.SetNewGameAfterTutorial( false );
	theGame.TutorialEnabled( false );	
	
	args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyEasy" ) ) ) );
	args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyMedium" ) ) ) );
	args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyHard" ) ) ) );		
	args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyVeryHard" ) ) ) );
	args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( "menuDifficultyInsane" ) ) ) );
	
	theHud.InvokeManyArgs( "vHUD.DifficultySelection", args );		
}	
