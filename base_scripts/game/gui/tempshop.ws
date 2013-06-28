/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Info board with potential quests
/** Copyright © 2010
/***********************************************************************/

exec function Shop( aktor : CActor)
{
	/*thePlayer.SetShopOwner( aktor );
	theHud.SetPassEscKey( true );
	theHud.m_hud.SetMainFrame("ui_shop.swf");
	theHud.EnableInput( true, false, true );
	theGame.SetActivePause( true );*/
}

function SendGoldAmount()
{
	var gold : string;
	
	//fake for now
	//gold = "1000";
	gold = IntToString( thePlayer.GetInventory().GetItemQuantityByName( 'Orens' ) );
	
	theHud.InvokeOneArg("pPanelClass.setgold", FlashValueFromString(gold));
}

exec function ShopBuyItem( itemIds : string)
{
	var itemId : SItemUniqueId;
	var merchant : CActor;
	var inv_player : CInventoryComponent;
	var inv_merchant : CInventoryComponent;
	var playersCashId : SItemUniqueId;
	var income : int;
	var gold : int;
	var outcome : int;
		
	itemId = NameToUniqueId( StringToName( itemIds ) );
	gold = thePlayer.GetInventory().GetItemQuantityByName( 'Orens' );
	merchant = thePlayer.shopowner;
	inv_player = thePlayer.GetInventory();
	inv_merchant = merchant.GetInventory();
	playersCashId = inv_player.GetItemId( 'Orens' );
	outcome = RoundF(  theHud.m_utils.GetItemPrice( itemId, inv_merchant ) );

	//Log( "cena kupna = " + outcome );
	//Log( "handlarzem jest " + merchant );
	
	if (outcome <= gold) // have enough gold?
	{
		// buy logic here 
		inv_merchant.GiveItem( inv_player , itemId, 1);
		inv_player.RemoveItem( playersCashId , outcome );
	} else
	{
		theHud.InvokeOneArg("pPanelClass.showWarning",FlashValueFromString("You don't have enough amount of orens."));
	}
	SendGoldAmount();
	
	//Shop_SendItemsData("SortTypeAll");
	//Inventory_SendItemsData("SortTypeAll");

}

exec function ShopSellItem( itemIds : string )
{
	var itemId : SItemUniqueId;
	var merchant : CActor;
	var inv_player : CInventoryComponent;
	var inv_merchant : CInventoryComponent;
	var outcome: int;
	var merchantsCashId : SItemUniqueId;
	var income : int;
	
	itemId = NameToUniqueId( StringToName( itemIds ) );
	merchant = thePlayer.shopowner;
	inv_player = (CInventoryComponent)thePlayer.GetInventory();
	inv_merchant = (CInventoryComponent)merchant.GetInventory();
	merchantsCashId = inv_merchant.GetItemId( 'Orens' );
	income = theHud.m_utils.GetItemPrice(itemId, inv_player );
	
	if ( income != 0 )
	{
		// sell logic here 
		inv_player.GiveItem(inv_merchant, itemId, 1);
		inv_player.AddItem( 'Orens' , income );
		//inv_merchant.GiveItem(inv_player, merchantsCashId, income );
	}
	
	SendGoldAmount();
	
	//Shop_SendItemsData("SortTypeAll");
	//Inventory_SendItemsData("SortTypeAll");
	
}

exec function Shop_SendItemsData( sort_tag2 : string )
{
	var itemId : SItemUniqueId;

	var item_names : string;
	var item_colors : string;
	var item_uids  : string;
	var item_tooltips : string;
	var item_glueds : string;
	var item_counts : string;
	var item_equippeds : string;
	var item_prices : string;
	
	var item_name  : string;
	var item_color : string;	
	var item_uid   : string;
	var item_tooltip : string;
	var item_count : string;
	var item_price : string;
	var item_tags : array < name >;
	
	var sort_tag : name;
		
	var i : int;		
	var merchant     : CActor;
		
	var allItems : array< SItemUniqueId >;
		
	merchant = thePlayer.GetShopOwner();
	
	sort_tag = StringToName( sort_tag2 );
		
	// get item count in player's inventory
	merchant.GetInventory().GetAllItems( allItems );
	// find all items with sort_tag in inventory
		
	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		itemId = allItems[i];
		item_name = merchant.GetInventory().GetItemName(itemId);
		merchant.GetInventory().GetItemTags( itemId, item_tags );
		if ( ( merchant.GetInventory().ItemHasTag( itemId, sort_tag ) || sort_tag == 'SortTypeAll' ) && ( !merchant.GetInventory().ItemHasTag( itemId, 'NoShow') && !merchant.GetInventory().ItemHasTag( itemId, 'nodrop') ) ) // add to list
		{
			// get item info
			item_uid = UniqueIdToString(itemId); 
			item_count = merchant.GetInventory().GetItemQuantity( itemId );
			item_tooltip = GetItemTooltipData( itemId, merchant.GetInventory() );
			item_price = theHud.m_utils.GetItemPrice(itemId, merchant.GetInventory());
			item_color = GetItemNameColor( itemId, merchant.GetInventory());
			// add to list
			item_names = item_names + item_name + ";";
			item_counts = item_counts + item_count + ";";
			item_uids  = item_uids + item_uid + ";";
			item_tooltips = item_tooltips + item_tooltip + ";";
			item_prices = item_prices + item_price + ";";
			item_colors = item_colors + item_color + ";";
		}
	}
	// send data to gui
	theHud.InvokeOneArg("pPanelClass.GetShopColors", FlashValueFromString(item_colors));
	theHud.InvokeOneArg("pPanelClass.GetShopItemNameList", FlashValueFromString(item_names));
	theHud.InvokeOneArg("pPanelClass.GetShopItemIdList", FlashValueFromString(item_uids));
	theHud.InvokeOneArg("pPanelClass.GetShopTooltips", FlashValueFromString(item_tooltips));
	theHud.InvokeOneArg("pPanelClass.GetShopItemCountList", FlashValueFromString(item_counts));
	theHud.InvokeOneArg("pPanelClass.GetShopPrices", FlashValueFromString(item_prices));
}