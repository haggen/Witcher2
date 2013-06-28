/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CWitcherGame
/** Copyright © 2009
/***********************************************************************/

import class CServerInterface extends CObject
{
	import final function Connect();
	
	import final function IsConnected() : bool;
	
	import final function Disconnect();
	
	import final function IsRegisteredUser() : bool;
	
	import final function SendPoints( points : int ) : bool;
	
	import final function ArenaLogWave( numWave, points, timeInMinutes : int );
};