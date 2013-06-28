// Dex test file, do not fuck with it !

class W2DexTorch extends CGameplayEntity
{
	saved var isOn : bool;
	saved var count : int;
	saved editable var other : EntityHandle;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		Log( "The state of " + this + " is: " + isOn );
		Log( "The count of " + this + " is: " + count );
		
		if ( isOn )
		{
			TurnOn();
		}		
	}
	
	event OnInteraction( interactionName : name, activator : CEntity )
	{	
		if ( isOn )
		{
			TurnOff();

			count = count + 1;

			if ( count > 3 )
			{
				Destroy();
			}
		}
		else
		{
			TurnOn();
		}	
	}
}

state Toggle in W2DexTorch
{
	entry function TurnOn()
	{
		parent.isOn = true;
		parent.GetComponent( "Toggle" ).SetEnabled( false );
		parent.PlayEffect( 'fire' );
		
		Sleep( 1.0f );
		
		parent.GetComponent( "Toggle" ).SetEnabled( true );
	}
	
	entry function TurnOff()
	{
		parent.isOn = false;
		parent.GetComponent( "Toggle" ).SetEnabled( false );
		parent.StopEffect( 'fire' );
		
		Sleep( 1.0f );
		
		parent.GetComponent( "Toggle" ).SetEnabled( true );
	}
	
}