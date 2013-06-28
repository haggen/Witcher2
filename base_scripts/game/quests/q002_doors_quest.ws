class CDoorQuest extends CDoor
{
	event OnDoorOpened( isPlayer, fromInside : bool )
	{
		FactsAdd("q002_doors_opened", 1);
		super.OnDoorOpened( isPlayer, fromInside );	
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		FactsAdd("q002_expl_ended", 1);
		super.OnAreaExit(area, activator);
	}
	
	// Event called when we do not have a key
	event OnDoorNoKey()
	{
		if(!FactsDoesExist("q002_i_have_key")) theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "You need a key to open this door!" ) );
	}
	
	// Event called when we do not have a valid DB fact to open this door
	event OnDoorNoFact()
	{
		if(!FactsDoesExist("q002_i_have_key")) theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "You cannot open this door right now!" ) );
	}
	
	// Event called when doors are locked and cannot be opened by fact or key
	event OnDoorNoWayToOpen()
	{
		if(!FactsDoesExist("q002_i_have_key")) theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "You cannot open this door right now!" ) );
	}

	// Event called when doors are unlocked
	event OnDoorUnlocked()
	{
		if(!FactsDoesExist("q002_i_have_key")) theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "Door unlocked using key." ) );
	}	
		
}