/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Unconscious state
/////////////////////////////////////////////
state Unconscious in CNewNPC extends Base
{
	var mayWakeUp : bool;
	default mayWakeUp = true;
	
	event OnEnterState()
	{
		// don't pass to base class
		//super.OnEnterState();		
		
		parent.SetAlive(false);
		
		parent.ClearRotationTarget();		
		//theHud.m_hud.CombatLogAdd("<span class='orange'>"+ parent.GetDisplayName() + "</span> " + GetLocStringByKeyExt("cl_unc") + "!");
	}
	
	event OnLeaveState()
	{		
		parent.GetMovingAgentComponent().SetEnabledRestorePosition(true);		
		
		// emergency unhide
		theGame.GetFistfightManagerWithoutCreation().UnhideActor( parent );
	}
	
	event OnLeavingState()
	{
		return mayWakeUp;
	}
	
	event OnDespawn( forced : bool )	
	{
		mayWakeUp = true;
	}
	
	event OnBreakUncoscious()
	{
		ExitUnconsciousInternal();
	}
	
	private function InformUnconscious()
	{
		var tags : array< name >;
		var i : int;
	
		// INFORM PLAYER
		thePlayer.OnNPCStunned(parent);
				
		// ADD FACTS
		tags = parent.GetTags();
		for( i=0; i<tags.Size(); i+=1 )
		{
			FactsAdd( "actor_" + tags[i] + "_was_stunned", 1 );
		}
	}

	// Stun NPC for a while
	entry function StateUnconscious( deathData : SActorDeathData, restored : bool, goalId : int )
	{
		var eventName : name;
		var waitTime : float;
		var itemTags : array< name >;
		
		SetGoalId( goalId );
		
		if( !restored )
		{
			InformUnconscious();
		}		
				
		mayWakeUp = false;
		
		if( deathData.noActionCancelling == false )
		{
			parent.ActionCancelAll();
		}
		
		if( restored )
		{
			parent.RaiseForceEvent( 'UnconsciousForced' );
		}
		else
		{
			if( !deathData.silent )
			{
				parent.ActivateBehavior('npc_exploration');
				Sleep(0.1);
				if( Rand(2) == 0 )
				{
					eventName = 'Unconscious1';
				}
				else
				{
					eventName = 'Unconscious2';
				}
				
				parent.RaiseForceEvent( eventName );
			}
		}
		
		Sleep(1.5);
		
		virtual_parent.UnconsciousStarted();
		
		if( !restored )
		{	
			// THROW AWAY ITEMS
			if ( parent.dropLootWhenUnconcious )
			{
				itemTags.PushBack( 'NoDrop' );
				parent.GetInventory().ThrowAwayItemsFiltered( itemTags );
			}		
		}
		
		// DISABLE MAC
		parent.GetMovingAgentComponent().SetEnabledRestorePosition(false);
		
		WaitForStaticFistfightEnd();
		
		// If time set uncoscious for some time, otherwise forever		
		if (parent.unconciousTime > 0)
		{
			waitTime = parent.unconciousTime;	
			Sleep( waitTime );
		}
		else
		{
			while(1)
			{
				Sleep(100);
			}
		}
		
		// Exit unconscious
		ExitUnconsciousInternal();
	}
	
	private entry function ExitUnconsciousInternal()
	{
		// TRY TO ENABLE PATHENGINE, CONTINUE SLEEPING IF FAILED
		var mac : CMovingAgentComponent = parent.GetMovingAgentComponent();
		while( mac && ( mac.SetEnabledRestorePosition(true) == false ) )
		{
			Sleep( 5.0 );
		}
		
		parent.ResetStats();		
		parent.RaiseForceEvent( 'Idle' );
		parent.PlayVoiceset( 100, "what_happened" );
		
		mayWakeUp = true;
		
		virtual_parent.UnconsciousEnded();
		
		// Go back to idle		
		parent.GetArbitrator().AddGoalIdle( true );
		MarkGoalFinished();
	}
		
	private latent function WaitForStaticFistfightEnd()
	{
		var ffMgr : W2FistfightManager = theGame.GetFistfightManagerWithoutCreation();
		if( ffMgr )
		{
			while( ffMgr.IsActorHidden( parent ) )
			{
				Sleep(1.0f);
			}
		}
	}
}

