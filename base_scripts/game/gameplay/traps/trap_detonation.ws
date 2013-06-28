// Funkcja sprawdzaj¹ca, czy ktoœ wszed³ w trigger pu³apki.

//class CTrap extends CActor
//{
/*
	latent brix function DetonateOnTrigger (trap_entity : CEntity, 
										trap_name : CName, 
										who_stepped : CActor, 
										range : Float, 
										working_effect : CEntityTemplate, 
										out explosion : CEntity) : bool
	{
		var damage : float;
		var damage_min : float;
		var damage_max : float;
		var casulties : array<CActor>;
		//var item_index : int;
		var trapId : SItemUniqueId;
		var i : int;
		var size : int;
		var explosion_effect : CEntity;
		var tags : array <name>;
		var is_monster : bool;
		var inventory : CInventoryComponent;
		
	// okreœlam zmienne	
	
	inventory = (CInventoryComponent)trap_entity.GetComponentByClassName( 'CInventoryComponent' );
	trapId = inventory.GetItemId(trap_name);
	
	damage_min = inventory.GetItemAttributeAdditive( trapId , 'damage_min' );
	damage_max = inventory.GetItemAttributeAdditive( trapId , 'damage_max' );
	damage = RandRangeF( damage_min , damage_max );	

	//jeœli potwór wszed³ w pu³apkê
	
	is_monster = false;
	
	tags = who_stepped.GetTags();
		for ( i = 0; i < tags.Size(); i += 1 )
			{
				if ( tags[i] == 'monster' ) is_monster = true;
			}
	
	if ( is_monster )
		{
		trap_entity.GetComponent ("trigger pulapki").SetEnabled(false);
		explosion = theGame.CreateEntity( working_effect, trap_entity.GetWorldPosition(), trap_entity.GetWorldRotation() );
		GetActorsInRange( casulties, range, 'monster', trap_entity );
		size = casulties.Size();
		
		Log("W pu³apkê wlaz³ " + who_stepped);
		Log("To potwór - odpalam pu³apkê");
		Log("Zaczytuje pu³apke " + UniqueIdToString( trapId ) );
		Log("Iloœæ ofiar pu³apki to " +size);
		Log("Wybuchnie " + trap_entity);
		Log("PULAPKA (dmgmin " + damage_min + "; dmgmax " + damage_max + ") - zadaje damage = " + damage);
		
			// sprawdzamy, ile potworów jest w zasiêgu pu³apki i nak³adamy im damage

		for ( i = 0; i < size; i += 1 )
			{

				casulties[i].DecreaseHealth( damage, true );	
				
				Log("Nak³adam obra¿enia na" +casulties[i]);

			}	
			// robimy rzeczy z pu³apk¹
	
				trap_entity.Destroy();
					
				Sleep(10.f);
	
				explosion.Destroy();
		}	

	// a jak to nie potwór to:		
		
	else
		{
		return false;
		Log("To nie potwór");
		}
		
	}*/
//}