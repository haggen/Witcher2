/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Triss state for the walk along the beach on the beginning of act 1
/** Copyright © 2009
/***********************************************************************/

state WalkToTargetWithPlayer in CNewNPC extends Base
{
	private var hasReachedDestination : bool;
	default hasReachedDestination = false;
	
	var action : CActorLatentActionWalkToTargetWaitForPlayer;

	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
		
	entry function StateWalkToTargetWaitForPlayer( target : PersistentRef, distanceToStop : float, distanceToGo : float,
			moveType : EMoveType, absSpeed : float, stopOnCombat : bool, goalId : int )
	{			
		var entity : CEntity;
		var pos : Vector;
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		entity = PersistentRefGetEntity( target );
		if( entity )
		{
			parent.SetFocusedNode( entity );
		}
		else
		{
			pos = PersistentRefGetWorldPosition( target );
			parent.SetFocusedPostion( pos );
		}
			
		action = new CActorLatentActionWalkToTargetWaitForPlayer in this;
		action.distanceToStop = distanceToStop;
		action.distanceToGo = distanceToGo;
		action.moveType = moveType;
		action.absSpeed = absSpeed;
		action.stopOnCombat = stopOnCombat;
		
		action.Perform( parent );

		MarkGoalFinished();
	}
	
	entry function StateWalkAlongPathWaitForPlayer( path : EntityHandle, upThePath : bool, fromBegining : bool, 
												distanceToStop : float, distanceToGo : float, distanceToChangeSpeed : float, optional moveTypename : EMoveType, optional absSpeed : float, goalId : int )
	{
		var isMoving     			: bool;
		var distToPlayer 			: float;
		var player       			: CPlayer;
		var currPos      			: Vector;
		var FollowerTag				: array < name >;
		var countTags, i 			: int;
		var FollowerString			: string;
		var curSpeed				: float;
		var newSpeed				: float;
		var pathEntity				: CEntity;
		var pathComponent			: CPathComponent;
		
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		pathEntity = EntityHandleGet( path );
		pathComponent = pathEntity.GetPathComponent();
		
		if ( pathComponent )
		{
			FollowerTag = parent.GetTags();
			countTags   = FollowerTag.Size();
			
			// Initialize loop
			hasReachedDestination = false;
			player    = thePlayer;
			isMoving  = false;
			curSpeed  = 0;

			parent.ActionRotateToAsync( player.GetWorldPosition() );
			while ( true )
			{
				currPos      = parent.GetWorldPosition();
				distToPlayer = VecDistance( player.GetWorldPosition(), currPos );
				
				if ( isMoving && parent.IsCurrentActionSucceded() )
					break;
				
				// Wait for player
				if ( distToPlayer > distanceToStop )
				{
					for ( i = 0; i < countTags; i += 1 )
					{
						FollowerString = FollowerTag[i] + "_waiting" ;
						if( FactsQuerySum( FollowerString ) == 0 || FactsDoesExist ( FollowerString ) == false)
						{
							FactsAdd( FollowerString , 1);
						}
					}
					
					parent.ActionRotateToAsync( player.GetWorldPosition() );
					isMoving = false;
				}
				
				if( distToPlayer <= distanceToChangeSpeed )
					newSpeed = 2.f;
				else
					newSpeed = absSpeed;
				
				// Move to destination
				if ( ( ! isMoving || newSpeed != curSpeed ) && distToPlayer <= distanceToGo )
				{
					for ( i = 0; i < countTags; i += 1 )
					{
						FollowerString = FollowerTag[i] + "_waiting" ;
						if( FactsQuerySum( FollowerString ) == 1)
						{
							FactsAdd( FollowerString , -1);
						}
					}
					
					isMoving = parent.ActionMoveAlongPathAsync( pathComponent, upThePath, fromBegining, 1.f, moveTypename, newSpeed );
					curSpeed = newSpeed;
					fromBegining = false;
				}
				
				Sleep( 1.f );
			}
		}
		hasReachedDestination = true;
		MarkGoalFinished();
	}
};
