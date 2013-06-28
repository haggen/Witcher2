/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Combat Silver state
/////////////////////////////////////////////

state CombatSilver in CPlayer extends CombatSword
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
		LogChannel( 'states', "CombatSilver - OnEnterState" );
		
		//parent.ActivateBehavior( behavior );
		
		parent.SetRequiredItems( 'None', 'silversword' );
		//thePlayer.GetInventory().MountItem( GetBestSteelSword() );
		
		attackEventNames.Clear();
		attackEventNames.PushBack('CombatAttackFastBack2a');
		attackEventNames.PushBack('CombatAttackFastBack2b');

		//thePlayer.SetCombatHotKeysBlocked( false );

		thePlayer.SetIsInShadow( false );
		
		/*if (thePlayer.IsDarkWeaponSilver() ) 		
		{
			thePlayer.SetDarkEffect( true );
			thePlayer.SetDarkWeaponAddVitality( true );
			if ( !thePlayer.IsNotGeralt() ) theCamera.PlayEffect('dark_difficulty');
		}*/
		
	}
	
	private function SetCombatCamera()
	{
		theCamera.SetCameraState(CS_Combat);
	}
	
	event OnLeaveState()
	{	
		super.OnLeaveState();	
		LogChannel( 'states', "CombatSilver - OnLeaveState" );	
		
		/*if (thePlayer.IsDarkWeaponSilver() ) 		
		{
			thePlayer.SetDarkEffect( false );
			thePlayer.SetDarkWeaponAddVitality( false );
			if ( !thePlayer.IsNotGeralt() ) theCamera.StopEffect('dark_difficulty');
		}*/
		
	}
	//Funkcja uzywana do obracania Geralta przed rzuceniem Aarda. 
	entry function CombatRotateToPositionSilver(position : Vector)
	{
		parent.RotateTo( position, 0.05f );

		thePlayer.LoopCombatSilver();
		
	}
	latent final function DrawSilverSwordLatent()
	{
		var weaponUid : SItemUniqueId;
		var res : bool;
		weaponUid = parent.GetInventory().GetItemByCategory('silversword', true);
		
		if ( weaponUid != GetInvalidUniqueId() )
		{
			if( parent.GetCurrentWeapon() != weaponUid )
			{
				res = parent.DrawWeaponLatent( weaponUid );
				if ( !res )
				{
					Log("ERROR in DrawSilverSwordLatent");
				}
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game input event
	
	event OnGameInputEvent( key : name, value : float )
	{
		var attackResult : bool = false;
	
		if ( !parent.HasLatentItemAction() )
		{
			if ( /*!parent.IsActionActive() &&*/ !parent.GetIsCastingAxii() )
			{
				// If no action is performed, we can check against holstering
				if ( key == 'GI_Holster' || key == 'GI_Silver' && !thePlayer.AreCombatHotKeysBlocked() )
				{
					if( !thePlayer.IsInGuardBlock() && !thePlayer.AreCombatHotKeysBlocked() && value > 0.5 )
					{
						Log( "Deact: " + parent.GetPendingBehaviorDeact() );
						parent.ChangePlayerState( PS_Exploration );	
						return true;
					}
					return false;
				}
				else if ( key == 'GI_Steel' && !thePlayer.AreCombatHotKeysBlocked() )
				{
					if( !thePlayer.IsInGuardBlock() && !thePlayer.AreCombatHotKeysBlocked() && value > 0.5 )
					{
						Log( "Deact: " + parent.GetPendingBehaviorDeact() );
						parent.ChangePlayerState( PS_CombatSteel );	
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
				AttackStrongSilver();
			}
			else if(parent.IsNotGeralt() || parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon()).IsWitcherSecondaryWeapon())
			{
				parent.IsOverweight();
				AttackReplacerSilver();
			}
			else
			{
				if(parent.IsOverweight())
				{
					AttackStrongSilverEncumbered();
				}
				else
				{
					AttackStrongSilver();
				}
			}
		}
		
		else if ( IsKeyAttackFast( key ) && value > 0.5f )
		{
			parent.SetPlayerCombatStance(PCS_High);
			//parent.SetGuardBlock( false, true );
			parent.SetCantBlock(true);
			if(parent.IsAssasinReplacer() && parent.IsNotGeralt())
			{
				AttackFastSilver();
			}
			else if(parent.IsNotGeralt() || parent.GetInventory().GetItemEntityUnsafe(parent.GetCurrentWeapon()).IsWitcherSecondaryWeapon())
			{
				AttackReplacerSilver();
			}
			else
			{
				if(parent.IsOverweight())
				{
					AttackFastSilverEncumbered();
				}
				else
				{
					AttackFastSilver();
				}
			}			
		}
		
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Attacks
	
	private function MoveToEnemy( enemy : CActor )
	{		
		var target, vecToTarget : Vector;
		var heading : float;
		
		target = enemy.GetWorldPosition();
			
		vecToTarget = target - parent.GetWorldPosition();
		vecToTarget.Z = 0.0;
		
		heading = Rad2Deg( AtanF( vecToTarget.Y, vecToTarget.X ) ) - 90.0f;
	}
	
	private entry function AttackReplacerSilver()
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
				LoopCombatSilver();
			}
		}
		
		// Back to combat loop
		LoopCombatSilver();
	}
	private entry function AttackStrongSilverEncumbered()
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
									
				parent.ComboAttackReplacer(RAT_TwoHanded);
			}
			else
			{
				parent.ComboAttackReplacer(RAT_TwoHanded);
				
				// Back to combat loop
				LoopCombatSilver();
			}
		}
		
		// Back to combat loop
		LoopCombatSilver();
	}
	private entry function AttackFastSilverEncumbered()
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
				LoopCombatSilver();
			}
		}
		
		// Back to combat loop
		LoopCombatSilver();
	}
	entry function AttackFastSilver()
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
			DrawSilverSword();
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
				LoopCombatSilver();
			}
		}

		
		// Back to combat loop
		LoopCombatSilver();
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
	
		entry function AttackStrongSilver()
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
			DrawSilverSword();
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
				LoopCombatSilver();
			}
		}

		
		// Back to combat loop
		LoopCombatSilver();
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
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	private function PlayHit( hitParams : HitParams )
	{
		if(thePlayer.CanPlayHitAnim(hitParams))
		{
			PlayHitSilver( hitParams );
		}
		else
		{
			theSound.PlaySoundOnActor(thePlayer, '', "witcher/damage/damage_hits/anim_body_hit_sword");
		}
	}
	
	entry function PlayHitSilver( hitParams : HitParams )
	{
		var hitEnum : EPlayerCombatHit;
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie Geralt walczy bez broni.
		var weaponId : SItemUniqueId;
		weaponId = thePlayer.GetCurrentWeapon(CH_Right);
		if(weaponId == GetInvalidUniqueId())
		{
			DrawSilverSword();
		}
		// Choose hit event. Use default funtion.
		hitEnum = parent.ChooseHitEnum( hitParams );
		
		// Raise hit event
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
		
		// Wait for idle state
		Sleep(0.1);
		parent.SetPlayerCombatStance(PCS_High);
		parent.WaitForBehaviorNodeDeactivation( 'CombatHitEnd' );
		
		// Go back to combat
		LoopCombatSilver();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter combat function
	
	entry function EntryCombatSilver( oldPlayerState : EPlayerState, behStateName : string )
	{
		Log( "Combat Silver start!" );
		
		// this function can't be interrupted, as it activates a key behavior it simply needs to activate
		parent.LockEntryFunction( true );
		
		parent.ActivateAndSyncBehaviorWithItemsSequence( behavior );
		
		if( oldPlayerState != PS_CombatTakedown )
		{
			SetCombatCamera();
		}
		
		parent.LockEntryFunction( false );

		// Go to combat loop
		LoopCombatSilver();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat loop function
	
	private latent function CombatLogic()
	{
		super.CombatLogic();
	}
	
	entry function LoopCombatSilver()
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
		ExitCombatSilver( newState );
	}

	entry function ExitCombatSilver( newState : EPlayerState )
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
