/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Critical Effects
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// ECriticalEffectType
/////////////////////////////////////////////////////////////////////
enum ECriticalEffectType
{
	CET_Poison,
	CET_Laming,
	CET_Bleed,
	CET_Burn,
	CET_Knockdown,
	CET_Disarm,
	CET_Drunk,
	CET_Immobile,
	CET_Fear,
	CET_Stun,
	CET_Blind,
	CET_Unbalance,
	CET_Falter,
	CET_Freeze,
	CET_MAX	// Must be last
}

// for what reason second enum?
enum ECrtiticalState
{
	CST_None,
	CST_Burn,
	CST_Knockdown,
	CST_Falter,
	CST_Blind,
	CST_Unbalance,
	CST_Drunk,
	CST_Stun,
	CST_Immobile,
	CST_Fear,
	CST_Freeze
};


/////////////////////////////////////////////////////////////////////
// W2CriticalEffectsManager
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectsManager extends CObject
{
	var prototypes : array< W2CriticalEffectBase >;
	
	function Initialize()
	{		
		prototypes.Grow( CET_MAX );
		
		// Poison
		prototypes[CET_Poison] = new W2CriticalEffectPoison in this;
		prototypes[CET_Poison].Reset();
		
		// Laming (slowdown)
		prototypes[CET_Laming] = new W2CriticalEffectLaming in this;
		prototypes[CET_Laming].Reset();
		
		// Bleed
		prototypes[CET_Bleed] = new W2CriticalEffectBleed in this;
		prototypes[CET_Bleed].Reset();
		
		// Burn
		prototypes[CET_Burn] = new W2CriticalEffectBurn in this;
		prototypes[CET_Burn].Reset();
		
		// Knockdown
		prototypes[CET_Knockdown] = new W2CriticalEffectKnockdown in this;
		prototypes[CET_Knockdown].Reset();
		
		// Disarm
		prototypes[CET_Disarm] = new W2CriticalEffectDisarm in this;
		prototypes[CET_Disarm].Reset();
		
		// Falter
		prototypes[CET_Falter] = new W2CriticalEffectFalter in this;
		prototypes[CET_Falter].Reset();
		
		// Blind
		prototypes[CET_Blind] = new W2CriticalEffectBlind in this;
		prototypes[CET_Blind].Reset();
		
		// Unbalance
		prototypes[CET_Unbalance] = new W2CriticalEffectUnbalance in this;
		prototypes[CET_Unbalance].Reset();
		
		// Drunk
		prototypes[CET_Drunk] = new W2CriticalEffectDrunk in this;
		prototypes[CET_Drunk].Reset();
		
		// Stun
		prototypes[CET_Stun] = new W2CriticalEffectStun in this;
		prototypes[CET_Stun].Reset();
		
		// Immobile
		prototypes[CET_Immobile] = new W2CriticalEffectImmobile in this;
		prototypes[CET_Immobile].Reset();
		
		// Fear
		prototypes[CET_Fear] = new W2CriticalEffectFear in this;
		prototypes[CET_Fear].Reset();
		
		// Freeze
		prototypes[CET_Freeze] = new W2CriticalEffectFreeze in this;
		prototypes[CET_Freeze].Reset();
	}
	
	function AbilityTest( attacker, defender : CActor, crtName, resName : name ) : bool
	{
		var a,b,c,r : float;
		if(defender == thePlayer)
		{
			if(thePlayer.activeQuenSign)
			{
				return false;
			}
		}
		if( attacker )
		{
			a = attacker.GetCharacterStats().GetFinalAttribute( crtName );
		}
		else
		{
			a = 1;
		}
		b = defender.GetCharacterStats().GetFinalAttribute( resName );
		c = MaxF( a - b, 0 );
		c = MinF( c, 1.0 );
		r = RandRangeF( 0.0, 1.0 );
		if( c == 0.0 )
			return false;
		else
			return (c >= r);
	}
	
	private final function GetEffectPrototype( effectType : ECriticalEffectType ) : W2CriticalEffectBase
	{
		return prototypes[effectType];
	}
	
	final function ApplyEffect( effectType : ECriticalEffectType, actor, attacker : CActor, duration : float, optional playerSource : bool ) : bool 
	{
		var i : int;
		var effectParams : W2CriticalEffectParams;
		var effect, clonedEffect : W2CriticalEffectBase;
		
		if(duration > 0)
		{
			effectParams.durationMax = duration;
			effectParams.durationMin = 0.75*effectParams.durationMax;
		}
		if(actor.IsCriticalEffectApplied(effectType))
		{
			return false;
		}
		if(effectType == CET_Stun || effectType == CET_Knockdown)
		{
			if(!actor.CanBeFinishedOff(attacker))
			{
				return false;
			}
		}
		if(actor == thePlayer)
		{
			if(effectType != CET_Burn && effectType != CET_Bleed && effectType != CET_Poison && effectType != CET_Freeze)
			{
				return false;
			}
			if(thePlayer.activeQuenSign)
			{
				return false;
			}
			if(thePlayer.IsAnyCriticalEffectApplied())
			{
				return false;
			}
		}
		//if ( actor == thePlayer ) theHud.m_hud.ShowTutorial("tut16", "tut202_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//if ( actor == thePlayer ) theHud.ShowTutorialPanelOld( "tut16", "tut202_333x166" );
		
		// If already present reset
		for( i=actor.criticalEffects.Size()-1; i>=0; i-=1 )
		{
			effect = actor.criticalEffects[i]; 
			if( effect.GetType() == effectType )
			{
				if( AbilityTest( attacker, actor, effect.GetEffectName(), effect.GetEffectResName() ) )
				{
					if(actor == thePlayer)
					{
						if(effectType == CET_Burn)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burn") + "</span>. ");
						}
						else if(effectType == CET_Bleed)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleed") + "</span>. ");
						}
						else if(effectType == CET_Poison)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poison") + "</span>. ");
						}
					}
					else if(playerSource)
					{
						if(effectType == CET_Burn)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burng") + " </span>. ");
						}
						else if(effectType == CET_Poison)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poisong") + " </span>. ");
						}
						else if(effectType == CET_Bleed)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleedg") + " </span>. ");
						}
						else if(effectType == CET_Stun)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_stung") + " </span>. ");
						}
						else if(effectType == CET_Knockdown)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_knockdowng") + " </span>. ");
						}
						else if(effectType == CET_Freeze)
						{
							theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_freezeg") + " </span>. ");
						}
					}
					if(playerSource)
					{
						effectParams.attacker = thePlayer;
					}
					else
					{
						effectParams.attacker = attacker;
					}
					effect.Reset();
					effect.SetParams(effectParams);
					effect.RestartEffect();
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		effect = GetEffectPrototype( effectType );
		if( effect )
		{
			if( AbilityTest( attacker, actor, effect.GetEffectName(), effect.GetEffectResName() ) )
			{
				if(actor == thePlayer)
				{
					if(effectType == CET_Burn)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burn") + "</span>. ");
					}
					else if(effectType == CET_Bleed)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleed") + "</span>. ");
					}
					else if(effectType == CET_Poison)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poison") + "</span>. ");
					}
				}
				else if(playerSource)
				{
					if(effectType == CET_Burn)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burng") + " </span>. ");
					}
					else if(effectType == CET_Poison)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poisong") + " </span>. ");
					}
					else if(effectType == CET_Bleed)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleedg") + " </span>. ");
					}
					else if(effectType == CET_Stun)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_stung") + " </span>. ");
					}
					else if(effectType == CET_Knockdown)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_knockdowng") + " </span>. ");
					}
					else if(effectType == CET_Freeze)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_freezeg") + " </span>. ");
					}
				}
				if(playerSource)
				{
					effectParams.attacker = thePlayer;
				}
				else
				{
					effectParams.attacker = attacker;
				}
				clonedEffect = (W2CriticalEffectBase)effect.Clone( actor );
				actor.criticalEffects.PushBack( clonedEffect );
				clonedEffect.SetParams(effectParams);
				clonedEffect.StartEffect();
				actor.OnCriticalEffectsChanged();
				return true;
			}
		}

		return false;
	}
	
	final function ForceEffect( effectType : ECriticalEffectType, actor : CActor, params : W2CriticalEffectParams, optional playerSource : bool) : bool 
	{
		var i : int;
		var effect, clonedEffect : W2CriticalEffectBase;
		if(actor.IsCriticalEffectApplied(effectType))
		{
			return false;
		}
		if(effectType == CET_Stun || effectType == CET_Knockdown)
		{
			if(!actor.CanBeFinishedOff(NULL))
			{
				return false;
			}
		}
		if(actor == thePlayer)
		{

			if(effectType != CET_Burn && effectType != CET_Bleed && effectType != CET_Poison && effectType != CET_Freeze)
			{
				return false;
			}
			if(thePlayer.activeQuenSign)
			{
				return false;
			}
		}
		//if ( actor == thePlayer ) theHud.m_hud.ShowTutorial("tut16", "tut202_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//if ( actor == thePlayer ) theHud.ShowTutorialPanelOld( "tut16", "tut202_333x166" );
		
		// If already present reset
		for( i=actor.criticalEffects.Size()-1; i>=0; i-=1 )
		{
			effect = actor.criticalEffects[i]; 
			if( effect.GetType() == effectType )
			{				
			
				if(actor == thePlayer)
				{
					if(effectType == CET_Burn)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burn") + "</span>. ");
					}
					else if(effectType == CET_Bleed)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleed") + "</span>. ");
					}
					else if(effectType == CET_Poison)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poison") + "</span>. ");
					}
				}
				else if(playerSource)
				{
					if(effectType == CET_Burn)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burng") + " </span>. ");
					}
					else if(effectType == CET_Poison)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poisong") + " </span>. ");
					}
					else if(effectType == CET_Bleed)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleedg") + " </span>. ");
					}
					else if(effectType == CET_Stun)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_stung") + " </span>. ");
					}
					else if(effectType == CET_Knockdown)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_knockdowng") + " </span>. ");
					}
					else if(effectType == CET_Freeze)
					{
						theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_freezeg") + " </span>. ");
					}
				}
				if(playerSource)
				{
					params.attacker = thePlayer;
				}
				effect.Reset();
				effect.SetParams( params );
				return true;
			}
		}
		
		effect = GetEffectPrototype( effectType );
		if( effect )
		{
			if(actor == thePlayer)
			{
				if(effectType == CET_Burn)
				{
					AddStoryAbilityCounter("story_s11", 1, 15);
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burn") + "</span>. ");
				}
				else if(effectType == CET_Bleed)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleed") + "</span>. ");
				}
				else if(effectType == CET_Poison)
				{
					AddStoryAbilityCounter("story_s18", 1, 15);
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poison") + "</span>. ");
				}
			}
			else if(playerSource)
			{
				if(effectType == CET_Burn)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_burng") + " </span>. ");
				}
				else if(effectType == CET_Poison)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_poisong") + " </span>. ");
				}
				else if(effectType == CET_Bleed)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_bleedg") + " </span>. ");
				}
				else if(effectType == CET_Stun)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_stung") + " </span>. ");
				}
				else if(effectType == CET_Knockdown)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_knockdowng") + " </span>. ");
				}
				else if(effectType == CET_Freeze)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt("cl_freezeg") + " </span>. ");
				}
			}
			if(playerSource)
			{
				params.attacker = thePlayer;
			}
			clonedEffect = (W2CriticalEffectBase)effect.Clone( actor );
			clonedEffect.SetParams( params );
			actor.criticalEffects.PushBack( clonedEffect );
			actor.OnCriticalEffectsChanged();			
			clonedEffect.StartEffect();
			return true;
		}

		return false;
	}
	
	
	// Custom checking effects
	final function CheckShieldShatter( attacker, defender : CActor ) : bool
	{
		return ( defender.GetHealth() < 30.0 && AbilityTest( attacker, defender, 'crt_shieldshatter', 'res_shieldshatter' ) );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectParams
/////////////////////////////////////////////////////////////////////
struct W2CriticalEffectParams
{
	var damageMin : float;
	var damageMax : float;
	var durationMin : float;
	var durationMax : float;
	var attacker : CActor;
}

/////////////////////////////////////////////////////////////////////
// W2CriticalEffect
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectBase extends CObject
{
	saved var type 			: ECriticalEffectType;
	saved var effectName 	: name;
	saved var effectResName : name;
	saved var duration 		: float;
	saved var damage 		: float;
	saved var actor			: CActor;
	saved var ttl 			: float;		
	saved var started		: bool; // is effect already started - used in load game
	default started = false;
	
	function GetType() : ECriticalEffectType { return type; }
	function GetEffectName() : name { return effectName; }	
	function GetEffectResName() : name { return effectResName; }
	function GetDuration() : float { return duration; }
	function GetTTL() : float { return ttl; }
	
	function GetStandardParams() : W2CriticalEffectParams
	{
		var params : W2CriticalEffectParams;
		var durationAttr : name;
		var damageAttr : name;
		
		if(this.GetType() == CET_Burn)
		{
			durationAttr = 'burn_time';
			damageAttr = 'burn_damage';
		}
		else if(this.GetType() == CET_Poison)
		{
			durationAttr = 'poison_time';
			damageAttr = 'poison_damage';
		}
		else if(this.GetType() == CET_Bleed)
		{
			durationAttr = 'bleed_time';
			damageAttr = 'bleed_damage';
		}
		else if(this.GetType() == CET_Stun)
		{
			durationAttr = 'stun_time';
			damageAttr = '';
		}
		else if(this.GetType() == CET_Knockdown)
		{
			durationAttr = 'knockdown_time';
			damageAttr = '';
		}
		else if(this.GetType() == CET_Immobile)
		{
			durationAttr = 'immobile_time';
			damageAttr = '';
		}
		else if(this.GetType() == CET_Freeze)
		{
			durationAttr = 'freeze_time';
			damageAttr = '';
		}
		params.durationMax = thePlayer.GetCharacterStats().GetAttribute(durationAttr);
		params.durationMin = 0.5*params.durationMax;
		params.damageMax = thePlayer.GetCharacterStats().GetAttribute(damageAttr);
		params.damageMin = 0.5*params.damageMax;
		return params;
	}
	function SetParams( params : W2CriticalEffectParams )
	{
		var standardParams : W2CriticalEffectParams = GetStandardParams();
		if(params.durationMin == 0 && params.durationMax == 0)
		{
			params.durationMin = standardParams.durationMin;
			params.durationMax = standardParams.durationMax;
		}
		if(params.damageMin == 0 && params.damageMax == 0)
		{
			params.damageMin = standardParams.damageMin;
			params.damageMax = standardParams.damageMax;
		}
		duration = RandRangeF( params.durationMin, params.durationMax );
		damage = RandRangeF( params.damageMin, params.damageMax );
		
		damage = damage*theGame.GetCriticalDamageDifficultyLevelMult(this.GetActor());
		actor = params.attacker;
		ttl = duration;
	}
			
	// Update effect, returns true if finished
	function Update( timeDelta : float ) : bool
	{
		ttl -= timeDelta;
		if(this.GetActor() == thePlayer && thePlayer.activeQuenSign)
		{
			EndEffect();
			return true;
		}
		if( ttl <= 0.0 )
		{
			EndEffect();
			return true;
		}
		
		return false;
	}
	
	// Deal damage
	function DealDamage( timeDelta : float, multiplier : float )
	{
		var dmg : float; 
		var npcDefender : CActor = GetActor();
		var dmgPerSec : float;
		var vitalityRegenName : name;
		var damagePercentage : float;
		vitalityRegenName = 'vitality_regen';
		
		if(actor.IsInCombat())
		{
			vitalityRegenName = 'vitality_combat_regen';
		}
		damagePercentage = 0.01*damage;
		dmgPerSec = npcDefender.GetCharacterStats().GetFinalAttribute('vitality')*damagePercentage;
		dmg = dmgPerSec*timeDelta*multiplier + npcDefender.GetCharacterStats().GetFinalAttribute(vitalityRegenName)*timeDelta;
		//Should burning effect kill player?
		//if( actor == thePlayer )
		//{
		//	dmg = MinF( dmg, thePlayer.GetHealth() - 5.0 );
		//	dmg = MaxF( dmg, 0.0 );
		//}
		
		if(npcDefender == thePlayer)
		{
			if(thePlayer.GetCurrentPlayerState() == PS_Cutscene)
			{
				return;
			}
		}
	
		npcDefender.DecreaseHealth( dmg, true, actor );
	}
	
	function GetActor() : CActor { return (CActor)GetParent(); }
	function GetNPC() : CNewNPC { return (CNewNPC)GetParent(); }
	
	abstract function Reset();
	
	abstract function StartGoal();
	abstract function StopGoal();
	
	// starts new effect
	function StartEffect()
	{
		// reset parameters on the first start
		// don't do that on load game when effects are restored
		if ( !started )
		{
			ttl = duration;
		}
		
		if( !GetActor().OnCriticalEffectStart( type, duration  ) )
		{
			if( GetActor() != thePlayer )
			{
				StartGoal();
			}
		}
		
		started = true;
	}
	
	// restarts effect if it is applied once again (before it ends)
	function RestartEffect()
	{
		GetActor().OnCriticalEffectRestart( type, duration );
	}
	
	function EndEffect()
	{
		if( !GetActor().OnCriticalEffectStop( type ) )
		{
			if( GetActor() != thePlayer )
			{
				StopGoal();
			}
		}
		
		started = false;
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectPoison
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectPoison extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Poison;
		this.effectName = 'crt_poison';
		this.effectResName = 'res_poison';		
		//this.ttl = duration;
	}

	function Update( timeDelta : float ) : bool
	{
		DealDamage( timeDelta, 1.0 );	
		return super.Update( timeDelta );
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		
		if( actor == thePlayer )
		{
			theCamera.PlayEffect('poison');
		}
		else
			actor.PlayEffect( 'poison' );
		
		super.StartEffect();
	}
	
	function EndEffect()
	{
		var actor : CActor = GetActor();
		
		if( actor == thePlayer )
		{
			theCamera.StopEffect('poison');
		}
		else
			actor.StopEffect( 'poison' );
			
		super.EndEffect();
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectLaming
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectLaming extends W2CriticalEffectBase
{	
	saved private var oldModification : EMoveTypeModification;

	function Reset()
	{
		this.type = CET_Laming;
		this.effectName = 'crt_laming';
		this.effectResName = 'res_laming';
		this.duration = 10.0;
		this.ttl = duration;
	}

	function StartEffect()
	{
		var actor : CActor = GetActor();
		var npc : CNewNPC = GetNPC();
		var combatEventsProxy : W2CombatEventsProxy;
		
		oldModification = actor.GetMoveTypeModification();
		actor.SetMoveTypeModification( MTM_AlwaysWalk );
		//actor.GetRootAnimatedComponent().SetAnimationTimeMultiplier( 0.5 );
	
		if( npc )
		{
			combatEventsProxy = npc.GetCombatEventsProxy();
			combatEventsProxy.EnableCharge( false );
			combatEventsProxy.EnableCircle( false );
		}
		
		super.StartEffect();
	}
	
	function EndEffect()
	{
		var npc : CNewNPC = GetNPC();
		var combatEventsProxy : W2CombatEventsProxy;
	
		GetActor().SetMoveTypeModification( oldModification );
		//GetActor().GetRootAnimatedComponent().SetAnimationTimeMultiplier( 1.0 );		
		
		if( npc )
		{
			combatEventsProxy = npc.GetCombatEventsProxy();
			combatEventsProxy.EnableCharge( true );
			combatEventsProxy.EnableCircle( true );
		}

		super.EndEffect();
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectBleed
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectBleed extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Bleed;
		this.effectName = 'crt_bleed';
		this.effectResName = 'res_bleed';
		//this.ttl = duration;
	}

	function Update( timeDelta : float ) : bool
	{
		DealDamage( timeDelta, theGame.GetDifficultyLevelMult() );
		//GetActor().PlayBloodOnHit();
		return super.Update( timeDelta );
	}
	function StartEffect()
	{
		var actor : CActor = GetActor();
		actor.PlayEffect('bleeding');
		super.StartEffect();
	}
	
	function EndEffect()
	{
		var actor : CActor = GetActor();
		actor.StopEffect('bleeding');
		super.EndEffect();	
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectBurn
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectBurn extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Burn;
		this.effectName = 'crt_burn';
		this.effectResName = 'res_burn';
		//this.ttl = duration;
	}

	function Update( timeDelta : float ) : bool
	{		
		DealDamage( timeDelta, 1.0 );		
		return super.Update( timeDelta );
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		actor.PlayEffect('burning_fx');
		super.StartEffect();
	}
	
	function EndEffect()
	{
		var actor : CActor = GetActor();
		actor.StopEffect('burning_fx');
		super.EndEffect();	
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalBurn();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalBurn' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectKnockdown
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectKnockdown extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Knockdown;
		this.effectName = 'crt_knockdown';
		this.effectResName = 'res_knockdown';
		this.duration = 3.0;
		this.ttl = duration;
	}
	
	function StartGoal()
	{
		if(!GetActor().IsCriticalEffectApplied(CET_Stun))
		{
			GetNPC().GetArbitrator().AddGoalKnockdown();
		}
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalKnockdown' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectDisarm
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectDisarm extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Disarm;
		this.effectName = 'crt_disarm';
		this.effectResName = 'res_disarm';
		this.duration = 3.0;
		this.ttl = duration;
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		var currWeaponItemId : SItemUniqueId;
		var npc : CNewNPC;
		var currentCombatType : ECombatType;
		
		if ( actor == thePlayer ) return; // don't support player
		
		npc = (CNewNPC)actor;

		currentCombatType = npc.GetCurrentCombatType();
		if ( currentCombatType != CT_Fists )
		{
			// Drop item
			currWeaponItemId = actor.GetCurrentWeapon();
			if ( currWeaponItemId != GetInvalidUniqueId() )
			{
				actor.GetInventory().DropItem( currWeaponItemId );
			}
			
			// Disable combat type
			npc.DisableCombatType( currentCombatType, true, thePlayer );
		}
/*
		if ( currentCombatType == CT_Fists )
		{
		}
		else if ( currentCombatType == CT_Sword )
		{			
		}
		else if ( currentCombatType == CT_Dual )
		{
		}
		else if ( currentCombatType == CT_ShieldSword )
		{
		}
		else if ( currentCombatType == CT_TwoHanded )
		{
		}
		else if ( currentCombatType == CT_Bow )
		{
		}
*/
		super.StartEffect();
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectDrunk
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectDrunk extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Drunk;
		this.effectName = 'crt_drunk';
		this.effectResName = 'res_drunk';
		this.duration = 60.0;
		this.ttl = duration;
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		if( actor == thePlayer )
		{
			actor.AddTimer('DrunkTimer', 0.1, false);
			actor.AddTimer('DrunkTimerRemove', 60, false);
		}
		
		super.StartEffect();
	}

	function EndEffect()
	{
		var actor : CActor = GetActor();
		if( actor == thePlayer )
		{
			// TODO: stop fullscreen effect
		}		

		super.EndEffect();		
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalDrunk();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalDrunk' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectImmobile
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectImmobile extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Knockdown;
		this.effectName = 'crt_immobile';
		this.effectResName = 'res_immobile';
		this.duration = 10.0;
		this.ttl = duration;
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalImmobile();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalImmobile' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectFear
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectFear extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Fear;
		this.effectName = 'crt_fear';
		this.effectResName = 'res_fear';
		this.duration = 10.0;
		this.ttl = duration;
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalFear();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'AddGoalFear' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectStun
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectStun extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Stun;
		this.effectName = 'crt_stun';
		this.effectResName = 'res_stun';
		this.duration = thePlayer.GetCharacterStats().GetAttribute('stun_time');
		this.ttl = duration;
	}
	
	function StartEffect()
	{
		if(this.duration == 0.0)
		{
			this.duration = thePlayer.GetCharacterStats().GetAttribute('stun_time');
		}
		if(!GetActor().IsCriticalEffectApplied(CET_Knockdown))
		{
			GetActor().PlayEffect( 'stun_fx' );
			if( !GetActor().OnCriticalEffectStart( type, duration  ) )
			{
				if( GetActor() != thePlayer )
				{
					StartGoal();
				}
			}
		}
		super.StartEffect();
	}
	
	function EndEffect()
	{
		GetActor().StopEffect( 'stun_fx' );
		if( !GetActor().OnCriticalEffectStop( type ) )
		{
			if( GetActor() != thePlayer )
			{
				StopGoal();
			}
		}
		super.EndEffect();
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalStun();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalStun' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectBlind
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectBlind extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Blind;
		this.effectName = 'crt_blind';
		this.effectResName = 'res_blind';
		this.duration = 10.0;
		this.ttl = duration;
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		if( actor == thePlayer )
		{
			// TODO: play fullscreen effect only (do not take control)
			FullscreenBlurSetup(1);
		}
		else
		{
			super.StartEffect();
		}
	}

	function EndEffect()
	{
		var actor : CActor = GetActor();
		if( actor == thePlayer )
		{
			// TODO: stop fullscreen effect
			FullscreenBlurSetup(0);
		}
		else
		{
			super.EndEffect();
		}		
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalBlind();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalBlind' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectUnbalance
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectUnbalance extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Unbalance;
		this.effectName = 'crt_unbalance';
		this.effectResName = 'res_unbalance';
		this.duration = 3.0;
		this.ttl = duration;
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalUnbalance();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalUnbalance' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectFalter
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectFalter extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Falter;
		this.effectName = 'crt_falter';
		this.effectResName = 'res_falter';
		this.duration = 10.0;
		this.ttl = duration;
	}
	
	function StartGoal()
	{
		GetNPC().GetArbitrator().AddGoalFalter();
	}
	
	function StopGoal()
	{
		GetNPC().GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalFalter' );
	}
};

/////////////////////////////////////////////////////////////////////
// W2CriticalEffectFreeze
/////////////////////////////////////////////////////////////////////
class W2CriticalEffectFreeze extends W2CriticalEffectBase
{	
	function Reset()
	{
		this.type = CET_Freeze;
		this.effectName = 'crt_freeze';
		this.effectResName = 'res_freeze';
		this.duration = thePlayer.GetCharacterStats().GetAttribute('freeze_time');
		this.ttl = duration;
	}
	
	function StartEffect()
	{
		var actor : CActor = GetActor();
		if(this.duration == 0.0)
			this.duration = thePlayer.GetCharacterStats().GetAttribute('freeze_time');
		actor.PlayEffect('freezing_fx');
		actor.SetAnimationTimeMultiplier( 0.5f );
		//actor.GetRootAnimatedComponent().SetAnimationTimeMultiplier( 0.5 );
		super.StartEffect();
	}
	
	function EndEffect()
	{
		var actor : CActor = GetActor();
		actor.StopEffect('freezing_fx');
		actor.SetAnimationTimeMultiplier( 1.0f );
		super.EndEffect();
	}
};
