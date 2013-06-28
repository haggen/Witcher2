//////////////// PULAPKI NA WIEDZMINA ///////////////////////////////////////

/*enum EAntiWitcherTrap
{
	T_AnimalTrap,
	T_WitcherKillerTrap,
	T_AntiWitcherTrap,
	T_ArachasSmokeTrap,
};


class CAntiWitcherTrap extends CGameplayEntity
{
	editable var TrapName : EAntiWitcherTrap;
	editable var damage_min_on_enter : float;
	editable var damage_max_on_enter : float;
	editable var ticks_count : float;	
	editable var damage_min_on_tick : float;
	editable var damage_max_on_tick : float;
	var Triggered : bool;
	var CanBeTriggered : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
	// check if trap should disarm itself after time 	
		if( this.HasTag( 'arachas_smoke_trap' ) )
		{
			TimeToDisarm();
		}
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{

		// check if it's a trap against witcher
		
		if( area.GetName() == "anim_trap_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == T_AnimalTrap )
				{
					ShutJaws();
				}	
			}			
		}
		else if( area.GetName() == "player_killing_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == T_WitcherKillerTrap )
				{
					killWitcher();
				}	
			}
		}	
		else if( area.GetName() == "anti_witcher_trap_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == T_AntiWitcherTrap )
				{
					harmWitcher();
				}	
			}
		}
		else if( area.GetName() == "arachas_smoke_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == T_ArachasSmokeTrap )
				{
					blindWitcher();
				}	
			}
		}
		
		//else if( area.GetName() == "anim_trap_spot_trigger" )
		//{
		//	this.SetBodyState( 'trap' );
		//}
		
	}

	// disarming the anti witcher trap
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( activator.IsA( 'CPlayer' ) )
		{
	 		if ( actionName == 'DisarmTrap' )
			{
				TrapDisarmed();
			}
		}	
	}
}

// trap will be self-disarming after time

state Deployed in CAntiWitcherTrap
{
	entry function TimeToDisarm()
	{
		Sleep(120.f);
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		parent.RemoveTimers();
		parent.Destroy();
	}	
}

// anti witcher trap is disarmed

state Disarmed in CAntiWitcherTrap
{
	entry function TrapDisarmed()
	{
		if ( thePlayer.GetCurrentStateName() != 'Exploration' )
		{
			thePlayer.ChangePlayerState( PS_Exploration );
			Sleep(0.3);
		} 
		thePlayer.SetManualControl( false, true );
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		thePlayer.RaiseEvent('loot_floor');
		parent.GetComponent( "anim_trap_trigger" ).SetEnabled( false );
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
		Sleep(4.0);
		parent.RaiseForceEvent( 'trap' );
		thePlayer.RaiseEvent('Idle');
		Sleep(0.6);
		thePlayer.SetManualControl( true, true );
	}
	
	// anti witcher trap is triggered and wounds witcher
	
	entry function ShutJaws()
	{
		var damage_min : float;
		var damage_max : float;
		var damage_min_tick : float;
		var damage_max_tick : float;
		var ticks_number : float;
		var ticks_count : float;
		var Damage  : float;
		var diffModeMult : float;
		
		diffModeMult = thePlayer.GetDifficultyLevelMult();

		damage_min = parent.damage_min_on_enter; 
		damage_max = parent.damage_max_on_enter; 
		damage_min_tick = parent.damage_min_on_tick; //parent.GetCharacterStats().GetFinalAttribute( 'damage_min' );
		damage_max_tick = parent.damage_max_on_tick; //parent.GetCharacterStats().GetFinalAttribute( 'damage_max' );
		ticks_number = parent.ticks_count;
		
		Damage = RandRangeF( damage_min * diffModeMult, damage_max * diffModeMult);
		
		parent.RaiseForceEvent( 'trap' );
		thePlayer.RaiseForceEvent( 'Hit' );
		parent.GetComponent ("anim_trap_trigger").SetEnabled(false);
		parent.GetComponent( "DisarmTrap" ).SetEnabled(false);
			
		thePlayer.DecreaseHealth( Damage, true, NULL );
		thePlayer.PlayEffect( 'standard_hit_fx' );
		thePlayer.PlayBloodOnHit();
			
		Log("Zak³adam krwanienie na wies³awa" );
		
		Damage = RandRangeF( damage_min_tick * diffModeMult, damage_max_tick * diffModeMult );
		
		if( ticks_number > 0 && thePlayer.GetDifficultyLevel() > 0 )
		{
			for ( ticks_count = 0; ticks_count < ticks_number; ticks_count += 1 )
			{
				thePlayer.DecreaseHealth( Damage, true, NULL );
				thePlayer.PlayEffect( 'standard_hit_fx' );
				thePlayer.PlayBloodOnHit();
				Log( "KRWAWIENIE");
				Sleep( 1.f );
			}
		}
		Sleep (3.f);
		parent.Destroy();
	}

	entry function killWitcher()
	{
		var trap_position : Vector;
		var Damage  : float;

		trap_position = parent.GetWorldPosition();
		
		parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect ('trap_effect');
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.3f );
		
		parent.ApplyAppearance( '3_trap_explode' );

		Damage = thePlayer.GetHealth() + 100.f;
		thePlayer.ActionRotateToAsync( trap_position );
		thePlayer.HitPosition( trap_position, 'FastAttack_t1', Damage, true );
		thePlayer.PlayBloodOnHit();
		
		Sleep (7.f);	

		parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	entry function harmWitcher()
	{
		var damage_min : float;
		var damage_max : float;
		var Damage : float;
		var diffModeMult : float;
		
		diffModeMult = thePlayer.GetDifficultyLevelMult();
				
		parent.RaiseForceEvent( 'trap' );
		thePlayer.RaiseForceEvent( 'Hit' );
			
		Log("Ranie wies³awa" );
		
		damage_min = parent.damage_min_on_enter; 
		damage_max = parent.damage_max_on_enter; 
		Damage = RandRangeF( damage_min * diffModeMult, damage_max * diffModeMult);
		
		thePlayer.DecreaseHealth( Damage, true, NULL );
		thePlayer.PlayEffect( 'standard_hit_fx' );
		thePlayer.PlayBloodOnHit();
		parent.GetComponent ("anti_witcher_trap_trigger").SetEnabled(false);

		Sleep (3.f);
		parent.Destroy();
	}
	
	entry function blindWitcher()
	{
	
		var tags : name;
		var trap_position : Vector;
		var Damage  : float;
				
		trap_position = parent.GetWorldPosition();
		
		//parent.PlayEffect ('trap_effect');
		FullscreenBlurSetup(1);
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.3f );
		
		//Damage = thePlayer.GetHealth() + 100.f;
		thePlayer.ActionRotateToAsync( trap_position );
		thePlayer.HitPosition( trap_position, 'FastAttack_t1', Damage, true );
		parent.GetComponent ("anim_trap_trigger").SetEnabled(false);	
		
		Sleep (5.f);	
		FullscreenBlurSetup(0.0);
		//parent.StopEffect( 'trap_effect');
		Sleep (3.f);
		
		//parent.Destroy();
	}
}*/