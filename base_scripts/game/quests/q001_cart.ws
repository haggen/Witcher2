///////////////////////////////////////////////////////////////////////////////////////////////////
//	class for q001 - saveable cart
///////////////////////////////////////////////////////////////////////////////////////////////////

class Q001_SaveableCart extends CGameplayEntity
{
	var NewPos : Vector;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( FactsDoesExist( "q001_cart_scene_seen" ) )
		{
			NewPos = theGame.GetNodeByTag('q001_cart_tele_point').GetWorldPosition();
			Teleport(NewPos);
		}
	}
}