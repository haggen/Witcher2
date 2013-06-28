

class CDragonA3Windows extends CDragonA3Base
{
	private var currentWindowComponent		: CAnimatedComponent;
	private var isPlayerRushing				: bool;
	private var dragonDamageFirePerSecond	: float;
	private var hitCounter					: int;
	
	function ChangeWindow( windowName : string )
	{
		var rot : EulerAngles;
		var firstWindow : bool;
		
		currentWindowComponent = (CAnimatedComponent)dragonTower.GetComponent( windowName );
		firstWindow = windowName == "wnd5";
		
		rot = currentWindowComponent.GetWorldRotation();
		rot.Yaw += 180;
		TeleportWithRotation( currentWindowComponent.GetWorldPosition(), rot );
		//TeleportWithRotation( currentWindowPoint.GetWorldPosition(), currentWindowPoint.GetWorldRotation() );
		beginDestroyingWindow( firstWindow );
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if(animEventName == 'fire_start' && animEventType == AET_Tick)
		{
			PlayEffect('fire_breath_2');
			AddTimer( 'FireCone', 0.3, true );
		}
		else if(animEventName == 'fire_stop' && animEventType == AET_Tick)
		{
			StopEffect('fire_breath_2');
			RemoveTimer( 'FireCone' );
		}
	}
	
	function HitDragon()
	{
		ActivateHit();
		
		hitCounter += 1;
		if( hitCounter > 2 )
		{
			RaiseEvent( 'fire_stop' );
			DragonLookatOff();
			hitCounter = 0;
		}
	}
}

state DestroyingWindow in CDragonA3Windows
{
	entry function beginDestroyingWindow( firstWindow : bool )
	{
		parent.isPlayerRushing = true;
		parent.currentWindowComponent.RaiseBehaviorEvent( 'destroy' );
		if( firstWindow )
			parent.dragonTower.PlayEffect( 'destroy_window_5' );
		else
			parent.dragonTower.PlayEffect( 'destroy_window_9' );
		parent.RaiseForceEvent( 'destroy_window' );
		thePlayer.KeepCombatMode();
		
		thePlayer.HitPosition( parent.currentWindowComponent.GetWorldPosition(), 'Attack_t2', 0.f, false, NULL, true );

		parent.WaitForBehaviorNodeDeactivation( 'window_destroyed' );
		
		Sleep(1);
		if( firstWindow )
			parent.dragonTower.PlayEffect( 'fire1_window5' );
		else
			parent.dragonTower.PlayEffect( 'fire1_window9' );
		Sleep(1);
		
		updateAfterWindowDestroyed();
	}
	
	entry function updateAfterWindowDestroyed()
	{
		while( parent.PlayerInRange( "FireAttack" ) )
		{
			Sleep(0.5);
		}
		parent.RaiseEvent( 'fire_stop' );
		parent.WaitForBehaviorNodeDeactivation( 'fire_stoped' );
		parent.isPlayerRushing = false;
		Sleep(3);
		
		if( !parent.PlayerInRange( "WindowRange" ) )
		{
			parent.RaiseEvent( 'fire_down' );
			parent.WaitForBehaviorNodeDeactivation( 'fire_loop' );
			parent.DragonLookatOn();
		}
		else
		{
			parent.RaiseEvent( 'fire_forward' );
			Sleep(0.5);
			updateAfterWindowDestroyed();
		}
	}
}

state Idle in CDragonA3Windows
{
	entry function enterIdle()
	{
	}
}

class CDragonWindowArea extends CEntity
{
	editable var windowName		: string;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var dragon : CDragonA3Windows;
		
		dragon = (CDragonA3Windows)theGame.GetEntityByTag( 'dragon_a3' );
		if( !dragon )
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "!!!!!Dragon doesn't exist!!!!! !!!!!THIS IS BAD AND AINT GONNA WORK!!!!!" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return false;
		}
		
		dragon.ChangeWindow( windowName );
		
		area.SetEnabled( false );
	}
}

class CDragonFireArea extends CEntity
{
	editable var isStart : bool;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var dragon : CDragonA3Windows;
		
		if( activator.GetEntity() != thePlayer )
			return false;
		
		dragon = (CDragonA3Windows)theGame.GetEntityByTag( 'dragon_a3' );
		if( !dragon )
		{
			Log( "Dragon doesn't exist!!!" );
			return false;
		}
		
		if( isStart )
		{
			start( dragon );
		}
		else
		{
			dragon.DragonLookatOff();
			dragon.RaiseForceEvent( 'fire_stop' );
		}
			
		area.SetEnabled(false);
	}
}

state Activated in CDragonFireArea
{
	entry function start( dragon : CDragonA3Windows )
	{
		dragon.enterIdle();
		if( !dragon.isPlayerRushing )
		{
			Sleep(0.5);
			dragon.RaiseForceEvent( 'fire_start' );
		}
		else
			dragon.RaiseForceEvent( 'fire_start' );
			
		dragon.DragonLookatOn();
	}
}

class CStairsCollapseArea extends CEntity
{
	editable var stairsName	: string;
	editable var firstStairs : bool;
	
	private var dragonTower		: CEntity;
	private var area	: CAreaComponent;
	private var halfarea : CAreaComponent;
	private var point	: CSpriteComponent;
	private var beforepoint	: CSpriteComponent;
	private var camera : CStaticCamera;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		area = (CAreaComponent)GetComponent( "area" );
		halfarea = (CAreaComponent)GetComponent( "halfarea" );
		point = (CSpriteComponent)GetComponent( "point" );
		beforepoint = (CSpriteComponent)GetComponent( "beforepoint" );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
			return false;
			
		dragonTower = theGame.GetEntityByTag('dragon_tower');
		if( !dragonTower )
			Log( "Dragon Tower doesn't exist!!!" );
			
		start();
		
		//area.SetEnabled( false );
	}
	
	/*event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( !firstStairs || activator.GetEntity() != thePlayer || area.GetName() != "trigger" )
			return false;
			
		camera = (CStaticCamera)theGame.GetNodeByTag( 'q307_stairs_focus_camera' );
		camera.Run(true);
		area.SetEnabled( false );
	}*/
}

state Activated in CStairsCollapseArea
{
	entry function start()
	{
		var comp : CAnimatedComponent;
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'stairs_blocker' );
		ent.TeleportWithRotation( parent.beforepoint.GetWorldPosition(), parent.beforepoint.GetWorldRotation() );

		theCamera.ExecuteCameraShake( CShake_Hit, 1.0 );
		
		if( parent.firstStairs )
		{
			Sleep( 0.5f );
		}
		
		comp = (CAnimatedComponent)parent.dragonTower.GetComponent( parent.stairsName );
		comp.RaiseBehaviorEvent('destroy');
		theSound.PlaySound( "fx/explosions/stone/cs_fx_stone_stairs_collapse" );
		
		Sleep(0.2);
		if( parent.halfarea.TestPointOverlap( thePlayer.GetWorldPosition() ) )
		{
			thePlayer.StateDeadFall();
			/*thePlayer.RaiseForceEvent( 'DragonTowerFall' );
			Sleep(0.5);
			theGame.SetTimeScale( 0.5 );
			Sleep(0.5);
			theGame.SetTimeScale( 0.8 );
			Sleep(0.2);
			theGame.SetTimeScale( 0.5 );
			Sleep(0.2);
			theGame.SetTimeScale( 1.0 );
			theHud.m_hud.SetGameOver();*/
		}
		
		Sleep(0.4);
		if( parent.area.TestPointOverlap( thePlayer.GetWorldPosition() ) )
		{
			thePlayer.StateDeadFall();
			/*thePlayer.RaiseForceEvent( 'DragonTowerFall' );
			Sleep(0.5);
			theGame.SetTimeScale( 0.5 );
			Sleep(0.5);
			theGame.SetTimeScale( 0.8 );
			Sleep(0.2);
			theGame.SetTimeScale( 0.5 );
			Sleep(0.2);
			theGame.SetTimeScale( 1.0 );
			theHud.m_hud.SetGameOver();*/
		}
		
		ent.TeleportWithRotation( parent.point.GetWorldPosition(), parent.point.GetWorldRotation() );
	}
}
