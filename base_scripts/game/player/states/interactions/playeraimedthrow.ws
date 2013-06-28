/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/



/////////////////////////////////////////////
// Aimed throw interaction state
/////////////////////////////////////////////

state AimedThrow in CPlayer extends Combat
{
	private var currentEnemy		: CEntity;
	private var oldPlayerState 		: EPlayerState;
	private var throwMarkerEnt		: CThrowMarker;
	private var thrownEntity		: CThrowable;
	
	private var isAiming			: bool;
	private var targetPos			: Vector;
	
	private var	wasMovable			: bool;
	private var wasControlingCamera	: bool;
	private var currentTimeScale	: float;
	
	private var throwSucceeded		: bool;
	private var buttonReleased		: bool;
	
	private var isPetard			: bool;
	
	private var questAiming			: bool;
	private var instantCombatAction , beginCombatAction, finishAimingAction		: EPlayerCombatAction;
	default questAiming = false;
	
	private var saveLock			: int;
	
	event OnEnterState()
	{		
		var petard : CPetardBase;
		super.OnEnterState();
		thePlayer.SetGuardBlock(false, true);
		theGame.EnableButtonInteractions( false );
		
		saveLock = -1;
		theGame.CreateNoSaveLock( 'PlayerThrowing', saveLock );
		
		theGame.GetBlackboard().GetEntryEntity( 'currentEnemy', currentEnemy );
		if(thePlayer.GetLastLockedTarget())
		{
			enemy = (CActor)currentEnemy;
			SetTargetLock( enemy );
		}
		//if ( !theHud.m_hud.ShowTutorial("tut54", "", false) ) // <-- tutorial content is present in external tutorial - disabled
		//if ( !theHud.ShowTutorialPanelOld( "tut54", "" ) )

		wasMovable 					= parent.isMovable;
		wasControlingCamera 		= !parent.IsPlayerCameraBlocked();
		currentTimeScale 			= theGame.GetTimeScale();
		
		parent.SetManualControl( true, true );
		questAiming					= false;
		
		buttonReleased = false;
		throwSucceeded = false;
		isAiming = false;
		targetPos.X = 0;
		targetPos.Y = 0;
		targetPos.Z = 0;
		
		thrownEntity = (CThrowable)parent.GetInventory().GetDeploymentItemEntity( parent.thrownItemId );
		if( !thrownEntity )
		{
			Log( "ERROR: No item returned in GetDeploymentItemEntity() for " + parent.GetInventory().GetItemName( parent.thrownItemId ) );
			parent.ChangePlayerState( oldPlayerState );
			return true;
		}
		
		if( thrownEntity.IsA( 'CPetardBase' ) )
		{
			instantCombatAction = PCA_ThrowPetardFast;
			beginCombatAction	= PCA_ThrowPetard;
			finishAimingAction = PCA_FinishAimingPetard;
			isPetard				= true;
			petard = (CPetardBase)thrownEntity;
			petard.InitThrowEntity(parent.thrownItemId);
		}
		else
		{
			instantCombatAction = PCA_ThrowDaggerFast;
			beginCombatAction	= PCA_ThrowDagger;
			finishAimingAction = PCA_FinishAimingDagger;
			isPetard				= false;
		}
		
		//Throw button was pressed, start aiming after the button was held down for 0.3 second.
		parent.AddTimer( 'AimingDelay', 0.3f, false );
	}
	
	event OnLeaveState()
	{
		parent.DetachEntityFromSkeleton( thrownEntity );
		
		parent.RemoveTimer( 'UpdateMarker' );
		theGame.SetTimeScale(currentTimeScale);
		
		if ( throwMarkerEnt )
		{
			throwMarkerEnt.Disable();
			throwMarkerEnt = NULL;
		}
		
		if( !throwSucceeded )
		{
			thrownEntity.Destroy();
		}
		
		parent.SetManualControl( wasMovable, wasControlingCamera );
		
		theGame.EnableButtonInteractions( true );
		
		theGame.ReleaseNoSaveLock( saveLock );
		saveLock = -1;
		
		if( isAiming )
		{
			theSound.RestoreAllSounds();
			theSound.RestoreMusic();
			theGame.SetTimeScale(currentTimeScale);
		}
		
		super.OnLeaveState();
	}
	
	// -----------------------------------------------------------------
	// State management
	// -----------------------------------------------------------------
	
	entry function EntryAimedThrow( oldPlayerState : EPlayerState, behStateName : string )
	{
		this.oldPlayerState = parent.GetLastCombatStyle();//oldPlayerState;
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		parent.PlayerStateCallEntryFunction( newState, "" );
	}
	
	event OnHit( hitParams : HitParams )
	{
		var hitEnum : EPlayerCombatHit;
		
		if( isAiming )
		{
			theSound.RestoreAllSounds();
			theSound.RestoreMusic();
			theSound.PlaySound( "gui/gui/gui_speedup" );			
			theGame.SetTimeScale(currentTimeScale);
		}
		hitEnum = parent.ChooseHitEnum(hitParams);
		parent.PlayerCombatHit(hitEnum);
		
		parent.ChangePlayerState( oldPlayerState );
	}
	// -----------------------------------------------------------------
	// Aiming
	// -----------------------------------------------------------------
	
	private entry function StartAiming()
	{
		var res : bool;
		var markerTmpl : CEntityTemplate;
		var cameraDirection, rotationTarget, targetPos : Vector;
		
		isAiming = true;	
		
		markerTmpl = (CEntityTemplate)LoadResource("throw_marker");
		cameraDirection = theCamera.GetCameraDirection();
		rotationTarget = parent.GetWorldPosition() + 10*VecNormalize(cameraDirection);
		parent.RotateTo( rotationTarget, 0.1 );
		parent.PlayerCombatAction(beginCombatAction);
		Sleep(0.1);
		res = parent.WaitForBehaviorNodeDeactivation( 'CombatActionEnd', 3.0 );
		if( res )
		{
			if( !thrownEntity )
			{
				thrownEntity = (CThrowable)parent.GetInventory().GetDeploymentItemEntity( parent.thrownItemId );
				Sleep(0.001);
			}
			
			if( !parent.HasSilverSword() && !parent.HasSteelSword() )
				parent.AttachEntityToBone( thrownEntity, "l_thumb1" );
			else
				parent.AttachEntityToBone( thrownEntity, "l_weapon" );

		
			theCamera.SetCameraState( CS_Petard );
			cameraDirection = theCamera.GetCameraDirection();
			cameraDirection.Z = 0;
			targetPos = thePlayer.GetWorldPosition() + 10.0*VecNormalize(cameraDirection);
			if( !questAiming )
			{
				theSound.SilenceMusic();
				theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
					SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
				theSound.PlaySound( "gui/gui/gui_slowdown" );			
				theGame.SetTimeScale(0.2f * currentTimeScale);
				throwMarkerEnt = (CThrowMarker)theGame.CreateEntity(markerTmpl, targetPos, thePlayer.GetWorldRotation());
				if ( !throwMarkerEnt )
				{
					Log( "ERROR: Can't create aim marker!" );
					theSound.RestoreAllSounds();
					theSound.RestoreMusic();
					theSound.PlaySound( "gui/gui/gui_speedup" );
					theGame.SetTimeScale(currentTimeScale);
					parent.ChangePlayerState( oldPlayerState );
					return;
				}
				Sleep(0.05);
				throwMarkerEnt.UpdatePosition( isPetard );
			}
			else if( !throwMarkerEnt )
			{
				throwMarkerEnt = (CThrowMarker)theGame.CreateEntity(markerTmpl, targetPos, thePlayer.GetWorldRotation());
				if ( !throwMarkerEnt )
				{
					Log( "ERROR: Can't create aim marker!" );
				}
				//Sleep(0.2);
				throwMarkerEnt.UpdatePosition( false );
			}
			
			while( !buttonReleased )
			{
				Sleep( 0.01 );
			}
		}
		
		StopAiming();
	}
	
	private latent function StopAiming()
	{
		var vec	:	Vector;
		var res : bool;
		
		if( !questAiming )
		{
			theGame.SetTimeScale(currentTimeScale);
			theSound.RestoreAllSounds();
			theSound.RestoreMusic();
			theSound.PlaySound( "gui/gui/gui_speedup" );			
		
			targetPos = throwMarkerEnt.GetPosition();
			
		}
		else
		{
			targetPos = throwMarkerEnt.GetPosition();
		}
		parent.RotateTo( targetPos, 0.1 );
		parent.PlayerActionForced(finishAimingAction);
		res = parent.WaitForBehaviorNodeDeactivation( 'CombatActionEnd', 0.5 );
		while( !res )
		{
			parent.PlayerActionForced(finishAimingAction);
			res = parent.WaitForBehaviorNodeDeactivation( 'CombatActionEnd', 0.5 );
		}
			
		if( questAiming )
		{
			Sleep( 1 );
			buttonReleased = false;
			StartAiming();
		}
	}
	
	timer function AimingDelay( time : float )
	{
		//If the throw button is pressed for longer then 'time' seconds, start aiming.
		StartAiming();
	}
	
	private entry function StartThrow()
	{
		var res : bool;
		var cameraDirection, rotationTarget : Vector;
		var timeout : float;
		
		timeout = 0.f;
				
		res = false;
		while( res == false )
		{
			Sleep(0.01f);
			if ( parent.IsActionActive() == false || timeout > 0.5f )
			{
				res = parent.PlayerCombatAction( instantCombatAction );
			}
			timeout += 0.01f;
		}
		
		
		if( !parent.HasSilverSword() && !parent.HasSteelSword() )
			parent.AttachEntityToBone( thrownEntity, "l_thumb1" );
		else
			parent.AttachEntityToBone( thrownEntity, "l_weapon" );
		
			
		if( currentEnemy )
			parent.RotateTo( currentEnemy.GetWorldPosition(), 0.1 );
		else
		{
			cameraDirection = theCamera.GetCameraDirection();
			rotationTarget = parent.GetWorldPosition() + 10*VecNormalize(cameraDirection);
			parent.RotateTo( rotationTarget, 0.1 );
		}
		
		// wait for a while
		Sleep( 1.0 );
		
		// change to the old player state
		parent.ChangePlayerState( oldPlayerState );
	}
	
	event OnGameInputEvent(key : name, value : float)
	{
		//Throw button was released, check if we entered Aiming or just make an instant throw at current enemy target(if available) or throw ahead.
		if( key == 'GI_UseItem' && !thePlayer.AreCombatHotKeysBlocked() )
		{
			if( !buttonReleased && value < 0.5 )
			{
				buttonReleased = true;
				parent.RemoveTimer( 'AimingDelay' );
				theGame.GetBlackboard().AddEntryTime( 'witcherAbilityCooldown', theGame.GetEngineTime() );
		
				if( !isAiming )
				{
					StartThrow();
				}
				return true;
			}
			return false;
		}
		
		// process the remaining input ONLY if we're in the aiming mode
		if ( isAiming )
		{
			if ( key == 'GI_AxisLeftX' )
			{
				return super.OnGameInputEvent( key, value );
			}
			else if ( key == 'GI_AxisLeftY' )
			{
				return super.OnGameInputEvent( key, value );
			}
			else if ( theGame.IsUsingPad() )
			{
				if ( key == 'GI_AxisRightY' || key == 'GI_AxisRightX' )
				{
					return super.OnGameInputEvent( key, value );
				}
			}
			else if ( IsCameraControlKey( key ) )
			{
				return super.OnGameInputEvent( key, value );
			}
			// this is some scary crap, it should work without the following condition
			else if( key == 'GI_MouseX' || key == 'GI_MouseY' )
				return false;
			
			return true;
		}
		
		return true;
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{				
		if ( animEventName == 'Thrown' )
		{
			throwSucceeded = true;
			
			if( !questAiming )
			{
				parent.GetInventory().RemoveItem( parent.thrownItemId );
			}
				
			Log( "Throwable item (" + parent.GetInventory().GetItemName( parent.thrownItemId ) + ") has been thrown, " + parent.GetInventory().GetItemQuantity( parent.thrownItemId ) + " more left." );
			
			if( enemy )
				currentEnemy = enemy;
				
			if( currentEnemy && ( !isAiming || questAiming ) )
			{
				if( currentEnemy.GetBoneIndex( 'pelvis' ) > -1 )
				{
					targetPos = MatrixGetTranslation( currentEnemy.GetBoneWorldMatrix( 'pelvis' ) );
				}
				else
				{
					targetPos = currentEnemy.GetWorldPosition();
					
				}
					
			}
					
			thrownEntity.StartFlying( targetPos );
			parent.ChangePlayerState( oldPlayerState );
		}
		else if ( animEventName == 'Hardlock' )
		{
			if ( animEventType == AET_DurationStart )
			{
				if ( IsSoftLock() )
				{
					SoftLockOff();
				}
				
				parent.SetHardlock( true );
				parent.AddTimer( 'EmergencyHardlockClear', 0.3 );
			}
			else if ( animEventType == AET_DurationEnd )
			{
				parent.SetHardlock( false );
				parent.RemoveTimer( 'EmergencyHardlockClear' );
			}
			else if( animEventType == AET_Duration )
			{
				parent.SetHardlock( true );
				parent.AddTimer( 'EmergencyHardlockClear', 0.3 );
			}
		}
		else
		{
			return super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	event OnItemUse( itemId : SItemUniqueId ) {}
	
	// -----------------------------------------------------------------
	// Quest functionality
	// -----------------------------------------------------------------
	
	entry function QEntryAiming( oldPlayerState : EPlayerState )
	{
		this.oldPlayerState = oldPlayerState;
		parent.RemoveTimer( 'AimingDelay' );
		parent.SetAllPlayerStatesBlocked( true );
		
		parent.ActivateBehavior( 'PlayerCombat' );
		
		questAiming = true;
		
		parent.SetManualControl( false, true );
		
		Sleep(0.1);
		StartAiming();
	}
	
	entry function QExitAiming()
	{
		var res : bool;
		throwMarkerEnt.Disable();
		throwMarkerEnt = NULL;
		
		parent.PlayerCombatAction(PCA_StopAimingDagger);
		
		if( thrownEntity )
			thrownEntity.Destroy();
		
		parent.SetAllPlayerStatesBlocked( false );		
		parent.ChangePlayerState( oldPlayerState );
	}
}

class CThrowMarker extends CEntity
{
	private var position	:	Vector;
	private var normal		:	EulerAngles;
	private var isPetard	:	bool;
	private var component	:	CComponent;
	
	function GetPosition() : Vector
	{
		if(!isPetard)
		{
			component = this.GetComponent("throw_marker");
			return component.GetWorldPosition();
		}
		return position;
	}
		
	private function CalculateTargetPos()
	{
		var cameraDir	: Vector 	= theCamera.GetCameraDirection();
		var range		: float		= 30;
		var pointA		: Vector	= theCamera.GetCameraPosition();
		var pointB		: Vector;
		var norm		: Vector;
		var epsilon		: Vector	= Vector( 0.01f, 0.01f, 0.01f );
					
		pointB = pointA + cameraDir * range;
		
		if( !theGame.GetWorld().StaticTrace( pointA, pointB, position, norm, CLT_Missile ) )
		{
			position = pointB;
			if( isPetard )
				theGame.GetWorld().PointProjectionTest( position, normal, 100.0 );
		}
		
		if( !isPetard )
		{
			position -= VecNormalize( cameraDir ) * 0.2f;
		}
	
		norm += epsilon;
		norm.Z = -norm.Z;
		normal = VecToRotation(norm);
	}
}

state Active in CThrowMarker
{	
	entry function UpdatePosition( isPetard : bool )
	{
		parent.isPetard = isPetard;
		
		if( isPetard )
			parent.PlayEffect( 'marker_fx' );
		else
			parent.PlayEffect( 'throw_marker' );
			
		parent.CalculateTargetPos();
		parent.TeleportWithRotation( parent.position, parent.normal );
		//thePlayer.SetRotationTarget( parent, true );
		parent.AddTimer( 'Update', 0.00000001, true );
	}
	
	timer function Update( time : float )
	{
		parent.CalculateTargetPos();
		parent.TeleportWithRotation( parent.position, parent.normal );
	}
}

state InActive in CThrowMarker
{
	entry function Disable()
	{
		parent.Destroy();
	}
}
