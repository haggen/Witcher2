

//enum trap listing

/*enum EWitcherTrap
{
	T_ExplosiveTrap,
	T_CripplingTrap,
	T_FreezingTrap,
	T_RageTrap,
	T_GrapplingTrap,
	T_TrapLinker,
	T_HarpyTrap,
	T_NekkerTrap,
};
	
// Witcher Trap Class definition - these traps are used by witcher against enemies	

class CWitcherTrap extends CGameplayEntity
{
	editable var TrapName : EWitcherTrap;
	var CanBeTriggered : bool;	
	var Triggered : bool;
	
	default CanBeTriggered = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
	// check if trap should disarm itself after time 	
		if( HasTag( 'witcher_trap' ) )
		{
			if ( TrapName == T_TrapLinker )
			{
				AddTimer( 'TriggerTraps', 0.5, true, true );
				Log( "Timer for Trap Linker Added" );
			}
			TimeToDisarm();
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
					TrapIsTriggered ( this, i_triggered );
					
					this.GetComponent ("trigger pulapki").SetEnabled(false);
					Log( "Trap " +this +" has been triggered" );
				}
			}	
		}
	}	
		
	//function to use trap's default behevior after being triggered
		
	private function TrapIsTriggered ( trap_triggered : CWitcherTrap, activator : CNewNPC )
	{
		if( trap_triggered.TrapName == T_ExplosiveTrap )
		{			
			trap_triggered.Detonate();
		}
		else if( trap_triggered.TrapName == T_FreezingTrap )
		{
			trap_triggered.Freeze();
		}
		else if( trap_triggered.TrapName == T_GrapplingTrap )
		{
			trap_triggered.Grapple();
		}
		else if( trap_triggered.TrapName == T_CripplingTrap )
		{
			trap_triggered.Cripple();
		}
		else if( trap_triggered.TrapName == T_RageTrap )
		{
			trap_triggered.Enrage();
		}
		else if( trap_triggered.TrapName == T_HarpyTrap && activator.IsA('CHarpie') && activator.HasTag('nest_harpy') )
		{
			trap_triggered.HarpyDestroyNest(activator);
		}
		else if( trap_triggered.TrapName == T_NekkerTrap && activator.IsA('CNekker') )
		{
			trap_triggered.NekkerStun(activator);
		}
	}

	// timer for Trap Linker for checking on triggered traps in range

	timer function TriggerTraps( time : float )
	{
		var ConnectedTraps : array< CNode >;
		var i : int;
		var size : int;
		var radius : float;
		var affectedTrap : CWitcherTrap;
		var TrapsPosition : Vector;
		var LinkerPosition : Vector;
		var TrapDistance : float;
		
		//Log( "Trap Linker says: TICK!" );
		
		theGame.GetNodesByTag( 'witcher_trap', ConnectedTraps );
		LinkerPosition = this.GetWorldPosition();
		radius = this.GetCharacterStats().GetFinalAttribute( 'link_radius' );
		size = ConnectedTraps.Size();
		
		if( size > 1 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				affectedTrap = (CWitcherTrap)ConnectedTraps[i];
				TrapsPosition = affectedTrap.GetWorldPosition();
				TrapDistance = VecDistanceSquared( LinkerPosition, TrapsPosition );
						
				if ( TrapDistance <= radius && TrapDistance > 0 )
				{
					if( affectedTrap.Triggered )
					{
						TriggerAllTrapsInRange( this, LinkerPosition );
					}
				}	
			}
		}
	}
	private function TriggerAllTrapsInRange( linker : CWitcherTrap, LinkerPosition : Vector )
	{
		var TrapsInRange : array< CNode >;
		var x : int;
		var count : int;
		var TrapToTrigger : CWitcherTrap;
		var TrapsPosition : Vector;
		var Distance : float;
		var radius : float;
		
		//Log( "TRIGGERING TRAPS!!" );
		
		theGame.GetNodesByTag( 'witcher_trap', TrapsInRange );
		count = TrapsInRange.Size();
		radius = this.GetCharacterStats().GetFinalAttribute( 'link_radius' );
		
		if( count > 1 )
		{
		//trigger all traps in range
			for ( x = 0; x < count; x += 1 )
			{
				TrapToTrigger = (CWitcherTrap)TrapsInRange[x];
				TrapsPosition = TrapToTrigger.GetWorldPosition();
				Distance = VecDistanceSquared( LinkerPosition, TrapsPosition );
					
				if ( Distance <= radius && Distance > 0 )
				{
					if( TrapToTrigger.Triggered == false && TrapToTrigger.CanBeTriggered == true )
					{
						TrapIsTriggered( TrapToTrigger, NULL );
						TrapToTrigger.GetComponent ("trigger pulapki").SetEnabled(false);
						//Log( "Trap " +TrapToTrigger +" is about to be triggered also" );
					}
				}
			}	
		}
		linker.Destroy();	
	}
}	

// trap will be self-disarming after time

state Deployed in CWitcherTrap
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

state Triggered in CWitcherTrap
{
	// explosive trap explodes
	
	entry function Detonate()
	{
		var casulties : array< CActor >;
		var otherTrap : CWitcherTrap;
		var i : int;
		var size : int;
		var tags : name;
		var creatures : array <name>;
		var trap_position : Vector;
		var radius : float;
		var damage : float;
		var damage_min  : float;
		var damage_max  : float;
		
		trap_position = parent.GetWorldPosition();
		damage_min = parent.GetCharacterStats().GetFinalAttribute( 'damage_min' );
		damage_max = parent.GetCharacterStats().GetFinalAttribute( 'damage_max' );
		radius = parent.GetCharacterStats().GetFinalAttribute( 'explosion_radius' );
		
		GetActorsInRange( casulties, radius, '', parent );
		
		size = casulties.Size();
		
		parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect ('trap_effect');
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.3f );
		
		parent.ApplyAppearance( '3_trap_explode' );

		
		for ( i = 0; i < size; i += 1 )
		{
			if( thePlayer.CanAttackEntity(casulties[i]) )
			{
				damage = RandRangeF( damage_min, damage_max );
				//Damage = RandRangeF( 30, 45 );
				casulties[i].SetBlock( false );
				casulties[i].ActionCancelAll();
				casulties[i].ActionRotateToAsync( trap_position );
				casulties[i].HitPosition( trap_position, 'FastAttack_t2', damage, true );
				casulties[i].PlayBloodOnHit();
				Sleep(0.1);
				casulties[i].SetBlock( true );
			}	
		}	
		
		Sleep (7.f);	

		parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	// freezing trap is triggered and freezes all surronding enemies	
	entry function Freeze()
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var tags : name;
		var freeze_duration : float;
		var radius : float;
		var body : string;
		var npc : CNewNPC;

		freeze_duration = parent.GetCharacterStats().GetFinalAttribute( 'freeze_duration' );
		radius = parent.GetCharacterStats().GetFinalAttribute( 'freeze_radius' );

		GetActorsInRange( casulties, radius , '', parent );
		size = casulties.Size();
		
		//parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect ('trap_effect');
		parent.ApplyAppearance( "3_trap_explode" );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Sleep( 0.5f);
		Log("Zamra¿am wszystkich w okolicy" );
		//parent.ApplyAppearance( '3_trap_explode' );
	
		if ( freeze_duration > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				if( casulties[i].health > 0 ) 
				{	
					npc = (CNewNPC)casulties[i]; 
					
					if ( npc && thePlayer.CanAttackEntity(npc) )
					{
						//npc.SetUnconsciousMode( UM_Immobile );
						//npc.EnterFrozen( freeze_duration );
						//Log( "ZAMROZENIE");
						npc.ApplyCriticalEffect( CET_Laming, NULL );
					}	
				}	
			}
		}
		Sleep ( freeze_duration );
		parent.Destroy();
	}

	// grappling trap is triggered and captures creature that triggered it	
	
	entry function Grapple()
	{
		var affected : CNewNPC;
		var npcs : array< CActor >;
		var damage  : float;
		var holding_duration  : float;
		var damage_min  : float;
		var damage_max  : float;
		var radius  : float;
		var TrapPosition : Vector;
		var size : int;
		var i : int;
		
		holding_duration = parent.GetCharacterStats().GetFinalAttribute( 'holding_duration' );
		radius = parent.GetCharacterStats().GetFinalAttribute( 'grappling_radius' );
		damage_min = parent.GetCharacterStats().GetFinalAttribute( 'damage_min' );
		damage_max = parent.GetCharacterStats().GetFinalAttribute( 'damage_max' );

		Sleep( 0.5f);
		parent.RaiseForceEvent( 'Spring' );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		Log("Chwytam przeciwnika" );
	
		if ( holding_duration > 0 )
		{
			TrapPosition = parent.GetWorldPosition();
			GetActorsInRange( npcs, radius, '', parent );
			size = npcs.Size();
			
			for ( 	i = 0; i < size; i += 1 )
			{
				affected = (CNewNPC)npcs[i];
				
				if ( affected && thePlayer.CanAttackEntity( affected ) )
				{
					damage = RandRangeF( damage_min, damage_max );
					affected.HitPosition( TrapPosition, 'FastAttack_t1', damage, true );
					//affected.PlayEffect( 'standard_hit_fx' );
					//affected.SetUnconsciousMode( UM_Immobile );
					//affected.EnterGrappled( holding_duration );
					affected.ApplyCriticalEffect( CET_Laming, NULL );
				}
			}	
		}
		Sleep ( holding_duration );
		parent.Destroy();
	}

	//crippling trap triggers wounding all surrounding enemies
	
	entry function Cripple()
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var damage_min : float;
		var damage_max : float;
		var radius : float;
		var bleeding_duration : float;
		var ticks : float;
		var ticks_number : float;
		var damage  : float;

		damage_min = parent.GetCharacterStats().GetFinalAttribute( 'damage_min' );
		damage_max = parent.GetCharacterStats().GetFinalAttribute( 'damage_max' );
		radius = parent.GetCharacterStats().GetFinalAttribute( 'crippling_radius' );
		bleeding_duration = parent.GetCharacterStats().GetFinalAttribute( 'bleeding_duration' );
		ticks = parent.GetCharacterStats().GetFinalAttribute( 'tick_every_x_second' );
		ticks_number = CeilF( bleeding_duration / ticks );

		GetActorsInRange( casulties, radius , '', parent );
		size = casulties.Size();

		//parent.ApplyAppearance( '2_triggered' );
		parent.PlayEffect('trap_effect');
		
		//Sleep( 0.3f );
		Log("Zak³adam krwanienie na wszystkich w okolicy" );
		//parent.ApplyAppearance( '3_trap_explode' );
	
		if ( bleeding_duration > 0 )
		{
			if( ticks_number > 0 )
			{
				for ( i = 0; i < size; i += 1 )
				{
					if( casulties[i].health > 0 && thePlayer.CanAttackEntity(casulties[i]) ) 
					{	
						damage = RandRangeF( damage_min, damage_max );
						casulties[i].ApplyCriticalEffect( CET_Laming, NULL );
						casulties[i].ApplyCriticalEffect( CET_Bleed, NULL );
					}
				}
			}
		}
		//parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
	}
	
	// enrages all creatures within explosion area forcing them to attack each other
	
	entry function Enrage()
	{
		var casulties : array< CActor >;
		var i : int;
		var size : int;
		var radius : float;
		var enrage_duration : float;
		var npc : CNewNPC;
		
		radius = parent.GetCharacterStats().GetFinalAttribute( 'influence_radius' );
		enrage_duration = parent.GetCharacterStats().GetFinalAttribute( 'enrage_duration' );
		GetActorsInRange( casulties, radius, '', parent );
		size = casulties.Size();
				
		parent.PlayEffect ('trap_effect');
		parent.ApplyAppearance( "3_trap_explode" );
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		//Sleep( 0.5f);
		//Log("Wywo³ujê enrage u wszystkich w okolicy" );
			
		if ( enrage_duration > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				npc = (CNewNPC)casulties[i];
							
				if( casulties[i].health > 0 ) 
				{	
					if ( npc && thePlayer.CanAttackEntity(npc) )
					{
						npc.EnterBerserk( enrage_duration );
						Log( "ENRAGE na " +npc );	
						// tempowo daje tu efekt ploniecia bo cholerstwo attitude robi problemy
						//npc.ApplyCriticalEffect( CET_Burn, NULL );
					}	
				}
			}	
		}
		//parent.StopEffect( 'trap_effect');
		
		Sleep (3.f);
		
		parent.Destroy();
		
	}
	
	entry function HarpyDestroyNest( activator: CNewNPC )
	{
		var parentPos : Vector;
		var harpy : CHarpie;
		var nest : CEntity;
		var nestTag : name;
		var triesCount : int;
		
		harpy = (CHarpie) activator;
		parentPos = parent.GetWorldPosition();
		
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		nestTag = harpy.nestTag;
		harpy.SetAttitude( thePlayer, AIA_Neutral );
		harpy.GetArbitrator().AddGoalMoveToTarget( parent, MT_Run, 3.f, 0.2f, EWM_Exit );
		triesCount = 0;
		
		while( VecDistance2D( parentPos, harpy.GetWorldPosition()) > 0.5f && triesCount < 10 )
		{
			triesCount += 1;
			Sleep( 0.3f );
		}
		
		harpy.RaiseEvent('AttackStatic1');
		Sleep( 2.f );
		
		parent.ApplyAppearance( "2_bomb_gone" );
		harpy.GetArbitrator().AddGoalDespawn( false, false );
		
		Sleep( 4.f );
		
		nest = theGame.GetEntityByTag( nestTag );
		nest.PlayEffect( 'explosion_nest_fx' );
		nest.ApplyAppearance("destroyed");
		
		FactsAdd( "nest_" +  nestTag + "_was_destroyed", 1 );
		
		parent.Destroy();
	}
	
	entry function NekkerStun( activator: CNewNPC )
	{
		var nekker : CNekker;
		
		nekker = (CNekker) activator;
		
		parent.Triggered = true;
		parent.CanBeTriggered = false;
		
		parent.ApplyAppearance( "2_trap_explode" );
		
		nekker.EnterUnconscious();
		
		Sleep( 4.f );
		
		FactsAdd( "quest_nekker_is_captured", 1 );
		
		parent.Destroy();
	}
}	
*/