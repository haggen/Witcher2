//////////////////////////////////////////////////////////////////////////////////////////////////////////
// quest functions for q204_dragons_dream
//////////////////////////////////////////////////////////////////////////////////////////////////////////

quest function Q207_DrunkStateStart( drunkTag : name ) : bool
{
	var drunk : CNewNPC;
	
	drunk = theGame.GetNPCByTag( drunkTag );
	drunk.SetMovementType( EX_Drunk );
	
	return true;
}

class CQ207SteelSwordManager extends CGameplayEntity
{
	saved var steelswordId : SItemUniqueId;
	var allItems : array<SItemUniqueId>;
	var i : int;
	
	latent function GetCurrentSword()
	{
		thePlayer.GetInventory().GetAllItems( allItems );
		
		for( i=0; i<allItems.Size(); i+=1 )
		{
			if( thePlayer.GetInventory().GetItemCategory( allItems[i] ) == 'steelsword' && thePlayer.GetInventory().IsItemMounted( allItems[i] ) )
			{
				steelswordId = allItems[i];
			}
		}
	}
	
	function EquipPreviousSteelswordToPlayer()
	{
		thePlayer.GetInventory().MountItem( steelswordId, false );
	}
}

quest latent function Q207GetCurrentGeraltSteelsword( managerTag : name )
{
	var steelswordManager : CQ207SteelSwordManager;
	
	steelswordManager = (CQ207SteelSwordManager) theGame.GetEntityByTag( managerTag );
	
	steelswordManager.GetCurrentSword();
}

quest function Q207EquipPreviousGeraltSword( managerTag : name )
{
	var steelswordManager : CQ207SteelSwordManager;
	
	steelswordManager = (CQ207SteelSwordManager) theGame.GetEntityByTag( managerTag );
	
	steelswordManager.EquipPreviousSteelswordToPlayer();
}

storyscene function Scene207EquipPreviousGeraltSword( player: CStoryScenePlayer, managerTag : name ) : bool
{
	var steelswordManager : CQ207SteelSwordManager;
	
	steelswordManager = (CQ207SteelSwordManager) theGame.GetEntityByTag( managerTag );
	
	steelswordManager.EquipPreviousSteelswordToPlayer();
	
	return true;
}