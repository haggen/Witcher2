//////////////////////////////////////////////////////////
//														//
//		Klasa specjalnych pu³apek na bossów				//
//														//
//////////////////////////////////////////////////////////
class CTrapDummy extends CGameplayEntity
{
	editable var trap_name : CName;
	editable var TrapToSet : CEntityTemplate;
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if ( actionName == 'SetSpecialTrap' )
		{
			//thePlayer.RaiseForceEvent( 'deploy_trap' );
			if(thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_CombatSilver)
			{
				thePlayer.ChangePlayerState(thePlayer.GetLastCombatStyle());
			}
			else
			{
				thePlayer.PlayerCombatAction(PCA_DeployTrap);
				this.AddTimer( 'Deploy', 0.2f, false );
			}
		}
	}
	
	timer function Deploy( time : float )
	{
		DeployTrapOnDummy();
		RemoveDummies();
	}
	
	function DeployTrapOnDummy()
	{
		var trapId : SItemUniqueId;
		var dummy_pos : Vector;
		var dummy_rot : EulerAngles;
		var ent : CEntity;
		
		dummy_pos = this.GetWorldPosition();
		dummy_rot = this.GetWorldRotation();
				
		ent = theGame.CreateEntity( TrapToSet, dummy_pos, dummy_rot);
		trapId = thePlayer.GetInventory().GetItemId( trap_name );
		thePlayer.GetInventory().RemoveItem(trapId, 1);
	}
		
	function RemoveDummies()
	{
		var nodes : array< CNode >;
		var count : int;
		var i : int;
		
		theGame.GetNodesByTag( 'trap_dummy', nodes );
		count = nodes.Size();
		
		for ( i = 0; i < count; i += 1 )		
		{
			if( nodes[i] != this )
				( (CEntity)nodes[i] ).Destroy();
		}
		
		Destroy();
	}	
}

class CSpecialTrap extends CGameplayEntity
{
	var i_triggered : CEntity;
	
	event OnAreaEnter( trap_trigger : CTriggerAreaComponent, activator : CComponent )
	{
		i_triggered = activator.GetEntity();

		if( i_triggered.HasTag( 'tentadrake_bubble' ) )
		{
			CutIt( i_triggered );
		}		
	}
}
	
state Cutting in CSpecialTrap
{
	entry function CutIt( i_triggered : CEntity ) 
	{
		var victim : TentadrakeBubble;
		var zagnica : Zagnica;
		var activator : CActor;
		var macka : ZagnicaMacka;
		
		activator = (CActor)i_triggered;
		
		if ( activator.IsAlive() == true )
		{
			victim = (TentadrakeBubble)i_triggered;
			zagnica = (Zagnica)theGame.GetEntityByTag( 'zagnica' );
			macka = zagnica.GetMacka( victim.parentMacIndex );
			
			if ( macka.isAttacking )
			{
				macka.DoMackaImmobilized();
				
				parent.GetComponent("trap_trigger").SetEnabled( false );
				parent.RaiseForceEvent( 'Spring' );
				
				victim.isCutByTrap = true;
				victim.EnterDead();
				
				parent.WaitForBehaviorNodeDeactivation( 'SpringEnded', 5.0f );
				theGame.UnlockAchievement('ACH_TENTAKILLER');
				Sleep( 1.0f );
				parent.Destroy();
			}	
		}
	}	
}

