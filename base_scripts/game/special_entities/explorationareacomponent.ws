/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CExplorationAreaSaveable
/** Copyright © 2011
/***********************************************************************/

import class CExplorationAreaComponent extends CActionAreaComponent
{
	event OnEnable( isEnabled : bool )
	{
		if ( isEnabled )
		{
			theHud.HudTargetEntityEx( (CGameplayEntity)GetEntity(), NAPK_Exploration );
		}
		else
		{
			theHud.HudTargetEntityEx( NULL );
		}
	}
	
	event OnPlayerInCombatEnteredArea( entered : bool )
	{
		if ( entered )
		{
			theHud.HudTargetEntityEx( (CGameplayEntity)GetEntity(), NAPK_ExplorationDisabled );
		}
		else
		{
			theHud.HudTargetEntityEx( NULL );
		}
	}
}
