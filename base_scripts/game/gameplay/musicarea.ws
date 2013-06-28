/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CTakedownArea
/** Copyright © 2010
/***********************************************************************/

class W2MusicArea extends CEntity
{	
	private editable var cueName : string;
	private editable var autoTurnOffArea : bool;
	private editable var isEnabled : bool;
	// private editable var stopCurrentMusic : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( isEnabled )
		{
			// ???
			// if ( stopCurrentMusic )
			// {
			//	theSound.StopAllSounds( 1.0 );
			//}
			theSound.PlayMusicNonQuest( cueName );
			if ( autoTurnOffArea )
			{
				isEnabled = false;
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
	
};
