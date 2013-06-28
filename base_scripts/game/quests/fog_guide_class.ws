///////////////////////////////////
// Special class for fog guide


class CFogGuide extends CNewNPC
{
	var spectreEntity 						: CEntityTemplate;
	var shieldBlockerEntity					: CEntityTemplate;
	
	var occupiedSlots 						: array<CNode>;
	var Spectres 							: array<W2MonsterWraith>;
	var magicShieldID, magicShieldNoBubleID	: SItemUniqueId;
	var magicShieldMesh						: CDrawableComponent;
	var magicRuneMesh						: CDrawableComponent;
	var encounter							: CEncounter;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		magicShieldID =	GetInventory().GetItemId('q201_magic_shield');
		magicShieldNoBubleID =	GetInventory().GetItemId('magic_shield_no_buble');
		encounter = (CEncounter) theGame.GetNodeByTag('quest_fog_main_encounter');
		
		if(this.HasTag('Detmold') == false)
		{
			PlayEffect( 'cast_magic_shield' );
			EquipItem(magicShieldID, false);
		}
	}
	
	function GetFreeTeleportPoint( out teleportPos : CNode ) : bool
	{
		var teleportPosition : Vector;
		var teleportPoints : array<CComponent>;
		var actIdx, randIdx, arrSize : int;
		var i, j : int;
		
		teleportPoints = GetComponentsByClassName('CWayPointComponent');
		
		arrSize = teleportPoints.Size();
		randIdx = (int)( RandF() * arrSize );
		
		for (i = 0; i<arrSize; i+=1)
		{
			actIdx = ( randIdx + i ) % arrSize;
						
			teleportPosition = teleportPoints[actIdx].GetWorldPosition();
			if( teleportPosition == GetWorldPosition() )
			{
				continue;
			}
			
			if( GetFreeReachablePoint( teleportPosition, 0.f, teleportPosition ) == false )
			{
				continue;
			}
			
			if ( occupiedSlots.Contains( teleportPoints[actIdx] ) )
			{
				continue;
			}
			
			teleportPos = teleportPoints[actIdx];
			LogChannel( 'wraith', "found a valid teleport pos for a wraith: [" + teleportPosition.X + ", " + teleportPosition.Y + ", " + teleportPosition.Z + "]" );
			return true;
		}
		
		LogChannel( 'wraith', "No unoccupied teleport positions" );	
			
		return false;
	}
	
	function GetOccupiedNode( spectre : W2MonsterWraith ) : CNode
	{
		var i, count : int;
		count = Spectres.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( Spectres[i] == spectre )
			{
				break;
			}
		}
			
		if ( i >= count )
		{
			LogChannel( 'wraith', "INCONSISTENCY" );	
			return NULL;
		}
		else
		{
			return occupiedSlots[i];
		}
	}
	
	function OccupySlot( node : CNode, spectre : W2MonsterWraith, occupy : bool )
	{
		var i, count : int;
		
		if ( occupy )
		{
			count = occupiedSlots.Size();
			for ( i = 0; i < count; i += 1 )
			{
				if ( occupiedSlots[i] == node )
				{
					break;
				}
			}
			
			if ( i < count )
			{
				LogChannel( 'wraith', "INCONSISTENCY" );	
			}
			else
			{
				occupiedSlots.PushBack( node );
				Spectres.PushBack( spectre );
				LogChannel( 'wraith', "dodajemy upiora [" + occupiedSlots.Size() + ", " + Spectres.Size() + "]" );
			}
		}
		else
		{
			occupiedSlots.Remove( node );
			Spectres.Remove( spectre );
			LogChannel( 'wraith', "usuwamy upiora [" + occupiedSlots.Size() + ", " + Spectres.Size() + "]" );
		}
	}
}

state UnderAttack in CFogGuide
{	
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.PlayEffect( 'wraith_energy_fx', parent );
		parent.StopEffect( 'cast_magic_shield');
		parent.RaiseForceEvent('trap');
		parent.GetInventory().StopItemEffect(parent.magicShieldID, 'shield_area__fx');
		parent.GetInventory().UnmountItem(parent.magicShieldID, true);
		parent.GetInventory().MountItem(parent.magicShieldNoBubleID, false);
		parent.GetInventory().PlayItemEffect(parent.magicShieldNoBubleID, 'wraith_border_area');
		parent.encounter.SetEnableState(false);
		
		Log("MAIN FOG ENCOUNTER" + parent.encounter + " IS ENABLED = " + parent.encounter.IsEncounterActive() );
		
		parent.occupiedSlots.Clear();
		parent.Spectres.Clear();
	}
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		parent.StopEffect( 'wraith_energy_fx' );
		parent.PlayEffect( 'cast_magic_shield' );
		parent.RaiseEvent('trapEnd');
		parent.GetInventory().StopItemEffect(parent.magicShieldNoBubleID, 'wraith_border_area');
		parent.GetInventory().UnmountItem(parent.magicShieldNoBubleID, true);
		parent.GetInventory().MountItem(parent.magicShieldID, false);
		parent.GetInventory().PlayItemEffect(parent.magicShieldID, 'shield_area__fx');
		//parent.magicShieldMesh.SetVisible(true);
		//parent.magicRuneMesh.SetVisible(true);
		parent.encounter.SetEnableState(true);
		
		Log("MAIN FOG ENCOUNTER" + parent.encounter + " IS ENABLED = " + parent.encounter.IsEncounterActive() );
	}
	
	entry function SpectresAppear()
	{
		var shieldBlocker 	: CEntity;
		var fightTimeLeft	: float;
		var deathData 		: SActorDeathData;
		var i, count		: int;
		var wraith			: W2MonsterWraith;
		var distToPlayer	: float;
		
		parent.LockEntryFunction( true );
		
		parent.spectreEntity = (CEntityTemplate)LoadResource( "gameplay\act2_fog_special_spectre" );
		parent.shieldBlockerEntity = (CEntityTemplate)LoadResource( "gameplay\magic_shield_blocker" );
		shieldBlocker = theGame.CreateEntity( parent.shieldBlockerEntity, parent.GetWorldPosition(), parent.GetWorldRotation() );
		SpawnSpectre(3);
		
		if ( parent.Spectres.Size() != 3 )
		{
			LogChannel( 'wraith', "Udalo sie stworzyc jedynie " + parent.Spectres.Size() + " upiory" );
		}
		
		fightTimeLeft = 180.0f; // the fight can last as long as 3 minutes
		while ( parent.Spectres.Size() > 0 && fightTimeLeft >= 0.0f )
		{
			Sleep ( 1.f );
			fightTimeLeft -= 1.0f;
			
			// remove all non-existant specters
			count = parent.Spectres.Size();
			for ( i = count - 1; i >= 0; i -= 1 )
			{
				wraith = parent.Spectres[ i ];
				if ( !wraith )
				{
					parent.Spectres.Erase( i );
					parent.occupiedSlots.Erase( i );
				}
			}
			
			// kill a spectre if it gets too far away from the player
			count = parent.Spectres.Size();
			for ( i = 0; i < count; i += 1 )
			{
				wraith = parent.Spectres[ i ];				
				distToPlayer = VecDistance2D( thePlayer.GetWorldPosition(), wraith.GetWorldPosition() );
				if ( distToPlayer > 25.0f ) 
				{
					// SAFEGUARD: player is too far away. We believe that there's
					// a problem with ghost teleports - that for some reason
					// they get teleported too  some location too far away - this
					// is a safeguard for that.
					// We can allow the player to get as far as to the opposite side of the bubble - but that's
					// it and a bit further. The bubble is 18 meters wide, so let's throw
					// a few additional meters of spare just in case - but if the ghost really
					// gets teleported somewhere far away - the safeguard will fire and
					// the ghost will die
					deathData.silent = true;
					wraith.Kill( true, thePlayer, deathData );
				}
			}
		}
		
		// kill the remianing wraiths and free the slots they maya be occupying
		deathData.silent = true;
		while ( parent.Spectres.Size() > 0 )
		{
			parent.Spectres[0].Kill( true, thePlayer, deathData );
		}
		parent.occupiedSlots.Clear();
		
		LogChannel( 'wraith', "Wszystkie upiory ubite" );
		
		FactsRemove( "owl_stopped" );
		LogChannel( 'wraith', "Fakt usuniety" );
		
		parent.GetArbitrator().AddGoalIdle(true);
		LogChannel( 'wraith', "Goal idle dodany" );
		
		shieldBlocker.Destroy();
		LogChannel( 'wraith', "Shield blocker zniszczony" );
		
		parent.LockEntryFunction( false );
		
	}
	
	latent function SpawnSpectre(quantity : int): bool
	{
		var spawnPoint : CNode;
		var spectre : W2MonsterWraith;
		var i : int;
		var spawnPosition, guidePosition, rotatePosition : Vector;
		var rotation : EulerAngles;
		
		
		for( i = 0; i < quantity;i += 1 )
		{
			spectre = (W2MonsterWraith)NULL;
			
			// Znajdujemy losowo spawnpoint
			if( ! parent.GetFreeTeleportPoint( spawnPoint ) )
			{
				LogChannel( 'wraith', "MEGA FUCKUP !!!!!!!!!!!!!!!!!!!!!!!!" );
				continue;
			}
			
			// Ustawiamy pozycje spawnu
			spawnPosition = spawnPoint.GetWorldPosition();
			
			// Ustawiamy rotacje spawnu
			guidePosition = parent.GetWorldPosition();
			rotatePosition = guidePosition - spawnPosition;
			rotation = EulerAngles();
			rotation.Yaw = VecHeading( rotatePosition );

			// Spawnujemy upiora
			spectre = (W2MonsterWraith) theGame.CreateEntity( parent.spectreEntity, spawnPosition, rotation );
		
			if ( spectre )
			{
				LogChannel( 'wraith', "spawnujemy upiora [" + spawnPosition.X + ", " + spawnPosition.Y + ", " + spawnPosition.Z + "]" );
			}
			else
			{
				LogChannel( 'wraith', "NIE UDALO SIE STWORZYC ENTITY UPIORA!!!" );
			}
			
			parent.OccupySlot( spawnPoint, spectre, true );
			
			while (!spectre.isInitialized)
			{
				Sleep(0.5);
			}
			
			LogChannel( 'wraith', "odpalamy channeling na upiorze [" + spawnPosition.X + ", " + spawnPosition.Y + ", " + spawnPosition.Z + "]" );
			spectre.StartFogChanneling();
		}
			
		return true;
	}
	
}

quest function QSpectresAttackShield( guideTag : name) : bool
{
	var guide : CFogGuide;
	
	guide = (CFogGuide) theGame.GetNPCByTag( guideTag );
	FactsAdd( "owl_stopped", 1 );
	guide.SpectresAppear();
	
	return true;
}

//////////////////////////////////////////////////////////////////////////////////

class FogGuideQ214 extends CEntity
{	
	var targetTag: name;
	
	timer function StartRotating( timeDelta : float )
	{
		var playerPos, targetPos, position : Vector;
		var rotation : EulerAngles;
		
		playerPos = thePlayer.GetWorldPosition();
		targetPos = theGame.GetEntityByTag(targetTag).GetWorldPosition();
		
		position = targetPos - playerPos;
		
		rotation.Yaw = VecHeading( position ) + 90;
		
		TeleportWithRotation( playerPos, rotation );
	}
	
	timer function GuideDespawn( timeDelta : float )
	{
		Destroy();
		
		if( FactsQuerySum('q214_medallion_to_vergen') == 1 || FactsQuerySum('q214_medallion_to_camp') == 1 )
		{
			thePlayer.GetCharacterStats().RemoveAbility( 'q214 greater hp regen on geralt' );
		}
	}
	
	event OnSpawned( spawnData: SEntitySpawnData) 
	{
		//targetTag = 'q214_medallion_target_to_vergen';
		AddTimer( 'StartRotating', 0.01f, true );
		PlayEffect( 'find_path_fx', this);
		
		if( FactsQuerySum('q214_medallion_to_vergen') == 1 || FactsQuerySum('q214_medallion_to_camp') == 1 )
		{
			thePlayer.GetCharacterStats().AddAbility( 'q214 greater hp regen on geralt' );
		}
		
		this.AddTimer('GuideDespawn', 6.0f, false);
	}
}

quest function Q214_SpawnFogGuide( fogGuideTemplate : CEntityTemplate, targetTag : name ) : bool
{
	var fogGuide : FogGuideQ214;

	fogGuide = (FogGuideQ214) theGame.CreateEntity( fogGuideTemplate, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
	
	fogGuide.targetTag = targetTag;
	fogGuide.AddTimer( 'StartRotating', 0.2f, true );
	
	return true;
}
