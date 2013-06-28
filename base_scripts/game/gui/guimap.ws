/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui map panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

enum EMapPinDisplayMode
{
	MapPinDisplay_Both,
	MapPinDisplay_MiniMap,
	MapPinDisplay_Map
}

/*
enum EMapPinType
{
	// Dynamic (visible on minimap)
	MapPinType_NpcNeutral,
	MapPinType_NpcHostile,
	MapPinType_NpcFriendly,
	
	// Dynamic quest (visible on minimap and map)
	MapPinType_Quest,
	
	// Static (visible on minimap and map)
	MapPinType_Inn,
	MapPinType_Shop,
	MapPinType_Craft
}
*/

class CMapPin
{
	editable var Enabled		: bool;
	editable var Name			: string;
	editable var Description	: string;	
	editable var Type			: EMapPinType;
	editable var DisplayMode	: EMapPinDisplayMode;
	
	// interaction mappin type
	public function IsMappinTypeNPC() : bool
	{
		return Type == MapPinType_NpcNeutral || Type == MapPinType_NpcHostile || Type == MapPinType_NpcFriendly;
	}

	default Enabled = true;
}

class CMapEntity extends CEntity
{
	private editable var MapId_Act : int;
	default MapId_Act = 0;
	
	function GetMapId() : int
	{
		return MapId_Act;
	}
}

class CGuiMapCommon
{
	public final function GetMapId() : int
	{
		var mapEntity : CMapEntity;
		mapEntity = (CMapEntity) theGame.GetEntityByTag( 'mapprop' );
		
		if ( mapEntity )
		{
			return mapEntity.GetMapId();
		}
		else
		{
			Log("WARNING: Map and minimap cant be loaded! Place on map or load layer mapproperty! Loading default map.");
			return 0;
		}
	}
}

class CGuiMap
{
	final function LoadMapFromEntity()
	{
		theHud.MapLoad( theHud.m_mapCommon.GetMapId() );
	}

	public var mapPins : array< CMapPin >;

	// Update mappin for given object
	// entity - tracked entity
	// mapPin - mapPin definition or NULL to hide
	final function MapPinSet( entity : CEntity, mapPin : CMapPin )
	{
		var i : int;		
		var static	: bool;
		var type	: string;
		
		// add map pin
		if ( mapPin )
		{	
			static = mapPin.Type == MapPinType_Inn || mapPin.Type == MapPinType_Shop || mapPin.Type == MapPinType_Craft;
			
			if ( mapPin.Type == MapPinType_Inn )
				type = "INN";
			else if ( mapPin.Type == MapPinType_Shop )
				type = "SHOP";
			else if ( mapPin.Type == MapPinType_Craft )
				type = "CRAFT";
			else if ( mapPin.Type == MapPinType_NpcNeutral )
				type = "NEUTRAL";
			else if ( mapPin.Type == MapPinType_NpcHostile )
				type = "HOSTILE";
			else if ( mapPin.Type == MapPinType_NpcFriendly )
				type = "FRIENDLY";
			else if ( mapPin.Type == MapPinType_Quest )
				type = "QUEST";

			// Update map pin if map pin entity already exists
			for ( i = mapPins.Size()-1; i >= 0; i -= 1 )
			{
				if ( mapPins[ i ].GetParent() == entity )
				{
					mapPins[ i ] = mapPin;
	
					if ( mapPin.DisplayMode == MapPinDisplay_MiniMap || mapPin.DisplayMode == MapPinDisplay_Both )
					{
						theHud.MapPinShow( entity, type, static );
					}
					return;
				}
			}
	
			// Remember map pin
			mapPins.PushBack( mapPin );

			if ( mapPin.DisplayMode == MapPinDisplay_MiniMap || mapPin.DisplayMode == MapPinDisplay_Both )
			{
				theHud.MapPinShow( entity, type, static );
			}
		}
		// remove map pin
		else
		{
			for ( i = mapPins.Size()-1; i >= 0; i -= 1 )
			{
				if ( mapPins[ i ].GetParent() == entity )
				{
					mapPins.Erase( i );
					theHud.MapPinHide( entity );
					return;
				}
			}
		}
	}
	
	public function ClearNullPins()
	{
		var i : int;
		for ( i = mapPins.Size()-1; i >= 0; i -= 1 )
		{
			if ( !mapPins[ i ].GetParent() )
			{
				mapPins.Erase( i );
			}
		}
	}
	
	public function CreateMapPin( entity : CEntity, description : string, type : EMapPinType, displayMode : EMapPinDisplayMode ) : CMapPin
	{
		var mapPin : CMapPin;
		
		mapPin = new CMapPin in entity;
		mapPin.Enabled = true;
		mapPin.Name = entity.GetName();
		mapPin.Description = description;
		mapPin.Type = type;
		mapPin.DisplayMode = displayMode;
		
		return mapPin;
	}
}


class CGuiMapBig extends CGuiPanel
{
	private var AS_map : int;
	
	var m_hasDoors     : bool;
	var m_doorWorldPos : Vector;
	var m_questName    : string;
	var m_questTodo    : string;

	// Hide hud
	function GetPanelPath() : string { return "ui_nav.swf"; }
	
	event OnOpenPanel()
	{
		thePlayer.setHudFadeoutTimerBlocked( true );
		theHud.SetHudVisibility("false" );
		super.OnOpenPanel();
		
		theSound.SilenceMusic();
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );

		theHud.m_hud.setCSText( "", "" );
		//theGame.SetActivePause( true );
		
		theHud.m_hud.HideTutorial();
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mNav", AS_map ) )
		{
			LogChannel( 'GUI', "CGuiMap: No mNav found at the Scaleform side!" );
		}
		
		//FillMap();
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		thePlayer.setHudFadeoutTimerBlocked( false );
		theHud.SetHudVisibility( "false" );
		
		theSound.RestoreAllSounds();
		theSound.RestoreMusic();
		
		super.OnClosePanel();
		//theHud.HideSleep();
	}
	
	private function FillMap()
	{
		var worldMapFile : string; // only one map for the whole game
		var mapFile      : string; // bigger version of minimap file
		var miniMapFile  : string; // minimap file - not used here
		var AS_playerPos, AS_loPins, AS_loFogOfWar, AS_hiFogOfWar, AS_pin : int;
		var playerPos    : Vector       = thePlayer.GetWorldPosition();
		var playerMapPosX, playerMapPosY : float;
		var playerWorldMapPosX, playerWorldMapPosY : float;
		var pinPosX, pinPosY, pinKind : int;
		var i              : int;
		var pinEntity      : CEntity;
		var pinWorldPos    : Vector;
		var gridSize       : int;
		var fowInfo        : array<int>;
		var navMapPins     : array< Vector >;
		var navMapPinsKind : array< int >;
		var navMapDescs    : array< string >;
		var flipX, flipY   : bool;
		var playerRotShift : float;
		var currentMapPinTags : array< name >;
		var navMapPinsTag	: array< name >;
		var questTag : name;
		
		theGame.GetQuestLogManager().GetTrackedQuestInfo( m_questName, m_questTodo, questTag );
		
		theHud.GetMapInfo( thePlayer.GetCurrentMapId(), theHud.m_mapCommon.GetMapId(), mapFile, miniMapFile, flipX, flipY );
		
		// Global map for the whole game
		worldMapFile = "img://globals/gui/maps/worldmap_2048x2048.dds";
		
		// Player position on location map
		playerMapPosX = ( playerPos.X-theHud.navMapMinX ) * theHud.navMapScaleX;
		playerMapPosY = theHud.navMapHeight - ( playerPos.Y-theHud.navMapMinY ) * theHud.navMapScaleY;
		
		// Player position on world map
		playerWorldMapPosX = 0;
		playerWorldMapPosY = 0;

		// Maps friendly names
		theHud.SetString( "HiRealmName", "", AS_map );
		if( thePlayer.GetCurrentAreaMapId() == "" || !thePlayer.GetCurrentAreaMapShowName() )
		{
			theHud.SetString( "LoRealmName", "", AS_map );
		}
		else
		{
			theHud.SetString( "LoRealmName", GetLocStringByKeyExt( thePlayer.GetCurrentAreaMapId() ), AS_map );
		}

		// Player position (on small and big map - the position is different)
		//AS_playerPos = theHud.CreateAnonymousObject();
		//theHud.SetFloat( "X", 0, AS_playerPos );
		//theHud.SetFloat( "Y", 0, AS_playerPos );
		//theHud.SetObject( "HiPCPosition", AS_playerPos, AS_map );
		//theHud.ForgetObject( AS_playerPos );
		
		//AS_playerPos = theHud.CreateAnonymousObject();
		//theHud.SetFloat( "X", x, AS_playerPos );
		//theHud.SetFloat( "Y", y, AS_playerPos );
		//theHud.SetObject( "LoPCPosition", AS_playerPos, AS_map );
		//theHud.ForgetObject( AS_playerPos );

		// World map pins
		//public var HiPins : Array; // of voNavPin
		// TODO
		
		m_hasDoors = FindMappinDoorPos( m_doorWorldPos );
		
		// Local map pins
		//public var LoPins : Array; // of voNavPin
		if ( !theHud.GetObject( "LoPins", AS_loPins, AS_map ) )
		{
			LogChannel( 'GUI', "Map: cannot get LoPins object from scaleform" );
			return;
		}
		theHud.ClearElements( AS_loPins );
		
		// Player position
		pinKind = 6; // PC
		AS_pin = theHud.CreateAnonymousObject();
			theHud.SetFloat( "PosX", playerMapPosX, AS_pin );
			theHud.SetFloat( "PosY", playerMapPosY, AS_pin );
			theHud.SetFloat( "Kind", pinKind, AS_pin );
			theHud.SetString( "Desc", "", AS_pin );
		theHud.PushObject( AS_loPins, AS_pin );
		theHud.ForgetObject( AS_pin );
		if ( flipY ) playerRotShift = 180; else playerRotShift = 0;
		theHud.SetFloat( "PlayerDirection", -(thePlayer.GetHeading() + playerRotShift), AS_map );
		
		// BETA HACK
		theHud.GetNavMapPins( navMapPins, navMapPinsKind, navMapDescs, navMapPinsTag );
		for ( i = 0; i < navMapPins.Size(); i += 1 )
		{
			// Calculate pin position
			currentMapPinTags.Clear();
			currentMapPinTags.PushBack( navMapPinsTag[i] );
			CalculateMapPinPos( navMapPins[i], navMapPinsKind[i], currentMapPinTags, pinPosX, pinPosY );

			AS_pin = theHud.CreateAnonymousObject();
			theHud.SetFloat( "PosX", pinPosX, AS_pin );
			theHud.SetFloat( "PosY", pinPosY, AS_pin );
			theHud.SetFloat( "Kind", navMapPinsKind[i], AS_pin );
			theHud.SetString( "Desc", navMapDescs[i], AS_pin );
			//LogChannel( 'MapPin', "Kind: " + pinKind + "  Pos : " + pinPosX + " , " + pinPosY );
			theHud.PushObject( AS_loPins, AS_pin );
			theHud.ForgetObject( AS_pin );
		}
		
		for ( i = 0; i < theHud.m_map.mapPins.Size(); i += 1 )
		{
			//if ( theHud.m_map.mapPins[i].DisplayMode == MapPinDisplay_Both ||
				// theHud.m_map.mapPins[i].DisplayMode == MapPinDisplay_Map )
			//{
				LogChannel( 'GUI', "Mappin: " + theHud.m_map.mapPins[i].Name + " : " + theHud.m_map.mapPins[i].Description );
			//}
			
			//editable var Enabled		: bool;
			//editable var Name			: string;
			//editable var Description	: string;
			//editable var Type			: EMapPinType;
			//editable var DisplayMode	: EMapPinDisplayMode;
			
			// ustawiaj pole Kind numberem z NavPinEnum
			/*
				public static var INN : Number = 2;
				public static var CRAFT : Number = 3;
				public static var SHOP : Number = 4;
				public static var QUEST : Number = 5;
				public static var PC : Number = 6;
				public static var NPC : Number = 7;
			*/
			switch( theHud.m_map.mapPins[i].Type ) // TODO: Move it to the function
			{
				case MapPinType_Quest:
					pinKind = 5;
					break;
				case MapPinType_Inn:
					pinKind = 2;
					break;
				case MapPinType_Shop:
					pinKind = 4;
					break;
				case MapPinType_Craft:
					pinKind = 3;
					break;
				default:
					pinKind = 0;
			}
			
			if ( pinKind != 0 )
			{
				// Calculate pin position
				pinEntity = (CEntity)theHud.m_map.mapPins[i].GetParent();
				CalculateMapPinPos( pinEntity.GetWorldPosition(), pinKind, pinEntity.GetTags(), pinPosX, pinPosY );

				AS_pin = theHud.CreateAnonymousObject();
					theHud.SetFloat( "PosX", pinPosX, AS_pin );
					theHud.SetFloat( "PosY", pinPosY, AS_pin );
					theHud.SetFloat( "Kind", pinKind, AS_pin );
					theHud.SetString( "Desc", GetMapPinDescForEntity(pinEntity, theHud.m_map.mapPins[i].Type), AS_pin );
					//LogChannel( 'MapPin', "Kind: " + pinKind + "  Pos : " + pinPosX + " , " + pinPosY );
				theHud.PushObject( AS_loPins, AS_pin );
				theHud.ForgetObject( AS_pin );
			}
		}
		
		theHud.ForgetObject( AS_loPins );
		

		// Maps paths
		theHud.SetString( "HiNavSheet",	worldMapFile, AS_map );
		theHud.SetString( "LoNavSheet",	"img://globals/gui/maps/" + mapFile + ".dds", AS_map );
		
		// Fog of war
		if ( theHud.GetFOWInfo( thePlayer.GetCurrentMapId(), fowInfo, gridSize ) )
		{
			theHud.SetFloat( "FogGridSize", gridSize, AS_map );
			theHud.SetFloat( "FogCellSizeX", 2048/gridSize, AS_map );
			theHud.SetFloat( "FogCellSizeY", 2048/gridSize, AS_map );
		
			if ( !theHud.GetObject( "LoFog", AS_loFogOfWar, AS_map ) )
			{
				LogChannel( 'GUI', "Map: cannot get LoFog object from scaleform" );
				return;
			}
			
			if ( !theHud.GetObject( "HiFog", AS_hiFogOfWar, AS_map ) )
			{
				LogChannel( 'GUI', "Map: cannot get HiFog object from scaleform" );
				return;
			}
		
			theHud.ClearElements( AS_loFogOfWar );
			theHud.ClearElements( AS_hiFogOfWar );
		
			for ( i = 0; i < (gridSize*gridSize); i = i + 1 )
			{
				theHud.PushFloat( AS_hiFogOfWar, 1 );
				theHud.PushFloat( AS_loFogOfWar, fowInfo[i] );
			}

			theHud.ForgetObject( AS_loFogOfWar );
			theHud.ForgetObject( AS_hiFogOfWar );
		}
		else
		{
			theHud.SetFloat( "FogGridSize", 32, AS_map );
			theHud.SetFloat( "FogCellSizeX", 64, AS_map );
			theHud.SetFloat( "FogCellSizeY", 64, AS_map );
			
			if ( !theHud.GetObject( "LoFog", AS_loFogOfWar, AS_map ) )
			{
				LogChannel( 'GUI', "Map: cannot get LoFog object from scaleform" );
				return;
			}
			
			if ( !theHud.GetObject( "HiFog", AS_hiFogOfWar, AS_map ) )
			{
				LogChannel( 'GUI', "Map: cannot get HiFog object from scaleform" );
				return;
			}
			
			theHud.ClearElements( AS_loFogOfWar );
			theHud.ClearElements( AS_hiFogOfWar );
			
			for ( i = 0; i < (32*32); i = i + 1 )
			{
				theHud.PushFloat( AS_hiFogOfWar, 1 );
				theHud.PushFloat( AS_loFogOfWar, 1 );
			}

			theHud.ForgetObject( AS_loFogOfWar );
			theHud.ForgetObject( AS_hiFogOfWar );			
		}
	
	}
	
	//////////////////////////////////////////////////////////////
	// Utility methods
	//////////////////////////////////////////////////////////////
	private function IsWorldPosInsideMap( x : float, y : float ) : bool
	{
		//LogChannel( 'rychu', theHud.navMapMinX + " : " + theHud.navMapMaxX + " ; " + theHud.navMapMinY + " : " + theHud.navMapMaxY );
		return x >= theHud.navMapMinX && x <= theHud.navMapMaxX && y >= theHud.navMapMinY && y <= theHud.navMapMaxY;
	}
	
	private function FindMappinDoorPos( out doorWorldPos : Vector ) : bool
	{
		var doorsNodes   : array< CNode >;
		var doorNode     : CNode;
		var result       : Vector;
		
		theGame.GetNodesByTag( 'mappin_door', doorsNodes );
		if ( doorsNodes.Size() == 0 ) return false;
		
		doorNode = FindClosestNode( thePlayer.GetWorldPosition(), doorsNodes );
		result = doorNode.GetWorldPosition();
	
		if ( IsWorldPosInsideMap(result.X, result.Y) )
		{
			doorWorldPos = result;
			return true;
		}

		return false;
	}
	
	private function FindMappinDoorForTagPos( mapPinName : name, out doorWorldPos : Vector ) : bool
	{
		var doorsNodes   : array< CNode >;
		var doorNode     : CNode;
		var result       : Vector;
		
		theGame.GetNodesByTag( StringToName("mappin_door_" + mapPinName), doorsNodes );
		if ( doorsNodes.Size() == 0 ) return false;
		
		doorNode = FindClosestNode( thePlayer.GetWorldPosition(), doorsNodes );
		result = doorNode.GetWorldPosition();
	
		if ( IsWorldPosInsideMap(result.X, result.Y) )
		{
			doorWorldPos = result;
			return true;
		}

		return false;
	}

	private function CalculateMapPinPos( mapPinsWorldPos : Vector, mapPinKind : int, mapPinTags : array< name >, out x : int, out y : int )
	{
		var posX, posY : float;
		var doorWorldPos : Vector;
		var foundDoors : bool = false;
		var i : int;
		
		// TODO: Quest map pin kind do not use number, use constant instead
		if ( mapPinKind == 5 && ! IsWorldPosInsideMap(mapPinsWorldPos.X, mapPinsWorldPos.Y) )
		{
			for ( i = 0; i < mapPinTags.Size(); i+=1 )
			{
				if ( FindMappinDoorForTagPos( mapPinTags[i], doorWorldPos ) )
				{
					posX = doorWorldPos.X;
					posY = doorWorldPos.Y;
					foundDoors = true;
					break;
				}
			}
			if ( !foundDoors && m_hasDoors )
			{
				posX = m_doorWorldPos.X;
				posY = m_doorWorldPos.Y;
				foundDoors = true;
			}
		}
		if ( !foundDoors )
		{
			posX = mapPinsWorldPos.X;
			posY = mapPinsWorldPos.Y;
		}

		x = (int)(( posX - theHud.navMapMinX ) * theHud.navMapScaleX);
		y = (int)(theHud.navMapHeight - (( posY - theHud.navMapMinY ) * theHud.navMapScaleY));
	}
	
	private function GetMapPinDescForEntity( entity : CEntity, type : EMapPinType ) : string
	{
		var result     : string;
		var mapPinName : string;
		var gameplayEntity : CGameplayEntity;

		gameplayEntity = (CGameplayEntity) entity;
		
		if ( gameplayEntity )
		{
			mapPinName = gameplayEntity.GetDisplayName( false );
		}
		else
		{
			mapPinName = ""; //entity.GetName();
		}
		
		if ( type == MapPinType_Quest && m_questName != "" )
		{
			result = "<font color='#FFFFFF'>" + m_questName + "</font>";
			if ( mapPinName != "" )
			{
				result += " / " + mapPinName;
			}
		}
		else
		{
			result = mapPinName;
		}
		
		return result;
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		FillMap();
	}
}
