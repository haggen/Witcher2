/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Minigame class import
/** Copyright © 2009 CD Projekt RED
/***********************************************************************/

latent storyscene function StartMinigameinSceneEx( player: CStoryScenePlayer, minigameTemplate : CEntityTemplate, gameTag : name, spawnPointTag : name, opponent : name, 
												   isPlayerFirst : bool, searchFreePlaceRadius : float, minigameDefaultAreaRadius : float,
												   audienceEntityTag : name, unused1 : bool, endWithBlackscreen : bool ) : bool
{
	var result : bool;
	result = StartMinigameEx( minigameTemplate, gameTag, spawnPointTag, opponent, isPlayerFirst, searchFreePlaceRadius, minigameDefaultAreaRadius, audienceEntityTag,
							endWithBlackscreen );
	return result;
}

latent quest function QStartMinigameEx( minigameTemplate : CEntityTemplate, gameTag : name, spawnPointTag : name, opponent : name, 
                                        isPlayerFirst : bool, searchFreePlaceRadius : float, minigameDefaultAreaRadius : float,
										audienceEntityTag : name, unused1 : bool, endWithBlackscreen : bool ) : bool
{
	var result : bool;
	result = StartMinigameEx( minigameTemplate, gameTag, spawnPointTag, opponent, isPlayerFirst, searchFreePlaceRadius, minigameDefaultAreaRadius, audienceEntityTag, 
						endWithBlackscreen );
	return result;
}

latent function StartMinigameEx( minigameTemplate : CEntityTemplate, gameTag : name, spawnPointTag : name, opponent : name, 
                                 isPlayerFirst : bool, searchFreePlaceRadius : float, minigameDefaultAreaRadius : float,
								 audienceEntityTag : name, endWithBlackscreen : bool ) : bool
{
	var gameOnWorld     : CMinigame;
	var gameCreated     : CMinigame;
	var gameToPlay      : CMinigame;
	var actor	        : CActor;
	var players	        : array< CActor >;
	var i               : int;
	var playerWins      : bool;
	var gamePos         : Vector;
	var areaRadius      : float;
	var npcsToOmit      : array< CNewNPC >;
	var npc             : CNewNPC;
	var minigameStarted : bool;
	var spawnPoint		: CEntity;
	// Audience
	var audience        : CAudience;
	
	// Set black screen to disable visible spawning 
	theGame.FadeOut( 0.0f );
	
	actor = theGame.GetActorByTag( opponent );
	if ( ! actor )
	{
		LogChannel( 'Minigame', "Opponent " + opponent + " not found!" );
		return false;
	}
	if ( isPlayerFirst )
	{
		players.PushBack( thePlayer );
		players.PushBack( actor );
	}
	else
	{
		players.PushBack( actor );
		players.PushBack( thePlayer );
	}
	
	thePlayer.ResetMovment();
	
	// Find game
	gameOnWorld = (CMinigame) theGame.GetEntityByTag( gameTag );
	
	if ( gameOnWorld && gameOnWorld.IsWithinTeleportRange() )
	{
		gameToPlay = gameOnWorld;
		gamePos = gameOnWorld.GetWorldPosition();
	}
	else
	{
		// Check if spawn point is defined
		if( spawnPointTag != '' )
		{
			spawnPoint = theGame.GetEntityByTag( spawnPointTag );
			if( spawnPoint )
			{
				gamePos = spawnPoint.GetWorldPosition();
			}
		}
		else
		{
			// Find safe minigame position
			if ( gameOnWorld )
			{
				areaRadius = gameOnWorld.GetAreaRadius();
			}
			else
			{
				areaRadius = minigameDefaultAreaRadius;
			}
			if ( !theGame.FindEmptyArea( searchFreePlaceRadius, areaRadius, 'scene', thePlayer.GetWorldPosition(), gamePos ) )
			{
				LogChannel( 'Minigame', "Minigame cannot start! Can't find safe placement." );
				return false;
			}
		}

		gameCreated = (CMinigame) theGame.CreateEntity( minigameTemplate, gamePos );
		gameToPlay = gameCreated;
	}	
	
	// Update area radius to more accurate, as now we have spawned minigame
	areaRadius = gameToPlay.GetAreaRadius(); //gameCreated
		
	// Put denied area around the minigame
	// Don't teleport opponent. Maybe it isn't necessary...
	// actor.Teleport( gamePos );
	gameToPlay.RaiseDeniedArea();
		
	// Teleport unwanted NPCs out of space
	npcsToOmit.PushBack( (CNewNPC)actor );
	theGame.GetRidOfNPCsFromPlace( gamePos, areaRadius, areaRadius, 2.0f, areaRadius * 4.0f, npcsToOmit );
	
	if ( audienceEntityTag != '' )
	{
		audience = (CAudience)theGame.GetEntityByTag( audienceEntityTag );
		if ( audience )
		{
			gameToPlay.audience = audience;
			audience.SetActorsToExclude( players );
			audience.StartAudience();
		}
	}
	
	theGame.EnableButtonInteractions( false );
	
	// Put out all objects from player hands
	actor.EmptyHands();

	// Restore screen either it was faded or not
	theGame.FadeInAsync( 2.0 );
	
	gameToPlay.m_endsWithBlackscreen = endWithBlackscreen;

	/* START GAME */

	if ( ! gameToPlay.StartGameWaitForResult( players, playerWins ) )
	{
		LogChannel( 'Minigame', "Minigame " + gameTag + " cannot start!" );
		minigameStarted = false;
	}
	else
	{
		minigameStarted = true;
	}
	
	/*
	if ( endWithBlackscreen )
	{
		theGame.FadeOutAsync( 2.0 );
		Sleep( 2.0 );
	}
	*/
	
	theGame.EnableButtonInteractions( true );
	
	// Stop audience
	if ( audience )
	{
		audience.StopAudience();
	}

	gameToPlay.ClearDeniedArea();
	
	if ( gameCreated )
	{
		gameCreated.Destroy();
	}
	
	

	if ( minigameStarted )
	{
		/*
		if ( playerWins && giveMoneyOnPlayerWin )
		{
			thePlayer.GetInventory().AddItem( 'Orens', thePlayer.GetLastBribe() * 2 );
		}
		*/
		
		return playerWins;
	}
	else
	{
		return false;
	}
}

import class CMinigame extends CEntity
{
	import final function StartGameWaitForResult( players : array< CActor >, out playerWins : bool ) : bool;
	import final function StartGame             ( players : array< CActor > ) : bool;
	import final function EndGame               ( playerWins : bool ) : bool;
	
	import final function IsStarted() : bool;
	
	import final function GetPlayers() : array< CActor >;
	
	import final function AttachCameraBehavior( behaviorName : name ) : bool;
	import final function DetachCameraBehavior( behaviorName : name ) : bool;
	import final function SendEventToCamera( eventName : name ) : bool;
	import final function SetCameraFloatVariable( varName : string, varValue : float ) : bool;
	import final function TeleportCamera( cameraPos : Vector, cameraRot : EulerAngles );

	import final function GetBonePosition( actor : CActor, boneName : name ) : Vector;
	import final function GetBoneRotation( actor : CActor, boneName : name ) : EulerAngles;
	import final function GetStartingTrajectories( animName : name, out playerOne : Vector, out playerTwo : Vector ) : bool;
	
	import final function IsWithinTeleportRange() : bool;
	import final function GetAreaRadius() : float;
	import final function RaiseDeniedArea() : bool;
	import final function ClearDeniedArea();
	
	import final function EnableDebugFragments( enable : bool, minigameType : int ); // 0 - wrist wrestling, 1 - dices
	import final function WristWrestlingSetArea( pos : float, width : float );
	import final function WristWrestlingSetPointer( pos : float );
	import final function WristWrestlingSetParams( hotSpotMinWidth : int, hotSpotMaxWidth : int, isInHotSpot : bool );
	
	public var m_endsWithBlackscreen : bool;
	
	// Audience
	public var audience : CAudience;
	
	import final function GetWristWrestlingNPCParams( actor : CActor, out hotSpotMinWidth : int,
		out hotSpotMaxWidth : int, out gameDifficulty : EAIMinigameDifficulty ) : bool;
		
	event OnStarted()                { return true; }
	event OnEnded( winnerIdx : int ) {}
	
	event OnGameInputEvent( key : name, value : float ) { return false; }
	
	default m_endsWithBlackscreen = false;
	
	function DoEnd( playerWins : bool )
	{
		End( playerWins );
	}
}

state Ending in CMinigame
{
	entry function End( playerWins : bool ) 
	{
		if ( parent.m_endsWithBlackscreen )
		{
			theGame.FadeOut( 2.0 );
		}
		parent.EndGame( playerWins );
	}
}

state Minigame in CNewNPC extends Base
{
	var m_initialPos : Vector;
	var m_initialRot : EulerAngles;
	var m_wasTeleported : bool;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnablePathEngineAgent( false );
		m_initialPos = parent.GetWorldPosition();
		m_initialRot = parent.GetWorldRotation();
		
		// Lock lookats
		parent.SetLookAtMode( LM_GameplayLock );
	}
	
	event OnLeaveState()
	{
		parent.TeleportWithRotation( m_initialPos, m_initialRot );

		parent.EnablePathEngineAgent( true );
		MarkGoalFinished();
	
		// Reset lookats
		parent.ResetLookAtMode( LM_GameplayLock );
		
		super.OnLeaveState();
	}

	entry function StateMinigame( wp : CNode, behavior : name, goalId : int )
	{
		SetGoalId( goalId );
		
		parent.ActionCancelAll();
		
		if ( behavior )
			parent.ActivateBehavior( behavior );

		if ( wp )
		{
			parent.TeleportWithRotation( wp.GetWorldPosition(), wp.GetWorldRotation() );
		}
	}
	
	entry function StateMinigameExit()
	{
		MarkGoalFinished();
	}
}

state Minigame in CPlayer extends Base
{
	var m_initialPos : Vector;
	var m_initialRot : EulerAngles;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnablePathEngineAgent( false );
		m_initialPos = parent.GetWorldPosition();
		m_initialRot = parent.GetWorldRotation();
		
		// Lock lookats
		parent.SetLookAtMode( LM_GameplayLock );
	}
	
	event OnLeaveState()
	{
		parent.TeleportWithRotation( m_initialPos, m_initialRot );
		parent.EnablePathEngineAgent( true );
		
		// Reset lookats
		parent.ResetLookAtMode( LM_GameplayLock );

		super.OnLeaveState();
	}

	entry function StateMinigame( wp : CNode, behavior : name )
	{
		parent.ActionCancelAll();
		
		if ( behavior )
			parent.ActivateBehavior( behavior );
		
		if ( wp )
			parent.TeleportWithRotation( wp.GetWorldPosition(), wp.GetWorldRotation() );
	}
}
