// Dream stone entity
class CDreamStone extends CGameplayEntity
{
	saved var stoneActive : bool;
	default stoneActive = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		RestoreStonesState();
	}
	
	function EnableStone( enable : bool )
	{
		SetStoneState(  enable );
		stoneActive = enable;
	}
	

	// ------------------------------------------------------------------------
	// Sub stones state mgmt.
	// ------------------------------------------------------------------------
	private function RestoreStonesState()
	{
		SetStoneState( stoneActive );
	}
	
	private function SetStoneState( enable : bool ) : bool
	{
		var drawableComp : CStaticMeshComponent;
		var interactionComp : CInteractionComponent;
		
		drawableComp = ((CStaticMeshComponent)GetComponentByClassName('CStaticMeshComponent'));
		interactionComp = ((CInteractionComponent)GetComponentByClassName('CInteractionComponent'));
		
		if ( !drawableComp || !interactionComp )
		{
			Log( " Dream stone doesn't have the required components" );
			return false;
		}
		
		drawableComp.SetVisible( enable );
		interactionComp.SetEnabled( enable );

		// ustawiasz flage show
		// odpalasz efekty
		// itd.
		
		return true;
	}

}

// ------------------------------------------------------------------------
// Quests management interface
// ------------------------------------------------------------------------

quest function ManageDreamStone(tag: name, enable : bool) : bool
{
	var dreamStone : CDreamStone;
	
	dreamStone = (CDreamStone)theGame.GetEntityByTag( tag );
	if ( !dreamStone )
	{
		return false;
	}
	
	dreamStone.EnableStone( enable );
}