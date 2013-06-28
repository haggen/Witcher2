//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiInventory extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_inventory			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	private var arg	: CFlashValueScript;
	
	function GetPanelPath() : string { return "ui_inventory.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		theGame.TutorialPlayerInInventory( true );
		
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
		theGame.TutorialPlayerInInventory( false );
		
		ProcessInventoryChanges();
		
		theHud.ForgetObject( AS_inventory );
	
		//theHud.EnableWorldRendering( true );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		theHud.HideInventory();
		
		CheckCombatState();
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mInv", AS_inventory ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No mInv found at the Scaleform side!" );
		}

		FillInventory();
	}
	
	function AddBookKnowledge( itemName : name )
	{
		if ( itemName == 'Book of Arachases' )  thePlayer.MaxKnowledgeAccumulator( 2, 100 ); 
		if ( itemName == 'Book of Bruxas' )      thePlayer.MaxKnowledgeAccumulator( 12, 100 ); 
		if ( itemName == 'Book of Bullvore' )    thePlayer.MaxKnowledgeAccumulator( 5, 100 ); 
		if ( itemName == 'Book of Draugirs' )    thePlayer.MaxKnowledgeAccumulator( 15, 100 ); 
		if ( itemName == 'Book of Draugs' )      thePlayer.MaxKnowledgeAccumulator( 14, 100 ); 
		if ( itemName == 'Book of Drowners' )    thePlayer.MaxKnowledgeAccumulator( 16, 100 ); 
		if ( itemName == 'Book of Nekkers' )     thePlayer.MaxKnowledgeAccumulator( 4, 100 ); 
		if ( itemName == 'Book of Rotfiends' )   thePlayer.MaxKnowledgeAccumulator( 0, 100 ); 
		if ( itemName == 'Book of Tentadrakes' ) thePlayer.MaxKnowledgeAccumulator( 19, 100 ); 
		if ( itemName == 'Book of Golems' )      thePlayer.MaxKnowledgeAccumulator( 17, 100 ); 
		if ( itemName == 'Book of Ifrits' )      thePlayer.MaxKnowledgeAccumulator( 18, 100 ); 
		if ( itemName == 'Book of Endriags' )    thePlayer.MaxKnowledgeAccumulator( 3, 100 ); 
		if ( itemName == 'Book of Dragons' )     thePlayer.MaxKnowledgeAccumulator( 13, 100 ); 
		if ( itemName == 'Book of Trolls' )      thePlayer.MaxKnowledgeAccumulator( 1, 100 ); 
		if ( itemName == 'Book of Gargoyles' )   thePlayer.MaxKnowledgeAccumulator( 8, 100 ); 
		if ( itemName == 'Book of Cadavers' )    thePlayer.MaxKnowledgeAccumulator( 0, 100 ); 
		if ( itemName == 'Book of Harpies' )     thePlayer.MaxKnowledgeAccumulator( 6, 100 ); 
		if ( itemName == 'Book of Wraiths' )     thePlayer.MaxKnowledgeAccumulator( 7, 100 ); 
		
		if ( itemName == 'Knowledge Herbalism Book' )     thePlayer.MaxKnowledgeAccumulator( 11, 100 ); 
		if ( itemName == 'Knowledge Alchemy Book' )     thePlayer.MaxKnowledgeAccumulator( 10, 100 );
		if ( itemName == 'Knowledge Crafting Book' )     thePlayer.MaxKnowledgeAccumulator( 12, 100 );
		
		
		if ( itemName == 'Glossary Temerian Dynasty' )   
		{ 
		if (FactsDoesExist ("witcher1_adda_lives"))
		{
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Adda", "Adda 0b",  "Politics", "glossariusz_256x256" );
		}
		else
		{
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Adda", "Adda 0a",  "Politics", "glossariusz_256x256" );
		}
		}
		if ( itemName == 'Glossary Aelirenn' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Aelirenn", "Aelirenn 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Thanned Riot' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Bunt na Thanedd", "Bunt na Thanedd 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Ban Ard' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Ban Ard", "Ban Ard 0",  "Geography", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Sorcerers' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Czarodzieje", "Czarodzieje 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary The Good Book' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Dobra Ksiega", "Dobra Ksiega 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Elder Races' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Elfy", "Elfy 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary The White Flame' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Emhyr var Emreis", "Emhyr var Emreis 0",  "Politics", "glossariusz_256x256" ); 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Emhyr var Emreis", "Emhyr var Emreis 1",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Conclave of Mages' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Kapitula Czarodziejow", "Kapitula Czarodziejow 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Scoiatael' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Scoiatael", "Scoiatael 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Council of Mages' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Rada Czarodziejow", "Rada Czarodziejow 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Vizimian Uprising' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Powstanie w Wyzimie", "Powstanie w Wyzimie 0",  "Politics", "wyzima_256x256" );
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Wyzima", "Wyzima 0",  "Politics", "wyzima_256x256" );
		}		
		if ( itemName == 'Glossary Special Forces' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Odzialy specjalne", "Odzialy specjalne 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Melitele' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Melitele", "Melitele 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Magic' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Magia", "Magia 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary The Lodge' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Loza Czarodziejek", "Loza Czarodziejek 0",  "Politics", "glossariusz_256x256" );
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Loza Czarodziejek", "Loza Czarodziejek 1",  "Politics", "glossariusz_256x256" ); 
		}
		
		if ( itemName == 'Glossary Dwarves' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Krasnoludy", "Krasnoludy 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Conjunction of Spheres' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Koniunkcja Sfer", "Koniunkcja Sfer 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Order of the Flaming Rose' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Zakon Plonacej Rozy", "Zakon Plonacej Rozy 0",  "Politics", "glossariusz_256x256" ); 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Jakub de Aldersberg", "Jakub de Aldersberg 0",  "Politics", "glossariusz_256x256" );
		}
		if ( itemName == 'Glossary Witchers' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Wiedzmini", "Wiedzmini 0",  "Culture", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Glossary Vejopatis Book' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Glossary Vejopatis", "Glossary Vejopatis 0",  "Culture", "oltarzvejopatisa_256x256" ); 
		}
		if ( itemName == 'Glossary Dun Banner' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Dun Banner", "Dun Banner 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Places Aedirn' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Aedirn", "Aedirn 0",  "Geography", "aedirn_256x256" );
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Temeria", "Temeria 0",  "Geography", "temeria_256x256" ); 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Redania", "Redania 0",  "Geography", "redania_256x256" );
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Kaedwen", "Kaedwen 0",  "Geography", "kaedwen_256x256"  ); 
		}
		if ( itemName == 'Places Dol Blathanna' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Dol Blathanna", "Dol Blathanna 0",  "Geography", "dolblathanna_256x256" );
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Francesca Findabair", "Francesca Findabair 0",  "Politics", "glossariusz_256x256" ); 
		}
		if ( itemName == 'Places Dolina Pontaru' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Dolina Pontaru", "Dolina Pontaru 0",  "Geography", "dolinapontaru_256x256" ); 
		}
		if ( itemName == 'Places Dolna Marchia' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Dolna Marchia", "Dolna Marchia 0",  "Geography", "dolnamarchia_256x256" ); 
		}
		if ( itemName == 'Places Loc Muinne' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Loc Muinne", "Loc Muinne 0",  "Geography", "locmuinne_256x256" ); 
		}
		if ( itemName == 'Places Nilfgaard' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Glossary, "Nilfgaard", "Nilfgaard 0",  "Geography", "nilfgaard_256x256" ); 
		}
		
		
		if ( itemName == 'Book of Arachases' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "arachas", "arachas 0",  "Insectoids", "arachas_256x512" ); 
		}
				if ( itemName == 'Book of Bruxas' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "bruxa", "bruxa 0",  "Wraiths", "bruxa_256x512" ); 
		}
				if ( itemName == 'Book of Bullvore' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "bullvore", "bullvore 0",  "Necrophages", "bullvore_256x512" ); 
		}
				if ( itemName == 'Book of Draugirs' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "draugir", "draugir 0",  "Wraiths", "draugir_256x512" ); 
		}
				if ( itemName == 'Book of Draugs' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "draug", "draug 0",  "Giants", "draug_256x512" ); 
		}
				if ( itemName == 'Book of Drowners' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "drowner", "drowner 0",  "Necrophages", "drawn_256x512" ); 
		}
				if ( itemName == 'Book of Nekkers' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "Nekker", "Nekker 0",  "Others", "nekker_256x512" ); 
		}
				if ( itemName == 'Book of Rotfiends' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "rotfiend", "rotfiend 0",  "Necrophages", "rotfiend_256x512" ); 
		}
				if ( itemName == 'Book of Tentadrakes' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "kejran", "kejran 0",  "Giants", "tentadrake_256x512" ); 
		}
				if ( itemName == 'Book of Golems' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "earth elemental", "earth elemental 0",  "Huge monsters", "golemearth_256x512" ); 
		}
				if ( itemName == 'Book of Ifrits' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "fire elemental", "fire elemental 0",  "Huge monsters", "golemfire_256x512" ); 
		}
				if ( itemName == 'Book of Endriags' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "endriaga", "endriaga 0",  "Insectoids", "endriaga_256x512" ); 
		}
				if ( itemName == 'Book of Dragons' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "dragon", "dragon 0",  "Giants", "dragon_256x512" ); 
		}
				if ( itemName == 'Book of Trolls' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "troll", "troll 0",  "Huge monsters", "troll_256x512" ); 
		}
				if ( itemName == 'Book of Gargoyles' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "gargoyle", "gargoyle 0",  "Others", "gargoyle_256x512" ); 
		}
				if ( itemName == 'Book of Cadavers' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "rotfiend", "rotfiend 0",  "Necrophages", "rotfiend_256x512" );
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "rotfiend", "bullvore 0",  "Necrophages", "bullvore_256x512" ); 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "rotfiend", "drowner 0",  "Necrophages", "drawn_256x512" ); 
		}
				if ( itemName == 'Book of Harpies' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "harpy", "harpy 0",  "Others", "harpy_256x512" ); 
		}
				if ( itemName == 'Book of Wraiths' )   
		{ 
			thePlayer.AddJournalEntry( JournalGroup_Monsters, "wraith", "wraith 0",  "Wraiths", "wraith_256x512" ); 
		}
		
	}
	
	private final function CheckIfItsMonsterBook( itemId : SItemUniqueId ) : bool
	{
		var isMonsterBook : bool = false;
		var itemName : name = thePlayer.GetInventory().GetItemName( itemId );
		if ( ( itemName == 'Book of Arachases' ) || ( itemName == 'Book of Bruxas' ) || ( itemName == 'Book of Bullvore' ) 
		|| ( itemName == 'Book of Draugirs' ) || ( itemName == 'Book of Draugs' ) || ( itemName == 'Book of Drowners' )
		|| ( itemName == 'Book of Nekkers' ) || ( itemName == 'Book of Rotfiends' ) || ( itemName == 'Book of Tentadrakes' )
		|| ( itemName == 'Book of Golems' )	|| ( itemName == 'Book of Ifrits' )	|| ( itemName == 'Book of Endriags' )
		|| ( itemName == 'Book of Dragons' ) || ( itemName == 'Book of Trolls' ) || ( itemName == 'Book of Gargoyles' )
		|| ( itemName == 'Book of Cadavers' ) || ( itemName == 'Book of Harpies' ) || ( itemName == 'Book of Wraiths' ) ) isMonsterBook = true;
		return isMonsterBook;
	}
	
	private final function ExamineItem( itemIdxF : float ) : bool
	{
		var itemId	: SItemUniqueId = m_mapItemIdxToId[ (int)itemIdxF ];
		var str : string;

		/*if ( !thePlayer.GetInventory().ItemHasTag( itemId, 'Usable') ) 
			{ 
				theHud.m_messages.ShowInformationText( "This item cannot be examined." );
				return false;
			}*/
		
		AddBookKnowledge( thePlayer.GetInventory().GetItemName( itemId ) );
		
		thePlayer.SetLastBook( itemId );
		FactsAdd( NameToString( thePlayer.GetInventory().GetItemName( itemId ) ) + "_Examined", 1, -1);
		
		str = GetLocStringByKeyExt( NameToString( thePlayer.GetInventory().GetItemName( thePlayer.GetLastBook() ) ) + "_entry" );
		theHud.InvokeOneArg("SetBookText", FlashValueFromString(str), AS_inventory );
	}

	private final function UpgradeItem( itemIdxF, upgradeIdxF : float )
	{
		var itemId	: SItemUniqueId = m_mapItemIdxToId[ (int)itemIdxF ];
		var upgrId	: SItemUniqueId = m_mapItemIdxToId[ (int)upgradeIdxF ];
		var confirm : CGuiConfirmItemUpgrade;
		
		if ( itemId != GetInvalidUniqueId() && upgrId != GetInvalidUniqueId() )
		{
			ProcessInventoryChanges();
		
			confirm = new CGuiConfirmItemUpgrade in theHud.m_messages;
			confirm.m_itemId		= itemId;
			confirm.m_itemIdx		= (int) itemIdxF;
			confirm.m_upgradeId		= upgrId;
			confirm.m_upgradeIdx	= (int) upgradeIdxF;
			
			theHud.m_messages.ShowConfirmationBox( confirm );
		}
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// upgradeuje przedmiot i informuje o tym gui
	private final function OnItemUpgraded( itemIdx, upgradeIdx : int ) : bool
	{
		var AS_items, AS_item : int;
		var itemId		: SItemUniqueId				= m_mapItemIdxToId[ itemIdx ];
		var upgrId		: SItemUniqueId				= m_mapItemIdxToId[ upgradeIdx ];
		var inv			: CInventoryComponent		= thePlayer.GetInventory();
		var slots		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var arrayIdx	: int;
		var params		: array< CFlashValueScript >;
		
		// Send updated definition to gui
		/*
		// This should change only upgraded item
	
		theHud.GetObject( "Items", AS_items, AS_inventory );
		{
			AS_item = theHud.CreateAnonymousObject();
			{
				theHud.m_utils.FillItemObject( inv, itemId, itemIdx, AS_item, slots );
				arrayIdx = m_mapArrayIdxToItemIdx.FindFirst( itemIdx );
				theHud.SetObjectElement( AS_items, arrayIdx, AS_item );
			}
			theHud.ForgetObject( AS_item );
			
			arrayIdx = m_mapArrayIdxToItemIdx.FindFirst( upgradeIdx );
			if ( inv.IsIdValid( upgrId ) )
			{
				AS_item = theHud.CreateAnonymousObject();
				{
					theHud.m_utils.FillItemObject( inv, upgrId, upgradeIdx, AS_item, slots );
					theHud.SetObjectElement( AS_items, arrayIdx, AS_item );
				}
				theHud.ForgetObject( AS_item );
			}
			else
			{
				m_mapItemIdxToId[ upgradeIdx ] = GetInvalidUniqueId();
				theHud.SetObjectElement( AS_items, arrayIdx, -1 );
			}
		}
		theHud.ForgetObject( AS_items );
		
		// QuickSlots
		FillQuickSlots( slots );
		*/
		
		FillInventory();
		
		params.Clear();
		params.PushBack( FlashValueFromInt( itemIdx ) );
		params.PushBack( FlashValueFromInt( upgradeIdx ) );
		theHud.InvokeManyArgs( "OnItemUpgraded", params, AS_inventory );
	}
	
	private final function OnEquipmentChanged()
	{
		ProcessInventoryChanges();
		theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_inventory );
		theHud.Invoke( "pPanelClass.UpdateMass" );
	}
	
	private final function RemoveItem( itemIdxF : float, quantity : float ) // the number of throwed items
	{
		var itemId	: SItemUniqueId = m_mapItemIdxToId[ (int)itemIdxF ];
		var itemName : name;
		//var confirm : CGuiConfirmItemRemove;
		
		/*
		if ( itemId != GetInvalidUniqueId() )
		{
			confirm = new CGuiConfirmItemRemove in theHud.m_messages;
			confirm.m_itemId	= itemId;
			confirm.m_itemIdx	= (int) itemIdxF;
			
			theHud.m_messages.ShowConfirmationBox( confirm );
		}
		*/
		ProcessInventoryChanges();
		thePlayer.GetInventory().ThrowAwayItem( itemId, (int)quantity );
		FillInventory();
	}
	
	// Not used
	/*
	private final function OnItemRemoved( itemIdx : int )
	{
		//var AS_items	: int;
		//var slots		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		//var arrayIdx	: int						= m_mapArrayIdxToItemIdx.FindFirst( itemIdx );
		
		//m_mapItemIdxToId[ itemIdx ] = GetInvalidUniqueId();
		
		// Send updated definition to gui
		//theHud.GetObject( "Items", AS_items, AS_inventory );
		//theHud.SetObjectElement( AS_items, arrayIdx, -1 );
		//theHud.ForgetObject( AS_items );
		
		// QuickSlots
		ProcessInventoryChanges();
		FillInventory();
		//FillQuickSlots( slots );
		
		//theHud.InvokeOneArg( "OnItemRemoved", FlashValueFromInt( itemIdx ), AS_inventory );
	}
	*/
	
	private final function CheckCombatState()
	{
		var 	weaponId	: SItemUniqueId;
		var		inventory	: CInventoryComponent = thePlayer.GetInventory();
		
		if ( thePlayer.GetCurrentStateName() == 'CombatSteel' )
		{
			weaponId = inventory.GetItemByCategory( 'steelsword' );
			if ( weaponId == GetInvalidUniqueId() || !inventory.IsItemHeld( weaponId ) )
			{
				thePlayer.ChangePlayerState( PS_Exploration );
			}
		}
		else if ( thePlayer.GetCurrentStateName() == 'CombatSilver' )
		{
			weaponId = inventory.GetItemByCategory( 'silversword' );
			if ( weaponId == GetInvalidUniqueId() || !inventory.IsItemHeld( weaponId ) )
			{
				thePlayer.ChangePlayerState( PS_Exploration );
			}
		}
	}
	
	private final function ProcessInventoryChanges()
	{
		var inventory			: CInventoryComponent		= thePlayer.GetInventory();
		var slotItems			: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		
		var itemName			: name;
		var invalidItemId		: SItemUniqueId = GetInvalidUniqueId();
		var itemId				: SItemUniqueId;
		var tempItemId			: SItemUniqueId;
		var itemMaskF			: float;
		var itemMask			: int;
		var itemMaskS			: string;
		var mounted				: bool;
		var mountToHand			: bool;
		var i					: int;
		var category			: name;
		var heldCategories		: array< name >;
		
		var AS_items, AS_item	: int;
		
		// Quick slots
		var AS_slots            : int;
		var size				: int;
		var quickSlotItemIdx	: float;
		var quickSlotItemId     : SItemUniqueId;
		var AS_lastSlots        : int;
		
		theHud.Invoke( "UpdateStringMasks", AS_inventory );
		
		theHud.GetObject( "Items", AS_items, AS_inventory );
		{
			for ( i = m_mapArrayIdxToItemIdx.Size()-1; i >= 0; i -= 1 )
			{
				itemId = m_mapItemIdxToId[ m_mapArrayIdxToItemIdx[ i ] ];
				if ( itemId == invalidItemId )
				{
					continue;
				}
				
				theHud.GetObjectElement( AS_items, i, AS_item );

				if ( AS_item == -1 ) // dropped items
				{
					inventory.DropItem( itemId );
				}
				else
				{
					mounted = inventory.IsItemMounted( itemId ) || inventory.IsItemHeld( itemId );
					
					theHud.GetString( "m_sMask", itemMaskS, AS_item );
					itemMask = StringToInt( itemMaskS );
					
					// mount item if it wasn't mounted before and is now 
					if ( (itemMask & 0x00000004) && !mounted  )
					{
						// if any item of the same category was previously held, we want this one to be held too
						mountToHand = false;
						category = inventory.GetItemCategory( itemId );
						tempItemId = inventory.GetItemByCategory( category, true );
						if ( ( tempItemId != GetInvalidUniqueId() && inventory.IsItemHeld( tempItemId ) ) || heldCategories.Contains( category ) )
						{
							mountToHand = true;
						}
						inventory.MountItem( itemId, mountToHand );
					}
					// unmount item if it was mounted before and now it isn't
					else if ( ! (itemMask & 0x00000004) && mounted )
					{
						// Store previously held items to compare their category
						if ( inventory.IsItemHeld( itemId ) )
						{
							heldCategories.PushBack( inventory.GetItemCategory( itemId ) );
						}
						inventory.UnmountItem( itemId );
					}
				}
				
				theHud.ForgetObject( AS_item );
			}
		}
		theHud.ForgetObject( AS_items );
		
		// Update quick slots
		theHud.GetObject( "Slots", AS_slots, AS_inventory );
		{
			thePlayer.ClearAllItemsInQuickSlots();
			size = theHud.GetArraySize( AS_slots );
			for ( i = 0; i < size; i += 1 )
			{
				quickSlotItemIdx = -1;
				theHud.GetFloatElement( AS_slots, i, quickSlotItemIdx );

				if ( quickSlotItemIdx > 0 )
				{
					quickSlotItemId = m_mapItemIdxToId[ (int)quickSlotItemIdx ];					
					thePlayer.SetItemInQuickSlot( quickSlotItemId, i );
				}
			}
		}
		theHud.ForgetObject( AS_slots );
		
		// Update selected quick slot item
		theHud.GetObject( "LastSelectedSlotArray", AS_lastSlots, AS_inventory );
		{
			size = theHud.GetArraySize( AS_lastSlots );
			if ( size > 0 )
			{
				theHud.GetFloatElement( AS_lastSlots, size - 1, quickSlotItemIdx );
				if ( thePlayer.GetThrownItem() == GetInvalidUniqueId() )
				{
					thePlayer.SelectSlotItem( (int)quickSlotItemIdx );
					thePlayer.UseItem( thePlayer.GetItemInQuickSlot( (int)quickSlotItemIdx ) ); // it will call 
				}
			}
		}
	}
	
	//////////////////////////////////////////////////////////////
	// Fill inventory
	//////////////////////////////////////////////////////////////
	private final function FillInventory()
	{
		var AS_items		: int;
		
		var inventory		: CInventoryComponent		= thePlayer.GetInventory();
		var stats			: CCharacterStats			= thePlayer.GetCharacterStats();
		var slotItems		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var itemId			: SItemUniqueId;
		var itemTags		: array< name >;
		var itemIdx			: int;
		var numItems		: int;
		var i				: int;
		var AS_item			: int;
		
		theHud.GetObject( "Items", AS_items, AS_inventory );
		
		theHud.ClearElements( AS_items );
		m_mapItemIdxToId.Clear();
		m_mapArrayIdxToItemIdx.Clear();
		
		// Get items in player's inventory
		inventory.GetAllItems( m_mapItemIdxToId );
		numItems = m_mapItemIdxToId.Size();
		for ( i = numItems-1; i >= 0; i -= 1 )
		{
			itemId = m_mapItemIdxToId[i];
			
			// add to list items that have proper tags
			inventory.GetItemTags( itemId, itemTags );
			if (	! itemTags.Contains( 'NoShow' ) && 
					! itemTags.Contains( 'NoDrop' ) )
			{
				m_mapArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems );
				
				theHud.PushObject( AS_items, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}

		// QuickSlots
		FillQuickSlots( slotItems );
		
		// Tutorial Block Trash
		if( theGame.tutorialInvTrashBlocked )
			theHud.SetBool( "bTrash", theGame.tutorialInvTrashBlocked, AS_inventory );
		
		// Orens
		theHud.SetFloat( "Orens", inventory.GetItemQuantityByName( 'Orens' ), AS_inventory );
		
		// Mass
		theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_inventory );

		theHud.ForgetObject( AS_items );
		
		theHud.Invoke( "Commit", AS_inventory );
	}
	
	private final function FillQuickSlots( slotItems : array< SItemUniqueId > )
	{
		var AS_slots	: int;
		var itemIdx		: int;
		var numItems	: int;
		var i			: int;
		
		theHud.GetObject( "Slots", AS_slots, AS_inventory );
		theHud.ClearElements( AS_slots );
		
		// QuickSlots
		numItems = slotItems.Size();
		for ( i = 0; i < numItems; i += 1 )
		{
			itemIdx = m_mapItemIdxToId.FindFirst( slotItems[ i ] );
			if ( itemIdx == -1 )
			{
				theHud.PushObject( AS_slots, -1 );
			}
			else
			{
				theHud.PushFloat( AS_slots, itemIdx );
			}
		}
		
		theHud.ForgetObject( AS_slots );
	}
}
/*
class CGuiConfirmItemRemove extends CGuiConfirmationBox
{
	var m_itemId	: SItemUniqueId;
	var m_itemIdx	: int;
	
	function GetText()				: string	{ return GetLocStringByKeyExt("Remove item?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		var inv : CInventoryComponent = thePlayer.GetInventory();
		if ( inv.ThrowAwayItem( m_itemId, inv.GetItemQuantity( m_itemId ) ) )
		{
			theHud.m_inventory.OnItemRemoved( m_itemIdx );
		}
	}
	event OnNo() {}
}
*/
class CGuiConfirmItemUpgrade extends CGuiConfirmationBox
{
	var m_itemId		: SItemUniqueId;
	var m_upgradeId		: SItemUniqueId;
	var m_itemIdx		: int;
	var m_upgradeIdx	: int;
	
	function GetText()				: string	{ return GetLocStringByKeyExt("Upgrade item?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		if ( thePlayer.UpgradeItem( m_itemId, m_upgradeId ) )
		{
			theHud.m_inventory.OnItemUpgraded( m_itemIdx, m_upgradeIdx );
		}
	}
	event OnNo() {}
}

