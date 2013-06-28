class CWindowLooking extends CEntity
{
	event OnInteraction( actionName : name, activator : CEntity )
	{
		//if ( actionName == 'LookThroughWindow' && IsKeyPressed )
		if ( actionName == 'LookThroughWindow' && theCamera.GetCameraState() == CS_Exploration )
		{
			theCamera.SetCameraState( CS_Window );
		}
		else if (actionName == 'LookThroughWindow' && theCamera.GetCameraState() == CS_Window ) 
		//else if (actionName == 'LookThroughWindow' && IsKeyReleased ) 
		{
			theCamera.SetCameraState( CS_Exploration );
		}
	}
}



