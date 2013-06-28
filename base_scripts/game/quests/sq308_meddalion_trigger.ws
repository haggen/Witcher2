class CMedallionTriggerSQ308 extends CGameplayEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			AddTimer('BlinkMedallion', 5.0, true);
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			RemoveTimer('BlinkMedallion');
		}
	}
	
	timer function BlinkMedallion( timeDelta : float )
	{
		theHud.Invoke("vHUD.blinkMed");
		theSound.PlaySound("gui/hud/medalionwarning");
	}
}