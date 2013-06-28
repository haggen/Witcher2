
enum EDragonFloorAttack
{
	DFA_Idle,
	DFA_Head_Claw,
	DFA_Head_Jaw,
	DFA_Head_Fire,
	DFA_Head_Fire_End,
	DFA_Head_To_Edge,
	DFA_Edge_Jaw,
	DFA_Edge_Claw_Left,
	DFA_Edge_Claw_Right,
	DFA_Edge_Claw_Both,
	DFA_Edge_Fire,
	DFA_Edge_Fire_Sides
};

class CDragonA3Floor extends CDragonA3Base
{
	private var isEdgePhase		: bool;
	private var isChangingPhase	: bool;
	private var checkAttack		: bool;
	private var canCounter		: bool;
	private var currentAttack	: EDragonFloorAttack;
	
	private var lastHitTime		: EngineTime;
	private var playerHasBeenHit : bool;
	private var counterDelta	: float;
	
	private var healthToEdge	: float;
	private var healthToTop		: float;
	
	private var floorBurning	: bool;
	
	default healthToEdge = 80;
	default healthToTop = 60;
	
	default canCounter = true;
	default counterDelta = 2;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if( FactsDoesExist( "dragon_head_phase_finished" ) )
		{
			DragonLookatOn();
			UpdateEdgePhase();
		}
		else
			BeginHeadPhase();
	}
	
	function CounterAttack()
	{
		if( isEdgePhase )
		{
			if( canCounter )
				EdgeCounterAttack();
		}
		else
		{
			HeadCounterAttack();
		}
	}
	
	// Overriden by states that dragon is currently in
	function CheckInstantHit() : bool
	{
		var vec : Vector;
		
		switch( currentAttack )
		{
			case DFA_Head_Claw:
			{
				if( PlayerInRange( 'RightClawDamage' ) )
				{
					VecTransform( GetBoneWorldMatrix( 'r_hand' ), vec );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					playerHasBeenHit = true;
					return true;
				}
				break;
			}
			case DFA_Head_Jaw:
			{
				if( PlayerInRange( 'JawDamage' ) )
				{
					VecTransform( GetBoneWorldMatrix( 'head' ), vec );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					playerHasBeenHit = true;
					return true;
				}
				break;
			}
			case DFA_Edge_Claw_Left:
			{
				if( PlayerInRange( 'LeftClawDamage' ) )
				{
					VecTransform( GetBoneWorldMatrix( 'l_hand' ), vec );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					return true;
				}
				break;
			}
			case DFA_Edge_Claw_Right:
			{
				if( PlayerInRange( 'RightClawDamage' ) )
				{
					VecTransform( GetBoneWorldMatrix( 'r_hand' ), vec );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					return true;
				}
				break;
			}
			case DFA_Edge_Jaw:
			{
				if( PlayerInRange( 'JawDamage' ) )
				{
					VecTransform( GetBoneWorldMatrix( 'head' ), vec );
					dragonHead.HitPlayer( 'Attack_t2', vec );
					return true;
				}
				break;
			}
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
		else if( animEventName == 'fire_start' && animEventType == AET_Tick )
		{
			PlayEffect('fire_breath_2');
			
			if( !floorBurning )
			{	
				floorBurning = true;
				AddTimer( 'BurnFloor', 1.0f, false );
			}
			
			AddTimer( 'FireCone', 0.3, true );
		}
		else if( animEventName == 'fire_stop' && animEventType == AET_Tick )
		{
			StopEffect('fire_breath_2');
			RemoveTimer( 'FireCone' );
		}
		else if( animEventName == 'tower_destroy' && animEventType == AET_Tick )
		{
			if( dragonTower.GetDestructionStateIdx() == 0 )
			{
				dragonTower.FirstDestruction();
			}
			else
			{
				dragonTower.SecondDestruction();
			}
		}
	}
	
	timer function BurnFloor( time : float )
	{
		dragonTower.PlayEffect( 'fire_floor' );
	}
	
	function PlayHitAnim( optional isSpell : bool )
	{
		StopEffect( 'fire_breath_2' );
		RemoveTimer( 'FireCone' );
		
		if( !isChangingPhase && !isEdgePhase && dragonHead.GetHealthPercentage() < healthToEdge )
		{
			BeginEdgePhase();
		}
		else if( !isChangingPhase && dragonHead.GetHealthPercentage() < healthToTop )
		{
			FinishFloorPhase();
		}
		
		// Counter attacks have bad animations - fix animations and uncomment this to work
		/*if( !isSpell && theGame.GetEngineTime() - lastHitTime < counterDelta )
		{
			lastHitTime = theGame.GetEngineTime();
			CounterAttack();
		}
		lastHitTime = theGame.GetEngineTime();*/
		
		SetDragonHitEnum();
		ActivateHit();
	}
	
	function EnableHeadToEdgeTriggers()
	{
		var trigger	: CTriggerAreaComponent;
		var entity	: CEntity;
		
		entity = theGame.GetEntityByTag( 'from_head_to_edge_trg1' );
		trigger = (CTriggerAreaComponent)entity.GetComponentByClassName( 'CTriggerAreaComponent' );
		if( trigger )
		{
			trigger.SetEnabled( true );
		}
		
		entity = theGame.GetEntityByTag( 'from_head_to_edge_trg2' );
		trigger = (CTriggerAreaComponent)entity.GetComponentByClassName( 'CTriggerAreaComponent' );
		if( trigger )
		{
			trigger.SetEnabled( true );
		}
	}
}

state HeadPhase in CDragonA3Floor
{
	private var missCount		: int;
	default missCount = 0;
	
	entry function BeginHeadPhase()
	{
		theGame.GetWorld().ShowLayerGroup("quests\q307_dragon\floor_d1");
		
		parent.currentAttack = DFA_Head_Jaw;
		parent.WaitForBehaviorNodeDeactivation( 'head_idle', 10 );
		parent.currentAttack = DFA_Idle;
		Sleep(0.1);
		
		parent.DragonLookatOn();
		parent.EnableHeadToEdgeTriggers();
		
		UpdateHeadPhase();
	}
	
	entry function UpdateHeadPhase()
	{
		while( true )
		{
			thePlayer.KeepCombatMode();
			ChooseAttack();
			Sleep(0.1);
		}
	}
	
	entry function HeadCounterAttack()
	{
		parent.currentAttack = DFA_Head_Claw;
		
		parent.RaiseForceEvent( 'head_counter_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'head_idle' );
		
		parent.currentAttack = DFA_Idle;
		Sleep(0.1);
		UpdateHeadPhase();
	}
	
	latent function ChooseAttack()
	{
		if( parent.PlayerInRange( "CloseAttackLeft" ) || parent.PlayerInRange( "CloseAttackRight" ) )
		{
			ClawAttack();
		}
		else if( parent.PlayerInRange( "ForwardAttack" ) )
		{
			JawAttack();
		}
		else if( parent.PlayerInRange( "FireAttack" ) )
		{
			FireAttack();
		}
		else
		{
		//	if( missCount > 4 )
		//		parent.BeginEdgePhase();
				
			missCount += 1;
			switch( Rand(3) )
			{
				case 0: ClawAttack();
						break;
				
				case 1: JawAttack();
						break;
				
				case 2: FireAttack();
			}
		}
	}
	
	latent function ClawAttack()
	{
		parent.currentAttack = DFA_Head_Claw;
		
		parent.playerHasBeenHit = false;
		parent.RaiseEvent( 'head_attack_claw' );
		parent.WaitForBehaviorNodeDeactivation( 'head_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function JawAttack()
	{
		parent.currentAttack = DFA_Head_Jaw;
		
		parent.playerHasBeenHit = false;
		parent.RaiseEvent( 'head_attack_jaw' );
		parent.WaitForBehaviorNodeDeactivation( 'head_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function FireAttack()
	{
		parent.currentAttack = DFA_Head_Fire;
		parent.DragonLookatOn( true );
		
		parent.RaiseEvent( 'fire_start' );
		Sleep(3);
		parent.RaiseEvent( 'fire_end' );
		parent.currentAttack = DFA_Head_Fire_End;
		parent.WaitForBehaviorNodeDeactivation( 'head_idle' );
		
		parent.DragonLookatOn();
		parent.currentAttack = DFA_Idle;
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var vec : Vector;
		
		if( !parent.checkAttack || parent.playerHasBeenHit )
			return false;
			
		switch( parent.currentAttack )
		{
			case DFA_Head_Claw:
			{
				if( interactionName == 'RightClawDamage' )
				{
					VecTransform( parent.GetBoneWorldMatrix( 'r_hand' ), vec );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DFA_Head_Jaw:
			{
				if( interactionName == 'JawDamage' )
				{
					VecTransform( parent.GetBoneWorldMatrix( 'head' ), vec );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
		}
	}
}

state EdgePhase in CDragonA3Floor
{
	entry function BeginEdgePhase()
	{
		parent.isEdgePhase = true;
		parent.isChangingPhase = true;
		parent.canCounter = false;
		//parent.canBeAttacked = false;
		
		if( parent.currentAttack != DFA_Idle )
		{
			if( parent.currentAttack == DFA_Head_Fire )
			{
				while( !parent.RaiseEvent( 'fire_end' ) )
					Sleep( 0.1f );
			}
			parent.WaitForBehaviorNodeDeactivation( 'head_idle' );
			parent.DragonLookatOn();
			Sleep( 0.1f );
		}
		
		parent.RaiseEvent( 'head_to_edge' );
		FactsAdd( "dragon_head_phase_finished", 1 );
		
		theGame.GetWorld().HideLayerGroup( "quests\q307_dragon\before_edge" );
		theGame.GetWorld().ShowLayerGroup( "quests\q307_dragon\before_top" );
		
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		Sleep(0.1);
		
		parent.canCounter = true;
		parent.isChangingPhase = false;
		
		//parent.canBeAttacked = true;
		UpdateEdgePhase();
	}
	
	entry function UpdateEdgePhase()
	{
		while( true )
		{
			ChooseAttack();
			Sleep(0.1);
		}
	}
	
	entry function EdgeCounterAttack()
	{
		parent.currentAttack = DFA_Edge_Claw_Right;
		
		parent.RaiseForceEvent( 'edge_counter_attack' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
		Sleep(0.1);
		UpdateEdgePhase();
	}
	
	latent function ChooseAttack()
	{
		if( parent.PlayerInRange( "CloseAttackLeft" ) )
		{
			ClawAttackLeft();
		}
		else if( parent.PlayerInRange( "CloseAttackRight" ) )
		{
			ClawAttackRight();
		}
		else if( parent.PlayerInRange( "ForwardAttack" ) )
		{
			JawAttack();
		}
		else if( parent.PlayerInRange( "ClawsDamage" ) )
		{
			ClawAttackBoth();
		}
		else if( parent.PlayerInRange( "FireAttack" ) )
		{
			FireAttack();
		}
		else
		{
			switch( Rand(5) )
			{
				case 0:	JawAttack();
						break;
				
				case 1: ClawAttackRight();
						break;
				
				case 2: ClawAttackLeft();
						break;
				
				case 3: ClawAttackBoth();
						break;
						
				case 4: FireAttack();
						break;
					
				//case 5: FireSidesAttack();
				//		break;
			}
		}
	}
	
	latent function JawAttack()
	{
		parent.currentAttack = DFA_Edge_Jaw;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_attack_jaw' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function ClawAttackRight()
	{
		parent.currentAttack = DFA_Edge_Claw_Right;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_attack_right_claw' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function ClawAttackLeft()
	{
		parent.currentAttack = DFA_Edge_Claw_Left;
		parent.playerHasBeenHit = false;
		
		parent.RaiseEvent( 'edge_attack_left_claw' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function ClawAttackBoth()
	{
		parent.currentAttack = DFA_Edge_Claw_Both;
		
		parent.RaiseEvent( 'edge_attack_claws' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	latent function FireAttack()
	{
		parent.currentAttack = DFA_Edge_Fire;
		parent.DragonLookatOn( true );
		
		parent.RaiseEvent( 'fire_start' );
		Sleep(3);
		parent.RaiseEvent( 'fire_end' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.DragonLookatOn();
		parent.currentAttack = DFA_Idle;
	}
	
	latent function FireSidesAttack()
	{
		parent.currentAttack = DFA_Edge_Fire_Sides;
		
		parent.RaiseEvent( 'fire_sides' );
		parent.WaitForBehaviorNodeDeactivation( 'edge_idle' );
		
		parent.currentAttack = DFA_Idle;
	}
	
	function HandleInstantAttack()
	{
		var vec : Vector;
		
		if( parent.currentAttack == DFA_Edge_Claw_Both )
		{
			if( parent.PlayerInRange( "ClawsDamage" ) )
			{
				VecTransform( parent.GetBoneWorldMatrix( 'neck2' ), vec );
				
				parent.dragonHead.HitPlayer( 'Attack_boss_t1', vec, 1.5f );
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
			case DFA_Edge_Claw_Left:
			{
				if( interactionName == 'LeftClawDamage' )
				{
					VecTransform( parent.GetBoneWorldMatrix( 'l_hand' ), vec );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DFA_Edge_Claw_Right:
			{
				if( interactionName == 'RightClawDamage' )
				{
					VecTransform( parent.GetBoneWorldMatrix( 'r_hand' ), vec );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
					parent.playerHasBeenHit = true;
				}
				break;
			}
			case DFA_Edge_Jaw:
			{
				if( interactionName == 'JawDamage' )
				{
					VecTransform( parent.GetBoneWorldMatrix( 'head' ), vec );
					parent.dragonHead.HitPlayer( 'Attack_t2', vec );
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

state FinishedFloorPhase in CDragonA3Floor
{
	entry function FinishFloorPhase()
	{
		parent.isChangingPhase = true;
		theHud.m_hud.HideBossHealth();
		
		parent.dragonTower.FinalDestruction();
		
		FactsAdd( "dragon_floor_ended", 1 );
	}
}

quest function Q307_BeginDragonFloorEdgePhase()
{
	var dragon : CDragonA3Floor;
	
	dragon = (CDragonA3Floor)theGame.GetEntityByTag('dragon_a3');
	if( dragon && !dragon.isEdgePhase )
	{
		dragon.BeginEdgePhase();
	}
	else
		Log( "ERROR - Q307_BeginDragonFloorEdgePhase() - CDragonA3Floor not found!" );
}

exec function xxx()
{
	var dragon : CDragonA3Floor;
	var vec : Vector;
	
	dragon = (CDragonA3Floor)theGame.GetEntityByTag('dragon_a3');
	if( dragon )
	{
		VecTransform( dragon.GetBoneWorldMatrix( 'r_hand' ), vec );
		dragon.dragonHead.HitPlayer( 'Attack_t2', vec );
	}
}
