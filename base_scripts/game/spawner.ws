/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Entity spawner
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

class CSpawner extends CEntity
{
	editable var entityTemplate : CEntityTemplate;
	editable var count : int;
	editable var attitudeToPlayer : EAIAttitude;
	editable var immortalityMode : EActorImmortalityMode;
	editable var hostileSpawnerTag : name;
	editable var spawnTags : array< name >;
	editable var respawn : bool;
	editable var respawnDelay : float;
	editable var initialHealth : int;
	private var spawnedNPCs : array< CNewNPC >;
	private var respawnTime : array< EngineTime >;
	private var respawnNeeded : array< bool >;
	
	default count = 1;
	default attitudeToPlayer = AIA_Hostile;
	default immortalityMode = AIM_None;
	default respawnDelay = 3.0f;
	default initialHealth = 100;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var i : int;
		spawnedNPCs.Clear();
		respawnTime.Clear();
		respawnNeeded.Clear();
		
		spawnedNPCs.Grow(count);
		respawnTime.Grow(count);
		respawnNeeded.Grow(count);
		
		for ( i = 0; i < count; i += 1 )
		{
			respawnNeeded[i] = true;
		}
		
		if( entityTemplate )
		{
			AddTimer( 'Respawn', 1.f, respawn );
		}	
	}
	
	timer function Respawn( t : float )
	{
		var i : int;		
		var entity : CEntity;
		var npc : CNewNPC;
	
		// Remove dead creatures from the table
		for ( i = spawnedNPCs.Size() - 1; i >=0 ; i -= 1 )
		{
			if( !respawnNeeded[i] )
			{
				if ( !spawnedNPCs[ i ] || spawnedNPCs[ i ].IsDead() )
				{
					respawnTime[i] = theGame.GetEngineTime() + respawnDelay;					
					spawnedNPCs[i] = NULL;
					respawnNeeded[i] = true;
				}
			}
		}
	
		// Spawn new creatures to fit the count
		for ( i = 0; i < count; i += 1 )
		{
			if( respawnNeeded[i] && theGame.GetEngineTime() > respawnTime[i] )
			{
				entity = theGame.CreateEntity( entityTemplate, GetWorldPosition(), GetWorldRotation(), true, false, false, PM_SaveStateOnly );
	
				npc = ( CNewNPC ) entity;
				if ( npc )
				{
					spawnedNPCs[i] = npc;
					respawnNeeded[i] = false;
					npc.SetAttitude( thePlayer, attitudeToPlayer );
					npc.SetImmortalityModePersistent( immortalityMode );
					npc.SetTags( spawnTags );
				}
			}				
		}	
		AddTimer( 'InitSpawned', 0.1, false );
	}
	
	timer function InitSpawned(tm: float)
	{
		var n,i,j : int;
		var hostileSpawner : CSpawner;
		var nodes : array<CNode>;
		
		if( IsNameValid( hostileSpawnerTag ) )
		{
			theGame.GetNodesByTag( hostileSpawnerTag, nodes );
			for( n=0; n<nodes.Size(); n+=1 )
			{				
				hostileSpawner = (CSpawner)nodes[n];
				if( hostileSpawner )
				{
					for( i=0; i<spawnedNPCs.Size(); i+=1 )
					{
						for( j=0; j<hostileSpawner.spawnedNPCs.Size(); j+=1 )
						{
							spawnedNPCs[i].SetAttitude( hostileSpawner.spawnedNPCs[j], AIA_Hostile );
							hostileSpawner.spawnedNPCs[j].SetAttitude( spawnedNPCs[i], AIA_Hostile );
						}
					}
				
				}
			}
		}
		
		for ( i = 0; i < spawnedNPCs.Size(); i+=1 )
		{
			spawnedNPCs[i].SetInitialHealth( initialHealth );
			spawnedNPCs[i].SetHealth( initialHealth, false, thePlayer );
		}

	}
};