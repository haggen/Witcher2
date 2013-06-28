/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Static fistfight state
/////////////////////////////////////////////
state CombatFistStatic in CNewNPC extends Base
{
	var combatParams 		: SCombatParams;
	
	var LOW_HEALTH_LEVEL : float;
	
	default LOW_HEALTH_LEVEL = 10.0f;

	event OnEnterState()
	{
		var id : SItemUniqueId;
	
		var itemId1 : SItemUniqueId;
		var itemId2 : SItemUniqueId;
		super.OnEnterState();
		
		parent.EmptyHands();

		parent.ShowHealthBar();
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		if( parent.IsAlive() )
		{
			parent.GetMovingAgentComponent().SetEnabledRestorePosition(true);
		}
		theGame.GetFistfightManager().DequeueNPC( parent );
	}
	
	///////////////////////////////////////////////////////////////////////
	// Standard events handlers
	///////////////////////////////////////////////////////////////////////
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{		
		if( animEventName == 'ShakeLight' )
		{
			theCamera.ExecuteCameraShake(CShake_Hit, 0.6); 
		}
		else if( animEventName == 'ShakeHeavy' )
		{
			theCamera.ExecuteCameraShake(CShake_Hit, 0.8);
		}
		else if( animEventName == 'HitLight' )
		{
			parent.PlayEffect('fistfight_hit');
			theGame.GetFistfightManager().OnHit( parent );
			parent.ShowHealthBar();
		}
		else if( animEventName == 'HitHeavy' ) 
		{
			parent.PlayEffect('fistfight_strong');
			theGame.GetFistfightManager().OnHit( parent );
			parent.ShowHealthBar();
		}
		else if( animEventName == 'HitKnockdown' )
		{			
			parent.PlayEffect('fistfight_strong');
		}
	}
	
	///////////////////////////////////////////////////////////////////////
	// Fistfight state management
	///////////////////////////////////////////////////////////////////////
	
	// It's the NPC who initializes the static fistfight.
	// This method is the first one in line, and it kicks off a static 
	// fistfight event.
	entry function CombatFistStatic( params : SCombatParams )	
	{
		var res 		: bool;
		var exBeh 		: bool;
		var enemy		: CActor;


		enemy = parent.GetTarget();
		parent.SetCombatHighlight( false );
		if( enemy != thePlayer )
		{
			parent.SetErrorState("Fistfight enemy is not player");
		}
			
		// Query the fistfight manager for a fistfight arrangements
		theGame.GetFistfightManager().QueueNPC( parent );
	}
};
