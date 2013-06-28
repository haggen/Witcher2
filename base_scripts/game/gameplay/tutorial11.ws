class W2AardBlockadesTutorial extends CGameplayEntity
{
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			theHud.m_hud.HideTutorial();
			theHud.m_hud.UnlockTutorial();
			theHud.m_hud.ShowTutorial("tut11", "tut11_333x166", false);
			//theHud.ShowTutorialPanelOld( "tut11", "tut11_333x166" );
		}
	}

}
