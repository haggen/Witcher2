/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the time manager
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Game time
/////////////////////////////////////////////

import struct GameTime {};

/////////////////////////////////////////////
// Game time functions
/////////////////////////////////////////////

// Create game time from given amount of seconds, minutes, etc. See notes on the bottom of the page.
import function GameTimeCreate( optional days, hours, minutes, seconds : int ) : GameTime;

// Extract number of seconds from the given game time
import function GameTimeSeconds( time : GameTime ) : int;

// Extract number of minutes from the given game time
import function GameTimeMinutes( time : GameTime ) : int;

// Extract number of hours from the given game time
import function GameTimeHours( time : GameTime ) : int;

// Extract number of days from the given game time
import function GameTimeDays( time : GameTime ) : int;

// Convert game time to string
import function GameTimeToString( time : GameTime ) : string;

// Count total number of seconds represented by this game time
import function GameTimeToSeconds( time : GameTime ) : int;

// Count total number of seconds represented by this game time
import function ScheduleTimeEvent( context : CObject, functionWithParams : string, date : GameTime, optional relative : bool, optional period : GameTime, optional limit : int );

/////////////////////////////////////////////
// Game time operators
/////////////////////////////////////////////

// operator ( GameTime + GameTime ) : GameTime
// operator ( GameTime + int ) : GameTime
// operator ( GameTime - GameTime ) : GameTime
// operator ( GameTime - int ) : GameTime
// operator ( GameTime * float ) : GameTime
// operator ( GameTime / float ) : GameTime
// operator ( GameTime += GameTime ) : GameTime
// operator ( GameTime += int ) : GameTime
// operator ( GameTime -= GameTime ) : GameTime
// operator ( GameTime -= int ) : GameTime
// operator ( GameTime *= float ) : GameTime
// operator ( GameTime /= float ) : GameTime
// operator ( GameTime == GameTime ) : bool
// operator ( GameTime != GameTime ) : bool
// operator ( GameTime < GameTime ) : bool
// operator ( GameTime > GameTime ) : bool
// operator ( GameTime >= GameTime ) : bool
// operator ( GameTime <= GameTime ) : bool

//
// Using GameTimeCreate:
//
//  GameTimeCreate() - now
//  GameTimeCreate( 10 ) - 10 seconds
//  GameTimeCreate( 1, 30 ) - 1 minute, 30 seconds
//  GameTimeCreate( 2, 45, 0 ) - 2 hours, 45 minutes, 0 seconds
//  GameTimeCreate( 1, 8, 30, 15 ) - 1 day, 8 hours, 30 minutes, 15 seconds

exec function GameTimeTest()
{
	var a,b : GameTime;
	
	a = GameTimeCreate();
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(5,2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(1,5,2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a /= 2.0;
	
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

}
