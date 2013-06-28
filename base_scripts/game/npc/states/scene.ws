/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Scene state
/////////////////////////////////////////////


state PrepareForScene in CNewNPC extends Base
{
	event OnLeaveState()
	{
		//MarkGoalFinished();
	}
	
	entry function StatePrepareForScene( scenePosition : Vector, heading : float, distance : float, moveType : EMoveType, goalId : int  )
	{
		SetGoalId( goalId );
		parent.ActionExitWork();
		
		parent.ActionMoveToWithHeading( scenePosition, heading, moveType, 1.0f, distance, MFA_EXIT );
		 
		if ( VecDistance( parent.GetWorldPosition(), scenePosition ) > distance )
		{
			parent.ActionSlideToWithHeading( scenePosition, heading, 0.5f );
			if ( VecDistance( parent.GetWorldPosition(), scenePosition ) > distance )
			{
				parent.Teleport( scenePosition );
			}
		}
		
		while ( true )
		{
			Sleep( 0.1f );
		}
	}
	
	entry function StateWorkInScene( apId : int, category : name, moveType : EMoveType, goalId : int )
	{
		var apMan : CActionPointManager = theGame.GetAPManager();
		var jobTree : CJobTree;
	
		SetGoalId( goalId );
		parent.ActionExitWork();
		
		jobTree = apMan.GetJobTree( apId );
		
		parent.MoveToActionPoint( apId, false, moveType );
		parent.SetActiveActionPoint( apId, category );
		parent.SetCurrentlyWorkingInAP( true );
		parent.ActionWorkJobTree( jobTree, category, false );
		
	}
	
	event OnSceneEnded()
	{
		parent.OnSceneEnded();
		parent.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalPrepareForScene' );
		parent.GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalWorkInScene' );
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
}


import state Scene in CNewNPC extends Base
{
	var behaviorGraphSet : bool;
	
	event OnEnterState()
	{
		super.OnEnterState();
		behaviorGraphSet = false;
		
		parent.SetLookAtMode( LM_Dialog );
	}

	event OnLeaveState()
	{
		parent.ResetLookAtMode( LM_Dialog );
		
		if( behaviorGraphSet )
		{
			//parent.PopBehavior( 'StoryScene' );
			behaviorGraphSet = false;
		}
	}
	
	event OnSceneEnded()
	{
		parent.OnSceneEnded();
		MarkGoalFinished();
	}

	entry function StateScene( scene : CStoryScene, goalId : int )
	{	
		var voicetag : CName;
		//var behaviorGraph : CBehaviorGraph;
		var animset : CSkeletalAnimationSet;
		var components : array< CComponent >; 
		var interactionComp : CInteractionComponent;
		var actionName : string;
		var i, count : int;
		
		SetGoalId( goalId );
		
		parent.ActionExitWork();
		parent.ActionCancelAll();
		
		voicetag = parent.GetVoicetag();
		
		animset = scene.GetCustomAnimset( voicetag );
		if ( animset )
		{
			parent.AddAnimset( animset );
		}
		
		if ( parent.ActivateBehavior( 'StoryScene' ) )
		{
			behaviorGraphSet = true;
		}
		if ( parent.IsInNonGameplayCutscene() )
		{
			parent.DisableLookAt();
		}
		
		/*
		// for the duration of the scene disable all talk-related interaction components
		components = parent.GetComponentsByClassName( 'CInteractionComponent' );
		count = components.Size();
		for ( i = 0; i < count; i += 1 )
		{
			interactionComp = ( CInteractionComponent )( components[ i ] );
			actionName = interactionComp.GetActionName();
			if ( actionName == "Talk" )
			{
				interactionComp.SetEnabled( false );
			}
		}
		*/

	}
}
