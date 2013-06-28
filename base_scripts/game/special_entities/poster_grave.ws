/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Poster Grave
/** Copyright © 2011
/***********************************************************************/

class CPosterGrave extends poster
{	
	latent function TeleportFadeIn( pozycjaGeralta : Vector )
	{
		theGame.FadeInAsync(1.f);
		Sleep(1.0f);
	}

	latent function TeleportFadeOut( pozycjaGeralta : Vector, rotacja : EulerAngles )
	{
		theGame.FadeOutAsync(1.f);
		Sleep(1.0f);
		thePlayer.TeleportWithRotation( pozycjaGeralta, rotacja );
	}
}

state LookAtPoster in CPosterGrave
{
	entry function ShowText( textId : string, leaveKey : int, keyDesc : string )
	{
		var text : string;
		var TeleportSpot : CComponent; 
		var pozycjaGeralta : Vector; 
		var rotacja : EulerAngles;
		
		thePlayer.SetCanUseHud( false );
		thePlayer.BlockPlayerState( thePlayer.GetCurrentPlayerState() );
		parent.turnOnComponent.SetEnabled( false );
		TeleportSpot = parent.GetComponent("teleport_spot");
		pozycjaGeralta = TeleportSpot.GetWorldPosition();
		rotacja = TeleportSpot.GetWorldRotation();
		parent.TeleportFadeOut( pozycjaGeralta, rotacja );
		parent.TeleportFadeIn( pozycjaGeralta );
		parent.turnOffComponent.SetEnabled( true );
		parent.lookAt = true;
		//Log ("camera entity ====" + this.IsActive());
		
		if ( textId == "" )
		{
			text = "";
		}
		else
		{
			text = GetLocStringByKeyExt( parent.textId );
		}
		//theHud.ShowScroll( textId );
		theHud.m_hud.SetMainFrame("ui_poster.swf");
		theHud.EnableInput( false, false, false );
		parent.new_camera = (CStaticCamera) theGame.CreateEntity(parent.camera_entity, parent.position, parent.rotation);
		Sleep(0.1f);
		parent.new_camera.Run(true);
		Sleep(0.5f);
		theHud.InvokeOneArg("pPanelClass.SetText", FlashValueFromString( text ) );
		
		WaitForLeave( leaveKey, keyDesc );
	}
}
