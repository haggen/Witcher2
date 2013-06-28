
//////////////////////////////////////////////////////////////////
////////////										//////////////
////////////	Classes for all extended traps		//////////////
////////////										//////////////
//////////////////////////////////////////////////////////////////

class CTrapExploding extends CBaseTrap
{	
	function HandleIgniHit( aard : CWitcherSignIgni )
	{
		if( isArmed )
			OnTriggerTrap( NULL );
	}
	
	private function ApplyAdditionalEffect( target : CActor )
	{
		var vec			:	Vector;
		var rotation	:	EulerAngles;
		var hitParams	:	HitParams;
		
		if( !target.IsAlive() )
			return;
		
		if( target == thePlayer )
		{
			target.OnHit(hitParams);
			if( target.IsRotatedTowards( this, 90 ) )
			{
				target.ActionRotateToAsync( GetWorldPosition() );
				thePlayer.PlayerCombatHit(PCH_Hit_2a);
				//target.RaiseForceEvent( 'Hit_t2a' );
			}
			else
			{
				vec = GetWorldPosition() - target.GetWorldPosition();
				target.ActionRotateToAsync( GetWorldPosition() - vec );
				//target.RaiseForceEvent( 'Hit_t2back' );
				thePlayer.PlayerCombatHit(PCH_HitBack_1);
			}
		}
		else
		{
			if( target.TestResByName( 'res_falter' ) )
			{
				rotation = VecToRotation( GetWorldPosition() - target.GetWorldPosition() );
				target.TeleportWithRotation( target.GetWorldPosition(), rotation );
				target.ForceCriticalEffect( CET_Falter, W2CriticalEffectParams( 0, 0, 2, 2 ) );
			}
			else
			{
				target.HitPosition( GetWorldPosition(), 'Attack', 0, false );
			}
		}
	}
	
	private function ApplyAdditionalGlobalEffect()
	{
		CheckFireTriggers();
		/*var	nodes		:	array< CNode >;
		var size, i		:	int;
		var trap		:	CBaseTrap;
		
		theGame.GetNodesByTag( 'trap', nodes );
		size = nodes.Size();
		for( i = 0; i < size; i += 1 )
		{
			trap = (CBaseTrap)nodes[i];
			
			if( trap.isArmed && VecDistance( GetWorldPosition(), trap.GetWorldPosition() ) <= range )
				trap.RemoteTriggerTrap( 0.3f );
		}*/
	}
	
	private function CheckFireTriggers()
	{
		var nodes	: array<CNode>;
		var i, size	: int;
		
		var trap	: CBaseTrap;
		var ddream	: CPetardDragonDream;
		var delay	: float;
		
		theGame.GetNodesByTag( 'TriggeredByFire', nodes );
		size = nodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			delay = CheckTriggeredNode( nodes[i] );
			if( delay == -1 )
				continue;
			
			delay = delay / 20;
				
			if( nodes[i].IsA('CBaseTrap') )
			{
				trap = (CBaseTrap)nodes[i];
				trap.RemoteTriggerTrap(delay);
			}
			else if( nodes[i].IsA('CPetardDragonDream') )
			{
				ddream = (CPetardDragonDream)nodes[i];
				ddream.AddTimer('TriggerFireWithDelay', delay, false);
			}
		}
	}
	
	private function CheckTriggeredNode( node : CNode ) : float
	{
		var area : CInteractionAreaComponent;
		var dist : float;
		
		if( node == this )
			return -1;
			
		area = (CInteractionAreaComponent)((CEntity)node).GetComponent('FireTrigger');
		if( !area )
		{
			Log("TriggeredByFire entity doesn't have FireTrigger component.");
			return 0.0f;
		}
		
		dist = VecLength( area.GetWorldPosition() - GetWorldPosition() );
		if( dist < area.GetRangeMax() + range )
		{
			return dist;
		}
		
		return -1;
	}
}

class CTrapRage extends CBaseTrap
{
	private function ApplyAdditionalEffect( target : CActor )
	{
		var npc : CNewNPC;
		
		if( target.IsA( 'CNewNPC' ) )
		{
			npc = (CNewNPC)target;
			if( npc.TestResByName( 'res_berserk' ) )
				npc.EnterBerserk( 15.0f );
		}
	}
}

class CMetalFragment extends CProjectile
{
	event OnProjectileCollision( collidingComponent : CComponent, pos : Vector, normal : Vector )
	{
		var ent : CEntity = collidingComponent.GetEntity();
		
		if( !ent.IsA('CActor') && !ent.IsA('CBaseTrap') && !ent.IsA('CProjectile') && !ent.IsA('CItemEntity') )
		{
			StopProjectile();
			PlayEffect('hit_fx');
			DelayedDestroy( 5.0f );
		}
	}
	
	event OnRangeReached( inTheAir : bool )
	{
		Destroy();
	}
	
	timer function DelayedDestroy( time : float )
	{
		Destroy();
	}
}

class CTrapCrippling extends CBaseTrap
{
	editable var metalFragment : CEntityTemplate;
	editable var speed : float;
	editable var amount : int;
	editable var nailRange : float;
	var frag : CProjectile;
	
	default speed = 15;
	
	private function ApplyAdditionalEffect( target : CActor )
	{
		target.PlayEffect( 'crippling_trap_hit' );
		super.ApplyAdditionalEffect( target );
	}
	
	private function ApplyAdditionalGlobalEffect()
	{
		var i, j : int;
		var x, y, z : float;
		var pos : Vector;
		var vec : Vector;
		
		pos = GetWorldPosition();
		pos.Z += 1;
		
		//LEFT
		for( i = 0; i < amount; i += 1 )
		{
			x = RandRangeF( -1.0f, -0.5f );
			y = RandRangeF( -0.5f, 0.5f );
			z = RandRangeF( -0.5f, 0.5f );
			vec = Vector( x, y, z, 1 );
			vec = VecNormalize( vec );
			frag = (CProjectile)theGame.CreateEntity( metalFragment, pos, VecToRotation( vec ) );
			frag.ShootProjectileAtPosition( 0, speed, 0, vec * nailRange + pos );
			frag.PlayEffect('trail_fx');
		}
		
		//RIGHT
		for( i = 0; i < amount; i += 1 )
		{
			x = RandRangeF( 0.5f, 1.0f );
			y = RandRangeF( -0.5f, 0.5f );
			z = RandRangeF( -0.5f, 0.5f );
			vec = Vector( x, y, z, 1 );
			vec = VecNormalize( vec );
			frag = (CProjectile)theGame.CreateEntity( metalFragment, pos, VecToRotation( vec ) );
			frag.ShootProjectileAtPosition( 0, speed, 0, vec * nailRange + pos );
			frag.PlayEffect('trail_fx');
		}
		
		//FRONT
		for( i = 0; i < amount; i += 1 )
		{
			x = RandRangeF( -0.5f, 0.5f );
			y = RandRangeF( 0.5f, 1.0f );
			z = RandRangeF( -0.5f, 0.5f );
			vec = Vector( x, y, z, 1 );
			vec = VecNormalize( vec );
			frag = (CProjectile)theGame.CreateEntity( metalFragment, pos, VecToRotation( vec ) );
			frag.ShootProjectileAtPosition( 0, speed, 0, vec * nailRange + pos );
			frag.PlayEffect('trail_fx');
		}
		
		//BACK
		for( i = 0; i < amount; i += 1 )
		{
			x = RandRangeF( -0.5f, 0.5f );
			y = RandRangeF( -1.0f, -0.5f );
			z = RandRangeF( -0.5f, 0.5f );
			vec = Vector( x, y, z, 1 );
			vec = VecNormalize( vec );
			frag = (CProjectile)theGame.CreateEntity( metalFragment, pos, VecToRotation( vec ) );
			frag.ShootProjectileAtPosition( 0, speed, 0, vec * nailRange + pos );
			frag.PlayEffect('trail_fx');
		}
		
		//DOWN
		for( i = 0; i < amount; i += 1 )
		{
			x = RandRangeF( -0.5f, 0.5f );
			y = RandRangeF( -0.5f, 0.5f );
			z = RandRangeF( -0.5f, -1.0f );
			vec = Vector( x, y, z, 1 );
			vec = VecNormalize( vec );
			frag = (CProjectile)theGame.CreateEntity( metalFragment, pos, VecToRotation( vec ) );
			frag.ShootProjectileAtPosition( 0, speed, 0, vec * nailRange + pos );
			frag.PlayEffect('trail_fx');
		}
	}
}

class CTrapNekker extends CBaseTrap
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var nekker : CNekker;
		
		if( !isArmed )
			return false;
		
		if( activator.GetEntity().IsA( 'CNekker' ) )
		{
			nekker = (CNekker)activator.GetEntity();
			Trigger( nekker );
		}
	}
}

state Triggered in CTrapNekker
{
	entry function Trigger( target : CNekker )
	{
		parent.isArmed = false;
		parent.ApplyAppearance( "2_trap_explode" );
		parent.GetComponent( "PickupTrap" ).SetEnabled( false );
		
		target.EnterUnconscious();
		
		Sleep( 4.f );
		
		FactsAdd( "quest_nekker_is_captured", 1 );
		
		parent.Destroy();
	}
}

class CTrapHarpy extends CBaseTrap
{
	var nodes : array<CNode>;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		GetComponent( "PickupTrap" ).SetEnabled( true );
	}
	function GetNest() : CHarpyNest
	{
		var i, size : int;
		var nests : array<CHarpyNest>;
		var nest : CHarpyNest;
		var closestDistance, distance : float;
		
		closestDistance = 50.0; //nie zbieramy gniazd blizszych niz X metrow
		
		theGame.GetNodesByTag('harpy_nest', nodes);
		size = nodes.Size();
		for(i = 0; i < size; i += 1)
		{
			nest = (CHarpyNest)nodes[i];
			if(nest && !nest.IsNestDestroyed())
			{
				nests.PushBack(nest);
			}
		}
		nest = NULL; //ustawiam na NULL, zeby nadpisywac w kolejnej petli, jesli nie znajde gniazda, funkcja zwroci null
		size = nests.Size();
		for(i = 0; i < size; i += 1)
		{
			nest = nests[i];
			distance = VecDistance(nest.GetWorldPosition(), thePlayer.GetWorldPosition());
			if(distance <= closestDistance)
			{
				closestDistance = distance;
				nest = nests[i];
			}
		}
		return nest;	
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var harpy : CHarpie;
		
		if( !isArmed )
			return false;
		
		harpy = (CHarpie)activator.GetEntity();
		
		if( harpy && harpy.IsAlive() && harpy.HasTag('nest_harpy') )
		{
			Trigger( harpy );
		}
	}
}

state Triggered in CTrapHarpy
{

	function TrapEvent(trapEvent : W2BehaviorCombatAttack, actor : CActor) : bool
	{
		var trapEventInt : int;
		trapEventInt = (int)trapEvent;
		actor.GetBehTreeMachine().Stop();
		if(trapEventInt <= 0 || actor.SetBehaviorVariable("AttackEnum", (float)trapEventInt) == false)
		{
			Log("No trap event");
		}
		//parent.SetBehaviorVariable("HitEnum", (float)hitEventInt);
		return actor.RaiseForceEvent('Attack');
	}
	entry function Trigger( target : CHarpie )
	{
		var nestTag : name;
		var nest : CHarpyNest;
		var tags : array<name>;
		var i, size : int;
		
		parent.isArmed = false;
		parent.GetComponent( "PickupTrap" ).SetEnabled( false );
		
		target.SetAttitude( thePlayer, AIA_Neutral );
		target.GetArbitrator().AddGoalMoveToTarget( parent, MT_Run, 3.f, 0.2f, EWM_Exit );
		
		while( VecDistance2D( parent.GetWorldPosition(), target.GetWorldPosition()) > 0.3f )
		{
			if( !target.IsAlive() )
			{
				parent.ReturnToDefault( target );
			}
			
			Sleep( 0.3f );
		}
		
		//Raise event nie bedzie dzialac trzeba obsluzyc to na TreeCombatHarpy
		//target.RaiseEvent('AttackStatic1');
		
		//na treecombat:
		if(TrapEvent(BCA_MeleeAttack1, target))
		{
			Sleep( 2.f );
		}
		
		if( !target.IsAlive() )
		{
			parent.ReturnToDefault( target );
		}
		
		parent.ApplyAppearance( "triggered" );
		target.GetArbitrator().AddGoalDespawn( false, false );
		
		Sleep( 4.f );
		
		nest = parent.GetNest();
		if(nest)
		{
			nest.SpawnHarpyToNest();
		}
		
		parent.Destroy();
	}
}

state Default in CTrapHarpy
{
	entry function ReturnToDefault( currentTarget : CHarpie )
	{
		parent.isArmed = true;
		parent.GetComponent( "PickupTrap" ).SetEnabled( true );
		currentTarget.SetAttitude( thePlayer, AIA_Hostile );
	}
}

exec function AddHarpyTrap()
{
	thePlayer.GetInventory().AddItem( 'Harpy Bait Trap', 10 );
}

class CHarpyNest extends CGameplayEntity
{
	saved var wasDestroyed : bool;
	editable var harpy : CEntityTemplate;
	editable var useHighSpawn : bool;
	var harpyEnt : CHarpie;
	
	default useHighSpawn = true;
	default wasDestroyed = false;
	
	timer function TimerDestroyNest(td : float)
	{
		DestroyNest();
	}
	function DestroyNest()
	{
		var tags : array<name>;
		var i, size : int;
		this.PlayEffect( 'explosion_nest_fx' );
		this.ApplyAppearance("destroyed");
		this.SetDestroyed();
		if(harpyEnt)
		{
			harpyEnt.Kill(false, thePlayer);
		}
		tags = this.GetTags();
		size = tags.Size();
		for(i = 0; i < size; i += 1)
		{
			FactsAdd( "nest_" +  tags[i] + "_was_destroyed", 1 );
		}
	}
	function SpawnHarpyToNest()
	{
		var component : CComponent;
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		component = this.GetComponent("LandPoint");
		if(component)
		{
			spawnPos = component.GetWorldPosition();
			spawnRot = component.GetWorldRotation();
		}
		else
		{
			spawnPos = this.GetWorldPosition();
			spawnRot = this.GetWorldRotation();
		}
		if(harpy)
		{
			harpyEnt = (CHarpie)theGame.CreateEntity(harpy, spawnPos, spawnRot);
		}
		if(harpyEnt)
		{
			harpyEnt.UseHighSpawn(useHighSpawn);
			this.AddTimer('TimerDestroyNest', 2.9);
		}
		else
		{
			DestroyNest();
		}

	}
	function IsNestDestroyed() : bool
	{
		return wasDestroyed;
	}
	function SetDestroyed()
	{
		wasDestroyed = true;
	}
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		if(wasDestroyed)
		{
			this.ApplyAppearance("destroyed");
		}
		super.OnSpawned(spawnData);
	}

}