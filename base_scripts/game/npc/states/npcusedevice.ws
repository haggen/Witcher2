
state UseDevice in CNewNPC extends Base
{
	var device : CGameplayDevice;
	
	event OnEnterState()
	{
		// Bo action cancel all
		//super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		if ( device )
		{
			LogChannel( 'Device', "WARN NPC is leaving state using device" );
			
			device.ReleaseSlotFor( parent );
			
			device = NULL;
		}
		
		super.OnLeaveState();
	}
	
	event OnBeingHit( hitParams : HitParams )
	{
		if ( device )
		{
			return device.CanHitUser( parent );
		}
		
		return true;
	}
	
	event OnHit( hitParams : HitParams )
	{
		if ( device )
		{
			device.HitUser( parent );
		}
	}

	entry function StateUseDevice( deviceHandle : EntityHandle, goalId : int )
	{
		var device : CGameplayDevice;
		var posWS : Vector;
		var rotWS : EulerAngles;
		var ret : bool;
		
		if ( device )
		{
			LogChannel( 'Device', "ERROR 01 in UseDevice for NPC - npc has got cached device!" );
		}
		
		SetGoalId( goalId );
		
		parent.ActionExitWork();
		
		device = (CGameplayDevice)EntityHandleGet( deviceHandle );
		if ( !device )
		{
			LogChannel( 'Device', "ERROR 02 in UseDevice for NPC - No goal device!" );
		}
		
		if ( !device.BookSlotFor( parent, posWS, rotWS ) )
		{
			LogChannel( 'Device', "WARN 03 in UseDevice for NPC - device didn't have slot for npc!" );
		}
		
		// Go to slot
		ret = parent.ActionMoveToWithHeading( posWS, rotWS.Yaw );
		if ( !ret )
		{
			LogChannel( 'Device', "ERROR 06 in UseDevice for NPC" );
		}
		
		ret = parent.ActionUseDevice( device );
		if ( !ret )
		{
			LogChannel( 'Device', "ERROR 04 in UseDevice for NPC" );
		}
		
		if ( device.HasSlotFor( parent ) )
		{
			LogChannel( 'Device', "ERROR 05 in UseDevice for NPC" );
		}
		
		// Reset device
		device = NULL;

		MarkGoalFinished();
	}
}
