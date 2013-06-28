// Klasa obslugujaca najazd na parchment i odjazd z niegostate Cutscene in CNewNPC extends Base

state LookAtScroll in q002_parchment
{
	entry function ShowText( textId : string)
	{
		//theHud.ShowScroll( textId );
		theHud.m_hud.SetMainFrame("ui_poster.swf");
		theHud.EnableInput( false, false, false );
		Sleep(0.5f);
		theHud.InvokeOneArg("pPanelClass.SetText", FlashValueFromString( GetLocStringByKeyExt( parent.textId ) ) );
		parent.SetActive(true);
	}
	entry function HideText()
	{
		theHud.m_hud.SetMainFrame("");
		theCamera.SetActive( true );	
	}
}

class q002_parchment extends CCamera
{
	var lookAt : bool;
	editable var textId : string;
	//var camera : CCameraComponent;
	var turnOnComponent, turnOffComponent : CComponent;
	
	function SetTextId( stextId : string )
	{
		textId = stextId;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//camera = (CCameraComponent)GetComponent( "q002_camera_parchment" );
		turnOnComponent = GetComponent( "q002_confession_interaction" );
		turnOffComponent = GetComponent( "q002_confession_interaction_off" );
		lookAt = false;
		//turnOnComponent.SetEnabled( false );
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( !lookAt)
		{
		
			thePlayer.RaiseForceEvent('GlobalEnd');
			thePlayer.SetCanUseHud( false );		
			thePlayer.SetManualControl(false, true);
			thePlayer.BlockPlayerState( thePlayer.GetCurrentPlayerState() );
			turnOnComponent.SetEnabled( false );
			//turnOffComponent.SetEnabled( true );
			lookAt = true;
			Log ("camera entity ====" + this.IsActive());
			ShowText( textId );
		}
		else
		{
			thePlayer.SetCanUseHud( true );		
			//turnOnComponent.SetEnabled( true );
			turnOffComponent.SetEnabled( false );
			thePlayer.SetManualControl(true, true);
			thePlayer.UnblockAllPlayerStates();
			HideText();
			lookAt = false;
		}
	}
}