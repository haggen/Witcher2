/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiArenaFail extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_arena			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_arena.swf"; }
	
	event OnOpenPanel()
	{
		theSound.PlaySound("gui/arena_jingles/arena_death");
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
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
		if(theGame.IsActivelyPaused())
		{
			theGame.SetActivePause( false );
		}
		theHud.ForgetObject( AS_arena );
	
		//theHud.EnableWorldRendering( true );
		theGame.EnableButtonInteractions(true);
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		//theHud.HideInventory();
		Log("");
		
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
		
		//theHud.Invoke( "Commit", AS_arena );
		theHud.Invoke( "pPanelClass.ShowFailed" );
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
		
		arenaManager.SetWasPlayerDead(true);
		
		//Get start panel data
		arenaManager.SetStartPanelData(false);
		startPanelData = arenaManager.GetStartPanelData();
		
		//Set start panel variables
		theHud.SetFloat("Waive", startPanelData.waiveNumber, AS_arena );
		//theHud.SetFloat("TotalOrens", orensNum, AS_arena);
		theHud.SetFloat("TotalPoints", theGame.GetArenaManager().playerScore, AS_arena);
		theHud.SetFloat("Waive", theGame.GetArenaManager().GetCurrentWaveText(), AS_arena);
		theHud.SetFloat("Round", theGame.GetArenaManager().GetCurrentWave().GetCurrentRoundText(), AS_arena);			


		//FillItems();
		
	}
	private final function ArenaFacebook() // TO DO FACEBOOK: send to facebook/forum
	{
		var score : int;
		score = theGame.GetArenaManager().playerScore;
		
		SendArenaScoreToSteamLeaderboards( score, theGame.GetArenaManager().GetCurrentWaveText() );
		
		if ( score > 0 )
		{
	
			//theGame.ExitGame();
			theHud.Invoke("pPanelClass.ShowServerTooltip");
			theHud.Invoke("pPanelClass.ShowServerIcon");
			theHud.InvokeOneArg("pPanelClass.SetServerTitle", FlashValueFromString( GetLocStringByKeyExt("srvtxt_wait") ));
			theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_conn") ));
			
			theServer.Connect();
			
			if(!theGame.GetArenaManager().GetPlayerCheated())
			{
				if ( theServer.IsConnected() )
				{
					theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_send") ));
					
					
					if ( theServer.SendPoints( score ) )
					{
						theHud.Invoke("pPanelClass.HideServerIcon");
						theHud.InvokeOneArg("pPanelClass.SetServerTitle", FlashValueFromString( GetLocStringByKeyExt("srvtxt_done") ));
						theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_succ") ));
					}
					else
					{
							theHud.InvokeOneArg("pPanelClass.SetServerTitle", FlashValueFromString( GetLocStringByKeyExt("srvtxt_erro") ));
							theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_nots") ));
					}
				}
				else
				{
					theHud.Invoke("pPanelClass.HideServerIcon");
					theHud.InvokeOneArg("pPanelClass.SetServerTitle", FlashValueFromString( GetLocStringByKeyExt("srvtxt_erro") ));
					theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_notc") ));
				}
			}
			else
			{
				theHud.InvokeOneArg("pPanelClass.SetServerTitle", FlashValueFromString( GetLocStringByKeyExt("srvtxt_erro") ));
				theHud.InvokeOneArg("pPanelClass.SetServerDesc", FlashValueFromString( GetLocStringByKeyExt("srvtxt_cheat") ));
			}
			
		
			theServer.Disconnect();
		
		}
		
		//theHud.Invoke("pPanelClass.HideServerTooltip");
		
	}
	private final function ArenaTryAgain() // reload
	{
		var arenaDoor : CArenaDoor;
		var arenaResetVal, arenaResetSetVal : int;
		//theGame.ExitGame();
		
		//thePlayer.PlayerStateCallEntryFunction( PS_Exploration, '' );
		//theGame.FadeOutAsync(0.0);
		arenaResetVal = FactsQuerySum("arena_reset");
		arenaResetSetVal = 1 - arenaResetVal;
		FactsAdd("arena_reset", arenaResetSetVal);
		theGame.FadeOutAsync(0.0);
		ClosePanel();
		thePlayer.OnArenaResurect();
		theGame.EnableButtonInteractions(true);
		arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		if(arenaDoor)
		{
			arenaDoor.EnableDoor(true);
		}
	}
	private final function ArenaClose() // exit to main menu
	{
		theGame.ExitGame();
	}
	private final function ArenaPanelIsReady()
	{
		theHud.Invoke( "pPanelClass.ShowFailed" );
	}	
}

