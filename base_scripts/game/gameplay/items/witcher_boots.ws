/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher jacket
/** Copyright © 2010
/***********************************************************************/
class CWitcheBootsDark extends CWitcherBoots
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
class CWitcherBoots extends CItemEntity
{	
	function UpdatePantsState()
	{
		var inv : CInventoryComponent;
		var item : SItemUniqueId;
		var itemEntity : CItemEntity;
		var pantsEntity : CWitcherPants;
		var parentEntity : CEntity = GetParentEntity();
		
		inv = ( (CGameplayEntity) parentEntity ).GetInventory();
		
		item = inv.GetItemByCategory( 'pants', true, true );
		if ( item != GetInvalidUniqueId() )
		{
			itemEntity = inv.GetItemEntityUnsafe( item );
			if ( itemEntity )
			{
				pantsEntity = ( CWitcherPants ) itemEntity;
				if ( pantsEntity )
				{
					pantsEntity.UpdatePantsLength();
				}
			}
		}
	}

	event OnMount( parentEntity : CEntity, slot : name )
	{
		UpdatePantsState();
	}
	
	event OnDetach( parentEntity : CEntity )
	{
		UpdatePantsState();
	}
}