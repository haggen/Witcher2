// Klasa obslugujaca strzaly w q208 - faza 2

class q208_arrows extends CRegularProjectile
{
	function StopArrow()
	{
		if( this )
		{
			this.StopProjectile();
			this.AddTimer('DestroyArrow', 2.0, false);
		}
	}
	timer function DestroyArrow(td : float)
	{
		Destroy();
	}
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var barricade : q208_baricade;
		var actor	: CActor;
		var npc		: CNewNPC;
		var npcPostion, actorPosition, actorToNPCVec : Vector;
		var itemEntity : CItemEntity;
		var entity : CEntity = collidingComponent.GetEntity();
		var fact : int;
		
		barricade = (q208_baricade) entity;
		itemEntity = (CItemEntity)entity;
		fact = FactsQuerySum( "q208_geralt_near_barricade" );

		if(barricade)
		{
			barricade.DestroyBarricade();
			this.Destroy();
			return false;
		}
		if(itemEntity )
		{
			actor = (CActor)itemEntity.GetParentEntity();
		}
		else
		{
			actor = (CActor)entity;
		}
		if ( actor ) 
		{
			npc = (CNewNPC) actor;
			npcPostion = npc.GetWorldPosition();
			
			if(actor == thePlayer)
			{
				this.Destroy();
			}
			if (actor == thePlayer && fact != 1) 
			{
				ProjectileDamage(actor, 'Attack');
			}
			else if (actor != thePlayer)
			{
				ProjectileDamage(actor, 'Attack');		
			}
		}
		else
		{
			PlayArrowHitSound();
		}
		
		StopArrow();

		//SetWillHitTarget( false );
	}
}