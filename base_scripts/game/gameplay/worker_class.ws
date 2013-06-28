// enum kategorii obiektow przenoszonych

enum EPortableItems
{
	LI_None,
	LI_Basket,
	LI_Box,
	LI_Broom,
	LI_Bucket,
	LI_Pickaxe
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// klasa obslugujaca ponoszone itemy

class W2Worker extends CNewNPC 				
{
	saved var my_tags 				: array< name >;
	saved var my_tool				: W2ItemHolder;
	saved var tool_name				: name;
	saved var last_tool_name		: name;
	saved var got_tool				: bool;
	saved var itemId				: SItemUniqueId;
	saved var curr_ap				: int;
	saved var curr_cat				: name;
	saved var last_work				: string;
	saved var change_tool			: bool;
	
	default last_tool_name = 'None';
	default got_tool = false;
	default change_tool = false;
	default last_work = "none";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		my_tags = GetTags();
		AddTimer( 'WhatIsToDo', 1.0f, true, false );
		AddTimer( 'CheckMyCurrentAP', 1.0f, true, false ); 
	}

	timer function WhatIsToDo( timeDelta : float ) : void 			// funkcja cyklicznie sprawdzajaca stan workera i dzialajaca w zaleznosci od stanu
	{
		if( !IsWorkingNow() )
		{
			if( change_tool )
			{
				if( WhatIsMyItem() != 'None' )		// mam uzywac przedmiotu
				{
					if( got_tool == false )			//jeszcze nie mam niczego w lapach
					{
						SetWorkerLastWork();
						this.my_tool = FindFreeToolHolder();  //gdzie znajde wlasciwy item
						this.change_tool = false;
						GetArbitrator().AddGoalGetWorkItem( true );  //ide  po przedmiot
						Log( "WhatIsToDo() - starting Goal = Go Pick Item"  );
					}
				} 
				else
				{
					if( got_tool == true )
					{
						GetArbitrator().AddGoalGetWorkItem( false );
						Log( "WhatIsToDo() - starting Goal = Go Put Item" );
					}	
				}
			}
		}
	}
	
	private function IsWorkItemEquipped()	:	bool
	{
		var item : name;
		
		item = this.tool_name;
				
		if( this.GetInventory().IsItemHeld( this.GetInventory().GetItemId( item ) ) )
		{
			this.got_tool = true;
			return true;
		}	
	}
	
	private function WhatIsMyItem() : name 			// zwraca nazwe itemu, jaki uzywany jest w aktualnie wylosowanej pracy - decyduje czy wziasc, czy odlozyc item
	{
		var work 			: string;
		var item			: name;
		
		work = GetWorkerCurrentWork();
	
		// pracuje z miotla
		if( StrFindFirst( work, "sweep" ) >= 0 )
		{	
			item = 'Broom';
		}
		else
		{
			item = 'None';
		}
		
		// zwracam nazwe szukanego itemu
		this.tool_name = item;
		Log( "WhatIsMyItem() - My item name is : " +item );
		return item;
	}

	private timer function CheckMyCurrentAP( timeDelta : float )
	{
		var active_work : string;
				
		active_work = GetWorkerCurrentWork();
		
		if( active_work == GetWorkerLastWork() )
		{
			this.change_tool = false; 
		}
		else
		{
			this.change_tool = true;
		}
		Log( "Last Work = " +this.last_work );
		Log( "Current Work = " +active_work );
		
	}

	private function GetCurrentAP()					//ustawia id i kategorie aktualnie wylosowanego actionpointa
	{
		this.curr_ap = GetActiveActionPoint();
		this.curr_cat = GetCurrentActionCategory();
	}
	
	private function SetCurrentAP()					//ustawia NPCwoi actionpoint na podstawie danych z ostatnio uzywanego AP (wraca do tego samego AP, co przed wzieciem itemu)
	{
		SetActiveActionPoint( this.curr_ap, this.curr_cat );
	}
	
	private function GetWorkerCurrentWork() : string		//zwraca string nazwy CActionpointComponent w aktualnie wykorzystywanym AP
	{
		var apID 					: int;
		var apMan 					: CActionPointManager = theGame.GetAPManager();
		var apString 				: string;
		var searchedStr				: string;
		
		apID = GetActiveActionPoint();
		apString = apMan.GetFriendlyAPName( apID );
		searchedStr = StrAfterLast( apString, "::" ); 
		Log( "GetWorkerCurrentWork() - searchedStr = " +searchedStr );
		
		return searchedStr;
	}
	
	private function SetWorkerLastWork()				//ustawia wartosc stringa na podstawie stringu obecnie uzywanego AP Componentu
	{
		this.last_work = GetWorkerCurrentWork();	
	}
	
	private function GetWorkerLastWork() : string		//zwraca string nazwy ostatnio uzywanego AP Componentu
	{
		return this.last_work;
	}
	
	private function IsWorkingNow() : bool 				//sprawdza, czy aktualnie wykonuje jakakolwiek prace
	{
		if( IsCurrentlyWorkingInAP() )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	private function FindFreeToolHolder() : W2ItemHolder 					//szuka itemHoldera, ktory jest mu przypisany
	{
		var i, count 				: int;
		var x, size 				: int;
		var holders 				: array<CNode>;
		var disp 					: W2ItemHolder;
		var worker_tag 				: name;
		 
		theGame.GetNodesByTag( 'item_holder', holders );
		count = holders.Size();
		size = my_tags.Size();
		
		for( i = 0; count > i; i += 1 )
		{
			disp = (W2ItemHolder)holders[i];
			worker_tag = disp.WorkerTag;
			size = my_tags.Size();
			
			for( x = 0; size > x; x += 1 )
			{
				if( my_tags[x] == worker_tag )
				{
					if( disp.NotUsed() )
					{
						//Log( "FindFreeToolHolder() - free holder is : " +disp );
						return disp;
					}	
				}	
			}
		}
	}
}	
	
state HandlingTools in W2Worker extends Base
{
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false;
	}

	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType ) // Event synchronizujacy animacje podnoszenia/odkladania
	{
		var tool 			: W2ItemHolder;
		var valid_id		: bool;
		var item_name		: name;
		
		if( animEventName == 'pick_item' )
		{
			tool = parent.my_tool;
			parent.itemId = parent.GetInventory().AddItem( parent.tool_name, 1, false );
			parent.GetInventory().MountItem( parent.itemId, true );
			tool.UpdateItemStatus( true );												// aktualizuje status itemHoldera
			parent.got_tool = true;
		}
		else if( animEventName == 'put_item' )
		{
			tool = parent.my_tool;
			parent.GetInventory().UnmountItem( parent.itemId, true );
			tool.UpdateItemStatus( false );												// aktualizuje status itemHoldera			
			parent.got_tool = false;
		}
	}	

	event OnEnterState()
	{
		//parent.IssueRequiredItems( 'None', parent.tool_name );
		parent.RemoveTimer( 'WhatIsToDo'); 
		parent.RemoveTimer( 'CheckMyCurrentAP' );
	}
	
	event OnLeaveState()
	{
		parent.DetachBehavior( 'npc_handling_tools' );
		parent.AddTimer( 'WhatIsToDo', 1.0f, true, false ); 
		parent.AddTimer( 'CheckMyCurrentAP', 1.0f, true, false );
	}
	
	entry function PickUpTool( goalId : int ) : void
	{
		var tool 			: W2ItemHolder;
		var waypoint		: CNode;
		var item_enum		: EPortableItems;
		
		// set goal id first
		SetGoalId( goalId );
		
		tool = parent.my_tool;
		waypoint = tool.GetPickUpPoint();
		item_enum = tool.HeldItemType;
		parent.ActionRotateToAsync( tool.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( waypoint, MT_Walk, 1, 0.1f );
		Sleep( 0.5f );
		parent.AttachBehavior( 'npc_handling_tools' );
		parent.SetBehaviorVariable( "enumItems", ToFloat( item_enum ) );
		parent.RaiseEvent( 'PickUp' ); 											// odpalenie eventu animacji odpalania pochodni
		parent.WaitForBehaviorNodeDeactivation( 'PickUpFinished' );				// czekanie az event sie skonczy
		MarkGoalFinished();
	}
	
	entry function PutDownTool( goalId : int ) : void
	{
		var tool 			: W2ItemHolder;
		var waypoint		: CNode;
		var item_enum		: EPortableItems;
		
		// set goal id first
		SetGoalId( goalId );		
		
		tool = parent.my_tool;
		waypoint = tool.GetPickUpPoint();
		item_enum = tool.HeldItemType;
		parent.ActionRotateToAsync( tool.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( waypoint, MT_Walk, 1, 0.1f );
		Sleep( 0.5f );
		parent.AttachBehavior( 'npc_handling_tools' );
		parent.SetBehaviorVariable( "enumItems", ToFloat( item_enum ) );
		parent.RaiseEvent( 'PutDown' ); 										// odpalenie eventu animacji odpalania pochodni
		parent.WaitForBehaviorNodeDeactivation( 'PutDownFinished' ); 			// czekanie az event sie skonczy
		MarkGoalFinished();
	}
	
	private function ToFloat( val : EPortableItems ) : float 					// zamienia wartosc enuma na float
	{
		return (float)(int)val;
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//klasa obiektow podnoszonych i przenoszonych na lokacji

class W2ItemHolder extends CGameplayEntity
{

	saved editable var HeldItemType 	: EPortableItems;
	saved private var ItemHeld 			: SItemUniqueId;
	saved editable var ItemIsMounted 	: bool;
	editable var WorkerTag 				: name;
	private var m_goToNode				: CNode;
	saved private var is_mounted			: bool;
	private var is_valid				: bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);

		if ( ItemIsMounted == true )
		{
			if( HeldItemType == LI_Basket )
			{
				ItemHeld = GetInventory().GetItemId( 'Lying_basket' );
				GetInventory().MountItem( ItemHeld );
			}
			else if ( HeldItemType == LI_Box )
			{
				ItemHeld = GetInventory().GetItemId( 'Lying_box_to_carry' );
				GetInventory().MountItem( ItemHeld );
			}
			else if ( HeldItemType == LI_Broom )
			{
				ItemHeld = GetInventory().GetItemId( 'Idle_broom' );
				GetInventory().MountItem( ItemHeld );
			}
			else if ( HeldItemType == LI_Bucket )
			{
				ItemHeld = GetInventory().GetItemId( 'Lying_bucket' );
				GetInventory().MountItem( ItemHeld );
			}
			else if ( HeldItemType == LI_Pickaxe )
			{
				ItemHeld = GetInventory().GetItemId( 'Idle_pickaxe' );
				GetInventory().MountItem( ItemHeld );
			}
		}
		else
		{
			Log( "Item on " +this +"is not set. Fix it." );
		}
		IsLinkedToWorker();
		m_goToNode = SetPickUpPoint();
		is_mounted = GetInventory().IsItemMounted( ItemHeld );
		is_valid = GetInventory().IsIdValid( ItemHeld );
		Log("ItemHolder - OnSpawned() - Is item mounted = " +is_mounted );
		Log("ItemHolder - OnSpawned() - Is item id valid = " +is_valid );
	}
	
	private function NotUsed() : bool // sprawdza, czy mountowany item jest pobrany do pracy, jesli tak, mam byc omijany przez innych npc
	{
		if( HeldItemType != LI_None )
		{ 
			if( ItemIsMounted )
			{ 
				return true;
			}
			else
			{
				return false;
			}	
		}	
		else 
		{ 
			return false;
		}
	}
	
	private function IsLinkedToWorker() : bool // funkcja sprawdza, czy podany jest tag workera
	{
		if( WorkerTag == '' || WorkerTag == 'None' )
		{
			Log( "ItemHolder " +this +" not used! Fix it or remove " +this +" from level!" );
			return false;
		}
		else 
		{
			return true;
		}
	}
	private function SetPickUpPoint() : CNode
	{
		var comps : array< CComponent >;
		var i, count : int;
		var nodeName : string;
		
		comps = GetComponentsByClassName('CWayPointComponent');
		count = comps.Size();
		for ( i = 0; i < count; i += 1 )
		{
			nodeName = comps[i].GetName();
			if ( nodeName == "pickup_point" )
			{
				return comps[i];
			}
		}
		return (CNode)NULL;
	}
	
	private function GetPickUpPoint() : CNode
	{
		return m_goToNode;
	}
	
	private function UpdateItemStatus( picked_up : bool ) : void // Funkcja zmieniajaca status dispensera w zaleznosci od tego, czy item jest zamontowany czy nie
	{
		var item_name		: name;
		
		if ( ItemIsMounted == false )
		{
			if( !picked_up )
			{
				if( HeldItemType == LI_Basket )
				{
					GetInventory().MountItem( ItemHeld );
					ItemIsMounted = true;
				}
				else if ( HeldItemType == LI_Box )
				{
					GetInventory().MountItem( ItemHeld );
					ItemIsMounted = true;
				}
				else if ( HeldItemType == LI_Broom )
				{
					GetInventory().MountItem( ItemHeld );
					ItemIsMounted = true;
				}
				else if ( HeldItemType == LI_Bucket )
				{
					GetInventory().MountItem( ItemHeld );
					ItemIsMounted = true;
				}
				else if ( HeldItemType == LI_Pickaxe )
				{
					GetInventory().MountItem( ItemHeld );
					ItemIsMounted = true;
				}
				else if ( HeldItemType == LI_None )
				{
					Log( "Place " +this +" should not display any items" );
					ItemIsMounted = false;
				}
				item_name = GetInventory().GetItemName( ItemHeld );
				Log( "ItemHolder - UpdateItemStatus() - showing item : " +item_name );
			}
		}	
		else if( ItemIsMounted == true )
		{
			if( picked_up )
			{
				if( HeldItemType == LI_Basket )
				{
					this.GetInventory().UnmountItem( ItemHeld );
					this.ItemIsMounted = false;
				}
				else if ( HeldItemType == LI_Broom )
				{
					this.GetInventory().UnmountItem( ItemHeld, true );
					this.ItemIsMounted = false;
				}
				else if ( HeldItemType == LI_Broom )
				{
					GetInventory().UnmountItem( ItemHeld, true );
					ItemIsMounted = false;
				}
				else if ( HeldItemType == LI_Bucket )
				{
					GetInventory().UnmountItem( ItemHeld );
					ItemIsMounted = false;
				}
				else if ( HeldItemType == LI_Pickaxe )
				{
					GetInventory().UnmountItem( ItemHeld );
					ItemIsMounted = false;
				}		
				else if ( HeldItemType == LI_None )
				{
					Log( "Place " +this +" should not display any items" );
					ItemIsMounted = false;
				}
				item_name = GetInventory().GetItemName( ItemHeld );
				Log( "ItemHolder - UpdateItemStatus() - hiding item : " +item_name );
			}
		}
		is_mounted = GetInventory().IsItemMounted( ItemHeld );
		Log("Is item mounted = " +is_mounted );
	}
}
