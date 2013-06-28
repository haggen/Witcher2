class CDragonTower extends CEntity
{	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var stateIdx : int;
		
		super.OnSpawned( spawnData );
		
		stateIdx = GetDestructionStateIdx();
		switch( stateIdx )
		{
			case 0: Intact();
					break;
				
			case 1: PartiallyDestroyed();
					break;
				
			case 2: SeverelyDestroyed();
					break;
					
			case 3: TotalyDestroyed();
					break;
					
			default: TotalyDestroyed();
		}
	}
	
	function SwitchToNextState()
	{
		FactsAdd( "dragon_tower_state", 1 );
	}
	
	function GetDestructionStateIdx() : int 
	{
		return FactsQuerySum( "dragon_tower_state" );
	}
}

state Intact in CDragonTower
{
	entry function Intact()
	{
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorForceEvent( 'toStage1' );
	}
}

state FirstDestruction in CDragonTower
{
	entry function FirstDestruction()
	{
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorEvent( 'destroy' );
		parent.SwitchToNextState();
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'destroy1' )
		{
			parent.PlayEffect('destroy_1');
		}
		else if ( eventName == 'animEndAUX' )
		{
			parent.PartiallyDestroyed();
		}
		else if ( eventName == 'floor_hole' )
		{
			CheckIfPlayerFalls();
		}
	}
	
	function CheckIfPlayerFalls()
	{
		var trigger : CEntity;
		var comp : CTriggerAreaComponent;
		
		trigger = theGame.GetEntityByTag( 'q307_floor_hole_trigger' );
		comp = (CTriggerAreaComponent)trigger.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		if( comp.TestPointOverlap( thePlayer.GetWorldPosition() ) )
			thePlayer.StateDeadFall();
	}
}

state PartiallyDestroyed in CDragonTower
{
	entry function PartiallyDestroyed()
	{
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorForceEvent( 'toStage2' );
	}
}

state SecondDestruction in CDragonTower
{
	entry function SecondDestruction()
	{
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorEvent( 'destroy' );
		parent.SwitchToNextState();
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'destroy2' )
		{
			parent.PlayEffect('deatroy_2');
		}
		else if ( eventName == 'animEndAUX' )
		{
			parent.SeverelyDestroyed();
		}
	}
}

state SeverelyDestroyed in CDragonTower
{
	entry function SeverelyDestroyed()
	{
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorForceEvent( 'toStage3' );
	}
}

state FinalDestruction in CDragonTower
{
	entry function FinalDestruction( optional raiseEvent : bool )
	{
		var comp : CDrawableComponent;
		var i : int;
		
		if( raiseEvent )
			((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorEvent( 'destroy' );
		
		for( i = 1; i < 9; i += 1 )
		{
			comp = (CDrawableComponent)parent.GetComponent("ceiling" + i);
			comp.SetVisible(false);
		}
		
		comp = (CDrawableComponent)parent.GetComponent( "window" );
		comp.SetVisible( true );
		
		parent.SwitchToNextState();
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'destroy3' )
		{
			parent.PlayEffect('destroy_3');
		}
		else if ( eventName == 'animEndAUX' )
		{
			parent.TotalyDestroyed();
		}
	}
}

state TotalyDestroyed in CDragonTower
{
	entry function TotalyDestroyed()
	{
		var comp : CDrawableComponent;
		var i : int;
		
		for( i = 1; i < 9; i += 1 )
		{
			comp = (CDrawableComponent)parent.GetComponent("ceiling" + i);
			comp.SetVisible(false);
		}
		
		((CAnimatedComponent)parent.GetComponent("tower")).RaiseBehaviorForceEvent( 'toStage4' );
	}
}

exec function TowerState()
{
	var dragonTower : CDragonTower;
	var index : int;
	
	dragonTower = (CDragonTower)theGame.GetEntityByTag('dragon_tower');
	index = dragonTower.GetDestructionStateIdx();
	index += 0;
}

exec function towerdest()
{
	var dragonTower : CDragonTower;
	
	dragonTower = (CDragonTower)theGame.GetEntityByTag('dragon_tower');
	dragonTower.TotalyDestroyed();
}