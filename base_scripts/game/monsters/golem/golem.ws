/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// W2MonsterGolem class
/////////////////////////////////////////////

class W2MonsterGolem extends W2Monster
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Bomb
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	editable var retryBombTime				: float;    // >=0		After bomb explode, the monster will not set off bomb again for this amount of time
	editable var lowHealthPercentForBomb	: int;      // (0,100]	If health is greater than this percentage than monster will not set off a bomb
	editable var hitCountCapForBomb         : int;      // >=0		If monster hit count is less than this number than monster will not set off a bomb
	editable var golemDestructionEntity		: CEntityTemplate;

	default retryBombTime = 5;
	default lowHealthPercentForBomb = 60;
	default hitCountCapForBomb = 5;

	// private
	var bombRetryTimer     : float;
	var bombLowHealthValue : float;
	var bombHitCount       : int;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Throw
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	editable var throwRetryTime      : float; // >=0 seconds
	editable var throwMinPlayerRange : float; // >0  meters
	editable var throwMaxPlayerRange : float; // >0  meters
	editable var throwDamageRange    : float;
	
	editable var elemental    : bool;
	
	default throwRetryTime      = 3.0;
	default throwMinPlayerRange = 5.0;
	default throwMaxPlayerRange = 10.0;
	default throwDamageRange    = 4.0;
	
	// private
	var throwRetryTimer            : float;
	var throwMinPlayerRangeSquared : float;
	var throwMaxPlayerRangeSquared : float;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	var isInitialized : bool;

	default isInitialized = false;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function GetMonsterType() : EMonsterType
	{
		if(elemental)
		{
			return MT_Elemental;
		}
		else
		{
			return MT_Golem;
		}
	}
	function CanPerformRespondedBlock() : bool
	{
		return true;
	}
	function GetGolemDestructionTemplate() : CEntityTemplate
	{
		return golemDestructionEntity;
	}
	// Initialize Golem
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
		

		PlayEffect('default_fx');
		
		// Bomb
		bombLowHealthValue = initialHealth * (lowHealthPercentForBomb / 100.0);
		GetInventory().AddItem( 'Golem Bomb', 1 );
		bombRetryTimer = 0;
		bombHitCount = 0;
		
		// Throw
		GetInventory().AddItem( 'Golem Throw', 1 );
		throwMinPlayerRangeSquared = throwMinPlayerRange * throwMinPlayerRange;
		throwMaxPlayerRangeSquared = throwMaxPlayerRange * throwMaxPlayerRange;
		throwRetryTimer = throwRetryTime;

		isInitialized = true;
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeCombatGolem( params );
		OnEnteringCombat();
	}
	
	latent function DestroyedOnFreeze() : bool
	{
		return false;
	}
}
/////////////////////////////////////////////
// W2MonsterGolemThrow class
/////////////////////////////////////////////
class W2MonsterGolemThrow extends CProjectile
{
	//private var hitActors : array< CActor >;
	private var destroyRequest : bool;

	event OnProjectileInit()
	{
		destroyRequest = false;
		AddTimer( 'EndCheck', 0.5, true, false );
	}

	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity;
		var actor : CActor;
		var damage : float;

		entity = collidingComponent.GetEntity();
		if( entity.IsA('CActor') && !entity.IsA('W2MonsterGolem') )
		{
			actor = (CActor)entity;
			//if( !hitActors.Contains( actor ) )
			{
				//damage = GetStrength();
				//actor.HitPosition( GetWorldPosition(), 'Attack_t1', damage, true );
				//hitActors.PushBack(actor);
				
				DealAoEDamage();
				destroyRequest = true;
			}
		}
	}

	event OnRangeReached( inTheAir : bool )
	{
		DealAoEDamage();
		destroyRequest = true;
	}
	
	private function DealAoEDamage()
	{
		var affected    : array< CActor >;
		var i           : int;
		var damage      : float = GetStrength();
		var hitPos      : Vector = GetWorldPosition();
		var casterGolem : W2MonsterGolem;
		var damageRange : float = 3.0;

		casterGolem = (W2MonsterGolem)caster;
		damageRange = casterGolem.throwDamageRange;

		GetActorsInRange( affected, damageRange, '', this );
		for ( i = 0; i < affected.Size(); i += 1 )
		{
			affected[i].HitPosition( hitPos, 'Attack_t1', damage, true );
		}
	}

	timer function EndCheck( t : float )
	{
		if( GetStrength() <= 0.0 || destroyRequest )
		{
			RemoveTimer( 'EndCheck' );
			Destroy();
		}
	}
};
