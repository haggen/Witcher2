/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Combat steel state
/////////////////////////////////////////////

state CombatSteel in CPlayer extends CombatSword
{
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Variables
	
	var behavior : name;
	var attackEventNames : array<name>;
	
	var COMBO_ATTACK_FAST_TYPE : int;
	var COMBO_ATTACK_STRONG_TYPE : int;
	
	default behavior = 'PlayerCombat';
	default COMBO_ATTACK_FAST_TYPE = 0;
	default COMBO_ATTACK_STRONG_TYPE = 1;
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnEnterState()
	{		
		super.OnEnterState();
		LogChannel( 'states', "CombatSteel - OnEnterState" );
		
		//parent.ActivateBehavior( behavior );
		
		attackEventNames.Clear();
		attackEventNames.PushBack('CombatAttackFastBack2a');
		attackEventNames.PushBack('CombatAttackFastBack2b');
		
		parent.SetRequiredItems( 'None', 'steelsword' );
		//set attack blocked animations
		
		//thePlayer.SetCombatHotKeysBlocked( false );
		
		thePlayer.SetIsInShadow( false );
		
		/*if (thePlayer.IsDarkWeaponSteel() && !thePlayer.IsDarkEffect()) 		
		{
			thePlayer.SetDarkEffect( true );
			thePlayer.SetDarkWeaponAddVitality( true );
			if ( !thePlayer.IsNotGeralt() ) theCamera.PlayEffect('dark_difficulty');
		}*/
		
	}
	private function SetCombatCamera()
	{
		//theHud.m_hud.HideTutorial();
		theHud.m_hud.UnlockTutorial();
		theCamera.SetCameraState(CS_Combat);
	}
	
	event OnLeaveState()
	{	
		super.OnLeaveState();		
		LogChannel( 'states', "CombatSteel - OnLeaveState" );
		/*if (thePlayer.IsDarkWeaponSteel() ) 		
		{
			thePlayer.SetDarkEffect( false );
			thePlayer.SetDarkWeaponAddVitality( false );
			if ( !thePlayer.IsNotGeralt() ) theCamera.StopEffect('dark_difficulty');
		}*/
		
	}
		//Funkcja uzywana do obracania Geralta przed rzuceniem Aarda. 
	entry function CombatRotateToPositionSteel(position : Vector)
	{
		parent.RotateTo( position, 0.05f );

		thePlayer.LoopCombatSteel();
	}
	entry function CSTakedown( target : CActor )
	{
		var actors : array < CEntity >;
		var names : array < string >;
		var pos : Vector;
		var rot : EulerAngles;
		
		names.PushBack("witcher");
		names.PushBack("man1");
		
		actors.PushBack( (CEntity)thePlayer );
		actors.PushBack( (CEntity)target );
		
		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		
		parent.SetManualControl( false, false );
		
		theGame.PlayCutscene( "fin_1man_01", names, actors, pos, rot );
		
		parent.SetManualControl( true, true );
	}	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game input event
	
	event OnGameInputEvent( key : name, value : float )
	{
		var attackResult : bool = false;
	
		if ( !parent.HasLatentItemAction() )
		{
			if ( /*!parent.IsActionActive() && */!parent.GetIsCastingAxii() )
			{	
				// If no action is performed, we can check against holstering
				if ( key == 'GI_Holster' || key == 'GI_Steel' && !thePlayer.AreCombatHotKeysBlocked() )
				{
					if( !thePlayer.IsInGuardBlock() && !thePlayer.AreCombatHotKeysBlocked() && value > 0.5 )
					{
						Log( "Deact: " + parent.GetPendingBehaviorDeact() );
						parent.ChangePlayerState( PS_Exploration );	
						return true;
					}
					return false;
				}
				else if ( key == 'GI_Silver' && !thePlayer.AreCombatHotKeysBlocked() )
				{
					if( !thePlayer.IsInGuardBlock() && !thePlayer.AreCombatHotKeysBlocked() && value > 0.5 )
					{
						Log( "Deact: " + parent.GetPendingBehaviorDeact() );
						parent.ChangePlayerState( PS_CombatSilver );	
						return true;
					}
					return false;
				}
			}
			
			attackResult = HandleAttackInput( key, value );
		}
		else
		{
			Log( "Ignored input due to latent item action or player action" );
		}	

		if ( !attackResult )
		{
			// Pass to base class
			return super.OnGameInputEvent( key, value );
		}	
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Handle attack
	
	private function HandleAttackInput(key : name, value : float) : bool
	{
		if(thePlayer.GetIsCastingAxii())
		{
			return false;
		}
		if ( parent.isMovable == false )
		{
			return false;
		}
		if ( HasStateChangeScheduled() )
		{
			return false;
		}
	
		if( parent.IsBlockingHit() )
		{
			if( IsKeyAttackFast( key ) && value > 0.5f )
			{
				if( Riposte() )
				{
					return false;
				}
			}			
		}
	
		if ( IsKeyAttackStrong( key ) && value > 0.5f )
		{
			parent.SetPlayerCombatStance(PCS_High);
			//parent.SetGuardBlock( false, true );
			parent.SetCantBlock(true);
			if(parent.IsAssasinReplacer() && parent.IsNotGeralt())
			{
				AttackStrong();	
			}
			else if(parent.IsNotGeralt() || parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon()).IsWitcherSecondaryWeapon())
			{
				AttackReplacer();
			}
			else
			{
				if(parent.IsOverweight())
				{
					AttackStrongEncumbered();
				}
				else
				{
					AttackStrong();	
				}
			}
		}
		
		else if ( IsKeyAttackFast( key ) && value > 0.5f)
		{
			parent.SetPlayerCombatStance(PCS_High);
			//parent.SetGuardBlock( false, true );
			parent.SetCantBlock(true);
			if(parent.IsAssasinReplacer() && parent.IsNotGeralt())
			{
				AttackFast();
			}
			else if(parent.IsNotGeralt() || parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon()).IsWitcherSecondaryWeapon())
			{
				parent.IsOverweight();
				AttackReplacer();
			}
			else
			{
				if(parent.IsOverweight())
				{
					AttackFastEncumbered();
				}
				else
				{
					AttackFast();
				}
			}			
		}
		
		// no attack
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Attacks
	
	private function MoveToEnemy( enemy : CActor )
	{		
		var target, vecToTarget : Vector;
		var heading : float;
		
		target = enemy.GetWorldPosition();
		
		// Sub small delta beacuse of collision
		//...
			
		vecToTarget = target - parent.GetWorldPosition();
		vecToTarget.Z = 0.0;
		
		heading = Rad2Deg( AtanF( vecToTarget.Y, vecToTarget.X ) ) - 90.0f;
			
		//if ( CanJumpTo( target,heading ) )
		//{
		//...
		//}
	}
	
	entry function AttackReplacer()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var enemyNPC : CNewNPC;
		var weaponId : SItemUniqueId;
		
		parent.ProcessRequiredItems();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		if ( !parent.HasLatentItemAction() )
		{
			if( IsSelectionAllowed() )
			{
				// Reset enemy
				ResetEnemy();
			
				// Find enemy
				enemy = FindEnemy();			
			}
			
			if ( enemy )
			{
				enemy.OnBeforeAttack();
					
				// Cache enemy
				CacheEnemy( enemy );
				//enemy.SetLastAttackedByPlayer(true);						
				// Attack
				FactsAdd("Geralt performs a fast attack");
									
				parent.ComboAttackReplacer(parent.GetReplacerAttackType());
			}
			else
			{
				parent.ComboAttackReplacer(parent.GetReplacerAttackType());
				
				// Back to combat loop
				LoopCombatSteel();
			}
		}
	
		// Back to combat loop
		LoopCombatSteel();
	}
	entry function AttackFastEncumbered()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var enemyNPC : CNewNPC;
		var weaponId : SItemUniqueId;
		
		parent.ProcessRequiredItems();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		if ( !parent.HasLatentItemAction() )
		{
			if( IsSelectionAllowed() )
			{
				// Reset enemy
				ResetEnemy();
			
				// Find enemy
				enemy = FindEnemy();			
			}
			
			if ( enemy )
			{
				enemy.OnBeforeAttack();
				//enemy.SetLastAttackedByPlayer(true);	
				// Cache enemy
				CacheEnemy( enemy );
										
				// Attack
				FactsAdd("Geralt performs a fast attack");
									
				parent.ComboAttackReplacer(RAT_OneHanded);
			}
			else
			{
				parent.ComboAttackReplacer(RAT_OneHanded);
				
				// Back to combat loop
				LoopCombatSteel();
			}
		}
	
		// Back to combat loop
		LoopCombatSteel();
	}
	entry function AttackStrongEncumbered()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var enemyNPC : CNewNPC;
		var weaponId : SItemUniqueId;
		
		parent.ProcessRequiredItems();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		if ( !parent.HasLatentItemAction() )
		{
			if( IsSelectionAllowed() )
			{
				// Reset enemy
				ResetEnemy();
			
				// Find enemy
				enemy = FindEnemy();			
			}
			
			if ( enemy )
			{
				enemy.OnBeforeAttack();
					
				// Cache enemy
				CacheEnemy( enemy );
				//enemy.SetLastAttackedByPlayer(true);						
				// Attack
				FactsAdd("Geralt performs a fast attack");
									
				parent.ComboAttackReplacer(RAT_TwoHanded);
			}
			else
			{
				parent.ComboAttackReplacer(RAT_TwoHanded);
				
				// Back to combat loop
				LoopCombatSteel();
			}
		}
	
		// Back to combat loop
		LoopCombatSteel();
	}
	entry function AttackFast()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var enemyNPC : CNewNPC;
		var weaponId : SItemUniqueId;
		
		parent.ProcessRequiredItems();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		
		if ( !parent.HasLatentItemAction() )
		{
			if( IsSelectionAllowed() )
			{
				// Reset enemy
				ResetEnemy();
			
				// Find enemy
				enemy = FindEnemy();			
			}
			
			if ( enemy )
			{
				enemy.OnBeforeAttack();
				//enemy.SetLastAttackedByPlayer(true);	
				// Cache enemy
				CacheEnemy( enemy );
					
				TryStartTakedown(enemy);
				
				// Attack dir
				attackDir = GetAttackDirection();
			
				// Attack
				FactsAdd("Geralt performs a fast attack");
									
				attackDist = GetAttackDistance();
				
				if ( ComboAttackFast( attackDir, attackDist ) )
				{
					parent.RegisterActiveAction( 'AttackEnd' );
				}
			}
			else
			{
				if ( ComboAttackFast( AD_Front, ADIST_Small ) )
				{
					parent.RegisterActiveAction( 'AttackEnd' );
				}
				
				// Back to combat loop
				LoopCombatSteel();
			}
		}
		
		// Back to combat loop
		LoopCombatSteel();
	}
	
	function GetAttackDistance() : EAttackDistance
	{
		var distToEnemy : float;
		
		distToEnemy = GetDistanceToEnemy();
		
		if ( distToEnemy <= 2.0f || distToEnemy > 10.0)
		{
			return ADIST_Small;
		}
		else if( distToEnemy > 2.0f && distToEnemy < 4.0f )
		{
			return ADIST_Medium;
		}
		else
		{
			return ADIST_Large;
		}
	}
	
	private function ComboAttackFast( attackDir : EAttackDirection, attackDist : EAttackDistance ) : bool
	{
		if( IsEnemyNeutral() )
		{
			return parent.ComboAttack( COMBO_ATTACK_FAST_TYPE, AD_Front, ADIST_Small );
		}
		else
		{
			return parent.ComboAttack( COMBO_ATTACK_FAST_TYPE, attackDir, attackDist );
		}
	}
	function GetBackAttackEventName() : name
	{
		var s : int;
		s = attackEventNames.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return attackEventNames[Rand(s)];
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////
	
	entry function AttackStrong()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackDist : EAttackDistance;
		var enemyNPC : CNewNPC;
		var weaponId : SItemUniqueId;
		
		parent.ProcessRequiredItems();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		
		if ( !parent.HasLatentItemAction() )
		{
			if( IsSelectionAllowed() )
			{
				// Reset enemy
				ResetEnemy();
			
				// Find enemy
				enemy = FindEnemy();			
			}
			
			if ( enemy )
			{
				enemy.OnBeforeAttack();
				//enemy.SetLastAttackedByPlayer(true);			
				// Cache enemy
				CacheEnemy( enemy );
					
				TryStartTakedown(enemy);
				
				// Attack dir
				attackDir = GetAttackDirection();
			
				// Attack
				FactsAdd("Geralt performs a fast attack");
									
				attackDist = GetAttackDistance();
				if ( ComboAttackStrong( attackDir, attackDist ) )
				{
					parent.RegisterActiveAction( 'AttackEnd' );
				}
			}
			else
			{
				if ( ComboAttackStrong( AD_Front, ADIST_Small ) )
				{
					parent.RegisterActiveAction( 'AttackEnd' );
				}
				
				// Back to combat loop
				LoopCombatSteel();
			}	
		}
		
		// Back to combat loop
		LoopCombatSteel();
	}
	
	private function ComboAttackStrong( attackDir : EAttackDirection, attackDist : EAttackDistance ) : bool
	{
		if( IsEnemyNeutral() )
		{
			return parent.ComboAttack( COMBO_ATTACK_STRONG_TYPE, AD_Front, ADIST_Small );
		}
		else
		{
			return parent.ComboAttack( COMBO_ATTACK_STRONG_TYPE, attackDir, attackDist );
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////

	private function Finisher() : bool
	{
		var enemy : CActor;

		if( IsSelectionAllowed() )
		{
			// Reset enemy
			ResetEnemy();
		
			// Find enemy
			enemy = FindEnemy();			
		}
		
		if ( enemy && parent.IsFinisherEnabled( enemy ) )
		{
			return parent.DoFinisher( enemy );
		}
		
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	private function PlayHit( hitParams : HitParams )
	{
		if(thePlayer.CanPlayHitAnim(hitParams))
		{
			PlayHitSteel( hitParams );
		}
		else
		{
			theSound.PlaySoundOnActor(thePlayer, '', "witcher/damage/damage_hits/anim_body_hit_sword");
		}
	}
	
	entry function PlayHitSteel( hitParams : HitParams )
	{
		var hitEnum : EPlayerCombatHit;
		var raiseEvent : bool;
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		var weaponId : SItemUniqueId;
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSteelSword();
		}
		// Choose hit event. Use default funtion.
		hitEnum = parent.ChooseHitEnum( hitParams );
		
		if(hitEnum != PCH_None)
		{
			if( hitParams.forceHitEvent )
			{
				parent.PlayerCombatHitForced(hitEnum);
			}
			else
			{
				// Raise hit event
				parent.PlayerCombatHit(hitEnum);
			}
		}
		raiseEvent;
		
		// Wait for idle state
		Sleep(0.1);
		parent.SetPlayerCombatStance(PCS_High);
		parent.WaitForBehaviorNodeDeactivation( 'CombatHitEnd' );
		
		// Go back to combat
		LoopCombatSteel();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter combat function
	
	entry function EntryCombatSteel( oldPlayerState : EPlayerState, behStateName : string )
	{
		Log( "Combat Steel start!" );
		
		// this function can't be interrupted, as it activates a key behavior it simply needs to activate
		parent.LockEntryFunction( true );
		
		parent.ActivateAndSyncBehaviorWithItemsSequence( behavior );
				
		if( oldPlayerState != PS_CombatTakedown )
		{
			SetCombatCamera();
		}
		
		parent.LockEntryFunction( false );

		// Go to combat loop
		LoopCombatSteel();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat loop function
	
	private latent function CombatLogic()
	{
		super.CombatLogic();
	}
	
	entry function LoopCombatSteel()
	{
		while( true )
		{
			CombatLogic();
			Sleep( 0.1 );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Exit combat function
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		ExitCombatSteel( newState );
	}

	entry function ExitCombatSteel( newState : EPlayerState )
	{
		var behStateName : string;
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		if( (newState != PS_Cutscene) && (newState != PS_Scene) && (newState != PS_CombatTakedown) && ( newState != PS_CombatFistfightStatic ) && (newState != PS_AimedThrow))
		{		
			parent.SetBlockingHit(false);
		}
		
		if( newState == PS_CombatTakedown )
		{
			parent.TakedownActor( oldState, takedownParams );
		}
		else
		{
			parent.PlayerStateCallEntryFunction( newState, behStateName );
		}
	}
}
