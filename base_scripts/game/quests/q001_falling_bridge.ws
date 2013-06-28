///////////////////////////////////////////////////////////////////////////////////
// class for falling bridge in Q001

class CFallingBridge extends CGameplayEntity
{
	var zoneActive, destroyedParts : int;
	saved var wasDestroyed : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if ( wasDestroyed )
		{
			StartDestruction();
		}
		else
		{
			RaiseForceEvent( 'Untouched' );
		}
	}
	
	event OnAreaEnter( area: CTriggerAreaComponent, activator: CComponent )
	{
		var activatorEntity : CEntity;
		
		activatorEntity = activator.GetEntity();

		if( activatorEntity == thePlayer )
		{
			if( area.GetName() == "zone01" )
			{
				if( destroyedParts >= 1 )
				{
					thePlayer.StateDeadFall();
				}
				
				zoneActive = 1;
			}
			else if( area.GetName() == "zone02" )
			{
				if( destroyedParts >= 2 )
				{
					thePlayer.StateDeadFall();
				}
			
				zoneActive = 2;
			}
			else if( area.GetName() == "zone03" )
			{
				if( destroyedParts >= 3 )
				{
					thePlayer.StateDeadFall();
				}
			
				zoneActive = 3;
			}
			else if( area.GetName() == "zone04" )
			{
				if( destroyedParts >= 4 )
				{
					thePlayer.StateDeadFall();
				}
			
				zoneActive = 4;
			}
			else if( area.GetName() == "zone05" )
			{
				if( destroyedParts >= 5 )
				{
					thePlayer.StateDeadFall();
				}
			
				zoneActive = 5;
			}
			else if( area.GetName() == "zone06" )
			{
				if( destroyedParts >= 6 )
				{
					thePlayer.StateDeadFall();
				}
			
				zoneActive = 6;
			}
		}
	}
	
	event OnAreaExit( area: CTriggerAreaComponent, activator: CComponent )
	{
		var activatorEntity : CEntity;
		
		activatorEntity = activator.GetEntity();
		
		if( activatorEntity == thePlayer )
		{
			if( area.GetName() == "zone06" )
			{
				zoneActive = 0;
			}
		}
	}
}

state crumbling in CFallingBridge
{
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'part01_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 1 );
		}
		else if( eventName == 'part02_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 2 );
		}
		else if( eventName == 'part03_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 3 );
		}
		else if( eventName == 'part04_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 4 );
		}
		else if( eventName == 'part05_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 5 );
		}
		else if( eventName == 'part06_crumble' )
		{
			parent.destroyedParts += 1;
			CheckDestroyedZone( 6 );
		}
	}
	
	entry function StartDestruction()
	{
		parent.wasDestroyed = true;
		parent.RaiseEvent( 'destroy' );
	}
	
	private function CheckDestroyedZone( zoneIndex : int )
	{
		if( parent.zoneActive == zoneIndex )
		{
			//thePlayer.SetRagdoll( true );
			//thePlayer.RaiseForceEvent( 'DragonTowerFall' );
			thePlayer.StateDeadFall();
		}	
	}
}

quest function Q001_StartBridgeDestruction( bridgeTag : name )
{
	((CFallingBridge)theGame.GetEntityByTag( bridgeTag )).StartDestruction();
}

