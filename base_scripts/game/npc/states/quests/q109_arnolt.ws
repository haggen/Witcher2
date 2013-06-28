state Q109Arnolt in CNewNPC extends Base
{
	entry function StateQ109Arnolt()
	{
		var Destination : CNode;
		var player_in_scene : CActor;
		
		parent.ChangeNpcExplorationBehavior();
		
		player_in_scene = thePlayer;

		Destination = theGame.GetNodeByTag( 'q109_arnolt_torch_litup' );
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( Destination.GetWorldPosition() );
		//parent.ActionMoveToNodeWithHeading( Destination, MT_Walk, 1, 0.1f );
		parent.ActionMoveToNode( Destination, MT_Walk, 1, 0.1f );
		
		MarkGoalFinished();
		
	}
};