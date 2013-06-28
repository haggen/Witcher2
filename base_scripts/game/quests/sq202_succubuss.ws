//////////////////////////////////////////////////////////////////////////////////////////////////////////
// quest functions for q204_dragons_dream
//////////////////////////////////////////////////////////////////////////////////////////////////////////

class CWrappedBody extends CContainer
{
	editable var unwrappedAppearanceName : string;
	editable var camera_entity, spectreTemplate : CEntityTemplate;
	
	saved var bodyUnwrapped : bool;
	var camWaypoint : CComponent;
	var new_camera : CStaticCamera;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		if( bodyUnwrapped )
		{
			UnwrappedShortEntry();
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
	
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{	
		if( actionName == 'Exploration' )
		{
			Unwrap();
			GetComponent( "unwrap" ).SetEnabled( false );
		}
		
		super.OnInteraction( actionName, activator );
	}
	
	function checkLoot()
	{
		if( bodyUnwrapped )
		{
			GetComponent("Loot").SetEnabled( true );
		
			this.GetInventory().UpdateLoot();
			if ( IsLootable() )
			{
				SetVisualsFull();
			}
			else
			{
				SetVisualsEmpty();
			}
		}
	}
	
	function IsLootable() : bool
	{
		var allItems		: array< SItemUniqueId >;
		var i 				: int;
		var isAnything 		: bool;

		GetInventory().GetAllItems( allItems );
		isAnything = false;
		
		if( bodyUnwrapped )
		{
			for ( i=0; i<allItems.Size(); i+=1 )
			{
				if ( !GetInventory().ItemHasTag( allItems[i], 'NoDrop' ) && GetInventory().GetItemQuantity( allItems[i] ) > 0  )
				{
					isAnything = true;
				}
			}
		}
		
		return isAnything;
	}
}

state Unwrapped in CWrappedBody
{
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var allItems		: array< SItemUniqueId >;
		var i : int;
		var isAnything : bool;
		
		if ( activator == thePlayer && parent.bodyUnwrapped )
		{	
			theHud.HudTargetEntityEx( parent, NAPK_Container );
			if ( ! thePlayer.IsInCombat() &&
				( ! parent.lockedByKey || thePlayer.GetInventory().HasItem( parent.keyItemName ) ) )
			{
				parent.ShowLootPreview();
			}
		}
	}
	
	event OnInteractionDeactivated( interactionName:name, activator:CEntity)
	{
		parent.HideLootPreview();
		theHud.HudTargetEntityEx( NULL );
	}
	
	entry function UnwrappedShortEntry()
	{
		if( FactsDoesExist( "sq202_talked_to_elf" ) && !FactsDoesExist( "sq202_quest_failed") )
		{
			parent.GetComponent( "examine_body" ).SetEnabled( true );
		}
	}

	entry function Unwrap()
	{	
		var camWaypointPosition, spectreSpawnPos : Vector;
		var camWaypointPositionRotation : EulerAngles;
	
	//CAMERA
		parent.camWaypoint = parent.GetComponent( "cameraWaypoint" );
		camWaypointPosition = parent.camWaypoint.GetWorldPosition();
		camWaypointPositionRotation = parent.camWaypoint.GetWorldRotation();
		
		parent.new_camera = (CStaticCamera) theGame.CreateEntity(parent.camera_entity, camWaypointPosition, camWaypointPositionRotation );
		Sleep(0.1f);
		parent.new_camera.Run(true);
		Sleep(0.8f);
		
	//FADEOUT	
		theGame.FadeOut(0.5f);
		theSound.PlaySound("l03_camp/l03_quests/sq202_burned_village/sq202_fabric");
		parent.ApplyAppearance(parent.unwrappedAppearanceName); 
		Sleep( 1.f );
		
		theGame.FadeIn(0.5f);
		parent.new_camera.Run(false);
		parent.new_camera.Destroy();
		
		Sleep( 1.f );
		
		parent.bodyUnwrapped = true;

		if( FactsDoesExist( "sq202_talked_to_elf" ) && !FactsDoesExist( "sq202_quest_failed") )
		{
			parent.GetComponent( "examine_body" ).SetEnabled( true );
		}
		
		parent.checkLoot();
		
		if( RandF() > 0.5f && !parent.HasTag('sq202_dead_body') )
		{
			spectreSpawnPos = thePlayer.GetWorldPosition();
			GetFreeReachablePoint( spectreSpawnPos, 5.f, spectreSpawnPos ); 
			
			theGame.CreateEntity( parent.spectreTemplate, spectreSpawnPos );
		}
	}
}
