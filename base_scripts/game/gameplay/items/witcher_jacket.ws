/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher jacket
/** Copyright © 2010
/***********************************************************************/
class CWitcherJacketDark extends CWitcherJacket
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
class CWitcherJacket extends CItemEntity
{
	event OnMount( parentEntity : CEntity, slot : name )
	{
		var inv : CInventoryComponent;
		inv = ( (CGameplayEntity) parentEntity ).GetInventory();
		
		if ( parentEntity != thePlayer || thePlayer.isNotGeralt ) return false;
		
		//inv.MountItem( inv.GetItemId( 'belt_jacket' ), false );
		inv.MountItem ( inv.GetItemByCategory( 'hair', false ) );		
	}
	
	event OnDetach( parentEntity : CEntity )
	{
		var inv : CInventoryComponent;
		inv = ( (CGameplayEntity) parentEntity ).GetInventory();
		
		if ( parentEntity != thePlayer || thePlayer.isNotGeralt ) return false;
		
		// No sword - no belt
		if ( inv.GetItemByCategory('steelsword') == GetInvalidUniqueId() && inv.GetItemByCategory('silversword') == GetInvalidUniqueId() )
		{
			//inv.UnmountItem( inv.GetItemId( 'belt_jacket' ), true );
		}
		else
		{
			//inv.MountItem( inv.GetItemId( 'belt_nojacket' ), false );
		}
	}
}
