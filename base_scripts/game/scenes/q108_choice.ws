////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions for act 1 quest q001_choice
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

latent storyscene function q108_ZoltanLightCampfire( player: CStoryScenePlayer ) : bool
{
	var zoltan : CNewNPC;
	var target : CNode;
	var dist : float;
	
	zoltan = theGame.GetNPCByTag( 'Zoltan' );
	target = theGame.GetNodeByTag('q108_campfire_scene');
	
	//zoltan.BreakWorking();
	
	zoltan.GetArbitrator().AddGoalMoveToTarget( target, MT_Walk, 2.f, 0.5f, EWM_Exit );
	
	dist = VecDistance2D( target.GetWorldPosition(), thePlayer.GetWorldPosition() );
	
	while( dist > 1.f )
	{
		dist = VecDistance2D( target.GetWorldPosition(), zoltan.GetWorldPosition() );
	
		Sleep(0.1f);
	}
	
	theGame.GetEntityByTag('q108_fireplace').PlayEffect( 'fire' );
	
	Sleep( 5.f );
	
	return true;
}