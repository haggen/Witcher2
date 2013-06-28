exec function GiveTraps()
{
	thePlayer.GetInventory().AddItem('Explosive Trap', 30);
	thePlayer.GetInventory().AddItem('Crippling Trap', 30);
	thePlayer.GetInventory().AddItem('Freezing Trap', 30);
	thePlayer.GetInventory().AddItem('Rage Trap', 30);
	thePlayer.GetInventory().AddItem('Nekker Stun Trap', 30);
	thePlayer.GetInventory().AddItem('Harpy Bait Trap', 10);
	thePlayer.GetInventory().AddItem('Animal Trap', 10);
}

exec function AddThrown()
{
	thePlayer.GetInventory().AddItem('Rusty Balanced Dagger', 30);
}

exec function AddLures()
{
	thePlayer.GetInventory().AddItem('Thumper', 30);
	thePlayer.GetInventory().AddItem('Rotting Meat', 30);
	thePlayer.GetInventory().AddItem('Shiny Trinket', 30);
	thePlayer.GetInventory().AddItem('Endriag Gland Extract', 30);
	thePlayer.GetInventory().AddItem('Phosphorescent Crystal', 30);
}
/*exec function Immortal( flag : int )
{
	if( flag == 0 )
	{
		thePlayer.SetInvulnerable( false );
		Log("GodeMode is OFF");
	}
	else if( flag == 1 )
	{
		thePlayer.SetInvulnerable( true );
		Log("GodeMode is ON");
	}
}*/

exec function EncounterSwitch ( flag : int )
{
	var area : CEncounter;
		
	area = (CEncounter)theGame.GetNodeByTag( 'test' );
		
	if ( flag == 1 )
	{
		area.SetEnableState( true );
		Log( "UAKTYWNIAM ENCOUNTER AREA " +area );
	}
	else if (flag == 0 )
	{	
		area.SetEnableState( false );
		Log( "DEZAKTYWUJE ENCOUNTER AREA " +area );
	}	
}	