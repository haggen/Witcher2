/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatMonster in W2Monster extends TreeCombatStandard
{	
	private final function GetDodgeEventDirection( eventName : name ) : name
	{
		if( StrFindFirst( eventName, 'Back' ) >= 0 )
		{
			return 'Back';
		}
		else if( StrFindFirst( eventName, 'Left' ) >= 0 )
		{
			return 'Left';
		}
		else if( StrFindFirst( eventName, 'Right' ) >= 0 )
		{
			return 'Right';
		}
		else
		{
			Log("GetDodgeEventDirection error: direction not recognized");
			return 'Back';
		}
	}
	
	private final function DodgeDirectionToPosition( direction : EDirection ) : Vector
	{
		var offset : Vector;
		var mat : Matrix;
		var delta : float;
		mat = parent.GetLocalToWorld();
		delta = 0.4;
		
		if( direction == D_Back )
		{
			return mat.W-mat.Y*delta;
		}
		else if( direction == D_Left )
		{
			return mat.W-mat.X*delta;
		}
		else
		{
			return mat.W+mat.X*delta;
		}
	}
			
	private final function GetDodgeEventNameFiltered( subStrings : array<name> ) : name
	{
		parent.GetCombatEventsProxy().GetDodgeEventNameFiltered( subStrings );
	}
	
	private entry function TreeDodgeStart()
	{
		var s : int;
		var direction : EDirection;
		var validDirections : array<EDirection>;
		var mac : CMovingAgentComponent = parent.GetMovingAgentComponent();
		var dodgeEnum : W2BehaviorCombatHit;
		
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		
		parent.ClearRotationTarget();		
		//parent.SetRotationTarget( parent.GetTarget() );
		
		parent.AddTimer( 'ClearTargetRotationTarget', 0.1f, false );
		parent.ActionRotateToAsync( parent.GetTarget().GetWorldPosition() );
			
		dodgeEnum = parent.GetCombatEventsProxy().GetDodgeBackEnum();
		
		if(dodgeEnum != BCH_None)
		{
			if(HitEvent(dodgeEnum))
			{
				Sleep(0.1);
				parent.WaitForBehaviorNodeDeactivation('HitEnd');
			}
		}

		TreeDodgeStop();
	}
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		YrdenReactionMonster(yrden);
	}
	entry function YrdenReactionMonster(yrden : CWitcherSignYrden)
	{
		var immobileDuration : float;
		immobileDuration = yrden.GetImmobileTime();
		parent.GetBehTreeMachine().Stop();
		parent.ClearRotationTarget();
		parent.CantBlockCooldown(immobileDuration);
		parent.ActionCancelAll();
		HitEvent(BCH_HitYrden);
		Sleep(0.1);
		Sleep(immobileDuration);
		parent.RaiseEvent('Idle');
		Sleep(0.1);
		parent.GetBehTreeMachine().Restart();

	}
	private entry function TreeDodgeStop()
	{
		parent.SetBlockingHit( false );		
		parent.GetBehTreeMachine().Restart();
	}
	
	timer function ClearTargetRotationTarget( timeDelta : float )
	{
		parent.GetTarget().ClearRotationTarget();
	}
}