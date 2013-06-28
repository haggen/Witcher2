///////////////////////////////////////////////////////////////////////////////////////////
/////                          Lever - quest - qte                                     /////
///////////////////////////////////////////////////////////////////////////////////////////

class LeverQTEListener extends QTEListener
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

//Sample good values: Q_209_LeverQte( 3, 0, 0.4, 0.2, ... );
latent quest function Q_209_LeverQte ( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, leverTag: name ) : bool
{
	var listener : LeverQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta : float;
	var witcher : CPlayer;
	var leverTarget : CEntity;
	var direction : Vector;
	var position : Vector;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
	
	witcher = thePlayer;
	leverTarget = theGame.GetEntityByTag( leverTag );
	listener = new LeverQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	direction = VecFromHeading( leverTarget.GetHeading() );
	position = leverTarget.GetWorldPosition() + direction * 0.8;
	
	witcher.ActionSlideToWithHeading( position, leverTarget.GetHeading() + 180, 0.5 );
	
	witcher.AttachBehavior( 'q209_qte_lever' );
	
	witcher.WaitForBehaviorNodeDeactivation ( 'QTELeverStarted' );
	
	qteStartInfo.action = 'QTE1';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	qteStartInfo.ignoreWrongInput = true;
	witcher.StartMashFullQTEAsync( qteStartInfo );	
	result = witcher.GetLastQTEResult();
		
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.2f )
		{
			witcher.RaiseEvent( 'progress' );
			leverTarget.RaiseEvent( 'progress' );
		}
		else if ( timeDelta > 0.2f || timeDelta == EngineTimeToFloat(curTime))
		{
			witcher.RaiseEvent( 'regress' );
			leverTarget.RaiseEvent( 'regress' );
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	} 

	if( result == QTER_Succeeded )
	{
		while( !witcher.RaiseEvent( 'qte_succeed' ) )
		{
			Sleep(0.1);
		}
	}
	else
	{
		witcher.RaiseEvent( 'regress' );
		leverTarget.RaiseEvent( 'regress' );
		while( !witcher.RaiseEvent( 'qte_fail' ) )
		{
			Sleep(0.1);
		}
	}

	witcher.WaitForBehaviorNodeDeactivation( 'qte_finished' );

	witcher.DetachBehavior( 'q209_qte_lever' );
		
	return result == QTER_Succeeded;
}