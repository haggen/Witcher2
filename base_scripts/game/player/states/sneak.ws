state Sneak in CPlayer extends Exploration
{
	var 		behavior						: name;
	var 		currentCoverParams 				: SStealthCoverParams;
	var 		currentStealthArea 				: CStealthArea; 
	private var currentStealthAreaNormal		: Vector;
	var 		coverLeft 						: bool;
	var 		takedownParams 					: STakedownParams;
	var 		hiddenIncremented 				: bool;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.ActionCancelAll();
		theHud.m_hud.CombatLogClear();	
		theCamera.SetCameraState(CS_Stealth);
		takedownParams = STakedownParams();
		hiddenIncremented = false;
		theHud.m_hud.CombatLogClear();

		// Play sneak music - L.Sz - przenioslem zarzadzanie muzyka sneakowa do CStealthArea
//////////////////////////				
//	we must revert change
//  we cannot guarantee that OnAreaExit will be launched when player is teleported somewhere around level and parent entity of area also will be unattached				
/////////////////////////			
		//theSound.PlayMusicNonQuest( "sneak" );
/////////////////////////			
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		parent.SetWalkMode( false );
		parent.enteringObstacle = false;
		theCamera.SetCameraState(CS_Exploration);
		
		if( hiddenIncremented )
		{
			parent.SetIsHidden(false);
			hiddenIncremented = false;
		}

		// Stop sneak music L.Sz - przenioslem zarzadzanie muzyka sneakowa do CStealthArea
//////////////////////////				
//	we must revert change
//  we cannot guarantee that OnAreaExit will be launched when player is teleported somewhere around level and parent entity of area also will be unattached				
/////////////////////////			
		//theSound.StopMusic( "sneak" );
/////////////////////////			
	}
	
	event OnTakedownActor( target : CActor )
	{
		if( target.GetImmortalityMode() == AIM_None )
		{
			SetupTakedownParamsSneak( target, takedownParams );
			parent.blockSpeedReset = true;
			parent.ChangePlayerState( PS_CombatTakedown );
			
			theCamera.SetCameraState( CS_Stealth );
		
			return true;
		}
		
		return false;
	}
	
	event OnStealthKillActor( target : CActor )
	{
		SetupStealthKillParamsSneak( target, takedownParams );
		parent.blockSpeedReset = true;
		parent.ChangePlayerState( PS_CombatTakedown );
		
		theCamera.SetCameraState( CS_Stealth );
		
		return true;
	}
	
	event OnDoesSupportRapidTurns( speedVal : float )
	{
		return speedVal > 0.0f;
	}
	
	entry function EntrySneak( oldPlayerState : EPlayerState, behStateName : string )
	{
		// this function can't be interrupted, as it activates a key behavior it simply needs to activate
		parent.LockEntryFunction( true );
		
		parent.ActivateAndSyncBehavior( 'stealth' );
		
		if( parent.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponLatent( parent.GetCurrentWeapon() );
		}
		
		// Update movment
		ProcessMovement( 0 );
	
		parent.SetWalkMode( true );
		ResetSneak();
		
		thePlayer.SetIsInShadow( true );
		
		parent.LockEntryFunction( false );
	}
	
	private function ResetSneak()
	{		
		currentCoverParams = SStealthCoverParams();
		currentStealthArea = NULL;
		parent.enteringObstacle = false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Handle attack
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if ( animEventName == 'CoverSwapL_R' )
		{
			currentCoverParams = currentStealthArea.GetOpositeSide( currentCoverParams );
		}
		else if ( animEventName == 'CoverSwapR_L' )
		{		
			currentCoverParams = currentStealthArea.GetOpositeSide( currentCoverParams );
		}
		else if( animEventName == 'ExitingCover' )
		{
			coverLeft = true;
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	event OnProcessMovement( rawSpeed, rawAngle : float )
	{
		var stealthAreaOrientation	: float;
		var exitAngleDiff 			: float;
		var eventResult				: bool;
		
		super.OnProcessMovement( rawSpeed, rawAngle );
		
		// check the heading request with respect to sneak area position
		if ( currentStealthArea )
		{
			stealthAreaOrientation	= VecHeading( currentStealthAreaNormal );
			exitAngleDiff 			= AbsF( AngleDistance( stealthAreaOrientation, parent.rawPlayerHeading ) );
			
			if ( exitAngleDiff < 30 )
			{
				eventResult = parent.RaiseEvent( 'cover_exit' );
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnExitPlayerState( newState : EPlayerState )
	{
		ExitSneak( newState );
	}
	
	entry function ExitSneak( newState : EPlayerState )
	{
		var behStateName : string;
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		thePlayer.SetIsInShadow( false );
		
		if( newState == PS_CombatTakedown )
		{
			parent.TakedownActor( oldState, takedownParams );
		}
		else
		{		
			parent.PlayerStateCallEntryFunction( newState, behStateName );			
		}
	}
	
	latent function WaitPEEnabled()
	{
		while ( !parent.GetRootAnimatedComponent().IsEnabled() )
		{
			Sleep(0.1);
		}
	}
	
	entry function EnterObstacle( stealthArea : CStealthArea )
	{
		var movingSpeed,r : float;
		var ev : name;
		var coverParams : SStealthCoverParams;
		var pos,posPlayer : Vector;
		var heading, edgeOffset : float;
		var a,b, abVec, normal, dbgA, dbgB: Vector;
		var mat : Matrix;
		var rot, tmpRot : EulerAngles;
		var opposite : bool;
		var areaTypeInt : int;
		
		coverLeft = false;
		
		Log( "EnterObstacle", stealthArea );
		
		parent.enteringObstacle = true;
		
		thePlayer.SetIsInShadow( true );
	
		// Wait while moving
		while ( parent.GetRawMoveSpeed() > 0.0f )
		{
			Sleep(0.01);			
		}		
		
		WaitPEEnabled();
		
		if( stealthArea.GetWallSidePoints(a,b,normal) )
		{
			// store the normal of the area
			currentStealthAreaNormal = normal;
			
			
			dbgA = a; dbgA.Z+=0.1;
			dbgB = b; dbgB.Z+=0.1;
			parent.GetVisualDebug().AddLine('wallside',dbgA,dbgB,true,Color(255,0,0));
			dbgA = (dbgA + dbgB)*0.5;
			parent.GetVisualDebug().AddLine('wallsideNormal',dbgA, dbgA+normal,true,Color(0,0,255));
			
			posPlayer = parent.GetWorldPosition();
			abVec = VecNormalize(a-b);
			edgeOffset = 0.05;	// offset to left/right trigger edge
			if( VecLength2D( abVec ) > 2*edgeOffset )
			{
				pos = VecNearestPointOnEdge( posPlayer, a-abVec*edgeOffset, b+abVec*edgeOffset );
			}
			else
			{
				pos = (a-b)*0.5;
			}
			
			r = 0.50f;
			pos += normal * r;
									
			
			coverParams = stealthArea.coverParams;			
			
			
			// Calculate side
			mat = parent.GetLocalToWorld();
			rot = VecToRotation(abVec);
			
			if( VecDot( abVec, -mat.Y ) > 0 )
			{	
				heading = rot.Yaw + 180;
				
				coverParams.side = SCS_Right;
			}
			else
			{	
				heading = rot.Yaw;
				
				coverParams.side = SCS_Left;			
			}
			
		
			if(stealthArea.coverParams.hidesPlayer == true)
			{
				parent.SetIsHidden(true);
				hiddenIncremented = true;
			}
			
			if( !stealthArea.IsBoth() && coverParams != stealthArea.coverParams )
			{
				opposite = true;
				coverParams = stealthArea.GetOpositeSide( coverParams );
			}
							
			ev = GetObstacleStartEvent( coverParams, opposite );
			parent.RaiseForceEvent(ev);
			if( opposite )
			{
				if( coverParams.side == SCS_Right )
					parent.ActionSlideToWithHeading(pos, heading + 180, 0.4, SR_Left );
				else
					parent.ActionSlideToWithHeading(pos, heading + 180, 0.4, SR_Right );
			}
			else
			{
				parent.ActionSlideToWithHeading(pos, heading, 0.4 );
			}
						
			currentCoverParams = coverParams;			
			currentStealthArea = stealthArea;
			
			if( !stealthArea.GetInnerTriggerArea().TestPointOverlap( parent.GetWorldPosition() + Vector(0,0,1) ) )
			{
				Log( "Cannot enter sneak obstacle properly, check nearby collisions/navmesh", currentStealthArea );
				parent.SetErrorState("Cannot enter sneak obstacle properly, check nearby collisions/navmesh");
				ExitObstacle( stealthArea.coverParams.hidesPlayer, true );
			}
			
			if( currentCoverParams.type == SCT_High )
			{
				theCamera.SetCameraState(CS_Stealth);
				areaTypeInt = (int)SCT_High;
				parent.SetBehaviorVariable( "StealthEnum", (float)areaTypeInt );
			}
			else
			{
				theCamera.SetCameraState(CS_StealthLow);
				areaTypeInt = (int)SCT_Low;
				parent.SetBehaviorVariable( "StealthEnum", (float)areaTypeInt );
			}
		}
		
		parent.enteringObstacle = false;
	}
	
	entry function ExitObstacle( hidesPlayer : bool, forceAnim : bool )
	{
		var ev : name;

		if( currentStealthArea )
		{
			Log( "ExitObstacle", currentStealthArea );
		
			if( forceAnim || !coverLeft)
			{
				ev = GetObstacleEndEvent( currentCoverParams );
				if( !parent.RaiseForceEvent( ev ) )
				{	
					Log( "Event not raised", currentStealthArea );
					parent.RaiseForceEvent('IdleSlow');
				}				
			}
			
			thePlayer.SetIsInShadow( true );
			
			if( hiddenIncremented )
			{
				parent.SetIsHidden( false );
				hiddenIncremented = false;
			}
		
			theCamera.SetCameraState(CS_Stealth);
		}
		
		// reset
		ResetSneak();
	}
	
	private function GetObstacleStartEvent( params : SStealthCoverParams, opposite : bool ) : name
	{
		if( opposite )
		{
			if( params.side == SCS_Right )
			{
				return 'cover_right_start_opposite';
			}
			else if( params.side == SCS_Left )
			{
				return 'cover_left_start_opposite';	
			}		
		}
		else
		{
			if( params.side == SCS_Right )
			{
				return 'cover_right_start';
			}
			else if( params.side == SCS_Left )
			{
				return 'cover_left_start';
			}
		}
	
		Log("ERROR: GetObstacleEvent unknown params", NULL );
		parent.SetErrorState("GetObstacleEvent unknown params");
		return '';		
	}
	
	private function GetObstacleEndEvent( params : SStealthCoverParams ) : name
	{
		
		if( params.side == SCS_Right )
		{
			return 'cover_right_end';
		}
		else if( params.side == SCS_Left )
		{
			return 'cover_left_end';	
		}	
		
		Log("ERROR: GetObstacleEvent unknown params", NULL );
		parent.SetErrorState("GetObstacleEvent unknown params");
		return '';	
	}
	
	function Log( text : string, stealthArea : CStealthArea  )
	{
		if( stealthArea )
		{
			LogChannel( 'StealthArea', StrFormat( "%1 StealthArea: %2", text, stealthArea.GetName() ) );
		}
		else
		{
			LogChannel( 'StealthArea', text );
		}
	}
	
	// Update visual debug information
	event OnUpdateVisualDebug()
	{	
		var vd : CVisualDebug = parent.GetVisualDebug();
		var pos : Vector = parent.GetVisualDebugPos();	
		if( currentStealthArea )
			vd.AddText( 'dbgStealth', "Inside cover, type: "+currentCoverParams.type+", side: "+currentCoverParams.side, pos, false, 14, parent.GetVisualDebugColor(), false, 1.0 );
		else
			vd.AddText( 'dbgStealth', "Outside cover", pos, false, 14, parent.GetVisualDebugColor(), false, 1.0 );		
	}
}
