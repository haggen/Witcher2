/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Cutscene state
/////////////////////////////////////////////

state Cutscene in CPlayer extends Base
{
	var csRunning : bool;
	var prevState : EPlayerState;
	var prevBehState : string;
	var wasDarkEffectSteel : bool;
	var wasDarkEffectSilver : bool;
	
	event OnEnterState()
	{
		theHud.SetHudVisibility( "false" );
		super.OnEnterState();
		theGame.EnableButtonInteractions( false );
		thePlayer.ResetPlayerMovement();
		
		parent.LockButtonInteractions();
		
		parent.SetLookAtMode( LM_Cutscene );
		if(!thePlayer.IsInTakedownCutscene())
		{
			if(thePlayer.IsDarkWeaponSilver())
			{
				wasDarkEffectSilver = true;
				thePlayer.SetDarkWeaponSilver( false );
			}
			if(thePlayer.IsDarkWeaponSteel())
			{
				wasDarkEffectSteel = true;
				thePlayer.SetDarkWeaponSteel( false );
			}
		}
	}
	
	event OnLeaveState()
	{
		parent.UnlockButtonInteractions();
		
		parent.ResetLookAtMode( LM_Cutscene );
		
		theGame.EnableButtonInteractions( true );
		super.OnLeaveState();
		thePlayer.ResetPlayerMovement();
		if(wasDarkEffectSilver)
		{
			wasDarkEffectSilver = false;
			thePlayer.SetDarkWeaponSilver( true );
		}
		if(wasDarkEffectSteel)
		{
			wasDarkEffectSteel = false;
			thePlayer.SetDarkWeaponSteel( true );
		}	
	}
	
	event OnLeavingState()
	{
		return !csRunning;
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	event OnCutsceneStarted()
	{
		Log( "ERROR OnCutsceneStarte : Player is already in cutscene state");
	}
	
	event OnCutsceneEnded()
	{
		parent.OnCutsceneEnded();
		csRunning = false;
		parent.PlayerStateCallEntryFunction( prevState, '' );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		// external exit blocked
		if ( !csRunning && prevState == newState )
		{
			parent.ResetMovment();
			
			if( newState == PS_Scene )
			{			
				parent.ReturnToSceneFromCutscene();
			}
			else
			{
				//parent.EntryExploration( prevState, prevBehState );
				parent.PlayerStateCallEntryFunction( prevState, prevBehState );
			}
		}
	}
	
	entry function EnterCutsceneState( oldPlayerState : EPlayerState, behStateName : string )
	{
		csRunning = true;
		prevState = oldPlayerState;
		prevBehState = behStateName;
	}
}
