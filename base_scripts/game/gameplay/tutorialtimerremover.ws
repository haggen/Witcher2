class W2TutorialTimerRemover extends CGameplayEntity
{
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if ( affectedEntity.IsA( 'CPlayer' ) )
		{
			thePlayer.RemoveTimer( 'ShowInventoryTutorial' );
			thePlayer.RemoveTimer( 'ShowWelcomeTutorials' );
			thePlayer.RemoveTimer( 'ShowTutorialPackage' );
		}
	}

}
