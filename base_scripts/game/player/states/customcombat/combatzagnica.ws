/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Combat Zagnica
/////////////////////////////////////////////

//DEPRACATED!
/*state CombatZagnica in CPlayer extends CombatSteel
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Variables
	
	var zgn : Zagnica;
	var enemyMacka : int;
	var DistanceToBone : float;
	var dodgeInProgress : bool;
	var inputBlocked : bool;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnEnterState()
	{	
		super.OnEnterState();
		
		//parent.EnablePhysicalMovement( true );
		parent.EnablePhysicalMovement( false );
		//parent.EnablePathEngineAgent( true );
		parent.AddTimer('DelayedMovementChange', 0.3, false );		
		
		zgn = (Zagnica)theGame.GetActorByTag( 'zagnica' );
		
		if ( !zgn )
		{
			Log( "ERROR Player CombatZagnica - Didn't find Zagnica actor!" );
		}
		else
		{	
			if( !zgn.FishermanSceneInProgress )
			{
				//theCamera.RaiseEvent( 'Camera_Zagnica' );
				//lockingDisabled = true;
			}
		}		
	}
	
	timer function DelayedMovementChange( timeDelta : float )
	{
		parent.EnablePhysicalMovement( true );
	}
	
	private function SetCombatCamera() {}
	
	event OnLeaveState()
	{			
		lockingDisabled = false;
		
		parent.ResetMovment();
		
		//parent.EnablePhysicalMovement( false );
		
		super.OnLeaveState();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Anim events
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		if ( animEventName == 'InAction' && animEventType == AET_DurationStart )
		{
			dodgeInProgress = true;
		}
		else if ( animEventName == 'body' )
		{
			((Zagnica)theGame.GetActorByTag('zagnica')).StartCuttingMacka();
		}
		else if (  animEventName == 'InAction' && animEventType == AET_DurationEnd )
		{
			dodgeInProgress = false;
		}
		
		super.OnAnimEvent( animEventName, animEventTime, animEventType );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game input event
	
	event OnGameInputEvent( key : name, value : float )
	{
		if( inputBlocked )
			return true;
	
		if ( key == 'PlayerChangeStateSteel' )
		{
			// Don't allow to go to exploration
			return true;
		}*/
		/*else if ( key == 'GI_Control06' && value > 0.5f )
		{
		
		}
		else if ( ( key == 'GI_Control07' || key == 'GI_AttackStrong' ) && zgn.rodeoCanBeStarted && IsKeyPressed( value ) )
		{
			zgn.rodeoCanBeStarted = false;
			zgn.Macka3.startRodeoM3();
			//parent.StartZgnRodeoQTE();
			
			//theGame.SetTimeScale( 1.f );
			
		//	zgn.SetAnimationTimeMultiplier( 1.0f );
		//	parent.SetAnimationTimeMultiplier( 1.0f );
		}*//*
		else
		{
			return super.OnGameInputEvent( key, value );
		}
	}
	
	private function DamageEnemy( attackType : name )
	{
		if ( HasEnemy() && InAttackRangeZgn( GetEnemy().GetWorldPosition() ) )
		{			
			GetEnemy().Hit( parent, attackType );
		}
	}
	
	// Checks if the specified target actor is in the attack range.
	function InAttackRangeZgn( target : Vector ) : bool
	{
	//	parent.GetVisualDebug().AddSphere( 'Target Position', 2, target, true, Color(128,0,0), 4 );
		
		DistanceToBone = VecDistance( parent.GetWorldPosition(), target );
					
		if( DistanceToBone < 3.0f && parent.IsRotatedTowardsPoint( target, 90 ) )
		{ 
			return true;
		}
		else
		{
			return false;
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enemies
	
	private function FindEnemy() : CActor
	{
		var enemies : array< CActor >;
		var enemy : CActor;
		var i : int;
		var tbf : TentadrakeBubbleFisherman;
		var tb  : TentadrakeBubble;
		enemies = parent.FindEnemiesInCombatArea(true, false);
		
		if ( enemies.Size() == 0 )
		{
			enemies = parent.FindEnemiesInCombatArea(true, true);
		}
				
		i = enemies.Size();		
		for ( i=enemies.Size()-1; i>=0; i-=1 )
		{
			enemy = enemies[i];
			
			tbf = (TentadrakeBubbleFisherman) enemies[i];
			if ( tbf && tbf.IsBubbleParentImmobilized() )
			{
				continue;
			}
			
			tb = (TentadrakeBubble) enemies[i];
			if ( tb && tb.IsBubbleParentImmobilized() )
			{
				continue;
			}
			
			enemies.Erase( i );
		}
		return SelectEnemy( enemies );
	}	

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
		
	event OnHit( hitParams : HitParams )
	{
		var macPos : Vector;
		var temp : bool;
		var X : Vector;
		var Angle : EulerAngles;
		var backPoint : Vector;
		
		parent.OnHit( hitParams );
		
		zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
		
		if( hitParams.attackType == 'vertical' )
		{
			parent.ResetMovment();
			//parent.ZgnVerticalHitPlayer();
			CalculateDamage( zgn, parent, false, true, true, true, 1 );
			
			X = parent.GetWorldPosition() - hitParams.hitPosition;
			Angle = VecToRotation( X );
			
			if( parent.IsRotatedTowards( zgn, 30 ) )
			{
				parent.RaiseForceEvent( 'HeavyHitFront' );
			}
			else if( !parent.IsRotatedTowards( zgn, 330 ) )
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			else
			{
			
				if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )
				{
					//parent.ActionRotateToAsync( hitParams.hitPosition );
					
					//parent.ActionSlideToWithHeadingAsync( parent.GetWorldPosition(), Angle.Yaw, 0.1f );
					parent.RaiseForceEvent( 'HeavyHitFront' );
				}
				else
				{
					//parent.ActionRotateToAsync( hitParams.hitPosition );
					//parent.ActionSlideToWithHeadingAsync( parent.GetWorldPosition(), Angle.Yaw, 0.1f );
					parent.RaiseForceEvent( 'HeavyHitBack' );
				}
			}

			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Vertical Attack");
			dodgeInProgress = false;
		}
		else if( hitParams.attackType == 'horizontal' && !dodgeInProgress )
		{
			parent.ResetMovment();
			CalculateDamage( zgn, parent, false, true, true, true, 1 );
		
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )
			{
				parent.RaiseForceEvent( 'HeavyHitFront' );
			}
			else
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			//parent.ZgnHorizontalHitPlayer( hitParams.hitPosition );
			
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Sweep Attack");
			dodgeInProgress = false;
		}
		else if( !zgn.ArenaHolderHasHit && hitParams.attackType == 'arenaHolder' )
		{
			parent.ResetMovment();
			
			CalculateDamage( zgn, parent, false, true, true, true, 0.8 );
		
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 100 ) )
			{
				//parent.ActionRotateToAsync( hitParams.hitPosition );
				parent.RaiseForceEvent( 'HeavyHitFrontLong' );
			}
			else
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			
			//parent.ArenaHolderHitPlayer( hitParams.hitPosition );
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Thrust Attack");
			dodgeInProgress = false;	
		}
		else if( !zgn.ArenaHolderHasHit && hitParams.attackType == 'arenaHolderBig' )
		{
			parent.ResetMovment();
			
			CalculateDamage( zgn, parent, false, true, true, true, 1.f );
		
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 100 ) )
			{
				//parent.ActionRotateToAsync( hitParams.hitPosition );
				parent.RaiseForceEvent( 'HeavyHitFrontLong' );
			}
			else
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			
			//parent.ArenaHolderHitPlayer( hitParams.hitPosition );
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Thrust Attack");
			dodgeInProgress = false;	
		}

		else if( hitParams.attackType == 'thrash' )
		{
			parent.ResetMovment();
			CalculateDamage( zgn, parent, false, true, true, true, 1 );
		
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 120 ) )
			{
				parent.RaiseForceEvent( 'HeavyHitFront' );
			}
			else
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			
			//parent.ZgnThrashHitPlayer( hitParams.hitPosition );
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Ranged Attack");
			dodgeInProgress = false;
		}
		
		else if( hitParams.attackType == 'finisher' )
		{
			parent.ResetMovment();
			
			CalculateDamage( zgn, parent, false, true, true, true, 2 );
			parent.RaiseForceEvent( 'HeavyHitBack' );
			thePlayer.BreakQTE();
			
			//parent.ZgnFinisherHitPlayer();
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Finisher Attack");
			dodgeInProgress = false;
		}
		else if( hitParams.attackType == 'roar' )
		{
			parent.ResetMovment();
			
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 100 ) )
			{
				parent.RaiseForceEvent( 'HeavyHitFrontLong' );
			}
			else
			{
				parent.RaiseForceEvent( 'HeavyHitBack' );
			}
			
			//parent.ZgnRoarHitPlayer( hitParams.hitPosition );
			//theHud.m_hud.CombatLogAdd("<span class='orange'>Tentadrake</span> hits <span class='orange'>Geralt</span> with Scream Attack");
			dodgeInProgress = false;
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter combat function
	
	entry function EntryCombatZagnica( oldPlayerState : EPlayerState, behStateName : string )
	{
		Log( "Combat Zagnica start!" );
		
		EntryCombatSteel( oldPlayerState, '');
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	entry function CutMacCS( PlayerPositionLR : name, MacIndex : int, csPos : Vector, csRot : EulerAngles )
	{
		var actors : array<CEntity>;
		var actorNames : array<string>;
		var csName: string;
		
		actors.PushBack( parent );
	//	actors.PushBack( theCamera );
		
		actorNames.PushBack( "witcher" );
	//	actorNames.PushBack( "camera" );
		
		super.SetManualControl( false, false );
		inputBlocked=true;
		
		parent.TeleportWithRotation( csPos, csRot );
		//super.SetManualControl( false, false );
		
		if( PlayerPositionLR == 'left' ) 
		{
			Sleep( 0.001f );
			
			csName = ( "witcher_cut_tentacle_mac" + MacIndex + "l" );
			theGame.PlayCutscene( csName, actorNames, actors, csPos, csRot );
		}
		else if ( PlayerPositionLR == 'right' )
		{
			Sleep( 0.001f );
		
			csName = ( "witcher_cut_tentacle_mac" + MacIndex + "r" );
			theGame.PlayCutscene( csName, actorNames, actors, csPos, csRot );
		}
				
		//parent.TeleportWithRotation( csPos, csRot );
		
		super.SetManualControl( true, true );
		inputBlocked=false;
		
	//	Sleep ( 1.f );
		//parent.EntryCombatZagnica();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function UpdateCamera()
	{
*/		
/*		var Enemies : array <CActor>;
		var i : int;
		
		// Dynamic zoom in/out camera in combat
			Enemies = parent.FindEnemiesInCombatArea(true, false);
			if (Enemies.Size() < 1)
			{
				parent.cameraFurther = 1.0;
			} else
			{	
				parent.cameraFurther = Enemies.Size();
				Enemies.Clear();
				Enemies = parent.FindEnemiesInCombatArea(false, true);
				parent.cameraFurther = parent.cameraFurther + ( ( Enemies.Size() ) * 3 ) / 2.5;
			}
*//*	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat loop function
	
	private latent function CombatLogic()
	{
		super.CombatLogic();
	}
	
	entry function LoopCombatZagnica()
	{
		while( true )
		{
			CombatLogic();
			Sleep( 0.1 );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Exit combat function
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		ExitCombatZagnica( newState );
	}

	entry function ExitCombatZagnica( newState : EPlayerState )
	{
		var behStateName : string;
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		// Get last behavior state name
		//behStateName = parent.GetCurrentBehaviorState();
		
		if ( newState == PS_Exploration )
		{
			// Go to exploration
			
			// Rise event
			//parent.RaiseEvent( 'ToExplorationSteel' );
		
			// Wait for ToExploration node activation
			//parent.WaitForEventProcessing( 'ToExplorationEnd' );
		
			// Get last behavior state name
			//behStateName = parent.GetCurrentBehaviorState();
	
			parent.EntryExploration( oldState, behStateName );
		}
		else if( newState == PS_Cutscene )
		{
			parent.EnterCutsceneZgnState( oldState, behStateName );
		}
	}
}*/
