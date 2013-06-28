/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiArenaEnd extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_arena			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_arena.swf"; }
		
	event OnOpenPanel()
	{
		theGame.FadeInAsync(0.5);
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		/*theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );*/
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		theHud.m_hud.setCSText( "", "" );
	}		
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items
		if(theGame.IsActivelyPaused())
		{
			theGame.SetActivePause( false );
		}
		theHud.ForgetObject( AS_arena );
	
		//theHud.EnableWorldRendering( true );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		//theHud.HideInventory();
		Log("");
		theHud.Invoke("pHUD.clearRecievedList");
		theGame.EnableButtonInteractions(true);
	}
	event OnFocusPanel()
	{
		super.OnFocusPanel();
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
		//theHud.Invoke( "pPanelClass.ShowCompleted" );
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
		arenaManager.SetStartPanelData(false);
		startPanelData = arenaManager.GetStartPanelData();
		
		//Set start panel variables
		theHud.SetFloat( "Waive", startPanelData.waiveNumber -1, AS_arena );
		
		//Set start panel variables
		theHud.SetFloat( "EarnedPoints", startPanelData.points, AS_arena );
		
		theHud.SetString( "Time", startPanelData.time, AS_arena );
		//theHud.SetFloat( "Damage", 1, AS_arena );
		theHud.SetFloat( "Killed", startPanelData.killedEnemies, AS_arena );
		theHud.SetFloat( "TotalPoints", startPanelData.totalPoints, AS_arena );
		// Mass
		//theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_arena );
		
		theHud.Invoke( "Commit", AS_arena );
		FillItems();
		
	}
	private final function SelectedItem( itemId : string ) 
	{
		var itemIdS : int = StringToInt( itemId );
		var container : CArenaContainter;
		var allItems : array< SItemUniqueId >;
		var teleportPoint : CNode;
		var arenaDoor : CArenaDoor;
		//theGame.GetArenaManager().SetRoundStart(false);
		//theGame.GetArenaManager().SetIsFighting(false);		
		//theGame.GetArenaManager().ShowArenaHUD( false );
		container = (CArenaContainter)theGame.GetNodeByTag('arena_container');
		container.GetInventory().GetAllItems( allItems );
		thePlayer.GetInventory().AddItem( container.GetInventory().GetItemName( allItems[itemIdS] ) );
		theGame.GetArenaManager().ClearArenaHUD();
		ClosePanel();
		teleportPoint = theGame.GetNodeByTag('arena_safe_spot');
		thePlayer.TeleportWithRotation(teleportPoint.GetWorldPosition(), teleportPoint.GetWorldRotation());
		theCamera.ResetRotation(false, true, true, 0.0f);
		theGame.FadeOutAsync(0.0);
		theGame.FadeInAsync(4.0);
		thePlayer.ChangePlayerState(PS_Exploration);
		theGame.EnableButtonInteractions(true);
		arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		if(arenaDoor)
		{
			arenaDoor.EnableDoor(true);
		}
		//Levelup
		theSound.PlayMusic("prep_room");
		thePlayer.SetLevelUp();
		
	}
	
	private final function ArenaPanelIsReady()
	{
		theHud.Invoke( "pPanelClass.ShowCompleted" );
	}	
}

