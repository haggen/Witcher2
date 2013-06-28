/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

// Nie dodawac tutaj rzeczy niezwiazanych z poruszaniem, uzyj ExtendedMovable !!!
// Nie dodawac tutaj rzeczy niezwiazanych z poruszaniem, uzyj ExtendedMovable !!!
// Nie dodawac tutaj rzeczy niezwiazanych z poruszaniem, uzyj ExtendedMovable !!!

/////////////////////////////////////////////
// Movable state
/////////////////////////////////////////////
import state Movable in CPlayer extends Base
{
	private 			var m_scheduledState			: EPlayerState;
	default				m_scheduledState				= PS_None;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
				
		// Intall movement timer
		parent.AddTimer( 'ProcessMovement', 0.001, true, false, TICK_PrePhysics );
		
		parent.SetManualControl( true, true );
		
		// set the state change flags
		m_scheduledState = PS_None;
	}
	
	event OnLeaveState()
	{
		var currRotation : EulerAngles;
		var agent : CMovingAgentComponent = parent.GetMovingAgentComponent();
		
		// Remove movement timer
		parent.RemoveTimer( 'ProcessMovement', TICK_PrePhysics );		
		
		// Pass to base class
		super.OnLeaveState();
		
		if( parent.blockSpeedReset == false )
		{
			currRotation = parent.GetWorldRotation();
			parent.rawPlayerAngle = 0.0;
			parent.rawPlayerHeading = currRotation.Yaw;
			parent.rawPlayerSpeed = 0.0;
		}		
		
		parent.blockSpeedReset = false;
		
		// reset additional movement flags
		agent.SetBehaviorVariable( "headingChange", 0 );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game inputs
		
	event OnGameInputEvent( key : name, value : float )
	{
		if( key == 'GI_WalkFlag' && value > 0.5f )
		{
			parent.SwitchWalkFlag();
			return true;
		}
		else if ( ProcessCameraInputs( key, value ) || ProcessMovementInputs( key, value ) )
		{
			//return true if the input have been processed and we dont want to pass it further
			return true;
		}
		
		// Not handled
		return false;
	}
	
	event OnPadStateChanged( isUsingPadNow : bool )
	{
		parent.ResetPlayerCamera();
	}
	
	final function ProcessCameraInputs( key : name, value : float ) : bool
	{
		if ( theGame.IsUsingPad() )
		{
			if ( key == 'GI_AxisRightY' )
			{
				thePlayer.ResetHUDTimer();
				return false;
			}
			else if ( key == 'GI_AxisRightX' )
			{
				thePlayer.ResetHUDTimer();
				return false;
			}
			else if ( key == 'GI_Control12' )
			{
				thePlayer.ResetHUDTimer();
				theCamera.ResetRotation();
				return false;
			}
		}
		else
		{
			if ( key == 'GI_MouseDampY' )
			{
				thePlayer.ResetHUDTimer();
				return false;
			}
			else if ( key == 'GI_MouseDampX' )
			{
				thePlayer.ResetHUDTimer();
				return false;
			}
		}
		
		return false;
	}
	
	final function ProcessMovementInputs( key : name, value : float ) : bool
	{
		if ( key == 'GI_AxisLeftX' )
		{
			if ( !parent.isMovable )
			{
				return true;
			}
			
			parent.SetOverweightTestRequired(true);
			parent.RemoveTimer( 'ShowMovementTutorial' );
			return false;
		}
		else if ( key == 'GI_AxisLeftY' )
		{
			if ( !parent.isMovable )
			{
				return true;
			}
			
			parent.SetOverweightTestRequired(true);
			parent.RemoveTimer( 'ShowMovementTutorial' );		
			return false;
		}
		
		return false;
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
	
	final function IsMovementControlKey( key : name ) : bool
	{
		if ( key == 'GI_AxisLeftY' || key == 'GI_AxisLeftX' ) return true;		
		else return false;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// State changes
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{		
		if ( animEventName == 'StateChangeAllowed' )
		{
			// if a state change has been scheduled - execute it
			if ( m_scheduledState != PS_None )
			{
				parent.ExecutePlayerStateChange( m_scheduledState );
				m_scheduledState = PS_None;
			}
			return true;
		}
		
		return parent.OnAnimEvent( animEventName, animEventTime, animEventType );
	}
	
	event OnChangePlayerState( newState : EPlayerState )
	{
		m_scheduledState = newState;
	}
	
	final function HasStateChangeScheduled() : bool
	{
		return m_scheduledState != PS_None;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Movement
	
	timer function ProcessMovement( timeDelta : float )
	{		
		// Calculate player speed and rotation angle	
		if ( parent.isMovable )
		{
			CalculatePlayerSpeed( timeDelta );
						
			if ( thePlayer.GetCurrentActionType() != ActorAction_Sliding )
			{
				parent.ActionMoveCustomAsync( new CMoveTRGPlayerManualMovement in parent );
			}
		}
		else
		{
			ResetMovementFlags();
		}
						
		// Process camera
		ProcessCamera( timeDelta );
		
		OnProcessMovement( parent.rawPlayerSpeed, parent.rawPlayerAngle );
	}
	
	private function ResetMovementFlags()
	{
		var currRotation : EulerAngles;
		currRotation = parent.GetWorldRotation();
		
		parent.rawPlayerSpeed = 0.f;
		parent.rawPlayerAngle = 0.f;
		parent.rawPlayerHeading = currRotation.Yaw;
	}
	
	event OnProcessMovement( rawSpeed, rawAngle : float );
	
	private function ProcessCamera( timeDelta : float )
	{
		var cameraUpDown, cameraLeftRight : float;

		thePlayer.HandleHUDTimer();
	    thePlayer.IncHUDTimer();

		// Update camera
		if ( thePlayer.GetCurrentStateName() != 'CombatSteel' && thePlayer.GetCurrentStateName() != 'CombatSilver' )
		{
			parent.cameraFurther = 0.0;
			parent.cameraFurtherCurrent = 0.0;
		}
		
		if ( !parent.IsPlayerCameraBlocked() )
		{
			// Dynamic zoom in/out camera in combat
			if ( parent.cameraFurtherCurrent != parent.cameraFurther ) //&& !thePlayer.turnOffCombatCamera )
			{
				if (parent.cameraFurtherCurrent > parent.cameraFurther)	
				{
					parent.cameraFurtherCurrent = parent.cameraFurtherCurrent - 0.02; 
				}	
				else if (parent.cameraFurtherCurrent < parent.cameraFurther - 0.15)
				{
					parent.cameraFurtherCurrent = parent.cameraFurtherCurrent + 0.01;
				}
			}
		}
		theCamera.SetZoom(parent.cameraFurtherCurrent);

		// send camera pos/rot data to hud (not at every frame)
		if (theCamera.GetHudDataDelay() <= 0.0)
		{
			theCamera.SetHudDataDelay(0.1);
			theHud.m_hud.SendNavigationDataToGUI( thePlayer );
		} 
		else
		{
			theCamera.SetHudDataDelay(theCamera.GetHudDataDelay() - 0.1);
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnActionStarted( actionType : EActorActionType )
	{
		parent.OnActionStarted( actionType );
		
		// PAKSAS TODO: co jak sie odpala inna akcja?
		//parent.wasMovableBeforeAction = isMovable;
		//SetManualControl( false, true );
	}
	
	event OnActionEnded( actionType : EActorActionType, result : bool )
	{
		parent.OnActionEnded( actionType, result );
		
		// PAKSAS TODO:!!!!!
		// SetManualControl( parent.wasMovableBeforeAction, true );
	}
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	event OnIsManualControl()
	{
		return parent.isMovable;
	}
	
	event OnResetMovement()
	{
		var agent : CMovingAgentComponent = parent.GetMovingAgentComponent();
		
		ProcessCamera( 0.f );
		agent.SetBehaviorVariable( "headingChange", 0 );
	}
	
	event OnDoesSupportRapidTurns( speedVal : float )
	{
		return speedVal >= 2.0;
	}
	
	function CalculatePlayerSpeed( timeDelta : float )
	{
		var cameraRelativeHeading 		: float;
		var worldHeading				: float;
		var playerRelativeHeading		: float;
		var playerRotation 				: EulerAngles = thePlayer.GetWorldRotation();
		var cameraRotation 				: float = theGame.GetActiveCameraComponent().GetHeading();//VecHeading( theCamera.GetCameraDirection() );
		
		parent.EvaluateMovement( timeDelta, parent.rawPlayerSpeed, cameraRelativeHeading );
		worldHeading = AngleDistance( cameraRotation, cameraRelativeHeading );
		parent.rawPlayerHeading = worldHeading;

		playerRelativeHeading = AngleDistance( worldHeading, playerRotation.Yaw );
		parent.rawPlayerAngle = playerRelativeHeading;	

		if ( parent.IsInGuardBlock() )
		{
			// !!! Another hacky flag check - this should be a property of a state or something...
			// Anyway - if the player's blocking - clamp the speed to 0 - we don't want
			// the player to move when he's blocking
			parent.rawPlayerSpeed = 0;
		}
	}
}


class CMoveTRGPlayerManualMovement extends CMoveTRGScript
{	
	private var m_headingChangeVal			: float;
	default		m_headingChangeVal			= 0.0f;
	
	// Called in order to update the movement goal's channels
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var headingChange 	: float;
		var currHeading 	: float;
		var speedVal		: float;
		currHeading = agent.GetHeading();
		headingChange = AbsF( AngleDistance( thePlayer.rawPlayerHeading, currHeading ) );
		speedVal = thePlayer.rawPlayerSpeed;
		
		// this goal never goes out of scope
		SetFulfilled( goal, false );
		SetMaxWaitTime( goal, 1000000 );
		
		// set the goal channels
		if ( thePlayer.isMovable )
		{		
			if ( speedVal > 0 )
			{	
				SetOrientationGoal( goal, thePlayer.rawPlayerHeading );
				SetHeadingGoal( goal, VecFromHeading( thePlayer.rawPlayerHeading ) );
				// check the heading change
				if ( headingChange > 140 )
				{
					m_headingChangeVal = 1.0;
					thePlayer.SetHardlock( true );
				}
				else
				{
					m_headingChangeVal = 0.0;
					thePlayer.SetHardlock( false );
				}
				
				if(thePlayer.IsOverweightInMovement())
				{
					speedVal = MinF( speedVal, 1.9 );
				}
			}
			
			// set speed
			SetSpeedGoal( goal, speedVal );
			if ( thePlayer.OnDoesSupportRapidTurns( speedVal ) == false )
			{
				m_headingChangeVal = 0.0;
			}
			
			// inform about a sudden heading change
			agent.SetBehaviorVariable( "headingChange", m_headingChangeVal );
		}
	}
}
