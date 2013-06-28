/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Dice Poker Minigame
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

enum W2MinigameDicePokerPlayers
{
	DicePoker_Player,
	DicePoker_NPC,
	
	DicePoker_PlayersNum,
}

enum W2MinigameDicePokerResult
{
	MinigameDicePokerResult_None,			// Nic
	MinigameDicePokerResult_OnePair,		// Para				AA
	MinigameDicePokerResult_TwoPair,		// 2 Pary			AA BB
	MinigameDicePokerResult_Three,			// Trojka			AAA
	MinigameDicePokerResult_Straight,		// Strit 			1-5 or 2-6
	MinigameDicePokerResult_FullHouse,		// Full	 			AAA BB
	MinigameDicePokerResult_Four,			// Kareta			AAAA
	MinigameDicePokerResult_Poker,			// Poker			AAAAA
}

struct W2MinigameDicePokerPlayerStatus
{
	var m_money         : int;
	var m_dices			: array< CMinigameDice >;
}

import class W2MinigameDicePoker extends CMinigame
{
	// Imports
	import final function FindSolutionMC( nAILevel : int, fRisk : float, bOpponentThrow : bool,
		ai1, ai2, ai3, ai4, ai5 : int,
		pl1, pl2, pl3, pl4, pl5 : int,
		out bRaise : bool, out bPlay : bool,
		out b1 : bool, out b2 : bool, out b3 : bool, out b4 : bool, out b5 : bool );
		
	import final function AddDiceCollisionListener();
	import final function RemoveDiceCollisionListener();
	
	import final function UnlockGOGMinigame();

	// Objects
	var m_guiPanel				: CGuiDice;
	var m_physicsSystem			: CPhysicsSystemComponent;

	// Game state
	var m_stake					: int;
	var m_currentThrow			: int;
	var m_playerStatuses		: array< W2MinigameDicePokerPlayerStatus >;
	var m_playerWins			: bool;

	// Gameplay variables
	var m_throwingPoint			: Vector;
	var m_throwingStrength		: float;
	var m_dicesBeingThrowed 	: array< CMinigameDice >;
	var m_tableBox				: Box;
	var m_throwStartPoint		: Vector;
	
	// Gui
	var m_guiResponse				: bool;
	var	m_padCurrentlyHighlighted	: int;
	var m_padResetInput				: bool;
	var m_padPersistentMovement		: int;
	var m_padMinX					: float;
	var m_padMaxX					: float;
	var m_padMinY					: float;
	var m_padMaxY					: float;
	var m_padXChange				: float;
	var m_padYChange				: float;
	var	m_padWaitingForThrow		: bool;
	
	// AI
	var m_npc					: CNewNPC;
	
	// Constants
	var	m_minStake				: int;
	
	event OnStarted()
	{
		var dice			: CMinigameDice;
		var wp      		: CComponent;
		var i       		: int;
		var playerIdx 		: int;
		var diceIdx 		: int;
		var players 		: array< CActor >;
		var tmpPlayers 		: array< CActor >;
		var playerStatus 	: W2MinigameDicePokerPlayerStatus;

		// Init constants :)
		m_minStake = 10;

		// Show panel
		m_guiPanel = theHud.ShowDice( this );
		
		tmpPlayers = GetPlayers();
		
		m_physicsSystem = (CPhysicsSystemComponent) this.GetComponentByClassName( 'CPhysicsSystemComponent' );
		if ( ! m_physicsSystem )
		{
			LogChannel( 'Minigame', "No physics system found" );
			return false;
		}
		
		// Check number of players
		if ( tmpPlayers.Size() < DicePoker_PlayersNum )
		{
			LogChannel( 'Minigame', "Not enough players for Dice Poker" );
			return false;
		}
		
		// Ensure appropriate order of players
		if( tmpPlayers[ 0 ] == thePlayer )
		{
			players.PushBack( tmpPlayers[ 0 ] );
			players.PushBack( tmpPlayers[ 1 ] );
		}
		else
		{
			players.PushBack( tmpPlayers[ 1 ] );
			players.PushBack( tmpPlayers[ 0 ] );
		}
		
		// Get players
		for ( playerIdx = 0; playerIdx < DicePoker_PlayersNum; playerIdx += 1 )
		{
			// Set player state
			wp = GetComponent( "player" + playerIdx );
			if( ! wp )
			{
				LogChannel( 'Minigame', "Waypoint 'player" + playerIdx + "' not found" );
			}
			players[playerIdx].EnterMinigameState( NULL, '' );
			players[playerIdx].SetHideInGame( true );
			//players[playerIdx].SetErrorState( "Let's play!" );
			
			// Get NPC info
			if( players[playerIdx] != thePlayer )
			{
				m_npc = ( CNewNPC ) players[ playerIdx ];
			}
			
			// Create status
			playerStatus.m_money = players[playerIdx].GetInventory().GetItemQuantityByName( 'Orens' );
			
			// Spawn dices
			playerStatus.m_dices.Clear();
			for ( diceIdx = playerIdx * 5 + 0; diceIdx < playerIdx * 5 + 5; diceIdx += 1 )
			{
				dice = new CMinigameDice in this;

				dice.m_rigidBodyIdx = m_physicsSystem.GetRigidBodyIndex( "dice0" + diceIdx );
				dice.m_physics      = m_physicsSystem;
				dice.m_component    = (CDrawableComponent) GetComponent( "dice0" + diceIdx );
				dice.m_index        = diceIdx;
				
				if ( ! dice.m_component )
				{
					LogChannel( 'Minigame', "No dice meshes" );
					return false;
				}
				
				dice.ResetPosition();
				
				playerStatus.m_dices.PushBack( dice );
			}

			m_playerStatuses.PushBack( playerStatus );
		}
		
		// Enable collision reporting (for sounds)
		EnableCollisionInfoReportingForComponent( m_physicsSystem, true, false );
		
		LogChannel( 'Minigame', "******************" );
		LogChannel( 'Minigame', "Dice Poker started" );
	
		m_currentThrow = 1;
		
		StateInitializeGUI();
		
		// Play some music
		theSound.PlayMusicNonQuest( "minigame_dices" );
		
		return true;
	}
	
	event OnEnded( winnerIdx : int )
	{
		var players : array< CActor >;
		var i       : int;
		
		// Update money and release players
		players = GetPlayers();
		for ( i = players.Size() - 1; i >= 0; i -= 1 )
		{
			//if ( m_playerStatuses[ i ].m_money  < 0 ) m_playerStatuses[ i ].m_money = 0;
			//if ( m_playerStatuses[ i ].m_money != 0 ) players[i].GetInventory().SetItemQuantity( 'Orens', m_playerStatuses[ i ].m_money);
			Log(m_playerStatuses[ i ].m_money);
			players[i].SetHideInGame( false );
			players[i].ExitMinigameState();
		}
		
		// Set NPC stats
		if( m_playerWins )
		{
			m_npc.DiceLossesIncrease();
		}
		else
		{
			m_npc.DiceWinsIncrease();
		}
		
		// Destroy dices
		m_playerStatuses.Clear();
		
		if ( winnerIdx < 0 )
			LogChannel( 'Minigame', "Dice Poker ended, no winner" );
		else
		{
			LogChannel( 'Minigame', "Dice Poker ended, the winner is " + players[ winnerIdx ].GetName() );
			players[ winnerIdx ].SetErrorState( "I have won the whole game!" );
		}
		
		// Stop music
		theSound.StopMusic( "minigame_dices" );
		
		theHud.HideDice();
	}
	
	timer function DicesInputTimer( timeDelta : float )
	{
		m_padResetInput = true;
		if( AbsF( m_padPersistentMovement ) == 1 )
		{
			MoveSelectionDicePad( m_padPersistentMovement );
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if( theGame.IsUsingPad() )
		{
			if( GetCurrentStateName() == 'PlayerThrowing' )
			{
				// Check state
				if( key == 'GI_AxisRightX' || key == 'GI_AxisRightY' )
				{
					if( AbsF( value ) < 0.01f )
					{
						if( ! m_padWaitingForThrow )
						{
							// Player moved thumb and it returned to original position, so throwing is ended
							m_guiResponse = true;
						}
					}
					else if( m_padWaitingForThrow && AbsF( value ) > 0.2f )
					{
						// Player moved thumb 
						m_padWaitingForThrow = false;
					}
				}
				
				// Check keys
				if( key == 'GI_AxisRightX' )
				{
					m_padMinX = MinF( m_padMinX, value );
					m_padMaxX = MaxF( m_padMaxX, value );
				}
				else if( key == 'GI_AxisRightY' )
				{
					m_padMinY = MinF( m_padMinY, value );
					m_padMaxY = MaxF( m_padMaxY, value );
				}
				else if( key == 'GI_AxisLeftX' )
				{
					m_padXChange = value * -2.f;
				}
				else if( key == 'GI_AxisLeftY' )
				{
					m_padYChange = value * 2.f;
				}
			}
			else if( GetCurrentStateName() == 'PlayerSelect' )
			{
				if( key == 'GI_AttackStrong' && value > 0.5f )
				{
					SelectDicePad();
					return true;
				}
				else if( key == 'GI_AxisLeftX' && value < -0.7f )
				{
					m_padPersistentMovement = 1;
					MoveSelectionDicePad( 1 );
					return true;
				}
				else if( key == 'GI_AxisLeftX' && value > 0.7f )
				{
					m_padPersistentMovement = -1;
					MoveSelectionDicePad( -1 );
					return true;
				}
				else if( key == 'GI_AxisLeftX' && AbsF( value ) < 0.3f )
				{
					m_padPersistentMovement = 0;
					return true;
				}
			}
		}
		else
		{
			if( key == 'GI_AttackFast' && GetCurrentStateName() == 'PlayerThrowing' )
			{
				m_guiResponse = true;
				return true;
			}
			
			if( GetCurrentStateName() == 'PlayerSelect' )
			{
				if( key == 'GI_AttackFast' && value < 0.5f )
				{
					SelectDiceMouse();
					return true;
				}
			}
		}
		
		return false;
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float )
	{
		// PAD only
		
		if( ! theGame.IsUsingPad() )
		{
			return false;
		}

		
		if( GetCurrentStateName() == 'PlayerSelect' )
		{
			if( key == 144 /* IK_Pad_DigitLeft */ && action == IACT_Press )
			{
				MoveSelectionDicePad( 1 );
				return true;
			}
			else if( key == 145 /* IK_Pad_DigitRight */ && action == IACT_Press )
			{
				MoveSelectionDicePad( -1 );
				return true;
			}
		}
		
		return false;
	}
	
	event OnDiceCollision()
	{
		// Play sound only if collisions with table
		theSound.PlaySound( "global/global_dice_game/code_dice_hit" );
	}
	
	final function StartPlayerSelection()
	{
		var i : int;
		
		theHud.m_hud.HideTutorial();
		if( theGame.IsUsingPad() )
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut75", "", false);
			//theHud.ShowTutorialPanelOld( "tut75", "" );
		}
		else
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut74", "", false);
			//theHud.ShowTutorialPanelOld( "tut74", "" );
		}
		if( theGame.IsUsingPad() )
		{
			m_padCurrentlyHighlighted = -1;
			
			// Select first non-empty slot
			for( i = 4; i >= 0; i -= 1 )
			{
				if( !m_playerStatuses[ DicePoker_Player ].m_dices[ i ].IsDisabled() )
				{
					m_padCurrentlyHighlighted = i;
					break;
				}
			}
	
			if( m_padCurrentlyHighlighted != -1 )
			{
				m_padResetInput = true;
				m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].SetHighlight( true );
			}
		}
		
		m_guiPanel.DiceSelection();
	}
	
	final function EndPlayerSelection()
	{
		var i : int;
		
		// Turn off indicating
		for( i = 0; i < m_playerStatuses[ DicePoker_Player ].m_dices.Size(); i += 1 )
		{
			m_playerStatuses[ DicePoker_Player ].m_dices[ i ].Select( 
				m_playerStatuses[ DicePoker_Player ].m_dices[ i ].IsSelected(), false );
			
			// Highlight
			m_playerStatuses[ DicePoker_Player ].m_dices[ i ].SetHighlight( false );
		}
	}
	
	final function MoveSelectionDicePad( movement : int )
	{
		var i : int;
		
		// Exit if not enough time has passed
		if( ! m_padResetInput )
		{
			return;
		}
		
		m_padResetInput = false;
		AddTimer( 'DicesInputTimer', 0.5f, false );
	
		// Cancel highlight
		m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].SetHighlight( false );
	
		for( i = 0; i < 5; i += 1 )
		{
			// Move selection to the left
			m_padCurrentlyHighlighted = m_padCurrentlyHighlighted + movement;

			// Assure proper range
			m_padCurrentlyHighlighted += 5;
			m_padCurrentlyHighlighted = m_padCurrentlyHighlighted % 5;
			
			// Check if enabled
			if( !m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].IsDisabled() )
			{
				break;
			}
		}

		// Set highlight
		m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].SetHighlight( true );
	}
	
	final function SelectDicePad()
	{
		if( m_padCurrentlyHighlighted < 0 )
		{
			return;
		}
		
		if( ! m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].IsSelected() )
		{
			// Select dice
		
			// Cancel highlight
			m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].SetHighlight( false );
		
			// Select currently highlighted dice
			m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].Select( true, true );
		}
		else
		{
			// Deselect dice
		
			// Deselect currently highlighted dice
			m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].Select( false, true );

			// Show highlight
			m_playerStatuses[ DicePoker_Player ].m_dices[ m_padCurrentlyHighlighted ].SetHighlight( true );
		}
	}
	
	final function SelectDiceMouse()
	{
		var rayStart, rayDirection : Vector;
		var cursorX, cursorY : int;
		var collidedRigidBodyIdx : int;
		var collidedComponent : CComponent;
		var i : int;
		
		if( theGame.IsUsingPad() )
		{
			theHud.m_hud.ShowTutorial("tut77", "", false);
		}
		else
		{
			theHud.m_hud.ShowTutorial("tut48", "", false);
		}
		
		
		
		theHud.GetMousePosition( cursorX, cursorY );

		theGame.GetActiveCameraComponent().ViewCoordsToWorldVector( cursorX, cursorY, rayStart, rayDirection );
		
		if ( m_physicsSystem.TraceFatRay( rayStart, rayStart + rayDirection * 10.f, 0.1f, collidedComponent, collidedRigidBodyIdx, CLT_Debris ) )
		{
			for ( i = 0; i < m_playerStatuses[ DicePoker_Player ].m_dices.Size(); i += 1 )
			{
				if ( m_playerStatuses[ DicePoker_Player ].m_dices[ i ].m_rigidBodyIdx == collidedRigidBodyIdx )
				{
					m_playerStatuses[ DicePoker_Player ].m_dices[ i ].Select( ! m_playerStatuses[ DicePoker_Player ].m_dices[ i ].IsSelected(), true );
				}
			}
		}
	}
	

	final function SelectAllDices( playerIdx : int, select : bool )
	{
		var i : int;
		
		for ( i = 0; i < m_playerStatuses[ playerIdx ].m_dices.Size(); i += 1 )
		{
			m_playerStatuses[ playerIdx ].m_dices[ i ].Select( select, false );
		}
	}
	
	latent final function ThrowDices( playerIdx : int )
	{
		var isDone  			: bool;
		var i       			: int;
		var player  			: int;
		var timeout 			: float;
		var tableCenter			: Vector;
		
		// For moving dices by hand
		var x, y, lastX, lastY	: int;
		var direction, right, position	: Vector;
		
		m_dicesBeingThrowed.Clear();
		
		// Disable dices
		for( player = 0; player < m_playerStatuses.Size(); player += 1 )
		{
			for ( i = 0; i < m_playerStatuses[ player ].m_dices.Size(); i += 1 )
			{
				// Disable movement
				m_playerStatuses[ player ].m_dices[ i ].DisablePhysics();
				
				if( player == playerIdx && m_playerStatuses[ player ].m_dices[ i ].IsSelected() )
				{
					m_dicesBeingThrowed.PushBack( m_playerStatuses[ player ].m_dices[ i ] );
				}
			}
		}
		
		// If no dices selected - no throwing
		if( m_dicesBeingThrowed.Size() == 0 )
		{
			return;
		}
		
		// Calculate table center
		tableCenter = m_tableBox.Min + ( m_tableBox.Max - m_tableBox.Min ) / 2.0f;

		// Collect dices
		for( i = 0; i < m_dicesBeingThrowed.Size(); i += 1 )
		{
			m_dicesBeingThrowed[ i ].Collect( Vector( tableCenter.X, tableCenter.Y,	m_tableBox.Max.Z + 0.3f ) );
		}
		
		if( playerIdx == DicePoker_Player )
		{
			if( theGame.IsUsingPad() )
			{
				SelectThrowPointForPlayerPad();
			}
			else
			{
				SelectThrowPointForPlayerHard();
			}
		}
		else
		{
			SelectThrowPointForNPC();
		}
		
		AddDiceCollisionListener();
		
		for( i = 0; i < m_dicesBeingThrowed.Size(); i += 1 )
		{
			m_dicesBeingThrowed[ i ].Throw( m_throwingPoint, m_throwingStrength );
		}
		
		// Wait some time
		Sleep( 2.f );

		RemoveDiceCollisionListener();
		
		LogChannel( 'Minigame', "Dices has been thrown" );
	}
	
	latent final function SelectThrowPointForPlayerPad()
	{
		var xDirection 		: float;
		var yDirection		: float;
		var tableSizeX		: float;
		var tableSizeY		: float;
		
		// For moving dice
		var i, size : int;
		var direction, right, position	: Vector;

		theHud.EnableInput( true, true, false );
		
		// Reset state
		m_padMinX = 0.0f;
		m_padMaxX = 0.0f;
		m_padMinY = 0.0f;
		m_padMaxY = 0.0f;
		m_padWaitingForThrow = true;
		
		// Wait for throw
		m_guiResponse = false;
		while( ! m_guiResponse )
		{
			// Get camera pointing direction
			direction = ( ( CCamera ) theGame.GetActiveCameraComponent().GetEntity() ).GetCameraDirection();
			
			// Cast on XY plane
			direction.Z = 0;
			direction = VecNormalize( direction );
			
			// Calculate perpendicular vector in XY plane
			right = VecNormalize( VecCross( direction, Vector( 0.0f, 0.0f, 1.0f ) ) );
		
			// Move holding dices
			size = m_dicesBeingThrowed.Size();
			for( i = 0; i < size; i += 1 )
			{
				position = -right * ( m_padXChange ) * 0.01f;
				position += direction * ( m_padYChange ) * 0.01f;
				m_dicesBeingThrowed[ i ].SetPositionRelative( position, m_tableBox );
			}
			
			Sleep( 0.001f );
		}

		// Check directions (due to camera angle, X is exchanged with Y and Y is reverted)
		if( AbsF( m_padMinX ) > AbsF( m_padMaxX ) )
		{
			yDirection = -m_padMinX;
		}
		else
		{
			yDirection = -m_padMaxX;
		}
		if( AbsF( m_padMinY ) > AbsF( m_padMaxY ) )
		{
			xDirection = m_padMinY;
		}
		else
		{
			xDirection = m_padMaxY;
		}
		
		// Take start position from any dice collected
		m_throwStartPoint = m_dicesBeingThrowed[ 0 ].m_component.GetWorldPosition();
		
		// Set throwing point initially below dices
		m_throwingPoint = m_throwStartPoint;
		m_throwingPoint.Z = m_tableBox.Min.Z;

		// Get table dimensions
		tableSizeX = m_tableBox.Max.X - m_tableBox.Min.X;
		tableSizeY = m_tableBox.Max.Y - m_tableBox.Min.Y;
	
		// Modify throwing point by direction indicated by player
		m_throwingPoint += Vector( xDirection * tableSizeX / 2.0f, yDirection * tableSizeY / 2.0f, 0.0f );
	
		// Set Throwing strength (just arbitrary value dependant on thumb movement)
		m_throwingStrength = ( xDirection * xDirection + yDirection * yDirection ) / 2.0f;
		
		theHud.EnableInput( true, true, true );
	}
	
	latent final function SelectThrowPointForPlayerHard()
	{
		var isDone  			: bool;
		var i       			: int;
		var player  			: int;
		var timeout 			: float;
		var tableCenter			: Vector;
		
		// For moving dices by hand
		var x, y, lastX, lastY	: int;
		var direction, right, position	: Vector;

		// Initialize variables
		theHud.GetMousePosition( lastX, lastY );
		x = lastX;
		y = lastY;
	
		theHud.EnableInput( true, true, false );

		// Point dice placement
		m_guiResponse = false;
		while( ! m_guiResponse )
		{
			// Get camera pointing direction
			direction = ( ( CCamera ) theGame.GetActiveCameraComponent().GetEntity() ).GetCameraDirection();
			
			// Cast on XY plane
			direction.Z = 0;
			direction = VecNormalize( direction );
			
			// Calculate perpendicular vector in XY plane
			right = VecNormalize( VecCross( direction, Vector( 0.0f, 0.0f, 1.0f ) ) );

			// Get current mouse position and use relative movement to calculate direction
			theHud.GetMousePosition( x, y );
			
			// LogChannel( 'Minigame', "x: " + x + ", y: " + y );
		
			// Move holding dices
			for( i = 0; i < m_dicesBeingThrowed.Size(); i += 1 )
			{
				position = -right * ( lastX - x ) * 0.01f;
				position += direction * ( lastY - y ) * 0.01f;
				m_dicesBeingThrowed[ i ].SetPositionRelative( position, m_tableBox );
			}
			
			lastX = x;
			lastY = y;
			
			Sleep( 0.001f );
		}

		// Take start position from any dice collected
		m_throwStartPoint = m_dicesBeingThrowed[ 0 ].m_component.GetWorldPosition();

		// Set throwing point initially below dices
		m_throwingPoint = m_throwStartPoint;

		// Initialize variables
		theHud.GetMousePosition( lastX, lastY );
		x = lastX;
		y = lastY;

		// Point direction
		m_guiResponse = false;
		while( ! m_guiResponse )
		{
			// Get camera pointing direction
			direction = ( ( CCamera ) theGame.GetActiveCameraComponent().GetEntity() ).GetCameraDirection();
			
			// Cast on XY plane
			direction.Z = 0;
			direction = VecNormalize( direction );
			
			// Calculate perpendicular vector in XY plane
			right = VecNormalize( VecCross( direction, Vector( 0.0f, 0.0f, 1.0f ) ) );

			// Get current mouse position and use relative movement to calculate direction
			theHud.GetMousePosition( x, y );

			m_throwingPoint -= right * ( lastX - x ) * 0.01f;
			m_throwingPoint += direction * ( lastY - y ) * 0.01f;
			
			lastX = x;
			lastY = y;
			Sleep( 0.001f );
		}
		
		theHud.EnableInput( true, true, true );
		
		// Calculate throw strength
		m_throwingStrength = MinF( VecDistance2D( m_throwStartPoint, m_throwingPoint ) * 0.5f, 0.7f );
		
		// Always throw in table direction
		m_throwingPoint.Z = m_throwStartPoint.Z - 0.2f * m_throwingStrength;
	}

	latent final function SelectThrowPointForNPC()
	{
		var tableCenter			: Vector;
		
		// Calculate table center
		tableCenter = m_tableBox.Min + ( m_tableBox.Max - m_tableBox.Min ) / 2.0f;
		
		// Take start position from any dice collected
		m_throwStartPoint = m_dicesBeingThrowed[ 0 ].m_component.GetWorldPosition();

		m_throwingStrength = 0.05f + RandF() * 0.5f;
		m_throwingPoint = Vector( 
			tableCenter.X + RandRangeF( -2.0f, 2.0f ) * 0.4f + 0.1f,
			tableCenter.Y + RandRangeF( -2.0f, 2.0f ) * 0.2f + 0.1f,
			m_tableBox.Min.Z );
	}
	
	final function GetPlayerScore( playerIdx : int, out figure : W2MinigameDicePokerResult, out diceMajor : int, out diceMinor : int )
	{
		var i      : int;
		var values : array< int >;
		var value  : int;

		for ( i = 0; i < m_playerStatuses[ playerIdx ].m_dices.Size(); i += 1 )
		{
			values.PushBack( m_playerStatuses[ playerIdx ].m_dices[ i ].GetResult() );
		}
		
		ArraySortInts( values );
		
		diceMajor = 0;
		diceMinor = 0;
		figure    = MinigameDicePokerResult_None;
		
		for ( i = 1; i < values.Size(); i += 1 )
		{
			value = values[ i ];
			
			if ( value != values[ i - 1 ] || value == 0 )
				continue;
		
			if ( figure == MinigameDicePokerResult_OnePair )
			{
				if ( diceMinor == value )
				{
					figure = MinigameDicePokerResult_Three;
				}
				else
				{
					figure = MinigameDicePokerResult_TwoPair;
					diceMajor  = value;
				}
			}
			else if ( figure == MinigameDicePokerResult_TwoPair )
			{
				figure = MinigameDicePokerResult_FullHouse;
			}
			else if ( figure == MinigameDicePokerResult_Three )
			{
				if ( diceMinor == value )
				{
					figure = MinigameDicePokerResult_Four;
				}
				else
				{
					figure = MinigameDicePokerResult_FullHouse;
					diceMajor = value;
				}
			}
			else if ( figure == MinigameDicePokerResult_Four )
			{
				figure = MinigameDicePokerResult_Poker;
				if( playerIdx == DicePoker_Player ) theGame.UnlockAchievement('ACH_POKER');
			}
			else
			{
				figure = MinigameDicePokerResult_OnePair;
				diceMinor = value;
				diceMajor = 0;
			}
		}
		
		// Test for STRAIGHT
		if ( figure == MinigameDicePokerResult_None && values[ 0 ] != 0 )
		{
			figure    = MinigameDicePokerResult_Straight;
			diceMajor = values[ values.Size() - 1 ];
			
			for ( i = 1; i < values.Size(); i += 1 )
			{
				if ( values[ i ] != values[ i - 1 ] + 1 )
				{
					figure    = MinigameDicePokerResult_None;
					diceMajor = 0;
					break;
				}
			}
		}
	}
	
	final function GetWinner() : int
	{
		var playerFigure, npcFigure : W2MinigameDicePokerResult;
		var playerMajor, playerMinor : int;
		var npcMajor, npcMinor : int;
		
		GetPlayerScore( DicePoker_Player, playerFigure, playerMajor, playerMinor );
		GetPlayerScore( DicePoker_NPC, npcFigure, npcMajor, npcMinor );
		
		if ( playerFigure > npcFigure ) return DicePoker_Player;
		if ( playerFigure < npcFigure ) return DicePoker_NPC;
		
		if ( playerMajor > npcMajor ) return DicePoker_Player;
		if ( playerMajor < npcMajor ) return DicePoker_NPC;
		
		if ( playerMinor > npcMinor ) return DicePoker_Player;
		if ( playerMinor < npcMinor ) return DicePoker_NPC;
		
		return -1;
	}
	
	final function BetAI( playerBet : int ) : int
	{
		var raise, play, rethrow1, rethrow2, rethrow3, rethrow4, rethrow5 : bool;
		var bet : int;
		var riskLevel : float;
		
		if( m_currentThrow == 1 )
		{
			// Initial betting, based only on NPC risk rate, not dices
			if( m_npc.GetDicePokerLevel() < 2 )
			{
				// On hard levels NPC raises stake
				bet = ( int )( playerBet + RandRangeF( m_minStake, playerBet * 0.33f ) );
			}
			else
			{
				// On easy levels, npc just accepts player stake
				bet = Max( playerBet, m_minStake );
			}
			
			// NPC cannot bet more than player have
			return Min( bet, m_playerStatuses[ DicePoker_Player ].m_money + playerBet );
		}
		
		riskLevel = 0.2f + ( int ) m_npc.GetDicePokerLevel() * 0.2f;
		FindSolutionMC( m_npc.GetDicePokerLevel(), riskLevel, true,
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 0 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 1 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 2 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 3 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 4 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 0 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 1 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 2 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 3 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 4 ].GetResult(),
			raise, play,
			rethrow1, rethrow2, rethrow3, rethrow4, rethrow5 );
			
		if( ! play )
		{
			LogChannel( 'Minigame', "NPC gave up!" );

			StateNPCGaveUp();
		}
		
		if( raise )
		{
			// This is CHEAT! NPC can bet money he doesn't have!
			// Info: Desing
			bet = ( int )( playerBet + RandRangeF( m_minStake, playerBet * 0.33f * riskLevel ) );
		}
		else
		{
			// Just accept player bet
			bet = Max( playerBet, m_minStake );
		}
		
		// NPC cannot bet more than player have
		return Min( bet, m_playerStatuses[ DicePoker_Player ].m_money + playerBet );
	}
	
	final function SelectDicesAI()
	{
		var raise, play, rethrow1, rethrow2, rethrow3, rethrow4, rethrow5 : bool;
		
		SelectAllDices( DicePoker_NPC, false );
		
		FindSolutionMC( m_npc.GetDicePokerLevel(), 0.0f /* not important here */, false /* bOpponentThrow */,
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 0 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 1 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 2 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 3 ].GetResult(),
			m_playerStatuses[ DicePoker_NPC ].m_dices[ 4 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 0 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 1 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 2 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 3 ].GetResult(),
			m_playerStatuses[ DicePoker_Player ].m_dices[ 4 ].GetResult(),
			raise, play,
			rethrow1, rethrow2, rethrow3, rethrow4, rethrow5 );
			
		m_playerStatuses[ DicePoker_NPC ].m_dices[ 0 ].Select( rethrow1, false );
		m_playerStatuses[ DicePoker_NPC ].m_dices[ 1 ].Select( rethrow2, false );
		m_playerStatuses[ DicePoker_NPC ].m_dices[ 2 ].Select( rethrow3, false );
		m_playerStatuses[ DicePoker_NPC ].m_dices[ 3 ].Select( rethrow4, false );
		m_playerStatuses[ DicePoker_NPC ].m_dices[ 4 ].Select( rethrow5, false );
	}
	
	final function PutDices( playerIdx : int )
	{
		var i : int;
		var dice : CMinigameDice;
		var position : Vector;
		
		for( i = 0; i < m_playerStatuses[ playerIdx ].m_dices.Size(); i += 1 )
		{
			dice = m_playerStatuses[ playerIdx ].m_dices[ i ];
			position = dice.m_component.GetWorldPosition();
		
			// Check if dice fell of the table
			if( (  position.X < m_tableBox.Min.X
				|| position.Y < m_tableBox.Min.Y )
				||
				(  position.X > m_tableBox.Max.X
				|| position.Y > m_tableBox.Max.Y ) )
			{
				dice.Disable();
				dice.Teleport( Vector( 0.0f, 0.0f, -1000.0f ) );
			}
			else
			{
				// Restore original position
				dice.ResetPosition();
			}
		}
	}
	
	final function CameraSide()
	{
		SendEventToCamera( 'side' );
	}

	final function CameraTop()
	{
		SendEventToCamera( 'top' );
	}

	final function CameraCloseUp()
	{
		SendEventToCamera( 'closeup' );
	}
}
