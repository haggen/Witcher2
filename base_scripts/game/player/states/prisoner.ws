/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

enum PE_PrisonerEvent
{
	PE_hit_face,
	PE_hit_front,
	PE_hit_left,
	PE_hit_right,
}

///////////////////////////////////////////// 
// Prisoner state for Q002
/////////////////////////////////////////////

state Prisoner in CPlayer extends Movable
{
	var prevState : EPlayerState;
	
	event OnEnterState()
	{
		parent.ActivateBehavior('prisoner');
		parent.AddTimer( 'ProcessMovement', 0.001, true, false, TICK_PrePhysics );
		
		parent.SetManualControl( parent.isMovable, true );
	}
	
	event OnLeaveState()
	{
		parent.RemoveTimer( 'ProcessMovement', TICK_PrePhysics );
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	event OnHit( hitParams : HitParams )
	{
		var roll : float;
		
		roll = RandF();
		
		if( roll >= 0.f && roll < 0.25f )
		{
			theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitFace');
			parent.RaiseEvent('HitFace');
		}
		else if( roll >= 0.25f && roll < 0.5f )
		{
			theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitFront');
			parent.RaiseEvent('HitFront');
		}
		else if( roll >= 0.5f && roll < 0.75f )
		{
			theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitLeft');
			parent.RaiseEvent('HitLeft');
		}
		else if( roll >= 0.75f && roll < 1.f )
		{
			theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitRight');
			parent.RaiseEvent('HitRight');
		}
		
		parent.DecreaseHealth( hitParams.damage, true, hitParams.attacker );
		
		if( parent.health <= 0 )
		{
			theHud.m_fx.DeathStart();
		}
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if ( IsCameraControlKey( key ) && !ProcessCameraInputs( key, value ) )
		{
			//We want the control over camera so pass the input further
			return false;
		}
		// this is some scary crap, it should work without the following condition
		else if( key == 'GI_MouseX' || key == 'GI_MouseY' )
			return false;
		
		return true;
	}
	
	entry function Q002_prisoner(oldPlayerState : EPlayerState)
	{
		prevState = oldPlayerState;
	}
	
	entry function LeavePrisonerState()
	{
		parent.ChangePlayerState( prevState );
	}
}

/////////////////////////////////////////////
// Prisoner state for Q302
/////////////////////////////////////////////

state PrisonerMovable in CPlayer extends ExtendedMovable
{
	var prevState : EPlayerState;
	
	event OnEnterState()
	{
		parent.ActivateBehavior( 'q302_geralt_prisoner' );
		
		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage1');
		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage2');
		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage3');

		theCamera.RaiseForceEvent('Camera_Exploration');
		parent.cameraFurther = 0.0;
		
		// Intall movement timer
		parent.AddTimer( 'ProcessMovement', 0.001, true, false, TICK_PrePhysics );
		
		parent.SetManualControl( true, true );
	}
	
	entry function Q302_prisoner(oldPlayerState : EPlayerState)
	{
		prevState = oldPlayerState;
	}
	
	entry function LeavePrisonerMovableState()
	{
		parent.ChangePlayerState( prevState );
	}
}

//////////////////////////////////////////////////
// quest functions //////////////////////////////

quest function Q002_EnterPrisonerState() : bool
{
	//thePlayer.Q002_prisoner( thePlayer.GetCurrentPlayerState() );
	thePlayer.PlayerStateCallEntryFunction( PS_Prisoner, '' );
	return true;
}

quest function Q302_EnterPrisonerState() : bool
{
	//thePlayer.Q302_prisoner( thePlayer.GetCurrentPlayerState() );
	thePlayer.PlayerStateCallEntryFunction( PS_PrisonerMovable, '' );
	
	return true;
}

latent quest function Q002_LeavePrisonerState( playAnimation : bool ) : bool
{
	if( playAnimation )
	{
		//theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('Release');
		thePlayer.RaiseEvent('Release');
		thePlayer.WaitForBehaviorNodeDeactivation('freed', 40.f );
		//thePlayer.LeavePrisonerState();
	}
	
	thePlayer.PlayerStateCallEntryFunction( PS_Exploration, '' );
	
	return true;
}

quest function Q002_HitPrisoner( hitType : PE_PrisonerEvent ) : bool
{
	if( hitType == PE_hit_face )
	{
		theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitFace');
		thePlayer.RaiseEvent('HitFace');
	}
	else if ( hitType == PE_hit_front )
	{
		theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitFront');
		thePlayer.RaiseEvent('HitFront');
	}
	else if ( hitType == PE_hit_left )
	{
		theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitLeft');
		thePlayer.RaiseEvent('HitLeft');
	}
	else if ( hitType == PE_hit_right )
	{
		theGame.GetEntityByTag('q002_geralt_shackles').RaiseEvent('HitRight');
		thePlayer.RaiseEvent('HitRight');
	}
	
	return true;
}

quest function Q302_LeavePrisonerState() : bool
{
	//thePlayer.LeavePrisonerMovableState();
	thePlayer.PlayerStateCallEntryFunction( PS_Exploration, '' );
	return true;
}

