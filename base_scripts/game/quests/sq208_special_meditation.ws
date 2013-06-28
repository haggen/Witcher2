////////////////////////////////////////////////////////////////////////////////////
// SPECIAL STATE FOR SQ208
////////////////////////////////////////////////////////////////////////////////////

state TalentsResetedMeditation in CPlayer extends Meditation
{
	entry function StateTalentsResetedMeditation( oldPlayerState : EPlayerState )
	{
		prevState = oldPlayerState;
		
		//hide swords etc.
		if( thePlayer.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			thePlayer.HolsterWeaponLatent( thePlayer.GetCurrentWeapon() );
		}
		
		parent.SetHotKeysBlocked( true );
		
		parent.ActivateBehavior( 'meditation' );

		
		parent.WaitForBehaviorNodeActivation( 'idle_start' );
		
		//theHud.ShowCharacter(true);
	}
	
	entry function StateMeditationTalentsResetedExit()
	{
		thePlayer.SetAllPlayerStatesBlocked( false );
		theHud.CloseAllPanels();
		
		parent.RaiseForceEvent('exploration');
		theCamera.ResetRotation(true,true,true, 2.67);
		theCamera.RaiseEvent('exploration');
		parent.WaitForBehaviorNodeDeactivation('meditation_end', 4.0);
//		theCamera.RaiseForceEvent('meditation_reset');
		//theCamera.WaitForBehaviorNodeDeactivation('cam_meditation_end', 7.0);
		theCamera.SetCameraState(CS_Exploration);

		
		//parent.SetHotKeysBlocked( false );
		
		parent.PlayerStateCallEntryFunction( PS_Exploration, '' );
	}
}

quest function QEnterTalentsResetedMeditation()
{
	thePlayer.StateTalentsResetedMeditation( thePlayer.GetCurrentPlayerState() );
}

quest function QExitTalentsResetedMeditation()
{
	thePlayer.StateMeditationTalentsResetedExit();
}