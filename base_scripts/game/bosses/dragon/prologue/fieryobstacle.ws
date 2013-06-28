/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

////////////////////////////////////////////////////////////////////////

class CFieryObstacle extends CGameplayEntity
{
	editable var fireEffectName : name;
	editable var fireZoneName, deniedAreaName : string;
	default fireEffectName = 'fire_line_start';
	default fireZoneName = "CTriggerAreaComponent0";
	default deniedAreaName = "CDeniedAreaComponent0";
	
	editable var fireDmg : float;
	editable var hurtsNPCs : bool;
	editable var isDeniedAreaEnabled : bool;	
	default isDeniedAreaEnabled = true;
	
	saved var ObstacleState : name;
	default ObstacleState = 'none';
	
	var dmgTargets : array<CActor>;
	var timerIsOn : bool;
	
	event OnSpawned( spawnData: SEntitySpawnData )
	{
		GetComponent( deniedAreaName ).SetEnabled( false );
	
		if( ObstacleState == 'burning' )
		{
			startBurning();
		}
		else if( ObstacleState == 'smoldered' )
		{
			stopBurning();
		}
	}
}

state burning in CFieryObstacle
{
	entry function startBurning()
	{		
		parent.ObstacleState = 'burning';
		parent.PlayEffect( parent.fireEffectName );
		parent.GetComponent( parent.deniedAreaName ).SetEnabled( parent.isDeniedAreaEnabled );
	}
	
	function burnActivators()
	{
		var i, arraySize : int;
		var obstaclePos : Vector;
		var target : CActor;
	
		arraySize = parent.dmgTargets.Size(); 
		obstaclePos = parent.GetWorldPosition();
			
		for( i = (arraySize - 1); i >= 0; i -= 1 )
		{
			target = parent.dmgTargets[i];
			
			if( target.IsA( 'CPlayer' ) )
			{	
				thePlayer.HitPosition( parent.GetWorldPosition(), 'Attack', parent.fireDmg, true );
				thePlayer.ApplyCriticalEffect( CET_Burn, NULL );
	
				//target.HitPosition( obstaclePos, 'Attack', parent.fireDmg, true );
				//if( target.RaiseForceEvent( 'Hit' ) )
				//{
				//	Log( "PALE SIE" );	
				//}
			}
			else 
			{
				target.ApplyCriticalEffect( CET_Burn, NULL );
			
				//target.ActionRotateToAsync( obstaclePos );
				//target.HitPosition( obstaclePos, 'FastAttack_t1', parent.fireDmg, true );
			}
		}
	}
	
	timer function dealDmg( timeDelta : float )
	{
		burnActivators();
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		areaName = area.GetName();
		
		if( areaName == parent.fireZoneName )
		{
			if( parent.hurtsNPCs )
			{
				parent.dmgTargets.PushBack( activatorActor );
			}
			else if ( !parent.hurtsNPCs && activatorActor.IsA( 'CPlayer' ) )
			{
				parent.dmgTargets.PushBack( activatorActor );
			}
			
			if( !parent.timerIsOn )
			{
				burnActivators();
				parent.AddTimer( 'dealDmg', 2.f, true );
				parent.timerIsOn = true;
			}
		}
	}	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		var areaName : string;
		
		activatorActor = (CActor) activator.GetEntity();
		areaName = area.GetName();
		
		if( areaName == parent.fireZoneName )
		{
			parent.dmgTargets.Remove( activatorActor );
			
			if( parent.dmgTargets.Size() == 0 )
			{
				parent.RemoveTimer( 'dealDmg' );
				parent.timerIsOn = false;
			}
		}
	}
}

state smoldered in CFieryObstacle
{
	entry function stopBurning()
	{
		parent.ObstacleState = 'smoldered';
		parent.StopEffect( parent.fireEffectName );
		parent.GetComponent( parent.deniedAreaName ).SetEnabled( false );
	}
}

exec function BurnStockade()
{
	var ruble : CFieryObstacle;
	
	ruble = (CFieryObstacle)theGame.GetEntityByTag( 'sq101_fiery_obstacle' );
	ruble.startBurning();
}
