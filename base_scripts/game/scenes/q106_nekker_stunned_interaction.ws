// Klasa obslugujaca interakcje ogluszonego nekkera w q106

class q106_nekker_interaction extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var component : CComponent;
		component = GetComponent( "q106_interaction" );
		component.SetEnabled( true );
	}

	event OnInteraction( actionName : name, activator : CEntity )
	{
			var component : CComponent;
			component = GetComponent( "q106_interaction" );
			component.SetEnabled( false );
			FactsAdd( "q106_stunning_nekker_phase", -1);
			FactsAdd( "q106_stunned_nekker_ready", 1);
	}
}
