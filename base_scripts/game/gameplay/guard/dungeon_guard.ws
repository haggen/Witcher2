class CDungeonGuard extends CGuardNPC
{
	var bodyFound	: bool;	// has dead body of this guard been found?
	
	inlined editable var alarmNoiseEmitter	: CInterestPoint;
	editable var alarmNoiseDuration			: float;
	
	default alarmNoiseDuration = 2.f;
	

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		bodyFound = false;
	}
	
	function KeepCombatMode()
	{
		// do not lose player
		var target : CActor = GetTarget();
		if( target )
			NoticeActor( target );		
	}
	
	event OnEnteringCombat()
	{
		theHud.m_fx.MedalionStart();	
		super.OnEnteringCombat();		
	}
			
	latent function BeforeCombat()
	{
		//var actors : array< CActor >;
		//var deltaXY : float = 5.0;
		//ActorsStorageGetClosestByActor( this, actors, Vector(-deltaXY,-deltaXY,-2), Vector(deltaXY,deltaXY, 2), this, true, true, 3 );
		//actors.Remove( thePlayer );
		
		// Axii chance only if no other actors around and target far enough
		/*if( actors.Size() == 0 && VecDistance2D( GetTarget().GetWorldPosition(), GetWorldPosition() ) > 2.5 )
		{
			theGame.GetBlackboard().AddEntryEntity( 'axiiEnemy', this );
			theGame.GetBlackboard().AddEntryTime( 'axiiEnemy', theGame.GetEngineTime() );
			RotateToNode( GetTarget(), 0.2 );
			PlayVoiceset( 100, "warning" );
			WaitForEndOfSpeach();
			//Sleep(1.5);
			theGame.GetBlackboard().AddEntryEntity( 'axiiEnemy', NULL );
		}*/
		theHud.m_fx.MedalionStart();
		
		super.BeforeCombat(); // raising alarm
		if ( alarmNoiseEmitter )
		{
			theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( alarmNoiseEmitter, this, alarmNoiseDuration );
		}
	}
}

class CDungeonGuardMachine extends CStateMachine
{
	private var npc : CDungeonGuard;
};

state Idle in CDungeonGuardMachine
{
	entry function StateIdle()
	{	
	}
}

state Checking in CDungeonGuardMachine
{
	entry function StateChecking()
	{					
		while( 1 )
		{
			SearchForTorch();
			Sleep(1.5);
			SearchForStunnedOrDead();
			Sleep(1.5);
		}
	}
	
	latent function SearchForTorch()
	{
		var lights : array< CNode >;
		var light : CSneakLights;
		var i : int;
		var c : CComponent;
		var res : bool;
	
		theGame.GetNodesByTag( 'sneak_torch', lights );
		
		for( i = lights.Size() - 1; i >= 0; i -= 1 )
		{
			light = (CSneakLights)lights[ i ];
			if ( light && ! light.light_status && ! light.LightWillBeOn )
			{
				c = light.GetComponent( "LightDetectionPoint" );
				res = parent.npc.VisibilityTest( VT_RangeAndLineOfSight, c );
				if( res )
				{						
					parent.npc.SwitchLight( light );
					
					// disable machine
					//parent.StateIdle();
				}
			}
		}		
	}
	
	latent function SearchForStunnedOrDead()
	{
		var actors : array<CActor>;		
		var range : float = parent.npc.GetPerceptionRange();
		var bounds : Vector = Vector( range, range, range );
		var npc : CNewNPC;
		var guard : CDungeonGuard;
		var i: int;
		var res : bool;
		ActorsStorageGetClosestByActor( parent.npc, actors, -bounds, bounds, parent.npc, true, false );
		for( i = actors.Size() - 1; i >= 0; i -= 1 )
		{
			npc = (CNewNPC)actors[i];
			if( npc )
			{
				if ( npc.IsDead() )
				{
					guard = (CDungeonGuard) npc;
					if ( guard && ! guard.bodyFound )
					{
						res = parent.npc.VisibilityTest( VT_RangeAndLineOfSight, npc );
						if( res )
						{
							guard.bodyFound = true;
							
							parent.npc.CheckDeadBody( npc );
							
							// disable machine
							parent.StateIdle();
						}
					}
				}
			}
		}
	}
}


state Idle in CDungeonGuard
{
	var guardMachine : CDungeonGuardMachine;

	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
		
		if( !parent.HasTag('dontCheckLights'))
		{
			if( !guardMachine )
			{
				guardMachine = new CDungeonGuardMachine in this;
				guardMachine.npc = parent;
			}
			
			guardMachine.StateChecking();
		}
		
		parent.ambushZone.SetEnabled(true);
	}
	
	event OnLeaveState()
	{
		// Pass to base class
		super.OnLeaveState();
		
		if( guardMachine )
		{
			guardMachine.StateIdle();
		}
	}
	
	entry function SwitchLight( targetLight : CSneakLights )
	{
		var waypoint : CNode;
		
		parent.ActionCancelAll();
		targetLight.LightWillBeOn = true;
		parent.ActionRotateToAsync( targetLight.GetWorldPosition() );
		parent.PlayVoiceset( 100, "torches_off_reaction" );
		//Sleep( 2.f );
		waypoint = targetLight.GetGoToNode();
		parent.ActionMoveToNodeWithHeading( waypoint, MT_Walk, 1, 0.1f );
		//Sleep( 2.f );
		//parent.AttachBehavior('npc_carry_torch');  // spushowanie behaviora noszacego pochodnie
		
		parent.SetBehaviorVariable( "TorchWeight", 1.f );
		parent.RaiseEvent('Torch_LightUp'); // odpalenie eventu animacji odpalania pochodni
		targetLight.GuardTurnLightOn();
		//Sleep( 1.5f );
		parent.WaitForBehaviorNodeDeactivation('LightUpEnd'); // czekanie az event sie skonczy
		
		// enable machine
		guardMachine.StateChecking();
		
		// go back to idle
		StateIdle();
	}
	
	entry function CheckDeadBody( npc : CNewNPC )
	{
		var dist : float;
		var offset, npcPos : Vector;
		parent.ActionCancelAll();
		
		parent.RaiseAlarm();
		
		npcPos = npc.GetWorldPosition();
		
		offset = VecNormalize2D( parent.GetWorldPosition() - npcPos );
		offset.Z = 0.0f;
		parent.ActionMoveTo( npcPos + offset, MT_Run, 1.0f, 1.0f );
		
		// enable machine
		guardMachine.StateChecking();
		
		// go back to idle
		StateIdle();
	}
};
