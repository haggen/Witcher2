
enum EBirdType
{
	Crow,
	Pigeon
};

enum EAnimalType
{
	AT_Cat,
	AT_Dog,
	AT_Pig,
	AT_Goose,
	AT_Deer,
	AT_Chicken
};

/***********************************************************************/
/************************** Class for birds ****************************/
/***********************************************************************/

class CBirds extends CEntity
{
	editable var destroyEffectTemplate : CEntityTemplate;
	var birdManager : CBirdsManager;
	function SetBirdManager(birdMng : CBirdsManager)
	{
		birdManager = birdMng;
	}
	function KillBird()
	{
		var boneMtx : Matrix;
		var position : Vector;
		var rotation : EulerAngles;
		birdManager.ShouldFly();
		if(destroyEffectTemplate)
		{
			boneMtx = GetRootAnimatedComponent().GetBoneMatrixWorldSpace( 'torso' );
			position = MatrixGetTranslation(boneMtx);
			rotation = MatrixGetRotation(boneMtx);
			theGame.CreateEntity(destroyEffectTemplate, position, rotation);
			birdManager.RemoveBird(this);
			this.Destroy();
		}
	}
	function HandleAardHit(aard : CWitcherSignAard)
	{
		KillBird();
	}
	function HandleIgniHit(igni : CWitcherSignIgni)
	{
		KillBird();
	}
	event OnOwnerEntityLost()
	{
		this.Destroy();
	}
}
class CBirdSpawnpoint extends CEntity
{
	editable var takeRotationFromSpawnpoint : bool;
	default takeRotationFromSpawnpoint = false;
	
	function TakesRotationFromSpawn() : bool
	{
		return takeRotationFromSpawnpoint;
	}
}
class CBirdsManager extends CGameplayEntity
{
	editable var birdsSpawnPointsTag : name;
	editable var birdType : EBirdType;
	editable var spawnRange : float;
	
	var birdSpawnpoints : array<CNode>;
	
	var birdTemplate : CEntityTemplate;
	var spawnedBirds : array<CBirds>;
	var birdsFlying : array<CBirds>;
	var birdsGround : array<CBirds>;
	
	var shouldFly, shouldLand : bool;
	
	default shouldFly = false;
	
	default shouldLand = false;
	
	default spawnRange = 50.0;
	default birdType = Crow;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		StateDefault();
		super.OnSpawned(spawnData);
	}
	function RemoveBird(bird : CBirds)
	{
		spawnedBirds.Remove(bird);
		birdsFlying.Remove(bird);
		birdsGround.Remove(bird);
	}
	function AddToFlying(bird : CBirds)
	{
		birdsFlying.PushBack(bird);
	}
	function RemoveFromFlying(bird : CBirds)
	{
		birdsFlying.Remove(bird);
	}
	function AddToGround(bird : CBirds)
	{
		birdsGround.PushBack(bird);
	}
	function RemoveFromGround(bird : CBirds)
	{
		birdsGround.Remove(bird);
	}
	function ShouldLand()
	{
		shouldLand = true;
		shouldFly = false;
	}
	function ShouldFly()
	{
		shouldFly = true;
		shouldLand = false;
		Fly();
	}
	function Fly()
	{
		var i, size : int;
		var bird : CBirds;
		var count : int;
		/*size = birdsFlying.Size();
		for(i = 0; i < size; i += 1)
		{
			birdsGround.Remove(birdsFlying[i]);
		}*/
		
		size = spawnedBirds.Size();
		for(i = 0; i < size; i += 1)
		{
			bird = spawnedBirds[i];
			if(bird.RaiseEvent('Fly'))
			{
				count += 1;
				AddToFlying(bird);
				RemoveFromGround(bird);
			}
		}
		Log("");
		if(count > 3)
		{
			theSound.PlaySoundOnActor( this, '', "global/global_animals/birds_group_takeoff" );
		}
		else if(count > 0)
		{
			theSound.PlaySoundOnActor( this, '', "global/global_animals/bird_single_takeoff" );
		}
		if(birdsFlying.Size() == spawnedBirds.Size())
		{
			shouldFly = false;
		}
	}
	function Land()
	{
		var i, size : int;
		var bird : CBirds;
		/*size = birdsGround.Size();
		for(i = 0; i < size; i += 1)
		{
			birdsFlying.Remove(birdsGround[i]);
		}*/
		
		size = spawnedBirds.Size();
		for(i = 0; i < size; i += 1)
		{
			bird = spawnedBirds[i];
			if(bird.RaiseEvent('Land'))
			{
				AddToGround(bird);
				RemoveFromFlying(bird);
			}
		}
		size = birdsGround.Size();
		if(birdsGround.Size() == spawnedBirds.Size())
		{
			shouldLand = false;
		}
		Log("");
	}
	function SpawnBirds()
	{
		var i, size : int;
		var bird : CBirds;
		
		size = birdSpawnpoints.Size();
		if(size <= 0)
		{
			theGame.GetNodesByTag(birdsSpawnPointsTag, birdSpawnpoints);
			size = birdSpawnpoints.Size();
		}
		for(i = 0; i < size; i += 1)
		{
			bird = (CBirds)theGame.CreateEntity(birdTemplate, birdSpawnpoints[i].GetWorldPosition(), birdSpawnpoints[i].GetWorldRotation());
			bird.SetBirdManager(this);
			spawnedBirds.PushBack(bird);
			RegisterOwnedEntity(bird);
		}
		birdsGround = spawnedBirds;
	}
	function DespawnBirds()
	{
		var i, size : int;
		size = spawnedBirds.Size();
			
		for(i = 0; i < size; i += 1)
		{
			spawnedBirds[i].Destroy();
		}
		spawnedBirds.Clear();
		birdsGround.Clear();
		birdsFlying.Clear();
	}
	event OnDestroyed()
	{
		DespawnBirds();
		this.RemoveTimer('BirdsSpawnCheck');
	}
	timer function BirdsSpawnCheck(td : float)
	{
		var distance : float;
		var squaredSpawnRange : float;
		
		squaredSpawnRange = spawnRange*spawnRange;
		
		distance = VecDistanceSquared(this.GetWorldPosition(), thePlayer.GetWorldPosition());
		if(spawnedBirds.Size() > 0)
		{
			if(distance > squaredSpawnRange + 10.0)
			{
				DespawnBirds();
			}
			else if(shouldLand)
			{
				Land();
			}
			else if(shouldFly)
			{
				Fly();
			}
		}
		else
		{
			if(distance <= squaredSpawnRange && distance > 64.0)
			{
				SpawnBirds();
			}
		}

	}

}
state Default in CBirdsManager
{
	entry function StateDefault()
	{
		var distance : float;
		var squaredSpawnRange : float;
		squaredSpawnRange = parent.spawnRange*parent.spawnRange;
			
		if(parent.birdType == Crow)
		{
			parent.birdTemplate = (CEntityTemplate)LoadResource("bird\crow");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnBirds();
			}
			parent.AddTimer('BirdsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}
			
		else if(parent.birdType == Pigeon)
		{
			parent.birdTemplate = (CEntityTemplate)LoadResource("bird\pigeon");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnBirds();
			}
			parent.AddTimer('BirdsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}
	}
}
class CBirdsArea extends CEntity
{
	editable var birdsManagerTag : name;
	var birdsManager : CBirdsManager;
	var birdManagers : array<CNode>;
	var i : int;
	var actorsInArea : int;
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		var actovatorNPC : CNewNPC;
		activatorActor = (CActor) activator.GetEntity();
		actovatorNPC = (CNewNPC)activatorActor;
		
		if(activatorActor == thePlayer || actovatorNPC)
		{
			theGame.GetNodesByTag(birdsManagerTag,birdManagers);
			actorsInArea += 1;
			for(i = 0; i < birdManagers.Size(); i += 1)
			{
				birdsManager = (CBirdsManager)birdManagers[i];
				birdsManager.ShouldFly();
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		var actovatorNPC : CNewNPC;
		activatorActor = (CActor) activator.GetEntity();
		actovatorNPC = (CNewNPC)activatorActor;
		
		if(activatorActor == thePlayer || actovatorNPC)
		{
			theGame.GetNodesByTag(birdsManagerTag,birdManagers);
			actorsInArea -= 1;
			if(actorsInArea <= 0)
			{
				actorsInArea = 0;
				for(i = 0; i < birdManagers.Size(); i += 1)
				{
					birdsManager = (CBirdsManager)birdManagers[i];
					birdsManager.ShouldLand();
				}
			}
		}
	}
}


/***********************************************************************/
/******************** Class for animals with AI ************************/
/***********************************************************************/

class CMoveAnimalWander extends CMoveTRGScript
{	
	// Called in order to update the movement goal's channels
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var dist, orientation			: float;
		var currPos, goToPos, moveDir	: Vector;
		
		var heading				: float;
		var newHeading 			: Vector;
		var headingChange 		: float;
		var checkPos 			: Vector;
		var animal 				: CAnimal;
		var bb 					: CBlackboard;
	
		SetFulfilled( goal, false );	
		
		animal = (CAnimal)agent.GetEntity();
		if ( !animal )
		{
			return;
		}
		
		goToPos = animal.GetGoToPosition();
		currPos = animal.GetWorldPosition();
		dist = VecDistanceSquared2D( goToPos, currPos );
		
		 // determine the speed with wich an animal should move
		if ( dist < 0.1f )
		{
			SetSpeedGoal( goal, 0 );
		}
		else
		{
			agent.SetMoveType( animal.GetSpeedFactor() );
			SetSpeedGoal( goal, agent.GetMaxSpeed() );
			
			// calculate heading and orientation
			moveDir = goToPos - currPos;
			orientation = VecHeading( moveDir );
			SetHeadingGoal( goal, moveDir );
			SetOrientationGoal( goal, orientation );
		}
	}
};


class CAnimal extends CActor
{
	var m_manager 						: CAnimalManager;
	editable var m_safeDistToPlayer  	: float;
	var m_goToPosition					: Vector;
	var m_pointIdx						: int;
	var m_trigger 						: CTriggerAreaComponent;
	var m_speedFactor					: EMoveType;
	
	private var m_safeDistToPlayerSq 	: float;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		m_safeDistToPlayerSq = m_safeDistToPlayer * m_safeDistToPlayer;
		m_pointIdx = -1;
		
		CalculateGoToPosition();
		Wander();
	}
	
	event OnOwnerEntityLost()
	{
		DespawnAnimal();
	}
	
	event OnHit( hitParams : HitParams )
	{
		PlayEffect( 'super_strong_hit', this );
		AnimalEnterDead();
	}
	
	timer function DestroyTimer( td : float )
	{
		if(  !WasVisibleLastFrame() )
		{
			if( IsAlive() )
			{
				DespawnAnimal();
			}
			else
			{
				Destroy();
			}
		}
	}
	
	function IsAnimal() : bool
	{
		return true;
	}
	
	function SetAnimalManager(animalMng : CAnimalManager)
	{
		m_manager = animalMng;
	}
	
	function DespawnAnimal()
	{
		m_manager.FreePoint( m_pointIdx );
		//m_manager.RemoveAnimal(this);
		this.Destroy();
	}
	
	function HandleAardHit(aard : CWitcherSignAard)
	{
		PlayEffect( 'aard_hit_fx', this );
		AnimalEnterDead();
	}
	
	function HandleIgniHit(igni : CWitcherSignIgni)
	{
		PlayEffect( 'fireball_hit_fx', this );
		AnimalEnterDead();
	}
	
	function GetGoToPosition() : Vector
	{
		return m_goToPosition;
	}
	
	function GetSpeedFactor() : EMoveType
	{
		return m_speedFactor;
	}
	
	function GetSafeDistanceToPlayer() : float
	{
		return m_safeDistToPlayer;
	}
	
	function CalculateGoToPosition()
	{
		var points : array< Vector >;
		var dist				: float;
		var currPos, goToPos	: Vector;
		var startPtIdx, ptIdx, i, count		: int;
		
		if ( m_trigger )
		{
			// find a point to run to
			currPos = GetWorldPosition();
			m_trigger.GetWorldPoints( points );
			count = points.Size();
			
			m_manager.FreePoint( m_pointIdx );
			
			dist = 0;
			startPtIdx = Rand( count ); 
			for ( i = 0; i < count; i += 1 )
			{
				ptIdx = ( startPtIdx + i ) % count;
				if ( m_manager.IsPointAvailable( ptIdx ) == false )
				{
					continue;
				}
				goToPos = points[ptIdx];
				
				dist = VecDistanceSquared2D( goToPos, currPos );
				if ( dist > 0.1 )
				{
					// we found the point - memorize and lock it
					m_goToPosition = goToPos;
					m_pointIdx = ptIdx;
					m_manager.ReservePoint( m_pointIdx );
					break;
				}
			}
		}
	}
	
	function IsPlayerNear() : bool
	{
		var distToPlayer 		: float;
		var currPos, playerPos	: Vector;
		
		if ( m_safeDistToPlayerSq > 0 )
		{
			playerPos = thePlayer.GetWorldPosition();
			currPos = GetWorldPosition();
			distToPlayer = VecDistanceSquared2D( playerPos, currPos );
				
			return distToPlayer < m_safeDistToPlayerSq;
		}
		else
		{
			return false;
		}
	}
}

state Wander in CAnimal
{ 
	var m_speedChangeTimer	: float;
	var SPEED_CHANGE_FREQ	: float;
	default SPEED_CHANGE_FREQ = 3.0f;
		
	event OnEnterState()
	{
		parent.CalculateGoToPosition();		
		parent.ActionMoveCustomAsync( new CMoveAnimalWander in parent );
		m_speedChangeTimer = 0;
	}
	
	event OnLeaveState()
	{
		parent.ActionCancelAll();
	}
	
	entry function Wander()
	{
		var dist				: float;
		var currPos, goToPos	: Vector;
		
		while( true )
		{
			Sleep( 0.5f );
			
			goToPos = parent.GetGoToPosition();
			currPos = parent.GetWorldPosition();
			dist = VecDistanceSquared2D( goToPos, currPos );
			if ( dist < 0.1f )
			{
				parent.Idle();
			}
			
			// speed change
			if ( parent.IsPlayerNear() )
			{
				parent.m_speedFactor = MT_Run;
			}
			else if( dist < 2.f )
			{
				parent.m_speedFactor = MT_Walk;
			}
			else
			{
				m_speedChangeTimer -= 0.5f;
				if ( m_speedChangeTimer <= 0 )
				{		
					AdjustSpeed();
					m_speedChangeTimer = SPEED_CHANGE_FREQ;
				}
			}
		}
	}
	
	function AdjustSpeed()
	{
		// randomize animal's speed
		if ( RandF() < 0.5 )
		{
			parent.m_speedFactor = MT_Walk;
		}
		else
		{
			parent.m_speedFactor = MT_Run;
		} 
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
		
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can always slide along
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		parent.PushAway( pusher );
	}
}

state Idle in CAnimal
{
	private var m_startWandering 		: bool;
	
	event OnEnterState()
	{
		m_startWandering = false;
	}
	
	event OnLeaveState()
	{
		m_startWandering = false;
	}
	
	event OnAnimEvent( eventName: name, eventTime: float, eventType: EAnimationEventType )
	{
		if( eventName == 'idleEnd' )
		{
			m_startWandering = true;
		}
	}
	
	entry function Idle()
	{		
		while( !m_startWandering )
		{
			Sleep( 0.5f );
			
			if ( parent.IsPlayerNear() )
			{
				break;
			}
		}
		
		parent.Wander();
	}
}

state Dead in CAnimal
{
	entry function AnimalEnterDead()
	{
		parent.SetAlive(false);
		thePlayer.OnNPCDeath(parent);
		parent.RemoveTimer('RemoveCombatSelection');
		parent.ClearRotationTarget();
		parent.EnablePathEngineAgent( false );
		parent.EnablePhysicalMovement( false );
		parent.RaiseForceEvent( 'death' );
		parent.AddTimer( 'DestroyTimer', 3.f, true );
	}
	entry function AnimalEnterDeadAard()
	{
		parent.SetAlive(false);
		thePlayer.OnNPCDeath(parent);
		parent.RemoveTimer('RemoveCombatSelection');
		parent.ClearRotationTarget();
		parent.EnablePathEngineAgent( false );
		parent.EnablePhysicalMovement( false );
		parent.SetRagdoll(true);
		parent.AddTimer( 'DestroyTimer', 3.f, true );
	}
}

//////////////////////////////////////////////////////////////////

class CAnimalSpawnpoint extends CEntity
{
	editable var takeRotationFromSpawnpoint : bool;
	default takeRotationFromSpawnpoint = false;
	
	function TakesRotationFromSpawn() : bool
	{
		return takeRotationFromSpawnpoint;
	}
}
class CAnimalManager extends CGameplayEntity
{
	editable var animalSpawnPointsTag : name;
	editable var animalType : EAnimalType;
	editable var spawnRange : float;
	editable var animalAreaTag : name;
	saved var animalAreaEntity : CEntity;
	
	var animalSpawnpoints : array<CNode>;
	
	var animalTemplate : CEntityTemplate;
	var spawnedAnimals : array<CAnimal>;
	var pointOccupation : array<bool>;

	default spawnRange = 50.0;
	default animalType = AT_Cat;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		StateDefault();
		super.OnSpawned(spawnData);
	}
	
	function RemoveAnimal(animal : CAnimal)
	{
		spawnedAnimals.Remove(animal);
	}

	function SpawnAnimals()
	{
		var i, size : int;
		var animal : CAnimal;
		
		animalAreaEntity = theGame.GetEntityByTag( animalAreaTag );
		InitializeWaypoints();
		
		size = animalSpawnpoints.Size();
		if(size <= 0)
		{
			theGame.GetNodesByTag(animalSpawnPointsTag, animalSpawnpoints);
			size = animalSpawnpoints.Size();
		}
		for(i = 0; i < size; i += 1)
		{
			animal = (CAnimal)theGame.CreateEntity(animalTemplate, animalSpawnpoints[i].GetWorldPosition(), animalSpawnpoints[i].GetWorldRotation());
			animal.m_trigger = (CTriggerAreaComponent)animalAreaEntity.GetComponentByClassName( 'CTriggerAreaComponent' );
			animal.SetAnimalManager( this );
			spawnedAnimals.PushBack(animal);
			RegisterOwnedEntity(animal);
		}
	}
	function DespawnAnimals()
	{
		var i, size : int;
		size = spawnedAnimals.Size();
			
		for(i = 0; i < size; i += 1)
		{
			spawnedAnimals[i].Destroy();
		}
		spawnedAnimals.Clear();
		pointOccupation.Clear();
	}
	event OnDestroyed()
	{
		DespawnAnimals();
		this.RemoveTimer('AnimalsSpawnCheck');
	}
	timer function AnimalsSpawnCheck(td : float)
	{
		var distance : float;
		var squaredSpawnRange : float;
		
		squaredSpawnRange = spawnRange*spawnRange;
		
		distance = VecDistanceSquared(this.GetWorldPosition(), thePlayer.GetWorldPosition());
		if(spawnedAnimals.Size() > 0)
		{
			if(distance > squaredSpawnRange + 10.0)
			{
				DespawnAnimals();
			}
		}
		else
		{
			if(distance <= squaredSpawnRange && distance > 64.0)
			{
				SpawnAnimals();
			}
		}

	}
	
	
	// --------------------------------------------------------------
	
	function InitializeWaypoints()
	{
		var movementTrigger : CTriggerAreaComponent;
		var points : array< Vector >;
		var i, count : int;
		
		if ( pointOccupation.Size() == 0 )
		{
			// initialize the number of points 
			movementTrigger = (CTriggerAreaComponent)animalAreaEntity.GetComponentByClassName( 'CTriggerAreaComponent' );
			if ( movementTrigger )
			{
				movementTrigger.GetWorldPoints( points );
				count = points.Size();
				for ( i = 0; i < count; i += 1 )
				{
					pointOccupation.PushBack( false );
				}
			}
		}	
	}
	
	function ReservePoint( pointIdx : int ) : bool
	{
		if ( pointIdx < 0 )
		{
			return false;
		}
		
		if ( pointOccupation[pointIdx] == false )
		{
			pointOccupation[pointIdx] = true;
			return true;
		}
		else
		{
			return false;
		}
	}

	function FreePoint( pointIdx : int ) : bool
	{
		if ( pointIdx < 0 )
		{
			return false;
		}
		if ( pointOccupation[pointIdx] == true )
		{
			pointOccupation[pointIdx] = false;
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function IsPointAvailable( pointIdx : int ) : bool
	{
		if ( pointIdx < 0 )
		{
			return false;
		}
		
		return pointOccupation[pointIdx] == false;
	}

}

state Default in CAnimalManager
{
	entry function StateDefault()
	{
		var distance : float;
		var squaredSpawnRange : float;
		squaredSpawnRange = parent.spawnRange*parent.spawnRange;
			
		if(parent.animalType == AT_Cat)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\cat");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}	
		else if(parent.animalType == AT_Dog)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\dog");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}	
		else if(parent.animalType == AT_Pig)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\pig");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}	
		else if(parent.animalType == AT_Goose)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\goose");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}	
		else if(parent.animalType == AT_Deer)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\deer");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}		
		else if(parent.animalType == AT_Chicken)
		{
			parent.animalTemplate = (CEntityTemplate)LoadResource("animal\chicken");
			Sleep(0.1);
			if(distance <= squaredSpawnRange)
			{
				parent.SpawnAnimals();
			}
			parent.AddTimer('AnimalsSpawnCheck', 1.0 + RandRangeF(0.0, 2.0), true);
		}	
	}
}
