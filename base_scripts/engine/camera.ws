/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Camera class
/////////////////////////////////////////////

enum ECameraState
{
	CS_Invalid = -1, 
	CS_Exploration,
	CS_Combat,
	CS_Interior,
	CS_InteriorClose,
	CS_Window,
	CS_Climb,
	CS_Zagnica,
	CS_Draug,
	CS_Stealth,
	CS_StealthLow,
	CS_Petard,
	CS_FistFight,
	CS_Meditation,
	CS_CombatClose,
	CS_Door,
	CS_FPP
};

enum ECameraShakeState
{
	CShakeState_Invalid = -1, 
	CShakeState_Normal,
	CShakeState_Tower,
	CShakeState_Ship,
	CShakeState_Drunk
};

enum ECameraShake
{
	CShake_Invalid = -1, 
	CShake_Hit,
	CShake_SiegeTowerHit,
	CShake_TrebuchetBallHit
};

import class CCameraComponent extends CSpriteComponent
{
	// Converts screen coordinates to vector in world coordinates
	import final function ViewCoordsToWorldVector( x, y : int, out rayStart : Vector, out rayDirection : Vector );
	
	// Converts screen coordinates to vector in world coordinates
	import final function WorldVectorToViewCoords( worldPos : Vector, out x : int, out y : int );
}

import class CCamera extends CEntity
{
	private var hudDataDelay : float;
	private var mECameraState : ECameraState;
	private var mECameraShakeState : ECameraShakeState;
	private var mECameraShake : int;
	default mECameraState = CS_Exploration;
	default mECameraShakeState = CShakeState_Normal;

	// Activate camera's selected camera component
	import final function SetActive( isActive : bool ) : bool;

	// Is selected camera component active
	import final function IsActive() : bool;
	
	// Is camera on stack
	import final function IsOnStack() : bool;

	// Get direction
	import final function GetCameraDirection() : Vector;

	// Get position
	import final function GetCameraPosition() : Vector;

	// Get camera position in world space
	import final function GetCameraMatrixWorldSpace() : Matrix;

	// Set fov
	import final function SetFov( fov : float );

	// Get fov
	import final function GetFov() : float;
	
	// Set zoom
	import final function SetZoom( value : float );

	// Get zoom
	import final function GetZoom() : float;

	// Reset camera state and data
	import final function Reset();
	
	// Reset camera rotations. Optionals: smoothly - true, horizontal - true, vertical - true.
	import final function ResetRotation( optional smoothly : bool, optional horizontal : bool, optional vertical : bool, optional duration : float );
	import final function ResetRotationTo( smoothly : bool, horizontalAngle : float, optional verticalAngle : float, optional duration : float );

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Rotate - use behavior for rotating
	import final function Rotate( leftRightDelta, upDownDelta : float );

	// Follow node
	import final function Follow( dest : CEntity );
	
	// Follow node with rotation
	import final function FollowWithRotation( dest : CEntity );

	// Look at target
	import final function LookAt( target : CNode, optional duration : float, optional activatingTime : float );
	
	// Look at static target 
	import final function LookAtStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	// Look at bone in an animated component
	import final function LookAtBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	// Deactivate focus on target
	import final function LookAtDeactivation( optional deactivatingTime : float );
	
	// Has look at target
	import final function HasLookAt() : bool;

	// Get look at target position
	import final function GetLookAtTargetPosition() : Vector;
	
	// Focus on target
	import final function FocusOn( target : CNode, optional duration : float, optional activatingTime : float );
	
	// Focus on static target
	import final function FocusOnStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	// Focus on bone in an animated component
	import final function FocusOnBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	// Deactivate focus
	import final function FocusDeactivation( optional deactivatingTime : float );
	
	// Is focused
	import final function IsFocused() : bool;

	// Get focus target position
	import final function GetFocusTargetPosition() : Vector;

	// Reset camera zoom parameters
	import final function ResetCameraZoom();
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// Script functions
	
	function GetHudDataDelay() : float
	{
		return hudDataDelay;
	} 
	
	function SetHudDataDelay( amount : float)
	{
		hudDataDelay = amount;
	}
	
	final function SetCameraState( newState : ECameraState ) : bool
	{
		var lCamState : int;
		var ret : bool;
		lCamState = (int) newState;
		
//Window		
		if (newState == CS_Window)
		{
			theCamera.CameraUpDownRotMul(0.2);
		}

		else
		{
			theCamera.CameraUpDownRotMul(1);
		}
//Meditation
		if (newState == CS_Meditation)
		{
			theCamera.SetBehaviorVariable('cameraOffsetsSuppres',0);
			theCamera.ResetRotationTo(true, thePlayer.GetHeading()+166, 0, 2.33);
			if (theCamera.RaiseEvent('meditation_start'))
			{
				Log("Meditation camera: meditation start event failed!!");
			}
		}

		else
		{
			theCamera.SetBehaviorVariable('cameraOffsetsSuppres',0);
		}

//Door
		if (newState == CS_Door)
		{
			theCamera.SetBehaviorVariable('cameraOffsetsSuppres',0);
			theCamera.ResetRotation(true);
		}

		else
		{
			theCamera.SetBehaviorVariable('cameraOffsetsSuppres',0);
		}

		ret = SetBehaviorVariable( "cameraState", (float) lCamState );
		if (ret) mECameraState = newState;
		return ret;
	}
	

	final function ExecuteCameraShake (newShake : ECameraShake, lShakeStrength : float ) : bool
	{
	var ret : bool;
		if ( !SetBehaviorVariable( "cameraShake", (float)(int)newShake ) )
		{
			Log( "ERROR: Camera:ExecuteCameraShake. Please DEBUG." );
			return false;
		}
		
		if ( !SetBehaviorVariable( "cameraShakeStrength", lShakeStrength ) )
		{
			Log( "ERROR: Camera:ExecuteCameraShake. Please DEBUG." );
			return false;
		}
		
		if ( !theCamera.RaiseForceEvent( 'Shake' ) )
		{
			Log( "ERROR: Camera:ExecuteCameraShake. Please DEBUG." );
			return false;
		}
		
		mECameraShake = newShake;
		
		return ret;
	}

	final function SetCameraPermamentShake (newShakeState : ECameraShakeState, lShakeStateStrength : float ) : bool
	{
		var lCamShakeState : int;
		var ret : bool;
		lCamShakeState = (int) newShakeState;
		ret = SetBehaviorVariable( "cameraShakeState", (float) lCamShakeState );
		SetBehaviorVariable( "cameraShakeStateStrength", lShakeStateStrength );
		if (ret) mECameraShakeState = newShakeState;
		return ret;

	}
	
	final function GetCameraState() : ECameraState
	{
		return mECameraState;
	}

	final function GetCameraShakeState() : ECameraShakeState
	{
		return mECameraShakeState;
	}


	final function CameraUpDownRotMul ( camMul : float )
	{
		SetBehaviorVariable( "cameraUpDownMul", camMul );
	}
	
	final function Rotate180()
	{
		var rot : EulerAngles;
		rot = GetWorldRotation();
		rot.Yaw += 180.0f;
		TeleportWithRotation( theCamera.GetWorldPosition(), rot );
	}
	
	//////////////////////////////////////////////////////////////////
	// Combo functions
	event OnComboAttack( canBeBlocked : bool, comboAttack : SBehaviorComboAttack )
	{
		return thePlayer.OnCameraComboAttack();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Quests


//funkcja zak³adaj¹ca lookat

latent quest function QCameraLookAtTarget( targetTag : name, duration: float, stop : bool, blockPlayer : bool ) : bool
{
	var target : CNode;
	var geralt : CPlayer;
	
	geralt = thePlayer;
	
	if(!stop)
	{
		target = theGame.GetNodeByTag( targetTag );
		//Sleep ( 0.5f );
		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
			geralt.ResetMovment();
		}
		theCamera.FocusOn( target );
		Sleep( duration );
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	else
	{
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	} 
	return true;
}

// i.e. used for enabling/disabling cameralookat when entering/leaving a specified trigger

latent quest function QCameraLookAtTarget2( targetTag : name, stop : bool, blockPlayer : bool ) : bool
{
	var target : CNode;
	var geralt : CPlayer;
	
	geralt = thePlayer;
	
	if(!stop)
	{
		target = theGame.GetNodeByTag( targetTag );
		//Sleep ( 0.5f );
		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
		}
		theCamera.FocusOn( target );

		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
		}
		else
		{
			geralt.SetManualControl(true, true);
		}
	}
	else
	{
		theCamera.FocusDeactivation();
		if (blockPlayer)
		{
			geralt.SetManualControl(false, false);
		}
		else
		{
			geralt.SetManualControl(true, true);
		}
	}
	return true;
}

//Funkcja pozwalaj¹ca na aktywowanie kamery po³o¿onej na lokacji
latent quest function QSetCameraActive ( cameraTag : name, duration : float, blockPlayer : bool, activate : bool) : bool
{
	var camera : CCamera;
	var geralt : CPlayer;
	
	Log( "ERROR - QSetCameraActive do przerobienia" );
	
	geralt = thePlayer;
	camera = (CCamera)theGame.GetNodeByTag(cameraTag);
	
	if (activate)
	{
		camera.SetActive(true);
		
		if(blockPlayer)
		{
			geralt.SetManualControl(false, false);
		}
		Sleep(duration);
		
		camera.SetActive(false);
		if(blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}
	}
	if (!activate)
	{
		camera.SetActive(false);
		
		if(blockPlayer)
		{
			geralt.SetManualControl(true, true);
		}	
	}
	return true;
}

// MT // Funkcja do odpalania kamera shake na kamerze
quest function QCameraShake(shakeType : ECameraShake, shakeStrength : float)
{
	theCamera.ExecuteCameraShake( shakeType, shakeStrength );
}

quest function QCameraPermamentShake( newShakeState : ECameraShakeState, lShakeStrength : float )
{
	theCamera.SetCameraPermamentShake( newShakeState, lShakeStrength );
}

//MSZ: Function for playing and stoping effects on game camera.
enum ECameraPlayEffect
{
	C_EffectStop,
	C_EffectPlay
};

quest function QPlayOrStopEffectOnCamera(effectName : name, playOrStop : ECameraPlayEffect) : bool
{
	if(playOrStop == C_EffectStop)
	{
		theCamera.StopEffect(effectName);
	}
	else if(playOrStop == C_EffectPlay)
	{
		theCamera.PlayEffect(effectName);
	}
	return true;
}

storyscene function ScenePlayOrStopEffectOnCamera(player: CStoryScenePlayer, effectName : name, playOrStop : ECameraPlayEffect) : bool
{
	if(playOrStop == C_EffectStop)
	{
		theCamera.StopEffect(effectName);
	}
	else if(playOrStop == C_EffectPlay)
	{
		theCamera.PlayEffect(effectName);
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Exec

exec function camFocusOnStatic( x : float, y : float, duration : float, actTime : float )
{
	var target : Vector;
	target = Vector( x, y, 1.8 );
	theCamera.FocusOnStatic( target, duration, actTime );
}

exec function camFocusOn( tag : name, duration : float, actTime : float )
{
	var target : CNode;
	target = theGame.GetNodeByTag( tag );
	theCamera.FocusOn( target, duration, actTime );
}

exec function camFocusOff( deactTime : float )
{
	theCamera.FocusDeactivation( deactTime );
}

exec function camLookAtStatic( x : float, y : float, duration : float, actTime : float )
{
	var target : Vector;
	target = Vector( x, y, 1.8 );
	theCamera.LookAtStatic( target, duration, actTime );
}

exec function camLookAt( tag : name, duration : float, actTime : float )
{
	var target : CNode;
	target = theGame.GetNodeByTag( tag );
	theCamera.LookAt( target, duration, actTime );
}

exec function camLookAtOff( deactTime : float )
{
	theCamera.LookAtDeactivation( deactTime );
}

exec function camSetCameraState( newState : ECameraState )
{
	theCamera.SetCameraState( newState );

}

exec function camExecuteCameraShake ( newShake : ECameraShake, lShakeStrength : float )
{
	theCamera.ExecuteCameraShake( newShake, lShakeStrength );
}

exec function SetCameraPermamentShake ( newShakeState : ECameraShakeState, lShakeStrength : float )
{
	theCamera.ExecuteCameraShake( newShakeState, lShakeStrength );
}


exec function camSetCameraUpDownMul( camMul : float )
{
	theCamera.CameraUpDownRotMul(camMul);

}

exec function camResetRotation()
{
	theCamera.ResetRotation( true, true, true );
}

exec function camResetRotationTo( angle : float, dur : float )
{
	theCamera.ResetRotationTo( true, angle, 0.f, dur );
}

exec function camResetRotationNow()
{
	theCamera.ResetRotation( false, true, true );
}

exec function camFov( newFov : float )
{
	theCamera.SetFov( newFov );
}
