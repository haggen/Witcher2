//////////////////////////////////////////
// CAMERA EFFECT TRIGGER CLASS	       	//
//////////////////////////////////////////

class CObjectEffectTrigger extends CEntity
{
	editable var effectName : CName;
	editable var objectsTag : CName;
	editable var stopEffectOnExit : bool;
	var isPlayingEffect : Bool;
	
	default isPlayingEffect = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		startEffect();
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( stopEffectOnExit)
		{
			stopEffect();
		}
	}
}

state PlayingEffect in CObjectEffectTrigger
{
	entry function startEffect()
	{
		var targets : array<CNode>;
		var singleEntity : CEntity;
		var sucess : bool;
		var i : int;
		
		theGame.GetNodesByTag( parent.objectsTag, targets );
		
		for( i=0;i<targets.Size();i+=1 )
		{
			singleEntity = (CEntity) targets[i];
			
			if(!singleEntity)
			{
				Log( "EFFECT TRIGGER: TARGET ENTITIES NOT FOUND");
				continue;
			}
			
			sucess = singleEntity.PlayEffect( parent.effectName );
			Log("EFFECT TRIGGER " + parent + ": PLAYING EFFECT FAILED");
			
			continue;
		}
	}
}

state StoppingEffect in CObjectEffectTrigger
{
	entry function stopEffect()
	{
		var targets : array<CNode>;
		var singleEntity : CEntity;
		var i : int;
		
		theGame.GetNodesByTag( parent.objectsTag, targets );
		
		for( i=0;i<targets.Size();i+=1 )
		{
			singleEntity = (CEntity) targets[i];
			
			if(!singleEntity)
			{
				continue;
			}
			
			singleEntity.StopEffect( parent.effectName );
			
			continue;
		}
	}
}