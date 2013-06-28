/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CMadhouseGhost class
/////////////////////////////////////////////

class CMadhouseGhost extends CNewNPC
{

	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.EnablePathEngineAgent( false );
		PlayEffect('ghost_fx');
		super.OnSpawned(spawnData);
	}
	event OnDespawn( forced : bool )
	{
		this.EnablePathEngineAgent( true );
		StopEffect('ghost_fx');
		super.OnDespawn(forced);
	}

}