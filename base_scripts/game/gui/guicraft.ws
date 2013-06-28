/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Shop gui panel
/** Copyright © 2010
/***********************************************************************/

import class CGuiCraft extends CGuiPanel
{
	private var AS_craft : int;
	
	private var m_mapItemIdxToId       : array< SItemUniqueId >;
	
	// Schematics
	private var m_mapSchematicArrayIdxToItemIdx : array< int >;
	
	// Items
	private var m_mapItemArrayIdxToItemIdx : array< int >;

	private var m_allItemsNames : array< name >;
	

	function GetPanelPath() : string { return "ui_craft.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	}
	
	event OnClosePanel()
	{
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.HideCraft();
	}

	private function FillCraft()
	{
		var AS_schematics		: int;
		var AS_items			: int;
		var AS_recipesEffects 	: int;
		
		var inventory		: CInventoryComponent		= thePlayer.GetInventory();
		var stats			: CCharacterStats			= thePlayer.GetCharacterStats();
		var slotItems		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var itemId			: SItemUniqueId;
		var itemTags		: array< name >;
		var itemIdx			: int;
		var numItems		: int;
		var i				: int;
		var AS_item			: int;
		var craftedItemName : name;
		var craftedItemId	: SItemUniqueId;
		
		if ( !theHud.GetObject( "Schematics", AS_schematics, AS_craft ) )
		{
			LogChannel( 'GUI', "GUI Craft: cannot find Schematics object at scaleform side." );
		}
		if ( !theHud.GetObject( "Ingredients", AS_items, AS_craft ) )
		{
			LogChannel( 'GUI', "GUI Craft: cannot find Items object at scaleform side." );
		}
		if ( !theHud.GetObject( "RecipesEffects", AS_recipesEffects, AS_craft ) )
		{
			LogChannel( 'GUI', "GUI Craft: cannot find RecipesEffects object at scaleform side." );
		}
		
		theHud.ClearElements( AS_schematics );
		m_mapSchematicArrayIdxToItemIdx.Clear();
		
		theHud.ClearElements( AS_items );
		m_mapItemArrayIdxToItemIdx.Clear();
		
		theHud.ClearElements( AS_recipesEffects );

		m_mapItemIdxToId.Clear();
		
		// Get items in player's inventory
		inventory.GetAllItems( m_mapItemIdxToId );
		numItems = m_mapItemIdxToId.Size();
		
		// Get crafting ingredients
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapItemIdxToId[i];
			
			// add to list items that have proper tags
			inventory.GetItemTags( itemId, itemTags );
			
			// Get items
			if ( ! itemTags.Contains( 'NoShow' ) && 
				 ! itemTags.Contains( 'nodrop' ) &&
				   itemTags.Contains( 'CraftingIngridient' ))
			{
				m_mapItemArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems );
				
				theHud.PushObject( AS_items, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}
		
		// Get crafting schematics
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapItemIdxToId[i];
			
			// add to list items that have proper tags
			inventory.GetItemTags( itemId, itemTags );
			
			// Get schematics
			if ( itemTags.Contains( 'Schematic' ) )
			{
				m_mapSchematicArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();

				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems, 'schematic' );
				
				theHud.PushObject( AS_schematics, AS_item );
				theHud.ForgetObject( AS_item );
				
				
				// Fill item created from recipe
				craftedItemName = inventory.GetCraftedItemName( itemId );
				theHud.m_utils.FillFlashItemDescription( craftedItemName, inventory, stats, AS_recipesEffects, i, slotItems );
			}
		}
		
		// Orens
		theHud.SetFloat( "Orens", inventory.GetItemQuantityByName( 'Orens' ), AS_craft );
		
		// Mass
		theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_craft );

		theHud.ForgetObject( AS_schematics );
		theHud.ForgetObject( AS_items );
		theHud.ForgetObject( AS_recipesEffects );
		
		theHud.Invoke( "Commit", AS_craft );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mCraft", AS_craft ) )
		{
			LogChannel( 'GUI', "No mCraft found at the Scaleform side!" );
		}

		FillCraft();
	}
	
	private final function CraftItem( itemsIdsStr : string, craftingItemPrice : float ) : bool
	{
		var ids : array< int >;
		var i : int;
		var itemId	: SItemUniqueId;
		var ingredientsNames : array< name >;
		var ingredientsQuantities : array< int >;
		var ingredientName : name;
		var idx : int;
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var craftedItemName : name;
		
		ids = theHud.m_utils.SplitStringForItemsIds( itemsIdsStr );
		//LogChannel( 'GUI', "Parametr: " + itemsIdsStr );

		// prepare ingredients list and remove ingredient items from inventory
		for ( i = 0; i < ids.Size(); i += 1 )
		{
			itemId = m_mapItemIdxToId[ ids[i] ];
			
			ingredientName = inv.GetItemName( itemId );
			idx = ingredientsNames.FindFirst( ingredientName );
			if ( idx == -1 )
			{
				ingredientsNames.PushBack( ingredientName );
				ingredientsQuantities.PushBack( 1 );
			}
			else
			{
				ingredientsQuantities[idx] += 1;
			}
		
			inv.RemoveItem( itemId, 1 );
		}
		
		// try to create something
		craftedItemName = theHud.m_utils.GetCraftedItemNameForIngredients( ingredientsNames, ingredientsQuantities );
		if ( craftedItemName != '' )
		{
			theSound.PlaySound( "gui/crafting/newitem" );
		
			thePlayer.RemoveOrens( (int)craftingItemPrice );
			inv.AddItem( craftedItemName, 1, false );
			FillCraft(); // update data to gui
			theGame.UnlockAchievement('ACH_CRAFTER');
			return true;
		}
		else
		{
			// item wasn't created
			return false;
		}
	}
}

/*
exec function DismantleItem( itemName : name )
{
	var itemIngredients: array < SItemIngredient >;
	var i: int;
	if ( thePlayer.GetInventory().ItemHasTag( thePlayer.GetInventory().GetItemId( itemName ), 'Dismantle' ) ) 
	{
		thePlayer.GetInventory().GetItemIngredients( thePlayer.GetInventory().GetItemId( itemName ), itemIngredients);
		for( i=0; i<itemIngredients.Size(); i+=1 )
			{
				if (RandRangeF(0, 100) < 50)
				{
					thePlayer.GetInventory().AddItem(itemIngredients[i].itemName, RoundF( thePlayer.GetCharacterStats().GetAttribute('loot_alchemy_bonus') * RandRangeF( 1, itemIngredients[i].quantity + 1) ) );
				}
				Log("Uzyskuje skladnik " + itemIngredients[i].itemName);
			}
		theHud.Invoke("MainFrame.PlayWork");
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId(itemName) , 1);		
		theHud.ShowInfo("Cannot dismantle that item!");
		
	} else
	{
		theHud.ShowInfo("Cannot dismantle that item!");
		Log("Przedmiotu nie mozna rozlozyc!");
	}
}
*/
