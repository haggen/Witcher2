class CDayNightChangingEntity extends CGameplayEntity
{

	var isOpened : bool;

	function CheckState()
	{
		if ( theGame.GetIsDay() )
		{
			isOpened = true;
			SetVisualsOpen();
		}
		else
		{
			isOpened = false;
			SetVisualsClose();
		}
	}
	
	timer function TimerCheck( timeDelta : float )
	{
		CheckState();
	}
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		CheckState();
		AddTimer( 'TimerCheck', 10.0, true );
	}
	
	event OnDestroyed() 
	{
		RemoveTimer( 'TimerCheck' );
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
			CheckState();
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
			CheckState();
	}
	
	function SetVisualsOpen()
	{
		ApplyAppearance( "unpacked" );
	}
	
	function SetVisualsClose()
	{
		ApplyAppearance( "packed" );
	}
}
