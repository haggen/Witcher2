/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Takedowns
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Takedown state
/////////////////////////////////////////////

struct STakedownParams
{
	var actor : CActor;	
	var eventNameDefault : name;
	var eventNameRun : name;
	var useSlot : bool;
	var multipleEnemies : bool;
	var slide : bool;
	var force : bool;
	var stopActors : bool;
	var stun : bool;
	var disableMovingAgent : bool;	
	var destNode : CNode;
};

function SetupTakedownParamsDefault( actor : CActor, out outParams : STakedownParams )
{
	outParams = STakedownParams();
	outParams.actor = actor;	
	//outParams.eventNameDefault	= 'takedown_man_01';	
	//outParams.eventNameDefault	= 'finisher_man_02';
	
	outParams.eventNameDefault = GetFinisherAnimName((CNewNPC)actor,1);
	outParams.eventNameRun = outParams.eventNameDefault;
	outParams.multipleEnemies = true;
	outParams.useSlot = true;
	outParams.slide = true;
	outParams.force = false;
	outParams.stopActors = true;
	outParams.stun = false;	
}

function SetupTakedownParamsEnv( actor : CActor, destNode : CNode, out outParams : STakedownParams )
{
	outParams = STakedownParams();
	outParams.actor = actor;	
	outParams.eventNameDefault	= 'stealth_takedown_env01';
	outParams.eventNameRun		= 'stealth_takedown_env01';
	outParams.slide = true;
	outParams.force = true;
	outParams.stopActors = true;
	outParams.stun = false;
	outParams.destNode = destNode;
}

function SetupTakedownParamsSneak( actor : CActor, out outParams : STakedownParams )
{
	outParams = STakedownParams();
	outParams.actor = actor;		
	outParams.eventNameDefault	= 'stealth_takedown01';
	outParams.eventNameRun		= 'stealth_run_takedown01';
	outParams.slide = true;
	outParams.force = true;
	outParams.stun = true;
}

function SetupStealthKillParamsSneak( actor : CActor, out outParams : STakedownParams )
{
	outParams = STakedownParams();
	outParams.actor = actor;		
	outParams.eventNameDefault	= 'stealth_takedown01';
	outParams.eventNameRun		= 'stealth_run_takedown01';
	outParams.slide = true;
	outParams.force = true;
	outParams.stun = false;
}

function GetFinisherAnimName( enemy : CNewNPC, numEnemies : int ) : name
{
	var i : int;
	var anim : string;
	var valid : array<int>;
	
	if ( enemy.GetCurrentStateName() == 'Falter' )
	{
		// TODO: put falter animation name
		return 'takedown_man_01';
	}
	else if ( enemy.GetCurrentStateName() == 'Stun' )
	{
		// TODO: put stun animation name
		return 'takedown_man_01';
	}
	
	if( enemy.HasCombatType( CT_ShieldSword ) )
	{
		return 'fin_shield_1man_01';
	}
	
	valid.PushBack(1);
	valid.PushBack(2);
	valid.PushBack(3);
	valid.PushBack(4);
	
	/*valid.PushBack(1);
	//valid.PushBack(2);
	//valid.PushBack(4);
	valid.PushBack(5);
	valid.PushBack(7);
	//valid.PushBack(10);
	//valid.PushBack(11);
	//valid.PushBack(12);
	//valid.PushBack(13);
	//valid.PushBack(15);*/
	
	if( numEnemies == 1 )	
	{	
		i = valid[Rand(valid.Size())];		
	}
	else	
	{
		//i = Rand(5)+1;
		i = 3; // TEMPSHIT
	}
		
	anim = StrFormat( "takedown_man_0%1", i );
		
	return StringToName(anim);
}

state CombatTakedown in CPlayer extends Combat
{
	var canLeaveState : bool;	
	var emergencyEvent : name;
	var disabledNPCs : array<CNewNPC>;
	
	default emergencyEvent = 'emergency_takedown1';
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{		
		super.OnEnterState();
		CreateNoSaveLock();		
		canLeaveState = false;
		parent.AttachBehavior('takedown');
		parent.SetImmortalityModeRuntime(AIM_Invulnerable);
		parent.SetManualControl( false, true );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		EnableNPCs();	
		parent.DetachBehavior('takedown');
		parent.SetImmortalityModeRuntime(AIM_None);
		parent.SetManualControl(true, true );
	}
	
	event OnLeavingState()
	{
		return canLeaveState;
	}
	
	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	function AddMarkEnemyTimer() {}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Anim events
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		if( animEventType == AET_Tick && animEventName == 'StrongAttack_t1' )
		{						
			enemy.Kill(true, thePlayer);			
		}
		else
		{
			return super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Game input event
	event OnGameInputEvent( key : name, value : float )
	{
		// do nothing
		return true;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Attack
	
	function CollectNearbyNPCs( params : STakedownParams, out nearbyNPCs : array<CNewNPC> )
	{
		var freeDelta : float = 10.0;
		var nearbyActors : array<CActor>;
		var i : int;
		var npc : CNewNPC;
		
		ActorsStorageGetClosestByActor(params.actor, nearbyActors,
			Vector( -freeDelta, -freeDelta, -3 ),
			Vector( freeDelta, freeDelta, 3 ),
			parent, true, false, 50 );
			
		nearbyActors.Remove(params.actor);
		
		ArrayActorsToNPCs( nearbyActors, nearbyNPCs );
	}
	
	function ExtractClosestNPC( params : STakedownParams, out npcs : array<CNewNPC> ) : CNewNPC
	{
		var i : int;
		var bestDist : float = 10000000.0f;
		var dist : float;
		var bestNPC, npc : CNewNPC;
		var pos, refPos : Vector;
		
		refPos = params.actor.GetWorldPosition();
		
		for( i = npcs.Size()-1; i>=0; i-=1 )
		{
			npc = npcs[i];
			if( npc.IsAlive() )
			{
				if(	npc.IsAttackableByPlayer() && npc.GetAttitude( thePlayer ) == AIA_Hostile && npc.CanBeTakedowned(thePlayer, false ) )
				{
					if( !npc.HasCombatType( CT_ShieldSword ) && !npc.HasCombatType( CT_TwoHanded ) )
					{
						pos = npc.GetWorldPosition();
						dist = VecDistance( pos, refPos );
						if( dist < bestDist )
						{
							bestDist = dist;
							bestNPC = npc;
						}
					}
				}
			}
		}
		
		if( bestNPC )
		{
			npcs.Remove( bestNPC );
		}
		
		return bestNPC;
	}
		
	entry function TakedownMonsterActor( oldState : EPlayerState, params : STakedownParams )
	{	
		var enemyNPC : CNewNPC;
		enemyNPC = (CNewNPC)params.actor;
		enemy = enemyNPC;
	
		enemyNPC.SetAlive(false);
		enemyNPC.StateTakedown(NULL, false, NULL);
			
		parent.SetRotationTarget(enemy, false );
		parent.RaiseForceEvent( 'Monster_finisher' );		
		//Sleep(0.2);
		parent.ClearRotationTarget();
		parent.WaitForBehaviorNodeDeactivation('TakeDownEnd');			
		//TerminateEnemy(enemy, params);
		//Sleep(0.5);
		
		canLeaveState = true;
		parent.ResetMovment();
		parent.ChangePlayerState( oldState );
	}
	
	entry function TakedownActor( oldState : EPlayerState, params : STakedownParams )
	{
		var slots : array<Matrix>;
		var slotsNum : int;
		var posPlayer, posPlayerMS, posRoot, slot1, slot2, dir : Vector;
		var rotPlayer, tmpRot : EulerAngles;
		var posTarget : array<Vector>;
		var rotTarget : array<EulerAngles>;
		var distToTarget : float;		
		var takedownEvent, evt : name;
		var nearbyNPCs : array<CNewNPC>;
		var i, numEnemies : int;
		var failed : bool;
		var enemy : int;	// failsafe
		var enemies : array< CNewNPC >;
		var secondaryEnemy : CNewNPC;
		var tempNpc : CNewNPC;
		var areaTestRes : bool;
		
		parent.RaiseForceEvent('Idle');
		
		if (params.actor.IsMonster())
		{
			TakedownMonsterActor( oldState, params );
		}
		enemies.PushBack( (CNewNPC)params.actor );
		
		// AREA MUST BE FREE OF ACTORS
		failed = false;
		if( !params.force )
		{
			CollectNearbyNPCs( params, nearbyNPCs );
			if( nearbyNPCs.Size() > 0 )
			{
				if( params.stopActors )
				{
					DisableNPCs( nearbyNPCs );
				}
				else
				{
					failed = BlockingNPCs( nearbyNPCs );
				}
			}
		}
		
		//-------------------------------
		
		numEnemies = enemies.Size();
		
		// Clear rotation targets
		parent.ClearRotationTarget();
		for( i=0; i<numEnemies; i+=1 )
		{
			enemies[i].ClearRotationTarget();			
		}
		
		SetCooldown( 1 );
		
		if( !failed )
		{			
			takedownEvent = GetEventName( params );
			slotsNum = 1 + numEnemies;
			if(parent.GetAnimCombatSlots( takedownEvent, slots, slotsNum, 1, parent.GetLocalToWorld(), 2, enemies[0].GetLocalToWorld() ) )
			{
				posRoot = MatrixGetTranslation( slots[0] );
				posPlayer = MatrixGetTranslation( slots[1] );			
				
				rotPlayer = MatrixGetRotation( slots[1] );
				
				parent.GetVisualDebug().AddSphere( 'tdPlayer', 0.5f, posPlayer, true, Color(255,0,0) );
				parent.GetVisualDebug().AddSphere( 'tdRoot', 0.5f, posRoot, true, Color(0,0,255) );		
				for( i=0; i<numEnemies; i+=1 )
				{
					posTarget.PushBack( MatrixGetTranslation( slots[i+2] ) );
					rotTarget.PushBack( MatrixGetRotation( slots[i+2] ) );
					parent.GetVisualDebug().AddSphere( StringToName("tdEnemy"+i), 0.5f, posTarget[i], true, Color(0,255,0) );
				}				
				
				if( params.force )
				{
					areaTestRes = true;
				}				
				else
				{
					areaTestRes = PositionTestArea( enemies[0], posPlayer, posTarget[0], numEnemies );
				}
				
				if( areaTestRes )
				{	
					if( numEnemies > 1 )
					{
						SetCooldown( numEnemies );						
					}
				
					for( i=0; i<numEnemies; i+=1 )
					{	
						enemies[i].SetAlive( false );
						enemies[i].StateTakedown( params.destNode, params.useSlot, NULL );
					}
					
					// DIABLE MAC
					for( i=0; i<numEnemies; i+=1 )
					{
						//if( !params.destNode )
						//{
							if( params.stun )
								enemies[i].GetMovingAgentComponent().SetEnabledRestorePosition( false );							
							else												
								enemies[i].EnablePathEngineAgent( false );							
						//}
					}
					
					// SLIDE
					if( params.slide )
					{
						parent.ResetMovment();
						SlideEnemies( enemies, posTarget, rotTarget );
						parent.ActionSlideToWithHeading( posPlayer, rotPlayer.Yaw, 0.2);		
					}					

					
					// PLAY ANIMATION ON NPCS
					for( i=0; i<numEnemies; i+=1 )
					{									
						if( i==1 )						
							evt = StringToName(takedownEvent+"_b");
						else
							evt = takedownEvent;
						
						PlayAnimation( enemies[i], evt, params );						
					}
					
					// PLAY ANIMATION ON PLAYER
					parent.GetVisualDebug().AddText(StringToName("dbgTakedownTxt"), "TAKEDOWN: "+takedownEvent, Vector(0,0,1.3), false, 0, Color(0,255,255), true, 5.0);
					if( params.useSlot )
					{
						parent.ActionPlaySlotAnimation('TAKEDOWN', takedownEvent );
					}
					else
					{
						parent.RaiseEvent( takedownEvent );
						parent.WaitForBehaviorNodeDeactivation('TakeDownEnd');
					}					
					parent.RaiseForceEvent('Idle');
					
					// TERMINATE ENEMIES
					if( !params.destNode )
					{
						for( i=0; i<numEnemies; i+=1 )
						{
							TerminateEnemy(enemies[i], params, true);
						}
					}
				}
				else
				{
					failed = true;
				}
			}
			else
			{
				Log("TakedownActor error: cannot get takedown slots positions!");
			}			
		}
		
		if(failed)
		{
			enemies[0].SetAlive(false);
			enemies[0].StateTakedown(NULL, false, NULL);
		
			/*dir = parent.GetWorldPosition() - posTarget;
			dir.Z = 0.0;			
			dir = VecNormalize2D(dir);
			posPlayer = posTarget + dir * 2.5;
			rotPlayer = VecToRotation( -dir );
			parent.ActionSlideToWithHeading(posPlayer, rotPlayer.Yaw, 0.2);*/
			
			parent.SetRotationTarget(enemies[0], false );
			parent.RaiseEvent( emergencyEvent );		
			Sleep(0.2);
			parent.ClearRotationTarget();
			//parent.WaitForBehaviorNodeDeactivation('TakeDownEnd');			
			TerminateEnemy(enemies[0], params, false);
			Sleep(0.5);
		}
		
		canLeaveState = true;
		parent.ResetMovment();
		parent.ChangePlayerState( oldState );
		
	}
	
	latent function PlayAnimation( enemy : CNewNPC, evt : name, params : STakedownParams )
	{
		enemy.GetVisualDebug().AddText(StringToName("dbgTakedownTxt"+Rand(1000)), "TAKEDOWN: "+evt, Vector(0,0,1.3), false, 0, Color(0,255,0), true, 5.0);
		if( params.useSlot )
		{
			enemy.StateTakedownPlaySlotAnim( evt );											
		}
		else
		{
			enemy.RaiseEvent( evt );					
		}		
	}
	
	latent function SlideEnemies( enemies : array<CNewNPC>, enemiesPos : array<Vector>, enemiesRot : array<EulerAngles> )
	{
		var i : int;
		for( i=0; i<enemies.Size(); i+=1 )
		{	
			enemies[i].ActionSlideToWithHeadingAsync( enemiesPos[i], enemiesRot[i].Yaw, 0.2 );
		}
	}

	
	function SetCooldown( numEnemies : int )
	{
		var bb : CBlackboard = theGame.GetBlackboard();
		var tm : EngineTime;
		var currentTime : EngineTime = theGame.GetEngineTime();
		
		bb.AddEntryTime('takedownStart', currentTime );
		bb.AddEntryFloat('takedownCount', numEnemies );
	}
	
	function CheckCooldownMultipleTakedown() : bool
	{
		var tm : EngineTime;
		var res : bool;
		res = theGame.GetBlackboard().GetEntryTime('takedownStart', tm );
		
		if( !res || (theGame.GetEngineTime() - tm) > 60.0 )
		{
			return true;
		}
		
		return false;
	}
	
	function TerminateEnemy( enemy : CActor, params : STakedownParams, silent : bool )
	{
		var deathData : SActorDeathData;
		deathData.silent = silent;
		deathData.noActionCancelling = true;
	
		if( params.stun )
			enemy.Stun(true, thePlayer, deathData);
		else
			enemy.Kill(true, thePlayer, deathData);
	}
	
	private function GetEventName( out params : STakedownParams ) : name
	{
		if( parent.GetRawMoveSpeed() > 0.2 )
		{			
			return params.eventNameRun;
		}
		else
		{
			return params.eventNameDefault;
		}
	}
	
	private function PositionTest( enemy : CActor, posPlayer, posTarget : Vector ) : bool
	{
		var mac : CMovingAgentComponent = enemy.GetMovingAgentComponent();
		var delta : float;		
		delta = 1.5;
		
		if( !parent.GetMovingAgentComponent().IsEndOfLinePositionValid( posPlayer ) ) return false;
		if(	!mac.IsEndOfLinePositionValid( posPlayer ) )	return false;
		if( !mac.IsEndOfLinePositionValid( posTarget + Vector( delta, 0, 0) ) )	return false;
		if( !mac.IsEndOfLinePositionValid( posTarget + Vector(-delta, 0, 0) ) )	return false;
		if( !mac.IsEndOfLinePositionValid( posTarget + Vector(0,  delta, 0) ) )	return false;
		if( !mac.IsEndOfLinePositionValid( posTarget + Vector(0, -delta, 0) ) )	return false;
			
		return true;
	}
	
	private latent function PositionTestArea( enemy : CActor, posPlayer, posTarget : Vector, numEnemies : int ) : bool
	{
		var mac : CMovingAgentComponent = enemy.GetMovingAgentComponent();
		var params : SPathEngineEmptySpaceQuery;
		var res, yaw : float;
		var pos : Vector;
		
		if( !parent.GetMovingAgentComponent().IsEndOfLinePositionValid( posPlayer ) ) return false;
		if(	!mac.IsEndOfLinePositionValid( posPlayer ) )	return false;
		
		if( numEnemies > 1 )
		{
			params.width = 5.0f;
			params.height = 5.0f;
		}
		else
		{
			params.width = 3.0f;
			params.height = 3.0f;
		}
		params.yaw = -1.0f;
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
			if( VecDistance2D( posTarget, pos ) < 0.1 )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function BlockingNPCs( out npcs : array<CNewNPC> ) : bool
	{
		var npc : CNewNPC;
		var i,s : int;
		
		s = npcs.Size();
		
		for( i=0; i<npcs.Size(); i+=1 )
		{
			npc = npcs[i];
			if( npc.IsAlive() || npc.IsUnconscious() )
			{
				return true;				
			}
		}
		
		return false;
	}
	
	private function DisableNPCs( out npcs : array<CNewNPC> )
	{
		var npc : CNewNPC;
		var i : int;
		for( i=0; i<npcs.Size(); i+=1 )
		{
			npc = npcs[i];
			if( npc.IsAlive() )
			{
				npc.GetArbitrator().AddGoalTakedownObserve();
				disabledNPCs.PushBack(npc);
			}
		}
	}
	
	private function EnableNPCs()
	{
		var i : int;
		for( i=0; i<disabledNPCs.Size(); i+=1 )
		{
			disabledNPCs[i].GetArbitrator().MarkGoalsFinishedByClassName('CAIGoalTakedownObserve');
		}
		
		disabledNPCs.Clear();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Hits
	
	private function PlayHit( hitParams : HitParams )
	{
		// Nothing
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		var oldState : EPlayerState;
		oldState = parent.GetCurrentPlayerState();
		
		if( newState == PS_Cutscene )
		{
			parent.EnterCutsceneState( PS_CombatSteel, '' );
		}
		else
		{
			parent.PlayerStateCallEntryFunction( newState, '' );			
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Combat loop function
	
	private latent function CombatLogic()
	{
		super.CombatLogic();
	}
}


