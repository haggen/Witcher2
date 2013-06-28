// Simaple custom behavior state nonblocking for npc
state Behavior in CNewNPC extends Base
{
	var behaviorName : name;

	entry function StateBehavior( behaviorName : name, goalId : int )
	{
		SetGoalId( goalId );
		this.behaviorName = behaviorName;
		parent.ActivateBehavior( behaviorName );
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
	
	event OnManualCarry()
	{
		if( behaviorName == 'arian_sitting' )
		{
			return true;
		}
		
		return false;
	}
}