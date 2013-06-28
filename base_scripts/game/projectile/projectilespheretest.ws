/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// CProjectileSphereTest class
/////////////////////////////////////////////

import class CProjectileSphereTest extends CProjectile
{
	private editable var hitEffectEntity	: CEntityTemplate;
	private editable var projectileType : name;
	
	var effect				: CEntity;
	var effectNodeOffset	: Vector;	
	
	// Get sphere radius
	import final function GetSphereRadius() : float;
	
	// Get sphere owner
	import final function GetSphereOwner() : CActor;
	
	// Get sphere world matrix
	import final function GetSphereWorldMatrix() : Matrix;
		
	event OnDestroyed()
	{
		super.OnDestroyed();
		if( effect )
		{			
			effect.Destroy();
			effect = NULL;
		}
	}
	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		SpawnEffect( pos, normal );

		if(projectileType == 'butterflies')
		{
			( (CDrawableComponent) GetComponentByClassName( 'CMeshComponent' ) ).SetVisible( false );
		}
	}
	
	function GetSphereCenter() : Vector
	{		
		var mat : Matrix;				
		mat = GetSphereWorldMatrix();
		return MatrixGetTranslation( mat );
	}
	
	// EFFECT
	function SpawnEffect( collisionPos : Vector, collisionNormal : Vector )
	{
		var rot : EulerAngles;
		var normal : Vector;
	
		if( hitEffectEntity )
		{
			rot = MatrixGetRotation( MatrixBuildFromDirectionVector( collisionNormal ) );
			//thePlayer.GetVisualDebug().AddAxis( 'fasdad', 1.0, collisionPos, rot, true );
			effect = theGame.CreateEntity( hitEffectEntity, collisionPos, rot );
			
			effectNodeOffset = collisionPos - GetSphereCenter();
			
			AddTimer( 'UpdateEffectPos', 0.001, true );
			AddTimer( 'DestroyEffect', 2.0, false );
		}
	}
	
	timer function UpdateEffectPos( timeDelta : float )
	{		
		effect.Teleport( GetSphereCenter() + effectNodeOffset );
	}
	
	timer function DestroyEffect( timeDelta : float )
	{
		RemoveTimer( 'UpdateEffectPos' );
		effect.Destroy();
		effect = NULL;
	}
};