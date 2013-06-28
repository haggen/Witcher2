/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CHudInstance
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

import class CHudInstance extends CFlashInstance
{
	import var guiWidth,		guiHeight		: float;
	
	// Minimap
	import var miniMapMinX,		miniMapMaxX		: float;
	import var miniMapMinY,		miniMapMaxY		: float;
	import var miniMapScaleX,	miniMapScaleY	: float;
	import var miniMapWidth,	miniMapHeight	: float;
	
	// Nav Map
	import var navMapMinX,		navMapMaxX		: float;
	import var navMapMinY,		navMapMaxY		: float;
	import var navMapWidth, 	navMapHeight 	: float;
	import var navMapScaleX, 	navMapScaleY 	: float;
	
	private var m_shouldResetCursor : bool;
	default m_shouldResetCursor = true;
	
	// "Namespaces" and panels
	var m_hud			: CGuiHud;
	var m_map			: CGuiMap;
	var m_messages		: CGuiMessages;
	var m_fx			: CGuiFX;
	var m_keys			: CGuiKeys;
	var m_inventory		: CGuiInventory;
	var m_character		: CGuiCharacter;
	var m_journal		: CGuiJournal;
	var m_meditation	: CGuiMeditation;
	var m_shop			: CGuiShop;
	var m_shopNew		: CGuiShopNew;
	var m_bribe			: CGuiBribe;
	var m_alchemyNew	: CGuiAlchemyStandalone;
	var m_craft			: CGuiCraft;
	var m_sleep			: CGuiSleep;
	var m_wrist			: CGuiWristWrestling;
	var m_dice			: CGuiDice;
	var m_elixirs		: CGuiElixirs;
	var m_overview		: CGuiOverview;
	var m_video			: CGuiVideo;
	var m_nav			: CGuiMapBig;
	var m_board			: CGuiBoard;
	var m_poster		: CGuiPoster;
	var m_mainMenu		: CGuiMainMenu;
	var m_creditsPanel	: CGuiCredits;
	
	var m_utils			: CGuiUtils;
	var m_mapCommon		: CGuiMapCommon;
	
	var m_isLaunchPanel : bool;
	var m_waitKeyCode	: int;
	var m_wasWaitKeyCodePressed : bool;
	
	var m_guiCameraEffect : int;
	
	var m_arena : CGuiArena;
	var m_arenadiff : CGuiArenaDiff;
	var m_arenafail : CGuiArenaFail;
	var m_arenaend : CGuiArenaEnd;
	
	var m_darkend : CGuiDarkEnd;
	
	var m_controls : CGuiControls;
	var m_tutfinish : CGuiTutorialFinish;
	var m_tutold : CGuiTutorialOld;
	var m_tutnew : CGuiTutorialNew;
	
	private var forbidOpeningMainMenu : int;
	default forbidOpeningMainMenu = 0;
	
	public var BEH_TRANS_IDLE : name;
	default BEH_TRANS_IDLE = 'idle';
	public var BEH_TRANS_ELIXIRS : name;
	default BEH_TRANS_ELIXIRS = 'elixir';
	public var BEH_TRANS_DRINK : name;
	default BEH_TRANS_DRINK = 'elixir_drink';
	public var BEH_TRANS_EFFECT1 : name;
	default BEH_TRANS_EFFECT1 = 'effect_01';
	public var BEH_TRANS_EFFECT2 : name;
	default BEH_TRANS_EFFECT2 = 'effect_02';
	public var BEH_TRANS_EFFECT3 : name;
	default BEH_TRANS_EFFECT3 = 'effect_03';
	public var BEH_TRANS_ALCHEMY : name;
	default BEH_TRANS_ALCHEMY = 'alchemy';
	public var BEH_TRANS_CHARACTER : name;
	default BEH_TRANS_CHARACTER = 'character';
	
	public var BEH_ACT_IDLE : name;
	default BEH_ACT_IDLE = 'idle_start';
	public var BEH_ACT_ELIXIRS : name;
	default BEH_ACT_ELIXIRS = 'elixir_start';
	public var BEH_ACT_ALCHEMY : name;
	default BEH_ACT_ALCHEMY = 'alchemy_start';
	public var BEH_ACT_CHARACTER : name;
	default BEH_ACT_CHARACTER = 'character_start';
	
	default m_guiCameraEffect = 0;
	
	var m_panelSwitch:string; //panel switch
	var m_meditationTrans : name;
	var m_meditationTransSecond : name;
	
	private var m_isGuiVisible : bool;
	default m_isGuiVisible = true;
	
	final function SetMeditationTransitions(firstTrans:name, secondTrans:name)
	{
		m_meditationTrans = firstTrans;
		m_meditationTransSecond = secondTrans;		
	}
	
	event OnGameStarting()
	{
		m_hud			= new CGuiHud		in this;
		m_map			= new CGuiMap		in this;
		m_messages		= new CGuiMessages	in this;
		m_fx			= new CGuiFX		in this;
		m_keys			= new CGuiKeys		in this;
		m_inventory		= NULL;
		m_character		= NULL;
		m_journal		= NULL;
		m_meditation	= NULL;
		m_shop			= NULL;
		m_shopNew		= NULL;
		m_craft			= NULL;
		m_board			= NULL;
		m_poster		= NULL;
		m_utils			= new CGuiUtils	in this;
		m_isLaunchPanel	= false;
		m_mapCommon		= new CGuiMapCommon in this;
		m_arena 		= NULL;
		m_controls 		= NULL;
		
		m_meditationTrans = BEH_TRANS_IDLE;
		m_meditationTransSecond = '';
		m_panelSwitch = "";
		m_waitKeyCode = 0;
		m_wasWaitKeyCodePressed = true;
	
		
		m_hud.OnGameStarting();
		
		SetBool( "_global.DEBUG", false );
		
		SetBool( "MovieClip.prototype.tabEnabled", false );
		
		UpdateKeyBindings();
		m_utils.Initialize();
	}
	
	event OnGameStarted()
	{
		//theHud.AllowOpeningMainMenu();
	}
	
	event OnGameEnded()
	{
		//theHud.ForbidOpeningMainMenu();
	}
	
	
	
	// ---------------------------------------------------------------------------------------------------
	// Global imports
	// ---------------------------------------------------------------------------------------------------
	import final function EnableInput( enableMouse, enableKeyboard, showCursor : bool, optional resetCursorPos : bool /* = true */ );
	import final function DisablePadLeftAxis( disablePad : bool );
	
	import final function EnableWorldRendering( renderWorld : bool );
	
	import final function ShowInteractionIcon( actionIK : string, actionName : string );
	import final function ShowInteractionIconKeyCode( inputKey : int, actionName : string );
	
	import final function PlayVideoSave( videoName : string );
	
	// ---------------------------------------------------------------------------------------------------
	// Cache imports
	// ---------------------------------------------------------------------------------------------------
	import final function BeginPreloadIcons( groupName : CName, groupSize : int );
	import final function PreloadIcon( url : string );
	import final function EndPreloadIcons( );
	
	// ---------------------------------------------------------------------------------------------------
	// Hud imports
	// ---------------------------------------------------------------------------------------------------
	import private final function HudTargetActor( actor : CActor, optional isBoss : bool /*=false*/ );
	import private final function HudTargetEntity( entity : CGameplayEntity );
	
	import private final function GainFocus();
	
	import private final function SetBalistaScope( balistaScope : bool );
	import private final function CenterMouse();
	
	// ---------------------------------------------------------------------------------------------------
	// Map imports
	// ---------------------------------------------------------------------------------------------------
	import final function MapPinShow( entity : CEntity, type : string, staticPin : bool );
	import final function MapPinHide( entity : CEntity );
	
	import final function GetQuestMapPinsPositions( out questMapPinsPositions : array< Vector > );
	
	import final function GetMapInfo( mapIndex : int, mapIndexDefault : int, out mapFile : string, out miniMapFile : string, out flipX : bool, out flipY : bool ) : bool;
	import final function MapLoad( mapIndex : int );
		
	import latent final function WaitForEvent( eventName : string );
	
	import final function GetFOWInfo( mapIndex: int, out fowInfo : array<int>, out grid : int ) : bool;

	import final function GetNavMapPins( out pins : array< Vector >, out kinds : array< int >, out navMapDescs : array< string >, out navMapPinTags : array< name > );

	// enables previously disabled map pin tag for quest tracked map pins
	import final function EnableTrackedMapPinTag( mapPinTag : name );
	
	// disables map pin tag for quest tracked map pins
	import final function DisableTrackedMapPinTag( mapPinTag : name );
	
	// enables previously disabled map pin tag for quest tracked map pins
	import final function EnableTrackedQuestMapPinTag( mapPinTag : name, questTag : name );
	
	// disables map pin tag for quest tracked map pins
	import final function DisableTrackedQuestMapPinTag( mapPinTag : name, questTag : name );
	
	// Gets currently loaded map's id
	import final function GetLoadedMapId() : int;
	
	// ---------------------------------------------------------------------------------------------------
	// Input imports
	// ---------------------------------------------------------------------------------------------------
	
	import final function BindAction( guiAction, engineAction : string );
	
	// Called by C++
	final function UpdateKeyBindings()
	{
		m_keys.UpdateKeyBindings();
		m_hud.UpdateKeyBindings();
	}
	
	final function OnNoHudStart()
	{	
		m_fx.NoHudStart();
	}
	
	final function OnNoHudStop()
	{
		m_fx.NoHudStop();
	}
	
	final function OnGuiCameraEffectOn( effect : int )
	{
		if ( m_guiCameraEffect == effect )
		{
			return;
		}
		
		if ( m_guiCameraEffect != SCGE_None )
		{
			OnGuiCameraEffectOff();
		}
		
		switch ( effect )
		{
			case SCGE_Hole:
			{
				m_fx.HoleStart();
				break;
			}
		}
		
		m_guiCameraEffect = effect;
	}
	
	final function OnGuiCameraEffectOff()
	{
		switch ( m_guiCameraEffect )
		{
			case SCGE_Hole:
			{
				m_fx.HoleStop();
				break;
			}
		}
		
		m_guiCameraEffect = SCGE_None;
	}
	
	// hack
	function SetWaitForKeyCode( key : int )
	{
		m_waitKeyCode = key;
		m_wasWaitKeyCodePressed = false;
	}
	
	function WasWaitKeyPressed() : bool
	{
		return m_wasWaitKeyCodePressed;
	}
	
	function ReleaseWaitingForKeyPressed()
	{
		m_wasWaitKeyCodePressed = true;
	}
	
	private function CanShowMainMenu() : bool
	{
		var canShowMenu : bool;
		
		canShowMenu = true;
		
		if(thePlayer.GetLastQTEResult() == QTER_InProgress)
		{
			canShowMenu = false;
		}
		else if(theGame.IsFading())
		{
			canShowMenu = false;
		}
		else if(theGame.IsBlackscreen())
		{
			canShowMenu = false;
		}
		else if(forbidOpeningMainMenu)
		{
			canShowMenu = false;
		}
		else if(thePlayer.GetCurrentStateName() == 'Meditation')
		{
			canShowMenu = false;
		}
		return  canShowMenu;
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float )
	{
		if ( action == IACT_Press )
		{
			if( 
				// Special case, when pad is disconnected
				( ! theGame.IsPadConnected() && key == 27 /* ESC */ )
				
				// When using pad...
				|| ( theGame.IsUsingPad() && key == 140 /* IK_Pad_Start */ )
				
				// When using keyboard...
				|| ( ! theGame.IsUsingPad() && m_keys.m_ikGameExit == key )
				)
			{
				if ( CanShowMainMenu() )
				{
					ShowMainMenu();
				}
				
				return true;
			}
		}
		
		if ( action == IACT_Press && !m_wasWaitKeyCodePressed && key == m_waitKeyCode )
		{
			m_wasWaitKeyCodePressed = true;
			return true;
		}
		
		return false;
	}
	
	import final function GetMousePosition( out x : int, out y : int );
	
	// ---------------------------------------------------------------------------------------------------
	// HUD
	// ---------------------------------------------------------------------------------------------------
	public function ShowHud()
	{
		//SetHudVisible( true );
	}
	
	public function HideHud()
	{
		//SetHudVisible( false );
	}
	
	public function ShowGui()
	{
		SetGuiVisibility( true );
	}
	
	public function HideGui()
	{
		SetGuiVisibility( false );
	}	
	
	public function SetHudVisibility( isVisible : string )
	{
		//theHud.InvokeOneArg( "vHUD.hudVisible", FlashValueFromString( isVisible ) );
	}
	
	public function SetHudVisible( isVisible : bool )
	{
		//theHud.InvokeOneArg( "vHUD.hudVisible", FlashValueFromBoolean( isVisible ) );
	}
	
	
	public function SetGuiVisibility( isVisible : bool )
	{
		m_isGuiVisible = isVisible;
		theHud.InvokeOneArg( "SetGuiVisibility", FlashValueFromBoolean( isVisible ) );
	}
	
	public function IsGuiVisible() : bool
	{
		return m_isGuiVisible;
	}

	public function SetItemSlotsVisibility( isVisible : bool )
	{
		theHud.InvokeOneArg( "vHUD.ShowItemSlots", FlashValueFromBoolean( isVisible ) );
	}
	
	// ---------------------------------------------------------------------------------------------------
	// Obsoletes to reimplement
	// ---------------------------------------------------------------------------------------------------
	
	// WTF?
	final function PauseTime( val : bool)
	{}
	
	final function ShowCrafting()
	{
		theHud.ShowCraft();
	}
	
	final function ShowScroll( text : string )
	{}
	final function HideScroll()
	{}
	
	final function ShowBook( text : string )
	{}
	
	// ---------------------------------------------------------------------------------------------------
	// Icons
	// ---------------------------------------------------------------------------------------------------
	
	import final function FindIconPath( iconName : string, out url : string, out width : int, out height : int ) : bool;
	
	// ---------------------------------------------------------------------------------------------------
	// Misc
	// ---------------------------------------------------------------------------------------------------
	
	public function IsResetCursorEnabled() : bool
	{
		return m_shouldResetCursor;
	}
	
	public function SetResetCursor( reset : bool )
	{
		m_shouldResetCursor = reset;
	}
	
	// ---------------------------------------------------------------------------------------------------
	// Panels
	// ---------------------------------------------------------------------------------------------------
	
	private function LoadBG( nazwa : string )
	{
		var customPanelUrl : string;
		var arguments : array< CFlashValueScript >;

		// Debug only - check if custom panel has video panel loaded
		GetString( "vCustomPanel._url", customPanelUrl );
		customPanelUrl = StrReplaceAll( customPanelUrl, "%5F", "_" );
		if ( customPanelUrl != "globals/gui/ui_panelbg.swf" )
		{
			LogChannel( 'GUI', "LoadBG(): Custom panel doesn't have video loaded. The current panel is URL: " + customPanelUrl );
		}

		// Load movie
		arguments.PushBack( FlashValueFromString(nazwa) );
		arguments.PushBack( FlashValueFromBoolean( true ) );
		theHud.InvokeManyArgs( "vCustomPanel.PlayVideo", arguments );
	}
	
	private function UnloadBG()
	{
		var arguments : array< CFlashValueScript >;

		//var arguments : array< CFlashValueScript >; 
		//arguments.PushBack( FlashValueFromString(nazwa) );
		//arguments.PushBack( FlashValueFromInt( 0 ) );
		//arguments.PushBack( FlashValueFromBoolean( false ) );
		//theHud.InvokeManyArgs( "vCustomPanel.StopVideo", arguments );

		arguments.PushBack( FlashValueFromString("ui_panelbg.swf") );
		theHud.InvokeManyArgs( "vCustomPanel.loadMovie", arguments );	
	}
	
	import final function CloseAllPanels();
	
	final function ProcessPanelSwitch( panelName : string )
	{
		var count, i : int;
		
		m_isLaunchPanel = true;
		
		theHud.EnableInput( true, true, true, false );
		
		// Called from Meditation panel
		if ( panelName == "N" )
		{
			ShowAlchemyNew();
			m_alchemyNew.SetPreviousPanel( "meditation" );
		}
		else if ( panelName == "W" )
		{
			ShowCharacter( true );
			m_character.SetPreviousPanel( "meditation" );
		}
		else if ( panelName == "S" )
		{
			ShowSleep();
			m_sleep.SetPreviousPanel( "meditation" );
		}
		else if ( panelName == "E" )
		{
			ShowElixirs();
			m_elixirs.SetPreviousPanel( "meditation" );
		}
		else if (panelName == "C")
		{
			ShowCraft();
			m_craft.SetPreviousPanel( "meditation" );
		}
		
		// Globals
		else if ( panelName == "drink_elixirs" )
		{
			ShowElixirs();
		}
		else if ( panelName == "meditation" )
		{
			//process all items that needs processing
			count = m_utils.m_itemBag.Size();
			for ( i = 0; i < count; i += 1 )
			{					
				thePlayer.UseItem( m_utils.m_itemBag[i] );
				// thePlayer.SelectThrownItem( m_utils.m_itemBag[i] ); // why to put elixirs intho trown item?
			}
			m_utils.m_itemBag.Clear();
			
			ShowMeditation();
		}
		
		m_isLaunchPanel = false;
	}
	
	// TODO: This method can open any available panel
	final function LaunchPanel( panelName : string )
	{
		Log( "==================================" +theGame.tutorialenabled +"=================" );
		// check for bans
		if ( panelName == "S" && !thePlayer.IsWaitTimeAllowed() )  // wait time
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "meditation_disabled" ) );
			return;
		}

		m_isLaunchPanel = true;
		
		// Called from Meditation panel
		if ( panelName == "N" )
		{
			//latent call for alchemy
			//theHud.ForbidOpeningMainMenu(); //block ESC
			
			thePlayer.ChangeMeditationState('','',panelName);
			//thePlayer.ChangeMeditationState(BEH_TRANS_ALCHEMY,BEH_ACT_ALCHEMY,panelName);
			theHud.EnableInput( false, false, false );
		}
		else if ( panelName == "W" )
		{
			//latent call for character
			//theHud.ForbidOpeningMainMenu(); //block ESC
			thePlayer.ChangeMeditationState(BEH_TRANS_CHARACTER,BEH_ACT_CHARACTER,panelName);
		}
		else if ( panelName == "S" )
		{
			
			if ( !theGame.IsGameTimePaused() ) 
			{
				ShowSleep();
				m_sleep.SetPreviousPanel( "meditation" );
			} 
			
			else if ( theGame.tutorialenabled && theGame.IsGameTimePaused() )
			{
				ShowSleep();
				m_sleep.SetPreviousPanel( "meditation" );
			}
			else
			{
				theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("WaitTimeBlocked") );
				thePlayer.StateMeditationExit();
			}
			
		}
		else if ( panelName == "E" )
		{
			//theHud.ForbidOpeningMainMenu();
			thePlayer.ChangeMeditationState(BEH_TRANS_ELIXIRS,BEH_ACT_ELIXIRS,panelName);
			theHud.EnableInput( false, false, false );
		}
		else if (panelName == "C")
		{
			ShowCraft();
			m_craft.SetPreviousPanel( "meditation" );
		}
		
		// Globals
		else if ( panelName == "drink_elixirs" )
		{
			ShowElixirs();
		}
		else if ( panelName == "meditation" )
		{
			//theGame.SetActivePause( false );
			//latent call for character
			//theHud.ForbidOpeningMainMenu(); //block ESC
			thePlayer.ChangeMeditationState2(m_meditationTrans,m_meditationTransSecond,BEH_ACT_IDLE,panelName);
		}
		
		m_isLaunchPanel = false;
	}
	
	public function IsLaunchPanel() : bool
	{
		return m_isLaunchPanel;
	}
	
		// returns true on success
	latent final function WaitForPanelLoad( panelPath : string ) : bool
	{
		var url : string;
		var i   : int;

		GetString( "pPanelClass._url", url );
		
		panelPath = StrReplaceAll( panelPath, "_", "%5F" );
		panelPath = "globals/gui/" + panelPath;
		
		
		//while ( url == "globals/gui/gui.swf" )
		while ( url != panelPath )
		{
			Sleep( 0.1 );
			GetString( "pPanelClass._url", url );	
			
			// Timeout
			i += 1;
			if ( i > 50 )
			{
				return false;
			}
		}
		
		return true;
	}
	
	final function IsPanelLoaded( panelPath : string ) : bool
	{
		var url : string;
		var i   : int;
		
		GetString( "pPanelClass._url", url );
		
		panelPath = StrReplaceAll( panelPath, "_", "%5F" );
		panelPath = "globals/gui/" + panelPath;
		
		//return url == panelPath;
		if (url == panelPath)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	// debug only
	public final function GetLoadedPanelName() : string
	{
		var url : string;
		
		GetString( "pPanelClass._url", url );
		
		return url;
	}
	
	final function ShowInventory()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		if( theGame.isMenuInventoryBlocked )
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_inventory )
		{
			m_inventory = new CGuiInventory in this;
		}
		m_inventory.OpenPanel( "inventory", true, false, true );
		
		//LoadBG( 'inventory' );
		
	}
	final function HideInventory()
	{
		var guiPanel : CGuiPanel = m_inventory;
		m_inventory = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	final function ShowArena()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_arena )
		{
			m_arena = new CGuiArena in this;
		}
		m_arena.OpenPanel( "journal", true, false, true );
		//m_arena.FillData();
		//LoadBG( 'inventory' );
		
	}
	final function HideArena()
	{
		var guiPanel : CGuiPanel = m_arena;
		m_arena = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowDarkEnd()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_darkend )
		{
			m_darkend = new CGuiDarkEnd in this;
		}
		m_darkend.OpenPanel( "", false, true, false);
		
	}
	
	final function ShowArenaDiff()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_arenadiff )
		{
			m_arenadiff = new CGuiArenaDiff in this;
		}
		m_arenadiff.OpenPanel( "", false, true, false);
		//m_arena.FillData();
		//LoadBG( 'inventory' );
		
	}
	final function HideArenaDiff()
	{
		var guiPanel : CGuiPanel = m_arenadiff;
		m_arenadiff = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	final function ShowArenaFail()
	{
		//theSound.PlaySound("gui/arena_jingles/arena_death");
		
		if ( !thePlayer.CanUseHud() && !m_arenaend )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_arenafail )
		{
			m_arenafail = new CGuiArenaFail in this;
		}
		m_arenafail.OpenPanel( "journal", true, false, true);
		//m_arena.FillData();
		//LoadBG( 'inventory' );
		
	}
	final function HideArenaFail()
	{
		var guiPanel : CGuiPanel = m_arenafail;
		m_arenafail = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowArenaEnd()
	{
		if ( !thePlayer.CanUseHud() && thePlayer.IsAlive() && !m_arenafail )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_arenaend )
		{
			m_arenaend = new CGuiArenaEnd in this;
		}
		m_arenaend.OpenPanel( "journal", true, false, true);
		//m_arena.FillData();
		//LoadBG( 'inventory' );
		
	}
	final function HideArenaEnd()
	{
		var guiPanel : CGuiPanel = m_arenaend;
		m_arenaend = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}

	final function ShowControls()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_controls )
		{
			m_controls = new CGuiControls in this;
		}
		m_controls.OpenPanel( "journal", true, false, true );
		//m_arena.FillData();
		//LoadBG( 'inventory' );
		
		
	}
	final function HideControls()
	{
		var guiPanel : CGuiPanel = m_controls;
		m_controls = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}

	final function ShowTutorialPanel()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();

		if ( ! m_tutnew )
		{
			m_tutnew = new CGuiTutorialNew in this;
		}
		m_tutnew.OpenPanel( "", false, false, true );
	}
		
	final function HideTutorialPanel()
	{
		var guiPanel : CGuiPanel = m_tutnew;
		m_tutnew = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}

	final function ShowTutorialPanelOld( tutorialId : string, tutorialImage : string ) : bool
	{
		/*
		var cam : CStaticCamera;
	
		if ( !thePlayer.CanUseHud() )
			return true;
		
		if( theGame.tutorialHideOldPanels )
		{
			return true;
		}

		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}

		cam = (CStaticCamera)theGame.GetActiveCameraComponent().GetEntity();
		//if( theGame.GetActiveCameraComponent().GetCurrentStateName() == theCamera.GetComponent() )		

		if( cam )
		{
			return true;
		}	

		HideLootWindow();
		theHud.m_hud.clearEntryText();
	
		theGame.SetOldTutorialDataNew( tutorialId, tutorialImage );

		if ( ! m_tutold )
		{
			m_tutold = new CGuiTutorialOld in this;
		}
		
		if ( !FactsDoesExist("tutorial_" + tutorialId) && tutorialId!="" && !FactsDoesExist("tutorial_showed") )
		{
			FactsAdd("tutorial_" + tutorialId, 1);
			FactsAdd("tutorial_showed", 1);

			if( theHud.m_hud.tutorialEnabled )
			{
				thePlayer.ResetPlayerMovement();
				m_tutold.OpenPanel( "", false, false, true );
			}	
		}	
		
		return true;
		*/
	}

	final function HideTutorialPanelOld()
	{
	/*
		var guiPanel : CGuiPanel = m_tutold;
		m_tutold = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	*/	
	}

	final function ShowTutorialFinish()
	{
		if ( !thePlayer.CanUseHud() )
			return;

		//theHud.Invoke("fadeLoaderOn");
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		if ( ! m_tutfinish )
		{
			m_tutfinish = new CGuiTutorialFinish in this;
		}
		m_tutfinish.OpenPanel( "", false, false, true );
	}
	
	final function HideTutorialFinish()
	{
		var guiPanel : CGuiPanel = m_tutfinish;
		m_tutfinish = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowCharacter( isInteractive : bool )
	{
		if( theGame.isMenuCharacterBlocked )
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}
		if ( !thePlayer.CanUseHud() )
			return;
		HideLootWindow();
		theHud.m_hud.clearEntryText();

		if ( ! m_character )
		{
			m_character = new CGuiCharacter in this;
		}
		if ( theGame.GetDifficultyLevel() < 2 || theGame.GetIsPlayerOnArena()) 
		{
			m_character.SetIsInteractive( true );
		} else
		{
			m_character.SetIsInteractive( isInteractive );
		}
		m_character.OpenPanel( "character", true, false, true );
	}
	final function HideCharacter()
	{
		var guiPanel : CGuiPanel = m_character;		
		m_character = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowJournal()
	{
		if(theGame.GetIsPlayerOnArena())
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}
		
		if( theGame.isMenuJournalBlocked )
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_journal )
		{
			m_journal = new CGuiJournal in this;
		}
		
		m_journal.OpenPanel( "alchemy", true, true, true );
	}
	final function HideJournal()
	{
		var guiPanel : CGuiPanel = m_journal;
		m_journal = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowMeditation()
	{
		if ( !thePlayer.CanUseHud() )
			return;
			
		theHud.m_hud.clearEntryText();
		//reset transformations
		m_meditationTrans = BEH_TRANS_IDLE;
		m_meditationTransSecond = '';
		
		if ( ! m_meditation )
		{
			m_meditation = new CGuiMeditation in this;
		}
		m_meditation.OpenPanel( "", false, false, true );
		FactsAdd("isMeditating", 1);
	}
	final function HideMeditation()
	{
		var guiPanel : CGuiPanel = m_meditation;
		m_meditation = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
			
		theHud.SetHudVisibility("true");
		FactsRemove("isMeditating");
	}
	
	final function ShowShop( merchant : CActor )
	{

		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! merchant )
		{
			return;
		}
		
		if ( ! m_shop )
		{
			m_shop = new CGuiShop in this;
		}
		m_shop.m_merchant = merchant;
		m_shop.OpenPanel( "", true, true, true );
	}
	final function HideShop()
	{
		var guiPanel : CGuiPanel = m_shop;
		m_shop = NULL;
		
		theHud.m_hud.ShowTutorial("tut71", "", false);
		//theHud.ShowTutorialPanelOld( "tut71", "" );
		thePlayer.AddTimer( 'ShowRefillTutorial', 5.0f, true );
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}
	
	final function ShowShopNew( merchant : CActor, optional is_storage : bool, optional storage : W2PlayerStorage )
	{
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		
		
		if ( ! merchant )
		{
			return;
		}
		
		if( ! storage )
		{
			thePlayer.SetShopOwner( merchant );
		}
		else 
		{
			thePlayer.SetStorageOwner( storage );
		}
		
		if ( ! m_shopNew )
		{
			m_shopNew = new CGuiShopNew in this;
		}
		m_shopNew.m_merchant = merchant;
		m_shopNew.m_storage = storage;
		
		if( storage )
		{
			m_shopNew.is_storage = is_storage;
		}	
		m_shopNew.OpenPanel( "inventory", true, true, true );
	}
	final function HideShopNew()
	{
		var guiPanel : CGuiPanel = m_shopNew;
		m_shopNew = NULL;
		thePlayer.AddTimer( 'ShowRefillTutorial', 5.0f, true );		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}

	
	latent function ShowBribe( min : int, max : int, text : string ) : int
	{
		var bribeAmount : int;
		var geraltMoney : int;
		
		HideLootWindow();
		if ( ! m_bribe )
		{
			m_bribe = new CGuiBribe in this;
		}

		m_bribe.OpenPanel( "", false, false, true );

		// Hack for GUI init
		Sleep( 0.1f );
		
		// Show bribe panel
		m_bribe.Bribing( min, max );
		m_bribe.ShowInformation( text );
		
		// Set geralt money GUI
		geraltMoney = thePlayer.GetInventory().GetItemQuantityByName( 'Orens' );
		m_bribe.SetPlayerMoney( geraltMoney );
		
		// Wait for selection
		m_bribe.WaitForPlayer();
		
		m_bribe.ClosePanel();
		
		// Return selected amount - 0 if canceled
		return m_bribe.bribeAmount;
	}
	
	final function ShowCraft()
	{
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_craft )
		{
			m_craft = new CGuiCraft in this;
		}
		
		m_craft.OpenPanel( "alchemy", true, true, true );
	}
	final function HideCraft()
	{
		var guiPanel : CGuiPanel = m_craft;
		m_craft = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}

	final function ShowAlchemyNew()
	{
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_alchemyNew )
		{
			m_alchemyNew = new CGuiAlchemyStandalone in this;
		}

		m_alchemyNew.OpenPanel( "alchemy", true, false, true );
	}
	final function HideAlchemyNew()
	{
		var guiPanel : CGuiPanel = m_alchemyNew;		
		m_alchemyNew = NULL;
		
		if ( guiPanel )
		{
			//guiPanel.ClosePanel();
		}
	}
	
	final function ShowSleep()
	{
		if ( ! m_sleep )
		{
			m_sleep = new CGuiSleep in this;
		}

		m_sleep.OpenPanel( "", true, false, true );
	}

	final function HideSleep()
	{
		var guiPanel : CGuiPanel = m_sleep;
		m_sleep = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}
	
	final function ShowElixirs()
	{
		HideLootWindow();
		if ( ! m_elixirs )
		{
			m_elixirs = new CGuiElixirs in this;
		}
		
		m_elixirs.OpenPanel( "alchemy", true, false, true );
	}
	final function HideElixirs()
	{
		var guiPanel : CGuiPanel = m_elixirs;
		m_elixirs = NULL;
		
		if ( guiPanel )
		{			
			//guiPanel.ClosePanel();
		}
		
	}
	
	final function ShowOverview()
	{
		/*HideLootWindow();
		if ( ! m_overview )
		{
			m_overview = new CGuiOverview in this;
		}
		
		m_overview.OpenPanel( "overview", true, true, true );*/
	}
	final function HideOverview()
	{
		/*var guiPanel : CGuiPanel = m_overview;
		m_overview = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}*/
	}

	final function ShowBoard( messages : array < string >, ids : array< SItemUniqueId >, questBoard	: CQuestBoard )
	{
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_board )
		{
			m_board = new CGuiBoard in this;
		}

		m_board.SetBoardData( messages, ids, questBoard );
		m_board.OpenPanel( "", false, false, true );
	}
	
	final function HideBoard()
	{
		var guiPanel : CGuiPanel = m_board;
		m_board = NULL;
		
		theHud.Invoke("fadeLoaderOn");
		
		if ( guiPanel )
		{			
			guiPanel.ClosePanel();
		}
	}
	
	final function ShowPoster( posterVar : poster )
	{
		//HideLootWindow();
		if ( ! m_poster )
		{
			m_poster = new CGuiPoster in this;
		}
		m_poster.Init( posterVar );

		m_poster.OpenPanel( "", false, true, true );
	}
	final function HidePoster()
	{
		var guiPanel : CGuiPanel = m_poster;
		m_poster = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}	

	final function ShowNav()
	{

		if( theGame.isMenuMapBlocked )
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}
		
		if(theGame.GetIsPlayerOnArena())
		{
			theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
			return;
		}
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_nav )
		{
			m_nav = new CGuiMapBig in this;
		}
		
		m_nav.OpenPanel( "", true, true, true );
	}
	final function HideNav()
	{
		var guiPanel : CGuiPanel = m_nav;
		m_nav = NULL;

		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}
	
	public final function ShowVideo()
	{		
		HideLootWindow();
		theHud.m_hud.clearEntryText();
		if ( ! m_video )
		{
			m_video = new CGuiVideo in this;
		}
		
		m_video.OpenPanel( "", false, false, true );
	}
	
	public final function HideVideo()
	{
		var guiPanel : CGuiPanel = m_video;
		m_video = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}
	
	private latent final function WaitForVideoPanelLoaded() : bool
	{
		var numTries : int = 50;

		if ( m_video )
		{
			while( numTries )
			{
				if ( m_video.IsPanelLoaded() )
				{
					return true;
				}
				Sleep( 0.1 );
				numTries -= 1;
			}
		}

		return false;
	}
	
	public final function ShowMainMenu()
	{
		if ( ! m_mainMenu )
		{
			m_mainMenu = new CGuiMainMenu in this;
		}
		
		m_mainMenu.inGame = true;
		m_mainMenu.OpenPanel( "", false, true, true );
	}
	
	public final function ShowMenuBeforeGame( optional startingMenuState : EMainMenuState )
	{
		//if ( ! m_mainMenu )
		//{
			m_mainMenu = new CGuiMainMenu in this;
		//}
		
		m_mainMenu.SetStartingMenuState( startingMenuState );
		m_mainMenu.ShowMenuBeforeGame();
	}
	
	public final function ShowCredits()
	{
		theHud.m_hud.clearEntryText();
		if ( !m_creditsPanel )
		{
			m_creditsPanel = new CGuiCredits in this;
		}
		
		m_creditsPanel.SetRestoreMainMenuOnExit( true );
		m_creditsPanel.canBeSkipped = true;
		
		m_creditsPanel.OpenPanel( "credits", true, true, true );
	}
	
	latent public final function ShowEndCredits()
	{
		theHud.EnableWorldRendering( false );
		theGame.FadeOutAsync( 0.01f );
		if ( !m_creditsPanel )
		{
			m_creditsPanel = new CGuiCredits in this;
		}
		
				
		
		m_creditsPanel.SetRestoreMainMenuOnExit( false );
		m_creditsPanel.canBeSkipped = false;
		
		
		m_creditsPanel.OpenPanel( "credits", true, true, true);
		
		WaitForEvent("endCredits");
		
		theHud.EnableWorldRendering( true );
	}
	
	public final function IsVideoPanelLoaded() : bool
	{
		return IsPanelLoaded( "ui_video.swf" );
	}

	latent final function PlayVideo( videoName : string )
	{
		var result : bool;
		
		HideLootWindow();
		// Mute music and sounds
		theSound.SilenceMusicImmediately();
		theSound.MuteAllSounds();
		
		ShowVideo();
		result = WaitForVideoPanelLoaded();
		if ( result )
		{	
			theGame.SetActivePause( true );
			m_video.PlayVideo( videoName, false, true );
			WaitForEvent("MovieStopped");
			theGame.SetActivePause( false );
		}
		
		// Set black screen on end
		theGame.FadeOut( 0.0f );

		// Restore music and sounds
		theSound.RestoreMusic();
		theSound.RestoreAllSounds();
	}
	
	latent final function PlayVideoEx( videoName : string, loop : bool, optional keepMusic : bool, optional dontPause : bool  )
	{
		var result : bool;
		
		// Mute music and sounds
		if( !keepMusic )
		{
			theSound.SilenceMusicImmediately();
		}
		theSound.MuteAllSounds();
		ShowVideo();
		
		result = WaitForVideoPanelLoaded();
		if ( result )
		{
			if ( !dontPause ) theGame.SetActivePause( true );
			theHud.EnableWorldRendering( false );
			m_video.PlayVideo( videoName, loop, true );
			WaitForEvent("MovieStopped");
			theHud.EnableWorldRendering( true );
			if ( !dontPause ) theGame.SetActivePause( false );
		}
		else
		{
			LogChannel( 'GUI', "PlayVideoEx: Cannot open video" );
		}
		// Set black screen on end - but before hiding the video panel 
		theGame.FadeOut( 0.0f );
				
		HideVideo();

		// Restore music and sounds
		if( !keepMusic )
		{
			theSound.RestoreMusic();
		}
		theSound.RestoreAllSounds();
	}
	
	final function PlayVideoAsync( videoName : string, loop : bool  )
	{
		Log( "Not supported" );
	}
	
	final function StopVideo()
	{
		m_video.StopVideo();
	}
	
	final function PauseVideo(pause:bool)
	{
		m_video.PauseVideo(pause);
	}
	
	final function GetVideo():CGuiVideo
	{
		return m_video;
	}
	
	// Minigames
	final function ShowWristWrestling()
	{
		//if ( !thePlayer.CanUseHud() )
		//{
			//return;
		//}
		
		HideLootWindow();
		if ( ! m_wrist )
		{
			m_wrist = new CGuiWristWrestling in this;
		}
		m_wrist.OpenPanel( "", false, false, false );
	}
	final function HideWristWrestling()
	{
		var guiPanel : CGuiPanel = m_wrist;
		m_wrist = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}
	final function GetWristWrestlingPanel() : CGuiWristWrestling
	{
		return m_wrist;
	}
	
	final function ShowDice( minigameDice : W2MinigameDicePoker ) : CGuiDice
	{
		//if ( !thePlayer.CanUseHud() )
		//{
			//return NULL;
		//}
		
		HideLootWindow();
		m_dice = new CGuiDice in this;
		m_dice.SetMinigame( minigameDice );
		m_dice.OpenPanel( "", false, false, true );
		
		return m_dice;
	}
	
	final function HideDice()
	{
		var guiPanel : CGuiPanel = m_dice;
		m_dice = NULL;
		
		if ( guiPanel )
		{
			guiPanel.ClosePanel();
		}
	}

	final function GetDicePanel() : CGuiDice
	{
		return m_dice;
	}
	
	final function ShowCustomPanel( customPanel : CGuiCustomPanel )
	{
		theHud.m_hud.clearEntryText();
		HideLootWindow();
		if ( m_customPanel )
			m_customPanel.ClosePanel();
		
		m_customPanel = customPanel;
		m_customPanel.OpenPanel( "demo_endpanel.swf", false, false, true );
	}
	final function HideCustomPanel()
	{
		var guiPanel : CGuiPanel = m_customPanel;
		m_customPanel = NULL;
		
		if ( guiPanel )
			guiPanel.ClosePanel();
	}
	private var m_customPanel : CGuiCustomPanel; // defined only when custom panel is visible
	
	final function ShowOverlayPanel( overlayPanel : CGuiOverlayPanel )
	{
	/*	HideLootWindow();
		if ( m_overlayPanel )
			m_overlayPanel.ClosePanel();
		
		m_overlayPanel = overlayPanel;
		m_overlayPanel.OpenPanel();*/
	}
	final function HideOverlayPanel()
	{
		var guiPanel : CGuiOverlayPanel = m_overlayPanel;
		m_overlayPanel = NULL;
		
		if ( guiPanel )
			guiPanel.ClosePanel();
	}
	private var m_overlayPanel : CGuiOverlayPanel; // defined only when overlay panel is visible
	
	public final function AllowOpeningMainMenu()
	{
		forbidOpeningMainMenu -= 1;
		Log("---forbidOpeningMainMenu " + forbidOpeningMainMenu );
	}
	
	public final function ForbidOpeningMainMenu()
	{
		forbidOpeningMainMenu += 1;
		Log("+++forbidOpeningMainMenu " + forbidOpeningMainMenu );
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function HudTargetActorEx( actor : CActor, optional isBoss : bool )
	{
		var npc : CNewNPC;
		npc = (CNewNPC)actor;
		
		if ( actor )
		{
			HudTargetEntity( NULL );
		}
		
		if ( npc )
		{
			if ( npc.GetAttitude( thePlayer ) == AIA_Hostile )
			{
				if ( thePlayer.GetIsEnemyLocked() )
				{
					theHud.m_hud.SetNPCAimPointKind( NAPK_HostileLocked );
				}
				else
				{
					theHud.m_hud.SetNPCAimPointKind( NAPK_Hostile );
				}
			}
			else
			{
				theHud.m_hud.SetNPCAimPointKind( NAPK_Talk );
			}
		}
		
		HudTargetActor( actor, isBoss );
	}
	
	public function HudTargetEntityEx( entity : CGameplayEntity, optional aimPointKind : ENpcAimPointKind )
	{
		if ( entity )
		{
			//theHud.m_hud.SetNPCName( "" );
			//theHud.m_hud.SetBossName( "" );
			HudTargetActor( NULL, false );
		}
				
		theHud.m_hud.SetNPCAimPointKind( aimPointKind );
		HudTargetEntity( entity );
	}
	
	// gui followers arena
	
	function ArenaFollowersGuiEnabled( val : bool )
	{
		if ( val )
		{
			theHud.Invoke("pHUD.ShowFollowerGui");
		} else
		{
			theHud.Invoke("pHUD.HideFollowerGui");
		}
	}
	
	function ArenaFollowersGuiName( val : String )
	{
		theHud.InvokeOneArg("pHUD.SetFollowerGuiName", FlashValueFromString( val ) );
	}
	
	function ArenaFollowersGuiHealth( val : int )
	{
		theHud.InvokeOneArg("pHUD.SetFollowerGuiHealth", FlashValueFromString( val ) );
	}
	
	function ArenaFollowersGuiPicture( val : int ) // int: 1 - krasnolud, 2 - czarodziejka, 3 - rycerz
	{
		theHud.InvokeOneArg("pHUD.SetFollowerGuiPicture", FlashValueFromInt( val ) );
		/*
		switch( val )
			{
				case 1:
				{
					theHud.Invoke("pHUD.SetFollowerGuiPicture1");
					break;
				}	
				case 2:
				{
					theHud.Invoke("pHUD.SetFollowerGuiPicture2");
					break;
				}	
				case 3:
				{
					theHud.Invoke("pHUD.SetFollowerGuiPicture3");
					break;
				}
				case 4:
				{
					theHud.Invoke("pHUD.SetFollowerGuiPicture4");
					break;
				}	
			}
		*/
	}
	
	//hack for mcinek hack
	private var mainMenuMusic : CSound; 
	//hack for mcinek hack
	
	function startMainMenuMusicMcinekHack( musicName : string ) 
	{
		mainMenuMusic = theSound.PlayMainMenuMusic( musicName );
	}
	
	function stopMainMenuMusicMcinekHack()
	{
		theSound.StopSound( mainMenuMusic );
		mainMenuMusic = CSound();
	}
}
