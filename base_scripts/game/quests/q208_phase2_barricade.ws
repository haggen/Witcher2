// Klasa obslugujaca barykade w quescie q208 - faza 2

state Burning in q208_baricade
{
	entry function q208_activate_burning()
	{
		parent.destructionComponent = (CDestructionSystemComponent) parent.GetComponentByClassName( 'CDestructionSystemComponent' );
		parent.PlayEffect('burning_fx');
		parent.PlayEffect('burn_wood_fx');
		Sleep(6.0f);
		parent.destructionComponent.ApplyScriptedDamage(-1, 101);
		Sleep(1.0f);
		parent.PlayEffect('burn_wood_fx');
		Sleep(6.0f);
		parent.destructionComponent.ApplyScriptedDamage(-1, 101);
		Sleep(6.0f);
		parent.StopEffect('burning_fx');
		parent.destructionComponent.ApplyScriptedDamage(-1, 101);
		if(parent.isInside)
		{
			FactsAdd( "q208_geralt_near_barricade", -1 );
		}
		parent.canEnter = false;
		parent.GetComponentByClassName('CDeniedAreaComponent').SetEnabled(false);
	}
}

class q208_baricade extends CGameplayEntity
{
	var destructionComponent : CDestructionSystemComponent;
	var isBeingDestroyed : bool;
	var canEnter : bool;
	var isInside : bool;
	default canEnter = true;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
	}
	function DestroyBarricade()
	{
		if(!isBeingDestroyed)
		{
			isBeingDestroyed = true;
			q208_activate_burning();
		}
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor)activator.GetEntity();

		if ( activatorActor == thePlayer && canEnter)
		{
			isInside = true;
			FactsAdd( "q208_geralt_near_barricade", 1 );
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor)activator.GetEntity();

		if ( activatorActor == thePlayer && canEnter)
		{
			isInside = false;
			FactsAdd( "q208_geralt_near_barricade", -1 );
		}
	}
}