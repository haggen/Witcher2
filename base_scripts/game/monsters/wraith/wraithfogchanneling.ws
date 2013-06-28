////////////////////////////////////////////////////
// Special state for fog in act 2

state FogChanneling in W2MonsterWraith extends Base
{
	var canTeleportSpectre		: bool;
	var guide : CFogGuide;
	var guideEffectPoint : CNode;

	event OnEnterState()
	{
		parent.RaiseForceEvent( 'StartChanneling' );
		
		guide = (CFogGuide)theGame.GetEntityByTag('fog_guide');
		guideEffectPoint = (CNode) guide.GetComponent("fx_spectre");
		
		parent.PlayEffect( 'absorption_energy_fx', guideEffectPoint );
	}
	
	event OnLeaveState()
	{
		var leftHandItem, rightHandItem : SItemUniqueId;
		var prevOccupiedPoint : CNode;
		var guide : CFogGuide;
		
		LogChannel( 'wraith', "upior konczy walke" );
		guide = (CFogGuide)theGame.GetEntityByTag('fog_guide');
		prevOccupiedPoint = guide.GetOccupiedNode( parent );
		guide.OccupySlot( prevOccupiedPoint, parent, false );
		
		parent.StopEffect( 'absorption_energy_fx' );
		
		if ( parent.IsAlive() )
		{
			LogChannel( 'wraith', "upior jest jeszcze zywy" );
		}
		else
		{
			parent.PlayEffect('death_fx');
			parent.StopEffect('default_fx');
			//theGame.CreateEntity(despawnTmpl, parent.GetWorldPosition(), parent.GetWorldRotation());
			leftHandItem = parent.GetInventory().GetItemByCategory('monster_weapon_secondary', true, false);
			rightHandItem = parent.GetInventory().GetItemByCategory('monster_weapon', true, false);
			if(leftHandItem != GetInvalidUniqueId())
				parent.GetInventory().UnmountItem(leftHandItem, true);
			if(rightHandItem != GetInvalidUniqueId())
				parent.GetInventory().UnmountItem(rightHandItem, true);
		}
	}
	
	event OnBeingHit(out hitParams : HitParams)
	{
		return true;
	}
	event OnHit(hitParams : HitParams)
	{
		canTeleportSpectre = true;
		theSound.PlaySoundOnActor(parent, 'head', "wraith/wraith/taunt/anim_wraith_dmg_taunt");
		theSound.PlaySoundOnActor(parent, 'pelvis', "combat/weapons/hits/sword_hit");
		parent.PlayBloodOnHit();
	}
	
	entry function StartChanneling( goalId : int)
	{		
		SetGoalId(goalId);
		
		while (1)
		{		
			if ( parent.IsAlive() == false )
			{
				break;
			}
			
			if( canTeleportSpectre )
			{
				canTeleportSpectre = false;
				TeleportSpectre();
			}
			
			Sleep(1.f);
		}
		
		MarkGoalFinished();
	}
	
	latent function TeleportSpectre()
	{		
		var teleportPosition, prevOccupiedPoint : CNode;
		var guidePosition, rotatePosition : Vector;
		var rotation : EulerAngles;
		var teleportPoints : array<CComponent>;
		var actIdx, randIdx, arrSize : int;
		var i : int;
		var spawnPosition : Vector;
		
		if ( guide.GetFreeTeleportPoint( teleportPosition ) )
		{
			prevOccupiedPoint = guide.GetOccupiedNode( parent );
			guide.OccupySlot( prevOccupiedPoint, parent, false );
			guide.OccupySlot( teleportPosition, parent, true );
			
			parent.isTeleporting = true;
			
			parent.SetImmortalityModeRuntime( AIM_Invulnerable );
			parent.SetAttackableByPlayerRuntime( false );
			parent.SetBlockingHit( true, 30 );
			parent.GetMovingAgentComponent().SetEnabledRestorePosition(false);

			// Play effect
			parent.StopEffect( 'default_fx' );
			parent.PlayEffect('death_fx'); // TODO: effect here or by animation
			Sleep(0.2);
			// Hide
			//parent.SetVisibility( false );
			// Delay
			Sleep( parent.teleportDelay );
		

			// is it possible to play effect at world place?
			// Teleport
			guidePosition = guide.GetWorldPosition();
			rotatePosition = guidePosition - teleportPosition.GetWorldPosition();
			rotation.Yaw = VecHeading(rotatePosition);
			spawnPosition = teleportPosition.GetWorldPosition();
			if(GetFreeReachablePoint(spawnPosition, 5.f, spawnPosition))
			{
				parent.TeleportWithRotation(spawnPosition, rotation);
			}
			parent.PlayEffect( 'default_fx', parent );
			parent.PlayEffect( 'spawn_fx', parent );
			Sleep(0.3);
			//parent.SetVisibility( true );
			parent.GetMovingAgentComponent().SetEnabledRestorePosition(true);
			//parent.RaiseForceEvent('AttackStatic1');
			//Sleep(1);
			parent.SetImmortalityModeRuntime( AIM_None );
			parent.SetAttackableByPlayerRuntime( true );
			parent.SetBlockingHit( false );
			// Reset teleport timer
			parent.isTeleporting = false;
			parent.RaiseForceEvent( 'StartChanneling' );
		}
	}
}

class CAIGoalWraithFogChanneling extends CAIGoal
{	
	function Start() : bool
	{
		var wraith : W2MonsterWraith;
		wraith = (W2MonsterWraith)GetOwner();
		return wraith.StartChanneling(GetGoalId());
	}	
}
