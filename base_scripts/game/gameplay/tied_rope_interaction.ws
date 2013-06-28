class W2TiedRope extends CGameplayEntity
{
	event OnInteraction( actionName : name, activator : CEntity )
	{
		var rope : CDrawableComponent;
		var ropes : array< CComponent >;
		var i : int;
		
		ropes = GetComponentsByClassName( 'CMeshComponent' );
	
		if ( activator != thePlayer || thePlayer.IsNotGeralt() )
			return false;

		if ( actionName != 'Use' )
			return false;		

		theSound.PlaySound( "l04_city/sq307/sq307_bag_drop01" ); 

		for( i=0; i< ropes.Size(); i+=1 )
		{
			rope = (CDrawableComponent)ropes[i];
			rope.SetVisible( false );
		}

		PlayEffect('rope_fx');
		GetComponent( "rope" ).SetEnabled( false );

		FactsAdd( "a3_forest_rope_untied", 1, -1 );
	}
}

quest function GSpecialDropBag()
{
	var drop_bag	 		: CEntity;
	
	drop_bag = theGame.GetEntityByTag( 'forest_drop_bag' );
	drop_bag.RaiseForceEvent( 'start' );
}