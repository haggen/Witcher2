class CWitcherStaff extends CWitcherSecondaryWeapon
{
	editable var effectName : name;
	event OnMount( parentEntity : CEntity, slot : name )
	{
		//StopEffect(effectName);
		
	}
	event OnDetach( parentEntity : CEntity )
	{
		if(thePlayer.GetCurrentWeapon() == GetInvalidUniqueId())
		{
			StopEffect(effectName);
		}
		else
		{
			PlayEffect( effectName );
		}
		super.OnDetach(parentEntity);
	}
}


class CWitcherSecondaryWeapon extends CItemEntity
{
	function IsWitcherSecondaryWeapon() : bool
	{
		return true;
	}
	event OnDetach( parentEntity : CEntity )
	{
		var inv			: CInventoryComponent;
		var itemId		: SItemUniqueId;
		var component	: CRigidMeshComponent;
		if ( parentEntity == thePlayer && ! thePlayer.isNotGeralt )
		{
			inv		= ( (CGameplayEntity) parentEntity ).GetInventory();
			itemId	= inv.GetItemByItemEntity( this );
					
			component = (CRigidMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
			if(component)
			{
				this.EnableCollisionInfoReportingForComponent(component, false, true);
			}
		}
	}
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		var witcherWeapon 	: CWitcherSecondaryWeapon;
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
		witcherWeapon = (CWitcherSecondaryWeapon)reportingComponent.GetEntity();
		terrainTile = (CTerrainTileComponent)collidingComponent;
		staticMesh = (CStaticMeshComponent)collidingComponent;
		if(witcherWeapon && !terrainTile)
		{
			if(actor)
			{
				/*if(actor != thePlayer)// && actor != previousAttackedActor)
				{
					previousAttackedActor = actor;
					actor.HitPosition(thePlayer.GetWorldPosition(), 'Attack', 10.0, true);
					actor.PlayBloodOnHit();
					
				}*/
				arachas = (CArachas)actor;
				if(arachas)
				{
					collisionPos = collisionInfo.firstContactPoint;
					boneIndex = arachas.GetRootAnimatedComponent().FindNearestBoneWS(collisionPos, distance);
					
					if(boneIndex != -1)
					{
						arachas.SetLastCollisionBone(boneIndex);
					}
				}
			}
			else if(staticMesh)
			{
				
				// Log(collisionInfo.soundMaterial);
				rowNum = Int8ToInt(collisionInfo.soundMaterial);
				effectPos = collisionInfo.firstContactPoint;
				sparks = (CCollisionSparks)theGame.CreateEntity(thePlayer.GetSparks(), effectPos, witcherWeapon.GetWorldRotation());
				fxName = thePlayer.GetSparksName(rowNum);
				if(fxName != '')
				{
					sparks.SetFXName(fxName);
				}
				else
				{
					sparks.SetFXName('sparks_fx');
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
}