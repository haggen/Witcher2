// Brix niszcz¹cy gniazdo, do którego jest podpiêty ten skrypt

latent brix function DestroyNest ( nest : CEntity, disabled_area : CEntity, show_effect : CEntityTemplate, out created_effect : CEntity)

{
	var setting_time : int;
	var countdown : int;
	var bomb_timer : float;
	var bombId : SItemUniqueId;
	
	if ( thePlayer.GetInventory().HasItem( 'Nest Destroyer') == true )
	{
		bombId = thePlayer.GetInventory().GetItemId( 'Nest Destroyer' );	
		
		thePlayer.ActionPlaySlotAnimation('PLAYER_SLOT', 'fsv_strong_01_s', 0.2, 0.3, true);	
		thePlayer.GetInventory().RemoveItem( bombId );	
		nest.GetComponent("UseBomb").SetEnabled(false);
						
		Sleep (5.f);
	
		created_effect = theGame.CreateEntity( show_effect, nest.GetWorldPosition(), nest.GetWorldRotation() );
	}
}	
