/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Info board with potential quests
/** Copyright © 2010
/***********************************************************************/

class CQuestBoard extends CGameplayEntity
{
	editable var isTrollNoteHere : bool;
	editable var isHairdresserNoteHere : bool;
	editable var hairdresserNoteToAdd : name;
	editable var hairdresserNoteToRemove : name;

	function IsLootable() : bool
	{
		var allItems		: array< SItemUniqueId >;
		var i 				: int;
		var isAnything 		: bool;

		GetInventory().GetAllItems( allItems );
		isAnything = false;
		
		for ( i=0; i<allItems.Size(); i+=1 )
		{
				isAnything = true;
		}
		
		return isAnything;
	}
	
	function SetProperApearance()
	{
		if ( IsLootable() )
		{
			ApplyAppearance( "full" );
		}
		else
		{
			ApplyAppearance( "empty" );
		}
	}
	
	event OnGameStarted()
	{
		SetProperApearance();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		SetProperApearance();
	}	
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		theHud.m_hud.ShowTutorial("tut33", "tut33_333x166", false);
		//theHud.ShowTutorialPanelOld( "tut33", "tut33_333x166" );
		if ( isTrollNoteHere )
		{
		if ( FactsDoesExist( "Troll_fact" ) )
		{
			if ( !FactsDoesExist( "Troll_Contract_Added" ) )
			{
				this.GetInventory().AddItem('Troll contract', 1, false);
				FactsAdd("Troll_Contract_Added", 1);
			}
		}
		else
		{
			if ( !FactsDoesExist( "Fake_Troll_Contract_Added" ) )
			{
				this.GetInventory().AddItem('NoTrollQuest', 1, false);
				FactsAdd("Fake_Troll_Contract_Added", 1);
			}
		}
		}
/*	
		//if ( FactsDoesExist( "Hairdresser_fact" ) )
		//{
			if ( !GetInventory().HasItem( hairdresserNoteToAdd ) )
			{
				if ( hairdresserNoteToRemove != '' )
				{
					GetInventory().RemoveItem( GetInventory().GetItemId( hairdresserNoteToRemove ) );
				}
				GetInventory().AddItem( hairdresserNoteToAdd, 1, false);
				//FactsAdd( "Hairdresser_Note_Added", 1 );
			}
		//}
*/

 			if ( !FactsDoesExist( "Added_" + NameToString( hairdresserNoteToAdd ) ) )
			{
				if ( hairdresserNoteToRemove != '' )
				{
					GetInventory().RemoveItem( GetInventory().GetItemId( hairdresserNoteToRemove ) );
				}
				GetInventory().AddItem( hairdresserNoteToAdd, 1, false );
				FactsAdd( "Added_" + NameToString( hairdresserNoteToAdd ), 1 );
			}
		}
		
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		var args 			: array< string >;  		// messsages
		var ids 			: array< SItemUniqueId >;   // messages ids
		var items 			: array< SItemUniqueId >;
		var isAnyQuest 		: bool;
		var strDesc			: string;
		var id 				: SItemUniqueId;
		var i 				: int;
		
		if ( actionName == 'Use' )
		{
			GetInventory().GetAllItems( items );
			isAnyQuest = false;
			for ( i=0; i < 5; i+=1 )
			{
				if ( items[i] != GetInvalidUniqueId() )
				{
					strDesc = GetLocStringByKeyExt( NameToString ( GetInventory().GetItemName( items[i] ) ) + "_quest" );
					id = items[i];
					isAnyQuest = true;
					
					args.PushBack( strDesc );
					ids.PushBack( id );
				}
			}
			
			if ( isAnyQuest )
			{
				thePlayer.SetLastBoard( this );
				GetComponent ("Look at board").SetEnabled( false );
				//theHud.EnableInput( true, false, true ); // mouse, keyboard, cursor

				theHud.ShowBoard( args, ids, this );
				GetComponent ("Look at board").SetEnabled( true);
			}
			else
			{
				theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "No quests on board" ) + "." );
			}
		}
		
		//SetProperApearance();
	}
}
