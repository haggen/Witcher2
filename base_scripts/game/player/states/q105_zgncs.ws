/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

////////////////////////////////////////////////////////
// State in player, when cutscene with Zagnica starts //
////////////////////////////////////////////////////////
/*
state ZgnCS in CPlayer extends Cutscene
{
	event OnCutsceneEnded()
	{
		super.OnCutsceneEnded();
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if ( animEventName == 'body' )
		{
			((Zagnica)theGame.GetActorByTag('zagnica')).StartCuttingMacka();
		}
	}
	
	entry function EnterCutsceneZgnState( oldPlayerState : EPlayerState, behStateName : string )
	{
		csRunning = true;
		prevState = oldPlayerState;
		prevBehState = behStateName;
	}
}
*/