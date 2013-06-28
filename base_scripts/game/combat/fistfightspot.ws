/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

class W2FistfightSpot extends CEntity
{
	editable var npcTag : name;
	editable var fadeInLost : bool;
	editable var fadeInWon : bool;
	private var currentDeathSpot : int;
	
	default fadeInLost = true;
	default fadeInWon = true;
	
	function GetNPCTag() : name
	{
		return npcTag;
	}
	
	function GetDeathSpotOrientation( out pos : Vector, out rot : EulerAngles )
	{
		var c : CComponent;
		currentDeathSpot += 1;
		if( currentDeathSpot == 6 )
			currentDeathSpot = 1;
		
		c = GetComponent( StrFormat( "death%1", currentDeathSpot ) );
		if( c )
		{
			pos = c.GetWorldPosition();
			rot = c.GetWorldRotation();
		}
		else
		{
			pos = GetWorldPosition();
			rot = GetWorldRotation();
		}
	}
};

struct W2FistfightSpotRef
{
	var node : CNode;
	var position : Vector;
	var rotation : EulerAngles;
};

function GetFistfightSpotEntity( spot : W2FistfightSpotRef ) : W2FistfightSpot
{
	return (W2FistfightSpot)spot.node;
}

function GetFistfightSpotOrientation( spot : W2FistfightSpotRef, out pos : Vector, out rot : EulerAngles )
{
	if( spot.node )
	{
		pos = spot.node.GetWorldPosition();
		rot = spot.node.GetWorldRotation();
	}
	else
	{
		pos = spot.position;
		rot = spot.rotation;
	}
}

function GetFistfightDeathSpotOrientation( spot : W2FistfightSpotRef, out pos : Vector, out rot : EulerAngles )
{
	var ffSpot : W2FistfightSpot;
	if( spot.node && spot.node.IsA('W2FistfightSpot' ) )
	{
		ffSpot = (W2FistfightSpot)spot.node;
		ffSpot.GetDeathSpotOrientation( pos, rot );
	}
	else
	{
		GetFistfightSpotOrientation( spot, pos, rot );
	}
}
