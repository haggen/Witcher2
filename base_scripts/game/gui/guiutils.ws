import class CGuiUtils extends CObject
{
	var m_itemBag	: array< SItemUniqueId >;
	
	private var m_percentSign : string;
	default m_percentSign = "%";
	
	import final function GetCraftedItemNameForIngredients( ingredientsNames : array< name >, ingredientsQuantities : array< int > ) : name;
	import final function GetImageSizeFromFileName( fileName : string, out imageWidth : int, out imageHeight : int ) : bool;
	import final function ParseAbilitiesTokens( token : string, sourceString : string ) : string;
	
	public function Initialize()
	{
		// Set percent sign
		if ( theGame.GetCurrentLocale() == "FR" )
		{
			m_percentSign = " %";
		}
		else
		{
			m_percentSign = "%";
		}
	}
	
	public final function AddItemToBag( itemId: SItemUniqueId)
	{
		m_itemBag.PushBack(itemId);
	}
	
	public final function GetTooltipDesc( inventory : CInventoryComponent, itemId : SItemUniqueId ) : string
	{
		var itemName : name = inventory.GetItemName( itemId );
		var output : string = "";
		var count : int;
		var i : int;
		if ( inventory.ItemHasTag( itemId, 'AlchemyIngridient' ) ) { output = output + GetLocStringByKeyExt( "type_alchingr" ) + "/"; count+=1; }                                                                                                                
		if ( inventory.ItemHasTag( itemId, 'Recipe' ) ) { output = output + GetLocStringByKeyExt( "type_alchrec" )+ "/"; count+=1; }                                                                                                                     
		if ( inventory.ItemHasTag( itemId, 'Armor' ) ) { output = output + GetLocStringByKeyExt( "type_armor" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.ItemHasTag( itemId, 'ArmorUpgrade' ) ) { output = output + GetLocStringByKeyExt( "type_armorupgr" )+ "/"; count+=1; }                                                                                                                   
		if ( inventory.ItemHasTag( itemId, 'Petard' ) ) { output = output + GetLocStringByKeyExt( "type_bomb" )+ "/"; count+=1; }                                                                                                                        
		if ( inventory.ItemHasTag( itemId, 'SortTypeBook' ) ) { output = output + GetLocStringByKeyExt( "type_book" )+ "/"; count+=1; }                                                                                                                        
		if ( inventory.GetItemCategory(itemId) == 'boots' ) { output = output + GetLocStringByKeyExt( "type_boots" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.GetItemCategory(itemId) == 'errands' ) { output = output + GetLocStringByKeyExt( "type_contract" )+ "/"; count+=1; }                                                                                                                    
		if ( inventory.ItemHasTag( itemId, 'CraftingIngridient' ) ) { output = output + GetLocStringByKeyExt( "type_craftingr" )+ "/"; count+=1; }                                                                                                                   
		if ( inventory.ItemHasTag( itemId, 'Schematic' ) ) { output = output + GetLocStringByKeyExt( "type_craftrec" )+ "/"; count+=1; }                                                                                                                    
		if ( inventory.GetItemCategory(itemId) == 'gloves' ) { output = output + GetLocStringByKeyExt( "type_gloves" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.GetItemCategory(itemId) == 'key' ) { output = output + GetLocStringByKeyExt( "type_key" )+ "/"; count+=1; }                                                                                                                         
		if ( inventory.ItemHasTag( itemId, 'Mutagen' ) ) { output = output + GetLocStringByKeyExt( "type_mutagen" )+ "/"; count+=1; }                                                                                                                     
		if ( inventory.GetItemCategory(itemId) == 'pants' ) { output = output + GetLocStringByKeyExt( "type_pants" )+ "/"; count+=1; }                                                                                                                       
		if ( inventory.ItemHasTag( itemId, 'Elixir' ) ) { output = output + GetLocStringByKeyExt( "type_potion" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.ItemHasTag( itemId, 'Rune' ) ) { output = output + GetLocStringByKeyExt( "type_rune" )+ "/"; count+=1; }                                                                                                                        
		if ( inventory.GetItemCategory(itemId) == 'silversword' ) { output = output + GetLocStringByKeyExt( "type_swordsilver" )+ "/"; count+=1; }                                                                                                                 
		if ( inventory.GetItemCategory(itemId) == 'steelsword' && !inventory.ItemHasTag(itemId, 'Secondary') ) { output = output + GetLocStringByKeyExt( "type_swordsteel" )+ "/"; count+=1; }                                                                                                                  
		if ( inventory.ItemHasTag(itemId, 'Secondary') ) { output = output + GetLocStringByKeyExt( "type_weapon" )+ "/"; count+=1; }                                                                                                                  
		if ( inventory.GetItemCategory(itemId) == 'rangedweapon' ) { output = output + GetLocStringByKeyExt( "type_thrown" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.ItemHasTag( itemId, 'Trap' ) ) { output = output + GetLocStringByKeyExt( "type_trap" ) + "/"; count+=1; }                                                                                                                         
		if ( inventory.ItemHasTag( itemId, 'SortTypeDismantle' ) || inventory.GetItemCategory(itemId) == 'other' ) { output = output + GetLocStringByKeyExt( "type_trash" )+ "/"; count+=1; }                                                                                                                       
		if ( inventory.ItemHasTag( itemId, 'Trophy' ) ) { output = output + GetLocStringByKeyExt( "type_trophy" )+ "/"; count+=1; }                                                                                                                      
		if ( inventory.ItemHasTag( itemId, 'Valuable' ) ) { output = output + GetLocStringByKeyExt( "type_valuable" )+ "/"; count+=1; }                                                                                                                 
		if ( inventory.ItemHasTag( itemId, 'Oil' ) || inventory.ItemHasTag( itemId, 'Rune' ) ) { output = output + GetLocStringByKeyExt( "type_weaponupgr" )+ "/"; count+=1; } 
		if ( inventory.ItemHasTag( itemId, 'Lure' ) ) { output = output + GetLocStringByKeyExt( "type_lure" )+ "/"; count+=1; } 
		if ( inventory.ItemHasTag( itemId, 'Quest' ) || inventory.ItemHasTag( itemId, 'SortTypeQuest' ) || ( inventory.GetItemCategory(itemId) == 'quest' ) ) { output = output + GetLocStringByKeyExt( "type_quest" )+ "/"; count+=1; } 
		if ( StrLen(output)-1 > 1 )
		{
			output = StrLeft(output, StrLen(output)-1 );
		}
		
		return output;
	}

	public final function FillItemObject( inventory : CInventoryComponent, stats : CCharacterStats, itemId : SItemUniqueId, itemIdx : int, AS_item : int, 
										  slotItems : array< SItemUniqueId >, optional custom : name )
	{
		var itemName		: string			= inventory.GetItemName( itemId );
		var itemCategory	: name				= inventory.GetItemCategory( itemId );
		var itemMask		: int				= inventory.GetItemTypeFlags( itemId );
		var itemRunes		: array< name >;
		var itemOils		: array< SBuff >;
		var attributes		: array< name >;
		var i, k			: int;
		
		var AS_attribute			: int;
		var valAdd,		valMul		: float;
		var valAddMax,	valMulMax	: float;
		var valueS					: string;
		
		var AS_attributes	: int;
		
		var url : string;
		var iconWidth, iconHeight : int;
		
		var itemTags : array< name >;
		
		var descFull : string;
		
		var craftedItemName : name;
		
		var allIngredientsNames : array< name >;
		var ingredientMask	: int;
		var AS_structure	: int;
		var ingredients		: array< SItemIngredient >;
		var fullDescTootlip : string;
		
		var AS_schemPart	: int; // voSchematicPart
		
		inventory.GetItemTags( itemId, itemTags );

		
		if ( inventory.IsItemMounted( itemId ) || inventory.IsItemHeld( itemId ) || slotItems.Contains( itemId ) )
		{
			itemMask |= 0x00000004;
		}
		
		// rython TODO: sprawdz czy plik "icons/items/" + itemName + "_64x64.dds" istnieje
		// jesli nie to defaultowa sciezke do defaultowego pliku dds podaj.
		//if ( !theHud.FindIconPath( "default_64x64.dds", url, iconWidth, iconHeight ) )
		//{
			//url = "img://globals/gui/default_64x64.dds";
		//}
		
		theHud.SetFloat	( "ID",			itemIdx,										AS_item );
		theHud.SetString( "Name",		GetLocStringByKeyExt( itemName ),				AS_item );
		//theHud.SetString( "Name",		itemNameHtml,				AS_item );
		//theHud.SetString( "Icon",		"icons/items/" + itemName + "_64x64.dds",		AS_item );
		theHud.SetString( "Icon",		"img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds",	AS_item );
		theHud.SetFloat ( "Class",		(int)inventory.GetItemClass( itemId ),			AS_item );
		theHud.SetString( "Desc",		GetTooltipDesc(inventory, itemId) ,	AS_item ); // make TooltipShort
		theHud.SetString( "Mask",		(string)itemMask,								AS_item );
		theHud.SetFloat ( "Mass",		inventory.GetItemAttributeAdditive( itemId, 'item_weight' ), AS_item );
		theHud.SetFloat	( "Price",		GetItemPrice( itemId, inventory ),	AS_item );
		
		// Elixirs
		if ( itemTags.Contains('Elixir') )
		{
			theHud.SetString( "Flav",		"",			AS_item ); // TODO
			theHud.SetFloat( "ToxicLevel",	inventory.GetItemAttributeAdditive( itemId, 'tox_level' ),	AS_item );
		}
		
		theHud.SetFloat	( "Count", inventory.GetItemQuantity( itemId ),	AS_item );
		
		if ( custom == 'alchemy' )
		{
			FillAllIngredientsNames( allIngredientsNames );
			
			if ( itemTags.Contains('Recipe') )
			{
				craftedItemName = inventory.GetCraftedItemName( itemId );
				fullDescTootlip = ListAttributesByItemName( "Abilities", inventory, craftedItemName, AS_item );
			}
			else
			{
				fullDescTootlip = ListAttributes( "Abilities", inventory, stats, itemId, AS_item );
			}
		
			// ElementKind
			if ( itemTags.Contains('AlchemyIngridient') )
			{
				for ( i = 0; i < allIngredientsNames.Size(); i += 1 )
				{
					if ( itemTags.Contains( allIngredientsNames[i] ) )
					{
						ingredientMask = GetIndredientMaskByName( allIngredientsNames[i] );
						break;
					}
				}

				theHud.SetFloat( "ElementKind", ingredientMask, AS_item );
			}
		
			// Structure
			if ( itemTags.Contains('Recipe') )
			{
				/*
					TYPE_VITRIOL     : Number = 0x00010000;
					TYPE_REBIS       : Number = 0x00020000;
					TYPE_VERMILION   : Number = 0x00040000;
					TYPE_AETHER      : Number = 0x00080000;
					TYPE_HYDRAGENUM  : Number = 0x00100000;
					TYPE_CAELUM      : Number = 0x00200000;
					TYPE_QUEBIRTH    : Number = 0x00400000;
					TYPE_SOL         : Number = 0x00800000;
					TYPE_FULGUR      : Number = 0x01000000;
				*/
				AS_structure = theHud.CreateArray( "Structure", AS_item );
			
				inventory.GetItemIngredients( itemId, ingredients );
				for ( i = 0; i < ingredients.Size(); i += 1 )
				{
					ingredientMask = GetIndredientMaskByName( ingredients[i].itemName );
					for ( k = 0; k < ingredients[i].quantity; k += 1 )
					{
						theHud.PushFloat( AS_structure, ingredientMask );
					}
				}
			
				theHud.ForgetObject( AS_structure );
			}
		}
		else if ( custom == 'schematic' )
		{
			craftedItemName = inventory.GetCraftedItemName( itemId );
		
			// fill price for creating item from schematic
			theHud.SetFloat	( "CraftingPrice",	GetSchematicItemPrice( itemId, inventory ), AS_item );
			
			// fill weight for created item
			theHud.SetFloat	( "Mass",	GetItemNameMass( craftedItemName, inventory ), AS_item );

			// fill crafted item abilities
			// TODO: Remove this call ( so says Richu )
			ListAttributesByItemName( "Abilities", inventory, craftedItemName, AS_item );
		
			// fill schematic structure
			AS_structure = theHud.CreateArray( "Structure", AS_item );
		
			inventory.GetItemIngredients( itemId, ingredients );
			for ( i = 0; i < ingredients.Size(); i += 1 )
			{
				AS_schemPart = theHud.CreateAnonymousObject();
				
				theHud.SetFloat(  "ID", 		0,																AS_schemPart );
				theHud.SetString( "Name",  		GetLocStringByKeyExt(ingredients[i].itemName), 					AS_schemPart );
				theHud.SetFloat(  "Count", 		ingredients[i].quantity, 										AS_schemPart );
				theHud.SetString( "Icon",  		GetIngredientIconName( ingredients[i].itemName ), 				AS_schemPart );
				theHud.SetFloat ( "Mass",  		GetItemNameMass( ingredients[i].itemName, inventory ), 			AS_schemPart );
				theHud.SetFloat	( "Price", 		GetItemNamePrice( ingredients[i].itemName, inventory ),			AS_schemPart );
				theHud.SetString( "DescFull", 	GetLocStringByKeyExt( "Tooltip" + ingredients[i].itemName ),	AS_schemPart );
				
				theHud.PushObject( AS_structure, AS_schemPart );
				
				theHud.ForgetObject( AS_schemPart );
			}
			
			theHud.ForgetObject( AS_structure );
		}
		// Attributes
		else
		{
			fullDescTootlip = ListAttributes( "Abilities", inventory, stats, itemId, AS_item );
		}
		
		// Bonuses
		{
			if ( itemCategory == 'armor' || itemCategory == 'silversword' || itemCategory == 'steelsword' )
			{
				thePlayer.GetActiveOilsForItem( itemId, itemOils );
			}
			inventory.GetItemEnhancementItems( itemId, itemRunes );
			
			if ( itemRunes.Size() > 0 || itemOils.Size() > 0 )
			{
				ListBonusesForItem( AS_item, itemRunes, itemOils );
			}
		}
		
		i = inventory.GetItemEnhancementSlotsCount( itemId );
		if ( i < 0 || i > 3 )
		{
			LogChannel( 'GUI', "Item " + itemName + " has invalid enchancement slots." );
		}
		theHud.SetFloat	( "RuneSlotsNum",	i,						AS_item );
		theHud.SetFloat	( "RuneSlotsAvail",	i - itemRunes.Size(),	AS_item );
		
		if ( ! itemTags.Contains('NoDescription') )
		{
			if ( inventory.ItemHasTag(itemId,'Vitriol') ) descFull += "<img width='10' height='10' src='img://globals/gui/icons/items/vitriol_64x64.dds'> ";
			if ( inventory.ItemHasTag(itemId,'Aether') ) descFull += "<img src='img://globals/gui/icons/items/aether_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Rebis') ) descFull += "<img src='img://globals/gui/icons/items/rebis_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Hydragenum') ) descFull += "<img src='img://globals/gui/icons/items/hydragenum_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Quebrith') ) descFull += "<img src='img://globals/gui/icons/items/quebrith_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Vermilion') ) descFull += "<img src='img://globals/gui/icons/items/vermilion_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Caelum') ) descFull += "<img src='img://globals/gui/icons/items/caelum_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Sol') ) descFull += "<img src='img://globals/gui/icons/items/sol_64x64.dds' width='10' height='10'> ";
			if ( inventory.ItemHasTag(itemId,'Fulgur') ) descFull += "<img src='img://globals/gui/icons/items/fulgur_64x64.dds' width='10' height='10'> ";
			
			theHud.SetString( "DescFull", GetLocStringByKeyExt( "Tooltip" + itemName ) + descFull + "<br>" + fullDescTootlip, AS_item );
		}
	}

	public function PlayerGotSubstance( substanceName : name ) : int
	{
		var gotIt : int = 0;
		var allItems : array < SItemUniqueId >;
		var i : int;
		
		thePlayer.GetInventory().GetAllItems( allItems );
		for( i=0; i<allItems.Size(); i+=1 )
		{
			if ( thePlayer.GetInventory().ItemHasTag( allItems[i], substanceName ) ) gotIt = gotIt + thePlayer.GetInventory().GetItemQuantity( allItems[i] );
		}
		return gotIt;
	}
	
	public function ListAttributes( objName : string, inventory : CInventoryComponent, stats : CCharacterStats, itemId : SItemUniqueId, AS_item : int, optional isInCrafting : int  ) : string
	{
		var AS_attribute			: int;
		var valAdd,		valMul		: float;
		var valAddMax,	valMulMax	: float;
		var displayPercMul, displayPercAdd 			: bool;
		var valueS					: string;
		var AS_attributes			: int;
		var attributes				: array< name >;
		var result					: string;
		var x,y 					: int;
		var schematItem, createdItem 			: SItemUniqueId;
		var craftedItemName 		: name;
		var sign					: string;
		var ingredients 			: array < SItemIngredient >;
		var i						: int;
		
		AS_attributes = theHud.CreateArray( objName, AS_item );
			
			// Add item damage min-max
			{
				stats.GetItemAttributeValuesWithPrereqAndInv(itemId, inventory, 'damage_min', valAdd,		valMul,    displayPercMul, displayPercAdd );
				stats.GetItemAttributeValuesWithPrereqAndInv(itemId, inventory, 'damage_max', valAddMax,	valMulMax, displayPercMul, displayPercAdd );
				valueS = "";
				
				if ( (valAdd != 0 || valAddMax != 0) && valMul != 1 )
				{
					valAdd *= valMul;
					valAddMax *= valMul;
				}

				if ( valAdd != 0 || valAddMax != 0 )
				{
					if ( valAdd != valAddMax )
					{
						if ( valAdd == 0 )
						{
							valueS = valueS + RoundFEx(valAddMax) + " ";
						}
						else if ( valAddMax == 0 )
						{
							valueS = valueS + RoundFEx(valAdd) + " ";
						}
						else
						{
							valueS = valueS + RoundFEx(valAdd) + "-" + RoundFEx(valAddMax) + " ";
						}
					}
					else
					{
						valueS = valueS + RoundFEx(valAdd) + " ";
					}
				}
				else if ( valMul != 1.f || valMulMax != 1.f )
				{
					if ( valMul != valMulMax )
					{
						x = RoundFEx((valMul - 1.f) * 100.f);
						y = RoundFEx((valMulMax - 1.f) * 100.f);
						if ( x != 0 && y != 0 ) valueS = valueS + x + "/" + y + m_percentSign;
						if ( x == 0 ) { if ( y > 0 ) { valueS = valueS + "+" + y + m_percentSign; } else { valueS = valueS + y + m_percentSign;  } }
						if ( y == 0 ) { if ( x > 0 ) { valueS = valueS + "+" + x + m_percentSign; } else { valueS = valueS + x + m_percentSign; } }
					}
					else
					{
						if ( valMul > 0.0f )
						{
							// the multiplicative modifier is defined - display it
							if ( valMul > 1.0f )
							{
								sign = "+";
							}
							else
							{
								sign = "";
							}
							valueS = valueS + sign + RoundFEx((valMul - 1.f) * 100.f) + m_percentSign;
						}
						else
						{
							// the multiplicative modifier is not set, so don't display anything
							valueS = "";
						}
					}
				}
				
				if ( valueS != "" )
				{
					
					AS_attribute = theHud.CreateAnonymousObject();
					theHud.SetFloat	( "ID",			0x00000041,								AS_attribute ); // TYPE_DAMAGE, BASIC
					theHud.SetString( "Name",		GetLocStringByKeyExt( "damage" ),		AS_attribute );
					//theHud.SetString( "Icon",		"icons/items/" + attrName + ".swf",		AS_attribute );
					theHud.SetString( "Value",		valueS,									AS_attribute );
					theHud.PushObject( AS_attributes, AS_attribute );
					theHud.ForgetObject( AS_attribute );
					
					
					//result = GetLocStringByKeyExt( "damage" ) + " " + valueS + "<br>";
				}
			}
			ListAttribute( stats, inventory, itemId, AS_attributes, 'damage_reduction', 0x00000011 );
			//result += ListAttribute( stats, inventory, itemId, AS_attributes, 'damage_reduction_block', 0x00000021 );
			result += ListAttribute( stats, inventory, itemId, AS_attributes, 'vitality', 0x00000101 );
			result += ListAttribute( stats, inventory, itemId, AS_attributes, 'endurance', 0x00000201 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'regeneration', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00000400 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'resistance', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00001000 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'critical', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00002000 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'endurance', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00004000 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'vitality', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00004000 );
			
			attributes.Clear();
			inventory.GetItemAttributesByType( itemId, 'bonus', attributes );
			result += ListAttributesForItem( stats, inventory, itemId, AS_attributes, attributes, 0x00004000 );
			
			if ( inventory.ItemHasTag(itemId,'Schematic') || inventory.ItemHasTag(itemId,'Recipe' ) )
			{
				craftedItemName = inventory.GetCraftedItemName( itemId );
				createdItem = inventory.AddItem( craftedItemName, 1, false );
				schematItem = inventory.AddItem( inventory.GetItemName( itemId ), 1, false );
				result += "<img src='img://globals/gui/icons/items/" + StrReplaceAll(craftedItemName, " ", "") + "_64x64.dds' width='22' height='22'>" 
					+ "<font color='#FFFFFF'>" + StrUpperUTF( GetLocStringByKeyExt( craftedItemName ) )
					+ "</font><br>" + GetLocStringByKeyExt( StringToName( "Tooltip"+ NameToString(craftedItemName) ) ) + "<br>";
				result += ListAttributes( objName, inventory, stats, createdItem , AS_item );
				if ( inventory.ItemHasTag(itemId,'Schematic') ) result += "<br><BR><font color='#FFFFFF'>"+ GetLocStringByKeyExt("IngrTooltipCreate") + "<br>";
				if ( inventory.ItemHasTag(itemId,'Recipe') ) result += "<br><BR><font color='#FFFFFF'>"+ GetLocStringByKeyExt("AlchIngrTooltipCreate") + "<br>";
				inventory.GetItemIngredients( schematItem , ingredients );
				for( i=0; i<ingredients.Size(); i+=1 )
				{		
					result = result + "<font color='#FFFFFF'><img width='16' height='16' src='img://globals/gui/icons/items/" + StrReplaceAll(ingredients[i].itemName," ","") + "_64x64.dds'>";
					if ( inventory.ItemHasTag(itemId,'Schematic') )
					{
						result = result + ingredients[i].quantity + "x " + GetLocStringByKeyExt( NameToString( ingredients[i].itemName ) ) + " (" + thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId(ingredients[i].itemName) ) + "/" + ingredients[i].quantity + ")<br>";
					} else
					{
						result = result + ingredients[i].quantity + "x " + GetLocStringByKeyExt( NameToString( ingredients[i].itemName ) ) + " (" + PlayerGotSubstance( ingredients[i].itemName ) + "/" + ingredients[i].quantity + ")<br>";
					}
				}
				inventory.RemoveItem( createdItem );
				inventory.RemoveItem( schematItem );
			}

				if( ( itemId == inventory.GetItemId('Dark difficulty silversword A1') || itemId == inventory.GetItemId('Dark difficulty silversword A2') || itemId == inventory.GetItemId('Dark difficulty silversword A3')
                 || itemId == inventory.GetItemId('Dark difficulty steelsword A1')  || itemId == inventory.GetItemId('Dark difficulty steelsword A2')  || itemId == inventory.GetItemId('Dark difficulty steelsword A3') )
				 && inventory.IsItemMounted( itemId ) ) 
				{
					result += "<br><font color='#d1cfcf'>" + GetLocStringByKeyExt( "darkdiff_tooltip_info" ) + "<br>"; // info about curse
				}
			
			if ( inventory.ItemHasTag(itemId,'DarkDiffA1') )
			{
					result += "<br><font color='#FFFFFF'>" + StrUpperUTF( GetLocStringByKeyExt( "darkdiff_act1_set"  ) ); // set 
					
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyArmorA1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA1"  ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyArmorA1') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA1" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA1" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA1') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA1" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA1" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA1') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA1" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA1" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA1'))  > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA1" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty silversword A1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A1" ); // yes
				}
				else
				{
					if (thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty silversword A1') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A1" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A1')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A1" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A1') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A1" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A1" ); // no
					}
				}				
				
			}
			
			if ( inventory.ItemHasTag(itemId,'DarkDiffA2') )
			{
					
					result += "<br><font color='#FFFFFF'>" + StrUpperUTF( GetLocStringByKeyExt( "darkdiff_act2_set"  ) ); // set 
					
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyArmorA2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA2"  ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyArmorA2') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA2" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA2" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA2') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA2" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA2" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA2') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA2" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA2" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA2') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA2" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty silversword A2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A2" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty silversword A2') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A2" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A2')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A2" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A2') ) > 0 + isInCrafting  )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A2" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A2" ); // no
					}
				}				
				
			}
			
			if ( inventory.ItemHasTag(itemId,'DarkDiffA3') )
			{
					
					result += "<br><font color='#FFFFFF'>" + StrUpperUTF( GetLocStringByKeyExt( "darkdiff_act3_set"  ) ); // set 
					
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyArmorA3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA3"  ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( inventory.GetItemId('DarkDifficultyArmorA3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyArmorA3" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA3" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyBootsA3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyBootsA3" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA3" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyGlovesA3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyGlovesA3" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA3" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('DarkDifficultyPantsA3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "DarkDifficultyPantsA3" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty silversword A3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A3" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty silversword A3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty silversword A3" ); // no
					}
				}
				
				if(thePlayer.GetInventory().IsItemMounted(thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A3')) ) 
				{
					result += "<br><font color='#40ff40'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A3" ); // yes
				}
				else
				{
					if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Dark difficulty steelsword A3') ) > 0 + isInCrafting )
					{
						result += "<br><font color='#007200'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A3" ); // not equipped
					} else
					{
						result += "<br><font color='#ff8080'>" +  GetLocStringByKeyExt( "Dark difficulty steelsword A3" ); // no
					}
				}				
				result += "<br>";
			}

	
			
			theHud.ForgetObject( AS_attributes );
			
			return result;
	}
	
	private final function ListBonusesForItem( AS_item : int, runes : array< name >, oils : array< SBuff > )
	{
		var oil				: SBuff;
		var i				: int;
		var AS_bonuses		: int;
		var AS_bonus		: int;
		var value			: string;
		
		AS_bonuses = theHud.CreateArray( "Bonuses", AS_item );
		
		// Runes
		for ( i = runes.Size()-1; i >= 0; i -= 1 )
		{
			AS_bonus = theHud.CreateAnonymousObject();
			
			//theHud.SetFloat	( "ID",		i,											AS_bonus );
			theHud.SetString( "Name",	GetLocStringByKeyExt( runes[i] ),			AS_bonus );
			theHud.SetString( "Icon",	"icons/items/" + runes[i] + "_64x64.dds",	AS_bonus );
			theHud.SetString( "Value",	"",											AS_bonus );
			
			theHud.PushObject( AS_bonuses, AS_bonus );
			theHud.ForgetObject( AS_bonus );
		}
		// Oils
		for ( i = oils.Size()-1; i >= 0; i -= 1 )
		{
			oil = oils[i];
			
			AS_bonus = theHud.CreateAnonymousObject();
			
			value = "(" + (int)oil.m_duration + "s)";
			
			//theHud.SetFloat( "ID",		1000 + i,									AS_bonus );
			theHud.SetString( "Name",		GetLocStringByKeyExt( oil.m_name ),			AS_bonus );
			theHud.SetString( "Icon",		"icons/items/" + oil.m_name + "_64x64.dds",	AS_bonus );
			theHud.SetString( "Value",		value,										AS_bonus );
			
			theHud.PushObject( AS_bonuses, AS_bonus );
			theHud.ForgetObject( AS_bonus );
		}
		
		theHud.ForgetObject( AS_bonuses );
	}
	
	private final function ListAttributesForItem( stats : CCharacterStats, inventory : CInventoryComponent, itemId : SItemUniqueId, 
												  AS_attributes : int , attributes : array< name >, mask : int ) : string
	{
		var i : int;
		var result : string;
		
		for ( i = attributes.Size()-1; i >= 0; i -= 1 )
		{
			result += ListAttribute( stats, inventory, itemId, AS_attributes, attributes[i], mask );
		}
		
		return result;
	}
	
	private final function ListAttributeBase( valAdd : float, valMul : float, displayPercMul : bool, displayPercAdd : bool ) : string
	{
		var value : string;
		if ( valAdd > 0.f )
		{
			if ( displayPercAdd )
			{
				value = "+" + FloatToString( RoundFEx(valAdd*100.f) ) + m_percentSign;
			}
			else
			{
				//value = "+" + FloatToString( RoundFEx(valAdd) );
				value = "+" + FloatToStringPrec( valAdd, 2 );
			}
		}
		else if ( valAdd < 0.f )
		{
			if ( displayPercAdd )
			{
				value = FloatToString( RoundFEx(valAdd*100.f) ) + m_percentSign;
			}
			else
			{
				//value = FloatToString( RoundFEx(valAdd) );
				value = FloatToStringPrec( valAdd, 2 );
			}
		}
		
		valMul -= 1.f;
		if ( valMul > 0.f )
		{
			if ( displayPercMul )
			{
				value = value + "+" + FloatToString( RoundFEx(valMul*100.f) ) + m_percentSign;
			}
			else
			{
				valMul += 1.f;
				//value = value + "+" + FloatToString( RoundFEx(valMul) );
				value = value + "+" + FloatToStringPrec( valMul, 2 );
			}
		}
		else if ( valMul < 0.f )
		{
			if ( displayPercMul )
			{
				value = value + FloatToString( RoundFEx(valMul*100.f) ) + m_percentSign;
			}
			else
			{
				valMul += 1.f;
				//value = value + FloatToString( RoundFEx(valMul) );
				value = value + FloatToStringPrec( valMul, 2 );
			}
		}
		return value;
	}
	
	private final function ListAttributeCommon( valAdd : float, valMul : float, displayPercMul : bool, displayPercAdd : bool,
												AS_attributes : int, attrName : name, mask : int ) : string
	{
		var AS_attribute	: int;
		var value			: string;
		var value2,value3   : int;
		var attrNameLoc		: string;
		var result			: string;
		var color 			: string;

		value = ListAttributeBase( valAdd, valMul, displayPercMul, displayPercAdd);
		value2 = RoundF(valAdd / 60);
		value3 = RoundF(valAdd);
		
		if ( value != "" && value != "+0" && value != "0" )
		{
			AS_attribute = theHud.CreateAnonymousObject();
			
			attrNameLoc = GetLocStringByKeyExt( attrName );
			
			theHud.SetFloat	( "ID",			mask,										AS_attribute );
			theHud.SetString( "Name",		attrNameLoc,								AS_attribute );
			theHud.SetString( "Icon",		"icons/attrs/" + attrName + "_64x64.dds",	AS_attribute );
			theHud.SetString( "Value",		value,										AS_attribute );
		
			theHud.PushObject( AS_attributes, AS_attribute );
			
			theHud.ForgetObject( AS_attribute );
			
			color = "#c5c8ff";
			if ( valAdd < 0 || valMul < 1.0 )
			{
				color = "#ff5959";
			}
			if ( attrName == 'tox_level' ) {
				color = "#73ff9b";
				result += "<font color='"+color+"'>" + attrNameLoc + "</font><font color='#FFFFFF'> " + value3 + "</font><br>";
			} else
			if ( attrName == 'durration' ) {
				color = "#f8f9a3";
				result += "<font color='"+color+"'>" + attrNameLoc + "</font><font color='#FFFFFF'> " + value2 + "</font><br>";
			} else
				result += "<font color='"+color+"'>" + attrNameLoc + "</font><font color='#FFFFFF'> " + value + "</font><br>";
		}
		
		return result;
	}
	
	private final function ListAttribute( stats : CCharacterStats, inventory : CInventoryComponent, itemId : SItemUniqueId, 
										  AS_attributes : int, attrName : name, mask : int ) : string
	{
		var valAdd, valMul					: float;
		var displayPercMul, displayPercAdd	: bool;

		if ( stats.GetItemAttributeValuesWithPrereqAndInv( itemId, inventory, attrName, valAdd, valMul, displayPercMul, displayPercAdd ) )
		{
			return ListAttributeCommon( valAdd, valMul, displayPercMul, displayPercAdd, AS_attributes, attrName, mask );
		}
		else
		{
			return "";
		}
	}

	public final function SplitStringForItemsIds( input : string ) : array< int >
	{
		var left, right : string;
		var currTxt : string;
		var result : array< int >;
	
		//itemsIdsStr = "123|1|555|66";
		//itemsIdsStr = "123";
	
		currTxt = input;
		right = input;
		while ( StrSplitFirst( currTxt, "|", left, right ) )
		{
			//Log( "Item id: " + left );
			result.PushBack( StringToInt(left) );
			currTxt = right;
		}
		//Log( "Item id: " + right );
		result.PushBack( StringToInt(right) );
		
		return result;
	}
	
	// Returns alchemy ingredient name that item has
	public final function GetItemIngredientName( itemId : SItemUniqueId ) : name
	{
		var itemTags : array< name >;
		thePlayer.GetInventory().GetItemTags( itemId, itemTags );
		
		if (itemTags.Contains('Vitriol')) 			return 'Vitriol';
		else if (itemTags.Contains('Rebis'))		return 'Rebis';
		else if (itemTags.Contains('Caelum'))		return 'Caelum';
		else if (itemTags.Contains('Aether'))		return 'Aether';
		else if (itemTags.Contains('Quebrith'))		return 'Quebrith';
		else if (itemTags.Contains('Sol'))			return 'Sol';
		else if (itemTags.Contains('Vermilion'))	return 'Vermilion';
		else if (itemTags.Contains('Hydragenum'))	return 'Hydragenum';
		else if (itemTags.Contains('Fulgur'))		return 'Fulgur';
		
		return '';
	}
	
	public function GetItemPrice( itemId : SItemUniqueId, inv : CInventoryComponent ) : int
	{
		return GetItemNamePrice( inv.GetItemName( itemId ), inv );
	}
	
	public function GetItemNamePrice( itemName : name, inv : CInventoryComponent ) : int
	{
		var item_price : float;
		var inv_merchant : CInventoryComponent;
		var merchant : CNewNPC;
		var multi : float;
		var dbgName : name;
		var priceSkillMult : float;
		var itemTags : array< name >;
		
		inv.GetItemNameTags( itemName, itemTags );
		
		// quest items are priceless
		if( ! itemTags.Contains( 'Special' ) )
		{
			if ( itemTags.Contains( 'Quest' ) )
			{
				return 0;
			}
		}

		priceSkillMult = thePlayer.GetCharacterStats().GetFinalAttribute('price_mult');
		if(priceSkillMult <= 0.0f)
		{
			priceSkillMult = 1.0f;
		}

		multi = priceSkillMult ;

		merchant = (CNewNPC)thePlayer.shopowner;
		
		if (merchant) 
		{
			multi *= merchant.GetPriceMult();
			inv_merchant = (CInventoryComponent)merchant.GetComponentByClassName( 'CInventoryComponent' );
			dbgName = itemName;
		}
	
			//base price
			item_price = inv.GetItemNameAttributeAdditive( itemName, 'item_price' );
			
			if (  ( ! itemTags.Contains( 'Elixir' ) && ! itemTags.Contains( 'Rune' ) && ! itemTags.Contains( 'Petard' ) && ! itemTags.Contains( 'Oil' ) && ! itemTags.Contains( 'Special' ) && ! itemTags.Contains( 'Ranged' ) && ! itemTags.Contains( 'Schematic' ) && ! itemTags.Contains( 'Trap' )) )
			//if ( !itemTags.Contains( 'Petard' ) )
			{
			//damage prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_min", 5);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_max", 5);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_reduction", 25);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_reduction_toxbonus", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_human", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_gargoil", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_wraith", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_huge", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_undead", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_insectoid", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_bonus_harpy", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_toxbonus", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_reduction_block", 5);
			item_price = item_price + GetAbilityPrice(itemName, inv, "instant_kill_chance", 5000);
			//vitality prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "vitality", 10);
			item_price = item_price + GetAbilityPrice(itemName, inv, "vitality_regen", 50);
			item_price = item_price + GetAbilityPrice(itemName, inv, "vitality_combat_regen", 50);
			//endurance prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "endurance", 50);
			item_price = item_price + GetAbilityPrice(itemName, inv, "endurance_combat_regen", 50);
			item_price = item_price + GetAbilityPrice(itemName, inv, "endurance_noncombat_regen", 25);
			//resistance prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "res_poison", 30);
			item_price = item_price + GetAbilityPrice(itemName, inv, "res_bleed", 30);
			item_price = item_price + GetAbilityPrice(itemName, inv, "res_burn", 30);
			//adrenaline prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "adrenaline_generation", 25);
			item_price = item_price + GetAbilityPrice(itemName, inv, "adrenaline_on_hit", 25);
			//signs
			item_price = item_price + GetAbilityPrice(itemName, inv, "damage_signsbonus", 25);
			item_price = item_price + GetAbilityPrice(itemName, inv, "signs_power", 50);
			//critical effects prices
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_poision", 30);
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_bleed", 30);
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_knockdown", 50);
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_stun", 50);
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_burn", 30);
			item_price = item_price + GetAbilityPrice(itemName, inv, "crt_freeze", 30);
			//various
			item_price = item_price + GetAbilityPrice(itemName, inv, "max_weight", 10);
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'TypeMagic')) {item_price = item_price * 1.1;}
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'TypeRare')) {item_price = item_price * 1.25;}
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'TypeEpic')) {item_price = item_price * 1.5;}
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'Armor')) {item_price = item_price * 2;}	
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'Gloves')) {item_price = item_price * 2;}
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'Pants')) {item_price = item_price * 2;}
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'Boots')) {item_price = item_price * 2;}	
			if (inv.ItemHasTag(inv.GetItemId( itemName ), 'Weapon')) {item_price = item_price * 1;}	else
			{ item_price = item_price * 0.5; } 
			}
		
		if ( inv == thePlayer.GetInventory() )
		{
			return (1 + RoundFEx(item_price / 10));
		} 
		else
		{
			return RoundFEx((item_price * 2.5) * multi + 1);
		}
	}
/*
	private function GetAbilityPrice( itemId : SItemUniqueId, inv : CInventoryComponent, nazwa : string, mnoznik : float ) : float
	{
		var abl_final : float;
		var price : float;
		var abl_name : name; 
	
		abl_final = inv.GetItemAttributeAdditive(itemId, StringToName( nazwa ));
		
		if ( abl_final < 0 ) return 0;
		
		price = abl_final * ( mnoznik * 1 );
	
		return price;
	}
	*/
	private function GetAbilityPrice( itemName : name, inv : CInventoryComponent, nazwa : string, mnoznik : float ) : float
	{
		var abl_final : float;
		var price : float;
		var abl_name : name; 
	
		abl_final = inv.GetItemNameAttributeAdditive( itemName, StringToName( nazwa ) );
		
		if ( abl_final < 0 ) return 0;
		
		price = abl_final * ( mnoznik * 1 );
	
		return price;
	}
	
	private function GetIndredientMaskByName( ingredientName : name ) : int
	{
		if ( ingredientName == 'Vitriol' )
		{
			return 0x00010000;
		}
		else if ( ingredientName == 'Rebis' )
		{
			return 0x00020000;
		}
		else if ( ingredientName == 'Vermilion' )
		{
			return 0x00040000;
		}
		else if ( ingredientName == 'Aether' )
		{
			return 0x00080000;
		}
		else if ( ingredientName == 'Hydragenum' )
		{
			return 0x00100000;
		}
		else if ( ingredientName == 'Caelum' )
		{
			return 0x00200000;
		}
		else if ( ingredientName == 'Quebrith' )
		{
			return 0x00400000;
		}
		else if ( ingredientName == 'Sol' )
		{
			return 0x00800000;
		}
		else if ( ingredientName == 'Fulgur' )
		{
			return 0x01000000;
		}
		else
		{
			LogChannel( 'GUI', "Alchemy: unknown igredient " + ingredientName );
			return 0;
		}
	}
	
	private function FillAllIngredientsNames( out ingredientNames : array< name > )
	{
		ingredientNames.Clear();
		ingredientNames.PushBack( 'Vitriol' );
		ingredientNames.PushBack( 'Rebis' );
		ingredientNames.PushBack( 'Vermilion' );
		ingredientNames.PushBack( 'Aether' );
		ingredientNames.PushBack( 'Hydragenum' );
		ingredientNames.PushBack( 'Caelum' );
		ingredientNames.PushBack( 'Quebrith' );
		ingredientNames.PushBack( 'Sol' );
		ingredientNames.PushBack( 'Fulgur' );
	}
	
	private function GetIngredientIconName( ingredientName : name ) : string
	{
		return "img://globals/gui/icons/items/" + StrReplaceAll(ingredientName, " ", "") + "_64x64.dds";
	}
	
	private function GetSchematicItemPrice( itemId : SItemUniqueId, inventory : CInventoryComponent ) : float
	{
		return inventory.GetItemAttributeAdditive( itemId, 'item_craft_price' );
	}
	
	private function GetItemNameMass( itemName : name, inventory : CInventoryComponent ) : float
	{
		return inventory.GetItemNameAttributeAdditive( itemName, 'item_weight' );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////
	// Info about items without item id, only by item name
	//////////////////////////////////////////////////////////////////////////////////////

	public function ListAttributesByItemName( objName : string, inventory : CInventoryComponent, itemName : name, AS_item : int  ) : string
	{
		var AS_attribute			: int;
		var valAdd,		valMul		: float;
		var valAddMax,	valMulMax	: float;
		var valueS					: string;
		var AS_attributes	: int;
		var displayPercMul, displayPercAdd 			: bool;
		var attributes		: array< name >;
		var damageStrLoc : string;
		var result : string;
		
		// Attributes
		
			AS_attributes = theHud.CreateArray( objName, AS_item );
			
			// Add item damage min-max
			{
				inventory.GetItemNameAttributeValues(itemName, 'damage_min', valAdd,	valMul, displayPercMul, displayPercAdd );
				inventory.GetItemNameAttributeValues(itemName, 'damage_max', valAddMax,	valMulMax, displayPercMul, displayPercAdd );
				valueS = "";
				if (valAdd!=0 || valAddMax!=0)
				{
					if ( valAdd != valAddMax )
						valueS = valueS + RoundFEx(valAdd) + "-" + RoundFEx(valAddMax) + " ";
					else
						valueS = valueS + RoundFEx(valAdd) + " ";
				}
				if (valMul != 1.f || valMulMax != 1.f)
				{
					if ( valMul != valMulMax )
						valueS = valueS + RoundFEx((valMul - 1.f) * 100.f) + "-" + RoundFEx((valMulMax - 1.f) * 100.f) + m_percentSign;
					else
						valueS = valueS + RoundFEx((valMul - 1.f) * 100.f) + m_percentSign;
				}
				
				if ( valueS != "" )
				{
					damageStrLoc = GetLocStringByKeyExt( 'Damage' );
					
					AS_attribute = theHud.CreateAnonymousObject();
					theHud.SetFloat	( "ID",			0x00000041,								AS_attribute );
					theHud.SetString( "Name",		damageStrLoc,							AS_attribute );
				
					//theHud.SetString( "Icon",		"icons/items/" + attrName + ".swf",		AS_attribute );
					theHud.SetString( "Value",		valueS,									AS_attribute );
					theHud.PushObject( AS_attributes, AS_attribute );
					theHud.ForgetObject( AS_attribute );
					
					//result = damageStrLoc + " " + valueS + "<br>";
				}
			}
			// Example: <damage_reduction mult="false" always_random="false" min="2" max="3"/>
			result += ListAttributeForItemName( inventory, itemName, AS_attributes, 'damage_reduction', 0x00000011 );
			result += ListAttributeForItemName( inventory, itemName, AS_attributes, 'damage_reduction_block', 0x00000021 );
			result += ListAttributeForItemName( inventory, itemName, AS_attributes, 'vitality', 0x00000101 );
			result += ListAttributeForItemName( inventory, itemName, AS_attributes, 'endurance', 0x00000201 );
			
			// Example: <res_knockdown mult="true" always_random="false" min="1.02" max="1.02" type="resistance"/>
			attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'regeneration', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00000400 );
			
			attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'resistance', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00001000 );
			
			attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'critical', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00002000 );
			
			attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'endurance', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00004000 );

						attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'vitality', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00004000 );
			
			attributes.Clear();
			inventory.GetItemNameAttributesByType( itemName, 'bonus', attributes );
			result += ListAttributesForItemName( inventory, itemName, AS_attributes, attributes, 0x00004000 );
			
			theHud.ForgetObject( AS_attributes );

			return result;
	}
	
	private final function ListAttributesForItemName( inventory : CInventoryComponent, itemName : name, AS_attributes : int , attributes : array< name >, mask : int ) : string
	{
		var i      : int;
		var result : string;
		for ( i = attributes.Size()-1; i >= 0; i -= 1 )
		{
			result += ListAttributeForItemName( inventory, itemName, AS_attributes, attributes[i], mask );
		}
	}
	
	private final function ListAttributeForItemName( inventory : CInventoryComponent, itemName : name, AS_attributes : int , attrName : name, mask : int ) : string
	{
		var valAdd, valMul					: float;
		var displayPercMul, displayPercAdd	: bool;

		inventory.GetItemNameAttributeValues( itemName, attrName, valAdd, valMul, displayPercMul, displayPercAdd );
		
		return ListAttributeCommon( valAdd, valMul, displayPercMul, displayPercAdd, AS_attributes, attrName, mask );
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function IsItemNamePowerSource( itemName : name ) : bool
	{
		return itemName == 'COP_Vitality' || itemName == 'COP_Endurance' || 
			   itemName == 'COP_Signs'    || itemName == 'COP_Damage'    ||
			   itemName == 'COP_Armor'    || itemName == 'AlchemyAdrenaline' || 
               itemName == 'QuenEffect';
	}

	
	public final function GetCurrentWeightString() : string
	{
		return (int)thePlayer.GetCurrentWeight() + " / " + (int)thePlayer.GetMaxWeight();
	}

	// hack
	public final function FillFlashItemDescription( itemName : name, inventory : CInventoryComponent, stats : CCharacterStats, AS_arrayFlash : int,
											        itemIdx : int, slotItems : array< SItemUniqueId >, optional custom : name )
	{
		var itemId  : SItemUniqueId;
		var AS_item : int;

		itemId = inventory.AddItem( itemName, 1, false );
		AS_item = theHud.CreateAnonymousObject();
		theHud.m_utils.FillItemObject( inventory, stats, itemId, itemIdx, AS_item, slotItems, custom );
		theHud.PushObject( AS_arrayFlash, AS_item );
		theHud.ForgetObject( AS_item );
		inventory.RemoveItem( itemId, 1 );
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////
}
