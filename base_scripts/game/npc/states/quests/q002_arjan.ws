state Q002Arjan in CNewNPC extends Base
{
	saved var beczka1, beczka2, beczka3, beczka4, beczka5 : bool;
	
	entry function StateQ002Arjan()
	{
		var Destination : CNode;
		var torturer_shield : SItemUniqueId;
		var torch : SItemUniqueId;
		var player_in_scene : CActor;
		var FireTarget01 : CNode;
		var FireTarget02 : CNode;
		var FireTarget03 : CNode;
		var FireTarget04 : CNode;
		var FireTarget05 : CNode;
		var EffectEntity : CEntity;
		var Targets : array <CNode>;
		var i : int;
		

		//var torturerActor : CNewNPC;
		
		parent.ChangeNpcExplorationBehavior();
		
		player_in_scene = thePlayer;
		torch = parent.GetInventory().GetItemId('Torch');
		parent.GetInventory().MountItem(torch, true);
		
		Destination = theGame.GetNodeByTag( 'podpalenie_01' );
		theGame.GetNodesByTag( 'fire_target_01', Targets );
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( Destination.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( Destination, MT_Walk, 1, 0.1f );
		
		if(!beczka1)
		{
			for (i = 0; i < Targets.Size(); i += 1 )
			{
				EffectEntity = (CEntity) Targets[i];
				EffectEntity.PlayEffect('fire');
			}
			beczka1 = true;
		}
		
		parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'ex_torch_setfire');
			
	
		//				podpalenie 02
		Destination = theGame.GetNodeByTag( 'podpalenie_02' );
		theGame.GetNodesByTag( 'fire_target_02', Targets );
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( Destination.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( Destination, MT_Walk, 1, 0.1f );
		
		if(!beczka2)
		{	
		for (i = 0; i < Targets.Size(); i += 1 )
		{
			EffectEntity = (CEntity) Targets[i];
			EffectEntity.PlayEffect('fire');
		}
			beczka2 = true;
		}
		
		parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'ex_torch_setfire');	
				
		//				podpalenie 03
		Destination = theGame.GetNodeByTag( 'podpalenie_03' );
		theGame.GetNodesByTag( 'fire_target_03', Targets );
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( Destination.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( Destination, MT_Walk, 1, 0.1f );
		
		if(!beczka3)
		{	
			for (i = 0; i < Targets.Size(); i += 1 )
				{
					EffectEntity = (CEntity) Targets[i];
					EffectEntity.PlayEffect('fire');
				}
			beczka3 = true;
		}
		
		parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'ex_torch_setfire');
		
		//				podpalenie 04
		Destination = theGame.GetNodeByTag( 'podpalenie_04' );
		theGame.GetNodesByTag( 'fire_target_04', Targets );
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( Destination.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( Destination, MT_Walk, 1, 0.1f );
		
		if(!beczka4)
			{	
			for (i = 0; i < Targets.Size(); i += 1 )
				{
					EffectEntity = (CEntity) Targets[i];
					EffectEntity.PlayEffect('fire');
				}
			beczka4 = true;
			}
		parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'ex_torch_setfire');
		
		//				podpalenie 05
		theGame.GetNodesByTag( 'fire_5', Targets );
				
		if(!beczka5)
			{	
			for (i = 0; i < Targets.Size(); i += 1 )
				{
					EffectEntity = (CEntity) Targets[i];
					EffectEntity.PlayEffect('fire');
				}
			beczka5 = true;
			}

		//torturer_shield = parent.GetInventory().GetItemId('Executioner Shield');
		//parent.GetInventory().MountItem(torturer_shield, true);
		//parent.SetAttitude(player_in_scene, AIA_Hostile);
		MarkGoalFinished();
		
	}
};