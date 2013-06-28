enum MagicProjectileType
{
	MPT_Toxic,
	MPT_Wind,
	MPT_Fire,
	MPT_Lightning,
	MPT_None
}
class CMagicProjectileSpawned extends CRegularProjectile
{
	editable var explosionFXTemplate : CEntityTemplate;
	editable var criticalEffectPercentage : int;
	editable var damageOnlyForPlayer : bool;
	editable var projectileType : MagicProjectileType;
	editable var hitActorFX : name;
	editable var optionalExcludeNPCTag : name;
	editable var stopsOnExplosion : bool;
	default stopsOnExplosion = true;
	default hitActorFX = 'fireball_hit_fx';
	default projectileType = MPT_None;
	default damageOnlyForPlayer = true;
	default criticalEffectPercentage = 25;
	
	event OnStartProjectile()
	{
		PlayEffect('projectile_fx');
	}
	function ProjectileDamage(actor : CActor, attackType: name)
	{
		var hitParams : HitParams;
		var damage, damageMin, damageMax : float;
		var actorPosition : Vector;
		var casterNPC : CNewNPC;
		var diceThrow : int;
		diceThrow = Rand(100) + 1;
		actorPosition = actor.GetWorldPosition();
		
		damage = RandRangeF( minDamage , maxDamage);
		hitParams.lethal = true;
		projectileHitPosition = actorPosition + VecNormalize(startPosition - actorPosition);
		hitParams.attackType = attackType;
		hitParams.hitPosition = projectileHitPosition;
		hitParams.attacker = caster;
		if(actor.IsAlive())
		{
			if(alwaysKillsTarget)
			{
				hitParams.damage = actor.GetHealth() + 10;
			}
			hitParams.damage = damage;
			actor.HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal);
			if(projectileType == MPT_Fire)
			{
				if(diceThrow > criticalEffectPercentage)
				{
					actor.PlayEffect(hitActorFX);
				}
				else
				{
					if(!actor.ApplyCriticalEffect(CET_Burn, caster))
					{
						actor.PlayEffect(hitActorFX);
					}
				}
			}
		}
	}
	function Explosion()
	{
		var attitude : bool;
		var actors : array<CActor>; 
		var actor : CActor;
		var size, i : int;
		var npc, actorNPC, hostileToPlayer : CNewNPC;
		var explosionTagValid : bool;
		GetActorsInRange(actors, 2.0, '', this);
		size = actors.Size();
		if(optionalExcludeNPCTag != '' && optionalExcludeNPCTag != 'None')
		{
			explosionTagValid = true;
		}
		else
		{
			explosionTagValid = false;
		}
		for(i = 0; i < size; i+=1)
		{
			actor = actors[i];
			if(actor == thePlayer)
			{
				ProjectileDamage(actor, 'Attack');
			}
			else if(!damageOnlyForPlayer)
			{
				if(!explosionTagValid || !actor.HasTag(optionalExcludeNPCTag))
				{
					ProjectileDamage(actor, 'Attack');
				}
			}
		}
		theGame.CreateEntity(explosionFXTemplate, this.GetWorldPosition(), this.GetWorldRotation());
		this.StopEffect('projectile_fx');
		this.AddTimer('DestroyFireball', 1.0, false);
		if(stopsOnExplosion)
			this.StopProjectile();
	}
	timer function DestroyFireball(td : float)
	{
		Destroy();
	}
	event OnRangeReached( inTheAir : bool )
	{
		Explosion();
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		Explosion();
	}
}
class CQuestMagicProjectile extends CRegularProjectile
{
	editable var explosionFXTemplate : CEntityTemplate;
	
	event OnStartProjectile()
	{
		PlayEffect('projectile_fx');
	}
	function Explosion()
	{
		var attitude : bool;
		var actors : array<CActor>; 
		var actor : CActor;
		var size, i : int;
		var npc, actorNPC, hostileToPlayer : CNewNPC;
		GetActorsInRange(actors, 2.0, '', this);
		size = actors.Size();
		theGame.CreateEntity(explosionFXTemplate, this.GetWorldPosition(), this.GetWorldRotation());
		this.StopEffect('projectile_fx');
		this.AddTimer('DestroyFireball', 1.0, false);
		this.Stop();
	}
	timer function DestroyFireball(td : float)
	{
		Destroy();
	}
	event OnRangeReached( inTheAir : bool )
	{
		Explosion();
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		
	}
}
class CMagicBoltColider extends CRegularProjectile
{
	editable var hitActorFX : name;
	default hitActorFX = 'fireball_hit_fx';	
	function ProjectileDamage(actor : CActor, attackType: name)
	{
		var hitParams : HitParams;
		var casterNPC : CNewNPC;
		var damage, damageMin, damageMax : float;
		var actorPosition : Vector;
		var component : CComponent;
		var target : CActor;
		var boneMtx	: Matrix;
		var node : CNode;
		var magicBolt : CMagicBolt;
		var hitEffectPosition : Vector;
		var item : SItemUniqueId;
		var npcActor : CNewNPC;
		npcActor = (CNewNPC)actor;
		target = actor;
		casterNPC = (CNewNPC)caster;
		component = target.GetComponent("fx point1");
		if(!component)
		{
			component = target.GetComponent("hit_point_fx");
		}
		if(component)
		{
			node = (CNode)component;
		}
		else
		{
			node = (CNode)target;
		}
		if(target.GetBoneIndex('pelvis') == -1)
		{
			hitEffectPosition = target.GetWorldPosition();
			hitEffectPosition.Z += 1.0;
		}
		else
		{
			boneMtx = target.GetBoneWorldMatrix('pelvis');
			hitEffectPosition = MatrixGetTranslation(boneMtx);
		}	
		actorPosition = actor.GetWorldPosition();
		
		item = casterNPC.GetInventory().GetItemByCategory('magic_bolts', false);
		magicBolt = (CMagicBolt)casterNPC.GetInventory().GetDeploymentItemEntity(item, hitEffectPosition, casterNPC.GetWorldRotation());
		target.PlayEffect(magicBolt.GetBoltActorHitFXName());
		
		damageMin = caster.GetCharacterStats().GetAttribute('ranged_damage_min');
		damageMax = caster.GetCharacterStats().GetAttribute('ranged_damage_max');
		damage = RandRangeF( damageMin , damageMax);
		if(damage <= 0)
			damage = RandRangeF( minDamage , maxDamage);
		hitParams.lethal = true;
		if(casterNPC.GetAttitude(actor) != AIA_Hostile)
		{
			damage = 0.0;
			hitParams.lethal = true;
		}
		projectileHitPosition = actorPosition + VecNormalize(startPosition - actorPosition);
		hitParams.attackType = attackType;
		hitParams.damage = damage;
		hitParams.hitPosition = projectileHitPosition;
		
		hitParams.attacker = caster;
		if(actor.IsAlive())
		{
			if(alwaysKillsTarget && casterNPC.GetAttitude(actor) == AIA_Hostile)
			{
				hitParams.damage = actor.GetHealth() + 10;
				actor.HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal);
			}
			else
			{
				actor.HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal);
			}
		}
	}
	event OnRangeReached( inTheAir : bool )
	{
		Destroy();
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var actor	: CActor;
		var npc, npcActor		: CNewNPC;
		var proj 	: CRegularProjectile; 
		var npcPostion, actorPosition, actorToNPCVec : Vector;
		var itemEntity : CItemEntity;
		var targetActor : CActor;
		var entity : CEntity = collidingComponent.GetEntity();
		
		itemEntity = (CItemEntity)entity;
		if(itemEntity )
		{
			actor = (CActor)itemEntity.GetParentEntity();
		}
		else
		{
			actor = (CActor)entity;
		}
		proj = this;
		targetActor = (CActor)targetEntity;
		if ( actor &&  (actor != targetActor)) 
		{
			npc = (CNewNPC) caster;
			npcActor = (CNewNPC)actor;
			npcPostion = npc.GetWorldPosition();
			if ( (actor != caster && npc.GetAttitude(actor) == AIA_Hostile) || actor != caster && npcActor.GetAttitude(thePlayer) == AIA_Hostile)
			{
				ProjectileDamage(actor, 'Attack');
			}
		}
		SetWillHitTarget( false );
	}

}
class CMagicProjectile extends CRegularProjectile
{
	editable var explosionFXTemplate : CEntityTemplate;
	editable var projectileType : MagicProjectileType;
	editable var hitActorFX : name;
	editable var stopsOnExplosion : bool;
	editable var forceHitAnimation : bool;
	editable var projectileFX : name;
	editable var destroyTime : float;
	editable var damageMinAttribute : name;
	editable var damageMaxAttribute : name;
	default damageMinAttribute = 'ranged_damage_min';
	default damageMaxAttribute = 'ranged_damage_max';
	default destroyTime = 1.0;
	default projectileFX = 'projectile_fx';
	default forceHitAnimation = false;
	default stopsOnExplosion = true;
	//editable var physicalFx : CEntityTemplate;
	default hitActorFX = 'fireball_hit_fx';
	default projectileType = MPT_None;
	
	function ProjectileDamage(actor : CActor, attackType: name)
	{
		var hitParams : HitParams;
		var damage, damageMin, damageMax : float;
		var actorPosition : Vector;
		var casterNPC : CNewNPC;
		actorPosition = actor.GetWorldPosition();
		casterNPC = (CNewNPC)caster;
		if(actor != thePlayer)
		{
			damageMinAttribute = 'damage_npc_min';
			damageMaxAttribute = 'damage_npc_max';
		}
		damageMin = caster.GetCharacterStats().GetAttribute(damageMinAttribute);
		damageMax = caster.GetCharacterStats().GetAttribute(damageMaxAttribute);
		damage = RandRangeF( damageMin , damageMax);
		if(damage <= 0)
			damage = RandRangeF( minDamage , maxDamage);
		hitParams.lethal = true;
		projectileHitPosition = actorPosition + VecNormalize(startPosition - actorPosition);
		hitParams.attackType = attackType;
		hitParams.hitPosition = projectileHitPosition;
		hitParams.attacker = caster;
		if(actor.IsAlive())
		{
			if(alwaysKillsTarget)
			{
				hitParams.damage = actor.GetHealth() + 10;
			}
			if(casterNPC.GetAttitude(actor) != AIA_Hostile )
			{
				damage = 0.0;
			}	
			hitParams.damage = damage;
			if(projectileType == MPT_Wind && actor == thePlayer)
			{
				hitParams.attackType = 'Attack_boss_t1';
			}
			actor.HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal, caster, forceHitAnimation, true, true);
			if(projectileType == MPT_Fire)
			{
				if(casterNPC.GetAttitude(actor) != AIA_Hostile)
				{
					actor.PlayEffect(hitActorFX);
				}
				else
				{
					if(!actor.ApplyCriticalEffect(CET_Burn, caster))
					{
						actor.PlayEffect(hitActorFX);
					}
				}
			}
			else if(projectileType == MPT_Lightning)
			{
				actor.PlayEffect(hitActorFX);
			}
			else if(projectileType == MPT_Wind )
			{
				if(casterNPC.GetAttitude(actor) == AIA_Hostile && actor != thePlayer)
				{
					actor.ApplyCriticalEffect(CET_Knockdown, caster);
				}
				actor.PlayEffect(hitActorFX);
			}
			else if(projectileType == MPT_Toxic )
			{
				if(casterNPC.GetAttitude(actor) == AIA_Hostile)
				{
					actor.ApplyCriticalEffect(CET_Poison, caster);
				}
				actor.PlayEffect(hitActorFX);
			}

		}
	}
	event OnStartProjectile()
	{
		PlayEffect(projectileFX);
	}
	function Explosion()
	{
		var attitude : bool;
		var actors : array<CActor>; 
		var actor : CActor;
		var size, i : int;
		var npc, actorNPC, hostileToPlayer : CNewNPC;
		GetActorsInRange(actors, 1.5, '', this);
		size = actors.Size();
		if(explosionFXTemplate)
			theGame.CreateEntity(explosionFXTemplate, this.GetWorldPosition(), this.GetWorldRotation());
		//if(physicalFx)
		//	theGame.CreateEntity(physicalFx, this.GetWorldPosition(), this.GetWorldRotation());
		if(size >= 1)
		{
			for(i = 0; i < size ; i += 1)
			{
				actor = actors[i];
				npc = (CNewNPC)caster;
				hostileToPlayer = (CNewNPC)actor;
				if(hostileToPlayer.GetAttitude(thePlayer) == AIA_Hostile)
				{
					attitude = true;
				}
				if(caster != actor)
				{
					if( (npc.GetAttitude( actor ) == AIA_Hostile) || (hostileToPlayer.GetAttitude( thePlayer ) == AIA_Hostile))
					{
						ProjectileDamage(actor, 'Attack');
					}
				}
			}
		}
		
		this.StopEffect(projectileFX);
		this.AddTimer('DestroyFireball', destroyTime, false);
		if(stopsOnExplosion)
			this.StopProjectile();
		
	}
	timer function DestroyFireball(td : float)
	{
		Destroy();
	}
	event OnRangeReached( inTheAir : bool )
	{
		Explosion();
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var actor	: CActor;
		var npc, actorNPC	: CNewNPC;
		var proj 	: CRegularProjectile; 
		var npcPostion, actorPosition, actorToNPCVec : Vector;
		var itemEntity : CItemEntity;
		var entity : CEntity = collidingComponent.GetEntity();
		
		itemEntity = (CItemEntity)entity;
		
		if(itemEntity )
		{
			actor = (CActor)itemEntity.GetParentEntity();
		}
		else
		{
			actor = (CActor)entity;
		}
		proj = this;
		if ( actor ) 
		{
			// Designers are not able to make a realistic game, so disable friendly fire :P
			npc = (CNewNPC) caster;
			actorNPC = (CNewNPC)actor;
			npcPostion = npc.GetWorldPosition();
			if ( (caster != actor && npc.GetAttitude( actor ) == AIA_Hostile) || (caster != actor && actorNPC.GetAttitude( thePlayer ) == AIA_Hostile))
			{
				Explosion();
			}
		}
		else
		{
			Explosion();
		}

		SetWillHitTarget( false );
	}

}
class CAttachedEntity extends CEntity
{
	editable var destroyAfterTime : float;
	function Init(parentActor : CActor, boneName : string)
	{
		if(parentActor)
		{
			if(boneName != "" && boneName != "None")
			{
				parentActor.AttachEntityToBone(this, boneName);
			}
		}
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('DestroyTimer', destroyAfterTime, false);
	}	
	timer function DestroyTimer(td : float)
	{
		this.Destroy();
	}
}
class CMagicAOESpell extends CEntity
{
	editable var effectName : name;
	editable var effectTime : float;
	editable var minDamage, maxDamage : float;
	editable var spellType : MagicProjectileType;
	editable var hitActorFX : name;
	editable var explosionFX : CEntityTemplate;
	editable var spellActivateTime : float;
	var areaOfEffect : CTriggerAreaComponent; 
	var affectedActor : CActor;
	var caster : CActor;
	var damageActor : CActor;
	default spellType = MPT_None;
	default effectTime = 3.0;
	default spellActivateTime = 0.0;
	default minDamage = 10.0;
	default maxDamage = 15.0;
	default hitActorFX = 'fireball_hit_fx';
	function Init(mage : CActor)
	{
		caster = mage;
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		areaOfEffect = (CTriggerAreaComponent)this.GetComponent("AOE");
		this.PlayEffect(effectName);
		this.AddTimer('StopFX', effectTime, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	function StopSpell()
	{
		this.StopEffect(effectName);
		this.AddTimer('DestroyFX', 1.0, false);
	}
	timer function StopFX(td : float)
	{
		StopSpell();
	}
	function SpellDamage(actor : CActor)
	{
		var hitParams : HitParams;
		var damage, damageMin, damageMax : float;
		var actorPosition : Vector;
		var actorToTrapVec : Vector;
		var explosionPos : Vector;
		actorPosition = actor.GetWorldPosition();
		
		damageMin = caster.GetCharacterStats().GetAttribute('damage_min');
		damageMax = caster.GetCharacterStats().GetAttribute('damage_max');
		damage = RandRangeF( damageMin , damageMax);
		if(damage <= 0)
			damage = RandRangeF( minDamage , maxDamage);

		hitParams.attackType = 'Attack';
		hitParams.damage = damage;
		hitParams.hitPosition = this.GetWorldPosition();
		hitParams.lethal = true;
		hitParams.attacker = caster;
		if(actor.IsAlive())
		{
			actor.HitPosition(hitParams.hitPosition, hitParams.attackType, hitParams.damage, hitParams.lethal);
			actorToTrapVec = VecNormalize(this.GetWorldPosition() - actor.GetWorldPosition());
			explosionPos = actor.GetWorldPosition() + 1.5*actorToTrapVec;
			explosionPos.Z += 1.5;
			if(explosionFX)
				theGame.CreateEntity(explosionFX, explosionPos, this.GetWorldRotation());
			this.StopSpell();
			if(spellType == MPT_Fire)
			{
				if(!actor.ApplyCriticalEffect(CET_Burn, caster))
				{
					actor.PlayEffect(hitActorFX);
				}
			}
		}
	}
	timer function SpellDamageTimer(td : float)
	{
		SpellDamage(damageActor);
	}
	event OnAreaEnter(area : CTriggerAreaComponent, activator : CComponent)
	{
		if(area == areaOfEffect)
		{
			affectedActor = (CActor)activator.GetEntity();
			if(affectedActor != caster)
			{
				if(spellActivateTime > 0.0)
				{
					damageActor = affectedActor;
					this.AddTimer('SpellDamageTimer', spellActivateTime, false);
				}
				else
				{
					SpellDamage(affectedActor);
				}
			}
		}
	}
}
class CExplosionFX extends CEntity
{
	editable var explosionFXName : name;
	editable var explosionTime : float;
	default explosionFXName = 'explosion';
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.PlayEffect(explosionFXName);
		if(explosionTime <= 0.0)
		{
			explosionTime = 5.0;
		}
		this.AddTimer('StopFX', explosionTime, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(explosionFXName);
		this.AddTimer('DestroyFX', explosionTime, false);
	}
}
class CMagicBolt extends CEntity
{
	editable var hitFX : name;
	editable var boltFX : name;
	editable var boltActorHitFX : name;
	editable var boltColider : CEntityTemplate;
	default hitFX = 'lightning_hit';
	default boltFX = 'lightning_bolt';
	default boltActorHitFX = 'lightning_hit_fx';
	function GetBoltActorHitFXName() : name
	{
		return boltActorHitFX;
	}
	function GetBoltColider() : CEntityTemplate
	{
		return boltColider;
	}
	function GetBoltFXName() : name
	{
		return boltFX;
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.PlayEffect(hitFX);
		this.AddTimer('StopFX', 3.0, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(hitFX);
		this.AddTimer('DestroyFX', 3.0, false);
	}
}
class CMageTeleportFX extends CEntity
{
	editable var effectName : name;
	editable var effectTime : float;
	default effectTime = 3.0;
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.PlayEffect(effectName);
		this.AddTimer('StopFX', effectTime, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(effectName);
		this.AddTimer('DestroyFX', effectTime, false);
	}
}
class CExplosionFXPhys extends CEntity
{
	editable var explosionFXName : name;
	editable var trailFXName : name;
	default explosionFXName = 'explosion';
	default trailFXName = 'trail';
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('Explosion', 0.1, false);

	}
	timer function Explosion(td : float)
	{
		this.PlayEffect(explosionFXName);
		this.PlayEffect(trailFXName);
		this.AddTimer('StopFX', 3.0, false);
	}	
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(explosionFXName);
		this.StopEffect(trailFXName);
		this.AddTimer('DestroyFX', 3.0, false);
	}
}
// Magic Projectile with scripted dmg
class CMagicProjectileWithScriptedDMG extends CMagicProjectile
{
	editable var 		objectToDestroyTag: name;
	editable var 		damage : float;
	editable var		effectName: name;
	var 				objectToDestroy: CEntity;
	var destructionComponent : CDestructionSystemComponent;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		objectToDestroy = theGame.GetEntityByTag(objectToDestroyTag);
		destructionComponent = (CDestructionSystemComponent) objectToDestroy.GetComponentByClassName( 'CDestructionSystemComponent' );
	}
	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity = collidingComponent.GetEntity();
		
		
		if (entity == objectToDestroy)
		{
			if(damage > 0)
			{
				destructionComponent.ApplyScriptedDamage( -1, damage );
			}
			if (effectName != '')
			{
				objectToDestroy.PlayEffect(effectName);
			}
			
			FactsAdd( "object_" + objectToDestroyTag + "_was_destroyed", 1 );
		}
	
		
		super.OnProjectileCollision( collidingComponent, pos, normal );
	}
}