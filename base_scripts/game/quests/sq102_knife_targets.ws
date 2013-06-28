///////////////////////////////////////////////////
// class for knives target, sq102_party, by MT

class CPartyKnivesTarget extends CActor
{
	editable var hitFactName : string;
	
	////////////////////////////////////////////////////////////////
	//things for poster functionality
	var lookAt : bool;
	editable var textId : string;
	var turnOnComponent, turnOffComponent, camer_node : CComponent;
	var camera : CCameraComponent;
	var new_camera : CStaticCamera;
	editable var camera_entity : CEntityTemplate;
	var position : Vector;
	var rotation : EulerAngles;
	
	function SetTextId( stextId : string )
	{
		textId = stextId;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		camera = (CCameraComponent)GetComponent( "poster_camera" );
		turnOnComponent = GetComponent( "poster_on_interaction" );
		turnOffComponent = GetComponent( "poster_off_interaction" );
		camer_node = GetComponent( "poster_camera_node" );
		lookAt = false;
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		position = this.camer_node.GetWorldPosition();
		rotation = this.camer_node.GetWorldRotation();
		
		if( !lookAt)
		{
			thePlayer.SetManualControl(false, true);
			thePlayer.BlockPlayerState( thePlayer.GetCurrentPlayerState() );
			turnOnComponent.SetEnabled( false );
			turnOffComponent.SetEnabled( true );
			lookAt = true;
			//Log ("camera entity ====" + this.IsActive());
			ShowText( textId );
		}
		else
		{
			turnOffComponent.SetEnabled( false );
			turnOnComponent.SetEnabled( true );
			thePlayer.SetManualControl(true, true);
			thePlayer.UnblockAllPlayerStates();
			HideText();
			lookAt = false;
		}
	}
	
	/////////////////////////////////////////////////////////////////////////
	// event for sq102
	event OnHit( hitParams : HitParams )
	{
		if( hitParams.attackType == 'FastAttack_t1' )
		{
			FactsAdd( hitFactName, 1 );
		}
	}
}

state LookAtPoster in CPartyKnivesTarget
{
	entry function ShowText( textId : string)
	{
		//theHud.ShowScroll( textId );
		theHud.m_hud.SetMainFrame("ui_poster.swf");
		theHud.EnableInput( false, false, false );
		parent.new_camera = (CStaticCamera) theGame.CreateEntity(parent.camera_entity, parent.position, parent.rotation);
		Sleep(0.1f);
		parent.new_camera.Run(true);
		Sleep(0.5f);
		theHud.InvokeOneArg("pPanelClass.SetText", FlashValueFromString( GetLocStringByKeyExt( parent.textId ) ) );
	}
	entry function HideText()
	{
		//theHud.HideScroll();
		parent.new_camera.Run(false);
		parent.new_camera.Destroy();
		theHud.m_hud.SetMainFrame("");
	}
}