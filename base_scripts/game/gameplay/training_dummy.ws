/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// CTrainingDummy class
/////////////////////////////////////////////

class CTrainingDummy extends CActor
{
	private editable var expGiven	: int;
	private editable var hitPoints	: float;
	saved var isDestroyed : bool;
	
	default expGiven = 0;
	default hitPoints = 100;
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		initialHealth = hitPoints;
		health = hitPoints;
		
		EnablePathEngineAgent(false);
		EnablePhysicalMovement(false);
		EnableRagdoll(false);
	}
	
	function IsDummy() : bool
	{
		return true;
	}
	
	// Being hit event - return false to reject hit
	event OnBeingHit( out hitParams : HitParams ) { return true; }

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
			this.RaiseEvent( 'hit' );
		}
	}
	
	// Get proper behavior hit event name
	/*function GetHitEventName( hitPosition : Vector, attackType : name ) : name
	{
	//TODO: match with behavior
		if( true ) //attackType == 'FastAttack_t1' )
		{
			if( IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				return 'hit_front_t1';
			}
			else
			{
				return 'hit_back_t1';
				ActionRotateToAsync( hitPosition );
			}
		}
	}*/

	// Check if actor should be dead
	function DeathCheck(lethal : bool, attacker : CActor, deathData : SActorDeathData  )
	{
		var numKilledDummies : int;
		if ( health <= 0.0 )
		{
			if( !IsImmortal() )
			{
				SetAlive( false );
				if( lethal )
				{	
					EnterDead();
					
					// Give story ability
					if( attacker == thePlayer && !isDestroyed )
					{
						numKilledDummies = FactsQuerySum("training_dummies_killed");
						if(numKilledDummies >= 9.0 )
						{
							if(!thePlayer.GetCharacterStats().HasAbility('story_s14_1'))
							{
								AddStoryAbility('story_s14', 1);
							}
							
						}
						else
						{
							FactsAdd("training_dummies_killed", 1);
						}
						thePlayer.IncreaseExp( RoundF( RandRangeF(1, 2) ) );
						//thePlayer.OnActorKilled( this );
					}
					isDestroyed = true;
				}
			}
		}
	}
	
	private function EnterDead( optional deathData : SActorDeathData )
	{
		var itemTags : array< name >;
		var lootBag : CEntity;
		var lootPoint : CComponent;
		
		RaiseForceEvent( 'destroy' );
		
		if( GetInventory() )
		{
			itemTags.PushBack( 'NoDrop' );
			lootBag = GetInventory().ThrowAwayItemsFiltered( itemTags );
			
			if( lootBag )
			{
				lootPoint = GetComponent( "LootPosition" );
				
				if( lootPoint )
				{
					lootBag.TeleportWithRotation( lootPoint.GetWorldPosition(), lootPoint.GetWorldRotation() );
				}
			}
		}
	}
		
	private function EnterUnconscious( optional deathData : SActorDeathData ){}
	
	/*
	function HandleAardHit( aard : CWitcherSignAard )
	{
		OnAardHitReaction( aard );
	}
	
	event OnAardHitReaction( aard : CWitcherSignAard );
	*/
}
