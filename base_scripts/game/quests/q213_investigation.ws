/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** PlayerInvestigate state
/** Copyright © 2011
/***********************************************************************/

class CInvestigationItem extends CGameplayEntity
{
	editable var	scene		: CStoryScene;
	editable var	input		: name;
	editable var 	duration 	: float;
	default duration			= 6.0;
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			thePlayer.InvestigateObject( this );
		}
	}
	
	final latent function PlayScene()
	{
		// holster the held weapon
		thePlayer.HolsterWeaponLatent( thePlayer.GetCurrentWeapon(CH_Right) );
		thePlayer.HolsterWeaponLatent( thePlayer.GetCurrentWeapon(CH_Left) );
		thePlayer.ActivateAndSyncBehavior( 'PlayerExploration' );
		Sleep( 0.5 );
		thePlayer.ActionMoveToNode( this, MT_Walk, 0, 1 );
		
		thePlayer.AttachBehavior( 'quest_custom' );
		thePlayer.RaiseEvent( 'loot_floor' );
		
		theGame.GetStorySceneSystem().PlayScene( scene, input );
		
		Sleep( duration + 1 );
	}
};