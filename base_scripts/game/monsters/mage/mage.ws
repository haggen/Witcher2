/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// W2MonsterMage class
/////////////////////////////////////////////

class W2MonsterMage extends W2Monster
{
	// Initialize the mage
	event OnSpawned(spawnData : SEntitySpawnData )
	{				
		primaryCombatType = CT_Mage;
		secondaryCombatType = CT_None;
		super.OnSpawned(spawnData);		
			
		SetErrorState( "W2MonsterMage class is obsolete, use CNewNPC with CT_Mage combat type" );
	}
}
