/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

////////////////////////////////////////////////////
// States for player, when Zagnica spit QTE start //
////////////////////////////////////////////////////
state SpitFinisherHit in CPlayer extends Combat
{
	event OnGameInputEvent( key : name, value : float )
	{
		return true;
	}
	
	entry function SpitFinisherHit( hitParams : HitParams, previousState : EPlayerState )
	{
		super.OnHit( hitParams );
		parent.RaiseForceEvent( 'HeavyHitUp' );
		parent.WaitForBehaviorNodeDeactivation( 'HeavyHitDeactivated', 5 );
		
		parent.ChangePlayerState( previousState );
	}
}

class SpitQTEListener extends QTEListener
{
	var lastMashTime : EngineTime;
	
	event OnQTEMash( player : CPlayer, key : name, qteValue : float )
	{
		lastMashTime = theGame.GetEngineTime();
	}
	event OnQTESuccess( player : CPlayer, resultData : SQTEResultData )
	{
		player.SetQTEListener( NULL );
	}
	event OnQTEFailure( player : CPlayer, resultData : SQTEResultData )
	{
		player.SetQTEListener( NULL );
	}
}

state ZgnSpitQTE in CPlayer extends Combat
{
	var i_mashValue,i_totalValue, i_mashDecay, mashBlendValue, i_DecayDelay : float;
	var QTEisOn : bool;
	var zgnPos, parentPos : Vector;
	var csRot : EulerAngles;
	var idx : int;
	var previousPlayerState : EPlayerState;
	
	event OnEnterState()
	{
		super.OnEnterState();
		
		zgnPos = theGame.zagnica.GetWorldPosition();
		parentPos = parent.GetWorldPosition();
		
		//idx = parent.GetInventory().GetItemByCategory('steelsword');
		//parent.DrawWeaponInstant( idx );
		
		zgnPos = zgnPos - parentPos; 
		
		csRot = VecToRotation( zgnPos );
		
		parent.SetManualControl( false, true );
		
		//parent.TeleportWithRotation( parentPos, csRot );
		parent.ActionSlideToWithHeadingAsync( parent.GetWorldPosition(), csRot.Yaw, 0.1f );
		
		parent.AttachBehavior( 'q105_spit_qte' );
		//parent.ActivateBehavior( 'q105_spit_qte' );
		parent.GetInventory().MountItem( thePlayer.GetInventory().GetItemId( 'Tentadrake Mucus' ), false );
	}
	
	event OnHit( hitParams : HitParams )
	{
		parent.SetQTEListener(NULL);
		parent.SpitFinisherHit( hitParams, previousPlayerState );
	}
	
	event OnLeaveState()
	{	
		parent.SetManualControl( true, true );
		
		parent.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId( 'Tentadrake Mucus' ), true );
		
		super.OnLeaveState();
	}
	
	entry function StartZgnSpitQTE( previousState : EPlayerState )
	{	
		var listener : SpitQTEListener;
		var result : EQTEResult;
		var curTime : EngineTime;
		var timeDelta : float;
		var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
		
		previousPlayerState = previousState;
		
		Sleep( 0.1 );
		//setting default variables
		i_mashDecay = 0.05;
		i_mashValue = 0.15;
		i_DecayDelay = 0.1;
		
		listener = new SpitQTEListener in parent;
		parent.SetQTEListener( listener );
		
		//starting witcher animation
		parent.RaiseForceEvent( 'ZgnSpitQTE_Start' );
		
		//waiting for first QTE animation to start
		parent.WaitForBehaviorNodeDeactivation ( 'QTESpitStarted' );
		
		qteStartInfo.action = 'AttackStrong';
		qteStartInfo.initialValue = 0.3f;
		qteStartInfo.timeOut = 50.0f;
		qteStartInfo.decayPerSecond = 0.2f;
		qteStartInfo.increasePerMash = 0.15f;
		qteStartInfo.ignoreWrongInput = true;
		parent.StartMashFullQTEAsync( qteStartInfo );
		result = parent.GetLastQTEResult();
		
		while ( result == QTER_InProgress )
		{
			curTime = theGame.GetEngineTime();
			timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
			if( timeDelta <= 0.5f )
			{
				mashBlendValue = parent.GetBehaviorVariable( "QTESpitmashBlend" ) + 0.15f;
			
				parent.SetBehaviorVariable( "QTESpitmashBlend", mashBlendValue );
			}
			else if ( timeDelta > 0.5f || timeDelta == EngineTimeToFloat(curTime))
			{
				mashBlendValue = parent.GetBehaviorVariable( "QTESpitmashBlend" ) - 0.15f;
			
				parent.SetBehaviorVariable( "QTESpitmashBlend", mashBlendValue );
			}
		
			result = parent.GetLastQTEResult();

			Sleep( 0.2 );
		}
		
		if( result == QTER_Succeeded )
		{
			parent.RaiseEvent( 'ZgnSpitQTE_End' );
			parent.WaitForBehaviorNodeDeactivation( 'QTESpitFinished', 3 );
			
			parent.ChangePlayerState( previousPlayerState );
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{	
		if ( key == 'GI_AxisRightX' || key == 'GI_AxisRightY' || key == 'GI_MouseDampX' || key == 'GI_MouseDampY' )
		{
			// Pass to base class input for camera
			return super.OnGameInputEvent( key, value );
		}
		
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// States for player, when Zagnica rodeo QTE starts									 //
///////////////////////////////////////////////////////////////////////////////////////
class RodeoQTEListener extends QTEListener
{
	var lastMashTime : EngineTime;
	
	event OnQTEMash( player : CPlayer, key : name, qteValue : float )
	{
		lastMashTime = theGame.GetEngineTime();
	}
	event OnQTESuccess( player : CPlayer, resultData : SQTEResultData )
	{
		player.SetQTEListener( NULL );
	}
	event OnQTEFailure( player : CPlayer, resultData : SQTEResultData )
	{
		player.SetQTEListener( NULL );
	}
}

/* DEPRECATED - now rodeo is on cutscene
state ZgnRodeoQTE in CPlayer extends Cutscene
{
	var mashBlendValue, i_DecayDelay : float;
	var zgnPos, parentPos, playerStartPos, boneRotVec : Vector;
	var boneRotation, playerStartRot : EulerAngles;
	var master : Zagnica;
	var canExitState : bool;
	
	event OnCutsceneEnded()
	{
		
	}
	
	event OnEnterState()
	{
		zgnPos = theGame.GetActorByTag( 'zagnica' ).GetWorldPosition();
		
		parentPos = parent.GetWorldPosition();
		canExitState = false;
	}
	
	event OnLeaveState()
	{
		parent.SetQTEListener(NULL);
		parent.EnablePhysicalMovement( true );
		//parent.EnablePathEngineAgent( true );
		parent.TeleportWithRotation( theGame.GetNodeByTag( 'fall_wp' ).GetWorldPosition(), theGame.GetNodeByTag( 'fall_wp' ).GetWorldRotation() );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		if( canExitState )
			parent.PlayerStateCallEntryFunction( newState, "" );
		else
			super.OnExitPlayerState( newState );
	}
	
	timer function PlayerRotation( TimeDelta : float )
	{
		var rot : EulerAngles;
		
		rot = MatrixGetRotation(master.GetBoneWorldMatrix('k_mac3_15'));
		parent.ActionSlideToWithHeadingAsync( MatrixGetTranslation(master.GetBoneWorldMatrix('k_mac3_15')), rot.Yaw, 0.1f );
		//parent.TeleportWithRotation( MatrixGetTranslation(master.GetBoneWorldMatrix('k_mac3_15')), MatrixGetRotation(master.GetBoneWorldMatrix('k_mac3_15')) );
	}
	
	entry function StartZgnRodeoQTE()
	{	
		var zgnComponent : CAnimatedComponent;
		var Rot : EulerAngles;
		var Pos : Vector;
		var listener : RodeoQTEListener;
		var result : EQTEResult;
		var curTime : EngineTime;
		var timeDelta : float;
		var temp : Vector;
		var temp2 : EulerAngles;
		var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
		
		Sleep( 0.00001 );
		
		master = (Zagnica) theGame.GetActorByTag('zagnica');
		
		zgnComponent = master.GetRootAnimatedComponent();
		
		playerStartPos = parent.GetWorldPosition();
		playerStartRot = parent.GetWorldRotation();
		
		Rot = theGame.GetNodeByTag( 'fall_wp' ).GetWorldRotation();
		Pos = theGame.GetNodeByTag( 'fall_wp' ).GetWorldPosition();
		
//		isMovable = false;
		
		parent.ActionCancelAll();
		
		parent.SetAnimationTimeMultiplier( 1.f );
		master.SetAnimationTimeMultiplier( 1.f );
		
		//parent.TeleportWithRotation( master.GetWorldPosition(), master.GetWorldRotation() );
		
		parent.EnablePhysicalMovement( false );
		parent.EnablePathEngineAgent( false );
		
		temp = MatrixGetTranslation(master.GetBoneWorldMatrix('k_mac3_15'));
		temp2 = MatrixGetRotation(master.GetBoneWorldMatrix('k_mac3_15'));
		
		//parent.TeleportWithRotation( MatrixGetTranslation(master.GetBoneWorldMatrix('k_mac3_15')), MatrixGetRotation(master.GetBoneWorldMatrix('k_mac3_15'))); 
		//parent.AddTimer( 'PlayerRotation', 0.0001f, true );
		
		parent.AttachBehavior( 'q105_rodeo_qte' );
		parent.ActivateBoneAnimatedConstraint( master, 'k_mac3_15', 'shiftWeight', 'shift' );

		
		/////////// Starting QTE ///////////
		listener = new RodeoQTEListener in parent;
		parent.SetQTEListener( listener );
		
		
		//parent.WaitForBehaviorNodeDeactivation( 'Rodeo_Started', 10 );
		
		qteStartInfo.action = 'AttackStrong';
		qteStartInfo.initialValue = 0.2f;
		qteStartInfo.timeOut = 3.0f;
		qteStartInfo.decayPerSecond = 0.2f;
		qteStartInfo.increasePerMash = 0.1f;
		parent.StartMashFullQTEAsync( qteStartInfo);	
		result = parent.GetLastQTEResult();
		
		while ( result == QTER_InProgress )
		{
			curTime = theGame.GetEngineTime();
			timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
			if( timeDelta <= 0.5f )
			{
				mashBlendValue = parent.GetBehaviorVariable( "rodeoBlend" ) + 0.3f;
			
				parent.SetBehaviorVariable( "rodeoBlend", mashBlendValue );
			}
			else if ( timeDelta > 0.5f || timeDelta == EngineTimeToFloat(curTime))
			{
				mashBlendValue = parent.GetBehaviorVariable( "rodeoBlend" ) - 0.2f;
			
				parent.SetBehaviorVariable( "rodeoBlend", mashBlendValue );
			}
		
			result = parent.GetLastQTEResult();
		
			Sleep( 0.2 );
		}
		
		parent.RaiseEvent( 'qte_finished' );
		
		if( result != QTER_Succeeded )
		{
			parent.RodeoFailed();
		}
	}
	
	entry function RodeoFailed()
	{
		master.rodeoIsFailed = true;
	}

	entry function EndRodeo()
	{
		parent.RemoveTimer( 'PlayerRotation' );
		
		parent.SetBehaviorVectorVariable( "shift", Vector(0,0,0,0) );
		parent.SetBehaviorVectorVariable( "shiftRot", Vector(0,0,0,0) );
		parent.DeactivateAnimatedConstraint( 'shiftWeight' );
	
		parent.EnablePhysicalMovement( true );
		parent.EnablePathEngineAgent( false );
		
		parent.DetachBehavior( 'q105_rodeo_qte' );
	}
	
	entry function FinalizeRodeo()
	{
		canExitState = true;
	}
}
*/

exec function rodeo()
{
	theGame.zagnica.Macka3.DoTryingEscapeM3();
}

exec function mucus( enable : bool )
{
	var item : CItemEntity;
	
	if( enable )
	{
		thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId( 'Tentadrake Mucus' ), false );
	}
	else
	{
		thePlayer.GetInventory().UnmountItem( thePlayer.GetInventory().GetItemId( 'Tentadrake Mucus' ), true );
	}
}
