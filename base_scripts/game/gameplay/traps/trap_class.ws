//////////////////////////////////////////
//      		TRAP CLASS	       		//
//////////////////////////////////////////

/*class CTrap extends CGameplayEntity
{
	editable var TrapName : CName;
	editable var TrapRange : float;
	editable var MinDamage : float;
	editable var MaxDamage : float;
	editable var EffectDuration : int;
	editable var AreaName : CName;
	editable var EffectRadius : int;
	editable var TickEverySeconds : int;
	editable var Tick : int;
	var Triggered : bool;
	var CanBeTriggered : bool;
	
	var init : int;
	var affected : array< CActor >;
	
	default TrapRange = 3;
	default MinDamage = 0;
	default MaxDamage = 0;
	default EffectDuration = 0;
	default Tick = 0;
	default Triggered = false;
	default EffectRadius = 3;
	default CanBeTriggered = true;
	default TickEverySeconds = 2;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
	// check if trap should disarm itself after time 	
		if( this.HasTag( 'enemy_trap' ) )
		{
			if (this.TrapName == 'Trap Linker' )
			{
				AddTimer( 'TriggerTraps', 0.5, true, true );
				Log( "Timer for Trap Linker Added" );
			}
			TimeToDisarm();
		}
		else if( this.HasTag( 'witcher_trap' ) )
		{
			this.SetBodyState( 'trap_hidden' );
		}
	}
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i_triggered : CNewNPC;
		i_triggered = (CNewNPC) activator.GetEntity();

		// check if it's a monster trap
		
		if( area.GetName() == "trigger pulapki" )
		{
			if( this.CanBeTriggered == true )
			{
				if( i_triggered.GetAttitude( thePlayer ) == AIA_Hostile )
				{
					if( this.TrapName == 'Explosive Trap' )
					{			
						Detonate( i_triggered );
					}
					else if( this.TrapName ==  'Freezing Trap' )
					{
						Freeze( i_triggered );
					}
					else if( this.TrapName ==  'Grappling Trap' )
					{
						Grapple( i_triggered );
					}
					else if( this.TrapName == 'Crippling Trap' )
					{
						Cripple( i_triggered );
					}
					else if( this.TrapName == 'Rage Trap' )
					{
						Enrage( i_triggered );
					}
					
					this.GetComponent ("trigger pulapki").SetEnabled(false);
					Log( "Trap " +this +" has been triggered" );
				}
			}	
		}
		// check if it's a trap against witcher
		
		else if( area.GetName() == "anim_trap_trigger" )
		{	
			if( i_triggered.HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == 'Animal Trap' )
				{
					this.GetComponent( "DisarmTrap" ).SetEnabled(false);
					ShutJaws( i_triggered );
				}	
			}
			this.GetComponent ("anim_trap_trigger").SetEnabled(false);
		}
		else if( area.GetName() == "player_killing_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == 'Explosive Trap' )
				{
					killWitcher( i_triggered );
				}	
			}
			this.GetComponent ("anim_trap_trigger").SetEnabled(false);
		}
		else if( area.GetName() == "arachas_smoke_trigger" )
		{	
			if( activator.GetEntity().HasTag( 'PLAYER' ) )
			{
				if( this.TrapName == 'Arachas Smoke Trap' )
				{
					blindWitcher( i_triggered );
				}	
			}
			this.GetComponent ("anim_trap_trigger").SetEnabled(false);
		}
		else if( area.GetName() == "anim_trap_spot_trigger" )
		{
			this.SetBodyState( 'trap' );
		}	
	}
	
	// disarming the anti witcher trap
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( actionName == 'DisarmTrap' )
		{
			TrapDisarmed();
		}
	}

	// timer for checking on triggered traps in range

	timer function TriggerTraps( time : float )
	{
		var ConnectedTraps : array< CNode >;
		var i : int;
		var size : int;
		var trap : CTrap;
		var TrapsPosition : Vector;
		var LinkerPosition : Vector;
		var TrapDistance : float;
		
		Log( "Trap Linker says: TICK!" );
		
		theGame.GetNodesByTag( 'enemy_trap', ConnectedTraps );
		LinkerPosition = this.GetWorldPosition();
		size = ConnectedTraps.Size();
		
		if( size > 1 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				trap = (CTrap)ConnectedTraps[i];
				TrapsPosition = trap.GetWorldPosition();
				TrapDistance = VecDistanceSquared( LinkerPosition, TrapsPosition );
				Log( "Triggered = " +Triggered );
				
				if ( TrapDistance <= this.TrapRange && TrapDistance > 0 )
				{
					if( trap.Triggered )
					{
						TriggerAllTrapsInRange( this, LinkerPosition );
					}
				}	
			}
		}	
	}
	private function TriggerAllTrapsInRange( linker : CTrap, LinkerPosition : Vector )
	{
		var TrapsInRange : array< CNode >;
		var x : int;
		var count : int;
		var TrapToTrigger : CTrap;
		var TrapsPosition : Vector;
		var Distance : float;
		
		Log( "TRIGGERING TRAPS!!" );
		
		theGame.GetNodesByTag( 'enemy_trap', TrapsInRange );
		count = TrapsInRange.Size();
		
		if( count > 1 )
		{
		//trigger all traps in range
			for ( x = 0; x < count; x += 1 )
			{
				TrapToTrigger = (CTrap)TrapsInRange[x];
				TrapsPosition = TrapToTrigger.GetWorldPosition();
				Distance = VecDistanceSquared( LinkerPosition, TrapsPosition );
					
				if ( Distance <= linker.TrapRange && Distance > 0 )
				{
					if( TrapToTrigger.Triggered == false && TrapToTrigger.CanBeTriggered == true )
					{
						if( TrapToTrigger.TrapName == 'Explosive Trap' )
						{			
							TrapToTrigger.Detonate( this );
						}
						else if( TrapToTrigger.TrapName ==  'Freezing Trap' )
						{
							TrapToTrigger.Freeze( this );
						}
						else if( TrapToTrigger.TrapName ==  'Grappling Trap' )
						{
							TrapToTrigger.Grapple( this );
						}
						else if( TrapToTrigger.TrapName == 'Crippling Trap' )
						{
							TrapToTrigger.Cripple( this );
						}
						else if( TrapToTrigger.TrapName == 'Rage Trap' )
						{
							TrapToTrigger.Enrage( this );
						}
						else if( TrapToTrigger.TrapName == 'Trap Linker' )
						{
							continue;
						}
						TrapToTrigger.GetComponent ("trigger pulapki").SetEnabled(false);
						Log( "Trap " +TrapToTrigger +" is about to be triggered also" );
					}
				}
			}	
		}	
		this.Destroy();	
	}
}	

// trap will be self-disarming after time

state Deployed in CTrap
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

state Disarmed in CTrap
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
		Sleep(4.0);
		
		parent.GetComponent( "anim_trap_trigger" ).SetEnabled( false );
		parent.GetComponent( "DisarmTrap" ).SetEnabled( false );
		parent.RaiseForceEvent( 'trap' );
		
		thePlayer.RaiseEvent('Idle');
		Sleep(0.6);
		thePlayer.SetManualControl( true, true );		
	}
}

state Triggered in CTrap
{
	// explosive trap explodes
	
	entry function Detonate ( i_triggered : CEntity )
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var tags : name;
		var creatures : array <name>;
		var trap_position : Vector;
		var Damage  : float;
		var player : CPlayer;
		
		player = thePlayer;
		trap_position = parent.GetWorldPosition();
		GetActorsInRange( casulties, parent.TrapRange , 'enemy', parent );
		size = casulties.Size();
		
		parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect ('trap_effect');
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.3f );
		
		parent.ApplyAppearance( '3_trap_explode' );

		
		for ( i = 0; i < size; i += 1 )
		{
			if( player.CanAttackEntity(casulties[i]) )
			{
				Damage = RandRangeF( parent.MinDamage, parent.MaxDamage );
				casulties[i].ActionRotateToAsync( trap_position );
				casulties[i].HitPosition( trap_position, 'FastAttack_t1', Damage, true );	
			}	
		}	
		
		Sleep (7.f);	

		parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	// freezing trap is triggered and freezes all surronding enemies	
	entry function Freeze ( i_triggered : CEntity )
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var tags : name;
		var body : string;
		var npc : CNewNPC;
		var player : CPlayer;
		
		player = thePlayer;
		
		GetActorsInRange( casulties, parent.TrapRange , 'enemy', parent );
		size = casulties.Size();
		
		//parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect ('trap_effect');
		parent.ApplyAppearance( "3_trap_explode" );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.5f);
		Log("Zamra¿am wszystkich w okolicy" );
		//parent.ApplyAppearance( '3_trap_explode' );
	
		if ( parent.EffectDuration > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				if( casulties[i].health > 0 ) 
				{	
					npc = (CNewNPC)casulties[i]; 
					
					if ( npc && player.CanAttackEntity(npc) )
					{
						//npc.EnterFrozen( parent.EffectDuration );
						Log( "ZAMROZENIE");
						//casulties[i].GetCharacterStats().AddAbility( 'Trap_Freeze' );
					}	
				}	
			}
		}
		Sleep ( parent.EffectDuration );
		parent.Destroy();
	}

	// grappling trap is triggered and captures creature that triggered it	
	
	entry function Grapple ( i_triggered : CEntity )
	{
		var player : CPlayer;
		var npc : CNewNPC;
		var Damage  : float;
		var TrapPosition : Vector;
		
		player = thePlayer;
					
		Sleep( 0.5f);
		parent.RaiseForceEvent( 'Spring' );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Log("Chwytam przeciwnika" );
	
		if ( parent.EffectDuration > 0 )
		{
			npc = (CNewNPC)i_triggered;
			TrapPosition = parent.GetWorldPosition();
			
			if ( npc && player.CanAttackEntity( npc ) )
			{
				Damage = RandRangeF( parent.MinDamage, parent.MaxDamage );
				npc.HitPosition( TrapPosition, 'FastAttack_t1', Damage, true );
				npc.PlayEffect( 'standard_hit_fx' );
				//npc.EnterGrappled( parent.EffectDuration );
			}
		}
		Sleep ( parent.EffectDuration );
		parent.Destroy();
	}

	//crippling trap triggers wounding all surrounding enemies
	
	entry function Cripple ( i_triggered : CEntity )
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var tags : name;
		var duration_tick : int;
		var tick_count : int;
		var Damage  : float;
		var player : CPlayer;
		
		player = thePlayer;
		duration_tick = CeilF( parent.EffectDuration / parent.Tick );
				
		GetActorsInRange( casulties, parent.TrapRange , 'enemy', parent );
		size = casulties.Size();

		//parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect('trap_effect');
		
		//Sleep( 0.3f );
		Log("Zak³adam krwanienie na wszystkich w okolicy" );
		//parent.ApplyAppearance( '3_trap_explode' );
	
		if ( parent.EffectDuration > 0 )
		{
			if( parent.Tick > 0 )
			{
				for ( tick_count = 0; tick_count < duration_tick; tick_count += 1 )
				{
					for ( i = 0; i < size; i += 1 )
					{
						if( casulties[i].health > 0 && player.CanAttackEntity(casulties[i]) ) 
						{	
							Damage = RandRangeF( parent.MinDamage, parent.MaxDamage );
							casulties[i].DecreaseHealth( Damage, true, NULL );
							casulties[i].PlayEffect( 'standard_hit_fx' );
							Log( "KRWAWIENIE");
							//casulties[i].GetCharacterStats().AddAbility( 'Trap_Bleeding' );
						}	
					}
				Sleep( parent.Tick );
				}
			}
		}
		//parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	// enrages all creatures within explosion area forcing them to attack each other
	
	entry function Enrage( i_triggered : CEntity )
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var npc : CNewNPC;
		var player : CPlayer;
		
		player = thePlayer;
		
		GetActorsInRange( casulties, parent.TrapRange , 'enemy', parent );
		size = casulties.Size();
				
		parent.PlayEffect ('trap_effect');
		parent.ApplyAppearance( "3_trap_explode" );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		//Sleep( 0.5f);
		Log("Wywo³ujê enrage u wszystkich w okolicy" );
			
		if ( parent.EffectDuration > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				npc = (CNewNPC)casulties[i];
							
				if( casulties[i].health > 0 ) 
				{	
					if ( npc && player.CanAttackEntity(npc) )
					{
						npc.EnterBerserk( parent.EffectDuration );
						Log( "ENRAGE na " +npc );	
					}	
				}
			}	
		}
		//parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
//////////////// PULAPKI NA WIEDZMINA ///////////////////////////////////////
	
	// anti witcher trap is triggered and wounds witcher
	
	entry function ShutJaws( i_triggered : CEntity )
	{
		var i : int;
		var size : int;
		var duration_tick : int;
		var tick_count : int;
		var Damage  : float;
		var player : CPlayer;
		
		player = thePlayer;
		duration_tick = CeilF( parent.EffectDuration / parent.Tick );
				
		parent.GetComponent( "anim_trap_trigger" ).SetEnabled( false );
		parent.RaiseForceEvent( 'trap' );
		player.RaiseForceEvent( 'Hit' );
			
		Log("Zak³adam krwanienie na wies³awa" );
	
		if ( parent.EffectDuration > 0 )
		{
			if( parent.Tick > 0 )
			{
				for ( tick_count = 0; tick_count < duration_tick; tick_count += 1 )
				{
					Damage = RandRangeF( parent.MinDamage, parent.MaxDamage );
					player.DecreaseHealth( Damage, true, NULL );
					player.PlayEffect( 'standard_hit_fx' );
					Log( "KRWAWIENIE");
					//player.GetCharacterStats().AddAbility( 'Trap_Bleeding' );
					Sleep( parent.Tick );
				}
			}
		}
		Sleep (3.f);
		parent.Destroy();
	}

	entry function killWitcher( i_triggered : CEntity )
	{
		var tags : name;
		var trap_position : Vector;
		var Damage  : float;
		var player : CPlayer;
		
		player = thePlayer;
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
		
		Sleep (7.f);	

		parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	entry function blindWitcher( i_triggered : CEntity )
	{
	
		var tags : name;
		var trap_position : Vector;
		var Damage  : float;
		var player : CPlayer;
		
		player = thePlayer;
		trap_position = parent.GetWorldPosition();
		
		//parent.PlayEffect ('trap_effect');
		FullscreenBlurSetup(1);
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.3f );
		
		//Damage = thePlayer.GetHealth() + 100.f;
		thePlayer.ActionRotateToAsync( trap_position );
		thePlayer.HitPosition( trap_position, 'FastAttack_t1', Damage, true );	
		
		Sleep (5.f);	
		FullscreenBlurSetup(0.0);
		//parent.StopEffect( 'trap_effect');
		Sleep (3.f);
		
		//parent.Destroy();
	}
}*/