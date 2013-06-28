////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions for act 2 quest q203_xeranthemum
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

latent storyscene function q203_NecrophageRunScene( player: CStoryScenePlayer, destinationTag : name ) : bool
{
	var necrophages : array<CNewNPC>;
	var size, i : int;
	var destination : CNode;
	
	theGame.GetNPCsByTag( 'q203_necrophage_w2', necrophages );
	size = necrophages.Size();
	destination = theGame.GetNodeByTag( destinationTag );
	
	for( i = 0; i < size - 1; i += 1 )
	{
		if( necrophages[i].IsAlive() )
		{
			
			necrophages[i].GetArbitrator().AddGoalMoveToTarget( destination, MT_Run, 3.0f, 0.5f, EWM_Exit );
			
			break;
		}
	}
	
	theCamera.FocusOn( necrophages[i] );
	Sleep( 6.f );
	theCamera.FocusDeactivation();
	
	return true;
}