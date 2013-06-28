exec function asd()
{
	AddItem( StringToName("Baltimore's Map") );
}

exec function LoadBookText()
{
	var str : string;
	str = GetLocStringByKeyExt( NameToString( thePlayer.GetInventory().GetItemName( thePlayer.GetLastBook() ) ) + "_entry" );
	theHud.InvokeOneArg("pPanelClass.GetTexts", FlashValueFromString(str) );

}
exec function CloseBook()
{
	/*theGame.SetActivePause( false );
	theHud.m_hud.SetMainFrame("");
	theHud.EnableInput( false, false, false );
	theHud.ShowInventory();*/
}



exec function Craft()
{
	/*AddItem('Schematic Light Leather Armor');
	AddItem('Schematic Light Leather Armor');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Cloth');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Leather');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');
	AddItem('Threads');*/
	/*theHud.SetPassEscKey( true );
	theHud.m_hud.SetMainFrame("ui_crafting.swf");
	theHud.Invoke("showCrafting");
	theHud.EnableInput( true, false, true );
	theGame.SetActivePause( true );*/
}

exec function Crafting_SendItemsData( )
{
	var itemId : SItemUniqueId;

	var item_names : string;
	var item_colors : string;
	var item_uids  : string;
	var item_tooltips : string;
	var item_counts : string;
	
	var item_name  : string;
	var item_color  : string;
	var item_uid   : string;
	var item_tooltip : string;
	var item_count : string;
	var item_tags : array < name >;
		
	var i : int;		
		
	var allItems : array< SItemUniqueId >;
		
	// get item count in player's inventory
	thePlayer.GetInventory().GetAllItems( allItems );
	// find all items with sort_tag in inventory
	
	//SendGoldAmount();
		
	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		itemId = allItems[i];
		item_name = thePlayer.GetInventory().GetItemName(itemId);
		thePlayer.GetInventory().GetItemTags( itemId, item_tags );
		if ( thePlayer.GetInventory().ItemHasTag( itemId, 'Schematic' ) )// add to list
		{
			// get item info
			item_uid = UniqueIdToString( itemId ); 
			item_count = thePlayer.GetInventory().GetItemQuantity( itemId );
			item_tooltip = GetItemTooltipData( itemId, thePlayer.GetInventory() );
			item_color = GetItemNameColor( itemId, thePlayer.GetInventory());
			// add to list
			item_names = item_names + item_name + ";";
			item_colors = item_colors + item_color + ";";
			item_counts = item_counts + item_count + ";";
			item_uids  = item_uids + item_uid + ";";
			item_tooltips = item_tooltips + item_tooltip + ";";
		}
	}
	// send data to gui
	theHud.InvokeOneArg("pPanelClass.GetSchematicName", FlashValueFromString( item_names ) );
	theHud.InvokeOneArg("pPanelClass.GetSchematicColor", FlashValueFromString( item_colors ) );
	theHud.InvokeOneArg("pPanelClass.GetSchematicId", FlashValueFromString( item_uids ) );
	theHud.InvokeOneArg("pPanelClass.GetSchematicTooltip", FlashValueFromString( item_tooltips ) );
	theHud.InvokeOneArg("pPanelClass.GetSchematicCount", FlashValueFromString( item_counts ) );
	
	Log("----> item count : " + item_counts);
}

function GetItemNameColor( item_id : SItemUniqueId, inventory : CInventoryComponent ) : string
{
  var color : string;
  color = "<font color='#F4F6F4'>";;
  if ( inventory.ItemHasTag( item_id, 'TypeMagic') ) color = "<font color='#06DA10'>";
  if ( inventory.ItemHasTag( item_id, 'TypeRare') ) color = "<font color='#79A1F3'>";
  if ( inventory.ItemHasTag( item_id, 'TypeEpic') ) color = "<font color='#DF9DEF'>";
  return color;
}

function GetItemNameColorByTags( itemTags : array<name> ) : string
{
	if ( itemTags.Contains( 'TypeEpic' ) )
		return "<font color='#DF9DEF'>";
	if ( itemTags.Contains( 'TypeRare' ) )
		return "<font color='#79A1F3'>";
	if ( itemTags.Contains( 'TypeMagic' ) )
		return "<font color='#06DA10'>";
	return "<font color='#F4F6F4'>";
}

// Get tooltip data
function GetItemTooltipData ( item_id : SItemUniqueId, inventory : CInventoryComponent ) : string
{
	var tooltip_name : string;
	var tooltip_type : string;
	var tooltip_desc : string;
	var tooltip_ext  : string;
	var tooltip_damage : float;
	var tooltip_damage_min_add : float;
	var tooltip_damage_max_add : float;
	var tooltip_damage_min_mult : float;
	var tooltip_damage_max_mult : float;
	var tooltip_magic : float;
	var tooltip_crit : float;
	var tooltip_isequipped : bool;
	var tooltip_data : string;
	
	var itemName	: string;
	var upgrades	: array <name>;
	var itemTags	: array< name >;
	var itemAttrs	: array< name >;
	var i	: int;
	var val : float;
	
	if (item_id == GetInvalidUniqueId()) return "";

	// get name
	itemName = inventory.GetItemName(item_id);
	inventory.GetItemTags( item_id, itemTags );
	//inventory.GetItemSlotItems( item_id, upgrades );
	
	// get item type and description
	tooltip_type = "Unknown item type*";

	if (itemTags.Contains('Lure')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeLure");  }
	else
	if (itemTags.Contains('Weapon')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeMelee");  }
	else
	if (itemTags.Contains('RangedWeapon')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeRanged");  }
	else
	if (itemTags.Contains('Elixir')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypePotion") + " " + GetLocStringByKeyExt("ElixirsMeditationTooltip");  }
	else
	if (itemTags.Contains('WeaponUpgrade')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeWeaponUpgrade");  }
	else
	if (itemTags.Contains('Oil')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeOil");  }
	else
	if (itemTags.Contains('Petard')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypePetard"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescPetard"); }
	else
	if (itemTags.Contains('Armor')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeArmor"); }
	else
	if (itemTags.Contains('Trap')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeTrap"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescTrap"); }
	else
	if (itemTags.Contains('Trophy')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeTrophy"); }
	else
	if (itemTags.Contains('Herb')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeIngredientHerb"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescHerb"); }
	else
	if (itemTags.Contains('AlchemyIngridient')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeIngredientAlchemy"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescIngredientAlch"); }
	else
	if (itemTags.Contains('CraftingIngridient')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeIngredientCrafting"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescIngredientCraft"); }
	else
	if (itemTags.Contains('Schematic')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeSchematic"); tooltip_desc = GetLocStringByKeyExt("TooltipItemDescSchematic"); }
	else
	if (itemTags.Contains('Crafting')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeCrafting"); }
	else
	if (itemTags.Contains('ArmorUpgrade')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeArmorUpgrade"); }
	else
	if (itemTags.Contains('Dye')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeDye");  }
	else
	if (itemTags.Contains('Mutagen')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeMutagen"); }
	else
	if (itemTags.Contains('Book')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeBook");  }
	else
	if (itemTags.Contains('Quest')) { tooltip_type = GetLocStringByKeyExt("TooltipItemTypeQuest");  }
	else
	if (itemTags.Contains('Dismantle')) { tooltip_desc = GetLocStringByKeyExt("TooltipItemTypeDismantle"); }
	
	if (itemTags.Contains('Vitriol'))   { tooltip_type = tooltip_type + " ( VITRIOL )"; }
	else
	if (itemTags.Contains('Rebis'))     { tooltip_type = tooltip_type + " ( REBIS )"; }
	else
	if (itemTags.Contains('Caelum'))    { tooltip_type = tooltip_type + " ( CAELUM )"; }
	else
	if (itemTags.Contains('Aether'))    { tooltip_type = tooltip_type + " ( AETHER )"; }
	else
	if (itemTags.Contains('Quebrith'))  { tooltip_type = tooltip_type + " ( QUEBRITH )"; }
	else
	if (itemTags.Contains('Sol'))       { tooltip_type = tooltip_type + " ( SOL )"; }
	else
	if (itemTags.Contains('Vermilion')) { tooltip_type = tooltip_type + " ( VERMILION )"; }
	else
	if (itemTags.Contains('Hydragenum')){ tooltip_type = tooltip_type + " ( HYDRAGENUM )"; }
	else
	if (itemTags.Contains('Fulgur'))    { tooltip_type = tooltip_type + " ( FULGUR )"; }

	// get damage (old)
	tooltip_damage = inventory.GetItemAttributeAdditive(item_id, 'damage_mult');
	// get damage min-max _ add
	tooltip_damage_min_add = inventory.GetItemAttributeAdditive(item_id, 'damage_min_add');
	tooltip_damage_max_add = inventory.GetItemAttributeAdditive(item_id, 'damage_max_add');
	// get damage min-max _ mult
	tooltip_damage_min_mult = inventory.GetItemAttributeAdditive(item_id, 'damage_min_mult');
	tooltip_damage_max_mult = inventory.GetItemAttributeAdditive(item_id, 'damage_max_mult');
	// is item already equiped?
	tooltip_isequipped = inventory.IsItemMounted(item_id);

// PREPARE TOOLTIP HTML DATA	
	// add : begin
	tooltip_data = "<html><head></head><body><center>";

	// add : item name
	tooltip_data = tooltip_data + "<font size='14'>" + GetItemNameColor(item_id, inventory) + StrUpperUTF( GetLocStringByKeyExt( itemName ) );
	
	// Add enchants info
	i = inventory.GetItemEnhancementSlotsCount( item_id );
	if ( i > 0 )
		tooltip_data = tooltip_data + "<br><font size='10' color='#FCF900'>" + GetLocStringByKeyExt("Enhancement slots") + ": " + i;

	if (upgrades.Size() > 0 && upgrades[0] != '')
	{
		tooltip_data = tooltip_data + "<br><font size='10' color='#FCF900'>+ " + GetLocStringByKeyExt(upgrades[0]);
		if (upgrades.Size() > 1 && upgrades[1] != '')
		{
			tooltip_data = tooltip_data + "<br>+" + GetLocStringByKeyExt(upgrades[1]);
			if (upgrades.Size() > 2 && upgrades[2] != '')
				tooltip_data = tooltip_data + "<br>+ " + GetLocStringByKeyExt(upgrades[2]);
		}
	}

	// Add item type
	tooltip_data = tooltip_data + "<br><font size='12' color='#B5FBFA'>" + tooltip_type;
	
	// Add item damage (old)
	if (tooltip_damage>0)
		tooltip_data = tooltip_data + "<br><font size='12' color='#FFFFFF'>" + GetLocStringByKeyExt("TooltipDamage") + " <font size='14'>+" + RoundF(tooltip_damage * 100) + "%";
	// Add item damage min-max
	if (tooltip_damage_min_add>0 || tooltip_damage_max_add>0)
		tooltip_data = tooltip_data + "<br><font size='12' color='#FFFFFF'>" + GetLocStringByKeyExt("TooltipDamage") + " <font size='14'>" + RoundF(tooltip_damage_min_add) + "-" + RoundF(tooltip_damage_max_add);
	if (tooltip_damage_min_mult>0 || tooltip_damage_max_mult>0)
		tooltip_data = tooltip_data + "<br><font size='12' color='#FFFFFF'>" + GetLocStringByKeyExt("TooltipDamage") + " +<font size='14'>" + RoundF(tooltip_damage_min_mult * 100) + "-" + RoundF(tooltip_damage_max_mult * 100) + "%";

	// Add txt desc	
	// TODO: Do Matiego - Czy nie mozna uzyc jako klucza tlumaczenia "Tooltip"+itemName? Po co to usuwanie spacji / po co spacja w itemName ktore tez jest tlumaczony?
	tooltip_ext = GetLocStringByKeyExt( "Tooltip" + StrReplace( itemName, " ", "" ) );
	if ( tooltip_ext )
		tooltip_data = tooltip_data + "<br><font size='12' color='#FFFFFF'>" + tooltip_ext;

	// Add critical effects
	inventory.GetItemAttributes( item_id, itemAttrs );
	for ( i = itemAttrs.Size()-1; i >= 0; i -= 1 )
	{
		val = inventory.GetItemAttributeAdditive( item_id, itemAttrs[i] );
		if ( val != 0 )
		{
			// TODO: Do Matiego -	Wez wymysl cos lepszego niz kilometrowa lista hardcodowanych atrybutow.
			// 						IsMult mozna przechowywac w definicji atrybutu, a lokalizacje oprzec na nazwie atrybutu,
			//						wtedy wystarczy szybka pentelka z kokardka jak tutaj :)
			tooltip_data = tooltip_data + "<br><font size='12' color='#FFFFFF'>" + GetLocStringByKeyExt( "Tooltip_" + itemAttrs[i] ) + "<font size='14'>";
			
			if ( false )//if( ismult )
			{
				if ( val < 0 )
					tooltip_data = tooltip_data + RoundF(val * 100) + "<font size='12'>%";
				else
					tooltip_data = tooltip_data + "+" + RoundF(val * 100) + "<font size='12'>%";
			}
			else
			{
				if ( val < 0 )
					tooltip_data = tooltip_data + RoundF(val);
				else
					tooltip_data = tooltip_data + "+" + RoundF(val);
			}
		}
	}

	// Add end
	tooltip_data = tooltip_data + "<br><font size='12' color='#FCCAB6'>" + tooltip_desc + "</center></body></html>";

	return tooltip_data;
}

exec function Inventory_SendItemsData( sort_tag2 : string )
{
	var itemId : SItemUniqueId;

	var item_names : string;
	var item_colors : string;
	var item_uids  : string;
	var item_tooltips : string;
	var item_glueds : string;
	var item_counts : string;
	var item_equippeds : string;
	var item_prices: string;
	var item_types : string;
	
	var item_name  : string;
	var item_color  : string;
	var item_uid   : string;
	var item_equipped : string;
	var item_tooltip : string;
	var item_glued : string;
	var item_count : string;
	var item_price : string;
	var item_type : string;
	var item_tags : array < name >;
	
	var sort_tag : name;
		
	var i : int;		
		
	var allItems : array< SItemUniqueId >;
		
	sort_tag = StringToName( sort_tag2 );
	
	// get item count in player's inventory
	thePlayer.GetInventory().GetAllItems( allItems );
	// find all items with sort_tag in inventory
		
	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		itemId = allItems[i];
		item_name = thePlayer.GetInventory().GetItemName(itemId);
		//Log("------------> name : " + item_name);
		thePlayer.GetInventory().GetItemTags( itemId, item_tags );
		if ( ( thePlayer.GetInventory().ItemHasTag( itemId, sort_tag ) || sort_tag == 'SortTypeAll' ) && ( !thePlayer.GetInventory().ItemHasTag( itemId, 'NoShow') && ( !thePlayer.GetInventory().ItemHasTag( itemId, 'Schematic') ) && 
			  !thePlayer.GetInventory().ItemHasTag( itemId, 'NoDrop') &&  !thePlayer.GetInventory().IsItemMounted( itemId ) ) ) // add to list
		{
			// get item info
			item_uid = UniqueIdToString(itemId); 
			item_count = thePlayer.GetInventory().GetItemQuantity( itemId );
			item_tooltip = GetItemTooltipData( itemId, thePlayer.GetInventory() );
			item_glued = thePlayer.GetInventory().IsItemMounted( itemId );
			item_equipped = thePlayer.GetInventory().IsItemMounted( itemId );
			item_price = theHud.m_utils.GetItemPrice(itemId, thePlayer.GetInventory());
			item_type = "0";
			item_color = GetItemNameColor( itemId, thePlayer.GetInventory());
			if (thePlayer.GetInventory().ItemHasTag(itemId, 'ArmorUpgrade')) item_type = "1";
			if (thePlayer.GetInventory().ItemHasTag(itemId, 'WeaponUpgrade')) item_type = "2";
			// add to list
			item_names = item_names + item_name + ";";
			item_colors = item_colors + item_color + ";";
			item_counts = item_counts + item_count + ";";
			item_uids  = item_uids + item_uid + ";";
			item_tooltips = item_tooltips + item_tooltip + ";";
			item_glueds = item_glueds + item_glued + ";";
			item_equippeds = item_equippeds + item_equipped + ";";
			item_prices = item_prices + item_price + ";";
			item_types = item_types + item_type + ";";
		}
	}
	// send data to gui
	theHud.InvokeOneArg("pPanelClass.GetItemNameList", FlashValueFromString(item_names));
	theHud.InvokeOneArg("pPanelClass.GetItemColorList", FlashValueFromString(item_colors));
	theHud.InvokeOneArg("pPanelClass.GetItemIdList", FlashValueFromString(item_uids));
	theHud.InvokeOneArg("pPanelClass.GetItemTooltipList", FlashValueFromString(item_tooltips));
	theHud.InvokeOneArg("pPanelClass.GetItemGluedList", FlashValueFromString(item_glueds));
	theHud.InvokeOneArg("pPanelClass.GetItemCountList", FlashValueFromString(item_counts));
	theHud.InvokeOneArg("pPanelClass.GetItemEquippedList", FlashValueFromString(item_equippeds));
	theHud.InvokeOneArg("pPanelClass.GetItemPriceList", FlashValueFromString(item_prices));
	theHud.InvokeOneArg("pPanelClass.GetItemTypeList", FlashValueFromString(item_types));
}

exec function GetCraftedTooltip( schematName2 : string)
{
	var itemName : string;
	var itemTooltip : string;
	var itemId : SItemUniqueId;
	var itemIngredients: array < SItemIngredient >;
	var itemIngredientsTxt : string;
	var allItems : array< SItemUniqueId >;
	var i, i2: int;
	var color : string;
	var allowToCraft : bool;
	var quant : int;
	var schematName : name;
	
	schematName = StringToName( schematName2);

	thePlayer.GetInventory().GetAllItems( allItems );
	// crated item
	itemName = thePlayer.GetInventory().GetCraftedItemName( thePlayer.GetInventory().GetItemId( schematName ) );
	thePlayer.GetInventory().AddItem( StringToName( itemName ), 1);
	itemId = thePlayer.GetInventory().GetItemId( StringToName( itemName ) );
	thePlayer.GetInventory().GetItemIngredients( thePlayer.GetInventory().GetItemId( schematName ), itemIngredients);
	itemTooltip = "<font size='12' color='#FCCAB6'>" + GetLocStringByKeyExt("Crafting scheme allows to craft") + ":<br>" + GetItemTooltipData( itemId, thePlayer.GetInventory() );
	thePlayer.GetInventory().RemoveItem( itemId , 1);
	itemIngredientsTxt = "Required ingredients:<br>";
	// ingredients
	allowToCraft=true;
	for( i=0; i<itemIngredients.Size(); i+=1 )
	{
		color = "#FF2222";
		quant = 0;
		for( i2=0; i2<allItems.Size(); i2+=1 )
		{
			if ( ( itemIngredients[i].itemName == thePlayer.GetInventory().GetItemName( allItems[i2] ) ) && ( itemIngredients[i].quantity <= thePlayer.GetInventory().GetItemQuantity( allItems[i2] ) ) ) 
			{
				color = "#22FF22";	
				quant = thePlayer.GetInventory().GetItemQuantity( allItems[i2] );
			}
		}
		if (color == "#FF2222") allowToCraft = false;
		itemIngredientsTxt = itemIngredientsTxt + "<font size='12' color='" + color + "'>" + itemIngredients[i].quantity + "x "  + GetLocStringByKeyExt(itemIngredients[i].itemName) + "<font size='10' color='#FFFFFF'> (" + quant + "/" + itemIngredients[i].quantity + ")<br>";
	}
	// send data
	theHud.InvokeOneArg("pPanelClass.GetCratedName", FlashValueFromString(GetLocStringByKeyExt( itemName ) ));
	theHud.InvokeOneArg("pPanelClass.GetCratedTooltip", FlashValueFromString(itemTooltip));
	theHud.InvokeOneArg("pPanelClass.GetCraftingIngr", FlashValueFromString(itemIngredientsTxt));
	theHud.InvokeOneArg("pPanelClass.GetAllowToCraft", FlashValueFromString(allowToCraft));
}

exec function DismantleItem( itemName2 : string )
{
	var itemIngredients: array < SItemIngredient >;
	var i: int;
	var itemName : name;
	
	itemName = StringToName( itemName2 );
	
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
				theHud.m_messages.ShowInformationText( "Item dismantled - gathered " + itemIngredients[i].itemName );
			}
		theHud.Invoke("pPanelClass.PlayWork");
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId(itemName) , 1);		
		//theHud.ShowInfo("Cannot dismantle that item!");
		theHud.m_messages.ShowInformationText( "Item dismantled but no items received." );
	} else
	{
		theHud.m_messages.ShowInformationText( "Cannot dismantle that item." );
		//theHud.m_hud.ShowInfo("Cannot dismantle that item!");
		Log("Przedmiotu nie mozna rozlozyc!");
	}
}

exec function CraftItem(schematName2 : string)
{
	var itemName : string;
	var itemIngredients: array < SItemIngredient >;
	var i : int;
	var schematName : name;
	
	schematName = StringToName( schematName2 );

	theHud.Invoke("pPanelClass.PlayWork");
	itemName = thePlayer.GetInventory().GetCraftedItemName( thePlayer.GetInventory().GetItemId( schematName ) );
	thePlayer.GetInventory().AddItem( StringToName( itemName ), 1);
	thePlayer.GetInventory().GetItemIngredients( thePlayer.GetInventory().GetItemId( schematName ), itemIngredients);
	// remove ingredients
	for( i=0; i<itemIngredients.Size(); i+=1 )
	{
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId(itemIngredients[i].itemName), itemIngredients[i].quantity );
	}
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( schematName ) , 1);

}

exec function CloseCrafting()
{
	/*var restoreInv : bool = false;
	if ( theHud.IsPanelLoaded("ui_book.swf") )
	{
		restoreInv = true;
		theGame.EnableButtonInteractions( true );
	}

	theGame.SetActivePause( false );
	if ( thePlayer.GetLastBoard() ) thePlayer.GetLastBoard().GetComponent ("Look at board").SetEnabled(true);
	theHud.m_hud.OpenPanel( "", "", "", false, false, true );
	theHud.EnableInput( false, false, false );
	theHud.SetPassEscKey( false );
	
	if ( restoreInv )
	{
		theHud.ShowInventory();
	}*/
}
