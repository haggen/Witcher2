/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Takedown slave state
/** Copyright © 2010
/***********************************************************************/

latent function NPCEnterTakedown( npc : CNewNPC, optional timeout : float ) : bool
{
	var arbitrator : CAIArbitrator = npc.GetArbitrator();
	var startTime : EngineTime;
	var cs : name;
	
	if( timeout <= 0.0f )
	{
		timeout = 1.0f;
	}
	
	startTime = theGame.GetEngineTime();
	arbitrator.AddGoalTakedown();	
	do
	{
		Sleep( 0.001 );
		cs = npc.GetCurrentStateName();		
		
		if( theGame.GetEngineTime() - startTime > timeout )
		{
			return false;
		}
	}
	while( cs != 'Takedown' );
	
	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
state Takedown in CNewNPC extends Base
{
	private var destNode : CNode;
	private var takedownArea : W2TakedownArea;
	
	private function StateInit()
	{
		parent.StopAllScenes();
		parent.EndLine();
		parent.ActionCancelAll();
		parent.GetArbitrator().ClearAllGoals();
	}
	
	entry function StateTakedownEntry( goalId : int )
	{
		SetGoalId( goalId );
		parent.StopAllScenes();
		parent.EndLine();
		parent.ActionCancelAll();
	}
	
	entry function StateTakedown( node : CNode, useSlot : bool, takedownArea : W2TakedownArea )
	{
		StateInit();
		if( useSlot )
			parent.AttachBehavior('npc_takedown_slot' );
		else
		{
			parent.AttachBehavior('npc_takedown' );
			if( parent.GetMovementType() == EX_CarryTorch )
			{				
				parent.SetBehaviorVariable( "TorchWeight", 1.f );
			}
			else
			{
				parent.SetBehaviorVariable( "TorchWeight", 0.f );
			}
		}
			
		//parent.ActivateBehavior( 'npc_takedown' );	
		destNode = node;
		this.takedownArea = takedownArea;
		
	}
	
	entry function StateTakedownFistfight()
	{
		parent.AttachBehavior( 'fistfight_takedown' );
	}
	
	entry function StateTakedownFistfightEnd( time : float )
	{
		Sleep( time );
		MarkGoalFinished();
	}
	
	entry function StateTakedownSticky()
	{
		StateInit();
	}
	
	entry function StateTakedownPlaySlotAnim( anim : name )
	{
		parent.ActionPlaySlotAnimation( 'TAKEDOWN', anim, 0.0f, 0.0f, true );
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var weaponId : SItemUniqueId;
		
		if (animEventName == 'DropTorch')
		{
			parent.GetInventory().DropItem( parent.GetCurrentWeapon() );
		}
		
		/*if (animEventName == 'SetRagdoll')
		{
			weaponId = parent.GetInventory().GetItemId('Executioner Shield');
			parent.GetInventory().DropItem( weaponId );
			parent.GetInventory().DropItem( parent.GetCurrentWeapon() );
		}*/
		if (animEventName == 'Blood_event')
		{
			parent.PlayEffect('standard_hit_fx');
		}
		
	
		/*if( animEventName == 'Slide' )
		{
			StateTakedownSlide();
		}*/
	}
	
	event OnAardHitReaction( aard : CWitcherSignAard )
	{
		//parent.SetAlive(false);
		//parent.GetMovingAgentComponent().SetEnabled(false);
		//parent.RaiseEvent('stealth_takedown_env01');
		//StateTakedownSlide();
	}
	
	entry function StateTakedownSlide()
	{
		var comp : CAnimatedComponent;
		var impulse : Vector;
		var destPos : Vector;
		
		//parent.Kill( true, thePlayer );
		/*parent.SetAlive( false );
		parent.SetRagdoll( true );
		
		comp = (CAnimatedComponent)parent.GetComponent( "Character" );
		
		comp.SetCanStickToMesh('Ragdoll_torso2');
		comp.SetCanStickToMesh('Ragdoll_torso');
		comp.SetCanStickToMesh('Ragdoll_pelvis');
		comp.SetCanStickToMesh('Ragdoll_head');		
		
		destPos = destNode.GetWorldPosition();
		impulse = VecNormalize( destPos - thePlayer.GetWorldPosition() );
		impulse.Z = 0.3f;
		
		impulse = impulse * 500.f;
		impulse.W = 1.f;
		
		comp.SetRootBoneImpulse( impulse );
		
		Sleep(2.0);
		
		parent.Kill( true, thePlayer );*/
	
		/*var speed : float = 10.0;
		var dist, time, sleepTime : float;
		var destPos : Vector;
		var slept : float;
		if( destNode )
		{
			destPos = destNode.GetWorldPosition();
			dist = VecDistance( parent.GetWorldPosition(), destPos );
			time = dist/speed;
			parent.ActionSlideToWithHeadingAsync( destPos, destNode.GetHeading(), time );		
			
			theCamera.ExecuteCameraShake(CShake_Hit, 0.8);		
			
			sleepTime = MaxF(0.0, time - 0.2 );			
			Sleep( sleepTime );
			slept += sleepTime;
			
			takedownArea.PerformEndAction();
			
			sleepTime = MaxF( 0.0, time - slept - 0.1 );
			Sleep( sleepTime );
			slept += sleepTime;
			
			parent.SetBehaviorVariable("slideEnded", 1.0);
			parent.PlayBloodOnHit();	
			theCamera.ExecuteCameraShake(CShake_Hit, 1.0);		
			
			sleepTime = MaxF( 0.0, time - slept );
			Sleep( sleepTime );
			
			parent.silentDeath = true;			
			parent.Kill(true, thePlayer);			
		}*/
		
	
	}
};

state TakedownObserve in CNewNPC extends Base
{
	event OnLeaveState()
	{
		parent.ClearRotationTarget();
	}

	entry function StateTakedownObserve( goalId : int )
	{
		var dist  : float;
		SetGoalId( goalId );
		
		parent.ActionCancelAll();
		parent.SetRotationTarget( thePlayer );
		dist = VecDistance( parent.GetWorldPosition(), thePlayer.GetWorldPosition() );
		if( dist < 4.0 )
		{
			parent.ActionMoveAwayFromNode( thePlayer, 4.5, MT_Walk, 1.0, 2.0 );
		}
		
		while(1)
		{			
			Sleep(5.0f);
		}
	}
}
