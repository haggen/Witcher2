///////////////////////////////////////////////////////////////////////////////////////////
/////                          Axii - quest - qte                                     /////
///////////////////////////////////////////////////////////////////////////////////////////

class AxiiQTEListener extends QTEListener
{
	var lastMashTime : EngineTime;
	
	event OnQTEMash( player : CPlayer, key : name, qteValue : float )
	{
		lastMashTime = theGame.GetEngineTime();
	}
	event OnQTESuccess( player : CPlayer, resultData : SQTEResultData )
	{
		//thePlayer.RaiseEvent( 'axii_qte_end' );
		//thePlayer.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_signs', 0.f );
		player.SetQTEListener( NULL );
	}
	event OnQTEFailure( player : CPlayer, resultData : SQTEResultData )
	{
		//thePlayer.RaiseEvent( 'axii_qte_end' );
		//thePlayer.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_signs', 0.f );
		player.SetQTEListener( NULL );
	}
}

latent storyscene function AxiiQte ( player: CStoryScenePlayer, qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, rotateToTargetTag: name ) : bool
{
/*
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta, behVariable : float;
	var witcher : CPlayer;
	var roateTarget : CEntity;
	
	witcher = thePlayer;
	roateTarget = theGame.GetEntityByTag( rotateToTargetTag );
	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	witcher.StartMashFullQTEAsync( 'QTE1', qteInitialValue, qteDurationTime, valueDecayPerSecond, valueIncreasePerMash );
	
	//if( rotateToTargetTag !='' && rotateToTargetTag !='None' )
	//{
//		witcher.ActionRotateTo( roateTarget.GetWorldPosition() );
//	}

	result = witcher.GetLastQTEResult();
	
	witcher.AttachBehavior( 'qte_quest_signs' );
		
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.3f )
		{
			behVariable = witcher.GetBehaviorVariable('QTEAxiiBlend') - 0.15f;
			
			witcher.SetBehaviorVariable( 'QTEAxiiBlend', behVariable);
		}
		else if ( timeDelta > 0.3f || timeDelta == EngineTimeToFloat(curTime))
		{
			behVariable = witcher.GetBehaviorVariable('QTEAxiiBlend') + 0.1f;
			
			witcher.SetBehaviorVariable( 'QTEAxiiBlend', behVariable);
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	} 
	

	witcher.RaiseEvent( 'axii_qte_end' );

	witcher.WaitForBehaviorNodeDeactivation( 'qte_axii_end' );

	witcher.DetachBehavior( 'qte_quest_signs' );
	//witcher.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_signs', 0.f );
		
	return result == QTER_Succeeded;
	*/
	
	var result : bool; 
	result = ImplAxiiQte( qteDurationTime, qteInitialValue, valueDecayPerSecond, valueIncreasePerMash, rotateToTargetTag );
	return result;
}

latent quest function QAxiiQte ( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, rotateToTargetTag: name ) : bool
{
	var result : bool;
	var vector : Vector;
	
	if( rotateToTargetTag )
	{
		vector = theGame.GetNodeByTag( rotateToTargetTag ).GetWorldPosition();
		thePlayer.RotateTo(vector, 0.05f);
	}
	result = ImplAxiiQte( qteDurationTime, qteInitialValue, valueDecayPerSecond, valueIncreasePerMash, rotateToTargetTag );
	return result;
}

latent function ImplAxiiQte( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, rotateToTargetTag: name ) : bool
{
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta, behVariable : float;
	var witcher : CPlayer;
	var roateTarget : CEntity;
	var res : bool;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
	
	witcher = thePlayer;
	roateTarget = theGame.GetEntityByTag( rotateToTargetTag );
	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	qteStartInfo.action = 'Use';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	witcher.StartMashFullQTEAsync( qteStartInfo );
	
	//if( rotateToTargetTag !='' && rotateToTargetTag !='None' )
	//{
	//	witcher.ActionRotateTo( roateTarget.GetWorldPosition() );
	//}

	result = witcher.GetLastQTEResult();
	
	witcher.AttachBehavior( 'qte_quest_signs' );
	
	res = witcher.WaitForBehaviorNodeDeactivation( 'ready' );
	if ( !res )
	{
		LogChannel( 'AxiiQte', "WaitForBehaviorNodeDeactivation( 'ready' ) failure" );
	}
		
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.3f )
		{
			behVariable = witcher.GetBehaviorVariable('QTEAxiiBlend') + 0.1f;
			
			witcher.SetBehaviorVariable( 'QTEAxiiBlend', behVariable);
		}
		else if ( timeDelta > 0.3f || timeDelta == EngineTimeToFloat(curTime))
		{
			behVariable = witcher.GetBehaviorVariable('QTEAxiiBlend') - 0.15f;
			
			witcher.SetBehaviorVariable( 'QTEAxiiBlend', behVariable);
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	}
	
	//LogChannel( 'AxiiQte', "1. Before raise event axii_qte_end" );

	if ( witcher.RaiseEvent( 'axii_qte_end' ) )
	{
		//LogChannel( 'AxiiQte', "2. Before wait for node deactivation" );
		witcher.WaitForBehaviorNodeDeactivation( 'qte_axii_end' );
	}
	else
	{
		LogChannel( 'AxiiQte', "WaitForBehaviorNodeDeactivation( 'qte_axii_end' )" );
	}
	//LogChannel( 'AxiiQte', "3. Before detach behavior" );
	witcher.DetachBehavior( 'qte_quest_signs' );
	//witcher.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_signs', 0.f );

	//LogChannel( 'AxiiQte', "4. Finished" );
	return result == QTER_Succeeded;
	
	//return thePlayer.StartMashFullQTE( 'QTE1', qteInitialValue, qteDurationTime, valueDecayPerSecond, valueIncreasePerMash );
	
	/*
	// TEMPORARY COMMENTED - DO NOT REMOVE THIS
	var minigame : CMinigame;
	var players  : array< CActor >;
	var winner   : int;
		
	minigame = (CMinigame) theGame.CreateEntity( thePlayer.axiiMinigame, thePlayer.GetWorldPosition() );
	if ( minigame )
	{
		players.PushBack( thePlayer );
		if ( ! minigame.StartGameWaitForResult( players, winner ) )
		{
			return true;
		}
		
		return winner == 0;
	}
	else
	{
		return true;
	}
	*/	
}

///////////////////////////////////////////////////////////////////////////////////////////
/////                          Igni - quest - qte                                     /////
///////////////////////////////////////////////////////////////////////////////////////////

class IgniQTEListener extends QTEListener
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

latent storyscene function IgniQte ( player: CStoryScenePlayer, qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, rotateToTargetTag: name ) : bool
{
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta, behVariable : float;
	var witcher : CPlayer;
	var roateTarget : CEntity;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
	
	witcher = thePlayer;
	roateTarget = theGame.GetEntityByTag( rotateToTargetTag );
	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	qteStartInfo.action = 'QTE2';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	witcher.StartMashFullQTEAsync( qteStartInfo );
	
	result = witcher.GetLastQTEResult();
	
	/*if( rotateToTargetTag !='' && rotateToTargetTag !='None' )
	{
		witcher.ActionRotateTo( roateTarget.GetWorldPosition() );
	}*/
	
	witcher.AttachBehavior( 'qte_quest_igni' );
		
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.3f )
		{
			behVariable = witcher.GetBehaviorVariable('QTEIgniBlend') - 0.15f;
			
			witcher.SetBehaviorVariable( 'QTEIgniBlend', behVariable);
		}
		else if ( timeDelta > 0.3f || timeDelta == EngineTimeToFloat(curTime))
		{
			behVariable = witcher.GetBehaviorVariable('QTEIgniBlend') + 0.1f;
			
			witcher.SetBehaviorVariable( 'QTEIgniBlend', behVariable);
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	} 
	

	witcher.RaiseEvent( 'igni_qte_end' );

	witcher.WaitForBehaviorNodeDeactivation( 'qte_igni_end' );

	witcher.DetachBehavior( 'qte_quest_igni' );
	//witcher.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_igni', 0.f );
		
	return result == QTER_Succeeded;
}

latent quest function QIgniQte ( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, rotateToTargetTag: name ) : bool
{
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta, behVariable : float;
	var witcher : CPlayer;
	var roateTarget : CEntity;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
	
	witcher = thePlayer;
	roateTarget = theGame.GetEntityByTag( rotateToTargetTag );
	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	qteStartInfo.action = 'QTE3';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	witcher.StartMashFullQTEAsync( qteStartInfo );
	
	result = witcher.GetLastQTEResult();
	
	/*if( rotateToTargetTag !='' && rotateToTargetTag !='None' )
	{
		witcher.ActionRotateTo( roateTarget.GetWorldPosition() );
	}*/
	
	witcher.AttachBehavior( 'qte_quest_igni' );
		
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.3f )
		{
			behVariable = witcher.GetBehaviorVariable('QTEIgniBlend') - 0.15f;
			
			witcher.SetBehaviorVariable( 'QTEIgniBlend', behVariable);
		}
		else if ( timeDelta > 0.3f || timeDelta == EngineTimeToFloat(curTime))
		{
			behVariable = witcher.GetBehaviorVariable('QTEIgniBlend') + 0.1f;
			
			witcher.SetBehaviorVariable( 'QTEIgniBlend', behVariable);
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	} 
	

	witcher.RaiseEvent( 'igni_qte_end' );

	witcher.WaitForBehaviorNodeDeactivation( 'qte_igni_end' );

	witcher.DetachBehavior( 'qte_quest_igni' );
	//witcher.GetRootAnimatedComponent().PopBehaviorGraph( 'qte_quest_igni', 0.f );
		
	return result == QTER_Succeeded;
}


/////////////////////////////////////////////////////////////////////////////////////
//////           Sekwencja QTE czterech przycisków - do questów                  //////
/////////////////////////////////////////////////////////////////////////////////////

latent storyscene function fourButtonQTE ( player: CStoryScenePlayer, buttonTimeOut: float, firstAction : name, secondAction : name, thirdAction : name, fourthAction : name ) : bool
{
	var res : bool;
	var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
	
	qteStartInfo.action = firstAction;
	qteStartInfo.timeOut = buttonTimeOut;
	res = thePlayer.StartSinglePressQTE( qteStartInfo );
	if( res )
	{
		qteStartInfo.action = secondAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	if( res )
	{
		qteStartInfo.action = thirdAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	if( res )
	{
		qteStartInfo.action = fourthAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	return res;
}   

latent quest function QFourButtonQTE ( player: CStoryScenePlayer, buttonTimeOut: float, firstAction : name, secondAction : name, thirdAction : name, fourthAction : name ) : bool
{
	var res : bool;
	var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
	
	qteStartInfo.action = firstAction;
	qteStartInfo.timeOut = buttonTimeOut;
	
	res = thePlayer.StartSinglePressQTE( qteStartInfo );
	if( res )
	{
		qteStartInfo.action = secondAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	if( res )
	{
		qteStartInfo.action = thirdAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	if( res )
	{
		qteStartInfo.action = fourthAction;
		res = thePlayer.StartSinglePressQTE( qteStartInfo );
	}
	
	return res;
}   

latent storyscene function singleButtonQTE( player: CStoryScenePlayer, buttonTimeOut: float, actionName : name ) : bool
{
	var res : bool;
	var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
	
	qteStartInfo.action = actionName;
	qteStartInfo.timeOut = buttonTimeOut;
	res = thePlayer.StartSinglePressQTE( qteStartInfo );
	return res;
}

latent quest function QSingleButtonQTE( player: CStoryScenePlayer, buttonTimeOut: float, actionName : name ) : bool
{
	var res : bool;
	var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
	
	qteStartInfo.action = actionName;
	qteStartInfo.timeOut = buttonTimeOut;
	res = thePlayer.StartSinglePressQTE( qteStartInfo );
	return res;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////                      QTE do questu q302                     //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

latent quest function Q302Qte ( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, ignoreWrongInput : bool ) : bool
{
	var result : bool;
	var vector : Vector;
	
	result = ImplQ302Qte( qteDurationTime, qteInitialValue, valueDecayPerSecond, valueIncreasePerMash, ignoreWrongInput );
	return result;
}

latent function ImplQ302Qte( qteDurationTime: float, qteInitialValue: float, valueDecayPerSecond: float, valueIncreasePerMash: float, ignoreWrongInput : bool ) : bool
{
	var listener : AxiiQTEListener;
	var result : EQTEResult;
	var curTime : EngineTime;
	var timeDelta, behVariable : float;
	var witcher : CPlayer;
	var res : bool;
	var qteStartInfo : SMashQTEStartInfo = SMashQTEStartInfo();
	//var item : SItemUniqueId;
	
	witcher = thePlayer;
	listener = new AxiiQTEListener in witcher;
	witcher.SetQTEListener( listener );
	
	qteStartInfo.action = 'Use';
	qteStartInfo.initialValue = qteInitialValue;
	qteStartInfo.timeOut = qteDurationTime;
	qteStartInfo.decayPerSecond = valueDecayPerSecond;
	qteStartInfo.increasePerMash = valueIncreasePerMash;
	witcher.StartMashFullQTEAsync( qteStartInfo );
	
	result = witcher.GetLastQTEResult();
		
	//item = thePlayer.GetInventory().GetItemByCategory('gloves_special', true, false);
	
	//if(item == GetInvalidUniqueId())
	//{
	//	Log("invalid item");
	//}
	
	//thePlayer.GetInventory().PlayItemEffect(item,'igni_fire_fx');
	
	while ( result == QTER_InProgress )
	{
		curTime = theGame.GetEngineTime();
		timeDelta = EngineTimeToFloat( curTime ) - EngineTimeToFloat( listener.lastMashTime );
		
		if( timeDelta <= 0.3f )
		{
			thePlayer.PlayEffect('igni_ties_fx');
			thePlayer.PlayEffect('aard_sneak');
			//thePlayer.GetInventory().PlayItemEffect(item,'igni_fire_fx');
		}
		else if ( timeDelta > 0.3f || timeDelta == EngineTimeToFloat(curTime))
		{
			thePlayer.StopEffect('igni_ties_fx');
			thePlayer.StopEffect('aard_sneak');
			//thePlayer.GetInventory().StopItemEffect(item,'igni_fire_fx');
		}
		
		result = witcher.GetLastQTEResult();
		
		Sleep( 0.1 );
	}
	
	return result == QTER_Succeeded;
}
