/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher jacket
/** Copyright © 2010
/***********************************************************************/

class CRoadSpawner extends CGameplayEntity
{	
	editable var spawnedEntity : CEntityTemplate;
	
	event OnAreaEnter(area : CTriggerAreaComponent, activator : CComponent)
	{
		theGame.CreateEntity( spawnedEntity, this.GetWorldPosition(), this.GetWorldRotation() );
		theCamera.ExecuteCameraShake( CShake_Hit, 0.1 );
	}
	event OnAreaExit( area: CTriggerAreaComponent, activator: CComponent )
	{
	}	
	
}

class CRoadMesh extends CGameplayEntity
{	
	editable var arrow : CEntityTemplate;
	
	event OnAreaEnter(area : CTriggerAreaComponent, activator : CComponent)
	{
		this.PlayEffect('marker_fx');
		this.PlayEffect('destroy_fx');
	}
	event OnAreaExit( area: CTriggerAreaComponent, activator: CComponent )
	{
		this.Destroy();
	}	
	
}

class CRoadTrigger extends CTriggerAreaComponent
{
}