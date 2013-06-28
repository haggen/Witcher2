////////////////////////////////////////////////////////////////////////
// CLASSES FOR SQ203
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// ROTFIEND NEST

class CRotfiendNest extends CInteractiveEntity
{
	editable var effectName : name;
	editable var destroyedApperanceName, destructionFact : string;
	saved var destroyed : bool;
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		super.OnInteractionActivated( interactionName, activator );
	
		if( interactionName == 'triggerActivator' && FactsDoesExist("Knowledge_1_2") && !destroyed )
		{
			GetComponent( "burn" ).SetEnabled( true );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'AttackFast' && activator.IsA( 'CPlayer' ) )
		{
			Burn();
		}
		
		super.OnInteraction( actionName, activator );
	}
}

state Burned in CRotfiendNest
{	
	entry function Burn()
	{
		var saveLockNum : int;
		
		thePlayer.EnableMeditation( false );
		parent.LockEntryFunction( true );
		saveLockNum = -1;
		theGame.CreateNoSaveLock( "sq203_rotfiend_nests", saveLockNum );
		
		thePlayer.SetManualControl(false, true);
		thePlayer.ResetPlayerMovement();
		
		if(thePlayer.GetCurrentPlayerState() == PS_Exploration)
		{
			thePlayer.RaiseForceEvent('Idle');
		}
		else
		{
			thePlayer.RaiseForceEvent('GlobalEnd');
		}
					
		if( thePlayer.GetCurrentPlayerState() != PS_Exploration ) 
		{
			thePlayer.ChangePlayerState( PS_Exploration );
			thePlayer.SetAllPlayerStatesBlocked( true );
			Sleep( 2.f );
		}
		
		parent.destroyed = true;
		parent.GetComponent( "burn" ).SetEnabled( false );
		
		thePlayer.RotateTo(parent.GetWorldPosition(), 0.2f);
		
		thePlayer.RaiseForceEvent('fire_floor_lightup');
		
		thePlayer.PlayEffect('igni_sneak');
		thePlayer.WaitForBehaviorNodeDeactivation ('fire_floor_lightup_finished', 20.f);
		parent.SetAutoEffect( 'burning_fx' );
		
		FactsAdd( parent.destructionFact, 1 );
		FactsAdd( thePlayer.GetQuestTrackId( 3 ) + "_progress", 1 , -1 );
		theHud.m_hud.SetTrackQuestProgress( 3 );
		
		theGame.ReleaseNoSaveLock( saveLockNum );
		thePlayer.SetManualControl(true, true);
		thePlayer.ResetPlayerMovement();
		thePlayer.SetAllPlayerStatesBlocked( false );
		thePlayer.UnblockAllPlayerStates();
		thePlayer.EnableMeditation( true );
		
		saveLockNum = -1;
		parent.LockEntryFunction( false );
	}
}

////////////////////////////////////////////////////////////////////////
// MINES NEST

class CMinesNest extends CGameplayEntity
{
	editable var destructionFact : string;
	saved var playerNear : bool;
	saved var destroyed : bool;
	
	default playerNear = false;
	default destroyed = false;
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Use' && activator.IsA( 'CPlayer' ) && thePlayer.GetInventory().HasItem('Grapeshot') )
		{
			GetComponent( "destroyNest" ).SetEnabled( false );
			blowUp();
		}
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if(activator == thePlayer && interactionName == 'explosion_range' )
		{
			if( !destroyed )
			{
				GetComponent( "destroy_nest_interaction" ).SetEnabled( true );
				playerNear = true;
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

state Destroyed in CMinesNest
{
	entry function blowUp()
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
		thePlayer.RotateToNode( parent, 0.1f );
		thePlayer.CannotDeployTrap(3.0);
		thePlayer.PlayerCombatAction(PCA_DeployTrap);
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Grapeshot'), 1);
		thePlayer.SetAllPlayerStatesBlocked( false );
		thePlayer.SetManualControl( true, true );
		
		parent.PlayEffect('bomb_smoke');
		
		Sleep( 5.f );
		
		parent.PlayEffect('nest_explosion_fx');
		parent.StopEffect('bomb_smoke');
		FactsAdd( parent.destructionFact, 1 );
		parent.checkExplosion();
	}
}
