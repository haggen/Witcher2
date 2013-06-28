// Specjalne Area do kolejkowania skryptowanych akcji dla NPC i obiekt obslugujacy noszone itemy. 
// Lista dedykowanych akcji ponizej.
/*

enum ELyingItems
{
	LI_None,
	LI_Lying_basket,
	LI_Lying_box_to_carry,
	LI_Idle_broom,
	LI_Lying_bucket
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Klasa triggera ktory odpala jeden zestaw skryptowanych akcji, gdy wchodzi sie w trigger i sprawdza, 
// czy postac powinna zmienic stan eksploracji i stan na powiazanym miejscu odkladania obiektu, gdy powinna cos nosic

class CCommunityScriptedActionsArea extends CGameplayEntity
{
	editable var CarriedItem : ELyingItems;
	editable var CarrierTag : name;
	editable var OnEnter_TurnOnActions : bool;	
	inlined editable var OnEnter_Actions : array< IActorLatentAction >;
	editable var WhileInside_TurnOnActions : bool;
	inlined editable var WhileInside_Actions : array< IActorLatentAction >;
	var script_area : CTriggerAreaComponent;
	var ItemIdOnDispenser : SItemUniqueId;
	var ItemIdOnNPC : SItemUniqueId;
	var ShouldStopUsingArea : bool;
	var DispenserTag : name;
	editable var AssociateDispenserTag : name;
	var dispenserSwitch : int;
	editable var SecureItemInUse : bool;
	editable var CheckForGoals : bool;
	
	default ShouldStopUsingArea = false;
	default CheckForGoals = true;
	default SecureItemInUse = false;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		script_area = ( CTriggerAreaComponent )GetComponent( "move_to_trigger" ); 
		
		if( WhileInside_TurnOnActions == true )
		{
			AddTimer( 'CheckIfInsideArea', 1.0f, true );
		}
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var carrier_npc : CNewNPC;

		carrier_npc = (CNewNPC)activator.GetEntity();
		
		if ( !carrier_npc )
		{
			return false;
		}
		if( carrier_npc.HasTag( CarrierTag ) )
		{
			if( this.OnEnter_TurnOnActions == true )
			{
				if( this.ShouldStopUsingArea == true )
				{
					//carrier_npc.GetArbitrator().ClearGoal();
					carrier_npc.GetArbitrator().AddGoalActing( OnEnter_Actions, this );
					carrier_npc.GetArbitrator().AddGoalIdle( false );
					this.ShouldStopUsingArea = false;
				}	
				else if( this.ShouldStopUsingArea == false )
				{
					carrier_npc.GetArbitrator().ClearGoal();
					carrier_npc.GetArbitrator().AddGoalActing( OnEnter_Actions, this );
					this.ShouldStopUsingArea = true;
				}	
			}
		}
	}	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		dispenserSwitch = 0;
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Timer sprawdza, czy postac jest aktualnie w obrebie CoomunityScriptedActionsArea
	
	timer function CheckIfInsideArea ( time : float )
	{
		var carrier_npc : CNewNPC;
		var carrier_npc_pos : Vector;
		var dispenser_unit : CGameplayEntity;
		var dispenser : CCommunityCarriedItemPlacement;
		
		dispenser_unit = ( CGameplayEntity )theGame.GetEntityByTag( this.AssociateDispenserTag );
		dispenser = ( CCommunityCarriedItemPlacement )dispenser_unit;	
		carrier_npc = (CNewNPC)theGame.GetNodeByTag( this.CarrierTag );
		carrier_npc_pos = carrier_npc.GetWorldPosition();
		
		if( SecureItemInUse == true )
		{
			if( this.script_area.TestPointOverlap( carrier_npc_pos ) )
			{
				ChangeCarriedItemsOnNPC( carrier_npc, carrier_npc_pos );
				
				if( this.dispenserSwitch == 0 )
				{
					dispenser.CommunityChangeDispenserStatus( dispenser );
					this.dispenserSwitch = 1;
				}	
			}
		}
		
		if( this.CheckForGoals == true )
		{
			if( carrier_npc.GetArbitrator().HasGoalsOfClass( 'CAIGoalActing' ) )
			{
				return;
			}
			else
			{
				if( this.script_area.GetName() == "move_to_trigger" )
				{
					if ( !carrier_npc )
					{
						return;
					}			
					if( this.script_area.TestPointOverlap( carrier_npc_pos ) )
					{
						carrier_npc.GetArbitrator().AddGoalActing( this.WhileInside_Actions, this );
					}
				}
			}	
		}
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// Funkcja zmieniajaca stan eksploracji postaci w zaleznosci o jej obecnego stanu i stanu zdefiniowanego w area, 
// w ktorym sie znajduje lub zdefiniowanej w akcji skryptowej
	
	public latent function CommunityChangeExState (npc : CNewNPC, dis_object : CCommunityCarriedItemPlacement )
	{
		if( CarriedItem == LI_Lying_box_to_carry )
		{
			if( npc.GetActorAnimState() == AAS_Box  )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_carry_box_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_carry_box_start', 0.3f, 0.3f, false);
			}
		}	
		else if( CarriedItem == LI_Lying_basket )
		{
			if( npc.GetActorAnimState() == AAS_FishBasket  )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_fishing_with_basket_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_fishing_with_basket_start', 0.3f, 0.3f, false);
			}
		}
		else if( CarriedItem == LI_Idle_broom )
		{
			if( npc.GetActorAnimState() == AAS_Broom )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_sweep_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_sweep_start', 0.3f, 0.3f, false);
			}
		}
		else if( CarriedItem == LI_Lying_bucket )
		{
			if( npc.GetActorAnimState() == AAS_Bucket )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_spill_dishwater_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_spill_dishwater_start', 0.3f, 0.3f, false);
			}
		}
	}	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// Funkcja dodajaca lub zabierajaca itemy w zaleznosci od tego, czy znajduje sie w obszarze, w ktory item powinien byc uzywany, 
// - jest to zabezpieczenie, jesli postac nie miala mozliwosci zabrania itemu z dyspensera (odstubowanie, load, etc. )
	
	public function ChangeCarriedItemsOnNPC (npc : CNewNPC, npc_pos : Vector )
	{
		var itemId : SItemUniqueId;
		
		if( CarriedItem == LI_Lying_box_to_carry )
		{
			itemId = npc.GetInventory().GetItemId( 'Box_to_carry' );
			
			if( this.script_area.TestPointOverlap( npc_pos ) )
			{
				if( npc.GetInventory().IsItemHeld( itemId ) == false )
				{
					npc.GetInventory().MountItem( itemId, true );
				}	
			}
			else
			{
				npc.GetInventory().UnmountItem( itemId, false );
			}
		}	
		else if( CarriedItem == LI_Lying_basket )
		{
			itemId = npc.GetInventory().GetItemId( 'Fishing_basket' );
			
			if( this.script_area.TestPointOverlap( npc_pos ) )
			{
				if( npc.GetInventory().IsItemHeld( itemId ) == false )
				{
					npc.GetInventory().MountItem( itemId, true );
				}	
			}
			else
			{
				npc.GetInventory().UnmountItem( itemId, false );
			}		
		}
		else if( CarriedItem == LI_Idle_broom )
		{
			itemId = npc.GetInventory().GetItemId( 'Broom' );
			
			if( this.script_area.TestPointOverlap( npc_pos ) )
			{
				if( npc.GetInventory().IsItemHeld( itemId ) == false )
				{
					npc.GetInventory().MountItem( itemId, true );
				}	
			}
			else
			{
				npc.GetInventory().UnmountItem( itemId, false );
			}		
		}
		else if( CarriedItem == LI_Lying_bucket )
		{
			itemId = npc.GetInventory().GetItemId( 'Bucket' );
			
			if( this.script_area.TestPointOverlap( npc_pos ) )
			{
				if( npc.GetInventory().IsItemHeld( itemId ) == false )
				{
					npc.GetInventory().MountItem( itemId, true );
				}	
			}
			else
			{
				npc.GetInventory().UnmountItem( itemId, false );
			}
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Klasa obiektu ustawiajacego noszony obiekt na lokacji i pokazujacy lub chowajacy item w zaleznosci
// od wykonanej przez npc'a operacji na obiekcie

class CCommunityCarriedItemPlacement extends CGameplayEntity
{
	editable var CarriedItem : ELyingItems;
	var ItemIdOnDispenser : SItemUniqueId;
	editable var ItemIsMounted : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);

		if ( ItemIsMounted == true )
		{
			if( CarriedItem == LI_Lying_basket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_basket' );
				GetInventory().MountItem( ItemIdOnDispenser );
			}
			else if ( CarriedItem == LI_Lying_box_to_carry )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_box_to_carry' );
				GetInventory().MountItem( ItemIdOnDispenser );
			}
			else if ( CarriedItem == LI_Idle_broom )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Idle_broom' );
				GetInventory().MountItem( ItemIdOnDispenser );
			}
			else if ( CarriedItem == LI_Lying_bucket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_bucket' );
				GetInventory().MountItem( ItemIdOnDispenser );
			}			
		}
		else
		{
			Log( "Item on " +this +"is not mounted." );
		}
	}
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// Funkcja zmieniajaca status dispensera w zaleznosci od tego, czy item jest zamontowany czy nie
	
	public function CommunityChangeDispenserStatus (dispenser : CCommunityCarriedItemPlacement )
	{
		if ( dispenser.ItemIsMounted == false )
		{
			if( CarriedItem == LI_Lying_basket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_basket' );
				GetInventory().MountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = true;
			}
			else if ( CarriedItem == LI_Lying_box_to_carry )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_box_to_carry' );
				GetInventory().MountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = true;
			}
			else if ( CarriedItem == LI_Idle_broom )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Idle_broom' );
				GetInventory().MountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = true;
			}
			else if ( CarriedItem == LI_Lying_bucket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_bucket' );
				GetInventory().MountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = true;
			}		
			else if ( CarriedItem == LI_None )
			{
				Log( "Place is waiting for an item to be brought" );
				dispenser.ItemIsMounted = false;
			}
		}
		else if( dispenser.ItemIsMounted == true )
		{
			if( CarriedItem == LI_Lying_basket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_basket' );
				GetInventory().UnmountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = false;
			}
			else if ( CarriedItem == LI_Lying_box_to_carry )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_box_to_carry' );
				GetInventory().UnmountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = false;
			}
			else if ( CarriedItem == LI_Idle_broom )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Idle_broom' );
				GetInventory().UnmountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = false;
			}
			else if ( CarriedItem == LI_Lying_bucket )
			{
				ItemIdOnDispenser = GetInventory().GetItemId( 'Lying_bucket' );
				GetInventory().UnmountItem( ItemIdOnDispenser );
				dispenser.ItemIsMounted = false;
			}		
			else if ( CarriedItem == LI_None )
			{
				Log( "Place is waiting for an item to be brought" );
				dispenser.ItemIsMounted = false;
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Akcje skryptowe
//
// 1. CCommunityActionRotateTo == Rotacja postaci w kierunku adefiniowanego node'a - po tagu
// 2. CCommunityActionMoveToNode == Podejscie do zdefiniowanego tagiem node'a punktu, z okreslona predkoscia i promieniem podejscia
// 3. CCommunityCarryingItems == zmiana stanu eksploracji postaci i usuwanie lub dodanie itemu w zaleznosci od nakladanego stanu
// 4. CCommunityChangeExplorationModeUsingArea == zmiana stanu eksploracji postaci i usuwanie lub dodanie itemu w zaleznosci od nakladanego stanu po wejsciu w zdefiniowany trigger
// 5.
// 6.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 1.

class CCommunityActionRotateTo extends IActorLatentAction
{
	editable saved var NodeToRotate : name;

	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var node_def : CNode;
		var node : CNode;
	
		node = actor.GetFocusedNode();
	
		if( NodeToRotate )
		{
			node_def = theGame.GetNodeByTag( NodeToRotate );
			actor.ActionRotateTo( node_def.GetWorldPosition() );
		}
		else 
		{
			actor.ActionRotateTo( node.GetWorldPosition() );
		}
	}	
}

// 2.

class CCommunityActionMoveToNode extends IActorLatentAction
{
	editable saved var moveType : EMoveType;
	editable saved var radius : float;
	editable saved var Destination : name;
	editable saved var AreaTag : name;
	
	default moveType = MT_Walk;
	default radius = 0.2;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var node   : CNode;	
		var area   : CCommunityScriptedActionsArea;	
	
		node = theGame.GetNodeByTag( Destination );
		area = ( CCommunityScriptedActionsArea )theGame.GetNodeByTag( AreaTag );
		
	
		if( node )
		{
			actor.ActionMoveToNodeWithHeading( node, moveType, 1.0, radius );
		}	
		if ( area )
		{
			area.DispenserTag = Destination;
		}
	}
}

// 3.

class CCommunityCarryingItems extends IActorLatentAction
{
	editable saved var CarriedItem : ELyingItems;
	editable saved var dispenserTag : name;
	var dispenser_ent : CGameplayEntity;
	var dispenser : CCommunityCarriedItemPlacement;
	var npc : CNewNPC;
	var item_id : SItemUniqueId;

	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		npc = ( CNewNPC )actor;
		dispenser_ent = ( CGameplayEntity )theGame.GetEntityByTag( dispenserTag );
		dispenser = ( CCommunityCarriedItemPlacement )dispenser_ent;
	
	//operacje na npc - ustalenie itemId obiektu przenoszonego
			
		if( CarriedItem == LI_Lying_basket )
		{
			item_id = npc.GetInventory().GetItemId( 'Fishing_basket' );
		}
		else if ( CarriedItem == LI_Lying_box_to_carry )
		{
			item_id = npc.GetInventory().GetItemId( 'Box_to_carry' );
		}
		else if ( CarriedItem == LI_Idle_broom )
		{
			item_id = npc.GetInventory().GetItemId( 'Broom' );
		}	
		else if ( CarriedItem == LI_Lying_bucket )
		{
			item_id = npc.GetInventory().GetItemId( 'Bucket' );
		}	
		else if ( CarriedItem == LI_None )
		{
			Log( "No item specified - you should choose the same item as CarriedItem" );
		}
		
		//operacje na npc
		
		if( CarriedItem == LI_Lying_box_to_carry )
		{
			if( npc.GetActorAnimState() == AAS_Box  )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_carry_box_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_carry_box_start', 0.3f, 0.3f, false);
			}
		}	
		else if( CarriedItem == LI_Lying_basket )
		{
			if( npc.GetActorAnimState() == AAS_FishBasket  )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_fishing_with_basket_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_fishing_with_basket_start', 0.3f, 0.3f, false);
			}
		}
		else if( CarriedItem == LI_Idle_broom )
		{
			if( npc.GetActorAnimState() == AAS_Broom )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_sweep_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_sweep_start', 0.3f, 0.3f, false);
			}
		}
		else if( CarriedItem == LI_Lying_bucket )
		{
			if( npc.GetActorAnimState() == AAS_Bucket )
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_spill_dishwater_stop', 0.3f, 0.3f, false);
			}
			else
			{
				npc.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'work_spill_dishwater_start', 0.3f, 0.3f, false);
			}
		}
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// Event do animacji pracy synchronizujacy animacje podnoszenia/odkladania ze statusem itemu w dispenserze

	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventName == 'take_item' )
		{
			//dispenser.GetInventory().UnmountItem( item_id, false );
			dispenser.CommunityChangeDispenserStatus( dispenser );
			npc.GetInventory().MountItem( this.item_id, true );
		}
		else if( animEventName == 'leave_item' )
		{
			//dispenser.GetInventory().MountItem( item_id );
			dispenser.CommunityChangeDispenserStatus( dispenser );
			npc.GetInventory().UnmountItem( this.item_id, true );
		}
	}	
}
	
// 4.

class CCommunityChangeExplorationModeUsingArea extends IActorLatentAction
{
	editable saved var CarriedItem : ELyingItems;
	editable saved var AreaTag : name;
	var dispenser_ent : CGameplayEntity;
	var dispenser : CCommunityCarriedItemPlacement;
	var npc : CNewNPC;
	var ent : CGameplayEntity;
	var area : CCommunityScriptedActionsArea;
	var item_id : SItemUniqueId;

	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		npc = ( CNewNPC )actor;
		ent = ( CGameplayEntity )theGame.GetEntityByTag( AreaTag );
		area = ( CCommunityScriptedActionsArea )ent;
		dispenser_ent = ( CGameplayEntity )theGame.GetEntityByTag( area.DispenserTag );
		dispenser = ( CCommunityCarriedItemPlacement )dispenser_ent;
		
		if( CarriedItem == LI_Lying_basket )
		{
			item_id = dispenser.GetInventory().GetItemId( 'Lying_basket' );
		}
		else if ( CarriedItem == LI_Lying_box_to_carry )
		{
			item_id = dispenser.GetInventory().GetItemId( 'Lying_box_to_carry' );
		}
		else if ( CarriedItem == LI_Idle_broom )
		{
			item_id = dispenser.GetInventory().GetItemId( 'Idle_broom' );
		}	
		else if ( CarriedItem == LI_Lying_bucket )
		{
			item_id = dispenser.GetInventory().GetItemId( 'Lying_bucket' );
		}	
		else if ( CarriedItem == LI_None )
		{
			Log( "No item specified - you should choose the same item as CarriedItem" );
		}
		area.CommunityChangeExState( npc, dispenser );
		dispenser.CommunityChangeDispenserStatus( dispenser );
	}	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// Event do animacji pracy synchronizujacy animacje podnoszenia/odkladania ze statusem itemu w dispenserze

	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventName == 'take_item' )
		{
			dispenser.GetInventory().UnmountItem( item_id, true );
		}
		else if( animEventName == 'leave_item' )
		{
			dispenser.GetInventory().MountItem( item_id );
		}
	}	
}
*/