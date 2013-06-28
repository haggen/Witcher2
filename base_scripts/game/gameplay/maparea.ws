struct SJournalEntry
{
	editable var entryType : EJournalKnowledgeGroup;
	editable var entryId : string;
	editable var entrySubId : string;
	editable var entryCategory : name;
}

class CMapArea extends CGameplayEntity
{
	editable var showAreaName : bool;
	editable var areaNameId : string;
	editable var loadNewMap : bool;
	editable var mapId : int;
	editable var mapAreaFowId : int;
	editable var loadDefaultActMapOnExit : bool;
	inlined editable var journalEntry : SJournalEntry;
	editable var journalEntryImg : string;
	saved var wasVisited : bool;
	
	default showAreaName = true;
	default loadDefaultActMapOnExit = true;
	default wasVisited = false;
	default mapAreaFowId = 0;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			wasVisited = true;
			if ( thePlayer.GetCurrentAreaMapId() != areaNameId ) 
			{
				if ( showAreaName && thePlayer.GetCurrentStateName() == 'Exploration' ) 
				{
					theHud.m_hud.setCSText( GetLocStringByKeyExt( areaNameId ), "" );
					thePlayer.AddTimer( 'clearHudTextField', 2.0f, false );
				}
				//theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( areaNameId ) );
				//theHud.m_hud.SetTextField( 0, GetLocStringByKeyExt( areaNameId ), 50, 500 );
				
				thePlayer.SetCurrentAreaMapId( areaNameId, showAreaName );
			}
			if ( loadNewMap ) theHud.MapLoad( mapId );
			if ( journalEntry.entryId != "" ) thePlayer.AddJournalEntry( journalEntry.entryType, journalEntry.entryId, journalEntry.entrySubId, journalEntry.entryCategory, journalEntryImg );
			thePlayer.SetCurrentMapId( mapId );
		}
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			// Load default map only if currently loaded map is the map from this trigger
			if ( loadDefaultActMapOnExit && theHud.GetLoadedMapId() == mapId )
			{
				thePlayer.SetCurrentMapId( theHud.m_mapCommon.GetMapId() );
				theHud.m_map.LoadMapFromEntity();
			}
		}
	}
	
}
