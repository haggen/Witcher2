/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Yrden sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////

// This sign is responsible for managing the traps the player can 
// put on the ground.
class CYrdenExplosion extends CEntity
{
	var storedFxName : name;
	function PlayExplosionFX(fxName : name)
	{
		storedFxName = fxName;
		this.PlayEffect(fxName);
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('StopFX', 3.0, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(storedFxName);
		this.AddTimer('DestroyFX', 3.0, false);
	}
}
class CYrdenLink extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		
	}
	function LinkTo(yrden : CWitcherSignYrden)
	{
		var component : CComponent;
		component = yrden.GetComponent('LinkTarget');
		this.PlayEffect('yrden_link_fx', component);
	}
	function FadeOut()
	{
		this.StopEffect('yrden_link_fx');
		this.AddTimer('DestroyLink', 2.0, false);
	}
	timer function DestroyLink(td : float)
	{
		this.Destroy();
	}
}
class CYrdenTrigger extends CEntity
{
	var yrdenConnect1 : CWitcherSignYrden;
	var yrdenConnect2 : CWitcherSignYrden;
	function SetYrdenConection(yrden1 : CWitcherSignYrden, yrden2 : CWitcherSignYrden)
	{
		yrdenConnect1 = yrden1;
		yrdenConnect2 = yrden2;
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		//Init();
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var npc : CNewNPC;
		var areaName : string;
		var distance : float;
		var yrdenExplosion : CYrdenExplosion;
		var y1Pos, y2Pos, targetPos, explosionPos : Vector;
		
		activatorActor = (CActor) activator.GetEntity();
		areaName = area.GetName();
		if(activatorActor != thePlayer)
		{
			npc = (CNewNPC)activatorActor;
			if(npc && (npc.GetAttitude(thePlayer) == AIA_Hostile || npc.HasTag('yrdentarget')) && npc.IsAlive())
			{
				if(yrdenConnect1 && yrdenConnect2)
				{	
					targetPos = npc.GetWorldPosition();
					y1Pos = yrdenConnect1.GetWorldPosition();
					y2Pos = yrdenConnect2.GetWorldPosition();
					distance = VecDistance(y1Pos, y2Pos);
					if(VecDistance(y1Pos, targetPos) < distance && VecDistance(y2Pos, targetPos))
					{
						npc.HandleYrdenHit(yrdenConnect1);
						explosionPos = npc.GetWorldPosition();
						explosionPos.Z += 1.5;	
						yrdenExplosion = (CYrdenExplosion)theGame.CreateEntity(yrdenConnect1.GetExplosionTemplate(), explosionPos, npc.GetWorldRotation()); 
						yrdenExplosion.PlayExplosionFX(yrdenConnect1.GetExplosionFX());
						npc.PlayEffect(yrdenConnect1.GetFreezeFxName());
						yrdenConnect1.FadeOut();
						yrdenConnect2.FadeOut();
						
					}
				}
			}
		}
		
	}
	function FadeOut()
	{
		this.Destroy();
	}
}
class CWitcherSignYrden extends CEntity
{
	var 			caster				: CActor;
	var 			level				: int;
	var				immobileTime		: float;
	var 			yrdenTriggers		: array<CYrdenTrigger>;
	var 			yrdenLinks			: array<CYrdenLink>;
	var 			yrdensLinkedTo		: array<CWitcherSignYrden>;
	var 			linkDistance		: float;
	var 			size, i				: int;
	var 			fadeing				: bool;
	var 			yrdenExplosion		: CYrdenExplosion;
	editable var 	fadeoutTime 		: float;
	editable var	yrdenLinkTmpl		: CEntityTemplate;
	editable var	yrdenTriggerTmpl 	: CEntityTemplate;
	editable var	explosionTemplate	: CEntityTemplate;
	
	default linkDistance = 15.0;
	// -------------------------------------------------------------------
	// management
	// -------------------------------------------------------------------
	
	// Initializes the trap
	function GetYrdenDamage(npc : CNewNPC) : float
	{
		var damage : float;
		var signsPower : float;
		var resYrden : float;
		var damageSignsBonus : float;
		resYrden = npc.GetCharacterStats().GetFinalAttribute('res_yrden');
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Damage);
		damageSignsBonus = thePlayer.GetCharacterStats().GetAttribute('damage_signsbonus');
		damageSignsBonus = damageSignsBonus * 0.2; //damage will be applied per second
		if(resYrden > 1.0f)
			resYrden = 1.0f;
		
		damage = (thePlayer.GetCharacterStats().GetFinalAttribute('yrden_damage_per_sec')*signsPower + damageSignsBonus)*(1 - resYrden);
		return damage;
		
	}
	function GetYrdenLevel() : int
	{
		return level;
	}
	function GetExplosionTemplate() : CEntityTemplate
	{
		return explosionTemplate;
	}
	function SetFading(isfadeing : bool)
	{
		fadeing = isfadeing;
	}
	function GetIsFadeing() : bool
	{
		return fadeing;
	}
	function SetConnectedTo(yrdenToConnect : CWitcherSignYrden)
	{
		yrdensLinkedTo.PushBack(yrdenToConnect);
	}
	function SetLink(yrdenLink : CYrdenLink, yrdenTrigger : CYrdenTrigger)
	{
		yrdenLinks.PushBack(yrdenLink);
		yrdenTriggers.PushBack(yrdenTrigger);
	}
	function RemoveLink(yrdenLink : CYrdenLink, yrdenTrigger : CYrdenTrigger)
	{
		yrdenLinks.Remove(yrdenLink);
		yrdenTriggers.Remove(yrdenTrigger);
	}
	function DisconnectFromAllYrdens()
	{
		var size, sizeLinks, sizeTriggers, i, j : int;
		var yrdenLink : CYrdenLink;
		var yrdenTrigger : CYrdenTrigger;
		var yrden : CWitcherSignYrden;
		size = yrdensLinkedTo.Size();
		if(size > 0)
		{
			for (i = 0; i < size ; i += 1)
			{
				yrden = yrdensLinkedTo[i];
				if(yrden)
				{
					sizeLinks = yrdenLinks.Size();
					sizeTriggers = yrdenTriggers.Size();
					if(sizeLinks == sizeTriggers)
					{
						if(sizeLinks > 0)
						{
							for(j = 0; j < sizeLinks ; j += 1)
							{
								yrdenLink = yrdenLinks[j];
								yrdenTrigger = yrdenTriggers[j];
								yrden.RemoveLink(yrdenLink, yrdenTrigger);
								yrdenLink.FadeOut();
								yrdenTrigger.FadeOut();
							}
						}
					}
					else
					{
						Log("YRDEN ERROR : yrden links not equal to yrden triggers");
					}
				}
				
			}
		}
		
	}
	final function Init( caster : CActor )
	{
		var signsPower		: float;
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Time);
		
		this.caster = caster;
		if(thePlayer.GetCharacterStats().HasAbility('magic_s11_2'))
		{
			this.level = 2;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s11'))
		{
			this.level = 1;
		}
		else
		{
			this.level = 0;
		}
		
		this.immobileTime = thePlayer.GetCharacterStats().GetFinalAttribute('yrden_immobile_time')*signsPower;
		if(this.immobileTime <= 0.0)
		{
			this.immobileTime = 5.0;
		}
		Activate();
	}
	function GetImmobileTime() : float
	{
		return this.immobileTime;
	}
	// --------------------------------------------------------------------
	// private functions
	// --------------------------------------------------------------------	
	private function GetTrapFxName() : name
	{
		return StringToName( "fx_level" + level );
	}
	private function GetFreezeFxName() : name
	{
		return StringToName( "yrden_lv" + level + "_fx");
	}
	function GetExplosionFX() : name
	{
		return StringToName( "yrden_explosion_lv" + level);
	}
}

///////////////////////////////////////////////////////////////////////////

state Active in CWitcherSignYrden
{
	private var		affectedNPCs : array< CNewNPC >;
	
	function YrdenLinkTo(nearbyYrden : CWitcherSignYrden)
	{
		var yrdenLink : CYrdenLink;
		var yrdenTrigger : CYrdenTrigger;
		var triggerPosition, vecToYrden, parentPos, nearbyYrdenPos : Vector;
		var triggerRotation : EulerAngles;
		var vecRotation : Vector;
		var distanceToYrden : float;

		parentPos = parent.GetWorldPosition();
		nearbyYrdenPos = nearbyYrden.GetWorldPosition();
		distanceToYrden = VecDistance(parentPos, nearbyYrdenPos);
		vecToYrden = VecNormalize(nearbyYrdenPos - parentPos);
		vecRotation = VecNormalize(parentPos - nearbyYrdenPos);
		triggerPosition = parentPos + 0.5*distanceToYrden*vecToYrden;
		triggerRotation = VecToRotation(vecRotation);
		triggerRotation.Pitch = -triggerRotation.Pitch;
			
		yrdenTrigger = (CYrdenTrigger)theGame.CreateEntity(parent.yrdenTriggerTmpl, triggerPosition, triggerRotation);
		yrdenTrigger.SetYrdenConection(parent, nearbyYrden);
			
		yrdenLink = (CYrdenLink)theGame.CreateEntity(parent.yrdenLinkTmpl, parentPos, triggerRotation);
		yrdenLink.LinkTo(nearbyYrden);
		parent.SetLink(yrdenLink, yrdenTrigger);
		nearbyYrden.SetLink(yrdenLink, yrdenTrigger);
		parent.SetConnectedTo(nearbyYrden);
		nearbyYrden.SetConnectedTo(parent);
		
	}
	function ConnectToNearbyYrdens()
	{
		var size, i : int;
		var activeYrdens : array<CWitcherSignYrden>;
		var nearbyYrden : CWitcherSignYrden;
		var yrdenAPos, yrdenBPos : Vector;
		var component : CComponent;
		var pleaseIgnoreMe : Vector;
		activeYrdens = thePlayer.GetActiveYrdenTraps();
		size = activeYrdens.Size();
		if(size > 1)
		{
			for(i = 0; i < size; i += 1)
			{
				nearbyYrden = activeYrdens[i];
				if(nearbyYrden != parent && !nearbyYrden.GetIsFadeing())
				{
					if(VecDistance2D(nearbyYrden.GetWorldPosition(), parent.GetWorldPosition()) >= 3.0
						&& VecDistance2D(nearbyYrden.GetWorldPosition(), parent.GetWorldPosition()) <= parent.linkDistance)
					{
						yrdenAPos = parent.GetWorldPosition();
						yrdenBPos = nearbyYrden.GetWorldPosition();
						yrdenAPos.Z += 0.5;
						yrdenBPos.Z += 0.5;
						if(!theGame.GetWorld().StaticTrace(yrdenAPos, yrdenBPos, pleaseIgnoreMe, pleaseIgnoreMe))
						{
							YrdenLinkTo(nearbyYrden);
						}
					}
				}
			}
		}
		
	}
	entry function Activate()
	{		
		var fxName 			: name;
		var stats 			: CCharacterStats;
		var duration		: float;
		var signsPower		: float;
		
		
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Time);
		fxName = parent.GetTrapFxName();
		parent.PlayEffect( fxName );
		thePlayer.UpdateYrdenTrap(parent);
		
		stats = parent.caster.GetCharacterStats();
		duration = (float)stats.GetFinalAttribute( 'yrden_trap_duration' )*signsPower; // MATI TODO: 10
		parent.AddTimer( 'LifetimeCounter', duration, false );
		
		parent.caster.DecreaseStamina(1.0);
		
		if(thePlayer.GetCharacterStats().HasAbility('magic_s10'))
			ConnectToNearbyYrdens();
		//theHud.m_hud.ShowTutorial("tut35", "tut35_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut35", "tut35_333x166" );
	}
	
	// --------------------------------------------------------------------
	// damage dealing
	// --------------------------------------------------------------------
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity 	: CEntity;
		var affectedNPC 	: CNewNPC;
		var explosionPos	: Vector;
		var fxName 			: name;
		var i, count 		: int;
		
		affectedEntity = activator.GetEntity();
		affectedNPC = (CNewNPC)affectedEntity;
		if(!affectedNPC.HasTag('yrdentarget'))
		{
			if ( affectedNPC == parent.caster || affectedNPC.GetAttitude( thePlayer ) != AIA_Hostile || !affectedNPC.IsAlive())
			{
				return false;
			}
		}
		else if(!affectedNPC.IsAlive())
		{
			return false;
		}
		count = affectedNPCs.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( affectedNPCs[ i ] == affectedNPC )
			{
				return false;
			}
		}
		affectedNPCs.PushBack( affectedNPC );
		
		affectedNPC.NotifySpellHit( 'Yrden' );
		affectedNPC.HandleYrdenHit( parent );
			
		// visualize the hit
		//fxName = parent.GetHitFxName();
		//affectedNPC.PlayEffect( fxName );
			
		// PAKSAS TODO: (TEMP)freeze the enemy
		fxName = parent.GetFreezeFxName();
		affectedNPC.PlayEffect( fxName );
		explosionPos = affectedNPC.GetWorldPosition();
		explosionPos.Z += 1.5;
		parent.yrdenExplosion = (CYrdenExplosion)theGame.CreateEntity(parent.GetExplosionTemplate(), explosionPos, affectedNPC.GetWorldRotation()); 
		parent.yrdenExplosion.PlayExplosionFX(parent.GetExplosionFX());
		parent.FadeOut();
		
		//affectedNPC.GetArbitrator().AddGoalIncapacitate( 10.0, false );
	}
	
	// --------------------------------------------------------------------
	// lifetime management
	// --------------------------------------------------------------------
	timer function LifetimeCounter( timeElapsed : float )
	{
		parent.RemoveTimer( 'LifetimeCounter' );
		parent.FadeOut();
	}
	
};

///////////////////////////////////////////////////////////////////////////

state Fading in CWitcherSignYrden
{
	entry function FadeOut()
	{		
		var fxName : name;
		fxName = parent.GetTrapFxName();
		parent.DisconnectFromAllYrdens();
		parent.SetFading(true);
		parent.StopEffect( fxName );
		thePlayer.RemoveYrdenTrap(parent);	
		parent.AddTimer( 'FadeoutTimer', parent.fadeoutTime, false );
	}
	
	timer function FadeoutTimer( timeDelta : float )
	{	
		parent.RemoveTimer( 'FadeoutTimer' ); 
		parent.Destroy();
	}
};

