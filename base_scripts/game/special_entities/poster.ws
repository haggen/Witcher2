/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Poster
/** Copyright © 2011
/***********************************************************************/

// Klasa obslugujaca najazd na plakat i odjazd z niegostate Cutscene in CNewNPC extends Base

state LookAtPoster in poster
{
	entry function ShowText( textId : string, leaveKey : int, keyDesc : string )
	{
		var text : string;
		
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
		if(theHud.CanShowMainMenu())
		{
			theHud.ForbidOpeningMainMenu();
		}
		
		WaitForLeave( leaveKey, keyDesc );
	}
	
	entry function HideText()
	{
		//theHud.HideScroll();
		parent.new_camera.Run(false);
		parent.new_camera.Destroy();
		theHud.m_hud.SetMainFrame("");
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
	}
	
	latent function WaitForLeave( leaveKey : int, keyDesc : string )
	{
		theHud.SetWaitForKeyCode( leaveKey );
		theHud.ShowInteractionIconKeyCode( leaveKey, keyDesc );
		while ( !theHud.WasWaitKeyPressed() )
		{
			Sleep( 0.1 );
		}
		parent.ClosePoster();
	}
}

class poster extends CGameplayEntity
{
	var lookAt 				: bool;
	var turnOnComponent		: CComponent;
	var turnOffComponent	: CInteractionComponent;
	var camer_node 			: CComponent;
	var camera 				: CCameraComponent;
	var new_camera 			: CStaticCamera;
	var position 			: Vector;
	var rotation 			: EulerAngles;
	var isActivated			: bool;
	default isActivated = false;
	
	editable var camera_entity 	: CEntityTemplate;
	editable var textId 		: string; 
	
	function SetTextId( stextId : string )
	{
		textId = stextId;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		camera 				= (CCameraComponent)GetComponent( "poster_camera" );
		turnOnComponent 	= GetComponent( "poster_on_interaction" );
		turnOffComponent 	= (CInteractionComponent)GetComponent( "poster_off_interaction" );
		camer_node 			= GetComponent( "poster_camera_node" );
		lookAt 				= false;
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{	
			//theHud.m_hud.ShowTutorial("tut06", "tut06_333x166", true); // <-- tutorial content is present in external tutorial - disabled
			//theHud.ShowTutorialPanelOld( "tut06", "tut06_333x166" );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		position = this.camer_node.GetWorldPosition();
		rotation = this.camer_node.GetWorldRotation();
		
		// disable poster on fading
		if ( theGame.IsFading() )
		{
			return false;
		}
		
		if ( !lookAt )
		{
			thePlayer.SetManualControl(false, false);
			
			if(thePlayer.GetCurrentPlayerState() == PS_Exploration)
			{
				thePlayer.RaiseForceEvent('Idle');
			}
			else
			{
				thePlayer.RaiseForceEvent('GlobalEnd');
			}
			
			thePlayer.SetCanUseHud( false );
			thePlayer.SetHotKeysBlocked( true );
			thePlayer.BlockPlayerState( thePlayer.GetCurrentPlayerState() );
			turnOnComponent.SetEnabled( false );
			
			//turnOffComponent.SetEnabled( true );
			lookAt = true;
			//Log ("camera entity ====" + this.IsActive());
			
			theGame.EnableButtonInteractions( false );
			isActivated = true;
			
			ShowText( textId, turnOffComponent.GetInteractionKey(), GetLocStringByKeyExt(turnOffComponent.GetInteractionFriendlyName()) );
		}
	}
	
	public function ClosePoster()
	{
		if ( isActivated )
		{
			theHud.ShowInteractionIcon( "", "" );
		
			thePlayer.SetCanUseHud( true );
			thePlayer.SetHotKeysBlocked( false );
			turnOffComponent.SetEnabled( false );
			turnOnComponent.SetEnabled( true );
			thePlayer.SetManualControl(true, true);
			thePlayer.UnblockAllPlayerStates();
			lookAt = false;
			theGame.EnableButtonInteractions( true );
			isActivated = false;
			HideText();
		}
	}
}

/////////////////////////////////////////////////////////////////////////////

state CLookAtPoster in CPoster
{
	entry function ShowText( textId : string)
	{
		parent.Run(true);
		if(theHud.CanShowMainMenu())
		{
			theHud.ForbidOpeningMainMenu();
		}
	}
	entry function HideText()
	{
		parent.Run(false);
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
	}
}

class CPoster extends CStaticCamera
{
	editable var textId : string;
	var turnOnComponent, turnOffComponent : CComponent;
	
	function SetTextId( stextId : string )
	{
		textId = stextId;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		turnOnComponent = GetComponent( "poster_on_interaction" );
		turnOffComponent = GetComponent( "poster_off_interaction" );
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
	
		if( !IsRunning() )
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
			
			turnOnComponent.SetEnabled( false );
			turnOffComponent.SetEnabled( true );

			ShowText( textId );
		}
		else
		{
			turnOffComponent.SetEnabled( false );
			turnOnComponent.SetEnabled( true );

			thePlayer.SetManualControl(true, true);
			thePlayer.SetAllPlayerStatesBlocked( false );
			thePlayer.UnblockAllPlayerStates();
			
			HideText();
		}
	}
}
