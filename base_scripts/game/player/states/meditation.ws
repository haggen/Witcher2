/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Meditation state.
/** Copyright © 2009
/***********************************************************************/

state Meditation in CPlayer extends Base
{
	var prevState		: EPlayerState;
	var timeMultiplier	: float;
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		if (animEventName == 'Bottle')
		{
			if ( thePlayer.GetInventory().HasItem('Geralt_Elixir') )
			{
				thePlayer.GetInventory().RemoveItem(thePlayer.GetInventory().GetItemId('Geralt_Elixir'));
				thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId('Geralt_Elixir'));
			}
			else
			{
				thePlayer.GetInventory().AddItem('Geralt_Elixir');
				thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Geralt_Elixir'), true);
			}
		}
	}
	
	event OnEnterState()
	{
		var arenaDoor : CArenaDoor;
		if(theGame.GetIsPlayerOnArena())
		{
			theGame.GetArenaManager().ShowArenaHUD(false);
			arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
			if(arenaDoor)
			{
				arenaDoor.EnableDoor(false);
			}
		}
		super.OnEnterState();
		
		theHud.SetHudVisibility( "false" );
		
		CreateNoSaveLock();
		FactsAdd( 'facts_meditation', 1, -1 );
		theCamera.SetCameraState(CS_Meditation);
		
		timeMultiplier = 1.f;
		
		theGame.EnableButtonInteractions( false );
		
		// we can exit from meditation only by StateMeditationExit() call - block other possibilities
		thePlayer.SetAllPlayerStatesBlocked( true );
		
		// Play meditation start sound
		theSound.PlaySound( "gui/waittime/started" );
		
		thePlayer.SetManualControl( false, false );
	}
	
	event OnLeaveState()
	{
		var arenaDoor : CArenaDoor;
		if(theGame.GetIsPlayerOnArena())
		{
			arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
			if(arenaDoor)
			{
				arenaDoor.EnableDoor(true);
			}
		}
		super.OnLeaveState();
		
		// Play meditation stop sound
		theSound.PlaySound( "gui/waittime/stopped" );
		
		FactsAdd( 'facts_meditation', -1, -1 );
		
		theGame.ResetHoursPerMinute();
		//theGame.SetDefaultAnimationTimeMultiplier( theGame.GetDefaultAnimationTimeMultiplier() / timeMultiplier );
		theGame.SetTimeScale( theGame.GetTimeScale() / timeMultiplier );
		
		theGame.EnableButtonInteractions( true );
		
		parent.SetHotKeysBlocked( false );
		
		thePlayer.SetAllPlayerStatesBlocked( false );
		
		thePlayer.SetManualControl( true, true );
	}
	
	event OnUseExploration( explorationArea : CActionAreaComponent )
	{
		return false;
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	entry function StateMeditation( oldPlayerState : EPlayerState )
	{
		prevState = oldPlayerState;
		
		//hide swords etc.
		if( thePlayer.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			thePlayer.HolsterWeaponLatent( thePlayer.GetCurrentWeapon() );
		}
		
		parent.SetHotKeysBlocked( true );
		
		parent.ActivateBehavior( 'meditation' );

		theHud.ShowMeditation();
		
		parent.WaitForBehaviorNodeActivation( 'idle_start' );
		
		
	}
	
	entry function ChangeMeditationState( actEvent: name, waitForAct: name, functionSwitch : string )
	{
		if (parent.RaiseEvent( actEvent ))
		{
			parent.WaitForBehaviorNodeActivation( waitForAct );			
		}
		else
		{
			Sleep(0.1);
		}
		if (functionSwitch != "")
		{
			theHud.ProcessPanelSwitch(functionSwitch);
		}
	}
	
	entry function ChangeMeditationState2( actEvent: name, secondEvent: name, waitForAct: name, functionSwitch : string )
	{
		if (parent.RaiseEvent( actEvent ))
		{
			Sleep(0);//wait for next tick
			parent.WaitForBehaviorNodeActivation( waitForAct, 20 );			
			if (parent.RaiseEvent( secondEvent ))
			{
				Sleep(0);//wait for next tick
				parent.WaitForBehaviorNodeActivation( waitForAct, 20 );			
			}
		}
		else if(parent.RaiseForceEvent( actEvent ))
		{
			Sleep(0);//wait for next tick
			parent.WaitForBehaviorNodeActivation( waitForAct, 20 );			
			if (parent.RaiseEvent( secondEvent ))
			{
				Sleep(0);//wait for next tick
				parent.WaitForBehaviorNodeActivation( waitForAct, 20 );			
			}
		}
		if (functionSwitch != "")
		{
			theHud.ProcessPanelSwitch(functionSwitch);
		}
	}
	
	entry function StateMeditationProcess( numHoursToWait : int, elixirsToDrink : array< SItemUniqueId > )
	{
		var startTime	 : GameTime;
		var i			 : int;
		var sleepedSecs  : int;
		var npcs		 : array< CNewNPC >;
		var lightsKeeper : W2LightsKeeper;
		var wasLightKeeperFound : bool;
		
		theHud.HideMeditation();
		
		if ( numHoursToWait > 0 )
		{
			thePlayer.RemoveAllBuffs();
			theHud.EnableInput( false, false, false );
			startTime = theGame.GetGameTime();
			
			theGame.SetHoursPerMinute( 48 );
			//theGame.SetDefaultAnimationTimeMultiplier( theGame.GetDefaultAnimationTimeMultiplier() * 10.f );
			theGame.SetTimeScale( theGame.GetTimeScale() * 10.f );
			timeMultiplier *= 10.f;

			do
			{
				sleepedSecs = GameTimeToSeconds( theGame.GetGameTime() );
				Sleep( 1.f );
				sleepedSecs = GameTimeToSeconds( theGame.GetGameTime() ) - sleepedSecs;
				thePlayer.ApplyTimerBuffs( sleepedSecs );
			}
			while ( GameTimeHours( theGame.GetGameTime() - startTime ) < numHoursToWait );
			
			theHud.EnableInput( true, true, true );
			
			thePlayer.IncreaseHealth( numHoursToWait * 24 ); 
			
			theGame.ResetHoursPerMinute();
			//theGame.SetDefaultAnimationTimeMultiplier( theGame.GetDefaultAnimationTimeMultiplier() * 0.1f );
			theGame.SetTimeScale( theGame.GetTimeScale() * 0.1f );
			timeMultiplier *= 0.1f;
		}
		
		//parent.SetToxicity(toxicity);
		
		if ( elixirsToDrink.Size() > 0 )
		{
			for ( i = 0; i < elixirsToDrink.Size(); i += 1 )
			{
				thePlayer.UseItem( elixirsToDrink[ i ] );
				Sleep(0.5);
			}
		}
		
		// HACK: switch lights on/off if the lights keeper haven't done it yet
		theGame.GetAllNPCs( npcs );
		wasLightKeeperFound = false;
		for ( i = 0; i < npcs.Size(); i += 1 )
		{
			lightsKeeper = (W2LightsKeeper)npcs[i];
			if ( lightsKeeper )
			{
				lightsKeeper.OnMeditationFinished();
				wasLightKeeperFound = true;
			}
		}
		if ( !wasLightKeeperFound )
		{
			// TODO: 
			FactsAdd( "spawn_keeper_after_meditation", 1 );
		}
		
		parent.RaiseEvent('idle');
		theCamera.RaiseEvent('idle');
		
		theHud.ShowMeditation();
	}
	
	entry function StateMeditationExit()
	{
		theHud.CloseAllPanels();
		
		parent.RaiseForceEvent('exploration');
		theCamera.ResetRotation(true,true,true, 2.67);
		if( theCamera.RaiseEvent('exploration') )
		{
			parent.WaitForBehaviorNodeDeactivation('meditation_end', 4.0);
			theCamera.SetCameraState(CS_Exploration);
		}
		else
		{
			Sleep(1.0);
			theCamera.SetCameraState(CS_Exploration);
			parent.WaitForBehaviorNodeDeactivation('meditation_end', 3.0);
		}
//		theCamera.RaiseForceEvent('meditation_reset');
		//theCamera.WaitForBehaviorNodeDeactivation('cam_meditation_end', 7.0);
		

		
		//parent.SetHotKeysBlocked( false );
		
		if( prevState == PS_Sneak )
			parent.PlayerStateCallEntryFunction( prevState, '' );
		else
			parent.PlayerStateCallEntryFunction( PS_Exploration, '' );
	}
	
	final function IsCameraControlKey( key : name ) : bool
	{
		if ( key == 'GI_AxisRightY' || key == 'GI_AxisRightX' )
			return true;
		else if ( key == 'GI_MouseDampY' || key == 'GI_MouseDampX' )
			return true;
		else
			return false;
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		// block camera input while meditating
		if( IsCameraControlKey( key ) )
		{
			return true;
		}
		return false;
	}
};
