class W2MinimapTutorial extends CGameplayEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			/*
			if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				theHud.m_hud.ShowTutorial("tut104", "tut04_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut104", "tut04_333x166" );
			}
			else
			{
				theHud.m_hud.HideTutorial();
				theHud.m_hud.UnlockTutorial();
				theHud.m_hud.ShowTutorial("tut04", "tut04_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut04", "tut04_333x166" );
			}
			*/
		}
	}
	


}
