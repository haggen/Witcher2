/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Triss Combat state
/** Copyright © 2009
/***********************************************************************/


state CombatTriss in CNewNPC
{
	var combatParams : SCombatParams;
	
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
	
		super.OnEnterState();	
		parent.ActivateBehavior( 'triss_combat' );
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec(180);		
		
		if( !parent.GetInventory().HasItem('Triss Weapon') )
		{
			parent.GetInventory().AddItem('Triss Weapon', 1);
			weaponId = parent.GetInventory().GetItemId('Triss Weapon');
			parent.EquipItem(weaponId, true);
		}		
		parent.DrawWeaponInstant( parent.GetInventory().GetFirstLethalWeaponId() );
	}	
			
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.StopEffect('cast1_hand_fx');
		//parent.GetRootAnimatedComponent().PopBehaviorGraph( 'triss_combat' );	
		parent.GetMovingAgentComponent().SetMaxMoveRotationPerSec(720);
		parent.ClearRotationTarget();
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	

		if( animEventName == 'CastStart' )
		{						
			parent.PlayEffect('cast1_hand_fx');		
		}
		
		if( animEventName == 'MagicAttack_t1' )
		{						
			parent.PlayEffect('cast1_fireshot_fx');		
		}
		
		else if ( animEventName == 'CastEnd' )	
		{						
			parent.StopEffect('cast1_hand_fx');		
		}
	}

	entry function CombatTriss( params : SCombatParams )
	{
		var target : CActor;
		var targetNPC : CNewNPC;
		var dist : float;		
		var targetPos, leaderPos, npcPos, dest, dest2 : Vector;			
		var leader : CActor;
		var iter : int;
		var mac : CMovingAgentComponent;
		
		combatParams = params;		
		
		leader = thePlayer;
		
		mac = parent.GetMovingAgentComponent();		
				
		parent.ActionCancelAll();		
		parent.RaiseForceEvent ( 'EnterCombat' );
		parent.WaitForBehaviorNodeDeactivation ( 'CombatEntered' );
				
		while( 1 )
		{			
			target = parent.GetTarget();
		
			leaderPos = leader.GetWorldPosition();
			npcPos = parent.GetWorldPosition();
			
			targetPos = target.GetWorldPosition();
			
			dist = VecDistance2D( targetPos, npcPos );
			
			// if too far or to close to target, or leader in line of fire move to new position
			if( dist > 6.0 || !LeaderTargetPositionCheck( npcPos, targetPos, leaderPos ) || !mac.IsEndOfLinePositionValid( targetPos ) )
			{				
				iter = 0;
				do
				{					
					dest = targetPos + VecRingRand( 3.1, 5.9 );					
					
					if( LeaderTargetPositionCheck( dest, targetPos, leaderPos ) && mac.IsEndOfLinePositionValid( dest ) )
					{
						break;
					}					
					
					iter += 1;					
					
					Sleep(0.05);				
				}
				while ( ( iter < 10 ) );
								
				if( mac.GetEndOfLineNavMeshPosition( dest, dest2 ) )
				{	
					if( VecDistance2D( dest2, npcPos ) < 2.0 )
					{
						parent.ActionMoveToAsync( dest2, MT_Run, 1.0f, 2.0 );
					}
					else
					{
						parent.ActionMoveToAsync( dest2, MT_Walk, 1.0f, 2.0 );
					}
				}
			}
			else if( dist < 2.4 )
			{
				//RotateToTarget( target, 1.5 );
				parent.ActionMoveAwayFromNode( target, 2.5, MT_Walk, -1.0, 2.0 );
			}
			
			if( !parent.IsRotatedTowards(target) )
			{
				RotateToTarget( target, 1.5 );
			}
			
			leaderPos = leader.GetWorldPosition();
			npcPos = parent.GetWorldPosition();
			targetPos = target.GetWorldPosition();
			if( LeaderTargetPositionCheck(npcPos, targetPos, leaderPos) )
			{
				//parent.PlayEffect('cast1_hand_fx');
				parent.SetRotationTarget( target );
				parent.RaiseForceEvent ( 'AttackMagic1');
				Sleep(0.5);
				target.PlayEffect('hit_cast1_triss');
				target.PlayEffect('dead_fire_fx');
				target.Hit(parent, 'MagicAttack_t1');
				parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
				parent.ClearRotationTarget();
				//parent.StopEffect('cast1_hand_fx');				
				//parent.StopEffect('cast1_hand_fx');				
			}
			else
			{
				Sleep(0.5);
			}
		}
				
		//parent.StopEffect('cast1_hand_fx');
		Sleep(0.5);
		parent.RaiseForceEvent ( 'CombatExit' );
		parent.WaitForBehaviorNodeDeactivation ( 'CombatExitEnd' );
	}
	
	private function DebugRot(angle: float)
	{
		parent.GetVisualDebug().AddText( 'rot', "Rotation "+angle, Vector(0,0,0.5), false, 0, Color(255,255,0), false, 2.0 );
	}
	
	latent function RotateToTarget( target : CEntity, time180 : float )
	{
		var vec : Vector;
		var rot, curRot : EulerAngles;
		var angleDistance, r, time : float;		
		
		if( target )
		{
			vec = target.GetWorldPosition() - parent.GetWorldPosition();
			rot = VecToRotation( vec );
			
			curRot = parent.GetWorldRotation();
			angleDistance = AngleDistance( curRot.Yaw, rot.Yaw );
			
			time = time180 * AbsF( angleDistance )/180.0;
			if( AbsF( angleDistance ) < 30 )
			{
				DebugRot( angleDistance);
				parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time );				
			}
			else if( angleDistance > 0 && angleDistance < 140 )
			{
				DebugRot( angleDistance );
				time = 0.8;
				parent.RaiseForceEvent( 'TurnRight' );
				parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time );				
			}
			else if( angleDistance < 0 && angleDistance > -140 )
			{
				DebugRot( angleDistance );
				time = 0.8;
				parent.RaiseForceEvent( 'TurnLeft' );
				parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time );				
			}
			else
			{
				if( angleDistance < 0 )
				{			
					DebugRot( angleDistance );
					parent.RaiseForceEvent( 'Turn180' );
					parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time );					
				}
				else
				{
					r = 360.0 - angleDistance;
					DebugRot( r );
					parent.RaiseForceEvent( 'Turn180' );
					parent.ActionSlideToWithHeading( parent.GetWorldPosition(), rot.Yaw, time180*0.5, SR_Left );
					//parent.ActionSlideToWithHeading( parent.GetWorldPosition(), curRot.Yaw + r*0.5, time180*0.5 );
					//parent.ActionSlideToWithHeading( parent.GetWorldPosition(), curRot.Yaw + r,		time180*0.5 );
				}
			}
			parent.RaiseForceEvent( 'Idle' );
		}
	}
	
	function LeaderTargetPositionCheck( npcPos, targetPos, leaderPos : Vector ) : bool
	{
		var v1, v2 : Vector;
		
		v1 = VecNormalize2D( npcPos - targetPos );	v1.Z = 0;
		v2 = VecNormalize2D( leaderPos - targetPos );	v2.Z = 0;
		
		// leader must not be in line of fire
		return ( VecDistanceToEdge( leaderPos, npcPos, targetPos ) > 1.0 ) || ( VecDot2D( v1, v2 ) < 0.707 );
	}
};
