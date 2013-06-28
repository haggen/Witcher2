/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Scripted quest conditions
/** Copyright © 2009
/***********************************************************************/

// a condition embedded in a CQuestActorCondition
import class CQCActorScriptedCondition extends IActorConditionType
{
	abstract function Evaluate( actor : CActor ) : bool;
};

/////////////////////////////////////////////////////////////////////////

// a basic quest condition
import class CQuestScriptedCondition extends IQuestCondition
{
	abstract function Activate();
	abstract function Deactivate();
	abstract function Evaluate() : bool;
};

/////////////////////////////////////////////////////////////////////////

// this condition checks if entity with specified tag exists
class CQuestTagExistsCondition extends CQuestScriptedCondition
{
	editable var tag		: name;
	editable var mustExist	: bool;
	var nodes : array< CNode >;
	
	function Evaluate() : bool
	{
		theGame.GetNodesByTag( tag, nodes );
		
		if( mustExist )
		{
			return nodes.Size() > 0;
		}
		else
		{
			return nodes.Size() == 0;
		}
	}
};

// Funkcja czekaj¹ca na odpowiedni poziom zycia npc w procentach 
latent quest function QCheckHealthLevel( npcTag : name, healthLevel : float) : bool
{
	var actor : CActor;
	
	if( npcTag != 'PLAYER' )
	{
		actor  = theGame.GetNPCByTag( npcTag );
	}
	else
	{
		actor = thePlayer;
	}
	
	
	while( CompareHealthLevel( actor, healthLevel, false ) == false )
	{
		Sleep( 0.1f );
	}
	return true;
}

latent quest function QCheckIfHealthLevelIsMoreThen( npcTag : name, healthLevel : float) : bool
{
	var actor : CActor;
	
	if( npcTag != 'PLAYER' )
	{
		actor  = theGame.GetNPCByTag( npcTag );
	}
	else
	{
		actor = thePlayer;
	}
	
	
	while( CompareHealthLevel( actor, healthLevel, true ) == false )
	{
		Sleep( 0.1f );
	}
	return true;
}

class CQCCheckHealthLevel extends CQCActorScriptedCondition
{
	editable var healthLevel : float;
	editable var isGreater : bool;
	
	default healthLevel = 1.0;
	default isGreater = false;
	
	
	function Evaluate( actor : CActor ) : bool
	{
		return CompareHealthLevel( actor, healthLevel, isGreater );
	}
};

function CompareHealthLevel( actor : CActor, healthLevel : float, greater : bool ) : bool
{
    var maxHealth, currentHealth, percentHealth : float;
     
	maxHealth = actor.initialHealth;
	currentHealth = actor.health;
	percentHealth = ( currentHealth / maxHealth ) * 100;
	
	if ( greater )
	{
		return percentHealth > healthLevel;
	}
	else
	{
		return percentHealth < healthLevel;
	}
}




class CQCCheckIfCombatModeOff extends CQCActorScriptedCondition
{
	
	function Evaluate( actor : CActor ) : bool
	{
		var result : bool;
		
		if ( actor.IsInCombat() == false )
		{
			return true;
		}
		
	}
};

class CQCCheckIfCombatModeActive extends CQCActorScriptedCondition
{
	
	function Evaluate( actor : CActor ) : bool
	{
		var result : bool;
		
		result = actor.IsInCombat();
		return result;
	}
};

class CQCWaitForElixirsPanelClose extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		return !theHud.IsPanelLoaded( "ui_elixirs.swf" );
	}
};

class CQCWaitForMeditationPanelClose extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		return !theHud.IsPanelLoaded( "ui_meditation.swf" );
	}
};

class CQWaitForMeditation extends CQCActorScriptedCondition
{
	var currentState : EPlayerState;
		

	function Evaluate( actor : CActor ) : bool
	{
		currentState = thePlayer.GetCurrentPlayerState();
		
		Log("currentState is " + currentState);
		
		return (currentState == PS_Meditation);
	}
};

class CQWaitForPlayerExplorationEnd extends CQCActorScriptedCondition
{
	var playerStateName : name;
	function Evaluate( actor : CActor ) : bool
	{
		playerStateName = thePlayer.GetCurrentStateName();
		return ( playerStateName != 'TraverseExploration' );
	}
}

//SL na potrzeby q213
class CQCHasntGotCandlmkrPotion extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		return ((FactsQuerySum('q213r_12_sabrinas_info_aquired') == 2) && ( thePlayer.GetInventory().GetItemQuantityByName('Candlemakers Potion Real') == 0 ) );	
	}
};

//SL na potrzeby q213
class CQCHasSilverSword extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		return ( thePlayer.GetInventory().GetItemByCategory('silversword', false) != GetInvalidUniqueId() );
	}
};

// Condition that checks if there's a critical effect applied to the specified actor
class CQCCriticalEffect extends CQCActorScriptedCondition
{
	editable var		m_effect : ECriticalEffectType;
	
	function Evaluate( actor : CActor ) : bool
	{
		return actor.IsCriticalEffectApplied( m_effect );
	}
};

// Condition that checks if actor is targeted
class CQCIsTargeted extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		var currEnemy : CActor;
		currEnemy = thePlayer.GetEnemy();
		
		return currEnemy == actor;
	}
};

// Condition that checks if actor is target locked
class CQCIsTargetLocked extends CQCActorScriptedCondition
{
	function Evaluate( actor : CActor ) : bool
	{
		var currEnemy : CActor;
		var value : float;
		currEnemy = thePlayer.GetLockedTarget();
		
		if(  currEnemy == actor )
		{
			return true;
		}
		else
			return false;
	}
};

// Condition that checks if player have spent specified number o undistributed talent points
class CQCTalentPointSpent extends CQCActorScriptedCondition
{
	editable var TalentPointSpent : int;
	
	function Evaluate( actor : CActor ) : bool
	{
		var points_left, points_dist : int;
		
		points_left = thePlayer.GetTalentPoints();
		points_dist = (thePlayer.GetLevel() - 1) - points_left;
	
		if(  points_dist == TalentPointSpent )
		{
			return true;
		}
		else
			return false;
	}
};

// Condition that checks if player has an ablility
class CQCIsPlayerAbilityDeveloped extends CQCActorScriptedCondition
{
	editable var abilityName : name;
	
	function Evaluate( actor : CActor ) : bool
	{
		if( thePlayer.GetCharacterStats().HasAbility( abilityName ) )
			return true;
		else
			return false;
	}
};

// Condition that checks if player has given ability mutated with a given mutagen in a given slot index (0, 1, 2)
class CQCIsMutagenAppliedToAbilityInSlot extends CQCActorScriptedCondition
{
	editable var abilityName : name;
	editable var mutagenName : name;
	editable var mutagenSlot : int;
	
	default mutagenSlot = 0;
	
	function Evaluate( actor : CActor ) : bool
	{
		var mutagen : name; 

		mutagen = thePlayer.GetCharacterStats().GetAbilityEnhancementItemName( abilityName, mutagenSlot );
				
		if( mutagenName == mutagen )
			return true;
		else
			return false;
	}
};

// Condition that checks if player has equipped specified item
class CQCIsSpecifiedItemEquipped extends CQCActorScriptedCondition
{
	editable var itemName : name;
	
	function Evaluate( actor : CActor ) : bool
	{
		var res : bool;

		res = thePlayer.GetInventory().IsItemMounted( thePlayer.GetInventory().GetItemId( itemName ) );

		if( res )
			return true;
		else
			return false;
	}
};

// Condition that checks if player has sufficient item quantity

enum EItemQuantity
{
	IQ_Equals,
	IC_LessThan,
	IC_MoreThan
}

class CQCIsItemQuantityMet extends CQCActorScriptedCondition
{
	editable var itemName	 : name;
	editable var inequality : EItemQuantity;
	editable var count 		: int;
	
	function Evaluate( actor : CActor ) : bool
	{
		var res : bool;
		var item_quant : int;

		item_quant = thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId( itemName ) );
		
		switch( inequality )
		{
			case IQ_Equals:
			{
				if( item_quant == count )
					res = true;
				else 
					res = false;
				break;
			}
			case IC_LessThan:
			{
				if( item_quant < count )
					res = true;
				else 
					res = false;
				break;
			}
			case IC_MoreThan:
			{
				if( item_quant > count )
					res = true;
				else 
					res = false;
				break;
			}
		}
		return res;
	}
};

// Condition that checks if number of riposte was made
class CQuestTutorialRipostesInRow extends CQuestScriptedCondition
{
	editable var RiposteInRow : int;
	
	function Evaluate() : bool
	{
		if( thePlayer.GetRiposteInRow() >= RiposteInRow )
		{
			return true;
		}
		else
			return false;
	}
};

// Condition that checks if player has blocked an attack
class CQuestPlayerBlockedHit extends CQuestScriptedCondition
{
	function Activate() 
	{
		thePlayer.TutorialResetPlayerBlocked();
	}
	
	function Evaluate() : bool
	{
		return thePlayer.tutHasBlocked;
	}
};

/////////////////////////////////////////////////////////////////////////

// Condition that checks which option in the radial menu was selected
class CQuestRadialMenuSelection extends CQuestScriptedCondition
{
	editable var selectedItem : EFastMenuSelection;
	var currentSelection : EFastMenuSelection;
	
	function Activate() 
	{
		theHud.m_hud.m_fastMenu.ResetLastSelection();
	}
	
	function Deactivate() 
	{
	}
	
	function Evaluate() : bool
	{
		currentSelection = theHud.m_hud.m_fastMenu.GetLastSelection();
		return selectedItem == currentSelection;
	}
};

/////////////////////////////////////////////////////////////////////////

enum EItemCategory
{
	IC_Trap,
	IC_Lure,
	IC_Petard,
	IC_Knife
}

class CQuestItemCurrentlySelected extends CQuestScriptedCondition
{
	editable var itemCategory : EItemCategory;
	
	var category : name;
	
	function Activate() 
	{
	}
	
	function Deactivate() 
	{
	}
	
	function Evaluate() : bool
	{
		category = thePlayer.GetInventory().GetItemCategory( thePlayer.GetThrownItem() );
		
		switch( itemCategory )
		{
			case IC_Trap:
				if( category == 'trap' )
					return true;
				break;
				
			case IC_Lure:
				if( category == 'lure' )
					return true;
				break;
				
			case IC_Petard:
				if( category == 'petard' )
					return true;
				break;
			
			case IC_Knife:
				if( category == 'rangedweapon' )
					return true;
				break;
		}
		
		return false;
	}
}

/////////////////////////////////////////////////////////////////////////

class CQuestSignCurrentlySelected extends CQuestScriptedCondition
{
	editable var signType : ESignTypes;
	
	function Activate() 
	{
	}
	
	function Deactivate() 
	{
	}
	
	function Evaluate() : bool
	{
		if( thePlayer.GetSelectedSign() == signType )
			return true;
		
		return false;
	}
}

/////////////////////////////////////////////////////////////////////////

// Condition that checks if item is placed in a quickslot
class CQuestItemInQuickslot extends CQuestScriptedCondition
{
	editable var requiredItem : name;
	
	function Activate() 
	{
	}
	
	function Deactivate() 
	{
	}
	
	function Evaluate() : bool
	{
		var slotItems : array< SItemUniqueId > = thePlayer.GetItemsInQuickSlots();
		var i, size : int;
		
		size = slotItems.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( thePlayer.GetInventory().GetItemName( slotItems[i] ) == requiredItem )
			{
				return true;
			}
		}
		
		return false;
	}
};


// Condition that checks if player is in meditation panel (or out of )
class CQCIsPlayerMeditating extends CQuestScriptedCondition
{
	editable var isInMeditationMenu 	: bool;
	
	function Evaluate() : bool
	{
		var res : bool;

		res = theGame.isPlayerMeditating;

		if( isInMeditationMenu )
		{
			if( res )
				return true;
			else
				return false;
		}		
		else
		{
			if( !res )
				return true;
			else
				return false;
		}			
	}
};

// Condition that checks if player is resting (via meditation panel)
class CQCIsPlayerResting extends CQuestScriptedCondition
{
	editable var isInRestingMenu 	: bool;
	
	function Evaluate() : bool
	{
		var res : bool;

		res = theGame.isPlayerResting;

		if( isInRestingMenu )
		{
			if( res )
				return true;
			else
				return false;
		}		
		else
		{
			if( !res )
				return true;
			else
				return false;
		}			
	}
};

/////////////////////////////////////////////////////////////////////////

// Checks for the presence of a blackscreen
class CQCIsBlackscreen extends CQuestScriptedCondition
{
	editable var m_isSceneVisible : bool;
	default m_isSceneVisible = false;
	
	
	function Activate() {}
	function Deactivate() {}
	
	function Evaluate() : bool
	{
		return theGame.IsBlackscreen() == !m_isSceneVisible;
	}
}

/////////////////////////////////////////////////////////////////////////
