/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////
// StoryScene class
/////////////////////////////////////////////

exec function PlaySceneOnActor( actorTag : name, sceneInput : string )
{
	var actor : CActor;
	actor = theGame.GetActorByTag( actorTag );
	actor.PlayScene( sceneInput );
}

import class CStoryScene extends CResource
{
	import final function GetCustomBehavior( voicetag : name ) : CBehaviorGraph;
	import final function GetCustomAnimset( voicetag : name ) : CSkeletalAnimationSet;
	
	import final function GetRequiredPositionTags() : array< name >;
}

import class CStoryScenePlayer extends CEntity
{
	import final function GetScene() : CStoryScene;
	import final function GetSceneActor( actorVoicetag : name ) : CActor;
	import final function GetSceneCamera( cameraName : name ) : CCamera;
	import final function GetActiveSceneCamera() : CCamera;
	import final function RemoveActorFromScene( actorVoicetag : name );
	import final function FadeOut();
	import final function FadeIn();
	import final function RegisterScriptedActor( actor : CActor );
	import final function UnregisterScriptedActor( actor : CActor );
	
	// Blocking scene is starting
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		var Player : CPlayer;
	
		theGame.SetHoursPerMinute( 0.f );
		//theHud.m_hud.HideTutorial();
		
		Player = thePlayer;
		theCamera.Rotate( 0, 0 );
		
		theGame.SetTimeScale( 1.0f );
	}
	
	// Blocking scene has finished
	event OnBlockingSceneEnded()
	{
		theGame.ResetHoursPerMinute();
	}
}

/*
enum EStorySceneSignalType
{
	SSST_Accept,
	SSST_Highlight,
	SSST_Skip,
};
*/

import class CStorySceneSystem
{
	import final function SendSignal( signalType : EStorySceneSignalType, value : int );
	
	import final function GetChoices() : array< string >;
	import final function GetHighlightedChoice() : int;
	import final function PlayScene( scene : CStoryScene, input : string );
	
	import final function IsCurrentlyPlayingAnyScene() : bool;
}

import class CStorySceneSpawner extends CEntity
{
	import private var storyScene : CStoryScene;
	import private var inputName : string;
	editable var useSpawnerLocation : bool;
	
	default useSpawnerLocation = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( useSpawnerLocation == true )
		{
			SetTags( storyScene.GetRequiredPositionTags() );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( actionName == 'Talk' )
		{
			theGame.GetStorySceneSystem().PlayScene( storyScene, inputName );
		}
	}
}