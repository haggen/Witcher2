//Raise event if Fact

class CRaiseEventIfFactExist extends CEffectEntity
{
	editable var requiredFact : string;
	editable var eventName : name;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if (FactsQuerySum(requiredFact) >= 1)
		{
			this.RaiseEvent( eventName );
		}
	}
}