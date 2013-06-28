/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher sword
/** Copyright © 2010
/***********************************************************************/
/*
enum EWitcherSwordType
{
	WST_Silver,
	WST_Steel
};
*/

class CWitcherSwordDark extends CWitcherSword
{
	event OnMount( parentEntity : CEntity, slotName : name )
	{
		var s, i, y : int;
		var inv	: CInventoryComponent;
		var itemId 	: SItemUniqueId;
		var m_activeOils : array<SBuff>;
		var itemName : name;
		
		inv		= ( (CGameplayEntity) parentEntity ).GetInventory();
		itemId	= inv.GetItemByItemEntity( this );
		
		if ( parentEntity == thePlayer && ! thePlayer.isNotGeralt && slotName == 'r_weapon')
		{
			
			m_activeOils = thePlayer.GetActiveOils();
			
			
			
				if(thePlayer.GetCurrentPlayerState() != PS_Cutscene )
				{
					if ( swordType == WST_Steel ) 
					{ 
						//inv.IsItemHeld(itemId)
						if(!thePlayer.IsDarkWeaponSteel())
						{
							thePlayer.SetDarkWeaponSteel( true ); 
						}
					} 
					else
					{ 
						if(!thePlayer.IsDarkWeaponSilver())
						{
							thePlayer.SetDarkWeaponSilver( true ); 
						}
				}
				
			}
			for ( i = 0; i < m_activeOils.Size(); i += 1 ) 
			{
				if ( m_activeOils[i].m_item == itemId ) 
				{
					thePlayer.GetCharacterStats().FilterAbilitiesByPrerequisites( m_activeOils[i].m_abilities );
					s = m_activeOils[i].m_abilities.Size();
					for ( y = 0; y < s; y += 1 )
					{
						thePlayer.GetCharacterStats().AddAbility( m_activeOils[i].m_abilities[y] );
					}		
				}
			}	
			theHud.m_hud.UpdateBuffs();
		}
		else if(parentEntity == thePlayer && ! thePlayer.isNotGeralt && slotName != 'r_weapon')
		{
			if ( swordType == WST_Steel ) 
			{
				if(thePlayer.IsDarkWeaponSteel())
				{
					thePlayer.SetDarkWeaponSteel( false ); 
				}
			} 
			else
			{ 
				if(thePlayer.IsDarkWeaponSilver())
				{
					thePlayer.SetDarkWeaponSilver( false ); 
				}
			}
		}
		thePlayer.CheckSet(itemId, parentEntity);
	}
	event OnDetach( parentEntity : CEntity )
	{
		var s,i, y : int;
		var inv			: CInventoryComponent;
		var itemId		: SItemUniqueId;
		var component	: CRigidMeshComponent;
		var m_activeOils : array<SBuff>;
		if ( parentEntity == thePlayer && ! thePlayer.isNotGeralt )
		{
			inv		= ( (CGameplayEntity) parentEntity ).GetInventory();
			m_activeOils = thePlayer.GetActiveOils();
			itemId	= inv.GetItemByItemEntity( this );
			if ( swordType == WST_Steel && thePlayer.GetCurrentWeapon() == itemId) 
			{ 
				//inv.IsItemHeld(itemId)
				if(thePlayer.IsDarkWeaponSteel())
				{
					thePlayer.SetDarkWeaponSteel( false ); 
				}
			} 
			else if( thePlayer.GetCurrentWeapon() == itemId )
			{ 
				if(thePlayer.IsDarkWeaponSilver())
				{
					thePlayer.SetDarkWeaponSilver( false ); 
				}
			}
			thePlayer.SetDarkSet(false);
			// MG: Removed scabbard mounting script, such stuff is done through bound items feature
			for ( i = 0; i < m_activeOils.Size(); i += 1 ) 
			{
				if ( m_activeOils[i].m_item == itemId ) 
				{
					s = m_activeOils[i].m_abilities.Size();
					for ( y = 0; y < s; y += 1 )
					{
						thePlayer.GetCharacterStats().RemoveAbility( m_activeOils[i].m_abilities[y] );
					}		
				}
			}				
			theHud.m_hud.UpdateBuffs();
			
			component = (CRigidMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
			if(component)
			{
				this.EnableCollisionInfoReportingForComponent(component, false, true);
			}
		}
	}
	
}
