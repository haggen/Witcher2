//////////////////////////////////////////////
// class for nekker nests

class CNekkerNest extends CGameplayEntity
{
	saved var playerNear : bool;
	saved var destroyed : bool;
	
	default playerNear = false;
	default destroyed = false;

	editable var nestNumber : int;

	event OnSpawned(spawnData : SEntitySpawnData )
	{

	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Exploration' && activator == thePlayer && thePlayer.GetInventory().HasItem('Grapeshot') )
		{
			GetComponent( "destroy_nest_interaction" ).SetEnabled( false );

			destroy();
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if(activator == thePlayer && interactionName == 'explosion_range' )
		{
			if( !destroyed && FactsDoesExist("Knowledge_5_2") )
			{
				GetComponent( "destroy_nest_interaction" ).SetEnabled( true );
				playerNear = true;
			}
			else
			{
				GetComponent( "destroy_nest_interaction" ).SetEnabled( false );
			}
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if(activator == thePlayer && interactionName == 'explosion_range' )
		{
			playerNear = false;
		}
	}
	
	function checkExplosion()
	{
		if( playerNear )
		{
			thePlayer.HitPosition( GetWorldPosition(), 'Attack', 20.f, true );
			thePlayer.PlayEffect( 'fireball_hit_fx' );
			thePlayer.ApplyCriticalEffect( CET_Burn, NULL );
		}
	}
}

state destroyed in CNekkerNest
{
	entry function destroy()
	{
		thePlayer.SetManualControl( false, true );
		
		if( thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_CombatSilver ) 
		{
			thePlayer.ChangePlayerState( PS_CombatSteel );
			thePlayer.SetManualControl(false, true);
			thePlayer.SetAllPlayerStatesBlocked( true );
			
			Sleep( 1.5f );
		}
		
		thePlayer.SetAllPlayerStatesBlocked( true );
		thePlayer.RotateToNode( parent, 0.2f );
		thePlayer.CannotDeployTrap(3.0);
		thePlayer.PlayerCombatAction(PCA_DeployTrap);
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Grapeshot'), 1);
		thePlayer.SetAllPlayerStatesBlocked( false );
		thePlayer.SetManualControl( true, true );
		
		Sleep( 1.f );
		
		parent.PlayEffect('smoke');
		
		Sleep( 5.f );
		
		parent.StopEffect('smoke');
		parent.PlayEffect('explosion_fx');
		parent.ApplyAppearance("destroyed");
		
		parent.destroyed = true;
		
		FactsAdd( "nekker_nest_" + parent.nestNumber + "_destroyed", 1 );
		
		parent.checkExplosion();
	}
}