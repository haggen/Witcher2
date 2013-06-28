/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Wrist Wrestling Minigame
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

/*
	Methods and classes implemented in HUD:
	
	Minigames.WristWrestling.*
	
	Minigames.WristWrestling.*	: <type>;	// <description>
*/

enum EMWW_GameType
{
	MWWGT_Simple,
	MWWGT_SimpleCont,
	MWWGT_Newton,
	MWWGT_Mash,
}

enum EMWW_GameDifficulty
{
	MWWGD_Easy,
	MWWGD_Normal,
	MWWGD_Nightmare,
}

struct SMMW_GameParamsEntry
{
	public editable var m_hotSpotMinWidth : int; 
	public editable var m_hotSpotMaxWidth : int;
	public editable var m_gameDifficulty  : EMWW_GameDifficulty;
	public editable var m_playerTag       : name;
	
	default m_gameDifficulty = MWWGD_Normal;
}

class W2MinigameWristWrestling extends CMinigame
{
	// Game configuration
	public editable var m_hotSpotMinWidth : int; 
	public editable var m_hotSpotMaxWidth : int;
	public editable var m_gameType        : EMWW_GameType;
	public editable var m_difficulty      : EMWW_GameDifficulty;
	public editable var m_gameParams      : array< SMMW_GameParamsEntry >;
	public editable var m_startPos        : string;
	
	default m_hotSpotMinWidth = 6;
	default m_hotSpotMaxWidth = 20;
	default m_gameType = MWWGT_Newton;
	default m_difficulty = MWWGD_Normal;
	
	// GUI configuration (change values only if flash changes)
	var m_guiBarMinValue    : int; // GUI flash minimum bar value (-250)
	var m_guiBarMaxValue    : int; // GUI flash maximum bar value (+250)

	// Flash runtime data
	var AS_wristWrestling	: int; // flash ID

	var players 			: array< CActor >;
	var m_humanPlayerIdx	: int;	// player index
	var m_round				: int;	// the round number

	// Current runtime GUI data
	var m_guiPointerPos     : int; // [-250,250]
	var m_guiHotSpotWidth   : int;
	var m_guiHotSpotPos     : int;
	
	// Overriden params
	var m_overridenHotSpotMinWidth  : int; 
	var m_overridenHotSpotMaxWidth  : int;
	var m_isHotSpotWidthOverriden   : bool;
	var m_isGameDifficultyOverriden : bool;	
	var m_overridenDifficulty       : EMWW_GameDifficulty;
	default m_isHotSpotWidthOverriden = false;
	default m_isGameDifficultyOverriden = false;
	
	var m_logic             : WristWrestlingLogic;
	
	var m_isUsingPad : bool;
	
	// Bar
	//                pointer
	//      -------------V------------
	// LOSE            (   )           WIN
	//      --------------------------
	//                hotspot
	//                 barPos
	
	public function SetHotSpotWidth( minWidth : int, maxWidth : int )
	{
		m_overridenHotSpotMinWidth = minWidth;
		m_overridenHotSpotMaxWidth = maxWidth;
		m_isHotSpotWidthOverriden = true;
	}
	public function EnableHotSpotWidthOverride( enable : bool )
	{
		m_isHotSpotWidthOverriden = enable;
	}
	
	public function SetGameDifficulty( gameDifficulty : EMWW_GameDifficulty )
	{
		m_overridenDifficulty = gameDifficulty;
		m_isGameDifficultyOverriden = true;
	}
	public function EnableGameDifficultyOverride( enable : bool )
	{
		m_isGameDifficultyOverriden = enable;
	}
	
	private function InitVariables()
	{
		m_guiBarMinValue  = -250;
		m_guiBarMaxValue  = 250;
		
		m_humanPlayerIdx  = 0;
		m_round           = 0;
		
		m_guiPointerPos = 0;
		
		AS_wristWrestling = -1;
		
		players = GetPlayers();
	}
	
	event OnActivatePlayersMimic()
	{
		return true;
	}
	
	event OnStarted()
	{
		var wp      : CComponent;
		var i       : int;
		var minigameDifficulty : EAIMinigameDifficulty;
		
		m_isUsingPad = theGame.IsUsingPad();

		switch ( m_gameType )
		{
			case MWWGT_Simple:
				m_logic = new WristWrestlingLogicSimple in this;
				break;
			case MWWGT_SimpleCont:
				m_logic = new WristWrestlingLogicSimpleCont in this;
				break;
			case MWWGT_Newton:
				m_logic = new WristWrestlingLogicNewton in this;
				break;
			case MWWGT_Mash:
				m_logic = new WristWrestlingLogicMash in this;
				break;
			default:
				m_logic = new WristWrestlingLogicNewton in this;
				break;
		}
		
		InitVariables();
		
		// Check number of players
		if ( players.Size() != 2 )
		{
			LogChannel( 'Minigame', "Not enough players for Wrist Wrestling" );
			return false;
		}
		
		// Set game params
		for ( i = 0; i < m_gameParams.Size(); i += 1 )
		{
			if ( players[0].HasTag( m_gameParams[i].m_playerTag )
				|| players[1].HasTag( m_gameParams[i].m_playerTag ) )
			{
				m_hotSpotMinWidth = m_gameParams[i].m_hotSpotMinWidth;
				m_hotSpotMaxWidth = m_gameParams[i].m_hotSpotMaxWidth;
				m_difficulty      = m_gameParams[i].m_gameDifficulty;
				break;
			}
		}
		
		// Get game params from NPC
		if ( players[0] != thePlayer )
		{
			if ( GetWristWrestlingNPCParams( players[0], m_hotSpotMinWidth, m_hotSpotMaxWidth, minigameDifficulty ) )
			{
				if ( minigameDifficulty == AIMD_Easy ) m_difficulty = MWWGD_Easy;
				else if ( minigameDifficulty == AIMD_Normal ) m_difficulty = MWWGD_Normal;
				else if ( minigameDifficulty == AIMD_Hard ) m_difficulty = MWWGD_Nightmare;
			}
		}
		else
		{
			if ( GetWristWrestlingNPCParams( players[1], m_hotSpotMinWidth, m_hotSpotMaxWidth, minigameDifficulty ) )
			{
				if ( minigameDifficulty == AIMD_Easy ) m_difficulty = MWWGD_Easy;
				else if ( minigameDifficulty == AIMD_Normal ) m_difficulty = MWWGD_Normal;
				else if ( minigameDifficulty == AIMD_Hard ) m_difficulty = MWWGD_Nightmare;
			}
		}
		
		if ( m_isHotSpotWidthOverriden )
		{
			m_hotSpotMinWidth = m_overridenHotSpotMinWidth;
			m_hotSpotMaxWidth = m_overridenHotSpotMaxWidth;
		}
		
		// So designers will not have to change hot spot min/max values
		m_hotSpotMinWidth *= 5;
		m_hotSpotMaxWidth *= 5;
		
		if ( m_isGameDifficultyOverriden )
		{
			m_difficulty = m_overridenDifficulty;
		}

		m_logic.Init( m_difficulty );

		// Lock players
		for ( i = 0; i < 2; i += 1 )
		{
			//wp = GetComponent( "player" + i );
			//players[i].EnterMinigameState( wp, 'wrist_wrestling' );
			players[i].EnterMinigameState( NULL, 'wrist_wrestling' );
			//players[i].SetErrorState( "Let's play!" );
			
			//players[i].GetMovingAgentComponent().SetEnabled( false );
			//players[i].ActionCancelAll();
		}
		
		//AttachCameraBehavior( 'wrist_wrestling' );

		if ( IsHudNeeded() )
		{
			theHud.m_hud.ShowTutorial("tut49", "", false);
			//theHud.ShowTutorialPanelOld( "tut49", "" );
			
			theHud.ShowWristWrestling();
			//theHud.LoadNewElement( "gui_wrist", true, true, true );
			
			EnableDebugFragments( true, 0 );
		}
		
		//theHud.EnableInput( true, true, false );
				
		LogChannel( 'Minigame', "******************" );
		LogChannel( 'Minigame', "Wrist Wrestling started" );
		
		theHud.m_hud.ShowTutorial("tut49", "", false);
		//theHud.ShowTutorialPanelOld( "tut49", "" );
		
		StateInit();

		return true;
	}
	
	event OnEnded( winnerIdx : int )
	{
		var players : array< CActor >;
		var i       : int;
		
		// Release players
		players = GetPlayers();
		for ( i = players.Size() - 1; i >= 0; i -= 1 )
		{
			players[i].ExitMinigameState();
		}
		
		if ( IsHudNeeded() )
		{
			AS_wristWrestling = -1;
			
			//theHud.LoadNewElement( "gui_hud", true, true, true );
			theHud.HideWristWrestling();
			theHud.EnableInput( true, true, false );
		}
		
		EnableDebugFragments( false, 0 );

		if ( winnerIdx < 0 )
		{
			LogChannel( 'Minigame', "Wrist wrestling ended, no winner" );
		}
		else
		{
			LogChannel( 'Minigame', "Wrist wrestling ended, the winner is " + players[ winnerIdx ].GetName() );
			players[ winnerIdx ].SetErrorState( "I have won the whole game!" );
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		var cursorX, cursorY, viewWidth, viewHeight : float;
		var rayStart, rayDirection					: Vector;
		var collidedComponent    					: CComponent;
		var collidedRigidBodyIdx 					: int;
		var i                    					: int;
		var leftAxis             					: bool;
		var mouseAxis : bool;
		var passInput : bool;

		leftAxis = (key == 'GI_AxisLeftX');
		mouseAxis = (key == 'GI_MouseX' );
		//LogChannel( 'rychu1', "Key: " + key + " Value: " + value ) ;
		
		if ( m_isUsingPad )
		{
			if ( leftAxis )
			{
				passInput = true;
			}
			else
			{
				passInput = false;
			}
		}
		else
		{
			if ( mouseAxis )
			{
				passInput = true;
			}
			else
			{
				passInput = false;
			}
		}
		
		//if ( leftAxis || // currently: A,D
			// rightAxis ) // currently: keyboard cursor, mouse
		if ( passInput )
		{
			//theHud.GetFloat( "_xmouse", cursorX );
			//theHud.GetFloat( "_ymouse", cursorY );
			
			m_logic.UpdateInput( value );

			if ( leftAxis )
			{
				
			}
			else
			{
			}
		
			// MainFrame.SetPointer(x) zeby ustawic wskaznik w odpowiedniej pozycji. x podajesz od -50 do 50
			// MainFrame.SetArea(x1,x2) - ustawiasz to pole na ktorym gracz musi trzymac wskaznik. x1 to pozycja pola tak jak przy SetPointer, x2 to jego szerokosc
			return true;
		}
		
		if ( key == 'GI_1' && value < 0.5f )
		{
			// ...
			return true;
		}
		else if ( key == 'GI_AttackFast' && value < 0.5f )
		{
			theHud.GetFloat( "_xmouse", cursorX );
			theHud.GetFloat( "_ymouse", cursorY );
				
			//StateFinishGame( 1 );

			return true;
		}
		return false;
	}
	
	final function IsHudNeeded() : bool
	{
		return m_humanPlayerIdx >= 0;
	}
	
	final function UpdateHud()
	{
		// Update HUD status
		//theHud.SetFloat( "m_player0money",  m_playerStatus[0].m_money,      AS_wristWrestling );
		//theHud.InvokeMethod( "UpdateHud", AS_wristWrestling );
	}
	
	latent final function WaitForHudResponse()
	{
		var isDone : bool;
		isDone = true;
		do {

			Sleep( 0.1f );
			//theHud.GetBool( "m_done", isDone, AS_wristWrestling );

		} while ( !isDone );
	}
	
	function UpdateGUI()
	{
		var areaArgs : array<string>;
		var pointerState : int;

		m_guiPointerPos = (int)(m_guiBarMinValue + ( (m_guiBarMaxValue - m_guiBarMinValue) * ((m_logic.GetPointerPos() + 1.0) / 2.0) ));

		m_guiHotSpotWidth = GuiGetHotSpotWidth();
		m_guiHotSpotPos   = GuiGetHotSpotPosition();

		// Old GUI
		//areaArgs.PushBack( m_guiHotSpotPos );
		//areaArgs.PushBack( m_guiHotSpotWidth );
		//theHud.InvokeManyArgs("MainFrame.SetArea", areaArgs );
		//theHud.InvokeOneArg("MainFrame.SetPointer", m_guiPointerPos );
		
		// New GUI
		if ( IsPointerInHotSpot() )
		{
			pointerState = 0;
		}
		else
		{
			pointerState = 1;
		}

		theHud.GetWristWrestlingPanel().SetArea( m_guiHotSpotPos, m_guiHotSpotWidth );
		theHud.GetWristWrestlingPanel().SetPointer( m_guiPointerPos );
		theHud.GetWristWrestlingPanel().SetPointerState( pointerState );

		// Fallback GUI
		WristWrestlingSetArea( m_logic.GetBarPos(), m_logic.GetBarWidthScale() );
		WristWrestlingSetPointer( m_logic.GetPointerPos() );
		WristWrestlingSetParams( m_hotSpotMinWidth, m_hotSpotMaxWidth, IsPointerInHotSpot() );
	}
	
	function UpdateLogic( timeDelta : float )
	{
		if ( m_logic.UpdateLogic( IsPointerInHotSpot(), timeDelta ) )
		{
			RemoveTimer( 'WristWrestlingTimer' );
			StateFinishGame( m_logic.GetWinner() );
		}
	}

	// GUI calculate method
	function GuiGetHotSpotWidth() : int
	{
		var scale : float;
		var barPos : float = m_logic.GetBarPos();

		if ( barPos >= 0 )
		{
			scale = 1 - barPos;
		}
		else
		{
			scale = 1 + barPos;
		}
		
		scale *= m_logic.GetBarWidthScale();
		
		return (int)((scale * (m_hotSpotMaxWidth - m_hotSpotMinWidth)) + m_hotSpotMinWidth);
	}
	
	// GUI calculate method
	function GuiGetHotSpotPosition() : int
	{
		var guiBarPos : int;
		
		guiBarPos = (int)(m_guiBarMinValue + ( (m_guiBarMaxValue - m_guiBarMinValue) * ((m_logic.GetBarPos() + 1.0) / 2.0) ));
		
		return (guiBarPos - (m_guiHotSpotWidth / 2));
	}
	
	function IsPointerInHotSpot() : bool
	{
		if ( (m_guiPointerPos >= m_guiHotSpotPos) && (m_guiPointerPos < (m_guiHotSpotPos + m_guiHotSpotWidth)) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	latent function InitGraphics()
	{
		var i : int;
		var v0 : Vector;
		var v1 : Vector;
		var r0, r1 : EulerAngles;
		var worldPos : Vector = GetWorldPosition();
		var worldRot : EulerAngles = GetWorldRotation();
		var startPlace : CWayPointComponent;
		
		startPlace = FindWaypoint( m_startPos );
		if ( startPlace )
		{
			worldPos = startPlace.GetWorldPosition();
			worldRot = startPlace.GetWorldRotation();
		}
		
		//var playerOne, playerTwo : Vector;
		//GetStartingTrajectories( 'ww_wrestle_idle1', playerOne, playerTwo );

		v0 = worldPos;
		v1 = worldPos;
		r0 = EulerAngles( worldRot.Pitch, worldRot.Yaw, worldRot.Roll );
		r1 = EulerAngles( worldRot.Pitch, worldRot.Yaw + 180, worldRot.Roll );
		
		
		TeleportCamera( worldPos, worldRot );

		// obsolete, use 'players[1].GetMovingAgentComponent().SetEnabled( false );' instead
		/*players[0].GetMovingAgentComponent().SetEnabledRestorePosition( false );
		players[1].GetMovingAgentComponent().SetEnabledRestorePosition( false );
		*/
		players[0].ActionCancelAll();
		players[1].ActionCancelAll();
		
		players[0].GetMovingAgentComponent().SetEnabled( false );
		players[1].GetMovingAgentComponent().SetEnabled( false );
		

		
		if ( players[1].GetMovingAgentComponent().IsEnabled() ||
			players[0].GetMovingAgentComponent().IsEnabled() )
		{
			LogChannel( 'WristWrestling', "Pathengine is not disabled when teleporting" );
		}
		
		/*
		players[0].ActionCancelAll();
		players[1].ActionCancelAll();

		while ( players[0].GetCurrentActionType() != ActorAction_None )
		{
			Sleep( 0.1 );
		}
		while ( players[1].GetCurrentActionType() != ActorAction_None )
		{
			Sleep( 0.1 );
		}
		*/
		
		players[0].TeleportWithRotation( v0, r0 );
		players[1].TeleportWithRotation( v1, r1 );
		
		theGame.FadeIn( 0.5 );
		
		Sleep( 1.0 );
		SendEventToCamera( 'wrestle_ready' );
		for ( i = 0; i < 2; i += 1 )
		{
			players[i].RaiseEvent( 'wrestle_ready' );
		}
		Sleep( 2.0 );
		SendEventToCamera( 'wrestle_start' );
		for ( i = 0; i < 2; i += 1 )
		{
			players[i].RaiseEvent( 'wrestle_start' );
			players[i].SetBehaviorMimicVariable( "wrestle_anim_select", 0);
			players[i].SetBehaviorMimicVariable( "wrestle_weight", 1);
		}
	}
	
	function UpdateGraphics()
	{
		var i : int;

		for ( i = 0; i < 2; i += 1 )
		{
			players[i].SetBehaviorVariable( 'wrestle_progress', m_logic.GetBarPos() );
		}
		players[0].SetBehaviorMimicVariable( "wrestle_progress", m_logic.GetBarPos());
		players[1].SetBehaviorMimicVariable( "wrestle_progress", ( 1-m_logic.GetBarPos() ) );
		SetCameraFloatVariable( "wrestle_progress", m_logic.GetBarPos() );
	}
	
	latent function PlayPlayerWin()
	{
		SendEventToCamera( 'wrestle_win' );
		players[0].RaiseEvent( 'wrestle_win' );
		players[0].SetBehaviorMimicVariable( "wrestle_anim_select", 1);
		//players[1].RaiseEvent( 'wrestle_lose' );
		players[1].RaiseEvent( 'wrestle_win' );
		players[1].SetBehaviorMimicVariable( "wrestle_anim_select", 2);

		if ( thePlayer.GetLastBribe() > 0 ) 
		{
			thePlayer.GetInventory().AddItem( 'Orens', thePlayer.GetLastBribe() );
			thePlayer.SetLastBribe(0);
		}

		FactsAdd("Won_Wrestling", 1);
		
		Sleep( 1.0 );
	}
	
	latent function PlayPlayerLose()
	{
		SendEventToCamera( 'wrestle_lose' );
		players[0].RaiseEvent( 'wrestle_lose' );
		players[0].SetBehaviorMimicVariable( "wrestle_anim_select", 2);
		//players[1].RaiseEvent( 'wrestle_win' );
		players[1].RaiseEvent( 'wrestle_lose' );
		players[1].SetBehaviorMimicVariable( "wrestle_anim_select", 1);

		if ( thePlayer.GetLastBribe() > 0 ) 
		{
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Orens'), thePlayer.GetLastBribe() );
			thePlayer.SetLastBribe(0);
		}
		
		Sleep( 1.0 );
		
		//theHud.LoadNewElement( "endgame", true, true, true );
		//Sleep( 2.5 );
	}

	timer function WristWrestlingTimer( timeDelta : float )
	{
		var i : int;
		
		UpdateLogic( timeDelta );
		UpdateGUI();
		UpdateGraphics();
	}
	
	function OnInitializedStateInit()
	{
		AddTimer( 'WristWrestlingTimer', 0.1f, true );
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

state Game in W2MinigameWristWrestling
{
	entry function StateInit()
	{
		var i : int;
		
		// Set initial blackscreen, because we are doing some thing with camera
		theGame.FadeOut( 0.0f );
		
		while ( ! theHud.GetWristWrestlingPanel().IsLoaded() )
		{
			Sleep( 0.1 );
		}
		
		theHud.EnableInput( true, true, false );

		parent.m_round = 0;
		
		// Attach camera behavior
		i = 0;
		while ( i < 5 ) // the number of trials
		{
			if ( parent.AttachCameraBehavior( 'wrist_wrestling' ) )
			{
				// leave loop on success
				break;
			}
			Sleep( 0.1 );
			i += 1;
		}

		if ( parent.IsHudNeeded() )
		{ 
			parent.UpdateHud();
		}

		parent.InitGraphics();
		
		parent.OnInitializedStateInit();
		
		//parent.StateThrow( 0 );
	}

	entry function StateThrow( playerIdx : int )
	{
		var players : array< CActor >;
		var player  : CActor;
		var isDone  : bool;
		
		//parent.SendEventToCamera( 'dialogset_2_vs_1' );
		
		players = parent.GetPlayers();
		//player  = players[ playerIdx ];
		
		// Wait till pressing [THROW]
		{
			//LogChannel( 'Minigame', player.GetName() + " will throw dices" );
			
			// If it is thePlayer turn, wait till player will throw
			//if ( player == thePlayer )
			{
				//theHud.InvokeMethod( "ShowThrowPanel", parent.AS_wristWrestling );
				//parent.WaitForHudResponse();
			}
			//else
			{
				Sleep( 1.f );
			}
		}

		//if ( playerIdx < parent.m_playerStatus.Size()-1 )
			//parent.StateThrow( playerIdx + 1 );
		//else
			//parent.StateFinishRound();
	}
	
	entry function StateFinishRound()
	{
		
		//var players   : array< CActor >;
		//var winnerIdx : int;
		
		//parent.m_round += 1;
		
		//winnerIdx = parent.GetWinner( 0, 1 );
		//if ( winnerIdx >= 0 )
		//{
			//players = parent.GetPlayers();
			//players[ winnerIdx ].SetErrorState( "I have won this round" );
			//LogChannel( 'Minigame', players[ winnerIdx ].GetName() + " has won this round" );
		
			//parent.m_playerStatus[ winnerIdx ].m_wins += 1;
			//if ( parent.m_playerStatus[ winnerIdx ].m_wins > 1 )
			//{
				//parent.StateFinishGame( winnerIdx );
//			}
		//}
		//LogChannel( 'Minigame', "------------------" );
		
		// Wait till player will go ahead
		//if ( parent.IsHudNeeded() )
		//{
			//parent.UpdateHud();
			//theHud.InvokeMethod( "ShowFinishRoundPanel", parent.AS_wristWrestling );
			//parent.WaitForHudResponse();
			
			//theHud.InvokeMethod( "ShowBidPanel", parent.AS_wristWrestling );
			//parent.WaitForHudResponse();
			
			//theHud.GetFloat( "m_stake", parent.m_stake, parent.AS_wristWrestling );
			//theHud.GetFloat( "m_player0money", parent.m_playerStatus[0].m_money, parent.AS_wristWrestling );
		//	theHud.GetFloat( "m_player1money", parent.m_playerStatus[1].m_money, parent.AS_wristWrestling );
		//}
		//else
		//{
	//		Sleep( 1.f );
		//}
				
		//parent.StateThrow( 0 );
	}
	
	entry function StateFinishGame( winnerIdx : int )
	{
		LogChannel( 'rychu', "StateFinishGame" );
		if ( winnerIdx == 0 )
		{
			parent.PlayPlayerWin();
		}
		else
		{
			parent.PlayPlayerLose();
		}
		
		if ( parent.IsHudNeeded() )
		{
			parent.UpdateHud();
			//theHud.InvokeMethod( "ShowFinishGamePanel", parent.AS_wristWrestling );
			parent.WaitForHudResponse();
		}
		else
		{
			Sleep( 1.f );
		}
		
		//parent.DetachCameraBehavior( 'wrist_wrestling' );
		
		// obsolete, use 'players[1].GetMovingAgentComponent().SetEnabled( false );' instead
		//parent.players[0].GetMovingAgentComponent().SetEnabledRestorePosition( true );
		//parent.players[1].GetMovingAgentComponent().SetEnabledRestorePosition( true );
		theGame.FadeOut( 1.0 );
		
		parent.players[0].SetBehaviorMimicVariable( "wrestle_weight", 0);
		parent.players[1].SetBehaviorMimicVariable( "wrestle_weight", 0);

		parent.players[0].GetMovingAgentComponent().SetEnabled( true );
		parent.players[1].GetMovingAgentComponent().SetEnabled( true );
		
		parent.DetachCameraBehavior( 'wrist_wrestling' );
		//parent.EndGame( winnerIdx == 0 );
		parent.DoEnd( winnerIdx == 0 );
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class WristWrestlingLogic
{
	public function Init( difficulty : EMWW_GameDifficulty )
	{
	}
	
	// value [-1,1]
	public function UpdateInput( value : float )
	{
	}
	
	public function GetBarPos() : float
	{
		return 0.0;
	}
	
	public function GetPointerPos() : float
	{
		return 0.0;
	}
	
	// returns true if game has finnished
	public function UpdateLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		return true;
	}
	
	public function GetWinner() : int
	{
		return -1;
	}
	
	public function GetBarWidthScale() : float
	{
		return 1.0f;
	}
}

class WristWrestlingLogicSimple extends WristWrestlingLogic
{
	// Game logic runtime data
	var m_barPos			: float; // [-1,1]
	var m_pointerPos	    : float; // [-1,1]
	var m_barInteriaTimer	: float;
	var m_lastInHotspot		: bool;  // was cursor in hotspot in the last game logic update?
	var m_isUsingPad		: bool;  // true if player is using PAD, false if player is using mouse
	var m_winner			: int;
	var m_tiredFactor		: float; // [0, 1] the longer wrist wrestling takes time the more tired player is (0 - rested, 1 - tired)
	var m_barSpeed          : float;

	public function Init( difficulty : EMWW_GameDifficulty )
	{
		InitVariables();
	}
	
	public function UpdateInput( value : float )
	{
		if ( m_isUsingPad )
		{
			SetPointerPos( value );
		}
		else
		{
			// Keep in bounds (XBox cursorX/Y max is +1/-1, but not Windows mouse)
			if ( value > 1.0 ) value = 1.0;
			if ( value < -1.0 ) value = -1.0;

			SetPointerPos( m_pointerPos + value * 0.02 );
		}
	}
	
	public function GetBarPos() : float
	{
		return m_barPos;
	}
	
	public function GetPointerPos() : float
	{
		return m_pointerPos;
	}

	public function UpdateLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		return ProcessLogic( isPointerInHotSpot, timeDelta );
	}
	
	public function GetWinner() : int
	{
		return m_winner;
	}
	
	public function GetBarWidthScale() : float
	{
		var scale : float;
		scale = 1.0 - m_tiredFactor;
		if ( scale < 0.3 )
		{
			scale = 0.3;
		}
		return scale;
	}
	
	// pos [-1,1]
	private function SetPointerPos( pos : float )
	{
		// keep in range
		if ( pos > 1 ) pos = 1;
		if ( pos < -1 ) pos = -1;
		m_pointerPos = pos;
	}
	
	private function InitVariables()
	{
		m_winner = -1;
		m_pointerPos = 0;
		m_barPos = 0;
		m_barInteriaTimer	= 0;
		m_lastInHotspot = true;
		m_isUsingPad = theGame.IsUsingPad();
		m_tiredFactor = 0.0;
		m_barSpeed = 0.1;
	}
	
	function ProcessLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		if ( isPointerInHotSpot )
		{
			if ( m_barInteriaTimer > 0 )
			{
				m_barInteriaTimer -= timeDelta;
				m_barPos -= timeDelta * m_barSpeed;
			}
			else
			{
				m_barPos += timeDelta * m_barSpeed;
			}
			m_lastInHotspot = true;
		}
		else
		{
			if ( m_lastInHotspot )
			{
				m_barInteriaTimer = 1.0; // seconds
			}

			m_barPos -= timeDelta * m_barSpeed;
			m_lastInHotspot = false;
		}
		
		// Calculate tired factor
		if ( m_tiredFactor < 1 )
		{
			m_tiredFactor += timeDelta * 0.03;
			//Log( "TIRED: " + m_tiredFactor );
		}
		
		// Calculate bar speed
		if ( m_tiredFactor > 0.5 )
		{
			m_barSpeed += 0.01 * timeDelta;
			
			// keep in bounds
			if ( m_barSpeed > 0.5 )
			{
				m_barSpeed = 0.5;
			}
		}
		
		if ( m_barPos >= 0.9 )
		{
			m_winner = 0;
			return true;
		}
		else if ( m_barPos < -0.9 )
		{
			m_winner = 1;
			return true;
		}
		
		return false;
	}
}

class WristWrestlingLogicSimpleCont extends WristWrestlingLogicSimple
{
	var m_barShift : float;
	
	default m_barShift = 0;

	public function UpdateInput( value : float )
	{
		if ( m_isUsingPad )
		{
			m_barShift = value * 0.03;
			SetPointerPos( m_pointerPos + value * 0.02 );
		}
		else
		{
			// Keep in bounds (XBox cursorX/Y max is +1/-1, but not Windows mouse)
			if ( value > 1.0 ) value = 1.0;
			if ( value < -1.0 ) value = -1.0;
		
			m_barShift = value * 0.03;
			SetPointerPos( m_pointerPos + value * 0.02 );
		}
	}
	
	public function UpdateLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		var result : bool;
		
		SetPointerPos( m_pointerPos + m_barShift );
		result = ProcessLogic( isPointerInHotSpot, timeDelta );
		
		return result;
	}
}

class WristWrestlingLogicNewton extends WristWrestlingLogicSimple
{
	var m_barVelocity		    : float; // scalar
	var m_barAcceleration	    : float; // scalar
	var m_barMass               : float;
	var m_distractingForce      : float;
	var m_distractingForceCurr  : float; 
	var m_distractingForceTimer : float;

	default m_barAcceleration       = 0;
	default m_barVelocity           = 0;
	default m_barMass               = 0.5;
	default m_distractingForce      = 0.0;
	default m_distractingForceCurr  = 0.0;
	default m_distractingForceTimer = 0.0;
	
	public function Init( difficulty : EMWW_GameDifficulty )
	{
		super.Init( difficulty );
		ApplyDifficultySettings( difficulty );
	}

	public function UpdateInput( value : float )
	{
		if ( m_isUsingPad )
		{
			m_barAcceleration = value / (m_barMass * 3.0);
		}
		else
		{
			// Log( "Mouse value: " + value );
			// Keep in bounds (XBox cursorX/Y max is +1/-1, but not Windows mouse)
			if ( value > 1.0 ) value = 1.0;
			if ( value < -1.0 ) value = -1.0;

			m_barAcceleration = value / (m_barMass * 6.0);
			//LogChannel( 'acceler', "ACC: " + m_barAcceleration + " Vel: " + m_barVelocity + " Value: " + value );
			//LogChannel( 'wristwrestling', "Input value = " + value );
		}
	}
	
	public function UpdateLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		var result : bool;
		
		//LogChannel( 'Wristwrestling', "Acceleration : " + m_barAcceleration );
		//LogChannel( 'Wristwrestling', "Velocity : " + m_barVelocity );
		
		// Distracting force
		m_distractingForceTimer -= timeDelta;
		if ( m_distractingForceTimer <= 0 )
		{
			m_distractingForce = -m_distractingForce;
			//m_distractingForceTimer = RandF() * 0.5;
			m_distractingForceTimer = 0.3;
			//m_distractingForceCurr = RandF() * m_distractingForce;
			m_distractingForceCurr = m_distractingForce;
			//LogChannel( 'Wristwrestling', "m_distractingForceCurr : " + m_distractingForceCurr );
		}
		m_barVelocity += m_distractingForceCurr * timeDelta;
		
		m_barVelocity += m_barAcceleration * timeDelta;
		
		// keep max velocity
		if ( m_barVelocity > 1.0 )
		{
			 m_barVelocity = 1.0;
		}
		else if ( m_barVelocity < -1.0 )
		{
			m_barVelocity = -1.0;
		}
		
		SetPointerPos( m_pointerPos + (m_barVelocity * timeDelta) );
		result = ProcessLogic( isPointerInHotSpot, timeDelta );
		
		return result;
	}
	
	private function ApplyDifficultySettings( difficulty : EMWW_GameDifficulty )
	{
		if ( difficulty == MWWGD_Easy )
		{
			m_barMass = 0.5;
			m_distractingForce = 0.2;
		}
		else if ( difficulty == MWWGD_Normal )
		{
			//m_barMass = 0.5;
			m_distractingForce = 0.4;
		}
		else if ( difficulty == MWWGD_Nightmare )
		{
			//m_barMass = 0.2;
			m_distractingForce = 0.8;
		}
	}
}

class WristWrestlingLogicMash extends WristWrestlingLogicSimple
{
	var m_barVelocity		: float; // scalar
	var m_barAcceleration	: float; // scalar
	var m_barMass           : float;

	default m_barAcceleration = 0;
	default m_barVelocity     = 0;
	default m_barMass         = 2.0;

	public function UpdateInput( value : float )
	{
		if ( m_isUsingPad )
		{
			m_barAcceleration = value / m_barMass;
		}
		else
		{
			value = AbsF( value );
			if ( value > 0.001 )
			{
				m_barAcceleration = value / (m_barMass * 2.0 );
			}
		}
	}
	
	public function UpdateLogic( isPointerInHotSpot : bool, timeDelta : float ) : bool
	{
		var result : bool;
		
		if ( m_barVelocity > 0 )
		{
			m_barAcceleration -= timeDelta * 0.8;
		}
		else
		{
			m_barAcceleration -= timeDelta * 0.5;
		}
		
		// maximum acceleration
		if ( m_barVelocity > 0 && m_barAcceleration < -3.0 )
		{
			m_barAcceleration = -3.0;
		}
		else if ( m_barVelocity <= 0 && m_barAcceleration < -2.5 )
		{
			m_barAcceleration = -2.5;
		}
		else if ( m_barVelocity > 0 && m_barAcceleration > 1.2 )
		{
			m_barAcceleration = 1.2;
		}
		else if ( m_barVelocity <= 0 && m_barAcceleration > 2.0 )
		{
			m_barAcceleration = 2.0;
		}
		
		m_barVelocity += m_barAcceleration * timeDelta;
		
		// maximum velocity
		if ( m_barVelocity > 0.2 )
		{
			m_barVelocity = 0.2;
		}
		else if ( m_barVelocity < -0.3 )
		{
			m_barVelocity = -0.3;
		}
		
		SetPointerPos( m_pointerPos + (m_barVelocity * timeDelta) );
		result = ProcessLogic( isPointerInHotSpot, timeDelta );
		
		//LogChannel ( 'WristWrestling', "Acceleration : " +  m_barAcceleration );
		//LogChannel ( 'WristWrestling', "Velocity : "     +  m_barVelocity );
		
		return result;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

quest function QWristWrestlingSetWidth( gameTag : name, minWidth : int, maxWidth : int ) : bool
{
	var minigame : W2MinigameWristWrestling;
	
	minigame = (W2MinigameWristWrestling) theGame.GetEntityByTag( gameTag );
	if ( minigame )
	{
		minigame.SetHotSpotWidth( minWidth, maxWidth );
		return true;
	}
	
	return false;
}

quest function QWristWrestlingSetDifficulty( gameTag : name, difficulty : EMWW_GameDifficulty ) : bool
{
	var minigame : W2MinigameWristWrestling;
	
	minigame = (W2MinigameWristWrestling) theGame.GetEntityByTag( gameTag );
	if ( minigame )
	{
		minigame.SetGameDifficulty( difficulty );
		return true;
	}
	
	return false;
}

quest function QWristWrestlingGameParams( gameTag : name, minWidth : int, maxWidth : int, difficulty : EMWW_GameDifficulty ) : bool
{
	var minigame : W2MinigameWristWrestling;
	
	minigame = (W2MinigameWristWrestling) theGame.GetEntityByTag( gameTag );
	if ( minigame )
	{
		minigame.SetHotSpotWidth( minWidth, maxWidth );
		minigame.SetGameDifficulty( difficulty );
		return true;
	}
	
	return false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
