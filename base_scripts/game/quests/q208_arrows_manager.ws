// ---------------------------------------------------------
//                  Q208 Arrrows Manager
// ---------------------------------------------------------

class q208_ArrowsManager extends CEntity
{	
	var shootingStart : CNode;
	editable var projectileTemplate : CEntityTemplate;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Idle();
		//StartShooting();
	}
}

state Idle in q208_ArrowsManager
{
	entry function Idle()
	{
		parent.RemoveTimer('ShooterUpdate');
	}
	
}

state Shooting in q208_ArrowsManager
{
	timer function ShooterUpdate(timeDelta : float)
	{
		ShootTestArrows(thePlayer);
	}

	entry function StartShooting()
	{
		//Sleep(0.1);
		parent.shootingStart = theGame.GetNodeByTag( 'shooting_start' );
		ShootTestArrows(thePlayer);
		parent.AddTimer('ShooterUpdate', 4.8f, true); 
	}
	
	function ShootTestArrows(target : CActor)
	{
		var i : int;
		var proj : q208_arrows;
		var vTarget : Vector;
		var targetPos, movementDirection : Vector;
		var rTarget : EulerAngles;
		var normal : EulerAngles;
		var distance : float;
		var fact : int;
		
		distance = 7.0;
		
		theSound.PlaySoundOnActor(parent, '', "l03_camp/l03_quests/q208/draug_arrows_release");
		theSound.PlaySoundOnActor(thePlayer, '', "combat/combat_dwarf/special/dwarf_battle_horn");
		
		for( i = 0; i < ( 250 * theGame.GetDifficultyLevelMult() ) ; i += 1 )
		{
			vTarget = parent.GetWorldPosition();
			vTarget += VecRingRand( 0.0, 10.0 );
			vTarget.Z = 5.0;
			proj = (q208_arrows)theGame.CreateEntity(parent.projectileTemplate , vTarget, EulerAngles()); 
			proj.InitSound(AST_GroupOfArrows);
			fact = FactsQuerySum( "q208_geralt_near_barricade" );
			
			if( proj )
			{
				targetPos = target.GetWorldPosition() + VecRingRand(0.0, 10.0);
				/*if(target.GetMovingAgentComponent().GetMoveSpeedAbs() > 0.75)
				{
					movementDirection = VecNormalize(VecFromHeading(target.GetHeading()));
					targetPos += distance*movementDirection;
					
				}*/
				
				
				if(fact != 1)
				{
					if(theGame.GetWorld().PointProjectionTest(targetPos, normal, 2.0))
					{
						proj.PlayEffect('trials');
						proj.PlayEffect('trials_particle');
						proj.Start( NULL, targetPos, false, 30.0 ); 
					}
					else
					{
						proj.Destroy();
					}
				}
				else
				{				
					if(i%25 == 0)
					{
						proj.PlayEffect('trials');
						proj.PlayEffect('trials_particle');
						proj.Start(target, Vector(0, 0, 0), false, 30.0 ); 
					}
					else
					{
						proj.PlayEffect('trials');
						proj.PlayEffect('trials_particle');
						proj.Start( NULL, targetPos, false, 30.0 ); 
					}
				}
			}
			else
			{
				Log("Cannot create projectile");
			}
		}
	}
}

// ---------------------------------------------------------
//                  Q208 Balls Manager
// ---------------------------------------------------------

class q208_BallsManager extends CEntity
{	
	editable var projectileTemplate : CEntityTemplate;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Idle();
	}
}

state Idle in q208_BallsManager
{
	entry function Idle()
	{
		parent.RemoveTimer('ShooterUpdate');
	}
	
}

state Shooting in q208_BallsManager
{
	timer function ShooterUpdate(timeDelta : float)
	{
		ShootBall(thePlayer);
	}

	entry function StartShooting()
	{
		ShootBall(thePlayer);
		parent.AddTimer('ShooterUpdate', 4.0f, true); 
	}
	
	function ShootBall(target : CActor)
	{
		var i : int;
		var proj : q208_arrows;
		var vTarget : Vector;
		var targetPos, movementDirection : Vector;
		var rTarget : EulerAngles;
		var distance : float;
		
		distance = 2.0;
		
		targetPos = target.GetWorldPosition() + VecRingRand(0.0, 10.0);
		
		if(target.GetMovingAgentComponent().GetMoveSpeedAbs() > 0.75)
		{
			movementDirection = VecNormalize(VecFromHeading(target.GetHeading()));
			targetPos += distance*movementDirection;		
		}
		theGame.CreateEntity( parent.projectileTemplate, targetPos);
	}
}


