/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Temporary functions, to be accessed from console
/** Feel free to change contents of this file
/** Copyright © 2009
/***********************************************************************/
exec function StoryAbl(ablname : name, level : int)
{
	AddStoryAbility(ablname, level);
}

exec function Summer()
{
	if(thePlayer.GetCharacterStats().HasAbility('story_s32_1'))
	{
		theHud.m_messages.ShowInformationText("story_s32_1");
	}
	else if(thePlayer.GetCharacterStats().HasAbility('story_s31_1'))
	{
		theHud.m_messages.ShowInformationText("story_s31_1");
	}
}

exec function Arena()
{
	if(theGame.GetIsPlayerOnArena())
	{
		theHud.m_messages.ShowInformationText("Grasz na arenie");
	}
	else
	{
		theHud.m_messages.ShowInformationText("Nie grasz na arenie");
	}
}
exec function AddItem1()
{
	thePlayer.GetInventory().AddItem('DarkDifficultyArmorA2');
}
exec function AddItem2()
{
	thePlayer.GetInventory().AddItem('DarkDifficultyBootsA2');
}
exec function AddItem3()
{
	thePlayer.GetInventory().AddItem('DarkDifficultyGlovesA2');
}
exec function AddItem4()
{
	thePlayer.GetInventory().AddItem('DarkDifficultyPantsA2');
}
exec function AddItem5()
{
	thePlayer.GetInventory().AddItem('Dark difficulty silversword A2');
}
exec function AddItem6()
{
	thePlayer.GetInventory().AddItem('Dark difficulty steelsword A2');
}
exec function SetWave(waveNum : int)
{
	var arenaManager : CArenaManager;
	var waveText : int;
	
	waveText = waveNum - 1;
	
	arenaManager = theGame.GetArenaManager();
	if(arenaManager)
	{
		if(waveNum > arenaManager.arenaWaves.Size())
		{
			arenaManager.tierNumber = waveNum/arenaManager.arenaWaves.Size();			
		}
		
		waveNum = (waveNum-1)%arenaManager.arenaWaves.Size();
		
		arenaManager.SetCurrentWave(waveNum, waveText);
	}
}
exec function UseCombatV2(flag : bool)
{
	thePlayer.SetCombatV2(flag);
}
exec function SetSelection(angleThreshold, minAngleThreshold, angle, distance, selected, attacked, selectedTimeOut, attackedTimeOut, finisher, axii, maxAngle, secondaryTestMult : float)
{
	thePlayer.SetEnemySelectionWeights(angleThreshold, minAngleThreshold, angle, distance, selected, attacked, selectedTimeOut, attackedTimeOut, finisher, axii, maxAngle, secondaryTestMult);
}
exec function GiveGold(amount : int)
{
	thePlayer.GetInventory().AddItem( 'Orens', amount);
}
exec function IgnoreInput( GIName : name, ignore : bool )
{
	theGame.IgnoreGameInput( GIName, ignore );
}

exec function RemPots()
{
	thePlayer.RemoveAllElixirs();
	thePlayer.RemoveAllOils();
}
exec function UAH()
{
	theGame.GetArenaManager().UpdateArenaHUD(true);
}
exec function DVit()
{
	var actor : CActor;
	actor = theGame.GetActorByTag('dragon_head');
	actor.SetInitialHealth(actor.GetCharacterStats().GetFinalAttribute('vitality'));
	actor.SetHealth(actor.GetInitialHealth(), true, NULL);
}
exec function AddTut()
{
	//theHud.m_hud.ShowTutorial("tut62", "", false); // <-- tutorial content is present in external tutorial - disabled
	//theHud.ShowTutorialPanelOld( "tut62", "" );
}
exec function PrintItems()
{
	var items : array<SItemUniqueId>;
	var i, size : int;
	thePlayer.GetInventory().GetAllItems(items);
	size = items.Size();
	
	for(i = 0; i < size; i += 1)
	{
		Log(thePlayer.GetInventory().GetItemName(items[i]));
	}
}
exec function PrintAbl()
{
	thePlayer.GetCharacterStats().LogStats();
}
exec function CER()
{
	thePlayer.SetCombatEndAnimRequest(true);
}
exec function AddApostropheItems()
{	
	thePlayer.GetInventory().AddItem(StringToName("Seltkirk's Chainmail"));
	thePlayer.GetInventory().AddItem(StringToName("Dandelion's Book of Poetry"));
	thePlayer.GetInventory().AddItem(StringToName("Kajetan's Talisman"));
	thePlayer.GetInventory().AddItem(StringToName("Young's Talisman"));
	thePlayer.GetInventory().AddItem(StringToName("Candlemaker's Potion"));
	thePlayer.GetInventory().AddItem(StringToName("Gone Explorer's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Priest's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Garwena's Letter"));
	thePlayer.GetInventory().AddItem(StringToName("Garwena's Letter 2"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Medalion"));
	thePlayer.GetInventory().AddItem(StringToName("Dragon's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Sabrina's Spear"));
	thePlayer.GetInventory().AddItem(StringToName("Part of Sabrina's Neckless"));
	thePlayer.GetInventory().AddItem(StringToName("Sheala's Protection Amulet"));
	thePlayer.GetInventory().AddItem(StringToName("Commander's Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Detmold's Cell Key"));
	thePlayer.GetInventory().AddItem(StringToName("Leto's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Peasant's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimore's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Iorweth's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Cedric's Map"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Poison"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Journal"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Report"));
	thePlayer.GetInventory().AddItem(StringToName("Eyla Tarn Captain's Journal"));
	thePlayer.GetInventory().AddItem(StringToName("Loredo's Letter"));
	thePlayer.GetInventory().AddItem(StringToName("Ludwig Merse's Report"));
	thePlayer.GetInventory().AddItem(StringToName("Dun Banner's Cloak"));
	thePlayer.GetInventory().AddItem(StringToName("Beaver's Hat"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimore's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Marietta's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Guard's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Detmold's Safe Key"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's key"));
}	
exec function AddAllTutorials()
{
/*
theHud.m_hud.HideTutorial();
theHud.m_hud.UnlockTutorial();
theHud.m_hud.ShowTutorial("tut00", "", false);
theHud.m_hud.ShowTutorial("tut01", "", false);
theHud.m_hud.ShowTutorial("tut02", "", false);
theHud.m_hud.ShowTutorial("tut03", "", false);
theHud.m_hud.ShowTutorial("tut04", "", false);
theHud.m_hud.ShowTutorial("tut05", "", false);
theHud.m_hud.ShowTutorial("tut06", "", false);
theHud.m_hud.ShowTutorial("tut07", "", false);
theHud.m_hud.ShowTutorial("tut08", "", false);
theHud.m_hud.ShowTutorial("tut09", "", false);
theHud.m_hud.ShowTutorial("tut10", "", false);
theHud.m_hud.ShowTutorial("tut11", "", false);
theHud.m_hud.ShowTutorial("tut12", "", false);
theHud.m_hud.ShowTutorial("tut13", "", false);
theHud.m_hud.ShowTutorial("tut14", "", false);
theHud.m_hud.ShowTutorial("tut15", "", false);
theHud.m_hud.ShowTutorial("tut16", "", false);
theHud.m_hud.ShowTutorial("tut17", "", false);
theHud.m_hud.ShowTutorial("tut18", "", false);
theHud.m_hud.ShowTutorial("tut19", "", false);
theHud.m_hud.ShowTutorial("tut20", "", false);
theHud.m_hud.ShowTutorial("tut21", "", false);
theHud.m_hud.ShowTutorial("tut22", "", false);
theHud.m_hud.ShowTutorial("tut23", "", false);
theHud.m_hud.ShowTutorial("tut24", "", false);
theHud.m_hud.ShowTutorial("tut25", "", false);
theHud.m_hud.ShowTutorial("tut26", "", false);
theHud.m_hud.ShowTutorial("tut27", "", false);
theHud.m_hud.ShowTutorial("tut28", "", false);
theHud.m_hud.ShowTutorial("tut29", "", false);
theHud.m_hud.ShowTutorial("tut30", "", false);
theHud.m_hud.ShowTutorial("tut31", "", false);
theHud.m_hud.ShowTutorial("tut32", "", false);
theHud.m_hud.ShowTutorial("tut33", "", false);
theHud.m_hud.ShowTutorial("tut34", "", false);
theHud.m_hud.ShowTutorial("tut35", "", false);
theHud.m_hud.ShowTutorial("tut36", "", false);
theHud.m_hud.ShowTutorial("tut37", "", false);
theHud.m_hud.ShowTutorial("tut38", "", false);
theHud.m_hud.ShowTutorial("tut39", "", false);
theHud.m_hud.ShowTutorial("tut40", "", false);
theHud.m_hud.ShowTutorial("tut41", "", false);
theHud.m_hud.ShowTutorial("tut42", "", false);
theHud.m_hud.ShowTutorial("tut43", "", false);
theHud.m_hud.ShowTutorial("tut44", "", false);
theHud.m_hud.ShowTutorial("tut45", "", false);
theHud.m_hud.ShowTutorial("tut46", "", false);
theHud.m_hud.ShowTutorial("tut47", "", false);
theHud.m_hud.ShowTutorial("tut48", "", false);
theHud.m_hud.ShowTutorial("tut49", "", false);
theHud.m_hud.ShowTutorial("tut50", "", false);
theHud.m_hud.ShowTutorial("tut51", "", false);
theHud.m_hud.ShowTutorial("tut52", "", false);
theHud.m_hud.ShowTutorial("tut53", "", false);
theHud.m_hud.ShowTutorial("tut54", "", false);
theHud.m_hud.ShowTutorial("tut55", "", false);
theHud.m_hud.ShowTutorial("tut56", "", false);
theHud.m_hud.ShowTutorial("tut57", "", false);
theHud.m_hud.ShowTutorial("tut58", "", false);
theHud.m_hud.ShowTutorial("tut59", "", false);
theHud.m_hud.ShowTutorial("tut60", "", false);
theHud.m_hud.ShowTutorial("tut61", "", false);
theHud.m_hud.ShowTutorial("tut62", "", false);
theHud.m_hud.ShowTutorial("tut63", "", false);
theHud.m_hud.ShowTutorial("tut64", "", false);
theHud.m_hud.ShowTutorial("tut65", "", false);
theHud.m_hud.ShowTutorial("tut66", "", false);
theHud.m_hud.ShowTutorial("tut68", "", false);
theHud.m_hud.ShowTutorial("tut70", "", false);
theHud.m_hud.ShowTutorial("tut71", "", false);
theHud.m_hud.ShowTutorial("tut72", "", false);
theHud.m_hud.ShowTutorial("tut73", "", false);
theHud.m_hud.ShowTutorial("tut74", "", false);
theHud.m_hud.ShowTutorial("tut75", "", false);
theHud.m_hud.ShowTutorial("tut76", "", false);
theHud.m_hud.ShowTutorial("tut77", "", false);
theHud.m_hud.ShowTutorial("tut103", "", false);
theHud.m_hud.ShowTutorial("tut104", "", false);
theHud.m_hud.ShowTutorial("tut112", "", false);
theHud.m_hud.ShowTutorial("tut113", "", false);
theHud.m_hud.ShowTutorial("tut114", "", false);
theHud.m_hud.ShowTutorial("tut132", "", false);
theHud.m_hud.ShowTutorial("tut163", "", false);
theHud.m_hud.ShowTutorial("tut164", "", false);
theHud.m_hud.ShowTutorial("tut165", "", false);
theHud.m_hud.ShowTutorial("tut172", "", false);
theHud.m_hud.ShowTutorial("tut201", "", false);
theHud.m_hud.ShowTutorial("tut202", "", false);
theHud.m_hud.ShowTutorial("tut203", "", false);
theHud.m_hud.ShowTutorial("tut204", "", false);
theHud.m_hud.ShowTutorial("tut205", "", false);
theHud.m_hud.ShowTutorial("tut206", "", false);
theHud.m_hud.ShowTutorial("tut207", "", false);
theHud.m_hud.ShowTutorial("tut208", "", false);
*/
}

exec function AddAllArmors()
{
	thePlayer.GetInventory().AddItem(StringToName("Seltkirk's Chainmail")); 
	thePlayer.GetInventory().AddItem(StringToName("Light Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Quilted Leather")); 
	thePlayer.GetInventory().AddItem(StringToName("Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Studded Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Temerian Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Heavy Leather Jacket")); 	
	thePlayer.GetInventory().AddItem(StringToName("Hardened Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Elven Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Astrogarus Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Light Chainmail Shirt")); 
	thePlayer.GetInventory().AddItem(StringToName("Shiadhal Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Quality Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Light Leather Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Heavy Elven Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Ravens Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Quilted Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Aedirnian Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Leather Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Leather Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Thyssen Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Ban Ard Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Armor of Loc Muinne")); 
	thePlayer.GetInventory().AddItem(StringToName("Dragonscale Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Zireael Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Draug Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Dearg Ruadhri")); 
	thePlayer.GetInventory().AddItem(StringToName("Armor of Tir")); 
	thePlayer.GetInventory().AddItem(StringToName("Cahir Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Ysgith Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Armor of Ys")); 
	thePlayer.GetInventory().AddItem(StringToName("Vran Armor")); 
	thePlayer.GetInventory().AddItem(StringToName("Roche Commando Jacket")); 
	thePlayer.GetInventory().AddItem(StringToName("Worn Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Worn Hardened Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Reinforced Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Hardened Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Temerian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaardian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Temerian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Kaedwenian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Nilfgaardian Unique Leather Boots")); 
	thePlayer.GetInventory().AddItem(StringToName("Unique Leather Boots of Elder Blood")); 
	thePlayer.GetInventory().AddItem(StringToName("Worn Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Short Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Worn Long Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Long Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Quality Long Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Short Studded Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Long Studded Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Sorccerer Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Elven Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Temerian Unique Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Kaedwenian Unique Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Nilfgaardian Unique Leather Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Unique Leather Gloves of Elder Blood")); 
	thePlayer.GetInventory().AddItem(StringToName("Herbalist Gloves")); 
	thePlayer.GetInventory().AddItem(StringToName("Worn Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Quality Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Studded Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Heavy Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Quality Heavy Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Heavy Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Quality Studded Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Studded Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Temerian Unique Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Temerian Unique Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaardian Unique Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("High Quality Nilfgaardian Unique Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Unique Leather Pants")); 
	thePlayer.GetInventory().AddItem(StringToName("Unique Leather Pants of Elder Blood")); 
	thePlayer.GetInventory().AddItem(StringToName("Unique Essenced Pants"));

}	
exec function AddAlchemy()
{	
	thePlayer.GetInventory().AddItem(StringToName("Candlemakers Potion Real")); 
	thePlayer.GetInventory().AddItem(StringToName("Cat")); 
	thePlayer.GetInventory().AddItem(StringToName("Swallow")); 
	thePlayer.GetInventory().AddItem(StringToName("Tawny Owl")); 
	thePlayer.GetInventory().AddItem(StringToName("Blizzard")); 
	thePlayer.GetInventory().AddItem(StringToName("Kiss")); 
	thePlayer.GetInventory().AddItem(StringToName("Marten"));
	thePlayer.GetInventory().AddItem(StringToName("Maribor Forest"));
	thePlayer.GetInventory().AddItem(StringToName("Shrike"));
	thePlayer.GetInventory().AddItem(StringToName("Golden Oriole"));
	thePlayer.GetInventory().AddItem(StringToName("Wolf")); 
	thePlayer.GetInventory().AddItem(StringToName("Wolverine")); 
	thePlayer.GetInventory().AddItem(StringToName("De Vries Extract")); 
	thePlayer.GetInventory().AddItem(StringToName("White Raffard Decoction")); 
	thePlayer.GetInventory().AddItem(StringToName("Petri Philter")); 
	thePlayer.GetInventory().AddItem(StringToName("Concretion")); 
	thePlayer.GetInventory().AddItem(StringToName("Thunderbolt"));
	thePlayer.GetInventory().AddItem(StringToName("Anabolic"));
	thePlayer.GetInventory().AddItem(StringToName("Shadow"));
	thePlayer.GetInventory().AddItem(StringToName("Unknown Red Potion"));
	thePlayer.GetInventory().AddItem(StringToName("Unknown Green Potion")); 
	thePlayer.GetInventory().AddItem(StringToName("Unknown Yellow Potion")); 
	thePlayer.GetInventory().AddItem(StringToName("Unknown Black Potion")); 
	thePlayer.GetInventory().AddItem(StringToName("Brown Oil")); 
	thePlayer.GetInventory().AddItem(StringToName("Hangman Venom")); 
	thePlayer.GetInventory().AddItem(StringToName("Crinfrid Oil")); 
	thePlayer.GetInventory().AddItem(StringToName("Specter Grease"));
	thePlayer.GetInventory().AddItem(StringToName("Caelm"));
	thePlayer.GetInventory().AddItem(StringToName("Cerbin Blath"));
	thePlayer.GetInventory().AddItem(StringToName("Argentia"));
	thePlayer.GetInventory().AddItem(StringToName("Surge")); 
	thePlayer.GetInventory().AddItem(StringToName("Unique Whetstone")); 
	thePlayer.GetInventory().AddItem(StringToName("Grapeshot")); 
	thePlayer.GetInventory().AddItem(StringToName("Devil Puffball")); 
	thePlayer.GetInventory().AddItem(StringToName("Samum")); 
	thePlayer.GetInventory().AddItem(StringToName("Dancing Star")); 
	thePlayer.GetInventory().AddItem(StringToName("Dragon Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Firefly"));
	thePlayer.GetInventory().AddItem(StringToName("Flare"));
	thePlayer.GetInventory().AddItem(StringToName("Stinker"));
	thePlayer.GetInventory().AddItem(StringToName("Red Haze")); 
	thePlayer.GetInventory().AddItem(StringToName("Explosive Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Crippling Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Freezing Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Rage Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Grappling Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Harpy Bait Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Nekker Stun Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Draug Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Dragon Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Arachas Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Magic Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Arachas Smoke Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Animal Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Used Trap")); 
	thePlayer.GetInventory().AddItem(StringToName("Rotting Meat"));
	thePlayer.GetInventory().AddItem(StringToName("Shiny Trinket"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag Gland Extract"));
	thePlayer.GetInventory().AddItem(StringToName("Phosphorescent Crystal"));
	thePlayer.GetInventory().AddItem(StringToName("Thumper"));
	thePlayer.GetInventory().AddItem(StringToName(""));
}
exec function AddBooks()
{
	thePlayer.GetInventory().AddItem(StringToName("Book of Arachases"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Bruxas"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Bullvore"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Draugirs"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Draugs"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Drowners"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Nekkers"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Rotfiends"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Tentadrakes"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Golems"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Ifrits"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Endriags"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Dragons"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Trolls"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Gargoyles"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Cadavers"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Harpies"));
	thePlayer.GetInventory().AddItem(StringToName("Book of Wraiths"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Temerian Dynasty"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Aelirenn"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Thanned Riot"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Ban Ard"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Sorcerers"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary The Good Book"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Elder Races"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary The White Flame"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Conclave of Mages"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Scoiatael"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Council of Mages"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Vizimian Uprising"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Special Forces"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Melitele"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Magic"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary The Lodge"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Dwarves"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Conjunction of Spheres"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Order of the Flaming Rose"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Witchers"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Vejopatis"));
	thePlayer.GetInventory().AddItem(StringToName("Glossary Dun Banner"));
	thePlayer.GetInventory().AddItem(StringToName("Places Aedirn"));
	thePlayer.GetInventory().AddItem(StringToName("Places Dol Blathanna"));
	thePlayer.GetInventory().AddItem(StringToName("Places Dolina Pontaru"));
	thePlayer.GetInventory().AddItem(StringToName("Places Dolna Marchia"));
	thePlayer.GetInventory().AddItem(StringToName("Places Loc Muinne"));
	thePlayer.GetInventory().AddItem(StringToName("Places Nilfgaard"));
	thePlayer.GetInventory().AddItem(StringToName("Knowledge Alchemy Book"));
	thePlayer.GetInventory().AddItem(StringToName("Knowledge Crafting Book"));
	thePlayer.GetInventory().AddItem(StringToName("Knowledge Herbalism Book"));
	thePlayer.GetInventory().AddItem(StringToName("Orders from Shilard"));
	thePlayer.GetInventory().AddItem(StringToName("q001_orders"));
	thePlayer.GetInventory().AddItem(StringToName("q203_moria_notes_01"));
	thePlayer.GetInventory().AddItem(StringToName("q203_moria_notes_02"));
	thePlayer.GetInventory().AddItem(StringToName("q203_moria_notes_03"));
	thePlayer.GetInventory().AddItem(StringToName("q203_moria_notes_key"));
	thePlayer.GetInventory().AddItem(StringToName("q203_xeranthemum_book"));
	thePlayer.GetInventory().AddItem(StringToName("q207_shilard_letters_01"));
	thePlayer.GetInventory().AddItem(StringToName("q207_shilard_letters_02"));
	thePlayer.GetInventory().AddItem(StringToName("q211_serrit_notes_01"));
	thePlayer.GetInventory().AddItem(StringToName("q304_renuald_letters_01"));
	thePlayer.GetInventory().AddItem(StringToName("sq202_autopsy_book"));
	thePlayer.GetInventory().AddItem(StringToName("sq202_succubus_book"));
	thePlayer.GetInventory().AddItem(StringToName("Ancient Manuscript"));
	thePlayer.GetInventory().AddItem(StringToName("Dandelion's Book of Poetry"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination01"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination02"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination03"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination04"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination05"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_combination06"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_runesbook_tome01"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_runesbook_tome02"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_runesbook_tome03"));
	thePlayer.GetInventory().AddItem(StringToName("sq303_runesbook_tome04"));
	thePlayer.GetInventory().AddItem(StringToName("sq107_dymitr_letter"));
	thePlayer.GetInventory().AddItem(StringToName("sq107_talar_man_letter_01"));
	thePlayer.GetInventory().AddItem(StringToName("sq101_patient_note_01"));
	thePlayer.GetInventory().AddItem(StringToName("sq101_patient_note_02"));
	thePlayer.GetInventory().AddItem(StringToName("sq101_patient_note_03"));
	thePlayer.GetInventory().AddItem(StringToName("sq101_patient_note_04"));
	thePlayer.GetInventory().AddItem(StringToName("q213_chosen_one_notes_01"));
	thePlayer.GetInventory().AddItem(StringToName("q213_chosen_one_notes_02"));
	thePlayer.GetInventory().AddItem(StringToName("q213_chosen_one_notes_03"));
	thePlayer.GetInventory().AddItem(StringToName("q203_mines_level1_map"));
	thePlayer.GetInventory().AddItem(StringToName("q203_mines_level2_map"));
	thePlayer.GetInventory().AddItem(StringToName("q203_mines_level3_map"));
	thePlayer.GetInventory().AddItem(StringToName("arrest warrant"));
	thePlayer.GetInventory().AddItem(StringToName("Detmolds Grimoir"));
}	
exec function AddIngredients()
{	
	thePlayer.GetInventory().AddItem(StringToName("Diamond Dust"));
	thePlayer.GetInventory().AddItem(StringToName("Amethyst Dust"));
	thePlayer.GetInventory().AddItem(StringToName("Cloth"));
	thePlayer.GetInventory().AddItem(StringToName("Quality cloth"));
	thePlayer.GetInventory().AddItem(StringToName("Leather"));
	thePlayer.GetInventory().AddItem(StringToName("Hardened leather"));
	thePlayer.GetInventory().AddItem(StringToName("Studded leather"));
	thePlayer.GetInventory().AddItem(StringToName("Iron ore"));
	thePlayer.GetInventory().AddItem(StringToName("Silver ore"));
	thePlayer.GetInventory().AddItem(StringToName("Dragon scales"));
	thePlayer.GetInventory().AddItem(StringToName("Draug essence"));
	thePlayer.GetInventory().AddItem(StringToName("Wood lumber"));
	thePlayer.GetInventory().AddItem(StringToName("Blue meteorite ore"));
	thePlayer.GetInventory().AddItem(StringToName("Red meteorite ore"));
	thePlayer.GetInventory().AddItem(StringToName("Yellow meteorite ore"));
	thePlayer.GetInventory().AddItem(StringToName("Harphy claws"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake skin"));
	thePlayer.GetInventory().AddItem(StringToName("Crab spider shell"));
	thePlayer.GetInventory().AddItem(StringToName("Troll skin"));
	thePlayer.GetInventory().AddItem(StringToName("Water essence"));
	thePlayer.GetInventory().AddItem(StringToName("Elemental stone"));
	thePlayer.GetInventory().AddItem(StringToName("Harphy feathers"));
	thePlayer.GetInventory().AddItem(StringToName("Gargoyle Heart"));
	thePlayer.GetInventory().AddItem(StringToName("Gargoyle dust"));
	thePlayer.GetInventory().AddItem(StringToName("Necrophage blood"));
	thePlayer.GetInventory().AddItem(StringToName("Necrophage skin"));
	thePlayer.GetInventory().AddItem(StringToName("Death essence"));
	thePlayer.GetInventory().AddItem(StringToName("Piece of Wraith Knight armor"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag skin"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag saliva"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag teeth"));
	thePlayer.GetInventory().AddItem(StringToName("Nekker teeth"));
	thePlayer.GetInventory().AddItem(StringToName("Nekker claws"));
	thePlayer.GetInventory().AddItem(StringToName("Threads"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag embryo"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake eyes"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag venom"));
	thePlayer.GetInventory().AddItem(StringToName("Wraith Knight Claws"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake Tissue"));
	thePlayer.GetInventory().AddItem(StringToName("Crab spider eyes"));
	thePlayer.GetInventory().AddItem(StringToName("Troll tongue"));
	thePlayer.GetInventory().AddItem(StringToName("Harphy saliva"));
	thePlayer.GetInventory().AddItem(StringToName("Harphy eyes"));
	thePlayer.GetInventory().AddItem(StringToName("Necrophage eyes"));
	thePlayer.GetInventory().AddItem(StringToName("Necrophage teeth"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag Mandible"));
	thePlayer.GetInventory().AddItem(StringToName("Nekker Eyes"));
	thePlayer.GetInventory().AddItem(StringToName("Nekker Heart"));
	thePlayer.GetInventory().AddItem(StringToName("Piece of Dwarven Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Oil"));
	thePlayer.GetInventory().AddItem(StringToName("Piece of Draug armor"));
	thePlayer.GetInventory().AddItem(StringToName("Drowner Brain"));
	thePlayer.GetInventory().AddItem(StringToName("Bruxa teeth"));
	thePlayer.GetInventory().AddItem(StringToName("White Myrtle Petals"));
	thePlayer.GetInventory().AddItem(StringToName("Hellebore Petals"));
	thePlayer.GetInventory().AddItem(StringToName("Celandine"));
	thePlayer.GetInventory().AddItem(StringToName("Beggartick Blossoms"));
	thePlayer.GetInventory().AddItem(StringToName("Mandrake Root"));
	thePlayer.GetInventory().AddItem(StringToName("Wolfsbane"));
	thePlayer.GetInventory().AddItem(StringToName("Bryony"));
	thePlayer.GetInventory().AddItem(StringToName("Verbena"));
	thePlayer.GetInventory().AddItem(StringToName("Balisse"));
	thePlayer.GetInventory().AddItem(StringToName("Wolf aloe leaves"));
	thePlayer.GetInventory().AddItem(StringToName("Green mold"));
	thePlayer.GetInventory().AddItem(StringToName(""));
}
exec function AddJunk()
{	
	thePlayer.GetInventory().AddItem(StringToName("Trigger Mechanism"));
	thePlayer.GetInventory().AddItem(StringToName("Iron Frame"));
	thePlayer.GetInventory().AddItem(StringToName("Spyglass"));
	thePlayer.GetInventory().AddItem(StringToName("Wood rope ladder"));
	thePlayer.GetInventory().AddItem(StringToName("Iron rope ladder"));
	thePlayer.GetInventory().AddItem(StringToName("Hatchet"));
	thePlayer.GetInventory().AddItem(StringToName("Hunting horn"));
	thePlayer.GetInventory().AddItem(StringToName("Chandelier"));
	thePlayer.GetInventory().AddItem(StringToName("Silver chandelier"));
	thePlayer.GetInventory().AddItem(StringToName("Rags"));
	thePlayer.GetInventory().AddItem(StringToName("Wire rope"));
	thePlayer.GetInventory().AddItem(StringToName("Grapnel"));
	thePlayer.GetInventory().AddItem(StringToName("Fishing net"));
	thePlayer.GetInventory().AddItem(StringToName("Precious ornament"));
	thePlayer.GetInventory().AddItem(StringToName("Stone medallion"));
	thePlayer.GetInventory().AddItem(StringToName("Shackles"));
	thePlayer.GetInventory().AddItem(StringToName("Pear of anguish"));
	thePlayer.GetInventory().AddItem(StringToName("Strange clamp"));
	thePlayer.GetInventory().AddItem(StringToName("Iron bangle"));
	thePlayer.GetInventory().AddItem(StringToName("Hinges"));
	thePlayer.GetInventory().AddItem(StringToName("Tool blades"));
	thePlayer.GetInventory().AddItem(StringToName("Precious figurine"));
	thePlayer.GetInventory().AddItem(StringToName("Tongs"));
	thePlayer.GetInventory().AddItem(StringToName("Primitive necklace"));
	thePlayer.GetInventory().AddItem(StringToName("Silver necklace"));
	thePlayer.GetInventory().AddItem(StringToName("Enriched silver necklace"));
	thePlayer.GetInventory().AddItem(StringToName("Primitive enriched silver necklace"));
	thePlayer.GetInventory().AddItem(StringToName("Silver ring"));
	thePlayer.GetInventory().AddItem(StringToName("Enriched silver ring"));
	thePlayer.GetInventory().AddItem(StringToName("Enriched iron ring"));
	thePlayer.GetInventory().AddItem(StringToName("Iron ring"));
	thePlayer.GetInventory().AddItem(StringToName("Wire"));
	thePlayer.GetInventory().AddItem(StringToName("Chains"));
	thePlayer.GetInventory().AddItem(StringToName("Sword blade"));
	thePlayer.GetInventory().AddItem(StringToName("Primitive drill"));
	thePlayer.GetInventory().AddItem(StringToName("Sword sheath"));
	thePlayer.GetInventory().AddItem(StringToName("Enriched sword sheath"));
	thePlayer.GetInventory().AddItem(StringToName("Silver sword sheath"));
	thePlayer.GetInventory().AddItem(StringToName("Enriched silver sword sheath"));
	thePlayer.GetInventory().AddItem(StringToName("Kajetan's Talisman"));
	thePlayer.GetInventory().AddItem(StringToName("Heart of Melitele"));
	thePlayer.GetInventory().AddItem(StringToName("Young's Talisman"));
	thePlayer.GetInventory().AddItem(StringToName("Fish"));
	thePlayer.GetInventory().AddItem(StringToName("Apple"));
	thePlayer.GetInventory().AddItem(StringToName("Old cheese"));
	thePlayer.GetInventory().AddItem(StringToName("Potato"));
	thePlayer.GetInventory().AddItem(StringToName("Cucumber"));
	thePlayer.GetInventory().AddItem(StringToName("Plum"));
	thePlayer.GetInventory().AddItem(StringToName("Bread"));
	thePlayer.GetInventory().AddItem(StringToName("Rags"));
	thePlayer.GetInventory().AddItem(StringToName("Cup"));
	thePlayer.GetInventory().AddItem(StringToName("Bowl"));
	thePlayer.GetInventory().AddItem(StringToName("Spoon"));
	thePlayer.GetInventory().AddItem(StringToName("Empty bottle"));
	thePlayer.GetInventory().AddItem(StringToName("Apple juice"));
	thePlayer.GetInventory().AddItem(StringToName("Bottled water"));
	thePlayer.GetInventory().AddItem(StringToName("Cows milk"));
	thePlayer.GetInventory().AddItem(StringToName("Goats milk"));
	thePlayer.GetInventory().AddItem(StringToName("Raspberry juice"));
	thePlayer.GetInventory().AddItem(StringToName("Dried fruit"));
	thePlayer.GetInventory().AddItem(StringToName("Honeycomb"));
	thePlayer.GetInventory().AddItem(StringToName("Chicken leg"));
	thePlayer.GetInventory().AddItem(StringToName("Mutton leg"));
	thePlayer.GetInventory().AddItem(StringToName("Blueberries"));
	thePlayer.GetInventory().AddItem(StringToName("Raspberries"));
	thePlayer.GetInventory().AddItem(StringToName("Pear"));
	thePlayer.GetInventory().AddItem(StringToName("Dried fruit and nuts"));
}
exec function AddUpgrades()
{	
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Amplification"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Amplification"));
	thePlayer.GetInventory().AddItem(StringToName("Major Mutagen of Amplification"));
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Range"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Range"));
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Critical Effect"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Critical Effect"));
	thePlayer.GetInventory().AddItem(StringToName("Major Mutagen of Critical Effect"));
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Vitality"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Vitality"));
	thePlayer.GetInventory().AddItem(StringToName("Major Mutagen of Vitality"));
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Power"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Power"));
	thePlayer.GetInventory().AddItem(StringToName("Major Mutagen of Power"));
	thePlayer.GetInventory().AddItem(StringToName("Minor Mutagen of Strength"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Strength"));
	thePlayer.GetInventory().AddItem(StringToName("Major Mutagen of Strength"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Concentration"));
	thePlayer.GetInventory().AddItem(StringToName("Mutagen of Mutagen of Insanity"));
	thePlayer.GetInventory().AddItem(StringToName("Hardened Fabric Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Mail Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Runic Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Leather Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Hardened Leather Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Reinforced Leather Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Leather Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Studded Leather Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Steel Plate Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Amethyst Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Diamond Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Elanie Bleidd"));
	thePlayer.GetInventory().AddItem(StringToName("Dhu Bleidd"));
	thePlayer.GetInventory().AddItem(StringToName("Quaility Steel Plate Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Vrans Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Dwarven Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Elven Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Mystic Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("kokarda wojsk specjalnych temerii"));
	thePlayer.GetInventory().AddItem(StringToName("kokarda wojsk specjalnych aedirn"));
	thePlayer.GetInventory().AddItem(StringToName("Rune of Sun"));
	thePlayer.GetInventory().AddItem(StringToName("Rune of Ysgith"));
	thePlayer.GetInventory().AddItem(StringToName("Nekkers Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Endriags Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Harpy Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Necrophage Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Bulvore Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Troll Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Drowner Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Tentadrake Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Rotfiend Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Draug Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Wraith Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Wraith Knight TrophyT"));
	thePlayer.GetInventory().AddItem(StringToName("Golem Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Gargoyle Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Elemental Trophy"));
	thePlayer.GetInventory().AddItem(StringToName("Arachas Trophy"));
}
exec function AddQuests()
{	
	thePlayer.GetInventory().AddItem(StringToName("q213_soldier_prayer"));
	thePlayer.GetInventory().AddItem(StringToName("Soldiers Letter"));
	thePlayer.GetInventory().AddItem(StringToName("Candlemaker's Potion"));
	thePlayer.GetInventory().AddItem(StringToName("Candlemakers Bill"));
	thePlayer.GetInventory().AddItem(StringToName("Gone Patient Charter"));
	thePlayer.GetInventory().AddItem(StringToName("Manuscript Wild Gone"));
	thePlayer.GetInventory().AddItem(StringToName("Gone Explorer's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Song of Gone"));
	thePlayer.GetInventory().AddItem(StringToName("q205_thorak_secret_notes"));
	thePlayer.GetInventory().AddItem(StringToName("Priest's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("q107_garwena_notes_01"));
	thePlayer.GetInventory().AddItem(StringToName("Garwena's Letter"));
	thePlayer.GetInventory().AddItem(StringToName("Garwena's Letter 2"));
	thePlayer.GetInventory().AddItem(StringToName("Medical Journal"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimores Map"));
	thePlayer.GetInventory().AddItem(StringToName("Cecils Map"));
	thePlayer.GetInventory().AddItem(StringToName("Medicine for Gridley"));
	thePlayer.GetInventory().AddItem(StringToName("Heart and eyes of murderer"));
	thePlayer.GetInventory().AddItem(StringToName("Heart of nekker"));
	thePlayer.GetInventory().AddItem(StringToName("Eyes of nekker"));
	thePlayer.GetInventory().AddItem(StringToName("Hearts and eyes of ox"));
	thePlayer.GetInventory().AddItem(StringToName("Beaver Grass"));
	thePlayer.GetInventory().AddItem(StringToName("Xeranthemum"));
	thePlayer.GetInventory().AddItem(StringToName("Triss scarf"));
	thePlayer.GetInventory().AddItem(StringToName("Troll horn"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Medalion"));
	thePlayer.GetInventory().AddItem(StringToName("Royal Blood"));
	thePlayer.GetInventory().AddItem(StringToName("Rose of Remembrance"));
	thePlayer.GetInventory().AddItem(StringToName("Dragon's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Sabrina's Spear"));
	thePlayer.GetInventory().AddItem(StringToName("Square Coin"));
	thePlayer.GetInventory().AddItem(StringToName("Relic Nail"));
	thePlayer.GetInventory().AddItem(StringToName("Magic Powder"));
	thePlayer.GetInventory().AddItem(StringToName("Part of Sabrina's Neckless"));
	thePlayer.GetInventory().AddItem(StringToName("Envoy Flag"));
	thePlayer.GetInventory().AddItem(StringToName("Sheala's Protection Amulet"));
	thePlayer.GetInventory().AddItem(StringToName("Armor Part"));
	thePlayer.GetInventory().AddItem(StringToName("Banner"));
	thePlayer.GetInventory().AddItem(StringToName("Commander's Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Medallion"));
	thePlayer.GetInventory().AddItem(StringToName("Strange Liquid"));
	thePlayer.GetInventory().AddItem(StringToName("Mucus Antidote"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Detmold's Cell Key"));
	thePlayer.GetInventory().AddItem(StringToName("Siegfrieds Signet Ring"));
	thePlayer.GetInventory().AddItem(StringToName("Stuffed Troll Head"));
	thePlayer.GetInventory().AddItem(StringToName("Endriag Queen Pheromones"));
	thePlayer.GetInventory().AddItem(StringToName("Elder Nekker Blood"));
	thePlayer.GetInventory().AddItem(StringToName("True recipe"));
	thePlayer.GetInventory().AddItem(StringToName("Fake recipe"));
	thePlayer.GetInventory().AddItem(StringToName("Bullvore Brain"));
	thePlayer.GetInventory().AddItem(StringToName("Harpy Egg"));
	thePlayer.GetInventory().AddItem(StringToName("Rotfiend Tongue"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimores Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Malgets Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Enchanted Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Magical Crystal"));
	thePlayer.GetInventory().AddItem(StringToName("Leto's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Cecils Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Peasant's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimore's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Iorweth's Dream"));
	thePlayer.GetInventory().AddItem(StringToName("Metal fragment"));
	thePlayer.GetInventory().AddItem(StringToName("Cedric's Map"));
	thePlayer.GetInventory().AddItem(StringToName("Pamphlet smearing Henselt"));
	thePlayer.GetInventory().AddItem(StringToName("Surgical tools"));
	thePlayer.GetInventory().AddItem(StringToName("Balista Part"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Filippa's Poison"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Journal"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Report"));
	thePlayer.GetInventory().AddItem(StringToName("Eyla Tarn Captain's Journal"));
	thePlayer.GetInventory().AddItem(StringToName("Loredo's Letter"));
	thePlayer.GetInventory().AddItem(StringToName("Ludwig Merse's Report"));
	thePlayer.GetInventory().AddItem(StringToName("Dun Banner's Cloak"));
	thePlayer.GetInventory().AddItem(StringToName("Beaver's Hat"));
	thePlayer.GetInventory().AddItem(StringToName("Mysterious Tablet"));
	thePlayer.GetInventory().AddItem(StringToName("q207_figurine"));
	thePlayer.GetInventory().AddItem(StringToName("TheBookOfPoisons"));
	thePlayer.GetInventory().AddItem(StringToName("Rusty Keychain"));
	thePlayer.GetInventory().AddItem(StringToName("Rusty Key"));
	thePlayer.GetInventory().AddItem(StringToName("Gate Room Key"));
	thePlayer.GetInventory().AddItem(StringToName("Storage key"));
	thePlayer.GetInventory().AddItem(StringToName("Bandit hideout key"));
	thePlayer.GetInventory().AddItem(StringToName("Upper shaft key"));
	thePlayer.GetInventory().AddItem(StringToName("Ves key"));
	thePlayer.GetInventory().AddItem(StringToName("Middle shaft key"));
	thePlayer.GetInventory().AddItem(StringToName("Lower shaft key"));
	thePlayer.GetInventory().AddItem(StringToName("Tower Key"));
	thePlayer.GetInventory().AddItem(StringToName("Triss Prison Key"));
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaard Camp Key"));
	thePlayer.GetInventory().AddItem(StringToName("Prison Key"));
	thePlayer.GetInventory().AddItem(StringToName("Rune Key"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimore's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Marietta's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Guard's Key"));
	thePlayer.GetInventory().AddItem(StringToName("Secret Passage Key"));
	thePlayer.GetInventory().AddItem(StringToName("Thorak Chest Key"));
	thePlayer.GetInventory().AddItem(StringToName("Old Tower Key"));
	thePlayer.GetInventory().AddItem(StringToName("Cecils Rune Key"));
	thePlayer.GetInventory().AddItem(StringToName("Detmold's Safe Key"));
	thePlayer.GetInventory().AddItem(StringToName("q214_passage_room_key"));
	thePlayer.GetInventory().AddItem(StringToName("Geralt's Cell Door"));
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's key"));
	thePlayer.GetInventory().AddItem(StringToName("Royal Post key"));
	thePlayer.GetInventory().AddItem(StringToName("Hideout key"));
	thePlayer.GetInventory().AddItem(StringToName("Garden key"));
	thePlayer.GetInventory().AddItem(StringToName("Secret Passage Key from Elf"));
}
exec function AddRecipies()
{	
	thePlayer.GetInventory().AddItem(StringToName("Recipe Wolverine"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Marten"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Blizzard"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Maribor Forest"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Golden Oriole"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe De Vries Extract"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe White Raffards Decoction"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Wolf"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Shrike"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Swallow"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Concretion"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Cat"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Kiss"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Tawny Owl"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Thunderbolt"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Petri Philter"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Shadow"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Samum"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Dancing Star"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Dragon Slumber"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Devil Puffball"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Flare"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Stinker"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Firefly"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Grapeshot"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Red Haze"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Caelm"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Cerbin Blath"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Specter Grease"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Argentia"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Brown Oil"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Crinfrid Oil"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Hangman Venom"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Surge"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Oil"));
	thePlayer.GetInventory().AddItem(StringToName("Recipe Amethyst Dust"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Leather Jacket"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Heavy Leather Jacket"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Leather Jacket"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Light Leather Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Heavy Elven Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Ravens Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Tentadrake Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Draug Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Dearg Ruadhri"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Armor of Tir"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Ysgith Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Armor of Ys"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Vran Armor"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Reinforced Leather Boots"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Long Leather Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Long Studded Leather Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Hardened Leather Boots"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Leather Pants"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Studded Leather Pants"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Long Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Heavy Leather Pants"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Unique Leather Pants of Elder Blood"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Unique Leather Boots of Elder Blood"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Unique Leather Gloves of Elder Blood"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Temerian Unique Leather Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Kaedwenian Unique Leather Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Nilfgaardian Unique Leather Gloves"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rune of Sun"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rune of Ysgith"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rune of Earth"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rune of Moon"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rune of Fire"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Amethyst Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Diamond Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Tentadrake Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Endriag Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Mystic Armor Enhancement"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Explosive Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Crippling Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Freezing Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Rage Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Grappling Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Harpy Bait Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Nekker Stun Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Tentadrake Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Dragon Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Arachas Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Draug Trap"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Caingornian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Yspadenian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Temerian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Short Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Hunting Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Jagged Blade"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Dol Blathanna High Quality Steel Blade"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Kaedwenian Quality Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Zerrikan Steel Sabre"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Mahakaman Steel Sihil"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Nilfgaardian Harphy Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Peacemaker"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Negotiator"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic High Quality Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Unique Silver Meteorite Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Caerme"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Ceremonial Steel Sword of Deithwen"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Amethyst Dust"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Diamond Dust"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Quality cloth"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Hardened leather"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Studded leather"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Leather"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Elemental stone"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Oil"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Water essence"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Blue meteorite ore"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Red meteorite ore"));
	thePlayer.GetInventory().AddItem(StringToName("Schematic Yellow meteorite ore"));
}	
exec function AddWeapons()
{	
	thePlayer.GetInventory().AddItem(StringToName("Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Unique Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Witcher Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Fate"));
	thePlayer.GetInventory().AddItem(StringToName("Negotiator"));
	thePlayer.GetInventory().AddItem(StringToName("Harpy"));
	thePlayer.GetInventory().AddItem(StringToName("Naevde Seidhe"));
	thePlayer.GetInventory().AddItem(StringToName("Moonblade"));
	thePlayer.GetInventory().AddItem(StringToName("Blood Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Gvalchca"));
	thePlayer.GetInventory().AddItem(StringToName("Draug Testimony"));
	thePlayer.GetInventory().AddItem(StringToName("Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Gynvael aedd"));
	thePlayer.GetInventory().AddItem(StringToName("Deithwen"));
	thePlayer.GetInventory().AddItem(StringToName("Addan deith"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Blue Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Red Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Yellow Meteorite Silver Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Unique Silver Meteorite Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Rusty Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Short Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Elven Sword of Blue Mountains"));
	thePlayer.GetInventory().AddItem(StringToName("Long Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Creydenian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Short Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Rusty Nilfgaardian Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Hunting Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Long Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Temerian Elite Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Hunting Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Temerian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Short Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Caingornian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Yspadenian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Long Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Hunting Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Jagged Blade"));
	thePlayer.GetInventory().AddItem(StringToName("Aedirnian Short Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Aedirnian Light Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Aedirnian Red Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Temerian Essenced Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Angivare"));
	thePlayer.GetInventory().AddItem(StringToName("Deireadh"));
	thePlayer.GetInventory().AddItem(StringToName("Arena Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Black Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Stennis Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Gwyhyr"));
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Kaedwenian Quality Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Peacemaker"));
	thePlayer.GetInventory().AddItem(StringToName("Dol Blathanna Quality Steel Blade"));
	thePlayer.GetInventory().AddItem(StringToName("Dol Blathanna High Quality Steel Blade"));
	thePlayer.GetInventory().AddItem(StringToName("Zerrikan Steel Sabre"));
	thePlayer.GetInventory().AddItem(StringToName("Zerrikan Poisoned Steel Sabre"));
	thePlayer.GetInventory().AddItem(StringToName("Dun Banner Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Mahakaman Steel Sihil"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Dueling Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Dueling Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Elven Short Sihil"));
	thePlayer.GetInventory().AddItem(StringToName("Elven Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaardian Steel Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaardian Harphy Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Nilfgaardian Essenced Sword"));
	thePlayer.GetInventory().AddItem(StringToName("Harvall"));
	thePlayer.GetInventory().AddItem(StringToName("Forgotten Sword of Vrans"));
	thePlayer.GetInventory().AddItem(StringToName("Ceremonial Steel Sword of Deithwen"));
	thePlayer.GetInventory().AddItem(StringToName("Caerme"));
	thePlayer.GetInventory().AddItem(StringToName("ImportedMahakamRuneSihil"));
	thePlayer.GetInventory().AddItem(StringToName("Gwalhir"));
	thePlayer.GetInventory().AddItem(StringToName("Dyaebl"));
	thePlayer.GetInventory().AddItem(StringToName("Ardaenye"));
	thePlayer.GetInventory().AddItem(StringToName("Witcher_Halberd"));
	thePlayer.GetInventory().AddItem(StringToName("W_StennisSwd"));
	thePlayer.GetInventory().AddItem(StringToName("W_Axe01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Axe02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Club01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Club02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Club03"));
	thePlayer.GetInventory().AddItem(StringToName("W_AxeDwarf01"));
	thePlayer.GetInventory().AddItem(StringToName("W_HammerDwarf01"));
	thePlayer.GetInventory().AddItem(StringToName("W_ElvenMesser01"));
	thePlayer.GetInventory().AddItem(StringToName("W_ElvenSword01"));
	thePlayer.GetInventory().AddItem(StringToName("W_ElvenSword02"));
	thePlayer.GetInventory().AddItem(StringToName("W_ExecRod"));
	thePlayer.GetInventory().AddItem(StringToName("W_ExecSword"));
	thePlayer.GetInventory().AddItem(StringToName("W_Halberd01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Halberd02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Hammer01"));
	thePlayer.GetInventory().AddItem(StringToName("W_HenseltSword01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Messer01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Messer02"));
	thePlayer.GetInventory().AddItem(StringToName("W_NilfgaardSword01"));
	thePlayer.GetInventory().AddItem(StringToName("W_RustyDagger01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Sabre01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Sabre02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Staff01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Staff02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Staff03"));
	thePlayer.GetInventory().AddItem(StringToName("W_Sword01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Sword02"));
	thePlayer.GetInventory().AddItem(StringToName("W_Sword03"));
	thePlayer.GetInventory().AddItem(StringToName("W_TwoHander01"));
	thePlayer.GetInventory().AddItem(StringToName("W_WraithSword01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Paddle01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Rake01"));
	thePlayer.GetInventory().AddItem(StringToName("W_SuccubusStaff01"));
	thePlayer.GetInventory().AddItem(StringToName("W_PickAxe01"));
	thePlayer.GetInventory().AddItem(StringToName("W_PickAxe02"));
	thePlayer.GetInventory().AddItem(StringToName("W_DeathmoldStaff"));
	thePlayer.GetInventory().AddItem(StringToName("W_Ladle01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Shovel01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Broom01"));
	thePlayer.GetInventory().AddItem(StringToName("W_Pale01"));
	thePlayer.GetInventory().AddItem(StringToName("Fishing Rod"));
	thePlayer.GetInventory().AddItem(StringToName("Rusty Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Sting"));
	thePlayer.GetInventory().AddItem(StringToName("Poisoned flying harphy claws"));
}	
exec function Vit()
{
	var deathData : SActorDeathData;
	thePlayer.SetHealth(thePlayer.GetInitialHealth(), false, NULL, deathData);
}
class TempSpawner extends CStateMachine
{
	
}
state Spawning in TempSpawner
{
	var tmpl1, tmpl2, tmpl3, tmpl4 : CEntityTemplate;
	var pos, camDirection : Vector;
	var rot : EulerAngles;
	var npc : CNewNPC;
	
	entry function SpawnCreatures(type : string)
	{
	
		camDirection = theCamera.GetCameraDirection();
		camDirection.Z = 0;
		camDirection = VecNormalize(camDirection);
		pos = thePlayer.GetWorldPosition() + 15.0*camDirection;
		theGame.FindEmptyArea(5.0, 1.0, '', pos, pos);
		rot = thePlayer.GetWorldRotation();
		
		if(type == "b")
		{
			tmpl1 = (CEntityTemplate)LoadResource("bandit");
			//tmpl2 = (CEntityTemplate)LoadResource("bandit_strong");
			theGame.CreateEntity(tmpl1, pos, rot);
			//theGame.CreateEntity(tmpl1, pos, rot);
			//theGame.CreateEntity(tmpl1, pos, rot);
			//theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "r")
		{
			tmpl1 = (CEntityTemplate)LoadResource("rotfiend");
			tmpl2 = (CEntityTemplate)LoadResource("rotfiend_strong");
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "n")
		{
			tmpl1 = (CEntityTemplate)LoadResource("nekker");
			tmpl2 = (CEntityTemplate)LoadResource("nekker_strong");
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "h")
		{
			tmpl1 = (CEntityTemplate)LoadResource("harpy");
			tmpl2 = (CEntityTemplate)LoadResource("harpy_strong");
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "d")
		{
			tmpl1 = (CEntityTemplate)LoadResource("drowner");
			tmpl2 = (CEntityTemplate)LoadResource("drowner_strong");
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "s")
		{
			tmpl1 = (CEntityTemplate)LoadResource("scoia");
			tmpl2 = (CEntityTemplate)LoadResource("scoia_dual");
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl1, pos, rot);
			theGame.CreateEntity(tmpl2, pos, rot);
		}
		if(type == "bh")
		{
			tmpl1 = (CEntityTemplate)LoadResource("bounty");
			tmpl2 = (CEntityTemplate)LoadResource("bounty_leader");
			tmpl3 = (CEntityTemplate)LoadResource("bounty_2h");
			npc = (CNewNPC)theGame.CreateEntity(tmpl1, pos, rot);
			npc.SetAttitude(thePlayer, AIA_Hostile);
			npc = (CNewNPC)theGame.CreateEntity(tmpl1, pos, rot);
			npc.SetAttitude(thePlayer, AIA_Hostile);
			npc = (CNewNPC)theGame.CreateEntity(tmpl2, pos, rot);
			npc.SetAttitude(thePlayer, AIA_Hostile);
			npc = (CNewNPC)theGame.CreateEntity(tmpl3, pos, rot);
			npc.SetAttitude(thePlayer, AIA_Hostile);
		}
	}
}
exec function Sp(type : string)
{
	
	var spawner : TempSpawner;
	spawner = new TempSpawner in theGame;
	if(type == "")
	{
		theHud.m_messages.ShowInformationText("Sp(typ, true/false), gdzie typ to: b, r, n, h, d, s albo bh");
	}
	else
	{
		spawner.SpawnCreatures(type);
	}
	
	
}
exec function AddDag()
{
	var itemName : string;
	itemName = "Filippa's Dagger";
	thePlayer.GetInventory().AddItem( StringToName( itemName ) ); 
}

exec function JT()
{
	thePlayer.AddJournalEntry(JournalGroup_Alchemy, "Journal Test", "Journal Test 0", "Crafting");
	thePlayer.GetInventory().AddItem('Recipe TestSwd', 1);

}
exec function addexp( i : int )
{
	thePlayer.IncreaseExp( i );
}
exec function A1Boss()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Temerian Elite Sword', 1);
	thePlayer.GetInventory().AddItem('Quality Witcher Silver Sword', 1);
	thePlayer.GetInventory().AddItem('Grapeshot', 4);
	thePlayer.GetInventory().AddItem('Tawny Owl', 2);
	thePlayer.GetInventory().AddItem('Maribor Forest', 2);
	thePlayer.GetInventory().AddItem('Wolf', 2);
	thePlayer.GetInventory().AddItem('Light Chainmail Shirt', 1);
	
	for (i = 0; i < 12; i += 1)
	{
		thePlayer.IncreaseExp( 1001);

	}
}
exec function A1()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Long Steel Sword', 1);
	thePlayer.GetInventory().AddItem('Heavy Leather Jacket', 1);
	
	for (i = 0; i < 6; i += 1)
	{
		thePlayer.IncreaseExp( 1001);
	}
}
exec function A2()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Aedirnian Light Sword', 1);
	thePlayer.GetInventory().AddItem('Negotiator', 1);
	thePlayer.GetInventory().AddItem('Kaedwenian Leather Jacket', 1);
	
	for (i = 0; i < 16; i += 1)
	{
		thePlayer.IncreaseExp( 1001);
	}
}
exec function A2Boss()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Kaedwenian Black Sword', 1);
	thePlayer.GetInventory().AddItem('Blood Sword', 1);
	thePlayer.GetInventory().AddItem('Armor of Loc Muinne', 1);
	thePlayer.GetInventory().AddItem('Grapeshot', 4);
	thePlayer.GetInventory().AddItem('Tawny Owl', 2);
	thePlayer.GetInventory().AddItem('Maribor Forest', 2);
	thePlayer.GetInventory().AddItem('Wolf', 2);
	
	for (i = 0; i < 26; i += 1)
	{
		thePlayer.IncreaseExp( 1001);

	}
}
exec function A3Boss()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Harvall', 1);
	thePlayer.GetInventory().AddItem('Deithwen', 1);
	thePlayer.GetInventory().AddItem('Cahir Armor', 1);
	thePlayer.GetInventory().AddItem('Grapeshot', 4);
	thePlayer.GetInventory().AddItem('Tawny Owl', 2);
	thePlayer.GetInventory().AddItem('Maribor Forest', 2);
	thePlayer.GetInventory().AddItem('Wolf', 2);
	
	for (i = 0; i < 32; i += 1)
	{
		thePlayer.IncreaseExp( 1001);

	}
}
exec function A3()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Elven Short Sihil', 1);
	thePlayer.GetInventory().AddItem('Gynvael aedd', 1);
	thePlayer.GetInventory().AddItem('Dearg Ruadhri', 1);
	
	for (i = 0; i < 29; i += 1)
	{
		thePlayer.IncreaseExp( 1001);

	}
}
exec function A1I()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Long Steel Sword', 1);
	thePlayer.GetInventory().AddItem('Heavy Leather Jacket', 1);
}
exec function A2I()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Aedirnian Light Sword', 1);
	thePlayer.GetInventory().AddItem('Negotiator', 1);
	thePlayer.GetInventory().AddItem('Kaedwenian Leather Jacket', 1);
	
}
exec function A2BossI()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Kaedwenian Black Sword', 1);
	thePlayer.GetInventory().AddItem('Blood Sword', 1);
	thePlayer.GetInventory().AddItem('Armor of Loc Muinne', 1);
	thePlayer.GetInventory().AddItem('Grapeshot', 4);
	thePlayer.GetInventory().AddItem('Tawny Owl', 2);
	thePlayer.GetInventory().AddItem('Maribor Forest', 2);
	thePlayer.GetInventory().AddItem('Wolf', 2);
	
}
exec function A3BossI()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Harvall', 1);
	thePlayer.GetInventory().AddItem('Deithwen', 1);
	thePlayer.GetInventory().AddItem('Cahir Armor', 1);
	thePlayer.GetInventory().AddItem('Grapeshot', 4);
	thePlayer.GetInventory().AddItem('Tawny Owl', 2);
	thePlayer.GetInventory().AddItem('Maribor Forest', 2);
	thePlayer.GetInventory().AddItem('Wolf', 2);
}
exec function A3I()
{
	var i : int;
	
	thePlayer.GetInventory().AddItem('Elven Short Sihil', 1);
	thePlayer.GetInventory().AddItem('Gynvael aedd', 1);
	thePlayer.GetInventory().AddItem('Dearg Ruadhri', 1);
}

exec function Rag()
{
	var actor : CActor;
	
	actor = theGame.GetActorByTag('drown');
	actor.SetRagdoll(true);
}
exec function IEE(encounterTag : name)
{
	var encounter : CEncounter;
	encounter = (CEncounter)theGame.GetNodeByTag(encounterTag);
	
	Log("Encounter is enabled "+encounter.IsEnabled());
}
exec function EE( encounterTag : name, enable : bool ) : bool
{
	var request : CEncounterStateRequest;
	request = new CEncounterStateRequest in theGame;
	request.enable = enable;
	
	theGame.AddStateChangeRequest( encounterTag, request );
	 
	return true;
}
exec function EnableComp(entityTag : name, enable : bool)
{
	var entity : CEntity;
	var component : CTriggerAreaComponent;
	entity = theGame.GetEntityByTag(entityTag);
	component = (CTriggerAreaComponent)entity.GetComponentByClassName('CTriggerAreaComponent');
	component.SetEnabled(enable);
}
exec function Gender()
{
	var actors : array<CActor>;
	var size, i : int;
	
	GetActorsInRange(actors, 30.0, '', thePlayer);
	size = actors.Size();
	for(i = 0; i < size; i += 1)
	{
		if(actors[i].IsWoman())
		{
			Log("actor["+i+"] jest kobieta");
		}
		if(actors[i].IsDwarf())
		{
			Log("actor["+i+"] jest krasnoludem");
		}
	}
}
exec function Hide()
{
	var actors : array<CActor>;
	var size, i : int;
	
	GetActorsInRange(actors, 30.0, '', thePlayer);
	size = actors.Size();
	for(i = 0; i < size; i += 1)
	{
		actors[i].SetHideInGame(true);
	}
}
exec function Show()
{
	var actors : array<CActor>;
	var size, i : int;
	
	GetActorsInRange(actors, 30.0, '', thePlayer);
	size = actors.Size();
	for(i = 0; i < size; i += 1)
	{
		actors[i].SetHideInGame(false);
	}
}
exec function Despawn()
{
	var actors : array<CActor>;
	var size, i : int;
	var npc : CNewNPC;
	
	GetActorsInRange(actors, 30.0, '', thePlayer);
	size = actors.Size();
	for(i = 0; i < size; i += 1)
	{
		npc = (CNewNPC)actors[i];
		npc.GetArbitrator().AddGoalDespawn(false, false, false, npc.GetWorldPosition());
	}
}
exec function ANpc(tag : name)
{
	var abilities : array<name>;
	var i, size : int;
	var actor : CActor;
	actor = theGame.GetActorByTag(tag);
	if(actor)
	{
		actor.GetCharacterStats().GetAbilities(abilities);
		size = abilities.Size();
		for(i = 0; i < size; i += 1)
		{
			Log(abilities[i]);
		}
	}
}
exec function H()
{
	Log("Health "+thePlayer.GetHealth());
}

quest function HackAddItemToPlayer(itemName : name)
{
	thePlayer.GetInventory().AddItem(itemName, 1);
}
exec function SecW()
{
	thePlayer.GetInventory().AddItem('W_StennisSwd', 1);
	thePlayer.GetInventory().AddItem('W_Axe01', 1);
	thePlayer.GetInventory().AddItem('W_Axe02', 1);
	thePlayer.GetInventory().AddItem('W_Club01', 1);
	thePlayer.GetInventory().AddItem('W_Club02', 1);
	thePlayer.GetInventory().AddItem('W_Club03', 1);
	thePlayer.GetInventory().AddItem('W_AxeDwarf01', 1);
	thePlayer.GetInventory().AddItem('W_HammerDwarf01', 1);
	thePlayer.GetInventory().AddItem('W_ElvenMesser01', 1);
	thePlayer.GetInventory().AddItem('W_ElvenSword01', 1);
	thePlayer.GetInventory().AddItem('W_ElvenSword02', 1);
	thePlayer.GetInventory().AddItem('W_ExecRod', 1);
	thePlayer.GetInventory().AddItem('W_ExecSword', 1);
	thePlayer.GetInventory().AddItem('W_Halberd01', 1);
	thePlayer.GetInventory().AddItem('W_Halberd02', 1);
	thePlayer.GetInventory().AddItem('W_Hammer01', 1);
	thePlayer.GetInventory().AddItem('W_HenseltSword01', 1);
	thePlayer.GetInventory().AddItem('W_Messer01', 1);
	thePlayer.GetInventory().AddItem('W_Messer02', 1);
	thePlayer.GetInventory().AddItem('W_NilfgaardSword01', 1);
	thePlayer.GetInventory().AddItem('W_RustyDagger01', 1);
	thePlayer.GetInventory().AddItem('W_Sabre01', 1);
	thePlayer.GetInventory().AddItem('W_Sabre02', 1);
	thePlayer.GetInventory().AddItem('W_Staff01', 1);
	thePlayer.GetInventory().AddItem('W_Staff02', 1);
	thePlayer.GetInventory().AddItem('W_Staff03', 1);
	thePlayer.GetInventory().AddItem('W_Sword01', 1);
	thePlayer.GetInventory().AddItem('W_Sword02', 1);
	thePlayer.GetInventory().AddItem('W_Sword03', 1);
	thePlayer.GetInventory().AddItem('W_TwoHander01', 1);
	thePlayer.GetInventory().AddItem('W_WraithSword01', 1);
	thePlayer.GetInventory().AddItem('W_Paddle01', 1);
	thePlayer.GetInventory().AddItem('W_Rake01', 1);
	thePlayer.GetInventory().AddItem('W_SuccubusStaff01', 1);
	thePlayer.GetInventory().AddItem('W_PickAxe01', 1);
	thePlayer.GetInventory().AddItem('W_PickAxe02', 1);
	thePlayer.GetInventory().AddItem('W_DeathmoldStaff', 1);
	thePlayer.GetInventory().AddItem('W_Ladle01', 1);
	thePlayer.GetInventory().AddItem('W_Shovel01', 1);
	thePlayer.GetInventory().AddItem('W_Broom01', 1);
	thePlayer.GetInventory().AddItem('W_Pale01', 1);
	thePlayer.GetInventory().AddItem('Fishing Rod', 1);	
}
exec function Bleed()
{
	var actors : array<CActor>;
	var i, size : int;
	
	GetActorsInRange(actors, 50.0, '', thePlayer);
	size = actors.Size();
	for(i = 0; i < size; i += 1)
	{
		if(actors[i] != thePlayer)
		{
			actors[i].ApplyCriticalEffect(CET_Bleed, thePlayer, 10.0);
		}
	}
}
quest function TempDemoStats()
{
	var i : int;
	for (i = 0; i < 33; i += 1 )
	{	
		
		if ( i < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( i >= 6 && i < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( i > 8 && i < 22 )
		{
			
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-8) ) );
		}
		else if ( i >= 24 && i < 33 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-23) + "_2" ) );
		}
		
	}
}
class W2BalanceCalc
{
	var abilities : array<name>;
	var petards : array<SItemUniqueId>;
	var cost : float;
	var statVitality, 
	statEndurance,
	statEnduranceRegenCombat,
	statEnduranceRegenNonCombat,
	statArmor, 
	statVitalityRegenCombat,
	statVitalityRegenNonCombat,  
	statDamage, 
	statAardDamage, 
	statIgniDamage, 
	statYrdenDamage, 
	statQuenDamage,
	statAardKnockChance, 
	statBleedChance,
	statPoisonChance,
	statIgniBurnChance, 
	statYrdenTime,
	statYrdenTraps,
	statIgniBurnTime, 
	statQuenTime,
	statResBleed,
	statResBurn,
	statResPoison,
	statResKnockdown,
	statResStun,
	statResAard,
	statResIgni,
	statResAxii,
	statResYrden,
	statResQuen,
	statAdrenalineGeneration,
	statMaxAxiiTargets,
	statMaxQuenTargets,
	statDaggerThrow,
	statHeliotrope,
	statDamagePetards,
	statDamageTraps,
	statPotionsTimeBonus,
	statOilsTimeBonus,
	statAdditionalPotion,
	statInstantKill,
	statBerserk,
	statBackDamageBonus,
	statRiposte,
	statDodgeRange,
	statBlockEnduranceCost,
	statGroupAttacks,
	statGroupFinishers,
	statNumPetards,
	statDamageRanged, //ranged_damage_min, ranged_damage_max
	statShotAccuracy, //shot_accuracy
	statIsAMage, 
	statLevel: float;
	
	var costVitality, 
	costEndurance,
	costEnduranceRegenCombat,
	costEnduranceRegenNonCombat,
	costArmor, 
	costVitalityRegenCombat,
	costVitalityRegenNonCombat,  
	costDamage, 
	costAardDamage, 
	costIgniDamage, 
	costYrdenDamage, 
	costQuenDamage,
	costAardKnockChance, 
	costBleedChance,
	costPoisonChance,
	costIgniBurnChance, 
	costYrdenTime,
	costYrdenTraps,
	costIgniBurnTime, 
	costQuenTime,
	costResBleed,
	costResBurn,
	costResPoison,
	costResKnockdown,
	costResStun,
	costResAard,
	costResIgni,
	costResAxii,
	costResYrden,
	costResQuen,
	costAdrenalineGeneration,
	costMaxAxiiTargets,
	costMaxQuenTargets,
	costDaggerThrow,
	costHeliotrope,
	costDamagePetards,
	costDamageTraps,
	costPotionsTimeBonus,
	costOilsTimeBonus,
	costAdditionalPotion,
	costInstantKill,
	costBerserk,
	costBackDamageBonus,
	costRiposte,
	costDodgeRange,
	costBlockEnduranceCost,
	costGroupAttacks,
	costGroupFinishers,
	costNumPetards,
	costDamageRanged,
	costShotAccuracy,
	costIsAMage,
	costLevel: float;
	var costconstVitality, 
	costconstEndurance,
	costconstEnduranceRegenCombat,
	costconstEnduranceRegenNonCombat,
	costconstArmor, 
	costconstVitalityRegenCombat,
	costconstVitalityRegenNonCombat,  
	costconstDamage, 
	costconstAardDamage, 
	costconstIgniDamage, 
	costconstYrdenDamage, 
	costconstQuenDamage,
	costconstAardKnockChance, 
	costconstBleedChance,
	costconstPoisonChance,
	costconstIgniBurnChance, 
	costconstYrdenTime,
	costconstYrdenTraps,
	costconstIgniBurnTime, 
	costconstQuenTime,
	costconstResBleed,
	costconstResBurn,
	costconstResPoison,
	costconstResKnockdown,
	costconstResStun,
	costconstResAard,
	costconstResIgni,
	costconstResAxii,
	costconstResYrden,
	costconstResQuen,
	costconstAdrenalineGeneration,
	costconstMaxAxiiTargets,
	costconstMaxQuenTargets,
	costconstDaggerThrow,
	costconstHeliotrope,
	costconstDamagePetards,
	costconstDamageTraps,
	costconstPotionsTimeBonus,
	costconstOilsTimeBonus,
	costconstAdditionalPotion,
	costconstInstantKill,
	costconstBerserk,
	costconstBackDamageBonus,
	costconstRiposte,
	costconstDodgeRange,
	costconstBlockEndurance,
	costconstGroupAttacks,
	costconstGroupFinishers,
	costconstNumPetards,
	costconstDamageRanged,
	costconstShotAccuracy,
	costconstIsAMage,
	costconstLevel : float;
	var stats : CCharacterStats;
	function SetActorStats(actor : CActor)
	{
		var npc : CNewNPC;
		npc = (CNewNPC)actor;
		stats = actor.GetCharacterStats();
		statVitality = stats.GetFinalAttribute('vitality');
		statVitalityRegenCombat = stats.GetFinalAttribute('vitality_regen');
		statArmor = stats.GetFinalAttribute('damage_reduction');
		statDamage = (stats.GetFinalAttribute('damage_min') + stats.GetFinalAttribute('damage_max'))/2;
		statDamageRanged = (stats.GetFinalAttribute('ranged_damage_min') + stats.GetFinalAttribute('ranged_damage_max'))/2;
		statShotAccuracy = stats.GetFinalAttribute('shot_accuracy');
		if(npc && npc.GetCurrentCombatType() == CT_Mage)
		{
			statIsAMage = 1;
		}
		else
		{
			statIsAMage = 0;
		}
		actor.GetCharacterStats().GetAbilities(abilities);
		statResBleed = stats.GetFinalAttribute('res_bleed');
		statResBurn = stats.GetFinalAttribute('res_burn');
		statResPoison = stats.GetFinalAttribute('res_poison');
		statResKnockdown = stats.GetFinalAttribute('res_knockdown');
		statResStun = stats.GetFinalAttribute('res_stun');
		statResAard = stats.GetFinalAttribute('res_aard');
		statResIgni = stats.GetFinalAttribute('res_igni');
		statResAxii = stats.GetFinalAttribute('res_axii');
		statResYrden = stats.GetFinalAttribute('res_yrden');
		statResQuen = stats.GetFinalAttribute('res_quen');
		statBleedChance = stats.GetFinalAttribute('crt_bleed');
		statPoisonChance = stats.GetFinalAttribute('crt_poison');
		statLevel = (float)actor.GetLevel();
		
	}
	function PrintActorStats(actor : CActor)
	{
		var i, size : int;
		SetCosts();
		SetActorStats(actor);
		CalculateActorCost();
		Log("------------ Actor: "+actor.GetDisplayName()+" stats START -------------");
		Log(actor);
		Log("Vitality " + statVitality + " Cost " + costVitality);
		Log("VitalityRegen " + statVitalityRegenCombat + " Cost " + costVitalityRegenCombat);
		Log("Armor " + statArmor + " Cost " + costArmor);
		Log("Damage " + statDamage + " Cost " + costDamage);
		Log("DamageRanged " + statDamageRanged + " Cost " + costDamageRanged);
		Log("ShotAcuuracy " + statShotAccuracy + " Cost " + costShotAccuracy);
		Log("IsMage " + statIsAMage + " Cost " + costIsAMage);
		Log("BleedChance " + statBleedChance + " Cost " + costBleedChance);
		Log("PoisonChance " + statPoisonChance + " Cost " + costPoisonChance);
		Log("BleedResistance " + statResBleed + " Cost " + costResBleed);
		Log("BurnResistance " + statResBurn + " Cost " + costResBurn);
		Log("PoisonResistance " + statResPoison + " Cost " + costResPoison);
		Log("KnockdownResistance " + statResKnockdown + " Cost " + costResKnockdown);
		Log("StunResistance " + statResStun + " Cost " + costResStun);
		Log("AardResistance " + statResAard + " Cost " + costResAard);
		Log("IgniResistance " + statResIgni + " Cost " + costResIgni);
		Log("AxiiResistance " + statResAxii + " Cost " + costResAxii);
		Log("YrdenResistance " + statResYrden + " Cost " + costResYrden);
		Log("QuenResistance " + statResQuen + " Cost " + costResQuen);
		Log("Level " + statLevel + " Cost " + costLevel);
		Log("TotalCost " + cost);
		Log("Abilities: ");
		for(i=0; i<abilities.Size(); i += 1)
		{
			Log(abilities[i]);
		}
		Log("------------ Actor: "+actor.GetDisplayName()+" stats END ---------------");
	}
	function CalculateActorCost()
	{
		costVitality  = statVitality  * costconstVitality;
		costArmor  = statArmor  * costconstArmor;
		costVitalityRegenCombat = statVitalityRegenCombat * costconstVitalityRegenCombat;
		costDamage  = statDamage  * costconstDamage;
		costBleedChance = statBleedChance * costconstBleedChance;
		costPoisonChance = statPoisonChance * costconstPoisonChance;
		costResBleed = statResBleed * costconstResBleed;
		costResBurn = statResBurn * costconstResBurn;
		costResPoison = statResPoison * costconstResPoison;
		costResKnockdown = statResKnockdown * costconstResKnockdown;
		costResStun = statResStun * costconstResStun;
		costResAard = statResAard * costconstResAard;
		costResIgni = statResIgni * costconstResIgni;
		costResAxii = statResAxii * costconstResAxii;
		costResYrden = statResYrden * costconstResYrden;
		costResQuen = statResQuen * costconstResQuen;
		costLevel = statLevel * costconstLevel;
		costDamageRanged = statDamageRanged * costconstDamageRanged;
		costShotAccuracy = statShotAccuracy * costconstShotAccuracy;
		costIsAMage = statIsAMage * costconstIsAMage;
		cost = 		costVitality+ 
					costArmor +
					costVitalityRegenCombat +
					costDamage +
					costBleedChance +
					costPoisonChance +
					costResBleed+
					costResBurn +
					costResPoison+
					costResKnockdown +
					costResStun +
					costResAard+
					costResIgni +
					costResAxii+
					costResYrden +
					costResQuen+
					costIsAMage+
					costShotAccuracy+
					costDamageRanged+
					costLevel;
	}
	function SetPlayerStats()
	{
		stats = thePlayer.GetCharacterStats();
		//Stats
		statVitality = stats.GetFinalAttribute('vitality');
		statEndurance = stats.GetFinalAttribute('endurance');
		statEnduranceRegenCombat = stats.GetFinalAttribute('endurance_combat_regen');
		statEnduranceRegenNonCombat = stats.GetFinalAttribute('endurance_noncombat_regen');
		if(thePlayer.GetToxicity() > 1.0)
		{
			statEnduranceRegenCombat = statEnduranceRegenCombat*stats.GetFinalAttribute('endurance_regen_toxbonus');
			statEnduranceRegenNonCombat = statEnduranceRegenCombat*stats.GetFinalAttribute('endurance_regen_toxbonus');
		}
		statArmor = stats.GetFinalAttribute('damage_reduction');
		if(thePlayer.GetToxicity() > 1.0)
			statArmor = statDamage * thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction_toxbonus');
		statVitalityRegenCombat = stats.GetFinalAttribute('vitality_combat_regen');
		statVitalityRegenNonCombat = stats.GetFinalAttribute('vitality_regen');
		statDamage = (stats.GetFinalAttribute('damage_min')+stats.GetFinalAttribute('damage_max'))/2;
		if(thePlayer.GetToxicity() > 1.0)
			statDamage = statDamage * thePlayer.GetCharacterStats().GetFinalAttribute('damage_toxbonus');
		statAardDamage = ( ( stats.GetFinalAttribute('aard_damage') * thePlayer.GetSignsPowerBonus(SPBT_Damage) ) + stats.GetFinalAttribute('damage_signsbonus') );
		statIgniDamage = ( ( stats.GetFinalAttribute('igni_damage') * thePlayer.GetSignsPowerBonus(SPBT_Damage) ) + stats.GetFinalAttribute('damage_signsbonus') );
		statYrdenDamage = ( ( stats.GetFinalAttribute('yrden_damage_per_sec')*stats.GetFinalAttribute('yrden_immobile_time') * thePlayer.GetSignsPowerBonus(SPBT_Time)* thePlayer.GetSignsPowerBonus(SPBT_Damage) ) + stats.GetFinalAttribute('damage_signsbonus') );
		statQuenDamage = ( ( stats.GetFinalAttribute('quen_bolt_damage') * thePlayer.GetSignsPowerBonus(SPBT_Damage) ) + stats.GetFinalAttribute('damage_signsbonus') );
		statAardKnockChance = stats.GetFinalAttribute('aard_knockdown_chance');
		statBleedChance = stats.GetFinalAttribute('crt_bleed');
		statPoisonChance = stats.GetFinalAttribute('crt_poison');
		statIgniBurnChance = stats.GetFinalAttribute('igni_burn_chance');
		statYrdenTime = stats.GetFinalAttribute('yrden_trap_duration')*thePlayer.GetSignsPowerBonus(SPBT_Time);
		statYrdenTraps = stats.GetFinalAttribute('yrden_max_concurrent_traps');
		statIgniBurnTime = stats.GetFinalAttribute('igni_burn_duration')*thePlayer.GetSignsPowerBonus(SPBT_Time);
		statQuenTime = stats.GetFinalAttribute( 'quen_duration' )*thePlayer.GetSignsPowerBonus(SPBT_Time);
		statResBleed = stats.GetFinalAttribute( 'res_bleed' );
		statResBurn = stats.GetFinalAttribute( 'res_burn' );
		statResPoison = stats.GetFinalAttribute( 'res_poison' );
		if(thePlayer.GetCharacterStats().HasAbility('magic_s7_2'))
		{
			statMaxAxiiTargets = 3;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s7'))
		{
			statMaxAxiiTargets = 2;
		}
		else
		{
			statMaxAxiiTargets = 1;
		}
		if(stats.HasAbility('magic_s6_2'))
		{
			statMaxQuenTargets = 3;
		}
		else if(stats.HasAbility('magic_s6'))
		{
			statMaxQuenTargets = 2;
		}
		else
		{
			statMaxQuenTargets = 1;
		}
		if(thePlayer.GetCharacterStats().HasAbility('training_s4'))
		{
			statDaggerThrow = 1;
		}
		else
		{
			statDaggerThrow = 0;
		}
		if(thePlayer.GetCharacterStats().HasAbility('magic_s14'))
		{
			statHeliotrope = 1;
		}
		else
		{
			statHeliotrope = 0;
		}
		statDamagePetards = stats.GetFinalAttribute( 'petards_damage_mult' );
		statDamageTraps = stats.GetFinalAttribute( 'traps_damage_mult' );
		statPotionsTimeBonus = stats.GetFinalAttribute( 'potions_time_bonus' );
		statOilsTimeBonus = stats.GetFinalAttribute( 'oils_time_bonus' );
		statInstantKill = stats.GetFinalAttribute( 'instant_kill_chance' );
		statBlockEnduranceCost = stats.GetFinalAttribute('endurance_on_block_mult');
		if(thePlayer.GetToxicity() > 1.0)
			statInstantKill = statInstantKill*stats.GetFinalAttribute( 'instant_kill_toxbonus' );
		if(thePlayer.GetCharacterStats().HasAbility('alchemy_s14'))
		{
			statBerserk = 1;
		}
		else
		{
			statBerserk = 0;
		}
		if(thePlayer.GetCharacterStats().HasAbility('sword_s4'))
		{
			statGroupAttacks = 1;
		}
		else
		{
			statGroupAttacks = 0;
		}
		if(thePlayer.GetCharacterStats().HasAbility('sword_s14'))
		{
			statGroupFinishers = 1;
		}
		else
		{
			statGroupFinishers = 0;
		}
		petards = thePlayer.GetInventory().GetItemsByCategory('petard');
		statNumPetards = petards.Size();
		if(statNumPetards > 10.0)
		{
			statNumPetards = 10.0;
		}
		statLevel = (float)thePlayer.GetLevel();
	}
	function SetCosts()
	{
		costconstVitality = 10; 
		costconstEndurance = 500;
		costconstEnduranceRegenCombat = 500;
		costconstEnduranceRegenNonCombat = 250;
		costconstArmor = 10; 
		costconstVitalityRegenCombat = 100;
		costconstVitalityRegenNonCombat = 50;  
		costconstDamage = 10; 
		costconstAardDamage = 20; 
		costconstIgniDamage = 20; 
		costconstYrdenDamage = 20; 
		costconstQuenDamage = 10;
		costconstAardKnockChance = 100; 
		costconstBleedChance = 50;
		costconstPoisonChance = 50;
		costconstIgniBurnChance = 50; 
		costconstYrdenTime = 2;
		costconstYrdenTraps = 100;
		costconstIgniBurnTime = 10; 
		costconstQuenTime = 10;
		costconstResBleed = 50;
		costconstResBurn = 50;
		costconstResPoison = 50;
		costconstResKnockdown = 50;
		costconstResStun = 50;
		costconstResAard = 50;
		costconstResIgni = 50;
		costconstResAxii = 50;
		costconstResYrden = 50;
		costconstResQuen = 50;
		costconstAdrenalineGeneration = 5;
		costconstMaxAxiiTargets = 100;
		costconstMaxQuenTargets = 100;
		costconstDaggerThrow = 100;
		costconstHeliotrope = 500;
		costconstDamagePetards = 10;
		costconstDamageTraps = 10;
		costconstPotionsTimeBonus = 10;
		costconstOilsTimeBonus = 10;
		costconstAdditionalPotion = 500;
		costconstInstantKill = 250;
		costconstBerserk = 500;
		costconstBackDamageBonus = 1;
		costconstRiposte = 250;
		costconstDodgeRange = 1;
		costconstBlockEndurance = 50;
		costconstGroupAttacks = 200;
		costconstGroupFinishers = 500;
		costconstNumPetards = 100;
		costconstLevel = 10;
		costconstDamageRanged = 20;
		costconstShotAccuracy = 2;
		costconstIsAMage = 200;
	}
	function CalculateCostsForPlayer()
	{
		costVitality  = statVitality  * costconstVitality;
	costEndurance = statEndurance * costconstEndurance;
	costEnduranceRegenCombat = statEnduranceRegenCombat * costconstEnduranceRegenCombat;
	costEnduranceRegenNonCombat = statEnduranceRegenNonCombat * costconstEnduranceRegenNonCombat;
	costArmor  = statArmor  * costconstArmor;
	costVitalityRegenCombat = statVitalityRegenCombat * costconstVitalityRegenCombat;
	costVitalityRegenNonCombat   = statVitalityRegenNonCombat   * costconstVitalityRegenNonCombat ;
	costDamage  = statDamage  * costconstDamage;
	costAardDamage  = statAardDamage  * costconstAardDamage;
	costIgniDamage  = statIgniDamage  * costconstIgniDamage;
	costYrdenDamage  = statYrdenDamage  * costconstYrdenDamage;
	costQuenDamage = statQuenDamage * costconstQuenDamage;
	costAardKnockChance  = statAardKnockChance  * costconstAardKnockChance;
	costBleedChance = statBleedChance * costconstBleedChance;
	costPoisonChance = statPoisonChance * costconstPoisonChance;
	costIgniBurnChance  = statIgniBurnChance  * costconstIgniBurnChance;
	costYrdenTime = statYrdenTime * costconstYrdenTime;
	costYrdenTraps = statYrdenTraps * costconstYrdenTraps;
	costIgniBurnTime  = statIgniBurnTime  * costconstIgniBurnTime;
	costQuenTime = statQuenTime * costconstQuenTime;
	costResBleed = statResBleed * costconstResBleed;
	costResBurn = statResBurn * costconstResBurn;
	costResPoison = statResPoison * costconstResPoison;
	costResKnockdown = statResKnockdown * costconstResKnockdown;
	costResStun = statResStun * costconstResStun;
	costResAard = statResAard * costconstResAard;
	costResIgni = statResIgni * costconstResIgni;
	costResAxii = statResAxii * costconstResAxii;
	costResYrden = statResYrden * costconstResYrden;
	costResQuen = statResQuen * costconstResQuen;
	costAdrenalineGeneration = statAdrenalineGeneration * costconstAdrenalineGeneration;
	costMaxAxiiTargets = statMaxAxiiTargets * costconstMaxAxiiTargets;
	costMaxQuenTargets = statMaxQuenTargets * costconstMaxQuenTargets;
	costDaggerThrow = statDaggerThrow * costconstDaggerThrow;
	costHeliotrope = statHeliotrope * costconstHeliotrope;
	costDamagePetards = statDamagePetards * costconstDamagePetards;
	costDamageTraps = statDamageTraps * costconstDamageTraps;
	costPotionsTimeBonus = statPotionsTimeBonus * costconstPotionsTimeBonus;
	costOilsTimeBonus = statOilsTimeBonus * costconstOilsTimeBonus;
	costAdditionalPotion = statAdditionalPotion * costconstAdditionalPotion;
	costInstantKill = statInstantKill * costconstInstantKill;
	costBerserk = statBerserk * costconstBerserk;
	costBackDamageBonus = statBackDamageBonus * costconstBackDamageBonus;
	costRiposte = statRiposte * costconstRiposte;
	costDodgeRange = statDodgeRange * costconstDodgeRange;
	costBlockEnduranceCost = costconstBlockEndurance / statBlockEnduranceCost;
	costGroupAttacks = statGroupAttacks * costconstGroupAttacks;
	costGroupFinishers = statGroupFinishers * costconstGroupFinishers;
	costNumPetards = statNumPetards * costconstNumPetards;
	costLevel = statLevel * costconstLevel;
	
	
	//Liczenie kosztu
	cost = 	costVitality +
			costEndurance+
			costEnduranceRegenCombat+
			costEnduranceRegenNonCombat+
			costArmor +
			costVitalityRegenCombat+
			costVitalityRegenNonCombat  +
			costDamage +
			costAardDamage +
			costIgniDamage +
			costYrdenDamage +
			costQuenDamage+
			costAardKnockChance +
			costBleedChance+
			costPoisonChance+
			costIgniBurnChance +
			costYrdenTime+
			costYrdenTraps+
			costIgniBurnTime +
			costQuenTime+
			costResBleed+
			costResBurn+
			costResPoison+
			costResKnockdown+
			costResStun+
			costResAard+
			costResIgni+
			costResAxii+
			costResYrden+
			costResQuen+
			costAdrenalineGeneration+
			costMaxAxiiTargets+
			costMaxQuenTargets+
			costDaggerThrow+
			costHeliotrope+
			costDamagePetards+
			costDamageTraps+
			costPotionsTimeBonus+
			costOilsTimeBonus+
			costAdditionalPotion+
			costInstantKill+
			costBerserk+
			costBackDamageBonus+
			costRiposte+
			costDodgeRange+
			costBlockEnduranceCost+
			costGroupAttacks+
			costGroupFinishers+
			costNumPetards+
			costLevel;
	}
	function PrintPlayerStats()
	{
		SetPlayerStats();
		SetCosts();
		CalculateCostsForPlayer();
		Log("---------- Geralt stats START ------------");
		Log("Vitality " + statVitality +" Cost "+costVitality);
		Log("VitalityRegenCombat " + statVitalityRegenCombat +" Cost "+costVitalityRegenCombat);
		Log("VitalityNonCombat " + statVitalityRegenNonCombat +" Cost "+costVitalityRegenNonCombat);
		Log("Endurance " + statEndurance +" Cost "+costEndurance);
		Log("EnduranceRegenCombat " + statEnduranceRegenCombat +" Cost "+costEnduranceRegenCombat);
		Log("EnduranceRegenNonCombat " + statEnduranceRegenNonCombat +" Cost "+costEnduranceRegenNonCombat);
		Log("BlockEnduranceCost " + statBlockEnduranceCost +" Cost "+costBlockEnduranceCost);
		Log("Armor " + statArmor +" Cost "+costArmor);
		Log("Damage " + statDamage +" Cost "+costDamage);
		Log("AardDamage " + statAardDamage +" Cost "+costAardDamage);
		Log("AardCriticalChance " + statAardKnockChance +" Cost "+costAardKnockChance);
		Log("IgniDamage " + statIgniDamage +" Cost "+costIgniDamage);
		Log("IgniCriticalChance " + statIgniBurnChance +" Cost "+costIgniBurnChance);
		Log("YrdenDamage " + statYrdenDamage +" Cost "+costYrdenDamage);
		Log("YrdenTrapsNum " + statYrdenTraps +" Cost "+costYrdenTraps);
		Log("YrdenTrapDuration " + statYrdenTime +" Cost "+costYrdenTime);
		Log("QuenReflectedDamage " + statQuenDamage +" Cost "+costQuenDamage);
		Log("QuenDuration " + statQuenTime +" Cost "+costQuenTime);
		Log("MaxQuenTargets " + statMaxQuenTargets +" Cost "+costMaxQuenTargets);
		Log("MaxAxiiTargets " + statMaxAxiiTargets +" Cost "+costMaxAxiiTargets);
		Log("BleedCritChance " + statBleedChance +" Cost "+costBleedChance);
		Log("PoisonCritChance " + statPoisonChance +" Cost "+costPoisonChance);
		Log("ResBleed " + statResBleed +" Cost "+costResBleed);
		Log("ResPoison " + statResPoison +" Cost "+costResPoison);
		Log("ResBurn " + statResBurn +" Cost "+costResBurn);
		Log("InstantKillChance " + statInstantKill +" Cost "+costInstantKill);
		Log("PetardsDamageBonus " + statDamagePetards +" Cost "+costDamagePetards);
		Log("TrapsDamageBonus " + statDamageTraps +" Cost "+costDamageTraps);
		Log("CanThrowDaggers " + statDaggerThrow +" Cost "+costDaggerThrow);
		Log("HasHeliotrope " + statHeliotrope +" Cost "+costHeliotrope);
		Log("HasBerserkSkill " + statBerserk +" Cost "+costBerserk);
		Log("HasRiposte " + statRiposte +" Cost "+costRiposte);
		Log("DodgeDistance " + statDodgeRange +" Cost "+costDodgeRange);
		Log("HasGroupAttacks " + statGroupAttacks +" Cost "+costGroupAttacks);
		Log("HasGroupFinishers " + statGroupFinishers +" Cost "+costGroupFinishers);
		Log("PetardsNumber " + statNumPetards +" Cost "+costNumPetards);
		Log("Level " + statLevel +" Cost "+costLevel);
		Log("GeraltTotalCost "+cost);
		
		Log("Used Items:");
		Log("Weapon: "+thePlayer.GetInventory().GetItemName(thePlayer.GetCurrentWeapon()));
		Log("Armor : "+thePlayer.GetInventory().GetItemName(thePlayer.GetInventory().GetItemByCategory('armor', true)));
		
		Log("Difficulty = " + theGame.GetDifficultyLevel());
		
		Log("---------- Geralt stats END --------------");
	}
}
exec function Diff()
{
	var trudnosc : string;
	
	if(theGame.GetDifficultyLevel() == 0)
	{
		trudnosc = "EASY";
	}
	else if(theGame.GetDifficultyLevel() == 1)
	{
		trudnosc = "MEDIUM";
	}
	else if(theGame.GetDifficultyLevel() == 2)
	{
		trudnosc = "HARD";
	}
	else if(theGame.GetDifficultyLevel() == 3)
	{
		trudnosc = "INSANE";
	}
	else if(theGame.GetDifficultyLevel() == 4)
	{
		trudnosc = "DARK";
	}
	else
	{
		trudnosc = "!!!NIEOBSLUGIWANA TRUDNOSC!!!";
	}
		theHud.m_messages.ShowInformationText("Grasz na trudnosci: "+trudnosc);
	
}
exec function CM()
{
	if(thePlayer.IsInCombat())
	{
		theHud.m_messages.ShowInformationText("Jest combat mode");
	}
	else
	{
		theHud.m_messages.ShowInformationText("Nie ma combat mode");
	}
	Log("Combat: " + thePlayer.IsInCombat());
}
exec function Sneak()
{
	thePlayer.EntrySneak(PS_Exploration, "Idle");
}
exec function CostPlayer()
{
	var balanceCalculator : W2BalanceCalc;
	balanceCalculator = new W2BalanceCalc in theGame;
	balanceCalculator.PrintPlayerStats();
}
exec function CostActor(tag : name)
{
	var actor : CActor;
	var balanceCalculator : W2BalanceCalc;
	actor = theGame.GetActorByTag(tag);
	if(actor)
	{
		balanceCalculator = new W2BalanceCalc in theGame;
		balanceCalculator.PrintActorStats(actor);
	}
}
exec function CostCombat(optional combatName : string, optional range : float)
{
	var actors : array<CActor>;
	var balanceCalculator : W2BalanceCalc;
	var combatRange : float;
	var i : int;
	if(range > 0.0f)
	{
		combatRange = range;
	}
	else
	{
		combatRange = 30.0f;
	}
	GetActorsInRange(actors, combatRange, '', thePlayer);
		Log("==============" +combatName+" Combat balance START ===============");
		balanceCalculator = new W2BalanceCalc in theGame;
		for(i = 0; i < actors.Size(); i += 1)
		{
			if(actors[i] != thePlayer)
				balanceCalculator.PrintActorStats(actors[i]);
		}
		balanceCalculator.PrintPlayerStats();
		Log("==============" +combatName+" Combat balance END ===============");
}

exec function En()
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag('enemy2');
	npc.ForceTargetPlayer( 50.0f );
}
exec function ToD()
{
	if(theGame.GetIsDay())
		Log("It's daytime");
		
	if(theGame.GetIsNight())
		Log("It's nighttime");
}
exec function FB()
{
	FakeBuildM(35);
	G();
	thePlayer.GetCharacterStats().AddAbility('training_s5');
	thePlayer.GetCharacterStats().AddAbility('training_s5_2');
}
exec function AddJ()
{
	var i : int;
	var je : array<string>;
	for (i = 4; i <=32; i+=1)
	{
		AddStoryAbility("story_s"+i, 1);
	}
	/*je.PushBack("Journal Amethyst Armor Enhancement");
	je.PushBack("Journal Amethyst Dust");
	je.PushBack("Journal Arachas Trap");
	je.PushBack("Journal Armor of Tir");
	je.PushBack("Journal Armor of Ys");
	je.PushBack("Journal Balanced Dagger");
	je.PushBack("Journal Blue Meteorite Ore");
	je.PushBack("Journal Blue Meteorite Silver Sword");
	je.PushBack("Journal Caingornian Steel Sword");
	je.PushBack("Journal Ceremonial Steel Sword of Deithwen");
	je.PushBack("Journal Crippling Trap");
	je.PushBack("Journal Dearg Ruadhri");
	je.PushBack("Journal Diamond Armor Enhancement");
	je.PushBack("Journal Diamond Dust");
	je.PushBack("Journal Dol Blathanna High Quality Steel Blade");
	je.PushBack("Journal Dragon Trap");
	je.PushBack("Journal Draug Armor");
	je.PushBack("Journal Draug Trap");
	je.PushBack("Journal Elemental Stone");
	je.PushBack("Journal Endriag Armor Enhancement");
	je.PushBack("Journal Explosive Trap");
	je.PushBack("Journal Freezing Trap");
	je.PushBack("Journal Grappling Trap");
	je.PushBack("Journal Hardened Leather");
	je.PushBack("Journal Hardened Leather Boots");
	je.PushBack("Journal Harpy Bait Trap");
	je.PushBack("Journal Heavy Elven Armor");
	je.PushBack("Journal Heavy Leather Jacket");
	je.PushBack("Journal Heavy Leather Pants");
	je.PushBack("Journal High Quality Blue Meteorite Silver Sword");
	je.PushBack("Journal High Quality Leather Pants");
	je.PushBack("Journal High Quality Red Meteorite Silver Sword");
	je.PushBack("Journal High Quality Witcher Silver Sword");
	je.PushBack("Journal High Quality Yellow Meteorite Silver Sword");
	je.PushBack("Journal Jagged Blade");
	je.PushBack("Journal Kaedwenian Quality Sword");
	je.PushBack("Journal Leather");
	je.PushBack("Journal Light Leather Armor");
	je.PushBack("Journal Long Leather Gloves");
	je.PushBack("Journal Long Studded Leather Gloves");
	je.PushBack("Journal Mahakaman Steel Sihil");
	je.PushBack("Journal Mystic Armor Enhancement");
	je.PushBack("Journal Negotiator");
	je.PushBack("Journal Nekker Stun Trap");
	je.PushBack("Journal Nilfgaardian Harphy Sword");
	je.PushBack("Journal Oil");
	je.PushBack("Journal Peacemaker");
	je.PushBack("Journal Quality Blue Meteorite Silver Sword");
	je.PushBack("Journal Quality Cloth");
	je.PushBack("Journal Quality Hunting Steel Sword");
	je.PushBack("Journal Quality Leather Jacket");
	je.PushBack("Journal Quality Long Gloves");
	je.PushBack("Journal Quality Red Meteorite Silver Sword");
	je.PushBack("Journal Quality Short Steel Sword");
	je.PushBack("Journal Quality Witcher Silver Sword");
	je.PushBack("Journal Quality Yellow Meteorite Silver Sword");
	je.PushBack("Journal Rage Trap");
	je.PushBack("Journal Ravens Armor");
	je.PushBack("Journal Red Meteorite Ore");
	je.PushBack("Journal Red Meteorite Silver Sword");
	je.PushBack("Journal Reinforced Leather Boots");
	je.PushBack("Journal Rune of Earth");
	je.PushBack("Journal Rune of Fire");
	je.PushBack("Journal Rune of Moon");
	je.PushBack("Journal Rune of Sun");
	je.PushBack("Journal Rune of Ysgith");
	je.PushBack("Journal Skorzana kurtka");
	je.PushBack("Journal Smocza Luska");
	je.PushBack("Journal Studded Leather");
	je.PushBack("Journal Studded Leather Pants");
	je.PushBack("Journal Temerian Steel Sword");
	je.PushBack("Journal Tentadrake Armor");
	je.PushBack("Journal Tentadrake Armor Enhancement");
	je.PushBack("Journal Tentadrake Trap");
	je.PushBack("Journal Water Essence");
	je.PushBack("Journal Yellow Meteorite Ore");
	je.PushBack("Journal Yellow Meteorite Silver Sword");
	je.PushBack("Journal Ysgith Armor");
	je.PushBack("Journal Yspadenian Steel Sword");
	je.PushBack("Journal Zerrikan Steel Sabre");

	for(i = 0; i<je.Size(); i+=1)
	{
		thePlayer.AddJournalEntry(JournalGroup_Crafting, je[i], je[i]+" 0", "Crafting");
	}
	je.Clear();
	je.PushBack("Journal Caelm");
	je.PushBack("Journal Anabolic");
	je.PushBack("Journal Argentia");
	je.PushBack("Journal Blizzard");
	je.PushBack("Journal Cat");
	je.PushBack("Journal Cerbin Blath");
	je.PushBack("Journal Concretion");
	je.PushBack("Journal Crinfrid Oil");
	je.PushBack("Journal Dancing Star");
	je.PushBack("Journal De Vries Extract");
	je.PushBack("Journal Devil Puffball");
	je.PushBack("Journal Dragon Dream");
	je.PushBack("Journal Firefly");
	je.PushBack("Journal Flare");
	je.PushBack("Journal Golden Oriole");
	je.PushBack("Journal Grapeshot");
	je.PushBack("Journal Hangman Venom");
	je.PushBack("Journal Kiss");
	je.PushBack("Journal Maribor Forest");
	je.PushBack("Journal Marten");
	je.PushBack("Journal Petri Philter");
	je.PushBack("Journal Red Haze");
	je.PushBack("Journal Samum");
	je.PushBack("Journal Shadow");
	je.PushBack("Journal Shrike");
	je.PushBack("Journal Specter Grease");
	je.PushBack("Journal Stinker");
	je.PushBack("Journal Surge");
	je.PushBack("Journal Swallow");
	je.PushBack("Journal Tawny Owl");
	je.PushBack("Journal Thunderbolt");
	je.PushBack("Journal White Raffard Decoction");
	je.PushBack("Journal Wolf");
	je.PushBack("Journal Wolverine");
	
		for(i = 0; i<je.Size(); i+=1)
	{
		thePlayer.AddJournalEntry(JournalGroup_Crafting, je[i], je[i]+" 0", "Crafting");
	}*/
}
exec function TestA()
{
	if(thePlayer.GetCharacterStats().HasAbility('Swallow _Stats'))
		Log("Mamy ability ");
		
}
exec function SP()
{
	var signsPower : float;
	
	signsPower = thePlayer.GetCharacterStats().GetFinalAttribute('signs_power');
	Log("Signs Power : " + signsPower);
}
exec function TestAb()
{
	var actors : array<CActor>;
	var actor : CActor;
	var i, size, sizeAb : int;
	var actorName : string;
	
	GetActorsInRange(actors, 20.0, '', thePlayer);
	size = actors.Size();
	if(size > 0)
	{
		for (i = 0; i < size; i += 1)
		{
			actor = actors[i];
			if(actor != thePlayer)
			{
				actorName = (string)actor.GetName();
				if(actor.GetCharacterStats().HasAbility('axii_debuf2'))
				{
					Log(actorName + " has ability: axii_debuf2");
				}
				else if(actor.GetCharacterStats().HasAbility('axii_debuf1'))
				{
					Log(actorName + " has ability: axii_debuf1");
				}
				else
				{
					Log(actorName + " has no axii debufs");
				}
			}
		}
	}
}



exec function TestDamage()
{
	var actor : CActor;
	var damageMin, damageMax, damageNpcMin, damageNpcMax, experience : float;
	
	actor = theGame.GetActorByTag('theenemy');
	damageMin = actor.GetCharacterStats().GetFinalAttribute('damage_min');
	damageMax = actor.GetCharacterStats().GetFinalAttribute('damage_max');
	damageNpcMin = actor.GetCharacterStats().GetFinalAttribute('damage_npc_min');
	damageNpcMax = actor.GetCharacterStats().GetFinalAttribute('damage_npc_max');
	experience = actor.GetCharacterStats().GetFinalAttribute('experience');
	
	Log("damageMin 		= " + damageMin);
	Log("damageMax 		= " + damageMax);
	Log("damageMinNPC 	= " + damageNpcMin);
	Log("damageMaxNPC	= " + damageNpcMax);
	Log("experience 	= " + experience);

}
exec function AddAbl(ablName : name)
{
	thePlayer.GetCharacterStats().AddAbility(ablName);
}
exec function SetDif( num : int )
{
	theGame.SetDifficultyLevel( num );
}
exec function CustomScript()
{
	//
}
exec function VSM()
{
	thePlayer.PlayVoiceset(100, "witcher_medalion_oneliners");
}
exec function VSA()
{
	thePlayer.PlayVoiceset(100, "witcher_alone_enemies_oneliners");
}
exec function VSF()
{
	thePlayer.PlayVoiceset(100, "witcher_team_enemies_oneliners");
}
exec function E(effect : ECriticalEffectType)
{
	var actors : array<CActor>;
	var size, i : int;
	var params : W2CriticalEffectParams;
	GetActorsInRange(actors, 50.0, '', thePlayer);
	size = actors.Size();
	params.durationMax = 20;
	params.durationMin = 19;
	if(size > 0)
	{
		for(i = 0; i < size; i += 1)
		{
			if(actors[i] != thePlayer)
				actors[i].ForceCriticalEffect(effect, params);
		}
	}
}
exec function EP(effect : ECriticalEffectType)
{
	var actors : array<CActor>;
	var size, i : int;
	var params : W2CriticalEffectParams;
	GetActorsInRange(actors, 50.0, '', thePlayer);
	size = actors.Size();
	if(size > 0)
	{
		for(i = 0; i < size; i += 1)
		{
			actors[i].ForceCriticalEffect(effect, params);
		}
	}
}
exec function Signs0()
{
	//Remove signs level 1
	thePlayer.GetCharacterStats().RemoveAbility('magic_s5');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s6');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s7');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s8');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s9');
	
	//Remove signs level 2
	thePlayer.GetCharacterStats().RemoveAbility('magic_s5_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s6_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s7_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s8_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s9_2');
}
exec function Signs1()
{
	//Remove signs level 2
	thePlayer.GetCharacterStats().RemoveAbility('magic_s5_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s6_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s7_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s8_2');
	thePlayer.GetCharacterStats().RemoveAbility('magic_s9_2');
	
	//Add signs level 1
	thePlayer.GetCharacterStats().AddAbility('magic_s5'); //Aard
	thePlayer.GetCharacterStats().AddAbility('magic_s6'); //Quen
	thePlayer.GetCharacterStats().AddAbility('magic_s7'); //Axii
	thePlayer.GetCharacterStats().AddAbility('magic_s8'); //Yrden
	thePlayer.GetCharacterStats().AddAbility('magic_s9'); //Igni
}
exec function Signs2()
{
	//Add signs level 1
	thePlayer.GetCharacterStats().AddAbility('magic_s5'); //Aard
	thePlayer.GetCharacterStats().AddAbility('magic_s6'); //Quen
	thePlayer.GetCharacterStats().AddAbility('magic_s7'); //Axii
	thePlayer.GetCharacterStats().AddAbility('magic_s8'); //Yrden
	thePlayer.GetCharacterStats().AddAbility('magic_s9'); //Igni
	
	//Add signs level 2
	thePlayer.GetCharacterStats().AddAbility('magic_s5_2'); //Aard
	thePlayer.GetCharacterStats().AddAbility('magic_s6_2'); //Quen
	thePlayer.GetCharacterStats().AddAbility('magic_s7_2'); //Axii
	thePlayer.GetCharacterStats().AddAbility('magic_s8_2'); //Yrden
	thePlayer.GetCharacterStats().AddAbility('magic_s9_2'); //Igni
}

exec function Play( actorTag : name, stringId : int )
{
	var actor : CActor;
	actor = theGame.GetActorByTag( actorTag );
	actor.PlayLine( stringId, true );	
}
function GetTestNPC() : CNewNPC
{
	//return theGame.GetNPCByName("test_elf0");
	//return theGame.GetNPCByName("knight_shield5");
	return theGame.GetNPCByName("npc_test_fist24");
}

exec function DispSkeleton( entTag : name )
{
	var ent : CEntity; 
	ent = theGame.GetEntityByTag( entTag );
	
	if ( ent.GetRootAnimatedComponent() )
	{
		ent.GetRootAnimatedComponent().DisplaySkeleton( true );
	}
}

exec function Tomsin()
{
	thePlayer.RaiseForceEvent( 'TomsinTest' );
}
	
exec function Tomsin2()
{
	if( thePlayer.IsInSneakMode() && thePlayer.GetCurrentPlayerState() == PS_Sneak )
	{
		thePlayer.SetSneakMode(false);
		thePlayer.ChangePlayerState( PS_Exploration );
	}
	else
	{
		thePlayer.SetSneakMode(true);
		thePlayer.ChangePlayerState( PS_Sneak );
	}
}

exec function Maras()
{
	var previousState : EPlayerState;
	
	thePlayer.GetInventory().AddItem( 'Rusty Balanced Dagger', 1 );
	thePlayer.SelectThrownItem( thePlayer.GetInventory().GetItemId( 'Rusty Balanced Dagger' ) );
	previousState = thePlayer.GetCurrentPlayerState();
	thePlayer.QEntryAiming( previousState );
}

exec function Maras2()
{
	thePlayer.GetInventory().RemoveItem( thePlayer.GetInventory().GetItemId( 'Rusty Balanced Dagger' ), 1 );
	thePlayer.QExitAiming();
}

exec function Freeze()
{
	var i, size				: int;
	var actors				: array< CActor >;
	var boundMin, boundMax	: Vector;
	var range				: float;
	var npc					: CNewNPC;
	
	range = 20;
	
	boundMin.X = -range;
	boundMin.Y = -range;
	boundMin.Z = -range;
	boundMax.X = range;
	boundMax.Y = range;
	boundMax.Z = range;
	
	ActorsStorageGetClosestByPos( thePlayer.GetWorldPosition(), actors, boundMin, boundMax );
	
	size = actors.Size();
	for( i = 0; i < size; i += 1 )
	{
		if( actors[i].IsAlive() && actors[i] != thePlayer )
		{
			actors[i].ForceCriticalEffect( CET_Freeze, W2CriticalEffectParams( 0, 0, 900, 900 ) );
		}
	}
}

exec function Temp()
{	
	DumpClassHierarchy( 'CAIGoal' );
}

exec function Temp2()
{
	var npc : CNewNPC = theGame.GetNPCByTag( 'moril' );
	var params : W2CriticalEffectParams;
	npc.ForceCriticalEffect( CET_Burn,  params);
	/*var nodes : array<CNode>;
	var size, i : int;
	var actor : CActor;
	var comp : CAnimatedComponent;
	
	theGame.GetNodesByTag( 'test', nodes );
	size = nodes.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		actor = (CActor)nodes[i];
		comp = (CAnimatedComponent)actor.GetComponentByClassName( 'CAnimatedComponent' );
		
		comp.ApplyLinearImpulse( 0, Vector( 0,0, 1000, 1 ) );
	}*/
}

exec function Temp3()
{
	var npc : CNewNPC;
	var goalIds : array<int>;
	
	npc = GetTestNPC();
	//npc.ClearRotationTarget();
	//npc.SetExternalControl( false );
	npc.GetArbitrator().GetGoalIdsByClassName( 'CAIGoal', goalIds );
	Log("");
}


exec function GallowsTest()
{
	var gallow : CEntity;
	var gallowAnimComponent : CAnimatedComponent;
	
	gallow = theGame.GetEntityByTag( 'q102_gallow' );
	gallowAnimComponent = (CAnimatedComponent) gallow.GetComponent( 'pozycja' );
	
	Log( "pozycja_skazaniec1               " + VecToString(MatrixGetTranslation (gallowAnimComponent.GetBoneMatrixWorldSpace( 'pozycja_skazaniec1' ))) );
	Log( "pozycja_skazaniec2               " + VecToString(MatrixGetTranslation (gallowAnimComponent.GetBoneMatrixWorldSpace( 'pozycja_skazaniec2' ))) );
	Log( "pozycja_skazaniec3               " + VecToString(MatrixGetTranslation (gallowAnimComponent.GetBoneMatrixWorldSpace( 'pozycja_skazaniec3' ))) );
	Log( "pozycja_skazaniec4               " + VecToString(MatrixGetTranslation (gallowAnimComponent.GetBoneMatrixWorldSpace( 'pozycja_skazaniec4' ))) );

}

// This demonstrated how to despawn NPC from community immediatelly.
exec function RychuForceDespawn()
{
	var npcs : array< CNewNPC >;
	
	var i : int;

	theGame.GetNPCsByTag( 'ToDespawn', npcs );

	for ( i = 0; i < npcs.Size(); i += 1 )
	{
		npcs[i].ForceDespawn();
	}
}

exec function DestrTest2()
{
	var beka : CEntity;
	beka = theGame.GetEntityByTag( 'beka' );
	beka.Destroy();
}

exec function FadeTest( fadeIn : bool )
{
	var beka : CEntity;
	beka = theGame.GetEntityByTag( 'beka' );
	beka.Fade( fadeIn );
}

exec function SetVisibleTest()
{
	var gallow : CEntity;
	var component : CDrawableComponent;
	
	gallow = theGame.GetEntityByTag( 'q102_gallow' );
	
	component = (CDrawableComponent) gallow.GetComponent( "rope3_mesh" );
	component.SetVisible( false );
	
	component = (CDrawableComponent) gallow.GetComponent( "rope4_mesh" );
	component.SetVisible( false );
}
/*exec function PlaySoundFX(eventName : name, entityTag : name)
{
	var entities : array <CNode>;
	var i      : int;
	var entity : CEntity;
	
	theGame.GetNodesByTag(entityTag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{
		entity = (CEntity) entities[i];
		entity.PlaySound(eventName);
	}
}*/

exec function RythonTest()
{
	// Localized strings test
	//var npc : CActor;

	//npc = theGame.GetActorByTag( 'rython' );
	//npc.PlayLineByStringKey( "RythonKeyA", true );
	
	// Log( GetLocStringByKey( "RythonKeyA" ) );
	//////////////////////////////////////////////////////
	
	var encEntity : CEncounter;
	var enable : bool;
	
	encEntity = (CEncounter) theGame.GetEntityByTag( 'encounter' );
	
	enable = ! encEntity.isEnabled;
	encEntity.SetEnableState( enable );
}

exec function TowerTest( towerTag : name )
{
	theGame.GetEntityByTag( towerTag ).RaiseEvent( 'destroy' );
}

// by mcinek
exec function StartAnimationLogging()
{
	theGame.StartAnimationLogging();
}

exec function StopAnimationLogging()
{
	theGame.StopAnimationLogging();
}

exec function particle_target_test()
{
	var effect_entity : CEntity;
	
	effect_entity = theGame.GetEntityByTag( 'target_node_test_entity' );
	if ( effect_entity )
	{	
		effect_entity.StopEffect( 'target_flame' );
		effect_entity.PlayEffect( 'target_flame', thePlayer );
	}
}


exec function ScaleLootChances( scale : float )
{
	SetLootChancesScale( scale );
}

exec function PrintLootChancesScale()
{
	Log( "Loot chances scaling factor: " + GetLootChancesScale() );
}

exec function killKejran()
{
	((Zagnica)theGame.GetActorByTag('zagnica')).DieZagnica();
}

exec function RemoveBlackScreen()
{
	theGame.FadeInAsync( 0.f );
}

exec function paksasRotTrg( enable : bool )
{
	var node : CNode;
	
	if ( enable )
	{
		node = theGame.GetNodeByTag( 'rotation_target' );
		thePlayer.SetRotationTarget( node, true );
	}
	else
	{
		thePlayer.ClearRotationTarget();
	}
}

exec function paksasEnablePE( enable : bool )
{	
	var mac : CMovingAgentComponent		= thePlayer.GetMovingAgentComponent();
	
	mac.SetEnabled( enable );
}

exec function T( x, y, z : float )
{
	var pos : Vector;
	
	pos.X = x;
	pos.Y = y;
	pos.Z = z;
	thePlayer.Teleport( pos );
}

exec function open_video()
{
	theHud.ShowVideo();
}

exec function close_video()
{
	theHud.HideVideo();
}

exec function play_video(_name:string)
{
	theHud.PlayVideoAsync( _name, false );
}

exec function stop_video()
{
	theHud.StopVideo();
}

exec function pause_video(pause:bool)
{
	theHud.GetVideo().PauseVideo(pause);
}

exec function video_setAudioLang(lang:int)
{
	theHud.GetVideo().SetAudioLanguage(lang);
}

exec function video_setSubtitleLang(lang:int)
{
	theHud.GetVideo().SetSubtitleLanguage(lang);
}

exec function video_showStatus(show:bool)
{
	theHud.GetVideo().ShowStatus(show);
}


quest function testSBVoid()
{
}

quest function testSBBool( val : bool ) : bool
{
	return val;
}

latent quest function testLSBVoid( time : float )
{
	Sleep( time );
}

latent quest function testLSBBool( time : float, val : bool ) : bool
{
	Sleep( time );
	return val;
}

exec function t01()
{
	var npcs : array< CNewNPC >;
	var i : int;
	var pos : Vector;
	
	theGame.GetNPCsByTag( 'monster', npcs );
	for ( i = 0; i < npcs.Size(); i += 1 )
	{
		pos = npcs[i].GetWorldPosition() + Vector(1,1,0);
		npcs[i].ActionMoveToAsync( pos ); // thePlayer.GetWorldPosition()
	}
}

exec function dbg_show_msg( msg : string )
{
	theHud.m_messages.ShowInformationText( msg );
}

exec function SAC()
{
	var npc : CNewNPC;
	npc = (CNewNPC)theGame.GetEntityByTag( 'fighter' );
	npc.SetIsAxiiControled( 1000000 );
}

exec function Adr()
{
	thePlayer.SetAdrenaline( 150.f );
}

exec function TestVisibility( actorTag : name )
{
	var actor : CActor;
	var isVisible : bool;
	actor = (CActor) theGame.GetEntityByTag( actorTag );
	isVisible = actor.WasVisibleLastFrame();
	dbg_show_msg( isVisible );
}

exec function TestTalkInteraction( actorTag : name )
{
	var actor : CNewNPC;
	var canTalk : bool;
	actor = (CNewNPC) theGame.GetEntityByTag( actorTag );
	canTalk  = actor.OnInteractionTalkTest();
	dbg_show_msg( canTalk  );
}

exec function SetCommRadius( spawnRange : float, despawnRange : float )
{
	SetCommunityRadius( spawnRange, despawnRange );
}

exec function TutTestFinalButtons( isTwo : bool )
{
	// false - jeden button, true - dwa buttony na koniec tutoriala
	theGame.SetNewGameAfterTutorial( isTwo );
}

exec function GuiClearReceivedList()
{
	theHud.Invoke("pHUD.clearRecievedList");
}

exec function GI( input : name )
{
	var i, j : int;
	
	i = theGame.GetInputIgnoreCount( input );
	
	j = 1337;
}

exec function TestGameTime()
{
	var time : GameTime;
	
	time = GameTimeCreate();
	Log( "=============================== " +GameTimeToString( time ) +" ===========================" );
}

exec function ToggleInteractions( isOn : bool )
{
	theGame.EnableButtonInteractions( isOn );
}

exec function isTutHidden()
{
	var res : bool;
	
	res = theGame.tutorialPanelHidden;
	Log( "========================================================================================================" ); 
	Log( "================================ TUTORIAL IS HIDDEN : " +res +" ========================================" );
	Log( "========================================================================================================" );
}

exec function GoT()
{
	theHud.m_hud.EnableTutorial();
}