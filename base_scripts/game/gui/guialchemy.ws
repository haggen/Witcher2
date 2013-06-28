/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Alchemy
/** Copyright © 2010
/***********************************************************************/

class CGuiAlchemyStandalone extends CGuiPanel
{
	private var AS_alchemy : int;
	
	private var m_mapItemIdxToId       : array< SItemUniqueId >;
	
	// Recipes
	private var m_mapRecipeArrayIdxToItemIdx : array< int >;
	
	// Ingredients
	private var m_mapIngredientArrayIdxToItemIdx : array< int >;

	// Hide hud
	function GetPanelPath() : string { return "ui_alchemy.swf"; }
	
	function IsNestedPanel() : bool
	{
		return true;
	}
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	}
	
	event OnClosePanel()
	{
		theHud.ForgetObject( AS_alchemy );
		
		theSound.RestoreAllSounds();

		super.OnClosePanel();
		
		theHud.HideAlchemyNew();
		
		theGame.SetActivePause(false);
	}
	
	private function FillAlchemy()
	{
		var AS_recipes		  : int;
		var AS_ingredients	  : int;
		var AS_recipesEffects : int;
		
		var inventory		: CInventoryComponent		= thePlayer.GetInventory();
		var stats			: CCharacterStats			= thePlayer.GetCharacterStats();
		var slotItems		: array< SItemUniqueId >	= thePlayer.GetItemsInQuickSlots();
		var itemId			: SItemUniqueId;
		var itemTags		: array< name >;
		var itemIdx			: int;
		var numItems		: int;
		var i				: int;
		var AS_item			: int;
		var craftedItemName : name;
		var craftedItemId	: SItemUniqueId;
		
		if ( !theHud.GetObject( "Recipes", AS_recipes, AS_alchemy ) )
		{
			LogChannel( 'GUI', "GUI Alchemy: cannot find Recipes object at scaleform side." );
		}
		if ( !theHud.GetObject( "Ingredients", AS_ingredients, AS_alchemy ) )
		{
			LogChannel( 'GUI', "GUI Alchemy: cannot find Ingredients object at scaleform side." );
		}
		if ( !theHud.GetObject( "RecipesEffects", AS_recipesEffects, AS_alchemy ) )
		{
			LogChannel( 'GUI', "GUI Alchemy: cannot find RecipesEffects object at scaleform side." );
		}
		
		theHud.ClearElements( AS_recipes );
		theHud.ClearElements( AS_recipesEffects );
		
		m_mapRecipeArrayIdxToItemIdx.Clear();
		
		theHud.ClearElements( AS_ingredients );
		m_mapIngredientArrayIdxToItemIdx.Clear();

		m_mapItemIdxToId.Clear();
		
		// Get items in player's inventory
		inventory.GetAllItems( m_mapItemIdxToId );
		numItems = m_mapItemIdxToId.Size();
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapItemIdxToId[i];
			
			// add to list items that have proper tags
			inventory.GetItemTags( itemId, itemTags );
			
			// Get recipes
			if ( itemTags.Contains( 'Recipe' ) )
			{
				// Fill recipe
				
				m_mapRecipeArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems, 'alchemy' );
				
				theHud.PushObject( AS_recipes, AS_item );
				theHud.ForgetObject( AS_item );
				
				// Fill item created from recipe
				craftedItemName = inventory.GetCraftedItemName( itemId );
				theHud.m_utils.FillFlashItemDescription( craftedItemName, inventory, stats, AS_recipesEffects, i, slotItems );
			}
			
			// Get ingredients
			if (	/* ! itemTags.Contains( 'nodrop' ) && */
					  itemTags.Contains( 'AlchemyIngridient' ) )
			{
				m_mapIngredientArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( inventory, stats, itemId, i, AS_item, slotItems, 'alchemy' );
				
				theHud.PushObject( AS_ingredients, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}
		
		theHud.ForgetObject( AS_recipes );
		theHud.ForgetObject( AS_ingredients );
		theHud.ForgetObject( AS_recipesEffects );
		
		theHud.Invoke( "Commit", AS_alchemy );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mAlchemy", AS_alchemy ) )
		{
			LogChannel( 'GUI', "No mAlchemy found at the Scaleform side!" );
		}
		FillAlchemy();
		theGame.SetActivePause(true);
	}
	
	function AddRandomMutagen()
	{
		var mutName : string;
		var mutChance : float = thePlayer.GetCharacterStats().GetAttribute('mutagen_chance');
		var randGlob, randKat, rand : int;
		
		randGlob = RoundF( RandRangeF( 1, 100 ) );
		randKat = RoundF( RandRangeF( 1, 100 ) );
		
		if ( randGlob < mutChance )
		{
			if ( ( randKat > 50 ) && ( randKat < 90 ) )
			{
				randKat = RoundF( RandRangeF( 1, 6 ) );
				switch( randKat )
				{
					case 1:AddItem('Mutagen of Amplification');
					case 2:AddItem('Mutagen of Range');
					case 3:AddItem('Mutagen of Critical Effect');
					case 4:AddItem('Mutagen of Vitality');
					case 5:AddItem('Mutagen of Power');
					case 6:AddItem('Mutagen of Strength');
				}
			} else
			if ( randKat >= 90 )
			{
				randKat = RoundF( RandRangeF( 1, 5 ) );
				switch( randKat )
				{
					case 1:AddItem('Major Mutagen of Amplification');
					case 2:AddItem('Major Mutagen of Critical Effect');
					case 3:AddItem('Major Mutagen of Vitality');
					case 4:AddItem('Major Mutagen of Power');
					case 5:AddItem('Major Mutagen of Strength');
				}
			}
			
			randKat = RoundF( RandRangeF( 1, 6 ) );
			switch( randKat )
			{
				case 1:AddItem('Minor Mutagen of Amplification');
				case 2:AddItem('Minor Mutagen of Range');
				case 3:AddItem('Minor Mutagen of Critical Effect');
				case 4:AddItem('Minor Mutagen of Vitality');
				case 5:AddItem('Minor Mutagen of Power');
				case 6:AddItem('Minor Mutagen of Strength');
			}
		}
		
	}
	
	private final function CreateElixir( itemsIdsStr : string) : bool
	{
		var ids : array< int >;
		var i : int;
		var itemId	: SItemUniqueId;
		var ingredientsNames : array< name >;
		var ingredientsQuantities : array< int >;
		var ingredientName : name;
		var idx : int;
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var craftedPotionName : name;
		var amount:int;
		
		ids = theHud.m_utils.SplitStringForItemsIds( itemsIdsStr );
		LogChannel( 'GUI', "Parametr: " + itemsIdsStr );
		
		//amount of requested copies is stored in first value
		amount = ids[0];
		
		// prepare ingredients list and remove ingredient items from inventory
		for ( i = 1; i < ids.Size(); i += 1 )
		{
			itemId = m_mapItemIdxToId[ ids[i] ];
			
			ingredientName = theHud.m_utils.GetItemIngredientName( itemId );
			if ( ingredientName == '' )
			{
				LogChannel( 'GUI', "Alchemy: CreateElixir() - item doesn't have ingredient" );
			}
			else
			{
				idx = ingredientsNames.FindFirst( ingredientName );
				if ( idx == -1 )
				{
					ingredientsNames.PushBack( ingredientName );
					ingredientsQuantities.PushBack( 1 );
				}
				else
				{
					ingredientsQuantities[idx] += amount;
				}

				inv.RemoveItem( itemId, amount );
			}
		}
		
		// try to create a potion
		craftedPotionName = theHud.m_utils.GetCraftedItemNameForIngredients( ingredientsNames, ingredientsQuantities );
		if ( craftedPotionName != '' )
		{
			theSound.PlaySound( "gui/alchemy/newpotion" );
		
			inv.AddItem( craftedPotionName, amount, false );
			AddRandomMutagen();
			
			FillAlchemy(); // update data to gui

			if ( craftedPotionName == 'Shadow' )
			{
				theGame.UnlockAchievement('ACH_OSTMURK');
			}

			if( !theGame.tutorialenabled )
			{
				//thePlayer.AddTimer( 'CheckforTutorials', 5.0f, true );
			}	
			AddAchievementCounter('ACH_ALCHEMY_JOURNEYMAN', 1, 5);
			return true;
		}
		else
		{
			return false;
		}
	}
}
