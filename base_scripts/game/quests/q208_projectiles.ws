class CMeteoriteSelector extends CEntity
{
	private editable var draugRockTemplate : CEntityTemplate;
	var proj : CMeteoriteProjectile;
	var playerPos : Vector;
	var selectorPos : Vector;
	var player : CPlayer;
	var camera : CCamera;
	var offset : Vector;
	var range : float;
	default range = 20.0;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		player = thePlayer;
		camera = theCamera;
		playerPos = player.GetWorldPosition();
		selectorPos = this.GetWorldPosition();
		if(VecDistance2D(selectorPos, playerPos) < 15.0)
		{
				this.PlayEffect('fireball_selection');
		}
		//super.OnSpawned();
		
	}
	function DestroySelector()
	{
		this.StopEffect('fireball_selection');
		this.AddTimer('DelayedDestroySelector', 2.0, false);
	}
	event OnDestroyed()
	{
		super.OnDestroyed();
	}
	function MeteoriteExplosion()
	{
		this.PlayEffect('explosion');
		this.AddTimer('FadeMeteoriteSelection', 2.0, false);
	}
	timer function FadeMeteoriteSelection(timeDelta : float)
	{
		this.StopEffect('explosion');
		this.StopEffect('fireball_selection');
		this.AddTimer('DeleteMeteoriteSelector', 2.0, false);
	}
	timer function DeleteMeteoriteSelector(timeDelta : float)
	{
		this.Destroy();
	}
}
class CMeteoriteProjectile extends CRegularProjectile
{
	private editable var hitEffectEntity	: CEntityTemplate;
	private editable var projectileType : name;
	//editable var destrRockTemplate : CEntityTemplate;
	
	var effect				: CEntity;
	var effectNodeOffset	: Vector;
	var meteoriteSelector	: CMeteoriteSelector;
	var selectorPos			: Vector;
	var thrashComp 			: CRigidMeshComponent;
	var impulseDir			: Vector;
	var massCenter			: Vector;
	var impulsePoint		: Vector;
	//var destrRock			: CDraugDestructibleRock;
	var draugCaveRock		: CMeteoriteProjectile;
	event OnDestroyed()
	{
		super.OnDestroyed();
		if( effect )
		{			
			effect.Destroy();
			effect = NULL;
		}
	}
	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		SetWillHitTarget( false );
		this.Destroy();
		/*SpawnEffect( collisionPos, collisionNormal );
		if(projectileType == 'normal')
		{
			Bounce( collisionPos, collisionNormal );
		}
		
		if(projectileType == 'butterflies')
		{
			( (CDrawableComponent) GetComponentByClassName( 'CMeshComponent' ) ).SetVisible( false );
		}
		*/
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		selectorPos = this.GetProjectileTargetPos();
		meteoriteSelector = (CMeteoriteSelector)theGame.CreateEntity(hitEffectEntity, selectorPos, EulerAngles());
		this.PlayEffect('metrorite_fire_trilas');
		super.OnSpawned(spawnData);
	}
	event OnRangeReached( inTheAir : bool )
	{
		//destrRock = (CDraugDestructibleRock)theGame.CreateEntity(destrRockTemplate, this.GetWorldPosition(), this.GetWorldRotation());
		this.AddTimer('RockExplode', 1.5, false);	
		RockDamage();
	}
	function RockDamage()
	{
		var player : CPlayer;
		var playerPos : Vector;
		var npc : CNewNPC;
		var npcPos : Vector;
		var camera : CCamera;
		var npcs : array<CNewNPC>;
		var size, i : int;
		theGame.GetAllNPCs(npcs);
		player = thePlayer;
		playerPos = player.GetWorldPosition();
		meteoriteSelector.MeteoriteExplosion();
		this.StopEffect('metrorite_fire_trilas');
		if(VecDistance(playerPos, this.GetWorldPosition())<20.0)
		{
			camera = theCamera;
			camera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			camera.RaiseEvent('Camera_ShakeHit');
 		}
		if(VecDistance(playerPos, this.GetWorldPosition())<7.0)
		{
			if( player.GetCurrentStateName() == 'exploration')
			{
				super.ProjectileDamage(player, 'Attack_t3');
			}
			else
			{
				super.ProjectileDamage(player, 'Attack_t3');
			}
			
			player.PlayEffect('burning_fx');
		}
		size = npcs.Size();
		for(i=0; i<size; i+=1)
		{
			npc = npcs[i];
			npcPos = npc.GetWorldPosition();
			if(VecDistance(npcPos, this.GetWorldPosition())<7.0)
			{
				npc.PlayEffect('burning_fx');
				super.ProjectileDamage((CActor)npc, 'hit_front_t3');
			}
		}
	}
	timer function RockExplode(timeDelta : float)
	{		
		this.Destroy();
	}
}