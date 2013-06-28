//klasa umo¿liwiaj¹ca aktywacjê i deaktywacjê dowolnej kamery po³ozonej na lokacji oraz raizowanie eventów dzwiêkowych podczas aktywacji i deaktywacji kamery
class CFocusPoint extends CEntity
{
	editable var action : name;
	editable var blockPlayer : bool;
	editable var cameraTag : name;
	editable var riseActivateEvent : bool;
	editable var riseDeactivateEvent : bool;
	editable var activateEventName : name;
	editable var deactivateEventName : name;
	editable var entityTag : name;
	editable var GUIMask : bool;
	editable var newCamera : bool;
	
	var player : CPlayer;
	var camera : CCamera;
	var static_camera : CStaticCamera;
	var entities : array <CNode>;
	var i      : int;
	var entity : CEntity;
	var activated : bool;
	var activationInteraction : CComponent;
	var deactivationInteraction : CComponent;
	
	
	default activated = false;
	
	private function DeactivateFocusPoint()
	{
		if ( !activated )
		{	
			return;
		}
		
		if(newCamera)
		{
			static_camera.Run(false);
		}
		else
		{
			camera.SetActive(false);
		}
			
		if(blockPlayer)
		{
			thePlayer.SetManualControl(true, true);
			thePlayer.SetAllPlayerStatesBlocked( false );
			thePlayer.UnblockAllPlayerStates();
		}
		
		if (riseDeactivateEvent)
		{
			for (i = 0; i < entities.Size(); i += 1 )
			{
				entity = (CEntity) entities[i];
				theSound.PlaySoundOnActor(entity, '', deactivateEventName);
			}
		}
		
		if (GUIMask) theHud.m_fx.HoleStop();
		
		activationInteraction.SetEnabled(true);
		deactivationInteraction.SetEnabled(false);
		
		activated = false;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		activationInteraction = GetComponent( "FocusPoint" );
		deactivationInteraction = GetComponent( "FocusPointDeactivation" );
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{	
		if ( interactionName == 'FocusPointDeactivation' && activated )
		{
			DeactivateFocusPoint();
		}
	}

	event OnInteraction( actionName : name, activator : CEntity )
	{
		player = thePlayer;
		theGame.GetNodesByTag(entityTag, entities);
		
		if(newCamera)
		{
			static_camera = (CStaticCamera)theGame.GetNodeByTag(cameraTag);
			if(static_camera.IsOnStack())
			{
				activated = true;
			}
			else
			{
				activated = false;
			}
		}
		else
		{
			camera = (CCamera)theGame.GetNodeByTag(cameraTag);
			if(camera.IsOnStack())
			{
				activated = true;
			}
			else
			{
				activated = false;
			}
		}
		
		if ( actionName == action )
		{
			
			if ( !activated )
			{
				activationInteraction.SetEnabled(false);
				deactivationInteraction.SetEnabled(true);
				
				if(blockPlayer)
				{
					if(thePlayer.GetCurrentPlayerState() == PS_Exploration)
					{
						thePlayer.RaiseForceEvent('Idle');
					}
					else
					{
						thePlayer.RaiseForceEvent('GlobalEnd');
					}
					thePlayer.SetManualControl(false, true);
					thePlayer.SetAllPlayerStatesBlocked( true );
				}
				if (newCamera)
				{
					static_camera.Run(true);
				}
				else
				{
					camera.SetActive(true);
				}
			
				if (riseActivateEvent)
				{
					for (i = 0; i < entities.Size(); i += 1 )
					{
						entity = (CEntity) entities[i];
						theSound.PlaySoundOnActor(entity, '', activateEventName);
					}
				}
				
				if (GUIMask) theHud.m_fx.HoleStart();
				
				activated = true;
			}
			else
			{
				DeactivateFocusPoint();
			}
		}	
	}
}