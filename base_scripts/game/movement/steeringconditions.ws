/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////////////////////////////////

import class CMoveSCScriptedCondition extends IMoveSteeringCondition
{
};

/////////////////////////////////////////////////////////////////////////

class CMoveSCPlayerHardlockCondition extends CMoveSCScriptedCondition
{
	function GetConditionName( out caption : string )
	{
		caption = "PlayerHardlock";
	}
	
	function Evaluate( agent : CMovingAgentComponent, goal : SMoveLocomotionGoal ) : bool
	{
		return thePlayer.hardlockOn;
	}
};

/////////////////////////////////////////////////////////////////////////
