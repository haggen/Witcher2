/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
 
class CDraugBoss extends CNewNPC
{
	private var currentShield, maxShield : float;
	private var tornadoRadius, tornadoDamage : float;
	private var isCovering : bool;
	
	default tornadoRadius = 9.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		noragdollDeath = true;
		DraugInitialize();
		thePlayer.SetBigBossFight( true );
		super.OnSpawned(spawnData);
	}
	timer function KeepPlayerCombat( td : float)
	{
		thePlayer.KeepCombatMode();
	}
	private function EnterDead( optional deathData : SActorDeathData )
	{
		thePlayer.SetBigBossFight( false );
		super.EnterDead( deathData );
		
		// Remove gui bar
		theHud.m_hud.HideBossHealth();
	}

	function IsBoss() : bool
	{
		return true;
	}
	function IsMonster() : bool
	{
		return true;
	}
	
	function DraugInitialize()
	{
		var params : SCombatParams;
		
		maxShield = this.GetCharacterStats().GetAttribute('shield');
		tornadoDamage = this.GetCharacterStats().GetAttribute('damage_tornado');
		currentShield = maxShield;
		PlayEffect('draug_fire');
		
		theHud.m_hud.SetBossName(this.GetDisplayName());
		theHud.HudTargetActorEx( this, true );
		theHud.m_hud.SetBossHealthPercent(100.f);
		theHud.m_hud.SetBossArmorPercent(100.0);
		UpdateHealthHud();
		ActivateBehavior('npc_exploration');
		//TreeCombatDraugSword(params);
	}
	
	latent function DestroyedOnFreeze() : bool
	{
		return false;
	}

	function EnterCombat(params : SCombatParams)
	{
		if( GetCurrentStateName() != 'DraugTornado' && !isCovering/*GetCurrentStateName() != 'DraugShootProjectiles'*/ )
			TreeCombatDraugSword(params);
	}
	
	private function UpdateHealthHud()
	{
		var armorPercent : float;
		
		armorPercent = (currentShield / maxShield) * 100.f;
		
		if( armorPercent < 20.f )
		{
			SetBodyPartState( 'draug_shield', 'destroy4', true );
			PlayEffect( 'shield_destroy_fx' );
		}
		else if( armorPercent < 40.f )
		{
			SetBodyPartState( 'draug_shield', 'destroy3', true );
			PlayEffect( 'shield_destroy_fx' );
		}
		else if( armorPercent < 60.f )
		{
			SetBodyPartState( 'draug_shield', 'destroy2', true );
			PlayEffect( 'shield_destroy_fx' );
		}
		else if( armorPercent < 80.f )
		{
			SetBodyPartState( 'draug_shield', 'destroy1', true );
			PlayEffect( 'shield_destroy_fx' );
		}
		
		theHud.m_hud.SetBossArmorPercent(armorPercent);
		theHud.m_hud.SetBossHealthPercent(GetHealthPercentage());
		
		if( health <= 0 )
		{
			theHud.m_hud.HideBossHealth();
		}
	}
	
	event OnArrowHit(hitParams : HitParams, projectile : CRegularProjectile)
	{
		projectile.Destroy();
	}
	
	private function HitDamage( hitParams : HitParams )
	{
		if( !isCovering )
		{
			super.HitDamage(hitParams);
			UpdateHealthHud();
		}
		else
			HitBlocked( hitParams );
	}
	
	function CanPerformRespondedBlock() : bool
	{
		return currentShield > 0;
	}
	function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{
		
		if( currentShield > 0 && damage > 0 )
		{
			currentShield -= damage;
			if( currentShield < 0 )
			{
				DecreaseHealth( currentShield * -1, true, source );
				currentShield = 0;
			}
		}
		else
		{
			if( damage > 0 ) 
			{
				PlayBloodOnHit();
			}
			DecreaseHealth( damage, true, source );
		}
		UpdateHealthHud();
	}
	private function HitBlocked( hitParams : HitParams )
	{
		if ( !IsCriticalEffectApplied( CET_Knockdown ) )
		{
			if(hitParams.attackReflected && !hitParams.groupAttack)
			{
				TryToPerformBlockResponse( hitParams );
			}
			PlayEffect('shield_hit');
		}
		
		hitParams.damage = hitParams.attacker.GetCharacterStats().ComputeDamageOutputPhysical(false);
		if( currentShield > 0 && hitParams.damage > 0 )
		{
			PlayEffect('shield_hit');
			currentShield -= hitParams.damage;
			if( currentShield < 0 )
			{
				DecreaseHealth( currentShield * -1, hitParams.lethal, hitParams.attacker );
				currentShield = 0;
			}
		}
		else
		{
			hitParams.damage = CalculateDamage(hitParams.attacker, this, false, false, false, true, 1.0, false, false);
			if( hitParams.damage > 0 ) 
			{
				PlayBloodOnHit();
				PlayBloodyFXOnWeapon(hitParams.attacker, this);
			}
			DecreaseHealth( hitParams.damage, hitParams.lethal, hitParams.attacker );
		}
		UpdateHealthHud();
		DecreaseStamina( 0.25 );
		if (GetStamina() < 1.00)
		{
			OnBlockRelease();
		}
	}
	
	function PlayerInRange( rangeNameString : string ) : bool
	{
		var range : CInteractionAreaComponent;

		range = (CInteractionAreaComponent)GetComponent( rangeNameString );
		
		if( range )
		{
			return range.ActivationTest( thePlayer );
		}
		else
		{
			Log( "DRAUG BOSS ERROR: No -- "+ rangeNameString +" -- CInteractionAreaComponent in draug entity" );
			return false;			
		}			
	}
}

/*
	entry function ActionAttackDistant(arrowsAttackTime : float)
	{
		var projectileShooter : CDraugProjectilesShooter;
		var random : int;
		var rocksAttack : bool;
		parent.DistantAttackCooldown(parent.distantAttackCooldownDefault);
		rocksAttack = false;
		if(parent.currentDraugState == DS_TwoHanded)
		{
			if(!parent.rocksCooldown)
			{
				parent.RaiseForceEvent( 'Rock2H' );
				parent.WaitForBehaviorNodeDeactivation('RockEnd');
				projectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
				projectileShooter.DraugRocks(2);
				parent.RocksAttackCooldown(parent.rockCooldownDefault);
				parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
				parent.DistantAttackCooldown(parent.distantAttackCooldownDefault);
				DraugUpdate();
			}
			else
			{
				DraugMoveToPlayer();
			}
		
		}
		else
		{
			projectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
			if(!parent.arrowsCooldown || !parent.rocksCooldown)
			{
				parent.DraugSetImmortal(true);
				if(parent.InAttackRange(thePlayer))
				{
					parent.RaiseForceEvent( 'ArrowsStartClose' );
				}
				else
				{
					parent.RaiseForceEvent( 'ArrowsStart' );
				}
				parent.WaitForBehaviorNodeDeactivation('CoverLoop');
				random = Rand(2);
				if(random == 0 && !parent.rocksCooldown)
				{
					rocksAttack = true;
					projectileShooter.DraugRocks(10);
					//rocksAttack = false;
					//projectileShooter.DraugArrows();
				}
				else if(!parent.arrowsCooldown)
				{
					rocksAttack = false;
					projectileShooter.DraugArrows();
					//rocksAttack = true;
					//projectileShooter.DraugRocks(10);
				}
				parent.distantAttackSwitch = true;
				parent.StartTimeCounting();
				while(parent.distantAttackSwitch)
				{
					Sleep(0.1);
					if(parent.PlayerInRange("CLOSE_ATTACK"))
					{
						parent.RaiseEvent('CoverAttack');
						parent.WaitForBehaviorNodeDeactivation('AttackEnd');
					}
					if(parent.CheckTimePassed(arrowsAttackTime))
					{
							parent.distantAttackSwitch = false;
					}
				}
				parent.RaiseEvent( 'ArrowsStop' );
				parent.WaitForBehaviorNodeDeactivation ( 'ArrowsEnd' );	
				if(rocksAttack)
				{
					parent.RocksAttackCooldown(parent.rockCooldownDefault);
				}
				else
				{
					parent.ArrowsAttackCooldown(parent.arrowsCooldownDefault);
				}
				parent.SpecialAttackForceCooldown(parent.specialAttackCooldownDefault);
				parent.DistantAttackCooldown(parent.distantAttackCooldownDefault);
				parent.DraugSetImmortal(false);
				DraugUpdate();
			}
			else
			{
					DraugMoveToPlayer();
			}
		}
	}
*/