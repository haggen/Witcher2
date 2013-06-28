
state UseDevice in CPlayer extends Movable
{
	var device : CGameplayDevice;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetManualControl( false, true );
	}
	
	event OnLeaveState()
	{
		if ( device )
		{
			LogChannel( 'Device', "WARN Player is leaving state using device" );
			
			device.ReleaseSlotFor( parent );
			
			device = NULL;
		}
		parent.SetManualControl( true, true );
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
	
	entry function EntryUseDevice( inputDevice : CGameplayDevice )
	{
		var posWS : Vector;
		var rotWS : EulerAngles;
		var ret : bool;
		
		if ( device )
		{
			LogChannel( 'Device', "ERROR 01 in UseDevice for CPlayer - player has got cached device!" );
		}
		
		device = inputDevice;
		
		if ( !device.BookSlotFor( parent, posWS, rotWS ) )
		{
			LogChannel( 'Device', "WARN 02 in UseDevice for CPlayer - device didn't have slot for player!" );
			FinishUseDevice();
		}
		
		// Go to slot
		//ret = parent.ActionSlideToWithHeading( posWS, rotWS.Yaw, 0.3f ); 
		ret = true;
		if ( !ret )
		{
			LogChannel( 'Device', "ERROR 05 in UseDevice for CPlayer" );
			FinishUseDevice();
		}
		
		ret = parent.ActionUseDevice( device );
		if ( !ret )
		{
			LogChannel( 'Device', "ERROR 03 in UseDevice for CPlayer" );
		}
		
		if ( device.HasSlotFor( parent ) )
		{
			LogChannel( 'Device', "ERROR 04 in UseDevice for CPlayer" );
		}
		
		device = NULL;
		
		FinishUseDevice();
	}
	
	function FinishUseDevice()
	{
		// Go to exploration
		parent.ChangePlayerState( PS_Exploration );
	}
}
