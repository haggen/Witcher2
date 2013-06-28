/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui journal methods
/** Copyright © 2010
/***********************************************************************/

enum EJournalKnowledgeGroup
{
	JournalGroup_Places		= 0,
	JournalGroup_Characters	= 1,
	JournalGroup_Monsters	= 2,
	JournalGroup_Crafting   = 3,
	JournalGroup_Tutorial	= 4,
	JournalGroup_Alchemy	= 5,
	JournalGroup_Glossary	= 6,
	JournalGroup_Flashback	= 7
}

struct SJournalKnowledgeEntry
{
	editable var m_id		: string; // localize to get name
	editable var m_subIds	: array<string>; // { 1, 2, 3a, 4b, 5 } - localize m_id + "_" + m_subIds[i] to get description
	editable var m_textIds	: array<string>;
	editable var m_iconIds	: array<string>;
	editable var m_category	: string;
	editable var m_isRead	: bool;
	editable var m_imageUrl  : string;
}

struct SJournalKnowledgeGroup
{
	editable var m_entries : array< SJournalKnowledgeEntry >;
}

struct SJournalKnowledge
{
	editable var m_groups : array< SJournalKnowledgeGroup >; // indexed with EJournalKnowledgeGroup
}

import struct SJournalQuestEntry
{
	import var entryGuid	: CGUID;
	import var entryName	: String;
	import var toDoHint		: String;
	import var groupName	: String;
	import var isRead		: Bool;
	import var isTracked	: Bool;
	import var isMainQuest	: Bool;
	import var status		: int;
};

class CGuiJournal extends CGuiPanel
{
	private var AS_journal		: int;
	private var m_questEntries	: array< SJournalQuestEntry >;
	
	// Hide hud
	function GetPanelPath() : string { return "ui_journal.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		
		theHud.m_hud.setCSText( "", "" );
		//theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
	}
	
	event OnClosePanel()
	{
		theHud.ForgetObject( AS_journal );
	
		//theHud.EnableWorldRendering( true );
		//theGame.SetActivePause( false );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.HideJournal();
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mJournal", AS_journal ) )
		{
			Log( "No mJournal found at the Scaleform side!" );
		}

		FillJournal();
	}
	
	private final function GetEntryContent( itemIdxF : float ) : string
	{
		var groupIdx	: int = (int)itemIdxF / 10000;
		var itemIdx		: int = (int)itemIdxF - groupIdx * 10000; // why % works on byte only?
		var elem		: SJournalKnowledgeEntry;
		var i			: int;
		var description	: string;
		
		if ( groupIdx == 9 ) // quests
		{
			thePlayer.MarkQuestLogEntryRead( m_questEntries[ itemIdx ].entryGuid );
			if ( m_questEntries[ itemIdx ].entryName != "" ) description = "<b>" + StrUpperUTF( m_questEntries[ itemIdx ].entryName ) + "</b><br>";
			return description + thePlayer.GetQuestLogEntryDescription( m_questEntries[ itemIdx ].entryGuid );
		}
		
		if ( groupIdx == 4 ) // tutorial
		{
			elem = thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ];
			
			//description = "<font size='20'>" + StrUpperUTF( GetLocStringByKeyExt( thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ].m_id ) ) + "</font><br>";
			
			if ( ! elem.m_isRead )
			{
				elem.m_isRead = true; // useless as its copy only - apparently not! this actually works!
				//thePlayer.SetJournalEntryAsRead( groupIdx, itemIdx, true );
			
				// There is no posibility to change array element directly in script so hack it:
				//thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ] = elem;
				thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Erase( itemIdx );
				thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Insert( itemIdx, elem );
			}
			
			for ( i = 0; i < elem.m_subIds.Size(); i += 1 )
			{
				// Hack :(
				if( elem.m_category == "Podstawy" )
				{
					description += theHud.m_hud.ParseButtons( theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( /* elem.m_id + " " + */ elem.m_subIds[ i ]  ) ) ) + "<br/><br/>";
				}
				else
				{
					description += "<center><br><img src='" + elem.m_imageUrl + "'> </center><br><br>";
					description += theHud.m_hud.ParseButtons( theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( elem.m_subIds[ i ] ) ) );
					description += "<br/><br/>";
				}				
			}
			
			thePlayer.UpdateLinksInDescription( description );
			
			return description;		
		}
		else
		{
			elem = thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ];
			
			if ( ! elem.m_isRead )
			{
				//description = "<b>" + GetLocStringByKeyExt( thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ].m_id ) + "</b><br>";
				
				elem.m_isRead = true; // useless as its copy only - apparently not! this actually works!
				//thePlayer.SetJournalEntryAsRead( groupIdx, itemIdx, true );
			
				// There is no posibility to change array element directly in script so hack it:
				//thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ] = elem;
				thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Erase( itemIdx );
				thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Insert( itemIdx, elem );
			}
			
			for ( i = 0; i < elem.m_subIds.Size(); i += 1 )
			{
				description += theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( elem.m_subIds[ i ]  ) ) + "<br/><br/>";
			}
			
			thePlayer.UpdateLinksInDescription( description );
			
			
			if ( groupIdx == 3 ) description = ParseFotItemTagCrafting( description ); // Stworz dynamiczny opis tworzonego itemu w craftingu na podstawie taga [[nazwaitemu]]
			if ( groupIdx == 5 ) description = ParseFotItemTagAlchemy( description ); // Stworz dynamiczny opis tworzonego itemu w alchemii na podstawie taga [[nazwaitemu]]
			
			return description;
		}
		
		return "TODO: Quest entry content";
	}
	
	//new tutorial journal content processing
	private final function GetTutorialEntryContent( itemIdxF : float, arrayId : string, optional index : float ) : string
	{
		var groupIdx		: int = (int)itemIdxF / 10000;
		var itemIdx			: int = (int)itemIdxF - groupIdx * 10000; // why % works on byte only?
		var elem			: SJournalKnowledgeEntry;
		var description		: string;
		var arrayIdx		: array< string >;
		var i				: int = (int)index;
		
		Log( "=================INDEX From FLASH : " +itemIdxF +" =======================" );
		elem = thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ];
		
		//description = "<font size='20'>" + StrUpperUTF( GetLocStringByKeyExt( thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ].m_id ) ) + "</font><br>";
		
		if ( ! elem.m_isRead )
		{
			elem.m_isRead = true; // useless as its copy only - apparently not! this actually works!
			//thePlayer.SetJournalEntryAsRead( groupIdx, itemIdx, true );
		
			// There is no posibility to change array element directly in script so hack it:
			//thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries[ itemIdx ] = elem;
			thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Erase( itemIdx );
			thePlayer.m_knowledge.m_groups[ groupIdx ].m_entries.Insert( itemIdx, elem );
		}
		if( arrayId == "Txt" )
			description = elem.m_textIds[ i ];
		else if( arrayId == "Icon" )
			description = elem.m_iconIds[ i ];
		else if( arrayId == "Title" )
			description = elem.m_id;
		else if( arrayId == "Img" )	
			description = elem.m_imageUrl;

		//thePlayer.UpdateLinksInDescription( description );
		
		return description;		
	}

	
	private final function TrackQuest( itemIdxF : float )
	{
		var groupIdx	: int = (int)itemIdxF / 10000;
		var itemIdx		: int = (int)itemIdxF - groupIdx * 10000; // why % works on byte only?
		var zeroGuid	: CGUID;
		
		if ( groupIdx == 9 ) // quests
		{
			if ( thePlayer.GetTrackedQuest() == m_questEntries[ itemIdx ].entryGuid )
				thePlayer.SetTrackedQuest( zeroGuid );
			else
				thePlayer.SetTrackedQuest( m_questEntries[ itemIdx ].entryGuid );
		}
	}
	
	//////////////////////////////////////////////////////////////
	// Fill journal
	private function FillJournal()
	{
		FillQuestsGroup();
		FillKnowledgeGroup( JournalGroup_Places,		"Places" );
		FillKnowledgeGroup( JournalGroup_Characters,	"Characters" );
		FillKnowledgeGroup( JournalGroup_Monsters,		"Monsters" );
		FillKnowledgeGroup( JournalGroup_Crafting,		"Crafting" );
		FillKnowledgeGroup( JournalGroup_Tutorial,		"Tutorial" );
		FillKnowledgeGroup( JournalGroup_Alchemy,		"Alchemy" );
		FillKnowledgeGroup( JournalGroup_Glossary,		"Glossary" );
		FillKnowledgeGroup( JournalGroup_Flashback,		"Flashback" );

		theHud.Invoke( "Commit", AS_journal );
	}
	
	private function ParseFotItemTagCrafting( str : string ) : string
	{
		var itemTagBefore : string;
		var itemName : string;
		var abilitiesTip : string;
		var output : string;
		var abilities : array < name >;
		var ingredients : array < SItemIngredient >;
		var add, mult : float;
		var dmin, dmax : float;
		var i : int;
		var displayPercMul, displayPercAdd : bool;
		var itemId, craftId : SItemUniqueId;
		var inventory : CInventoryComponent = thePlayer.GetInventory();
		var charStats : CCharacterStats = thePlayer.GetCharacterStats();
		itemTagBefore = StrAfterFirst( str, "[[" );
		itemName = StrBeforeFirst( itemTagBefore, "]]" );
		
		// ===================
		// TWORZY DYNAMICZNIE WPIS O TWORZONYM PRZEDMIOCIE W OPISIE SCHEMATU RZEMIELNICZYM W JOURNALU
		
		itemId = inventory.AddItem( StringToName(itemName), 1, false );
		craftId = inventory.AddItem( StringToName("Schematic " + itemName), 1, false );
		theHud.Invoke("pHUD.clearRecievedList");
		theHud.Invoke("vHUD.stopCSText" );
		thePlayer.GetInventory().GetItemAttributes( thePlayer.GetInventory().GetItemId( StringToName(itemName) ), abilities );
		abilitiesTip = "" + GetLocStringByKeyExt("SchematicTooltipCreate") + "<br><br>";
		abilitiesTip = abilitiesTip + "<img width='60' height='60' src='img://globals/gui/icons/items/" + StrReplaceAll(itemName," ","") + "_64x64.dds'>";
		abilitiesTip = abilitiesTip + "<font color='#FF9900'>" + StrUpperUTF( GetLocStringByKeyExt( itemName ) ) + "<br><br><font color='#f4ffc1'>";
		charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, 'damage_min', dmin, mult, displayPercMul, displayPercAdd );
		charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, 'damage_max', dmax, mult, displayPercMul, displayPercAdd );
		if ( dmin != 0 && dmax != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( "damage" ) + ": " + RoundF( dmin ) + "-" +RoundF(dmax) +"<br>";
		
		for( i=0; i<abilities.Size(); i+=1 )
		{
			if ( abilities[i] == 'damage_min' || abilities[i] == 'damage_max' ) continue;
			
			charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, abilities[i], add,	mult, displayPercMul, displayPercAdd );
			
			if ( abilities[i] == 'tox_level' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + RoundF(add) + "<br>";
			}else
			if ( abilities[i] == 'durration' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + RoundF(add / 60) + "<br>";
			}else
			if ( abilities[i] == 'item_price' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/orens_15x15.dds' width='12' height='12'> " + RoundF( add )  + " ";
				if ( mult > 0 && mult != 1) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/orens_15x15.dds' width='12' height='12'> " + FloatToStringPrec( mult, 1 ) + " ";
			}
			else
			if ( abilities[i] == 'item_weight' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/waga_15x15.dds' width='12' height='12'> " + RoundF( add ) + " ";
				if ( mult > 0 && mult != 1) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/waga_15x15.dds' width='12' height='12'> " + FloatToStringPrec( mult, 1 ) + " ";
			}
			else
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + theHud.m_utils.ListAttributeBase( add, mult, displayPercMul, displayPercAdd ) + "<br>";
				if ( mult > 0 && mult != 1) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + theHud.m_utils.ListAttributeBase( add, mult, displayPercMul, displayPercAdd ) + "<br>";
			}
		}
		
		thePlayer.GetInventory().GetItemIngredients( thePlayer.GetInventory().GetItemId( StringToName("Schematic " + itemName) ), ingredients );
		abilitiesTip = abilitiesTip + "<br><br><font color='#FFFFFF'>" + GetLocStringByKeyExt("IngrTooltipCreate") + "<br><br>";
		for( i=0; i<ingredients.Size(); i+=1 )
		{
			abilitiesTip = abilitiesTip + "<img width='26' height='26' src='img://globals/gui/icons/items/" + StrReplaceAll(ingredients[i].itemName," ","") + "_64x64.dds'>";
			abilitiesTip = abilitiesTip + ingredients[i].quantity + "x " + GetLocStringByKeyExt( NameToString( ingredients[i].itemName ) ) + "<br>";
		}
		abilitiesTip = abilitiesTip + "<br><font color='#FFFFFF'>";
		output = StrReplaceAll( str, "[["+itemName+"]]", abilitiesTip );
		thePlayer.GetInventory().RemoveItem( craftId, 1 );
		thePlayer.GetInventory().RemoveItem( itemId , 1 );

		return output;
		
	}
	
	private function ParseFotItemTagAlchemy( str : string ) : string
	{
		var itemTagBefore : string;
		var itemName : string;
		var abilitiesTip : string;
		var output : string;
		var abilities : array < name >;
		var ingredients : array < SItemIngredient >;
		var add, mult : float;
		var dmin, dmax : float;
		var i : int;
		var displayPercMul, displayPercAdd : bool;
		var itemId, craftId : SItemUniqueId;
		var inventory : CInventoryComponent = thePlayer.GetInventory();
		var charStats : CCharacterStats = thePlayer.GetCharacterStats();
		itemTagBefore = StrAfterFirst( str, "[[" );
		itemName = StrBeforeFirst( itemTagBefore, "]]" );
		
		// ===================
		// TWORZY DYNAMICZNIE WPIS O TWORZONEJ MIKSTURZE W OPISIE RECEPTURY W JOURNALU
		
		itemId = inventory.AddItem( StringToName(itemName), 1, false );
		craftId= inventory.AddItem( StringToName("Recipe " + itemName), 1, false );
		theHud.Invoke("pHUD.clearRecievedList");
		theHud.Invoke("vHUD.stopCSText" );
		inventory.GetItemAttributes( itemId, abilities );
		abilitiesTip = "<br>";
		abilitiesTip = abilitiesTip + "<img width='60' height='60' src='img://globals/gui/icons/items/" + StrReplaceAll(itemName," ","") + "_64x64.dds'>";
		abilitiesTip = abilitiesTip + "<font color='#FF9900'>" + StrUpperUTF( GetLocStringByKeyExt( itemName ) ) + "<br><br><font color='#f4ffc1'>";
		charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, 'damage_min', dmin, mult, displayPercMul, displayPercAdd );
		charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, 'damage_max', dmax, mult, displayPercMul, displayPercAdd );
		
		if ( dmin != 0 && dmax != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( "damage" ) + ": " + RoundF( dmin ) + "-" +RoundF(dmax) +"<br>";
		
		for( i=0; i<abilities.Size(); i+=1 )
		{
			if ( abilities[i] == 'damage_min' || abilities[i] == 'damage_max' ) continue;
			
			charStats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, abilities[i], add,	mult, displayPercMul, displayPercAdd );
			
			if ( abilities[i] == 'tox_level' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + RoundF(add) + "<br>";
			}else
			if ( abilities[i] == 'durration' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + RoundF(add / 60) + "<br>";
			}else
			if ( abilities[i] == 'item_price' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/orens_15x15.dds' width='12' height='12'> " + RoundF( add ) + " ";
				if ( mult > 0 && mult != 1) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/orens_15x15.dds' width='12' height='12'> " + FloatToStringPrec( mult, 1 ) + " ";
			}
			else
			if ( abilities[i] == 'item_weight' ) 
			{
				if ( add != 0 ) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/waga_15x15.dds' width='12' height='12'> " + RoundF( add ) + " ";
				if ( mult > 0 && mult != 1) abilitiesTip = abilitiesTip + "<img src='img://globals/gui/icons/tooltip/waga_15x15.dds' width='12' height='12'> " + FloatToStringPrec( mult, 1  ) + " ";
			}
			else
			{		
				if ( add != 0 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + theHud.m_utils.ListAttributeBase( add, mult, displayPercMul, displayPercAdd ) + "<br>";
				if ( mult > 0 && mult != 1 ) abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( abilities[i] ) ) + ": " + theHud.m_utils.ListAttributeBase( add, mult, displayPercMul, displayPercAdd ) + "<br>";
			}
		}
		
		inventory.GetItemIngredients( inventory.GetItemId( StringToName("Recipe " + itemName) ), ingredients );
		abilitiesTip = abilitiesTip + "<br><br><font color='#FFFFFF'>" + GetLocStringByKeyExt("AlchIngrTooltipCreate") + "<br><br>";
		for( i=0; i<ingredients.Size(); i+=1 )
		{
			abilitiesTip = abilitiesTip + "<img width='14' height='14' src='img://globals/gui/icons/items/" + StrReplaceAll(ingredients[i].itemName," ","") + "_64x64.dds'>";
			abilitiesTip = abilitiesTip + GetLocStringByKeyExt( NameToString( ingredients[i].itemName ) ) + "<br>";
		}
		inventory.RemoveItem( craftId, 1 );
		inventory.RemoveItem( itemId , 1 );
		abilitiesTip = abilitiesTip + "<br><font color='#FFFFFF'>";
		output = StrReplaceAll( str, "[["+itemName+"]]", abilitiesTip );
		
		return output;
	}
	
	
	private function FillKnowledgeGroup( groupType : EJournalKnowledgeGroup, groupName : string )
	{
		var AS_entries	: int;
		var AS_entry	: int;
		var group		: SJournalKnowledgeGroup;
		var item		: SJournalKnowledgeEntry;
		var imgW, imgH  : int; // image dimensions
		var	description	: string;
		
		var i, j, size	: int;
		
		if ( ! theHud.GetObject( groupName, AS_entries, AS_journal ) )
		{
			return;
		}
		theHud.ClearElements( AS_entries );
		
		// Check if entry is empty
		if ( groupType < thePlayer.m_knowledge.m_groups.Size() )
		{
			group = thePlayer.m_knowledge.m_groups[ groupType ];
			size = group.m_entries.Size();
			for ( i = 0; i < size; i += 1 )
			{
				item = group.m_entries[i];
				
				
				
				// demo hack
				if ( JournalGroup_Alchemy == groupType && item.m_id == "Journal None" )
				{
					continue;
				}
		
		
		
		
				// mcinek HACK to not-display pad tutorials on keyboard playthroughs and vice-versa
				if( groupType == JournalGroup_Tutorial )
				{
					description = "";
					
					// Get item description
					for( j = 0; j < item.m_subIds.Size(); j += 1 )
					{
						description += theHud.m_hud.ParseButtons( theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( item.m_subIds[ j ] ) ) );
					}
					
					// Check if description contains any non-parsed buttons
					if( StrFindFirst( description, "[[" ) != -1 )
					{
						Log( "Skipping TUTORIAL item: " + item.m_id + " because contains not mapped button" );
					
						// Just skip this item
						continue;
					}
				}
			
				AS_entry = theHud.CreateAnonymousObject();
				
				theHud.SetFloat	( "ID",				groupType * 10000 + i,				AS_entry );
				theHud.SetString( "Name",			GetLocStringByKeyExt( item.m_id ),	AS_entry );
				theHud.SetBool	( "Seen",			item.m_isRead,						AS_entry );
				
				// Image
				if ( item.m_category != "[[locale.jou.TUTORIAL]]" && item.m_imageUrl != "img://globals/gui/icons/journal/.dds" &&  item.m_imageUrl != "img://globals/gui/icons/.dds"  && item.m_imageUrl != "" )
				{
					//theHud.SetString( "Picture", "img://globals/gui/icons/places/amphitheatre_512x256.dds", AS_entry);
					theHud.SetString( "Picture", item.m_imageUrl, AS_entry);
					if ( !theHud.m_utils.GetImageSizeFromFileName( item.m_imageUrl, imgW, imgH ) )
					{
						imgW = imgH = 0;
					}
				}
				theHud.SetFloat( "PictureSizeX", imgW, AS_entry );
				theHud.SetFloat( "PictureSizeY", imgH, AS_entry );
			
				if ( item.m_category == "" )
					theHud.SetString( "Chapter",	GetLocStringByKeyExt( "Other" ),	AS_entry );
				else
					theHud.SetString( "Chapter",	GetLocStringByKeyExt( item.m_category ), AS_entry );

				theHud.PushObject( AS_entries, AS_entry );
				theHud.ForgetObject( AS_entry );
			}
		}
		
		theHud.ForgetObject( AS_entries );
	}
	
	private function FillQuestsGroup()
	{
		var AS_entries			: int;
		var AS_entry			: int;
		var item, chapter		: SJournalQuestEntry;		
		var i, x, size, count 	: int;
		
		if ( ! theHud.GetObject( "Quests", AS_entries, AS_journal ) )
		{
			return;
		}
		theHud.ClearElements( AS_entries );
		
		m_questEntries.Clear();
		thePlayer.GetQuestLogEntries( m_questEntries );

		count = m_questEntries.Size();
		
		if( !theGame.tutorialenabled )
		{
			for( x = count-1; x >= 0; x -= 1 )
			{
				chapter = m_questEntries[x];
				
				if( chapter.groupName == "Tutorial" )
				m_questEntries.Erase(x);
			}
		}	
	
		
		size = m_questEntries.Size();
		for ( i = 0; i < size; i += 1 )
		{
			item = m_questEntries[i];
			
			AS_entry = theHud.CreateAnonymousObject();
			
			theHud.SetFloat	( "ID",			90000 + i,			AS_entry );
			theHud.SetString( "Name",		item.entryName,		AS_entry );
			theHud.SetString( "Chapter",	item.groupName,		AS_entry );
			theHud.SetString( "ToDo",		item.toDoHint,		AS_entry );
			theHud.SetBool	( "Seen",		item.isRead,		AS_entry );
			theHud.SetString( "IsMain",		item.isMainQuest,	AS_entry );
			//theHud.SetString( "Picture", "img://globals/gui/icons/places/amphitheatre_512x256.dds", AS_entry);
			//theHud.SetFloat( "PictureSizeX", 512, AS_entry);
			//theHud.SetFloat( "PictureSizeY", 256, AS_entry);
			theHud.SetFloat( "PictureSizeX", 0,					AS_entry);
			theHud.SetFloat( "PictureSizeY", 0,					AS_entry);

			// "S"uccess, "F"ailure, "T"racked, ""
			if ( item.isTracked )
				theHud.SetString( "State",		"T",			AS_entry );
			else
			if ( item.status == 1 )
				theHud.SetString( "State",		"S",			AS_entry );
			else
			if ( item.status == 2 )
				theHud.SetString( "State",		"F",			AS_entry );
			else
				theHud.SetString( "State",		"",				AS_entry );
			
			theHud.PushObject( AS_entries, AS_entry );
			theHud.ForgetObject( AS_entry );
		}
		
		theHud.ForgetObject( AS_entries );
	}
}
