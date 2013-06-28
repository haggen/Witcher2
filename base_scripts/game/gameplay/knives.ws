
//////////////////////////////////////////////////
//			Throwable knife class				//
//////////////////////////////////////////////////

class CThrowableKnife extends CThrowable
{
}

state Flying in CThrowableKnife
{
	entry function StartFlying( destination : Vector )
	{
		var mat		:	Matrix;
		var knife	:	CKnifeProjectile;
		var pos		:	Vector;
		
		if( thePlayer.HasSilverSword() || thePlayer.HasSteelSword() )
			mat = thePlayer.GetBoneWorldMatrix( 'l_weapon' );
		else
			mat = thePlayer.GetBoneWorldMatrix( 'l_thumb1' );
		
		knife = (CKnifeProjectile)theGame.CreateEntity( parent.ThrownTemplate, MatrixGetTranslation( mat ), MatrixGetRotation( mat ) );
		if ( !knife )
		{
			Log( "======================================================================" );
			Log( "KNIFE ERROR" );
			Log( "Could not create KnifeProjectile." );
			Log( "======================================================================" );
			
			return;
		}
		Sleep(0.0001);
		
		knife.SetMother( parent );
		knife.SetCharacterStats( parent.GetCharacterStats() );
		
		if( VecLength( destination ) > 0 )
		{
			knife.ThrowAtPosition( destination, 3 );
		}
		else
		{
			pos = ( RotForward( thePlayer.GetWorldRotation() ) * 25 ) + thePlayer.GetWorldPosition();
			knife.ThrowAtPosition( pos, 3 );
		}

		((CDrawableComponent)parent.GetComponentByClassName('CDrawableComponent')).SetVisible(false);
		//parent.Destroy();
	}
}

class CKnifeProjectile extends CProjectile
{
	//Stats
	private var minDamage	:	float;
	private var maxDamage	:	float;
	
	private var mother		:	CThrowableKnife;
	
	function SetMother( ent : CThrowableKnife )
	{
		mother = ent;
	}
	
	function CloneKnife() : CKnifeProjectile
	{
		var clone	: CKnifeProjectile;
		var mat		: Matrix;
		
		clone = (CKnifeProjectile)theGame.CreateEntity( mother.ThrownTemplate, GetWorldPosition(), GetWorldRotation() );
		clone.SetCharacterStats(mother.GetCharacterStats());
		
		return clone;
	}
	
	function SetCharacterStats( stats : CCharacterStats )
	{
		var bonus : float;
		
		minDamage	= stats.GetFinalAttribute( 'damage_min' );
		maxDamage	= stats.GetFinalAttribute( 'damage_max' );
		
		if( thePlayer.GetCharacterStats().HasAbility( 'training_s4_2' ) )
		{
			bonus = thePlayer.GetCharacterStats().GetAttribute( 'damage_throw_combo' );
			minDamage += bonus;
			maxDamage += bonus;
		}
	}
	
	function ThrowAtPosition( position : Vector, angle : float )
	{
		//var startingPos		: Vector = GetWorldPosition();
		//var destination		: Vector;
		//var controlPoint	: Vector;
		//var mat				: Matrix;
		//var angle			: float = 5;
		//var distance		: float = 25;
		//var length			: float;
		
		//controlPoint = position - startingPos;
		
		//controlPoint = VecNormalize( controlPoint );
		
		//distance = 2 * length * CosF( Deg2Rad( angle ) );
		
		//mat = MatrixBuiltRotation( EulerAngles( 0, 0, -angle ) );
		//destination = VecNormalize( VecTransformDir( mat, controlPoint ) ) * distance;
		
		//destination = distance * controlPoint;
		//destination += startingPos;
		
		PlayEffect('trail_fx');
		ShootProjectileAtPosition( angle, 30, 0, position );
		//ShootProjectileAtPosition( 0, 45, 0, destination );
	}
	
	timer function DelayedDestroy( time : float )
	{
		Destroy();
	}
	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var ent : CEntity = collidingComponent.GetEntity();
		var actor : CActor;
		var npc : CNewNPC;
		var damage, finalDamage : float;
		
		if( ent != thePlayer && !collidingComponent.IsA('CTerrainTileComponent') )
		{
			//StopEffect('trail_fx');
			StopProjectile();
			
			actor = (CActor)ent;
			
			if( !actor && ent.IsA( 'CDragonA3Base' ) )
			{
				actor = ((CDragonA3Base)ent).GetDragonHead();
			}
			
			if( actor )
			{
				npc = (CNewNPC)actor;
				if( npc && npc.GetAttitude( thePlayer ) == AIA_Friendly )
				{
					Destroy();
					return true;
				}
				
				damage = RandRangeF( minDamage, maxDamage );
				finalDamage = damage - actor.GetCharacterStats().GetFinalAttribute('damage_reduction');
				
				if( actor.IsBoss() )
					finalDamage *= 0.5f;
				
				if(finalDamage <= 5.0)
				{
					finalDamage = 5.0;
				}
				
				actor.HitPosition( GetWorldPosition(), 'FastAttack_t1', finalDamage, true, thePlayer );
				actor.PlayBloodOnHit();
				Destroy();
			}
			else
				PlayEffect( 'default_hit' );
		
			AddTimer( 'DelayedDestroy', 5.0f, false );
			
			mother.Destroy();
		}
	}
	
	event OnRangeReached( inTheAir : bool )
	{
		var mat : Matrix;
		var vec : Vector;
		var ang : EulerAngles;
		var comp : CPhantomComponent;
		
		if( !mother )
		{
			Destroy();
			return true;
		}
		
		//comp = (CPhantomComponent)GetComponentByClassName( 'CPhantomComponent' );
		//comp.SetEnabled(true);
		
		ang = GetWorldRotation();
		ang.Yaw = 0;
		ang.Roll = ang.Pitch;
		ang.Pitch = 0;
			
		mat = MatrixBuiltRotation( ang );
		vec = VecTransformDir( mat, VecFromHeading( GetHeading() ) );
		
		if( vec.Z > 0 )
			vec.Z *= -1;
		
		vec *= 50;
		vec += GetWorldPosition();
		
		//AddTimer( 'DelayedDestroy', 5.0f, false );
		
		CloneKnife().ThrowAtPosition( vec, ang.Roll );//ShootProjectileAtPosition( ang.Roll, 30, 0, vec );
		Destroy();
		
		//ShootProjectileAtPosition( ang.Roll, 30, 0, vec );
	}
}
