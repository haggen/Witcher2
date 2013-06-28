/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Combat fistfight state
/////////////////////////////////////////////
class CDynamicFFArea extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		
		activatorActor = (CActor) activator.GetEntity();
		
		if( activatorActor == thePlayer)
		{
			thePlayer.SetIsInDynamicFFArea(true);
		}
	}	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		
		activatorActor = (CActor) activator.GetEntity();
		if( activatorActor == thePlayer)
		{
			thePlayer.SetIsInDynamicFFArea(false);
		}
	}
}


function UseStaticFistfight() : bool
{
	return true;
}

function UseFistfightTakedowns() : bool
{
	return false;
}

enum W2PlayerComboEventType
{
	PCET_AttackFast,
	PCET_AttackStrong,
	PCET_Takedown,
};

struct W2PlayerComboEvent
{
	var type : W2PlayerComboEventType;
	var time : EngineTime;
	var enemy : CActor;
}

state CombatFistfightDynamic in CPlayer extends Combat
{
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Variables
	
	private var behavior : name;
	private var normalCombatRadius : float;
	private var comboEventArray : array< W2PlayerComboEvent >;
	private var COMBO_EVENT_ARRAY_SIZE : int;
	private var takedownNpc : CNewNPC;
	private var takedownPrefix : name;
	private var qteActionInProgress : bool;

	default behavior = 'PlayerFistfight';
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	

	event OnEnterState()
	{		
		var id : SItemUniqueId;
		super.OnEnterState();
		thePlayer.SetAdrenaline(0.0f);
		if(!parent.GetFFLootEnabled())
		{
			theGame.EnableButtonInteractions( false );
		}
		normalCombatRadius = parent.GetMovingAgentComponent().GetCombatWalkAroundRadius();
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( 0.6 );
		
	
		if( parent.GetCurrentWeapon() != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponInstant( parent.GetCurrentWeapon() );
		}
		
		id = parent.GetInventory().GetFirstNonLethalWeaponId();			
		if ( id == GetInvalidUniqueId() ) Log("WARNING!: Witcher Bare Fists item was not found! Fistfight will not work!");
		parent.DrawWeaponInstant( id );
		
		theCamera.SetCameraState(CS_Combat);
		
		COMBO_EVENT_ARRAY_SIZE = 3;		
		qteActionInProgress = false;
	}
	
	event OnLeaveState()
	{
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( normalCombatRadius );
		super.OnLeaveState();
		parent.HolsterWeaponInstant( parent.GetCurrentWeapon() );
		
		theGame.EnableButtonInteractions( true );
		//parent.PopBehavior( behavior );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var damage : float;
		if( animEventName == 'FF_Hit' )
		{			
			damage = 20;
			damage = MinF( parent.GetHealth() - 5, damage );
			parent.DecreaseHealth( damage, false, parent );		
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	//Funkcja uzywana do obracania Geralta przed rzuceniem Aarda. 
	entry function CombatRotateToPositionFF(position : Vector)
	{
		parent.RotateTo( position, 0.05f );

		thePlayer.LoopCombatFistfight();
		
	}
	private function AttackRangeTest( target : CActor ) : bool
	{
		var posPlayer : Vector = parent.GetWorldPosition();
		var posTarget : Vector = target.GetWorldPosition();
		if( VecDistance2D( posPlayer, posTarget ) < 1.5 )
		{
			if( ( posPlayer.Z > posTarget.Z - 1.0 ) && ( posPlayer.Z < posTarget.Z + 3.0 ) )
			{
				if( parent.IsRotatedTowardsPoint( posTarget, 45 ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function RememberFistfightEvent( type : W2PlayerComboEventType )
	{
		while( comboEventArray.Size() >= COMBO_EVENT_ARRAY_SIZE )
		{
			comboEventArray.Erase( 0 );
		}
		
		comboEventArray.PushBack( W2PlayerComboEvent( type, theGame.GetEngineTime(), enemy ) );
	}
	
	function CheckComboEventTypes( type : W2PlayerComboEventType, count : int ) : bool
	{
		var i : int;
		var s : int = comboEventArray.Size();	
		if( s < count )
			return false;
			
		for( i=s-count; i<s; i+=1 )
		{
			if( comboEventArray[i].type != type )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function CheckComboEventEnemy( enemy : CActor, count : int ) : bool
	{
		var i : int;
		var s : int = comboEventArray.Size();
		if( s < count )
			return false;
			
		for( i=s-count; i<s; i+=1 )
		{
			if( comboEventArray[i].enemy != enemy )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function CheckPlayerComboEvents()
	{
		var size : int = comboEventArray.Size();
		var currentEnemy : CActor = this.GetEnemy();
		
		if( !UseFistfightTakedowns() )
		{
			return;
		}
		
		if( currentEnemy.IsBlockingHit() )
		{
			if( VecDistance( currentEnemy.GetWorldPosition(), parent.GetWorldPosition() ) < 2.5 )
			{
				RememberFistfightEvent( PCET_Takedown );
				TryStartNoQTEAction( 'ff_2e' );
			}
		}
		
		if( size > 0 )
		{
			if( VecDistance( currentEnemy.GetWorldPosition(), parent.GetWorldPosition() ) < 2.5 )
			{
				if( comboEventArray[size-1].enemy != currentEnemy && comboEventArray[size-1].type != PCET_Takedown )
				{
					RememberFistfightEvent( PCET_Takedown );
					TryStartNoQTEAction( 'ff_8w' );
				}
			}
		}
	
		if( size >= 3 && comboEventArray[0].time > theGame.GetEngineTime() - 5 )
		{
			if( CheckComboEventEnemy( enemy, 3 ) )
			{
				if( CheckComboEventTypes( PCET_AttackFast, 3 ) )
				{					
					RememberFistfightEvent( PCET_Takedown );					

					/*if( enemy && enemy.GetHealthPercentage() > 50.0 )
					{					
						TryStartNoQTEAction( 'ff_8w' );
					}
					else*/
					{					
						if( Rand(2) == 0 )
							TryStartQTEAction( 'ff_2e' );
						else
							TryStartQTEAction( 'ff_8w' );
					}
					
					return;
				}
			}
		}	
	}
	
	event OnQTESuccess( resultData : SQTEResultData )
	{
		parent.ClearCleanupFunction();
		ContinueQTEAction( takedownNpc, true, takedownPrefix );
	}

	event OnQTEFailure( resultData : SQTEResultData )
	{	
		//ContinueQTEAction( takedownNpc, false );
	}
	
	
	private latent function LockNPC( npc : CNewNPC ) : bool
	{
		var res : bool;
		res = NPCEnterTakedown( npc );
		if( !res )
			return false;
		
		npc.StateTakedownFistfight();
		npc.EnablePathEngineAgent( false );
		npc.RaiseForceEvent('Idle');
		
		return true;
	}
	
	private function UnlockNPC( npc : CNewNPC )
	{	
		if( npc.GetHealth() > 0 )
		{
			npc.EnablePathEngineAgent( true );
			npc.StateTakedownFistfightEnd(0.5);			
		}
	}
	
	private function TryStartQTEAction( prefix : name )
	{
		var enemyNPC : CNewNPC = GetEnemyNPC();
		if( enemyNPC )
		{
			//if( FreeSpaceTest( enemyNPC ) )
			//{
				takedownNpc = enemyNPC;
				takedownPrefix = prefix;
				StartQTEAction( takedownNpc, prefix );			
			//}
		}
	}
	
	private function TryStartNoQTEAction( prefix : name )
	{
		var enemyNPC : CNewNPC = GetEnemyNPC();
		if( enemyNPC )
		{
			//if( FreeSpaceTest( enemyNPC ) )
			//{
				takedownNpc = enemyNPC;
				takedownPrefix = prefix;
				StartNoQTEAction( takedownNpc, prefix );
			//}
		}
	}
	
	private cleanup function ActionCleanup()
	{
		UnlockNPC( takedownNpc );
		qteActionInProgress = false;
		parent.DetachBehavior('fistfight_takedown');
		parent.SetBlockingHit( false );
	}
		
	private entry function StartQTEAction( npc : CNewNPC, prefix : name )
	{
		var res1, res2, lockRes : bool;
		var anim : name;
		var qteTime : float = 1.0f;
		var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
		
		parent.SetCleanupFunction( 'ActionCleanup' );
		
		lockRes = LockNPC( npc );
		if( !lockRes )
		{
			return;
		}
		
		anim = StringToName( prefix + "_warning" );
		
		qteActionInProgress = true;
		parent.SetBlockingHit( true );		
		
		parent.RaiseForceEvent('Idle');
		parent.AttachBehavior('fistfight_takedown');		
		
		parent.WarpToAnimSlotPosition( npc, anim, 0.2f );
		qteStartInfo.action = 'QTE2';
		qteStartInfo.timeOut = qteTime;
		qteStartInfo.ignoreWrongInput = true;
		parent.StartSinglePressQTEAsync( qteStartInfo );
		
		res1 = parent.RaiseEvent( anim );
		res2 = npc.RaiseEvent( anim );
		
		if( !(res1 && res2) )
		{
			LogChannelf( 'AI', "ERROR: StartQTEAction res1: %1, res2 %2", res1, res2 );
		}
		
		Sleep( qteTime );
		
		ContinueQTEAction( npc, false, prefix );
	}
		
	private entry function ContinueQTEAction( npc : CNewNPC, counter : bool, prefix : name )
	{
		var res1, res2 : bool;
		var anim : name;

		parent.SetCleanupFunction( 'ActionCleanup' );		
		
		if( StrFindFirst( prefix, "w" ) >= 0 )
		{
			if( counter )
				anim = StringToName( prefix + "_recounter" );
			else
				anim = StringToName( prefix + "_counter" );			
		}
		else
		{		
			if( counter )
				anim = StringToName( prefix + "_counter" );
			else
				anim = StringToName( prefix + "_attack" );
		}
		
		parent.WarpToAnimSlotPosition( npc, anim, 0.0f );
		
		res1 = parent.RaiseEvent( anim );
		res2 = npc.RaiseEvent( anim );
		
		if( !(res1 && res2) )
		{
			LogChannelf( 'AI', "ERROR: ContinueQTEAction res1: %1, res2 %2", res1, res2 );
		}
		
		parent.WaitForBehaviorNodeActivation( 'FistfightTakedownIdle' );
		
		ActionCleanup();
	}
			
	private entry function StartNoQTEAction( npc : CNewNPC, prefix : name )
	{
		var res1, res2, lockRes : bool;
		var anim : name;
		
		parent.SetCleanupFunction( 'ActionCleanup' );
		
		lockRes = LockNPC( npc );
		if( !lockRes )
		{
			return;
		}

		qteActionInProgress = true;
		parent.SetBlockingHit( true );
		
		anim = StringToName( prefix + "_attack" );
		
		parent.RaiseForceEvent('Idle');
		parent.AttachBehavior('fistfight_takedown');	
		
		parent.WarpToAnimSlotPosition( npc, anim, 0.2f );
		
		res1 = parent.RaiseEvent( anim );
		res2 = npc.RaiseEvent( anim );
		
		if( !(res1 && res2) )
		{
			LogChannelf( 'AI', "ERROR: ContinueQTEAction res1: %1, res2 %2", res1, res2 );
		}
		
		parent.WaitForBehaviorNodeActivation( 'FistfightTakedownIdle' );
		Sleep(0.2);
		ActionCleanup();
	}
		
	/*private function FreeSpaceTest( npc : CActor ) : bool
	{
		var mac : CMovingAgentComponent = npc.GetMovingAgentComponent();
		var params : SPathEngineEmptySpaceQuery;
		var pos, dir : Vector;
		var yaw, res : float;
		var rot : EulerAngles;
		
		dir = npc.GetWorldPosition() - parent.GetWorldPosition();
		dir.Z = 0.0f;
		rot = VecToRotation( dir );
		
		params.width = 1.5f;
		params.height = 3.5f;		
		params.yaw = rot.Yaw;
		params.searchRadius = 2.0f;
		params.localSearchRadius = 1.0f;		
		params.maxPathLen = 2.0f;
		params.maxCenterLevelDifference = 1.0f;
		params.maxAreaLevelDifference = 0.5f;
		params.numTests = 0;
		params.checkObstaclesLevel = PEESC_SceneObstacles;
		params.useAwayMethod = true;
		params.debug = true;
	
		res = mac.FindEmptySpace( params, pos, yaw );
		
		if( res > 0.9*params.width )
		{
			if( VecDistance2D( npc.GetWorldPosition(), pos ) < 0.1 )
			{
				return true;
			}
		}
		
		return false;
	}*/
	
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game input event
	
	event OnGameInputEvent( key : name, value : float )
	{
		var attackResult : bool;
		
		attackResult = HandleAttackInput( key, value );
		
		if ( key == 'PlayerChangeStateFists' )
		{
			if( value > 0.5 )
			{
				parent.ChangePlayerState( PS_Exploration );
				return true;
			}
			return false;
		}
		
		if( attackResult )
		{
			return true;
		}
		
		return super.OnGameInputEvent( key, value );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Handle attack
	
	private function HandleAttackInput(key : name, value : float) : bool
	{	
		if(thePlayer.GetIsCastingAxii())
		{
			return false;
		}
		if( qteActionInProgress )
		{
			return true;
		}
		if ( HasStateChangeScheduled() )
		{
			return false;
		}
		
		if ( IsKeyAttackStrong( key ) && value > 0.5f )
		{			
			AttackFistStrong();
			parent.SetFistFightCooldown();
		}
		else if ( IsKeyAttackFast( key ) && value > 0.5f )
		{
			AttackFistFast();
			parent.SetFistFightCooldown();
		}
		
		else if ( key == 'GI_Accept_Evade' && value > 0.5f && !thePlayer.isNotGeralt )
		{
			//parent.RaiseForceEvent ( 'Evade' );
		}
		else if ( key == 'GI_Hotkey00' && value > 0.5f )
		{
			parent.ChangePlayerState( PS_Exploration );
		}
		else
		{
			// no attack
			return false;
		}
		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	entry function AttackFistFast()
	{
		var enemy : CActor;
		var attackDir : EAttackDirection;
		var attackEvent : name;

		parent.SetFistFightCooldown();
		if( IsSelectionAllowed() )
		{
			// Reset enemy
			ResetEnemy();
			
			// Find enemy
			enemy = FindEnemy();
		}
				
		if ( enemy )
		{
			// Cache enemy
			CacheEnemy( enemy );
			
			//enemy.SetLastAttackedByPlayer(true);
			
			CheckPlayerComboEvents();
						
			// Attack dir
			attackDir = GetAttackDirection();
		
			// Choose attack
			attackEvent = ChooseFastAttackEvent( attackDir, GetDistanceToEnemy() );
		
			// Move to enemy
			//MoveToEnemy( enemy );
		
			// Attack
			FactsAdd("Geralt performs a fast attack");
			parent.RaiseEvent( attackEvent );

			// Wait
			parent.WaitForBehaviorNodeDeactivation( 'attack_finished' );
	
			// Freeze movement
			//FreezeMovement();
			//parent.AddTimer( 'Freeze', 2.5f, true );
			
			parent.BreakQTE();
			RememberFistfightEvent( PCET_AttackFast );			
		}
		else
		{
			// Attack
			parent.RaiseEvent( ChooseFastAttackEvent( AD_Front, 2.1f ) );
			
			// Wait
			parent.WaitForBehaviorNodeDeactivation( 'attack_finished' );
			
			// Back to combat loop
			LoopCombatFistfight();
			
		}
		
		// Back to combat loop
		LoopCombatFistfight();
	}
	
	private function ChooseFastAttackEvent( attackDir : EAttackDirection, attackDist : float ) : name
	{	

		return 'FistFightFast';
	}
	event OnBeingHit(out hitParams : HitParams)
	{
		var quenDamage : float;
		if(!parent.GetIsInDynamicFFArea())
		{
			hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + 7.0;
		}
		if( parent.activeQuenSign )
		{
			//przeniesione do quena
			//theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "cl_quen" ) );	
			quenDamage = hitParams.attacker.GetCharacterStats().ComputeDamageOutputPhysical(false);
			parent.activeQuenSign.QuenHit(quenDamage, hitParams);
			//hitParams.damage = 0;
			return false;

		}	
		return parent.OnBeingHit(hitParams);
	}
	entry function AttackFistStrong()
	{
		var enemy : CActor;		
		var attackDir : EAttackDirection;
		var attackEvent : name;

		parent.SetFistFightCooldown();
		if( IsSelectionAllowed() )
		{
			// Reset enemy
			ResetEnemy();
			
			// Find enemy
			enemy = FindEnemy();
		}
		
		if ( enemy )
		{
			// Cache enemy
			CacheEnemy( enemy );
			
			//enemy.SetLastAttackedByPlayer(true);
			
			CheckPlayerComboEvents();
			
			enemy.RaiseForceEvent ( 'bc_head_f_s');
		
			// Attack dir
			attackDir = GetAttackDirection();
		
			// Choose attack
			attackEvent = ChooseStrongAttackEvent( attackDir, GetDistanceToEnemy() );
		
			// Move to enemy
			//MoveToEnemy( enemy );
		
			// Attack
			FactsAdd("Geralt performs a fast attack");
			parent.RaiseEvent( attackEvent );
				
			// Wait
			parent.WaitForBehaviorNodeDeactivation( 'attack_finished' );
	
			// Freeze movement
			//FreezeMovement();
			//parent.AddTimer( 'Freeze', 2.5f, true );

			parent.BreakQTE();
			RememberFistfightEvent( PCET_AttackStrong );			
		}
		else
		{
			// Attack
			parent.RaiseEvent( ChooseStrongAttackEvent( AD_Front, 2.1f ) );
			
			// Wait
			parent.WaitForBehaviorNodeDeactivation( 'attack_finished' );
			
			// Back to combat loop
			LoopCombatFistfight();
			
		}

		// Back to combat loop
		LoopCombatFistfight();
	}
	
	private function ChooseStrongAttackEvent( attackDir : EAttackDirection, attackDist : float ) : name
	{	
		return 'FistFightStrong';

	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	private function PlayHit( hitParams : HitParams )
	{
		PlayHitFistfight( hitParams );
	}
	
	entry function PlayHitFistfight( hitParams : HitParams )
	{
		var hitEvent : name;
		
		// Choose hit event. Use default funtion.
		hitEvent = ChooseHitEvent( hitParams );
		
		// Raise hit event
		parent.RaiseForceEvent( hitEvent );
		
		// Wait for idle state
		parent.WaitForBehaviorNodeActivation( 'Idle' );
		
		// Go back to combat
		LoopCombatFistfight();
	}
	
	private function ChooseHitEvent( hitParams : HitParams ) : name
	{
		var isFrontToSource : bool;
		
		isFrontToSource = parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 );
		
		return 'Hit';
	}
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter combat function
	
	entry function EntryCombatFistfight( oldPlayerState : EPlayerState, behStateName : string )
	{
		Log( "Combat Fistfight start!" );
		
		// this function can't be interrupted, as it activates a key behavior it simply needs to activate
		parent.LockEntryFunction( true );
		
		parent.SetFistFightCooldown();
		parent.SetRequiredItems( 'None', 'None' );
		// Push combat behavior
		parent.ActivateAndSyncBehavior( behavior );
		
		//parent.LockEntryFunction(true);
		//parent.SetAllPlayerStatesBlocked( true );		
		Sleep(0.1);
		//parent.RaiseForceEvent( 'ToFistFight' );
		//parent.WaitForBehaviorNodeDeactivation( 'ToFistFightEnd' );
		//parent.SetAllPlayerStatesBlocked( false );
		//parent.LockEntryFunction(false);
		
		// Update movment
		ProcessMovement( 0 );
		
		parent.LockEntryFunction( false );

		// Go to combat loop
		LoopCombatFistfight();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat loop function
	
	private latent function CombatLogic()
	{
		super.CombatLogic();
	}
	
	entry function LoopCombatFistfight()
	{
		while( true )
		{
			CombatLogic();
			Sleep( 0.1 );
			if(requestExplorationState)
			{
				requestExplorationState = false;
				//parent.SetBehaviorVariable("ToExploration", 1.0);
				//Sleep(1.0);
				
				parent.ChangePlayerState(PS_Exploration);

			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Exit combat function
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		ExitCombatFistfight( newState );
	}
	
	entry function ExitCombatFistfight( newState : EPlayerState )
	{
		var behStateName : string;
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		// Get last behavior state name
		//behStateName = parent.GetCurrentBehaviorState();
		
		/*if( newState != PS_Scene )
		{
			parent.LockEntryFunction( true );
			// Rise event
			parent.RaiseForceEvent( 'ToExploration' );
		
			// Wait for ToExploration node activation
			parent.WaitForBehaviorNodeDeactivation( 'ToExplorationEnd' );
			
			parent.LockEntryFunction( false );
		}*/
	
		parent.PlayerStateCallEntryFunction( newState, behStateName );
	}
}
