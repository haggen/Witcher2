//Class used in GC Demo 2010 - first rock hits the barriers at game start.
class CDraugStartProjectile extends CExplodingProjectile
{
	var swooshSound : CSound;
	var explosionSound : CSound;

	function ApplyExplosionEffects( impactPos : Vector )
	{
		theSound.StopSoundWithFade(swooshSound);
		explosionSound = theSound.PlaySoundOnActor(this, '', "fx/draug_ball_fx/draug_ball_impact");
		theSound.PlayMusicNonQuest("draug_fight"); 
		theHud.m_hud.HideMinimap();
	}
	function StartRock(targetPos : Vector)
	{
		this.ShootAtPosition( NULL, 30.0, targetPos);
		swooshSound = theSound.PlaySoundOnActorWithFade(this, '', "fx/draug_ball_fx/draug_ball_whoosh");
	}
	function OnProjectileDestroy()
	{
		theSound.StopSoundWithFade(explosionSound);
		this.Destroy();
	}
}
class CDraugSafeArea extends CEntity
{

}
class CFireArea extends CEntity
{
	var activatorEntity : CActor;
	//var draug : CDraugBossBase;
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		activatorEntity = (CActor)activator.GetEntity();
		if(activatorEntity == thePlayer)
		{
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( 20, 20, 100, 100 ) );			
		}
	}
}

class CDraugSoundProjectile extends CRegularProjectile
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	event OnRangeReached( inTheAir : bool )
	{
		theSound.PlaySoundOnActor( this, '', "l03_camp/l03_ambiences/l03_battlefield/l03_battlefield_amb_rnd/l03_battlefield_arrows");
		StopEffect('trials_particle');
		AddTimer('StopTrials', 2.0, false);
		super.OnRangeReached( inTheAir );	
	}
	timer function StopTrials(td : float)
	{
		StopEffect('trials');
	}
}

/*class CDraugEndProjectile extends CRegularProjectile
{
	var draug : CDraugBossGC;
	var swooshSound : SSoundEventHandle;
	var explosionSound : SSoundEventHandle;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer('PlaySmokeFC', 0.1, false);
		draug = (CDraugBossGC)theGame.GetEntityByTag('draug_boss');
		theCamera.FocusOn(this);
		swooshSound = theSound.PlaySoundOnActorWithFade(this, '', "fx/draug_ball_fx/draug_ball_whoosh");
	}
	event OnRangeReached( inTheAir : bool )
	{
		thePlayer.HitPosition(this.GetWorldPosition(), 'Attack_boss_t1', 0.0, true);
		this.PlayEffect('destruction_fx');
		ShowEndDemoScreen();
		draug.AddTimer('EndDemo', 3.0, false);
		//this.AddTimer('FadeSounds', 2.0, false);
		FadeSounds();
		theSound.StopSoundWithFade(swooshSound);
		explosionSound = theSound.PlaySoundOnActor(this, '', "fx/draug_ball_fx/draug_ball_impact");
	}
	function ShowEndDemoScreen()
	{
		theHud.m_fx.W2LogoStart( true );
	}
	function FadeSounds()
	{
		theSound.MuteAllSounds();
		theSound.SilenceMusic();
	}
	timer function PlaySmokeFC(td : float)
	{
		this.PlayEffect('fireball');
	}
}*/

class CDraugProjectileSelector extends CDecalEntity
{
	private editable var draugRockTemplate 	: CEntityTemplate;
	private editable var draugRockStartPositionTag : name;
	private editable var usesStartPosition : bool;
	default usesStartPosition = false;
	var proj 								: CDraugCaveRock;
	var startPos 							: Vector;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		
		this.AddTimer('PlayStartFX', 1.0, false);
		//this.AddTimer('SpawnRock', 1.0f, false);
		SpawnDraugRock();
	
		super.OnSpawned(spawnData);
	}
	function DestroySelector()
	{
		//this.StopEffect('fireball_selection');
		this.AddTimer('DelayedDestroySelector', 2.0, false);
	}
	timer function PlayStartFX(td : float)
	{
		this.PlayEffect('marker_fx');
	}
	timer function DelayedDestroySelector(timeDelta : float)
	{
		this.Destroy();
	}
	function SpawnDraugRock()
	{
		var destructionComp : CDestructionSystemComponent;
		var target : Vector;
		if(usesStartPosition)
		{
			if(draugRockStartPositionTag != '' && draugRockStartPositionTag != 'None')
			{
				startPos = theGame.GetNodeByTag(draugRockStartPositionTag).GetWorldPosition();
			}
			else
			{
				startPos = this.GetWorldPosition();
				startPos.Z += 20.0;
			}
		}
		else
		{
			startPos = this.GetWorldPosition() + theCamera.GetCameraDirection() * 60.0;
			startPos.Z += 30.0;
		}
		proj = (CDraugCaveRock)theGame.CreateEntity(draugRockTemplate, startPos, EulerAngles());
		target = this.GetWorldPosition();
		//target.Z = 0.0;
		proj.StartRock( target, false ); 
		proj.SetSelector(this);
	}
	timer function SpawnRock(timeDelta : float)
	{
		SpawnDraugRock();
	}
}

// This class describes a rock that breaks into pieces upon impact
class CDraugCaveRock extends CExplodingProjectile
{		
	editable var	impactRange 		: float;
	editable var	explosionDamage		: float;
	editable var	alwaysKillsTarget	: bool;
	editable var	explosionDecal		: CEntityTemplate;
	editable var	maxDecalsNum		: int;
	var swooshSound : CSound;
	var explosionSound : CSound;
	var rockSelector : CDraugProjectileSelector;
	var draugProjectileShooter : CDraugProjectilesShooter;
	
	default maxDecalsNum = 10;
	default alwaysKillsTarget = false;
	default impactRange = 5.0;
	default explosionDamage = 50.0;
	
	function SetSelector(newRockSelector : CDraugProjectileSelector)
	{
		rockSelector = newRockSelector;
	}
	
	function StartRock( target : Vector, forceHit : bool )
	{
		draugProjectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
		ShootAtPosition( NULL, 20.0, target );
		swooshSound = theSound.PlaySoundOnActorWithFade(this, '', "fx/draug_ball_fx/draug_ball_whoosh");
	}
	
	function ApplyShotEffects()
	{		
		PlayEffect( 'trails' );
	}
	
	function ApplyExplosionDamage(actor : CActor, impactPos : Vector)
	{
		var finalDamage, actor_Reduction : float;
		actor_Reduction = actor.GetCharacterStats().GetFinalAttribute('damage_reduction');
		finalDamage = explosionDamage;
		if(alwaysKillsTarget)
		{
			finalDamage = 2.0*actor.GetHealth();
		}
		if (finalDamage <= 0)
		{
			finalDamage = 0;
		}
		if(actor == thePlayer)
		{
			actor.HitPosition(impactPos, 'Attack_boss_t1', finalDamage, true, NULL, true, true, true);
			draugProjectileShooter.SetShootingRocks(false);
		}
		else if( !actor.IsA('CDraugBoss') )
		{
			actor.HitPosition(impactPos, 'Attack', finalDamage, true);
		}
	}
	
	function SpawnDecal(position : Vector, rotation: EulerAngles)
	{
		var decalsArray : array<CNode>;
		var currentDecal : CEntity;
		var normal : EulerAngles;
		var finalPosition : Vector;
		finalPosition = position;	
		theGame.GetNodesByTag('draug_decal', decalsArray);
		if(decalsArray.Size() > maxDecalsNum)
		{
			currentDecal = (CEntity)decalsArray[0];
			currentDecal.Destroy();
		}
		if(theGame.GetWorld().PointProjectionTest(finalPosition, normal, 1.0))
		{
			theGame.CreateEntity(explosionDecal, finalPosition, rotation);
		}
	}
	
	function OnProjectileDestroy()
	{
		theSound.StopSoundWithFade(explosionSound);
		this.Destroy();
	}
	
	function ApplyExplosionEffects( impactPos : Vector )
	{
		var component : CComponent;
		var playerPos, rockPos : Vector;
		var rotation : EulerAngles;
		var actors : array<CActor>;
		var i, size : int;
		rotation.Yaw = 180*RandF();
		playerPos = thePlayer.GetWorldPosition();
		component = this.GetComponent("PositionNode");
		rockPos = component.GetWorldPosition();
		//rockPos = this.GetWorldPosition();
		//SpawnDecal(impactPos, rotation);
		SpawnDecal(rockSelector.GetWorldPosition(), rotation);
		theSound.StopSoundWithFade(swooshSound);
		explosionSound = theSound.PlaySoundOnActor(this, '', "fx/draug_ball_fx/draug_ball_impact");
		GetActorsInRange(actors, impactRange, '', component);
		size = actors.Size();
		if(size > 0)
		{
			for(i = 0; i < size; i += 1)
			{
				if(VecDistance2D(actors[i].GetWorldPosition(), rockPos)<impactRange)
				{
					ApplyExplosionDamage(actors[i], rockPos);
				}
			}
		}
		// to mozna odpalic z efektow i jest lepsze, bo sledzi pozycje gracza i dostosowuje sile
		//theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
 		//theCamera.RaiseEvent('Camera_ShakeHit');
 		if(rockSelector)
 		{
			rockSelector.DestroySelector();
		}
		
	}
}

class CDraugArrows extends CRegularProjectile
{
	var component : CPhantomComponent;
	event OnRangeReached( inTheAir : bool )
	{
		StopEffect('trials_particle');
		AddTimer('StopTrials', 2.0, false);
		component = (CPhantomComponent)this.GetComponentByClassName('CPhantomComponent');
		component.Deactivate();
		AddTimer('TimerDestroyArrow', 3.0, false);
		super.OnRangeReached( inTheAir );
	}
	event OnProjectileCollision(comp : CComponent, pos : Vector, normal : Vector)
	{
		AddTimer('TimerDestroyArrow', 3.0, false);
		super.OnProjectileCollision(comp, pos, normal);
		
	}
	timer function TimerDestroyArrow( td : float )
	{
		Destroy();
	}
	timer function StopTrials(td : float)
	{
		StopEffect('trials');
	}
}
class CDraugProjectilesShooter extends CEntity
{
	editable var draugArrows : CEntityTemplate;
	editable var draugSoundArrows : CEntityTemplate;
	editable var draugCaveSelector : CEntityTemplate;
	editable var maxRocks : int;
	
	private var shootingRocks : bool;
	private var shootingEnded : bool;
	
	default shootingRocks = false;
	default maxRocks = 5;
	
	function SetShootingRocks(flag : bool)
	{
		shootingRocks = flag;
	}
	
	timer function PlayArrowsSound(td : float)
	{
		theSound.PlaySound( "l03_camp/l03_ambiences/l03_battlefield/l03_battlefield_amb_rnd/l03_battlefield_arrows");	
	}
	
	function ShootingInProgress() : bool
	{
		return !shootingEnded;
	}
}
state ShootingProjectiles in CDraugProjectilesShooter
{
	var projectileSelectors : array<CNode>;
	
	entry function DraugRocks(rocksNumber : int)
	{
		var i : int;
		var targetPos, movementDirection : Vector;
		var rotation : EulerAngles;
		var lastOne : CDraugProjectileSelector = NULL;
		parent.shootingRocks = true;
		parent.shootingEnded = false;
		while (	parent.shootingRocks )
		{

			targetPos = thePlayer.GetWorldPosition() + VecRingRand(0.0f, 10.0);
			
			rotation.Yaw = 180.0*RandF();
			projectileSelectors.Clear();
			theGame.GetNodesByTag('draug_selector', projectileSelectors);
			if(projectileSelectors.Size() < parent.maxRocks)
			{
				lastOne = (CDraugProjectileSelector)theGame.CreateEntity(parent.draugCaveSelector, targetPos, rotation);
			}
			Sleep(1.5);
			rocksNumber-=1;
			if(rocksNumber<=0)
			{
				parent.shootingRocks = false;
			}
		}
		Sleep(2);
		parent.shootingEnded = true;
	}
	entry function DraugArrows()
	{
		var startPos, startPosBase, offset, targetPosition : Vector;
		var i, j : int;
		var proj : CDraugArrows;
		var soundProj : CDraugSoundProjectile;
		var normal : EulerAngles;
		var angle : float;
		
		parent.shootingEnded = false;
		startPosBase = thePlayer.GetWorldPosition() + theCamera.GetCameraDirection() * 150.0;	
		//Do grania dzwieku	
			
		for(j=0; j<3; j+=1)
		{
			startPos = startPosBase;
			startPos.Z = 15.0;
			soundProj = (CDraugSoundProjectile)theGame.CreateEntity(parent.draugSoundArrows, startPos, EulerAngles()); 
			soundProj.PlayEffect('trials');
			soundProj.PlayEffect('trials_particle');
			targetPosition = thePlayer.GetWorldPosition();
			targetPosition.Z -= 0.5;
			angle = 20.0 + 60*RandF();
			theGame.GetWorld().PointProjectionTest(targetPosition, normal, 2.0);
			soundProj.Start( NULL, targetPosition, false, angle ); 
			//parent.AddTimer('PlayArrowsSound', 5.0, false);
			for( i=0; i<50; i+=1 )
			{
				offset = VecRingRand( 0.0, 30.0 );
				startPos = startPosBase + offset;
				startPos.Z = 15.0;
				proj = (CDraugArrows)theGame.CreateEntity(parent.draugArrows, startPos, EulerAngles()); 
				if( proj )
				{
					if(i%25 == 0)
					{
						//proj.PlayEffect('trials');
						//proj.Start( thePlayer, Vector(0, 0, 0), false, 45.0 ); 
						
						proj.PlayEffect('trials');
						proj.PlayEffect('trials_particle');
						targetPosition = thePlayer.GetWorldPosition() + 0.25*offset;
						targetPosition.Z -= 0.5;
						angle = 20.0 + 60*RandF();
						theGame.GetWorld().PointProjectionTest(targetPosition, normal, 2.0);
						proj.Start( NULL, targetPosition, false, angle ); 
					}
					else
					{
						proj.PlayEffect('trials');
						proj.PlayEffect('trials_particle');
						targetPosition = thePlayer.GetWorldPosition() + 0.25*offset;
						targetPosition.Z -= 0.5;
						angle = 20.0 + 60*RandF();
						theGame.GetWorld().PointProjectionTest(targetPosition, normal, 2.0);
						proj.Start( NULL, targetPosition, false, angle ); 
					}
				}
				else
				{
					Log("Cannot create projectile");
				}
			}
			Sleep(2.0);
		}
		Sleep(4);
		parent.shootingEnded = true;
	}
}
class CDecalEntity extends CEntity
{
	var meshComponents, particleComponents : array<CComponent>;
	var sizeMeshComponents, sizeParticleComponents, i : int;
	var zTranslation : float;
	var currentComponentPos, currentComponentPosLocal, newComponentPos : Vector;
	var normal, currentComponentRotLocal : EulerAngles;
	var currentComponent : CComponent;
	
	editable var groundSearchRange : float;
	default groundSearchRange = 1.0;
	function SetDecalPosition()
	{
		meshComponents = GetComponentsByClassName('CMeshComponent');
		particleComponents = GetComponentsByClassName('CParticleComponent');
		sizeMeshComponents = meshComponents.Size();
		sizeParticleComponents = particleComponents.Size();
		for(i=0; i<sizeMeshComponents; i+=1)
		{
			currentComponent = meshComponents[i];
			currentComponentPos = currentComponent.GetWorldPosition();
			newComponentPos = currentComponentPos;
			currentComponentPosLocal = currentComponent.GetLocalPosition();
			currentComponentRotLocal = currentComponent.GetLocalRotation();
			if ( theGame.GetWorld().PointProjectionTest( newComponentPos, normal, groundSearchRange ) )
			{
				currentComponent.SetPosition( currentComponentPosLocal + ( newComponentPos - currentComponentPos ) );
				currentComponent.SetRotation( normal );
			}
		}
		for(i=0; i<sizeParticleComponents; i+=1)
		{
			currentComponent = particleComponents[i];
			currentComponentPos = currentComponent.GetWorldPosition();
			newComponentPos = currentComponentPos;
			currentComponentPosLocal = currentComponent.GetLocalPosition();
			currentComponentRotLocal = currentComponent.GetLocalRotation();
			if ( theGame.GetWorld().PointProjectionTest( newComponentPos, normal, groundSearchRange ) )
			{
				currentComponent.SetPosition( currentComponentPosLocal + ( newComponentPos - currentComponentPos ) );
				//currentComponent.SetRotation( normal );
			}
		}
	}
	timer function TimerDestroy( td : float)
	{
		Destroy();
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		SetDecalPosition();
		AddTimer('TimerDestroy', 6.0, false);
	}
}
