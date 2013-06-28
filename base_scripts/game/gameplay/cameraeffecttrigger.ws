//////////////////////////////////////////
// CAMERA EFFECT TRIGGER CLASS	       	//
//////////////////////////////////////////

/*
class CCameraEffectTrigger extends CEntity
{
	editable var effectName : CName;
	var isPlayingEffect : Bool;
	
	default isPlayingEffect = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i_triggered : CEntity;
		i_triggered = activator.GetEntity();
		
		if ( i_triggered.IsA ( 'CCamera' ) && ! isPlayingEffect )
		{
			isPlayingEffect = true;
			i_triggered.PlayEffect( effectName );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i_triggered : CEntity;
		i_triggered = activator.GetEntity();
		
		if ( i_triggered.IsA ( 'CCamera' ) && isPlayingEffect )
		{
			isPlayingEffect = false;
			i_triggered.StopEffect( effectName );
		}
	}
}
*/