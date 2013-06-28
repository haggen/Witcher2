class CWitcheGlovesDark extends CItemEntity
{
	event OnDetach( parentEntity : CEntity )
	{
		var inv : CInventoryComponent;
		var itemId : SItemUniqueId;
		if(parentEntity == thePlayer && !thePlayer.IsNotGeralt())
		{
			inv = thePlayer.GetInventory();
			itemId = inv.GetItemByItemEntity( this );
			thePlayer.SetDarkSet(false);
		}
		super.OnDetach( parentEntity );
	}
	event OnMount( parentEntity : CEntity, slot : name )
	{
		var inv : CInventoryComponent;
		var itemId : SItemUniqueId;
		if(parentEntity == thePlayer && !thePlayer.IsNotGeralt())
		{
			inv = thePlayer.GetInventory();
			itemId = inv.GetItemByItemEntity( this );
			thePlayer.CheckSet(itemId, parentEntity);
		}
		super.OnMount(parentEntity, slot);
	}
}