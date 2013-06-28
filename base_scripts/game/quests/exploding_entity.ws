/////////////////////////////////////////////////////////////////////////////////////////
// Class for object exploding when hit by igni
/////////////////////////////////////////////////////////////////////////////////////////

class CExplodingEntity extends CGameplayEntity
{
	editable var damageDealt : float;
	var playerInRange : bool;
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if( activator == thePlayer && interactionName == 'explosion_range' )
		{
			playerInRange = true;
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if(activator == thePlayer && interactionName == 'explosion_range' )
		{
			playerInRange = false;
		}
	}
	
	function HandleIgniHit( igni : CWitcherSignIgni )
	{
		PlayEffect( 'nest_explosion_fx' );
		ApplyAppearance( "2_destroyed" );
		Explosion();
	}
	
	function Explosion()
	{
		if( playerInRange )
		{
			thePlayer.HitPosition( GetWorldPosition(), 'Attack', damageDealt, true );
			thePlayer.PlayEffect( 'fireball_hit_fx' );
			thePlayer.ApplyCriticalEffect( CET_Burn, NULL );
		}
	}
}