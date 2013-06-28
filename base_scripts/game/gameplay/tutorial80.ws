class W2ElixirTutorial extends CGameplayEntity
{
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			//theHud.m_hud.HideTutorial();
			//theHud.m_hud.UnlockTutorial();
			//theHud.m_hud.ShowTutorial("tut80", "", false); // <-- tutorial content is present in external tutorial - disabled
			//theHud.ShowTutorialPanelOld( "tut80", "" );
		}
	}
}
