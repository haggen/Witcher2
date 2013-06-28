class W2PlayerStorage extends CGameplayEntity
{
	private var priceMultiplicator : float;
	
	default priceMultiplicator = 0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		SetPriceMultiplicator();
	}

	event OnInteraction( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			theHud.ShowShopNew( thePlayer, true, this );
		}	
	}
	
	private function SetPriceMultiplicator()
	{
		priceMultiplicator = 0;
	}
	
	private function GetPriceMultiplicator() : float
	{
		return priceMultiplicator;
	}
	
	private function ToggleInteraction( isDisabled : bool )
	{
		this.GetComponentByClassName('CInteractionComponent').SetEnabled( isDisabled );
	}
}
