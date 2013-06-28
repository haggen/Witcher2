class CInterventionTrigger extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer && !thePlayer.IsInCombat() && FactsDoesExist( "gameplay_catch_by_guard" ) )
		{
			FactsAdd( "trigger_spotted_cutscene", 1 );
		}
	}
}