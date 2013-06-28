/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Trigger Fact Entity
/** Copyright © 2011
/***********************************************************************/

import class CTriggerEntity extends CGameplayEntity
{
	import final function AddProperFact( factName : string, factValue : int );
}

class W2FactTriggerEntity extends CEntity
{
	editable var factName : string;
	editable var factValue : int;
	editable var triggerEntityTag : name;

	// Something has entered trigger area owned by this entity
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity = theGame.GetEntityByTag( triggerEntityTag );
		var triggerEntity : CTriggerEntity;
		triggerEntity  = ( CTriggerEntity ) entity;
	
		if ( triggerEntity && activator.GetEntity().IsA( 'CPlayer' ) )
		{
			triggerEntity.AddProperFact( factName, factValue );
		}
		
		super.OnAreaEnter( area, activator );
	}
}