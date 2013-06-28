/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher jacket
/** Copyright © 2010
/***********************************************************************/
class CWitcherPantsDark extends CWitcherPants
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
class CWitcherPants extends CItemEntity
{
	function UpdatePantsLength()
	{
		var inv : CInventoryComponent;
		var item : SItemUniqueId;
		var parentEntity : CEntity = GetParentEntity();
		
		inv = ( (CGameplayEntity) parentEntity ).GetInventory();
		
		item = inv.GetItemByCategory( 'boots', true, true );
		
		if ( item != GetInvalidUniqueId() )
		{
			// Has boots, set pantlegs to short
			this.SetBodyPartState('pants', 'Default');
		} 
		else
		{	
			// Has no boots, set pantlegs to long
			this.SetBodyPartState('pants', 'no_shoes');
		}
	}
	
	event OnMount( parentEntity : CEntity, slot : name )
	{
		UpdatePantsLength();
	}
	
	event OnDetach( parentEntity : CEntity )
	{
	}
}
