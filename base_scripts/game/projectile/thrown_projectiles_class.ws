// klasa i funkcje do obslugi broni rzucanej 

class CThrownWeapon extends CProjectile
{
	editable var 	velocity				: float;
	editable var 	range					: float;

	private var		throwTarget				: CNode;
	private var		throwTargetPos			: Vector;
	private var		offset					: Vector;
	
	default 		velocity 				= 14;
	default			range					= 100;
	
	function ThrowAtNode( angle : float, target : CNode )
	{	
		this.throwTarget = target;
		throwTargetPos = this.throwTarget.GetWorldPosition();
		offset = Vector(0, 0, 1);

		ShootProjectileAtPosition( angle, velocity, 0.0, throwTargetPos + offset );
		//ShootProjectileAtNode( angle, velocity, 0.0, target, range );

		// make weapon leave a trail as it flies
		PlayEffect( 'trail' );
	}
	
	function ThrowAtPosition( angle : float, target : Vector )
	{		
		this.throwTarget = NULL;
		
		ShootProjectileAtPosition( angle, velocity, 0.0, target );
		
		// make the weapon leafe a trail as it flies
		PlayEffect( 'trail' );
	}
	
	// Event called when weapon reaches its target
	event OnRangeReached( inTheAir : bool )
	{
		var minDamage : float;
		var maxDamage : float;
		var damage, finalDamage : float;
		var target : CNewNPC;
		var item : SItemUniqueId;
				
		item = thePlayer.thrownItemId;
		minDamage = thePlayer.GetInventory().GetItemAttributeAdditive( item, 'min_damage' );
		maxDamage = thePlayer.GetInventory().GetItemAttributeAdditive( item, 'max_damage');
		target = (CNewNPC)this.throwTarget;
		
		damage = RandRangeF( minDamage, maxDamage );
		finalDamage = damage - target.GetCharacterStats().GetFinalAttribute('damage_reduction');
		if(finalDamage <= 5.0)
		{
			finalDamage = 5.0;
		}
		target.ActionRotateToAsync( thePlayer.GetWorldPosition() );
		target.HitPosition( thePlayer.GetWorldPosition(), 'FastAttack_t1', finalDamage, true );
		target.PlayBloodOnHit();
		this.Destroy();
	}
}