/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/



/////////////////////////////////////////////
// CProjectile class
/////////////////////////////////////////////

import class CProjectile extends CEntity
{
	import var caster 						: CActor;
	import var projectileName 				: name;

	// Initializes the projectile
	import final function Init( caster : CActor );
	
	// Shoots the projectile at the specified node
	import final function ShootProjectileAtNode( angle : float, velocity : float, strength : float, target : CNode, optional range : float );
	
	// Shoots the projectile at the specified position
	import final function ShootProjectileAtPosition( angle : float, velocity : float, strength : float, target : Vector, optional range : float );
	
	// Stops the projectile
	import final function StopProjectile();
	
	// Returns the current physical strength of the projectile
	import final function GetStrength() : float;
	
	// Called when the spell is being initialized
	event OnProjectileInit();
	
	// Collision event
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector );
	
	// Movement end event
	event OnRangeReached( inTheAir : bool );
};

/////////////////////////////////////////////

// A simple projectile that deal damage upon physical contact - 
// requires physical testing to be enabled
class CRegularProjectile extends CProjectile
{	
	private editable var minStartVelocity	: float;
	private editable var maxStartVelocity	: float;	
	private editable var hitProbability		: float;
	private editable var minDamage 			: float;
	private editable var maxDamage 			: float;
	private editable var destroyProjectileTime : float;	
	private editable var alwaysKillsTarget 	: bool;
	private editable var collidesOnlyWithActors : bool;
	
	private editable var destroyProjectileAfterNonTerrainCollision : bool;
	private editable var objectsTreatedAsTerrainTags : array<name>;
	
	private editable var hitObstacleFX : CEntityTemplate;
	private editable var projectileFX : name;
	
	var targetWasHit : bool;
	var willHitTarget : bool;
	var targetEntity : CEntity;
	var targetPos : Vector;
	var startPosition : Vector;
	var projectileHitPosition : Vector;
	var vel : float;
	
	var soundType : EArrowSoundType;
	
	default minStartVelocity = 9.0;
	default maxStartVelocity = 11.0;
	default hitProbability = 0.5f;
	default minDamage  = 12.0f;
	default maxDamage  = 17.0f;
	default destroyProjectileTime = 5.0f;
	default willHitTarget = false;
	default alwaysKillsTarget = false;
	default projectileFX = 'trail_fx';
	

	default destroyProjectileAfterNonTerrainCollision = true; 

	function InstantArrowKill() : bool
	{
		var chance, diceThrow : float;
		var chanceToxMult, chanceBasic : float;
		var toxicityThreshold : float;
		if(caster != thePlayer)
			return false;
		toxicityThreshold = thePlayer.GetCharacterStats().GetFinalAttribute('toxicity_threshold');
		if(toxicityThreshold <= 0.0f)
		{
			toxicityThreshold = 1.0f;
		}
		diceThrow = RandRangeF(0.0f, 1.0f);
		
		chanceBasic = thePlayer.GetCharacterStats().GetFinalAttribute('instant_arrow_kill_chance');
		chanceToxMult = thePlayer.GetCharacterStats().GetFinalAttribute('instant_kill_toxbonus');
		if(chanceToxMult <1.0)
		{
			chanceToxMult = 1.0;
		}
		if(thePlayer.GetToxicity()>toxicityThreshold)
		{
			chanceBasic*chanceToxMult;
		}
		chance = chanceBasic;
		if(diceThrow <= chance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	// Set willHitTarget
	function SetWillHitTarget( flag : bool )
	{
		willHitTarget = flag;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		startPosition = this.GetWorldPosition();
		super.OnSpawned(spawnData);
	}
	function InitSound(sound : EArrowSoundType)
	{
		soundType = sound;
	}
	function Start( target : CActor, offset : Vector, forceHit : bool, optional angle : float, optional range : float)
	{
		var innerRadius : float;
		var outerRadius : float;
		var r 			: float;
		var missAngle 	: float;
		var missOffset  : Vector;
		OnStartProjectile();
		
		PlayEffect(projectileFX);
		//Determine velocity
		if(vel <= 0)
			vel = RandRangeF( minStartVelocity, maxStartVelocity );
		// Determine hit
		if( !target )
		{
			willHitTarget  = false;
		}
		else
		{
			willHitTarget = true;
		}
		
		// Change offset if should miss target
		if( willHitTarget == false )
		{
			if( target )
			{
				innerRadius = target.GetRadius() + 0.5f; // should be higher than actor radius
				outerRadius = 2.0f;
			
				missOffset.Z = 0.0;
				r = RandRangeF( innerRadius, outerRadius );
				missAngle = RandRangeF( 0.0, 2*Pi() );
				missOffset.X = CosF( missAngle ) * r;				
				missOffset.Y = SinF( missAngle ) * r;
				targetPos = offset + missOffset;
			}
			else
			{
				targetPos = offset;
			}
			if(range <= 0.0)
			{
				range = 100000;
			}
			
			targetEntity = NULL;			
			ShootProjectileAtPosition( angle, vel, 0.0, targetPos, range );
		}
		else
		{
			if(range <= 0.0)
			{
				range = 100000;
			}
			targetEntity = target;
			targetPos = target.GetWorldPosition();
			ShootProjectileAtNode( angle, vel, 0.0, targetEntity, range );
		}
	}
	
	function GetProjectileTargetPos() : Vector
	{
		return targetPos;
	}
	function GetProjectileTarget() : CEntity
	{
		return targetEntity;
	}
	function GetProjectileSpeed() : float
	{
		return vel;
	}
	function SetProjectileRandomSpeed()
	{
		vel = RandRangeF( minStartVelocity, maxStartVelocity );
	}
	function SetProjectileSpeed(newSpeed : float)
	{
		vel = newSpeed;
	}
	// Event called when projectile finished moving
	function ProjectileDamage(actor : CActor, attackType: name)
	{
		var hitParams : HitParams;
		var damage, damageMin, damageMax : float;
		var actorPosition : Vector;
		actorPosition = actor.GetWorldPosition();
		targetWasHit = true;		
		if(actor == thePlayer)
		{
			damageMin = caster.GetCharacterStats().GetAttribute('ranged_damage_min');
			damageMax = caster.GetCharacterStats().GetAttribute('ranged_damage_max');
		}
		else
		{
			damageMin = caster.GetCharacterStats().GetAttribute('damage_npc_min');
			damageMax = caster.GetCharacterStats().GetAttribute('damage_npc_max');
		}
		damage = RandRangeF( damageMin , damageMax);
		if(damage <= 0)
			damage = RandRangeF( minDamage , maxDamage);
		projectileHitPosition = actorPosition + VecNormalize(startPosition - actorPosition);
		hitParams.attackType = attackType;
		hitParams.damage = damage;
		hitParams.hitPosition = projectileHitPosition;
		hitParams.lethal = true;
		hitParams.attacker = caster;
		if(InstantArrowKill())
			alwaysKillsTarget = true;
		if(actor.IsAlive())
		{
			if(alwaysKillsTarget)
			{
				hitParams.damage = actor.GetHealth() + 10;
				actor.OnArrowHit(hitParams, this);
			}
			else
			{
				actor.OnArrowHit(hitParams, this);
			}
			actor.PlayBloodOnHit(); // stupid
		}
	}
	function PlayArrowHitSound()
	{
		if(soundType == AST_NoSound)
		{
			return;
		}
		else if(soundType == AST_EverySingleArrow)
		{
			if(VecDistanceSquared(this.GetWorldPosition(), thePlayer.GetWorldPosition()) < 900 )
			{
				if(thePlayer.CanPlayArrowSound())
				{
					theSound.PlaySoundOnActor(this, '', "combat/weapons/bow/anim_arrow_hit");
					thePlayer.SetArrowSoundCooldown(0.1);
				}
			}
		}
		else
		{
			if(VecDistanceSquared(this.GetWorldPosition(), thePlayer.GetWorldPosition()) < 900 && thePlayer.CanPlayArrowSound())
			{
				theSound.PlaySound("l03_camp/l03_quests/q208/draug_arrows_hit");
				thePlayer.SetArrowSoundCooldown(3.0);
			}
		}
	}
	event OnStartProjectile();
	event OnRangeReached( inTheAir : bool )
	{
		var actor : CActor;
		if( willHitTarget || alwaysKillsTarget )
		{
			actor = (CActor)targetEntity;
			if( actor && !actor.IsInvulnerable() && !targetWasHit)
			{
				ProjectileDamage(actor, 'Attack');
			}
			
			Destroy();
		}
		else
		{
			Destroy();
			//AddTimer( 'DestroyProjectile', MaxF( destroyProjectileTime, 0.0f ), false );
		}
	}
	function SetTargetWasHit(flag : bool)
	{
		targetWasHit = flag;
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var actor	: CActor;
		var npc		: CNewNPC;
		var npcPostion, actorPosition, actorToNPCVec : Vector;
		var itemEntity : CItemEntity;
		var entity : CEntity = collidingComponent.GetEntity();
		var i, size : int;
		var shouldDestroy : bool;
		var terrainComponent : CTerrainTileComponent;
		var targetNPC : CNewNPC;
		var actorTest : CActor;
		
		itemEntity = (CItemEntity)entity;
		if(itemEntity)
		{
			actor = (CActor)itemEntity.GetParentEntity();
		}
		else
		{
			actor = (CActor)entity;
		}
		if ( actor && !targetWasHit) 
		{
			// Designers are not able to make a realistic game, so disable friendly fire :P
			npc = (CNewNPC) caster;
			npcPostion = npc.GetWorldPosition();
			if ( !npc  || npc.GetAttitude( actor ) == AIA_Hostile)
			{
				if(actor != caster)
				{
					ProjectileDamage(actor, 'Attack');
				}
			}
			if(caster == thePlayer)
			{
				targetNPC = (CNewNPC)actor;
				if(targetNPC && targetNPC.GetAttitude(thePlayer) == AIA_Hostile)
				{
					ProjectileDamage(actor, 'Attack');
				}
			}

			SetWillHitTarget( false );
		}
		else if(!collidesOnlyWithActors)
		{
			PlayArrowHitSound();
			if(hitObstacleFX)
			{
				actorTest = (CActor)entity; 
				if(!actorTest)
				{
					theGame.CreateEntity(hitObstacleFX, pos, VecToRotation(normal));
				}
			}
			
			if(destroyProjectileAfterNonTerrainCollision)
			{
				
				size = objectsTreatedAsTerrainTags.Size();
				terrainComponent = (CTerrainTileComponent)collidingComponent;
				if(terrainComponent)
				{
					shouldDestroy = false;
				}
				else
				{
					shouldDestroy = true;
					for(i = 0; i < size; i += 1)
					{
						if(entity.HasTag(objectsTreatedAsTerrainTags[i]))
						{
							shouldDestroy = false;
						}
					}
				}
				if(shouldDestroy)
				{
					Destroy();
				}
				else
				{
					AddTimer( 'DestroyProjectile', MaxF( destroyProjectileTime, 0.0f ), false );
				}
			}
			else
			{
				AddTimer( 'DestroyProjectile', MaxF( destroyProjectileTime, 0.0f ), false );
			}
			SetWillHitTarget( false );
			this.StopEffect(projectileFX);
		}

		
	}
	
	timer function DestroyProjectile( timeDelta : float )
	{
		this.Destroy();		
	}
}

// Projectile for q101 - bounces from TrissShield (which is part of Roche actor), stops in static collisions, vanishes when the player is hit
class CProjectileQ101 extends CRegularProjectile
{
	event OnRangeReached( inTheAir : bool )
	{
		var actor : CActor;
		if( willHitTarget || alwaysKillsTarget )
		{
			actor = (CActor)targetEntity;
			if( actor && !actor.IsInvulnerable())
			{
				ProjectileDamage(actor, 'Attack');
			}
		}
		
		Destroy();
	}
	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var actor	: CActor;
		var npc		: CNewNPC;
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
		if ( actor && actor.IsAlive() )
		{
			if ( actor == thePlayer )
			{
				ProjectileDamage(actor, 'Attack');
				Destroy();
			}
			// else do the default thing (bounce)
		}
		else
		{
			// Stay in the ground
			AddTimer( 'DestroyProjectile', MaxF( destroyProjectileTime, 0.0f ), false );
			StopProjectile();
		}
	}
}