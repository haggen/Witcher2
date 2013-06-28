/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

import struct CSound {}

import class CScriptSoundSystem extends CObject
{
	import function PlayMusic( cueName : string );
	import function PlayMusicNonQuest( cueName : string );
	import function PlayMusicFistFight( cueName : string );
	
	import function StopMusic( cueName : string, optional dontSilence : bool );
	import function SetMusicVolume( dbVolume : float );
	import function SilenceMusic();
	import function SilenceMusicImmediately();
	import function RestoreMusic();

	import function PlaySound( eventName : string ) : CSound;
	import function PlaySoundWithFade( eventName : string ) : CSound;
	import function PlaySoundOnActor( actor : CNode, boneName : name, eventName : string ) : CSound;
	import function PlaySoundOnActorWithFade( actor : CNode, boneName : name, eventName : string ) : CSound;
	import function PlaySoundWithParameter( eventName : string, parameterName : string, parameterValue : float  ) : CSound;

	
	import function SetSoundVolume( sound : CSound, volume : float );
	
	import function StopSound( sound : CSound );
	import function StopSoundWithFade( sound : CSound );
	import function StopSoundByName( eventName : string ); // NOTE: Stops all events with given name!
	import function StopSoundByNameWithFade( eventName : string ); // NOTE: Stops all events with given name!
	
	// IMPORTANT! - Every SetSoundsVolume !must! be followed by RestoreAllSounds!
	import function MuteAllSounds();
	import function RestoreAllSounds();
	import function SetSoundsVolume( types : int, dbVolume : float, fadeTime : float );
	
	import function TriggerCombatMusic( timeout : float );
	import function CancelCombatMusic();
	import function BlockCombatMusic( block : bool );

	// Haha! Final game hack!
	import function PlayMainMenuMusic( eventName : string ) : CSound;
	

	import function UpdateParameter( parameterName : string, parameterValue : float );
}

// Some useful, console functions

exec function silenceMusic()
{
	theSound.SilenceMusic();
}

exec function restoreMusic()
{
	theSound.RestoreMusic();
}

exec function playMusic( cueName : string )
{
	theSound.PlayMusicNonQuest( cueName );
}

exec function stopMusic( cueName : string )
{
	theSound.StopMusic( cueName );
}

exec function setMusicVolume( musicVolume : float )
{
	theSound.SetMusicVolume( musicVolume );
}
