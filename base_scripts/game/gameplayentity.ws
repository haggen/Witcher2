  /***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2010 Dexio's Late Night R&D Home Center
/***********************************************************************/

import class CGameplayEntity extends CPeristentEntity
{
	import final function GetInventory() : CInventoryComponent;
	import final function GetCharacterStats() : CCharacterStats;	

	import final function RegisterOwnedEntity( entity : CEntity );
	import final function UnregisterOwnedEntity( entity : CEntity );
	


	editable saved var isHighlightedByMedallion : bool;
	
	default isHighlightedByMedallion = true;

	// If 'fallBack' is false, then display name is taken only from the gameplay entity
	import final function GetDisplayName( optional fallBack : bool /* = true */ ) : string;
	
	// -----------------------------------------------------------------
	// MapPin
	// -----------------------------------------------------------------
	private editable inlined var mapPin : CMapPin;
	
	// NPCs shouldnt use 'mapPin' set in entity
	// This method can be removed when all mapPin from NPCs entities is removed
	public function IsOnSpawnedMapPinEnabled() : bool
	{
		return true;
	}
	
	function IsPowerSource() : bool
	{
		return false;
	}
	
	function MappinEnable( enable : bool )
	{
		if( ! mapPin )
			return;
		
		mapPin.Enabled = enable;
		
		if( enable )	theHud.m_map.MapPinSet( this, mapPin );
		else			theHud.m_map.MapPinSet( this, NULL );
	}
	
	function MapPinSet( enabled : bool, pinName, pinDescription : string, pinType : EMapPinType, pinDisplayMode : EMapPinDisplayMode )
	{
		if ( ! mapPin )
		{
			mapPin = new CMapPin in this;
		}
		
		mapPin.Name			= pinName;
		mapPin.Description	= pinDescription;
		mapPin.Type			= pinType;
		mapPin.DisplayMode	= pinDisplayMode;
		
		MappinEnable( enabled );
	}
	
	function MapPinClear()
	{
		//if ( mapPin )
		//{
			theHud.m_map.MapPinSet( this, NULL );
			mapPin = NULL;
		//}
	}
	
	function IsInteractionMappinType() : bool
	{
		if ( mapPin )
		{
			return mapPin.IsMappinTypeNPC();
		}
		else
		{
			return true;
		}
	}
	
	// -----------------------------------------------------------------
	// Events
	// -----------------------------------------------------------------
	event OnGameplayPropertyChanged( propertyName : name );
	
	// Entity was dynamically spawned
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if ( mapPin && IsOnSpawnedMapPinEnabled() )
		{
			MappinEnable( mapPin.Enabled );
		}
	}
	
	// Entity was destroyed
	event OnDestroyed()
	{
		MapPinClear();
		
		super.OnDestroyed();
	}
};

///////////////////////////////////////////////////////////////////////

import class IEntityStateChangeRequest extends CObject
{
};

import class CScriptedEntityStateChangeRequest extends IEntityStateChangeRequest
{
	abstract function Execute( entity : CGameplayEntity );
};

import class CEnableDeniedAreaRequest extends IEntityStateChangeRequest
{
	import var enable	: bool;
};

import class CEnableExplorationAreaRequest extends IEntityStateChangeRequest
{
	import var enable	: bool;
};

import class CDoorStateRequest extends IEntityStateChangeRequest
{
	import var doorState : EDoorState; 
	import var immediate : bool;
};

import class CDynamicActorTemplateRequest extends IEntityStateChangeRequest
{
	import function Initialize( dynamicTemplate : CEntityTemplate, appearance : name, load : bool, isNotGeralt : bool );
};

import class CPlaySoundOnActorRequest extends IEntityStateChangeRequest
{
	import function Initialize( boneName : name, soundName : string, optional fadeTime : float );
};

