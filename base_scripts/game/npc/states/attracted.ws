state AttractedByLure in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}

	entry function StateAttractedByLure( lureHandle : EntityHandle, goalId : int )
	{
		var pos : Vector;
		var norm : Vector;
		var lure : CLure;
		var monster : W2Monster;
		monster = (W2Monster)parent;
		SetGoalId( goalId );
		if(monster)
		{
			
			lure = (CLure)monster.GetLure();
			if(lure)
			{
				//parent.ChangeNpcExplorationBehavior();
				
				norm = VecNormalize( lure.GetWorldPosition() - parent.GetWorldPosition() );
				pos = lure.GetWorldPosition() + norm;
				parent.ActionMoveTo( pos, MT_Run, 1.f, 2.f );
				lure.AddTimer('TimerDestroyLure', 4.0);
				
				Sleep(5.0f);
			}
		}
		MarkGoalFinished();
		
	}
};