//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiControls extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_controls			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_keys.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.FadeInAsync(0.5);
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	
		theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		theHud.m_hud.setCSText( "", "" );
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items
		theGame.SetActivePause( false );
		theHud.ForgetObject( AS_controls );
	
		//theHud.EnableWorldRendering( true );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.HideControls();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		//theHud.HideInventory();
		Log("");
		
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillKeys()
	{
		var AS_items		: int;
		
		var inventory		: CInventoryComponent;
		var containter		: CArenaContainter;
		var stats			: CCharacterStats			= thePlayer.GetCharacterStats();
		var slotItems		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var itemId			: SItemUniqueId;
		var itemIdx			: int;
		var numItems		: int;
		var i				: int;
		var AS_item			: int;
		
		theHud.ForgetObject( AS_items );
		
		theHud.Invoke( "Commit", AS_controls );
	}
	private final function FillData()
	{
		var arenaManager : CArenaManager;
		var startPanelData : SStartPanelData;
		var locale : string;
		var blaN : string;
		
		//arenaManager = theGame.GetArenaManager();
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mKeys", AS_controls ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No m_controls found at the Scaleform side!" );
		}
		
		//Get start panel data
		//arenaManager.SetStartPanelData(true);
		//startPanelData = arenaManager.GetStartPanelData();
		
		//Set start panel variables
		//theHud.SetFloat( "Waive", startPanelData.waiveNumber, AS_controls );
		locale = StrLower( theGame.GetCurrentLocale() );		
		blaN   = "img://globals/gui/icons/meditation/" + locale + "_icon_active_n_334x334.dds";
		//theHud.SetFloat( "RIOponentCountI", startPanelData.oppNumRound1[0], AS_controls );
		//theHud.SetString( "sIcon1", GetLocStringByKeyExt("[[GI_AttackFast,1]]"), AS_controls );

		//theHud.SetString( "sIcon1", "[[GI_FastMenu,1]]", AS_controls  );
		theHud.SetString( "sIcon1", theHud.m_hud.ParseButtons( "[[GI_AxisLeftY,1]],[[GI_AxisLeftY,-1]],[[GI_AxisLeftX,-1]],[[GI_AxisLeftX,1]]" ), AS_controls );
		theHud.SetString( "sIcon2", theHud.m_hud.ParseButtons( "" ), AS_controls );
		theHud.SetString( "sIcon3", theHud.m_hud.ParseButtons( "" ), AS_controls );
		theHud.SetString( "sIcon4", theHud.m_hud.ParseButtons( "[[GI_AttackStrong,1]]" ), AS_controls );
		theHud.SetString( "sIcon5", theHud.m_hud.ParseButtons( "[[GI_Accept_Evade,1]]" ), AS_controls );
		theHud.SetString( "sIcon6", theHud.m_hud.ParseButtons( "[[GI_Block,1]]" ), AS_controls );
		theHud.SetString( "sIcon7", theHud.m_hud.ParseButtons( "[[GI_LockTarget,1]]" ), AS_controls );
		theHud.SetString( "sIcon8", theHud.m_hud.ParseButtons( "" ), AS_controls );
		theHud.SetString( "sIcon9", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon10", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon11", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon12", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon13", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon14", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon15", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon16", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon17", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon18", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon19", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon20", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );
		theHud.SetString( "sIcon21", theHud.m_hud.ParseButtons( "[[GI_AttackFast,1]]" ), AS_controls );

		// Mass
		//theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_arena );
		
		theHud.Invoke( "Commit", AS_controls );
		theHud.Invoke( "pPanelClass.ShowStart" );
		FillKeys();
		
	}
	private final function ArenaStart()
	{
		var arenaManager : CArenaManager;
		arenaManager = theGame.GetArenaManager();
		arenaManager.StartCurrentWave();
		theGame.FadeOutAsync(0.0f);
		theGame.FadeInAsync(1.0);
		theSound.PlayMusic(arenaManager.GetArenaMusic());
		arenaManager.SetRoundStart(true);
		arenaManager.SetIsFighting(true);
		//arenaManager.ShowArenaHUD(true); - it's already in StartThisRound function
		ClosePanel();
	}
	private final function ArenaClose()
	{
		var arenaManager : CArenaManager;
		arenaManager = theGame.GetArenaManager();
		arenaManager.SetRoundStart(false);
		arenaManager.SetIsFighting(false);
		ClosePanel();
		
	}
	private final function ArenaPanelIsReady()
	{
		theHud.Invoke( "pPanelClass.ShowStart" );
	}	
	
}

