class CGuardNPC extends CNewNPC
{
	private var ambushZone	: CComponent;
	private var killZone	: CComponent;
	private var timeout		: float;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		this.unconciousTime = 0;
		ambushZone = this.GetComponent('ambush_zone');
		killZone = this.GetComponent('stealthkill_zone');		
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( actionName == 'Ambush' )
		{
			if( thePlayer.IsInSneakMode() )
			{
				thePlayer.ChangePlayerState( thePlayer.GetProperExplorationState() );			
				timeout = 10;
				AddTimer('TakedownTimer', 0.05, true );
				((CNewNPC)this).StateIdleFreeze();
				TakedownTimer(0);				
			}
		}
		if ( actionName == 'Exploration' )
		{
			if( thePlayer.IsInSneakMode() )
			{
				thePlayer.ChangePlayerState( thePlayer.GetProperExplorationState() );			
				timeout = 10;
				AddTimer('KillTimer', 0.05, true );
				((CNewNPC)this).StateIdleFreeze();
				KillTimer(0);				
			}
		}
		super.OnInteraction( actionName, activator );
	}
	
	timer function TakedownTimer( t : float )
	{	
		timeout -= t;
		if( thePlayer.GetCurrentPlayerState() == PS_Sneak )
		{
			if( thePlayer.OnTakedownActor(this) )
			{				
				ambushZone.SetEnabled(false);
				killZone.SetEnabled(false);
			}
			RemoveTimer('TakedownTimer');
		}		
		
		if( timeout<=0 )
		{
			RemoveTimer('TakedownTimer');
			((CNewNPC)this).StateIdle();
		}
	}
	
	timer function KillTimer( t : float )
	{	
		timeout -= t;
		if( thePlayer.GetCurrentPlayerState() == PS_Sneak )
		{
			if( thePlayer.OnStealthKillActor(this) )
			{				
				ambushZone.SetEnabled(false);
				killZone.SetEnabled(false);
			}
			RemoveTimer('KillTimer');
		}		
		
		if( timeout<=0 )
		{
			RemoveTimer('KillTimer');
			((CNewNPC)this).StateIdle();
		}
	}
	
	event OnEnteringCombat()
	{
		if( ambushZone ) ambushZone.SetEnabled(false);
		if( killZone ) killZone.SetEnabled(false);
		
		super.OnEnteringCombat();
	}
	
	latent function BeforeCombat()
	{
		RaiseAlarm();
	}
	
	function RaiseAlarm()
	{
		var tm, currentTime : EngineTime;		
		theGame.GetBlackboard().GetEntryTime( 'dungeonAlarm', tm );
		
		currentTime = theGame.GetEngineTime();
		
		if( currentTime > tm )
		{
			PlayVoiceset( 100, "alarm" );
			theGame.GetBlackboard().AddEntryTime( 'dungeonAlarm',  currentTime + 10.0 );
		}		
	}
	
	latent function HandleItemsOnDeath() : bool
	{
		if( ambushZone ) ambushZone.SetEnabled(false);
		if( killZone ) killZone.SetEnabled(false);	
	
		// Drop the weapon
		GetInventory().DropItem( GetInventory().GetFirstWeaponId() );
	
		// Inventory bag should appear after some time
		//Sleep(10.0); // DO NOT UNCOMMENT OR I WILL KILL YOU
		GetInventory().ThrowAwayAllItems();
			
		return true;
	}
}
