/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CDaraug Ghost class
/////////////////////////////////////////////

class CDraugGhost extends CNewNPC
{

	function IsMonster() : bool
	{
		return true;
	}
	
	function GetMonsterType() : EMonsterType
	{
		return MT_HumanGhost;
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		var item : SItemUniqueId;
		
		item = GetInventory().GetItemByCategory('opponent_weapon', true, false);
		if(item == GetInvalidUniqueId())
		{
			Log("invalid item");
		}
		PlayEffect('ghost_fx');
		this.GetInventory().PlayItemEffect(item,'ghost_fx');
		
		super.OnSpawned(spawnData);
	}
	event OnDespawn( forced : bool )
	{
	
		var item : SItemUniqueId;
		
		item = GetInventory().GetItemByCategory('opponent_weapon', true, false);
		if(item == GetInvalidUniqueId())
		{
			Log("invalid item");
		}
		StopEffect('ghost_fx');
		this.GetInventory().StopItemEffect(item,'ghost_fx');
		super.OnDespawn(forced);
	}

}