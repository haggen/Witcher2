

class CRiszon extends CNewNPC
{
	private saved var m_isFightStarted : bool;
	default m_isFightStarted = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		if ( spawnData.restored )
		{
			if ( m_isFightStarted )
			{
				theHud.HudTargetActorEx( this, true );
				theHud.m_hud.SetBossName( GetDisplayName() );
				theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
			}
		}
	}
	function StartBossFight()
	{
		thePlayer.SetBigBossFight( true );
		theHud.HudTargetActorEx( this, true );
		theHud.m_hud.SetBossName( GetDisplayName() );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
		m_isFightStarted = true;
	}
	
	function EndBossFight()
	{
		thePlayer.SetBigBossFight( false );
		theHud.m_hud.HideBossHealth();
		m_isFightStarted = false;
	}
	
	private function HitDamage( hitParams : HitParams )
	{
		super.HitDamage( hitParams );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}
	
	private function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{
		super.HitPosition( hitPosition, attackType, damage, lethal, source, forceHitEvent, rangedAttack, magicAttack );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}
	
	function IsBoss() : bool
	{
		return true;
	}
}

quest latent function QStartRiszonBossfight()
{
	var lethoBossFightIdx		: int = FactsQuerySum( "letho_q106_ending_entry" );
	var lethoBossFightSaveIdx	: int = FactsQuerySum( "letho_boss_fight_save_idx" );
	
	// ------------------- PATCH0 -------------------
		//  save the game before the combats
		if ( lethoBossFightIdx < 1 )
		{
			// this is the very first boss fight with letho
			if ( lethoBossFightSaveIdx < 1 )
			{
				// allow to save only if no save from this
				// stage was previously made - and we can tell from
				// the contents of the facts db.
				// If there was no save, immediately BEFORE saving
				// the game add a proper fact to the db, so that the save
				// contains this fact and doesn't allow to make another
				// save when the game is loaded and the combat mode kicks in
				FactsAdd( "letho_boss_fight_save_idx", 1 );
				theGame.SaveGame( true );
			}
			else
			{
				// this means that the the player is fighting
				// his first boss fight with Letho, but the save was already made - don't save the game
			}
		}
		else
		{
			// this is the very last boss fight with letho
			if ( lethoBossFightSaveIdx < 2 )
			{
				// same thing as with the first boss fight
				FactsAdd( "letho_boss_fight_save_idx", 1 );
				theGame.SaveGame( true );
			}
		}
		// ------------------- PATCH0 -------------------
			
	((CRiszon)theGame.GetEntityByTag( 'Riszon' )).StartBossFight();
}

quest function QEndRiszonBossFight()
{
	((CRiszon)theGame.GetEntityByTag( 'Riszon' )).EndBossFight();
}