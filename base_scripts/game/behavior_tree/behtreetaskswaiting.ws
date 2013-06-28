/////////////////////////////////////////////////////////////////////
// Wait
/////////////////////////////////////////////////////////////////////
class CBTTaskWait extends IBehTreeTask
{
	editable var minTime : float;
	editable var maxTime : float;
	
	default minTime = 1.0;
	default maxTime = 1.0;
	
	latent function Main() : EBTNodeStatus
	{
		var time : float;		
		time = RandRangeF( minTime, maxTime );
		Sleep( time );
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// WaitWhileTargetFar
/////////////////////////////////////////////////////////////////////
class CBTTaskWaitWhileTargetFar extends IBehTreeTask
{
	editable var distance : float;
	editable var checkPeriod : float;
	default distance = 3.0f;
	default checkPeriod = 0.5f;

	latent function Main() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		npc = GetNPC();
		while(1)
		{
			target = npc.GetTarget();
			if( !target )
				return BTNS_Failed;
				
			if( VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() ) < distance )
			{
				return BTNS_Completed;
			}
			
			Sleep( checkPeriod );
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// WaitWhileTargetOutsideAttackRange
/////////////////////////////////////////////////////////////////////
class CBTTaskWaitWhileTargetOutsideAttackRange extends IBehTreeTask
{
	editable var checkPeriod : float;
	default checkPeriod = 0.5f;

	latent function Main() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		npc = GetNPC();
		while(1)
		{
			target = npc.GetTarget();
			if( !target )
				return BTNS_Failed;
				
			if( npc.InAttackRange( target ) )
			{
				return BTNS_Completed;
			}
			
			Sleep( checkPeriod );
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// WaitWhileTargetMoving
/////////////////////////////////////////////////////////////////////
class CBTTaskWaitWhileTargetMoving extends IBehTreeTask
{
	editable var checkPeriod : float;
	editable var initialDelay : float;
	default checkPeriod = 0.5f;
	default initialDelay = 0.5f;

	latent function Main() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		npc = GetNPC();		
		while(1)
		{
			target = npc.GetTarget();
			if( !target )
				return BTNS_Failed;
				
				
			if( initialDelay > 0.0 )
			{
				Sleep( initialDelay );
			}
				
			if( !target.IsMoving() )
			{
				return BTNS_Completed;
			}
			
			Sleep( checkPeriod );
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// WaitBeforeAttack
/////////////////////////////////////////////////////////////////////
class CBTTaskWaitBeforeAttack extends IBehTreeTask
{
	private var attackDelay : float;

	function OnBegin() : EBTNodeStatus
	{
		var usedSlots : int;
		var target : CActor;
		var npc : CNewNPC;		
		
		npc = GetNPC();
		target = npc.GetTarget();
				
		// attack or sleep
		usedSlots = ( target.GetCombatSlots().GetNumAllCombatSlots() - target.GetCombatSlots().GetNumFreeCombatSlots() );
		attackDelay = 1.0 + ( usedSlots / 3 );
		if( theGame.GetEngineTime() - target.GetLastTimeAttacked() < attackDelay )
		{
			return BTNS_Active;			
		}
		
		return BTNS_Completed;
	}

	latent function Main() : EBTNodeStatus
	{
		var sleepTime : float;
		sleepTime = attackDelay;
		sleepTime = MaxF( sleepTime, 0.1 );
		Sleep( sleepTime );
		return BTNS_Completed;
	}
}