/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Quen sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////
class CQuenTarget extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		if (thePlayer.GetCharacterStats().HasAbility('story_s31_1' ) )
		{
			this.PlayEffect('quen_hit_fire');
		}
		else
		{
			this.PlayEffect('quen_hit');
		}
		this.AddTimer('StopFX', 3.0, false);
	}
	timer function StopFX(td : float)
	{
		this.StopEffect('quen_hit');
		this.StopEffect('quen_hit_fire');
		this.AddTimer('DestroyTarget', 3.0, false);
	}
	timer function DestroyTarget(td : float)
	{
		this.Destroy();
	}
}
class CQuenLightningBolt extends CEntity
{
	var quen : CWitcherSignQuen;
	var lastBoltTarget : CNewNPC;
	var lastTargets : array<CNewNPC>;
	var targetForced : bool;
	var forcedTarget : CNewNPC;
	var maxTargets : int;

	event OnSpawned(spawnData : SEntitySpawnData )
	{
		//Init();
		super.OnSpawned(spawnData);
	}
	function ForceTarget(target : CNewNPC)
	{
		targetForced = true;
		forcedTarget = target;
	}
	function Init(damage : float)
	{
		quen = thePlayer.getActiveQuen();
		if(quen)
		{
			BoltActivate(damage);
		}
		else
		{
			Destroy();
		}
	}
	function SetMaxTargets(newMaxTargets : int)
	{
		maxTargets = newMaxTargets;
	}
	function SetLastTarget(targets : array<CNewNPC>)
	{
		lastTargets = targets;
	}
	
};

state Active in CQuenLightningBolt
{
	function FindTarget() : CNewNPC
	{
		var actors : array<CActor>;
		var npc : CNewNPC;
		var size, i : int;
		GetActorsInRange( actors, 10.f, '', parent );
		size = actors.Size();
		if(size > 0)
		{
			for (i = 0; i < size; i += 1)
			{
				npc = (CNewNPC)actors[i];
				if(npc && npc.GetAttitude(thePlayer) == AIA_Hostile && !CheckLastTarget(npc))
				{
					
					return npc;
				}
			}
			return NULL;
		}
		else
		{
			return NULL;
		}
	}
	function DealDamageToTatget(target : CNewNPC, position : Vector, damageReceived : float)
	{
		var damage, damageBasic : float;
		var signDamageBonus : float;
		var signsPower : float;
		var resQuen : float;
		var quenBoltDamageMult : float;
		var quenBasicDmgInt, quenDmgInt, quenResInt : int;
		
		quenBoltDamageMult = thePlayer.GetCharacterStats().GetFinalAttribute('quen_bolt_damage');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		signDamageBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_signsbonus');
		resQuen = target.GetCharacterStats().GetFinalAttribute('res_quen');
		
		damageBasic = (damageReceived*quenBoltDamageMult)+signDamageBonus;
		damage = damageBasic*(1-resQuen);

		quenBasicDmgInt = RoundF(damageBasic);
		quenDmgInt = RoundF(damage);
		quenResInt = quenBasicDmgInt - quenDmgInt;
		if(quenResInt < 0)
		{
			quenResInt = 0;
		}
		if(damage <= 0 || target.HasMagicShield())
		{
			theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_quen" ) );
			damage = 0;
		}
		else
		{
			theHud.m_hud.CombatLogAdd("<span class='white'> " + GetLocStringByKeyExt("cl_quendmg") + " " + quenDmgInt + " (" + AddDamageIcon() + quenBasicDmgInt + " - " + AddArmorIcon() + quenResInt + ")</span>. ");
			target.HitPosition(position, 'Attack', damage, true);
		}
	}
	function CheckLastTarget(target : CNewNPC) : bool
	{
		var size, i : int;
		var checkResult : bool;
		checkResult = false;
		size = parent.lastTargets.Size();
		if(size > 0)
		{
			for(i = 0; i < size; i += 1)
			{
				if(target == parent.lastTargets[i])
				{
					checkResult = true;
				}
			}
		}
		return checkResult;
	}
	entry function BoltActivate(quenReceivedDamage : float)
	{
		var target : CNewNPC;
		var chainBolt : CQuenLightningBolt;
		var targetPos : Vector;
		var quenTarget : CQuenTarget;
		var quenExplosion : CExplosionFX;
		
		//Sleep(0.5);
		if(parent.targetForced)
		{
			target = parent.forcedTarget;
			parent.targetForced = false; 
		}
		else
		{
			target = FindTarget();
		}
		parent.quen = thePlayer.getActiveQuen();
		if(target && parent.quen)
		{
			if(parent.maxTargets > 0 )
			{
				targetPos = target.GetWorldPosition();
				targetPos.Z += 1.5;
				if( parent.quen.IsFireQuen())
				{
					parent.PlayEffect( 'bolt_hit_fire' );
					target.PlayEffect('fireball_hit_fx');
				}
				else
				{
					target.PlayEffect('hit_quen_lv1');
				}
				DealDamageToTatget(target, parent.GetWorldPosition(), quenReceivedDamage);
				quenTarget = (CQuenTarget)theGame.CreateEntity(parent.quen.GetTargetTemplate(), targetPos, target.GetWorldRotation());
				if(quenTarget)
				{
					if(VecDistance2D(parent.GetWorldPosition(), quenTarget.GetWorldPosition()) > 3.0)
					{
						if (thePlayer.GetCharacterStats().HasAbility('story_s31_1' ) )
						{
							parent.PlayEffect('quen_bolt_fire', quenTarget);
						}
						else
						{
							parent.PlayEffect('quen_bolt', quenTarget);
						}
					}
				}
				Sleep(0.3);
				targetPos = target.GetWorldPosition();
				targetPos.Z += 1.5;
				chainBolt = (CQuenLightningBolt)theGame.CreateEntity(parent.quen.GetBoltTemplate(), targetPos, target.GetWorldRotation());
				chainBolt.SetMaxTargets(parent.maxTargets - 1);
				parent.lastTargets.PushBack(target);
				chainBolt.SetLastTarget(parent.lastTargets);
				chainBolt.Init(quenReceivedDamage);
			}
		}
		//Sleep(1.0);
		parent.StopEffect('quen_bolt');
		parent.StopEffect('quen_bolt_fire');
		Sleep(1.0);
		parent.Destroy();
	}

}
class CQuenHitEffect extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		if ( thePlayer.GetCharacterStats().HasAbility('story_s31_1' ) )
		{
			this.PlayEffect('quen_hit_lv1_fire');
		}
		else
		{
			this.PlayEffect('quen_hit_lv1');
		}
		
		StopFX();
	}	

	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	function StopFX()
	{
		this.StopEffect('quen_hit_lv1');
		this.StopEffect('quen_hit_lv1_fire');
		this.AddTimer('DestroyFX', 5.0, false);
	}
}
class CWitcherSignQuen extends CEntity
{	
	var 			level			: int;
	editable var 	fadeoutTime 	: float;
	editable var 	hitEffectLvl1	: CEntityTemplate;
	editable var	quenBolt		: CEntityTemplate;
	editable var	quenTargetTmp	: CEntityTemplate;
	editable var	physicalFireHit : CEntityTemplate;
	
	var				totalDuration	: float;
	var				activationTime	: EngineTime;
	var 			durationDelta 	: float;
	var 			lastBoltTarget	: CNewNPC;
	var				maxTargets		: int;
	var 			chainBolt 		: CQuenLightningBolt;
	var 			targetPos 		: Vector;
	var 			npc 			: CNewNPC;
	var				receivedDamage	: float;
	var				fireQuen		: bool;
	
	function IsFireQuen() : bool
	{
		if (thePlayer.GetCharacterStats().HasAbility('story_s31_1' ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function SetLastBoltTarget(lastTarget : CNewNPC)
	{
		lastBoltTarget = lastTarget;
	}
	function GetLastBoltTarget() : CNewNPC
	{
		return lastBoltTarget;
	}
	function GetBoltTemplate() : CEntityTemplate
	{
		return quenBolt;
	}
	function GetTargetTemplate() : CEntityTemplate
	{
		return quenTargetTmp;
	}
	
	// -------------------------------------------------------------------
	// management
	// -------------------------------------------------------------------
	// Initializes the trap
	final function Init()
	{
		var stats : CCharacterStats;
		var signsPower : float;
		stats = thePlayer.GetCharacterStats();
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Time);
				
		if(stats.HasAbility('magic_s6_2'))
		{
			maxTargets = 3;
		}
		else if(stats.HasAbility('magic_s6'))
		{
			maxTargets = 2;
		}
		else
		{
			maxTargets = 1;
		}
		if(stats.HasAbility('magic_s5_2'))
		{
			level = 2;
		}
		else if(stats.HasAbility('magic_s5'))
		{
			level = 1;
		}
		else
		{
			level = 0;
		}
		thePlayer.setActiveQuen( this );
		
		totalDuration	= thePlayer.GetCharacterStats().GetAttribute( 'quen_duration' )*signsPower - fadeoutTime;
		activationTime	= theGame.GetEngineTime();
		durationDelta = 0.0f;
		Activate();
	}
	function SetReceivedDamage(damage : float)
	{
		if(level == 2)
		{
			receivedDamage = 0.5*damage;
		}
		else if(level == 1)
		{
			receivedDamage = 0.25*damage;
		}
		else
		{
			receivedDamage = 0;
		}
		
	}
	final function QuenHit(damage : float, hitParams : HitParams)
	{
		var timeDamage 	: float;
		var damageAbsorption : float;
		var stats : CCharacterStats;
		var signsPower : float;
		
		stats = thePlayer.GetCharacterStats();
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		
		SetReceivedDamage(damage);
		if(hitParams.attacker)
		{
			npc = (CNewNPC)hitParams.attacker;
		}
		damageAbsorption = stats.GetFinalAttribute('quen_damage_absorption');
		damage = damage / damageAbsorption;
		timeDamage =  damage;
		durationDelta += timeDamage;
		VisualiseHit(hitParams);
		if(GetTTL() <= 0.0f)
		{
			FadeOut();
		}
		else
		{
			DecreaseTime();
		}
		if(level == 0)
		{
			theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_quen" ) );
		}
		if(level > 0 && !hitParams.rangedAttack)
		{
			//Sleep(0.5);
			this.AddTimer('CreateLightning', 0.1, false);
			
		}
		
	}
	timer function CreateLightning(td : float)
	{
		this.RemoveTimer('CreateLightning');
		targetPos = thePlayer.GetWorldPosition();
		targetPos.Z += 1.5;
		chainBolt = (CQuenLightningBolt)theGame.CreateEntity(quenBolt, targetPos, thePlayer.GetWorldRotation());
		chainBolt.SetMaxTargets(maxTargets);
		if(npc)
		{
			chainBolt.ForceTarget(npc);
		}
		chainBolt.Init(receivedDamage);
	}
	final function GetTotalDuration() : float
	{
		return totalDuration;
	}
	final function GetTTL() : float
	{
		var ttl : float;
		ttl= totalDuration - EngineTimeToFloat( theGame.GetEngineTime() - activationTime ) - durationDelta;
		if(ttl <= 0.0f)
		{
			ttl = 0.0f;
		}
		return ttl;
	}
	
	// --------------------------------------------------------------------
	// private functions
	// --------------------------------------------------------------------	
	private function StopAllEffects()
	{
		thePlayer.StopEffect('Quen_level1');
		thePlayer.StopEffect('Quen_level0');
		thePlayer.StopEffect('Quen_level1_fire');
		thePlayer.StopEffect('Quen_level0_fire');
	}
	private function GetTrapFxName() : name
	{
		if( IsFireQuen() )
		{
			if(level >= 1)
			{
				return StringToName( "Quen_level1_fire");
			}
			else
			{
				return StringToName( "Quen_level0_fire");// + level );
			}
		}
		else
		{
			if(level >= 1)
			{
				return StringToName( "Quen_level1");
			}
			else
			{
				return StringToName( "Quen_level0");// + level );
			}
		}
	}
	
	private function GetHitFxName( level : int ) : name
	{
		if( IsFireQuen() )
		{
			return StringToName( "quen_hit_level0_fire");
		}
		else
		{
			return StringToName( "quen_hit_level0");// + level );
		}
	}
	
	function BurnEnemy( enemy : CActor )
	{
		var burnChance : float;
		
		burnChance = thePlayer.GetCharacterStats().GetAttribute( 'quen_burn_chance' );
		
		if( RandF() < burnChance )
		{
			enemy.ApplyCriticalEffect( CET_Burn, NULL );
		}
	}
	
	function VisualiseHit(hitParams : HitParams)
	{
		var spawnPos : Vector;
		var toTargetVec : Vector;
		var rotation : EulerAngles;
		var fxName 	: name = GetHitFxName( level );
		var quenFX : CQuenHitEffect;
		var explosionPhys : CIgniPhysicsExplosion;
		
		toTargetVec = hitParams.hitPosition - thePlayer.GetWorldPosition();
		rotation = VecToRotation(toTargetVec);
		thePlayer.StopEffect( fxName );
		thePlayer.PlayEffect( fxName );
		
		if( IsFireQuen() )
		{
			spawnPos = thePlayer.GetWorldPosition();
			spawnPos.Z += 0.6;
			explosionPhys = (CIgniPhysicsExplosion)theGame.CreateEntity(physicalFireHit, spawnPos, thePlayer.GetWorldRotation());
			explosionPhys.PlayExplosionFX('destruction_quen', 'trail_fx');
			BurnEnemy( hitParams.attacker );
		}
		if(this.level > 0.0)
		{
			spawnPos = thePlayer.GetWorldPosition();
			spawnPos.Z += 1.5;
			quenFX= (CQuenHitEffect)theGame.CreateEntity(hitEffectLvl1, spawnPos, rotation);
			if(hitParams.attacker && !hitParams.rangedAttack)
			{
				if( IsFireQuen() )
				{
					hitParams.attacker.PlayEffect('fireball_hit_fx');
				}
				else
				{
					hitParams.attacker.PlayEffect('hit_quen_lv1');
				}
				
				hitParams.attacker.OnAttackBlocked(hitParams);
			}
		}
	}
	
	event OnBlockingSceneStarted()
	{
	}
	
	event OnBlockingSceneEnded()
	{
	}
}

///////////////////////////////////////////////////////////////////////////

state Active in CWitcherSignQuen
{
	entry function Activate()
	{		
		var fxName 			: name	= parent.GetTrapFxName();
		var duration		: float	= parent.totalDuration - parent.fadeoutTime;

		parent.StopAllEffects();
		thePlayer.PlayEffect( fxName );

		parent.AddTimer( 'LifetimeCounter', parent.GetTTL(), false );
		
		thePlayer.DecreaseStamina(1.0);
		thePlayer.setActiveQuen( parent );
		//thePlayer.GetCharacterStats().AddAbility('QuenBuff');
		//theHud.m_hud.ShowTutorial("tut34", "tut34_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut34", "tut34_333x166" );
		
	}
	entry function DecreaseTime()
	{
		var duration		: float	= parent.totalDuration - parent.fadeoutTime - parent.durationDelta;

		parent.AddTimer( 'LifetimeCounter', parent.GetTTL(), false );
		
		thePlayer.setActiveQuen( parent );
	}
	
	// --------------------------------------------------------------------
	// lifetime management
	// --------------------------------------------------------------------
	timer function LifetimeCounter( timeElapsed : float )
	{		
		parent.RemoveTimer( 'LifetimeCounter' );
		parent.FadeOut();
	}
	
	event OnBlockingSceneStarted()
	{
		parent.StopAllEffects();
	}
	
	event OnBlockingSceneEnded()
	{
		thePlayer.PlayEffect( parent.GetTrapFxName() );
	}
	
};

///////////////////////////////////////////////////////////////////////////

state Fading in CWitcherSignQuen
{
	entry function FadeOut()
	{		
		var fxName : name;
		fxName = parent.GetTrapFxName();
		parent.StopAllEffects();
		
		thePlayer.GetCharacterStats().RemoveAbility('QuenBuff');
		
		parent.AddTimer( 'FadeoutTimer', parent.fadeoutTime, false );
	}
	
	timer function FadeoutTimer( timeDelta : float )
	{	
		parent.RemoveTimer( 'FadeoutTimer' ); 
		thePlayer.setActiveQuen( NULL );
		parent.Destroy();
	}
};
