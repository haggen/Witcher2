/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Axii Minigame
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

struct W2MinigameAxii_GameParams
{
	public editable var m_GameTime				: float; // how long the minigame last
	public editable var m_ClickCountLimit		: int;   // player will win after successful click (if 0 than this win method is disabled)
	public editable var m_VelocityChangeFactor	: float; // how fast the velocity changes
	public editable var m_InitAcceleration		: float; // initial acceleration of the pointer
	public editable var m_ClickFailTolerance	: int;   // the number of bad clicks that player can do
	
	default m_GameTime				= 5;
	default m_ClickCountLimit		= 4;
	default m_VelocityChangeFactor	= 0.5f;
	default m_InitAcceleration		= 4.0f;
	default m_ClickFailTolerance	= 1;
}

class W2MinigameAxii extends CMinigame
{
	// Game configuration
	public editable var m_borderMinWidth : int;
	public editable var m_borderMaxWidth : int;
	public editable var m_defaultParams  : W2MinigameAxii_GameParams;
	
	default m_borderMinWidth = 0;   // -150
	default m_borderMaxWidth = 100; // 100
	
	// GUI configuration (change values only if flash changes)
	var m_guiConfBorderMinWidth		: int;
	var m_guiConfBorderMaxWidth		: int;
	var m_guiConfPointerMinValue	: int; // GUI flash minimum pointer value
	var m_guiConfPointerMaxValue	: int; // GUI flash maximum pointer value
	var m_guiConfTimeMaxValue       : int; // min value is 0

	// Current runtime GUI data
	var m_guiCurrPointerPos		: int;
	var m_guiCurrBorderWidth	: int;
	var m_guiCurrTimePos		: int;
	
	var players 			: array< CActor >; // should contain only one player - thePlayer
	var m_humanPlayerIdx	: int;             // player index - should be always 0

	var m_logic : AxiiMinigameLogic;
	
	// Bar
	//                pointer
	//      --------------------------
	//      |   |        $       |   |  
	//      --------------------------
	//                hotspot
	//                 barPos
	
	private function InitVariables()
	{
		m_guiConfBorderMinWidth		= m_borderMinWidth;
		m_guiConfBorderMaxWidth		= m_borderMaxWidth;
		m_guiConfPointerMinValue	= -199;
		m_guiConfPointerMaxValue	= 199;
		m_guiConfTimeMaxValue       = 100;

		m_humanPlayerIdx = 0;
	
		players = GetPlayers();
	}
	
	event OnStarted()
	{
		var wp      : CComponent;
		var i       : int;

		m_logic = new AxiiMinigameLogicSimple in this;

		InitVariables();
		
		// Check number of players
		if ( players.Size() != 1 )
		{
			LogChannel( 'Minigame', "Not enough players for Axii Minigame" );
			return false;
		}
		
		m_logic.Init( m_defaultParams );

		// Lock players
		for ( i = 0; i < 2; i += 1 )
		{
			//players[i].EnterMinigameState( NULL, 'wrist_wrestling' );
			//players[i].SetErrorState( "Let's play!" );
		}
		
		thePlayer.SetManualControl( false, false );
		
		//AttachCameraBehavior( 'wrist_wrestling' );

		//theHud.LoadNewElement( "gui_axii", true, true, true );
		// TODO
		theHud.InvokeOneArg( "SetCursorPos", FlashValueFromInt( -199 ) );
		theHud.Invoke( "showAxiiQTA" );
				
		//LogChannel( 'Minigame', "******************" );
		//LogChannel( 'Minigame', "Wrist Wrestling started" );
		
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
			//players[i].ExitMinigameState();
		}
		
		if ( IsHudNeeded() )
		{
			//theHud.LoadNewElement( "gui_hud", true, true, true );
			// TODO
			theHud.Invoke( "hideAxiiQTA" );
		}

		if ( winnerIdx < 0 )
		{
			//LogChannel( 'Minigame', "Wrist wrestling ended, no winner" );
		}
		else
		{
			//LogChannel( 'Minigame', "Wrist wrestling ended, the winner is " + players[ winnerIdx ].GetName() );
			//players[ winnerIdx ].SetErrorState( "I have won the whole game!" );
			// dbg
			/*
			if ( winnerIdx == 0 )
			{
				thePlayer.SetErrorState( "WIN" );
			}
			else if ( winnerIdx == 1 )
			{
				thePlayer.SetErrorState( "Loose" );
			}
			else
			{
				thePlayer.SetErrorState( "Shit" );
			}
			*/
		}
		
		//DetachCameraBehavior( 'wrist_wrestling' );
		thePlayer.SetManualControl( true, true );
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		var cursorX, cursorY, viewWidth, viewHeight : float;
		var rayStart, rayDirection					: Vector;
		var collidedComponent    					: CComponent;
		var collidedRigidBodyIdx 					: int;
		var i                    					: int;
		var leftAxis             					: bool;
		var rightAxis            					: bool;

		leftAxis = (key == 'GI_AxisLeftX');
		rightAxis = (key == 'GI_AxisRightX');

		if ( leftAxis || rightAxis )
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
		}
		
		if ( key == 'GI_1' && value < 0.5f )
		{
			// ...
			return true;
		}
		else if ( key == 'GI_AttackFast' && value < 0.5f )
		{
			//theHud.GetFloat( "_xmouse", cursorX );
			//theHud.GetFloat( "_ymouse", cursorY );

			m_logic.SetCursorInLeftBorder( IsCursorInLeftBorder() );
			m_logic.SetCursorInRightBorder( IsCursorInRightBorder() );
			m_logic.UpdateInputButton( 0 );

			return true;
		}
		else if ( key == 'GI_AttackStrong' && value < 0.5f )
		{
			m_logic.SetCursorInLeftBorder( IsCursorInLeftBorder() );
			m_logic.SetCursorInRightBorder( IsCursorInRightBorder() );
			m_logic.UpdateInputButton( 1 );
			
			return true;
		}
		
		// block all keys in mingame
		return true;
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

		m_guiCurrPointerPos = (int)(m_guiConfPointerMinValue + ( (m_guiConfPointerMaxValue - m_guiConfPointerMinValue) * ((m_logic.GuiGetPointerPos() + 1.0) / 2.0) ));

		m_guiCurrBorderWidth = GuiCalcBorderWidth();
		
		m_guiCurrTimePos = (int)(m_logic.GuiGetCurrentTime() * m_guiConfTimeMaxValue);

		// TODO
		//areaArgs.PushBack( m_guiHotSpotPos );
		//areaArgs.PushBack( m_guiHotSpotWidth );
		//theHud.InvokeManyArgs("MainFrame.SetArea", areaArgs );
		
		//LogChannel( 'rythongui', "Cursor pos: " + m_guiCurrPointerPos );
		theHud.InvokeOneArg( "SetCursorPos", FlashValueFromInt( m_guiCurrPointerPos ) );
		theHud.InvokeOneArg( "SetBorderWidth", FlashValueFromInt( m_guiCurrBorderWidth ) );
		//theHud.InvokeOneArg( "SetTime", m_guiCurrTimePos );
		
		
		if ( m_logic.GuiDoShowSuccess() )
		{
			theHud.Invoke( "AxiiClickSuccess" );
		}
		if ( m_logic.GuiDoShowPointerDirChange() )
		{
			theSound.PlaySound( "witcher/magic/anim_axii_click" );
		}
	}
	
	function UpdateLogic( timeDelta : float )
	{
		if ( m_logic.UpdateLogic( timeDelta ) )
		{
			RemoveTimer( 'AxiiMinigameTimer' );
			StateFinishGame( m_logic.GetWinner() );
		}
	}

	// GUI calculate method
	function GuiCalcBorderWidth() : int
	{
		var scale : float;

		scale = m_logic.GuiGetBorderWidth();

		return (int)((scale * (m_guiConfBorderMaxWidth - m_guiConfBorderMinWidth)) + m_guiConfBorderMinWidth);
	}

	function IsCursorInLeftBorder() : bool
	{
		var res : string;
		var value : bool;
		// TODO
		//res = theHud.Invoke( "IsCursorInLeftBorder" );
		
		
		theHud.GetBool( "CursorInLeftBorder", value );
		
		
		//Log("a");
		
		return value;
	}
	
	function IsCursorInRightBorder() : bool
	{
		// TODO
		//var res : string = "xxx";
		var value : bool = true;
		// TODO
		//res = theHud.Invoke( "IsCursorInRightBorder" );
		
		
		theHud.GetBool( "CursorInRightBorder", value );
		
		//Log("a");
		
		return value;
	}
	
	latent function InitGraphics()
	{
		
	}
	
	function UpdateGraphics()
	{
		var i : int;

		for ( i = 0; i < 2; i += 1 )
		{
			//players[i].SetBehaviorVariable( 'wrestle_progress', m_logic.GetBarPos() );
		}
		
		//SetCameraFloatVariable( "wrestle_progress", m_logic.GetBarPos() );
	}
	
	latent function PlayPlayerWin()
	{
		//SendEventToCamera( 'wrestle_win' );
		//players[0].RaiseEvent( 'wrestle_win' );
		//players[1].RaiseEvent( 'wrestle_lose' );

		//Sleep( 1.0 );
	}
	
	latent function PlayPlayerLose()
	{
		//SendEventToCamera( 'wrestle_lose' );
		//players[0].RaiseEvent( 'wrestle_lose' );
		//players[1].RaiseEvent( 'wrestle_win' );

		//Sleep( 1.0 );
		
		//theHud.LoadNewElement( "endgame", true, true, true );
		//Sleep( 2.5 );
		
		// TODO
		theHud.Invoke( "AxiiFailure" );
		// Sleep( 0.1f );
	}

	timer function AxiiMinigameTimer( timeDelta : float )
	{
		//var value1 : bool = true;//dbg
		//var value2 : bool = true;//dbg

		var i : int;
		
		
		// rdbg
		
		//res = theHud.Invoke( "IsCursorInRightBorder" );
		//theHud.GetBool( "CursorInLeftBorder", value1 );
		//theHud.GetBool( "CursorInRightBorder", value2 );
		//LogChannel( 'kaczka', "Left: " + value1 + "   Right: " + value2 );
		// rdbg
		
		UpdateLogic( timeDelta );
		UpdateGUI();
		UpdateGraphics();
	}
	
	function OnInitializedStateInit()
	{
		AddTimer( 'AxiiMinigameTimer', 0.1f, true );
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

state Game in W2MinigameAxii
{
	entry function StateInit()
	{
		var i : int;


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
			// TODO: is any sleep needed ?
			//Sleep( 1.f );
		}
		
		//parent.DetachCameraBehavior( 'wrist_wrestling' );
		
		// obsolete, use 'players[1].GetMovingAgentComponent().SetEnabled( false );' instead
		//parent.players[0].GetMovingAgentComponent().SetEnabledRestorePosition( true );
		//parent.players[1].GetMovingAgentComponent().SetEnabledRestorePosition( true );
		
		//parent.players[0].GetMovingAgentComponent().SetEnabled( true );
		//parent.players[1].GetMovingAgentComponent().SetEnabled( true );
		
		//parent.EndGame( winnerIdx == 0 );
		parent.DoEnd( winnerIdx == 0 );
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class AxiiMinigameLogic
{
	public function Init( gameParams : W2MinigameAxii_GameParams )
	{
	}
	
	// value [-1,1]
	public function UpdateInput( value : float )
	{
	}
	
	public function UpdateInputButton( btnNum : int )
	{
	}
	
	public function GuiGetPointerPos() : float
	{
		return 0.0;
	}
	
	public function GuiGetBorderWidth() : float
	{
		return 0.0;
	}
	
	public function GuiGetCurrentTime() : float
	{
		return 0.0;
	}
	
	public function GuiDoShowSuccess() : bool
	{
		return false;
	}
	
	public function GuiDoShowPointerDirChange() : bool
	{
		return false;
	}
	
	// returns true if game has finnished
	public function UpdateLogic( timeDelta : float ) : bool
	{
		return true;
	}
	
	public function SetCursorInLeftBorder( isCursorInBorder : bool )
	{
	}

	public function SetCursorInRightBorder( isCursorInBorder : bool )
	{
	}
	
	public function GetWinner() : int
	{
		return -1;
	}
}

class AxiiMinigameLogicSimple extends AxiiMinigameLogic
{
	// Game parameters
	var m_paramGameTime				: float; // how long the minigame last
	var m_paramVelocityChangeFactor	: float; // how fast the velocity changes
	var m_paramInitAcceleration     : float; // initial acceleration of the pointer
	var m_paramClickCountLimit		: int;   // player will win after successful click (if 0 than this win method is disabled)
	var m_paramClickFailTolerance	: int;   // the number of bad clicks that player can do

	// Game logic runtime data
	var m_pointerPos	    	: float; // [-1,1]
	var m_borderWidth			: float; // (0,1]
	var m_currTime         		: float; // [0,1]
	var m_isCursorInLeftBorder	: bool;
	var m_isCursorInRightBorder	: bool;
	var m_gameTime				: float;
	var m_wasClicked			: bool;
	var m_clickNeeded			: bool;
	var m_clickCount			: int;	// the number of correct clicks
	var m_failClickCount		: int;	// the number of fail clicks
	
	// Gui
	var m_doShowSuccessClick		: bool;
	var m_doShowPointerDirChange	: bool;
	
	// Physics
	var m_pointerVelocity			: float; // scalar
	var m_pointerAcceleration		: float; // scalar
	var m_pointerAccelerationDir	: float;
	var m_pointerMass				: float;
	
	default m_pointerAcceleration	= 0;
	default m_pointerVelocity		= 0;
	default m_pointerMass			= 0.5;

	var m_winner			: int;   // 0 - player won
	var m_isUsingPad		: bool;  // true if player is using PAD, false if player is using mouse
	var m_isGameEnded       : bool;

	// Initialization

	public function Init( gameParams : W2MinigameAxii_GameParams )
	{
		InitVariables( gameParams );
	}
	
	// Input
	
	public function UpdateInput( value : float )
	{
		if ( m_isUsingPad )
		{
			//SetPointerPos( value );
		}
		else
		{
			// Keep in bounds (XBox cursorX/Y max is +1/-1, but not Windows mouse)
			if ( value > 1.0 ) value = 1.0;
			if ( value < -1.0 ) value = -1.0;

			//SetPointerPos( m_pointerPos + value * 0.02 );
		}
	}
	
	public function UpdateInputButton( btnNum : int )
	{
		if ( btnNum == 0 ) // left click
		{
			// player clicked when cursor wasn't in border - looser!
			if ( !m_isCursorInLeftBorder )
			{
				m_failClickCount += 1;
				
				if ( m_failClickCount > m_paramClickFailTolerance )
				{
					// player looses
					m_winner = 1;
					m_isGameEnded = true;
				}
				
				m_doShowSuccessClick = false;
			}
			else
			{
				m_wasClicked = true;
				m_doShowSuccessClick = true;
				m_clickCount += 1;

				if ( m_pointerAccelerationDir < 0 )
				{
					m_pointerAccelerationDir = -m_pointerAccelerationDir;
					m_doShowPointerDirChange = true;
				}
			}
		}
		else if ( btnNum == 1 ) // right click
		{
			// player clicked when cursor wasn't in border - looser!
			if ( !m_isCursorInRightBorder )
			{
				m_failClickCount += 1;
				
				if ( m_failClickCount > m_paramClickFailTolerance )
				{
					// player looses
					m_winner = 1;
					m_isGameEnded = true;
				}
				
				m_doShowSuccessClick = false;
			}
			else
			{
				m_wasClicked = true;
				m_doShowSuccessClick = true;
				m_clickCount += 1;

				if ( m_pointerAccelerationDir > 0 )
				{
					m_pointerAccelerationDir = -m_pointerAccelerationDir;
					m_doShowPointerDirChange = true;
				}
			}
		}
	}

	
	// GUI update
	public function GuiGetPointerPos() : float
	{
		return m_pointerPos;
	}
	
	public function GuiGetBorderWidth() : float
	{
		return m_borderWidth;
	}
	
	public function GuiGetCurrentTime() : float
	{
		return m_currTime;
	}
	
	public function GuiDoShowSuccess() : bool
	{
		if ( m_doShowSuccessClick )
		{
			m_doShowSuccessClick = false;
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function GuiDoShowPointerDirChange() : bool
	{
		if ( m_doShowPointerDirChange )
		{
			m_doShowPointerDirChange = false;
			return true;
		}
		else
		{
			return false;
		}
	}

	// Update

	public function UpdateLogic( timeDelta : float ) : bool
	{
		return ProcessLogic( timeDelta );
	}
	
	public function SetCursorInLeftBorder( isCursorInBorder : bool )
	{
		m_isCursorInLeftBorder = isCursorInBorder;
	}
	
	public function SetCursorInRightBorder( isCursorInBorder : bool )
	{
		m_isCursorInRightBorder = isCursorInBorder;
	}
	
	public function GetWinner() : int
	{
		return m_winner;
	}
	
	////////////////////////////////////////////////////////////////////////
	
	private function InitVariables( gameParams : W2MinigameAxii_GameParams )
	{
		// Game params
		//m_paramInitAcceleration		= 4.0f; // dbg 4.0
		//m_paramGameTime				= 5.0f; // dbg 4.0
		//m_paramVelocityChangeFactor	= 0.5f; // dbg 0.5 - 0.5 means that after one second the velcity will have half of its initial value
		//m_paramClickCountLimit		= 4;
		//m_paramClickFailTolerance		= 1;
		
		m_paramInitAcceleration     = gameParams.m_InitAcceleration;
		m_paramGameTime				= gameParams.m_GameTime;
		m_paramVelocityChangeFactor	= gameParams.m_VelocityChangeFactor;
		m_paramClickCountLimit		= gameParams.m_ClickCountLimit;
		m_paramClickFailTolerance   = gameParams.m_ClickFailTolerance;
		
		m_winner = -1; // unknown winner
		m_pointerPos = -0.99;
		m_isUsingPad = theGame.IsUsingPad();
		m_borderWidth = 1;
		m_currTime = 0;
		m_isGameEnded = false;
		m_isCursorInLeftBorder = false;
		m_isCursorInRightBorder = false;
		m_pointerAcceleration = m_paramInitAcceleration;
		m_pointerAccelerationDir = 1.0f;
		m_gameTime = 0;
		m_clickNeeded = false;
		m_wasClicked = false;
		m_doShowSuccessClick = false;
		m_doShowPointerDirChange = false;
		m_clickCount = 0;
		m_failClickCount = 0;
	}

	function ProcessLogic( timeDelta : float ) : bool
	{
		var accFrac : float;
		var wasCenterPassed : bool;
		var pointerPosBefore : float;
		
		if ( m_isGameEnded )
		{
			return true;
		}
		
		//m_paramGameTime -= timeDelta;
		m_gameTime += timeDelta;
		
		//if ( m_paramGameTime <= 0 )
		if ( m_gameTime >= m_paramGameTime || ( m_paramClickCountLimit > 0 && m_clickCount >= m_paramClickCountLimit ) )
		{
			// Player wins
			m_winner = 0;
			return true;
		}
		
		//LogChannel( 'rython', "Pointer accel: " + m_pointerAcceleration );
		//m_pointerAcceleration *= (1 - (m_paramVelocityChangeFactor * timeDelta));
		accFrac = m_paramVelocityChangeFactor * timeDelta;
		m_pointerAcceleration -= accFrac;
		if ( m_pointerAcceleration < 0 )
		{
			m_pointerAcceleration = 0;
		}
		
		//m_pointerVelocity += m_pointerAccelerationDir * m_pointerAcceleration * timeDelta;
		//m_pointerPos += m_pointerVelocity * timeDelta;
		
		pointerPosBefore = m_pointerPos;
		m_pointerPos += m_pointerAccelerationDir * m_pointerAcceleration * timeDelta;
		
		//LogChannel( 'rython', "Pointer pos: " + m_pointerPos );
		
		// Pass through center
		if ( (pointerPosBefore < 0 && m_pointerPos >= 0)
			|| (pointerPosBefore > 0 && m_pointerPos <= 0) )
		{
			wasCenterPassed = true;
		}
		else
		{
			wasCenterPassed = false;
		}
		if ( wasCenterPassed )
		{
			if ( m_clickNeeded )
			{
				if ( !m_wasClicked )
				{
					// player looses
					m_winner = 1;
					m_isGameEnded = true;
				}
				else
				{
					m_wasClicked = false;
				}
			}
			else
			{
				m_clickNeeded = true;
				m_wasClicked = false;
			}
		} 
		
		if ( m_pointerPos > 1.0f )
		{
			m_pointerPos = 1.0f;
			//m_pointerAccelerationDir = -m_pointerAccelerationDir;
			m_pointerVelocity = -m_pointerVelocity;
			
			if ( m_pointerAccelerationDir > 0 )
			{
				m_pointerAccelerationDir = -m_pointerAccelerationDir;
				m_doShowPointerDirChange = true;
			}
			//LogChannel( 'rython', "Odbijam w lewo" );
		}
		else if ( m_pointerPos < -1.0f )
		{
			m_pointerPos = -1.0f;
			//m_pointerAccelerationDir = -m_pointerAccelerationDir;
			m_pointerVelocity = -m_pointerVelocity;
			//LogChannel( 'rython', "Odbijam w prawo" );
			
			if ( m_pointerAccelerationDir < 0 )
			{
				m_pointerAccelerationDir = -m_pointerAccelerationDir;
				m_doShowPointerDirChange = true;
			}
		}
		
		
		// Border width
		m_borderWidth = (m_paramGameTime - m_gameTime) / m_paramGameTime;

		return false;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
