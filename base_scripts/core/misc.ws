/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Misc functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Misc functions
/////////////////////////////////////////////

// Log script crap
import function Log( text : string );

// Formated logging
import function Logf( text : string, optional a,b,c,d : string );

// Log script crap
import function LogChannel( channel : name, text : string );

// Formated logging
import function LogChannelf( channel : name, text : string, optional a,b,c,d : string );

// Trace current callstack ( to log )
import function Trace();

// Break here if under debugger
import function DebugBreak();
// Sleep execution for given amount of time ( LATENT and ENTRY only )
import latent function Sleep( time : float );

// Yield thread execution for the current frame ( LATENT and ENTRY only )
import latent function Yield();

// Kill internal state thread ( LATENT and ENTRY only )
import latent function KillThread();

// Dump class hierarchy under given baseClass to log
import function DumpClassHierarchy( baseClass : name ) : bool;

enum EBrixResult
{
	BR_Success,
	BR_Failure,
};

// Is key press
function IsKeyPressed( value : float ) : bool
{
	if ( value > 0.5f ) return true;
	else return false;
}

// Is key release
function IsKeyReleased( value : float ) : bool
{
	if ( value <= 0.5f ) return true;
	else return false;
}

// Is name valid
function IsNameValid( n : name ) : bool
{
	return (n!='' && n!='None' );
}
