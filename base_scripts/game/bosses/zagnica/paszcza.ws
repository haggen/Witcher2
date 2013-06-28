/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Zagnica's Paszcza class
/////////////////////////////////////////////

class ZagnicaPaszcza extends ZagnicaAttack
{
	var screamAttackEvent : name;
	var screamAttackZone : name;
	var spitAttackEvent : name;
	var spitAttackZone : name;
	
	var ForceIdleEvent : name;	
	var IdleActivateNotifier : name;
	var	IdleDeactivateNotifier : name;
	var screamInProgress : bool;
	
	function BindVariables()
	{
		IdleActivateNotifier = 'Idle_activate_zagn';
		IdleDeactivateNotifier = 'Idle_deactivate_zagn';
		
		spitAttackZone = 'Mouth_range';
		spitAttackEvent = 'ranged1';
		
		screamAttackZone = 'Scream_range';
		screamAttackEvent = 'scream_start';
		
		ForceIdleEvent = 'force_idle';
	}
	
	
	function ScreamCanOccur() : bool
	{
		if( zgn.CheckInteractionPlayerOnly( screamAttackZone ) )
		{
			if ( !zgn.ExclusiveAttackInProgress )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	
	function SpitCanOccur() : bool
	{	
		if ( isAttacking || zgn.ExclusiveAttackInProgress || zgn.AnyMackaImmobilized() )
		{
			return false;
		}
		
		if ( zgn.MissedAttacksCount >= 1 && zgn.CheckInteractionPlayerOnly( zgn.Paszcza.spitAttackZone ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function RageAttack()
	{
		DoRage();
	}
	
	function TryingEscape()
	{	
		DoTryEscape();
	}
	
	function RodeoHitBridge()
	{
		DoRodeoHitBridge();
	}
	function StopAttacks()
	{
		DoStopAttacks();
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// States for Zagnica's paszcza
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

state Idle in ZagnicaPaszcza
{
	entry function ReturnToIdle()
	{
		parent.isAttacking = false;
	}
}

state VerticalAttack in ZagnicaPaszcza
{
	entry function DoVerticalAttackMouth()
	{
		var eventProcessed : bool;
		var res : bool;
		
		parent.isAttacking = true;
		
		eventProcessed = parent.zgn.RaiseEvent( parent.zgn.VerticalAttackMouthEvent );
		
		if ( eventProcessed )
		{
			res = parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier );
			if( !res )
				res = false;
			parent.isAttacking = false;
		}
		else
		{
			parent.isAttacking = false;
		}
	}
}

state HorizontalAttack in ZagnicaPaszcza
{
	entry function DoHorizontalAttackMouth()
	{
		var eventProcessed : bool;
		
		parent.isAttacking = true;
		
		eventProcessed = parent.zgn.RaiseEvent( parent.zgn.HorizontalAttackMouthEvent );
		
		if( eventProcessed )
		{
			parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier );
			parent.isAttacking = false;
		}
		else
		{
			parent.isAttacking = false;
		}
	}
}

state RoarAttack in ZagnicaPaszcza
{
	entry function DoRoarAttack()
	{
		var res : bool;
		
		parent.zgn.StopMackasAttacks();
		
		while ( parent.zgn.AnyMackaAttacking() )
		{
			Sleep( 0.00001f );
		}
		
		parent.isAttacking = true;
		parent.zgn.ExclusiveAttackInProgress = true;
		
		parent.zgn.RaiseForceEvent( parent.screamAttackEvent );
		parent.zgn.WaitForBehaviorNodeDeactivation( 'scream_ended' );

		parent.isAttacking = false;
		parent.zgn.ExclusiveAttackInProgress = false;
	}
}

state SpitAttack in ZagnicaPaszcza
{
	entry function DoSpitAttack()
	{	
		var zgnPos, playerPos : Vector;
		var csRot : EulerAngles;
		var res : bool;
	
		parent.zgn.MissedAttacksCount = 0;
		parent.zgn.ExclusiveAttackInProgress = true;
		parent.isAttacking = true;
		
		parent.zgn.StopMackasAttacks();
		
		while ( parent.zgn.AnyMackaAttacking() )
		{
			Sleep( 0.001f );
		}
		
		parent.zgn.RaiseForceEvent( parent.spitAttackEvent );
		parent.zgn.WaitForBehaviorNodeDeactivation( 'Ranged_deactivate_zagn' );
		
		if( parent.zgn.spitHasHit )
		{
			parent.zgn.spitHasHit = false;
			
			parent.zgn.RaiseForceEvent( 'finisher1_start' );
			parent.zgn.WaitForBehaviorNodeDeactivation( 'finisher_end' );
		}
		
		parent.isAttacking = false;
		parent.zgn.ExclusiveAttackInProgress = false;
	}
}
state Rage in ZagnicaPaszcza
{
	entry function DoRage()
	{
		var screamHasHit : bool;
		
		parent.zgn.ExclusiveAttackInProgress = true;
		
		parent.zgn.RaiseForceEvent( 'rage_start' );
		((CActor)parent.zgn.Sheala).PlayScene( "Warning1" ); 
		parent.screamInProgress = false;
		
		while( !parent.screamInProgress )
		{
			Sleep( 0.1f );
		}
		
		while( parent.screamInProgress )
		{
			if( parent.zgn.CheckInteractionPlayerOnly( parent.screamAttackZone ) && !screamHasHit )
			{	
				screamHasHit = true;
				thePlayer.ZgnHit( parent.zgn, 'roar', parent.zgn.GetWorldPosition() );
				parent.zgn.AddTimer( 'Blur', 0.1f, true );
				
				Sleep ( 2.f );
				screamHasHit = false;
			}
			
			Sleep ( 0.01f );
		}
		
		parent.zgn.WaitForBehaviorNodeDeactivation( 'rage_stop', 20 );
		
		parent.zgn.ExclusiveAttackInProgress = false;
		
		parent.zgn.SpecialAttackDelay( 1.f );
	}
}

state TryingEscape in ZagnicaPaszcza
{
	entry function DoTryEscape()
	{
		parent.screamInProgress = false;
		
		while( !parent.screamInProgress )
		{
			Sleep( 0.1f );
		}
		
		while( parent.screamInProgress )
		{
			if( parent.zgn.CheckInteractionPlayerOnly( parent.screamAttackZone ) )
			{
				thePlayer.ZgnHit( parent.zgn, 'roar', parent.zgn.GetWorldPosition() );
				parent.zgn.AddTimer( 'Blur', 0.1f, true );
			}
			
			Sleep ( 0.1f );
		}
	}
}

state StopAttacks in ZagnicaPaszcza
{
	entry function DoStopAttacks()
	{
		parent.zgn.RaiseEvent('force_idle');
	}
}

state RodeoHitBridge in ZagnicaPaszcza
{
	entry function DoRodeoHitBridge()
	{
		parent.zgn.RaiseEvent( 'rodeo_hit_bridge' );
	}
}