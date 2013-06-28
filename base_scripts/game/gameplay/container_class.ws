///////////////////////////////////
// 		  CONTAINER CLASS        //
///////////////////////////////////


class CContainer extends CGameplayEntity
{
	//editable var loot_table		: string; // not used
	editable var isDynamic		: bool;
	
	editable var onlyOneTheSameType : bool;
	
	editable var lockedByKey	: bool;
	editable var keyItemName	: name;
	
	editable var showInventoryAfterUse : bool;
	editable var hideInteractionIfEmpty : bool;
	
	editable var isNotEnabledOnSpawn : bool;
	
	var m_isBlocked : bool;
	var m_saveLock  : int;
	
	default isDynamic = false;
	default isNotEnabledOnSpawn = false;
	default m_isBlocked = false;
	
	//saved var wasUsed : bool;
	
	//default wasUsed = false;
	
	// Entity was dynamically spawned
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		this.GetInventory().UpdateLoot();
		if ( IsLootable() )
		{
			SetVisualsFull();
			
			if (!isNotEnabledOnSpawn)
			{
				GetComponent("Loot").SetEnabled( true );
			}
		}
		else
		{
			SetVisualsEmpty();
			GetComponent("Loot").SetEnabled( false );
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var allItems		: array< SItemUniqueId >;
		var i : int;
		var isAnything : bool;
		
		if ( activator == thePlayer )
		{	
			//SetGameplayParameter( 0, true, 1.f );
			theHud.HudTargetEntityEx( this, NAPK_Container );
			
			if ( ! thePlayer.IsInCombat() &&
				( ! lockedByKey || thePlayer.GetInventory().HasItem( keyItemName ) ) )
			{
				ShowLootPreview();
			}
		}
	}
	
	public function Closed()
	{
		if ( m_isBlocked )
		{
			theGame.EnableButtonInteractions( true );
			if(!theHud.CanShowMainMenu())
			{
				theHud.AllowOpeningMainMenu();
			}
			theGame.ReleaseNoSaveLock( m_saveLock );
			m_saveLock = -1;
			m_isBlocked = false;
		}
	}
	
	function IsLootable() : bool
	{
		var allItems		: array< SItemUniqueId >;
		var i 				: int;
		var isAnything 		: bool;

		GetInventory().GetAllItems( allItems );
		isAnything = false;
		
		for ( i=0; i<allItems.Size(); i+=1 )
		{
			if ( !GetInventory().ItemHasTag( allItems[i], 'NoDrop' ) && GetInventory().GetItemQuantity( allItems[i] ) > 0  )
			{
				isAnything = true;
			}
		}
		
		return isAnything;
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer || thePlayer.IsNotGeralt()  )
		{
			HideLootPreview();
			//SetGameplayParameter( 0, false, 1.f );
			theHud.HudTargetEntityEx( NULL );
		}
	}
	
	function ShowLootWindow() : bool
	{
		if ( thePlayer.GetLastContainer() ) return false;
		
		if(thePlayer.GetCurrentPlayerState() == PS_Exploration)
		{
			thePlayer.RaiseForceEvent('Idle');
		}
		else
		{
			thePlayer.RaiseForceEvent('GlobalEnd');
		}
	
		thePlayer.SetCanUseHud( false );
		thePlayer.SetHotKeysBlocked( true );
		thePlayer.SetCombatHotKeysBlocked( true );
		thePlayer.SetLastContainer( this );
		thePlayer.SetManualControl(false, false);
		theHud.Invoke("LoadLootWindow");
		theHud.EnableInput( true, true, true, false );
		HideLootPreview();
		theGame.SetTimeScale(0.05);
		
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		var sourceInv	: CInventoryComponent;
		var targetInv	: CInventoryComponent;
	
		var arrayData 	: array < CFlashValueScript >;
		
		var itemId		: SItemUniqueId;
		var allItems	: array< SItemUniqueId >;
		var lootedItems	: array< SItemUniqueId >;
		
		var i			: int;
		var quantity	: int;
		var itemName	: name;
		
		if ( m_isBlocked ) return false;

		if ( activator != thePlayer || thePlayer.IsNotGeralt() )
			return false;
			
			//if( !theGame.tutorialenabled )
			//{
				//theHud.m_hud.ShowTutorial("tut29", "tut29_333x166", false); // <-- tutorial content is present in external tutorial - disabled
				//theHud.ShowTutorialPanelOld( "tut29", "tut29_333x166" );
			//}	
		
		// Check for key
		if ( lockedByKey && ! thePlayer.GetInventory().HasItem( keyItemName ) )
		{
			if( !theGame.tutorialenabled )
			{
				theHud.m_hud.ShowTutorial("tut52", "", false);
				//theHud.ShowTutorialPanelOld( "tut52", "" );
			}	
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "You need a key" ));
			return false;
		} 
		if ( lockedByKey && thePlayer.GetInventory().HasItem( keyItemName ) )
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "Opened by key" ));
		} 
		
		if ( actionName != 'Container' )
			return false;		
			
		if ( !IsLootable() )
		{
			MakeContainerEmpty();
			GetComponent("Loot").SetEnabled( false );
			return false;
		}
		
		if ( thePlayer.IsDead() ) return false;
		
		if ( theGame.IsUsingPad() || showInventoryAfterUse ) 
		{
			TakeAllItems();
			QuestItemGlow();
			if ( !IsLootable() ) GetComponent("Loot").SetEnabled( false );
			SetVisualsEmpty();
			DestroyIt();			
			HideLootPreview();
		} else
		{
			if(theHud.CanShowMainMenu())
			{
				theHud.ForbidOpeningMainMenu();
			}
			theGame.EnableButtonInteractions( false );
			m_saveLock = -1;
			theGame.CreateNoSaveLock( "container_loot_opened", m_saveLock );
			m_isBlocked = true;
		
			FillLootWindow();
			ShowLootWindow();
		}
	}
	
	function TakeAllItems()
	{
		var sourceInv	: CInventoryComponent;
		var targetInv	: CInventoryComponent;
	
		var arrayData 	: array < CFlashValueScript >;
		
		var itemId		: SItemUniqueId;
		var allItems	: array< SItemUniqueId >;
		
		var i			: int;

		// Transfer items
		sourceInv = this.GetInventory();
		targetInv = thePlayer.GetInventory();
		
		sourceInv.GetAllItems( allItems );
		
		for ( i = allItems.Size()-1; i >= 0; i-=1 )
		{
			itemId = allItems[i];
			if ( !isDynamic || !sourceInv.ItemHasTag( itemId, 'NoDrop' ) )
			{
				if( !theGame.tutorialenabled )
				{
					CheckForTutorial(itemId, sourceInv);
				}	

				if ( AllowItemDarkDiff( sourceInv, itemId ) ) Helper_TransferItemFromContainerToPlayer( itemId, targetInv, sourceInv, isDynamic );
			}
		}
		
		theSound.PlaySound( "gui/hud/manyitemslooted" );
		
		MakeContainerEmpty();
		
		if (showInventoryAfterUse) theHud.ShowInventory(); 
	}
	
	function FillLootWindow( optional closeAfter : bool )
	{
		var i				: int;
		var itemId			: SItemUniqueId;
		var itemName		: string;
		var allItems		: array< SItemUniqueId >;
		var itemTags		: array< name >;
		var args : array <CFlashValueScript>;
		var numShownItems	: int = 0;
		var inventory		: CInventoryComponent = GetInventory();
		var isAnything 		: bool;
		var add_quantity	: int;
		
		inventory.GetAllItems( allItems );
		numShownItems = 1;
		args.PushBack( FlashValueFromInt( RoundF( thePlayer.GetCurrentWeight() ) ) );
		args.PushBack( FlashValueFromInt( RoundF( thePlayer.GetMaxWeight() ) ) );
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt("ContTakeAll") ) );
		
		if ( numShownItems< 8 ) // panel loot  - quest items
		for ( i = allItems.Size()-1; i >= 0; i -= 1 )
		{
			add_quantity = 0;
			itemId = allItems[i];
			inventory.GetItemTags( itemId, itemTags );
			
			Log( inventory.GetItemName( itemId ) + " x" + inventory.GetItemQuantity( itemId ) );
			
			if ( itemTags.Contains( 'Quest' ) && !itemTags.Contains( 'NoDrop' ) )
			{
				itemName = inventory.GetItemName( itemId );
				
				add_quantity = 0; 
				
				if ( inventory.ItemHasTag( itemId, 'AlchemyIngridient' ) && !isDynamic ) 
				{
					add_quantity = RoundF( thePlayer.GetCharacterStats().GetAttribute( 'loot_alchemy_bonus' ) ); 
				}			
				
				args.PushBack( FlashValueFromString( itemName ) );
				args.PushBack( FlashValueFromString( GetLocStringByKeyExt( itemName ) ) );
				args.PushBack( FlashValueFromInt( add_quantity + inventory.GetItemQuantity( itemId ) ) );
				args.PushBack( FlashValueFromString( UniqueIdToString( itemId ) ) );
				args.PushBack( FlashValueFromString( "<img src='img://globals/gui/icons/items/" + StrReplaceAll( StrReplaceAll( itemName , " ", ""), "'", "" ) + "_64x64.dds' width='30' height='30'>" ) ) ;
				args.PushBack( FlashValueFromFloat( inventory.GetItemAttributeAdditive( itemId, 'item_weight' ) ) );
				args.PushBack( FlashValueFromInt( 1 ) );
				
				isAnything = true;
				
				// Send only first 8 items
				numShownItems += 1;
				if ( numShownItems == 8 )
					break;
			}
		}		
		
		if ( numShownItems< 8 ) // panel loot  - not quest items
		for ( i = allItems.Size()-1; i >= 0; i -= 1 )
		{
			add_quantity = 0;
			itemId = allItems[i];
			inventory.GetItemTags( itemId, itemTags );
			
			Log( inventory.GetItemName( itemId ) + " x" + inventory.GetItemQuantity( itemId ) );
			
			if ( !itemTags.Contains( 'NoDrop' ) && !itemTags.Contains( 'Quest' ))
			{
				itemName = inventory.GetItemName( itemId );
				
				add_quantity = 0; 
				
				if ( inventory.ItemHasTag( itemId, 'AlchemyIngridient' ) && !isDynamic ) 
				{
					add_quantity = RoundF( thePlayer.GetCharacterStats().GetAttribute( 'loot_alchemy_bonus' ) ); 
				}					
				
				args.PushBack( FlashValueFromString( itemName ) );
				args.PushBack( FlashValueFromString( GetLocStringByKeyExt( itemName ) ) );
				args.PushBack( FlashValueFromInt( add_quantity + inventory.GetItemQuantity( itemId ) ) );
				args.PushBack( FlashValueFromString( UniqueIdToString( itemId ) ) );
				args.PushBack( FlashValueFromString( "<img src='img://globals/gui/icons/items/" + StrReplaceAll( StrReplaceAll( itemName , " ", ""), "'", "" ) + "_64x64.dds' width='30' height='30'>" ) ) ;
				args.PushBack( FlashValueFromFloat( inventory.GetItemAttributeAdditive( itemId, 'item_weight' ) ) );
				args.PushBack( FlashValueFromInt( 0 ) );
				
				isAnything = true;
				
				// Send only first 8 items
				numShownItems += 1;
				if ( numShownItems == 8 )
					break;
			}
		}		
		
		
		if ( !isAnything ) 
		{
			args.Clear();
			args.PushBack( FlashValueFromInt( RoundF( thePlayer.GetCurrentWeight() ) ) );
			args.PushBack( FlashValueFromInt( RoundF( thePlayer.GetMaxWeight() ) ) );
			args.PushBack( FlashValueFromString( GetLocStringByKeyExt("ContEmpty") ) );
		}
		
		theHud.InvokeManyArgs("uiLootTable.setItems", args);	
		
		if ( closeAfter && !isAnything ) HideLootWindow();
	}
	
	function ShowLootPreview()
	{
		var AS_lootTable	: int = theHud.CreateAnonymousArray();
		var AS_item			: int;
		
		var inventory		: CInventoryComponent = GetInventory();
		var allItems		: array< SItemUniqueId >;
		
		var i				: int;
		var itemId			: SItemUniqueId;
		var itemName		: string;
		var itemTags		: array< name >;
		var numShownItems	: int = 0;
		
		var args : array <CFlashValueScript>;
	
		var isAnything 		: bool;

		Log( "-------------------------------------- ");
		Log( "CONTAINER ITEM LIST : ");
		Log( "-------------------------------------- ");

		if( !theGame.tutorialenabled )
		{		
			//if (!theHud.m_hud.ShowTutorial("tut17", "", false)) // <-- tutorial content is present in external tutorial - disabled
			//{ 
				if (IsQuestItem()) 	theHud.m_hud.ShowTutorial("tut51", "tut51_333x166", false); 
			//}
			//if (!theHud.ShowTutorialPanelOld( "tut17", "" )) { if (IsQuestItem()) 	theHud.ShowTutorialPanelOld( "tut51", "tut51_333x166" ); }
			/*
			if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
			{
				theHud.m_hud.ShowTutorial("tut172", "tut72_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut172", "tut72_333x166" );
			}
			else
			{
				theHud.m_hud.ShowTutorial("tut72", "tut72_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut72", "tut72_333x166" );
			}
			*/
		}
		
		inventory.GetAllItems( allItems );
			
		for ( i = allItems.Size()-1; i >= 0; i -= 1 ) // questowe
		{
			itemId = allItems[i];
			inventory.GetItemTags( itemId, itemTags );
			
			Log( inventory.GetItemName( itemId ) + " x" + inventory.GetItemQuantity( itemId ) );
			
			if ( ! itemTags.Contains( 'NoDrop' ) && itemTags.Contains( 'Quest' ) )
			{
				AS_item = theHud.CreateAnonymousObject();
				
				itemName = inventory.GetItemName( itemId );
				theHud.SetString( "Name",	GetLocStringByKeyExt( itemName ),		AS_item );
				theHud.SetString( "Icon",	"img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds",	AS_item );
				theHud.SetFloat	( "Class",	(int)inventory.GetItemClass( itemId ),	AS_item );
				
				theHud.PushObject( AS_lootTable, AS_item );
				theHud.ForgetObject( AS_item );
				isAnything = true;
				
				// Send only first 5 items
				numShownItems += 1;
				if ( numShownItems == 4 )
					break;
			}
		}
		
	if ( numShownItems< 4 ) // nie questowe
		for ( i = allItems.Size()-1; i >= 0; i -= 1 )
		{
			itemId = allItems[i];
			inventory.GetItemTags( itemId, itemTags );
			
			Log( inventory.GetItemName( itemId ) + " x" + inventory.GetItemQuantity( itemId ) );
			
			if ( ! itemTags.Contains( 'NoDrop' ) && !itemTags.Contains( 'Quest' ))
			{
				AS_item = theHud.CreateAnonymousObject();
				
				itemName = inventory.GetItemName( itemId );
				theHud.SetString( "Name",	GetLocStringByKeyExt( itemName ),		AS_item );
				theHud.SetString( "Icon",	"img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds",	AS_item );
				theHud.SetFloat	( "Class",	(int)inventory.GetItemClass( itemId ),	AS_item );
				
				theHud.PushObject( AS_lootTable, AS_item );
				theHud.ForgetObject( AS_item );
				isAnything = true;
				
				// Send only first 5 items
				numShownItems += 1;
				if ( numShownItems == 4 )
					break;
			}
		}	

		//if ( isAnything ) 
		theHud.m_hud.SetLootTable( AS_lootTable );
		theHud.ForgetObject( AS_lootTable );
	}
	
	function HideLootPreview()
	{
		theHud.m_hud.SetLootTable( -1 );
	}
	
	function MakeContainerEmpty() : bool
	{
		var loottable		: C2dArray;
		var respawn_time	: int;
		var i				: int;
		
		//ShowLootPreview();
		
		if ( IsLootable() )
		{
			SetVisualsEmpty();
			//if ( hideInteractionIfEmpty ) 
			GetComponent("Loot").SetEnabled( false );
		
			// Destroy empty dynamic container (loot dropped by npc)
			if ( isDynamic)
			{
				HideLootPreview();
				Destroy();
			}
		}
		
		
		return true;
	}
	
	function DestroyIt( ) : bool
	{
		var inv				: CInventoryComponent;
		
		inv = GetInventory();

		if ( !IsLootable() )
		{
			if ( isDynamic) Destroy();
		}
		
		return true;
	}
	
	
	function IsQuestItem() : bool
	{
		var allItems		: array< SItemUniqueId >;
		var isQuest 		: bool;
		var i				: int;
		
		GetInventory().GetAllItems( allItems );
		
		for ( i=0; i<allItems.Size(); i+=1 )
		{
			if ( GetInventory().ItemHasTag(allItems[i], 'Quest') ) 
			{
				isQuest = true;
			}
		}
		
		return isQuest;
	}
	
	// Podswietlenie kontenera, gdy jest w nim quest item
	function QuestItemGlow()
	{	
		StopEffect( 'quest_glow' );
	
		if ( IsQuestItem() ) 
		{
			PlayEffect( 'quest_glow' );
		}
	}
	
	function SetVisualsFull()
	{
		ApplyAppearance( "1_full" );
		PlayEffect( 'glow' );
		QuestItemGlow();
		isHighlightedByMedallion = true;
	}
	
	function SetVisualsEmpty()
	{
		ApplyAppearance( "2_empty" );
		StopEffect( 'glow' );
		StopEffect( 'quest_glow' );
		StopEffect('medalion_detection_fx');
		isHighlightedByMedallion = false;
		QuestItemGlow();
		if ( hideInteractionIfEmpty ) GetComponent("Loot").SetEnabled( false );
	}
}

// BE CAREFUL WITH INVENTORY COMPONENTS ORDER
function Helper_TransferItemFromContainerToPlayer( itemId : SItemUniqueId, targetInv, sourceInv : CInventoryComponent, isDynamic : bool )
{
	var quantity	: int;
	var itemName	: name;
	
	itemName = sourceInv.GetItemName( itemId );
	quantity = sourceInv.GetItemQuantity( itemId );
	
	if ( sourceInv.ItemHasTag( itemId, 'AlchemyIngridient' ) && !isDynamic ) 
	{
		// Quantity alteration possible, use modified routine. For ingredients it is safe, but not for upgradeable items.
		quantity = quantity + RoundF( thePlayer.GetCharacterStats().GetAttribute( 'loot_alchemy_bonus' ) );
		targetInv.AddItem( StringToName( itemName ), quantity, true );
		sourceInv.RemoveItem( itemId, quantity );
	}
	else
	{
		// Transfer item normally. For many items this is the only proper way, as it won't drop any specific item info like runes imprinted.
		sourceInv.GiveItem( targetInv, itemId, quantity );
	}
	
	Log( "Transfering item " + itemName + " to player's inventory in quantity " + quantity );
}

exec function HideLootWindow( optional noinput : bool )
{
	if ( thePlayer.GetLastContainer() )
	{
		thePlayer.SetManualControl(true, true);
		theHud.Invoke("uiLootTable.Close");
		theHud.Invoke("UnLoadLootWindow");
		theHud.EnableInput( false, false, false, false );
		thePlayer.SetCanUseHud( true );
		thePlayer.SetHotKeysBlocked( false );
		thePlayer.SetCombatHotKeysBlocked( false );
		if ( thePlayer.GetCombatBlockTriggerActive() ) 
		{
			thePlayer.SetCombatHotKeysBlocked( true );
		}
		theGame.SetTimeScale(1.0);
		if ( !thePlayer.GetLastContainer().IsLootable() ) thePlayer.GetLastContainer().GetComponent("Loot").SetEnabled( false );
		thePlayer.GetLastContainer().Closed();
		thePlayer.SetLastContainer( NULL );
	}
}

exec function LootItem( itemName : string, quantity : int )
{
	var itemId : SItemUniqueId;
	if ( thePlayer.GetLastContainer() )
	{
		itemId = thePlayer.GetLastContainer().GetInventory().GetItemId( StringToName( itemName ) );
		
		CheckForTutorial(itemId, thePlayer.GetLastContainer().GetInventory() );
		
		if ( AllowItemDarkDiff( thePlayer.GetLastContainer().GetInventory(), itemId ) )
		{
			Helper_TransferItemFromContainerToPlayer( itemId, thePlayer.GetInventory(), thePlayer.GetLastContainer().GetInventory(), thePlayer.GetLastContainer().isDynamic );
		}
		
		theSound.PlaySound( "gui/hud/itemlooted" );
		thePlayer.GetLastContainer().QuestItemGlow();
		if ( thePlayer.GetLastContainer().IsLootable() )
		{
			thePlayer.GetLastContainer().SetVisualsFull();
			thePlayer.GetLastContainer().FillLootWindow( true );
		}
		else
		{
			thePlayer.GetLastContainer().SetVisualsEmpty();
			thePlayer.GetLastContainer().DestroyIt();
			thePlayer.GetLastContainer().GetComponent("Loot").SetEnabled( false );
			HideLootWindow();
		}		
	}
}

exec function LootAll(  )
{
	if ( thePlayer.GetLastContainer() )
	{
		thePlayer.GetLastContainer().QuestItemGlow();
		thePlayer.GetLastContainer().TakeAllItems();
		thePlayer.GetLastContainer().QuestItemGlow();
		if ( !thePlayer.GetLastContainer().IsLootable() ) thePlayer.GetLastContainer().GetComponent("Loot").SetEnabled( false );
		thePlayer.GetLastContainer().SetVisualsEmpty();
		thePlayer.GetLastContainer().DestroyIt();
		
		// It must be called last, because it resets GetLastContainer()!
		HideLootWindow();
	}
	//thePlayer.GetLastContainer().GetInventory().GiveItem( thePlayer.GetInventory(), NameToUniqueId( StringToName( itemId ) ), quantity );
}

	function CheckForTutorial(itemId : SItemUniqueId, sourceInv	: CInventoryComponent )
	{
		//if ( sourceInv.GetItemCategory(itemId ) == 'alchemyingredient' ) { theHud.m_hud.ShowTutorial("tut24", "", false); }; // <-- tutorial content is present in external tutorial - disabled
		//if ( sourceInv.GetItemCategory(itemId ) == 'alchemyingredient' ) { theHud.ShowTutorialPanelOld( "tut24", "" ); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'skillupgrade' ) { theHud.m_hud.ShowTutorial("tut25", "", false); }; // <-- tutorial content is present in external tutorial - disabled
		//if ( sourceInv.GetItemCategory(itemId ) == 'skillupgrade' ) { theHud.ShowTutorialPanelOld( "tut25", "" ); };
		if ( sourceInv.GetItemCategory(itemId ) == 'armorupgrade' ) { theHud.m_hud.ShowTutorial("tut26", "", false); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'armorupgrade' ) { theHud.ShowTutorialPanelOld( "tut26", "" ); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'rangedweapon' ) { theHud.m_hud.ShowTutorial("tut42", "", false); }; // <-- tutorial content is present in external tutorial - disabled
		//if ( sourceInv.GetItemCategory(itemId ) == 'rangedweapon' ) { theHud.ShowTutorialPanelOld( "tut42", "" ); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'petard' ) { theHud.m_hud.ShowTutorial("tut43", "", false); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'petard' ) { theHud.ShowTutorialPanelOld( "tut43", "" ); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'trap' ) { theHud.m_hud.ShowTutorial("tut44", "", false); }; // <-- tutorial content is present in external tutorial - disabled 
		//if ( sourceInv.GetItemCategory(itemId ) == 'trap' ) { theHud.ShowTutorialPanelOld( "tut44", "" ); };
		if ( sourceInv.GetItemCategory(itemId ) == 'lure' ) { theHud.m_hud.ShowTutorial("tut45", "", false); };
		//if ( sourceInv.GetItemCategory(itemId ) == 'lure' ) { theHud.ShowTutorialPanelOld( "tut45", "" ); };
		if ( sourceInv.ItemHasTag( itemId, 'Rune' ) || sourceInv.ItemHasTag( itemId, 'Oil' ) ) { theHud.m_hud.ShowTutorial("tut27", "", false); };
		//if ( sourceInv.ItemHasTag( itemId, 'Rune' ) || sourceInv.ItemHasTag( itemId, 'Oil' ) ) { theHud.ShowTutorialPanelOld( "tut27", "" ); };
	}

	function AllowItemDarkDiff( sourceInv : CInventoryComponent, itemId : SItemUniqueId ) : bool
	{
	
		if ( ( sourceInv.ItemHasTag(itemId, 'DarkDiffA1') || sourceInv.ItemHasTag(itemId, 'DarkDiffA2') || sourceInv.ItemHasTag(itemId, 'DarkDiffA3') || sourceInv.ItemHasTag(itemId, 'DarkDiff') ) && theGame.GetDifficultyLevel() < 4 )
		{
			return false;
		} else
		{
			return true;
		}
	}