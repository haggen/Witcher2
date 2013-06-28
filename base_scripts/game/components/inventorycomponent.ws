/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory component exports
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

	
// Is item a weapon.
import function IsItemWeapon( item : name ) : bool;
	
// Is item lethal.
import function IsItemLethal( item : name ) : bool;

// Global loot chances scaling factor (value stored in User.ini)
import function SetLootChancesScale( scale : float );
import function GetLootChancesScale() : float;

/////////////////////////////////////////////
// SItemUniqueId
/////////////////////////////////////////////

import struct SItemUniqueId { };

// operator( SItemUniqueId == SItemUniqueId ) : bool;
// operator( SItemUniqueId != SItemUniqueId ) : bool;

// Returns invalid unique id - for comparision
function GetInvalidUniqueId() : SItemUniqueId
{
	var invalidUniqueId : SItemUniqueId;
	return invalidUniqueId;
}

/* imported enum
enum EInventoryItemClass
{
	InventoryItemClass_Common	= 1,
	InventoryItemClass_Magic	= 2,
	InventoryItemClass_Rare		= 3,
	InventoryItemClass_Epic		= 4,
};*/

// DM: try not to use such functions, we will see if they are really needed later :)
// Convert unique id to string format
import function UniqueIdToString( itemId : SItemUniqueId ) : string;
// Convert name to unique id
import function NameToUniqueId( itemId : name ) : SItemUniqueId;

import struct SItemIngredient 
{
	import var itemName : name;
	import var quantity : int;
}; 

/////////////////////////////////////////////
// CItemEntity
/////////////////////////////////////////////

import class CItemEntity extends CEntity
{
	// Get entity item is attached to
	import final function GetParentEntity() : CEntity;

	event OnMount( parentEntity : CEntity, slot : name ) {}
	event OnDrop( parentEntity : CEntity ) {}
	event OnDetach( parentEntity : CEntity ) {}
	function IsWitcherSecondaryWeapon() : bool
	{
		return false;
	}
}

/////////////////////////////////////////////
// CInventoryComponent
/////////////////////////////////////////////

import class CInventoryComponent extends CComponent
{
	// ---------------------------------------------------------------------------
	// Items management
	// ---------------------------------------------------------------------------
	
	// Copy default slot abilities to items in inventory.
	import final function FillItems();
	
	// Check if item index is valid.
	import final function IsIdValid( itemId : SItemUniqueId ) : bool;
	
	// Returns all names of items stored in the inventory instance.
	import final function GetItemsNames() : array< name >;
	
	// Get all items in form of unique id array
	import final function GetAllItems( out items : array< SItemUniqueId > );
	
	// Get all items with given tag in form of unique id array
	import final function GetItemsByTag( tag : name ) : array< SItemUniqueId >;
	
	// Get all items of given category in form of unique id array
	import final function GetItemsByCategory( tag : name ) : array< SItemUniqueId >;
	
	// Get number of items
	import final function GetItemCount() : int;	
	
	// Get item with given index
	import final function GetItemId( item : name ) : SItemUniqueId;
	
	// Get item name
	import final function GetItemName( itemId : SItemUniqueId ) : name;
	
	// Get item category
	import final function GetItemCategory( itemId : SItemUniqueId ) : name;
	
	// Get item class
	import final function GetItemClass( itemId : SItemUniqueId ) : EInventoryItemClass;
	
	// Get item type flags
	import final function GetItemTypeFlags( itemId : SItemUniqueId ) : int;
	
	// Get tags of given item, returns false if index is not valid
	import final function GetItemTags( itemId : SItemUniqueId, out tags : array<name> ) : bool;
	
	// Get tags of given item, returns false if there is no such item
	import final function GetItemNameTags( itemName : name, out tags : array<name> ) : bool;
	
	// Get list of ingredients list held by this item
	import final function GetItemIngredients( itemId : SItemUniqueId, out ingredients : array< SItemIngredient > ) : bool;
	
	// Get name of the item that can be crafted from given one
	import final function GetCraftedItemName( itemId : SItemUniqueId ) : name;
	
	// Get item quantity by index
	import final function GetItemQuantity( itemId : SItemUniqueId ) : int;
	
	// Get item quantity by name
	import final function GetItemQuantityByName( itemName : name ) : int;
	
	// Check if the item has given tag
	import final function ItemHasTag( itemId : SItemUniqueId, tag : name ) : bool;
	
	// Get any item with given tag, returns invalid index (-1) if not found
	import final function GetItemByTag( tag : name ) : SItemUniqueId;
	
	// Get item for which we have given itemEntity spawned
	import final function GetItemByItemEntity( itemEntity : CItemEntity ) : SItemUniqueId;

	// Get attribute value from item.
	import final function GetItemAttributeAdditive( itemId : SItemUniqueId, attrName : name ) : float;

	import final function GetItemNameAttributeAdditive( itemName : name, attrName : name ) : float;
	
	// Get attribute value from item.
	import final function GetItemAttributeValues( itemId : SItemUniqueId, attrName : name, out valAdditive : float,
		out valMultiplicative : float, out displayPercMul : bool, out displayPercAdd : bool );
	
	import final function GetItemNameAttributeValues( itemName : name, attrName : name, out valAdditive : float,
		out valMultiplicative : float, out displayPercMul : bool, out displayPercAdd : bool );
	
	// Get attribute names from item.
	import final function GetItemAttributes( itemId : SItemUniqueId, out attributes : array<name> );
	
	// Get attribute names from item.
	import final function GetItemAttributesByType( itemId : SItemUniqueId, attrType : name, out attributes : array<name> );
	
	import final function GetItemNameAttributesByType( itemName : name, attrType : name, out attributes : array<name> );
	
	// Get abilities from item
	import final function GetItemAbilities( itemId : SItemUniqueId, out abilities : array<name> );
	
	// Get item currently bound to given category
	import final function GetItemByCategory( category : name, optional mountOnly : bool /*=true*/, optional ignoreDefaultItem : bool /*=false*/ ): SItemUniqueId;
	
	import final function GetDefaultItemForCategory( category : name ) : SItemUniqueId;
	
	// Transfer one item to other inventory ( holsters items if needed )
	import final function GiveItem( otherInventory : CInventoryComponent, itemId : SItemUniqueId, optional quantity : int ) : SItemUniqueId;
	
	// If there is specified item in inventory
	import final function HasItem( item : name ) : bool;
	
	// Add specified item to inventory
	import final function AddItem( item : name, optional quantity : int, optional informGui : bool /* = true */ ) : SItemUniqueId;
	
	// Sets quantity of given item
	import final function SetItemQuantity( item : name, quantity : int ) : bool;
	
	// Check number of enhancement slot in item
	import final function GetItemEnhancementSlotsCount( itemId : SItemUniqueId ) : int;
	 
	// Get names from item's extension slots
	import final function GetItemEnhancementItems( itemId : SItemUniqueId, out itemNames : array<name> );
	
	// Get names from item's extension slots
	import final function GetItemEnhancementCount( itemId : SItemUniqueId ) : int;
	
	// Convert extension item into enhanced item's slot item :)
	import final function EnhanceItem( ehnancedItemId : SItemUniqueId, extensionItemId : SItemUniqueId ) : bool;
	
	// Remove extension from item
	import final function RemoveItemEnhancementByIndex( enhancedItemId : SItemUniqueId, slotIndex : int ) : bool;
	import final function RemoveItemEnhancementByName( enhancedItemId : SItemUniqueId, itemName : name ) : bool;
	
	// Remove item with specified index from inventory
	import final function RemoveItem( itemId : SItemUniqueId, optional quantity : int ) : bool;
	
	// Removes all items from inventory
	import final function RemoveAllItems();
	
	// USE WITH EXTREME CAUTION / ASK DREY
	import final function GetItemEntityUnsafe( itemId : SItemUniqueId ) : CItemEntity;
	
	// Spawn deployment item entity
	import final function GetDeploymentItemEntity( itemId : SItemUniqueId, optional position : Vector, optional rotation : EulerAngles, optional allocateIdTag : bool ) : CEntity;
	
	// Add specified item to inventory
	import final function MountItem( itemId : SItemUniqueId, optional toHand : bool ) : bool;
	
	// Add specified item to inventory
	import final function UnmountItem( itemId : SItemUniqueId, optional destroyEntity : bool ) : bool;
	
	// Check if specified item is mounted to equip bone
	import final function IsItemMounted(  itemId : SItemUniqueId ) : bool;	
	
	// Check if specified item is held
	import final function IsItemHeld(  itemId : SItemUniqueId ) : bool;	
	
	// Drop item
	import final function DropItem( itemId : SItemUniqueId, optional removeFromInv /*=false*/ : bool );
	
	// Returns the name of a hold slot defined for the item
	import final function GetItemHoldSlot( itemId : SItemUniqueId ) : name;
	
	// Play effect on item
	import final function PlayItemEffect( itemId : SItemUniqueId, effectName : name );
	import final function StopItemEffect( itemId : SItemUniqueId, effectName : name );
	
	// Throw away given item to a spawned container, returns true if succeded
	import final function ThrowAwayItem( itemId : SItemUniqueId, optional quantity : int ) : bool;
	
	// Throw away all items, returns entity created
	import final function ThrowAwayAllItems() : CEntity;
	
	// Throw away items, excluding those with any of given tags, returns entity created
	import final function ThrowAwayItemsFiltered( excludedTags : array< name > ) : CEntity;
	
	// Destroy item
	import final function DespawnItem( itemId : SItemUniqueId );
	
	// Despawn all items
	import final function DespawnAllItems();	
	
	// Spawn all items
	import final function SpawnAllItems();	
	
	// ---------------------------------------------------------------------------
	// Weapons
	// ---------------------------------------------------------------------------
	
	// Get first weapon index
	import final function GetFirstWeaponId() : SItemUniqueId;

	// Get first lethal weapon index
	import final function GetFirstLethalWeaponId() : SItemUniqueId;

	// Get first non-lethal weapon index
	import final function GetFirstNonLethalWeaponId() : SItemUniqueId;
	
	// ---------------------------------------------------------------------------
	// Debug
	// ---------------------------------------------------------------------------
	
	// Print contents of inventory
	import final function PrintInfo();
	
	// Test loot cache against loot definition. Add items if their respawn time elapsed
	import final function UpdateLoot();
	
}

// Do not remove! Used by C++ SItemDefinition::RecalculateTypeFlags()
function CalculateItemTypeFlags( category : name, itemTags : array< name > ) : int
{
	var mask : int = 0;    
	
	if ( category == 'armor' )
	{
		mask = mask | 0x00010011; // armor, jacket slot
	}
	if ( category == 'gloves' )
	{
		mask = mask | 0x00010021; // armor, gloves slot
	}
	if ( category == 'pants' )
	{
		mask = mask | 0x00010041; // armor, pants slot
	}
	if ( category == 'boots' )
	{
		mask = mask | 0x00010081; // armor, boots slot
	}
	if ( itemTags.Contains(  'SortTypeArmorUpgrade' ) )
	{
		mask = mask | 0x00020001;
	}
	if ( category == 'ranged' )
	{
		mask = mask | 0x00040801; // range, range slot
	}
	if ( category == 'rangedweapon' )
	{
		mask = mask | 0x00040801; // range, range slot
	}
	if ( category == 'silversword' )
	{
		mask = mask | 0x00080201; // weapon, silver slot
	}
	if ( category == 'steelsword'  )
	{
		mask = mask | 0x00080401; // weapon, steel slot
	}
	if ( itemTags.Contains(  'SortTypeWeaponUpgrade' ) )
	{
		mask = mask | 0x00100001;
	}
	if ( itemTags.Contains(  'SortTypePetard' ) )
	{
		mask = mask | 0x00201001; // trap, quick slot
	}
	if ( itemTags.Contains(  'SortTypeTrap' ) )
	{
		mask = mask | 0x00401001; // trap, quick slot
	}
	if ( itemTags.Contains(  'SortTypeIngridient' ) )
	{
		if ( itemTags.Contains( 'AlchemyIngridient' ) )
			mask = mask | 0x00800001;
		if ( itemTags.Contains( 'CraftingIngridient' ) )
			mask = mask | 0x01000001;
	}
	if ( itemTags.Contains(  'SortTypeSchematic' ) )
	{
		mask = mask | 0x02000001;
	}
	if ( itemTags.Contains(  'SortTypeLure' ) )
	{
		mask = mask | 0x04000001;
	}
	if ( itemTags.Contains(  'SortTypePotion' ) )
	{
		mask = mask | 0x08000001;
	}
	if ( itemTags.Contains(  'SortTypeBook' ) )
	{
		mask = mask | 0x10000001;
	}
	if ( itemTags.Contains(  'SortTypeTrophy' ) )
	{
		mask = mask | 0x20000101; // trophy, trophy slot
	}
	if ( itemTags.Contains(  'SortTypeSkillUpgrade' ) ) // mutagen
	{
		mask = mask | 0x40000001;
	}
	if ( itemTags.Contains(  'SortTypeQuest' ) )
	{	
		mask = mask | 0x00000003;
	}
	if ( itemTags.Contains(  'SortTypeOther' ) )
	{
		mask = mask | 0x00004001;
	}
	
	// upgrade items that do not require slots
	if ( itemTags.Contains( 'Oil' ) )
	{	
		mask = mask | 0x00002000;
	}

	// error
	if ( mask == 0 )
	{
		return 0x00000001;
	}
	
	// examine item
	if ( itemTags.Contains('Usable') )
	{
		mask = mask | 0x00000008;
	}
	
	// items that can be put into quick slot
	if ( itemTags.Contains('QuickSlot') )
	{
		mask = mask | 0x00001000;
	}
	
	return mask;
}

//////////////////////////////////////////////////////////////////////////

	function Q302TransferInvToChest( fromActor : CPlayer, toActor : CContainer )
	{
		var i : int;				
		var allItems : array< SItemUniqueId >;
		var fromInv, toInv : CInventoryComponent;
		
		fromInv = fromActor.GetInventory();
		toInv   = toActor.GetInventory();
		
		fromInv.GetAllItems( allItems );
		
		Log("===========================[ TRANSFE ALL ITEMS ");
		
		for ( i = 0; i < allItems.Size(); i += 1 )
		{
			if ( !fromInv.ItemHasTag(allItems[i], 'NoShow') && !fromInv.ItemHasTag(allItems[i], 'Quest') )
			{	
				Log("Transfering item " + fromInv.GetItemName( allItems[i] ) + " from " + fromActor.GetName() + " to " + toActor.GetName() );
				//if ( allItems[i] == fromInv.GetItemByCategory('steelsword') || allItems[i] == fromInv.GetItemByCategory('silversword') || allItems[i] == fromInv.GetItemByCategory('armor') )
				//{
					fromInv.UnmountItem( allItems[i], true );
				//}
				fromInv.GiveItem( toInv, allItems[i], fromInv.GetItemQuantity( allItems[i] ) );
			}
		}
		Log("==============================================");
	}
	
	function Q302TransferFromChestToGeralt( fromActor : CContainer, toActor : CPlayer )
	{
		var i : int;				
		var allItems : array< SItemUniqueId >;
		var fromInv, toInv : CInventoryComponent;
		
		fromInv = fromActor.GetInventory();
		toInv   = toActor.GetInventory();
		
		fromInv.GetAllItems( allItems );
		
		Log("===========================[ TRANSFE ALL ITEMS ");
		
		for ( i = 0; i < allItems.Size(); i += 1 )
		{
			if ( !fromInv.ItemHasTag(allItems[i], 'NoShow') && !fromInv.ItemHasTag(allItems[i], 'NoDrop') )
			{	
				Log("Transfering item " + fromInv.GetItemName( allItems[i] ) + " from " + fromActor.GetName() + " to " + toActor.GetName() );
				/*if ( allItems[i] == fromInv.GetItemByCategory('steelsword') || allItems[i] == fromInv.GetItemByCategory('silversword') || allItems[i] == fromInv.GetItemByCategory('armor') )
				{
					fromInv.UnmountItem( allItems[i], false);
				}*/
				fromInv.GiveItem( toInv, allItems[i], fromInv.GetItemQuantity( allItems[i] ) );
			}
		}
		Log("==============================================");
	}
