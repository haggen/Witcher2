
enum EDragonTopAttack
{
	DTA_Idle,
	DTA_Edge_Claws,
	DTA_Edge_Claw_Left,
	DTA_Edge_Claw_Right,
	DTA_Edge_Jaw,
	DTA_Edge_Jaw_Side,
	DTA_Edge_Fire,
	DTA_Edge_Wings,
	DTA_WW_Claw,			//WW = Wall Walk
	DTA_WW_Tail,
	DTA_WW_To_Edge_Claw,
	DTA_Fly_Fire,
	DTA_Fly_Fire_Round,
	DTA_Fly_Claw
}

enum EDragonTopState
{
	DTS_Edge,
	DTS_WW_Left,
	DTS_WW_Right,
	DTS_Fly
}

class CDragonA3 extends CDragonA3Base
{
	private var currentAttack	: EDragonTopAttack;
	private var currentState	: EDragonTopState;
	private var checkAttack		: bool;
	private var flyAfterHit		: bool;
	private var playerHasBeenHit : bool;
	
	private var lastHitTime		: EngineTime;
	private var counterDelta	: float;
	
	private var healthToEndQTE	: float;
	
	private var rotationDependentInteractions	: array< CInteractionComponent >;
	private var initialRDIRotations				: array< EulerAngles >;
	
	default counterDelta = 1.5;
	default healthToEndQTE = 5.0f;
	timer function DragonKeepCombatMode(td : float)
	{
		thePlayer.KeepCombatMode();
	}
	function AddRDI( interactionName : string )
	{
		var interaction : CInteractionComponent;
		
		interaction = (CInteractionComponent)GetComponent( interactionName );
		if( interaction )
		{
			rotationDependentInteractions.PushBack( interaction );
			initialRDIRotations.PushBack( interaction.GetWorldRotation() );
		}
		else
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "Interaction '" + interactionName + "' could not be found. Dragon may not work properly!" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
		}
	}
	
	function UpdateRDI()
	{
		var i, size : int;
		var wrot, frot : EulerAngles;
		
		wrot = GetWorldRotation();
		
		size = rotationDependentInteractions.Size();
		for( i = 0; i < size; i += 1 )
		{
			frot = wrot;
			frot.Yaw += initialRDIRotations[i].Yaw;
			rotationDependentInteractions[i].SetRotation( frot );
		}
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		//Hits
		AddRDI( "HitLeft" );
		AddRDI( "HitRight" );
		
		//Damage
		AddRDI( "LeftClawDamage" );
		AddRDI( "RightClawDamage" );
		AddRDI( "FlyClawDamage" );
	}
	
	function CheckInstantHit() : bool
	{
		var vec : Vector;
		
		switch( currentAttack )
		{
			// Edge state
			case DTA_Edge_Claw_Right:
			{
				if( PlayerInRange( 'RightClawDamage' ) )
				{
					vec = MatrixGetTranslation( GetBoneWorldMatrix( 'r_hand' ) );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					return true;
				}
				break;
			}
			case DTA_Edge_Claw_Left:
			{
				if( PlayerInRange( 'LeftClawDamage' ) )
				{
					vec = MatrixGetTranslation( GetBoneWorldMatrix( 'l_hand' ) );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					return true;
				}
				break;
			}
			case DTA_Edge_Jaw_Side:
			{
				if( PlayerInRange( 'JawDamage' ) )
				{
					vec = MatrixGetTranslation( GetBoneWorldMatrix( 'head' ) );
					dragonHead.HitPlayer( 'Attack_t3', vec );
					return true;
				}
				break;
			}
			case DTA_Edge_Jaw:
			{
				if( PlayerInRange( 'JawDamage' ) )
				{
					vec = MatrixGetTranslation( GetBoneWorldMatrix( 'head' ) );
					dragonHead.HitPlayer( 'Attack_boss_t1', vec, 1.5f );
					return true;
				}
				break;
			}
			
			// Wall walk state
			// probably no checks are necessary
			
			// Fly state
			// definitly no checks are necessary
		}
		
		return false;
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventName == 'attack' )
		{
			if( animEventType == AET_DurationStart )
			{
				if( !CheckInstantHit() )
					checkAttack = true;
			}
			else if( animEventType == AET_DurationEnd )
				checkAttack = false;
		}
		else if(animEventName == 'fire_start' && animEventType == AET_Tick)
		{
			PlayEffect('fire_breath_1');
			AddTimer( 'FireCone', 0.3, true );
		}
		else if(animEventName == 'fire_stop' && animEventType == AET_Tick)
		{
			StopEffect('fire_breath_1');
			RemoveTimer( 'FireCone' );
		}
	}
	
	function GetDragonHitEvent() : name
	{
		//Set this to false in case you get hit before 'hit_to_fly' deactivates.
		flyAfterHit = false;
		
		if( Rand(10) == 0 )
		{
			flyAfterHit = true;
			return 'hit_to_fly';
		}
		else if( PlayerInRange( "HitRight" ) )
		{
			return 'hit_right';
		}
		else if( PlayerInRange( "HitLeft" ) )
		{
			return 'hit_left';
		}
		else
		{
			switch( Rand(3) )
			{
				case 0: return 'hit_front1';
						break;
						
				case 1: return 'hit_front2';
						break;
						
				case 2: return 'hit_neck';
						break;
			}
		}
	}
	
	function StopAllDragonEffects()
	{
		StopEffect( 'fire_breath_1' );
	}
	
	function RemoveAllDragonTimers()
	{
		// RemoveTimer( 'ChooseAttackWhileMoving' ); Not used anymore
		RemoveTimer( 'FireCone' );
	}
	
	function PlayHitAnim( optional isSpell : bool )
	{
		RemoveAllDragonTimers();
		StopAllDragonEffects();
		
		if( dragonHead.GetHealthPercentage() < healthToEndQTE )
		{
			BeginEndQTE();
		}
		
		// Counter attacks have bad animations - fix animations and uncomment this to work
		/*if( theGame.GetEngineTime() - parent.lastHitTime < parent.counterDelta )
		{
			parent.CounterAttack();
		}
		parent.lastHitTime = theGame.GetEngineTime();*/
		
		SetDragonHitEnum();
		ActivateHit();
	}
}

state Edge in CDragonA3
{
	entry function Apear()
	{
		parent.AddTimer('DragonKeepCombatMode', 1.0, true);
		
		parent.RaiseForceEvent( 'apear' );
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 10 );
		Sleep(0.5);
		parent.DragonLookatOn();
		UpdateEdge();
	}
	
	entry function UpdateEdge()
	{
		while( true )
		{
			ChooseAttack();
			Sleep(0.3);
		}
	}
	
	/*	Counter attacks as entry function couses many problems and since
		hitting dragon doesn't stop his actions they are not realy needed anymore
		
	entry function CounterAttack()
	{
		parent.canBeAttacked = false;
		parent.currentAttack = DTA_Edge_Claw_Right;
		
		parent.RaiseForceEvent( 'counter_attack_claw_left' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge' );
		
		parent.currentAttack = DTA_Idle;
		parent.canBeAttacked = true;
		Sleep(0.1);
		UpdateEdge();
	}
	*/
	
	latent function ChooseAttack() : bool
	{
		if( parent.PlayerInRange( "CloseSector" ) )
		{
			if( parent.PlayerInRange( "CloseSectorLeft" ) )
				LeftClawAttack();
			else
				RightClawAttack();
				
			return true;
		}
		else if( parent.PlayerInRange( "LeftAttack" ) )
		{
			SideJawAttack( true );
			return true;
		}
		else if( parent.PlayerInRange( "RightAttack" ) )
		{
			SideJawAttack( false );
			return true;
		}
		else if( parent.PlayerInRange( "MiddleSector" ) )
		{
			switch( Rand(3) )
			{
				case 0:
						FireUpAttack();
						break;
				case 1:
						ClawAttack();
						break;
				case 2:
						JawAttack();
						break;
			}
			return true;
		}
		else
		{
			if( Rand(5) == 0 )
			{
				if( Rand(2) == 0 )
				{
					parent.BeginFlying();
				}
				else
				{
					parent.BeginWallWalk();
				}
			}
			else if( parent.PlayerInRange("TowerRight") )
				WalkAround( false );
			else
				WalkAround( true );
			return true;
		}
		
		// ?? Maybe todo ??
		// FireForwardAttack();
		// WingsAttack();
		
		return false;
	}
	
	latent function ClawAttack()
	{
		parent.currentAttack = DTA_Edge_Claws;
		
		parent.RaiseEvent( 'edge_claw_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function LeftClawAttack()
	{
		parent.currentAttack = DTA_Edge_Claw_Left;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_left_claw_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function RightClawAttack()
	{
		parent.currentAttack = DTA_Edge_Claw_Right;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_right_claw_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function JawAttack()
	{
		parent.currentAttack = DTA_Edge_Jaw;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_jaw_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function SideJawAttack( isLeft : bool )
	{
		parent.currentAttack = DTA_Edge_Jaw_Side;
		parent.playerHasBeenHit = false;
		
		if( isLeft )
			parent.RaiseEvent( 'edge_left_jaw_attack' );
		else
			parent.RaiseEvent( 'edge_right_jaw_attack' );
			
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function FireUpAttack()
	{
		parent.currentAttack = DTA_Edge_Fire;
		
		parent.RaiseEvent( 'fire_attack2_start' );
		Sleep(4);
		parent.RaiseEvent( 'fire_attack2_stop' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function WalkAround( moveLeft : bool )
	{
		if( moveLeft )
			parent.RaiseEvent( 'walk_left' );
		else
			parent.RaiseEvent( 'walk_right' );
		
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		parent.UpdateRDI();
	}
	
	/* Not used actions
	
	latent function FireForwardAttack()
	{
		parent.currentAttack = DTA_Edge_Fire;
		
		parent.RaiseEvent( 'fire_attack_start' );
		Sleep(4);
		parent.RaiseEvent( 'fire_attack_stop' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function FireSidesAttack()
	{
		parent.currentAttack = DTA_Edge_Fire;
		
		parent.RaiseEvent( 'edge_fire_sides_start' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 10 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function WingsAttack()
	{
		parent.currentAttack = DTA_Edge_Wings;
		
		parent.RaiseEvent( 'edge_wing_start' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 10 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	function HandleWingPush()
	{
		var vec : Vector;
		
		if( parent.PlayerInRange( "WingPush" ) )
		{
			vec = VecFromHeading( parent.dragonHead.GetHeading() + 180 );
			vec += thePlayer.GetWorldPosition();
			thePlayer.HitPosition( vec, 'Attack_boss_t1', 0, false );
		}
	}
	*/
	
	function HandleInstantAttack()
	{
		var vec : Vector;
		
		switch( parent.currentAttack )
		{
			case DTA_Edge_Claws:
			{
				if( parent.PlayerInRange( "MiddleSector" ) )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'neck2' ) );
					
					parent.dragonHead.HitPlayer( 'Attack_boss_t1', vec, 1.5f );
				}
			}
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var vec : Vector;
		
		if( !parent.checkAttack || parent.playerHasBeenHit )
			return false;
			
		switch( parent.currentAttack )
		{
			case DTA_Edge_Claw_Right:
			{
				if( interactionName == 'RightClawDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'r_hand' ) );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DTA_Edge_Claw_Left:
			{
				if( interactionName == 'LeftClawDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'l_hand' ) );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DTA_Edge_Jaw_Side:
			{
				if( interactionName == 'JawDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'head' ) );
					parent.dragonHead.HitPlayer( 'Attack_t3', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DTA_Edge_Jaw:
			{
				if( interactionName == 'JawDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'head' ) );
					parent.dragonHead.HitPlayer( 'Attack_boss_t1', vec, 1.5f );
					parent.playerHasBeenHit = true;
				}
				break;
			}
		}
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		/*if( animEventName == 'wing_push' && animEventType == AET_Tick )
		{
			HandleWingPush();
		}*/
		if( animEventName == 'instant_attack' && animEventType == AET_Tick )
		{
			HandleInstantAttack();
		}
		else
		{
			parent.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
}

state WallWalk in CDragonA3
{
	var isLeft : bool;
	var startTime : EngineTime;
	var minTime, maxTime : float;
	
	default minTime = 5;
	default maxTime = 10;
	
	entry function BeginWallWalk()
	{
		if( Rand(2) == 0 )
		{
			isLeft = true;
			parent.RaiseEvent( 'wall_walk_left' );
		}
		else
		{
			isLeft = false;
			parent.RaiseEvent( 'wall_walk_right' );
		}
		parent.WaitForBehaviorNodeDeactivation( 'loop_walk' );
		startTime = theGame.GetEngineTime();
		Sleep(0.5);
		UpdateWallWalk();
	}
	
	entry function UpdateWallWalk()
	{
		while( true )
		{
			ChooseAction();
			Sleep(0.1);
		}
	}
	
	latent function ChooseAction()
	{
		var elapsedTime : EngineTime = theGame.GetEngineTime() - startTime;
		var i : int;
		
		if( (elapsedTime > minTime && Rand(10) == 0) || elapsedTime > maxTime )
		{
			EndWallWalk();
		}
		else if( parent.PlayerInRange( "MiddleSector" ) )
		{
			TailAttack();
		}
		else
		{
			for( i = 0; i < 10; i += 1 )
			{
				ChooseInteractionDrivenAction();
				Sleep(0.1);
			}
		}
	}
	
	latent function ChooseInteractionDrivenAction()
	{
		if( isLeft )
		{
			if( parent.PlayerInRange( "WallClawLeft" ) )
			{
				ClawAttack();
			}
			else if( parent.PlayerInRange( "WallStopLeft" ) )
			{
				ClawStopAttack();
			}
		}
		else
		{
			if( parent.PlayerInRange( "WallClawRight" ) )
			{
				ClawAttack();
			}
			else if( parent.PlayerInRange( "WallStopRight" ) )
			{
				ClawStopAttack();
			}
		}
	}
	
	latent function ClawAttack()
	{
		parent.currentAttack = DTA_WW_Claw;
		parent.playerHasBeenHit = false;
		parent.UpdateRDI();
		
		parent.RaiseEvent( 'wall_walk_claw_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'loop_walk', 10 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function TailAttack()
	{
		parent.currentAttack = DTA_WW_Tail;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'wall_walk_tail_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'loop_walk', 10 );
		
		parent.currentAttack = DTA_Idle;
	}
	
	latent function ClawStopAttack()
	{
		parent.currentAttack = DTA_WW_To_Edge_Claw;
		
		parent.RaiseEvent( 'wall_walk_stop_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 10 );
		
		parent.UpdateRDI();
		parent.currentAttack = DTA_Idle;
		Sleep(0.3);
		parent.UpdateEdge();
	}
	
	latent function EndWallWalk()
	{
		parent.RaiseEvent( 'wall_walk_end' );
		parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 10 );
		
		parent.UpdateRDI();
		Sleep(0.3);
		parent.UpdateEdge();
	}
	
	function HandleInstantAttack()
	{
		var vec : Vector;
		
		switch( parent.currentAttack )
		{
			case DTA_WW_To_Edge_Claw:
			{
				if( parent.PlayerInRange( "WallClawDamage" ) )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'neck2' ) );
					
					parent.dragonHead.HitPlayer( 'Attack_boss_t1', vec, 1.5f );
				}
			}
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var vec : Vector;
		
		if( !parent.checkAttack || parent.playerHasBeenHit )
			return false;
			
		switch( parent.currentAttack )
		{
			case DTA_WW_Claw:
			{
				if( isLeft )
				{
					if( interactionName == 'RightClawDamage' )
					{
						vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'r_hand' ) );
						parent.dragonHead.HitPlayer( 'Attack_t2', vec );
						parent.playerHasBeenHit = true;
					}
				}
				else
				{
					if( interactionName == 'LeftClawDamage' )
					{
						vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'l_hand' ) );
						parent.dragonHead.HitPlayer( 'Attack_t2', vec );
						parent.playerHasBeenHit = true;
					}
				}				
				break;
			}
			case DTA_WW_Tail:
			{
				if( interactionName == 'TailDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'tail5' ) );
					parent.dragonHead.HitPlayer( 'Attack_t4', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
		}
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventName == 'instant_attack' && animEventType == AET_Tick )
		{
			HandleInstantAttack();
		}
		else
		{
			parent.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
}

state Flying in CDragonA3
{
	var previousAttack : EDragonTopAttack;
	var noTimeout : bool;
	var startTime : EngineTime;
	var minTime, maxTime : float;
	
	default minTime = 5;
	default maxTime = 10;
	
	entry function BeginFlying()
	{
		parent.RaiseEvent( 'fly_start' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly', 5 );
		startTime = theGame.GetEngineTime();
		Sleep(0.5);
		UpdateFlying();
	}
	
	entry function UpdateFlying()
	{
		while( true )
		{
			ChooseAction();
			Sleep(0.5);
		}
	}
	
	function PlayerInClawArea() : bool
	{
		var area : CAreaComponent;
		
		area = (CAreaComponent)parent.GetComponent( "FlyClawArea" );
		if( area )
		{
			return area.TestPointOverlap( thePlayer.GetWorldPosition() );
		}
		else
		{
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			Log( "***********************************************************************************" );
			Log( "DRAGON BOSS ERROR: No -- FlyClawArea -- CAreaComponent in dragon entity" );
			Log( "***********************************************************************************" );
			Log( "ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR-ERROR" );
			return false;
		}
	}
	
	latent function ChooseAction()
	{
		var elapsedTime : EngineTime = theGame.GetEngineTime() - startTime;
		
		if( (elapsedTime > minTime && Rand(10) == 0) || elapsedTime > maxTime )
		{
			StopFlying();
		}
		else if( PlayerInClawArea() )
		{
			AttackClaw();
		}
		else if( parent.PlayerInRange( "TowerBack" ) )
		{
			ChangeSide();
			
			if( parent.PlayerInRange( "TowerRight" ) )
				AttackFireMove( false );
			else
				AttackFireMove( true );
		}
		else
		{
			if( parent.PlayerInRange( "TowerRight" ) )
				AttackFireMove( false );
			else
				AttackFireMove( true );
		}
		
		/* useless?
			AttackFireForward();
			MoveAround( true, RandRangeF(2,5) );
			MoveAround( false, RandRangeF(2,5) );
		*/
	}
	
	latent function AttackFireMove( moveLeft : bool )
	{
		parent.currentAttack = DTA_Fly_Fire_Round;
		
		if( moveLeft )
			parent.RaiseEvent( 'fly_fire_left' );
		else
			parent.RaiseEvent( 'fly_fire_right' );
			
		Sleep( 4.f );
		
		parent.RaiseEvent( 'fire_attack_stop' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly', 5 );
		
		parent.UpdateRDI();
		previousAttack = DTA_Fly_Fire_Round;
		parent.currentAttack = DTA_Idle;
	}
	
	latent function AttackClaw()
	{
		parent.currentAttack = DTA_Fly_Claw;
		
		parent.RaiseEvent( 'fly_attack' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly', 10 );
		
		parent.UpdateRDI();
		previousAttack = DTA_Fly_Claw;
		parent.currentAttack = DTA_Idle;
	}
	
	latent function ChangeSide()
	{
		parent.RaiseEvent( 'fly_180' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly', 10 );
		
		parent.UpdateRDI();
	}
	
	latent function StopFlying()
	{
		parent.RaiseEvent( 'fly_end' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_edge', 5 );
		Sleep(0.3);
		parent.UpdateEdge();
	}
	
	/* Actions that are useless
	
	latent function AttackFireForward()
	{
		parent.currentAttack = DTA_Fly_Fire;
		
		parent.RaiseEvent( 'fire_attack_start' );
		Sleep( 3.f );
		parent.RaiseEvent( 'fire_attack_stop' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly', 5 );
		
		previousAttack = DTA_Fly_Fire;
		parent.currentAttack = DTA_Idle;
	}
	
	latent function MoveAround( moveLeft : bool, duration : float )
	{
		if( moveLeft )
			parent.RaiseEvent( 'fly_left_start' );
		else
			parent.RaiseEvent( 'fly_right_start' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'fly_loop' );
		
		parent.AddTimer( 'ChooseAttackWhileMoving', 0.1, true );
		Sleep( duration );
		parent.RemoveTimer( 'ChooseAttackWhileMoving' );
		
		parent.RaiseEvent( 'fly_end' );
		noTimeout = parent.WaitForBehaviorNodeDeactivation( 'idle_fly' );
	}
	
	timer function ChooseAttackWhileMoving( time : float )
	{
		if( parent.PlayerInRange( "FlyFire" ) )
		{
			AttackFromMoving( DTA_Fly_Fire );
			parent.RemoveTimer( 'ChooseAttackWhileMoving' );
		}
		else if( parent.PlayerInRange( "MiddleSector" ) )
		{
			AttackFromMoving( DTA_Fly_Claw );
			parent.RemoveTimer( 'ChooseAttackWhileMoving' );
		}
	}
	
	entry function AttackFromMoving( attackType : EDragonTopAttack )
	{
		if( attackType == DTA_Fly_Fire )
		{
			parent.RaiseEvent( 'fly_end' );
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation( 'idle_fly' );
			Sleep(0.1);
			AttackFireForward();
			Sleep(0.5);
			UpdateFlying();
		}
		else if( attackType == DTA_Fly_Claw )
		{
			parent.RaiseEvent( 'fly_end' );
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation( 'idle_fly' );
			Sleep(0.1);
			AttackClaw();
			Sleep(0.5);
			UpdateFlying();
		}
		else
		{
			//WTF!? There's no more!
		}
	}
	*/
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var vec : Vector;
		
		if( !parent.checkAttack )
			return false;
			
		switch( parent.currentAttack )
		{
			case DTA_Fly_Claw:
			{
				if( interactionName == 'FlyClawDamage' )
				{
					vec = MatrixGetTranslation( parent.GetBoneWorldMatrix( 'torso3' ) );
					parent.dragonHead.HitPlayer( 'Attack_boss_t1', vec );
				}
				break;
			}
		}
	}
}

/* DEPRECATED - now hits are implemented as additive animations which is much better and doesn't stop current action on hit
state BeingHit in CDragonA3
{
	var healthToEndQTE : float;
	default healthToEndQTE = 5;
	
	entry function BeginHitDragon()
	{		
		parent.RemoveAllDragonTimers();
		parent.StopAllDragonEffects();
		
		if( parent.dragonHead.GetHealthPercentage() < healthToEndQTE )
		{
			parent.BeginEndQTE();
		}
		
		if( theGame.GetEngineTime() - parent.lastHitTime < parent.counterDelta )
		{
			parent.CounterAttack();
		}
		parent.lastHitTime = theGame.GetEngineTime();
		parent.RaiseForceEvent( parent.GetDragonHitEvent() );
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation( 'hit_end' );
		
		if( parent.flyAfterHit )
		{
			parent.flyAfterHit = false;
			parent.UpdateFlying();
		}
		else
			parent.UpdateEdge();
	}
}
*/

state EndQTE in CDragonA3
{
	entry function BeginEndQTE()
	{
		parent.RemoveTimer('DragonKeepCombatMode');
		parent.canBeAttacked = false;
		parent.canDie = true;
		
		parent.RaiseForceEvent( 'to_cutscene' );
		Sleep( 2.f );
		theGame.FadeOutAsync( 2.f );
		parent.WaitForBehaviorNodeDeactivation( 'cutscene_start', 15 );
		
		theHud.m_hud.HideBossHealth();
		
		FactsAdd( "q307_dragon_end", 1 );
		
		theGame.SaveGame( true );
	}
}

exec function KillDragon()
{
	var dragon : CDragonA3;
	
	dragon = (CDragonA3)theGame.GetEntityByTag('dragon_a3');
	
	dragon.BeginEndQTE();
}

exec function Regen()
{
	thePlayer.SetHealth( thePlayer.GetInitialHealth(), false, NULL );
}
