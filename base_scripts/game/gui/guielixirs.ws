/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Elixirs
/** Copyright © 2010
/***********************************************************************/

class CGuiElixirs extends CGuiPanel
{
	private var AS_elixirs : int;
	private var m_mapElixItemIdxToId       : array< SItemUniqueId >;
	private var m_mapElixArrayIdxToItemIdx : array< int >;

	// Hide hud
	function GetPanelPath() : string { return "ui_elixirs.swf"; }
	
	function IsNestedPanel() : bool
	{
		return true;
	}
	
	event OnOpenPanel()
	{		
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	}
	
	event OnClosePanel()
	{		
		//set some stuff before super.onclosepanel
		var itemCount : int;
		
		itemCount = theHud.m_utils.m_itemBag.Size();
		//play drink effect	
		if ( itemCount == 1)
			theHud.SetMeditationTransitions(theHud.BEH_TRANS_DRINK,theHud.BEH_TRANS_EFFECT1);
		else if (itemCount == 2)
			theHud.SetMeditationTransitions(theHud.BEH_TRANS_DRINK,theHud.BEH_TRANS_EFFECT2);
		else if (itemCount >= 3)
			theHud.SetMeditationTransitions(theHud.BEH_TRANS_DRINK,theHud.BEH_TRANS_EFFECT3);
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();

		theHud.HideElixirs();
	}
	
	private function FillElixirs()
	{
		var AS_potions		: int;
		
		var inventory		: CInventoryComponent		= thePlayer.GetInventory();
		var stats			: CCharacterStats			= thePlayer.GetCharacterStats();
		var slotItems		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var itemId			: SItemUniqueId;
		var itemTags		: array< name >;
		var itemIdx			: int;
		var numItems		: int;
		var i, s			: int;
		var AS_item			: int;
		var AS_activeElix   : int;
		var AS_buff   		: int;
		var activeBuffs		: array < SBuff >;
		var tmp : float;


		theHud.SetFloat( "NumPotionSlots", thePlayer.GetCharacterStats().GetAttribute( 'potion_slots' ), AS_elixirs );
		theHud.SetFloat( "ToxicBarMin", thePlayer.GetCharacterStats().GetAttribute( 'toxicity_light' ), AS_elixirs );
		theHud.SetFloat( "ToxicBarMax", thePlayer.GetCharacterStats().GetAttribute( 'toxicity_high' ), AS_elixirs );
		
		// Elixirs array -----------------------------------------
		
		if ( !theHud.GetObject( "Elixirs", AS_potions, AS_elixirs ) )
		{
			LogChannel( 'GUI', "CGuiElixirs: No Elixirs1 found at the Scaleform side!" );
		}
		
		theHud.ClearElements( AS_potions );
		m_mapElixItemIdxToId.Clear();
		m_mapElixArrayIdxToItemIdx.Clear();
		
		// Get items in player's inventory
		inventory.GetAllItems( m_mapElixItemIdxToId );
		numItems = m_mapElixItemIdxToId.Size();
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapElixItemIdxToId[i];
			
			// add to list items that have proper tags
			inventory.GetItemTags( itemId, itemTags );
			if (	! itemTags.Contains( 'NoShow' ) && 
					! itemTags.Contains( 'nodrop' ) &&
					  itemTags.Contains( 'Elixir' ) )
			{
				m_mapElixArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				//tmp = thePlayer.GetInventory().GetItemAttributeAdditive( itemId, 'tox_level' );
				
				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems, 'elixirs' );
				
				theHud.PushObject( AS_potions, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}
		
		// QuickSlots
		//FillQuickSlots( slotItems );
		
		// Orens
		//theHud.SetFloat( "Orens", inventory.GetItemQuantityByName( 'Orens' ), AS_inventory );
		
		theHud.ForgetObject( AS_potions );
		
		
		// Active elixirs
		theHud.GetObject( "ActiveElixirs", AS_activeElix, AS_elixirs );
		theHud.ClearElements( AS_activeElix );
		activeBuffs = thePlayer.GetActiveElixirs();
		s = activeBuffs.Size();
		for ( i = 0; i < s; i += 1 )
		{
			// omit power sources as they cannot be treated as elixirs
			if ( theHud.m_utils.IsItemNamePowerSource( activeBuffs[i].m_name ) )
			{
				continue;
			}
			
			theHud.m_utils.FillFlashItemDescription( activeBuffs[ i ].m_name, inventory, stats, AS_activeElix, i, slotItems );
		}
		theHud.ForgetObject( AS_activeElix );
		
		
		theHud.Invoke( "Commit", AS_elixirs );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mElixirs", AS_elixirs ) )
		{
			LogChannel( 'GUI', "CGuiElixirs: No mElixir found at the Scaleform side!" );
		}

		FillElixirs();
	}
	/*
	private final function CalcElixir( itemsIdsStr : string ) : string
	{
		var ids : array< int >;
		var i : int;
		var itemId	: SItemUniqueId;
		
		ids = SplitStringForItemsIds( itemsIdsStr );
		
		
		
		// w stringach: id|id
		return "010010010010"; // 000 000 000 000 - 100 100 100 100 percents
	}
	*/
	
	private final function DrinkElixir( itemsIdsStr : string )
	{
		var ids : array< int >;
		var i : int;
		var itemId	: SItemUniqueId;
		
		ids = theHud.m_utils.SplitStringForItemsIds( itemsIdsStr );
		
		for ( i = 0; i < ids.Size(); i += 1 )
		{
			itemId = m_mapElixItemIdxToId[ ids[i] ];
			theHud.m_utils.AddItemToBag( itemId );
		}
		
		theGame.UnlockAchievement('ACH_POTION_TASTER');
		
		ClosePanel();
		theHud.m_hud.OpenPanel( "", "", "", false, false, true );	

		{
			thePlayer.AddTimer( 'ElixirTutorial', 3.0f, false);
		}


	}
}
