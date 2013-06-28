/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Cat fx class
/** Copyright © 2011
/***********************************************************************/

import class CGameplayFXCatEffect extends CEntity
{
	private var soundLoop : CSound;

	// Entity was dynamically spawned
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		theSound.PlaySound( "gui/alchemy/catstart" );
		soundLoop = theSound.PlaySound( "gui/alchemy/catloop" );
	}

	// Entity was destroyed
	event OnDestroyed()
	{
		theSound.StopSoundWithFade( soundLoop );
	}
}
