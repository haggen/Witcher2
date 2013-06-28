/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

////////////////////////////////////////////////////////////////////////

class CDragonCover extends CGameplayEntity
{
	editable var coverNumber : int;

	var dragon : CDragon;
	var BreathCoveringActors : array<CActor>;
	saved var isBurning, isActive : bool;

	default isActive = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var comp : CDestructionSystemComponent;
		
		super.OnSpawned( spawnData );
		
		comp = (CDestructionSystemComponent)GetComponent( "DestructionWall" );
		comp.SetTakesDamage( false );
		
		if( !isActive )
		{
			deactivateCover();
			RaiseForceEvent( 'forceDestroy' );
			PlayEffect( 'burned' );
		}
		else if( isBurning )
			burnCover();
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CActor;
	
		affectedEntity = (CActor) activator.GetEntity();
		BreathCoveringActors.PushBack( affectedEntity );
		
		if( activator.GetEntity() == thePlayer )
		{
			dragon.OnPlayerChangedCover( coverNumber - 1, false );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CActor;
	
		affectedEntity = (CActor) activator.GetEntity();
		BreathCoveringActors.Remove( affectedEntity );
		
		if( activator.GetEntity() == thePlayer )
		{
			dragon.OnPlayerChangedCover( coverNumber - 1, true );
		}
	}
}

state active in CDragonCover
{
	entry function activateCover()
	{
		parent.dragon = (CDragon) theGame.GetActorByTag( 'Dragon' );
	}	
}

state burning in CDragonCover
{
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if( eventName == 'hoarding_burned' )
		{
			parent.deactivateCover();
		}
	}
	
	entry function burnCover()
	{
		parent.RaiseEvent( 'destroy' );
		parent.isBurning = true;
		
		parent.dragon.coverManager.OnCoverStartBurning( parent );
	}
}

state destroyed in CDragonCover
{
	entry function deactivateCover()
	{
		var comp : CComponent;
		var dscomp : CDestructionSystemComponent;
		
		comp = parent.GetComponent( "ParticleCollider" );
		comp.SetEnabled( false );
		
		dscomp = (CDestructionSystemComponent)parent.GetComponent( "DestructionWall" );
		dscomp.SetTakesDamage( true );
		
		parent.dragon.coverManager.OnCoverBurned( parent.coverNumber );
		parent.isActive = false;
	}
}
