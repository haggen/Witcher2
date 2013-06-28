///////////////////////////////////////////////////////////////////////////////////////////////////
//	MT: classes for sq303
///////////////////////////////////////////////////////////////////////////////////////////////////

class CGargoyleChest extends CContainer
{
	editable var runesTag : name;
	editable var chestId : string;
	editable inlined var combinations : array<CGargoyleChestCombination>;
	editable var punishPlayer : bool;
	
	saved var active : bool;
	saved var combinationChosen : bool;
	saved var correctCombination : array<name>;
	saved var deactivatedRunes : array<name>;
	saved var runes : array<CNode>;
	
	default active = true;
	default combinationChosen = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		if( active )
		{
			Init();
		}
	}
}

///////////////////////////////////////////////////////////////////////////

class CGargoyleChestCombination
{
	editable var combination : array<name>;
}

///////////////////////////////////////////////////////////////////////////


state Active in CGargoyleChest
{
	entry function Init()
	{
		var index : int;
	
		parent.PlayEffect('magic_obstacle_fx');
		
		Sleep( 0.1f );
		parent.runes.Clear();
		theGame.GetNodesByTag( parent.runesTag, parent.runes );
		
		// chosing random combination
		if( !parent.combinationChosen )
		{
			parent.deactivatedRunes.Clear();
			
			index = Rand( parent.combinations.Size() );
			parent.correctCombination = parent.combinations[index].combination;
			parent.active = true;
			parent.combinationChosen = true;
			
			FactsAdd( parent.chestId + "_combination" + index + "_chosen", 1);
		}
		
		CheckCombination();
	}
	
	entry function Reset()
	{
		var x : int;
		
		for( x=0; x<=parent.runes.Size(); x+=1)
		{
			((CGargoyleRune)parent.runes[x]).Reset();
		}
		
		parent.deactivatedRunes.Clear();
		FactsAdd( parent.chestId + "_wrong_combination", 1,2);
		
		if( parent.punishPlayer )
		{
			PunishPlayer();
		}
	}
	
	latent function PunishPlayer()
	{
		var punishmentNum : int;
		
		punishmentNum = Rand( 4 );
			
		if( punishmentNum == 0 )
		{
			thePlayer.HitPosition( parent.GetWorldPosition(), 'Attack', 100.f, true );
			thePlayer.PlayEffect( 'fireball_hit_fx' );
			thePlayer.ApplyCriticalEffect( CET_Burn, NULL ); 
		}
		else if( punishmentNum == 1 )
		{
			thePlayer.HitPosition( parent.GetWorldPosition(), 'Attack', 100.f, true );
			thePlayer.PlayEffect( 'Axii_fail' );
			thePlayer.ApplyCriticalEffect( CET_Poison, NULL ); 
		}
		else if( punishmentNum == 2 )
		{
			thePlayer.HitPosition( parent.GetWorldPosition(), 'Attack', 100.f, true );
			thePlayer.PlayEffect( 'lightning_hit_fx' );
			thePlayer.ApplyCriticalEffect( CET_Blind, NULL ); 
		}
		else if( punishmentNum == 3 )
		{
			thePlayer.HitPosition( parent.GetWorldPosition(), 'Attack', 100.f, true );
			thePlayer.PlayEffect( 'lightning_hit_fx' );
			thePlayer.ApplyCriticalEffect( CET_Bleed, NULL ); 
		}
	}
	
	entry function CheckCounter()
	{
		if( parent.deactivatedRunes.Size() == parent.correctCombination.Size() )
		{
			CheckCombination();
		}
	}
	
	latent function CheckCombination()
	{
		var correctCount, i : int;
	
		for( i=0; i<parent.deactivatedRunes.Size(); i+=1)
		{
			if( parent.deactivatedRunes[i] != parent.correctCombination[i] )
			{
				Sleep(3.0f);
				parent.Reset();
				break;
			}
			
			correctCount +=1;
			
			if( correctCount == parent.correctCombination.Size() )
			{
				parent.Deactivate();
			}
		}
	}
}

state Deactivated in CGargoyleChest
{
	entry function Deactivate()
	{
		parent.active = false;
		parent.StopEffect('magic_obstacle_fx');
		FactsAdd( parent.chestId + "_disabled", 1 );
		parent.GetComponent("Loot").SetEnabled( true );
	}
}

///////////////////////////////////////////////////////////////////////////

class CGargoyleRune extends CGameplayEntity
{
	editable var gargoyleChestTag, runeId, effectName : name;
	editable var isOnWall : bool;
	saved var gargoyleChest : CGargoyleChest;
	saved var isActive : bool;
	
	default isActive = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( isActive )
		{
			Init();
		}
	}
}

///////////////////////////////////////////////////////////////////////////

state Active in CGargoyleRune
{
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Exploration' && activator.IsA( 'CPlayer' ) )
		{
			parent.Deactivate();
		}
	}

	entry function Init()
	{
		Sleep( 0.1f );
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		
		parent.PlayEffect( parent.effectName );
	}

	entry function Reset()
	{
		parent.PlayEffect( parent.effectName );
		
		parent.isActive = true;
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		parent.GetComponent( "extinguish" ).SetEnabled( true );
	}
}

state Deactivated in CGargoyleRune
{
	entry function Deactivate()
	{
		parent.isActive = false;
		parent.gargoyleChest.deactivatedRunes.PushBack( parent.runeId );
		parent.GetComponent( "extinguish" ).SetEnabled( false );
		
		thePlayer.RotateTo(parent.GetWorldPosition(), 0.2);
		//thePlayer.AttachBehavior('exploration');
		
		if( thePlayer.GetCurrentPlayerState() != PS_Exploration ) 
		{
			thePlayer.ChangePlayerState( PS_Exploration );
			Sleep( 2.f );
		}
		
		if( parent.isOnWall )
		{
			thePlayer.RaiseForceEvent('torch_extinguish');
			thePlayer.PlayEffect('aard_sneak');
			thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
			Sleep( 0.5f );
			parent.PlayEffect('sneak_aard');
			parent.StopEffect( 'fire' );
		}
		else
		{
			thePlayer.RaiseForceEvent('fire_floor_extinguish');
			thePlayer.WaitForBehaviorNodeDeactivation ('fire_floor_extinguish_finished', 20.f);

		}

		parent.StopEffect( parent.effectName );
		parent.gargoyleChest.CheckCounter();
	}
}

////////////////////////////////////////////////////////////////////

class CGargoyleCandle extends CGargoyleRune
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( isActive )
		{
			Init();
		}
		else
		{
			PlayEffect( 'fire' );
		}
	}
}

state Active in CGargoyleCandle
{
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Exploration' && activator.IsA( 'CPlayer' ) )
		{
			parent.Deactivate();
		}
	}

	entry function Init()
	{
		Sleep( 0.1f );
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		
		parent.StopEffect( parent.effectName );
	}

	entry function Reset()
	{
		parent.StopEffect( parent.effectName );
		
		parent.isActive = true;
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		parent.GetComponent( "extinguish" ).SetEnabled( true );
	}
}

state Deactivated in CGargoyleCandle
{
	entry function Deactivate()
	{
		parent.isActive = true;
		parent.gargoyleChest.deactivatedRunes.PushBack( parent.runeId );
		parent.GetComponent( "extinguish" ).SetEnabled( false );
		
		thePlayer.RotateTo(parent.GetWorldPosition(), 0.2);
		//thePlayer.AttachBehavior('exploration');
		
		if( thePlayer.GetCurrentPlayerState() != PS_Exploration ) 
		{
			thePlayer.ChangePlayerState( PS_Exploration );
			Sleep( 2.f );
		}
		
		if( parent.isOnWall )
		{
			thePlayer.RaiseForceEvent('torch_extinguish');
			thePlayer.PlayEffect('igni_sneak');
			thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
			Sleep( 0.5f );
			parent.PlayEffect('sneak_igni');
			parent.PlayEffect( 'fire' );
		}
		else
		{
			thePlayer.RaiseForceEvent('fire_floor_lightup');
			thePlayer.WaitForBehaviorNodeDeactivation ('fire_floor_lightup_finished', 20.f);
		}

		parent.PlayEffect( parent.effectName );

		parent.gargoyleChest.CheckCounter();
	}
}

/////////////////////////////////////////////////////////////////////////

class CGargoyleCandleSQ208 extends CGargoyleRune
{
	
}

state Active in CGargoyleCandleSQ208
{
	event OnInteraction( actionName : name, activator : CEntity )
	{
		if( actionName == 'Exploration' && activator.IsA( 'CPlayer' ) )
		{
			parent.Deactivate();
		}
	}

	entry function Init()
	{
		Sleep( 0.1f );
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		
		parent.StopEffect( parent.effectName );
	}

	entry function Reset()
	{
		var Tag1 : poster;
		var Tag2 : poster;
		var Tag3 : poster;
		
		parent.StopEffect( parent.effectName );
		
		parent.isActive = true;
		parent.gargoyleChest = (CGargoyleChest) theGame.GetNodeByTag( parent.gargoyleChestTag );
		parent.GetComponent( "extinguish" ).SetEnabled( true );
		

		Tag1 = (poster)theGame.GetEntityByTag( 'totem_raz' );
		Tag2 = (poster)theGame.GetEntityByTag( 'totem_dwa' );
		Tag3 = (poster)theGame.GetEntityByTag( 'totem_trzy' );
		Tag1.ClosePoster();
		Tag2.ClosePoster();
		Tag3.ClosePoster();
/*	
		Tag1.GetComponent( "poster_on_interaction" ).SetEnabled( false );
		Tag2.GetComponent( "poster_on_interaction" ).SetEnabled( false );
		Tag3.GetComponent( "poster_on_interaction" ).SetEnabled( false );
*/		
	}
}

state Deactivated in CGargoyleCandleSQ208
{
	entry function Deactivate()
	{
		parent.isActive = false;
		parent.gargoyleChest.deactivatedRunes.PushBack( parent.runeId );
		parent.GetComponent( "extinguish" ).SetEnabled( false );
	//	parent.GetComponent( "sq208_lookat_totem" ).SetEnabled( false );
		
		thePlayer.RotateTo(parent.GetWorldPosition(), 0.2);
		//thePlayer.AttachBehavior('exploration');
		
		if( thePlayer.GetCurrentPlayerState() != PS_Exploration ) 
		{
			thePlayer.ChangePlayerState( PS_Exploration );
			Sleep( 2.f );
		}
		
		if( parent.isOnWall )
		{
			thePlayer.RaiseForceEvent('torch_extinguish');
			thePlayer.PlayEffect('igni_sneak');
			thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
			Sleep( 0.5f );
			parent.PlayEffect('sneak_igni');
			parent.PlayEffect( 'fire' );
		}
		else
		{
			thePlayer.RaiseForceEvent('fire_floor_lightup');
			thePlayer.WaitForBehaviorNodeDeactivation ('fire_floor_lightup_finished', 20.f);
		}

		parent.PlayEffect( parent.effectName );

		parent.gargoyleChest.CheckCounter();
	}
}