/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Igni sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////
class CIgniPhysicsExplosion extends CEntity
{
	var storedFxName1 : name;
	var storedFxName2 : name;
	function PlayExplosionFX(fxName1 : name, fxName2 : name)
	{
		storedFxName1 = fxName1;
		storedFxName2 = fxName2;
		this.AddTimer('DestuctionFX', 0.02, false);
	}
	timer function DestuctionFX(td : float)
	{
		this.PlayEffect(storedFxName1);
		this.PlayEffect(storedFxName2);
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
		this.StopEffect(storedFxName1);
		this.StopEffect(storedFxName2);
		this.AddTimer('DestroyFX', 3.0, false);
	}
}
class CIgniExplosionFX extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('DestroyFX', 5.0, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
}
class CWitcherSignIgni extends CRegularProjectile
{	
	editable var fadeoutTime				: float;
	editable var explosionFX				: CEntityTemplate;
	editable var explosionPhysics			: CEntityTemplate;
	var level								: int;
	var	target 								: CEntity;
	var explosionRange						: float;
	var igniBurnParams 						: W2CriticalEffectParams;
	
	function Initialize( caster : CActor, target : CEntity )
	{
		this.target = target;
		caster.PlayEffect('Igni_level0');
		fadeoutTime = 3.0;
		// initialize the projectile
		Init( caster );
		igniBurnParams.damageMax = thePlayer.GetCharacterStats().GetFinalAttribute('igni_burn_damage');
		if(igniBurnParams.damageMax <= 0.0)
		{
			igniBurnParams.damageMax = 5.0;
		}
		igniBurnParams.damageMin = 0.5*igniBurnParams.damageMax;
		igniBurnParams.durationMax = thePlayer.GetCharacterStats().GetFinalAttribute('igni_burn_duration');
		if(igniBurnParams.durationMax <= 0.0)
		{
			igniBurnParams.durationMax = 5.0;
		}
		igniBurnParams.durationMin = 0.75*igniBurnParams.durationMax;
		
		//theHud.m_hud.ShowTutorial("tut37", "tut37_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut37", "tut37_333x166" );
		
	}

	function GetCriticalEffectParams() : W2CriticalEffectParams
	{
		return igniBurnParams;
	}
	event OnProjectileInit()
	{
		var stats 			: CCharacterStats;
		stats = thePlayer.GetCharacterStats();
		this.level			= 0;
		if(stats.HasAbility('magic_s9_2'))
		{
			this.level	= 2;
			this.explosionRange = 2.5;
		}
		else if(stats.HasAbility('magic_s9'))
		{
			this.level	= 1;
			this.explosionRange = 1.0;
		}
		else
		{
			this.level	= 0;
			this.explosionRange = 0.0;
		}
		Activate();
	}
	
	// --------------------------------------------------------------------
	// private functions
	// --------------------------------------------------------------------	
	private function GetProjectileFxName( level : int ) : name
	{
		return StringToName( "fx_level" + level );
	}
	
	private function GetHitFxName( level : int ) : name
	{
		return StringToName( "Igni_hit_level" + level );
	}
	
	private function GetBurningFxName( level : int ) : name
	{
		return StringToName( "Igni_burn_level" + level );
	}
	
	private function VisualizeHit( entity : CEntity )
	{
		var explosion : CIgniExplosionFX;
		var explosionPhys : CIgniPhysicsExplosion;
		explosion = (CIgniExplosionFX)theGame.CreateEntity(this.explosionFX,this.GetWorldPosition(), this.GetWorldRotation());
		if(this.level == 2)
		{
			explosion.PlayEffect('hit_igni_lv2');
		}
		else if(this.level == 1)
		{
			explosion.PlayEffect('hit_igni_lv1');
		}
		else
		{
			explosion.PlayEffect('hit_igni_lv0');			
		}
		if(this.level >=1)
		{
			explosionPhys = (CIgniPhysicsExplosion)theGame.CreateEntity(this.explosionPhysics,this.GetWorldPosition(), this.GetWorldRotation());
			explosionPhys.PlayExplosionFX('destruction_fx', 'trail_fx');
		}
		
	}
	
	// Called when the projectile reaches its maximum travel distance
	event OnRangeReached( inTheAir : bool )
	{
		FadeOut();
	}
	function SetFadeOutTime(fadetime : float)
	{
		fadeoutTime = fadetime;
	}
}

///////////////////////////////////////////////////////////////////////////

state Active in CWitcherSignIgni
{
	var hitEntities : array<CEntity>;
	
	event OnEnterState()
	{
		hitEntities.Clear();
	}
	
	event OnLeaveState()
	{
		hitEntities.Clear();
	}
	
	entry function Activate()
	{		
		var projectileFxName : name;
		var stats 							: CCharacterStats;
		var speed 							: float;
		var strength 						: float;
		var range 							: float;
		var actor							: CActor;
		var targetPos 						: Vector;
		parent.caster.DecreaseStamina( 1.0 );
		
		// rotate towards the target

		actor = (CActor)parent.target;
		if(!actor || !actor.IsAlive())
		{
			actor = NULL;
		}
		// start the projectile
		stats = parent.caster.GetCharacterStats();
		speed = stats.GetAttribute( 'igni_speed' );
		strength = stats.GetAttribute( 'igni_damage' );
		range = stats.GetAttribute( 'igni_max_dist' ) * thePlayer.GetSignsPowerBonus(SPBT_Range);
		range = range;// - (parent.fadeoutTime * speed);
		//Sleep(0.2);
		CheckFireTriggers( range, speed );
		projectileFxName = parent.GetProjectileFxName( parent.level );
		targetPos = thePlayer.CalculateSignTarget(parent.target);
		parent.ShootProjectileAtPosition(0.0, speed, strength, targetPos, range);
		parent.PlayEffect( projectileFxName );
		parent.PlayEffect('move');
		if(VecDistance(parent.GetWorldPosition(), actor.GetWorldPosition()) < 1.5)
		{
			parent.OnProjectileCollision(actor.GetComponent("Character"), parent.GetWorldPosition(), Vector(0,0,0));
		}
	}
	
	private latent function CheckFireTriggers( range : float, speed : float )
	{
		var nodes	: array<CNode>;
		var i, size	: int;
		
		var trap	: CBaseTrap;
		var ddream	: CPetardDragonDream;
		var delay	: float;
		
		theGame.GetNodesByTag( 'TriggeredByFire', nodes );
		size = nodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			delay = CheckTriggeredNode( nodes[i], range );
			if( delay == -1 )
				continue;
			
			delay = delay / speed;
				
			if( nodes[i].IsA('CBaseTrap') )
			{
				trap = (CBaseTrap)nodes[i];
				trap.RemoteTriggerTrap(delay);
			}
			else if( nodes[i].IsA('CPetardDragonDream') )
			{
				ddream = (CPetardDragonDream)nodes[i];
				ddream.AddTimer('TriggerFireWithDelay', delay, false);
			}
		}
	}
	
	private function CheckTriggeredNode( node : CNode, range : float ) : float
	{
		var area : CInteractionAreaComponent;
		var heading : Vector;
		var i : float;
		var testPos : Vector;
		
		area = (CInteractionAreaComponent)((CEntity)node).GetComponent('FireTrigger');
		if( !area )
		{
			Log("TriggeredByFire entity doesn't have FireTrigger component.");
			return 0.0f;
		}
		
		if( parent.target )
		{
			heading = parent.target.GetWorldPosition() - parent.GetWorldPosition();
			heading.Z = 0;
			heading = VecNormalize( heading );
		}
		else
			heading = VecFromHeading( parent.caster.GetHeading() );
		
		testPos = parent.GetWorldPosition() + heading * 0.5f;
		for( i = range; i > 0; i -= 1 )
		{
			if( VecLength( testPos - area.GetWorldPosition() ) < area.GetRangeMax() + 0.5 )
			{
				return range - i;
			}
			
			if( i >= 1 )
			{
				testPos += heading;
			}
			else
			{
				testPos += heading * i;
			}
		}
		
		return -1;
	}
	
	// --------------------------------------------------------------------
	// damage dealing
	// --------------------------------------------------------------------
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{			
		var hitEntity 	: CEntity = collidingComponent.GetEntity();
		var itemEntity 	: CItemEntity;
		var actors		: array<CActor>;
		var enemy 		: CNewNPC;
		var size		: int;
		var i			: int;
		itemEntity = (CItemEntity)hitEntity;
		if(itemEntity)
		{
			hitEntity = itemEntity.GetParentEntity();
		}
		if ( hitEntities.Contains( hitEntity ) == false && hitEntity != thePlayer)
		{
			hitEntity.NotifySpellHit( parent.projectileName );
			hitEntity.HandleIgniHit( parent );
			parent.VisualizeHit( hitEntity );
			hitEntities.PushBack( hitEntity );
			if(hitEntity != thePlayer && !itemEntity )
			{
				parent.IgniBlocked();
			}
			if(parent.level >=1 )
			{
				GetActorsInRange( actors, parent.explosionRange, '', parent );
				size = actors.Size();
				for(i = 0; i< size; i += 1)
				{
					enemy = (CNewNPC)actors[i];
					if(enemy.GetAttitude(thePlayer) == AIA_Hostile)
					{
						if(enemy != hitEntity)
						{
							enemy.HandleIgniHit(parent);
						}
					}
				}
			}
		}
		
	}
	
};

///////////////////////////////////////////////////////////////////////////
state IgniBlocked in CWitcherSignIgni
{
	entry function IgniBlocked()
	{
		var projectileFxName : name;
		projectileFxName = parent.GetProjectileFxName( parent.level );
		parent.StopProjectile();
		parent.FadeOut();
		
	}
}
state Fading in CWitcherSignIgni
{
	entry function FadeOut()
	{		
		var projectileFxName : name;
		var stats 							: CCharacterStats;
		var	speed							: float;
		var range							: float;
		parent.SetFadeOutTime(5.0);	
		projectileFxName = parent.GetProjectileFxName( parent.level );
		//parent.StopProjectile();
		parent.StopEffect( projectileFxName );
		stats = parent.caster.GetCharacterStats();
		speed = stats.GetAttribute( 'igni_speed' );
		range = stats.GetAttribute( 'igni_max_dist' );
		parent.StopProjectile();
		//parent.ShootProjectileAtNode( 0, speed, 0, NULL, 10.0 );
		
		parent.AddTimer( 'FadeoutTimer', parent.fadeoutTime, false );
	}
	
	timer function FadeoutTimer( timeDelta : float )
	{	
		parent.RemoveTimer( 'FadeoutTimer' ); 
		parent.Destroy();
	}
};
