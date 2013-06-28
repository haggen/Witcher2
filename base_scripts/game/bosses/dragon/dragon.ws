class CDragon extends CActor
{
	editable var DragonMappin : CEntityTemplate;
	editable var BlankaDestroyEffect : CEntityTemplate;
	
	var BreathCovers : array<CDragonCover>;
	var firstPhaseEnded : bool;
	
	private var coverManager : CCoverManager;
	private var coverAttackWP : array<name>;
	private var dragonAttackManager : CDragonAttackManager;
	private var beforeHoardingArea : CAreaComponent;
	private var betweenHoardingArea : CAreaComponent;
	
	private var flipFlop : bool;
	private var fireBreathIC : CInteractionComponent;
	private var targetFirePoint : CComponent;
	private var allowChangeState : bool;
	private var gateTrigger : CTriggerAreaComponent;
	
	private var fireDamage		: float;
	//private var fireBurnDamage	: float;
	//private var fireBurnTime	: float;
	
	default allowChangeState = true;
	
	function GetCoverManager() : CCoverManager
	{
		if( !coverManager )
		{
			coverManager = new CCoverManager in this;
			coverManager.Initialize();
		}
		
		return coverManager;
	}
	
	function GetAttackManager() : CDragonAttackManager
	{
		if( !dragonAttackManager )
		{
			dragonAttackManager = new CDragonAttackManager in this;
			dragonAttackManager.dragon = this;
			dragonAttackManager.update();
		}
		
		return dragonAttackManager;
	}
	
	function IsBoss() : bool
	{
		return true;
	}
	
	latent function Initialize()
	{
		var nodes : array<CNode>;
		var i, arraySize : int;
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'before_hoarding_area' );
		while( !ent )
		{
			Sleep( 0.1f );
			ent = theGame.GetEntityByTag( 'before_hoarding_area' );
		}
		beforeHoardingArea = (CAreaComponent)ent.GetComponent( 'Area' );
		
		ent = theGame.GetEntityByTag( 'between_hoarding_area' );
		while( !ent )
		{
			Sleep( 0.1f );
			ent = theGame.GetEntityByTag( 'between_hoarding_area' );
		}
		betweenHoardingArea = (CAreaComponent)ent.GetComponent( 'Area' );
		
		targetFirePoint = GetComponent( 'target_point_fx' );
		
		allowChangeState = false;
		AddTimer( 'KeepPlayerCombatMode', 1.0f, true );
		
		//parent.DrawWeaponInstant( parent.GetInventory().GetItemId( 'Dragon breath' ) );
		
		theGame.GetNodesByTag( 'q001_fire_cover', nodes );
		arraySize = nodes.Size();
		
		for( i = 0; i < arraySize; i += 1 )
		{
			BreathCovers.PushBack( (CDragonCover)nodes[i] );
			BreathCovers[i].activateCover();
		}
		
		TeleportToAnimationPoint();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var ent : CEntity;
		
		fireBreathIC = (CInteractionComponent)GetComponent( 'breathRange' );
		
		this.EnablePathEngineAgent( false );
		this.EnablePhysicalMovement( true );
		
		fireDamage = GetCharacterStats().GetFinalAttribute( 'fire_damage' );
		
		//fireBurnDamage = GetCharacterStats().GetFinalAttribute( 'fire_burn_damage' );
		//fireBurnTime = GetCharacterStats().GetFinalAttribute( 'fire_burn_time' );
		
		ent = theGame.GetEntityByTag( 'q001_gate_trigger' );
		gateTrigger = (CTriggerAreaComponent)ent.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		coverAttackWP.PushBack( 'coverAttack1' );
		coverAttackWP.PushBack( 'coverAttack2' );
		coverAttackWP.PushBack( 'coverAttack3' );
		coverAttackWP.PushBack( 'coverAttack4' );
		coverAttackWP.PushBack( 'coverAttack5' );
		coverAttackWP.PushBack( 'coverAttack6' );
		coverAttackWP.PushBack( 'coverAttack7' );
		coverAttackWP.PushBack( 'coverAttack8' );
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
		
		if( (eventName == 'fire_start' && eventType == AET_Tick) || (eventName == 'fire_fx' && eventType == AET_DurationStart) )
		{
			PlayEffect( 'fire_attack' );
			fireBreathIC.SetEnabled( true );
		}
		else if( (eventName == 'fire_stop' && eventType == AET_Tick) || (eventName == 'fire_fx' && eventType == AET_DurationEnd) )
		{
			StopEffect( 'fire_attack' );
			fireBreathIC.SetEnabled( false );
		}
		else if( eventName == 'dragon_qte_start' )
		{
			//thePlayer.StartDragonQteBridge1();
			qteStartInfo.action = 'Dodge';
			qteStartInfo.timeOut = 3.f;
			thePlayer.StartSinglePressQTEAsync( qteStartInfo );
		}
		else if( eventName == 'bridge_fall' )
		{
			theGame.GetEntityByTag('q001_tower01').RaiseEvent('destroy');
		}
		else if( eventName == 'dragon_qte_end' )
		{
			//thePlayer.StartDragonQteBridge1();
			qteStartInfo.action = 'Dodge';
			qteStartInfo.timeOut = 3.f;
			thePlayer.StartSinglePressQTEAsync( qteStartInfo );
		}
		else if( eventName == 'camera_shake' )
		{
			theCamera.RaiseForceEvent( 'Camera_Shake_zagnica_hit' );
		}
	}
	
	function TeleportToAnimationPoint()
	{
		var point : CNode;

		point = theGame.GetNodeByTag('dragon_point');
		
		TeleportWithRotation( point.GetWorldPosition(), point.GetWorldRotation() );
	}
	
	event OnPlayerChangedCover( coverWPIndex : int, exit : bool )
	{
		GetAttackManager().AppendNewAction( !exit, coverWPIndex );
	}
	
	event OnFirstPhaseEnded()
	{
		var DGT : CDragonGateTrigger;
		
		DGT = (CDragonGateTrigger)theGame.GetEntityByTag( 'q001_gate_dragon_trigger' );
		DGT.EnableTriggers( true );

		if( gateTrigger.TestPointOverlap( thePlayer.GetWorldPosition() ) )
		{
			GetAttackManager().ForceNewAction( DNA_Stop );
		}
		
		firstPhaseEnded = true;
	}
	
	function DragonLookatOn()
	{
		GetRootAnimatedComponent().ActivateBoneAnimatedConstraint( thePlayer, 'head', "lookAtWeight", "lookAt" );
	}
	
	function DragonLookatOff()
	{
		GetRootAnimatedComponent().DeactivateAnimatedConstraint( "lookAtWeight" );
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var activatorActor : CActor;
		var activatorCover : CDragonCover;
		var activatorIsSafe : bool;
		var i : int;
		var max_Quen_Hit : float;
		
		max_Quen_Hit = 10000;
		
		if( activator.IsA('CNewNPC') || activator.IsA( 'CPlayer' ) )
		{
			if( gateTrigger.TestPointOverlap( activator.GetWorldPosition() ) )
				return false;
				
			activatorActor = (CActor) activator;

			for( i = BreathCovers.Size() - 1; i > -1; i -=1 )
			{
				if( BreathCovers[i].isActive && BreathCovers[i].BreathCoveringActors.Contains(activatorActor) )
				{
					activatorIsSafe = true;
					continue;
				}
			}
			if( !activatorIsSafe )
			{
				if(activatorActor == thePlayer)
				{
					if(thePlayer.getActiveQuen())
					{
						thePlayer.getActiveQuen().FadeOut();
					}
				}
				activatorActor.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( 0, 0, 0, 0 ) );
				activatorActor.DecreaseHealth( fireDamage * theGame.GetDamageDifficultyLevelMult(NULL, activatorActor), true, this );
			}
		}
		else if( GetCurrentStateName() == 'HoardingAttack' && activator.IsA('CDragonCover') )
		{
			activatorCover = (CDragonCover) activator;
			
			if( !activatorCover.isBurning )
			{
				activatorCover.burnCover();
			}
		}
	}
	
	function PlayerInBreathRange() : bool
	{
		var range : CInteractionAreaComponent;
		range = (CInteractionAreaComponent)this.GetComponent( "breathRange" );
		if( range )
		{
			return range.ActivationTest( thePlayer );
		}
		else
		{
			Log( "DRAGON ERROR: Can not find CInteractionAreaComponent 'breathRange' in dragon entity" );
			return false;
		}			
	}
	
	timer function KeepPlayerCombatMode( time : float )
	{
		thePlayer.KeepCombatMode();
	}
	
	function PlayBurningEffectOnGround( optional instant : bool )
	{
		var nodes	: array< CNode >;
		var ent		: CEntity;
		var size, i : int;
		
		ent = theGame.GetEntityByTag( 'q001_burning_floor' );
		if( instant )
			ent.PlayEffect( 'burned' );
		else
			ent.PlayEffect( 'floor_burn' );
		
		theGame.GetNodesByTag( 'q001_burning_stairs', nodes );
		size = nodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			ent = (CEntity)nodes[i];
			if( instant )
				ent.PlayEffect( 'burned' );
			else
				ent.PlayEffect( 'steps_burn' );
		}
	}
}

state BeginPhase1 in CDragon
{
	entry function startPhase1()
	{
		var ent : CEntity;
		var attached : bool;
		
		ent = theGame.CreateEntity( parent.DragonMappin, parent.GetWorldPosition() );
		attached = ent.ActivateBoneAnimatedConstraint( parent, 'muscle_head', "shiftWeight", "shift", true );
		
		theGame.GetEntityByTag( 'q001_tower01' ).RaiseEvent('colapse');
		
		parent.RaiseForceEvent('appear');
		parent.WaitForBehaviorNodeDeactivation( 'FlyLoop', 15 );
		parent.continueFlying();
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if( activator.HasTag( 'cart_brok_burned' ) )
		{
			activator.PlayEffect( 'cart_brok_burn' );
		}
		
		parent.OnInteractionActivated( interactionName, activator );
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'burn_ground' )
		{
			parent.PlayBurningEffectOnGround();
		}
		
		parent.OnAnimEvent( eventName, eventTime, eventType );
	}
}

state FlyLoop in CDragon
{
	var flyTimeout : float;
	default flyTimeout = 20.0f;
	
	event OnLeaveState()
	{
		parent.RemoveTimer( 'FlyTimeout' );
	}
	
	entry function continueFlying()
	{
		parent.allowChangeState = true;
	}
	
	entry function unhide( optional isTimeout : bool )
	{
		parent.allowChangeState = false;
		
		parent.TeleportToAnimationPoint();
		parent.RaiseEvent( 'unhide' );
		parent.WaitForBehaviorNodeDeactivation( 'FlyLoop' );
		
		if( isTimeout )
			parent.AddTimer( 'FlyTimeout', flyTimeout, false );
		
		parent.allowChangeState = true;
	}
	
	//startFlying can be used only while dragon is Stopped!!!
	entry function startFlying()
	{
		parent.allowChangeState = false;
		
		parent.RaiseEvent( 'unhide' );
		Sleep( 0.6f );
		
		parent.allowChangeState = true;
	}
	
	timer function FlyTimeout( time : float )
	{
		parent.GetAttackManager().ForceNewAction( DNA_BeginAttack );
	}
	
	timer function UpdateFirePointPosition( time : float )
	{
		parent.targetFirePoint.SetPosition( thePlayer.GetWorldPosition() - parent.GetWorldPosition() );
	}
	
	timer function DelayEffect( time : float )
	{
		parent.AddTimer( 'UpdateFirePointPosition', 0.01, true );
		parent.PlayEffect( 'target_fire' );
	}
	
	timer function DelayStopEffect( time : float )
	{
		parent.StopEffect( 'target_fire' );
		parent.RemoveTimer( 'UpdateFirePointPosition' );
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( (eventName == 'allow_lookat' && eventType == AET_DurationStart) )
		{
			if( parent.betweenHoardingArea.TestPointOverlap( thePlayer.GetWorldPosition() ) )
			{
				parent.DragonLookatOn();
				parent.AddTimer( 'DelayEffect', 0.5f, false );
			}
		}
		else if( (eventName == 'allow_front_lookat' && eventType == AET_DurationStart) )
		{
			if( parent.beforeHoardingArea.TestPointOverlap( thePlayer.GetWorldPosition() ) )
			{
				parent.DragonLookatOn();
				parent.AddTimer( 'DelayEffect', 0.5f, false );
			}
		}
		else if( (eventName == 'allow_lookat' && eventType == AET_DurationEnd) || (eventName == 'allow_front_lookat' && eventType == AET_DurationEnd) )
		{
			parent.AddTimer( 'DelayStopEffect', 0.1f, false );
			parent.DragonLookatOff();
		}
		
		parent.OnAnimEvent( eventName, eventTime, eventType );
	}
}

state Hidden in CDragon
{
	entry function hide( optional unhideAfter : bool )
	{
		parent.allowChangeState = false;
		
		while( !parent.RaiseEvent( 'hide' ) )
		{
			Log( "Dragon failed to raise event 'hide', trying again..." );
			Sleep(0.5);
		}
		parent.WaitForBehaviorNodeDeactivation( 'DragonHidden' );
		
		if( unhideAfter )
			parent.unhide( true );
		
		parent.allowChangeState = true;
	}
	
	entry function forceHide()
	{
		parent.RaiseForceEvent( 'forceHidden' );
	}
}

state HoardingAttack in CDragon
{
	var attackTimeout : float;
	var timerActive : bool;
	var currentHoardingIndex : int;
	
	default attackTimeout = 10;
	
	event OnEnterState()
	{
		currentHoardingIndex = -1;
	}
	
	event OnLeaveState()
	{
		parent.ActionCancelAll();
		parent.RemoveTimer( 'HarmPlayerInFire' );
		parent.DragonLookatOff();
		parent.coverManager.OnCoverAttackStopped( currentHoardingIndex + 1 );
	}
	
	entry function attackHoarding( hoardingIndex : int, optional noTimeout : bool )
	{
		var point : CNode;
		point = theGame.GetNodeByTag( parent.coverAttackWP[hoardingIndex] );
		if( !point )
			return;

		parent.allowChangeState = false;
		
		currentHoardingIndex = hoardingIndex;
		parent.coverManager.OnCoverAttacked( currentHoardingIndex + 1 );
		
		parent.TeleportWithRotation( point.GetWorldPosition(), point.GetWorldRotation() );
		parent.DragonLookatOn();
		parent.RaiseEvent( 'hoardingAttack' );
		parent.WaitForBehaviorNodeDeactivation( 'AttackStarted' );
		
		if( !noTimeout )
		{
			parent.AddTimer( 'AttackingTimeout', attackTimeout, false );
			timerActive = true;
		}
		
		parent.AddTimer( 'HarmPlayerInFire', 0.5f, true );
		
		parent.allowChangeState = true;
	}
	
	entry function slide( hoardingIndex : int, optional outsideAfter : bool )
	{
		var point : CNode;
		var dist : float;
		
		point = theGame.GetNodeByTag( parent.coverAttackWP[hoardingIndex] );
		if( !point )
			return;
		
		if( currentHoardingIndex != hoardingIndex )
		{
			parent.coverManager.OnCoverAttackStopped( currentHoardingIndex + 1 );
			parent.coverManager.OnCoverAttacked( hoardingIndex + 1 );
			currentHoardingIndex = hoardingIndex;
		}
		
		if( !timerActive )
		{
			parent.AddTimer( 'AttackingTimeout', attackTimeout, false );
			timerActive = true;
		}
		
		//parent.TeleportWithRotation( point.GetWorldPosition(), point.GetWorldRotation() );
		dist = VecLength( parent.GetWorldPosition() - point.GetWorldPosition() );
		parent.ActionSlideToWithHeadingAsync( point.GetWorldPosition(), point.GetHeading(), 0.15f * dist );
		
		if( outsideAfter )
			attackOutside();
	}
	
	entry function attackOutside()
	{
		parent.RemoveTimer( 'AttackingTimeout' );
		timerActive = false;
	}
	
	timer function AttackingTimeout( time : float )
	{
		parent.hide( true );
		timerActive = false;
	}
	
	timer function HarmPlayerInFire( time : float )
	{
		var i : int;
		var isSafe : bool = false;
		
		if( parent.PlayerInBreathRange() )
		{
			if( parent.gateTrigger.TestPointOverlap( thePlayer.GetWorldPosition() ) )
				return;
				
			for( i = parent.BreathCovers.Size() - 1; i > -1; i -=1 )
			{
				if( parent.BreathCovers[i].isActive && parent.BreathCovers[i].BreathCoveringActors.Contains(thePlayer) )
				{
					isSafe = true;
					continue;
				}
			}
			if( !isSafe )
			{
				//TODO: Count resistances & maybe harm other, not only player?
				if( theGame.GetDifficultyLevel() > 1 )
				{
					thePlayer.DecreaseHealth( parent.fireDamage * time * theGame.GetDamageDifficultyLevelMult(NULL, thePlayer), true, parent );
				}
				thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( 0, 0, 0, 0 ) );
			}
		}
		else
		{
			if( parent.allowChangeState )
			{
				parent.GetAttackManager().ForceNewAction( DNA_ForceStopAttack );
			}
		}
	}
}

state Stopped in CDragon
{
	entry function StopFlying( optional forceEvent : bool )
	{
		parent.allowChangeState = false;
		
		if( forceEvent )
		{
			parent.RaiseForceEvent( 'forcedStop' );
		}
		else
		{
			while( !parent.RaiseEvent( 'stop' ) )
			{
				Log( "Dragon failed to raise event 'stop', trying again..." );
				Sleep(0.5);
			}
			parent.WaitForBehaviorNodeDeactivation( 'DragonStopped' );
		}
		
		parent.allowChangeState = true;
	}
}

enum EDragonNextAction
{
	DNA_BeginAttack,
	DNA_StopAttack,
	DNA_Slide,
	DNA_SlideStop,
	DNA_ForceStopAttack,
	DNA_Stop,
	DNA_None
}

class CDragonAttackManager extends CStateMachine
{
	var dragon : CDragon;
	var attackedCovers : array<int>;
	var nextAction : EDragonNextAction;
	var currentIndex : int;
	var hoardingLeftSide : bool;
	
	default currentIndex = 1000;
	default nextAction = DNA_None;
	
	function AppendNewAction( enteredCover : bool, coverWPIndex : int )
	{
		if( enteredCover )
		{
			attackedCovers.PushBack( coverWPIndex );
			
			if( currentIndex == coverWPIndex )
				return;
				
			currentIndex = coverWPIndex;
			
			if( attackedCovers.Size() > 1 )
				return;
				
			nextAction = DNA_BeginAttack;
		}
		else
		{
			attackedCovers.Remove( coverWPIndex );
		
			if( attackedCovers.Size() > 0 )
			{
				if( Abs( attackedCovers[0] - coverWPIndex ) == 1 )
				{
					currentIndex = attackedCovers[0];
					if( nextAction != DNA_BeginAttack )
						nextAction = DNA_Slide;
				}
			}
			else
			{
				if( coverWPIndex == 5 || coverWPIndex == 7 )
				{
					if( dragon.firstPhaseEnded )
						nextAction = DNA_Stop;
					else
						nextAction = DNA_ForceStopAttack;
				}
				else if( nextAction == DNA_Slide )
				{
					nextAction = DNA_SlideStop;
				}
				else
				{
					currentIndex = -1;
					nextAction = DNA_StopAttack;
				}
			}
		}
		
		switch( nextAction )
		{
			case DNA_BeginAttack:
				Log( "DRAGON NEXT ACTION:	****	'DNA_BeginAttack'	****" );
				break;
			case DNA_StopAttack:
				Log( "DRAGON NEXT ACTION:	****	'DNA_StopAttack'	****" );
				break;
			case DNA_Slide:
				Log( "DRAGON NEXT ACTION:	****	'DNA_Slide'			****" );
				break;
			case DNA_SlideStop:
				Log( "DRAGON NEXT ACTION:	****	'DNA_SlideStop'		****" );
				break;
			case DNA_ForceStopAttack:
				Log( "DRAGON NEXT ACTION:	****	'DNA_ForceStopAttack'		****" );
				break;
			case DNA_None:
				Log( "DRAGON NEXT ACTION:	****	'DNA_None'			****" );
				break;
				
			Log( "DRAGON CURRENT STATE:	****	" + dragon.GetCurrentStateName() + "	****" );
		}
	}
	
	function ForceNewAction( action : EDragonNextAction )
	{
		nextAction = action;
	}
	
	function IsHoardingSideLeft( index : int ) : bool
	{
		return index == 0 || index == 1 || index == 4 || index == 5;
	}
}

state Active in CDragonAttackManager
{
	entry function update()
	{
		var stateName : name;
		
		while( true )
		{
			if( parent.dragon.allowChangeState )
			{
				stateName = parent.dragon.GetCurrentStateName();
				switch( parent.nextAction )
				{
					case DNA_None:
					{
						break;
					}
					
					case DNA_BeginAttack:
					{
						if( parent.currentIndex == -1 )
						{
							parent.nextAction = DNA_None;
							break;
						}
							
						if( stateName == 'FlyLoop' )
						{
							parent.dragon.hide();
						}
						else if( stateName == 'Hidden' )
						{
							parent.hoardingLeftSide = parent.IsHoardingSideLeft( parent.currentIndex );
							parent.dragon.attackHoarding( parent.currentIndex );
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'HoardingAttack' )
						{
							if( parent.hoardingLeftSide == parent.IsHoardingSideLeft( parent.currentIndex ) )
							{
								parent.dragon.slide( parent.currentIndex );
							}
							else
							{
								parent.dragon.hide();
							}
						}
						else if( stateName == 'Stopped' )
						{
							parent.dragon.forceHide();
						}
						break;
					}
					
					case DNA_StopAttack:
					{
						if( stateName == 'HoardingAttack' )
						{
							parent.dragon.attackOutside();
						}
						else if( stateName == 'Hidden' )
						{
							parent.dragon.unhide();
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'FlyLoop' )
						{
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Stopped' )
						{
							parent.dragon.startFlying();
							parent.nextAction = DNA_None;
						}
						break;
					}
					
					case DNA_Slide:
					{
						if( stateName == 'HoardingAttack' )
						{
							parent.dragon.slide( parent.currentIndex );
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Hidden' )
						{
							//****************************************
							//****************************************
							//This could be the reason of BUG!!!!!!!!
							//Entering this while already in State - Hidden while DNA_StopAttack is being performed
							//can stop the dragon from unhiding, making him hidden until next action is triggered
							//****************************************
							//****************************************
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'FlyLoop' )
						{
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Stopped' )
						{
							parent.nextAction = DNA_None;
						}
						break;
					}
					
					case DNA_SlideStop:
					{
						if( stateName == 'HoardingAttack' )
						{
							parent.dragon.slide( parent.currentIndex, true );
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Hidden' )
						{
							parent.dragon.attackHoarding( parent.currentIndex, true );
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'FlyLoop' )
						{
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Stopped' )
						{
							parent.nextAction = DNA_None;
						}
						
						parent.currentIndex = -1;
						break;
					}
					
					case DNA_ForceStopAttack:
					{
						if( stateName == 'HoardingAttack' )
						{
							parent.dragon.hide();
						}
						else if( stateName == 'Hidden' )
						{
							parent.dragon.unhide();
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'FlyLoop' )
						{
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Stopped' )
						{
							parent.nextAction = DNA_None;
						}
						
						parent.currentIndex = -1;
						break;
					}
					
					case DNA_Stop:
					{
						if( stateName == 'HoardingAttack' )
						{
							parent.dragon.hide();
						}
						else if( stateName == 'Hidden' )
						{
							parent.dragon.unhide();
						}
						else if( stateName == 'FlyLoop' )
						{
							parent.dragon.StopFlying();
							parent.nextAction = DNA_None;
						}
						else if( stateName == 'Stopped' )
						{
							parent.nextAction = DNA_None;
						}
						
						parent.currentIndex = -1;
						break;
					}
				}
			}
			
			Sleep(0.5);
		}
	}
}

class CDragonGateTrigger extends CEntity
{
	var exitTrg		: CTriggerAreaComponent;
	var enterTrg	: CTriggerAreaComponent;
	var insideEnter	: bool;
	var insideExit	: bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		enterTrg = (CTriggerAreaComponent)GetComponent( 'Enter' );
		exitTrg = (CTriggerAreaComponent)GetComponent( 'Exit' );
		
		EnableTriggers( false );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
			return false;
		
		if( area == enterTrg )
		{
			insideEnter = true;
		}
		else
		{
			insideExit = true;
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
			return false;
			
		if( area == enterTrg )
		{
			insideEnter = false;
			
			if( !insideExit )
			{
				RemoveTimers();
				AddTimer( 'DelayExit', 2.0f, false );
			}
		}
		else
		{
			insideExit = false;
			
			if( !insideEnter )
			{
				RemoveTimers();
				AddTimer( 'DelayEnter', 2.0f, false );
			}
		}
	}
	
	timer function DelayExit( time : float )
	{
		theGame.dragon.GetAttackManager().ForceNewAction( DNA_StopAttack );
	}
	
	timer function DelayEnter( time : float )
	{
		theGame.dragon.GetAttackManager().ForceNewAction( DNA_Stop );
	}
	
	function EnableTriggers( enable : bool )
	{
		exitTrg.SetEnabled( enable );
		enterTrg.SetEnabled( enable );
	}
}

quest function Q001_DestroyDragon()
{
	theGame.dragon.Destroy();
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//							PHASE 3								//
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

state phase3 in CDragon
{
	var leftComp, rightComp : CComponent;
	
	entry function startPhase3( startingPoint : name )
	{
		var node : CNode;
		var comp : CComponent;
		
		parent.fireBreathIC.SetEnabled( false );
		
		comp = parent.GetComponent( 'clawsRange' );
		comp.SetEnabled( true );
		
		comp = parent.GetComponent( 'clawsRange2' );
		comp.SetEnabled( true );
		
		comp = parent.GetComponent( 'deathRange' );
		comp.SetEnabled( true );
		
		leftComp = parent.GetComponent( "blankaEffectLeft" );
		rightComp = parent.GetComponent( "blankaEffectRight" );
		
		node = theGame.GetNodeByTag( startingPoint );
		
		parent.ActivateBehavior( 'dragon_prologue_phase2' );
		parent.TeleportWithRotation( node.GetWorldPosition(), node.GetWorldRotation() );
	}
	
	entry function proceedToPhase3()
	{
		parent.WaitForBehaviorNodeActivation('walk_started', 10 );
		parent.TeleportWithRotation( parent.GetWorldPosition(), EulerAngles(0,270,0) );
	}
	
	entry function phase3FireAttack()
	{
		parent.RaiseForceEvent( 'forceFire' );
		
		parent.proceedToPhase3();		
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var activatorActor : CActor;
		var dmg : float;
		
		activatorActor = (CActor) activator;
	
		if( interactionName == 'clawsRange' )
		{
			parent.clawAttack();
		}
		else if( interactionName == 'deathRange' )
		{
			RagdollKill( 500.f, 0.f, 100.f );
			
			parent.clawHit();
		}
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if ( eventName == 'claw_hit' && eventType == AET_DurationStart )
		{
			if( parent.CheckInteraction( "clawsRange2" ) && !parent.flipFlop )
			{
				parent.flipFlop = true;
				
				RagdollKill( 200.f, -200.f, 400.f );
			}
		}
		else if ( eventName == 'claw_hit' && eventType == AET_DurationEnd && parent.flipFlop )
		{
			parent.clawHit();
		}
		else if( eventName == 'fire_fx' && eventType == AET_DurationStart )
		{
			parent.PlayEffect( 'fire_attack' );
		}
		else if( eventName == 'fire_fx' && eventType == AET_DurationEnd )
		{
			parent.StopEffect( 'fire_attack' );
		}
		else if( eventName == 'burn' )
		{
			CheckBurning();
		}
		else if( eventName == 'camera_shake' )
		{
			theCamera.RaiseForceEvent( 'Camera_ShakeHit' );
		}
		else if( eventName == 'left_foot' )
		{
			PlayBlankaEffect( true );
		}
		else if( eventName == 'right_foot' )
		{
			PlayBlankaEffect( false );
		}
	}
	
	function CheckBurning()
	{
		var foltest : CActor;
		
		if( !FactsDoesExist( "q001_bridge_hidden" ) )
		{
			foltest = theGame.GetActorByTag( 'Foltest' );
			thePlayer.SetManualControl( false, false );
	
			thePlayer.SetAlive( false );
			
			foltest.PlayEffect( 'burning_fx' );
			thePlayer.PlayEffect( 'burning_fx' );
			
			foltest.RaiseForceEvent( 'qte_burn' );
			thePlayer.RaiseForceEvent( 'qte_burn' );
			
			parent.clawHit();
		}
	}
	
	function PlayBlankaEffect( isLeft : bool )
	{
		if( isLeft )
			theGame.CreateEntity( parent.BlankaDestroyEffect, leftComp.GetWorldPosition() );
		else
			theGame.CreateEntity( parent.BlankaDestroyEffect, rightComp.GetWorldPosition() );
	}
	
	function RagdollKill( forceX, forceY, forceZ : float )
	{
		var comp : CAnimatedComponent;
		var foltest : CActor;
		var impulse : Vector;
		
		thePlayer.SetManualControl( false, false );
		thePlayer.SetAlive( false );
				
		impulse.X = forceX;
		impulse.Y = forceY;
		impulse.Z = forceZ;
		comp = thePlayer.GetRootAnimatedComponent();
		thePlayer.SetRagdoll( true );
		thePlayer.PlayBloodOnHit();
		comp.SetRootBoneImpulse( impulse );
		
		foltest = theGame.GetActorByTag( 'Foltest' );
		foltest.ActivateBehavior( 'npc_exploration' );
		comp = foltest.GetRootAnimatedComponent();
		foltest.SetRagdoll( true );
		foltest.PlayBloodOnHit();
		comp.SetRootBoneImpulse( impulse );
	}
}

state clawAttack in CDragon
{	
	entry function clawAttack()
	{
		parent.RaiseEvent( 'claw_attack' );
		parent.proceedToPhase3();
	}
	
	entry function clawHit()
	{
		parent.RaiseForceEvent( 'forceIdle' );
		Sleep(2);
		
		theSound.PlaySound("gui/gui/gui_gameover");
		theHud.m_hud.SetGameOver();
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
	}
}

state stopped in CDragon
{
	entry function EndPhase3()
	{
		parent.StopEffect( 'fire_attack' );
		parent.RaiseForceEvent( 'forceIdle' );
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
	}
}

class CDestructableBlanka extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer( 'DelayEffect', 0.01, false );
		AddTimer( 'DelayDestroy', 5.0, false );
	}
	
	timer function DelayDestroy( time : float )
	{
		Destroy();
	}
	
	timer function DelayEffect( time : float )
	{
		PlayEffect( 'blank_destroy_fx' );
	}
}
