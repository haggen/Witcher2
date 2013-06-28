/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
/* Q105 Sam's class by PW */
/* Uprzedzam pytania - TAK, to jest absolutnie konieczne */

class Sam extends CNewNPC 
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( !FactsDoesExist("q105_witnessed_tentacle") )
		{
			ActivateBehavior( 'fisherman' );
			RaiseEvent( 'abduction_scene' );
		}
		
		super.OnSpawned(spawnData);
	}
}