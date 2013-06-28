//klasa pozwalajaca na ustawienie Geraltowi atrybutu isHidden, decydujacego o tym czy gracz jest widoczny czy nie.

class CDarkArea extends CEntity
{
	editable var DarkAreaName : CName;
	editable var isEnabled : bool;
		
	default isEnabled = true;
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		var player : CPlayer;	
		
		player = thePlayer;
		affectedEntity = activator.GetEntity();
		
		if( affectedEntity.IsA( 'CPlayer' ) )
		{
			if( isEnabled )
			{
				player.SetIsHidden(true);
				Log( "ZNIKAM!" );
			}	
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
			Log( "POJAWIAM SIÊ!" );			
		}
	}
}