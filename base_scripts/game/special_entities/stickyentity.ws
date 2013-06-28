/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

class W2StickyEntity extends CEntity
{
	editable var workingAreaName : string;
	editable var stickPlaceName : string;
	editable var aardAngleToleration : float;
	//editable var vulnerableActorsTags : array< name >;
	editable var vulnerableActorsTag : name;
	editable var bloodDecalCount : int;
	editable var bloodDecalLifeLength : float;
	editable var bloodDecalFadeTime : float;
	editable var activationLimit : int;
	
	default aardAngleToleration = 20; // in angles
	default bloodDecalCount = 10;
	default bloodDecalLifeLength = 15.0f; // 10.0f
	default bloodDecalFadeTime = 10.0f; // 7.0f
	default activationLimit = 1;
	
	private var hitCheckTimeout : float;
	private var npcAnimComp : CAnimatedComponent;
	private var npc : CNewNPC;
	private var activationCount : int;
	
	private var isInProgress : bool;
	default isInProgress = false;
	default activationCount = 0;
	
	function HandleAardHit( aard : CWitcherSignAard )
	{
		Activate();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		LogChannel( 'stickyEntity', "Spawned ---------------------------------------------------- " );
	}
	
	public function Activate() : bool
	{
		var workingArea : CAreaComponent;
		var npcPos : Vector;
		var workingAreaBounds : Vector;
		var workingAreaRadius : float;
		var actorsInRange : array< CActor >;
		var impulse : Vector;
		var playerToNpcYaw : float;
		var playerToNpcAngle : EulerAngles;
		var playerToNpcDir : Vector;
		var playerRotation : EulerAngles;
		var npcToStickyEntityDist : float;
		var stickPlacePos : Vector;
		var rotateActorAngle : EulerAngles;
		var npcToStickyDir : Vector;
		var npcToStickyAngle : EulerAngles;
		var npcRotation : EulerAngles;
		
		if ( isInProgress )
		{
			LogChannel( 'stickyEntity', "Not activated: in progress" );
			return false;
		}
		if ( activationCount >= activationLimit )
		{
			LogChannel( 'stickyEntity', "Not activated: activation limit exceeded" );
			return false;
		}
		
		// Initialize variables
		
		workingArea = (CAreaComponent)GetComponent( workingAreaName );
		workingAreaRadius = GetAreaRadius( workingArea );
		
		stickPlacePos = GetComponent( stickPlaceName ).GetWorldPosition();
		
		// Check if player is within area
		if ( !workingArea.TestPointOverlap( thePlayer.GetWorldPosition() ) )
		{
			// do not activate if player is outside area
			//return; // TODO: disabled temporary this feature
		}

		// Find actor

		//workingAreaBounds = Vector( workingAreaRadius, workingAreaRadius, 2 );
		//ActorsStorageGetClosestByPos( thePlayer.GetWorldPosition(), actors, -workingAreaBounds, workingAreaBounds, thePlayer, true, true );
		GetActorsInRange( actorsInRange, workingAreaRadius, vulnerableActorsTag, thePlayer );
		npc = (CNewNPC) GetClosestActor( thePlayer.GetWorldPosition(), actorsInRange );
		if ( !npc )
		{
			LogChannel( 'stickyEntity', "Not activated: no NPC found" );
			return false;
		}
		if ( !npc.IsAlive() )
		{
			LogChannel( 'stickyEntity', "Not activated: NPC is not alive" );
			return false;
		}
		
		// calculate angle between aard - do not activate if the angle is huge
		//RotForward( thePlayer.GetWorldRotation() ); // GetHeading()
		playerToNpcDir = VecNormalize( npc.GetWorldPosition() - thePlayer.GetWorldPosition() );
		playerToNpcAngle = VecToRotation( playerToNpcDir );
		playerRotation = thePlayer.GetWorldRotation();
		if ( AbsF( playerRotation.Yaw - playerToNpcAngle.Yaw ) > aardAngleToleration )
		{
			LogChannel( 'stickyEntity', "Not activated: aard angle bad: " + (playerRotation.Yaw - playerToNpcAngle.Yaw) );
			//return false; // disable angle check!
		}
		//LogChannel( 'sticky', playerRotation.Yaw + " : " + playerToNpcAngle.Yaw );
		
		//npc.GetArbitrator().AddGoalIncapacitate( -1, false );		
		npc.SetAlive( false );
		npc.StateTakedownSticky();
		
		npcAnimComp = (CAnimatedComponent)npc.GetComponent( "Character" );
		
		///////////////////////////////////////////////////////////////////////////////
		// rotate actor
		npcToStickyDir = VecNormalize( stickPlacePos - npc.GetWorldPosition() );
		npcToStickyAngle = VecToRotation( npcToStickyDir );
		npcRotation = npc.GetWorldRotation();
		
		rotateActorAngle = VecToRotation( VecNormalize( stickPlacePos - npcPos ) );
		
		if ( AbsF( npcRotation.Yaw - npcToStickyAngle.Yaw ) > 180 )
		{
			rotateActorAngle.Yaw += 180; // back
		}

		//npc.TeleportWithRotation( npc.GetWorldPosition(), rotateActorAngle );
		///////////////////////////////////////////////////////////////////////////////
		
		

		npcToStickyEntityDist = VecDistance( stickPlacePos, npc.GetWorldPosition() );
		//if ( !npcAnimComp.GetCenterOfMassWorldPos( npcPos ) )
		//{
			npcPos = npc.GetWorldPosition();
			npcPos.Z = stickPlacePos.Z;
			//stickPlacePos.Z += npcToStickyEntityDist / 3.0f;
			//stickPlacePos.Z += 0.5f;
			
		//}
		
		//LogChannel( 'stickyEntity', "Distance: " + npcToStickyEntityDist );
		impulse = VecNormalize( stickPlacePos - npcPos );
		LogChannel( 'stickyEntity', "Normalized : " + VecToString( impulse ) );
		impulse = impulse * ( npcToStickyEntityDist * 200.0f ); // 120
		impulse.W = 1.0f;
		
		impulse.Z += 100.0f;
		
		npcAnimComp.ResetRigidBodiesVelocity();
		npc.SetRagdoll( true );
		npcAnimComp.ResetRigidBodiesVelocity();
		npcAnimComp.SetCanStickToMesh('Ragdoll_torso2');
		npcAnimComp.SetCanStickToMesh('Ragdoll_torso');
		npcAnimComp.SetCanStickToMesh('Ragdoll_pelvis');
		npcAnimComp.SetCanStickToMesh('Ragdoll_head');
		
		LogChannel( 'stickyEntity', "Activated : ( Impulse: " + VecToString( impulse ) + " )" );
		LogChannel( 'stickyEntity', " NPC: " + VecToString( npcPos ) + "  Sticky: " + VecToString( stickPlacePos ) + " Dist: " + npcToStickyEntityDist + " )" );
		
		npcAnimComp.SetRootBoneImpulse( impulse );
		
		hitCheckTimeout = 3.0f;
		AddTimer( 'CheckHitTimer', 0.1f, true );
		
		activationCount += 1;
		isInProgress = true;
		return true;
	}

	timer function CheckHitTimer( timeDelta : float )
	{
		var i : int;
		var deathData : SActorDeathData;
		
		//ApplyForceTick( timeDelta );

		// timeout
		hitCheckTimeout -= timeDelta;
		if ( hitCheckTimeout <= 0 )
		{
			RemoveTimer( 'CheckHitTimer' );
			isInProgress = false;
			npc.SetDeadDestructDistance( 5.0 );
			npc.Kill( true, thePlayer ); // XBox HACK: force kill
			//npc.Stun( true, thePlayer );
			return;
		}
		
		if ( npcAnimComp.IsStickedToMesh() )
		{			
			deathData.silent = true;
			npc.SetDeadDestructDistance( 5.0 );
			npc.Kill( true, thePlayer, deathData );
			//npc.Stun( true, thePlayer );
		
			npc.PlayEffect('standard_hit_fx');
			
			for ( i = 0; i < bloodDecalCount; i += 1 )
			{
				SpawnBloodDecalOnHit();
			}
			isInProgress = false;
			RemoveTimer( 'CheckHitTimer' );
		}
	}
	
	private function ApplyForceTick( timeDelta : float )
	{
		var stickPlacePos : Vector;
		var npcPos : Vector;
		var impulse : Vector;
		var npcToStickyEntityDist : float;
		
		stickPlacePos = GetComponent( stickPlaceName ).GetWorldPosition();
		npcToStickyEntityDist = VecDistance( stickPlacePos, npc.GetWorldPosition() );
		//if ( !npcAnimComp.GetCenterOfMassWorldPos( npcPos ) )
		//{
			npcPos = npc.GetWorldPosition();
			npcPos.Z = stickPlacePos.Z;
			//stickPlacePos.Z += npcToStickyEntityDist / 2.0f;
			
		//}
		
		//LogChannel( 'stickyEntity', "Distance: " + npcToStickyEntityDist );
		impulse = VecNormalize( stickPlacePos - npcPos );
		impulse = impulse * ( npcToStickyEntityDist * 10.0f ); // 120
		impulse.W = 1.0f;
		
		//npcAnimComp.SetRootBoneImpulse( impulse );
		npcAnimComp.ApplyLinearImpulse( 0, impulse );
	}
	
	private function GetAreaRadius( areaComponent : CAreaComponent ) : float
	{
		var points : array< Vector >;
		var areaWorldPos : Vector;
		var dist : float;
		var longestDist : float;
		var i : int;
		
		areaWorldPos = areaComponent.GetWorldPosition();
		areaComponent.GetWorldPoints( points );
		longestDist = VecDistance( areaWorldPos, points[0] );
		
		for ( i = 1; i < points.Size(); i += 1 )
		{
			dist = VecDistance( areaWorldPos, points[i] );
			if ( dist > longestDist )
			{
				longestDist = dist;
			}
		}
		
		return longestDist;
	}
	
	private function GetClosestActor( position : Vector, actors : array< CActor > ) : CActor
	{
		var shortestDist : float = 999999.9;
		var dist : float;
		var shortestIdx : int = -1;
		var i : int;
		
		for ( i = 0; i < actors.Size(); i += 1 )
		{
			dist = VecDistanceSquared( position, actors[i].GetWorldPosition() );
			if ( dist < shortestDist )
			{
				shortestDist = dist;
				shortestIdx = i;
			}
		}
		
		if ( shortestIdx >= 0 )
		{
			return actors[ shortestIdx ];
		}
		else
		{
			return NULL;
		}
	}
	
	function SpawnBloodDecalOnHit()
	{
		var mat : IMaterial = thePlayer.GetRandomDecalMaterial();
		var orign, dirFront, dirUp : Vector;
		var angle : float;
		var size : float;
		var matrix : Matrix;
		if( mat )
		{
			dirFront.X = RandRangeF( -1.0, 1.0 );
			dirFront.Y = RandRangeF( -1.0, 1.0 );
			dirFront.Z = -1.0;
			dirFront.W = 1.0;
			
			angle = RandRangeF( 0, 2*Pi() );
			
			dirUp.X = CosF( angle );
			dirUp.Y = SinF( angle );
			dirUp.Z = 0.0f;
			dirUp.W = 1.0f;
			
			size = RandRangeF( 0.7, 1.2 );
			
			//matrix = GetLocalToWorld();
			//orign = GetWorldPosition();
			//orign.Z += 1.0f;
			//orign += matrix.Y;
			
			if ( npcAnimComp.GetCenterOfMassWorldPos( orign ) )
			{
				RendererDecalSpawn( orign, dirFront, dirUp, size, size, 2.0, bloodDecalLifeLength, bloodDecalFadeTime, mat );
			}
		}
	}
}