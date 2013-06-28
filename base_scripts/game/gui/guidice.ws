/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Minigame Dice
/** Copyright © 2010
/***********************************************************************/

class CGuiDice extends CGuiPanel
{
	private var m_minigameDice : W2MinigameDicePoker;
	private var m_initialized : bool;
	default m_initialized = false;
	
	function GetPanelPath() : string { return "ui_game_dice.swf"; }
	
	public function SetMinigame( minigameDice : W2MinigameDicePoker )
	{
		m_minigameDice = minigameDice;
	}
	
	function CanBeClosedByEsc() : bool { return false; }

	//////////////////////////////////////////////////////////////
	// Public Functions
	//////////////////////////////////////////////////////////////
	
	public function IsInitialized() : bool
	{
		return m_initialized;
	}

	public function Betting( maxBetting : int, minBetting : int, textMain, textOk, textCancel : string )
	{
		var params : array< CFlashValueScript >;
		params.PushBack( FlashValueFromInt( maxBetting ) );
		params.PushBack( FlashValueFromInt( minBetting ) );
		params.PushBack( FlashValueFromString( textOk ) );
		params.PushBack( FlashValueFromString( textCancel ) );
		theHud.InvokeManyArgs( "pPanelClass.Betting", params );
		ShowInformation( textMain );
	}
	
	public function PlayerAcceptBetting( betting : int, textMain, textOk, textCancel : string )
	{
		var params : array< CFlashValueScript >;
		params.PushBack( FlashValueFromInt( betting ) );
		params.PushBack( FlashValueFromString( textOk ) );
		params.PushBack( FlashValueFromString( textCancel ) );
		theHud.InvokeManyArgs( "pPanelClass.PlayerAcceptBetting", params );
		ShowInformation( textMain );
	}

	public function RoundResult( geraltWins : bool, cashWon : int, textOk, textCancel : string )
	{
		var params : array< CFlashValueScript >;
		params.PushBack( FlashValueFromBoolean( geraltWins ) );
		params.PushBack( FlashValueFromBoolean( false ) );
		params.PushBack( FlashValueFromInt( cashWon ) );
		params.PushBack( FlashValueFromString( textOk ) );
		params.PushBack( FlashValueFromString( textCancel ) );
		theHud.InvokeManyArgs( "pPanelClass.RoundResult", params );
		
		if( geraltWins )
		{
			ShowInformation( "[[locale.dice.Winner]]" );
		}
		else
		{
			ShowInformation( "[[locale.dice.Looser]]" );
		}
	}
	
	public function NPCBetting( npcBet : int )
	{
		theHud.InvokeOneArg( "pPanelClass.NPCBetting", FlashValueFromInt( npcBet ) );
		ShowInformation( "[[locale.dice.NPCBetting]]" );
	}
	
	public function DiceSelection()
	{
		theHud.Invoke( "pPanelClass.DiceSelection" );
		ShowInformation( "[[locale.dice.DiceSelection]]" );
	}

	public function NPCThinking()
	{
		HideInformation();
		ShowInformation( "[[locale.dice.NPCThinking]]" );
	}

	public function NPCThrowing()
	{
		HideInformation();
		ShowInformation( "[[locale.dice.NPCThrowing]]" );
	}

	public function WaitingForThrow()
	{
		HideInformation();
		ShowInformation( "[[locale.dice.WaitingForThrow]]" );
	}

	public function ShowInformation( info : string )
	{
		theHud.InvokeOneArg( "pPanelClass.ShowInformation", FlashValueFromString( info ) );
	}

	public function HideInformation()
	{
		theHud.Invoke( "pPanelClass.HideInformation" );
	}

	public function SetStake( stake : int )
	{
		theHud.InvokeOneArg( "pPanelClass.SetStake", FlashValueFromInt( stake ) );
	}

	public function SetGeraltMoney( money : int )
	{
		theHud.InvokeOneArg( "pPanelClass.SetGeraltMoney", FlashValueFromInt( money ) );
	}
	
	public function SetGeraltWins( wins : int )
	{
		theHud.InvokeOneArg( "pPanelClass.SetGeraltWins", FlashValueFromInt( wins ) );
	}
	
	public function SetNPCWins( wins : int )
	{
		theHud.InvokeOneArg( "pPanelClass.SetNPCWins", FlashValueFromInt( wins ) );
	}

	public function SetNPCName( oppName : string )
	{
		theHud.InvokeOneArg( "pPanelClass.SetNPCName", FlashValueFromString( oppName ) );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	public final function FillData()
	{
		m_initialized = true;
	}
	
	final function callbackPlayerBet( cashBet : float )
	{
		//LogChannel( 'Minigame', "callbackPlayerBet()" );
		m_minigameDice.StatePlayerDidBet( ( int ) cashBet );
	}
	
	final function callbackPlayerCancel()
	{
		//LogChannel( 'Minigame', "callbackPlayerCancel()" );

		if( m_minigameDice.GetCurrentState().GetStateName() == 'PlayerBetting' )
		{
			m_minigameDice.StatePlayerCancelBet();
		}
		else if( m_minigameDice.GetCurrentState().GetStateName() == 'RoundEnded' )
		{
			m_minigameDice.StateRoundEndedResponse( false );
		}
	}

	final function callbackPlayerNewRound()
	{
		//LogChannel( 'Minigame', "callbackPlayerNewRound()" );
		
		m_minigameDice.StateRoundEndedResponse( true );
	}
	
	final function callbackPlayerOk()
	{
		//LogChannel( 'Minigame', "callbackPlayerOk()" );
		
		m_minigameDice.StatePlayerSelected();
	}
}
