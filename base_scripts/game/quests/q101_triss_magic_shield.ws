// Klasa obslugujaca interakcje jak sie wychodzi z banki triss na landingu

class q101_triss_magic_shield extends W2TargetingArea
{
	editable var maxTimeOutside			: float;
	editable var arrowTemplate 			: CEntityTemplate;
	
	default maxTimeOutside				= 3.0;


	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer  )
		{
			RemoveTimer( 'ShotTimer' );	
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			AddTimer( 'ShotTimer', maxTimeOutside, false );
		}
	}
	
	timer function ShotTimer( timeDelta : float )
	{
		var projectile 				: CRegularProjectile;
		var startNode				: CNode;
		var startNodePos			: Vector;
		
		var targetsTags				: array<name>;
		var targetPositionOffset	: Vector;
		
		startNode = theGame.GetNodeByTag( 'q101_arrow_maker3' );
		startNodePos = startNode.GetWorldPosition();
		
		projectile = (CRegularProjectile)theGame.CreateEntity( arrowTemplate, startNodePos, EulerAngles() );
		projectile.PlayEffect('trials');
		projectile.PlayEffect('trail_fx');
		projectile.Start( thePlayer, targetPositionOffset, false, 45.0 );
		thePlayer.Kill();
	}
}
