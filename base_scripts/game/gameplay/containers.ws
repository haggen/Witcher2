
// ------------------------------------------------------------------------
//                                 CONTAINERS
// ------------------------------------------------------------------------



brix function GenerateNewLootContent( 	entity : CEntity, loot_table : string, last_check : int, out store_last : int, out spawned : bool	)
{
	var loottable : C2dArray;
	var inv : CInventoryComponent;
	var respawn_time : int;
	var next_spawn : int;
	var current_check : int;
	var current_time : GameTime;
	var item : name;
	var h : int;
	var d : int;
		
	loottable = LoadCSV("globals/loot tables/" + loot_table + ".csv");	
	inv = (CInventoryComponent)entity.GetComponentByClassName( 'CInventoryComponent' );
	item = ( StringToName(loottable.GetValueAt(1, 0)) );
	current_time = GameTimeCreate();
	respawn_time = (int) loottable.GetValueAt(5, 0);
			
// pierwsze spawnowanie lootu 

		if ( last_check == -1 )
		{
			SpawnNewLoot( entity, loot_table, spawned );
			current_check = GameTimeHours( current_time ) + GameTimeDays( current_time)*24;
			store_last = current_check;
			next_spawn = respawn_time - current_check + last_check + 1;
		}
		
// kolejne spawnowanie lootu
		else 
		{
			current_check = GameTimeHours( current_time ) + GameTimeDays( current_time)*24;
						
			if ( respawn_time <= current_check - last_check )
			{
				SpawnNewLoot( entity, loot_table, spawned );
				next_spawn = respawn_time - current_check + last_check;
				store_last = current_check; 
			}
			else
			{
				next_spawn = respawn_time - current_check + last_check;
			}
		}
}		
			
function SpawnNewLoot( entity : CEntity, loot_table : string, out spawned : bool)
{
	var loottable : C2dArray;
	var i : int;
	var count : int;
	var inv : CInventoryComponent;
	var propability : int;
	var quantity : int;
	var quantity_min : int;
	var quantity_max : int;
	var respawn_time : int;
	
	loottable = LoadCSV("globals/loot tables/" + loot_table + ".csv");	
	inv = (CInventoryComponent)entity.GetComponentByClassName( 'CInventoryComponent' );
	
	for ( i=0; i<loottable.GetNumRows(); i+=1 )
		{
			quantity_min = (int) loottable.GetValueAt(2, i);
			quantity_max = (int) loottable.GetValueAt(3, i);
			quantity = (int) RandRangeF(quantity_min, quantity_max);
			propability = (int) loottable.GetValueAt(4, i);
			for ( count=0; count<quantity; count+=1 )
				{
				if (RandF() * 100 < propability)
					{
						inv.AddItem(StringToName(loottable.GetValueAt(1, i)));
						spawned = true;
						entity.GetComponent("Gather herbs").SetEnabled (true);
					}
				}
		}
}
