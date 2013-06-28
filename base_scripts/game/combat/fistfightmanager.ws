/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Fistfight manager
/** Copyright © 2010
/***********************************************************************/

class W2FistfightManager extends CStateMachine
{
	var m_deniedArea 			: CEntity;
	var npcQueue 				: array< CNewNPC >;
	var hiddenActors 			: array< CActor >;
	
	// fight related data
	var m_currentPlayerState	: EPlayerState;
	var m_enemyNPC				: CNewNPC;
	var m_spot					: W2FistfightSpotRef;
	
	///////////////////////////////////////////////////////////////////////
		
	event OnIsRequestInProgress()
	{
		return false;
	}
	
	// this cheat allows to finish the fistfight by stunning the player's opponent
	event OnStunOpponentCheat()
	{
		if ( m_enemyNPC )
		{
			m_enemyNPC.Stun( true, thePlayer );
			FinishWon();
		}	
	}
	
	event OnActorIncapacitated( actor : CActor )
	{
	}
	
	///////////////////////////////////////////////////////////////////////
	// Arbitration events
	///////////////////////////////////////////////////////////////////////
	
	event OnQTESuccessful( attacker : CActor );
	
	event OnQTEFailure( attacker : CActor );
	
	event OnComboAttack( attacker : CActor, canBeBlocked : bool, comboAttack : SBehaviorComboAttack );
	
	event OnHit( fighter : CActor );
	
	///////////////////////////////////////////////////////////////////////
	// Helper functions
	///////////////////////////////////////////////////////////////////////
		
	final latent function FindFistfightPosition( out pos : Vector, out yaw : float ) : bool
	{
		var params : SPathEngineEmptySpaceQuery;
		var res : float;
		
		params.width = 2.0f;
		params.height = 4.0f;
		params.yaw = -1.0f;
		params.searchRadius = 10.0f;
		params.localSearchRadius = 2.0f;		
		params.maxPathLen = 25.0f;
		params.maxCenterLevelDifference = 5.0f;
		params.maxAreaLevelDifference = 0.5f;
		params.numTests = 40;
		params.checkObstaclesLevel = PEESC_SceneObstacles;
		params.useAwayMethod = true;
		params.debug = true;
		
		res = thePlayer.GetMovingAgentComponent().FindEmptySpace( params, pos, yaw );
		return res >= params.width * 0.9;
	}
	
	final latent function GetFistfightSpot( npc : CNewNPC, nearNode : CNode ) : W2FistfightSpotRef
	{
		var nodes : array<CNode>;
		var bestDist, dist, yaw : float;
		var nearPos, pos : Vector;
		var i,s : int;
		var spot : W2FistfightSpotRef;		
		var spotEntity : W2FistfightSpot;
		var npcTag : name;
		var res : bool;
		
		// Search for spots
		nearPos = nearNode.GetWorldPosition();
		theGame.GetNodesByTag('fistfight_spot', nodes);
		s = nodes.Size();
		bestDist = 10000000000;
		for( i=0; i<s; i+=1 )
		{
			spotEntity = (W2FistfightSpot)nodes[i];
			if( spotEntity )
			{
				npcTag = spotEntity.GetNPCTag();
				if( IsNameValid( npcTag ) && npc.HasTag( npcTag ) )
				{
					pos = nodes[i].GetWorldPosition();
					dist = VecDistance2D( nearPos, pos );
					if( dist < bestDist && dist < 20.0 )
					{
						bestDist = dist;
						spot.node = nodes[i];
					}
				}
			}
		}
		
		if( spot.node )
		{
			LogChannel('static_ff', "GetFistfightSpot: Using fistfight spot: "+spot.node);
			return spot;
		}
		
		// Try to automatically find position
		res = FindFistfightPosition( spot.position, yaw );
		if( res )
		{
			spot.rotation = EulerAngles( 0, yaw, 0 );
			LogChannel('static_ff', "GetFistfightSpot: using empty space");
			return spot;
		}
		
		// Use current nearNode position
		spot.position = nearNode.GetWorldPosition();
		spot.rotation = nearNode.GetWorldRotation();
		LogChannel('static_ff', "GetFistfightSpot: near node: "+nearNode);		
		
		return spot;
	}
	
	
	
	function QueueNPC( npc : CNewNPC )
	{
		if( !npcQueue.Contains(npc) )
		{
			npcQueue.PushBack( npc );
		}
	}
	
	function DequeueNPC( npc : CNewNPC )
	{		
		npcQueue.Remove( npc );
	}
	
	function GetFirstNPCInQueue() : CNewNPC
	{
		if( npcQueue.Size() > 0 )
		{
			return npcQueue[0];
		}
		
		return NULL;
	}
	
	function TeleportToFistfightSpot( spot : W2FistfightSpotRef, player, npc : CActor, optional noRotation : bool )
	{
		var spotRot : EulerAngles;		
		var spotPos : Vector;		
		GetFistfightSpotOrientation( spot, spotPos, spotRot );

		player.TeleportWithRotation( spotPos, spotRot );
		theCamera.TeleportWithRotation( spotPos, spotRot );
		npc.TeleportWithRotation( spotPos, spotRot );		
	}
	
	latent function SlideToSlotPosition()
	{
		var spotRot, myRot : EulerAngles;		
		var spotPos : Vector;		
		GetFistfightSpotOrientation( m_spot, spotPos, spotRot );
		
		// the agents can rotate about the slot center while fighting - try reducing
		// the rotation slides when they have
		myRot = thePlayer.GetWorldRotation();
		if( AbsF( AngleDistance(spotRot.Yaw, myRot.Yaw) ) > 90.0 )
		{
			spotRot.Yaw += 180.0f;
		}

		thePlayer.ActionSlideToWithHeadingAsync( spotPos, spotRot.Yaw, 0.5f );
		m_enemyNPC.ActionSlideToWithHeadingAsync( spotPos, spotRot.Yaw, 0.5f );
		theCamera.TeleportWithRotation( spotPos, spotRot );
		Sleep( 0.5f );
	}

	latent function SpawnDeniedArea( spot : W2FistfightSpotRef )
	{
		var deniedAreaTemplate : CEntityTemplate;
		var pos, curPos 		: Vector;
		var rot, curRot 		: EulerAngles;
		var area 				: CAreaComponent;

		
		GetFistfightSpotOrientation( spot, pos, rot ) ;
		
		if( m_deniedArea )
		{
			curPos = m_deniedArea.GetWorldPosition();
			curRot = m_deniedArea.GetWorldRotation();
			if( curPos != pos || curRot != rot )
			{
				DestroyDeniedArea();
			}
		}
		
		if( !m_deniedArea )
		{	
			deniedAreaTemplate = (CEntityTemplate) LoadResource("gameplay\fistfight_deniedarea");
			if( deniedAreaTemplate )
			{
				m_deniedArea = theGame.CreateEntity( deniedAreaTemplate, pos, rot );
				
				if( m_deniedArea )
				{
					Sleep( 0.1 );		
					area = (CAreaComponent)m_deniedArea.GetComponentByClassName('CAreaComponent');
					if( area )
					{
						RemoveNPCs( m_spot, m_enemyNPC, area );								
					}
					else
					{
						LogChannelf( 'static_ff', "ERROR: Fistfight no area component");
					}
				}
				else
				{
					LogChannelf( 'AI', "ERROR: Fistfight denied area spawn error");
				}
			}
			else
			{
				LogChannelf( 'AI', "ERROR: Fistfight denied area template load error");
			}
		}
	}
	
	function DestroyDeniedArea()
	{
		if( m_deniedArea )
		{
			// Disable so it will not block player directly after call
			m_deniedArea.GetComponentByClassName('CDeniedAreaComponent').SetEnabled(false);
			m_deniedArea.Destroy();
			m_deniedArea = NULL;
		}
	}
	
	function RemoveNPCs( spot : W2FistfightSpotRef, enemyNpc : CActor, area : CAreaComponent )
	{
		var actors : array< CActor >;
		var actor : CActor;
		var delta : float = 100000;
		var bounds : Vector = Vector( delta, delta );
		var i,s : int;
		var npc : CNewNPC;
		var pos : Vector;
		var rot : EulerAngles;
		
		GetFistfightSpotOrientation( spot, pos, rot );
		
		ActorsStorageGetClosestByPos( pos, actors, -bounds, bounds, thePlayer, false, true );
				
		for( i=actors.Size()-1; i>=0; i-=1 )
		{
			actor = actors[i];
			if( actor == enemyNpc )
				continue;
		
			npc = (CNewNPC)actor;
			if( npc && npc.GetMovingAgentComponent().IsEnabled() )
			{
				if( !npc.HasTag('ignoreFistfightArea') )
				{	
					if( area.TestPointOverlap( npc.GetWorldPosition() ) )
					{
						LogChannelf( 'AI', "WARNING: Removing npc %1 from fistfight area", npc.GetName() );
						npc.Teleport(pos);
					}
				}				
			}						
		}
	}
	
	function HideActor( actor : CActor , spot : W2FistfightSpotRef )
	{
		var pos : Vector;
		var rot : EulerAngles;
		actor.SetHideInGame(true);
		GetFistfightDeathSpotOrientation( spot, pos, rot );
		actor.TeleportWithRotation( pos, rot );
		
		hiddenActors.PushBack( actor );
	}
	
	function UnhideActor( actor : CActor )
	{
		actor.SetHideInGame( false );
		hiddenActors.Remove( actor );
	}
	
	function UnhideAllActors()
	{
		var i : int;
		for( i=0; i<hiddenActors.Size(); i+=1 )
		{
			if( hiddenActors[i] )
			{
				hiddenActors[i].SetHideInGame( false );
			}
		}		
		hiddenActors.Clear();
	}
	
	function IsActorHidden( actor : CActor ) : bool
	{
		return hiddenActors.Contains( actor );
	}
	
	function GetOpponent( fighter : CActor ) : CActor 
	{
		if ( fighter == thePlayer )
		{
			return m_enemyNPC;
		}
		else
		{
			return thePlayer;
		}
	}
	 
};

////////////////////////////////////////////////////////////////////////////

// This state can setup a fight
state Idle in W2FistfightManager
{
	private var fistfightRequestTime : EngineTime;	// Fistfight request lock
	
	event OnIsRequestInProgress()
	{
		return false;
	}
	
	// Standard entry function
	entry function Idle()
	{
		var npc : CNewNPC;
		
		// wait a while before you set up a fight
		Sleep( 2 );
		
		parent.m_enemyNPC = NULL;
		while( true )
		{
			if( parent.npcQueue.Size() > 0 )
			{
				npc = parent.npcQueue[0];
				if( npc && npc.IsAlive() && npc.GetAttitude( thePlayer ) == AIA_Hostile )
				{
					parent.m_enemyNPC = npc;
					parent.ArrangeCombat();
				}
				else
				{
					parent.npcQueue.Remove( npc );
				}
			}
		
			Sleep( 1.0f );
		}
	}
};

////////////////////////////////////////////////////////////////////////////

state ArrangeCombat in W2FistfightManager
{
	event OnIsRequestInProgress()
	{
		return true;
	}
	
	// This function will try arranging a static fistfight and will transition the manager
	// to a proper state once it's done
	entry function ArrangeCombat()
	{
		var timeout, moveRes : bool;
		var timeoutTime : EngineTime;
		var area : CAreaComponent;
		var currentPlayerState : EPlayerState;
		
		//theHud.m_hud.HideTutorial();
		//theHud.HideTutorialPanelOld();
		theHud.m_hud.UnlockTutorial();
		parent.m_spot = parent.GetFistfightSpot( parent.m_enemyNPC, thePlayer );
		parent.m_currentPlayerState = thePlayer.GetCurrentPlayerState();
		
		if( currentPlayerState != PS_CombatFistfightStatic
			|| (currentPlayerState == PS_CombatFistfightStatic && thePlayer.GetEnemy() == parent.m_enemyNPC )
			|| parent.GetFirstNPCInQueue() == parent.m_enemyNPC )
		{
			thePlayer.ChangePlayerState( PS_CombatFistfightStatic );
			thePlayer.RaiseForceEvent('Idle');
			theCamera.RaiseForceEvent('Idle');		
			
			// we're making the player immortal for the time of the fight
			thePlayer.SetImmortalityModeRuntime( AIM_Immortal, 100000 );
					
			// Add npc to queue if not
			parent.DequeueNPC( parent.m_enemyNPC );
		
			parent.Combat();
		}
		else
		{
			// failed to setup a combat - go back to idle
			parent.Idle();
		}
	}
}

////////////////////////////////////////////////////////////////////////////


enum EStaticFightStage
{
	SFT_StartHitting,
	SFT_Decide,
	SFT_WaitForHitQTE,
	SFT_WitcherAttack,
	SFT_WitcherWarning,
	SFT_EnemyWarning,
	SFT_WaitForEnemyCounter,
	SFT_WaitForWitcherCounter,
	SFT_WitcherCounter,
	SFT_WitcherRecounter,
	SFT_EnemyCounter,
	SFT_EnemyAttack,
	SFT_Finisher,
	SFT_Defeat,
	SFT_Interrupted
}


// This is a combat arbitration state
state Combat in W2FistfightManager
{
	private var m_keyAttackFast 		: name;
	private var m_keyBlock 				: name;
	private var m_keyRecounter 			: name;
	
	private var m_stage					: EStaticFightStage;
	private var m_lastButton 			: name;
	
	private var m_hitter				: CActor;
	private var m_actorIncapacitated 	: CActor;
	

	event OnEnterState()
	{			
		super.OnEnterState();
		
		if ( !theGame.IsUsingPad() )
		{
			m_keyAttackFast = 'QTE1';
			m_keyBlock = 'QTE2';
			m_keyRecounter = 'QTE3';
		} 
		else
		{
			m_keyAttackFast = 'Dodge';
			m_keyBlock = 'GuiCharacterDowngrade';
			m_keyRecounter = 'AttackFast';
		}
		
		// clear all actions the fighters might have
		parent.m_enemyNPC.ActionCancelAll();
		thePlayer.ActionCancelAll();
							
		// behavior for npc
		parent.m_enemyNPC.ActivateBehavior('npc_fistfight_static');
				
		// Disable mac
		parent.m_enemyNPC.GetMovingAgentComponent().SetEnabledRestorePosition( false );								
		thePlayer.GetMovingAgentComponent().SetEnabledRestorePosition( false );												
				
		parent.TeleportToFistfightSpot( parent.m_spot, thePlayer, parent.m_enemyNPC );
		thePlayer.RaiseForceEvent('Idle');
		parent.m_enemyNPC.RaiseForceEvent('Idle');
				
		theCamera.RaiseEvent( 'fistfight_reset' );
		
		// target the enemy
		//theHud.HudTargetActorEx( parent.m_enemyNPC, false );
		
		// play a fistfight music
		theSound.PlayMusicFistFight( "fistfight" );
								
		m_stage = SFT_StartHitting;
		m_actorIncapacitated = (CActor)NULL;
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		theSound.StopMusic( "fistfight" );
	}
	
	event OnIsRequestInProgress()
	{
		return true;
	}
		
	entry function Combat()
	{		
		var opponent		: CActor;
		var waitForHitTime	: float;
		var eventResult		: bool;
		
		parent.SpawnDeniedArea( parent.m_spot );
		
		// start the fight - show the QTE
		theGame.FadeIn();
		
		// main fight loop
		while ( true )
		{			
			switch( m_stage )
			{
				case SFT_StartHitting:
				{
					m_stage = SFT_Decide;
					Sleep( 1.0f ); // fallthrough
				}
				
				case SFT_Decide:
				{
					// slide to slot position
					parent.SlideToSlotPosition();
					
					// reset the poses
					thePlayer.RaiseForceEvent( 'Idle' );
					parent.m_enemyNPC.RaiseForceEvent( 'Idle' );
						
					
					// maintain the combat mode
					thePlayer.KeepCombatMode();
					
					// go to the next combo stage
					SelectHitDirection();
						
					InitializeQTE( true );
					m_stage = SFT_WaitForHitQTE;
					waitForHitTime = 1.0f;
					// fallthrough
				}
				
				case SFT_WaitForHitQTE:
				{
					break;
				}
				
				// --------------------------------------------------------------
				// Hit execution
				// --------------------------------------------------------------
				case SFT_WitcherAttack:
				{
					// administer a hit
					eventResult = thePlayer.RaiseEvent( 'AttackW' );
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'AttackW' );
						parent.m_enemyNPC.RaiseEvent( 'AttackW' );
						thePlayer.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
						m_stage = SFT_Decide;
					}
					break;
				}
				
				case SFT_WitcherWarning:
				{
					// administer a warning
					eventResult = thePlayer.RaiseEvent( 'WarningW' );
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'WarningW' );
						parent.m_enemyNPC.RaiseEvent( 'WarningW' );
						
						// proceed to the next combo way
						m_stage = SFT_WaitForEnemyCounter;
						waitForHitTime = 1.0f;
							
						// initialize a block QTE
						InitializeQTE( m_hitter == thePlayer );
					}
					
					break;
				}
				
				case SFT_EnemyWarning:
				{
					// administer a warning
					eventResult = thePlayer.RaiseEvent( 'WarningE' );
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'WarningE' );
						parent.m_enemyNPC.RaiseEvent( 'WarningE' );
						
						// proceed to the next combo way
						m_stage = SFT_WaitForWitcherCounter;
						waitForHitTime = 1.0f;
							
						// initialize a block QTE
						InitializeQTE( m_hitter == thePlayer );	
					}
					break;
				}
				
				case SFT_WitcherCounter:
				{
					// administer a hit
					eventResult = thePlayer.RaiseEvent( 'CounterW' );
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'CounterW' );
						parent.m_enemyNPC.RaiseEvent( 'CounterW' );
						thePlayer.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
						m_stage = SFT_Decide;
					}
					break;
				}
				
				case SFT_WitcherRecounter:
				{
					// administer a hit
					thePlayer.RaiseEvent( 'RecounterW' );
					theCamera.RaiseEvent( 'RecounterW' );
					parent.m_enemyNPC.RaiseEvent( 'RecounterW' );
					thePlayer.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
					m_stage = SFT_Decide;
					break;
				}
				
				case SFT_EnemyCounter:
				{
					// administer a hit
					eventResult = thePlayer.RaiseEvent( 'CounterE' );	
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'CounterE' );
						parent.m_enemyNPC.RaiseEvent( 'CounterE' );
						thePlayer.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
						m_stage = SFT_Decide;
					}
					break;
				}

				case SFT_EnemyAttack:
				{
					// administer a hit
					eventResult = thePlayer.RaiseEvent( 'AttackE' );
					if ( eventResult )
					{
						theCamera.RaiseEvent( 'AttackE' );
						parent.m_enemyNPC.RaiseEvent( 'AttackE' );
						thePlayer.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
						m_stage = SFT_Decide;
					}
					break;
				}
				
				// --------------------------------------------------------------
				// Block
				// --------------------------------------------------------------
				case SFT_WaitForEnemyCounter:
				{
					// wait... and if nothing happens for a while - go to the failure hit
					waitForHitTime -= 0.1f;
					if ( waitForHitTime < 0 )
					{
						m_stage = SFT_EnemyAttack;
					}
					break;
				}
				case SFT_WaitForWitcherCounter:
				{
					// wait... and if nothing happens for a while - go to the failure hit
					waitForHitTime -= 0.1f;
					if ( waitForHitTime < 0 )
					{
						m_stage = SFT_WitcherRecounter;
					}
					break;
				}
				
				
				// --------------------------------------------------------------
				// Final punch
				// --------------------------------------------------------------
				case SFT_Defeat:
				{					
					// the player lost too much health - he lost
					parent.FinishLost();
					break;
				}
				
				case SFT_Finisher:
				{	
					// the player won
					FactsAdd("Won_Fistfight", 1);
					parent.FinishWon();
					break;
				}
				
				case SFT_Interrupted:
				{
					break;
				}
			}
			
			// wait 
			Sleep( 0.1f );
		}
	}
	
	// ============================================================
	// Combat events implementation
	// ============================================================
	event OnQTESuccessful( attacker : CActor )
	{
		// this event can be received upon every combo hit performed - so it can be received
		// in multiple states - and we have to decide what to do with it dependeing
		// on the state the fight state machine is in
				
		var healthPercentage		: float = parent.m_enemyNPC.GetHealthPercentage();
		var health					: float = parent.m_enemyNPC.GetHealth();
						

		switch( m_stage )
		{
			case SFT_WaitForHitQTE:
			{
				// decide if we should perform a finisher
				if ( healthPercentage < 30.0 || health <= 10.0 )
				{
					// finish the NPC off
					m_stage = SFT_Finisher;
				}
				else
				{
					m_stage = RandomizeHitType();
				}
				break;
			}
				
			case SFT_WaitForEnemyCounter:
			{
				m_stage = SFT_WitcherRecounter;
				break;
			}
				
			case SFT_WaitForWitcherCounter:
			{
				m_stage = SFT_EnemyCounter;
				break;
			}
				
			default:
				m_stage = SFT_Decide;
		}
	}
	
	event OnQTEFailure( attacker : CActor )
	{
		// this event can be received upon every combo hit performed - so it can be received
		// in multiple states - and we have to decide what to do with it dependeing
		// on the state the fight state machine is in
		
		switch( m_stage )
		{
			case SFT_WaitForHitQTE:
			{
				// decide if we should perform a finisher
				if( thePlayer.GetHealth() <= 1 )
				{
					// finish the player off
					m_stage = SFT_Defeat;
				}
				else
				{
					m_stage = SFT_EnemyWarning;
				}
				break;
			}
				
			case SFT_WaitForEnemyCounter:
			{
				m_stage = SFT_WitcherCounter;
				break;
			}
				
			case SFT_WaitForWitcherCounter:
			{
				m_stage = SFT_EnemyAttack;
				break;
			}
				
			default:
				m_stage = SFT_Decide;
		}
	}
	
	event OnHit( fighter : CActor )
	{
		var damage : float;
		var enemy : CActor = parent.GetOpponent( fighter );
		
		damage = CalcFistfightDamage( enemy ) ;
		fighter.DecreaseHealth( damage, false, enemy );
	}
	
	event OnActorIncapacitated( actor : CActor )
	{
		m_stage = SFT_Interrupted;
		thePlayer.BreakQTE();
		
		if ( actor == thePlayer )
		{
			// the player lost too much health - he lost
			parent.FinishLost();
		}
		else
		{		
			parent.FinishWon();
		}
	}
	
	// ============================================================
	// Helper functions
	// ============================================================
	private function SelectHitDirection()
	{		
		var attackTypeIdx : int;
		
		attackTypeIdx = RandDifferent( 9, attackTypeIdx );
		attackTypeIdx = attackTypeIdx % 8;
		
		thePlayer.SetBehaviorVariable( 'attackTypeIdx', (float)attackTypeIdx );
		theCamera.SetBehaviorVariable( 'attackTypeIdx', (float)attackTypeIdx );
		parent.m_enemyNPC.SetBehaviorVariable( 'attackTypeIdx', (float)attackTypeIdx );
	}
	
	
	private function RandomizeHitType() : EStaticFightStage
	{
		if ( Rand(2) == 0 )
		{
			return SFT_WitcherAttack;
		}
		else
		{
			return SFT_WitcherWarning;
		}
	}
	
	private function CalcFistfightDamage( attacker : CActor ) : float
	{
		var cs : CCharacterStats = attacker.GetCharacterStats();
		var damageMin : float = cs.GetFinalAttribute('damage_min');
		var damageMax : float = cs.GetFinalAttribute('damage_max');
	
		if( attacker == thePlayer )
		{
			damageMin = cs.GetFinalAttribute('ff_damage_min');
			damageMax = cs.GetFinalAttribute('ff_damage_max');
		}
	
		return RandRangeF( damageMin, damageMax );
	}
	
	private function InitializeQTE( isPlayerHitting : bool )
	{
		var buttonName : name = RandomButton( false );
		var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
		
		m_keyAttackFast = buttonName;
		qteStartInfo.action = buttonName;
		qteStartInfo.timeOut = 1.0f;
		qteStartInfo.position = GetButtonPosition( buttonName );
		qteStartInfo.ignoreWrongInput = false;
		qteStartInfo.isSkippable = false;
		
		thePlayer.StartSinglePressQTEAsync( qteStartInfo );
	}
	
	private function RandomButton( performKnockdown : bool ) : name
	{
		var rand : float;
		var output : name;
		if ( !theGame.IsUsingPad() )
		{
			output = 'QTE1';
			m_keyAttackFast = 'QTE1';
			if ( m_lastButton == 'QTE1' ) { output = 'QTE2'; m_keyAttackFast = 'QTE2';  }
			rand = RandRangeF(0, 40);
			if ( rand > 10 && m_lastButton != 'QTE2' ) { output = 'QTE2'; m_keyAttackFast = 'QTE2'; }
			if ( rand > 20 && m_lastButton != 'QTE3' ) { output = 'QTE3'; m_keyAttackFast = 'QTE3'; }
			if ( rand > 30 && m_lastButton != 'QTE4' ) { output = 'QTE4'; m_keyAttackFast = 'QTE4'; }
			if ( performKnockdown ) { output = 'QTE1';  m_keyAttackFast = 'QTE1'; }
			m_lastButton = output;
		}
		else
		{
			output = 'Dodge';
			m_keyAttackFast = 'Dodge';
			if ( m_lastButton == 'Dodge' ) {output = 'GuiCharacterDowngrade'; m_keyAttackFast = 'GuiCharacterDowngrade'; }
			rand = RandRangeF(0, 40);
			if ( rand > 10 && m_lastButton != 'GuiCharacterDowngrade' ){ output = 'GuiCharacterDowngrade'; m_keyAttackFast = 'GuiCharacterDowngrade'; }
			if ( rand > 20 && m_lastButton != 'AttackFast' ) {output = 'AttackFast'; m_keyAttackFast = 'AttackFast'; }
			if ( rand > 30 && m_lastButton != 'AttackStrong' ) {output = 'AttackStrong'; m_keyAttackFast = 'AttackStrong'; }
			if ( performKnockdown ){ output = 'Dodge'; m_keyAttackFast = 'Dodge'; }
			m_lastButton = output;
		}
		return output;
	}
	
	private function GetButtonPosition( buttonName : name ) : EQTEPosition
	{
		var output : EQTEPosition;
		if ( !theGame.IsUsingPad() )
		{
			if ( buttonName == 'QTE1') output = QTEPosition_West;
			if ( buttonName == 'QTE2') output = QTEPosition_East;
			if ( buttonName == 'QTE3') output = QTEPosition_North;
			if ( buttonName == 'QTE4') output = QTEPosition_South;
		} 
		else
		{
			if ( buttonName == 'AttackFast') output = QTEPosition_West;
			if ( buttonName == 'GuiCharacterDowngrade') output = QTEPosition_East;
			if ( buttonName == 'AttackStrong') output = QTEPosition_North;
			if ( buttonName == 'Dodge') output = QTEPosition_South;
		}
		return output;
	}
};

////////////////////////////////////////////////////////////////////////////

state Finish in W2FistfightManager
{
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.DestroyDeniedArea();
	}
	
	event OnIsRequestInProgress()
	{
		return false;
	}
	
	cleanup function Cleanup()
	{
		theGame.FadeInAsync(0.5);
		LogChannel( 'static_ff', "W2FistfightManager Finish cleanup" );
		thePlayer.SetErrorState( "W2FistfightManager Finish cleanup" );
	}

	entry function FinishLost()
	{
		var ffSpot 				: W2FistfightSpot = GetFistfightSpotEntity( parent.m_spot );
		var enemyNPCTags 		: array<name>;
		var i					: int;
		
		//play the finisher
		PlayFinisher( false );
		
		// cleanup
		parent.SetCleanupFunction('Cleanup');
		parent.UnhideAllActors();
			
		// set proper facts in the facts DB
		FactsAdd( "Witcher lost fistfight", 1, 5 );
		enemyNPCTags = parent.m_enemyNPC.GetTags();
		for( i = 0; i < enemyNPCTags.Size(); i += 1 )
		{
			FactsAdd( "Witcher lost fistfight with " + enemyNPCTags[i], 1 );			
		}
		
		// decide what to do with the player
		if( parent.m_enemyNPC.deadlyFists )
		{
			// we need to kill the player
			thePlayer.SetImmortalityModeRuntime( AIM_None );
			thePlayer.Kill();
		}
		else
		{	
			// make the player unconcious
			thePlayer.IncreaseHealth(1);
			thePlayer.ChangePlayerState( PS_Exploration );
		}
		Sleep( 0.5 );
		
		if( !ffSpot || ( ffSpot && ffSpot.fadeInLost ) )
		{
			theGame.FadeIn();
		}
		parent.Idle();
		
	}
	
	
	entry function FinishWon()
	{	
		var ffSpot 				: W2FistfightSpot = GetFistfightSpotEntity( parent.m_spot );	
		var enemyNPCTags 		: array<name>;
		var i					: int;
		var deathData 			: SActorDeathData;
		
		//play the finisher
		PlayFinisher( true );
		
		// cleanup
		parent.SetCleanupFunction('Cleanup');
		parent.UnhideAllActors();	
		
		// set proper facts in the facts DB
		FactsAdd( "Witcher won fistfight", 1, 5 );
		enemyNPCTags = parent.m_enemyNPC.GetTags();
		for( i = 0; i < enemyNPCTags.Size(); i += 1 )
		{
			FactsAdd( "Witcher won fistfight with " + enemyNPCTags[i], 1 );			
		}
		
		// set the exploration state on the player
		thePlayer.ChangePlayerState( PS_Exploration );
		
		// stun the opponent
		deathData.silent = false;
		deathData.fallDownDeath = false;
		deathData.noActionCancelling = false;
		parent.m_enemyNPC.Stun( false, thePlayer, deathData );
		parent.m_enemyNPC.EnterUnconscious( deathData );
		
		if ( thePlayer.GetHealth() <= 1 )
		{
			thePlayer.IncreaseHealth( 10 );
		}
		
		// fade in
		if( !ffSpot || ( ffSpot && ffSpot.fadeInWon ) )
		{
			theGame.FadeIn();
		}
		parent.Idle();
	}
	
	// ===========================================================================
	// Helper methods
	// ===========================================================================
	private latent function PlayFinisher( victory : bool )
	{
		var actorsNames		: array< string >;
		var actorsEntities	: array< CEntity >;
		var spotRot 		: EulerAngles;		
		var spotPos 		: Vector;		
		var cutsceneResult	: bool;
		var finisherIdx		: int;
		
		theGame.FadeOut( 0.1 );
		
		if ( victory )
		{
			actorsNames.PushBack( "witcher" );
			actorsNames.PushBack( "enemy" );
		}
		else
		{
			actorsNames.PushBack( "enemy" );
			actorsNames.PushBack( "witcher" );
		}
		actorsEntities.PushBack( thePlayer );
		actorsEntities.PushBack( parent.m_enemyNPC );
					
		GetFistfightSpotOrientation( parent.m_spot, spotPos, spotRot );
		finisherIdx = (int)( RandRangeF( 0, 100 ) ) % 8;
					
		cutsceneResult = theGame.PlayCutscene( 	"fin_ff_" + finisherIdx,
											actorsNames, actorsEntities, 
											spotPos, spotRot );
		
		theGame.FadeOut( 0 );
	}
};
