enum EFinisherDistance
{
	FD_Far,
	FD_Medium,
	FD_Close
}
enum EFinisherAreaNum
{
	FA_NoArea,
	FA_Area01,
	FA_Area02,
	FA_Area03,
	FA_Area04,
	FA_Area05,
	FA_Area06,
	FA_Area07,
	FA_Area08,
	FA_Area09,
	FA_Area10
}

class CCommentaryTrigger extends CGameplayEntity
{
	editable saved var disableOnExit : bool;
	editable saved var commentaryType : EPlayerCommentary;
	editable saved var commentaryCooldown : float;
	
	default disableOnExit = false;
	default commentaryCooldown = 0.0f;
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		//Init();
		super.OnSpawned(spawnData);
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			if(thePlayer.PlayerCanPlayCommentary())
				thePlayer.PlayerCommentary(commentaryType, commentaryCooldown);
			if(disableOnExit)
			{
				area.SetEnabled(false);
			}
		}
	}
}
class CTutorialTrigger extends CGameplayEntity
{
	editable var tutorialName : string;
	editable var imageName : string;
	editable var slowTime : bool;
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		//Init();
		super.OnSpawned(spawnData);
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			theHud.m_hud.ShowTutorial(tutorialName, imageName, slowTime);
			//theHud.ShowTutorialPanelOld( tutorialName, imageName );
			area.SetEnabled(false);
		}
	}
}
class CFFLootOnTrigger extends CGameplayEntity
{
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		//Init();
		super.OnSpawned(spawnData);
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			thePlayer.SetFFLootEnabled(true);
			if(thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
			{
				theGame.EnableButtonInteractions( true );
			}
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			thePlayer.SetFFLootEnabled(false);
			if(thePlayer.GetCurrentPlayerState() == PS_CombatFistfightDynamic)
			{
				theGame.EnableButtonInteractions( false );
			}
		}
	}
}
class CFinisherArea extends CGameplayEntity
{
	editable var finisherAreaNum : EFinisherAreaNum;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			thePlayer.SetPlayerFinisherArea(finisherAreaNum);
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var activatorActor : CActor;
		activatorActor = (CActor) activator.GetEntity();
		if(activatorActor == thePlayer)
		{
			thePlayer.SetPlayerFinisherArea(FA_NoArea);
		}
	}
}
class CFinisherSpot extends CEntity
{
	editable var finisherDistance : EFinisherDistance;
	editable var finisherAreaNum : EFinisherAreaNum;
	default finisherDistance = FD_Far;
	
	function GetFinisherArea() : EFinisherAreaNum
	{
		return finisherAreaNum;
	}
	function GetFinisherDistance() : EFinisherDistance
	{
		return finisherDistance;
	}
}