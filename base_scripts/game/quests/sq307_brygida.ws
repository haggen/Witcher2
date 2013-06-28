class CNpcWithHealthbar extends CNewNPC
{
	saved var healthbarIsActive : bool;
	saved var healthbarNum : int;
	
	event OnDeath()
	{
		theHud.ArenaFollowersGuiEnabled( false );
		super.OnDeath();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var arguments : array<CFlashValueScript>;
		
		if( healthbarIsActive )
		{
			arguments.PushBack(FlashValueFromBoolean(true));
			arguments.PushBack(FlashValueFromBoolean(true));
			arguments.PushBack(FlashValueFromBoolean(false));
			arguments.PushBack(FlashValueFromBoolean(false));
			arguments.PushBack(FlashValueFromBoolean(false));
			
			theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);
			
			theHud.ArenaFollowersGuiEnabled( true );
			theHud.ArenaFollowersGuiName( GetDisplayName() );
			theHud.ArenaFollowersGuiHealth( 100 );
			theHud.ArenaFollowersGuiPicture( healthbarNum );
		}
		
		super.OnSpawned( spawnData );
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

quest function QEnableFollowerHealthbar( targetActorTag : name, enable : bool, imgNum : int )
{
	var npc : CNpcWithHealthbar;
	var arguments : array<CFlashValueScript>;
	npc = (CNpcWithHealthbar)theGame.GetNPCByTag(targetActorTag);
	
	arguments.PushBack(FlashValueFromBoolean(true));
	arguments.PushBack(FlashValueFromBoolean(true));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	
	theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);
	
	theHud.ArenaFollowersGuiEnabled( enable );
	theHud.ArenaFollowersGuiName( npc.GetDisplayName() );
	theHud.ArenaFollowersGuiHealth( 100 );
	theHud.ArenaFollowersGuiPicture( imgNum );
	
	npc.healthbarIsActive = enable;
	npc.healthbarNum = imgNum;
}
