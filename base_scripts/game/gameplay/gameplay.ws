/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009 Ozzie's Early Day R&D Home Center
/***********************************************************************/

// ------------------------------------------------------------------------
//                            RÓ¯NE FUNKCJE 
// ------------------------------------------------------------------------

function RemoveDarkDiffItemsIfNotDarkDiff( npc_newnpc : CNewNPC )
{
	if ( theGame.GetDifficultyLevel() != 4 )
	{
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA1' ), 10 );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA3' ),10 );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty steelsword A3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Schematic Dark difficulty silversword A3' ), 10  );	
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyArmorA1' ), 10 );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyArmorA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyArmorA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyBootsA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyBootsA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyBootsA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyGlovesA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyGlovesA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyGlovesA3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyPantsA1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyPantsA2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'DarkDifficultyPantsA3' ),10 );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty steelsword A1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty steelsword A2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty steelsword A3' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty silversword A1' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty silversword A2' ), 10  );
		npc_newnpc.GetInventory().RemoveItem( npc_newnpc.GetInventory().GetItemId( 'Dark difficulty silversword A3' ), 10  );			
	}
}
	
function PlayerRemoveDarkDiffItemsIfNotDarkDiff()
{
	if ( theGame.GetDifficultyLevel() != 4 )
	{
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA1' ), 10 );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyArmorA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyBootsA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyGlovesA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Schematic DarkDifficultyPantsA3' ),10 );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyArmorA1' ), 10 );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyArmorA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyArmorA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyBootsA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyBootsA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyBootsA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyGlovesA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyGlovesA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyGlovesA3' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyPantsA1' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyPantsA2' ), 10  );
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'DarkDifficultyPantsA3' ),10 );		
	}
}
		

function PlaySoundLoc( eventName : string, langId : string )
{
	theSound.PlaySound( eventName + "_" + langId );
}
function PlaySoundLocOnNode( node : CNode, eventName : string, langId : string )
{
	theSound.PlaySoundOnActor(node, '', eventName + "_" + langId );
}

exec function GUIFullscreenBlurSetup( val : float )
{
	FullscreenBlurSetup( val );
}

// Use item
exec function UseItem( itemName : name )
{
	var itemId : SItemUniqueId;
	
	itemId = thePlayer.GetInventory().GetItemId( itemName ); 
	
	thePlayer.UseItem( itemId );
	thePlayer.SelectThrownItem( itemId );
}

// Add item
exec function AddItem( itemName : string )
{
	thePlayer.GetInventory().AddItem( StringToName( itemName ) ); 
}

exec function RemoveAllItems()
{
	var items : array<SItemUniqueId>;
	var i, size : int;
	
	thePlayer.GetInventory().GetAllItems( items );
	
	size = items.Size();
	for( i = 0; i < size; i += 1 )
	{
		thePlayer.GetInventory().RemoveItem( items[i] );
	}
}

exec function FastForward( hours : int )
{
	var nullObject : CObject;
	
	if ( hours > 0 )
	{
		ScheduleTimeEvent( nullObject, "FastForward( 0 )", GameTimeCreate( hours,0,0 ), true );
		theGame.SetHoursPerMinute( 48 );
	}
	else
	{
		theGame.ResetHoursPerMinute();
	}
}

exec function GimmieTraps()
{
	if( !theGame.zagnica )
	{
		return;
	}
	
	AddTrap();
	AddTrap();
	AddTrap();
	AddTrap();
	theGame.zagnica.RemoveDummies();
	theGame.zagnica.UpdateDummies();
}
	
exec function AddTrap()
{
	thePlayer.GetInventory().AddItem( 'Tentadrake Trap' );
}

exec function RemTrap()
{
	var itemId : SItemUniqueId;
	
	itemId = thePlayer.GetInventory().GetItemId( 'Tentadrake Trap' );
	thePlayer.GetInventory().RemoveItem( itemId );
}

// SL: Add best Items
exec function GiveBestItems()
{
	thePlayer.GetInventory().AddItem( 'Forgotten Sword of Vrans' ); 
	thePlayer.GetInventory().AddItem( 'Addan deith' ); 
	thePlayer.GetInventory().AddItem( 'Ban Ard Armor' ); 
	thePlayer.GetInventory().AddItem( 'Hardened Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Long Studded Leather Gloves' ); 
	thePlayer.GetInventory().AddItem( 'High Quality Temerian Unique Leather Pants' ); 
}

// SL: Add best Items
exec function GiveAllStuff()
{
	//Zbroje
	thePlayer.GetInventory().AddItem( 'Forgotten Sword of Vrans' ); 
	thePlayer.GetInventory().AddItem( 'Plain Shirt' ); 
	thePlayer.GetInventory().AddItem( 'Light Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Quilted Leather' ); 
	thePlayer.GetInventory().AddItem( 'Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Studded Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Heavy Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Hardened Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Light Chainmail Shirt' ); 
	thePlayer.GetInventory().AddItem( 'Elven Armor' ); 
	thePlayer.GetInventory().AddItem( 'Kaedwenian Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Aedirnian Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Shiadhal Armor' ); 
	thePlayer.GetInventory().AddItem( 'Astrogarus Armor' ); 
	thePlayer.GetInventory().AddItem( 'Cahir Armor' ); 
	thePlayer.GetInventory().AddItem( 'Quality Leather Jacket' ); 
	thePlayer.GetInventory().AddItem( 'Light Leather Armo' ); 
	thePlayer.GetInventory().AddItem( 'Heavy Elven Armor' ); 
	thePlayer.GetInventory().AddItem( 'Ravens Armor' ); 
	thePlayer.GetInventory().AddItem( 'Tentadrake Armor' ); 
	thePlayer.GetInventory().AddItem( 'Quilted Armor' ); 
	thePlayer.GetInventory().AddItem( 'Thyssen Armor' ); 
	thePlayer.GetInventory().AddItem( 'Armor of Loc Muinne' ); 
	thePlayer.GetInventory().AddItem( 'Dragonscale Armor' ); 
	thePlayer.GetInventory().AddItem( 'Zireael Armor' ); 
	thePlayer.GetInventory().AddItem( 'Kaedwenian Leather Armor' ); 
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Armor' ); 
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Heavy Armor' ); 
	thePlayer.GetInventory().AddItem( 'Draug Armor' ); 
	thePlayer.GetInventory().AddItem( 'Dearg Ruadhri' ); 
	thePlayer.GetInventory().AddItem( 'Armor of Tir' ); 
	thePlayer.GetInventory().AddItem( 'Ysgith Armor' ); 
	thePlayer.GetInventory().AddItem( 'Armor of Ys' ); 
	thePlayer.GetInventory().AddItem( 'Temerian Armor' ); 
	thePlayer.GetInventory().AddItem( 'Vran Armor' ); 
	
	//Buty
	thePlayer.GetInventory().AddItem( 'Worn Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Reinforced Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Worn Hardened Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Hardened Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Temerian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'High Quality Temerian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'High Quality Nilfgaardian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Kaedwenian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'High Quality Kaedwenian Unique Leather Boots' ); 
	thePlayer.GetInventory().AddItem( 'Unique Leather Boots of Elder Blood' ); 
	
	//Rekawice
	thePlayer.GetInventory().AddItem( 'Worn Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Short Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Long Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Worn Long Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Short Studded Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Long Studded Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Quality Long Gloves' );
	thePlayer.GetInventory().AddItem( 'Sorccerer Gloves' );
	thePlayer.GetInventory().AddItem( 'Elven Gloves' );
	thePlayer.GetInventory().AddItem( 'High Quality Temerian Unique Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'High Quality Kaedwenian Unique Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'High Quality Nilfgaardian Unique Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Unique Leather Gloves of Elder Blood' );
	thePlayer.GetInventory().AddItem( 'Herbalist Gloves' );
	
	//Spodnie
	thePlayer.GetInventory().AddItem( 'Worn Pants' );
	thePlayer.GetInventory().AddItem( 'Heavy Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Quality Heavy Leather Pants' );
	thePlayer.GetInventory().AddItem( 'High Quality Heavy Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Quality Leather Pants' );
	thePlayer.GetInventory().AddItem( 'High Quality Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Studded Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Quality Studded Leather Pants' );
	thePlayer.GetInventory().AddItem( 'High Quality Studded Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Temerian Unique Leather Pants' );
	thePlayer.GetInventory().AddItem( 'High Quality Temerian Unique Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Unique Leather Pants' );
	thePlayer.GetInventory().AddItem( 'High Quality Nilfgaardian Unique Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Kaedwenian Unique Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Unique Leather Pants of Elder Blood' );
	
	//Miecze srebrne
	thePlayer.GetInventory().AddItem( 'Witcher Silver Sword');
	thePlayer.GetInventory().AddItem( 'Quality Witcher Silver Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Witcher Silver Sword');
	thePlayer.GetInventory().AddItem( 'Blue Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Red Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Yellow Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Quality Blue Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Quality Red Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Quality Yellow Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Blue Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Red Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Yellow Meteorite Silver Sword');
	thePlayer.GetInventory().AddItem( 'Unique Silver Sword');
	thePlayer.GetInventory().AddItem( 'Unique Silver Meteorite Sword');
	thePlayer.GetInventory().AddItem( 'Fate');
	thePlayer.GetInventory().AddItem( 'Negotiator');
	thePlayer.GetInventory().AddItem( 'Naevde Seidhe');
	thePlayer.GetInventory().AddItem( 'Caerme');
	thePlayer.GetInventory().AddItem( 'Harpy');
	thePlayer.GetInventory().AddItem( 'Moonblade');
	thePlayer.GetInventory().AddItem( 'Blood Sword');
	thePlayer.GetInventory().AddItem( 'Gvalchca');
	thePlayer.GetInventory().AddItem( 'Gynvael aedd');
	thePlayer.GetInventory().AddItem( 'Deithwen');
	thePlayer.GetInventory().AddItem( 'Draug Testimony');
	thePlayer.GetInventory().AddItem( 'Addan deith');
	
	//Miecze stalowe
	thePlayer.GetInventory().AddItem( 'Rusty Steel Sword');
	thePlayer.GetInventory().AddItem( 'Aedirnian Short Sword');
	thePlayer.GetInventory().AddItem( 'Aedirnian Light Sword');
	thePlayer.GetInventory().AddItem( 'Aedirnian Red Sword');
	thePlayer.GetInventory().AddItem( 'Caingornian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Yspadenian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Creydenian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Temerian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Temerian Elite Sword');
	thePlayer.GetInventory().AddItem( 'Temerian Essenced Sword');
	thePlayer.GetInventory().AddItem( 'Short Steel Sword');
	thePlayer.GetInventory().AddItem( 'Quality Short Steel Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Short Steel Sword');
	thePlayer.GetInventory().AddItem( 'Long Steel Sword');
	thePlayer.GetInventory().AddItem( 'Quality Long Steel Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Long Steel Sword');
	thePlayer.GetInventory().AddItem( 'Hunting Steel Sword');
	thePlayer.GetInventory().AddItem( 'Quality Hunting Steel Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Hunting Steel Sword');
	thePlayer.GetInventory().AddItem( 'Jagged Blade');
	thePlayer.GetInventory().AddItem( 'Peacemaker');
	thePlayer.GetInventory().AddItem( 'Angivare');
	thePlayer.GetInventory().AddItem( 'Deireadh');
	thePlayer.GetInventory().AddItem( 'Kaedwenian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Kaedwenian Quality Sword');
	thePlayer.GetInventory().AddItem( 'Kaedwenian Black Sword');
	thePlayer.GetInventory().AddItem( 'Dol Blathanna Quality Steel Blade');
	thePlayer.GetInventory().AddItem( 'Dol Blathanna High Quality Steel Blade');
	thePlayer.GetInventory().AddItem( 'Zerrikan Steel Sabre');
	thePlayer.GetInventory().AddItem( 'Zerrikan Poisoned Steel Sabre');
	thePlayer.GetInventory().AddItem( 'Elven Short Sihil');
	thePlayer.GetInventory().AddItem( 'Elven Sword');
	thePlayer.GetInventory().AddItem( 'Elven Sword of Blue Mountains');
	thePlayer.GetInventory().AddItem( 'Mahakaman Steel Sihil');
	thePlayer.GetInventory().AddItem( 'Quality Dueling Steel Sword');
	thePlayer.GetInventory().AddItem( 'High Quality Dueling Steel Sword');
	thePlayer.GetInventory().AddItem( 'Gwyhyr');
	thePlayer.GetInventory().AddItem( 'Harvall');
	thePlayer.GetInventory().AddItem( 'Ceremonial Steel Sword of Deithwen');
	thePlayer.GetInventory().AddItem( 'Forgotten Sword of Vrans');
	thePlayer.GetInventory().AddItem( 'Executioner Rod');
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Steel Sword');
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Harphy Sword');
	thePlayer.GetInventory().AddItem( 'Nilfgaardian Essenced Sword');
	thePlayer.GetInventory().AddItem( 'Iron shard');
	thePlayer.GetInventory().AddItem( 'Steel Sabre');
	thePlayer.GetInventory().AddItem( 'Poisoned Steel Sabre');
	thePlayer.GetInventory().AddItem( 'Poisoned Jagged Blade');
	thePlayer.GetInventory().AddItem( 'Cursed claymore');
	thePlayer.GetInventory().AddItem( 'Redania Steel Sword');
	thePlayer.GetInventory().AddItem( 'Redania Heavy Sword');
	thePlayer.GetInventory().AddItem( 'Redania Butcher');
	thePlayer.GetInventory().AddItem( 'Dwarven Khuris');
	thePlayer.GetInventory().AddItem( 'Dwarven Short Sword');
	thePlayer.GetInventory().AddItem( 'Dwarven Unique Khuris');
	
	//Runy	
	thePlayer.GetInventory().AddItem( 'Rune of Sun');
	thePlayer.GetInventory().AddItem( 'Rune of Ysgith');
	thePlayer.GetInventory().AddItem( 'Rune of Earth');
	thePlayer.GetInventory().AddItem( 'Rune of Moon');
	thePlayer.GetInventory().AddItem( 'Rune of Fire');
	
	//Ulepszenia	
	thePlayer.GetInventory().AddItem( 'Amethyst Armor Enhancement');
	thePlayer.GetInventory().AddItem( 'Diamond Armor Enhancement');
	thePlayer.GetInventory().AddItem( 'Tentadrake Armor Enhancement');
	thePlayer.GetInventory().AddItem( 'Endriag Armor Enhancement');
	thePlayer.GetInventory().AddItem( 'Mystic Armor Enhancement');
	
	//Craft	
	thePlayer.GetInventory().AddItem( 'Troll skin');
	thePlayer.GetInventory().AddItem( 'Necrophage skin');
	thePlayer.GetInventory().AddItem( 'Cloth');
	thePlayer.GetInventory().AddItem( 'Cloth');
	thePlayer.GetInventory().AddItem( 'Oil');
	thePlayer.GetInventory().AddItem( 'Oil');
	thePlayer.GetInventory().AddItem( 'Oil');
	thePlayer.GetInventory().AddItem( 'Endriag skin');
	thePlayer.GetInventory().AddItem( 'Schematic Leather');
}

//SL: Add all keys
exec function GiveKeys()
{

	thePlayer.GetInventory().AddItem( 'Rusty Keychain');
	thePlayer.GetInventory().AddItem( 'Tower Key');
	thePlayer.GetInventory().AddItem( 'Triss Prison Key');
	thePlayer.GetInventory().AddItem( 'Nilfgaard Camp Key');
	thePlayer.GetInventory().AddItem( 'Prison Key');
	thePlayer.GetInventory().AddItem( 'Rune Key');
	thePlayer.GetInventory().AddItem( StringToName("Baltimore\'s Key") );
}
//SL: Add Orens
exec function AddOr( quantity : int )
{
	thePlayer.GetInventory().AddItem( 'Orens', quantity ); 
}

//SL: Remove Orens
exec function RemoveOr( quantity : int )
{
	if(quantity <= thePlayer.GetInventory().GetItemCount() )
	{		
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Orens'), quantity ); 
	}
	else
		thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId('Orens'), thePlayer.GetInventory().GetItemQuantityByName('Orens') ); 
		
}


exec function FastForwardOn ()
{
		theGame.SetHoursPerMinute( 48 );
}

exec function FastForwardOff ()
{
		theGame.ResetHoursPerMinute();
}

exec function RunTut()
{
	theGame.TutorialEnabled( true );
}

exec function GoTutButton()
{
	thePlayer.EnableTutButton( true );
}

exec function BurnMe()
{
	thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( 1, 1, 10, 10 ) );
}
