// Funkcja sprawdzaj�ca, czy kto� wszed� w trigger pu�apki.

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
		
	// okre�lam zmienne	
	
	inventory = (CInventoryComponent)trap_entity.GetComponentByClassName( 'CInventoryComponent' );
	trapId = inventory.GetItemId(trap_name);
	
	damage_min = inventory.GetItemAttributeAdditive( trapId , 'damage_min' );
	damage_max = inventory.GetItemAttributeAdditive( trapId , 'damage_max' );
	damage = RandRangeF( damage_min , damage_max );	

	//je�li potw�r wszed� w pu�apk�
	
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
		
		Log("W pu�apk� wlaz� " + who_stepped);
		Log("To potw�r - odpalam pu�apk�");
		Log("Zaczytuje pu�apke " + UniqueIdToString( trapId ) );
		Log("Ilo�� ofiar pu�apki to " +size);
		Log("Wybuchnie " + trap_entity);
		Log("PULAPKA (dmgmin " + damage_min + "; dmgmax " + damage_max + ") - zadaje damage = " + damage);
		
			// sprawdzamy, ile potwor�w jest w zasi�gu pu�apki i nak�adamy im damage

		for ( i = 0; i < size; i += 1 )
			{

				casulties[i].DecreaseHealth( damage, true );	
				
				Log("Nak�adam obra�enia na" +casulties[i]);

			}	
			// robimy rzeczy z pu�apk�
	
				trap_entity.Destroy();
					
				Sleep(10.f);
	
				explosion.Destroy();
		}	

	// a jak to nie potw�r to:		
		
	else
		{
		return false;
		Log("To nie potw�r");
		}
		
	}*/
//}