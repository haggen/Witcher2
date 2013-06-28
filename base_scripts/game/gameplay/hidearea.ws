//klasa pozwalajaca na ustawienie Geraltowi atrybutu isHidden, decydujacego o tym czy gracz jest widoczny czy nie.
class CHideArea extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		var player : CPlayer;	
		
		player = thePlayer;
		affectedEntity = activator.GetEntity();
		
		if( affectedEntity.IsA( 'CPlayer' ) )
		{
			player.SetIsHidden(true);
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		var player : CPlayer;	
		
		player = thePlayer;
		affectedEntity = activator.GetEntity();
		
		if( affectedEntity.IsA( 'CPlayer' ) )
		{
			player.SetIsHidden(false);
		}
	}

}