/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Communiy System
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Community class
/////////////////////////////////////////////
import class CCommunity extends CResource
{
}

import function GetNPCFromCommunity( entityTemplate : CEntityTemplate, appearancesList : array< name >, worldPosition : Vector, out isSuccessful : bool ) : CNewNPC;

import function OnCommunityNPCDeath( npc : CNewNPC );

// Visibility spawn/despawn radius - use with care! Returns true on success. Despawn radius has to be greater than spawn radius.
import function SetCommunitySpawnRadius( spawnRadius : float ) : bool;
import function SetCommunityDespawnRadius( despawnRadius : float ) : bool;
import function SetCommunityRadius( spawnRadius : float, despawnRadius : float ) : bool;

/////////////////////////////////////////////////////////////////////
// CCommunityInitializer
/////////////////////////////////////////////////////////////////////
import class CCommunityInitializer extends CObject
{
	// Perform initialization
	function Perform( npc : CNewNPC ) : bool;
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerGuardArea
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerGuardArea extends CCommunityInitializer
{
	editable var guardAreaTag : name;
	function Perform( npc : CNewNPC ) : bool
	{
		return npc.SetGuardArea( guardAreaTag );		
	}
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerSetImmortal
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerSetImmortal extends CCommunityInitializer
{
	editable var immortalityMode : EActorImmortalityMode;
	function Perform( npc : CNewNPC ) : bool
	{
		npc.SetImmortalityModePersistent( immortalityMode );
		return true;
	}
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerSetAttitude
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerSetAttitude extends CCommunityInitializer
{
	editable var Attitude : EAIAttitude;
	function Perform( npc : CNewNPC ) : bool
	{
		npc.SetAttitude( thePlayer, Attitude );
		return true;
	}
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerBattleArea
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerBattleArea extends CCommunityInitializer
{
	editable var battleAreaTag : name;
	editable var teleport : bool;
	
	function Perform( npc : CNewNPC ) : bool
	{
		var node : CNode;
		var ba : CBattleArea;
		node = theGame.GetNodeByTag( battleAreaTag );
		ba = (CBattleArea)node;
		if( ba )
		{
			ba.EnterArea( npc, teleport );
			return true;
		}
		
		return false;
	}
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerMoveToObject
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerMoveToObject extends CCommunityInitializer
{
	editable var objectTag : name;
	editable var moveType : EMoveType;
	editable var breakOnCombat : bool;
	
	default moveType = MT_Run;

	function Perform( npc : CNewNPC ) : bool
	{
		var node : CNode = theGame.GetNodeByTag( objectTag );
		var prio : EAIPriority;
		if( node )
		{
			if( breakOnCombat )
				npc.GetArbitrator().AddGoalMoveToTarget( node, moveType, 1.0f, 1.0, EWM_Exit, AIP_Normal, 3.0 );			
			else
				npc.GetArbitrator().AddGoalMoveToTarget( node, moveType, 1.0f, 1.0, EWM_Exit, AIP_High );			
			return true;
		}
		else
		{
			return false;
		}
	}
}
//Drawing Weapon
class CCommunityInitializerDrawWeapon extends CCommunityInitializer
{
	
	function Perform( npc : CNewNPC ) : bool
	{
		var weaponId : SItemUniqueId;
		
			if( npc.HasCombatType( CT_ShieldSword ) )
			{
				weaponId = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
				if ( weaponId == GetInvalidUniqueId() )
				weaponId = npc.GetInventory().GetItemByCategory('steelsword', false);
				npc.DrawWeaponInstant(weaponId);
				
				weaponId = npc.GetInventory().GetItemByCategory('opponent_shield', false);
				if ( weaponId == GetInvalidUniqueId() )
				weaponId = npc.GetInventory().GetItemByCategory('shield', false);
				npc.DrawWeaponInstant(weaponId);
			}
			
			else if( npc.HasCombatType( CT_Bow ) )
			{
				weaponId = npc.GetInventory().GetItemByCategory('opponent_bow', false);
				if ( weaponId == GetInvalidUniqueId() )
				weaponId = npc.GetInventory().GetItemByCategory('rangedweapon', false);
				npc.DrawWeaponInstant(weaponId);
			}
			
			else
			{
				npc.DrawWeaponInstant( npc.GetInventory().GetFirstLethalWeaponId() );
			}
			return true;
	}
	
}	

//Equip item
class CCommunityInitializerEquipItem extends CCommunityInitializer
{
	editable var item_name : name;
	editable var toHand : bool;

	function Perform( npc : CNewNPC ) : bool
	{
		var item_id : SItemUniqueId;

		item_id = npc.GetInventory().GetItemId(item_name);
		npc.GetInventory().MountItem(item_id, toHand );
	}
}	

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerSetImmortal Custom Q105
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerSetImmortalCustomQ105 extends CCommunityInitializer
{
	function Perform( npc : CNewNPC ) : bool
	{
		if(FactsQuerySum('q105_set_scoia_nekker_mortal') == 1)
		{
			npc.SetImmortalityModePersistent( AIM_None );
		}
		
		return true;
	}
	//editable var immortalityMode : EActorImmortalityMode;
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerCombatForceAttackPlayer
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerCombatForceAttackPlayer extends CCommunityInitializer
{
	editable var time : float;
	
	function Perform( npc : CNewNPC ) : bool
	{
		npc.ForceTargetPlayer(time);
		return true;
	}
}

/////////////////////////////////////////////////////////////////////
// CCommunityInitializerAddAbility
/////////////////////////////////////////////////////////////////////
class CCommunityInitializerAddAbility extends CCommunityInitializer
{
	editable var abilityName : name;
	var i, size : int;
	var abilities : array<name>;
	
	function Perform( npc : CNewNPC ) : bool
	{
		npc.GetCharacterStats().GetAbilities(abilities);
		size = abilities.Size();
		for (i = 0; i < size; i += 1)
		{
			npc.GetCharacterStats().RemoveAbility(abilities[i]);
		}
		npc.GetCharacterStats().AddAbility(abilityName);
		if(!npc.GetCharacterStats().HasAbility(abilityName))
		{
			Log("QSetOneAbilityForNPC ERROR - bledna nazwa ability (nie zdefiniowana w XML): " + abilityName);
		}
		return true;
	}
}

//Custom remove hat from zyvik
class CCommunityInitializerZyvikRemoveHat extends CCommunityInitializer
{
	function Perform( npc : CNewNPC ) : bool
	{
		if(FactsQuerySum('q208_give_hat') == 1)
		{
			npc.GetInventory().RemoveItem(npc.GetInventory().GetItemId('Zyvik hat'));
		}
		
		return true;
	}
}
