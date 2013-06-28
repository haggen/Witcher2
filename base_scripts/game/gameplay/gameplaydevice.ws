
import class CGameplayDevice extends CGameplayEntity
{
	saved var interrupted : bool;
	
	default interrupted = false;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned( spawnData );	
		EnableInterrupt( false );
	}
	
	event OnInteraction( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			if ( interactionName == 'UseDevice' )
			{
				if ( !HasSlotFor( thePlayer ) && CanBeUsedBy( thePlayer ) )
				{
					thePlayer.EntryUseDevice( this );
				}
				else
				{
					LogChannel( 'Device', "Player can't use device!" );
				}
			}
			else if ( interactionName == 'InterruptDevice' )
			{
				InterruptDevice();
				
				EnableInterrupt( false );
				
				interrupted = true;
			}
		}
	}
	
	event OnDeviceLogicStarted( logicName : string )
	{
		LogChannel( 'Device', "Device logic started - " + logicName );
	}
	
	event OnDeviceLogicFinished( logicName : string )
	{
		LogChannel( 'Device', "Device logic finished - " + logicName );
	}
	
	event OnDeviceUsingStarted()
	{
		LogChannel( 'Device', "Device using started - " + GetName() );
	}
	
	event OnDeviceUsingFinished()
	{
		LogChannel( 'Device', "Device using finished - " + GetName() );
		
		interrupted = false;
		
		EnableInterrupt( false );
	}
	
	event OnUserEnterState( user : CActor, stateName : string )
	{
		LogChannel( 'Device', "User " + user.GetName() + " - enter state " + stateName );
	}
	
	event OnUserLeaveState( user : CActor, stateName : string )
	{
		LogChannel( 'Device', "User " + user.GetName() + " - leave state " + stateName );
	}
	
	event OnMachinePartEnterState( machine : CEntity, part : CAnimatedComponent, stateName : string )
	{
		LogChannel( 'Device', "Machine part " + part.GetName() + " - enter state " + stateName );
		
		if ( !interrupted )
		{
			EnableInterrupt( CanBeInterrupted() );
		}
	}
	
	event OnMachinePartLeaveState( machine : CEntity, part : CAnimatedComponent, stateName : string )
	{
		LogChannel( 'Device', "Machine part " + part.GetName() + " - leave state " + stateName );
	}
	
	event OnDeviceInterrupted()
	{
		LogChannel( 'Device', "Interrupt" );
		
		EnableInterrupt( false );	
		interrupted = true;
	}
	
	event OnDeviceUserHit( user : CActor )
	{
		LogChannel( 'Device', "User hit - " + user.GetName() );
		
		EnableInterrupt( false );	
		interrupted = true;
	}
	
	function EnableInterrupt( flag : bool )
	{
		var comp : CInteractionComponent;
		
		comp = (CInteractionComponent)GetComponent( "interrupt" );
		if ( comp )
		{
			comp.SetEnabled( flag );
		}
	}
	
	import final function IsRunning() : bool;
	import final function CanBeUsedBy( user : CActor ) : bool;
	
	import final function BookSlotFor( user : CActor, slotPosWS : Vector, slotRotWS : EulerAngles ) : bool;
	import final function ReleaseSlotFor( user : CActor );
	import final function HasSlotFor( user : CActor ) : bool;
	
	import final function EnableSlot( num : int );
	import final function DisableSlot( num : int );
	
	import final function AddMachine( tag : name );
	import final function RemoveMachine( tag : name );
	
	import final function CanHitUser( user : CActor ) : bool;
	import final function HitUser( user : CActor );
	
	import final function CanBeInterrupted() : bool;
	import final function InterruptDevice();
	
	import final function GetLogicProgress() : float;
	
	import final function CommandBroadcastEvent( evtName : name );
	import final function CommandSetVariable( varName : string, varValue : float );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

enum EDeviceInteraction
{
	DI_Use,
	DI_Interrupt,
};

class CGameplayDeviceInteractionComponent extends CInteractionComponent
{
	editable var interactionType : EDeviceInteraction;
	
	event OnActivationTest( activator : CEntity )
	{
		var device : CGameplayDevice;
		
		device = (CGameplayDevice)GetEntity();
		
		if ( device && activator == thePlayer )
		{
			if ( interactionType == DI_Use )
			{
				return device.CanBeUsedBy( thePlayer );
			}
			else if ( interactionType == DI_Interrupt && device.IsRunning() )
			{
				return device.CanBeInterrupted();
			}
		}
		
		return false;
	}
}
