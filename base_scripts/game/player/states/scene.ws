/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Scene state
/////////////////////////////////////////////

state PrepareForScene in CPlayer extends Movable
{
	entry function StatePrepareForScene( scenePosition : Vector, heading : float, distance : float, moveType : EMoveType )
	{
		parent.ActionMoveToWithHeading( scenePosition, heading, moveType, 1.0f, distance );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		parent.PlayerStateCallEntryFunction( newState, "" );
	}
}

import state Scene in CPlayer extends Base
{
	private var behaviorStateName : string;	
	private var appearance : name;

	event OnEnterState()
	{
		super.OnEnterState();
		Log( "Player: Enter scene state" );
		theHud.m_hud.clearEntryText();
		parent.HideFastMenu();
		theGame.EnableButtonInteractions( false );		
		parent.immortalityModeScene = AIM_Invulnerable;
		thePlayer.SetGuardBlock(false, true);

		//appearance = parent.GetAppearance();
		//parent.SetAppearance( 'witcher_full_mimics' );
		
		parent.LockButtonInteractions();
		
		parent.SetLookAtMode( LM_Dialog );
	}	
	
	event OnLeaveState()
	{	
		Log( "Player: Exit scene state" );
		
		parent.UnlockButtonInteractions();
		
		parent.ResetLookAtMode( LM_Dialog );
		
		theGame.EnableButtonInteractions( true );
		parent.immortalityModeScene = AIM_None;
		super.OnLeaveState();
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
		
	entry function ReturnToSceneFromCutscene()
	{
		
	}
	
	entry function StartScene( oldPlayerState : EPlayerState, behStateName : string )
	{		
		this.behaviorStateName = behStateName;
		
		// Exploration state (or sneak) as default ending state
		parent.sceneExitState = parent.GetProperExplorationState();
	
		parent.ResetPlayerCamera();
		
		parent.SetMoveSpeed( 0.f );
		parent.SetRotationSpeed( 0.f );
		
		//parent.OnResetMovement();
	}
	
	event OnBlockingSceneStarted( scene : CStoryScene )
	{	
		if( parent.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponInstant( parent.GetCurrentWeapon() );
		}
		
		InitScene( scene );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		// external exit blocked, excluding cutscene
		if ( newState == PS_Cutscene )
		{
			ExitScene( newState );
		}
	}
	
	private entry function ExitScene( newState : EPlayerState )
	{
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		if ( newState != PS_Cutscene )
		{		
			parent.PlayerStateCallEntryFunction( newState, '' );			
		}
		else if ( newState == PS_Cutscene )
		{
			parent.EnterCutsceneState( oldState, '' );
		}
	}
	
	private function InitScene( scene : CStoryScene )
	{
		var voicetag : CName;
		var animset : CSkeletalAnimationSet;		
		
		voicetag = parent.GetVoicetag();
		
		animset = scene.GetCustomAnimset( voicetag );
		if ( animset )
		{
			parent.AddAnimset( animset );
		}
		
		parent.ActivateBehavior( 'StoryScene' );
		parent.DisableLookAt();
	}
}
