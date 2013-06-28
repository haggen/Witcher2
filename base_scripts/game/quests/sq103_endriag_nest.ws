//////////////////////////////////////////////
// class for endriag nests

class CEndriagNest extends CActor
{
	private editable saved var hitPoints	: float;
	private editable var nestNumber	: int;
	saved var isAlive : bool;

	default hitPoints = 100;
	default isAlive = true;
	
	timer function CloseCocoon(timeDelta:float)
	{
		if( isAlive )
		{
			RaiseEvent('close');
			GetComponent( "open" ).SetEnabled( true );
			SetAttackableByPlayerPersistent( false );
			
			// Temp for review
		//	GetComponent( "detonate" ).SetEnabled( false );		
	
			if( CheckInteraction("check") )
			{
				thePlayer.RaiseEvent( 'Hit_t3b' );
				thePlayer.ApplyCriticalEffect( CET_Poison, NULL ); 
			}
		}
	}
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		if( isAlive )
		{
			initialHealth = hitPoints;
			health = hitPoints;
			
			EnablePathEngineAgent(false);
			EnablePhysicalMovement(false);
			EnableRagdoll(false);
		}
		else
		{
			EnablePathEngineAgent(false);
			EnablePhysicalMovement(false);
			EnableRagdoll(false);
			SetAttackableByPlayerPersistent( false );
			ApplyAppearance("nest_endraiga_destroyed_final");
		}
	}
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Exploration' && activator == thePlayer )
		{
			RaiseEvent('open');
			GetComponent( "open" ).SetEnabled( false );
			SetAttackableByPlayerPersistent( true );
			
	//		GetComponent( "detonate" ).SetEnabled( true );
			
			AddTimer('CloseCocoon', 10.f, false, false);
		}	
	/*	// Temp for review
		else if( actionName == 'Use' && activator == thePlayer )
		{
			GetComponent( "detonate" ).SetEnabled( false );
			EnterDead();
		}
*/	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if(activator == thePlayer && this.isAlive && FactsDoesExist("Knowledge_4_2") )
		{
			GetComponent( "open" ).SetEnabled( true );
		}
	}
	
	// Being hit event - return false to reject hit
	event OnBeingHit( out hitParams : HitParams ) { return true; }
	
	function IsMonster() : bool
	{
		return true;
	}
	
	// What happens when the actor fails to block the hit
	function OnHitDamage( attacker : CActor, attackType : name, hitParams : HitParams )
	{
		if( IsStrongAttack( hitParams.attackType ) ) 
		{
			hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + 2.0;
		}
			
		hitParams.damage = CalculateDamage(attacker, this, false, false, false, true, hitParams.outDamageMultiplier);
		GetVisualDebug().AddText( 'dbgHit', "Hit damage: " + hitParams.damage , Vector(0.0, 0.0, 3.4), false, 12, Color(255, 0, 0, 255), false, 3);
		TryToApplyAllCritEffectsOnHit(this, attacker, true);
							
		if (hitParams.damage > 0)  
		{
			if ( attacker == thePlayer )
			{
				thePlayer.IncreaseStaminaBuild();
				PlayShakeOnHit(attackType);
			}
			
			OnHit( hitParams );			
		
			if ( hitParams.attackType != 'MagicAttack_t1' && hitParams.attackType != 'FistFightAttack_t1' ) // Magical attack do not cast blood at hit
			{
				PlaySparksOnHit(this, hitParams);
			}
		}
			
		DecreaseHealth( hitParams.damage, hitParams.lethal, attacker );
	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		//var eventName : name;		
		super.OnHit( hitParams );
		if( IsAlive() )
		{
			//eventName = GetHitEventName( hitParams.hitPosition, hitParams.attackType );
			this.PlayEffect('stndard_hit');
		}
	}
	
	// Check if actor should be dead
	function DeathCheck(lethal : bool, attacker : CActor, deathData : SActorDeathData )
	{
		if ( health <= 0.0 )
		{
			if( !IsImmortal() )
			{
				SetAlive( false );
				if( lethal )
				{	
					EnterDead();
					
					// Inform player
					if( attacker == thePlayer )
					{
						thePlayer.OnActorKilled( this );
					}
				}
			}
		}
	}

	function HandleAardHit( aard : CWitcherSignAard )
	{
		var hitParams : HitParams;
		var level : int;
		var damage : float;
		var aardDamage, signsPower, resAard, signDamageBonus : float;
	
		if( IsAlive() && IsAttackableByPlayer() )
		{
			level = aard.GetAardLevel();
			aardDamage = thePlayer.GetCharacterStats().GetAttribute('aard_damage');
			signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
			signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
			resAard = GetCharacterStats().GetAttribute('res_aard');
			resAard = resAard / 100.0f;
			if(resAard > 1.0f)
				resAard = 1.0;
			damage =  ( ( aardDamage * signsPower ) + signDamageBonus ) * ( 1 - resAard );
			if(damage <= 0)
			{
				damage = 5.0;
			}
			
			hitParams.attacker = thePlayer;
			hitParams.attackType = '';
			hitParams.hitPosition = thePlayer.GetWorldPosition();
			hitParams.damage = damage;
			hitParams.lethal = true;
			hitParams.outDamageMultiplier = 1.0f;
			hitParams.forceHitEvent = '';
			hitParams.rangedAttack = true;
			
			PlayEffect('stndard_hit');
			HitDamage( hitParams );
		}
	}
	
	function HandleIgniHit( igni : CWitcherSignIgni )
	{
		var hitParams : HitParams;
		var igniDamage : float;
		var signsPower : float;
		var signDamageBonus : float;
		var resIgni : float;
		var params : W2CriticalEffectParams;
		var damage : float;
		var stats : CCharacterStats;
		
		if( IsAlive() && IsAttackableByPlayer() )	
		{
			igniDamage = thePlayer.GetCharacterStats().GetAttribute('igni_damage');
			signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
			signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
			resIgni = GetCharacterStats().GetAttribute('res_igni');
			resIgni = resIgni / 100.0f;
			if(resIgni > 1.0f)
				resIgni = 1.0f;
			damage =  ( ( igniDamage * signsPower ) + signDamageBonus ) * ( 1 - resIgni );
			if(damage <= 0)
			{
				damage = 5.0;
			}
			
			hitParams.attacker = thePlayer;
			hitParams.attackType = '';
			hitParams.hitPosition = thePlayer.GetWorldPosition();
			hitParams.damage = damage;
			hitParams.lethal = true;
			hitParams.outDamageMultiplier = 1.0f;
			hitParams.forceHitEvent = '';
			hitParams.rangedAttack = true;
			
			this.PlayEffect('stndard_hit');
			HitDamage( hitParams );
		}
	}
	
	private function EnterDead( optional deathData : SActorDeathData)
	{
		var itemTags : array<CName>;
		
		isAlive = false;
		PlayEffect('explosion_nest');
		RaiseEvent('destroy');
		itemTags.PushBack( 'NoDrop' );
		GetInventory().ThrowAwayItemsFiltered( itemTags );
		ApplyAppearance("nest_endraiga_destroyed");
		FactsAdd( "endriag_nest_" + nestNumber + "_destroyed", 1 );
	}
		
	private function EnterUnconscious( optional deathData : SActorDeathData){}
}

