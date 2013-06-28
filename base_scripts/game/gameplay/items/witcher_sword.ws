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

import class CWitcherSword extends CItemEntity
{
	import private var swordType : EWitcherSwordType;
	
	// Play runes effect
	import final function FlashRunes();
	
	// Set rune for slot
	import final function SetRuneIndexForSlot( slotIndex : int, runeIndex : int );
	var previousAttackedActor : CActor;
	

	event OnUpdateRunes( enhancementItems : array< name > )
	{
		var i : int;
		
		// Map enhancement items to effect parameters
		for ( i=0; i<enhancementItems.Size(); i=i+1 )
		{
			if ( enhancementItems[i] == 'Rune of Sun' )
			{
				SetRuneIndexForSlot( i + 1, 1 );
			}
			else if ( enhancementItems[i] == 'Rune of Earth' )
			{
				SetRuneIndexForSlot( i + 1, 2 );
			}
			else if ( enhancementItems[i] == 'Rune of Moon' )
			{
				SetRuneIndexForSlot( i + 1, 3 );
			}
			else if ( enhancementItems[i] == 'Rune of Fire' )
			{
				SetRuneIndexForSlot( i + 1, 4 );
			}
			else if ( enhancementItems[i] == 'Rune of Ysgith' )
			{
				SetRuneIndexForSlot( i + 1, 5 );
			}
		}
	}
	
	// MG: Removed scabbard mounting script, such stuff is done through bound items feature
	/*event OnMount( parentEntity : CEntity, slot : name )
	{
		var inv			: CInventoryComponent;
		var itemId		: SItemUniqueId;
		var category	: name;
		var component	: CRigidMeshComponent;
	}*/
	
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		var witcherSword 	: CWitcherSword;
		var effectPos 		: Vector; 
		var actor 			: CActor;
		var collisionPos 	: Vector;
		var distance 		: float;
		var arachas			: CArachas;
		var boneIndex		: int;
		var terrainTile		: CTerrainTileComponent;
		var sparks 			: CCollisionSparks;
		var rowNum			: int;
		var fxName 			: name;
		var staticMesh		: CStaticMeshComponent;
		
		distance = 2.0;
		actor = (CActor)collidingComponent.GetEntity();
		witcherSword = (CWitcherSword)reportingComponent.GetEntity();
		terrainTile = (CTerrainTileComponent)collidingComponent;
		staticMesh = (CStaticMeshComponent)collidingComponent;
		if(witcherSword && !terrainTile)
		{
			if(staticMesh)
			{
				
				// Log(collisionInfo.soundMaterial);
				rowNum = Int8ToInt(collisionInfo.soundMaterial);
				effectPos = collisionInfo.firstContactPoint;
				sparks = (CCollisionSparks)theGame.CreateEntity(thePlayer.GetSparks(), effectPos, witcherSword.GetWorldRotation());
				fxName = thePlayer.GetSparksName(rowNum);
				if(fxName != '')
				{
					sparks.SetFXName(fxName);
				}
			}
		}
	}
	timer function CollisionReportingOff(td : float)
	{
		var component : CRigidMeshComponent;
		this.RemoveTimer('CollisionReportingOff');
		component = (CRigidMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		if(component)
		{
			this.EnableCollisionInfoReportingForComponent(component, false, true);
		}
	}
	event OnMount( parentEntity : CEntity, slotName : name )
	{
		var s, i, y : int;
		var inv	: CInventoryComponent;
		var itemId 	: SItemUniqueId;
		var m_activeOils : array<SBuff>;
		if ( parentEntity == thePlayer && ! thePlayer.isNotGeralt && slotName == 'r_weapon')
		{
			inv		= ( (CGameplayEntity) parentEntity ).GetInventory();
			m_activeOils = thePlayer.GetActiveOils();
			itemId	= inv.GetItemByItemEntity( this );
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
	event OnTest()
	{
		FlashRunes();
	}
}

exec function MGTEST()
{
	thePlayer.GetInventory().PlayItemEffect( thePlayer.GetCurrentWeapon(), 'FlashRunes' );
}
class CCollisionSparks extends CEntity
{
	var explosionFXName : name;
	default explosionFXName = '';
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('PlaySparksEffect', 0.01, false);
	}
	function SetFXName(fxName : name)
	{
		explosionFXName = fxName;
	}
	timer function PlaySparksEffect(td : float)
	{
		if(explosionFXName != '' && explosionFXName != 'None')
			this.PlayEffect(explosionFXName);
		this.AddTimer('StopFX', 3.0, false);
	}
	timer function StopFX(td : float)
	{
		this.StopEffect(explosionFXName);
		this.AddTimer('DestroyFX', 3.0, false);
	}
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}

}