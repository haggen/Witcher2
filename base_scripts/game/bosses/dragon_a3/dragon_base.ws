enum EDragonLookat
{
	DL_Fast,
	DL_Slow
};

enum EDragonHitAnim
{
	DHA_Front,
	DHA_Left,
	DHA_Right
};

class CDragonA3Base extends CEntity
{
	private var dragonHead : CDragonHead;
	private var slowLookAtActive : bool;
	private var fastLookAtActive : bool;
	private var bloodEffectName : name;
	
	var dragonTower	: CDragonTower;
	var canBeAttacked : bool;
	var canDie : bool;
	
	default canBeAttacked = true;
	default canDie = false;
	
	function GetDragonHead() : CDragonHead
	{
		return dragonHead;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		dragonTower = (CDragonTower)theGame.GetEntityByTag('dragon_tower');
		if( !dragonTower )
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "!!!!!Dragon Tower doesn't exist!!!!! !!!!!THIS IS BAD AND AINT GONNA WORK!!!!!" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		}
			
		theHud.m_hud.SetBossName( dragonHead.GetDisplayName() );
		theHud.HudTargetActorEx( dragonHead, true );
		theHud.m_hud.SetBossHealthPercent( dragonHead.GetHealthPercentage() );
		theHud.m_hud.SetBossArmorPercent( 0.f );
	}
	
	function AttachDragonHead( attachedHead : CDragonHead )
	{
		dragonHead = attachedHead;
	}
	
	event OnDestroyed()
	{
		theHud.m_hud.HideBossHealth();
	}
	
	//PlayerInRange - checks if player is in specified dragon action range
	function PlayerInRange( rangeNameString : string ) : bool
	{
		var range : CInteractionAreaComponent;
		
		range = (CInteractionAreaComponent)this.GetComponent( rangeNameString );
		if( range )
		{
			return range.ActivationTest( thePlayer );
		}
		else
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "***********************************************************************************" );
			Log( "DRAGON BOSS ERROR: No -- "+ rangeNameString +" -- CInteractionAreaComponent in dragon entity" );
			Log( "***********************************************************************************" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return false;
		}			
	}
	
	function CalculateFireDamage() : float
	{
		var playerRes : float;
		
		playerRes = thePlayer.GetCharacterStats().GetFinalAttribute( 'res_burn' );
		
		return dragonHead.dragonDamageFirePerSecond * ( 1.0 - playerRes );
	}
	
	timer function FireCone( time : float )
	{		
		if( PlayerInRange( "FireAttack" ) )
		{
			thePlayer.KeepCombatMode();
		
			if(thePlayer.getActiveQuen())
			{
				thePlayer.getActiveQuen().FadeOut();
			}
	
			thePlayer.DecreaseHealth( CalculateFireDamage() * time, true, dragonHead );
			thePlayer.ApplyCriticalEffect( CET_Burn, dragonHead );
		}
	}

	//DragonLookatOn - turns lookat on. Dragon looks at Geralt.
	function DragonLookatOn( optional slow : bool )
	{
		if( slow )
		{
			if( fastLookAtActive )
			{
				this.GetRootAnimatedComponent().DeactivateAnimatedConstraint( "lookAtWeight" );
				fastLookAtActive = false;
			}
			
			if( !slowLookAtActive )
			{
				this.GetRootAnimatedComponent().ActivateBoneAnimatedConstraint( thePlayer, 'head', "lookAtSlow", "lookAt" );
				slowLookAtActive = true;
			}
		}
		else
		{
			if( slowLookAtActive )
			{
				this.GetRootAnimatedComponent().DeactivateAnimatedConstraint( "lookAtSlow" );
				slowLookAtActive = false;
			}
			
			if( !fastLookAtActive )
			{
				this.GetRootAnimatedComponent().ActivateBoneAnimatedConstraint( thePlayer, 'head', "lookAtWeight", "lookAt" );
				fastLookAtActive = true;
			}
		}
	}
	
	//DragonLookatOff - turns lookat off.
	function DragonLookatOff()
	{
		if( fastLookAtActive )
		{
			this.GetRootAnimatedComponent().DeactivateAnimatedConstraint( "lookAtWeight" );
			fastLookAtActive = false;
		}
		
		if( slowLookAtActive )
		{
			this.GetRootAnimatedComponent().DeactivateAnimatedConstraint( "lookAtSlow" );
			slowLookAtActive = false;
		}
	}
	
	function CheckCanBeAttacked() : bool
	{
		return canBeAttacked;
	}
	
	function HandleAardHit( aard : CWitcherSignAard )
	{
		var damage : float;
		var aardDamage, signsPower, resAard, signDamageBonus : float;
		
		aardDamage = thePlayer.GetCharacterStats().GetAttribute('aard_damage');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
		resAard = dragonHead.GetCharacterStats().GetAttribute('res_aard');
		resAard /= 100.0f;
		
		if(resAard > 1.0f)
			resAard = 1.0;
			
		damage = ( ( aardDamage * signsPower ) + signDamageBonus ) * ( 1 - resAard );
		
		if(damage <= 0)
		{
			damage = 5.0;
		}
		
		dragonHead.DecreaseHealth( damage, true, thePlayer );
		HitDragon();
		PlayHitAnim( true );
	}
	
	function HandleIgniHit( igni : CWitcherSignIgni )
	{
		var igniDamage : float;
		var signsPower : float;
		var signDamageBonus : float;
		var resIgni : float;
		var damage : float;
		
		igniDamage = thePlayer.GetCharacterStats().GetAttribute('igni_damage');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		signDamageBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
		resIgni = dragonHead.GetCharacterStats().GetAttribute('res_igni');
		resIgni /= 100.0f;
		
		if(resIgni > 1.0f)
			resIgni = 1.0f;
			
		damage = ( ( igniDamage * signsPower ) + signDamageBonus ) * ( 1 - resIgni );
		
		if(damage <= 0)
		{
			damage = 5.0;
		}
		
		dragonHead.DecreaseHealth( damage, true, thePlayer );
		HitDragon();
		PlayHitAnim( true );
	}
	
	function SetDragonHitEnum()
	{
		if( PlayerInRange("LeftHit") )
		{
			SetBehaviorVariable( 'hitEnum', (int)DHA_Left );
			bloodEffectName = 'right_blood_hit';
		}
		else if( PlayerInRange("RightHit") )
		{
			SetBehaviorVariable( 'hitEnum', (int)DHA_Right );
			bloodEffectName = 'left_blood_hit';
		}
		else
		{
			SetBehaviorVariable( 'hitEnum', (int)DHA_Front );
			bloodEffectName = 'front_blood_hit';
		}
	}
	
	function ActivateHit()
	{
		PlayEffect( bloodEffectName );
		SetBehaviorVariable( 'hitWeight', 1 );
		AddTimer( 'HitOverrideEnd', 0.3, false );
	}
	
	timer function HitOverrideEnd( time : float )
	{
		SetBehaviorVariable( 'hitWeight', 0 );
	}
	
	//MSz: functions that have to be overwritten in child classes
	function HitDragon() {}
	function PlayHitAnim( optional isSpell : bool ) {}
}
state Death in CDragonA3Base
{
	entry function DragonDeath();
}

//MSZ CDragonHead class used for dragon damage calculation and damage animations management
class CDragonHead extends CActor
{
	var dragon : CDragonA3Base;
	var dragonDamageFirePerSecond : float;
	
	function IsBoss() : bool
	{
		return true;
	}
	
	function IsMonster() : bool
	{
		return true;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.EnablePathEngineAgent(false);
		this.EnablePhysicalMovement(false);
		
		thePlayer.SetBigBossFight( true );
		
		if(!this.GetCharacterStats().HasAbility('DragonHeadA3'))
		{
			this.GetCharacterStats().AddAbility('DragonHeadA3');
		}
		
		dragonDamageFirePerSecond = GetCharacterStats().GetFinalAttribute( 'damage_fire_per_sec' );
		
		super.OnSpawned( spawnData );
	}
	
	function HitPlayer( attackType : name, hitPosition : Vector, optional dmgMultiplicator : float ) 
	{
		var damage : float;
		/*var hitParams : HitParams;
		
		hitParams.attacker = this;
		hitParams.attackType = attackType;
		hitParams.hitPosition = hitPosition;
		hitParams.impossibleToBlock = true;
		hitParams.forceHitEvent = true;*/
		
		if( dmgMultiplicator <= 0 )
			dmgMultiplicator = 1.0f;
		
		if( thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic )
		{
			dmgMultiplicator *= 7.0f;
		}
		
		damage = CalculateDamage( this, thePlayer, false, false, false, true, dmgMultiplicator );
		
		thePlayer.HitPosition( hitPosition, attackType, damage, true, this, true );
		
		//thePlayer.HitDamage( hitParams );
	}
	
	function AttachToDragon( attachedDragon : CDragonA3Base )
	{
		var mat : Matrix;
		mat = MatrixBuiltTranslation( Vector(0,0,-1) );
		ActivateBoneAnimatedConstraint( attachedDragon, 'muscle_head', "shiftWeight", "shift", true, mat );
		
		dragon = attachedDragon;
		attachedDragon.AttachDragonHead( this );
	}
	
	event OnBeingHit( out hitParams : HitParams )
	{
		if( dragon )
		{
			return dragon.CheckCanBeAttacked();
		}
		else
		{
			return false;
		}
	}
	
	private function HitDamage( hitParams : HitParams )
	{
		theSound.PlaySoundOnActor(this, '', "combat/weapons/hits/sword_hit");
		hitParams.outDamageMultiplier = 1.0f;
		
		super.HitDamage( hitParams );
		
		dragon.HitDragon();
		dragon.PlayHitAnim();
	}
	
	function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{
		theSound.PlaySoundOnActor(this, '', "combat/weapons/hits/sword_hit");
		super.HitPosition( hitPosition, attackType, damage, lethal, source, forceHitEvent, rangedAttack, magicAttack );
		
		dragon.HitDragon();
		dragon.PlayHitAnim();
	}
	
	private function EnterDead( optional deathData : SActorDeathData )
	{
		if( dragon.canDie )
			StateDead();
		else
		{
			SetHealth( 1, false, NULL );
		}
	}
	
	function DecreaseHealth( amount : float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData )
	{
		super.DecreaseHealth( amount, lethal, attacker, deathData );
		
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}
}

state CDragonHeadDefault in CDragonHead
{
	var isPlayingDamageAnim, canBeAttacked : bool;
	default isPlayingDamageAnim = false;
	default canBeAttacked = false;
	
	event OnEnterState()
	{
		parent.dragon = (CDragonA3Base)theGame.GetEntityByTag('dragon_a3');
	}
	
	entry function DragonHeadIdle()
	{
	
	}
}

state DragonHeadDead in CDragonHead
{
	var dragon : CDragonA3Base;
	entry function StateDead()
	{
		thePlayer.SetBigBossFight( false );
		theHud.m_hud.HideBossHealth();
		dragon = (CDragonA3Base)theGame.GetEntityByTag('dragon_a3');
		dragon.DragonDeath();
	}
}
