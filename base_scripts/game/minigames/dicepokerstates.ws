/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Dice Poker Minigame
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

state InitializeGUI in W2MinigameDicePoker
{
	entry function StateInitializeGUI()
	{
		// TEMPHACK: Load effects entity here and get table dimensions
		var dice : CMinigameDice;
		var i, player : int;
		var resource : CResource;
		var tableComponent 	: CBoundedComponent;
		
		while ( ! theHud.GetDicePanel().IsInitialized() )
		{
			Sleep( 0.1 );
		}
		theHud.EnableInput(true, true, true, false);

		resource = LoadResource( "fx\dices" );
		for( player = 0; player < parent.m_playerStatuses.Size(); player += 1 )
		{
			for ( i = 0; i < parent.m_playerStatuses[ player ].m_dices.Size(); i += 1 )
			{
				dice = parent.m_playerStatuses[ player ].m_dices[ i ];
				dice.m_effectEntity = theGame.CreateEntity( ( CEntityTemplate ) resource, dice.m_component.GetWorldPosition() );
			}
		}
	
		tableComponent = ( CBoundedComponent ) parent.GetComponent( "mg_board" );
		if( ! tableComponent )
		{
			LogChannel( 'Minigame', "Cannot get table component" );
		}
		parent.m_tableBox = tableComponent.GetBoundingBox();

		// UGLY HACK: waiting for GUI to load
		Sleep( 0.1f );
		
		parent.m_guiPanel.SetGeraltMoney( parent.m_playerStatuses[ DicePoker_Player ].m_money );
		parent.m_guiPanel.SetNPCName( parent.m_npc.GetDisplayName() );
		parent.m_guiPanel.SetGeraltWins( parent.m_npc.GetDiceLosses() );
		parent.m_guiPanel.SetNPCWins( parent.m_npc.GetDiceWins() );

		parent.StatePlayerSelect();
	}
}

state PlayerSelect in W2MinigameDicePoker
{	
	entry function StatePlayerSelect()
	{
		if( parent.m_currentThrow == 1 )
		{
			parent.SelectAllDices( DicePoker_Player, true );
			parent.StateNPCSelect();
		}

		parent.SelectAllDices( DicePoker_Player, false );

		parent.CameraCloseUp();

		parent.StartPlayerSelection();
	}
	
	entry function StatePlayerSelected()
	{
		parent.RemoveTimer( 'DicesInputTimer' );
		parent.m_padPersistentMovement = 0;
		
		parent.EndPlayerSelection();
		
		parent.StateNPCSelect();
	}
}

state NPCSelect in W2MinigameDicePoker
{
	entry function StateNPCSelect()
	{
		if( parent.m_currentThrow == 1 )
		{
			parent.SelectAllDices( DicePoker_NPC, true );
		}
		else
		{
			parent.m_guiPanel.NPCThinking();

			Sleep( 1.0f );
			parent.SelectDicesAI();
		}

		parent.StatePlayerBetting( true, Min( parent.m_npc.GetDicePokerMinBet(), parent.m_playerStatuses[ DicePoker_Player ].m_money ) );
	}
}

state PlayerBetting in W2MinigameDicePoker
{
	var firstBet : bool;
	
	entry function StatePlayerBetting( isFirstBet : bool, minimalBet : int )
	{
		var money 		: float;
		var maximalBet 	: int;
		
		firstBet = isFirstBet;
		
		if( parent.m_currentThrow == 1 )
		{
			parent.CameraSide();
		}
		else
		{
			parent.CameraTop();
		}
		
		if( parent.m_playerStatuses[ DicePoker_Player ].m_money == 0 )
		{
			if( parent.m_currentThrow == 1 )
			{
				parent.m_guiPanel.ShowInformation( "[[locale.dice.NoMoney]]" );
				Sleep( 2.0f );
				
				//parent.EndGame( false );
				parent.DoEnd( false );
				return;
			}
			else
			{
				// If player has no money, go directly to throwing
				parent.StatePlayerThrowing();
			}
		}

		// Select stake
		if( firstBet )
		{
			minimalBet = Min( parent.m_npc.GetDicePokerMinBet(), parent.m_playerStatuses[ DicePoker_Player ].m_money );
			maximalBet = Min( parent.m_npc.GetDicePokerMaxBet(), parent.m_playerStatuses[ DicePoker_Player ].m_money );
			parent.m_guiPanel.Betting( maximalBet, minimalBet,
				"[[locale.dice.PlaceYourBet]]", "[[locale.dice.Bet]]", "[[locale.dice.Pass]]" );
		}
		else
		{
			parent.m_guiPanel.PlayerAcceptBetting( minimalBet,
				"[[locale.dice.AcceptBet]]", "[[locale.dice.Accept]]", "[[locale.dice.Pass]]" );
		}
	}
	
	entry function StatePlayerCancelBet()
	{
		if( parent.m_currentThrow == 1 && firstBet )
		{
			// No consequences if we just started
			//parent.EndGame( false );
			parent.DoEnd( false );
			return;
		}

		// End round
		parent.StateRoundEnded( DicePoker_NPC );
	}
	
	entry function StatePlayerDidBet( money : int )
	{
		parent.m_stake += money;
		parent.m_playerStatuses[ DicePoker_Player ].m_money -= money;
		
		// Update GUI
		parent.m_guiPanel.SetGeraltMoney( parent.m_playerStatuses[ DicePoker_Player ].m_money );
		parent.m_guiPanel.SetStake( parent.m_stake );
		
		if( firstBet )
		{
			parent.StateNPCBetting( money );
		}
		else
		{
			parent.StatePlayerThrowing();
		}
	}
}

state NPCBetting in W2MinigameDicePoker
{
	entry function StateNPCBetting( playerBet : int )
	{
		var npcBet : int;
		
		npcBet = parent.BetAI( playerBet );
				
		if( npcBet == playerBet )
		{
			// Show info only when NPC accepts the stake
			// When he rises we ask player later
			parent.m_guiPanel.NPCBetting( npcBet );
			Sleep( 2.0f );
		}

		parent.m_stake += npcBet;
		parent.m_playerStatuses[ DicePoker_NPC ].m_money -= npcBet;
		
		// Update GUI
		parent.m_guiPanel.SetStake( parent.m_stake );

		// Check if npc overstaked player
		if( npcBet > playerBet )
		{
			parent.StatePlayerBetting( false, npcBet - playerBet );
		}
		
		parent.StatePlayerThrowing();
	}
	
	entry function StateNPCGaveUp()
	{
		parent.m_guiPanel.ShowInformation( "[[locale.dice.OpponentGivesUp]]" );
		Sleep( 2.0f );
			
		// NPC gives up
		parent.StateRoundEnded( DicePoker_Player);
	}
}

state PlayerThrowing in W2MinigameDicePoker
{
	entry function StatePlayerThrowing()
	{
		parent.CameraSide();
		
		if( theGame.IsUsingPad() )
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut76", "tut68_333x166", false);
		}
		else
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut68", "tut68_333x166", false);
		}
		
		parent.m_guiPanel.WaitingForThrow();

		// HACK: for not getting 'click' to early
		Sleep( 0.2f );

		// Throw dices
		parent.ThrowDices( DicePoker_Player );
		
		// Put dices back into slots
		parent.PutDices( DicePoker_Player );
		
		parent.StateNPCThrowing();
	}
}

state NPCThrowing in W2MinigameDicePoker
{
	entry function StateNPCThrowing()
	{
		parent.m_guiPanel.NPCThrowing();
		Sleep( 1.0f );
	
		// Throw dices
		parent.ThrowDices( DicePoker_NPC );
		
		// Put dices back into slots
		parent.PutDices( DicePoker_NPC );

		parent.StateShowResult();
	}
}

state ShowResult in W2MinigameDicePoker
{
	entry function StateShowResult()
	{
		var i, winner : int;
		
		parent.CameraTop();
		
		if( parent.m_currentThrow == 2 )
		{
			// End round, show winner
			winner = parent.GetWinner();
			
			if( winner < 0 )
			{
				// Deuce
				parent.m_guiPanel.ShowInformation( "[[locale.dice.Deuce]]" );
				Sleep( 2.0f );
				
				// Give money back
				for( i = 0; i < parent.m_playerStatuses.Size(); i += 1 )
				{
					parent.m_playerStatuses[ i ].m_money += parent.m_stake / parent.m_playerStatuses.Size();
				}
			}
			
			parent.StateRoundEnded( winner );
		}
		else
		{
			parent.m_currentThrow += 1;
			parent.StatePlayerSelect();
		}
	}
}

state RoundEnded in W2MinigameDicePoker
{
	entry function StateRoundEnded( playerWonIdx : int )
	{
		var askToPlayAgain	: bool;
		var playerResult	: W2MinigameDicePokerResult;
		var temp1, temp2	: int;
		var tutorialState	: bool;
		var hud				: CGuiHud;
		var i				: int;
		
		// Check if deuce
		if( playerWonIdx == -1 )
		{
			// Clear state
			parent.m_currentThrow = 1;
			parent.m_stake = 0;
			
			// Update GUI
			parent.m_guiPanel.SetGeraltMoney( parent.m_playerStatuses[ DicePoker_Player ].m_money );
			parent.m_guiPanel.SetStake( parent.m_stake );
			
			// Reset dice state
			for( i = 0; i < parent.m_playerStatuses[0].m_dices.Size(); i += 1 )
			{
				parent.m_playerStatuses[DicePoker_Player].m_dices[ i ].Reset();
				parent.m_playerStatuses[DicePoker_NPC].m_dices[ i ].Reset();
			}
				
			// Play again
			parent.StatePlayerSelect();
		}

		// Check if player wins
		parent.m_playerWins = playerWonIdx == DicePoker_Player;

		// Give winner the money
		parent.m_playerStatuses[ playerWonIdx ].m_money += parent.m_stake;
		
		// Update GUI
		parent.m_guiPanel.SetGeraltMoney( parent.m_playerStatuses[ DicePoker_Player ].m_money );
		if( parent.m_playerWins )
		{
			parent.m_guiPanel.SetGeraltWins( parent.m_npc.GetDiceLosses() + 1 );
			thePlayer.GetInventory().AddItem('Orens', parent.m_stake / 2);
			FactsAdd("Won_Dice", 1);
		}
		else
		{
			parent.m_guiPanel.SetNPCWins( parent.m_npc.GetDiceWins() + 1 );
			thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Orens'), parent.m_stake / 2);
		}
		
		// SPECIAL CHECKING FOR GOG MINIGAME
		
		/*if( parent.m_npc.GetVoicetag() == 'GOG MONK' )
		{
			if( playerWonIdx == DicePoker_Player )
			{
				parent.GetPlayerScore( DicePoker_Player, playerResult, temp1, temp2 );
				if( playerResult == MinigameDicePokerResult_TwoPair )
				{
					parent.UnlockGOGMinigame();
					
					// Force showing tutorial window
					hud = theHud.m_hud;
					tutorialState = hud.tutorialEnabled;
					hud.tutorialEnabled = true;
					theHud.m_hud.ShowTutorial("gogmonk2pairswin", "tutgog_333x166", false);
					hud.tutorialEnabled = tutorialState;
				}
			}
		}*/
		
		////////////////////////////////////

		
		// Show panel
		parent.m_guiPanel.RoundResult( parent.m_playerWins, parent.m_stake / 2,
			"[[locale.dice.Continue]]", "[[locale.dice.Quit]]" );
	}

	entry function StateRoundEndedResponse( continuePlaying : bool )
	{
		/*var playerIdx, i : int;
		
		(if( continuePlaying )
		{
			// Clear state
			parent.m_currentThrow = 1;
			parent.m_stake = 0;
			
			// Reset dices
			for( playerIdx = 0; playerIdx < parent.m_playerStatuses.Size(); playerIdx += 1 )
			{
				for( i = 0; i < parent.m_playerStatuses[ playerIdx ].m_dices.Size(); i += 1 )
				{
					parent.m_playerStatuses[ playerIdx ].m_dices[ i ].ResetPosition();
				}
			}
			
			// Update GUI
			parent.m_guiPanel.SetGeraltMoney( parent.m_playerStatuses[ DicePoker_Player ].m_money );
			parent.m_guiPanel.SetStake( parent.m_stake );
			
			// Play again
			parent.StatePlayerSelect();
		}*/

		// Check if player has 2 wins
		//parent.EndGame( parent.m_playerWins );
			
		parent.DoEnd( parent.m_playerWins );
	}
}
