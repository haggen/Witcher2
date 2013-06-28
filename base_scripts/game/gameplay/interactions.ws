/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Scripted interactions
/** Copyright © 2010
/***********************************************************************/

class CPlayerWithSwordInteractionComponent extends CInteractionComponent
{
	editable var mustHaveSword : bool;
	default mustHaveSword = true;
	
	event OnActivationTest( activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			if ( thePlayer.HasSteelSword() == mustHaveSword )
			{
				return true;
			}
		}
		
		return false;
	}
}

class CPlayerInCombatModeInteractionComponent extends CInteractionComponent
{
	editable var mustBeInCombat : bool;
	default mustBeInCombat = true;
	
	event OnActivationTest( activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			if ( thePlayer.IsInCombat() == mustBeInCombat )
			{
				return true;
			}
		}
		
		return false;
	}
}