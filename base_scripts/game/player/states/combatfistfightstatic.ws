/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Fistfight state
/////////////////////////////////////////////

state CombatFistfightStatic in CPlayer extends Movable
{	
	////////////////////////////////////////////////////////////////////////////////
	// Events
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.HolsterWeaponInstant( GetInvalidUniqueId() );
		
		parent.IssueRequiredItems( 'None', 'None' );
		theCamera.SetCameraState (CS_FistFight);

		parent.ResetMovment();
		parent.SetManualControl(false, true );
		
		theCamera.FollowWithRotation(thePlayer);
		
		// activate the behavior and force it to its default state
		parent.ActivateBehavior('fistfight_static');
		
		// enter the combat mode
		parent.KeepCombatMode();

		theGame.EnableButtonInteractions( false );
	}
	
	event OnLeaveState()
	{
		theCamera.Follow(thePlayer);
		super.OnLeaveState();
		parent.SetManualControl( true, true );
		theGame.GetFistfightManager().DestroyDeniedArea();
		parent.GetMovingAgentComponent().SetEnabledRestorePosition(true);
		parent.SetImmortalityModeRuntime( AIM_None );			
		theGame.EnableButtonInteractions( true );

		theHud.m_hud.HideNPCHealth();

		parent.BreakQTE();

	}
	
	///////////////////////////////////////////////////////////////////////
	// Standard events handlers
	///////////////////////////////////////////////////////////////////////
	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	// Event called when a QTE is successfully handled by the player.
	event OnQTESuccess( resultData : SQTEResultData )
	{
		theGame.GetFistfightManager().OnQTESuccessful( parent );
	}

	// Event called when the playe fails a QTE.
	event OnQTEFailure( resultData : SQTEResultData )
	{
		theGame.GetFistfightManager().OnQTEFailure( parent );	
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		var args : array <string>;
		var damage : float;
		
		if( animEventName == 'ShakeLight' )
		{
			theHud.m_fx.BlurShakeStart();
		}
		else if( animEventName == 'ShakeHeavy' )
		{
			theHud.m_fx.BlurShakeStart();
		}
		else if( animEventName == 'HitLight' )
		{
			parent.PlayEffect('fistfight_hit');
			theGame.GetFistfightManager().OnHit( parent );
		}
		else if( animEventName == 'HitHeavy' ) 
		{
			parent.PlayEffect('fistfight_strong');
			theGame.GetFistfightManager().OnHit( parent );
		}
		else if( animEventName == 'SlowMo' )
		{
			parent.PlayEffect ('fistfight_slow');
			theCamera.SetBehaviorVariable ( 'FOV_Offset', 20.0);
			FovTimer();
		}
		else if( animEventName == 'FovChange' )
		{
			theCamera.SetBehaviorVariable ( 'FOV_Offset', 20.0);
			FovTimer();
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if( IsCameraControlKey( key ) )
		{
			return super.OnGameInputEvent( key, value );
		}
		
		// DEBUG
		if ( theGame.IsCheatEnabled( CHEAT_InstantKill ) )
		{
			if( key == 'GI_N' )
			{
				if( value > 0.5f )
				{
					theGame.GetFistfightManager().OnStunOpponentCheat();
					return true;
				}
				return false;
			}
		}
	}
	
	event OnActorKilled( actor : CActor )
	{
		theGame.GetFistfightManager().OnActorIncapacitated( actor );
		parent.OnActorKilled( actor );
	}
	
	event OnActorStunned( actor : CActor )
	{
		theGame.GetFistfightManager().OnActorIncapacitated( actor );
		parent.OnActorStunned( actor );
	}
	
	///////////////////////////////////////////////////////////////////////
	// Fistfight management
	///////////////////////////////////////////////////////////////////////
	entry function EntryCombatFistfightStatic( oldPlayerState : EPlayerState, behStateName : string )
	{
	}
	
	///////////////////////////////////////////////////////////////////////
	// Timers
	///////////////////////////////////////////////////////////////////////
	
	timer function FovReset( timeDelta : float )
	{
		theCamera.SetBehaviorVariable ( 'FOV_Offset', 0.0);
		return;
	}

	private function FovTimer()
	{
		parent.AddTimer( 'FovReset', 0.3, false );
	}
	
	////////////////////////////////////////////////////////////////////////////////
	// Exit
	event OnExitPlayerState( newState : EPlayerState )
	{
		if( parent.IsAnExplorationState( newState ) || newState == PS_Scene || newState == PS_Cutscene )
		{
			ExitCombatFistfightStatic( newState );
		}
	}

	entry function ExitCombatFistfightStatic( newState : EPlayerState )
	{
		parent.PlayerStateCallEntryFunction( newState, '' );
	}
};
