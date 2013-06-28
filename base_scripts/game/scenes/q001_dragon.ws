
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions for prologue boss fight
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

quest latent function Q_001_SpawnDragon( dragonTemplate : CEntityTemplate, spawnpointTag : name ) : bool
{
	var dragon : CDragon;
	var spawnpoint : CNode;
	
	spawnpoint = theGame.GetNodeByTag( spawnpointTag );
	while( !spawnpoint )
	{
		Sleep( 0.1f );
		spawnpoint = theGame.GetNodeByTag( spawnpointTag );
	}
	
	dragon = (CDragon) theGame.CreateEntity( dragonTemplate, spawnpoint.GetWorldPosition(), spawnpoint.GetWorldRotation() );
		
	theGame.SetDragon( dragon );
	
	if( dragon )
		return true;
	else
		return false;
}

quest latent function Q_001_StartBossFight() : bool
{
	var dragon : CDragon = theGame.dragon;
	
	dragon.Initialize();
	dragon.startPhase1();
	
	while( dragon.GetCurrentStateName() != 'FlyLoop' )
		Sleep(0.2);
	
	return true;
}

quest function Q_001_DragonAfterHoardings()
{
	var dragon : CDragon = theGame.dragon;
	
	dragon.PlayBurningEffectOnGround( true );
	dragon.StopFlying( true );
	dragon.OnFirstPhaseEnded();
}

quest function Q_001_StartBossFightPhase3( startingPoint : name ) : bool
{
	var dragon : CDragon = theGame.dragon;
	
	dragon.startPhase3( startingPoint );
	
	return true;
}

quest function Q_001_EndPhase3() : bool
{
	if( thePlayer.IsAlive() )
	{
		theGame.dragon.EndPhase3();
		return true;
	}
	
	return false;
}

quest latent function Q_001_startFireSolitude()
{
	var dragon : CDragon = theGame.dragon;
	var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
	
	while( dragon.GetCurrentStateName() != 'phase3' )
	{
		Sleep( 0.1f );
	}
	
	dragon.phase3FireAttack();
	
	qteStartInfo.action = 'AttackStrong';
	qteStartInfo.timeOut = 0.8f;
	qteStartInfo.ignoreWrongInput = true;
	//qteStartInfo.isSkippable = false;
	thePlayer.StartSinglePressQTEAsync( qteStartInfo );
}

quest latent function Q_001_HandleQTEResult()
{
	var node : CNode;
	var speed : float;
	var foltest : CActor = theGame.GetActorByTag( 'Foltest' );
	
	if( !thePlayer.IsAlive() )
		return;

	node = theGame.GetNodeByTag( 'jump_qte_wp' );
	thePlayer.SetManualControl( false, true );
	//HACK HACK HACK!!!
	thePlayer.SetBehaviorVariable( 'useMotionExtraction', 0.0f );
	thePlayer.SetBehaviorVariable( 'manualSpeed', 1.0f );
	foltest.SetBehaviorVariable( 'manualSpeed', 1.0f );
	//thePlayer.ActionMoveToNodeWithHeading( node, MT_Run, 1.0f, 0.2f, MFA_EXIT );
	speed = VecLength( thePlayer.GetWorldPosition() - node.GetWorldPosition() ) / (3.0f * 1.4f);
	thePlayer.ActionSlideToWithHeading( node.GetWorldPosition(), node.GetHeading(), speed );
	thePlayer.SetBehaviorVariable( 'useMotionExtraction', 1.0f );
	thePlayer.SetBehaviorVariable( 'manualSpeed', 0.0f );
	foltest.SetBehaviorVariable( 'manualSpeed', 0.0f );
	//END OF HACK
	foltest.RaiseForceEvent( 'qte_jump' );
	thePlayer.RaiseForceEvent( 'qte_jump' );
	thePlayer.WaitForBehaviorNodeDeactivation( 'jump_ended', 6.5f );
	thePlayer.SetManualControl( true, true );
}

quest function Q_001_crumbling_shake() : bool
{
	return theCamera.RaiseEvent('Camera_Shake_zagnica_hit');
}

//////// TEST ONLY
/*
quest function Q_001_TEST( startingPoint : name ) : bool
{
	theGame.dragon.test( startingPoint );
}*/
