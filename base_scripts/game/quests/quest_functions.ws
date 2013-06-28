enum EDragonA3CombatPhase
{
	DCP_Windows,
	DCP_FirstFloor,
	DCP_TowerTop,
	DCP_NoDragon,
	DCP_DragonFlying
};
enum EArrowSoundType
{
	AST_NoSound,
	AST_EverySingleArrow,
	AST_GroupOfArrows
}

enum ELangVersion
{
	LV_PL,
	LV_DE,
	LV_FR,
	LV_EN
};

enum ETutorialInputBlocker
{
	TIB_Camera_Movement,
	TIB_Movement_Walk,
	TIB_Movement_WalkSwitch,
	TIB_Movement_ToggleWalkRun,
	TIB_Equip_HolsterWeapon,
	TIB_Equip_Steel,
	TIB_Equip_Silver,
	TIB_Equip_NextSign,
	TIB_Equip_NextItem,
	TIB_Equip_Aard,
	TIB_Equip_Yrden,
	TIB_Equip_Igni,
	TIB_Equip_Quen,
	TIB_Equip_Axii,
	TIB_Use_FastMenu,
	TIB_Use_Medallion,	
	TIB_Combat_LockTarget,
	TIB_Combat_AttackFast,
	TIB_Combat_AttackStrong,
	TIB_Combat_BlockAttack,
	TIB_Combat_EvadeAttack,
	TIB_Combat_UseSelectedSign,
	TIB_Combat_UseSelectedItem,
	TIB_Combat_AdrenalineAttack,
	TIB_Panel_Inventory,
	TIB_Panel_Character,
	TIB_Panel_Map,
	TIB_Panel_Journal,
	TIB_Panel_DeleteInventoryItem,
	TIB_Special_QuestInteraction,	
	TIB_Special_QuickSave,
	TIB_Special_HideGUI
};

enum ETutorialBlockInventoryInput
{
	TBII_AllButtons,
	TBII_Filter_Weapons,
	TBII_Filter_Ranged,
	TBII_Filter_Armors,
	TBII_Filter_Enchancements,
	TBII_Filter_Potions,
	TBII_Filter_Traps,
	TBII_Filter_Bombs,
	TBII_Filter_Books,
	TBII_Filter_Trophies,
	TBII_Filter_Mutagens,
	TBII_Filter_Alchemy,
	TBII_Filter_Crafting,
	TBII_Filter_Diagrams,
	TBII_Filter_Lures,
	TBII_Filter_QuestItems,
	TBII_Filter_Junk,	
	TBII_Filter_AllItems,
	TBII_Slot_SteelSword,
	TBII_Slot_Armor,
	TBII_Slot_Boots,
	TBII_Slot_Gauntlets,
	TBII_Slot_SilverSword,
	TBII_Slot_Trophy,
	TBII_Slot_Trousers,
	TBII_Slot_ThrowItemAway,
	TBII_Button_Exit
};

latent quest function Q105_TeleportPlayerToBossFight(nodeTag : name)
{
	var node : CNode;
	node = theGame.GetNodeByTag(nodeTag);
	
	if(node)
	{
		thePlayer.TeleportWithRotation(node.GetWorldPosition(), node.GetWorldRotation());
		theCamera.ResetRotation(false, true, true, 0.0f);
	}
	//Sleep(0.1);
	//theGame.FadeInAsync(1.0);
}
quest function QClearAllPlayerBuffs()
{
	thePlayer.RemoveAllBuffs();
}

quest function QClearAllPlayerEffects()
{
	thePlayer.RemoveAllBuffs();
	thePlayer.RemoveCriticalEffects();
}

quest function QEnableTrigger ( shouldBeEnabled : bool, objectTag : name) : bool
{
	var entity    : array <CNode>;
	var component : array <CComponent>;
	var count, i, j, count2 : int;
	var single_entity : CEntity;
	var single_component : CTriggerAreaComponent;
	
	

	theGame.GetNodesByTag( objectTag, entity);
	count = entity.Size();
	
	for ( i = 0; i < count; i += 1 )
	{
		single_entity = (CEntity) entity[i];
		if ( ! single_entity )
			continue;
		component = single_entity.GetComponentsByClassName('CTriggerAreaComponent');
		count2 = component.Size();
		for(j = 0; j < count2; j+=1)
		{
			single_component = (CTriggerAreaComponent)component[j];
			if ( ! single_component )
				continue;
			single_component.SetEnabled( shouldBeEnabled );
		}
		
	}
	
	return true;
}

quest function QStartsFightWithTaunt(npcsTag : name)
{
	var npc : CNewNPC;
	var nodes : array<CNode>;
	var i, size : int;
	
	theGame.GetNodesByTag(npcsTag, nodes);
	size = nodes.Size();
	for(i = 0; i < size; i += 1)
	{
		npc = (CNewNPC)nodes[i];
		if(npc)
		{
			npc.StartsWithCombatIdle(true);
		}
	}
}

quest function QSetBossFight( isFightingWithBigBoss : bool )
{
	thePlayer.SetBigBossFight( isFightingWithBigBoss );
}

//Metoda kaze NPCom o podanym tagu zauwazyc innych NPC (w tym PLAYERa).
quest function QNoticeActor(NPCsTag : name, targetsTAG : name)
{
	var npcs : array<CNewNPC>;
	var actors : array<CActor>;
	var i, j, size, size2 : int;
	theGame.GetActorsByTag(targetsTAG, actors);
	theGame.GetNPCsByTag(NPCsTag, npcs);
	
	
	size = npcs.Size();
	size2 = actors.Size();
	for (i = 0; i < size; i += 1)
	{
		for(j = 0; j < size2; j += 1)
		{
			npcs[i].NoticeActor(actors[j]);
		}
	}
	
}
//Metoda dajaca graczowi ABL o podanej nazwie
quest function QAddAbilityToPlayer(abilityName : name)
{
	if(!thePlayer.GetCharacterStats().HasAbility(abilityName))
	{
		thePlayer.GetCharacterStats().AddAbility(abilityName);
	}
}
quest function QAddStoryAbilityToPlayer(abilityName : string)
{
	if(!thePlayer.GetCharacterStats().HasAbility( StringToName( abilityName + "_1") ) )
	{
		AddStoryAbility( abilityName, 1 );
	}
}
//Metoda usuwa wszystkie ability danej postaci, ustawiajac jedna, jedyna ability, podana jako parametr
quest function QSetOneAbilityForNPC(npcTag : name, abilityName : name)
{
	var actor : CActor;
	var i, size : int;
	var abilities : array<name>;
	var vitality : float;
	actor = theGame.GetActorByTag(npcTag);
	if(actor)
	{
		actor.GetCharacterStats().GetAbilities(abilities);
		size = abilities.Size();
		for (i = 0; i < size; i += 1)
		{
			actor.GetCharacterStats().RemoveAbility(abilities[i]);
		}
		actor.GetCharacterStats().AddAbility(abilityName);
				
		vitality = actor.GetCharacterStats().GetFinalAttribute('vitality');
		if(actor.GetCharacterStats().HasAbility('OppE_Wounded'))
		{
			actor.GetCharacterStats().RemoveAbility('OppE_Wounded');
		}
		actor.SetInitialHealth(vitality);
		actor.SetHealth(vitality, true, NULL);
		if(!actor.GetCharacterStats().HasAbility(abilityName))
			Log("QSetOneAbilityForNPC ERROR - bledna nazwa ability (nie zdefiniowana w XML): " + abilityName);
	}
	else
	{
		Log("QSetOneAbilityForNPC ERROR - brak npc o podanym tagu: > " + npcTag + " < na planszy");
	}
}

//Metoda sluzy do wymuszania danemu NPC ataku na dany cel (obsluguje 1 npc i 1 cel). 
//Moga wystapic problemy, jesli wywolamy ja kilka razy na wielu obiektach, poniewaz zapisuje ona nastawienia npc wzgledem innych npc
//npcTag - tag NPC ktory bedzie hostile do celu, ktoremu wymuszamy atakowanie
//targetPlayer - jest jest "true" to pomijamy szukanie celu, wiedzac, ze to gracz
//targetTag - jesli targetPlayer jest "false" szukamy celu po tagu (jednego celu) 
//optionalBattleRange - opcjonalnie mozemy podac zasieg bitwy (zasieg z jakiego npc zbierze wszystkich actorow by zapisac ich nastawienie)
//optionalForceHostileTime - opcjonalnie mozemy podac czas przez jaki npc bedzie atakowal tylko dany cel


quest function QCombatForceAttackPlayer(npcTag : name, time : float )
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag(npcTag);
	if(npc)
	{
		npc.ForceTargetPlayer(time);
	}
}
quest function QCombatForceAttackPlayerCancel(npcTag : name)
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag(npcTag);
	if(npc)
	{
		npc.StopTargetPlayer();
	}
}

quest function QShootDraugRock(template : CEntityTemplate, startPointTag : name, targetPointTag : name)
{
	var startNode, targetNode : CNode;
	var draugRock : CDraugCaveRock;
	var startPos, targetPos : Vector;
	startNode = theGame.GetNodeByTag(startPointTag);
	targetNode = theGame.GetNodeByTag(targetPointTag);
	targetPos = targetNode.GetWorldPosition();
	startPos = startNode.GetWorldPosition();
	draugRock = (CDraugCaveRock)theGame.CreateEntity(template, startPos, startNode.GetWorldRotation());
	if(draugRock)
		draugRock.StartRock(targetPos, false);
}
//skrypt odpalajacy dla aktora chodzenie po sciezce z followerem i czekanie na gracza zaleznie od dystansu
latent quest function WalkAlongThePathWaitForPlayerInQuest( targetPathTag : name, targetEndofPathTag : name, targetActorTag : name, optional actorFollowerTag : array<name>, 
distanceToStop : float, distanceToGo : float, distanceToChangeSpeed : float, upThePath : bool, optional moveTypename : EMoveType, optional absSpeed : float, optional interceptSectionName : string ) : bool
{
	var target 					: CEntity;
	var path   					: CPathComponent;
	var actor  					: CNewNPC;
	var follower  				: CNewNPC;
	var endofpath 				: CEntity;
	var distanceToEnd 			: float;
	var i 						: int;

	
	endofpath = (CEntity)theGame.GetNodeByTag( targetEndofPathTag );
	target = (CEntity)theGame.GetNodeByTag( targetPathTag );
	actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );
	while ( !actor )
	{
		actor  = (CNewNPC)theGame.GetActorByTag( targetActorTag );	
		Sleep (0.5f);
	}
	
	path = target.GetPathComponent();
	if ( !path )
	{
		Log("WalkAlongThePathWaitForPlayerInQuest: No path found");
		return false;
	}
	
	actor.GetArbitrator().ClearGoal();
	actor.GetArbitrator().AddGoalWalkAlongPathWaitForPlayer( path, upThePath, false, distanceToStop, distanceToGo, distanceToChangeSpeed, moveTypename, absSpeed );

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
		if ( distanceToEnd < 1.0f )
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

latent quest function Q_FPP_Combat() : bool
{
	if(false) //usuniecie kamery FPP
	{
		while(FactsQuerySum("FPP_Combat") == 1)
		{
			theCamera.SetCameraState(CS_FPP);
			Sleep(1.0);
		}
	}
	else
	{
		return true;
	}
}
//skrypt odpalajacy dla aktora chodzenie po sciezce z followerem i czekanie na gracza zaleznie od dystansu
latent quest function WalkToTargetWaitForPlayerInQuest( targetTag : name, targetActorTag : name, 
	distanceToStop : float, distanceToGo : float, moveTypename : EMoveType, absSpeed : float ) : bool
{
	var target : CEntity;
	var actor  : CNewNPC;
	var targetArea : Sphere;
	var targetPos : Vector;
	var targetAreaIntersectPoints : int;
	var prevActorPos : Vector;
	var currActorPos : Vector;
	var distTraveled, distanceToEnd : float;
	var intersectionPoint0 : Vector;
	var intersectionPoint1 : Vector;
	
	
	// look up the actual entities corresponding to the actor and target
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
		return false;
	}
	
	// calculate the area around the target point
	targetArea.CenterRadius2 = target.GetWorldPosition(); // target area position
	targetPos = target.GetWorldPosition();
	targetArea.CenterRadius2.W = distanceToStop + 1.0; // target area radius
	
	// aquire the actor's position
	currActorPos = actor.GetWorldPosition();
	prevActorPos = currActorPos;
	
	// wait until the actor walks into the area
	while ( true ) 
	{
		prevActorPos = currActorPos;
		currActorPos = actor.GetWorldPosition();
	
		distTraveled = VecDistance( currActorPos, prevActorPos );
		if ( distTraveled > 0.001 )
		{
			// raytrace the distance the player has crossed and check
			// if it intersects the target area
			targetAreaIntersectPoints = SphereIntersectEdge( targetArea, prevActorPos, currActorPos, intersectionPoint0, intersectionPoint1 );
		}
		else
		{
			// we're not moving - check if the destination has been reached
			distanceToEnd = VecDistance( currActorPos, targetPos );
			if ( distanceToEnd <= targetArea.CenterRadius2.W )
			{
				targetAreaIntersectPoints = 1;
			}
		}

		if ( targetAreaIntersectPoints > 0 )
		{
			// yes - the player's reached the area
			break;
		}
		else
		{
			// keep on waiting - the player's not there yet
			Sleep( 1.f );
		}
	}
	
	return true;	
}

quest function SetMaxMoveSpeedTypeQuest( moveType : EMoveType, formationFollowerTags : array<name> ) : bool
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

latent quest function QuestCheckDeadCount( tag : name, deadCount : int ) : bool
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

latent quest function QuestCheckUnconciousCount( tag : name, unconciousCount : int ) : bool
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

quest function QuestCheckIfIsAlive( tag: name ) : bool 
{
	var targetActor : CActor;

	targetActor = theGame.GetActorByTag( tag );
	return targetActor.IsAlive();
}

//funkcja sprawdzaj¹ca godzinê

quest function QuestCheckTime( from_hour: int, to_hour: int ) : bool 
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

quest function QSetPlayerWalkMode ( IsWalking: bool ) : bool
{	
	thePlayer.ChangePlayerState( PS_Exploration );
	thePlayer.SetWalkMode( IsWalking );
	thePlayer.SetAllPlayerStatesBlocked( IsWalking );
	return true;
}

//Funkcja blokujaca mozliwosc wyciagania miecza
quest function QBlockPlayerSword ( BlockSword: bool ) : bool
{	
	thePlayer.ChangePlayerState( PS_Exploration );
	thePlayer.SetAllPlayerStatesBlocked( BlockSword );
	return true;
}

//SL: Funkcja blokujaca rozne rzeczy na czas chujowego lasu
quest function Q213BlockAllInDickForrest( BlockAll : bool )
{	
	// block meditation
	thePlayer.EnableMeditation( !BlockAll );
	
	LogChannel( 'GUI', "Q213BlockAllInDickForrest: " + BlockAll );
}

//SL: Funkcja blokujaca mozliwosc uzywania FastMenu
quest function QBlockFastMenu ( BlockFastMenu: bool )
{	
	thePlayer.SetCanUseHud(!BlockFastMenu);
	thePlayer.SetCombatHotKeysBlocked( !BlockFastMenu );
	LogChannel( 'GUI', "QBlockFastMenu: " + BlockFastMenu );
}

//Funkcja sprawdzaj¹ca czy gracz jest w combat mode

quest function QCheckCombatMode () : bool
{
	if(thePlayer.IsInCombat() == true)
	{
		return true;
	}
	
	return false;	
}


//KR: funkcja wylaczajaca rysowanie meshy

quest function QSetComponentVisible ( shouldBeVisible : bool, objectTag : name, componentName : string) : bool
{
	var entity    : array <CNode>;
	var component : array <CNode>;
	var count, i : int;
	var single_entity : CEntity;
	var single_component : CDrawableComponent;
	

	theGame.GetNodesByTag( objectTag, entity);
	count = entity.Size();
	
	for ( i = 0; i < count; i += 1 )
	{
		single_entity = (CEntity) entity[i];
		if ( ! single_entity )
			continue;
		
		single_component = (CDrawableComponent) single_entity.GetComponent( componentName );
		if ( ! single_component )
			continue;
		
		single_component.SetVisible( shouldBeVisible );
	}
	
	return true;
}



//SL: Funkcja czekajaca az gracz opusci combat mode

latent quest function QWaitUntilPlayerLeavesCombatMode () : bool
{
	while(thePlayer.IsInCombat() == true)
	{
		Sleep( 2.0f );
	}
	
	return true;
}

//SL: Funkcja zabija wszystkie postacie o zadanym TAGu
quest function QKillAllNPCWithTag( targetTag : name ) : bool
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

//KR: Funkcja wykonuje destruct na npcach o danym tagu // funkcja uzywana TYLKO do niszczenia zafreezowanych NPCow na behaviourze.
quest function QDestroyAllNPCWithTag( targetTag : name ) : bool
{
	
	var actors : array <CActor>;
	var i      : int;
	var actor : CActor;
	
	theGame.GetActorsByTag(targetTag, actors);
	
	for (i = 0; i < actors.Size(); i += 1 )
	{	
		actor = actors[i];
		
		actor.ClearImmortality();
		actor.Destroy();
	}
	
	
	return true;
}




//funkcja w³¹czaj¹ca i wy³¹czaj¹ca eksploracjê

quest function QEnableComponent ( shouldBeEnabled : bool, objectTag : name, componentName : string) : bool
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
latent quest function QNPCStartsCarryingNPC( carrierTag, carriedTag, masterBehaviorName, slaveBehaviorName, DestinationTag : name,
											latentAction : IActorLatentAction ) : bool
{
	InteractionNpcMaster( carrierTag, carriedTag, masterBehaviorName, slaveBehaviorName, DestinationTag, latentAction );
}

latent quest function QInteractionNpcMaster( masterTag, slavesTag, masterBehaviorName, slaveBehaviorName, nodeOfInterestTag : name,
											latentAction : IActorLatentAction ) : bool
{
	InteractionNpcMaster( masterTag, slavesTag, masterBehaviorName, slaveBehaviorName, nodeOfInterestTag, latentAction );
}

latent function InteractionNpcMaster( masterTag, slavesTag, masterBehaviorName, slaveBehaviorName, nodeOfInterestTag : name,
												 latentAction : IActorLatentAction ) : bool
{
	var master			: CNewNPC;
	var slave			: CActor;
	var slaves			: array<CActor>;
	var nodeOfInterest	: CNode;	
	
	//theGame.GetActorsByTag( slavesTag, slaves );
	slave = theGame.GetActorByTagWithTimeout( slavesTag, 1000.0f );
	if( !slave )
	{
		Logf( "InteractionNpcMaster no slave with tag %1", slavesTag );
		return false;
	}
	
	slaves.PushBack( slave );
	
	if( nodeOfInterestTag )
	{
		nodeOfInterest = theGame.GetNodeByTagWithTimeout( nodeOfInterestTag, 10.f );
		if ( ! nodeOfInterest ) 
			return false;
	}
	
	master = theGame.GetNPCByTagWithTimeout( masterTag, 1000.f );
	if ( ! master )
		return false;
		
	if( nodeOfInterest && !nodeOfInterest.IsA( 'CEntity' ) )
	{
		master.SetErrorStatef( "InteractionNpcMaster nodeOfInterest '%1', is not CEntity", nodeOfInterestTag );
	}
	
	master.GetArbitrator().ClearAllGoals();	
	master.GetArbitrator().AddGoalInteractionMaster( slaves, masterBehaviorName, slaveBehaviorName, latentAction, (CEntity)nodeOfInterest );
	return true;
}

//Funkcja ka¿¹ca postaci iœæ do punktu, funkcja oczekuje na to a¿ NPc dojdzie do punktu

latent quest function QMoveToObjectUntilReached( DestinationTag : name, ActorTag: name, moveType : EMoveType, speed : float ) : bool
{
	var Actor					: CNewNPC;
	var Destination				: CNode;
	var distToTarget 			: float;
	var targetPos, actorPos		: Vector;

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

latent quest function QDelay( Duration : float ) : bool
{
	Sleep ( Duration );
	return true;
}

//PW: F-kcja ka¿¹ca postaci iœæ do punktu, funkcja nie oczekuje na to a¿ NPc dojdzie do punktu

latent quest function QMoveToObject( DestinationTag : name, ActorTag: name, moveType : EMoveType, speed : float, exitWorkMode : EExitWorkMode  ) : bool
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
	Actor.GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, 0.5f, exitWorkMode );
		
	return true; 
}

//Funkcja wy³aczaj¹ca wandering
//obsolete
latent quest function QTurnOffWandering ( ActorTag: name, Wandering: bool) : bool
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
quest function QSetAttitude ( actorTag: name, attitude : EAIAttitude, dontNotice : bool ) : bool
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
	}
	
	if( !dontNotice )
	{
		for ( i = 0; i < count; i += 1 )
		{
			actors[i].NoticeActor( player_in_scene );
		}
	}
	
	return true;
}

quest function QCalmDown ( actorTag: name, dontNotice : bool ) : bool
{
	var actors: array <CNewNPC>;
	var npc : CNewNPC;
	
	theGame.GetNPCsByTag( actorTag, actors );
	npc.CalmDown();
	
	return true;
}

//Ustawianie Affiliation
quest function QSetGlobalAffiliation( groupNameA : name, groupNameB : name, affiliation : EAIAffiliation )
{
	theGame.SetGlobalAffiliation( groupNameA, groupNameB, affiliation );
}

//PW: ustawia Attitude NPCa do Target
quest function QSetNPCAttitudeToTarget( npcTag : name, targetTag: name, attitude : EAIAttitude, dontNotice : bool) : bool
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
			
			//SL update, powoduje, ze postac nie jest od razu infromowana
			if( !dontNotice )
			{
				npc.NoticeActor( targets[i] );
			}
			
		}
	}
	return true;
}

// umozliwia wylaczenie przeliczania statsow geralta w czasie - np. wylaczyc auto regen zywotnosci
quest function QSetDontRecalcStats( WylaczRegeneracje : bool ) : bool
	
	{
		thePlayer.SetDontRecalcStats(WylaczRegeneracje);
		return true;
	}



//ekwipowanie itemu npcowi lub playerowi
latent quest function QEquipItemOnNPC ( npc: name, item_name : name) : bool
{
	var item_id : SItemUniqueId;
	var npc_newnpc : CNewNPC;

	if( npc == 'PLAYER' ) {
		item_id = thePlayer.GetInventory().GetItemId(item_name);
		thePlayer.GetInventory().MountItem(item_id, false);
	}
	else {
		npc_newnpc = theGame.GetNPCByTag(npc);
		item_id = npc_newnpc.GetInventory().GetItemId(item_name);
		npc_newnpc.GetInventory().MountItem(item_id, false);
	}
	return true;
}

//ekwipowanie itemu npcowi lub Playerowi
latent quest function QAddItemOnNPC ( npc: name, item_name : name) : bool
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

//usuwanie przedmiotu z NPCa lub playera
quest function QRemoveItemFromNPC( npc : name, item_name : name) : bool
{
	var npc_newnpc : CNewNPC;
	var item_id : SItemUniqueId;
	
	if( npc == 'PLAYER' ) {
		item_id = thePlayer.GetInventory().GetItemId(item_name);
		thePlayer.GetInventory().RemoveItem(item_id);
	}
	else	
	{	
		npc_newnpc = theGame.GetNPCByTag(npc);
		item_id = npc_newnpc.GetInventory().GetItemId(item_name);
		npc_newnpc.GetInventory().RemoveItem(item_id);
	}
	return true;	
}

//usuwanie przedmiotu ze skrzyni lub innego Entity
quest function QRemoveItemFromEntity( entityTag : name, item_name : name) : bool
{
	var entity_new : CContainer;
	var item_id : SItemUniqueId;

	entity_new = (CContainer)theGame.GetEntityByTag(entityTag);
	item_id = entity_new.GetInventory().GetItemId(item_name);
	entity_new.GetInventory().RemoveItem(item_id);

	return true;	
}

// dodawanie przedmipotu do skrzyni lub innego entity

quest function QGiveItemToEntity( entityTag : name, item_name : name) : bool
{
	var entity_new : CContainer;
	var item_id : SItemUniqueId;
	var inv 	   : CInventoryComponent;
	
	inv = entity_new.GetInventory();
	entity_new = (CContainer)theGame.GetEntityByTag(entityTag);
	item_id = entity_new.GetInventory().GetItemId(item_name);
	entity_new.GetInventory().GiveItem(inv, item_id);

	return true;	
}


//sprawdzenie czy obiekt dostal aardem (przestarzale, uzywac CQuestFightCondition)
latent quest function QCheckIfAardHit ( ObjectTag : name ) : bool
{
	var fact : string = "object_" + ObjectTag + "_was_hit_by_ard" ;
	
	while( FactsQuerySum( fact ) == 0 )
	{
		Sleep (0.05f);
	}
	
	return true;
}

//sprawdzenie czy obiekt dostal igni(przestarzale, uzywac CQuestFightCondition)
latent quest function QCheckIfIgniHit ( ObjectTag : name ) : bool
{
	var fact : string = "object_" + ObjectTag + "_was_hit_by_Igni" ;

	while( FactsQuerySum( fact ) == 0 )
	{
		Sleep (0.05f);
	}
	
	return true;
}

//set idle state for anpc
latent quest function QSetNPCIdleState ( actorTag : array<name> ) : bool
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
quest function QPlayEffect ( entityTag : name, effectName : name, activate : bool, sfx : bool, persistentEffect : bool ) : bool
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
				if ( persistentEffect )
				{
					entity.SetAutoEffect( effectName );
				}
				else
				{
					entity.PlayEffect( effectName );
				}
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
				if ( persistentEffect )
				{
					entity.SetAutoEffect( 'None' );
				}
				else
				{
					entity.StopEffect(effectName);
				}
			}
		}
	}
	
	return true;
}

quest function QPlayEffectWithTarget ( entityTag : name, effectName : name, activate : bool, targetTag: name) : bool
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
				entity.PlayEffect(effectName, theGame.GetNodeByTag(targetTag));
		}
		else if (activate == false)
		{
				entity.StopEffect(effectName);
		}
	}
	
	return true;
}


//MT: Custom function for Axii
quest function QPlayEffectWithTargetComponent ( entityTag : name, effectName : name, activate : bool, targetTag: name, componentName: string) : bool
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
				entity.PlayEffect(effectName, theGame.GetEntityByTag(targetTag).GetComponent(componentName));
		}
		else if (activate == false)
		{
				entity.StopEffect(effectName);
		}
	}
	
	return true;
}

//PW: f-kcja teleportacji aktora wedle pozycji i rotacji node'a
quest function QTeleportActorWithRotation ( actorTag : name, targetDestinationTag : name) : bool
{
	var actor : CActor;
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
	

	if( !actor.TeleportToNode( node, true ) )
	{
		Log (" Teleport failed! TeleportToNode returned false" );
	}
	
	return true;
}

//Spawns tentadrake and starts boss fight
latent quest function Qq105_StartBossFight ( Tentadrake : CEntityTemplate ): bool
{
	var lookatTarget			 : Vector;
	var zgn 					 : Zagnica;
	var magicBarrier			 : CForceField;
	var sheala					 : CEntity;
	var zgnWP 					 : CNode;
	
	theGame.GetWorld().ShowLayerGroup( "boss_arena\scripts\zgn_fight" );
	
	zgnWP = theGame.GetNodeByTag('zgn_spawnpoint');
	if ( !zgnWP )
	{
		Log("ZAGNICA ZAGNICA ZAGNICA ZAGNICA ZAGNICA ZAGNICA ZAGNICA ZAGNICA");
		Log(" Zgn WP ");
	}
	zgn = (Zagnica) theGame.CreateEntity( Tentadrake, zgnWP.GetWorldPosition(), zgnWP.GetWorldRotation(), true, false, true );
	while( !theGame.zagnica )
	{
		Sleep(0.001);
		Log("Qq105_StartBossFight waiting for zagnica to spawn");
	}
	
	magicBarrier = (CForceField) theGame.GetNodeByTag( 'electric_obstacle' );
	//theCamera.RaiseEvent( 'Camera_Zagnica' );
	
	sheala = theGame.GetEntityByTag( 'sheala' );	

	zgn.StartPhase1();
	thePlayer.EnablePhysicalMovement( true );
	magicBarrier.PlayEffect( 'electric' );
	magicBarrier.SetActive( true );
	
	Log( "Fight with Zagnica started" );
	
	return true;
}

// Funkcja dodaj¹ca wpis do bazy faktów

quest function QAddFact ( Fact_ID : name, Fact_Value : int, Valid_for : int, time : int) : bool
{
	if ( time > 0 )
	{
		FactsAdd( Fact_ID, Fact_Value, Valid_for, time);
	}
	else
	{
		FactsAdd( Fact_ID, Fact_Value, Valid_for );
	}
	return true;
}

//Funckja sprawdzaj¹ca wpis w bazie faktów

quest function QCheck_if_Fact_exist ( Fact_ID : name, Fact_Value : int) : bool
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
quest function QGetWeaponFromPlayer ( containerTag : name, remove : bool) : bool
{
	var i 	       		: int;
	var container  		: CGameplayEntity;
	var source_inv 		: CInventoryComponent;
	var dest_inv		: CInventoryComponent;
	var allItems   		: array< SItemUniqueId >;
	var categoriesToMove : array< name >;
	var itemId	   		: SItemUniqueId;
	var skip       		: bool;
	var itemCategory 	: name;
	var itemQuantity	: int;
	
	container = (CGameplayEntity) theGame.GetNodeByTag(containerTag);
	
	if ( remove )
	{
		dest_inv = container.GetInventory();
		source_inv = thePlayer.GetInventory();
	}
	else
	{
		source_inv = container.GetInventory();
		dest_inv = thePlayer.GetInventory();
	}
	
	if ( !source_inv )
	{
		Log( "QGetWeaponFromPlayer: Failed to find source inventory ( tag: " + containerTag + " )" );
		return false;
	}
	if ( !dest_inv )
	{
		Log( "QGetWeaponFromPlayer: Failed to find destination inventory ( tag " + containerTag + " )" );
		return false;
	}
	
	source_inv.GetAllItems( allItems );
	
	// Create a list of categories that should be moved to container
	categoriesToMove.PushBack( 'steelsword' );
	categoriesToMove.PushBack( 'silversword' );
	categoriesToMove.PushBack( 'trap' );
	categoriesToMove.PushBack( 'petard' );
	categoriesToMove.PushBack( 'rangedweapon' );
	// -- Luke TODO
	
	for ( i = 0; i<allItems.Size(); i+=1 )
	{
		itemCategory = source_inv.GetItemCategory( allItems[i] );
		if ( categoriesToMove.Contains( itemCategory ) )
		{
			itemQuantity = source_inv.GetItemQuantity( allItems[i] );
			source_inv.GiveItem( dest_inv, allItems[i], itemQuantity );	
		}
	}

	return true;
}

//function that allows to change door state

quest function QSetDoorState (doorTag: name, door_state : EDoorState, immediate : bool ) : bool
{
	var request : CDoorStateRequest;
	
	request = new CDoorStateRequest in theGame;
	request.doorState = door_state;
	request.immediate = immediate;
	theGame.AddStateChangeRequest( doorTag, request );

	return true;
}

//funkcja blokujaca wybrany state playerowi
quest function QBlockPlayerState ( isBlocked : bool, stateType : EPlayerState ) : bool
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
quest function QUnBlockAllPlayerState() : bool
{
	thePlayer.UnblockAllPlayerStates();
}

//PW: f-kcja obs³uguj¹ca scenê pogoni za celem
quest function QSetSceneChaseSequence ( ChasersTag : array<name>, VictimTag : name, timeout : float ) : bool
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

quest function QBlockMeditaction ( isBlocked : bool ) : bool
{
	thePlayer.EnableMeditation( ! isBlocked );
	return true;
}

quest function QSetPhysicalMovementOnPlayer ( enabled : bool ) : bool
{
	var Player : CPlayer;
	
	Player = thePlayer;
	Player.EnablePhysicalMovement( enabled );
	
	return true;
}

// funkcja do wlaczania sklepu z linii dialogowej

quest function QShowMeGoods( merchantTag : CName ) : bool
{
	//Shop( theGame.GetNPCByTag( merchantTag ) );
	RemoveDarkDiffItemsIfNotDarkDiff( theGame.GetNPCByTag( merchantTag ) );
	theHud.ShowShopNew( theGame.GetNPCByTag( merchantTag ) );
}

//PW: Move To dla >1 aktora
latent quest function QMoveToObjectMultipleActors ( DestinationTag : name, ActorsTag: array<name>, moveType : EMoveType, speed : float, radius : float, exitWorkMode : EExitWorkMode ) : bool
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
		Actors[i].GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, radius, exitWorkMode );
	}
	
	return true; 
}

// Funkcja wy³¹czaj¹ca/wlaczajaca Sneak Mode
quest function QSneakModeOff ( sneakMode : bool ) : bool
{
	var geralt : CPlayer;
	
	
	geralt = thePlayer;
	
	geralt.SetSneakMode( sneakMode );
	geralt.ChangePlayerState( PS_Exploration );
	
	return true;
}

// Funkcja za³¹czaj¹ca dany stan obiektowi fizycznemu - niszczenie

//PW: f-kcja do odpalania eventu animacji z behaviora na NPCu
quest function QSceneRaiseAnimationEvent ( actorTag : name, behaviorGraphName : name, eventName : name, force : bool) : bool
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
quest function QEnableTalkComponent ( shouldBeEnabled : bool, actorTag : name ) : bool
{
	var object	: CActor;
	var component : CComponent;
	
	object = theGame.GetActorByTag( actorTag );
	component = object.GetComponent ( "talk" );
	component.SetEnabled( shouldBeEnabled );

	return true;
}

// Zalozenie mappinu na obiekt
quest function QSetMappin( ObjectTag: name, MappinName : name, mapDescription : string, minimapDisplay : bool, enabled : bool, type : EMapPinType, remove : bool) : bool
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
quest function QShowHideLayer ( layerTag: name, show : bool ) : bool
{
	// DEPRECATED, use ShowLayerGroup() instead
	//theGame.GetWorld().ShowLayers( layerTag, show );
	
	return true;
}

//PW: f-kcja do ustawiania POIT
latent quest function QGatherActorsSetPOIT ( DestinationTag : name, ActorsTag: array<name>, actorSearchRange : float, poit : EPointOfInterestType, radius, timeout : float, observePOIT : bool ) : bool
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
latent quest function QBlackscreenWithFadeIn ( fadeOut : bool, fadeIn : bool, duration : float) : bool
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
latent quest function QCSplayText ( txt1 : string, txt2 : string, duration : float) : bool
{
	var str1 : string;
	var str2 : string;
	if ( txt1 != "" ) str1 = GetLocStringByKeyExt( txt1 );
	if ( txt2 != "" ) str2 = GetLocStringByKeyExt( txt2 );
	theHud.m_hud.setCSText( str1 , str2 );
	thePlayer.AddTimer( 'clearHudTextField', duration, false );	
	
	return true;
}

// Funkcja czyszczaca napis w cutscenie
latent quest function QCSclearText () : bool
{
	//theHud.m_messages.HideCutsceneText();
	thePlayer.AddTimer( 'clearHudTextField', 0.1f, false );	
	return true;
}

//PW: f-kcja do zbierania aktorów i ustawiania ich na leadera z POIT. Nie wa¿ne, nie patrz na to.
latent quest function QGatherActorsMoveWithLead ( destinationTag : name, actorsTag: array<name>, leaderTag: name, actorSearchRange : float, poit : EPointOfInterestType, radius, leadTimeout : float, actorsTimeout : float, observePOIT : bool ) : bool
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

latent quest function QQ102_GALLOW ( allStand : bool, firstHang : bool, secondHang : bool, afterHanging : bool, showRope : bool ) : bool
{
	var jaskier : CEntity;
	var zoltan : CEntity;
	var woman_hanger : CEntity;
	var man_hanger : CEntity;
	var gallow : CEntity;
	var executioner : CEntity;	
	
	var elfHanger : CAnimatedComponent;
	var womanElfHanger : CAnimatedComponent;
	var jaskier_component: CAnimatedComponent;
	var zoltan_component: CAnimatedComponent;
	
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
	
	var isOk : bool;
	
	isOk = true;

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
	woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
	man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );  
	elfHanger = (CAnimatedComponent) man_hanger.GetRootAnimatedComponent();
	womanElfHanger = (CAnimatedComponent) woman_hanger.GetRootAnimatedComponent();
	jaskier_component = (CAnimatedComponent)jaskier.GetRootAnimatedComponent();
	zoltan_component = (CAnimatedComponent)zoltan.GetRootAnimatedComponent();
	
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
			woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
			man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );
  
			elfHanger = (CAnimatedComponent) man_hanger.GetRootAnimatedComponent();
			womanElfHanger = (CAnimatedComponent) woman_hanger.GetRootAnimatedComponent();
			jaskier_component = (CAnimatedComponent)jaskier.GetRootAnimatedComponent();
			zoltan_component = (CAnimatedComponent)zoltan.GetRootAnimatedComponent();		
			Sleep ( 0.01f );
		}
		
	
		jaskier.TeleportWithRotation( vectorJaskier, rotationJaskier);
		zoltan.TeleportWithRotation( vectorZoltan, rotationZoltan);
		gallow.TeleportWithRotation( vectorGallow, rotationGallow);
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorElfHanger, rotationElfHanger);
		theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( vectorWomanElfHanger, rotationWomanElfHanger);
		
		theGame.GetActorByTag('q102_hanger02').EnablePathEngineAgent( false );
		theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
		((CNewNPC)zoltan).EnablePathEngineAgent( false );
		((CNewNPC)jaskier).EnablePathEngineAgent( false );
		
		Sleep(0.01f);
		
		ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
		ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
		ropeElfHanger.RaiseBehaviorForceEvent('hanging_off');
		ropeWomanElfHanger.RaiseBehaviorForceEvent('hanging_off');

		jaskier.RaiseForceEvent('hanging_jaskier_off');
		zoltan.RaiseForceEvent('hanging_off');
		woman_hanger.RaiseForceEvent('woman_hanger');
		man_hanger.RaiseForceEvent('man_elf_hanger');
		
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

		theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
		
		gallow.TeleportWithRotation( vectorGallow, rotationGallow);
		jaskier.TeleportWithRotation( vectorJaskier, rotationJaskier);
		zoltan.TeleportWithRotation( vectorZoltan, rotationZoltan);
		
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorElfHanger, rotationElfHanger);
				
		jaskier.RaiseForceEvent('hanging_jaskier_off');
		zoltan.RaiseForceEvent('hanging_off');
		man_hanger.RaiseForceEvent('man_elf_hanger');
		
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
		((CNewNPC)zoltan).EnablePathEngineAgent( true );
		((CNewNPC)jaskier).EnablePathEngineAgent( true );
		
		theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( vectorWPhanger1, rotationWPhanger1);
		theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( vectorWPhanger2, rotationWPhanger2);
		
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
	
	else if ( showRope )
	{
		component = (CDrawableComponent) gallow.GetComponent( "rope4_mesh" );
		component.SetVisible( true );
		return true;
	}
	
	return true;
}

//PW: f-kcja do dawania ;-)
quest function QGiveItemInScene( giverTag: name, receiverTag : name, itemName : name, optional quantity : int ) : bool
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
	
	npcInventory.GiveItem( receiver.GetInventory(), itemId, quantity );
	
	return true;
}
//Funkcja która pozwala na zabranie lub oddanie itemu NPC-owi
quest function QGetWeaponFromNPC ( actorTag : name, containerTag : name, remove : bool) : bool

{
	var i 	       		: int;
	var container  		: CGameplayEntity;
	var source_inv 		: CInventoryComponent;
	var dest_inv		: CInventoryComponent;
	var allItems   		: array< SItemUniqueId >;
	var categoriesToMove : array< name >;
	var itemId	   		: SItemUniqueId;
	var skip       		: bool;
	var itemCategory 	: name;
	var itemQuantity	: int;
	
	container = (CGameplayEntity) theGame.GetNodeByTag(containerTag);
	
	if ( remove )
	{
		dest_inv = container.GetInventory();
		source_inv = theGame.GetActorByTag(actorTag).GetInventory();
	}
	else
	{
		source_inv = container.GetInventory();
		dest_inv = theGame.GetActorByTag(actorTag).GetInventory();
	}
	
	if ( !source_inv )
	{
		Log( "QGetWeaponFromPlayer: Failed to find source inventory ( tag: " + containerTag + " )" );
		return false;
	}
	if ( !dest_inv )
	{
		Log( "QGetWeaponFromPlayer: Failed to find destination inventory ( tag " + containerTag + " )" );
		return false;
	}
	
	source_inv.GetAllItems( allItems );
	
	// Create a list of categories that should be moved to container
	categoriesToMove.PushBack( 'opponent_weapon' );
	categoriesToMove.PushBack( 'opponent_weapon_secondary' );
	categoriesToMove.PushBack( 'opponent_shield' );
	categoriesToMove.PushBack( 'opponent_bow' );
	categoriesToMove.PushBack( 'opponent_weapon_polearm' );
	categoriesToMove.PushBack( 'roche_items' );
	// -- Luke TODO
	
	for ( i = 0; i<allItems.Size(); i+=1 )
	{
		itemCategory = source_inv.GetItemCategory( allItems[i] );
		if ( categoriesToMove.Contains( itemCategory ) )
		{
			itemQuantity = source_inv.GetItemQuantity( allItems[i] );
			source_inv.GiveItem( dest_inv, allItems[i], itemQuantity );	
		}
	}

	return true;
}

//funkcja pozwalaj¹ca na ustawianie stanu bodypartów
quest function QSetBodyPartState ( targetTag : name, bodyPartName : name, bodyPartState : name, optional applyNow : bool) : bool
{
	var entity : CEntity;
	
	entity = theGame.GetEntityByTag(targetTag);
	
	entity.SetBodyPartState( bodyPartName, bodyPartState, applyNow );

	return true;
}

quest function QDrawSteelSwordGeraltInScene()
{
	var id : SItemUniqueId;
	var playerInv : CInventoryComponent;

	playerInv = thePlayer.GetInventory();
	id = playerInv.GetItemByCategory('steelsword');
	//playerInv.GetItemId( 'Rusty Steel Sword' );
	if ( id != GetInvalidUniqueId() )
	{
		thePlayer.SetLastCombatStyle(PCS_Steel);
		thePlayer.DrawWeaponInstant( id );
	}
	else
	{
		Log( "[tempshit quest function] Failed to draw steel sword" );
	}
}

quest function QChangeCombatToSteel()
{
	thePlayer.SetLastCombatStyle(PCS_Steel);
	thePlayer.ChangePlayerState( PS_CombatSteel );
}

//funkcja pozwalajaæa na dodanie itemu do containera
quest function QAddItemToContainer ( itemName : name, containerTag : name, quantity : int) : bool
{
	var inv 	   :  CInventoryComponent;
	var container  : CEntity;
	
	container = (CEntity)theGame.GetNodeByTag(containerTag);
	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	
	inv.AddItem(itemName, quantity);
	
	return true;
}

//funkcja scenowa do despawnu postaci
quest function QDespawnNPCS( npcTag : name): bool
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
quest function QUnEquipItemOnNPCScene ( npc: name, item_name : name) : bool
{
	var item_id : SItemUniqueId;
	var npc_newnpc : CNewNPC;

	npc_newnpc = theGame.GetNPCByTag(npc);
	item_id = npc_newnpc.GetInventory().GetItemId(item_name);
	npc_newnpc.GetInventory().UnmountItem(item_id);
	return true;
}

latent quest function QUnEquipItemOnPlayerScene ( item_name : name) : bool
{
	var item_id : SItemUniqueId;

	item_id = thePlayer.GetInventory().GetItemId(item_name);
	thePlayer.GetInventory().UnmountItem( item_id );
	return true;
}

latent quest function QEquipItemOnPlayerScene ( item_name : name) : bool
{
	var item_id : SItemUniqueId;

	item_id = thePlayer.GetInventory().GetItemId(item_name);
	thePlayer.GetInventory().MountItem( item_id, false );
	return true;
}

quest function QHideLoadingScreen() : bool
{
	// TODO: obsolete?
	return false;
}

quest function QSetCharacterApearance( apearance : name, npcTag : name) : bool
{
	var triss : CNewNPC;
	triss =  theGame.GetNPCByTag(npcTag);
	triss.SetAppearance(apearance);
	return true;
}

quest function QSetGeraltNaked() : bool
{
	var cplayer : CPlayer;
	var allItems : array< SItemUniqueId >;
	var hairId : SItemUniqueId;
	var i : int;
	
	cplayer = thePlayer;

	cplayer.GetInventory().GetAllItems( allItems );
	
	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		if ( thePlayer.GetInventory().IsItemMounted( allItems[i] )  )
		{
			thePlayer.GetInventory().UnmountItem( allItems[i], true );
		}
	}
	
	hairId = thePlayer.GetInventory().GetItemId('default_geralt_hair');
	thePlayer.GetInventory().MountItem(hairId, false);
	
	return true;
}
//Funkcja pozwalaj¹ca na rzucenie entity w zdefiniowany cel
quest function QThrowObject ( objectTag : name, targetTag : name, angleInDegrees : float, multiplier : float ) : bool 
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

quest function QTempStun ( actorTag: name ) : bool
{
	var actorNPC : CNewNPC;	
	actorNPC = theGame.GetNPCByTag(actorTag);	
	actorNPC.Stun(false, NULL);
	return true;
}

//PW: f-kcja do wrzucania lub zrzucania ze stosu behavior grafów na postaci
quest function QPushOrPopBehaviorGraph ( actorTag : name, behaviorGraphName : name, push : bool) : bool
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
quest function QCreateEntityInScene ( entityTemplate : CEntityTemplate, position : Vector, optional rotation : EulerAngles,
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

//PW: f-kcja do ustawiania Idle'a na postaci w zasiêgu actorSearchRange
quest function QSetIdleInRange ( centerPointTag : name, actorSearchRange : float, actorsTag : array<name>) : bool
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
quest function QDestroyObject ( nodeTag : name, debugLayerGroupName : string ) : bool
{
	var node 	 : array <CNode>;
	var entity 	 : CEntity;
	var count, i : int;
	var defLayer : bool;
	
	
	if ( debugLayerGroupName != "" )
	{
		//defLayer = theGame.GetWorld().IsLayerLoaded( debugLayerGroupName ); // DEPRECATED
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

// MT: funkcja w³¹czaj¹ca/wy³¹czaj¹ca p³on¹ce przeszkody
quest function QActivateBurningObstacle ( targetTag : name, enable : bool ) : bool
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

//Funkcja w której gracz mo¿e nosiæ postaæ
latent quest function QScenePlayerStartsCarryingNPC( carriedTag, masterBehaviorName, slaveBehaviorName : name, drawWeapon : bool ) : bool
{
	var result : bool;
	
	result = InteractionPlayerMaster( carriedTag, masterBehaviorName, slaveBehaviorName, drawWeapon );
	return result;
}

latent quest function QInteractionPlayerMaster( slavesTag, masterBehaviorName, slaveBehaviorName : name, drawWeapon : bool ) : bool
{
	var result : bool;
	result = InteractionPlayerMaster( slavesTag, masterBehaviorName, slaveBehaviorName, drawWeapon );
	return result;
}

latent function InteractionPlayerMaster( slavesTag, masterBehaviorName, slaveBehaviorName : name, drawWeapon : bool ) : bool
{
	var slaves : array<CActor>;
	var i : int;
	var result : bool;
	
	theGame.GetActorsByTag( slavesTag, slaves );
	for( i=0; i<slaves.Size(); i+=1 )
	{
		if( slaves[i].IsExternalyControlled() )
		{
			thePlayer.SetErrorState("Cannot start interaction while slave is externally controlled");
			return false;
		}
	}
	
	result = thePlayer.StateInteractionMaster( slaves, masterBehaviorName, slaveBehaviorName, drawWeapon );
	while( result == false )
	{
		Sleep( 0.5 );
		result = thePlayer.StateInteractionMaster( slaves, masterBehaviorName, slaveBehaviorName, drawWeapon );
	}
	
	
	return true;
}

// Ladne konczenie interakcji
quest latent function QInteractionPlayerMasterStop( carryTransitionMode : W2CarryTransitionMode ) : bool
{
	thePlayer.OnStopInteractionState( carryTransitionMode );
	
	while( thePlayer.GetCurrentPlayerState() == PS_PlayerCarry )
	{
		Sleep(0.1);
	}
	
	return true;
}

///////////////////////////////////// SOUND FUNCTIONS /////////////////////////////////////////////

// Funkcja startuj¹ca muzyczny motyw
quest function QPlayMusic( cueName : name ) : bool
{
	theSound.PlayMusic( cueName );
	return true;
}

// Funkcja ustawiajaca glosnosc muzyki w decybelach
quest function QSetMusicVolume( dbVolume : float )
{
	theSound.SetMusicVolume( dbVolume );
}

// Funkcja zatrzymuj¹ca motyw muzyczny
quest function QStopMusic( cueName : string )
{
	theSound.StopMusic( cueName );
}

// Funkcja wyciszajaca muzyke (fade out)
quest function QSilenceMusic()
{
	theSound.SilenceMusic();
}

// Funkcja przywracajaca glosnosc muzyki (fade in)
quest function QRestoreMusic()
{
	theSound.RestoreMusic();
}

// Funkcja odtwarzajaca dzwiek bez pozycjonowania w 3D
quest function QPlaySound( eventName : string )
{
	theSound.PlaySound( eventName );
}

// Funkcja odtwarzajaca dzwiek bez pozycjonowania z delikatnym wejsciem (fade in)
quest function QPlaySoundWithFade( eventName : string )
{
	theSound.PlaySoundWithFade( eventName );
}

// Funkcja odtwarzajaca dzwiek spozycjonowany na konkretnej kosci aktora (domyslnie - puste)
quest function QPlaySavableSoundOnActor( actorTag : name, boneName : name, eventName : string, fadeTime : float )
{
	var request : CPlaySoundOnActorRequest;

	request = new CPlaySoundOnActorRequest in theGame;
	request.Initialize( boneName, eventName, fadeTime );
	
	theGame.AddStateChangeRequest( actorTag, request );
}

// Funkcja odtwarzajaca dzwiek spozycjonowany na konkretnej kosci aktora (domyslnie - puste)
quest function QPlaySoundOnActor( actorTag : name, boneName : name, eventName : string )
{
	var actor : CNode;
	
	actor = theGame.GetNodeByTag( actorTag );
	theSound.PlaySoundOnActor( actor, boneName, eventName );
}

// Funkcja odtwarzajaca dzwiek spozycjonowany na aktorze z delikatnym wejsciem (fade in)
quest function QPlaySoundOnActorWithFade( actorTag : name, boneName : name, eventName : string )
{
	var actor : CNode;
	
	actor = theGame.GetNodeByTag( actorTag );
	theSound.PlaySoundOnActorWithFade( actor, boneName, eventName );
}

// Funkcja stopujaca wszystkie dzwieki o danej nazwie
quest function QStopSoundByName( eventName : string )
{
	theSound.StopSoundByName( eventName );
}

// Funkcja stopujaca wszystkie dzwieki o danej nazwie z delikatnym wyjsciem (fade out)
quest function QStopSoundByNameWithFade( eventName : string )
{
	theSound.StopSoundByNameWithFade( eventName );
}

// Funkcja wyciszajaca wszystkie dzwieki (fade out)
quest function QMuteAllSounds()
{
	theSound.MuteAllSounds();
}

// Funkcja przywracajaca wszystkie dzwieki (fade in)
quest function QRestoreAllSounds()
{
	theSound.RestoreAllSounds();
}

// Blocks/unblocks triggering combat music cue
quest function QBlockCombatMusic( block : bool )
{
	theSound.BlockCombatMusic( block );
}

///////////////////////////////////////////////////////////////////////////////////////////////////

quest function QActivateEnvironment ( AreaEnvironment: string, stabilize : bool ) : bool
{
	AreaEnvironmentActivate(AreaEnvironment);
	
	if( stabilize )
	{
		AreaEnvironmentStabilize();
	}
}

quest function QDectivateEnvironment ( AreaEnvironment: string ) : bool
{
	AreaEnvironmentDeactivate(AreaEnvironment);
}


/*latent quest function ActivateEnvironment ( , AreaEnvironment: string ) : bool
{
	StartAxiiQte();
}
*/

quest function QSetManualControlInScene( movement : bool , camera : bool ) : bool
	{
		thePlayer.SetManualControl(movement, camera);
		
		return true;
	}
	
// Reset camery gracza
quest function QResetPlayerCamera() : bool
	{
		//thePlayer.ResetPlayerCamera();
		theCamera.Reset();
		
		return true;
	}
	
//Funkcja pozwalaj¹ca na za³adowanie lub od³adowanie grupu warstw

quest function QManageLayerGroup ( path : string, load : bool ): bool
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

quest function Qq000Trebuchet ( trebuchet: name, fire : bool, stop : bool, load : bool) : bool
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

latent quest function QMoveAlongPathInScene( npcTag : name, pathTag : name, upThePath, fromBegining : bool, margin, speed : float, moveType : EMoveType) : bool
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

//Funkcja uruchamiaj¹ca chodzenie po œcie¿ce, trzyma sygnal do momentu gdy postac dojdzie

latent quest function QMoveAlongPathUntilReached( npcTag : name, pathTag : name, destinationTag : name, upThePath, fromBegining : bool, margin, speed : float, moveType : EMoveType, optional exitWorkFast : bool ) : bool
{
	var npc 							: CNewNPC;
	var path   							: CPathComponent;
	var targetPath 						: CEntity;
	var dist 							: float;
	var destinationNode					: CNode;
	var destination, actorPosition 		: Vector;
	
	targetPath = theGame.GetEntityByTag(pathTag );
	npc  = theGame.GetNPCByTag( npcTag );
	destinationNode = theGame.GetNodeByTag( destinationTag );
	destination = destinationNode.GetWorldPosition();
	
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
	
	npc.ActionExitWork( exitWorkFast );
	npc.GetArbitrator().ClearGoal();
	npc.GetArbitrator().AddGoalWalkAlongPath( path, upThePath, fromBegining, margin, moveType, speed );
	
	dist = 1;
	while( dist > 0.3f )
	{
		actorPosition = npc.GetWorldPosition();
		dist = VecDistance2D( destination, actorPosition );
		
		Sleep( 0.1f );
	}
	
	return true;
}


// kills player
quest function QGameOver() : bool
{
	theSound.PlaySound("gui/gui/gui_gameover");
	theHud.m_hud.SetGameOver();

	return true;
}

//sprawdzenie zgaszenia pochodni
latent quest function QCheckIfTorchOn ( ObjectTag : name, LightAreaIsOn : bool, doorTag: name, immediate : bool  ) : bool
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

// Funkcja zak³adaj¹ca fomracjê w scenie
quest function QSetFormation ( FormationLeaderTag : name, formationFollowerTags : array<name>, formationType : EFormationType, noCombat : bool ) : bool
{
	return true;
}

//Odpalenie eventu animacji na aktorze

quest function QPlayAnimationEvent( entityTag : name, eventName: name, forceEvent: bool ) : bool
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

//Zadawanie obrazen targetowi // MT
latent quest function dealDamageToTarget( targetTag : name, amount : float ) : bool
{
	theGame.GetActorByTag( targetTag ).DecreaseHealth( amount, true, NULL );
	Sleep(2.f);
	return true;
}

// funkcja wyswietla creditsy

quest function ShowDarkEnd()
{
	if(theGame.GetDifficultyLevel() == 4)
	{
	
		theHud.ShowDarkEnd();
		if(!theGame.IsActivelyPaused())
		{
			theGame.SetActivePause(true);
		}
	}
}

latent quest function ShowCredits(ltitle: string, l1 : string, l2 : string, l3 : string, l4 : string, l5 : string, rtitle: string, r1 : string, r2: string, r3 : string, r4 : string, r5 : string, time : float, clearCredits : bool)
{
	var args : array < string >;
	
	if ( ! clearCredits )
	{
		args.PushBack(ltitle); // title left
		args.PushBack(l1); // 1
		args.PushBack(l2); // 2
		args.PushBack(l3); // 3
		args.PushBack(l4); // 4
		args.PushBack(l5); // 5
		args.PushBack(rtitle); // title right
		args.PushBack(r1); // 1
		args.PushBack(r2); // 2
		args.PushBack(r3); // 3
		args.PushBack(r4); // 4
		args.PushBack(r5); // 5
	
		theHud.m_messages.ShowCredits( args );
		Sleep( time );
	}
	
	theHud.m_messages.HideCredits();
}

// funkcja do pokazywania logo
quest function W2Logo( visible : bool)
{
  if (visible)
  {
		//theHud.m_fx.W2LogoStart( false );
		ShowLogo();
  }
  else
  {
		//theHud.m_fx.W2LogoStop();
		CloseLogo();
  }
}

quest function QEnableEncounters( encounterTag : name, enable : bool ) : bool
{
	var request : CEncounterStateRequest;
	request = new CEncounterStateRequest in theGame;
	request.enable = enable;
	
	if( !theGame.GetEntityByTag( encounterTag ) )
	{
		Log( "Could'nt find encounter with tag '" + encounterTag + "'" );
		return false;
	}
	
	theGame.AddStateChangeRequest( encounterTag, request );
	return true;
}

//Funcka pozwalajaca na podmiane szablonu aktora

latent quest function QLoadDynamicActorTemplate (actorTag: name, dynamicTemplatePath: CEntityTemplate, load: bool, appearance: name, isNotGeralt : bool) : bool
{
	var request : CDynamicActorTemplateRequest;
	var allItems : array< SItemUniqueId >;
	var i : int;
	
	request = new CDynamicActorTemplateRequest in theGame;
	request.Initialize( dynamicTemplatePath, appearance, load, isNotGeralt );
	
	Log("======================= REPLACER ===================");
	Log("Actor Tag: " + NameToString( actorTag ));
	Log("Appearance :" + NameToString( appearance ));
	Log("isNotGeralt: " + isNotGeralt );
	Log("====================================================");
	
	thePlayer.StopEffect( 'Quen_level0' );
	
	theGame.AddStateChangeRequest( actorTag, request );
	
	
	return true;
	
}
latent quest function QWaitForSeconds(waitTime: float) : bool
{
	Sleep(waitTime);
	return true;
}

//MSZ: Function for shooting arrows at target position.
//Warnings: projectileTemplate - must be a CRegularProjectile class object. 
latent quest function QShootProjectilesAtPosition(projectileTemplate: CEntityTemplate, projectilesNumber: int, startPositionTag: name, randomStartPosRadius: float, startPositionOffset : Vector, targetPositionTag: name, randomTargetPosRadius: float, targetPositionOffset: Vector, angle : float, shootersDelay : float, playSound : EArrowSoundType, playGroupArrowsShootSound : bool) : bool
{
	var i, j, k, sizeStartA, sizeTargetA, projectilesPerStartPos, projectilesPerTargetPos : int;
	var startPos, targetPos : Vector;
	var normal : EulerAngles;
	var startArray, targetArray : array<CNode>;
	var projectile : CRegularProjectile;
	var arrowDelay : float;	
	theGame.GetNodesByTag(startPositionTag, startArray);
	theGame.GetNodesByTag(targetPositionTag, targetArray);
	sizeStartA = startArray.Size();
	sizeTargetA = targetArray.Size();
	if(playGroupArrowsShootSound)
	{
		theSound.PlaySoundOnActor(startArray[0], '', "l03_camp/l03_quests/q208/draug_arrows_release");
	}
	if(shootersDelay > 0.0)
	{
		arrowDelay = shootersDelay/projectilesNumber;
	}
	if(sizeStartA == 0)
	{
		Log("QShootProjectileAtPosition ERROR: no start position");
		
	}
	else if(sizeTargetA == 0)
	{
		Log("QShootProjectileAtPosition ERROR: no target position");
	}
	else
	{
		projectilesPerStartPos = RoundF(projectilesNumber / sizeStartA);
		if(projectilesPerStartPos<=0)
		{
			projectilesPerStartPos = 1;
		}
		for(i = 0; i<sizeStartA; i+=1)
		{
			k = i;
			if(k>=sizeTargetA)
			{
					k = 0;
			}
			for(j=0; j<projectilesPerStartPos; j+=1)
			{
				startPos = startArray[i].GetWorldPosition() + startPositionOffset;
				startPos +=VecRingRand(0.0, randomStartPosRadius);
				targetPos = targetArray[k].GetWorldPosition() + targetPositionOffset;
				targetPos += VecRingRand(0.0, randomTargetPosRadius);
				theGame.GetWorld().PointProjectionTest(targetPos, normal, 2.0);
				projectile = (CRegularProjectile)theGame.CreateEntity(projectileTemplate, startPos, EulerAngles());
				if(angle > 0)
				{
					projectile.PlayEffect('trials');
					projectile.PlayEffect('trail_fx');
					projectile.InitSound(playSound);
					projectile.Start( NULL, targetPos, false, angle );
					if(arrowDelay > 0)
					{
						Sleep(arrowDelay);
					}
				}
				else
				{
					projectile.PlayEffect('trials');
					projectile.PlayEffect('trail_fx');
					projectile.InitSound(playSound);
					projectile.Start( NULL, targetPos, false );
					if(arrowDelay > 0)
					{
						Sleep(arrowDelay);
					}
				}
				
				k +=1;
				if(k>=sizeTargetA)
				{
					k = 0;
				}
			}
		}

	}
	return true;
}
latent quest function QShootProjectilesAtTargets(projectileTemplate: CEntityTemplate, projectilesNumber: int, startPositionTag: name, randomStartPosRadius: float, startPositionOffset : Vector, targetsTags: array<name>, targetPositionOffset: Vector, angle : float, shootersDelay : float, playSound : EArrowSoundType, playGroupArrowsShootSound : bool) : bool
{
	var i, j, k, sizeTempTargetA, sizeTargetTagsA, sizeStartA, sizeTargetA, projectilesPerStartPos, projectilesPerTargetPos : int;
	var startPos : Vector;
	var currentTargetTag : name;
	var startArray, tempTargetArray : array<CNode>;
	var targetArray : array<CActor>;
	var currentTarget : CActor;
	var projectile : CRegularProjectile;
	var arrowDelay : float;
	var playNode : CNode;
	sizeTargetTagsA = targetsTags.Size();
	Log("QShootProjectilesAtTargets : function started");
	if(sizeTargetTagsA > 0)
	{
		//MSZ: preparing targetArray
		for(i=0; i<sizeTargetTagsA; i+=1)
		{
			currentTargetTag = targetsTags[i];
			theGame.GetNodesByTag(currentTargetTag, tempTargetArray);
			sizeTempTargetA = tempTargetArray.Size();
			if(sizeTempTargetA>0)
			{
				for(j=0; j<sizeTempTargetA; j+=1)
				{
					targetArray.PushBack((CActor)tempTargetArray[j]);
				}
			}
		}
		theGame.GetNodesByTag(startPositionTag, startArray);
		if(playGroupArrowsShootSound)
		{
			theSound.PlaySoundOnActor(startArray[0], '', "l03_camp/l03_quests/q208/draug_arrows_release");
		}
		sizeStartA = startArray.Size();
		sizeTargetA = targetArray.Size();
		if(shootersDelay > 0.0)
		{
			arrowDelay = shootersDelay/projectilesNumber;
		}
		if(sizeStartA == 0)
		{
			Log("QShootProjectileAtTarget ERROR: no start position");
			
		}
		else if(sizeTargetA == 0)
		{
			Log("QShootProjectileAtTarget ERROR: no targets");
		}
		else
		{
			projectilesPerStartPos = RoundF(projectilesNumber / sizeStartA);
			if(projectilesPerStartPos<=0)
			{
				projectilesPerStartPos = 1;
			}
			for(i = 0; i<sizeStartA; i+=1)
			{
				k = i;
				if(k>=sizeTargetA)
				{
					k = 0;
				}
				for(j=0; j<projectilesPerStartPos; j+=1)
				{
					startPos = startArray[i].GetWorldPosition() + startPositionOffset;
					startPos +=VecRingRand(0.0, randomStartPosRadius);
					currentTarget = targetArray[k];
					projectile = (CRegularProjectile)theGame.CreateEntity(projectileTemplate, startPos, EulerAngles());
					if(angle > 0)
					{
						projectile.PlayEffect('trials');
						projectile.PlayEffect('trail_fx');
						projectile.InitSound(playSound);
						projectile.Start( currentTarget, targetPositionOffset, false, angle );
						Log("QShootProjectilesAtTargets : shooting at target " + currentTarget);
						if(arrowDelay > 0)
						{
							Sleep(arrowDelay);
						}
					}
					else
					{
						projectile.PlayEffect('trials');
						projectile.PlayEffect('trail_fx');
						projectile.InitSound(playSound);
						projectile.Start( currentTarget, targetPositionOffset, false );
						Log("QShootProjectilesAtTargets : shooting at target " + currentTarget);
						if(arrowDelay > 0)
						{
							Sleep(arrowDelay);
						}
					}
					
					k +=1;
					if(k>=sizeTargetA)
					{
						k = 0;
					}
				}
			}

		}
	}
	else
	{
		Log("QShootProjectileAtTarget ERROR: no target tags specified");
	}
	
	return true;
}

// MT // FUNKCJA DO USTAWIANIA GRACZOWI STANU EKSPLORACYJNEGO
quest function SetPlayerExplorationState() : bool
{
	var player : CPlayer;
	var oldState : EPlayerState;
	var behStateName : string;
	
	player = thePlayer;
	oldState = player.GetCurrentPlayerState();
	behStateName = player.GetCurrentStateName();
	
	if( player.EntryExploration(oldState, behStateName) )
	{
		return true;
	}
	else
	{
		return false;
	}
}

// Odpalanie linnijek dialogowych skryptem po ID dla arrayow postaci

struct SCharTagAndPlayLine
{
	var characterTag : name;
	var linesIDs : array<int>;
};

latent quest function QPlayLineForCharacterArray ( data : array<SCharTagAndPlayLine> ) : bool
{
	var currLineIndex : int;
	var currCharIndex : int;
	var i : int;
	var maxLinesSize : int;

	// znajdz max linijke
	maxLinesSize = 0;
	for ( i = 0; i < data.Size(); i += 1 )
	{
		if ( data[i].linesIDs.Size() > maxLinesSize )
		{
			maxLinesSize = data[i].linesIDs.Size();
		}
	}

	// dla kazej linijki piosenki	
	for ( currLineIndex = 0; currLineIndex < maxLinesSize; currLineIndex += 1 )
	{
		// dla kazdego npca
		for ( currCharIndex = 0; currCharIndex < data.Size(); currCharIndex += 1 )
		{
			if ( currLineIndex < data[currCharIndex].linesIDs.Size() )
			{
		
				// data[currCharIndex].linesIDs[ currLineIndex ] - id linijki do odegrania
		
				// data[currCharIndex].characterTag - tag aktora
				theGame.GetActorByTag( data[currCharIndex].characterTag ).PlayLine( data[currCharIndex].linesIDs[ currLineIndex ], false );
			}
		}
	}
}


// funkcja pozwalajaca na zmiane appereanca po tagu
quest function QApplyAppearance( appearanceName : string, npcTag : name  ) : bool 
{
	var actorNPC : CNewNPC;
	
	actorNPC  = theGame.GetNPCByTag( npcTag );

	actorNPC.ApplyAppearance( appearanceName );

	return true;
}

// funkcja pozwalajaca na zmiane appereanca po tagu
quest function QApplyAppearanceForEntity( appearanceName : string, entityTag : name  ) : bool 
{
	var entity : CEntity;
	
	entity  = theGame.GetEntityByTag( entityTag );

	entity.ApplyAppearance( appearanceName );

	return true;
}

quest function QDrawWeapon( targetsTag : name ) : bool
{
	var targets : array<CNewNPC>;
	var i : int;
	var weaponId : SItemUniqueId;
	
	theGame.GetNPCsByTag( targetsTag, targets );
	
	for( i = 0; i < targets.Size(); i +=1 )
	{
		if( targets[i].HasCombatType( CT_ShieldSword ) )
		{
			weaponId = targets[i].GetInventory().GetItemByCategory('opponent_weapon');
			if ( weaponId == GetInvalidUniqueId() )
			{
				weaponId = targets[i].GetInventory().GetItemByCategory('steelsword');
			}
			targets[i].DrawWeaponInstant(weaponId);
			
			weaponId = targets[i].GetInventory().GetItemByCategory('opponent_shield');
			if ( weaponId == GetInvalidUniqueId() )
			{
				weaponId = targets[i].GetInventory().GetItemByCategory('shield');
			}
			targets[i].DrawWeaponInstant(weaponId);
		}
		
		else if( targets[i].HasCombatType( CT_Bow ) )
		{
			weaponId = targets[i].GetInventory().GetItemByCategory('opponent_bow');
			if( weaponId == GetInvalidUniqueId() )
			{
				weaponId = targets[i].GetInventory().GetItemByCategory('rangedweapon');
			}
			targets[i].DrawWeaponInstant(weaponId);
		}
		
		else
		{
			targets[i].DrawWeaponInstant( targets[i].GetInventory().GetFirstLethalWeaponId() );
		}
	}
	
	return true;
}	


quest function QDrawCrossbow( targetsTag : name ) : bool
{
	var targets : array<CNewNPC>;
	var i : int;
	var weaponId : SItemUniqueId;
	
	theGame.GetNPCsByTag( targetsTag, targets );
	
	for( i = 0; i < targets.Size(); i +=1 )
	{
			weaponId = targets[i].GetInventory().GetItemByCategory('opponent_bow');
			if( weaponId == GetInvalidUniqueId() )
			{
				weaponId = targets[i].GetInventory().GetItemByCategory('rangedweapon');
			}
			targets[i].DrawWeaponInstant(weaponId);
	}		
	
	return true;
}	

//pause/unpause czasu w GUI
quest function QPauseGUITime ( pause : bool) : bool
{
	theHud.PauseTime( pause );
	return true;
}
// MT // Funkcja do ustawiania pijackiej, rannej, itd. eksploracji
quest function QChangeNPCExplorationState( npcsTag : name, newState : EExplorationState ) : bool
{
	var npcs : array<CNewNPC>;
	var i : int;
	
	theGame.GetNPCsByTag( npcsTag, npcs );
	
	for( i = 0; i < npcs.Size(); i +=1 )
	{
		npcs[i].ActivateBehavior( 'npc_exploration' );
		npcs[i].SetMovementType( newState );
	}
	
	return true;
}

//LSZ // Funkcja do q209i_defending_vergen. Geralt jest powalany czarem Detmolda.

quest latent function QGeraltFallsDown_in_q209i() : bool
{
	thePlayer.AttachBehavior('quest_custom');
	thePlayer.RaiseForceEvent('start_geralt_falls_down');
	
	thePlayer.WaitForBehaviorNodeDeactivation ('geralt_felt_down', 20.f);
	
return true;
}

//LSZ // Funcka sluzaca do blokowania gracza i/lub kamery
quest function QBlockPlayer(blockPlayer : bool, freeCamera : bool) : bool
{
	thePlayer.SetManualControl(!blockPlayer, freeCamera);
	thePlayer.ResetPlayerMovement();
	
	return true;
	
}
quest function QArenaConnectToCrowd()
{
	theGame.GetArenaManager().ConnectToArenaCrowd();
}
latent quest function QArenaReset()
{
	var arenaManager : CArenaManager;
	var arenaContainer : CArenaContainter;

	arenaManager = (CArenaManager)theGame.GetEntityByTag('arena_manager');
	arenaContainer = (CArenaContainter)theGame.GetEntityByTag('arena_container');
	
	//arenaContainer.GetInventory().RemoveAllItems();
	//arenaManager.InitArena();
	
	arenaManager.ResetSpawnedOpponents();
	arenaManager.ResetRounds();
	arenaManager.RemoveTimer('TimerWaveBonusTime');
	arenaManager.SetIsFighting(false);
	arenaManager.SetRoundStart(false);
	arenaManager.ShowArenaHUD(false);
	arenaManager.UpdateArenaHUD(false);
	arenaManager.ShowArenaHUD(true);
	arenaManager.RemoveAllTraps();
	thePlayer.SetManualControl(true, true);
	theHud.ArenaFollowersGuiHealth( 100 );
	theSound.PlayMusic("prep_room");
	FactsAdd("arena_room", 1);
	Sleep(2.5);
	theGame.FadeInAsync(2.0);
}

quest function QArenaChooseDifficulty()
{
	var arenaManager : CArenaManager;
	theHud.m_hud.HideTutorial();
	theHud.m_hud.DisableTutorial();
	theHud.ShowArenaDiff();
	arenaManager = (CArenaManager)theGame.GetEntityByTag('arena_manager');
	//arenaManager.ShowArenaHUD(true);
}
quest function QArenaPlayRoomMusic()
{
	theSound.PlayMusic("prep_room");
}
quest function QArenaUpdateHUD()
{
	var arenaManager : CArenaManager;
	theHud.m_hud.HideTutorial();
	theHud.m_hud.DisableTutorial();
	arenaManager = (CArenaManager)theGame.GetEntityByTag('arena_manager');
	if(arenaManager)
	{
		arenaManager.UpdateArenaHUD(false);
	}
}
//MT// Funkcja do resetowania inputow gracza
quest function QResetPlayerMovement()
{
	thePlayer.ResetMovment();
}

quest function QSetPlayerSneakMode(Flag: bool)

{
	thePlayer.SetSneakMode(Flag);
	thePlayer.ChangePlayerState(PS_Exploration);
}
//MT// Restores health to target
quest function QRestoreHealth( targetTag : name ) : bool
{
	var target : CNewNPC;
	var maxHealth, currentHealth, healAmount : float;
     
    if( targetTag != 'PLAYER' )
    {
		target = theGame.GetNPCByTag( targetTag );
		
		maxHealth = target.GetInitialHealth();
		currentHealth = target.health;
		
	    healAmount = maxHealth - currentHealth;
		target.IncreaseHealth( healAmount );
    }
    else
    {
		maxHealth = thePlayer.GetInitialHealth();
		currentHealth = thePlayer.health;
		
		healAmount = maxHealth - currentHealth;
		thePlayer.IncreaseHealth( healAmount );
    }
	
	return true;
}

//MT// Sets immortal on actor
quest function QSetImmortal( targetsTag : name, immortalityMode : EActorImmortalityMode ) : bool
{
	var targets : array<CActor>;
	var i : int;
	
	theGame.GetActorsByTag( targetsTag, targets );
	
	for( i = 0; i < targets.Size(); i += 1 )
	{
		targets[i].SetImmortalityModePersistent( immortalityMode );
	} 
	
	return true;
}
//clear immortal on actors
quest function QClearImmortal( targetsTag : name ) : bool
{
	var targets : array<CActor>;
	var i : int;
	
	theGame.GetActorsByTag( targetsTag, targets );
	
	for( i = 0; i < targets.Size(); i += 1 )
	{
		targets[i].ClearImmortality();
	} 
	
	return true;
}

quest function QForceCancelWork( NpcTag : name) : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( NpcTag );
	
	npc.ActionCancelAll();
	//npc.ActionExitWorkAsync( false );
	
	return true;
}

quest function QPlayEventOnPlayer(EventName : name, BehaviourName : name) : bool
{
	thePlayer.AttachBehavior( BehaviourName );
	thePlayer.RaiseEvent( EventName );

	return true;
}

quest function QStaticCombat( npcTag : name, targetTag : name, symetric : bool, affectAll : bool ) : bool
{
	var npc, target : CNewNPC;		
	var npcs : array <CNewNPC>;
	var i      : int;

	target = theGame.GetNPCByTag( targetTag );
	
	if( !affectAll )
	{		
		npc = theGame.GetNPCByTag( npcTag );
		
		if( npc && target )
		{
			npc.GetArbitrator().AddGoalStaticCombat( target, npc.GetWorldPosition() );
			if( symetric )
			{
				target.GetArbitrator().AddGoalStaticCombat( npc, target.GetWorldPosition() );
			}
			return true;
		}
	}
	
	else // SL / Wariant affectAll nie jest symetryczny!!
	{
		theGame.GetNPCsByTag(npcTag, npcs);
		
		for (i = 0; i < npcs.Size(); i += 1 )
		{	
			npc = npcs[i];
			npc = theGame.GetNPCByTag( npcTag );
			
			if( npc && target )
			{
				npc.GetArbitrator().AddGoalStaticCombat( target, npc.GetWorldPosition() );
				Log(npcTag + " has been associated with " + targetTag);
			}
		}
		return true;
	}
	return false;
}

//jednoprzyciskowe QTE
latent quest function QStartQte ( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, ignoreWrongInput : bool ) : bool
{
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var witcher : CPlayer;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();

	
	witcher = thePlayer;
	//LogChannel( 'QStartQte', "Start" );

	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	
	qteStartInfo.action = 'Use';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	qteStartInfo.ignoreWrongInput = ignoreWrongInput;
	witcher.StartMashFullQTEAsync( qteStartInfo );
	

	result = witcher.GetLastQTEResult();
	
		
	while ( result == QTER_InProgress )
	{
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	} 
	
	if ( result == QTER_Succeeded )
	{
		theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "Action successful!" ) );
	}
	else
	{
		theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "Action failed!" ) );
	}
	
	return result == QTER_Succeeded;
}
//funkcja do questu q302 przenoszaca cale inventory wiedzmina do skrzynki w wiezieniu
latent quest function QQ302TransferInvToChest () :bool
{


	Q302TransferInvToChest( thePlayer, (CContainer) theGame.GetEntityByTag('q302_chest_in_jail') );
}

//funkcja do questu q302 przenoszaca cale inventory wiedzmina ze skrzynki w wiezieniu
latent quest function QQ302TransferFromChestToGeralt () :bool
{
	Q302TransferFromChestToGeralt( (CContainer) theGame.GetEntityByTag('q302_chest_in_jail'), thePlayer );
}

latent quest function QQ002TransferInvToChest () :bool
{


	Q302TransferInvToChest( thePlayer, (CContainer) theGame.GetEntityByTag('q002_geralt_stuff') );
}

latent quest function QQ002TransferFromChestToGeralt () :bool
{
	Q302TransferFromChestToGeralt( (CContainer) theGame.GetEntityByTag('q002_geralt_stuff'), thePlayer );
}


//
//funkcja odblokowujaca wszystkie staty
quest function QBlockAllPlayerState(block : bool) : bool
{
	thePlayer.SetAllPlayerStatesBlocked(block);
}

//funkcja do questu q302 przenoszaca cale inventory wiedzmina ze skrzynki w wiezieniu
latent quest function SQ102TransferFromChestToGeralt () :bool
{
	Q302TransferFromChestToGeralt( (CContainer) theGame.GetEntityByTag('sq102_ves_chest'), thePlayer );
}

//funkcja do questu sq102 przenoszaca cale inventory wiedzmina do skrzynki
latent quest function SQ102TransferFromGeraltToChest () : bool
{
	Q302TransferInvToChest( thePlayer, (CContainer) theGame.GetEntityByTag('sq102_ves_chest') );
}

//MT// funkcja do odkladania skrzynki przez npca
latent quest function QPutDownBox( targetTag : name ) : bool
{
	var target : CNewNPC;
	
	target = theGame.GetNPCByTag( targetTag );
	
	target.RaiseEvent('stop_carry_box');
	target.WaitForBehaviorNodeDeactivation( 'CarryEnd', 20.f );
	
	target.SetMovementType( EX_Normal );
	
	return true;
}

//funkcja do ustawiania attituda grupy
latent quest function QSetGroupAttitude( srcGroup : name, dstGroup : name, attitude : EAIAttitude ) : bool
{
	theGame.SetGlobalAttitude( srcGroup, dstGroup, attitude );
	
	return true;
}

//funkcja do ustawiania attituda grupy
latent quest function QEnablePhysics( objectTag : name, Enable : bool ) : bool
{
	var entity    : array <CNode>;
	var single_entity : CEntity;
	var count, i : int;
	var single_component : CRigidMeshComponent;	
	
	theGame.GetNodesByTag( objectTag, entity);
	count = entity.Size();
	
	for ( i = 0; i < count; i += 1 )
	{
		single_entity = (CEntity) entity[i];
		if ( ! single_entity )
			continue;
		
		single_component = (CRigidMeshComponent) single_entity.GetComponentByClassName( 'CRigidMeshComponent' );
		
		if ( ! single_component )
			continue;
			
		if(Enable)
		{
			single_component.EnablePhysics();
		}
		else
		{
			single_component.DisablePhysics();
		}
	}
	
	return true;
}

;
// MT // Odpycha playera // SL zaleznie od ustawienia wzgledem tarczownika
quest function QKnockBackPlayer( atackerPositionTag : name) : bool
{
	
		var isFrontToSource : bool;
		var atackerPosition : CEntity;
		var hitPosition : Vector;
		var s : int;
		var hitEnums_t3 				: array<EPlayerCombatHit>;
		
		atackerPosition = (CEntity)theGame.GetNodeByTag(atackerPositionTag);
		
		hitPosition = atackerPosition.GetWorldPosition();
		
		isFrontToSource = thePlayer.IsRotatedTowardsPoint( hitPosition, 90 );
		
		theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
		theCamera.RaiseEvent('Camera_ShakeHit');
		if( isFrontToSource )
		{	
			s = hitEnums_t3.Size();
			if( s == 0 )
			{
				thePlayer.PlayerCombatHit(PCH_Hit_3a);
			}
				else
			{	
				thePlayer.PlayerCombatHit(hitEnums_t3[Rand(s)]);
			}		
		}
		else
		{
			thePlayer.PlayerCombatHit(PCH_HitBack_3);
		}

	return true;
}

// SL // Odpycha playera - odpowiednik funkcji do q303 (mozliwe, ze bedzie inny event wznoszony)

quest function QKnockBackPlayerQ303( atackerPositionTag : name) : bool
{
	
		var isFrontToSource : bool;
		var atackerPosition : CEntity;
		var hitPosition : Vector;
		var s : int;
		var hitEnums_t3 				: array<EPlayerCombatHit>;
		
		atackerPosition = (CEntity)theGame.GetNodeByTag(atackerPositionTag);
		
		hitPosition = atackerPosition.GetWorldPosition();
		
		isFrontToSource = thePlayer.IsRotatedTowardsPoint( hitPosition, 90 );
		
		theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
		theCamera.RaiseEvent('Camera_ShakeHit');
		if( isFrontToSource )
		{	
			s = hitEnums_t3.Size();
			if( s == 0 )
			{
				thePlayer.PlayerCombatHit(PCH_Hit_3a);
			}
				else
			{	
				thePlayer.PlayerCombatHit(hitEnums_t3[Rand(s)]);
			}		
		}
		else
		{
			thePlayer.PlayerCombatHit(PCH_HitBack_3);
		}

	return true;
}

// MT // Zadaje zdefiniowany dmg zdefiniowanemu obiektowi
quest function QDealDmgToObject( objectTag : name, damage : float ) : bool
{
	var target : CEntity;
	var destructionComponent : CDestructionSystemComponent;
	
	target = theGame.GetEntityByTag( objectTag );
	
	destructionComponent = (CDestructionSystemComponent) target.GetComponentByClassName( 'CDestructionSystemComponent' );
	
	destructionComponent.ApplyScriptedDamage( -1, damage );
	
	return true;
}

// MT // Geralt spada z zawalajacego sie mostu
quest latent function QSetRagdollOnPlayer( enable : bool ) : bool
{
	thePlayer.SetRagdoll( enable );
	
	return true;
}

;
//L.Sz. Funkcja pozwalajaca na zapalenie swieczki o konkretnym tagu. Tymczasowo podpiete sa animacje do zastawiania pulapki
quest latent function QGeraltFireCandle (candleTag : name) : bool
{

var candle : CNode;
var candlePosition : Vector;
var candleHeading : float;

	candle = theGame.GetNodeByTag(candleTag);
	candlePosition = candle.GetWorldPosition();
	//candleHeading = candle.GetHeading();
	
	thePlayer.SetManualControl(false, true);
	thePlayer.RotateTo(candlePosition, 0.2);
	thePlayer.AttachBehavior('exploration');
	thePlayer.RaiseForceEvent('fire_candle');
	
	thePlayer.WaitForBehaviorNodeDeactivation ('candle_fired', 20.f);
	thePlayer.SetManualControl(true, true);
	
return true;
}


//Funckja zakladajaca efekt sepii do flashabckow i innych rzeczy na gameplayu dziejacych sie w przeszlosci
quest function QSetSepiaFullscreenEffect (Enable : bool, fadeIn : float, fadeOut : float) : bool
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

// SL // Przydziela danym NPC'om guardAreaTag
quest function QAssociateGuardAreaToNPC( npcTag : name, areaTag : name ) : bool
{
	var npcs : array <CNewNPC>;
	var i      : int;
	var npc : CNewNPC;
	
	theGame.GetNPCsByTag(npcTag, npcs);
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		npc.SetGuardArea( areaTag );
		Log(areaTag + " has been associated with " + npcTag);
		
	}
	return true;
}

quest latent function Q307_SetDragonCombatPhase(phaseId : EDragonA3CombatPhase, dragonToSpawn : CEntityTemplate)
{
	var dragon : CDragonA3Base;
	var dragonFlying : CEntity;
	var spawnNode : CNode;
	var dragonHead : CDragonHead; 
	var dragonHeadHolder : CNode;
	
	dragon = (CDragonA3Base)theGame.GetEntityByTag('dragon_a3');
	
	dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
	if( !dragonHead && phaseId != DCP_NoDragon )
	{
		Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
		Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
		Log( "!!!!!Dragon Head doesn't exist!!!!!!!!!!!!THIS IS VERY BAD AND AINT GONNA WORK!!!!!" );
		Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
		Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
		Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		return;
	}
	dragonHeadHolder = theGame.GetNodeByTag('dragon_head_hold');
	
	if(phaseId == DCP_NoDragon)
	{
		if( dragon )
		{
			dragon.Destroy();
		}
			
		dragonHead.Teleport(dragonHeadHolder.GetWorldPosition());
	}
	else if(phaseId == DCP_DragonFlying)
	{
		thePlayer.EnablePhysicalMovement(false);
		
		spawnNode = theGame.GetNodeByTag('q307_dragon_flying_sp');
		dragonFlying = theGame.CreateEntity(dragonToSpawn, spawnNode.GetWorldPosition(), spawnNode.GetWorldRotation());
	}
	else if(phaseId == DCP_Windows)
	{
		thePlayer.EnablePhysicalMovement(true);
		
		dragonFlying = theGame.GetEntityByTag('dragon_a3_flying');
		if( dragonFlying )
		{
			dragonFlying.Destroy();
		}
		
		if(dragon)
		{
			dragon.Destroy();
		}
		
		spawnNode = theGame.GetNodeByTag('d_window1_3');
		dragon = (CDragonA3Windows)theGame.CreateEntity( dragonToSpawn, spawnNode.GetWorldPosition(), spawnNode.GetWorldRotation() );
		if( !dragon )
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "!!!!!Dragon has not been created!!!!!!!!!!!!!!!THIS IS BAD AND AINT GONNA WORK!!!!!" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return;
		}
		
		dragonHead.AttachToDragon( dragon );
	}
	else if(phaseId == DCP_FirstFloor)
	{
		thePlayer.EnablePhysicalMovement(true);
		
		if(dragon)
		{
			dragon.Destroy();
		}
		
		spawnNode = theGame.GetNodeByTag('dragon_a3_floor_sp');
		dragon = (CDragonA3Floor)theGame.CreateEntity(dragonToSpawn, spawnNode.GetWorldPosition(), spawnNode.GetWorldRotation());
		if( !dragon )
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "!!!!!Dragon has not been created!!!!!!!!!!!!!!!THIS IS BAD AND AINT GONNA WORK!!!!!" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return;
		}
		
		dragonHead.AttachToDragon( dragon );
	}
	else if(phaseId == DCP_TowerTop)
	{
		thePlayer.EnablePhysicalMovement(true);
		
		if( dragon )
		{
			dragon.Destroy();
		}
		
		spawnNode = theGame.GetNodeByTag('dragon_a3_top_sp');
		dragon = (CDragonA3Base)theGame.CreateEntity(dragonToSpawn, spawnNode.GetWorldPosition(), spawnNode.GetWorldRotation());
		if( !dragon )
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "!!!!!Dragon has not been created!!!!!!!!!!!!!!!THIS IS BAD AND AINT GONNA WORK!!!!!" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return;
		}
		
		dragonHead.AttachToDragon( dragon );
		((CDragonA3)dragon).Apear();
	}
	else
	{
		Log("ERROR Q307_SetDragonCombatPhase - no dragon");
	}
}

// Starting fight with Letho/Riszon
quest function Q308_StartFight()
{
	var riszon : CRiszon;
	var node : CNode;

	node = theGame.GetNodeByTag( 'Riszon' );
	riszon = (CRiszon)node;
	
	if( !riszon )
		Log( "Can't find instance of CRiszon with tag 'Riszon'" );
		
	riszon.StartBossFight();
}

// Tempowa funkcja wyrzucajaca obiekt do 0.0.0
quest function QTeleportObjectToZeroZero( objectTag : name ) : bool
{
	var object : CEntity;
	var nodes    : array <CNode>;
	var count, i : int;
	var entities : array <CEntity>;
	
	theGame.GetNodesByTag( objectTag, nodes);
	count = nodes.Size();
	
	for ( i = 0; i < count; i += 1 )
	{
		object = (CEntity) nodes[i];
		if ( ! object )
			continue;
			
		entities.PushBack( object );
		
		continue;
	}
	
	for ( i = 0; i < entities.Size(); i+=1 )
	{
		entities[i].Teleport( Vector(0,0,0) );
		
		continue;
	}
	
	return true;
}

// MT // funkcja wylaczajaca postaciom guard triggery
quest function QRemoveGuardTrigger( npcTag : name ) : bool
{
	var npcs : array <CNewNPC>;
	var i      : int;
	var npc : CNewNPC;
	
	theGame.GetNPCsByTag(npcTag, npcs);
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		npc.ClearGuardArea();
		Log(npcTag + " no longer has guard trigger assigned");
		
	}
	return true;
}

// SL // fake level up
quest function FakeLevelUp( levelUpCount : int ) : bool
{
	FakeLevel( levelUpCount );
	return true;
}

// SL // Zmiana combat type (wpisany current jest podmieniany na new)
quest function QSwapCombatType(npcTag : name, currentCombatType : ECombatType, newCombatType : ECombatType, affectAll : bool, reenterCombat : bool ) : bool
{
	var npc, target : CNewNPC;		
	var npcs : array <CNewNPC>;
	var i      : int;
	
	if( !affectAll )
	{		
		npc = theGame.GetNPCByTag( npcTag );
		npc.SwapCombatType( currentCombatType, newCombatType, reenterCombat );
	}
	
	else
	{
		theGame.GetNPCsByTag(npcTag, npcs);
		
		for (i = 0; i < npcs.Size(); i += 1 )
		{	
			npc = npcs[i];
			
			npc.SwapCombatType( currentCombatType, newCombatType, reenterCombat );
		}
	}
	return true;
}

quest function QSetCombatType(npcsTag : name, primary, secondary : ECombatType, reenterCombat : bool )
{		
	var npcs : array <CNewNPC>;
	var i : int;
	theGame.GetNPCsByTag(npcsTag, npcs);
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npcs[i].SetCombatType( primary, secondary, reenterCombat );
	}
}

latent quest function QMoveToObjectUntilReachedWithRadius( DestinationTag : name, ActorTag: name, moveType : EMoveType, speed : float, radius : float ) : bool
{
	var Actor: CNewNPC;
	var Destination: CNode;
	var distToTarget : float;
	var targetPos, actorPos	: Vector;

	Actor = theGame.GetNPCByTag(ActorTag);
	if ( !Actor )
	{
		return false;
	}
	
	//SL commented out player.RegisterScriptedActor( Actor );

	Destination = theGame.GetNodeByTag( DestinationTag );
	if ( !Destination )
	{
		return false;		
	}

	targetPos = Destination.GetWorldPosition();
	if(radius < 3.5)
	{
		radius = 3.5;
	}
	
	Actor.ClearRotationTarget();
	Actor.GetArbitrator().ClearGoal();
	Actor.GetArbitrator().AddGoalMoveToTarget( Destination, moveType, speed, radius, EWM_Exit );
	
	while ( true )
	{
		actorPos = Actor.GetWorldPosition();
		targetPos = Destination.GetWorldPosition();
		distToTarget = VecDistance2D( actorPos, targetPos );
		
		if(distToTarget <= radius)
		{
			return true; 
		}
		Sleep( 0.5f );
	}
}

//MT// Funkcja do odpalania kwestii z voicesetu dla ludkow
quest function QPlayVoiceset( npcsTag, voicesetInputName : name ) : bool
{
	var npcs : array<CNewNPC>;
	var i : int;
	
	theGame.GetNPCsByTag( npcsTag, npcs );
	
	for( i=0; i<npcs.Size(); i+=1 )
	{
		if( !npcs[i] )
		{
			continue;
		}
	
		npcs[i].PlayVoiceset( 100, NameToString( voicesetInputName ) );
		
		continue;
	}
	
	return true;
}

//SL// Zlamany kark ochroniarza Sheali
quest function q107_shealas_guard_broken_neck( player: CStoryScenePlayer ) : bool
{
	var npc : CNewNPC;

	npc = theGame.GetNPCByTag( 'a1_shealas_guard' );

	npc.ActionCancelAll();
	npc.RaiseForceEvent( 'NeckBroken' );
	
	return true;
}

// Zniszczenie obiektu fizycznego
quest function QChangeIteractiveObjectState ( objectTag : name, stateVal : bool  ) : bool
{
	var object : CEntity;
	var interactiveEnt : CInteractiveEntity;
	
	object = theGame.GetEntityByTag( objectTag );
	interactiveEnt = (CInteractiveEntity)object;
	if ( interactiveEnt )
	{
		interactiveEnt.SetState( stateVal );
	}
	
	return true;
}

//SL// Przelacznik komponentow (liny i zapadnie) szubienicy w akcie 1
quest function Q107_GallowSwitch( ropesOn : bool, leversOn : bool ) : bool
{
		var gallow : CEntity;
		
		var rope3 : CDrawableComponent;
		var rope4 : CDrawableComponent;
		
		var lever3 : CAnimatedComponent;
		var lever4 : CAnimatedComponent;
		
		
		gallow = theGame.GetEntityByTag('q102_gallow');		

		rope3 = (CDrawableComponent) gallow.GetComponent( "rope3_mesh" );
		lever3 = (CAnimatedComponent) gallow.GetComponent('lever3');
		
		rope4 = (CDrawableComponent) gallow.GetComponent( "rope4_mesh" );
		lever4 = (CAnimatedComponent) gallow.GetComponent('lever4');
		
		if( leversOn ) 
			{
				lever3.RaiseBehaviorForceEvent('hanging_on');
				lever4.RaiseBehaviorForceEvent('hanging_on');
			}
		else
			{			
				lever3.RaiseBehaviorForceEvent('hanging_off');
				lever4.RaiseBehaviorForceEvent('hanging_off');
			}
					
		rope3.SetVisible( ropesOn );	
		rope4.SetVisible( ropesOn );
					
		return true;
}

// Skrypt do breakowania stanu uncousius

quest function breakUncousius ( actorsTag : name ) : bool
{
	var actors : array<CNewNPC>;
	var i : int;
				
	theGame.GetNPCsByTag( actorsTag, actors);
	
	for(i = 0; i < actors.Size(); i += 1)
	{
		if( actors.Size() == 0 )
		{
			continue;
		}
	
		actors[i].BreakUnconscious();
		continue;
		
	}
	return true;
}

// przerywa unconscious po statycznym FF
quest function QBreakUncousiusOnPlayer()
{
	thePlayer.BreakUnconscious();
}

// Funckja odpalajaca .bik'a czyli filmik w grze

latent quest function questPlayBikVideoInGame( video_name : string ) : bool
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

latent quest function QTempshitSetCrossbowWalk(targetsTag : name, enable : bool) : bool
{
	var targets : array<CNewNPC>;
	var i : int;
	
	theGame.GetNPCsByTag( targetsTag, targets );
	
	if( enable)
	{
		for( i = 0; i < targets.Size(); i += 1 )
		{
			if( !targets[i] )
			{
				continue;
			}
			
			targets[i].SetBehaviorVariable( "ActorItemAnimState", 1.5f );
			targets[i].EquipItem( targets[i].GetInventory().GetItemId('Crossbow_01'), true );
		}
	}
	else
	{
		for( i = 0; i < targets.Size(); i += 1 )
		{
			if( !targets[i] )
			{
				continue;
			}
		
			targets[i].SetBehaviorVariable( "ActorItemAnimState", 0.f );
			targets[i].UnEquipItem( targets[i].GetInventory().GetItemId('Crossbow_01'), true );
		}
	}
	
	return true;
}

// Funckja dodajaca wpis do dziennika o journalEntryId

quest function QAddJournalEntry( journalEntryType : EJournalKnowledgeGroup, journalEntryId, journalEntrySubId : string,
								 journalEntryCategory : string, journalEntryImage : string ) : bool
{
	if ( journalEntryId == "")
	{
		Log("Trying to add journal entry with empty JournalId!. Ignoring this try.");
		return false;
	}

	thePlayer.AddJournalEntry( journalEntryType, journalEntryId, journalEntrySubId, journalEntryCategory, journalEntryImage );
	return true;
}

// SL : ActionPlaySlotAnimation na postaci o danym tagu
quest latent function QPlaySlotAnimation( targetTag : name, slotName : name, animation : name ) : bool
{
	var npc : CNewNPC;
	var res : bool;
	
	npc = theGame.GetNPCByTag( targetTag );
	res = npc.ActionPlaySlotAnimation( slotName, animation );
	if ( res == false )
	{
		Log ("NIE ODPALAM SIEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
	}
	return true;
}


quest function QPlayMimicAnimation( targetTag : name, animation : name ) : bool
{
	var NPC : CNewNPC;
	
	NPC = theGame.GetNPCByTag( targetTag );
	if (NPC.PlayMimicAnimationAsync( animation ) == false)
		{
			Log ("NIE ODPALAM SIEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
		}
	return true;
}
quest function GCCameraDraug(activateCamera : bool)
{
	if(activateCamera)
	{
		thePlayer.SetManualControl(false, false);
		theCamera.FocusOnStatic(theGame.GetEntityByTag('gc_cs_start').GetWorldPosition(), 120.0);
		theCamera.SetBehaviorVariable("cameraDraug", 1.0);
		theCamera.SetBehaviorVariable("cameraDraugStart", 1.0);
		//theCamera.SetCameraState(CS_Draug);
	}
	else
	{
		theCamera.FocusDeactivation(2.5);
		theCamera.SetBehaviorVariable("cameraDraugStart", 0.0);
		theCamera.SetBehaviorVariable("cameraDraug", 0.0);
		//theCamera.SetCameraState(CS_Combat);
		thePlayer.SetManualControl(true, true);
	}
}

/*latent quest function GCEndDemo(ballTemplate : CEntityTemplate)
{
	var proj : CDraugEndProjectile;
	var draug : CDraugBossGC;
	var startPos : Vector;
	Sleep(4.0);
	draug = (CDraugBossGC)theGame.GetEntityByTag('draug_boss');
	while(!draug.GetDemoEnded())
	{
		startPos = thePlayer.GetWorldPosition() + theCamera.GetCameraDirection() * 70.0;
		startPos.Z = 20.0;
		proj = (CDraugEndProjectile)theGame.CreateEntity(ballTemplate, startPos, EulerAngles());
		proj.Start(thePlayer, Vector(0,0,0), true);		
		Sleep(5.0);
	}
}*/

quest function GCFadeAllSounds()
{
	theSound.MuteAllSounds();
	theSound.SilenceMusic();
}
quest function XboxEndDemo()
{
	theHud.m_fx.W2LogoStart( true );
}
latent quest function GCSpawnWraith(ghostTemplate : CEntityTemplate, spawnpointTag : name, spawnpointTag2 : name)
{
	var position : Vector;
	var rotation : EulerAngles;
	position = theGame.GetEntityByTag(spawnpointTag).GetWorldPosition();
	rotation = theGame.GetEntityByTag(spawnpointTag).GetWorldRotation();
	theGame.CreateEntity(ghostTemplate, position, rotation);
	
	/*Sleep(10.0);
	position = theGame.GetEntityByTag(spawnpointTag2).GetWorldPosition();
	rotation = theGame.GetEntityByTag(spawnpointTag2).GetWorldRotation();
	theGame.CreateEntity(ghostTemplate, position, rotation);
	*/
}

latent quest function Q002TorturerWeaponsReady(ActorTag: name) : bool
{	
	var Actor	: CNewNPC;
	var goals : array<int>;
	var isGoalPresent : bool = true;
	
	Actor = theGame.GetNPCByTag(ActorTag);		
		
	if ( !Actor )
	{
		Log ("Actor not found! Breaking MoveTo!");
		return false;
	}
				
	Actor.GetArbitrator().AddGoalQ002Torturer();
	
	while( isGoalPresent )
	{
		Sleep(0.5);
		goals.Clear();
		isGoalPresent = Actor.GetArbitrator().GetGoalIdsByClassName('CAIGoalScriptedState', goals );
	}
	
	return true;
}

latent quest function Q002ArjanBurnAll(ActorTag: name) : bool
{	
	var Actor	: CNewNPC;
	var goals : array<int>;
		
	Actor = theGame.GetNPCByTag(ActorTag);		
		
	if ( !Actor )
	{
		Log ("Actor not found! Breaking MoveTo!");
		return false;
	}
				
	Actor.GetArbitrator().AddGoalQ002Arjan();
	
	do
	{
		Sleep(0.5);
		Actor.GetArbitrator().GetGoalIdsByClassName('CAIGoalScriptedState', goals );
	}
	while( goals.Size() <= 0 );
	
	return true;
}

// funkcja przeznaczona dla q002_prison_break

latent quest function Q109ArnoltMoveTo(ActorTag: name) : bool
{	
	var Actor	: CNewNPC;
	var goals : array<int>;
		
	Actor = theGame.GetNPCByTag(ActorTag);		
		
	if ( !Actor )
	{
		Log ("Actor not found! Breaking MoveTo!");
		return false;
	}
				
	Actor.GetArbitrator().AddGoalQ109Arnolt();
	
	do
	{
		Sleep(0.5);
		Actor.GetArbitrator().GetGoalIdsByClassName('CAIGoalScriptedState', goals );
	}
	while( goals.Size() <= 0 );
	
	return true;
}

// funkcja przeznaczona dla q002_prison_break

class CActorLatentActionPlayArnoltTorchAnimation extends IActorLatentAction
{
	saved var animationName : name;
	saved var effectName : name;
	saved var itemName : name;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var result : bool;
		var torchID : SItemUniqueId;
		var inventory : CInventoryComponent = actor.GetInventory();
		
		torchID = inventory.GetItemId( itemName );
		result = inventory.MountItem(torchID, true);
		inventory.PlayItemEffect(torchID, effectName );
		
		result = actor.ActionPlaySlotAnimation( 'NPC_ANIM_SLOT', animationName, 0.2f, 0.3f, false );

	}	
}

latent quest function Q109ArnoltTorch( ActorTag: name ) : bool
{	
	var actions : array< IActorLatentAction >;
	var moveTo : CActorLatentActionMoveTo;
	var playAnimation : CActorLatentActionPlayArnoltTorchAnimation;
	var arbitrator : CAIArbitrator;

		var Actor : CNewNPC;
		var torchID : SItemUniqueId;
		var Destination : CNode;	

		Actor = theGame.GetNPCByTag(ActorTag);
		Destination = theGame.GetNodeByTag( 'q109_arnolt_torch_litup' );
		
	moveTo = new CActorLatentActionMoveTo in Actor;
	moveTo.moveType = MT_Walk;
	moveTo.radius = 0.5;
	
	playAnimation = new CActorLatentActionPlayArnoltTorchAnimation in Actor;
	playAnimation.animationName = 'ex_torch_litup';
	playAnimation.effectName = 'torch_fire';
	playAnimation.itemName = 'Torch';
	actions.PushBack( moveTo );
	actions.PushBack( playAnimation );
	
	Actor.ClearRotationTarget();
	Actor.ActionExitWork();
	arbitrator = Actor.GetArbitrator();
	arbitrator.ClearGoal();
	
	if( !Destination.IsA( 'CEntity' ) )
	{
		Actor.SetErrorState( "Q109ArnoltTorch destination is not entity" );
	}
	
	arbitrator.AddGoalActing( actions, (CEntity)Destination );
	
	while( arbitrator.HasGoalsOfClass( 'CAIGoalActing' ) )
	{
		Sleep(0.1);
	}
	
/*	
		Actor.ActionRotateToAsync( Destination.GetWorldPosition() );
		torchID = Actor.GetInventory().GetItemId('Torch');
		Actor.GetInventory().MountItem(torchID, true);
		Actor.ActionPlaySlotAnimation("NPC_ANIM_SLOT", 'ex_torch_litup');
		Actor.GetInventory().PlayItemEffect(torchID, 'torch_fire' );*/
		
		return true;
}

// funkcja przeznaczona dla q109_assassination

latent quest function QDisplayScrollText( tag : name, textId : string )
{
	var entity_parachment : q002_parchment;
	var entity : CEntity;
	var turnOnComponent : CComponent;
	entity = theGame.GetEntityByTag( tag );
	entity_parachment = (q002_parchment) entity;
	turnOnComponent = entity.GetComponent( "q002_confession_interaction" );
	entity_parachment.SetTextId( textId );
	turnOnComponent.SetEnabled( true );
}

// ogolna funkcja pozwalajaca wyswietlic text na ekranie 

latent quest function DisplayText( player: CStoryScenePlayer, text : string ) : bool
{
	theHud.ShowScroll( text );
	return true;
}


//// Skrypt odpalajacy kamere na graczu ////

latent quest function qActivateCamera( cameraTag : name, show_GUI_hole : bool, activate : bool, blockPlayer : bool, delay : float, new_camera : bool ) : bool
{
	var camera : CCamera;
	var static_camera : CStaticCamera;

	
	if ( activate )
	{
		if( new_camera )
		{
			static_camera = (CStaticCamera)theGame.GetNodeByTag(cameraTag);
			static_camera.Run(true);
		}
		else
		{
			camera = (CCamera)theGame.GetNodeByTag(cameraTag);
			camera.SetActive(true);
		}
		
		thePlayer.SetManualControl( !blockPlayer, !blockPlayer );	
		
		if (show_GUI_hole) 
		{
			theHud.m_fx.HoleStart();
		}

		if ( delay > 0.0f)
		{
			Sleep ( delay );
			if (show_GUI_hole) 
			{
				theHud.m_fx.HoleStop();
			}
			if(blockPlayer)
			{
				thePlayer.SetManualControl(true, true);	
			}
			
			//camera.SetActive( false );
			
			theCamera.SetActive( true );	
			
		}
	}
	else
	{
		if (show_GUI_hole) 
		{
			theHud.m_fx.HoleStop();
		}
			thePlayer.SetManualControl(true, true);	

			
		if( new_camera )
		{
			static_camera = (CStaticCamera)theGame.GetNodeByTag(cameraTag);
			static_camera.Run(false);
		}
		else
		{
			theCamera.SetActive( true );
		}
	}
		
	return true;
}


// Funkcja latentna do sprawdzania czy postac jest w combat mode

latent quest function QPauseCheckCombatMode () : bool
{
	while( true )
	{
		if(thePlayer.IsInCombat())
		{
			return true;
		}
		Sleep(0.2f);
	}
}

// Funckcja ladujaca panele GUI - nie naduzywac pls
 
quest function QLoadGUIPanel( panelName : string, FlashInput : bool, GameInput : bool, TurnActivePauseOn : bool ) : bool
{
	// TODO: implement
	return true;
}

quest function QGuiOpenInventory()
{
	theHud.ShowInventory();
}

quest function QGuiOpenCharacterPanel()
{
	theHud.ShowCharacter( true );
}

quest function QGuiCloseCharacterPanel()
{
	theHud.ShowCharacter( false );
}



quest function QDespawnAllItems( actorTag : name )
{
	var actor : CActor;
	
	actor= theGame.GetActorByTag( actorTag );
	
	if ( actor )
	{
		actor.GetInventory().DespawnAllItems();
	}
}

quest function QSpawnAllItems( actorTag : name )
{
	var actor : CActor;
	
	actor= theGame.GetActorByTag( actorTag );
	
	if ( actor )
	{
		actor.GetInventory().SpawnAllItems();
	}
}

// przestawia kamere combatowoa na blizsza i niedynamiczna
quest function QSceneTurnOffCombatCamera( turnOff : bool )
{
	thePlayer.TurnOffCombatCamera( turnOff );
}

// SL // dodaje/usuwa ability o okreslonej nazwie do wszystkich postaci o danym tagu
quest function AddRemoveNPCAbility( npcTag : name, abilityName :name, remove : bool ) : bool
{
	var npc, target : CNewNPC;		
	var npcs : array <CNewNPC>;
	var i      : int;
	
	theGame.GetNPCsByTag(npcTag, npcs);
	if ( npcs.Size() == 0 ) 
	{
		Log("AddRemoveNPCAbility_questFunction: No npc's with tag " + npcTag + " found!!!");
		return false;
	}
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		npc = theGame.GetNPCByTag( npcTag );
		if(!remove)
		{
			npc.GetCharacterStats().AddAbility( StringToName(abilityName));
		}
		else
		{
			npc.GetCharacterStats().RemoveAbility( StringToName(abilityName));
		}
		npc.ResetStats();
		npc.SetHealth( npc.initialHealth, false, NULL );
	}
	 
	return true;
}

// SL // usuwa wplyw eliksiru o okreslonej nazwie z gracza
quest function QRemoveActiveElixirByName( abilityName :name ) : bool
{
			thePlayer.RemoveElixirByName(abilityName);

		return true;
}

// MK // Skrypt zmieniajacy styl walki postaci

quest function qChangeCombatStyle( tag : name, combatStyle : ECombatType, currentCombatStyle : ECombatType ) : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( tag );
	npc.SwapCombatType( currentCombatStyle, combatStyle, true);
	
	return true;
}

// MT // Skrypt wypuszczajacy losowo true/false

quest function QRandomizer() : bool
{
	if( RandF() >= 0.5 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

// SL // Przywraca zycie postaciom o danym tagu
quest function CureNPCWithTag( npcTag : name ) : bool
{

	var npc, target : CNewNPC;		
	var npcs : array <CNewNPC>;
	var i      : int;
	
	theGame.GetNPCsByTag(npcTag, npcs);
	if ( npcs.Size() == 0 ) 
	{
		Log("CureNPCWithTag_questFunction: No npc's with tag " + npcTag + " found!!!");
		return false;
	}
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		
		npc.ResetStats();
		npc.SetHealth( npc.initialHealth, false, NULL );
	}
	 
	return true;
}

// SL // Przywraca zycie graczowi
quest function CurePlayer() : bool
{
	thePlayer.SetHealthToMax();
	 
	return true;
}

// SL / behavior controler dla Geralta lezacego na plazy
quest latent function SQ106GeralLaysOnBeach() : bool
{
	thePlayer.AttachBehavior('sq106_laying');
	thePlayer.RaiseForceEvent('geralt_felt_down');
	
	thePlayer.WaitForBehaviorNodeDeactivation(' ', 5.f);
	
return true;
}

quest function QArjanIdleSit() : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag('Arjan');
	npc.GetArbitrator().ClearAllGoals();
	npc.GetArbitrator().AddGoalBehavior('arian_sitting');
	
return true;
}


quest function QOdrinIdleSit() : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag('q212r_odrin');
	npc.GetArbitrator().ClearAllGoals();
	npc.GetArbitrator().AddGoalBehavior('arian_sitting');
	
return true;
}


quest function QBehaviorGoal( npcsTag : name, behaviorName : name ) : bool
{
	var npcs : array< CNewNPC >;
	var i : int;
	theGame.GetNPCsByTag( npcsTag, npcs );
	for( i = 0; i<npcs.Size(); i+=1 )
	{
		npcs[i].GetArbitrator().AddGoalBehavior( behaviorName );
	}
}

// SL / ustala zwyciezce rundy fistfight'u o okreslonej dlugosci, True oznacza wygrana gracza
latent quest function FistFightRound( secondFighterTag : name, roundLength : float) : bool
{
    var secondNpc : CNewNPC;
    var maxHealth_1, maxHealth_2, currentHealth_1, currentHealth_2, percentHealth_1, percentHealth_2 : float;
    
    
    //poczekaj do zakonczenia rundy
	Sleep( roundLength );
	
	//pobierz stan hp'kow pierwszego fightera
	maxHealth_1 = thePlayer.initialHealth;
	currentHealth_1 = thePlayer.health;	
		
	percentHealth_1 = currentHealth_1 / maxHealth_1 * 100.0f; 
	
	//pobierz stan hp'kow drugiego fightera
	secondNpc  = theGame.GetNPCByTag( secondFighterTag );
	
	maxHealth_2 = secondNpc.initialHealth;
	currentHealth_2 = secondNpc.health;
	
	percentHealth_2 = currentHealth_2 / maxHealth_2 * 100.0f; 
	
	if(percentHealth_1 >= percentHealth_2)
	{
		Log("PLAYER won");
	}
	
	//zwroc true jesli wygral pierwszy, false jesli wygral drugi
    return (percentHealth_1 >= percentHealth_2);
		
}

// wlacza stan combat na graczu
quest function QChangePlayerStateToCombat() : bool
{
	thePlayer.ChangePlayerState(PS_CombatSteel);
	return true;
}

// wlacza stan na graczu
quest function QChangePlayerState( stateNew : EPlayerState ) : bool
{
	thePlayer.ChangePlayerState(stateNew);
	return true;
}

// SL / funkcja sluzaca do resetowania faktu o danym ID (ustawiania jego wartosci na 0 )
quest function ResetFact( factID : name ) :
 bool
{
	var sum : int;
	
	sum = FactsQuerySum(factID);
	FactsAdd( factID , -sum);
	
	return true;
}

// god mode
quest function QGodMode( on : bool ) : bool
{
	GodMode();
	return true;
}

//Funkcja do obslugi bram
quest function QSetGateState (gateTag: name, on : bool, force : bool ) : bool
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

//Funkcja sprawdzajaca  czy pierwsza postac ma wiecej HP niz druga
quest function QCheckHigherHealthLevel( firstCharacterTag : name,secondCharacterTag : name) : bool
{
     var firstNpc : CNewNPC;
     var secondNpc : CNewNPC;
     var firstNpcCurrentHealth : float;
     var secondNpcCurrentHealth : float;
     
     if( firstCharacterTag != 'PLAYER' )
     {
		firstNpc = theGame.GetNPCByTag( firstCharacterTag );
		
		firstNpcCurrentHealth = firstNpc.health;
    
	 }
	  if( secondCharacterTag != 'PLAYER' )
     {
		secondNpc = theGame.GetNPCByTag( secondCharacterTag );
		
		secondNpcCurrentHealth = secondNpc.health;
    
	 }
	 if ( firstCharacterTag = 'PLAYER' )
	 {
		firstNpcCurrentHealth = thePlayer.health;
		
	 }
	  if ( secondCharacterTag = 'PLAYER' )
	 {
		secondNpcCurrentHealth = thePlayer.health;
		
	 }
	if (firstNpcCurrentHealth >= secondNpcCurrentHealth)
	{
     return true;
    }
    else
    {
    return false;
    }   
}

// pokazuje akt info
quest function QShowActInfo( actText : string ) : bool
{
	theHud.m_messages.ShowActText( actText );
	return true;
}

// MT// Funkcja do wprowadzania gracza w aim mode
quest function SQ102_EnterAimMode()
{
	var previousState : EPlayerState;
	
	theCamera.ResetRotation( false, true, true );
	thePlayer.GetInventory().AddItem( 'Rusty Balanced Dagger', 1 );
	thePlayer.SelectThrownItem( thePlayer.GetInventory().GetItemId( 'Rusty Balanced Dagger' ) );
	previousState = thePlayer.GetCurrentPlayerState();
	thePlayer.QEntryAiming( previousState );
}

quest function SQ102_ExitAimMode()
{
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Rusty Balanced Dagger' ), 1 );
	thePlayer.QExitAiming();
}

// pokazuje tekst na ekranie
quest function QShowInfo( text : string ) : bool
{
	theHud.m_messages.ShowInformationText( text );
	return true;
}

// pokazuje tekst na ekranie
quest latent function QShowWarning( text : string ) : bool
{
	theGame.FadeOut();
	theHud.m_messages.ShowInformationText( text );
	Sleep(20);
	theHud.m_messages.HideInformationText();
	theGame.FadeIn();
	return true;
}

// wyciemnienie ekranu
quest function QFadeOut() : bool
{
	theGame.FadeOutAsync();
	return true;
}

// rozjasnienie ekranu
quest function QFadeIn() : bool
{
	theGame.FadeInAsync();
	return true;
}

// forceowe wywalanie bs
quest function QForceRemoveBlackscreen() : bool
{
	theGame.FadeInAsync( 0.f );
	return true;
}

//pokazuje end panel
quest function QGDCEndPanel(player: CStoryScenePlayer) : bool
{
	//thePlayer.SetHealth( 0, true, thePlayer );
	theSound.MuteAllSounds();
	theSound.SilenceMusic();
	theHud.m_fx.W2LogoStart( true );
	return true;
}

// MT - wlaczanie/wylaczanie chodzenia po navmeshu
quest function QSwitchPathEngineWalking( enable : bool ) : bool
{
	thePlayer.EnablePathEngineAgent( enable );
	
	return true;
}


quest function QSetNpcHealthLevel( HpValue : float, CharacterTag : name ) : bool
{
	var Npc : CNewNPC;
	
	Npc = theGame.GetNPCByTag( CharacterTag );
	Npc.SetHealth( HpValue, true, NULL );
	
	return true;
}

quest latent function QRotateNPCToTarget( npcTag, targetTag : name, duration : float, exitWorkMode : EExitWorkMode ) : bool
{
	var target : CNode;
	var npc : CNewNPC;
	
	target = theGame.GetNodeByTag( targetTag );
	npc = theGame.GetNPCByTag( npcTag );
	
	npc.GetArbitrator().ClearAllGoals();
	npc.ClearRotationTarget();
	npc.ExitWork(exitWorkMode);
	npc.RotateTo( target.GetWorldPosition(), duration );
	//npc.RotateToNode(target, duration);
	//npc.ActionRotateTo( target.GetWorldPosition());
	
	return true;
}

quest latent function QRotateNPCToTargetContinuous( npcTag, targetTag : name, duration : float, exitWorkMode : EExitWorkMode ) : bool
{
	var target : CNode;
	var npc : CNewNPC;
	
	target = theGame.GetNodeByTag( targetTag );
	npc = theGame.GetNPCByTag( npcTag );
	
	npc.GetArbitrator().ClearAllGoals();
	npc.ExitWork(exitWorkMode);
	npc.SetRotationTargetWithTimeout( target, false, duration + 1 );
	Sleep( duration );
	npc.ClearRotationTargetWithTimeout();

	
	return true;
}

quest latent function QClearRotation( npcTag: name) : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );
	
	npc.ClearRotationTargetWithTimeout();
	
	return true;
}
//L.Sz // Removes fact from facts DB
quest function QRemoveFact( player: CStoryScenePlayer, factId : string ) : bool
{
	// Checks if the specified fact is defined in the DB.
	if( FactsDoesExist( factId ) )
	{
		// Removes a single fact from the facts db.
		FactsRemove( factId );
	}
	
	return true;
}

//Start look at node
quest function QStartLookAt (actorTag : name,targetTag : name, duration : float, enable : bool): bool 
{
var actor : CActor;
var target : CNode;

actor = theGame.GetActorByTag(actorTag);
target = theGame.GetNodeByTag(targetTag);
	if (enable)
	{
		actor.EnableDynamicLookAt(target, duration);
	}

	else
	{
		actor.DisableLookAt();
	}
	
	return true;

}

quest function QSetUnconciousNPC (npcTag : name ) : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag(npcTag);
	
	npc.Stun(true, NULL);
}


quest function QMinigameSetNpcWristWrestling( npcTag : name, hotSpotMinWidth : int, hotSpotMaxWidth : int, gameDifficulty : EAIMinigameDifficulty ) : bool
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );

	if ( npc )
	{
		return npc.SetWristWrestlingParams( hotSpotMinWidth, hotSpotMaxWidth, gameDifficulty );
	}
	else
	{
		return false;
	}
}

quest latent function Q207GetWeaponFromPlayer () : bool
{
	var inv 	   : CInventoryComponent;
	var i 	       : int;
	var container  : CEntity;
	var item_count : int;
	var player_inv : CInventoryComponent;
	var allItems   : array< SItemUniqueId >;
	var itemId	   : SItemUniqueId;

	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	player_inv = thePlayer.GetInventory();
	
	player_inv.GetAllItems( allItems );

	for ( i = 0; i < allItems.Size(); i += 1 )
	{	
		itemId = allItems[i];
		
		if( IsItemWeapon( player_inv.GetItemName(itemId) ) && player_inv.IsItemMounted( itemId ) && ( player_inv.GetItemCategory( itemId ) == 'silversword' || player_inv.GetItemCategory( itemId ) == 'steelsword' ) )
		{
			player_inv.UnmountItem( itemId, true );
		}
	}
	
	return true;
}

quest latent function Q207MountWeaponToPlayer () : bool
{
	var inv 	   : CInventoryComponent;
	var i 	       : int;
	var container  : CEntity;
	var item_count : int;
	var player_inv : CInventoryComponent;
	var allItems   : array< SItemUniqueId >;
	var itemId	   : SItemUniqueId;

	inv = (CInventoryComponent)container.GetComponentByClassName( 'CInventoryComponent' );
	player_inv = thePlayer.GetInventory();
	
	player_inv.GetAllItems( allItems );
	
	for ( i = 0; i < allItems.Size(); i += 1 )
	{
		itemId = allItems[i];
		
		if( IsItemWeapon( player_inv.GetItemName(itemId) ) && player_inv.GetItemCategory( itemId ) == 'steelsword' )
		{
			player_inv.MountItem( itemId );
		}
	}

	return true;
}

//Force critical effect on NPC

quest function QForceCriticalEffectOnNPC (NPCTag: name, effectType: ECriticalEffectType, damageMin : float, damageMax : float, durationMin : float, durationMax : float) : bool
{
var npc : CNewNPC;
var effectParams : W2CriticalEffectParams = W2CriticalEffectParams(damageMin, damageMax, durationMin, durationMax);
var npcs : array <CNewNPC>;
var i      : int;

	
	theGame.GetNPCsByTag(NPCTag, npcs);
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		npc.ForceCriticalEffect(effectType, effectParams);
	}
	return true;
}
quest latent function QTrebuchetBallHit( ballTag : name, ball_appearance : string ) : bool
{
	var ball :  CTrebuchetBall;
	
	ball = (CTrebuchetBall) theGame.GetEntityByTag( ballTag );
	
	ball.RaiseEvent( 'start' );
	ball.ApplyAppearance(ball_appearance);
	
	return true;
}


quest latent function QPlayerHolsterWeapon (latentHolster : bool) : bool
{

	if(latentHolster) {
		thePlayer.HolsterWeaponLatent(thePlayer.GetCurrentWeapon(CH_Right));
		thePlayer.HolsterWeaponLatent(thePlayer.GetCurrentWeapon(CH_Left));
		thePlayer.ChangePlayerState(PS_Exploration);
		
	} else {
		thePlayer.HolsterWeaponInstant(thePlayer.GetCurrentWeapon(CH_Right));
		thePlayer.HolsterWeaponInstant(thePlayer.GetCurrentWeapon(CH_Left));
		thePlayer.ChangePlayerState(PS_Exploration);
	}
	
	
	return true;
}

quest function QSetAutoMountWithBlackScreen( enable : bool )
{
	thePlayer.SetAutoMountWithBlackScreen( enable );
}


latent quest function QShowGuiText(player: CStoryScenePlayer, stringName : string) : bool
{
	theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( stringName)  );
	// Sleep(2.0f);

	return true;
}

latent quest function QOpenTrapDoor() : bool
{
	var trapdoor : CEntity;
	var exploration : CEntity;
	var exploration_component : CComponent;
	
	
	trapdoor = theGame.GetEntityByTag( 'q109_trapdoor_garden' );
	trapdoor.RaiseEvent( 'open' );
	exploration = theGame.GetEntityByTag('q002_trap_door_expl');
	exploration_component = trapdoor.GetComponent( "q002_trap_door_expl" );

	return true;
}

latent quest function QTriggerMedallion() : bool
{
	thePlayer.TriggerMedallion();
}
//Przenioslem odpalanie funkcji do bloczka scripted actions - L.SZ.
/*latent quest function QMageTeleport( mageTag, placeTag : name )
{
	var 	npc 						: CNewNPC = theGame.GetNPCByTag( mageTag );
	
	var 	appearEffectTemplate 		: CEntityTemplate; 
	var	 	disappearEffectTemplate 	: CEntityTemplate; 
	var 	disappearanceFX 			: name;
	var 	disappearanceDuration		: float;
	
	var 	appearanceFX 				: name;
	var 	appearanceDuration 			: float;

	var		teleportPos					: Vector;
	var		teleportRot					: EulerAngles;
	var		wasBlockingHit				: bool;
	
	disappearEffectTemplate= (CEntityTemplate)LoadResource( "fx\mage_teleport_pre" );
	appearEffectTemplate = (CEntityTemplate)LoadResource( "fx\mage_teleport_post" );
	
	teleportPos = theGame.GetNodeByTag( placeTag ).GetWorldPosition();
	teleportRot = theGame.GetNodeByTag( placeTag ).GetWorldRotation();
	
	// disable AI params for the teleport time being
	npc.ActionCancelAll();
	wasBlockingHit = npc.IsBlockingHit();
	
	npc.SetBlockingHit( true, 30 );

	// make the NPC disappear
	
	npc.RaiseForceEvent ('Teleport');
	Sleep(0.7);
	npc.PlayEffect( disappearanceFX );
	Sleep(0.3);
	//npc.WaitForBehaviorNodeDeactivation('TeleportEnd');
	theGame.CreateEntity(disappearEffectTemplate, npc.GetWorldPosition(), npc.GetWorldRotation());
	Sleep( disappearanceDuration );

	// teleport
	theGame.CreateEntity(appearEffectTemplate, teleportPos, npc.GetWorldRotation());
	npc.TeleportWithRotation( teleportPos, teleportRot );
	
	// make the NPC appear
	npc.PlayEffect( appearanceFX );
	Sleep( appearanceDuration );
	
	// restore attack state
	npc.SetBlockingHit( wasBlockingHit );
	
}*/


quest function QSetUnlimitedMageShield( mageTag : name,  enable : bool )
{
	var npc	: CNewNPC = theGame.GetNPCByTag( mageTag );

	if( enable )
	{
		npc.unlimitedMagicShield =  true;
	} 
	else
	{
		npc.unlimitedMagicShield =  false;
	}
}					

quest function QEnableHUD( enable : bool )
{
	if( !enable )
	{
		theHud.m_fx.NoHudStart();
	}
	else
	{
		theHud.m_fx.NoHudStop();
	}
	
	thePlayer.SetCanUseHud( enable );
	LogChannel( 'GUI', "QEnableHUD: " + enable );
}

quest function QRagdollDeath( targetTag : name )
{
	var actors : array <CActor>;
	var i      : int;
	var actor : CActor;
	var deathData : SActorDeathData;
	deathData.silent = true;
	
	theGame.GetActorsByTag(targetTag, actors);
	
	for (i = 0; i < actors.Size(); i += 1 )
	{	
		actor = actors[i];
		
		actor.ClearImmortality();
		actor.SetRagdoll(true);
		actor.Kill(false,NULL,deathData);		
	}
}


latent quest function QWalkWithPlayerAndTalk( npcTag : name, distanceToTalk : float)
	{
		var distToPlayer 			: float;
		var player       			: CPlayer;
		var currPos      			: Vector;
		var npc						: CNewNPC;
		var NPCString				: string;
		
		while ( true )
		{
			npc = theGame.GetNPCByTag( npcTag );
			currPos      = npc.GetWorldPosition();
			distToPlayer = VecDistance( thePlayer.GetWorldPosition(), currPos );
				
			// Wait for player
			if ( distToPlayer > distanceToTalk )
			{
				NPCString = npcTag + "_waiting" ;
				if( FactsQuerySum( NPCString ) == 0 || FactsDoesExist ( NPCString ) == false)
				{
					FactsAdd( NPCString , 1);
				}
			}
				
			// Move to destination
			if ( distToPlayer <= distanceToTalk )
			{
				NPCString = npcTag + "_waiting" ;
				if( FactsQuerySum( NPCString ) == 1)
				{
					FactsAdd( NPCString , -1);
				}
			}
			Sleep(1.0f);
		}
	}
	
//Funckja odpalajaca i wylaczajaca audience

quest function QAudience( AudienceTag : name, Enable : bool )
{
	var audience : CAudience;
	
	audience = (CAudience)theGame.GetEntityByTag( AudienceTag );
	
	if(Enable)
	{
		audience.StartAudience();
	}
	else
	{
		audience.StopAudience();
	}
}	

//MT : function for enabling/disabling destruction system component

quest function QSetTakesDamage( objectTag : name, enable : bool )
{
	var object : CEntity;
	var component : CDestructionSystemComponent;
	
	object = theGame.GetEntityByTag( objectTag );
	
	if( !object )
	{
		Log( "QSetTakesDamage ERROR : target object not found " );
	}
	
	component = (CDestructionSystemComponent) object.GetComponentByClassName( 'CDestructionSystemComponent' );
	
	if( !component )
	{
		Log( "QSetTakesDamage ERROR : No CDestructionSystemComponent in entity " + object );
	}
	
	component.SetTakesDamage( enable );
}

// Activates or disactivates fistfight area
quest function QFistfightAreaEnable( fistfightAreaTag : name, enabled : bool )
{
	var nodes : array< CNode >;
	var ffArea : W2FistfightArea;
	var i : int;
	theGame.GetNodesByTag( fistfightAreaTag, nodes );
	for( i=0; i<nodes.Size(); i+=1 )
	{
		ffArea = (W2FistfightArea)nodes[i];
		if( ffArea )
		{
			ffArea.SetAreaActive( enabled );
		}
	}
}

// MT: Function for enabling/disabling static camera
quest latent function QActivateStaticCamera( cameraTag: name, runAndWait, canPlayerMove: bool, optional enable, startHoleFx, disableHud: bool )
{
	var camera : CStaticCamera;

	camera = (CStaticCamera)theGame.GetNodeByTag( cameraTag );
	
	if ( camera )
	{
		thePlayer.SetManualControl(canPlayerMove, canPlayerMove);
		
		if( runAndWait )
		{
			if( startHoleFx )
			{
				theHud.m_fx.HoleStart();
			}
			if( disableHud )
			{	
				thePlayer.SetCanUseHud( false );
				theHud.m_fx.NoHudStart();
			}
			
			////
			camera.RunAndWait();
			////
			
			if( !canPlayerMove )
			{
				thePlayer.SetManualControl(true, true);
			}
			if( startHoleFx )
			{
				theHud.m_fx.HoleStop();
			}
			if( disableHud )
			{
				thePlayer.SetCanUseHud( true );
				theHud.m_fx.NoHudStop();
			}
		}
		else
		{
			if( startHoleFx )
			{
				theHud.m_fx.HoleStart();
			}
			else
			{
				theHud.m_fx.HoleStop();
			}
			if( disableHud )
			{	
				thePlayer.SetCanUseHud( false );
				theHud.m_fx.NoHudStart();
			}
			else
			{
				thePlayer.SetCanUseHud( true );
				theHud.m_fx.NoHudStop();
			}
			////
			camera.Run( enable );
			////
		}
	}
	else
	{
		Log( "ERROR in QActivateStaticCamera : Camera with tag " + cameraTag + "not found." );
	}
}

// Funkcja do odpalania zniszczenia gniazda nekkera
quest latent function QDestroyNekkerNest( nestTag : name )
{
	var nest : CEntity;	
	
	nest = theGame.GetEntityByTag( nestTag );	

	thePlayer.RotateToNode( nest, 0.1f );
	//thePlayer.ActionPlaySlotAnimation( "HIT", 'steel_low_petard_throw' );
	
	if( thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_CombatSilver ) 
	{
		thePlayer.ChangePlayerState( PS_CombatSteel );
		Sleep( 2.f );
		
	}
	
	thePlayer.PlayerCombatAction(PCA_DeployTrap);
	Sleep( 5.f );
	
	nest.PlayEffect('explosion_fx');
	nest.ApplyAppearance("destroyed");
}

// Funkcja do odpalania zniszczenia gniazda trupojada w kopalniach
quest latent function QDestroyMinesNest( targetTag : name )
{
	var target : CNode;
	
	target = theGame.GetNodeByTag( targetTag );
	
	thePlayer.SetManualControl( false, true );
		
	if( thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_CombatSilver ) 
	{
		thePlayer.ChangePlayerState( PS_CombatSteel );
		thePlayer.SetManualControl(false, true);
		thePlayer.SetAllPlayerStatesBlocked( true );
		
		Sleep( 1.5f );
	}
	
	thePlayer.SetAllPlayerStatesBlocked( true );
	thePlayer.RotateToNode( target, 0.1f );
	thePlayer.PlayerCombatAction(PCA_DeployTrap);
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Grapeshot'), 1);
	thePlayer.SetAllPlayerStatesBlocked( false );
	thePlayer.SetManualControl( true, true );
	
	Sleep( 2.f);
	//thePlayer.ActionPlaySlotAnimation( "HIT", 'steel_low_petard_throw' );
}

quest latent function QSetIsAttackableByPlayer( actorsTag : name, enable : bool )
{
	var actors : array<CActor>;
	var i : int;
	
	theGame.GetActorsByTag( actorsTag, actors );
	
	for(i=0;i<actors.Size();i+=1)
	{
		actors[i].SetAttackableByPlayerPersistent( enable );
	}
}

// SL: Usuwa efekt kota z gracza
quest function QCatEffectToggle( enable : bool )
{
	if(!enable)
	{
		thePlayer.RemoveElixirByName('Cat');
	}
	
	thePlayer.EnableCatEffect( enable );
	
}

// Unmountowanie itemu na postaci

quest function QUnmountItemOnNPC( npcTag : name, item_category : name )
{
	var Npc : CNewNPC;
	
	Npc = theGame.GetNPCByTag( npcTag);
	Npc.GetInventory().UnmountItem( Npc.GetInventory().GetItemByCategory( item_category ) );
}

quest function QSetCommunitySpawnRadius( spawnRadius : float, despawnRadius : float ) : bool
{
	SetCommunityRadius( spawnRadius, despawnRadius );
}

quest function ReturnQuickSlotItemsToInventory()
{
/*
	var slotItems : array< SItemUniqueId > = thePlayer.GetItemsInQuickSlots();
	var i, itemQuant : int;
	var itemName, lastItem : name;
	var res : bool;
	
	for( i=0; i< slotItems.Size(); i+=1 )
	{
		itemName = thePlayer.GetInventory().GetItemName( slotItems[i] );
		if( itemName == lastItem )
		{
			itemQuant = 0;
			lastItem = itemName;
		}	
		else
		{
			itemQuant = thePlayer.GetInventory().GetItemQuantity( slotItems[i] );
			lastItem = itemName;
		}	
		thePlayer.GetInventory().RemoveItem( slotItems[i], itemQuant );
		thePlayer.GetInventory().AddItem( itemName, itemQuant, false );
	}
*/
}

quest function GSaveQuickSlotItems()
{
	thePlayer.SavePlayerSlotItemsNames();
}

quest function GRestoreQuickSlotItems( equipToQuickSlot : bool )
{
	thePlayer.RestorePlayerSlotItemsNames( equipToQuickSlot );
}
// Funckja odpalajaca manager strzal

quest function QEnableArrowsManager( tag : name, enable : bool )
{
	var entity : q208_ArrowsManager;
	
	entity = (q208_ArrowsManager) theGame.GetEntityByTag( tag );
	
	if ( enable )
	{
		entity.StartShooting();
	}
	else
	{
		entity.Idle();
	}
}

// Sprawdzenie czy podnoszenie NPCa sie skonczylo
latent quest function QWaitForPlayerCarryJoined()
{
	while( thePlayer.OnCheckPlayerCarryJoined() == false )
	{
		Sleep(0.5);
	}
}

//Skrypt tworzacy kule ognia - nie powinien byc uzywany w zadnej innej sytuacji

quest latent function qDraugonBall( targetTag : name, template : CEntityTemplate )
{
	var targets : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag( targetTag, targets);
	
	for(i=0;i<targets.Size();i+=1)
	{
		theGame.CreateEntity(template, targets[i].GetWorldPosition());
	}
}

//Manager do kul przy Draugu

quest function QEnableBallsManager( tag : name, enable : bool )
{
	var entity : q208_BallsManager;
	
	entity = (q208_BallsManager) theGame.GetEntityByTag( tag );
	
	if ( enable )
	{
		entity.StartShooting();
	}
	else
	{
		entity.Idle();
	}
}

//Function for blowing up Sheala
quest latent function QShealaExplodes( targetTag : name, explosionTemplate : CEntityTemplate )
{
	var target : CNode;
	var rot : EulerAngles;
	var pos : Vector;

	target = theGame.GetNodeByTag( targetTag );
	rot = target.GetWorldRotation();
	pos = target.GetWorldPosition();
	pos.Z += 2.f;
	theGame.CreateEntity( explosionTemplate, pos, target.GetWorldRotation() );
	Sleep(0.15);
}

quest latent function QShealaEscapes( targetTag : name, teleportTemplate : CEntityTemplate )
{
	var 	target 						: CNode = theGame.GetNodeByTag( targetTag );
	
	theGame.CreateEntity(teleportTemplate, target.GetWorldPosition(), target.GetWorldRotation());
	theGame.GetEntityByTag('Sheala').PlayEffect('mage_disappear_fx');
	
	Sleep( 0.5f );
}

latent quest function QPlayVideo( videoName : string, optional keepMusic : bool )
{
	theHud.PlayVideoEx( videoName, false, keepMusic );
}

latent quest function QTomsinTestDoNotUseIt( tag : name, dupcia : bool )
{
	var npc : CNewNPC = theGame.GetNPCByTag( tag );
	var itemId : SItemUniqueId;
	
	itemId = npc.GetInventory().GetItemByCategory( 'opponent_weapon', false );
	
	if ( dupcia )
	{
		npc.DrawWeaponLatent( itemId );
	}
	else
	{
		npc.HolsterWeaponLatent( itemId );
	}
}

latent quest function QModifyPriceMultiplicator ( NPCTag: name, Multiplicator: float )
{
	var actorNPC : CNewNPC;	
	
	actorNPC = theGame.GetNPCByTag(NPCTag);	
	actorNPC.SetPriceMult( Multiplicator );
	
}
quest function QActivateGameCamera()
{
	theCamera.SetActive(true);
}

quest function QSetUseMageTeleport(npcTag: name, enable : bool) : bool
{

	var npc, target : CNewNPC;		
	var npcs : array <CNewNPC>;
	var i      : int;
	
	theGame.GetNPCsByTag(npcTag, npcs);
	if ( npcs.Size() == 0 ) 
	{
		Log("CureNPCWithTag_questFunction: No npc's with tag " + npcTag + " found!!!");
		return false;
	}
	
	for (i = 0; i < npcs.Size(); i += 1 )
	{	
		npc = npcs[i];
		
		npc.SetUseMageTeleport(enable);
	}
	return true;
}

quest latent function QWaitForPlayerState( playerSate : EPlayerState )
{
	while( thePlayer.GetCurrentPlayerState() != playerSate )
	{
		Sleep(0.1);
	}
}

quest latent function QWaitForPlayerStateDifferent( playerSate : EPlayerState )
{
	while( thePlayer.GetCurrentPlayerState() == playerSate )
	{
		Sleep(0.1);
	}
}
latent quest function QDressFakeGeralt()
{
	var allItems : array< SItemUniqueId >;
	var i : int;
	var actor : CNewNPC;
	var itemName : name;
	
	actor = theGame.GetNPCByTag('fake_geralt');
	
	actor.SetAppearance('default');
	
	thePlayer.GetInventory().GetAllItems( allItems );
	
	for ( i = 0; i < allItems.Size(); i += 1 )
	{
		itemName = thePlayer.GetInventory().GetItemName( allItems[i] );
		actor.GetInventory().AddItem( thePlayer.GetInventory().GetItemName( allItems[i] ) , 1 );
		if ( thePlayer.GetInventory().IsItemMounted( allItems[i] ) && thePlayer.GetInventory().GetItemCategory( allItems[i] ) != 'steelsword' && thePlayer.GetInventory().GetItemCategory( allItems[i] ) != 'silversword' ) 
		{
			actor.GetInventory().MountItem( actor.GetInventory().GetItemId( itemName ), false );
		}
	}
}

quest function QActivateQuestLight( QLtag : name, enable : bool ) : bool
{
	var target : CEntity;
	
	target = (CQuestLights)theGame.GetNodeByTag( QLtag );
	((CQuestLights)target).Background_Activate();
	

}

quest function QEnableGuardingTrigger( triggerTag : name, enable : bool ) : bool
{
	var triggers : array<CNode>;
	var size, i : int;
	
	theGame.GetNodesByTag( triggerTag, triggers );
	size = triggers.Size();
	
	if( size == 0 )
	{
		Log( "function QEnableGuardingTrigger: Couldn't find CCommunityGuardingArea with tag '" + triggerTag + "'." );
		return false;
	}
	
	//for( i = size - 1; i >= 0; i -= 1 )
	for( i = 0; i < size; i += 1 )
	{
		((CCommunityGuardingArea)triggers[i]).SetEnabled( enable );
	}
	return true;
}

quest function QModifyTime( multiplier : float )
{

	theGame.SetTimeScale( theGame.GetTimeScale() * multiplier );

}

quest function QSetTimeScale( time : float )
{

	theGame.SetTimeScale( time );

}

quest function QMeditationExit()
{
	thePlayer.StateMeditationExit();
}

quest latent function QCheckIfInMeditation() : bool
{
	var currentState : EPlayerState;
	
	currentState = thePlayer.GetCurrentPlayerState();
	
	Log("currentState is " + currentState);
	
	while(currentState != PS_Meditation)
	{
		Log("currentState is " + currentState);
		Sleep (0.5f);
	}
	
	return true;
}

// If 'false' than player will not be able to Sleep (from meditation panel)
// It should be used in prolog, when the time change is blocked.
quest function QWaitTimeEnable( enable : bool )
{
	thePlayer.SetWaitTimeAllowed( enable );
}

quest function QLockAchievement( achName : name )
{
	theGame.LockAchievement( achName );
}

// Function changing state of sneak lights
quest function QChangeSneakLightsState( targetsTag : name, enable : bool )
{
	var i : int;
	var nodes : array<CNode>;
	var sneakLight : CSneakLights;

	theGame.GetNodesByTag(targetsTag, nodes );
	
	for( i=0;i<=nodes.Size();i+=1 )
	{
		nodes[i] = (CSneakLights) sneakLight;
		
		sneakLight.light_status = enable;
		sneakLight.SwitchLightState(enable);
	}
}

quest function Q213ShowWarningOnscreen()
{

	theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "Return at dusk" ) + "." );

}

latent quest function Q213EnterSabrinaMeditation()
{
	thePlayer.ChangePlayerState( PS_Meditation );
}
	
// L.Sz. Funkca do zamykania/otwierania kontenerow
quest function QSetContainerState (targetsTag : name, open : bool)
{
	var i : int;
	var nodes : array<CNode>;
	var container : CContainer;
	
	theGame.GetNodesByTag(targetsTag, nodes );
	
		for( i=0;i<=nodes.Size();i+=1 )
	{
		nodes[i] = (CContainer) container;
		
		container.LockEntryFunction(open);
	}
}

//J.R. funkcja do zmiany appearanca npcowi
quest function QSetAppearance (entityTag : name, appearance : name)
{
	var entity : CEntity;
	
	entity = theGame.GetEntityByTag(entityTag);
		
	entity.ApplyAppearance(appearance);
}

// funkcja sciagaja stan StateGuardReacting jesli gracz wciaz znajduje sie w triggerze guardowania

quest function QLeaveGuardingState(	awareAreaTag : name )
{
	var guard_area : CCommunityGuardingArea;
	var left_guard : CNewNPC;
	var right_guard : CNewNPC;
	var failedEventName : name;	

	guard_area = (CCommunityGuardingArea) theGame.GetNodeByTag( awareAreaTag );
	
	if( !guard_area )
	{
		Log( "Guarding Trigger tagged " +"'" +awareAreaTag +"'" +" was not found!" );
	}
	guard_area.SetEnabled( false );
}

// function for removing Geralt's silver sword in q001

quest function Q001RemoveSilverSword()
{
	var geraltSword : SItemUniqueId;

	geraltSword = thePlayer.GetInventory().GetItemByCategory('silversword', false );
	
	thePlayer.GetInventory().RemoveItem(geraltSword);
}

// function for playing credits
quest function QFadeOutInstant()
{
	theGame.FadeOutAsync(0.0f);
}
latent quest function QPlayEndCredits()
{
	thePlayer.SetGameEnded();
	theGame.FadeOutAsync(0.01f);
	
	theGame.UnlockAchievement( 'ACH_TO_BE_CONTINUED' );
	if ( thePlayer.GetInsaneAch() && theGame.GetDifficultyLevel() == 3 ) theGame.UnlockAchievement( 'ACH_INSANITY' );
	
	theHud.ShowEndCredits();
	theGame.FadeOutAsync(0.0);
}

quest function QDestroyEntity(entityTag : name)
{
	theGame.GetEntityByTag(entityTag).Destroy();
}

quest function QSetDrunk() : bool
{
	theCamera.SetCameraPermamentShake(CShakeState_Drunk, 1.0);
	thePlayer.PlayEffect('drunk_fx');
	thePlayer.AddTimer('DrunkTimerRemove', 30.0f, false);
	return true;
}

quest function QModifyCarryItemLeft( targetNpcName: string, itemName: name )
{
	theGame.GetNPCByName( targetNpcName ).ChangeCarryItemLeftValue( itemName );
}

quest function QModifyCarryItemRight( targetNpcName: string, itemName: name )
{
	theGame.GetNPCByName( targetNpcName ).ChangeCarryItemRightValue( itemName );
}

quest function QClearCarriedItems( targetNpcName: string )
{
	theGame.GetNPCByName( targetNpcName ).ChangeCarryItemLeftValue( 'Any' );
	theGame.GetNPCByName( targetNpcName ).ChangeCarryItemRightValue( 'Any' );
}

//SL : Kills NPC by dealing damage equal to actor health
quest function QKillAllNPCWithTagByDamage( targetTag : name ) : bool
{
	
	var actors : array <CActor>;
	var i      : int;
	var actor : CActor;
	
	theGame.GetActorsByTag(targetTag, actors);
	
	for (i = 0; i < actors.Size(); i += 1 )
	{	
		actor = actors[i];
		
		actor.ClearImmortality();
		actor.DecreaseHealth( actor.GetHealth() + 1 , true, NULL );
	}
	
	
	return true;
}

quest function QDrawSteelSword()
{
	var id : SItemUniqueId;
	var playerInv : CInventoryComponent;

	playerInv = thePlayer.GetInventory();
	id = playerInv.GetItemByCategory('steelsword');
	if ( id != GetInvalidUniqueId() )
	{
		thePlayer.SetLastCombatStyle(PCS_Steel);
		thePlayer.DrawWeaponInstant( id );
	}
	else
	{
		Log( "Failed to draw steel sword" );
	}
}

quest function QGeraltHasMoney( amount : int ) : bool
{
	if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Orens') ) < amount )
	{
		return false;
	} else
	{
		return true;
	}
}

quest function QHolsterSword()
{
	var id : SItemUniqueId;
	var id2 : SItemUniqueId;
	var playerInv : CInventoryComponent;

	playerInv = thePlayer.GetInventory();
	
	id = playerInv.GetItemByCategory('steelsword');
	id2 = playerInv.GetItemByCategory('silversword');
	if ( id != GetInvalidUniqueId() )
	{
		thePlayer.HolsterWeaponInstant(id);
		thePlayer.HolsterWeaponInstant(id2);
		//playerInv.MountItem(id, false);
		//playerInv.MountItem(id2, false);
	}
	else
	{
		Log( "Failed to holster steel sword" );
	}
}

quest function QChangeDifficulty()
{
	theGame.SetDifficultyLevel(1);
}

quest function QSetMappinAtEntityEnabled( entityTag : name, enable : bool )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MappinEnable(enable);
}

quest function QRemoveMappinFromEntity( entityTag : name )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MapPinClear();
}

quest function QAddMappinToEntity( entityTag : name, enabled : bool, pinType : EMapPinType, pinDisplayMode : EMapPinDisplayMode, pinDescription : string, pinName : string )
{
	var entity : CGameplayEntity;
	entity = ( CGameplayEntity ) theGame.GetEntityByTag( entityTag );
	entity.MapPinSet(enabled, pinName, pinDescription, pinType, pinDisplayMode);
}

quest function QShowTutorial( tutorialId : string, imageName : string, slowTime : bool ) : bool
{
	theHud.m_hud.ShowTutorial( tutorialId, imageName, slowTime );
	//theHud.ShowTutorialPanelOld( tutorialId, imageName );
}

latent quest function QKeepCombatMode()
{
	while(true)
	{
		thePlayer.KeepCombatMode();
		Sleep(0.1f);
	}
}

//funkcja questowa do despawnu postaci (Tym razem wszystkich bez wyjatkow)
quest function QForceDespawnAllNPCs( npcTag : name): bool
{
	var npcs : array< CNewNPC >;
	var i : int;

	theGame.GetNPCsByTag( npcTag, npcs );
	
	Log( "DespawnNPCS(): Found " + npcs.Size() + " NPCs with tag " + npcTag );

	for ( i = 0; i < npcs.Size(); i += 1 )
	{
		npcs[i].ForceDespawn();
	}
	return true;
}

quest function QSetQuestProgress( questIndex : int, value : int ) : bool
{
	FactsAdd( thePlayer.GetQuestTrackId( questIndex ) + "_progress", value , -1, -1 );
	theHud.m_hud.SetTrackQuestProgress( questIndex );
	return true;
}

quest function QSQ101MadhouseGhosts(npcTag: name) : bool
{
	var npcs : array< CNewNPC >;
	var i : int;

	theGame.GetNPCsByTag( npcTag, npcs );
	
	for ( i = 0; i < npcs.Size(); i += 1 )
	{
		npcs[i].EnablePathEngineAgent( false );
	}
	return true;
	
}

quest function QUnequipArmor( ) 
{
	var item_id : SItemUniqueId;
	var playerInv : CInventoryComponent;
	
	playerInv = thePlayer.GetInventory();
	
	item_id = playerInv.GetItemByCategory('armor');
	if ( playerInv.IsItemMounted(item_id)  )
	{
		playerInv.UnmountItem( item_id, true );
	}
	
	item_id = playerInv.GetItemByCategory('gloves');
	if ( playerInv.IsItemMounted(item_id)  )
	{
		playerInv.UnmountItem( item_id, true );
	}
	
}

//funkcja zabierajaca graczowi miecz z reki/slotu i pakujaca do containera

quest function QPlayerWeaponToContainer( containerTag : name) : bool
{
	var container : CContainer;
	var steelWeapon, silverWeapon : SItemUniqueId;
	
	steelWeapon = thePlayer.GetInventory().GetItemByCategory('steelsword', true, true);
	silverWeapon = thePlayer.GetInventory().GetItemByCategory('silversword', true, true);
	container = (CContainer)theGame.GetEntityByTag( containerTag );
	
	if(steelWeapon != GetInvalidUniqueId())
	{
		thePlayer.GetInventory().GiveItem( container.GetInventory(), steelWeapon, 1);
	}
	else if(silverWeapon != GetInvalidUniqueId())
	{
		thePlayer.GetInventory().GiveItem( container.GetInventory(), silverWeapon, 1);
	}
}

quest function QFistFightBet( won : bool) 
{
	var lastBribe 	: int;
	var inv 		: CInventoryComponent = thePlayer.GetInventory();

	lastBribe = thePlayer.GetLastBribe();
	
	if(won) 
	{
		Log(">QFistFightBet: Added " + lastBribe + " Orens to inv");
		inv.AddItem( 'Orens', lastBribe);
		thePlayer.SetLastBribe(0);
	}
	else
	{
		Log(">QFistFightBet: Removed " +lastBribe +" Orens from inv");
		inv.RemoveItem( inv.GetItemId( 'Orens' ), lastBribe );
		//thePlayer.GetInventory().AddItem( 'Orens', -thePlayer.GetLastBribe());
		thePlayer.SetLastBribe(0);
	}
	
}

quest function QClearPlayerBuild() 
{
	thePlayer.ClearBuild();
}

quest function QDisplayDebugText( text : string ) : bool
{
	LogChannel( 'DebugText', "Display Debug Text: " + text );
	theHud.m_messages.ShowInformationText( text );
	
	return true;
}

//Metoda zabierajaca graczowi ABL o podanej nazwie
quest function QRemoveAbilityFromPlayer(abilityName : name)
{
	if(thePlayer.GetCharacterStats().HasAbility(abilityName))
	{
		thePlayer.GetCharacterStats().RemoveAbility(abilityName);
	}
}

quest function QEnableMapPinTag( mapPinTag : name )
{
	theHud.EnableTrackedMapPinTag( mapPinTag );
}

quest function QDisableMapPinTag( mapPinTag : name )
{
	theHud.DisableTrackedMapPinTag( mapPinTag );
}

quest function QAnimatedToggleCarry( slaveTag : name) : bool
	{
	var slaves : array<CActor>;
	var slave : CNewNPC;
	
	slave = theGame.GetNPCByTag(slaveTag);
	
	if( thePlayer.GetCurrentPlayerState() == PS_PlayerCarry )
		{
		thePlayer.OnManualCarryStopRequest();
		}
		else if( thePlayer.IsAnExplorationState( thePlayer.GetCurrentPlayerState() ) && slave.OnManualCarry() )
		{
			if( !thePlayer.HostilesAround() )
			{
				slaves.PushBack( slave );
				thePlayer.StateInteractionMasterAnimated( slaves, CTM_Sit );
			}
		}	
		return true;
	}
quest function QEnableQuestMapPinTag( mapPinTag : name, questTag : name )
{
	theHud.EnableTrackedQuestMapPinTag( mapPinTag, questTag );
}

quest function QDisableQuestMapPinTag( mapPinTag : name, questTag : name  )
{
	theHud.DisableTrackedQuestMapPinTag( mapPinTag, questTag );
}

quest function QPlayEffectOnItem (actorTag: name, itemCategory: name, effectName : name )
{
	var item : SItemUniqueId;
	var actor : CActor;
	
	actor = theGame.GetActorByTag(actorTag);
		
		item = actor.GetInventory().GetItemByCategory(itemCategory, true, false);
		if(item == GetInvalidUniqueId())
		{
			Log("invalid item");
		}
		actor.GetInventory().PlayItemEffect(item,effectName);
}

quest function QStopEffectOnItem (actorTag: name, itemCategory: name, effectName : name )
{
	var item : SItemUniqueId;
	var actor : CActor;
	
	actor = theGame.GetActorByTag(actorTag);
		
		item = actor.GetInventory().GetItemByCategory(itemCategory, true, false);
		if(item == GetInvalidUniqueId())
		{
			Log("invalid item");
		}
		actor.GetInventory().StopItemEffect(item,effectName);
}

quest function QUnlockAchievement( achievementName : name )
{
	Log("UNLOCKING ACHIEVEMENT " + NameToString( achievementName ));
	theGame.UnlockAchievement(achievementName);
}

quest function Q212RocheDrawWeapon( targetsTag : name ) : bool
{
	var targets : array<CNewNPC>;
	var i : int;
	var weaponId : SItemUniqueId;
	
	theGame.GetNPCsByTag( targetsTag, targets );
	
	for( i = 0; i < targets.Size(); i +=1 )
	{
		targets[i].DrawWeaponInstant( targets[i].GetInventory().GetItemId('RocheCombatStanceSword'));
	}
	
	return true;
}	

latent quest function QIssueRequiredItemOnNPC( npcTag : name, LeftItemNameOrCategory : name, RightItemNameOrCategory : name ) : bool
{
	var npcs : array<CNewNPC>;
	var i,size : int;
	
	theGame.GetNPCsByTag( npcTag, npcs );
	
	size = npcs.Size();
	
	for( i = 0; i < size; i +=1 )
	{	
		npcs[i].SetRequiredItems( LeftItemNameOrCategory, RightItemNameOrCategory );
		npcs[i].ProcessRequiredItems();
	}
}

quest function QEnablePhysicalMovement( enable : bool)
{
	thePlayer.EnablePhysicalMovement( enable );
}

quest function QEndGame()
{
	theGame.ExitGame();
}

quest function QEnableCombatUpdate( npcTag : name, enable : bool )
{
	var npc 	: CNewNPC;
	var time	: float;
	
	npc = (CNewNPC)theGame.GetEntityByTag( npcTag );
	if ( npc )
	{
		if ( enable == false )
		{
			time = 10000000.0;
		}
		else
		{
			time = 0.0;
		}
		npc.GetArbitrator().PostponeCombatUpdate( time );
	}
}

// Draug drop

quest function QDropFromDraug()
{
	var loss : float = RandRangeF(1, 100);
	
	theGame.UnlockAchievement( 'ACH_DRAUG_DEAD' );
	
	thePlayer.GetInventory().AddItem('Death essence');
	thePlayer.GetInventory().AddItem('Draug essence');
	thePlayer.GetInventory().AddItem('Piece of Draug armor');
	thePlayer.GetInventory().AddItem('Mystic Armor Enhancement');
	thePlayer.GetInventory().AddItem('Draug Trophy');

	if( loss > 50) thePlayer.GetInventory().AddItem('Red meteorite ore');
	if( loss > 60) thePlayer.GetInventory().AddItem('Yellow meteorite ore');
	if( loss > 70) thePlayer.GetInventory().AddItem('Blue meteorite ore');
	if( loss > 80) thePlayer.GetInventory().AddItem('Rune of Fire');
}

// MT: Removing combat blockade function
quest function QUnblockCombat()
{
	thePlayer.SetCombatBlockTriggerActive( false, NULL );
	thePlayer.ChangePlayerState( PS_Exploration );
	thePlayer.SetCombatHotKeysBlocked( false );
	thePlayer.SetCombatBlocked(false);
	thePlayer.RemoveTimer('combatBlocked');
	thePlayer.RemoveTimer('KeepBlockOnIfInsideArea');
}

quest function QSetInterventionPosition()
{
	thePlayer.SetInterventionCSPosition();
}

quest function QResetPlayerAfterBribingPolice()
{
	thePlayer.SetManualControl( true, true );
	FactsRemove( "gameplay_catch_by_guard" );
	FactsRemove( "trigger_spotted_cutscene" );
	thePlayer.TeleportToBeforeInterventionPoint();
}

// KR: funkcja sluzaca do usuwania hudowych onscreenow (typu LOCKED, DOORS UNLOCKED etc.) ktore moga sie przebijac na cutscenie

quest function QClearOnScreenHUDMessages()
{
	theHud.m_messages.ShowInformationText( "" );
}

// KR: funkcja sluzaca do uodpalania tutorialu zaleznie od sterowania

quest function QIsUsingPad() : bool
{
	/*
	if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
	{
		theHud.m_hud.HideTutorial();
		theHud.m_hud.UnlockTutorial();
		theHud.m_hud.ShowTutorial("tut114", "", false, 5);
		//theHud.ShowTutorialPanelOld( "tut114", "" );
		//return false;
	}
	else
	{
		theHud.m_hud.HideTutorial();
		theHud.m_hud.UnlockTutorial();
		theHud.m_hud.ShowTutorial("tut14", "", false, 5);
		//theHud.ShowTutorialPanelOld( "tut14", "" );
	//	return false;
	}
	*/
}

latent quest function PlayIntroVideoLocalized( movieName : string )
{
	var audioLang : string;
	var subLang : string;
	
	//subLang = theGame.GetCurrentLocale();
	theGame.GetGameLanguageName( audioLang, subLang );
	
	if( subLang == "PL" )										//	1	PL								
		theHud.PlayVideoEx( movieName +"_pl", false );
	else if( subLang == "EN" )									//	2	EN
		theHud.PlayVideoEx( movieName +"_en", false );
	else if( subLang == "DE" )									//	3	DE								
		theHud.PlayVideoEx( movieName +"_de", false );
	else if( subLang == "IT" )									//	4	IT
		theHud.PlayVideoEx( movieName +"_it", false );
	else if( subLang == "FR" )									//	5	FR
		theHud.PlayVideoEx( movieName +"_fr", false );	
	else if( subLang == "CZ" )									//	6	CZ
		theHud.PlayVideoEx( movieName +"_cz", false );	
	else if( subLang == "ES" )									//	7	ES
		theHud.PlayVideoEx( movieName +"_es", false );	
	else if( subLang == "ZH" )									//	8	ZH
		theHud.PlayVideoEx( movieName +"_zh", false );	
	else if( subLang == "RU" )									//	9	RU
		theHud.PlayVideoEx( movieName +"_ru", false );	
	else if( subLang == "HU" )									//	10	HU
		theHud.PlayVideoEx( movieName +"_hu", false );	
	else if( subLang == "JP" )									//	11	JP
		theHud.PlayVideoEx( movieName +"_jp", false );
	else if( subLang == "TR" )									//	12	TR
		theHud.PlayVideoEx( movieName +"_tr", false );
	else if( subLang == "KR" )									//	13	KR
		theHud.PlayVideoEx( movieName +"_kr", false );	
	else if( subLang == "BR" )									//	14	BR
		theHud.PlayVideoEx( movieName +"_br", false );	
	
}

quest function QSetKillingGuardCauseDialog( npcTag : name, killingCauseDialog : bool )
{
	var npcs : array< CNewNPC >;
	var i, size : int;
	
	theGame.GetNPCsByTag( npcTag, npcs );
	
	size = npcs.Size();
	
	for( i=0; size>i; i+=1 )
	{
		npcs[i].killingCauseGuardDialog = killingCauseDialog;
		//Log( "==== guard " + npcs[i] +" killingCauseGuardDialog = " +npcs[i].killingCauseGuardDialog );
	}
}

//instant blackscreen function

latent quest function QSetInstantBlackscreen()
{
	theGame.FadeOut( 0.f );
}


//sterowanie moveable gracza i kamery

quest function IsMovable( player : bool, camera : bool )
{
	thePlayer.SetManualControl( player, camera );
}

// mountuje itemy z dlc i importu
quest function QSetDLCImportEquip()
{
	SetDLCImportEquip();
}

// pozwala zapamietac wyekwipowane itemy
quest function QPlayerSaveEquip()
{
	thePlayer.SaveEquip();
}

// pozwala odtworzyc zapamietane wyekwipowane itemy
quest function QPlayerRestoreEquip()
{
	thePlayer.RestoreEquip();
}

// funkcja zapamietujaca stan schowka na nastepny akt
quest function PlayerStorageSaveItems()
{
	//SetItemsInVirtualStorage();
	Log( "=======  temp - Saving Items from Storage ==========" );	
	
}

// funkcja umozliwia odtwarza stan schowka zapisanym w poprzednim akcie
quest function PlayerStorageRestoreItems()
{
	//GetItemsInVirtualStorage();
	Log( "=======  temp - Restoring Items to Storage ==========" );
	
}

//Odpalanie efektu krytycznego na graczu
quest function QSQ308GateGuardianDmg (effectType: ECriticalEffectType, playHit: bool, attackerTag: name, dmgMin : int, dmgMax : int, dealAdditionalDmg: bool, dmgFromHit : float )
{
	var atackerPosition : CEntity;
	var hitPosition : Vector;
	var playerHealth : float;
	var decreaseAmount : float;

	atackerPosition = (CEntity)theGame.GetNodeByTag(attackerTag);
	hitPosition = atackerPosition.GetWorldPosition();

	thePlayer.ForceCriticalEffect( effectType, W2CriticalEffectParams( dmgMin, dmgMax, 0, 0 ), true);
	if(playHit == true)
	{
		thePlayer.HitPosition( hitPosition, 'Attack', 0.0, true );
	}
	if(dealAdditionalDmg == true)
	{
		playerHealth = thePlayer.GetHealth();
		
		if( theGame.GetDifficultyLevel() == 0 || theGame.GetDifficultyLevel() == 5 )
		{
			decreaseAmount = (playerHealth * 0.5);
			thePlayer.DecreaseHealth(decreaseAmount, true, thePlayer);
		}
		
		else if( theGame.GetDifficultyLevel() == 1 )
		{
			decreaseAmount = (playerHealth * 0.65);
			thePlayer.DecreaseHealth(decreaseAmount, true, thePlayer);
		}

		else
		{
			decreaseAmount = (playerHealth * 0.8);
			thePlayer.DecreaseHealth(decreaseAmount, true, thePlayer);
		}
	}
}

quest function QRagdollDeathFalse( targetTag : name )
{
	var actors : array <CActor>;
	var i      : int;
	var actor : CActor;
	var deathData : SActorDeathData;
	deathData.ragDollAfterDeath = false;
	
	theGame.GetActorsByTag(targetTag, actors);
	
	for (i = 0; i < actors.Size(); i += 1 )
	{	
		actor = actors[i];
		
		actor.noragdollDeath = true;
		actor.ClearImmortality();
		actor.Kill(false,NULL,deathData);		
	}
}	

//////////////////////////////// TUTORIAL STUFF ///////////////////////////////////////////////////////////////////////////////

//tutorial initialisation function
quest function TutorialEnabled()
{
	var fact_value : int;
	
	if ( theGame.tutorialenabled == true )
	{
		FactsAdd("tutorial_loaded", 1);
		theGame.TutorialEnabled(false);

	}	
	else
	{
		FactsAdd("tutorial_loaded", 0);
	}
	fact_value = FactsQuerySum( "tutorial_loaded" );
}


quest function TutorialHideOldTutorialPanel( hide : bool )
{
	theGame.HideOldTutorialPanels( hide );
}

quest function TutorialSetGui()
{
	var arguments : array<CFlashValueScript>;
	
	arguments.PushBack(FlashValueFromBoolean(true));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);
}

//allows application of a critical effect on player
quest function TutorialApplyCriticalEffectOnPlayer ( effectType : ECriticalEffectType, damageMin : int, damageMax : int, durationMin : int, durationMax : int )
{
	thePlayer.ForceCriticalEffect( effectType, W2CriticalEffectParams(damageMin, damageMax, durationMin, durationMax )); 
	//thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( 50, 70, 0, 0 )); 
}

//
quest function QShowNewTutorial( tutorialId : string, imageName : string )
{
	theGame.TutorialPanelOpenByPlayer( false );
	theGame.SetTutorialUseNew( false );
	theGame.SetTutorialId( tutorialId, imageName );
	thePlayer.ShowTutorialQuestPanel( false );

	//theSound.PlaySound( "gui/tutorial_jingles/task_begin" );
}

quest function QShowNewTutorialNew( imageName : string, 	firstField : string, 	firstIcon : string,	secondField : string, 	secondIcon : string,
															thirdField : string, 	thirdIcon : string, fourthField : string, 	fourthIcon : string )
{
	var tutIds : array< string >;
	var iconIds : array< string >;

	theGame.TutorialPanelOpenByPlayer( false );
	theGame.SetTutorialUseNew( true );	
	theGame.SetTutorialNewIdsNew( imageName, firstField, firstIcon, secondField, secondIcon, thirdField, thirdIcon, fourthField, fourthIcon );
	thePlayer.ShowTutorialQuestPanel( true );

	//theSound.PlaySound( "gui/tutorial_jingles/task_begin" );
}

quest function QShowTutorialTask( isDisplayed : bool, tutorialTaskId : string )
{
	theGame.SetTutorialTaskId( tutorialTaskId );
	theHud.m_hud.ShowTutorialTask( isDisplayed );
	theSound.PlaySound( "gui/tutorial_jingles/tutorial_hint" );
}

quest function TutorialTaskHide()
{
	theHud.m_hud.KillTutorialTask();
}

quest function QSetTutorialId(tutorialId : string, imageName : string )
{
	theGame.SetTutorialId( tutorialId, imageName );
}

quest function HideTutorial()
{
	//theGame.SetTimeScale( 1.0 );	
	theHud.Invoke( "HideTutorial" );
}	

quest function TutorialToggleGamePause( IsOn : bool )
{
	if( IsOn )
		theGame.SetActivePause( true );
	else	
		theGame.SetActivePause( false );
}

quest function TutorialIsTutorialEnabled() : bool
{
	if( theGame.tutorialenabled )
		return true;
	else
		return false;
}

quest function TutorialGetAllItems()
{
	theGame.TutorialGetItems();
}

quest function TutorialSetItemOnFinish()
{
	theGame.TutorialSetItems();
}

quest function TutorialTestBeforeNewGame( is : bool )
{
	theGame.SetNewGameAfterTutorial( is );
}

quest function TutorialRemoveStartingRecipes()
{
	var inv : CInventoryComponent = thePlayer.GetInventory();
		
	inv.RemoveItem( inv.GetItemId( 'Recipe Kiss' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Maribor Forest' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Petri Philter' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Cerbin Blath' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Cat' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Caelm' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Samum' ), 1 );
	inv.RemoveItem( inv.GetItemId( 'Recipe Marten' ), 1 );
}

quest function TutorialAddStartingRecipes()
{
	var inv : CInventoryComponent = thePlayer.GetInventory();
	
	inv.AddItem( 'Recipe Kiss', 1, false  );
	inv.AddItem( 'Recipe Maribor Forest', 1, false  );
	inv.AddItem( 'Recipe Petri Philter', 1, false  );
	inv.AddItem( 'Recipe Cerbin Blath', 1, false  );
	inv.AddItem( 'Recipe Cat', 1, false  );
	inv.AddItem( 'Recipe Samum', 1, false  );
	inv.AddItem( 'Recipe Marten', 1, false  );
	inv.AddItem( 'Recipe Caelm', 1, false  );
}

quest function TutorialMountItemsAtEnd()
{
	var itemId 		: SItemUniqueId;
	
	if( thePlayer.GetInventory().HasItem( 'Leather Jacket' ) )
	{
		itemId = thePlayer.GetInventory().GetItemId( 'Leather Jacket' );
		thePlayer.GetInventory().MountItem( itemId, false );
	}
	if( thePlayer.GetInventory().HasItem( 'Worn Pants' ) )
	{
		itemId = thePlayer.GetInventory().GetItemId( 'Worn Pants' );
		thePlayer.GetInventory().MountItem( itemId, false );
	}
	if( thePlayer.GetInventory().HasItem( 'Worn Leather Boots' ) )
	{
		itemId = thePlayer.GetInventory().GetItemId( 'Worn Leather Boots' );
		thePlayer.GetInventory().MountItem( itemId, false );
	}
	if( thePlayer.GetInventory().HasItem( 'Witcher Silver Sword' ) )
	{
		itemId = thePlayer.GetInventory().GetItemId( 'Witcher Silver Sword' );
		thePlayer.GetInventory().MountItem( itemId, false );
	}
	if( thePlayer.GetInventory().HasItem( 'Long Steel Sword' ) )
	{
		itemId = thePlayer.GetInventory().GetItemId( 'Long Steel Sword' );
		thePlayer.GetInventory().MountItem( itemId, false );
	}	
}

quest function TutorialForGamePad() : bool
{
	if( theGame.IsPadConnected() && theGame.IsUsingPad() )
		return true;
	else
		return false;
}

quest function TutorialTempSetTutorialEnabled( isEnabled : bool )
{
	theGame.TutorialEnabled( isEnabled );
}

quest function TutorialIsRestrictedToDawn( sleepToDawn : bool )
{
	theGame.TutorialSetSleepToDawn( sleepToDawn );
}

quest function QEnableTutorialStuff( isEnabled : bool )
{
	var arenaManager : CArenaManager;
	
	arenaManager = (CArenaManager)theGame.GetNodeByTag('arena_manager');
	
	thePlayer.EnableTutButton( isEnabled );
	if( !arenaManager )
	{
		theGame.TutorialEnabled( true );	// temp shit do testow
	}
}

quest function TutorialSetInventoryIfNoNewGame() : bool
{
	if( theGame.newGameAfterTutorial )
	{
		return false;
	}
	return true;
}

quest function TutorialMountWetBoots()
{
	if( thePlayer.GetInventory().HasItem( 'Soaked Wet Boots' ) )
		thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId( 'Soaked Wet Boots' ), false );
	else
		Log( "===== NO SOAKED WET BOOTS FOUND!!!! =======" );
}	

quest function TutorialRemoveTutorialItems()
{
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Tournament Notice' ), 1 );
	//thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Worn Squire Boots' ), 1 );
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Arena Invitation' ), 1 );
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Soaked Wet Boots' ), 1 );
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Recipe Healing Concoction' ), 1 );
	thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemByCategory('boots') );
	theGame.TutorialEnabled( false );
}

quest function TutorialSetDisabled()
{
	theGame.TutorialEnabled( false );
}

quest function TutorialSetInvTrashBlock( isBlocked :  bool )
{
	theGame.TutorialInventoryTrashIsBlocked( isBlocked );
}

quest function TutorialToggleHighlightEntity( entityTag : name, isHighlighted : bool )
{
	var entity : CEntity;
	
	entity = theGame.GetEntityByTag( entityTag );
	if( isHighlighted )
	{
		entity.PlayEffect( 'toturial_glow' );
		//entity.PlayEffect( 'medalion_detection_fx' );
	}	
	else
	{
		entity.StopEffect( 'toturial_glow' );
		//entity.StopEffect( 'medalion_detection_fx' );
	}	
}

quest function TutorialResetPlayerState()
{
	thePlayer.ChangePlayerState( PS_CombatSteel );
	thePlayer.ResetPlayerMovement();
}

quest function TutorialClearUsableItems()
{
	var inv : CInventoryComponent = thePlayer.GetInventory();
	var bomb : SItemUniqueId = inv.GetItemId( 'Samum' );
	var bomb_count : int = inv.GetItemQuantity( bomb );
	var trap : SItemUniqueId = inv.GetItemId( 'Freezing Trap' );
	var trap_count : int = inv.GetItemQuantity( trap );
	var dagger : SItemUniqueId = inv.GetItemId( 'Balanced Dagger' );
	var dagger_count : int = inv.GetItemQuantity( dagger );
	
	inv.RemoveItem( bomb, bomb_count );
	inv.RemoveItem( trap, trap_count );
	inv.RemoveItem( dagger, dagger_count );	
}

quest function QForceCombatPositionOnNPC( npcTag : name )
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetArbitrator().AddGoalIdleAfterCombat( 10.0f );
}

quest latent function TutorialForceSummoning( npcTag : name, timeout : float )
{
	var npc 	: CNewNPC;
	var res 	: bool;
	
	npc = theGame.GetNPCByTag( npcTag );
	npc.GetBehTreeMachine().Stop();
	npc.ActionPlaySlotAnimation( 'NPC_ANIM_SLOT', 'c_mage_teleport', 0.2f, 0.2f ); 
	//npc.RaiseForceEvent ( 'Teleport' );
	//res = npc.WaitForBehaviorNodeDeactivation ( 'TeleportEnded', timeout );
	npc.GetBehTreeMachine().Restart();
	//return res;
}

quest latent function QWaitForBehaviorDeactivationOnActor( npcTag : name, deactivation : name, timeout : float ) : bool
{
	var npc : CNewNPC;
	var res : bool;
	
	npc = theGame.GetNPCByTag( npcTag );
	res = npc.WaitForBehaviorNodeDeactivation( deactivation, timeout );
	
	return res;
}

quest function TutorialRestrictPlayerMovement( blockMovement : bool, blockCamera : bool )
{
	thePlayer.SetManualControl( blockMovement, blockCamera );
}

quest function TutorialGargoyleShakesAxii( creatureTag : name )
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( creatureTag );
	npc.CalmDown();
	
}

quest latent function QWaitForEventProcessedOnActor( npcTag : name, eventName : name, timeout : float ) : bool
{
	var npc : CNewNPC;
	var res : bool;
	
	npc = theGame.GetNPCByTag( npcTag );
	res = npc.WaitForEventProcessing( eventName, timeout );
	
	return res;
}

quest function TutorialReplacePotionWithQuestPotion()
{
	var inventory 	: CInventoryComponent		= thePlayer.GetInventory();
	var itemId 		: SItemUniqueId;
	var itemQty 		: int;
		
	if( inventory.HasItem( 'Argentia' ) )
	{
		itemId = inventory.GetItemId( 'Argentia' );
		itemQty = inventory.GetItemQuantity( itemId );
		inventory.RemoveItem( itemId, itemQty );
		inventory.AddItem( 'Healing Concoction', 1, false );
	}
}

quest latent function QDenyFastMenuSelection( deniedSelection : array< EFastMenuSelection >, deny : bool )
{
	var size, i : int;
	
	while( !theHud.m_hud.m_fastMenu )
	{
		Sleep( 0.01f );
	}
	
	size = deniedSelection.Size();
	for( i = 0; i < size; i += 1 )
	{
		if( deny )
		{
			if( !theHud.m_hud.m_fastMenu.deniedSelection.Contains( deniedSelection[i] ) )
				theHud.m_hud.m_fastMenu.deniedSelection.PushBack( deniedSelection[i] );
		}
		else
		{
			theHud.m_hud.m_fastMenu.deniedSelection.Remove( deniedSelection[i] );
		}
	}
}

quest function TutorialNPCBlockMovement( tag : name, isBlocked : bool )
{
	var npc : CNewNPC = theGame.GetNPCByTag( tag );
	
	if( isBlocked )
		npc.GetArbitrator().AddGoalImmobile();
	else
		npc.GetArbitrator().AddGoalIdle( true );
}

quest latent function TutorialFinish()
{
	theHud.EnableInput( true, true, true );
	//theGame.FadeOutAsync(1.0);
	theGame.FadeInAsync(1.0);
	theGame.TutorialDifficultyPrompt();
}

quest function TutorialBlockMeditationInput( drinkPotions : bool, restUntil : bool, characterPanel : bool, alchemyPanel : bool )
{
	theGame.TutorialSetBlockMeditationInput( drinkPotions, restUntil, characterPanel, alchemyPanel );
}

quest function TutorialResetAllInputBlocks()
{
	theGame.ClearIgnoredInput();
}

quest function TutorialInputBlockingAllSwitch( BlockInput : bool )
{
	Log( "*************************************************" );
	if( BlockInput )
		Log( "Input blocked from TutorialInputBlockingAllSwitch." );
	else
		Log( "Input unblocked from TutorialInputBlockingAllSwitch." );
	Log( "Whole input blocked" );
	//kamera
	theGame.IgnoreGameInput( 'GI_MouseDampX', BlockInput );				//camera X-axis mouse
	theGame.IgnoreGameInput( 'GI_MouseDampY', BlockInput );				//camera Y-axis mouse
	theGame.IgnoreGameInput( 'GI_AxisRightX', BlockInput );				//camera X-axis pad
	theGame.IgnoreGameInput( 'GI_AxisRightY', BlockInput );				//camera Y-axis pad	

	//sterowanie postacia
	theGame.IgnoreGameInput( 'GI_AxisLeftX', BlockInput );				//left/right movement
	theGame.IgnoreGameInput( 'GI_AxisLeftY', BlockInput );				//forward/backward movement
	theGame.IgnoreGameInput( 'GI_WalkSwitch', BlockInput );				//enable walking
	theGame.IgnoreGameInput( 'GI_WalkFlag', BlockInput );				//toggle walking/running
	
	//przygotowanie broni/znakow
	theGame.IgnoreGameInput( 'GI_Holster', BlockInput );				//holster weapon
	theGame.IgnoreGameInput( 'GI_Steel', BlockInput );					//draw steel sword
	theGame.IgnoreGameInput( 'GI_Silver', BlockInput );					//draw silver sword
	theGame.IgnoreGameInput( 'GI_Hotkey03', BlockInput );				//choose next sign
	theGame.IgnoreGameInput( 'GI_Hotkey04', BlockInput );				//choose next item
	theGame.IgnoreGameInput( 'GI_Hotkey05', BlockInput );				//choose aard
	theGame.IgnoreGameInput( 'GI_Hotkey06', BlockInput );				//choose yrden
	theGame.IgnoreGameInput( 'GI_Hotkey07', BlockInput );				//choose igni
	theGame.IgnoreGameInput( 'GI_Hotkey08', BlockInput );				//choose quen
	theGame.IgnoreGameInput( 'GI_Hotkey09', BlockInput );				//choose axii
	theGame.IgnoreGameInput( 'GI_FastMenu', BlockInput );				//open radial menu

	//walka
	theGame.IgnoreGameInput( 'GI_LockTarget', BlockInput );				//lock on current target
	theGame.IgnoreGameInput( 'GI_AttackFast', BlockInput );				//fast attack
	theGame.IgnoreGameInput( 'GI_AttackStrong', BlockInput );			//strong attack
	theGame.IgnoreGameInput( 'GI_Block', BlockInput );					//block incomming
	theGame.IgnoreGameInput( 'GI_Accept_Evade', BlockInput );			//dodge incomming / roll

	//uzywanie zdolnosci/itemow
	theGame.IgnoreGameInput( 'GI_UseAbility', BlockInput );				//use sign
	theGame.IgnoreGameInput( 'GI_UseItem', BlockInput );				//use item
	theGame.IgnoreGameInput( 'GI_Adrenaline', BlockInput );				//adrenaline attack
	theGame.IgnoreGameInput( 'GI_Medallion', BlockInput );				//use medallion
	//theGame.IgnoreGameInput( 'GI_CircleOfPower', BlockInput );			//special quest interaction
	theGame.IgnoreGameInput( 'GI_Cancel', BlockInput );					//delete item in inventory panel

	//panele informacyjne	
	theGame.IgnoreGameInput( 'GI_Inventory', BlockInput );				//open inventory panel
	theGame.IgnoreGameInput( 'GI_Character', BlockInput );				//open character panel
	theGame.IgnoreGameInput( 'GI_Nav', BlockInput );					//open map panel
	theGame.IgnoreGameInput( 'GI_Journal', BlockInput );				//open journal panel
	theGame.TutorialToggleCharacterBlock( BlockInput );
	theGame.TutorialToggleInventoryBlock( BlockInput );
	theGame.TutorialToggleMapBlock( BlockInput );
	theGame.TutorialToggleJournalBlock( BlockInput );

	//dodatkowe
	theGame.IgnoreGameInput( 'GI_F5', BlockInput );						//save game in quickslot
	theGame.IgnoreGameInput( 'GI_H', BlockInput );						//hide GUI
	
	Log( "*************************************************" );
	
	if( BlockInput == true )
	{
		thePlayer.ResetPlayerMovement();
	}
}

quest function TutorialInputBlockingSwitch( input : ETutorialInputBlocker, BlockInput : bool )
{
	Log( "*************************************************" );
	if( BlockInput )
		Log( "Input blocked from TutorialInputBlockingSwitch." );
	else
		Log( "Input unblocked from TutorialInputBlockingSwitch." );
		
	switch( input )
	{
		case TIB_Camera_Movement:
		{
			Log( "TIB_Camera_Movement" );
			theGame.IgnoreGameInput( 'GI_MouseDampX', BlockInput );				//camera X-axis mouse
			theGame.IgnoreGameInput( 'GI_MouseDampY', BlockInput );				//camera Y-axis mouse
			theGame.IgnoreGameInput( 'GI_AxisRightX', BlockInput );				//camera X-axis pad
			theGame.IgnoreGameInput( 'GI_AxisRightY', BlockInput );				//camera Y-axis pad				
			break;
		}
		case TIB_Movement_Walk:
		{
			Log( "TIB_Camera_Movement" );
			theGame.IgnoreGameInput( 'GI_AxisLeftX', BlockInput );				//left/right movement
			theGame.IgnoreGameInput( 'GI_AxisLeftY', BlockInput );				//forward/backward movement
			break;
		}
		case TIB_Movement_WalkSwitch:
		{
			Log( "TIB_Movement_WalkSwitch" );
			theGame.IgnoreGameInput( 'GI_WalkSwitch', BlockInput );				//enable walking
			break;
		}
		case TIB_Movement_ToggleWalkRun:
		{
			Log( "TIB_Movement_ToggleWalkRun" );
			theGame.IgnoreGameInput( 'GI_WalkFlag', BlockInput );				//toggle walking/running
			break;
		}
		case TIB_Equip_HolsterWeapon:
		{
			Log( "TIB_Equip_HolsterWeapon" );
			theGame.IgnoreGameInput( 'GI_Holster', BlockInput );				//holster weapon
			break;
		}
		case TIB_Equip_Steel:
		{
			Log( "TIB_Equip_Steel" );
			theGame.IgnoreGameInput( 'GI_Steel', BlockInput );					//draw steel sword
			break;
		}
		case TIB_Equip_Silver:
		{
			Log( "TIB_Equip_Silver" );
			theGame.IgnoreGameInput( 'GI_Silver', BlockInput );					//draw silver sword
			break;
		}
		case TIB_Equip_NextSign:
		{
			Log( "TIB_Equip_NextSign" );
			theGame.IgnoreGameInput( 'GI_Hotkey03', BlockInput );				//choose next sign
			break;
		}
		case TIB_Equip_NextItem:
		{
			Log( "TIB_Equip_NextItem" );
			theGame.IgnoreGameInput( 'GI_Hotkey04', BlockInput );				//choose next item
			break;
		}
		case TIB_Equip_Aard:
		{
			Log( "TIB_Equip_Aard" );
			theGame.IgnoreGameInput( 'GI_Hotkey05', BlockInput );				//choose aard
			break;
		}
		case TIB_Equip_Yrden:
		{
			Log( "TIB_Equip_Yrden" );
			theGame.IgnoreGameInput( 'GI_Hotkey06', BlockInput );				//choose yrden
			break;
		}
		case TIB_Equip_Igni:
		{
			Log( "TIB_Equip_Igni" );
			theGame.IgnoreGameInput( 'GI_Hotkey07', BlockInput );				//choose igni
			break;
		}
		case TIB_Equip_Quen:
		{
			Log( "TIB_Equip_Quen" );
			theGame.IgnoreGameInput( 'GI_Hotkey08', BlockInput );				//choose quen
			break;
		}
		case TIB_Equip_Axii:
		{
			Log( "TIB_Equip_Axii" );
			theGame.IgnoreGameInput( 'GI_Hotkey09', BlockInput );				//choose axii
			break;
		}
		case TIB_Use_FastMenu:
		{
			Log( "TIB_Use_FastMenu" );
			theGame.IgnoreGameInput( 'GI_FastMenu', BlockInput );				//open radial menu
			break;
		}
		case TIB_Use_Medallion:
		{
			Log( "TIB_Use_Medallion" );
			theGame.IgnoreGameInput( 'GI_Medallion', BlockInput );				//use medallion
			break;
		}
		case TIB_Combat_LockTarget:
		{
			Log( "TIB_Combat_LockTarget" );
			theGame.IgnoreGameInput( 'GI_LockTarget', BlockInput );				//lock on current target
			break;
		}
		case TIB_Combat_AttackFast:
		{
			Log( "TIB_Combat_AttackFast" );
			theGame.IgnoreGameInput( 'GI_AttackFast', BlockInput );				//fast attack
			break;
		}
		case TIB_Combat_AttackStrong:
		{
			Log( "TIB_Combat_AttackStrong" );
			theGame.IgnoreGameInput( 'GI_AttackStrong', BlockInput );			//strong attack
			break;
		}
		case TIB_Combat_BlockAttack:
		{
			Log( "TIB_Combat_BlockAttack" );
			theGame.IgnoreGameInput( 'GI_Block', BlockInput );					//block incomming
			break;
		}
		case TIB_Combat_EvadeAttack:
		{
			Log( "TIB_Combat_EvadeAttack" );
			theGame.IgnoreGameInput( 'GI_Accept_Evade', BlockInput );			//dodge incomming / roll
			break;
		}
		case TIB_Combat_UseSelectedSign:
		{
			Log( "TIB_Combat_UseSelectedSign" );
			theGame.IgnoreGameInput( 'GI_UseAbility', BlockInput );				//use sign
			break;
		}
		case TIB_Combat_UseSelectedItem:
		{
			Log( "TIB_Combat_UseSelectedItem" );
			theGame.IgnoreGameInput( 'GI_UseItem', BlockInput );				//use item
			break;
		}
		case TIB_Combat_AdrenalineAttack:
		{
			Log( "TIB_Combat_AdrenalineAttack" );
			theGame.IgnoreGameInput( 'GI_Adrenaline', BlockInput );				//adrenaline attack
			break;
		}
		case TIB_Panel_Inventory:
		{
			Log( "TIB_Panel_Inventory" );
			theGame.IgnoreGameInput( 'GI_Inventory', BlockInput );				//open inventory panel
			theGame.TutorialToggleInventoryBlock( BlockInput );
			break;
		}
		case TIB_Panel_Character:
		{
			Log( "TIB_Panel_Character" );
			theGame.IgnoreGameInput( 'GI_Character', BlockInput );				//open character panel
			theGame.TutorialToggleCharacterBlock( BlockInput );
			break;
		}
		case TIB_Panel_Map:
		{
			Log( "TIB_Panel_Map" );
			theGame.IgnoreGameInput( 'GI_Nav', BlockInput );					//open map panel
			theGame.TutorialToggleMapBlock( BlockInput );			
			break;
		}
		case TIB_Panel_Journal:
		{
			Log( "TIB_Panel_Journal" );
			theGame.IgnoreGameInput( 'GI_Journal', BlockInput );				//open journal panel
			theGame.TutorialToggleJournalBlock( BlockInput );
			break;
		}
		case TIB_Panel_DeleteInventoryItem:
		{
			Log( "TIB_Panel_DeleteInventoryItem" );
			theGame.IgnoreGameInput( 'GI_Cancel', BlockInput );					//delete item in inventory panel
			break;
		}
		case TIB_Special_QuestInteraction:
		{
			Log( "TIB_Special_QuestInteraction" );
			theGame.IgnoreGameInput( 'GI_CircleOfPower', BlockInput );			//special quest interaction
			break;
		}
		case TIB_Special_QuickSave:
		{
			Log( "TIB_Special_QuickSave" );
			theGame.IgnoreGameInput( 'GI_F5', BlockInput );						//save game in quickslot
			break;
		}
		case TIB_Special_HideGUI:
		{
			Log( "TIB_Special_HideGUI" );
			theGame.IgnoreGameInput( 'GI_H', BlockInput );						//hide GUI
			break;
		}
	}
	
	Log( "*************************************************" );
		
	if( input == TIB_Movement_Walk )
	{
		if( BlockInput == true )
		{
			thePlayer.ResetPlayerMovement();
		}	
	}	
}

exec function TestCheckSlots()
{
	var slotAr : array< SItemUniqueId >;
	var itemsAr : array< SItemUniqueId >;
	var i,j : int;
	var itemName : name;
	
	slotAr = thePlayer.GetItemsInQuickSlots();
	
	for( i=0; i<slotAr.Size(); i+=1 )
	{
		itemName = thePlayer.GetInventory().GetItemName( slotAr[i] );
		Log( "===================== In QuickSlots: " +itemName +" ==================" );
	}
	
	thePlayer.GetInventory().GetAllItems( itemsAr );
	
	for( j=0; j<itemsAr.Size(); j+=1 )
	{
		itemName = thePlayer.GetInventory().GetItemName( itemsAr[j] );
		Log( "===================== In Inventory: " +itemName +" ==================" );
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wylaczanie minimapy

quest function TutorialHideMinimap()
{
	var arguments : array<CFlashValueScript>;
	
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	arguments.PushBack(FlashValueFromBoolean(false));
	theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wylaczanie chatu community, gdy nie powinien byc kontynuowany
quest function QStopChatScene (npcTag: name )
{
	var npc: CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );
	npc.StopAllScenes();
}

quest function QArenaTeleportToStart()
{
	var teleportPoint : CNode;
	teleportPoint = theGame.GetNodeByTag('arena_safe_spot');
	thePlayer.TeleportWithRotation(teleportPoint.GetWorldPosition(), teleportPoint.GetWorldRotation());
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Play USMs with subtitles and texts

quest latent function GPlayMovieWithDescription( videoName : string, headlineText : string, optional afterTime : int )
{
	//optional textFadeIn, textFadeOut : float
	//var args : array< CFlashValueScript >;
	var arg : CFlashValueScript;
	
	arg = FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( headlineText ) ) );
	//args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( headlineText ) ) ) );
	//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( infoText ) ) );
	//args.PushBack( FlashValueFromFloat( textFadeIn ));
	//args.PushBack( FlashValueFromFloat( textFadeOut ));
	
	theHud.m_hud.HideTutorial();
	thePlayer.ResetPlayerMovement();
	//theHud.InvokeManyArgs( "USMSubtitles", args );
	
	if ( afterTime > 0 ) 
		{
			thePlayer.SetUSMTitle( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( headlineText ) ) ) );
			thePlayer.AddTimer( 'ShowUSMTitle', afterTime );
			theHud.PlayVideoEx( videoName, false, false, true  );
		}else
		{
			theHud.InvokeOneArg( "USMSubtitles", arg );
			theHud.PlayVideoEx( videoName, false);
		}
	
	theHud.Invoke( "HideUSMSubtitles" );
}

quest function QResetPlayer()
{
	thePlayer.SetAllPlayerStatesBlocked( false );
	thePlayer.PlayerStateCallEntryFunction(PS_Exploration, '');
}

quest function QToggleStorageInteraction( storageTag : name, enableInteraction : bool )
{
	var storage : W2PlayerStorage;
	
	storage = (W2PlayerStorage)theGame.GetEntityByTag( storageTag );
	storage.ToggleInteraction( enableInteraction );
}

// resets current map ID stored in player
quest function ResetMapID()
{
	thePlayer.SetCurrentMapId( 1234 );
}