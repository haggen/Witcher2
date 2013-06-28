state CiuciuBabkaPlayer in CNewNPC extends Base
{
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
		parent.ActivateBehavior( 'npc_exploration' );
	}
	
	//Funkcja obs³uguj¹ca zachowanie uczestników gry w momencie gdy NPC jest "ciuciubabk¹"
	entry function JoinCiuciuBabka( blindMan : CNewNPC, playRange : float, centerPoint : CNode )
	{
		var actorPosition	: Vector;
		var isReturning		: bool;
		var i : int;
			
		while ( true )
		{
			// Give new orders to ciuciubabkaPlayer
			if ( ! isReturning )
			{
				parent.ActionRotateTo(blindMan.GetWorldPosition());
				
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) > playRange )
				{
					parent.ActionMoveToNodeAsync(centerPoint, MT_Walk, 1.f, playRange ); 
					isReturning = true;
				}
				else
				// Give new orders to ciuciubabkaPlayer
				if ( !parent.IsCurrentActionInProgress() )
				{
					if( VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) < 1.8 )
					{
						i = Rand (4);
							
						if (i == 1)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpB', 0.2, 0.3, true);
						}
						else if (i == 2)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpL', 0.2, 0.3, true);
						}
						else if (i == 3)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpR', 0.2, 0.3, true);
						}
						else
						{
							parent.ActionMoveAwayFromNode( blindMan, 2.f, MT_Walk, 1.f, 4.f) ;
						}
							
					}
					else
					
					if( VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) > 2.5 && VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) <= playRange)
					{
						/*i = Rand (3);
					
						if (i == 1)
						{
							parent.ActionPlaySlotAnimation("NPC_ANIM_SLOT", 'c_sword_idle', 0.2, 0.3, false);
							
							if ( VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) < 1.5 )
							{
								parent.ActionPlaySlotAnimation("NPC_ANIM_SLOT", 'c_sword_cjumpB', 0.2, 0.3, true);
							}
						}
						else if (i == 2)
						{
							parent.ActionPlaySlotAnimation("NPC_ANIM_SLOT", 'work_retreat01', 0.2, 0.3, false);
							
							if ( VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) < 1.5 )
							{
								parent.ActionPlaySlotAnimation("NPC_ANIM_SLOT", 'c_sword_cjumpB', 0.2, 0.3, true);
							}
						}*/
							
						if (!blindMan.IsRotatedTowardsPoint(parent.GetWorldPosition(), 90 ))
						{
							i = Rand (4);
							
							if ( i == 1 || i == 2 )
							{
								parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpF', 0.2, 0.3, true);
								
								if ( VecDistance2D( parent.GetWorldPosition(), blindMan.GetWorldPosition() ) < 1.5 )
								{
									parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpB', 0.2, 0.3, true);
								}
							}
						}
					}
				}
			}
			else
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) <= playRange )
				{
					isReturning = false;
					parent.ActionCancelAll();
				}
			}
			
			Sleep ( 0.5 );
		}
	}
	//Funkcja obs³uguj¹ca zachowanie uczestników gry w momencie gdy gracz jest "ciuciubabk¹"
	entry function JoinCiuciuBabkaWithGeralt( geralt : CPlayer, playRange : float, centerPoint : CNode )
	{
		var actorPosition	: Vector;
		var isReturning		: bool;
		var i : int;
		
		while ( true )
		{
			// Give new orders to ciuciubabkaPlayer
			if ( ! isReturning )
			{
				parent.ActionRotateTo(geralt.GetWorldPosition());
				
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) > playRange )
				{
					parent.ActionMoveToNodeAsync( centerPoint, MT_Walk, 1.f, playRange ); 
					isReturning = true;
				}
				else
				// Give new orders to ciuciubabkaPlayer
				if ( !parent.IsCurrentActionInProgress() )
				{
					if( VecDistance2D( parent.GetWorldPosition(), geralt.GetWorldPosition() ) < 1.8 )
					{
						i = Rand (4);
							
						if (i == 1)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpB', 0.2, 0.3, true);
						}
						else if (i == 2)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpL', 0.2, 0.3, true);
						}
						else if (i == 3)
						{
							parent.ActionPlaySlotAnimation('NPC_ANIM_SLOT', 'c_sword_cjumpR', 0.2, 0.3, true);
						}
						else
						{
							parent.ActionMoveAwayFromNode( geralt, 2.f, MT_Walk, 1.f, 4.f) ;
						}
					}
				}
			}
			else
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), parent.GetWorldPosition() ) <= playRange )
				{
					isReturning = false;
					parent.ActionCancelAll();
				}
			}
				/* Give new orders to geralt
			if ( ! playerIsReturning )
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), geralt.GetWorldPosition() ) > playRange -1 )
				{
					theCamera.LookAtNode( centerPoint, true );
					//geralt.ActionRotateTo(centerPoint.GetWorldPosition());
					playerIsReturning = true;
				}
				
			}
			else
			{
				if ( VecDistance2D( centerPoint.GetWorldPosition(), geralt.GetWorldPosition() ) < playRange -1 )
				{
					playerIsReturning = false;
					theCamera.LookAtDeactivation();
					geralt.ActionCancelAll();
				}
			}*/
			
			Sleep ( 0.5 );
		}	
	}
}