//Play effect if Fact

class CPlayEffectIfFactExist extends CEffectEntity
{
	editable var requiredFact : string;
	editable var effectName : name;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if (FactsQuerySum(requiredFact) >= 1)
		{
			PlayEffect( effectName, this );
		}
	}
}