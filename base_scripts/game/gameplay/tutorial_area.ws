class CTutorialArea extends CGameplayEntity
{
	editable var tutorialId : string;
	editable var imageName : string;
	editable var slowTime : bool;
	saved var wasVisited : bool;
	
	default wasVisited = false;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			theHud.m_hud.ShowTutorial( tutorialId, imageName, slowTime);
			//theHud.ShowTutorialPanelOld( tutorialId, imageName );
			wasVisited = true;
		}
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
		}
	}
	
}
