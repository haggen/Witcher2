/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CGuardArea
/** Copyright © 2010
/***********************************************************************/

class CGuardArea extends CEntity
{
	private editable var fleeAreaTag : name;
	private editable var maxDistance : float;
	private editable var mayWander : bool;
	default maxDistance = 1.0f;
	default mayWander = true;
	
	final function GetMaxDistance() : float
	{
		return maxDistance;
	}
	
	final function MayWander() : bool
	{
		return mayWander;
	}
	
	function GetArea() : CAreaComponent
	{
		return (CAreaComponent)GetComponentByClassName( 'CAreaComponent' );
	}
	
	function GetFleeArea() : CAreaComponent
	{
		var node : CNode;
		var ga : CGuardArea;
		if( fleeAreaTag!='' && fleeAreaTag!='None' )
		{
			node = theGame.GetNodeByTag( fleeAreaTag );
			ga = (CGuardArea)node;
			if( ga )
			{
				return ga.GetArea();
			}
			else
			{
				Logf("ERROR: CGuardArea '%1' invalid flee area tag '%2'", this.GetName(), fleeAreaTag );
			}
		}
		
		return NULL;
	}
}