// Area of effect class for petards

class CAreaOfEffect extends CGameplayEntity
{
	editable var AreaName : CName;
	editable var MinDamage : float;
	editable var MaxDamage : float;
	editable var EffectRadius : int;
	editable var EffectDuration : int;
	editable var TickEverySeconds : int;
	
	var init : int;
	var affected : array< CActor >;
	private var owner : CActor;
		
	default MinDamage = 0;
	default MaxDamage = 0;
	default EffectRadius = 3;
	default TickEverySeconds = 2;
	default EffectDuration = 12;
	
	function SetOwner( owner : CActor )
	{
		this.owner = owner;
	}

// when area is created on impact
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var Damage  : float;
		var playerPos : Vector;
		
		init = 0;
		PlayEffect( 'effect' );

		if ( AreaName == 'Fire Wall' || AreaName == 'Poison Cloud' )
		{
			AddTimer( 'GetAffected', 1.f, true, false );
			AddTimer( 'Tick', TickEverySeconds, true, false );
		}
		else if ( AreaName == 'Arachas Cloud' )
		{
			AddTimer( 'GetAffectedAll', 1.f, true, false );
			AddTimer( 'Tick', TickEverySeconds, true, false );
			AddTimer( 'AreaTimeToDestroy', 5.f, true, false );
		}
		else if ( AreaName == 'Rotfiend Guts' )
		{
			//AddTimer( 'GetAffectedAll', 1.f, true, false );
			AddTimer( 'TickPlayer', 1, false, false );
		}
		else if ( AreaName == 'Grapeshot Explosion' )
		{
			GetActorsInRange( this.affected, EffectRadius , '', this );
			ApplyDamage( false );
		}
		else if ( AreaName == 'Gargoyle Teleport' )
		{
			PlayEffect ('marker_fx');
			AddTimer( 'TickPlayer', 1, false, false );
		}
		else if ( AreaName == 'Wraith Teleport' )
		{
			PlayEffect ('teleport_in');
			//AddTimer( 'TickPlayer', 1, false, false );
		}
		else if ( AreaName == 'Troll Bomb' )
		{
			//GetActorsInRange( this.affected, EffectRadius, '', this );
			//ApplyDamage( true );
		}
		else
		{
			AddTimer( 'GetAffected', 1.f, true, false );
			AddTimer( 'AreaDurationEffect', EffectDuration, true, false );
		}
		AddTimer( 'AreaTimeToDestroy', EffectDuration, true, false );
	}	

// timer controlling when area should be destroyed
	
	timer function AreaTimeToDestroy( timeDelta : float )
	{	
		if ( init == 1 )
		{
			StopEffect( 'effect' );
			RemoveTimer( 'Tick' );
			RemoveTimer( 'AreaDurationEffect' );
			RemoveTimer( 'GetAffected' );
			RemoveTimer( 'GetAffectedAll' );
			RemoveEffects();
		}
		else if( init == 2 )
		{
			Destroy();
		}
		init += 1;
		Log( "Tick! " +( init - 1) );
	}


// timer for short over time ticks applying various effects

	timer function Tick( timeDelta : float )
	{
		ApplyDamage( false );
	}
	
	timer function TickPlayer( timeDelta : float )
	{
		ApplyDamageToPlayer();
	}

// timer gathering info about npcs in range of an effect
	
	timer function GetAffected( timeDelta : float )
	{
		GetActorsInRange( this.affected, EffectRadius , '', this );
	}	
	
	timer function GetAffectedAll( timeDelta : float )
	{	
		GetActorsInRange( this.affected, EffectRadius ,'',  this );
	}	


// function used by timers to apply damage to targets

	function ApplyDamage( omitSelf : bool )
	{
		var i : int;
		var size : int;
		var Damage : float;
		var playerPos : Vector;
		
		size = this.affected.Size();
		playerPos = thePlayer.GetWorldPosition();

		for ( i = 0; i < size; i += 1 )
		{
			if ( omitSelf && affected[i] == owner )
			{
				continue;
			}
			
			if( this.affected[i].health > 0 ) 
			{
				if ( thePlayer.CanAttackEntity( affected[i] ) )
				{
					Damage = RandRangeF( MinDamage, MaxDamage );
					this.affected[i].HitPosition( playerPos, 'FastAttack_t1', Damage, true );
					this.affected[i].PlayBloodOnHit();
					
					Log(" DAMAGE! " );
				}	
			}
		}
	}
	

// timer for effects that should be sustained over defined period of time
	
	timer function AreaDurationEffect( timeDelta : float )
	{

		var i : int;
		var size : int;
		var Damage  : float;
		var areaPos : Vector;
		var npc : CNewNPC;

		areaPos = this.GetWorldPosition();
		size = this.affected.Size();
	
		for ( i = 0; i < size; i += 1 )
		{
			if( this.affected[i].health > 0 ) 
			{	
				npc = ( CNewNPC )this.affected[i];
				
				if( thePlayer.CanAttackEntity( npc ) )
				{
					if( AreaName == 'Wild Growth Area' )
					{
						//npc.EnterFrozen( this.EffectDuration );
						Log(" IVIES EVERYWHERE!! " );
					}	
					if( AreaName == 'Enraging Cloud' )
					{
						npc.EnterBerserk( this.EffectDuration );
						Log(" HULK MAAAD!!! " );
					}
					else if( this.AreaName == 'Flamable Gas Cloud' )
					{
						//FlamableGasCloud();
					}
					else if( this.AreaName == 'Noise Area' )
					{
						npc.GetComponent( "SENSE_HEARING" ).SetEnabled( false );
					}
					else if( this.AreaName == 'Incapacitate Area' )
					{
						npc.ApplyCriticalEffect( CET_Immobile, NULL );
					}
					else if( this.AreaName == 'Blinding Area' )
					{
						npc.GetComponent( "SENSE_VISION" ).SetEnabled( false );
					}
				}	
			}
		}
	}	
			
	function RemoveEffects()
	{
		var i : int;
		var size : int;
		var npc : CNewNPC;
				
		for ( i = 0; i < size; i += 1 )
		{
			if( affected[i].health > 0 ) 
			{
				npc = ( CNewNPC )affected[i]; 
				if( this.AreaName == 'Noise Area' )
				{
					npc.GetComponent( "SENSE_HEARING" ).SetEnabled( true );
				}
				else if( this.AreaName == 'Blinding Area' )
				{
					npc.GetComponent( "SENSE_VISION" ).SetEnabled( true );
				}	
			}		
		}	
	}
}

state AOE in CAreaOfEffect
{
	editable var MinDamage : float;
	editable var MaxDamage : float;

	default MinDamage = 20;
	default MaxDamage = 40;
	
	entry function ApplyDamageToPlayer()
	{
		var i : int;
		var size : int;
		var Damage : float;
		var rangeVec, myPos : Vector;

		//Sleep(2.0);
		
		// Play pre effects
		if ( parent.AreaName == 'Gargoyle Teleport' )
		{
			parent.PlayEffect ('spawn_fx');	
			Sleep(0.4);
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');	
		}
		else if ( parent.AreaName == 'Wraith Teleport' )
		{
			parent.PlayEffect ('teleport_in');	
			Sleep(0.4);
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');	
		}
		else
		{
		//	parent.owner.PlayEffect('blood_explosion');
		}

		// Get entites that were hit		
		myPos = parent.GetWorldPosition();
		rangeVec = Vector( parent.EffectRadius, parent.EffectRadius, parent.EffectRadius );
		ActorsStorageGetClosestByPos( myPos, parent.affected, -rangeVec, rangeVec, parent.owner );
		
		size = parent.affected.Size();

		for ( i = 0; i < size; i += 1 )
		{
			if( parent.affected[i].health > 0 ) 
			{	
				// Play damage effects

				if ( parent.AreaName == 'Rotfiend Guts' )
				{
					parent.owner.PlayEffect('camera_blood_explosion');
				}
				
				//Sleep(3.0);
	
				Damage = RandRangeF( MinDamage, MaxDamage );
				parent.affected[i].HitPosition( myPos, 'Attack_t3', Damage, true );
				//Sleep(0.2);
				

				
				Log(" DAMAGE! " );
			}
		}
		
		// Play post effects
		if ( parent.AreaName == 'Gargoyle Teleport' )
		{
			//parent.PlayEffect ('marker_fx');
			//Sleep(0.6);
			parent.StopEffect ('marker_fx');
			
			Damage = RandRangeF( MinDamage, MaxDamage );
			parent.affected[i].HitPosition( myPos, 'Attack_t3', Damage, true );
		
			Log(" DAMAGE! " );
		}
	}
}