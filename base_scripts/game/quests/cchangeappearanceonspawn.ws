//Klasa pozwalajaca na zmiane appearancu obiektu podczas spawnu

class CChangeAppearanceOnSpawn extends CGameplayEntity
{
	editable var appearance : string;
	editable var requiredFact : string;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if (FactsDoesExist(requiredFact))
		{
			this.ApplyAppearance(appearance);
		}
	}
}