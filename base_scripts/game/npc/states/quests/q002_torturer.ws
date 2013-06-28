state Q002Torturer in CNewNPC extends Base
{
	entry function StateQ002Torturer()
	{
		var Destination : CNode;
		var torturer_shield : SItemUniqueId;
		var torturer_sword : SItemUniqueId;
		var player_in_scene : CActor;
		var wpvector : Vector;
		var tarczaent : CEntity;
		var waypoint_component : CComponent;
		var voicesetResult : bool;
		//var torturerActor : CNewNPC;
		
		parent.ChangeNpcExplorationBehavior();
		
		tarczaent = theGame.GetEntityByTag('q002_torturer_shield_point');
		waypoint_component = tarczaent.GetComponent( "punkt_dojscia" );
		wpvector = waypoint_component.GetWorldPosition();
		player_in_scene = thePlayer;
		torturer_sword = parent.GetInventory().GetItemId('Executioner Sword');
		//parent.GetInventory().MountItem(torturer_sword, true);
		parent.ActionCancelAll();
		parent.ActionSlideToWithHeading( wpvector, waypoint_component.GetHeading(), 0.2f); 
		FactsAdd( "q002_shield_taken", 1 );
		//((CDrawableComponent)theGame.GetEntityByTag('q002_torturer_shield_point').GetComponent( "shield_mesh_disableable" )).SetVisible(false);
		parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'Torturer_gets_shield');	
		parent.SetAttitude(player_in_scene, AIA_Hostile);
		parent.GetInventory().MountItem(torturer_sword, true);
		// voicesetResult = parent.PlayVoiceset(3000, "torturer_react" );
		MarkGoalFinished();
		
	}
};