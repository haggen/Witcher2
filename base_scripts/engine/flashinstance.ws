/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CFlashInstance
/** Copyright © 2009
/***********************************************************************/

/*

	AS variables usage:
	
	1. Basic variable usage:
		a. Simple variable creation
			theHud.SetString( "m_playerName", "Geralt" );							// _global.m_playerName		= "Geralt";
			theHud.SetFloat ( "m_playerGold", 100.f );							// _global.m_playerGold		= 100;
			theHud.SetBool  ( "m_playerIsAlife", true );							// _global.m_playerIsAlife	= true;
		
		b. Creating arrays
			var AS_array : int;
			AS_array = theHud.CreateArray( "m_arrayOfNumbers" );					// _global.m_arrayOfNumbers		= new Array();
			theHud.PushFloat( AS_array, 1.f );									// _global.m_arrayOfNumbers[]	= 1.f;
			theHud.PushFloat( AS_array, 2.f );									// _global.m_arrayOfNumbers[]	= 2.f;
			theHud.PushFloat( AS_array, 3.f );									// _global.m_arrayOfNumbers[]	= 3.f;
			theHud.PushFloat( AS_array, 4.f );									// _global.m_arrayOfNumbers[]	= 4.f;
			theHud.ForgetObject( AS_array ); 	// check the "Frequent variable usage" section
	
		c. Creating objects
			var AS_struct : int;
			AS_struct = theHud.CreateObject( "m_selectedWeapon" );				// _global.m_selectedWeapon				= new Object();
			theHud.SetString( "m_name",	"Bombastick Staff",	AS_struct );		// _global.m_selectedWeapon.m_name		= "Bombastick Staff";
			theHud.SetString( "m_type",	"staff",			AS_struct );		// _global.m_selectedWeapon.m_type		= "staff";
			theHud.SetFloat ( "m_price",	100.f,				AS_struct );		// _global.m_selectedWeapon.m_price		= 100;
			theHud.SetBool  ( "m_magical",	true,				AS_struct );	// _global.m_selectedWeapon.m_magical	= true;
			theHud.ForgetObject( AS_struct ); // check the "Frequent variable usage" section
			
		d. Accessing existing objects
			var isMagical : bool;
			var AS_struct : int;
			theHud.GetObject( "m_selectedWeapon", AS_struct );
			
			theHud.GetBool( "m_magical", isMagical, AS_struct )
			if ( isMagical )
				Log( "Player holds magical weapon" );
			
			theHud.ForgetObject( AS_struct ); // check the "Frequent variable usage" section
			
		e. Accessing existing arrays
			var element  : float;
			var AS_array : int;
			theHud.GetObject( "m_arrayOfNumbers", AS_array );
			
			if ( theHud.GetArraySize() > 0 )
			{
				theHud.GetFloatElement( AS_array, 0, element );
				if ( element < 10.f )
				{
					theHud.RemoveElement( AS_array, 0 );
				}
			}
			
			theHud.ForgetObject( AS_array ); // check the "Frequent variable usage" section
	
	2. Frequent object/array usage
		class Foo
		{
			var numberOfTicks	: int;
			var AS_object		: int;
			
			default numberOfTicks	= 0;
			default AS_object		= -1;
			
			function Init()
			{
				//! Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
				if ( ! theHud.GetObject( "m_stats", AS_object ) )
					AS_object = theHud.CreateObject( "m_stats" );
					
				//! Initialize object properties
				theHud.SetFloat( "m_noOfTicks", numberOfTicks, AS_object );
			}
			
			function Finalize()
			{
				//! Forget variable id
				theHud.ForgetObject( AS_object );

				//! and variable should be destroyed when it is no more needed
				//theHud.SetNull( "m_stats" );
			}
			
			function OnTick()
			{
				numberOfTicks += 1;
				
				//! Update object properties
				theHud.SetFloat( "m_noOfTicks", numberOfTicks, AS_object );
			}
		}
*/

///////////////////////////////////////////////////////////////////////////////////

/* This is for passing parameters to Flash */

import struct CFlashValueScript
{
	import var type 	: EFlashValueType;
	import var nnumber 	: float;
	import var sstring 	: string;
	import var bbool	: bool;
	import var hhandle	: int;
}

function FlashValueFromBoolean( value : bool ) : CFlashValueScript
{
	var v : CFlashValueScript;
	v.type = FVT_BOOL;
	v.bbool = value;
	return v;
}

function FlashValueFromFloat( value : float ) : CFlashValueScript
{
	var v : CFlashValueScript;
	v.type = FVT_NUMBER;
	v.nnumber = value;
	return v;
}

function FlashValueFromInt( value : int ) : CFlashValueScript
{
	return FlashValueFromFloat( ( float ) value );
}

function FlashValueFromHandle( value : int ) : CFlashValueScript
{
	var v : CFlashValueScript;
	v.type = FVT_HANDLE;
	v.hhandle = value;
	return v;
}

function FlashValueFromString( value : string ) : CFlashValueScript
{
	var v : CFlashValueScript;
	v.type = FVT_STRING;
	v.sstring = value;
	return v;
}

function FlashValueFromStringArray( value : array< string > ) : array< CFlashValueScript >
{
	var v : array< CFlashValueScript >;
	var i : int;
	
	for( i = 0; i < value.Size(); i += 1 )
	{
		v.PushBack( FlashValueFromString( value [ i ] ) );
	}
	
	return v;
}

///////////////////////////////////////////////////////////////////////////////////

import class CFlashInstance extends CObject
{
	// Invoke flash method without arguments
	import final function Invoke( method : string, optional parentId : int /*=-1 = _global*/ ) : bool;

	// Invoke flash method with one argument
	import final function InvokeOneArg( method : string, argument : CFlashValueScript, optional parentId : int /*=-1 = _global*/ ) : bool;
	
	// Invoke flash method with many arguments
	import final function InvokeManyArgs( method : string, arguments : array< CFlashValueScript >, optional parentId : int /*=-1 = _global*/ ) : bool;
	
	import final function InvokeMethod_rO( method : string, out result : int, optional parentId : int /*=-1 = _global*/ ) : bool;
	
	// AS simple type access interface
	// * return true on success
	import final function SetNull  ( varName : string,                 optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function SetString( varName : string, value : string, optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function SetFloat ( varName : string, value : float,  optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function SetBool  ( varName : string, value : bool,   optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function SetObject( varName : string, objectId : int, optional parentId : int /*=-1 = _global*/ ) : bool;
	
	import final function GetString( varName : string, out value : string, optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function GetFloat ( varName : string, out value : float,  optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function GetBool  ( varName : string, out value : bool,   optional parentId : int /*=-1 = _global*/ ) : bool;
	import final function GetObject( varName : string, out objectId : int, optional parentId : int /*=-1 = _global*/ ) : bool;
	
	// AS complex type creation interface
	// * return unique id of a variable
	import final function CreateArray ( varName : string, optional parentId : int /*=-1 = _global*/ ) : int;
	import final function CreateAnonymousArray() : int;
	import final function CreateObject( varName : string, optional parentId : int /*=-1 = _global*/ ) : int;
	import final function CreateAnonymousObject() : int;
	import final function ForgetObject( objectId : int ) : bool;	// Forget given object/array id

	// AS array modification interface
	// * return false if failed (no such array?)
	import final function PushString( arrayId : int, value : string )	: bool;
	import final function PushFloat ( arrayId : int, value : float )	: bool;
	import final function PushBool  ( arrayId : int, value : bool )		: bool;
	import final function PushObject( arrayId : int, objectId : int )	: bool; // pass objectId = -1 to push NULL
	
	import final function SetStringElement( arrayId : int, index : int, value : string )	: bool;
	import final function SetFloatElement ( arrayId : int, index : int, value : float )		: bool;
	import final function SetBoolElement  ( arrayId : int, index : int, value : bool )		: bool;
	import final function SetObjectElement( arrayId : int, index : int, objectId : int )	: bool; // pass objectId = -1 to set NULL
	
	import final function GetStringElement( arrayId : int, index : int, out value : string )	: bool;
	import final function GetFloatElement ( arrayId : int, index : int, out value : float )		: bool;
	import final function GetBoolElement  ( arrayId : int, index : int, out value : bool )		: bool;
	import final function GetObjectElement( arrayId : int, index : int, out value : int )		: bool;

	import final function PopElement   ( arrayId : int ) : bool;
	import final function RemoveElement( arrayId : int, index : int ) : bool;
	import final function ClearElements( arrayId : int ) : bool;
	import final function GetArraySize ( arrayId : int ) : int;
	
	event OnFlashInit() {}
};

import function CreateFlashEntityHandle( entity : CEntity ) : string;
import function GetEntityByFlashHandle( handle : string ) : CEntity;