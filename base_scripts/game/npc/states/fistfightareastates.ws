state FistfightArea in CNewNPC extends Base
{
	private var position : Vector;
	private var rotation : EulerAngles;
	private var normalCombatRadius : float;

	event OnEnterState()
	{
		//super.OnEnterState();
		parent.GetMovingAgentComponent().EnableCombatMode(true);
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( 0.6 );
		parent.HolsterWeaponInstant( parent.GetCurrentWeapon(), DHIM_Normal);
		parent.ClearRotationTarget();
	}

	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.GetMovingAgentComponent().EnableCombatMode(false);
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( normalCombatRadius );
	}

	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can't slide along other agents
		return false;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		var pusherNPC : CActor;
		var attitude : EAIAttitude;
		pusherNPC = (CActor)pusher.GetEntity();
		
		if ( pusherNPC != thePlayer )
		{
			return false;
		}
		
		attitude = parent.GetAttitude( thePlayer );
		if ( attitude != AIA_Hostile )
		{
			parent.PushAway( pusher );
		}
	}
	
	entry function StateFistfightAreaEnter( fistfightArea : W2FistfightArea, pos : Vector, rot : EulerAngles, moveType : EMoveType, goalId : int )
	{
		var enemy : CNewNPC = fistfightArea.GetOtherNPC( parent );
		var enemyArbitrator : CAIArbitrator = enemy.GetArbitrator();
		SetGoalId( goalId );
		
		position = pos;
		rotation = rot;
		
		parent.ExitWork( EWM_Exit );
		parent.AddTimer('TeleportTimer', 10.0, false );
		parent.RaiseForceEvent('Idle');
		parent.ActionMoveToWithHeading( pos, rot.Yaw, moveType, 1.0, 0.0f );
		while( enemy && enemyArbitrator.HasCurrentGoalOfClass( 'CAIGoalFistfightAreaEnter' ) && enemy.IsMoving() )
		{
			Sleep(0.5);
		}
		
		MarkGoalFinished();
	}
	
	timer function TeleportTimer(td : float )
	{
		parent.TeleportWithRotation( position, rotation );
		MarkGoalFinished();
	}
}
