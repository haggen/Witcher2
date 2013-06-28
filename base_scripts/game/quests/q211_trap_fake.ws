///////////////////////////////////////////////////////////////////////////////////////
// Class for q211r_richon

class CFakeTrap extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		resetTrap();
	}
}

state Idle in CFakeTrap
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity().IsA( 'CPlayer' ) )
		{
			parent.activateTrap();
		}
	}
	
	entry function resetTrap()
	{
		parent.RaiseEvent( 'idle' );
	}
}

state Activated in CFakeTrap
{
	entry function activateTrap()
	{
		parent.RaiseEvent( 'trap' );
		
		Sleep( 5.f );
		
		parent.resetTrap();
	}
}
