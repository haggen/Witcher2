// Klasa obslugujaca sytuacje w ktorej gracz przestaje podazac za postacia ( oddala sie na tyle daleko, ze postac 'gubi' gracza )
// factID: follower_observer_lost, jesli 1, to znaczy, ze postac zostala zgubiona

class CFollObservItem extends CItemEntity
{
	var enable : bool;
	var sum : int;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
	
		Log("follower_observer_item created <<<-------------------- ");
		FactsAdd( 'follower_observer_lost' , 0);
		enable = true;
	}

	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		var actor : CActor;
		actor = (CActor)activator;
		
		if(activator.IsA( 'CPlayer' )&& enable)
		{
			sum = FactsQuerySum('follower_observer_lost');
			Log("follower_observer_item activated <<<-------------------- " + (-sum));
			FactsAdd( 'follower_observer_lost' , -sum);			
		}
	}
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
	
		var actor : CActor;
		actor = (CActor)activator;
		
		if(activator.IsA( 'CPlayer' ) && enable)
		{
			Log("follower_observer_item deactivated <<<-------------------- +1");
			FactsAdd( 'follower_observer_lost' , 1);
		}
	}
	event OnDestroyed()
	{
		sum = FactsQuerySum('follower_observer_lost');
		Log("follower_observer_item destroyed <<<-------------------- " + (-sum) );
		FactsAdd( 'follower_observer_lost' , -sum);
	}
}
