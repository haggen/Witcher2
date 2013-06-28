/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CWitcherSignAard sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
 

/////////////////////////////////////////////
class CAardExplosion extends CEntity
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
class CWitcherSignAard extends CProjectile
{	
	editable var fadeoutTime				: float;
	editable var explosionTmpl				: CEntityTemplate;
	var level								: int;
	var explosionRange						: float;
	var	target 								: CEntity;
	var damage								: float;
	var aardRange							: float;

	function GetAardLevel() : int
	{
		return level;
	}
	function GetAardDamage() : float
	{
		return damage;
	}
	timer function DestroyAard(td : float)
	{
		this.Destroy();
	}
	function Initialize( caster : CActor, target : CEntity )
	{
		this.target = target;
		
		// initialize the projectile
		Init( caster );
	}
	
	event OnProjectileInit()
	{			
		if(thePlayer.GetCharacterStats().HasAbility('magic_s1_2'))
		{
			this.level = 2;
			this.explosionRange = 2.5;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s1'))
		{
			this.level = 1;
			this.explosionRange = 1.0;
		}
		else
		{
			this.level = 0;
			this.explosionRange = 0.0;
		}		
		this.damage = thePlayer.GetCharacterStats().GetFinalAttribute('aard_damage');
		if(this.damage <= 0)
		{
			this.damage = 10.0;
		}
		aardRange = thePlayer.GetCharacterStats().GetFinalAttribute('aard_max_dist');
		Activate();
	}
	
	// --------------------------------------------------------------------
	// private functions
	// --------------------------------------------------------------------	
	private function GetProjectileFxName() : name
	{
		if( thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) )
		{
			return StringToName( "fx_level" + level + "_ice");
		}
		else
		{
			return StringToName( "fx_level" + level );
		}
	}
	
	private function GetPlayerFxName() : name
	{
		if( thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) )
		{
			return StringToName( "Aard_level0_ice" );
		}
		else
		{
			return StringToName( "Aard_level0" );
		}
	}
	
	private function GetHitFxName() : name
	{
		return StringToName( "aard_hit_fx" );
	}
	private function GetExplosionFXName() : name
	{
		if( thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) )
		{
			return StringToName( "hit_aard_lv" + level + "_ice");
		}
		else
		{
			return StringToName( "hit_aard_lv" + level );
		}
		
	}
	private function VisualizeHit( entity : CEntity )
	{
		var hitFxName : name;
		var aardExplosion : CAardExplosion;
		var explosionFXName : name;
		aardExplosion = (CAardExplosion)theGame.CreateEntity(this.explosionTmpl, this.GetWorldPosition(), this.GetWorldRotation());
		aardExplosion.PlayExplosionFX(GetExplosionFXName());
	}
}

///////////////////////////////////////////////////////////////////////////

state Active in CWitcherSignAard
{
	private var		hitEntities : array< CEntity >;
	private var	isSickyEntityEnabled : bool; // gdc hack
	
	entry function Activate()
	{		
		var projectileFxName 				: name;
		var playerFxName 					: name;
		var stats 							: CCharacterStats;
		var speed 							: float;
		var aardDamage 						: float;
		var range 							: float;
		var actor							: CActor;
		var position						: Vector;
		var normal							: EulerAngles;
		var playerPosition 					: Vector;
		
		// GDC hack
		isSickyEntityEnabled = false;
		
		projectileFxName = parent.GetProjectileFxName();
		parent.PlayEffect( projectileFxName );
		
		playerFxName = parent.GetPlayerFxName();
		parent.caster.PlayEffect( playerFxName );
		parent.caster.DecreaseStamina( 1.0 );
		
		actor = (CActor)parent.target;
		// rotate towards the target
		// start the projectile
		stats = parent.caster.GetCharacterStats();
		speed = stats.GetAttribute( 'aard_speed' );
		aardDamage = stats.GetAttribute( 'aard_damage' );
		range = stats.GetFinalAttribute( 'aard_max_dist' ) * thePlayer.GetSignsPowerBonus(SPBT_Range);
		range = range * parent.fadeoutTime;
		//parent.ShootProjectileAtNode( 0, speed, aardDamage, parent.target, parent.aardRange ); // commented for GDC only
		position = thePlayer.CalculateSignTarget(parent.target);
		parent.ShootProjectileAtPosition(0.0, speed, aardDamage, position, range);
		if(VecDistance(parent.GetWorldPosition(), actor.GetWorldPosition()) < 1.5)
		{
			parent.OnProjectileCollision(actor.GetComponent("Character"), parent.GetWorldPosition(), Vector(0,0,0));
		}
		// GDC HACK!!!
		//isSickyEntityEnabled = StickyEntitiesCheck();
		//{
			//parent.ShootProjectileAtNode( 0, speed, aardDamage, parent.target, range );
			//parent.FadeOut();
		//}
		
		//theHud.m_hud.ShowTutorial("tut38", "tut38_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut38", "tut38_333x166" );
	}
	
	// --------------------------------------------------------------------
	// damage dealing
	// --------------------------------------------------------------------
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{			
		var hitEntity		: CEntity = collidingComponent.GetEntity();
		var targetMonster	: W2Monster;
		var hitActor, actor : CActor;
		var actors			: array<CActor>;
		var size, i			: int;
		var hitNPC, enemy	: CNewNPC;
		var itemEntity : CItemEntity;
		var entity : CEntity = collidingComponent.GetEntity();
		var nodes : array<CNode>;
		var birds : array<CNode>;
		var binaryStorage : CNodesBinaryStorage;
		var boundsMax : Vector = Vector(0.75, 0.75, 0.75);
		var boundsMin : Vector = Vector(-0.75, -0.75, -0.75);
		var bird : CBirds;
		
		
		binaryStorage = new CNodesBinaryStorage in parent;
		
		if(parent.level == 1)
		{
			boundsMax = 2.0*boundsMax;
			boundsMin = 2.0*boundsMin;
		}
		else if(parent.level == 2)
		{
			boundsMax = 3.0*boundsMax;
			boundsMin = 3.0*boundsMin;
		}
		theGame.GetNodesByTag('birds', nodes);
		binaryStorage.InitializeWithNodes(nodes);
		binaryStorage.GetClosestToPosition(parent.GetWorldPosition(), birds, boundsMin, boundsMax, true, 20);
		
		for(i = 0; i < birds.Size(); i += 1)
		{
			bird = (CBirds)birds[i];
			if(bird)
			{
				bird.KillBird();
			}
		}
		itemEntity = (CItemEntity)entity;
		if(itemEntity )
		{
			hitEntity = itemEntity.GetParentEntity();
			hitActor = (CActor)hitEntity;
		}
		else
		{
			hitEntity = hitEntity;
			hitActor = (CActor)hitEntity;
		}
		if(hitActor == thePlayer)
		{
			return false;
		}
		hitNPC = (CNewNPC)hitActor;
		if ( !WasHit( hitEntity ) && hitEntity )
		{
			hitEntities.PushBack( hitEntity );
			if ( !isSickyEntityEnabled )
			{
				hitEntity.NotifySpellHit( parent.projectileName );
				hitEntity.HandleAardHit( parent );
				if( !thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) || !hitNPC)
				{
					hitEntity.PlayEffect(parent.GetHitFxName());
				}
			}
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
						enemy.HandleAardHit(parent);
						if( !thePlayer.GetCharacterStats().HasAbility( 'story_s32_1' ) )
						{
							enemy.PlayEffect(parent.GetHitFxName());
						}
					}
				}
			}
		}
		parent.VisualizeHit( hitEntity );
		parent.FadeOut();
	}
	
	event OnRangeReached( inTheAir : bool )
	{
		parent.FadeOut();
	}
	
	private function WasHit( entity : CEntity ) : bool
	{
		var i, count		: int;
		count = hitEntities.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( hitEntities[i] == entity )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function StickyEntitiesCheck() : bool
	{
		var stickyEntity : W2StickyEntity;
		var nodes : array< CNode >;
		var stickyNodes : array< CNode >;
		var stickyNode : CNode;
		var i : int;
		
		// Get all sticky entity from world
		theGame.GetNodesByTag( 'StickyEntityTag', nodes );
		for ( i = 0; i < nodes.Size(); i += 1 )
		{
			if ( nodes[i].IsA('W2StickyEntity') )
			{
				stickyNodes.PushBack( nodes[i] );
			}
		}
		
		// Choose the closest one
		stickyNode = FindClosestNode( thePlayer.GetWorldPosition(), stickyNodes );

		stickyEntity = (W2StickyEntity)stickyNode;
		if ( stickyEntity )
		{
			return stickyEntity.Activate();
		}
		return false;
	}
};

///////////////////////////////////////////////////////////////////////////

state Fading in CWitcherSignAard
{
	entry function FadeOut()
	{		
		var projectileFxName 				: name;
		var stats 							: CCharacterStats;
		var	speed							: float;
		var range							: float;
		var position						: Vector;
		
		projectileFxName = parent.GetProjectileFxName();
		parent.StopEffect( projectileFxName );
		parent.AddTimer('DestroyAard', 2.0, false);
		stats = parent.caster.GetCharacterStats();
		speed = stats.GetFinalAttribute( 'aard_speed' );
		range = 100.0;
		//range = range * ( 1 - parent.fadeoutTime );
		position = parent.GetWorldPosition() + 10*VecFromHeading(parent.GetHeading());
		parent.StopProjectile();
	}
};
