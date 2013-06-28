//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiArena extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_arena			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_arena.swf"; }
	
	event OnOpenPanel()
	{
		//var arenaDoor : CArenaDoor;
		super.OnOpenPanel();
		theGame.FadeInAsync(0.5);
		theHud.m_hud.HideTutorial();
		
		/*theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );*/
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		//theGame.EnableButtonInteractions(false);
		theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		theHud.m_hud.setCSText( "", "" );
		//arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		//if(arenaDoor)
		//{
		//	arenaDoor.EnableDoor(false);
		//}
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items
		var arenaDoor : CArenaDoor;
		if(theGame.IsActivelyPaused())
		{
			theGame.SetActivePause( false );
		}
		theHud.ForgetObject( AS_arena );
	
		//theHud.EnableWorldRendering( true );
		
		arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		if(arenaDoor)
		{
			arenaDoor.EnableDoor(true);
		}
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		theGame.EnableButtonInteractions(true);
		//theHud.HideInventory();
		Log("");
		
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillItems()
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
		
		containter = (CArenaContainter)theGame.GetNodeByTag('arena_container');
		
		inventory = containter.GetInventory();
		
		if( ! theHud.GetObject( "Items", AS_items, AS_arena ))
		{
			Log("No Items object in mArena object");
		}
		
		theHud.ClearElements( AS_items );
		m_mapItemIdxToId.Clear();
		m_mapArrayIdxToItemIdx.Clear();
		
		// Get items in arena's inventory
		inventory.GetAllItems( m_mapItemIdxToId );
		numItems = m_mapItemIdxToId.Size();
		for ( i = numItems-1; i >= 0; i -= 1 )
		{
			itemId = m_mapItemIdxToId[i];
			
			m_mapArrayIdxToItemIdx.PushBack( i );
				
			AS_item = theHud.CreateAnonymousObject();
				
			theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems );
				
			theHud.PushObject( AS_items, AS_item );
			theHud.ForgetObject( AS_item );
		}

		// QuickSlots
		//FillQuickSlots( slotItems );

		// Orens
		//theHud.SetFloat( "Orens", inventory.GetItemQuantityByName( 'Orens' ), AS_inventory );
		
		// Mass
		//theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_inventory );

		theHud.ForgetObject( AS_items );
		
		theHud.Invoke( "Commit", AS_arena );
	}
	private final function FillData()
	{
		var arenaManager : CArenaManager;
		var startPanelData : SStartPanelData;
		
		arenaManager = theGame.GetArenaManager();
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mArena", AS_arena ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No m_arena found at the Scaleform side!" );
		}
		
		//Get start panel data
		
		arenaManager.SetStartPanelData(!arenaManager.GetRewardWasRandomized());
		arenaManager.SetRewardWasRandomized(true);
		startPanelData = arenaManager.GetStartPanelData();
		
		//Set start panel variables
		theHud.SetFloat( "Waive", startPanelData.waiveNumber, AS_arena );
		
		theHud.SetFloat( "Orens", startPanelData.gold, AS_arena );
		
		theHud.SetFloat( "PointsForWin", startPanelData.waiveInitialPoints, AS_arena );
		theHud.SetFloat( "Bonus", startPanelData.waiveBonusPoints, AS_arena );
		theHud.SetString( "BonusTime", startPanelData.bonusTime, AS_arena );
		
		theHud.SetFloat( "RIOponentCountI", startPanelData.oppNumRound1[0], AS_arena );
		theHud.SetString( "RIOponentNameI", startPanelData.oppNamesRound1[0], AS_arena );
		
		theHud.SetFloat( "RIOponentCountII", startPanelData.oppNumRound1[1], AS_arena );
		theHud.SetString( "RIOponentNameII", startPanelData.oppNamesRound1[1], AS_arena );
		
		theHud.SetFloat( "RIOponentCountIII", startPanelData.oppNumRound1[2], AS_arena );
		theHud.SetString( "RIOponentNameIII", startPanelData.oppNamesRound1[2], AS_arena );
		
		theHud.SetFloat( "RIIOponentCountI", startPanelData.oppNumRound2[0], AS_arena );
		theHud.SetString( "RIIOponentNameI", startPanelData.oppNamesRound2[0], AS_arena );
		
		theHud.SetFloat( "RIIOponentCountII", startPanelData.oppNumRound2[1], AS_arena );
		theHud.SetString( "RIIOponentNameII", startPanelData.oppNamesRound2[1], AS_arena );
		
		theHud.SetFloat( "RIIOponentCountIII", startPanelData.oppNumRound2[2], AS_arena );
		theHud.SetString( "RIIOponentNameIII", startPanelData.oppNamesRound2[2], AS_arena );
		
		theHud.SetFloat( "RIIIOponentCountI", startPanelData.oppNumRound3[0], AS_arena );
		theHud.SetString( "RIIIOponentNameI", startPanelData.oppNamesRound3[0], AS_arena );
		
		theHud.SetFloat( "RIIIOponentCountII", startPanelData.oppNumRound3[1], AS_arena );
		theHud.SetString( "RIIIOponentNameII", startPanelData.oppNamesRound3[1], AS_arena );
		
		theHud.SetFloat( "RIIIOponentCountIII", startPanelData.oppNumRound3[2], AS_arena );
		theHud.SetString( "RIIIOponentNameIII", startPanelData.oppNamesRound3[2], AS_arena );
		
		// Mass
		//theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_arena );
		
		theHud.Invoke( "Commit", AS_arena );
		theHud.Invoke( "pPanelClass.ShowStart" );
		FillItems();
		
	}
	function IsArenaPanel() : bool
	{
		return true;
	}
	private final function ArenaStart()
	{
		var arenaManager : CArenaManager;
		arenaManager = theGame.GetArenaManager();
		FactsAdd("arena_fight", 1);
		theGame.FadeOutAsync(0.0f);
		ClosePanel();
		theSound.StopMusic("prep_room");
		arenaManager.AddTimer('TimerStartFight', 1.0);
		theGame.EnableButtonInteractions(true);
		theSound.PlaySound("gui/arena_jingles/new_wave");
		//arenaManager.ShowArenaHUD(true); - it's already in StartThisRound function
		
	}
	private final function ArenaClose()
	{
		var arenaManager : CArenaManager;
		arenaManager = theGame.GetArenaManager();
		arenaManager.SetRoundStart(false);
		arenaManager.SetIsFighting(false);
		arenaManager.ShowArenaHUD(true);
		theGame.EnableButtonInteractions(true);
		ClosePanel();
		
	}
	private final function ArenaPanelIsReady()
	{
		theHud.Invoke( "pPanelClass.ShowStart" );
	}	
	
}

