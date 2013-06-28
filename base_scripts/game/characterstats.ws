/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CCharacterStats
/** Copyright © 2010
/***********************************************************************/

/*
enum EAbilityEnhancementType
{
	AET_AdjustAllModifiersByUniformValue,
	AET_AddAdjustModifiers,
	AET_AdjustModifiersIfExist
};
*/

import class CCharacterStats
{
	// Is given ability defined at all?
	import final function IsAbilityDefined( abilityName : name ) : bool;
	
	// Get list of attributes by attribute type
	import final function GetAttributesByType( type : name, out attributes : array< name > );
	
	// Get attribute value
	import final function GetAttribute( attributeName : name ) : float;
	
	// Gets item stats including character stats
	import final function GetItemAttributeValuesWithPrerequisites( itemId : SItemUniqueId, attrName : name,
		out valAdd : float, out valMul : float, out dispPerc : bool, out dispAdd : bool ) : bool;
	
	// Useful if character stats and inventory don't belong to the same actor
	import final function GetItemAttributeValuesWithPrereqAndInv( itemId : SItemUniqueId, inventory : CInventoryComponent, attrName : name,
		out valAdd : float, out valMul : float, out dispPerc : bool, out dispAdd : bool ) : bool;

	// Get attribute value with additional display info (used by GUI), returns true if attribute was found
	import final function GetAttributeForDisplay( attributeName : name, out value : float, out displayPerc : bool ) : bool;
	
	// Give ability
	import final function AddAbility( abilityName : name ) : bool;
	
	// Take away ability
	import final function RemoveAbility( abilityName : name ) : float;
	
	// Check ability
	import final function HasAbility( abilityName : name ) : bool;
	
	// Enhance ability with an item
	import final function EnhanceAbility( abilityName : name, itemId : SItemUniqueId, enhancementType : EAbilityEnhancementType ) : bool;
	
	// Remove ability enhancement
	import final function RemoveAbilityEnhancement( abilityName : name, slotIdx : int ) : bool;
	
	// Get name of the item that was used to enhance given ability
	import final function GetAbilityEnhancementItemName( abilityName : name, slotIndex : int ) : name;
	
	// Get ability enhancements
	import final function GetAbilityEnhancements( abilityName : name, out attributes : array< name >, out valAdd : array< float >,
												  out valMul : array< float >, out dispPercAdd : array< bool >, out dispPercMul : array< bool > );
	
	// Get maximal number of enhancements for given ability
	import final function GetMaxEnhancementsForAbility( abilityName : name ) : int;
	
	// Returns true if ability can be bought due to other abilities prerequisites
	import final function IsAbilityAvailableToBuy( abilityName : name ) : bool;
	
	// Log character stats
	import final function LogStats();
	
	import final function GetAbilities( out abilities : array< name > );
	
	import final function FilterAbilitiesByPrerequisites( out abilities : array< name > );
	
	// Initialize some basic attributes and abilities, called from native code
	function Init()
	{
		// just in case, most likely do nothing here
	}
	
	// Function is calculating final value of attribute (includes _add and _mult modifiers)
	function GetFinalAttribute(attribute_name : name) : float
	{
		//attribute_output = (attribute_base + attribute_add) * attribute_mult; 
		return GetAttribute( attribute_name );
	}
	
	// Compute randomized damage output, nonexisting attributes will be treated as 0
	function ComputeDamageOutputPhysical(NPCvsNPC : bool) : float
	{
		var outputDamage : float;
		var damageMin : float;
		var damageMax : float;
		if(NPCvsNPC)
		{
			damageMin = GetFinalAttribute( 'damage_npc_min' );
			damageMax = GetFinalAttribute( 'damage_npc_max' );
			if(damageMin == 0.0f && damageMax == 0.0f)
			{
				damageMin = GetFinalAttribute( 'damage_min' );
				damageMax = GetFinalAttribute( 'damage_max' );
			}
		}
		else
		{
			damageMin = GetFinalAttribute( 'damage_min' );
			damageMax = GetFinalAttribute( 'damage_max' );
		}
		outputDamage = RandRangeF( damageMin, damageMax );

		return outputDamage;
	}
	
	// Compute final damage received - input should come from ComputeDamageOutputPhysical
	function ComputeReceivedDamagePhysical( damage : float ) : float
	{
		var receivedDamage : float;
		var resistance : float;
		var resistanceModifierMult : float;
		var resistanceModifierAdd : float;
		
		resistance = GetAttribute( 'physical_resist' );
		resistanceModifierMult = GetAttribute( 'physical_resist_mult' );
		resistanceModifierAdd = GetAttribute( 'physical_resist_add' );
		
		receivedDamage = resistanceModifierMult * resistance + resistanceModifierAdd - damage;
		return receivedDamage;
	}
		
}

exec function Stats()
{
	thePlayer.GetCharacterStats().LogStats();
}