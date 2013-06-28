//// class for q308 - ending

class CIvyBarrier extends CGameplayEntity
{
	saved var active : bool;

	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if( interactionName == 'IvyActivate' && activator == thePlayer && !active )
		{
			active = true;
			PlayEffect( 'activate_fx' );
		}
	}

	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if( interactionName == 'IvyDeactivate' && activator == thePlayer && active )
		{
			active = false;
			StopEffect( 'activate_fx' );
		}
	}
}