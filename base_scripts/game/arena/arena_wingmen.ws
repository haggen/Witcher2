class CArenaWingman extends CNewNPC
{
	event OnDeath()
	{
		if(HasTag('wingman_dwarf'))
		{
			theGame.GetArenaManager().SetWinFact("");
			FactsRemove("arena_dwarf");
			FactsRemove("dwarf_win");
			FactsAdd("dwarf_fail", 1);
		}
		else if(HasTag('wingman_knight'))
		{
			theGame.GetArenaManager().SetWinFact("");
			FactsRemove("arena_knight");
			FactsRemove("knight_win");
			FactsAdd("knight_fail", 1);
		}
		else if(HasTag('wingman_sorceress'))
		{
			theGame.GetArenaManager().SetWinFact("");
			FactsRemove("arena_mage");
			FactsRemove("mage_win");
			FactsAdd("mage_fail", 1);
		}
		theHud.ArenaFollowersGuiEnabled( false );
		super.OnDeath();
	}
	function SetHealth( value : float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData  )
	{
		var healthPercent : float;
		value = MinF( MaxF( value, 0.f ), initialHealth );
		if ( health != value || value == 0.0 )
		{
			health = value;
			healthPercent = 100.0f*(GetHealth()/GetInitialHealth());
			theHud.ArenaFollowersGuiHealth( RoundF(healthPercent) );
			DeathCheck( lethal, attacker, deathData );
	
			if ( ! IsBoss() && this == thePlayer.GetEnemy() )
			{		
				theHud.m_hud.SetNPCHealthPercent( 100 * health / initialHealth );
			}
		}
	}
}