/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for EngineTime
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Engine time
/////////////////////////////////////////////

import struct EngineTime {};

/////////////////////////////////////////////
// Engine time functions
/////////////////////////////////////////////

// Create EngineTime from float (seconds)
import function EngineTimeFromFloat( seconds : float ) : EngineTime;

// Convert EngineTime to float (seconds)
import function EngineTimeToFloat( time : EngineTime ) : float;

// Convert EngineTime to string (seconds)
import function EngineTimeToString( time : EngineTime ) : string;

// Get processor time - for code execution time measurements
import function GetProcessorTime() : EngineTime;

/////////////////////////////////////////////
// Engine time operators
/////////////////////////////////////////////

// operator( EngineTime + EngineTime ) : EngineTime;
// operator( EngineTime + float ) : EngineTime;
// operator( EngineTime += EngineTime ) : EngineTime;
// operator( EngineTime += float ) : EngineTime;

// operator( EngineTime - EngineTime ) : EngineTime;
// operator( EngineTime - float ) : EngineTime;
// operator( EngineTime -= EngineTime ) : EngineTime;
// operator( EngineTime -= float ) : EngineTime;

// operator( EngineTime * float ) : EngineTime;
// operator( EngineTime *= float ) : EngineTime;
// operator( EngineTime / float ) : EngineTime;
// operator( EngineTime /= float ) : EngineTime;

// operator( EngineTime == EngineTime ) : bool;
// operator( EngineTime != EngineTime ) : bool;
// operator( EngineTime < EngineTime ) : bool;
// operator( EngineTime > EngineTime ) : bool;
// operator( EngineTime >= EngineTime ) : bool;
// operator( EngineTime <= EngineTime ) : bool;

// operator( EngineTime < float ) : bool;
// operator( EngineTime > float ) : bool;
// operator( EngineTime >= float ) : bool;
// operator( EngineTime <= float ) : bool;
