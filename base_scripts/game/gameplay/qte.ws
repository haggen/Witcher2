/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Quick Time Events
/** Copyright © 2010
/***********************************************************************/

/*
enum EQTEPosition
{
	QTEPosition_North,
	QTEPosition_East,
	QTEPosition_South,
	QTEPosition_West,
	QTEPosition_Center
};

enum EQTEResult
{
	QTER_Failed,
	QTER_Succeeded,
	QTER_InProgress
};
*/

import struct SQTEResultData
{
	import var action : name;
	import var totalTime : float;
	import var time : float;
};

class QTEListener
{
	event OnQTEMash( player : CPlayer, key : name, qteValue : float )    { }
	event OnQTESuccess( player : CPlayer, resultData : SQTEResultData ) { player.SetQTEListener( NULL ); }
	event OnQTEFailure( player : CPlayer, resultData : SQTEResultData ) { player.SetQTEListener( NULL ); }
}

//
// Usage:
//
// listener = new q666_QTEListener in player;
// player.SetQTEListener( listener );
// player.StartSinglePressQTEAsync( ... );
//
