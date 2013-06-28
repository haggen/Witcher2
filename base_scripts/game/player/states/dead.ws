/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Dead state for player
/** Copyright © 2009
/***********************************************************************/

state Dead in CPlayer extends Base
{
	var canLeave : bool;

	event OnEnterState()
	{
		super.OnEnterState();
		CreateNoSaveLock();
		parent.ActivateBehavior( 'PlayerExploration' );
		if( !theGame.GetIsPlayerOnArena() )
		{
			//FactsAdd(theGame.GetArenaManager().GetFailFact());
			thePlayer.GetInventory().DropItem( thePlayer.GetCurrentWeapon() );
		}
		else
		{
			theGame.GetArenaManager().ArenaCrowdReaction(ACR_Failed);
		}
		Log( parent.GetName()+" dead" );			
		StopCameraRotation();
		canLeave = false;
	}
	
	latent function DelayDeathScreen()
	{
		theHud.m_hud.HideTutorial();
		Sleep(1.0);
		theGame.SetTimeScale( 0.5 );
		Sleep(1.0);
		theGame.FadeOutAsync( 1.8 );
		theGame.SetTimeScale( 0.8 );
		Sleep(0.5);
		theGame.SetTimeScale( 0.5 );
		Sleep(0.5);
		theGame.SetTimeScale( 1.0 );
		//theHud.m_fx.DeathStart();
		//theHud.m_hud.SetGameOver();

		if( theGame.tutorialenabled )
		{
			//theGame.FadeOutAsync(1.0);
			theGame.FadeInAsync(1.0);
			theGame.TutorialDifficultyPrompt();
		}
		
		else if( theGame.GetIsPlayerOnArena() )
		{	
			//theSound.StopMusic("arena_1", true);
			//theSound.StopMusic("arena_2", true);
			//theSound.StopMusic("arena_3", true);
			//theSound.StopMusic("arena_4", true);
			//theSound.StopMusic("arena_5", true);
			theGame.GetArenaManager().RemoveTimer('TimerWaveBonusTime');
			theGame.GetArenaManager().StopChantSounds();
			theGame.FadeInAsync(1.0);
			if(!thePlayer.CanUseHud())
			{
				thePlayer.SetCanUseHud(true);
			}
			theHud.ShowArenaFail();
		}

		else
		{
			Sleep(3.0);
			//theHud.Invoke( "pPanelClass.ShowFailed" );
			//theHud.m_fx.DeathStart();
			theHud.m_hud.SetGameOver();
		}
	}
	
	event OnLeavingState()
	{
		return canLeave;
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
	event OnArenaResurect()
	{
		canLeave = true;
		parent.RevivePlayer();
	}
	event OnResurect()
	{
		canLeave = true;
		parent.SetRagdoll(false);
		parent.RaiseForceEvent('Idle');		
		parent.ResetStats();		
		parent.SetAlive( true );
		theHud.m_fx.DeathStop();
	}
	
	entry function StateDead( deathData : SActorDeathData )
	{
		// mcinek: Insane death system :)
		theGame.PlayerDead();
		HideLootWindow();
		parent.RaiseForceEvent( 'Death' );
		DelayDeathScreen();
	} 
	
	entry function StateDeadFall( optional deathData : SActorDeathData )
	{
		parent.RaiseForceEvent( 'DragonTowerFall' );
		DelayDeathScreen();
	}
	
	private function StopCameraRotation()
	{
		var playerCamera : CCamera;

		// Update camera
		playerCamera = 	theCamera;
		
		if ( playerCamera )
		{
			playerCamera.Rotate( 0.0, 0.0 );
		}
	}
};
