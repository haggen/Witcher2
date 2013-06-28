/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

//brix starting phase1 of Zagnica fight
brix function ZgnStartPhase1( zgn : Zagnica )
{
	var Player : CPlayer;
	var magicBarrier : CEntity;
	
	Player = thePlayer;
	magicBarrier = (CEntity) theGame.GetNodeByTag( 'electric_obstacle' );
	
	zgn.StartPhase1();
	
//	thePlayer.EnablePhysicalMovement( true );
//	thePlayer.EnablePathEngineAgent( false);
	
	magicBarrier.PlayEffect( 'electric' );
	//Player.SetBodyPartState( 'witcher_body_1', 'bomb', true );
	theCamera.RaiseEvent( 'Camera_Zagnica' );
	
	theCamera.FocusOn( zgn.GetComponent( "mouth_focus" ) );

	Log( "Fight with Zagnica started" );
}

////////////////////////////////////////////////////////////////////////////////////
exec function ZgnMacTest()
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	zgn.RaiseEvent( 'MacTest' );
}

exec function ZgnCutsceneTest()
{
	var actors : array<CEntity>;
	var actorNames : array<string>;
	var csPos : Vector;
	var csRot : EulerAngles;
	
	actors.PushBack( theGame.GetActorByTag( 'zagnica' ) );
	actors.PushBack( thePlayer );
	actorNames.PushBack( "Root" );
	actorNames.PushBack( "witcher" );
	
	csPos = theGame.GetActorByTag( 'zagnica' ).GetWorldPosition();
	csRot = theGame.GetActorByTag( 'zagnica' ).GetWorldRotation();
	
	theGame.PlayCutsceneAsync( "rodeo_fall", actorNames, actors, csPos, csRot );
}

exec function SlowTime()
{
	theGame.SetTimeScale( 0.2f );
}

exec function NormalTime()
{
	theGame.SetTimeScale( 1.f );
}

exec function ZgnImmobilizeTest()
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	((ZagnicaMacka)zgn.Macka1).DoMackaImmobilized();
}

exec function CameraTest()
{
	var camera : CCamera;
	var ij,i,j : int;
	
	camera = theCamera;
	
	//theCamera.Reset();
	
	theCamera.TeleportWithRotation( theGame.GetNodeByTag( 'fall_wp' ).GetWorldPosition(), theGame.GetNodeByTag( 'fall_wp' ).GetWorldRotation() );
	
	for ( i=0; i<1000; i+=1 )
	{
		for ( j=0; j<1000; j+=1 )
		{
			ij+=1;
		}
	}
	//Sleep( 1 );
	
	theCamera.RaiseForceEvent( 'Camera_rodeo' );
	((CCamera)theGame.GetNodeByTag( 'camera_test' )).RaiseForceEvent( 'Camera_rodeo' );
	
	camera.SetBehaviorVectorVariable( "sourceTarget" , Vector(0,0,0) );
	camera.SetBehaviorVectorVariable( "lookAtTarget" , Vector(0,0,0) );
	
	camera.SetBehaviorVariable( "lookAtDuration" , 0 );
	camera.SetBehaviorVariable( "moveDuration" , 0 );
	
	camera.Rotate( 0, 0 );
	
	Log("#############################################################################################");
	Log( camera.GetBehaviorVariable( "sourceWeight" ) );
	Log( camera.GetBehaviorVariable( "lookAtWeight" ) );
	Log( camera.GetBehaviorVariable( "cameraFurther" ) );
	Log( camera.GetBehaviorVariable( "cameraUpDownMul" ) );
	Log( camera.GetBehaviorVariable( "cameraUpDownRot" ) );
	Log( camera.GetBehaviorVariable( "cameraLeftRightRot" ) );
	
	Log( VecToString( MatrixGetTranslation( theCamera.GetBoneWorldMatrix( 'Root' ) ) ) );
}

exec function CameraTestInfo()
{
	var rot : EulerAngles;
	rot = theCamera.GetWorldRotation();
	Log("==================================================================");
	Log ( VecToString( theCamera.GetWorldPosition() ) );
	Log( rot.Pitch +" " +rot.Roll+ " "+ rot.Yaw );
	Log( theCamera.GetBehaviorVariable( "cameraFurther" ) );
	Log( theCamera.GetBehaviorVariable( "cameraUpDownMul" ) );
	Log( theCamera.GetBehaviorVariable( "cameraUpDownRot" ) );
	Log( theCamera.GetBehaviorVariable( "cameraLeftRightRot" ) );
	Log( VecToString( MatrixGetTranslation( theCamera.GetBoneWorldMatrix( 'Root' ) ) ) );
}

exec function RotateTest()
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	zgn.ActionRotateToAsync( thePlayer.GetWorldPosition() );
}

exec function fallTest()
{
	var playerRotation : EulerAngles;
	
	playerRotation = thePlayer.GetWorldRotation();
	
	Log( "START ROTATION              " + playerRotation.Pitch + playerRotation.Roll + playerRotation.Yaw );
	
	thePlayer.EnablePathEngineAgent( false );
	thePlayer.ActivateBehavior( 'q105_rodeo_qte' );
}

exec function CollisionTest()
{
	var most : CEntity;
	var component : CStaticMeshComponent;
	
	most = (CEntity) theGame.GetNodeByTag( 'zgn_bridge' );
	
	component = (CStaticMeshComponent) most.GetComponent("CollisionMesh_hit3_1");
	
	component.SetVisible( false );
	
	component = (CStaticMeshComponent) most.GetComponent("CollisionMesh_hit3_2");

	component.SetVisible( false );
	
	component = (CStaticMeshComponent) most.GetComponent("CollisionMesh_hit3_3");
	
	component.SetVisible( false );
	
	component = (CStaticMeshComponent) most.GetComponent("CollisionMesh_hit3_4");
	
	component.SetVisible( false );
}

exec function zgnDeathTest()
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	zgn.RaiseEvent( 'bridge_hit' );
	zgn.RaiseEvent( 'bridge_hit_m1' );
	zgn.RaiseEvent( 'bridge_hit_m2' );
	zgn.RaiseEvent( 'bridge_hit_m3' );
	zgn.RaiseEvent( 'bridge_hit_m4' );
	zgn.RaiseEvent( 'bridge_hit_m5' );
	zgn.RaiseEvent( 'bridge_hit_m6' );
	
	zgn.EnterPhase2();
}

exec function mostTest(idx : int)
{
	var most : CEntity;
	var eventName : name;
	
	most = (CEntity) theGame.GetNodeByTag( 'zgn_bridge' );
	
	if( idx == 1 )
	{
		eventName = 'destruct1';
	}
	else if( idx == 2 )
	{
		eventName = 'destruct2';
	}
	else if( idx == 3 )
	{	
		eventName = 'destruct3';
	}
	
	most.RaiseEvent( eventName );
}

exec function ZgnCutTest( CutMacIndex : int )
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	zgn.TrapCutMacCutsceneZgn( CutMacIndex );
	//thePlayer.CutMacCS( 'left',CutMacIndex, zgn.GetComponent( "mac" + CutMacIndex + "_cutscene_point" ).GetWorldPosition(), zgn.GetComponent( "mac" + CutMacIndex + "_cutscene_point" ).GetWorldRotation() );
	
}

exec function TeleportTest1()
{
	thePlayer.EnablePhysicalMovement( true );
}

exec function TeleportTest2()
{
	var pos : Vector;

	pos = thePlayer.GetWorldPosition();
	pos.Z += 100;

	thePlayer.EnablePhysicalMovement( false );
	thePlayer.EnablePathEngineAgent( false );
	thePlayer.Teleport( pos );
}

exec function PhysTest()
{
	var kamulec : CEntity;

	kamulec = (CEntity) theGame.GetNodeByTag( 'TEST' );
	
	//kamulec.ForceNewDestructionState( 'Destroyed' ); // deprecated!
}

exec function ZgnAttackTest( MacIdx : int, AttackName : name )
{
	var zgn : Zagnica;
	
	zgn = (Zagnica) theGame.GetActorByTag( 'zagnica' );
	
	if( AttackName == 'vertical' )
	{
		if ( MacIdx == 0 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if( MacIdx == 1 )
		{
			((ZagnicaMacka)zgn.Macka1).DoVerticalAttack();
		}
		else if( MacIdx == 2 )
		{
			((ZagnicaMacka)zgn.Macka2).DoVerticalAttack();
		}
		else if( MacIdx == 3 )
		{
			((ZagnicaMacka)zgn.Macka3).DoVerticalAttack();
		}
		else if( MacIdx == 4 )
		{
			((ZagnicaMacka)zgn.Macka4).DoVerticalAttack();
		}
		else if( MacIdx == 5 )
		{
			((ZagnicaMacka)zgn.Macka5).DoVerticalAttack();
		}
		else if( MacIdx == 6 )
		{
			((ZagnicaMacka)zgn.Macka6).DoVerticalAttack();
		}
	}
	else if( AttackName == 'horizontal' )
	{
		if ( MacIdx == 0 || MacIdx == 2 || MacIdx == 5 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if( MacIdx == 1 )
		{
			zgn.Macka1.DoArenaHolderAttack();
		}
		else if( MacIdx == 6 )
		{
			zgn.Macka6.DoArenaHolderAttack();
		}
		else if( MacIdx == 3 )
		{
			zgn.Macka3.DoHorizontalAttack();
		}
		else if( MacIdx == 4 )
		{
			zgn.Macka4.DoHorizontalAttack();
		}
	}
	else if( AttackName == 'throw' )
	{
		if ( MacIdx != 1 && MacIdx != 6 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if( MacIdx == 1 )
		{
			zgn.Macka1.DoThrowAttack();
		}
		else if( MacIdx == 6 )
		{
			zgn.Macka6.DoThrowAttack();
		}
	}
	else if( AttackName == 'sweep' )
	{
		if ( MacIdx != 1 && MacIdx != 6 && MacIdx != 2 && MacIdx != 5 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if( MacIdx == 3 )
		{
			zgn.Macka1.DoArenaHolderAttack();
		}
		else if( MacIdx == 4 )
		{
			zgn.Macka6.DoArenaHolderAttack();
		}
	}
	else if( AttackName == 'roar' )
	{
		if ( MacIdx != 0 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if ( MacIdx == 0 )
		{
			zgn.Paszcza.DoRoarAttack();
		}
	}
	else if( AttackName == 'spit' )
	{
		if ( MacIdx != 0 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if ( MacIdx == 0 )
		{
			zgn.Paszcza.DoSpitAttack();
		}
	}
	else if( AttackName == 'escape' )
	{
		if ( MacIdx != 0 )
		{
			Log( "ERROR - this attack is unavailable for this Zagnica part" );
		}
		else if ( MacIdx == 0 )
		{
			zgn.enterCsMode();
			zgn.Macka3.DoTryingEscapeM3();
		}
	}
	
	else 
	{
		Log ( "ERROR - there is no such attack name" );
	}
}

