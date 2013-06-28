/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Despawning state
/////////////////////////////////////////////

state Despawning in CNewNPC extends Base
{
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
	}
	
	// Despawn
	entry function StateDespawnAtPlace( despawnPoint : Vector, isHiddenDespawn : bool, goalId : int )
	{
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
	
		// Release current action point
		if ( parent.GetActiveActionPoint() )
		{
			theGame.GetAPManager().SetFree( parent.GetName(), parent.GetActiveActionPoint() );
		}
	
		// Return items to original owners
		parent.GiveBackItemsToOrgOwner();		
		
		// Go to despawn point if we found one
		parent.ActionMoveTo( despawnPoint, parent.GetModifiedMoveType( MT_Walk ) );

		DestroyNpcWhenPossible( isHiddenDespawn );
	}
	
	entry function StateDespawn( goalId : int, isHiddenDespawn : bool )
	{
		var despawnPoint : Vector;
		var foundDespawnPoint : bool;
		
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		foundDespawnPoint = false;

		// Release current action point
		if ( parent.GetActiveActionPoint() )
		{
			theGame.GetAPManager().SetFree( parent.GetName(), parent.GetActiveActionPoint() );
		}
		
		// Return items to original owners
		parent.GiveBackItemsToOrgOwner();		
		
		// Go to despawn point if we found one
		foundDespawnPoint = parent.GetDefaultDespawnPoint( despawnPoint );
		if ( foundDespawnPoint )
		{
			parent.ActionMoveTo( despawnPoint, parent.GetModifiedMoveType( MT_Walk ) );
		}

		DestroyNpcWhenPossible( isHiddenDespawn );
	}
	
	// Despawn
	entry function StateForceDespawn( goalId : int )
	{
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
	
		// Release current action point
		if ( parent.GetActiveActionPoint() )
		{
			theGame.GetAPManager().SetFree( parent.GetName(), parent.GetActiveActionPoint() );
		}

		// Return items to original owners
		parent.GiveBackItemsToOrgOwner();		

		//parent.UnregisterEntity();
		parent.GetArbitrator().ClearAllGoals();

		// Destroy entity
		parent.Destroy();	
	}
	
	private latent function DestroyNpcWhenPossible( isHiddenDespawn : bool )
	{
		var i : int = 0;
		
		// If NPC should be despawne out of camera than wait for that occasion
		if ( isHiddenDespawn )
		{
			while( !parent.CanBeDesctructed() && i < 240 )
			{
				Sleep(0.2);
				i += 1;
			}
		}
	
		//parent.GetArbitrator().ChangeGoalPriority( GetGoalId(), PRIORITY_VALUE_HIGH );
		virtual_parent.OnBeforeDestroy();
		
		//parent.UnregisterEntity();
		parent.GetArbitrator().ClearAllGoals();

		// Destroy entity
		parent.Destroy();	
	}
}
