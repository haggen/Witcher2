/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009 m6a6t6i's Early Day R&D Home Center
/***********************************************************************/

// ------------------------------------------------------------------------
//                                 LOOT 
// ------------------------------------------------------------------------

// wypelnia inventory component entity - np. skrzynie
brix function FillRandomLoot( entity : CEntity, loot_table : string)
{
	var loottable : C2dArray;
	var i : int;
	var count : int;
	var inv : CInventoryComponent;
	var propability : int;
	var quantity : int;
	var quantity_min : int;
	var quantity_max : int;
	var always_mount : int;
	
	loottable = LoadCSV("globals/loot tables/" + loot_table + ".csv");	
	inv = (CInventoryComponent)entity.GetComponentByClassName( 'CInventoryComponent' );
	
	if ( inv.GetItemCount() == 0 )
	{
		for ( i=0; i<loottable.GetNumRows(); i+=1 )
		{
			always_mount = (int) loottable.GetValueAt(6, i);
			propability = (int) loottable.GetValueAt(4, i);
			
			if (RandF() * 100 < propability)
			{
				quantity_min = (int) loottable.GetValueAt(2, i);
				quantity_max = (int) loottable.GetValueAt(3, i);
				quantity = (int) RandRangeF(quantity_min, quantity_max);

				inv.AddItem(StringToName(loottable.GetValueAt(1, i) ), quantity);
				
				if (always_mount > 0) 
				{
					inv.MountItem(inv.GetItemId( StringToName(loottable.GetValueAt(1, i)) ));
				}
			}
		}
	}
}

// wypelnia inventory component actora - np. npc
function FillRandomLootActor( actor : CActor, loot_table : string)
{
	var loottable : C2dArray;
	var i : int;
	var count : int;
	var inv : CInventoryComponent;
	var propability : int;
	var quantity : int;
	var quantity_min : int;
	var quantity_max : int;
	var always_mount : int;
	
	loottable = LoadCSV("globals/loot tables/" + loot_table + ".csv");	
	inv = actor.GetInventory();
	
	for ( i=0; i<loottable.GetNumRows(); i+=1 )
	{
		always_mount = (int) loottable.GetValueAt(6, i);
		propability = (int) loottable.GetValueAt(4, i);
		
		if (RandF() * 100 < propability)
		{
			quantity_min = (int) loottable.GetValueAt(2, i);
			quantity_max = (int) loottable.GetValueAt(3, i);
			quantity = (int) RandRangeF(quantity_min, quantity_max);

			inv.AddItem(StringToName(loottable.GetValueAt(1, i) ), quantity);
			//Log(" ---> adding item name " + StringToName(loottable.GetValueAt(1, i) ));
			
			if (always_mount > 0) 
			{
				//actor.EquipItem(inv.GetItemId( StringToName(loottable.GetValueAt(1, i)) ));
				inv.MountItem(inv.GetItemId( StringToName(loottable.GetValueAt(1, i)) ));
			}
		}
	}
}