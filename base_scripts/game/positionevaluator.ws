/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CAIPositionEvaluator
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// CAIPositionEvaluator
/////////////////////////////////////////////////////////////////////
import class CAIPositionEvaluator extends CObject
{
	// Find position, returns best position found and its score
	import final function FindPosition( centralActor, clientActor : CActor,
										provider : IAIPositionProvider,
										conditions : array<IAIPositionCondition>,
										maxTests : int,
										baseScore : float,
										out outPosition : Vector ) : float;
										
	// Test position with given conditions, returns score
	import final function TestPosition( position : Vector,
										centralActor, clientActor : CActor,
										conditions : array<IAIPositionCondition> ) : float;
};

/////////////////////////////////////////////////////////////////////
// IAIPositionProvider
/////////////////////////////////////////////////////////////////////
import class IAIPositionProvider extends CObject
{
};

/////////////////////////////////////////////////////////////////////
// CAIPositionProviderRing
/////////////////////////////////////////////////////////////////////
import class CAIPositionProviderRing extends IAIPositionProvider
{
	import var minRadius : float;
	import var maxRadius : float;
}

/////////////////////////////////////////////////////////////////////
// CAIPositionProviderInLine
/////////////////////////////////////////////////////////////////////
import class CAIPositionProviderInLine extends IAIPositionProvider
{
	import var minDistance : float;
	import var maxDistance : float;
}

/////////////////////////////////////////////////////////////////////
// IAIPositionCondition
/////////////////////////////////////////////////////////////////////
import class IAIPositionCondition extends CObject
{
	import var scorePassed : float;
	import var scoreFailed : float;
};

/////////////////////////////////////////////////////////////////////
// CAIPositionConditionDistance
/////////////////////////////////////////////////////////////////////
import class CAIPositionConditionDistance extends IAIPositionCondition
{
	import var minDistance : float;
	import var maxDistance : float;
	import var fromCentralActor : bool;
};

/////////////////////////////////////////////////////////////////////
// CAIPositionConditionPathDistance
/////////////////////////////////////////////////////////////////////
import class CAIPositionConditionPathDistance extends IAIPositionCondition
{
	import var maxDistance : float;
	import var fromCentralActor : bool;
};

/////////////////////////////////////////////////////////////////////
// CAIPositionConditionAngleDistance
/////////////////////////////////////////////////////////////////////
import class CAIPositionConditionAngleDistance extends IAIPositionCondition
{
	import var maxAngleDistance : float;
};

/////////////////////////////////////////////////////////////////////
// CAIPositionConditionStraightLine
/////////////////////////////////////////////////////////////////////
import class CAIPositionConditionStraightLine extends IAIPositionCondition
{
	import var fromCentralActor : bool;
};
