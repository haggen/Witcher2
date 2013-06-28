//skrypt odpalajacy dla aktora chodzenie po sciezce z followerem i czekanie na gracza zaleznie od dystansu
latent storyscene function WalkAlongThePathWaitForPlayerInScene(player: CStoryScenePlayer, targetPathTag : name, targetEndofPathTag : name, targetActorTag : name, optional actorFollowerTag : array<name>, 
distanceToStop : float, distanceToGo : float, distanceToChangeSpeed : float, upThePath : bool, optional moveTypename : EMoveType, optional absSpeed : float, optional interceptSectionName : string ) : bool
{
	var target : CEntity;
	var path   : CPathComponent;
	var actor  : CNewNPC;
	var follower  : CNewNPC;
	var endofpath : CEntity;
	var distanceToEnd : float;
	var i : int;
	
	endofpath = (CEntity)theGame.GetNodeByTag( targetEndofPathTag );
	target = (CEntity)theGame.GetNodeByTag( targetPathTag );
	actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );
	while ( !actor )
	{
		actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );	
		Sleep (0.5f);
	}
	
	path = target.GetPathComponent();
	if ( path )
	{
		actor.GetArbitrator().ClearGoal();
		actor.GetArbitrator().AddGoalWalkAlongPathWaitForPlayer( path, upThePath, false, distanceToStop, distanceToGo, distanceToChangeSpeed, moveTypename, absSpeed );
	}
	else
	{
		Log("StartAct1WalkAlongTheBeach: No path found");
	}

	for ( i = 0; i < actorFollowerTag.Size(); i += 1 )
	{
		follower  = (CNewNPC)theGame.GetActorByTag( actorFollowerTag[i] );
		if(follower)
		{
			follower.GetArbitrator().ClearGoal();
			follower.GetArbitrator().AddGoalPointOfInterest( POIT_Follow, actor, 1.f, 0.f, true );
		}
	} 
	
	while ( true )
	{
		distanceToEnd = VecDistance2D( actor.GetWorldPosition(), endofpath.GetWorldPosition() );
		//Log("dystans do end of path " +distanceToEnd);
		if ( distanceToEnd < 0.5f )
			return true;
		
		Sleep( 1.f );
	}
	
	// JP: ponizsze sie nigdy nie wykona
	for ( i = 0; i < actorFollowerTag.Size(); i += 1 )
	{
		follower  = (CNewNPC)theGame.GetActorByTag( actorFollowerTag[i] );
		if(follower)
		{
			//follower.StateIdle();
		}
	}
	
	return true;	
}

//skrypt odpalajacy dla aktora chodzenie po sciezce z followerem i czekanie na gracza zaleznie od dystansu
latent storyscene function WalkToTargetWaitForPlayerInScene(player: CStoryScenePlayer, targetTag : name, targetActorTag : name, 
	distanceToStop : float, distanceToGo : float, moveTypename : EMoveType, absSpeed : float ) : bool
{
	var target : CEntity;
	var actor  : CNewNPC;
	var i : int;
	
	target = (CEntity)theGame.GetNodeByTag( targetTag );
	actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );
	while ( !actor )
	{
		actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );	
		Sleep (0.5f);
	}
	
	if ( target )
	{
		actor.GetArbitrator().ClearGoal();
		actor.GetArbitrator().AddGoalWalkToTargetWaitForPlayer( target, distanceToStop, distanceToGo, moveTypename, absSpeed );
	}
	else
	{
		Log("WalkAlongThePathWaitForPlayerInScene: No target found");
	}
	
	while ( true )
	{
		if ( VecDistance2D( actor.GetWorldPosition(), target.GetWorldPosition() ) < 0.5f )
			return true;
		
		Sleep( 1.f );
	}
	
	return true;	
}
enum EArenaWingmanType
{
	AW_Dwarf,
	AW_Knight,
	AW_Mage
}
storyscene function ArenaSetWingman(player: CStoryScenePlayer, arenaWingman : EArenaWingmanType)
{
	var npc : CNewNPC;
	var targetActorTag : name;
	var picture : int;
	if(arenaWingman == AW_Dwarf)
	{
		targetActorTag ='arena_dwarf';
		picture = 1;
	}
	else if(arenaWingman == AW_Knight)
	{
		targetActorTag = 'arena_knight';
		picture = 3;
	}
	else if(arenaWingman == AW_Mage)
	{
		targetActorTag = 'arena_sorceress';
		picture = 2;
	}
	npc = (CNewNPC)theGame.GetActorByTag(targetActorTag);
	theHud.ArenaFollowersGuiEnabled( true );
	theHud.ArenaFollowersGuiName( npc.GetDisplayName() );
	theHud.ArenaFollowersGuiHealth( 100 );
	theHud.ArenaFollowersGuiPicture( picture );
}
storyscene function SetMaxMoveSpeedType( player: CStoryScenePlayer, moveType : EMoveType, formationFollowerTags : array<name> ) : bool
{
	var followers : array<CNewNPC>;
	var i : int;
	
	if ( moveType == MT_AbsSpeed )
	{
		Log( "Wrong move type" );
		return false;
	}
		
	for ( i = 0; i < formationFollowerTags.Size(); i += 1 )
	{
		theGame.GetNPCsByTag( formationFollowerTags[i], followers );
	}
	if ( followers.Size() == 0 )
	{
		Log( "No followers of formation found" );
		return false;
	}

	// Add followers to formation
	for ( i = 0; i < followers.Size(); i += 1 )
	{
		followers[i].GetMovingAgentComponent().SetMoveType( moveType );
	}
}

//Funkcja do sprawdzania iloœci zabitych wrogów w scenie

latent storyscene function SceneCheckDeadCount( player: CStoryScenePlayer, tag : name, deadCount : int ) : bool
{
	while( true )
	{
		if(FactsQuerySum( "actor_" + tag + "_was_killed" ) >= deadCount)
		{
			return true;
		}
		Log( "---------> KILL LIST COUNT = " + FactsQuerySum( "actor_" + tag + "_was_killed" ) ); 
		Sleep( 0.2f );
	}
}

//funkcja sprawdzaj¹ca iloœæ pokonanych postaci w walce na pieœci

latent storyscene function SceneCheckUnconciousCount( player: CStoryScenePlayer, tag : name, unconciousCount : int ) : bool
{
	while( true )
	{
		if(FactsQuerySum( "actor_" + tag + "_was_stunned" ) >= unconciousCount)
		{
			return true;
		}
		Log( "---------> UNCONCIOUS LIST COUNT = " + FactsQuerySum( "actor_" + tag + "_was_stunned" ) ); 
		Sleep( 0.2f );
	}
}

//funkcja sprawdzaj¹ca czy dana postaæ ¿yje, funkcja sptrawdza to tylko raz i wypuszcza sygna³

storyscene function SceneCheckIfIsAlive( player: CStoryScenePlayer, tag: name ) : bool 
{
	var targetActor : CActor;

	targetActor = theGame.GetActorByTag( tag );
	return targetActor.IsAlive();
}

//funkcja sprawdzaj¹ca godzinê

storyscene function SceneCheckTime( player: CStoryScenePlayer, from_hour: int, to_hour: int ) : bool 
{
	var hour : int;

	hour = GameTimeHours( theGame.GetGameTime() );
	
	if ( hour >= from_hour && hour <= to_hour)
	{
		return true;
	}
	
	return false;
}

//Funkcja zak³adaj¹ca graczowi tryb chodzenia, oraz zdejmuj¹ca go jak chcemy 

storyscene function SetPlayerWalkMode ( player: CStoryScenePlayer, IsWalking: bool ) : bool
{
	thePlayer.SetWalkMode( IsWalking );
	return true;
}

//Funkcja sprawdzaj¹ca czy gracz jest w combat mode

storyscene function CheckCombatMode ( player: CStoryScenePlayer ) : bool
{
	if(thePlayer.IsInCombat() == true)
	{
		return true;
	}
	
	return false;	
}

//SL: Funkcja czekajaca az gracz opusci combat mode

latent storyscene function WaitUntilPlayerLeavesCombatMode ( player: CStoryScenePlayer ) : bool
{
	while(thePlayer.IsInCombat() == true)
	{
		Sleep( 0.5f );
	}
	
	return true;	
}

//SL: Funkcja zabija wszystkie postacie o zadanym TAGu
storyscene function KillAllNPCWithTag( player: CStoryScenePlayer, targetTag : name ) : bool
{
	
	var actors : array <CActor>;
	var i      : int;
	var actor : CActor;
	
	theGame.GetActorsByTag(targetTag, actors);
	
	for (i = 0; i < actors.Size(); i += 1 )
	{	
		actor = actors[i];
		
		actor.ClearImmortality();
		actor.Kill();		
	}
	
	
	return true;
}

//funkcja zak³adaj¹ca lookat

latent storyscene function SceneCameraLookAtTarget( player: CStoryScenePlayer, targetTag : name, duration: float, stop : bool, blockPlayer : bool ) : bool
{
	var target : CNode;
	var geralt : CPlayer;
	
	geralt = thePlayer;
	
	if(!stop)
	{
		target = theGame.GetNodeByTag( targetTag );
		//Sleep ( 0.5f );
		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
			geralt.ResetMovment();
		}
		theCamera.FocusOn( target );
		Sleep( duration );
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	else
	{
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	return true;
}

// i.e. used for enabling/disabling cameralookat when entering/leaving a specified trigger

latent storyscene function SceneCameraLookAtTarget2( player: CStoryScenePlayer, targetTag : name, stop : bool, blockPlayer : bool ) : bool
{
	var target : CNode;
	var geralt : CPlayer;
	
	geralt = thePlayer;
	
	if(!stop)
	{
		target = theGame.GetNodeByTag( targetTag );
		//Sleep ( 0.5f );
		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
		}
		theCamera.FocusOn( target );

		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	else
	{
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	return true;
}



//funkcja w³¹czaj¹ca i wy³¹czaj¹ca eksploracjê

storyscene function EnableComponent ( player: CStoryScenePlayer, shouldBeEnabled : bool, objectTag : name, componentName : string) : bool
{
	var entity    : array <CNode>;
	var component : array <CNode>;
	var count, i : int;
	var single_entity : CEntity;
	var single_component : CComponent;
	

	theGame.GetNodesByTag( objectTag, entity);
	count = entity.Size();
	
	for ( i = 0; i < count; i += 1 )
	{
		single_entity = (CEntity) entity[i];
		if ( ! single_entity )
			continue;
		
		single_component = single_entity.GetComponent( componentName );
		if ( ! single_component )
			continue;
		
		single_component.SetEnabled( shouldBeEnabled );
	}
	
	return true;
}

//Funkcja w której postaæ mo¿e nosiæ drug¹ postaæ do okreœlonego punktu

latent storyscene function SceneNPCStartsCarryingNPC(player: CStoryScenePlayer, carrierTag, carriedTag, masterBehaviorName, slaveBehaviorName, DestinationTag : name,
														latentAction : IActorLatentAction ) : bool
{
	var res : bool;
	res = InteractionNpcMaster( carrierTag, carriedTag, masterBehaviorName, slaveBehaviorName, DestinationTag, latentAction );
	return res;
}

//Funkcja ka¿¹ca postaci iœæ do punktu, funkcja oczekuje na to a¿ NPc dojdzie do punktu

latent storyscene function MoveToObjectUntilReached( player: CStoryScenePlayer, DestinationTag : name, ActorTag: name, moveType : EMoveType, speed : float ) : bool
{
	var Actor					: CNewNPC;
	var Destination				: CNode;
	var distToTarget 			: float;
	var targetPos, actorPos		: Vector;
	var formationsMgr			: CFormationsManager = theGame.GetFormationsMgr();
	var formation				: CFormation;
	var pattern					: IFormationPattern;
	var movementMode 			: CMoveFPGoTo;
	
	Actor = theGame.GetNPCByTag(ActorTag);
	if ( !Actor )
	{
		Log ("Actor not found! Breaking MoveTo!");
		return false;
	}
	
	Destination = theGame.GetNodeByTag( DestinationTag );
	if ( !Destination )
	{
		Log ("Destination point not found! Breaking MoveTo!");
		return false;		
	}
	
	Actor.ClearRotationTarget();
	Actor.GetArbitrator().ClearGoal();
	Actor.GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, 0.5f, EWM_Exit );
	targetPos = Destination.GetWorldPosition();
	
	while ( true )
	{
		actorPos = Actor.GetWorldPosition();
		distToTarget = VecDistance2D( actorPos, targetPos );
		
		if(distToTarget <= 1.0f)
		{
			return true; 
		}
		Sleep( 1.0f );
	}
}

//Funkcja delay

latent storyscene function SceneDelay( player: CStoryScenePlayer, Duration : float ) : bool
{
	Sleep ( Duration );
	return true;
}

//PW: F-kcja ka¿¹ca postaci iœæ do punktu, funkcja nie oczekuje na to a¿ NPc dojdzie do punktu

latent storyscene function MoveToObject (player: CStoryScenePlayer, DestinationTag : name, ActorTag: name, moveType : EMoveType, speed : float ) : bool
{
	var Actor					: CNewNPC;
	var Destination				: CNode;

	Actor = theGame.GetNPCByTagWithTimeout( ActorTag, 3.0 );
	if ( !Actor )
	{
		Log ("Actor not found! Breaking AsyncMoveToObject!");
		return false;
	}
	
	Destination = theGame.GetNodeByTagWithTimeout( DestinationTag, 3.0 );
	if ( !Destination )
	{
		Log ("Destination point not found! Breaking AsyncMoveToObject!");
		return false;
	}
	

	Actor.GetArbitrator().ClearGoal();
	Actor.GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, 0.5f, EWM_Exit );
		
	return true; 
}

//Funkcja wy³aczaj¹ca wandering

latent storyscene function TurnOffWandering (player: CStoryScenePlayer, ActorTag: name, Wandering: bool) : bool
{
	var Actor: CNewNPC;
	Actor = theGame.GetNPCByTag(ActorTag);
	
	while ( !Actor )
	{
		Actor = theGame.GetNPCByTag(ActorTag);
		Sleep ( 0.5f );
	}
	
	//Actor.SetMayRandWander( Wandering );
	return true;
}

//Ustawianie Attitude w scenie
storyscene function SetAttitudeInScene (player: CStoryScenePlayer, actorTag: name, attitude : EAIAttitude) : bool
{
	var actors: array <CNewNPC>;
	var player_in_scene : CActor;
	var count, i : int;
	
	player_in_scene = thePlayer;
	theGame.GetNPCsByTag( actorTag, actors );

	count = actors.Size();

	for ( i = 0; i < count; i += 1 )
	{
		actors[i].SetAttitude(player_in_scene, attitude);
		actors[i].NoticeActor( player_in_scene );
	}
	return true;
}

//PW: ustawia Attitude NPCa do Target
storyscene function SetNPCAttitudeToTarget(player: CStoryScenePlayer, npcTag : name, targetTag: name, attitude : EAIAttitude) : bool
{
	var npcs: array <CNewNPC>;
	var targets: array <CNewNPC>;
	var count, npcCount, i, j : int;
	var npc : CNewNPC;
	
	theGame.GetNPCsByTag( npcTag, npcs );	
	theGame.GetNPCsByTag( targetTag, targets );

	npcCount = npcs.Size();
	count = targets.Size();

	for ( j = 0; j < npcCount; j += 1 )
	{
		npc = npcs[j];
		for ( i = 0; i < count; i += 1 )
		{
			npc.SetAttitude(targets[i], attitude);
			npc.NoticeActor( targets[i] );
		}
	}
	return true;
}

//ekwipowanie itemu npcowi
latent storyscene function EquipItemOnNPCScene (player: CStoryScenePlayer, npc: name, item_name : name) : bool
{
	var item_id : SItemUniqueId;
	var npc_newnpc : CNewNPC;

	npc_newnpc = theGame.GetNPCByTag(npc);
	item_id = npc_newnpc.GetInventory().GetItemId(item_name);
	npc_newnpc.GetInventory().MountItem(item_id);
	return true;
}

//ekwipowanie itemu npcowi
latent storyscene function AddItemOnNPCScene (player: CStoryScenePlayer, npc: name, item_name : name) : bool
{
	var npc_newnpc : CNewNPC;

	if( npc == 'PLAYER') {
		thePlayer.GetInventory().AddItem( item_name );
	}
	else {
		npc_newnpc = theGame.GetNPCByTag(npc);
		npc_newnpc.GetInventory().AddItem( item_name );
	}
	
	return true;
	
}

//usuwanie przedmiotu z NPCa
storyscene function RemoveItemFromNPCScene(player : CStoryScenePlayer, npc : name, item_name : name) : bool
{
	var actor	: CActor		= theGame.GetActorByTag( npc );
	var itemId	: SItemUniqueId = actor.GetInventory().GetItemId( item_name );
	actor.GetInventory().RemoveItem( itemId );
	return true;	
}

//sprawdzenie czy obiekt dostal aardem

latent storyscene function CheckIfAardHit (player: CStoryScenePlayer, ObjectTag : name ) : bool
{
	var fact : string = "object_" + ObjectTag + "_was_hit_by_ard" ;

	while( FactsQuerySum( fact ) == 0 )
	{
		Sleep (0.05f);
	}
	
	return true;
}

//set idle state for anpc
latent storyscene function SetNPCIdleStateScene (player: CStoryScenePlayer, actorTag : array<name> ) : bool
{
	var npcs : array<CNewNPC>;
	var i 	 : int;
	
	for (i = 0; i < actorTag.Size(); i += 1 )
	{
		theGame.GetNPCsByTag( actorTag[i], npcs );
	}
	for (i = 0; i < npcs.Size(); i += 1 )
	{
		npcs[i].GetArbitrator().ClearAllGoals();
		npcs[i].GetArbitrator().AddGoalIdle( true );
	}
	
	return true;
}
storyscene function PlayEffect (player: CStoryScenePlayer, entityTag : name, effectName : name, activate : bool, sfx : bool) : bool
{
	var entities : array <CNode>;
	var i      : int;
	var entity : CEntity;
	
	theGame.GetNodesByTag(entityTag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{
		entity = (CEntity) entities[i];
		if (activate == true)
		{
			if (sfx == false)
			{
				entity.PlayEffect(effectName);
			}
			else
			{
				theSound.PlaySoundOnActor( entity, '', NameToString( effectName) );
			}
		}
		else if (activate == false)
		{
			if (sfx == false)
			{
				entity.StopEffect(effectName);
			}
		}
	}
	
	return true;
}

//PW: f-kcja teleportacji aktora wedle pozycji i rotacji node'a
storyscene function TeleportActorWithRotation ( player: CStoryScenePlayer, actorTag : name, targetDestinationTag : name) : bool
{
	var actor : CEntity;
	var targetDestination : Vector;
	var targetRot : EulerAngles;
	var node : CNode;
	
	node = theGame.GetNodeByTag( targetDestinationTag );
	
	if ( !node )
	{
		Log (" Teleport failed! node of given target is NULL" );
		return false;
	}
	
	actor = theGame.GetActorByTag( actorTag );
	
	if ( !actor )
	{
		Log (" Teleport failed! actor is NULL" );
		return false;
	}
	
	targetDestination = node.GetWorldPosition();
	targetRot	= node.GetWorldRotation();
	
	actor.TeleportWithRotation(targetDestination, targetRot );
	
	return true;
}

//Spawns tentadrake and starts boss fight
latent storyscene function q105_StartBossFight (player: CStoryScenePlayer, Tentadrake : CEntityTemplate ): bool
{
	var lookatTarget			 : Vector;
	var Player 					 : CPlayer;
	var zgn 					 : Zagnica;
	var magicBarrier, sheala	 : CEntity;
	
	lookatTarget = zgn.GetComponent( "mouth_focus" ).GetWorldPosition();
	Player = thePlayer;
	sheala = theGame.GetEntityByTag( 'sheala' );

	zgn = (Zagnica) theGame.CreateEntity( Tentadrake, theGame.GetNodeByTag('zgn_spawnpoint').GetWorldPosition(), theGame.GetNodeByTag('zgn_spawnpoint').GetWorldRotation() );
	
	magicBarrier = (CEntity) theGame.GetNodeByTag( 'electric_obstacle' );
	theCamera.RaiseEvent( 'Camera_Zagnica' );
	
	zgn.TeleportWithRotation( theGame.GetNodeByTag('zgn_spawnpoint').GetWorldPosition(), theGame.GetNodeByTag('zgn_spawnpoint').GetWorldRotation() );
	 
	zgn.StartPhase1();
	Player.EnablePhysicalMovement( true );
	magicBarrier.PlayEffect( 'electric' );
	
	theCamera.FocusOn( zgn.GetComponent( "mouth_focus" ) );
	
//	Player.SetBodyPartState( 'witcher_body_1', 'bomb', true );
//	theCamera.RaiseEvent( 'Camera_Zagnica' );
//	theCamera.LookAtStaticTarget( lookatTarget );
	Log( "Fight with Zagnica started" );
	
	return true;
}

// Funkcja dodaj¹ca wpis do bazy faktów

storyscene function AddFact ( player: CStoryScenePlayer, Fact_ID : name, Fact_Value : int, Valid_for : int, time : int) : bool
{
	FactsAdd( Fact_ID, Fact_Value, -1, time);
	return true;
}

//Funckja sprawdzaj¹ca wpis w bazie faktów

storyscene function Check_if_Fact_exist ( player: CStoryScenePlayer, Fact_ID : name, Fact_Value : int) : bool
{
	var factExist : bool;
	var factValue : int;
	
	factExist = FactsDoesExist ( Fact_ID );
	factValue = FactsQueryLatestValue ( Fact_ID ); 
	
		if ( factExist == true && factValue == Fact_Value )
		{
			return true;
		}
		
		else
		{
			return false;
		}
}

//function that allows to take all the weapon from player and/or give it back
storyscene function GetWeaponFromPlayer (player: CStoryScenePlayer, containerTag : name, remove : bool, dontRemoveNonLethal : bool) : bool
{
	var inv 	   : CInventoryComponent;
	var i 	       : int;
	var container  : CEntity;
	var item_count : int;
	var item_type  : float;
	var player_inv : CInventoryComponent;
	var allItems   : array< SItemUniqueId >;
	var itemId	   : SItemUniqueId;
	var skip       : bool;

	
	container = (CEntity)theGame.GetNodeByTag(containerTag);
	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	player_inv = thePlayer.GetInventory();
	
	player_inv.GetAllItems( allItems );
	
	if (remove)
	{
		for ( i = 0; i < allItems.Size(); i += 1 )
		{	
			itemId = allItems[i];
			
			item_type = player_inv.GetItemAttributeAdditive(itemId, 'itemtype');
			skip = false;
			if( dontRemoveNonLethal && !IsItemLethal( player_inv.GetItemName( itemId ) ) )
			{
				skip = true;
			}
			
			if( !skip )
			{				
				//if (item_type == 1.0 || item_type == 2.0) // add potion name to item list
				if( IsItemWeapon( player_inv.GetItemName( itemId ) ) )
				{
					player_inv.GiveItem(inv, itemId);
				}
			}
		}
	}
	else
	{
		item_count = inv.GetItemCount();
		
		for ( i = 0; i < allItems.Size(); i += 1 )
		{
			inv.GiveItem( player_inv, allItems[i] );
		}
	}
	return true;
}

//function that allows to change door state

storyscene function SetDoorState (player: CStoryScenePlayer, doorTag: name, door_state : EDoorState, immediate : bool ) : bool
{
	var request : CDoorStateRequest;
	
	request = new CDoorStateRequest in theGame;
	request.doorState = door_state;
	request.immediate = immediate;
	theGame.AddStateChangeRequest( doorTag, request );
	
	return true;
}

//funkcja blokujaca wybrany state playerowi
storyscene function BlockPlayerStateInScene ( player: CStoryScenePlayer, isBlocked : bool, stateType : EPlayerState ) : bool
{
	if (isBlocked)
	{
		thePlayer.BlockPlayerState( stateType );
	}
	else
	{
		thePlayer.UnblockPlayerState( stateType );
	}
	return true;
}

//funkcja odblokowujaca wszystkie staty
storyscene function UnBlockAllPlayerStateInScene( player: CStoryScenePlayer) : bool
{
	thePlayer.UnblockAllPlayerStates();
}

//PW: f-kcja obs³uguj¹ca scenê pogoni za celem
storyscene function SetSceneChaseSequence ( player: CStoryScenePlayer, ChasersTag : array<name>, VictimTag : name, timeout : float ) : bool
{
	var Chasers : array<CNewNPC>;
	var Victim : CNode;
	var i : int;
	
	Victim = theGame.GetNodeByTag( VictimTag );
	if ( ! Victim )
	{
		Log ("Victim not found! Breaking SetSceneChaseSequence!");
		return false;
	}
	
	for (i = 0; i < ChasersTag.Size(); i += 1 )
	{
		theGame.GetNPCsByTag( ChasersTag[i], Chasers );
	}
	for (i = 0; i < Chasers.Size(); i += 1 )
	{
		Chasers[i].GetArbitrator().ClearGoal();
		Chasers[i].GetArbitrator().AddGoalPointOfInterest( POIT_Chase, Victim, 2.0f, timeout, true );
	}
	
	return true;
}

//funkcja w³¹czajaca i wy³¹czaj¹ca medytacjê 

storyscene function BlockMeditaction ( player: CStoryScenePlayer, isBlocked : bool ) : bool
{
	thePlayer.EnableMeditation( ! isBlocked );
	return true;
}

storyscene function SetPhysicalMovementOnPlayer ( player: CStoryScenePlayer, enabled : bool ) : bool
{
	var Player : CPlayer;
	
	Player = thePlayer;
	Player.EnablePhysicalMovement( enabled );
	
	return true;
}

// funkcja do wlaczania sklepu z linii dialogowej

storyscene function ShowMeGoods( player: CStoryScenePlayer, merchantTag : CName ) : bool
{
	//Shop( theGame.GetNPCByTag( merchantTag ) );
	RemoveDarkDiffItemsIfNotDarkDiff( theGame.GetNPCByTag( merchantTag ) );
	theHud.ShowShopNew( theGame.GetNPCByTag( merchantTag ) );
}

//PW: Move To dla >1 aktora
latent storyscene function MoveToObjectMultipleActors (player: CStoryScenePlayer, DestinationTag : name, ActorsTag: array<name>, moveType : EMoveType, speed : float, radius : float ) : bool
{
	var Actors: array<CNewNPC>;
	var Destination: CNode;
	var i : int;
	var size : int;
	
	Destination = theGame.GetNodeByTag( DestinationTag );
	if ( ! Destination )
	{
		return false;
	}
	
	size = ActorsTag.Size();
	for ( i = 0; i < size; i += 1 )
	{
		theGame.GetNPCsByTag(ActorsTag[i], Actors);
	}

	if ( Actors.Size() == 0 )
	{
		return false;
	}
	
	size = Actors.Size();
	for ( i = 0; i < size; i += 1 )
	{		
		Actors[i].GetArbitrator().ClearGoal();
		Actors[i].GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, radius, EWM_Exit );
	}
	
	return true; 
}
// Funkcja wy³¹czaj¹ca Sneak Mode
storyscene function SneakModeOff (player: CStoryScenePlayer) : bool
{
	var geralt : CPlayer;
	
	geralt = thePlayer;
	
	geralt.SetSneakMode(false);
	geralt.ChangePlayerState( PS_Exploration );
}

// Funkcja za³¹czaj¹ca dany stan obiektowi fizycznemu - niszczenie

/*storyscene function ChangePhysicStateOfObject (player: CStoryScenePlayer, objectTag : name, destructionState : name) : bool
{
	var object : CEntity;

	object = theGame.GetEntityByTag( objectTag );
	
	object.ForceNewDestructionState( destructionState );
	
	return true;
}*/

//PW: f-kcja do odpalania eventu animacji z behaviora na NPCu
storyscene function SceneRaiseAnimationEvent ( player: CStoryScenePlayer, actorTag : name, behaviorGraphName : name, eventName : name, force : bool) : bool
{
	var actor : CActor;
	
	Log( "ERROR - SceneRaiseAnimationEvent - Nie uzywac tego!!!" );
	
	// PTom: To jest bardzo niebezpieczny kod! Do przerobienia. 
	actor = theGame.GetActorByTag ( actorTag );
	actor.ActivateBehavior( behaviorGraphName );
	
	if ( force == true)
		actor.RaiseForceEvent( eventName );
	
	else
		actor.RaiseEvent( eventName );
	
	return true;
}
// Funkcja wlaczajaca interaction Talk

storyscene function EnableTalkComponent ( player: CStoryScenePlayer, shouldBeEnabled : bool, actorTag : name ) : bool
{
	var object	: CActor;
	var component : CComponent;
	
	object = theGame.GetActorByTag( actorTag );
	component = object.GetComponent ( "talk" );
	component.SetEnabled( shouldBeEnabled );

	return true;
}

storyscene function TeleportOutOfScene( player : CStoryScenePlayer, actorTag: name, destinationTag : name ) : bool
{
	var npc : CNewNPC;
	var destination : CNode;
	
	npc = (CNewNPC) ( theGame.GetActorByTag( actorTag ) );
	destination = theGame.GetNodeByTag( destinationTag );
	
	player.RemoveActorFromScene( npc.GetVoicetag() );
	npc.Teleport( destination.GetWorldPosition() );
	
	return true;
}

// Zalozenie mappinu na obiekt

storyscene function SetMappin( player : CStoryScenePlayer, ObjectTag: name, MappinName : name, mapDescription : string, minimapDisplay : bool, enabled : bool, type : EMapPinType, remove : bool) : bool
{
	var displayMode : EMapPinDisplayMode;
	var destination : CGameplayEntity;
	destination = (CGameplayEntity) theGame.GetEntityByTag( ObjectTag );
	
	if ( ! destination )
		return false;
	
	if( ! remove )
	{
		if ( minimapDisplay )	displayMode = MapPinDisplay_Both;
		else					displayMode = MapPinDisplay_Map;

		destination.MapPinSet( enabled, MappinName, mapDescription, type, displayMode );
	}
	else
	{
		destination.MapPinClear();
	}
	return true;
}

//PW: f-kcja do ukrywania/odkrywania warstw

storyscene function ShowHideLayer ( player : CStoryScenePlayer, layerTag: name, show : bool ) : bool
{
	// DEPRECATED, use ShowLayerGroup() instead
	//theGame.GetWorld().ShowLayers( layerTag, show );
	
	return true;
}

//PW: f-kcja do ustawiania POIT

latent storyscene function GatherActorsSetPOIT (player: CStoryScenePlayer, DestinationTag : name, ActorsTag: array<name>, actorSearchRange : float, poit : EPointOfInterestType, radius, timeout : float, observePOIT : bool ) : bool
{
	var actors: array<CActor>;
	var destination: CNode;
	var i, j : int;
	var size : int;
	var npc : CNewNPC;
	
	destination = theGame.GetNodeByTag( DestinationTag );
	if ( ! destination )
	{
		return false;
	}
	
	size = ActorsTag.Size();
	for ( i = 0; i < size; i += 1 )
	{
		GetActorsInRange( actors, actorSearchRange, ActorsTag[i], destination, NULL );
	}
		
	size = actors.Size();
	for ( j = 0; j < size; j += 1 )
		{
		npc = (CNewNPC)actors[j];
			if (npc)
			{				
				npc.GetArbitrator().ClearGoal();
				npc.GetArbitrator().AddGoalPointOfInterest( poit, destination, radius, timeout, observePOIT );
			}
		}
	
	return true; 
}

// Blackscreen z fade out i fade in
latent storyscene function BlackscreenWithFadeIn ( player : CStoryScenePlayer, fadeOut : bool, fadeIn : bool, duration : float) : bool
{
	if ( fadeIn && !fadeOut )
	{
		theGame.FadeOut( 0.f );
		Sleep ( duration );
		theGame.FadeIn();
	}
	else if ( fadeOut && !fadeIn )
	{
		theGame.FadeOut();
		Sleep ( duration );
	}
	else if ( fadeOut && fadeIn )
	{
		theGame.FadeOut();
		Sleep ( duration );
		theGame.FadeIn();
	}
	else if ( !fadeOut && !fadeIn )
	{
		theGame.FadeOut( 0.f );
	}
	
	return true;
}

// Funkcja odpalajaca napis w cutscenie
latent storyscene function CSplayText ( player : CStoryScenePlayer, txt1 : string, txt2 : string, duration : float) : bool
{
	var str1 : string;
	var str2 : string;
	if ( txt1 != "" ) str1 = GetLocStringByKeyExt( txt1 );
	if ( txt2 != "" ) str2 = GetLocStringByKeyExt( txt2 );
	theHud.m_hud.setCSText( str1 , str2 );
	thePlayer.AddTimer( 'clearHudTextField', duration, false );	
	//theHud.m_messages.ShowCutsceneText( txt1, txt2 );
	//Sleep ( duration );
	//theHud.m_messages.HideCutsceneText();
	return true;
}

// Funkcja czyszczaca napis w cutscenie
latent storyscene function CSclearText ( player : CStoryScenePlayer ) : bool
{
	//theHud.m_messages.HideCutsceneText();
	thePlayer.AddTimer( 'clearHudTextField', 0.1f, false );	
	return true;
}

//PW: f-kcja do zbierania aktorów i ustawiania ich na leadera z POIT. Nie wa¿ne, nie patrz na to.
latent storyscene function GatherActorsMoveWithLead (player: CStoryScenePlayer, destinationTag : name, actorsTag: array<name>, leaderTag: name, actorSearchRange : float, poit : EPointOfInterestType, radius, leadTimeout : float, actorsTimeout : float, observePOIT : bool ) : bool
{
	var actors: array<CActor>;
	var destination: CNode;
	var i, j : int;
	var size : int;
	var npc,leader : CNewNPC;
	var retries : int;
	
	destination = theGame.GetNodeByTag( destinationTag );
	if ( ! destination )
	{
		return false;
	}
	
	leader = theGame.GetNPCByTag( leaderTag );
	if ( ! leader )
	{
		return false;
	}
		
	leader.GetArbitrator().ClearGoal();
	leader.GetArbitrator().AddGoalPointOfInterest( poit, destination, radius, leadTimeout, observePOIT );
	
	size = actorsTag.Size();
	for ( i = 0; i < size; i += 1 )
	{
		GetActorsInRange( actors, actorSearchRange, actorsTag[i], leader, NULL );
	}
	
	while ( true )
	{
		size = actors.Size();
		for ( j = 0; j < size; j += 1 )
		{
			npc = (CNewNPC) actors[j];
			if (npc && leader != npc )
			{
				npc.GetArbitrator().ClearGoal();
				npc.GetArbitrator().AddGoalWalkWithActor( leader, 1.f, 4.f, actorsTimeout, 0.f, destinationTag, MT_Run, false );
			}
		}
	}
	
	return true; 
}

// Funkcja odpalajaca odpowiedni stan wisielcow na rynku

latent storyscene function Q102_GALLOW ( player : CStoryScenePlayer, allStand : bool, firstHang : bool, secondHang : bool, afterHanging : bool ) : bool
{
	var jaskier : CEntity;
	var zoltan : CEntity;
	var gallow : CEntity;
	var executioner : CEntity;	
	
	var elfHanger : CAnimatedComponent;
	var womanElfHanger : CAnimatedComponent;
	
	var ropeJaskier : CAnimatedComponent;
	var ropeZoltan : CAnimatedComponent;
	var ropeElfHanger : CAnimatedComponent;            
	var ropeWomanElfHanger : CAnimatedComponent;
	
	var leverElfHanger : CAnimatedComponent;           
	var leverWomanElfHanger : CAnimatedComponent;
	
	
	var vectorJaskier : Vector;
	var vectorZoltan : Vector;	
	var vectorElfHanger : Vector;
	var vectorWomanElfHanger : Vector;
	var vectorGallow : Vector;
	var vectorWPhanger1 : Vector;
	var vectorWPhanger2 : Vector;	
	var vectorExecutioner : Vector;		
	
	var rotationJaskier : EulerAngles;	
	var rotationZoltan : EulerAngles;	
	var rotationElfHanger : EulerAngles;
	var rotationWomanElfHanger : EulerAngles;
	var rotationGallow : EulerAngles;	
	var rotationWPhanger1 : EulerAngles;
	var rotationWPhanger2 : EulerAngles;	
	var rotationExecutioner : EulerAngles;	

	var component : CDrawableComponent;

	vectorJaskier = theGame.GetNodeByTag('q102_dandelion').GetWorldPosition();
	vectorZoltan = theGame.GetNodeByTag('q102_zoltan').GetWorldPosition();
	vectorElfHanger = theGame.GetNodeByTag('q102_hanger01_wp').GetWorldPosition();
	vectorWomanElfHanger = theGame.GetNodeByTag('q102_hanger02_wp').GetWorldPosition();
	vectorGallow = theGame.GetNodeByTag('q102_gallow_wp').GetWorldPosition();	
	vectorWPhanger1 = theGame.GetNodeByTag('q102_hanger1_hang').GetWorldPosition();
	vectorWPhanger2 = theGame.GetNodeByTag('q102_hanger2_hang').GetWorldPosition();
	vectorExecutioner = theGame.GetNodeByTag('q102_executioner_wp').GetWorldPosition();	
	
	rotationJaskier = theGame.GetNodeByTag('q102_dandelion').GetWorldRotation();
	rotationZoltan = theGame.GetNodeByTag('q102_zoltan').GetWorldRotation();
	rotationElfHanger = theGame.GetNodeByTag('q102_hanger01_wp').GetWorldRotation();
	rotationWomanElfHanger = theGame.GetNodeByTag('q102_hanger02_wp').GetWorldRotation();
	rotationGallow = theGame.GetNodeByTag('q102_gallow_wp').GetWorldRotation();
	rotationWPhanger1 = theGame.GetNodeByTag('q102_hanger1_hang').GetWorldRotation();
	rotationWPhanger2 = theGame.GetNodeByTag('q102_hanger2_hang').GetWorldRotation();
	rotationExecutioner = theGame.GetNodeByTag('q102_executioner_wp').GetWorldRotation();

	gallow = theGame.GetEntityByTag('q102_gallow');
	jaskier = theGame.GetEntityByTag( 'Dandelion' );
	zoltan = theGame.GetEntityByTag( 'Zoltan' );  
	elfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_hanger01').GetComponent('Character'); 
	womanElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_hanger02').GetComponent('Character');
	executioner = theGame.GetEntityByTag('q102_executioner');

	ropeJaskier = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope1');
	ropeZoltan = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope2');
	ropeElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope3');
	ropeWomanElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope4');
	
	leverElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('lever3');
	leverWomanElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('lever4');  

	if( allStand )
	{
		while ( !jaskier || !zoltan || !elfHanger || !womanElfHanger )
		{
			jaskier = theGame.GetEntityByTag( 'Dandelion' );
			zoltan = theGame.GetEntityByTag( 'Zoltan' );  
			elfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_hanger01').GetComponent('Character');
			womanElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_hanger02').GetComponent('Character');
			Sleep ( 0.01f );
		}
		
	
		jaskier.TeleportWithRotation( vectorJaskier, rotationJaskier);
		zoltan.TeleportWithRotation( vectorZoltan, rotationZoltan);
		gallow.TeleportWithRotation( vectorGallow, rotationGallow);
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorElfHanger, rotationElfHanger);
		theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( vectorWomanElfHanger, rotationWomanElfHanger);
		
		theGame.GetActorByTag('q102_hanger02').EnablePathEngineAgent( false );
		theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );

		/*if( theGame.GetActorByTag('q102_hanger02').GetBehaviorName() != 'q102_hangman' )
		{
			theGame.GetActorByTag('q102_hanger02').GetRootAnimatedComponent().PushBehaviorGraph( 'q102_hangman' );
		}
		
		if( theGame.GetActorByTag('q102_hanger01').GetBehaviorName() != 'q102_hangman' )
		{
			theGame.GetActorByTag('q102_hanger01').GetRootAnimatedComponent().PushBehaviorGraph( 'q102_hangman' );
		}
		
		theGame.GetActorByTag('q102_hanger01').ActivateBoneAnimatedConstraint( gallow, 'pozycja_skazaniec3', 'shiftWeight', 'shift' );
		theGame.GetActorByTag('q102_hanger02').ActivateBoneAnimatedConstraint( gallow, 'pozycja_skazaniec4', 'shiftWeight', 'shift' );
		*/
		jaskier.RaiseForceEvent('hanging_jaskier_off');
		zoltan.RaiseForceEvent('hanging_off');
		
		ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
		ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
		ropeElfHanger.RaiseBehaviorForceEvent('hanging_off');
		ropeWomanElfHanger.RaiseBehaviorForceEvent('hanging_off');
		
		leverElfHanger.RaiseBehaviorForceEvent('hanging_off');
		leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_off');
		
		((CActor) executioner).EnablePathEngineAgent( false );
		executioner.TeleportWithRotation( vectorExecutioner, rotationExecutioner);
		Sleep (0.1);
		((CActor) executioner).EnablePathEngineAgent( true );
		
		return true;
	}
	else if ( firstHang )
	{
	
		component = (CDrawableComponent) gallow.GetComponent( "rope4_mesh" );
		component.SetVisible( false );

		// theGame.GetWorld().LoadLayerAsync("scenes\q102_woman_hanger", false); // DEPRECATED

		theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
		//theGame.GetActorByTag('q102_hanger01').ActivateBoneAnimatedConstraint( gallow, 'pozycja_skazaniec3', 'shiftWeight', 'shift' );
		
		gallow.TeleportWithRotation( vectorGallow, rotationGallow);
		jaskier.TeleportWithRotation( vectorJaskier, rotationJaskier);
		zoltan.TeleportWithRotation( vectorZoltan, rotationZoltan);
		
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorElfHanger, rotationElfHanger);
				
		jaskier.RaiseForceEvent('hanging_jaskier_off');
		zoltan.RaiseForceEvent('hanging_off');
		elfHanger.RaiseBehaviorForceEvent('hanging_off');
		
		ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
		ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
		ropeElfHanger.RaiseBehaviorForceEvent('hanging_off');
		
		leverElfHanger.RaiseBehaviorForceEvent('hanging_off');
		leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_on');
		
		((CActor) executioner).EnablePathEngineAgent( false );
		executioner.TeleportWithRotation( vectorExecutioner, rotationExecutioner);
		Sleep (0.1);
		((CActor) executioner).EnablePathEngineAgent( true );
		
		return true;
	}
	else if ( secondHang )
	{		
		component = (CDrawableComponent) gallow.GetComponent( "rope3_mesh" );
		component.SetVisible( false );
		
		// theGame.GetWorld().LoadLayerAsync("scenes\q102_man_hanger", false); // DEPRECATED

		jaskier.TeleportWithRotation( vectorJaskier, rotationJaskier);
		zoltan.TeleportWithRotation( vectorZoltan, rotationZoltan);
		
		jaskier.RaiseForceEvent('hanging_jaskier_off');
		zoltan.RaiseForceEvent('hanging_off');
		
		ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
		ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
		
		leverElfHanger.RaiseBehaviorForceEvent('hanging_on');
		leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_on');
		
		return true;
	}
	
		else if ( afterHanging )
	{
		theGame.GetActorByTag('q102_hanger02').EnablePathEngineAgent( false );
		theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
		
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorWPhanger1, rotationWPhanger1);
		theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( vectorWPhanger2, rotationWPhanger2);
		
		//theGame.GetActorByTag('q102_hanger01').ActivateBoneAnimatedConstraint( gallow, 'pozycja_skazaniec3', 'shiftWeight', 'shift' );
		//theGame.GetActorByTag('q102_hanger02').ActivateBoneAnimatedConstraint( gallow, 'pozycja_skazaniec4', 'shiftWeight', 'shift' );
		
		elfHanger.RaiseBehaviorForceEvent('hanging_on');
		womanElfHanger.RaiseBehaviorForceEvent('hanging_on');

		ropeElfHanger.RaiseBehaviorForceEvent('hanging_on');
		ropeWomanElfHanger.RaiseBehaviorForceEvent('hanging_on');
		
		leverElfHanger.RaiseBehaviorForceEvent('hanging_on');
		leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_on');
		
		
		zoltan.RaiseForceEvent('Idle');
		jaskier.RaiseForceEvent('Idle');
		ropeJaskier.RaiseBehaviorForceEvent('hanging_on');
		ropeZoltan.RaiseBehaviorForceEvent('hanging_on');
		return true;
	}
	
	return true;
}

//PW: f-kcja do dawania ;-)
storyscene function GiveItemInScene( player: CStoryScenePlayer, giverTag: name, receiverTag : name, itemName : name, optional quantity : int ) : bool
{
	var npc, receiver : CActor;
	var itemId 	  	  : SItemUniqueId;
	var npcInventory  : CInventoryComponent;
	
	npc 		 = theGame.GetActorByTag( giverTag );
	receiver 	 = theGame.GetActorByTag( receiverTag );
	npcInventory = npc.GetInventory();
	itemId 	 = npcInventory.GetItemId( itemName );
	
	if ( quantity > npc.GetInventory().GetItemQuantity( itemId ) )
	{
		Log ("NPC " + giverTag + " doesn't have " + IntToString( quantity ) + " X " + itemName + "!");
		quantity = npc.GetInventory().GetItemQuantity( itemId );
	}
	
	npcInventory.AddItem( receiver.GetInventory().GetItemName( itemId ), quantity, true );
	//npcInventory.GiveItem( receiver.GetInventory(), itemId, quantity );
	
	return true;
}
//Funkcja która pozwala na zabranie lub oddanie itemu NPC-owi
storyscene function GetWeaponFromNPC (player: CStoryScenePlayer, actorTag : name, containerTag : name, remove : bool) : bool
{
	var inv			:  CInventoryComponent;
	var i			: int;
	var container	: CEntity;
	var item_count	: int;
	var item_type	: float;
	var actor_inv	: CInventoryComponent;
	var allItems	: array< SItemUniqueId >;
	var itemId		: SItemUniqueId;

	
	container = (CEntity)theGame.GetNodeByTag(containerTag);
	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	actor_inv = theGame.GetNPCByTag(actorTag).GetInventory();
	
	if (remove)
	{	
		actor_inv.GetAllItems( allItems );
		for ( i = 0; i < allItems.Size(); i += 1 )
		{	
			itemId = allItems[i];
			item_type = theGame.GetNPCByTag(actorTag).GetInventory().GetItemAttributeAdditive(itemId, 'itemtype');
				
			if (item_type == 1.0 || item_type == 2.0)
			{
				actor_inv.GiveItem(inv, itemId);
			}	
		}
	}
	else
	{
		inv.GetAllItems( allItems );
		
		for ( i = 0; i < allItems.Size(); i += 1 )
		{
			inv.GiveItem(actor_inv, allItems[i]);
		}
	}
	return true;
}

//funkcja pozwalaj¹ca na ustawianie stanu bodypartów
storyscene function SetBodyPartStateInScene (player: CStoryScenePlayer, targetTag : name, bodyPartName : name, bodyPartState : name, optional applyNow : bool) : bool
{
	var entity : CEntity;
	
	entity = theGame.GetEntityByTag(targetTag);
	
	entity.SetBodyPartState( bodyPartName, bodyPartState, applyNow );

	return true;
}

storyscene function DrawSteelSwordGeraltInScene(player : CStoryScenePlayer)
{
	var id : SItemUniqueId;
	var playerInv : CInventoryComponent;

	playerInv = thePlayer.GetInventory();
	id = playerInv.GetItemByCategory('steelsword');
	//playerInv.GetItemId( 'Rusty Steel Sword' );
	if ( id != GetInvalidUniqueId() )
	{
		thePlayer.DrawWeaponInstant( id );
	}
	else
	{
		Log( "[tempshit scene function] Failed to draw steel sword" );
	}
}

storyscene function DrawSilverSwordGeraltInScene(player : CStoryScenePlayer)
{
	var id : SItemUniqueId;
	var playerInv : CInventoryComponent;

	playerInv = thePlayer.GetInventory();
	id = playerInv.GetItemByCategory('silversword');
	//playerInv.GetItemId( 'Rusty Steel Sword' );
	if ( id != GetInvalidUniqueId() )
	{
		thePlayer.DrawWeaponInstant( id );
	}
	else
	{
		Log( "[tempshit scene function] Failed to draw steel sword" );
	}
}

//funkcja pozwalajaæa na dodanie itemu do containera
storyscene function AddItemToContainer (player: CStoryScenePlayer, itemName : name, containerTag : name, quantity : int) : bool
{
	var inv 	   :  CInventoryComponent;
	var container  : CEntity;
	
	container = (CEntity)theGame.GetNodeByTag(containerTag);
	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	
	inv.AddItem(itemName, quantity);
	
	return true;
}

//funkcja scenowa do despawnu postaci
storyscene function DespawnNPCS(player: CStoryScenePlayer, npcTag : name): bool
{
	var npcs : array< CNewNPC >;
	var i : int;

	theGame.GetNPCsByTag( npcTag, npcs );
	
	Log( "DespawnNPCS(): Found " + npcs.Size() + " NPCs with tag " + npcTag );

	for ( i = 0; i < npcs.Size(); i += 1 )
	{
		if( !npcs[i].IsUnconscious() )
		{
			npcs[i].ForceDespawn();
		}
	}
	return true;
}

//unekwipowanie itemu npcowi
storyscene function UnEquipItemOnNPCScene (player: CStoryScenePlayer, npc: name, item_name : name) : bool
{
	var item_id : SItemUniqueId;
	var npc_newnpc : CNewNPC;

	npc_newnpc = theGame.GetNPCByTag(npc);
	item_id = npc_newnpc.GetInventory().GetItemId(item_name);
	npc_newnpc.GetInventory().UnmountItem(item_id);
	return true;
}

latent storyscene function UnEquipItemOnPlayerScene (player: CStoryScenePlayer, item_name : name) : bool
{
	var item_id : SItemUniqueId;

	item_id = thePlayer.GetInventory().GetItemId(item_name);
	thePlayer.GetInventory().UnmountItem( item_id );
	return true;
}

latent storyscene function EquipItemOnPlayerScene (player: CStoryScenePlayer, item_name : name) : bool
{
	var item_id : SItemUniqueId;

	item_id = thePlayer.GetInventory().GetItemId(item_name);
	thePlayer.GetInventory().MountItem( item_id, false );
	return true;
}

storyscene function HideLoadingScreen( player: CStoryScenePlayer ) : bool
{
	// TODO: obsolete?
	return false;
}

storyscene function SetCharacterApearance( player: CStoryScenePlayer, apearance : name, npcTag : name) : bool
{
	var triss : CNewNPC;
	triss =  theGame.GetNPCByTag(npcTag);
	triss.SetAppearance(apearance);
	return true;
}

storyscene function SetGeraltNaked( player: CStoryScenePlayer ) : bool
{
	var cplayer : CPlayer;
	var allItems : array< SItemUniqueId >;
	var i : int;
	
	cplayer = thePlayer;

	cplayer.GetInventory().GetAllItems( allItems );
	
	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		cplayer.GetInventory().UnmountItem( allItems[i], true);
	}
	
	return true;
}
//Funkcja pozwalaj¹ca na rzucenie entity w zdefiniowany cel
storyscene function ThrowObject (player: CStoryScenePlayer, objectTag : name, targetTag : name, angleInDegrees : float, multiplier : float ) : bool 
{
	var target : CNode;
	var object : CEntity;
	var targetPos : Vector;
 
	target = theGame.GetNodeByTag(targetTag);
	object = theGame.GetEntityByTag(objectTag);
	targetPos = target.GetWorldPosition();
 
	ThrowEntity(object, angleInDegrees, targetPos, multiplier);
 
	return true;
}

//Funckja pozwalajaca na chwilowy stun postaci

storyscene function TempStun (player: CStoryScenePlayer, actorTag: name) : bool
{
	//var actor : CActor;
	var actorNPC : CNewNPC;
	
	
	//actor = theGame.GetActorByTag(actorTag);
	actorNPC = theGame.GetNPCByTag(actorTag);	
	actorNPC.Stun();

	return true;
}

//PW: f-kcja do wrzucania lub zrzucania ze stosu behavior grafów na postaci
storyscene function PushOrPopBehaviorGraph ( player: CStoryScenePlayer, actorTag : name, behaviorGraphName : name, push : bool) : bool
{
	var actor : CActor;
	
	Log( "ERROR - PushOrPopBehaviorGraph - Nie uzywac tego!!!" );
	
	// PTom czy na pewno jest cos takiego potrzebne???
	
	actor = theGame.GetActorByTag ( actorTag );
	
	if (push == true)
		actor.AttachBehavior( behaviorGraphName );
		
	else
		actor.DetachBehavior( behaviorGraphName );
		
	return true;
}

//PW: f-kcja do tworzenia entity dynamicznie - mo¿na podawaæ pozycjê z palca lub wzglêdem node'a
storyscene function CreateEntityInScene ( player: CStoryScenePlayer, entityTemplate : CEntityTemplate, position : Vector, optional rotation : EulerAngles,
										orPositionFromWpTag : name, optional optionalUseAppearancesFromIncludes : bool, optional optionalForceBehaviorPose : bool ) : bool
{
	var wpPosition : Vector;
	var wpRotation : EulerAngles;
	var wpEntity   : CNode;
		
	if( position == Vector(0,0,0,0) )
	{
		wpEntity   = theGame.GetNodeByTag( orPositionFromWpTag );
		wpPosition = wpEntity.GetWorldPosition();
		wpRotation = wpEntity.GetWorldRotation();
	
		theGame.CreateEntity( entityTemplate, wpPosition, wpRotation, optionalUseAppearancesFromIncludes, optionalForceBehaviorPose );
	}
	
	else
		theGame.CreateEntity( entityTemplate, position, rotation, optionalUseAppearancesFromIncludes, optionalForceBehaviorPose );
		
	return true;
}

//Funkcja pozwalaj¹ca na aktywowanie kamery po³o¿onej na lokacji
latent storyscene function SetCameraActive (player: CStoryScenePlayer, cameraTag : name, duration : float, blockPlayer : bool, activate : bool) : bool
{
	var camera : CCamera;
	var geralt : CPlayer;
	
	geralt = thePlayer;
	camera = (CCamera)theGame.GetNodeByTag(cameraTag);
	
	if (activate)
	{
		camera.SetActive(true);
		
		if(blockPlayer)
		{
			geralt.SetManualControl(false, false);
		} else
		{
			geralt.SetManualControl(true, true);	
		}
		Sleep(duration);
		
		camera.SetActive(false);
		if(blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	if (!activate)
	{
		camera.SetActive(false);
		
		//if(blockPlayer) - po huj to jest?? jak wylaczasz kamere daj sterowanie na gracza - ZAWSZE
		//{
			geralt.SetManualControl(true, true);
		//}	
	}
	return true;
}

//PW: f-kcja do ustawiania Idle'a na postaci w zasiêgu actorSearchRange
storyscene function SetIdleInRange (player: CStoryScenePlayer, centerPointTag : name, actorSearchRange : float, actorsTag : array<name>) : bool
{
	var npcs 		: array<CActor>;
	var i			: int;
	var centerPoint : CNode;
	var convNPC		: CNewNPC;
	
	if (!centerPoint)
	{
		Log( "SetIdleInRange: NO CENTER POINT FOUND!" );
		return false;
	}
	centerPoint = theGame.GetNodeByTag( centerPointTag );
	
	for ( i = 0; i < actorsTag.Size(); i += 1 )
	{
		GetActorsInRange( npcs, actorSearchRange, actorsTag[i], centerPoint );
	}
		
	for (i = 0; i < npcs.Size(); i += 1 )
	{
		convNPC = (CNewNPC) npcs[i];
		if ( !convNPC )
		{
			Log( "SetIdleInRange: NO NPCS FOUND!" );
			return false;
		}
		convNPC.GetArbitrator().ClearAllGoals();
		convNPC.GetArbitrator().AddGoalIdle( true );
	}
	
	return true;
}

// PW: f-kcja do niszczenia \m/
// pozwala zrobiæ test, czy layer na którym jest obiekt nie zosta³ od³adowany - najczêstsza przyczyna nie dzia³ania destroya
/*storyscene function DestroyObject (player: CStoryScenePlayer, nodeTag : name, debugLayerGroupName : string ) : bool
{
	var node 	 : array <CNode>;
	var entity 	 : CEntity;
	var count, i : int;
	var defLayer : bool;
	
	
	if ( debugLayerGroupName != "" )
	{
		// defLayer = theGame.GetWorld().IsLayerLoaded( debugLayerGroupName ); // DEPRECATED
		if ( !defLayer )
		{
			Log ("DestroyObject: The layer containing the object you wish destroyed has been unloaded!");
			return false;
		}
	}
	
	theGame.GetNodesByTag( nodeTag, node );
	count = node.Size();
	
	for ( i = 0; i < count; i += 1 )
	{	
		entity = (CEntity) node[i];
		if ( !entity )
		{
			Log ("DestroyObject: object you wanted destroyed not found! Maybe the layer containing it has been unloaded, insert debugLayerGroupName and test.");
			return false;
		}
		entity.Destroy();
	}
	
	return true;
}
*/
// MT: funkcja w³¹czaj¹ca/wy³¹czaj¹ca p³on¹ce przeszkody
storyscene function ActivateBurningObstacle ( player: CStoryScenePlayer, targetTag : name, enable : bool ) : bool
{
	var targets : array<CNode>;
	var i, arraySize : int;
	
	theGame.GetNodesByTag( targetTag, targets );

	arraySize = targets.Size();

	if( enable )
	{
		for( i = 0; i < arraySize; i += 1 )
		{
			((CFieryObstacle)targets[i]).startBurning();
		}
		
		return true;
	} 
	else
	{
		for( i = 0; i < arraySize; i += 1 )
		{
			((CFieryObstacle)targets[i]).stopBurning();
		}
		
		return true;
	}
}

/* Tu zosta³o zamkniête Wielkie Z³o.
storyscene latent function PlayAnimation( player: CStoryScenePlayer, targetActorTag : name, animationName : name ) : bool
{
	var targetActor : CActor;
	
	targetActor = (CActor) theGame.GetEntityByTag( targetActorTag );
	
	return ( targetActor.ActionPlaySlotAnimation( "NPC_ANIM_SLOT", animationName, 0.2f, 0.2f ) );
}
*/

//Funkcja w której gracz mo¿e nosiæ postaæ
latent storyscene function ScenePlayerStartsCarryingNPC( player: CStoryScenePlayer, carriedTag, masterBehaviorName, slaveBehaviorName : name, drawWeapon : bool ) : bool
{
	var result : bool;
	result = InteractionPlayerMaster( carriedTag, masterBehaviorName, slaveBehaviorName, drawWeapon );
	return result;
}

// Funkcja startuj¹ca muzyczny motyw
storyscene function PlayMusic( player: CStoryScenePlayer, cueName : name ) : bool
{
	theSound.PlayMusic( cueName );
	return true;
}
	
// Funkcja zatrzymuj¹ca aktualny motyw muzyczny
storyscene function StopMusic( player: CStoryScenePlayer, cueName : name )
{
	theSound.StopMusic( cueName );
}

storyscene function ActivateEnvironment ( player: CStoryScenePlayer, AreaEnvironment: string ) : bool
{
	AreaEnvironmentActivate(AreaEnvironment);
}

/*latent storyscene function ActivateEnvironment ( player: CStoryScenePlayer, AreaEnvironment: string ) : bool
{
	StartAxiiQte();
}
*/

storyscene function SetManualControlInScene( player: CStoryScenePlayer, movement : bool , camera : bool ) : bool
	{
		var geralt : CPlayer;
		
		geralt = thePlayer;
		
		if(!movement && !camera)
		{
			geralt.SetManualControl(false, false);
		}
		
		if(!movement && camera)
		{
			geralt.SetManualControl(false, true);
		}
		
		if(movement && camera)
		{
			geralt.SetManualControl(true, true);
		}
		
		return true;
	}
	
//Funkcja pozwalaj¹ca na za³adowanie lub od³adowanie grupu warstw

storyscene function ManageLayerGroup ( player: CStoryScenePlayer, path : string, load : bool ): bool
{
	if ( load)
	{
		// theGame.GetWorld().LoadLayerAsync(path, false); // DEPRECATED
	}
	else
	{
		// DEPRECATED: Use HideLayerGroup() instead.
		//theGame.GetWorld().UnloadLayer(path);
	}
	return true;
}

//Funkcja pozwalaj¹ca na raisowanie eventów behaviorowych w scenie

storyscene function q000Trebuchet (player: CStoryScenePlayer, trebuchet: name, fire : bool, stop : bool, load : bool) : bool
{

	var trebuchets : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(trebuchet, trebuchets);
	
	for ( i = 0; i < trebuchets.Size(); i += 1 )
	{
		if (fire)
		{
			((CEntity)trebuchets[i]).RaiseEvent('Fire');
		}
		if (load)
		{
			((CEntity)trebuchets[i]).RaiseEvent('Load');
		}
		if (stop)
		{
			((CEntity)trebuchets[i]).RaiseEvent('Stop');
		}
	}
	return true;
}

//Funkcja uruchamiaj¹ca chodzenie po œcie¿ce

latent storyscene function MoveAlongPathInScene(player: CStoryScenePlayer, npcTag : name, pathTag : name, upThePath, fromBegining : bool, margin, speed : float, moveType : EMoveType) : bool
{
	var npc 					: CNewNPC;
	var path   					: CPathComponent;
	var targetPath 				: CEntity;
	
	
	targetPath = theGame.GetEntityByTag(pathTag );
	npc  = theGame.GetNPCByTag( npcTag );
	
	while ( !npc )
	{
		npc  = theGame.GetNPCByTag( npcTag );
		Sleep (0.5f);
	}
	
	path = targetPath.GetPathComponent();
	if ( !path )
	{
		return false;
	}
	
	npc.GetArbitrator().ClearGoal();
	npc.GetArbitrator().AddGoalWalkAlongPath( path, upThePath, fromBegining, margin, moveType, speed);
	
	return true;
}

// Funkcja czekaj¹ca na odpowiedni poziom zycia npc w procentach 
latent storyscene function CheckHealthLevel(player: CStoryScenePlayer, npcTag : name, healthLevel : float) : bool
{
     var npc : CNewNPC;
     var maxHealth, currentHealth, percentHealth : float;
     
     if( npcTag != 'PLAYER' )
     {
		npc  = theGame.GetNPCByTag( npcTag );
		
		maxHealth = npc.initialHealth;
		currentHealth = npc.health;
		percentHealth = currentHealth / maxHealth * 100.0f;
     
		while ( percentHealth >= healthLevel)
		{
			 currentHealth = npc.health;
			 percentHealth = currentHealth / maxHealth * 100.0f;
			 Log ( "Max health:             " + maxHealth + "Current health:            " + currentHealth + "Procent zycia           "  + percentHealth);
			 Sleep( 0.1f );
		}
	 }
	 else
	 {
		maxHealth = thePlayer.initialHealth;
		currentHealth = thePlayer.health;
		percentHealth = currentHealth / maxHealth * 100.0f;
     
		while ( percentHealth >= healthLevel)
		{
			 currentHealth = thePlayer.health;
			 percentHealth = currentHealth / maxHealth * 100.0f;
			 Log ( "Max health:             " + maxHealth + "Current health:            " + currentHealth + "Procent zycia           "  + percentHealth);
			 Sleep( 0.1f );
		}
	 }
	
     return true;
}


// kills player
storyscene function GameOver(player: CStoryScenePlayer) : bool
{
	theSound.PlaySound("gui/gui/gui_gameover");
	theHud.m_hud.SetGameOver();

	return true;
}

//sprawdzenie zgaszenia pochodni

latent storyscene function CheckIfTorchOn (player: CStoryScenePlayer, ObjectTag : name, LightAreaIsOn : bool, doorTag: name, immediate : bool  ) : bool
{
	var Object :  CEntity;
	var Status : bool;

	var door	: CDoor;
	var i		: int;
	var door_state : EDoorState;
	
	Object = (CEntity) theGame.GetNodeByTag( ObjectTag );
	
	
	while( true )
	{
		Status = ((CSneakLightsArea)Object).LightAreaIsOn;

		
		if(Status == true)
		{
				door = (CDoor)theGame.GetNodeByTag( doorTag );
				door.CloseDoor(immediate);
				door.LockDoor(true);
			
			return true;
		}
		
		if(Status == false)
		{
				door = (CDoor)theGame.GetNodeByTag( doorTag );
				door.CloseDoor(immediate);
				door.LockDoor(false);
			
			return false;
		}
	
		
		
		Sleep (0.4f);
	}
}

storyscene function SetPlayerSceneExitState(player: CStoryScenePlayer, exitState : EPlayerState ) : bool
{
	var currentState : EPlayerState;	
	currentState = thePlayer.GetCurrentPlayerState();
	if( currentState != PS_Scene && currentState != PS_Cutscene )
	{
		Log("ERROR SetPlayerSceneExitState will take no effect, invalid player state");
	}
	thePlayer.OnSetSceneExitState( exitState );
	return true;
}
//Funkcja ekwipujaca Geraltowi miecz o cutscenie
storyscene function SetPlayerCombatSteelOnExitState( player: CStoryScenePlayer ) : bool
{
	var swordId : SItemUniqueId;
	
	swordId = thePlayer.GetInventory().GetItemByCategory( 'steelsword', true );
	if( swordId == GetInvalidUniqueId() )
	{
		swordId = thePlayer.GetInventory().GetItemByCategory( 'silversword', true );
		
		if( swordId == GetInvalidUniqueId() )
		{
			thePlayer.OnSetSceneExitState( PS_CombatFistfightDynamic );
			return true;
		}
		else
			thePlayer.OnSetSceneExitState( PS_CombatSilver );
	}
	else
		thePlayer.OnSetSceneExitState( PS_CombatSteel );
	
	thePlayer.SetLastCombatStyle(PCS_Steel);
	thePlayer.GetInventory().MountItem( swordId, true );
	return true;
}

//Funkcja ekwipujaca Geraltowi miecz o cutscenie
storyscene function SetPlayerCombatSilverOnExitState( player: CStoryScenePlayer ) : bool
{
	var swordId : SItemUniqueId;
	
	swordId = thePlayer.GetInventory().GetItemByCategory( 'silversword', true );
	if( swordId == GetInvalidUniqueId() )
	{
		swordId = thePlayer.GetInventory().GetItemByCategory( 'steelsword', true );
		
		if( swordId == GetInvalidUniqueId() )
		{
			thePlayer.OnSetSceneExitState( PS_CombatFistfightDynamic );
			return true;
		}
		else
			thePlayer.OnSetSceneExitState( PS_CombatSteel );
	}
	else
		thePlayer.OnSetSceneExitState( PS_CombatSilver );
	thePlayer.SetLastCombatStyle(PCS_Silver);	
	thePlayer.GetInventory().MountItem( swordId, true );
	return true;
}

// Funkcja zakladajaca na Gui scope do lunety

storyscene function sceneShowScope(player: CStoryScenePlayer, show : bool ) : bool
{
	if( show )
	{
		theHud.m_fx.ScopeStart();
	}
	else
	{
		theHud.m_fx.ScopeStop();
	}

	return true;
	
}

// Funckja odpalajaca .bik'a czyli filmik w grze
latent storyscene function playBikVideoInGame(player: CStoryScenePlayer, video_name : string ) : bool
{
	if( video_name != "")
	{
		theHud.PlayVideo( video_name );
	}
	else
	{
		return false;
	}

	return true;
	
}

// Funckja odpalajaca panel rzemieslnictwa

storyscene function ShowCraftingPanel( player: CStoryScenePlayer ) : bool
{
	theHud.ShowCrafting();
	return true;
}

// Funckja zmieniajaca multiplikator cen w sklepie danego kupca

storyscene function SetMerchantPriceMult( player: CStoryScenePlayer, merchantTag : name, priceMult : float ) : bool
{
	if ( priceMult == 0)
	{
		Log("Trying to set 0 priceMult to merchant with tag " + merchantTag + ". Ignoring this try.");
		return false;
	}
	theGame.GetNPCByTag( merchantTag ).SetPriceMult( priceMult );
	return true;
}

// Funckja dodajaca wpis do dziennika o journalEntryId

storyscene function AddJournalEntry( player: CStoryScenePlayer, journalEntryType : EJournalKnowledgeGroup, journalEntryId,
									 journalEntrySubId : string, journalEntryCategory : string, journalEntryImage : string ) : bool
{
	if ( journalEntryId == "")
	{
		Log("Trying to add journal entry with empty JournalId!. Ignoring this try.");
		return false;
	}
	thePlayer.AddJournalEntry( journalEntryType, journalEntryId, journalEntrySubId, journalEntryCategory, journalEntryImage );
	return true;
}

// Funckja sprawdzajaca czy powiodla sie aksjacja

storyscene function GameplayOptionAxii( player: CStoryScenePlayer, neededLevel : int, targetNPCTag : name  ) : bool
{
	var axiiLevel : int;
	var chance : float;
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag(targetNPCTag);
	
	axiiLevel  = 0;
	if (thePlayer.GetCharacterStats().HasAbility('story_s1_1')) axiiLevel = 1;
	if (thePlayer.GetCharacterStats().HasAbility('story_s1_2')) axiiLevel = 2;
	if (thePlayer.GetCharacterStats().HasAbility('story_s1_3')) axiiLevel = 3;
	
	AddStoryAbilityCounter("story_s16", 1, 1);
	
	if ( npc.failedAksjacja ) axiiLevel = 0;
	
	if ( neededLevel==-1 ) 
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_aks_16x16.dds'> " + GetLocStringByKeyExt( "Axii failed!" ) );
			npc.SetIsFailedAksjacja();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}	
	
	if ( neededLevel == -1 || axiiLevel <= neededLevel ) 
	{
		if ( neededLevel != -1 && neededLevel < 4 && RandRangeF( 1, 100 ) > 10 ) 
		{	
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_aks_16x16.dds'> " + GetLocStringByKeyExt( "Axii successful!" ) );
			if ( axiiLevel < 3 ) 
			{
				AddStoryAbility("story_s1", axiiLevel + 1);
			}
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return true;
		} else
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_aks_16x16.dds'> " + GetLocStringByKeyExt( "Axii failed!" ) );
			npc.SetIsFailedAksjacja();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}
	};
	if ( axiiLevel == 0 ) 
	{
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_aks_16x16.dds'> " + GetLocStringByKeyExt( "Axii successful!" ) );
		if ( axiiLevel < 3 ) AddStoryAbility("story_s1", axiiLevel + 1);
		npc.SetIsFailedAksjacja();
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		return false;
	}
	
	if ( axiiLevel > neededLevel ) 
	{
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_aks_16x16.dds'> " + GetLocStringByKeyExt( "Axii successful!" ) );
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		if ( axiiLevel < 3 ) AddStoryAbility("story_s1", axiiLevel + 1);
		return true;
	}
	
	return true;
}

// Funckja sprawdzajaca czy powiodlo sie zastraszanie

storyscene function GameplayOptionIntimidate( player: CStoryScenePlayer, neededLevel : int, targetNPCTag : name  ) : bool
{
	var intimidateLevel : int;
	var chance : float;
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag(targetNPCTag);
	
	intimidateLevel  = 0;
	if (thePlayer.GetCharacterStats().HasAbility('story_s2_1')) intimidateLevel = 1;
	if (thePlayer.GetCharacterStats().HasAbility('story_s2_2')) intimidateLevel = 2;
	if (thePlayer.GetCharacterStats().HasAbility('story_s2_3')) intimidateLevel = 3;

	if ( npc.failedZastraszenie ) intimidateLevel = 0;
	
	if ( neededLevel == -1 ) 
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_zast_16x16.dds'> " + GetLocStringByKeyExt( "Intimidation failed!" ) );
			npc.SetIsFailedZastraszenie();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}
		
	if ( neededLevel == -1 || intimidateLevel <= neededLevel ) 
	{
		if ( neededLevel != -1 && neededLevel < 4 &&  RandRangeF( 1, 100 ) > 20 ) 
		{	
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_zast_16x16.dds'> " + GetLocStringByKeyExt( "Intimidation successful!" ) );
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			theGame.UnlockAchievement('ACH_SCARE_HIM');
			if ( intimidateLevel < 3 ) AddStoryAbility("story_s2", intimidateLevel + 1);
			return true;
		} else
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_zast_16x16.dds'> " + GetLocStringByKeyExt( "Intimidation failed!" ) );
			npc.SetIsFailedZastraszenie();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}
	};
	if ( intimidateLevel == 0 ) 
	{	
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_zast_16x16.dds'> " + GetLocStringByKeyExt( "Intimidation successful!" ) );
		npc.SetIsFailedZastraszenie();
		if ( intimidateLevel < 3 ) AddStoryAbility("story_s2", intimidateLevel + 1);
		theGame.UnlockAchievement('ACH_SCARE_HIM');
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		return false;
	}
	if ( intimidateLevel > neededLevel ) 
	{
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_zast_16x16.dds'> " + GetLocStringByKeyExt( "Intimidation successful!" ) );
		if ( intimidateLevel < 3 ) AddStoryAbility("story_s2", intimidateLevel + 1);
		theGame.UnlockAchievement('ACH_SCARE_HIM');
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		return true;
	}
	
	return true;
}

// Funckja sprawdzajaca czy powiodla sie perswazja

storyscene function GameplayOptionPersuade( player: CStoryScenePlayer, neededLevel : int, targetNPCTag : name ) : bool
{
	var persuadeLevel : int;
	var chance : float;
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag(targetNPCTag);
	
	persuadeLevel  = 0;
	if (thePlayer.GetCharacterStats().HasAbility('story_s3_1')) persuadeLevel = 1;
	if (thePlayer.GetCharacterStats().HasAbility('story_s3_2')) persuadeLevel = 2;
	if (thePlayer.GetCharacterStats().HasAbility('story_s3_3')) persuadeLevel = 3;
	
	if ( npc.failedPerswazja ) persuadeLevel = 0;
	
	if ( neededLevel == -1 ) 
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_persw_16x16.dds'> " + GetLocStringByKeyExt( "Persuade failed!" ) );
			npc.SetIsFailedPerswazja();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}
	
	
	if ( neededLevel == -1 || persuadeLevel <= neededLevel ) 
	{
		if ( neededLevel != -1 && neededLevel < 4 && RandRangeF( 1, 100 ) > 20 ) 
		{	
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_persw_16x16.dds'> " + GetLocStringByKeyExt( "Persuade successful!" ) );
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			if ( persuadeLevel < 3 ) AddStoryAbility("story_s3", persuadeLevel + 1);
			return true;
		} else
		{
			theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_persw_16x16.dds'> " + GetLocStringByKeyExt( "Persuade failed!" ) );
			npc.SetIsFailedPerswazja();
			thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
			return false;
		}
	};
	if ( persuadeLevel == 0 ) 
	{
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_persw_16x16.dds'> " + GetLocStringByKeyExt( "Persuade successful!" ) );
		if ( persuadeLevel < 3 ) AddStoryAbility("story_s3", persuadeLevel + 1);
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		return false;
	}
	if ( persuadeLevel > neededLevel ) 
	{
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_persw_16x16.dds'> " + GetLocStringByKeyExt( "Persuade successful!" ) );
		if ( persuadeLevel < 3 ) AddStoryAbility("story_s3", persuadeLevel + 1);
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		return true;
	}
	
	return true;
}

// Funckja sprawdzajaca czy powiodlo sie przekupstwo

latent storyscene function GameplayOptionBribe( player: CStoryScenePlayer, neededAmount : int,
	targetNPCTag : name, text : string ) : bool
{
	var result : bool;
	var bribeValue, bribeMaxValue : int;
	var bribeAmount : int;
	var playerOrensCount : int = thePlayer.GetInventory().GetItemQuantityByName('Orens');

	bribeMaxValue = neededAmount + (int)((float)neededAmount * RandF());

	if ( bribeMaxValue > playerOrensCount )
	{
		bribeMaxValue = playerOrensCount;
	}

	bribeAmount = theHud.ShowBribe( 1, bribeMaxValue, text );

	if ( bribeAmount >= neededAmount )
	{
		result = true;
	}
	else
	{
		result = false;
	}

	// Set last bribe only if it was successful.
	// Failed bribes are ignored
	if( result )
	{
		thePlayer.SetLastBribe( bribeAmount );
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_bribe_16x16.dds'> " + GetLocStringByKeyExt( "Bribe successful!" ) );
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
		// Get bribe money from player
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Orens' ), bribeAmount );
	}
	else
	{
		thePlayer.SetLastBribe( 0 );
		theHud.m_hud.setCSText( "", "<img src='img://globals/gui/icons/quest/icon_g_bribe_16x16.dds'> " + GetLocStringByKeyExt( "Bribe failed!" ) );
		thePlayer.AddTimer( 'clearHudTextField', 1.0f, false );
	}

	return result;
}


// Funckja do zakladow

latent storyscene function GameplayOptionBet( player: CStoryScenePlayer, minAmount : int, maxAmount : int, targetNPCTag : name, text : string ) : bool
{
	var result : bool;
	var bribeValue, bribeMaxValue : int;
	var bribeAmount : int;
	var playerOrensCount : int = thePlayer.GetInventory().GetItemQuantityByName('Orens');

	bribeMaxValue = maxAmount;
	
	if ( playerOrensCount < minAmount ) return false;
	if ( playerOrensCount < maxAmount ) maxAmount = playerOrensCount;

	if ( bribeMaxValue > playerOrensCount )
	{
		bribeMaxValue = playerOrensCount;
	}
	
	bribeAmount = theHud.ShowBribe( minAmount, maxAmount, text );
	
	// Set last bribe only if it was successful.
	// Failed bribes are ignored
	if( bribeAmount > 0 )
	{
		thePlayer.SetLastBribe( bribeAmount );
		//thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Orens' ), bribeAmount );
		result = true;
	}
	else
	{
		thePlayer.SetLastBribe( 0 );
		result = false;
	}

	return result;
}


// Funckja dodaje ability na geratla

storyscene function PCAddAbility( player: CStoryScenePlayer, abilityName : name ) : bool
{
	thePlayer.GetCharacterStats().AddAbility( abilityName );
	return true;
}

// Funckja dodaje ability na NPC

storyscene function NPCAddAbility( player: CStoryScenePlayer, npcTag : name, abilityName : name ) : bool
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetCharacterStats().AddAbility( abilityName );
	return true;
}

// Funckja sprawdza czy jest ability na geralcie

storyscene function PCHasAbility( player: CStoryScenePlayer, abilityName : name ) : bool
{
	return thePlayer.GetCharacterStats().HasAbility( abilityName );
}

// Funckja sprawdza czy jest ability na npc

storyscene function NPCHasAbility( player: CStoryScenePlayer, npcTag : name, abilityName : name ) : bool
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetCharacterStats().HasAbility( abilityName );
	return npc.GetCharacterStats().HasAbility( abilityName );
}

// Funkcja naklada efekt krytyczny na postac npc

storyscene function NPCApplyCriticalEffect( player: CStoryScenePlayer, effectType : ECriticalEffectType, npcTag : name )
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.ApplyCriticalEffect( effectType, thePlayer );
}

// Funckja dodaje ability na geratla

storyscene function QPCAddAbility( player: CStoryScenePlayer, abilityName : name ) : bool
{
	thePlayer.GetCharacterStats().AddAbility( abilityName );
	return true;
}

// Funckja dodaje ability na NPC

storyscene function QNPCAddAbility( player: CStoryScenePlayer, npcTag : name, abilityName : name ) : bool
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetCharacterStats().AddAbility( abilityName );
	return true;
}

// Funckja usuwa ability na geratla

storyscene function QPCRemoveAbility( player: CStoryScenePlayer, abilityName : name ) : bool
{
	thePlayer.GetCharacterStats().RemoveAbility( abilityName );
	return true;
}

// Funckja usuwa ability na NPC

storyscene function QNPCRemoveAbility( player: CStoryScenePlayer, npcTag : name, abilityName : name ) : bool
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetCharacterStats().RemoveAbility( abilityName );
	return true;
}

// Funckja sprawdza czy jest ability na geralcie

storyscene function QPCHasAbility( player: CStoryScenePlayer, abilityName : name ) : bool
{
	return thePlayer.GetCharacterStats().HasAbility( abilityName );
}

// Funckja sprawdza czy jest ability na npc

storyscene function QNPCHasAbility( player: CStoryScenePlayer, npcTag : name, abilityName : name ) : bool
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetCharacterStats().HasAbility( abilityName );
	return npc.GetCharacterStats().HasAbility( abilityName );
}

// funkcja wyswietla kartke z podanym tekstem

storyscene latent function DisplayScrollText( player: CStoryScenePlayer, text : string ) : bool
{
	theHud.ShowScroll( text );
	return true;
}

// funkcja pozwalajaca na zmiane appereanca po tagu
storyscene function ApplyAppearance( player: CStoryScenePlayer, appearanceName : string, npcTag : name  ) : bool 
{
	var actorNPC : CNewNPC;
	

	actorNPC  = theGame.GetNPCByTag( npcTag );

	actorNPC.ApplyAppearance( appearanceName );

	return true;
}

// funkcja pozwalajaca na zmiane appereanca po tagu
storyscene function ApplyAppearanceForEntity( player: CStoryScenePlayer, appearanceName : string, entityTag : name  ) : bool 
{
	var entity : CEntity;
	

	entity  = theGame.GetEntityByTag( entityTag );

	entity.ApplyAppearance( appearanceName );

	return true;
}

// przestawia kamere combatowoa na blizsza i niedynamiczna
storyscene function SceneTurnOffCombatCamera( player: CStoryScenePlayer,  turnOff : bool ) : bool
{
	thePlayer.TurnOffCombatCamera( turnOff );
	return true;
}

// pokazuje end panel
storyscene function GDCEndPanel(player: CStoryScenePlayer) : bool
{
	theSound.MuteAllSounds();
	theSound.SilenceMusic();
	theHud.m_fx.W2LogoStart( true );
	return true;
}

// pokazuje akt info
storyscene function ShowActInfo(player: CStoryScenePlayer, actText : string ) : bool
{
	theHud.m_messages.ShowActText( actText );
	return true;
}

storyscene latent function ShowWarning( player: CStoryScenePlayer, text : string ) : bool
{
	theGame.FadeOut();
	theHud.m_messages.ShowInformationText( text );
	Sleep(5);
	theHud.m_messages.HideInformationText();
	theGame.FadeIn();
	return true;
}

//MT // Removes fact from facts DB
storyscene function RemoveFact( player: CStoryScenePlayer, factId : string ) : bool
{
	// Checks if the specified fact is defined in the DB.
	if( FactsDoesExist( factId ) )
	{
		// Removes a single fact from the facts db.
		FactsRemove( factId );
	}
	
	return true;
}

// pokazuje tekst na ekranie
storyscene function ShowInfo( player: CStoryScenePlayer, text : string ) : bool
{
	theHud.m_messages.ShowInformationText( text );
	return true;
}

//Funkcja do obslugi bram
storyscene function SetGateState (player: CStoryScenePlayer, gateTag: name, on : bool, force : bool ) : bool
{
	var gates	: array <CNode>;
	var gate	: CSwitchableEntity;
	var i		: int;
	
	theGame.GetNodesByTag( gateTag, gates );
	
	for (i = 0; i < gates.Size(); i += 1 )
	{
		gate = (CSwitchableEntity) gates[i];
		if (gate)
		{
			gate.Switch(on,force);
		}
	}
	return true;
}


storyscene function ShowGuiText(player: CStoryScenePlayer, stringName : string) : bool
{
	theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( stringName)  );
	//Sleep(6.0f);

	return true;
}



// q214 - minigra

storyscene function q214_check_minigame (player: CStoryScenePlayer) : bool
{
	var entity	: q214_minigame;
	
	entity = ( q214_minigame) theGame.GetEntityByTag( 'q214_minigame' );
		
	if(entity)
	{
		entity.miniGameStart();
		return true;
	}
	else
	{
		return false;
	}
}

storyscene function q214_clear_minigame (player: CStoryScenePlayer) : bool
{
	var entity	: q214_minigame;
	
	entity = ( q214_minigame) theGame.GetEntityByTag( 'q214_minigame' );
		
	if(entity)
	{
		entity.clearFacts();
		return true;
	}
	else
	{
		return false;
	}
}

// q214 minigra selekcja

storyscene function q214_selection (player: CStoryScenePlayer, a, b, c, d, e, f, g : bool) : bool
{
	var ea, eb, ec, ed, ee, ef, eg	: CEntity;
	
	ea = theGame.GetEntityByTag( 'q214_selection_a' );
	eb = theGame.GetEntityByTag( 'q214_selection_b' );	
	ec = theGame.GetEntityByTag( 'q214_selection_c' );
	ed = theGame.GetEntityByTag( 'q214_selection_d' );
	ee = theGame.GetEntityByTag( 'q214_selection_e' );
	ef = theGame.GetEntityByTag( 'q214_selection_f' );
	eg = theGame.GetEntityByTag( 'q214_selection_g' );

	ea.StopEffect('seletion');
	eb.StopEffect('seletion');	
	ec.StopEffect('seletion');	
	ed.StopEffect('seletion');
	ee.StopEffect('seletion');
	ef.StopEffect('seletion');
	eg.StopEffect('seletion');

	if( a )
	{
		ea.PlayEffect('seletion');
		return true;
	}
	else if ( b )
	{
		eb.PlayEffect('seletion');
		return true;	
	}
	else if ( c )
	{
		ec.PlayEffect('seletion');
		return true;	
	}	
	else if ( d )
	{
		ed.PlayEffect('seletion');
		return true;	
	}	
	else if ( e )
	{
		ee.PlayEffect('seletion');
		return true;	
	}	
	else if ( f )
	{
		ef.PlayEffect('seletion');
		return true;	
	}	
	else if ( g )
	{
		eg.PlayEffect('seletion');
		return true;	
	}	
	else
	{
		ea.StopEffect('seletion');
		eb.StopEffect('seletion');	
		ec.StopEffect('seletion');	
		ed.StopEffect('seletion');
		ee.StopEffect('seletion');
		ef.StopEffect('seletion');
		eg.StopEffect('seletion');
		return true;
	}
}

storyscene function AddExperience (player: CStoryScenePlayer, amount : int ) : bool
{
	//thePlayer.IncreaseExp( amount );
	return true;
}

latent storyscene function ScenePlayVideo( player : CStoryScenePlayer, videoName : string ) : bool
{
	theHud.PlayVideoEx( videoName, false );
	theHud.m_hud.SetMainFrame("ui_dialog.swf");
	return true;
}

storyscene function SceneUnlockAchievement( player : CStoryScenePlayer, achName : name )
{
	theGame.UnlockAchievement( achName );
}

storyscene function SceneLockAchievement( player : CStoryScenePlayer, achName : name )
{
	theGame.LockAchievement( achName );
}

storyscene function SetDrunk( player : CStoryScenePlayer ) : bool
{
	theCamera.SetCameraPermamentShake(CShakeState_Drunk, 1.0);
	thePlayer.PlayEffect('drunk_fx');
	thePlayer.AddTimer('DrunkTimerRemove', 30.0f, false);
	return true;
}

storyscene function GeraltHasMoney( player : CStoryScenePlayer , amount : int ) : bool
{
	if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Orens') ) < amount )
	{
		return false;
	} else
	{
		return true;
	}
}

storyscene function SetMappinAtEntityEnabled( player : CStoryScenePlayer , entityTag : name, enable : bool )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MappinEnable(enable);
}

storyscene function RemoveMappinFromEntity( player : CStoryScenePlayer , entityTag : name )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MapPinClear();
}

storyscene function AddMappinToEntity( player : CStoryScenePlayer , entityTag : name, enabled : bool, pinType : EMapPinType, pinDisplayMode : EMapPinDisplayMode, pinDescription : string, pinName : string )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MapPinSet(enabled, pinName, pinDescription, pinType, pinDisplayMode);
}

storyscene function ShowTutorial( player : CStoryScenePlayer , tutorialId : string, imageName : string, slowTime : bool ) : bool
{
	theHud.m_hud.ShowTutorial( tutorialId, imageName, slowTime );
	//theHud.ShowTutorialPanelOld( tutorialId, imageName  );
}

storyscene function AddOrens( player : CStoryScenePlayer , orensCount : int )
{
	thePlayer.GetInventory().AddItem( 'Orens', orensCount );
}


latent storyscene function SetInstantBlackscreen(player : CStoryScenePlayer ) : bool
{
	theGame.FadeOut( 0.f );
	return true;
}


storyscene function SetSepiaFullscreenEffect (player : CStoryScenePlayer, Enable : bool, fadeIn : float, fadeOut : float) : bool
{
	if( Enable )
	{
		theGame.StartSepiaEffect( fadeIn );
	}
	else
	{
		theGame.StopSepiaEffect( fadeOut );
	}
	
return true;
}

latent storyscene function ChangeGeraltHair ( player : CStoryScenePlayer, hairstyle : EWitcherHairstyle ) : bool 
{
	theGame.FadeOut();
	thePlayer.SetCurrentHair( hairstyle );
	theGame.FadeIn();
	Sleep( 3.0 );
	return true;
}

storyscene function RemoveBetValue ( player : CStoryScenePlayer ) : bool
{
	var amount : int = thePlayer.GetLastBribe();
	
	if ( amount <= thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Orens') ) )
	{
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Orens'), amount );
		return true;
	}
	else
	{
		return false;
	}
}

storyscene function StorePlayerItems( player: CStoryScenePlayer, merchantTag : CName, storageTag : CName ) : bool
{
	theHud.ShowShopNew( theGame.GetNPCByTag( merchantTag ), true, (W2PlayerStorage)theGame.GetEntityByTag( storageTag ) );
}

storyscene function AddDarkDifficultyModeItems( player : CStoryScenePlayer, npc: name ) : bool
{
	var npc_newnpc : CNewNPC = theGame.GetNPCByTag( npc );
	var inventory : CInventoryComponent;
	var playerInventory : CInventoryComponent; 

inventory = npc_newnpc.GetInventory();
playerInventory = thePlayer.GetInventory();
	
	if ( theGame.GetDifficultyLevel() == 4 )
	{
		
		if ( theHud.m_mapCommon.GetMapId() == 1 )
		{
			//ARMOR
			if(!playerInventory.HasItem('Schematic DarkDifficultyArmorA1')	&& !inventory.HasItem( 'Schematic DarkDifficultyArmorA1' ))
			{
				inventory.AddItem( 'Schematic DarkDifficultyArmorA1' );
			}
			//BOOTS
			if(!playerInventory.HasItem('Schematic DarkDifficultyBootsA1') && !inventory.HasItem('Schematic DarkDifficultyBootsA1'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyBootsA1' );
			}
			//GLOVES
			if(!playerInventory.HasItem('Schematic DarkDifficultyGlovesA1') && !inventory.HasItem('Schematic DarkDifficultyGlovesA1'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyGlovesA1' );
			}
			//PANTS	
			if(!playerInventory.HasItem('Schematic DarkDifficultyPantsA1') && !inventory.HasItem('Schematic DarkDifficultyPantsA1'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyPantsA1' );
			}
			//SILVERSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty silversword A1') && !inventory.HasItem('Schematic Dark difficulty silversword A1'))
			{
				inventory.AddItem( 'Schematic Dark difficulty silversword A1' );	
			}
			//STEELSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty steelsword A1') && !inventory.HasItem('Schematic Dark difficulty steelsword A1'))
			{
				inventory.AddItem( 'Schematic Dark difficulty steelsword A1' );	
			}
		}

		
		else if ( theHud.m_mapCommon.GetMapId() == 2 )
		{
			//ARMOR
			if(!playerInventory.HasItem('Schematic DarkDifficultyArmorA2')	&& !inventory.HasItem( 'Schematic DarkDifficultyArmorA2' ))
			{
				inventory.AddItem( 'Schematic DarkDifficultyArmorA2' );
			}
			//BOOTS
			if(!playerInventory.HasItem('Schematic DarkDifficultyBootsA2') && !inventory.HasItem('Schematic DarkDifficultyBootsA2'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyBootsA2' );
			}
			//GLOVES
			if(!playerInventory.HasItem('Schematic DarkDifficultyGlovesA2') && !inventory.HasItem('Schematic DarkDifficultyGlovesA2'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyGlovesA2' );
			}
			//PANTS	
			if(!playerInventory.HasItem('Schematic DarkDifficultyPantsA2') && !inventory.HasItem('Schematic DarkDifficultyPantsA2'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyPantsA2' );
			}
			//SILVERSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty silversword A2') && !inventory.HasItem('Schematic Dark difficulty silversword A2'))
			{
				inventory.AddItem( 'Schematic Dark difficulty silversword A2' );	
			}
			//STEELSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty steelsword A2') && !inventory.HasItem('Schematic Dark difficulty steelsword A2'))
			{
				inventory.AddItem( 'Schematic Dark difficulty steelsword A2' );	
			}			
		}
		else if ( theHud.m_mapCommon.GetMapId() == 3 )
		{
			//ARMOR
			if(!playerInventory.HasItem('Schematic DarkDifficultyArmorA3')	&& !inventory.HasItem( 'Schematic DarkDifficultyArmorA3' ))
			{
				inventory.AddItem( 'Schematic DarkDifficultyArmorA3' );
			}
			//BOOTS
			if(!playerInventory.HasItem('Schematic DarkDifficultyBootsA3') && !inventory.HasItem('Schematic DarkDifficultyBootsA3'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyBootsA3' );
			}
			//GLOVES
			if(!playerInventory.HasItem('Schematic DarkDifficultyGlovesA3') && !inventory.HasItem('Schematic DarkDifficultyGlovesA3'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyGlovesA3' );
			}
			//PANTS	
			if(!playerInventory.HasItem('Schematic DarkDifficultyPantsA3') && !inventory.HasItem('Schematic DarkDifficultyPantsA3'))
			{
				inventory.AddItem( 'Schematic DarkDifficultyPantsA3' );
			}
			//SILVERSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty silversword A3') && !inventory.HasItem('Schematic Dark difficulty silversword A3'))
			{
				inventory.AddItem( 'Schematic Dark difficulty silversword A3' );	
			}
			//STEELSWORDS
			if(!playerInventory.HasItem('Schematic Dark difficulty steelsword A3') && !inventory.HasItem('Schematic Dark difficulty steelsword A3'))
			{
				inventory.AddItem( 'Schematic Dark difficulty steelsword A3' );	
			}			
		}
		return true;
	}
	else
	{
		//REMOVING SCHEMATICS FROM THE MERCHANTS
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA3' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA3' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA3' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA3' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A3' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A1' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A2' ) );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A3' ) );
		return false;
	}
}

storyscene function PlayAnimationEvent(player: CStoryScenePlayer, entityTag : name, eventName: name, forceEvent: bool ) : bool
{
	var entity : CEntity;

	entity = theGame.GetEntityByTag( entityTag );

	if( forceEvent == true )
	{
		entity.RaiseForceEvent( eventName );
	}
	else
	{
		entity.RaiseEvent( eventName );
	}
	return true;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TUTORIAL STUFF

storyscene function TutorialToggleHighlightInScene( player: CStoryScenePlayer, entityTag : name, isHighlighted : bool ) : bool
{
	var entity : CEntity;
	
	entity = theGame.GetEntityByTag( entityTag );
	
	if( isHighlighted )
	{
		entity.PlayEffect( 'toturial_glow' );
	}	 
	else
	{
		entity.StopEffect( 'toturial_glow' );
	}
}
