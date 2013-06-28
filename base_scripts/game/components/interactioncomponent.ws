/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CInteractionComponent
/** Copyright © 2010
/***********************************************************************/

import class CInteractionComponent extends CInteractionAreaComponent
{
	// Returns the action the component is set to initiate
	import final function GetActionName() : string;

	import final function GetInteractionFriendlyName() : string;
	
	import final function GetInteractionKey() : int;
}
