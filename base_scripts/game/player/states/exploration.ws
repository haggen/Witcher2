/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Exploration state
/////////////////////////////////////////////

state Exploration in CPlayer extends ExtendedMovable
{
	var eventAllowHitTime : EngineTime;
	var hitEventNames_t2 : array<name>;
	var hitEventNames_t3 : array<name>;

	event OnEnterState()
	{	
		parent.SetPlayerCombatStance(PCS_Low);
		
		parent.ActionCancelAll();

		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage1');
		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage2');
		parent.GetInventory().StopItemEffect( parent.GetCurrentWeapon(), 'blood_weapon_stage3');

		theCamera.SetCameraState(CS_Exploration);
		parent.cameraFurther = 0.0;
		super.OnEnterState();
		SetFindEnemyTimer();
		theHud.m_hud.CombatLogClear();
		
		hitEventNames_t2.Clear();
		hitEventNames_t2.PushBack('Hit_t2a');
		hitEventNames_t2.PushBack('Hit_t2b');
		
		hitEventNames_t3.Clear();
		hitEventNames_t3.PushBack('Hit_t3a');
		hitEventNames_t3.PushBack('Hit_t3b');
		
		thePlayer.SetIsInShadow( false );
				
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.RemoveTimer('FindEnemy');
	} 
	
	function SetFindEnemyTimer()
	{
		//parent.AddTimer( 'FindEnemy', 1.0, true );
		// NIE WIEM KTO TO TU WSADZIL ALE JEBIE WSZYSTKO W DEMIE DO GC
	}
	
	timer function FindEnemy( timeDelta : float )
	{
		var actors : array< CActor >;		
		actors = parent.FindEnemiesInCombatArea();
		if( actors.Size() > 0 )
		{
			if( !theGame.GetFistfightManager().OnIsRequestInProgress() )
			{
				parent.ChangePlayerState( PS_CombatSteel );
			}
		}
	}
	
	
	entry function SayGreeting( Npc : CNewNPC )
	{
		// Geralt don't speak first anymore
		// thePlayer.PlayVoiceset(100, "witcher_gameplay_greetings" );
		// thePlayer.WaitForEndOfSpeach()
		Npc.GetArbitrator().AddGoalTalk();
		thePlayer.ActionRotateTo( Npc.GetWorldPosition() );
	}
		
	event OnGameInputEvent( key : name, value : float )
	{
		var enemy : CNewNPC;
		var actor : CActor;
		var cooldown : EngineTime;
		
		if ( parent.isMovable )
		{
			if ( key == 'GI_UseItem' && !thePlayer.AreCombatHotKeysBlocked() )
			{
				if( value > 0.5 && !thePlayer.IsNotGeralt() )
				{
					if(thePlayer.IsManualControl() && !thePlayer.AreCombatHotKeysBlocked()&&!parent.HasLatentItemAction())
						thePlayer.ChangePlayerState(thePlayer.GetLastCombatStyle());
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
					return true;
				}
				return false;
			}
			// Enter combat state silver
			else if ( key == 'GI_Silver' && !thePlayer.AreCombatHotKeysBlocked() )
			{
				if( value > 0.5 && !thePlayer.IsNotGeralt() )
				{
					if(!thePlayer.AreCombatHotKeysBlocked()&&!parent.HasLatentItemAction())
					{
						parent.SetLastCombatStyle(PCS_Silver);
						parent.ChangePlayerState( PS_CombatSilver );
					}
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
					return true;
				}
				return false;
			}
			// Enter combat state steel
			else if ( key == 'GI_Steel' && !thePlayer.AreCombatHotKeysBlocked() )
			{
				if( value > 0.5 )
				{
					if(!thePlayer.AreCombatHotKeysBlocked()&&!parent.HasLatentItemAction())
					{
						parent.SetLastCombatStyle(PCS_Steel);
						parent.ChangePlayerState( PS_CombatSteel );
					}
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
					return true;
				}
				return false;
			}
			// Enter combat state fistfight
			// Drey: PlayerChangeStateFists input is not defined, i guess fists are only allowed as backup when no swords are equipped ?
			/*else if ( key == 'PlayerChangeStateFists' && value > 0.5)
			{
				// Character without equiped any weapon
				if(!thePlayer.AreCombatHotKeysBlocked()&&!parent.HasLatentItemAction())
				{
					parent.ChangePlayerState( PS_CombatFistfightDynamic );	
				}
				else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
				{
					theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
				}	
				return true;		
			}*/
		}
		
		// Pass to base class
		return super.OnGameInputEvent( key, value );
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		var trap : CEntity;
		super.OnAnimEvent( animEventName, animEventTime, animEventType );
	
		if ( animEventName == 'InteractTrap' )
		{
			if( theGame.GetBlackboard().GetEntryEntity( 'currentTrap', trap ) )
			{
				if( trap )
				{
					((CBaseTrap)trap).OnTrapInteractAnimEvent();
				}
			}
		}			
	}
	
	event OnHit( hitParams : HitParams )
	{	

		var currTime, deltaTime : EngineTime;
		var hitEvent : name;
		
		// Check allow hit flag
		currTime = theGame.GetEngineTime();
		deltaTime = currTime - eventAllowHitTime;
		
		//Log( EngineTimeToString( deltaTime ) );
	
		//if ( deltaTime < 0.1f )
		//{
		PlayHit( hitParams );
		parent.OnHit( hitParams );
	}
	
	private function PlayHit( hitParams : HitParams )
	{
		PlayHitExploration( hitParams );
	}
	
	entry function PlayHitExploration( hitParams : HitParams )
	{
		var hitEvent : name;
		var hitEnum : EPlayerCombatHit;
		var raiseEvent : bool;
		
		// Choose hit event. Use default funtion.
		//hitEvent = ChooseHitEvent( hitParams );
		
		hitEnum = parent.ChooseHitEnum( hitParams );
		
		parent.PlayerCombatHit(hitEnum);
		// Raise hit event
		//parent.RaiseForceEvent( hitEvent );
		//raiseEvent;
		
		// Wait for idle state
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation( 'CombatHitEnd' );
		
		// Go back to combat
		//LoopCombatSteel();
	}
	
	entry function EntryExploration( oldPlayerState : EPlayerState, behStateName : string )
	{	
		// this function can't be interrupted, as it activates a key behavior it simply needs to activate
		parent.LockEntryFunction( true );
		
		if( parent.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponLatent( parent.GetCurrentWeapon() );
		}
		
		ProcessMovement( 0 );
		parent.ActivateAndSyncBehavior( 'PlayerExploration' );
		
		parent.LockEntryFunction( false );
	}
	
	entry function LoopExploration()
	{
		while( true )
		{
			Sleep( 0.5 );
		}
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		ExitExploration( newState );
	}
	
	/*function GetEndingEventName( newState : EPlayerState ) : name
	{
		if (newState == PS_CombatSteel )
		{
			return 'ToCombatSteel';
		} 
		else if( newState == PS_CombatSilver )
		{
			return 'ToCombatSilver';
		}
		else if( newState == PS_CombatFistfight )
		{
			return 'ToFistfight';
		}

		return '';
	}*/
	
	entry function ExitExploration( newState : EPlayerState )
	{
		var behStateName : string;
		var endingEventName : name;
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		//behStateName = parent.GetCurrentBehaviorState();

		if ( oldState == PS_Cutscene || oldState == PS_Scene )
		{
			//parent.PopBehavior( 'PlayerExploration' );
		}
		
		parent.PlayerStateCallEntryFunction( newState, behStateName );
	}
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	function GetHitEventName_t2() : name
	{
		var s : int;
		s = hitEventNames_t2.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return hitEventNames_t2[Rand(s)];
		}
	}
	
	function GetHitEventName_t3() : name
	{
		var s : int;
		s = hitEventNames_t3.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return hitEventNames_t3[Rand(s)];
		}
	}
	
	function SetChangeStateTimer()
	{
		//parent.AddTimer( 'ChangeStateTimer', 0.5, false);
		parent.ChangePlayerState( parent.GetLastCombatStyle() );
	}
	
	timer function ChangeStateTimer( timeDelta : float )
	{
		//parent.ActivateBehavior( 'PlayerCombat' );
		//parent.ChangePlayerState( PS_CombatSteel );
	}
	
	/*private function ChooseHitEvent( hitParams : HitParams ) : name
	{
		var isFrontToSource : bool;
		
		isFrontToSource = parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 );
		
		if( hitParams.attackType == 'Attack' )
		{
			if( isFrontToSource )
			{	
				if( hitParams.attacker )
				{
					SetChangeStateTimer();
				}
				parent.RaiseForceEvent( 'Hit' );
			}
			else
			{
				return 'HitBack';
			}
		}
		
		else if( hitParams.attackType == 'Attack_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				if( hitParams.attacker )
				{
					SetChangeStateTimer();
				}
				parent.RaiseForceEvent( 'Hit_t1' );
				Log ( "HIT" + parent.RaiseForceEvent( 'Hit_t1' ) );
			}
			else
			{
				return 'Hit_t1b';
			}
		}
		else if( hitParams.attackType == 'Attack_t2' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{
				if( hitParams.attacker )
				{
					SetChangeStateTimer();
				}
				return GetHitEventName_t2();
			}
			else  
			{
				return 'Hit_t2back';
			}
		}
		else if( hitParams.attackType == 'Attack_t3' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{
				if( hitParams.attacker )
				{
					SetChangeStateTimer();
				}
				return GetHitEventName_t3();
			}
			else
			{
				return 'Hit_t3back';
			}
		}
		else if( hitParams.attackType == 'Attack_t4' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{
				if( hitParams.attacker )
				{
					SetChangeStateTimer();
				}
				return 'Hit_t4';
			}
			else
			{
				return 'Hit_t3back';
			}
		}
		
		else if( hitParams.attackType == 'Attack_boss_t1' )
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
			if( isFrontToSource )
			{	
				return 'HeavyHitFront';
			}
			else
			{
				return 'HeavyHitBack';
			}
		}
		else if( hitParams.attackType == 'FistFightAttack_t1' )
		{
			if( isFrontToSource )
			{	
				parent.RaiseForceEvent( 'Hit' );
			}
			else
			{
				return 'HitBack';
			}
		}
	}*/
}
