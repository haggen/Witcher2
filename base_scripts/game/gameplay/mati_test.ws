exec function MakeMeRich()
{
	thePlayer.GetInventory().AddItem('Orens', 10000);
}

exec function unknown_potion()
{
	thePlayer.DecreaseHealth( thePlayer.GetHealth() - 10 , true, NULL );
}

exec function darktest()
{
	//theCamera.PlayEffect('dark_difficulty');
	thePlayer.GetInventory().AddItem('Dark difficulty silver sword A1');
}

exec function t13()
{
	//theHud.m_hud.SetMainFrame("ui_arenadif.swf");
	//theHud.EnableInput( true, false, true );
	//theGame.SetActivePause( true );
	//theHud.ArenaFollowersGuiEnabled( true );
	//theHud.ArenaFollowersGuiName( "Tralalaa Tralski" );
	//theHud.ArenaFollowersGuiHealth( 45 );
	//theHud.ArenaFollowersGuiPicture( 2 );
	thePlayer.GetInventory().AddItem('Orens', 10000);
	
	thePlayer.GetInventory().AddItem('DarkDifficultyArmorA1');
	thePlayer.GetInventory().AddItem('DarkDifficultyBootsA1');
	thePlayer.GetInventory().AddItem('DarkDifficultyGlovesA1');
	thePlayer.GetInventory().AddItem('DarkDifficultyPantsA1');
	thePlayer.GetInventory().AddItem('Dark difficulty silversword A1');
	thePlayer.GetInventory().AddItem('Dark difficulty steelsword A1');
	
	thePlayer.GetInventory().AddItem('DarkDifficultyArmorA2');
	thePlayer.GetInventory().AddItem('DarkDifficultyBootsA2');
	thePlayer.GetInventory().AddItem('DarkDifficultyGlovesA2');
	thePlayer.GetInventory().AddItem('DarkDifficultyPantsA2');
	thePlayer.GetInventory().AddItem('Dark difficulty silversword A2');
	thePlayer.GetInventory().AddItem('Dark difficulty steelsword A2');

	thePlayer.GetInventory().AddItem('DarkDifficultyArmorA3');
	thePlayer.GetInventory().AddItem('DarkDifficultyBootsA3');
	thePlayer.GetInventory().AddItem('DarkDifficultyGlovesA3');
	thePlayer.GetInventory().AddItem('DarkDifficultyPantsA3');
	thePlayer.GetInventory().AddItem('Dark difficulty silversword A3');
	thePlayer.GetInventory().AddItem('Dark difficulty steelsword A3');
	

}

exec function t12()
{
	Log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	//theHud.Invoke( "vPanel.ShowFailed" );
	//theHud.Invoke( "vPanelClass.ShowFailed" );
	//theHud.Invoke( "pPanelClass.ShowFailed" );
	//theHud.Invoke( "pPanelClass.ShowCompleted" );
	
	//theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_cries_pl/arena_oneleft_pl");
	theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_cries/arena_enthusiasm_pl");
	//theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_cries_pl/arena_lazy_pl");
}

exec function die()
{
	thePlayer.SetHealth(0, true, NULL);
}

exec function TaskTest( is : bool )
{
	theHud.m_hud.ShowTutorialTask( is );
}

exec function testtrack()
{
     /*  var questName, questTodo : string;
       if ( theGame.GetQuestLogManager().GetTrackedQuestInfo( questName, questTodo ) )
       {
               LogChannel( 'rychu', "Quest name: " + questName + "   Quest Todo: "
+ questTodo );
				theHud.m_hud.SetTrackQuestInfo( StrUpper(questName), questTodo );
       }
       else
       {
				theHud.m_hud.ClearTrackQuestInfo();
       }*/
}

exec function loottest( val : bool )
{
	//var args : array <CFlashValueScript>;
	if ( val )
	{
		thePlayer.SetManualControl(false, false);
		theHud.Invoke("LoadLootWindow");
		theHud.EnableInput( true, true, true, false );
		//theHud.InvokeManyArgs("uiLootTable.setItems", args);
	} else
	{
		thePlayer.SetManualControl(true, true);
		theHud.Invoke("UnLoadLootWindow");
		theHud.EnableInput( false, false, false, false );
	}
}

exec function ov(  )
{
	var args : array <CFlashValueScript>;
	var params : W2CriticalEffectParams;
	//thePlayer.AddJournalEntry( JournalGroup_Tutorial, "tut100_title", theHud.m_hud.ParseButtons(GetLocStringByKeyExt("tut100_text")), "MECHANIKA", "");
	//var params : W2CriticalEffectParams;
	//params.durationMax = 60;
	//params.durationMin = 60;
	//theHud.m_fx.ScopeStart();
	//thePlayer.SetHealth(0, true, thePlayer);
	//thePlayer.SetLevelUp();
	//theHud.ShowShopNew( theGame.GetNPCByTag('mmmm') );
	//theHud.m_messages.ShowActText( "Prolog" );
	/*thePlayer.GetInventory().AddItem('Wood lumber');
	thePlayer.GetInventory().AddItem('Wood lumber');
	thePlayer.GetInventory().AddItem('Wood lumber');
	thePlayer.GetInventory().AddItem('Iron ore');
	thePlayer.GetInventory().AddItem('Iron ore');
	thePlayer.GetInventory().AddItem('Iron ore');
	thePlayer.GetInventory().AddItem('Iron ore');
	thePlayer.GetInventory().AddItem('Iron ore');
	thePlayer.GetInventory().AddItem('Iron ore');
	theHud.ShowCraft();*/
	//thePlayer.ForceCriticalEffect(CET_Drunk, params);
	//thePlayer.StateMeditationExit();
	//thePlayer.EnableMeditation( false );
	//theHud.Invoke("fadeLoaderOn");
	//AddItem( StringToName( "Filippa's Notes" ));
	//AddItem( StringToName( "q001_orders" ));
//theHud.m_hud.ShowTutorial( "tut61", "", false);
	//thePlayer.AddTimer('ClearTutorial', 10, false);
	//thePlayer.AddTime
	//thePlayer.GetInventory().AddItem('Geralt_Elixir');
	//thePlayer.GetInventory().MountItem( thePlayer.GetInventory().GetItemId('Geralt_Elixir'), true);
	//thePlayer.GetInventory().AddItem('Book of Arachases');
	/*thePlayer.GetInventory().AddItem('Book of Bruxas');
	thePlayer.GetInventory().AddItem('Book of Bullvore');
	thePlayer.GetInventory().AddItem('Book of Draugirs');
	thePlayer.GetInventory().AddItem('Book of Draugs');
	thePlayer.GetInventory().AddItem('Book of Drowners');
	thePlayer.GetInventory().AddItem('Book of Nekkers');
	thePlayer.GetInventory().AddItem('Book of Rotfiends');
	thePlayer.GetInventory().AddItem('Book of Tentadrakes');
	thePlayer.GetInventory().AddItem('Book of Golems');
	thePlayer.GetInventory().AddItem('Book of Ifrits');
	thePlayer.GetInventory().AddItem('Book of Endriags');
	thePlayer.GetInventory().AddItem('Book of Dragons');
	thePlayer.GetInventory().AddItem('Book of Trolls');
	thePlayer.GetInventory().AddItem('Book of Gargoyles');
	thePlayer.GetInventory().AddItem('Book of Cadavers');
	thePlayer.GetInventory().AddItem('Book of Harpies');
	thePlayer.GetInventory().AddItem('Book of Wraiths');*/
	//theHud.m_hud.SetTrackQuestInfo( "ZLECENIE NA HARPIE", "Zniszcz gniazda harpii." );
	//theHud.m_hud.SetTrackQuestProgress( 10 );
	//theGame.FadeOutAsync( 0.f );
	//theSound.PlaySound("gui/gui/gui_gameover");
	//theHud.m_hud.SetGameOver( true );
	//theHud.ShowCraft();
	//AddItem("Ludwig Merse's Report");
	//theGame.UnlockAchievement('ACH_PROLOG_FINISHED');
	//theHud.LaunchPanel("ui_main_menu.swf");
	//theHud.GetObject( "vPanel", AS_customPanel );
	//theHud.InvokeOneArg( "vHUD.loadMovie",  FlashValueFromString("ui_main_menu.swf"));
	
	/*AddItem('Glossary Temerian Dynasty' )   ;
	AddItem('Glossary Aelirenn' )   ;
			AddItem('Glossary Thanned Riot' ) ;  
			AddItem('Glossary Ban Ard' )   ;
	AddItem('Glossary Sorcerers' )   ;
			AddItem('Glossary The Good Book' )  ; 
			AddItem('Glossary Elder Races' )   ;
			AddItem('Glossary The White Flame' )   ;
			AddItem('Glossary Conclave of Mages' )  ; 
			AddItem('Glossary Scoiatael' )   ;
			AddItem('Glossary Council of Mages' )  ; 
			AddItem('Glossary Visimian Uprising' )  ; 
			AddItem('Glossary Special Forces' )  ; 
		AddItem('Glossary Melitele' )   ;
			AddItem('Glossary Magic' )   ;
		AddItem('Glossary The Lodge' )  ; 
			AddItem('Glossary Dwarves' ) ;  
			AddItem('Glossary Conjunction of Spheres' ) ;  
		AddItem('Glossary Order of the Flaming Rose' );   
			AddItem('Glossary Witchers' )   ;
			AddItem('Glossary Vejopatis' ) ;  
			AddItem('Glossary Dun Banner' ) ;  
			AddItem('Places Aedirn' )  ; 
			AddItem( 'Places Dol Blathanna' ) ;  
			AddItem('Places Dolina Pontaru' );   
			AddItem('Places Dolna Marchia' )  ; 
			AddItem('Places Loc Muinne' ) ;  
			AddItem('Places Nilfgaard' );  
		AddItem('Book of Arachases' )  ; 
			AddItem('Book of Bruxas' )   ;
			AddItem('Book of Bullvore' ) ;  
		AddItem('Book of Draugirs' );   
			AddItem('Book of Draugs' )   ;
			AddItem('Book of Drowners' )   ;
			AddItem('Book of Nekkers' )   ;
			AddItem('Book of Rotfiends' )   ;
			AddItem('Book of Tentadrakes' )   ;
			AddItem('Book of Golems' )   ;
			AddItem('Book of Ifrits' )   ;
			AddItem('Book of Endriags' )   ;
			AddItem('Book of Dragons' )   ;
			AddItem('Book of Trolls' )   ;
			AddItem('Book of Gargoyles' )   ;
			AddItem('Book of Cadavers' )   ;
			AddItem('Book of Harpies' )   ;
			AddItem('Book of Wraiths' )   ;
			
				thePlayer.GetInventory().AddItem(StringToName("Rusty Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Quality Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("High Quality Silver Balanced Dagger"));
	thePlayer.GetInventory().AddItem(StringToName("Sting"));*/
	//thePlayer.IncreaseExp(2500);
	
	//thePlayer.AddJournalEntry( JournalGroup_Glossary, "Rada Czarodziejow", "Rada Czarodziejow 0",  "Politics", "glossariusz_256x256" ); 
	/*theHud.m_hud.setJournalEntryText( "aaaA", "bbb" );
	theHud.m_hud.setKnowledgeEntryText( "aaaA", "bbb" );
	theHud.m_hud.setAbilityEntryText( "aaaA", "bbb" );*/
	
	//heSound.MuteAllSounds();
	//theSound.SilenceMusic();
	//theHud.m_fx.W2LogoStart( true );
	
    //theHud.ShowOverview();
	
	/*thePlayer.IncreaseKnowledgeAccumulator( 9, 1000 );
	thePlayer.IncreaseKnowledgeAccumulator( 10, 1000 );
	thePlayer.IncreaseKnowledgeAccumulator( 11, 1000 );*/
	
	//theCamera.SetCameraPermamentShake(CShakeState_Drunk, 1.0);
	//thePlayer.AddTimer('DrunkTimerRemove', 30.0f, false);
	//thePlayer.AddTimer('DrunkTimerFX', 0.5f, true);
	
	theHud.ShowCredits();
	
	//thePlayer.GetInventory().AddItem( StringToName( "Herbalist's Gloves") );
	
	/*thePlayer.GetInventory().AddItem( StringToName( "Thorak Chest Key") );
	thePlayer.GetInventory().AddItem( StringToName( "Baltimore's Dream"));
    thePlayer.GetInventory().AddItem( StringToName( "Letho's Dream"));
	thePlayer.GetInventory().AddItem( StringToName( "Peasant's Dream"));
	thePlayer.GetInventory().AddItem( StringToName( "Iorweth's Dream"));
	thePlayer.GetInventory().AddItem( StringToName( "Dragon's Dream"));*/
	
	//theHud.SetHudVisible( false );
	
	//theHud.m_fx.HoleStart();
	
	/*AddStoryAbility( "story_s13", 1 );
	AddStoryAbility( "story_s13", 2 );
	AddStoryAbility( "story_s1", 1 );
	AddStoryAbility( "story_s1", 2 );
	AddStoryAbility( "story_s1", 3 );*/
	
	//thePlayer.IncreaseKnowledgeAccumulator( 4, 1000 );
}

exec function setdrunk()
{
	theCamera.SetCameraPermamentShake(CShakeState_Drunk, 1.0);
	thePlayer.AddTimer('DrunkTimerRemove', 30.0f, false);
}


exec function add1()
{
	thePlayer.GetInventory().AddItem(StringToName("Eyla Tarn Captain's Journal")); 
	thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Report"));
	thePlayer.GetInventory().AddItem(StringToName("Priest's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Gone Explorer's Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Malgets Notes"));
	thePlayer.GetInventory().AddItem(StringToName("Baltimore_notes"));
	thePlayer.GetInventory().AddItem(StringToName("cecils map"));
	thePlayer.GetInventory().AddItem(StringToName("Soldiers Letter"));
	thePlayer.GetInventory().AddItem(StringToName("q213_soldier_prayer"));
	thePlayer.GetInventory().AddItem(StringToName("Vejopatis"));
}

exec function addexp1( val : int )
{
	thePlayer.IncreaseExp( val );
}

exec function EClearBuild()
{
	thePlayer.ClearBuild();
}

exec function HideMouseCursor()
{
	theHud.EnableInput(true, true, false, false);
}

exec function GUISetFov( val : float)
{
	//theCamera.SetFov( val );
	//val = val - 45;
	//RadialBlurSetup( thePlayer.GetWorldPosition(), (val / 200), (val / 150), (val / 150), (val / 150) );
	//Log(val );
}

exec function sg()
{
	var allItems : array< SItemUniqueId >;
	var i : int;
	var actor : CNewNPC;
	var itemName : name;
	
	actor = theGame.GetNPCByTag('fake_geralt');
	
	actor.SetAppearance('default');
	
	thePlayer.GetInventory().GetAllItems( allItems );
	
	for ( i = 0; i < allItems.Size(); i += 1 )
		{
				itemName = thePlayer.GetInventory().GetItemName( allItems[i] );
				actor.GetInventory().AddItem( thePlayer.GetInventory().GetItemName( allItems[i] ) , 1 );
				if ( thePlayer.GetInventory().IsItemMounted( allItems[i] ) ) 
				{
					actor.GetInventory().MountItem( actor.GetInventory().GetItemId( itemName ), false );
				}
		}	
}

exec function fx_overdose1()
{
	theCamera.PlayEffect('overdose', theCamera);
	thePlayer.SetToxicity( 90 );
	AddItem( StringToName("Baltimore's Map") );
}
exec function fx_overdose2()
{
	theCamera.PlayEffect('overdose_1', theCamera);
}
exec function fx_overdose3()
{
	theCamera.PlayEffect('overdose_2', theCamera);
}

exec function aab( )
{
	FactsAdd( 'gameplay_catch_by_guard', 1 );
}

exec function tostartpoint()
{
	var ent : CNode;
	var pos : Vector;
	ent = theGame.GetNodeByTag('start');
	pos = ent.GetWorldPosition();
	thePlayer.Teleport( pos );	
}

exec function AddPots()
{
	AddItem('Tawny Owl');
	AddItem('Swallow');
	AddItem('Thunderbolt');
	AddItem('Cat');
}

exec function DrinkPots()
{
	AddItem('Tawny Owl');
	AddItem('Swallow');
	AddItem('Thunderbolt');
	AddItem('Cat');
	UseItem('Tawny Owl');
	UseItem('Swallow');
	UseItem('Thunderbolt');
	UseItem('Cat');
	thePlayer.SetToxicity(70);
}

exec function dupa()
{
	AreaEnvironmentActivate( "AreaEnviroment1" );
	AreaEnvironmentStabilize( );
}











function allitems1( )
{
thePlayer.GetInventory().AddItem('Grapeshot');
thePlayer.GetInventory().AddItem('Devil Puffball');
thePlayer.GetInventory().AddItem('Samum');
thePlayer.GetInventory().AddItem('Dancing Star');
thePlayer.GetInventory().AddItem('Dragon Dream');
thePlayer.GetInventory().AddItem('Firefly');
thePlayer.GetInventory().AddItem('Flare');
thePlayer.GetInventory().AddItem('Stinker');
thePlayer.GetInventory().AddItem('Bomb Target Marker');
thePlayer.GetInventory().AddItem('Red Haze');

thePlayer.GetInventory().AddItem('Recipe Wolverine');
thePlayer.GetInventory().AddItem('Recipe Marten');
thePlayer.GetInventory().AddItem('Recipe Blizzard');
thePlayer.GetInventory().AddItem('Recipe Maribor Forest');
thePlayer.GetInventory().AddItem('Recipe Golden Oriole');
thePlayer.GetInventory().AddItem('Recipe De Vries Extract');
thePlayer.GetInventory().AddItem('Recipe White Raffards Decoction');
thePlayer.GetInventory().AddItem('Recipe Wolf');
thePlayer.GetInventory().AddItem('Recipe Shrike');
thePlayer.GetInventory().AddItem('Recipe Swallow');
thePlayer.GetInventory().AddItem('Recipe Concretion');
thePlayer.GetInventory().AddItem('Recipe Cat');
thePlayer.GetInventory().AddItem('Recipe Kiss');
thePlayer.GetInventory().AddItem('Recipe Tawny Owl');
thePlayer.GetInventory().AddItem('Recipe Thunderbolt');
thePlayer.GetInventory().AddItem('Recipe Petri Philter');
thePlayer.GetInventory().AddItem('Recipe Shadow');
thePlayer.GetInventory().AddItem('Recipe Samum');
thePlayer.GetInventory().AddItem('Recipe Dancing Star');
thePlayer.GetInventory().AddItem('Recipe Dragon Slumber');
thePlayer.GetInventory().AddItem('Recipe Devil Puffball');
thePlayer.GetInventory().AddItem('Recipe Flare');
thePlayer.GetInventory().AddItem('Recipe Stinker');
thePlayer.GetInventory().AddItem('Recipe Firefly');
thePlayer.GetInventory().AddItem('Recipe Grapeshot');
thePlayer.GetInventory().AddItem('Red Haze');
thePlayer.GetInventory().AddItem('Recipe Caelm');
thePlayer.GetInventory().AddItem('Recipe Cerbin Blath');
thePlayer.GetInventory().AddItem('Recipe Specter Grease');
thePlayer.GetInventory().AddItem('Recipe Argentia');
thePlayer.GetInventory().AddItem('Recipe Brown Oil');
thePlayer.GetInventory().AddItem('Recipe Crinfrid Oil');
thePlayer.GetInventory().AddItem('Recipe Hanged Mans Venom');
thePlayer.GetInventory().AddItem('Recipe Surge');
thePlayer.GetInventory().AddItem('Recipe Oil');
thePlayer.GetInventory().AddItem('Recipe Amethyst Dust');

thePlayer.GetInventory().AddItem('Schematic Leather Jacket');
thePlayer.GetInventory().AddItem('Schematic Heavy Leather Jacket');
thePlayer.GetInventory().AddItem('Schematic Quality Leather Jacket');
thePlayer.GetInventory().AddItem('Schematic Light Leather Armor');
thePlayer.GetInventory().AddItem('Schematic Heavy Elven Armor');
thePlayer.GetInventory().AddItem('Schematic Ravens Armor');
thePlayer.GetInventory().AddItem('Schematic Tentadrake Armor');
thePlayer.GetInventory().AddItem('Schematic Draug Armor');
thePlayer.GetInventory().AddItem('Schematic Dearg Ruadhri');
thePlayer.GetInventory().AddItem('Schematic Armor of Tir');
thePlayer.GetInventory().AddItem('Schematic Ysgith Armor');
thePlayer.GetInventory().AddItem('Schematic Armor of Ys');
thePlayer.GetInventory().AddItem('Schematic Reinforced Leather Boots');
thePlayer.GetInventory().AddItem('Schematic Hardened Leather Boots');
thePlayer.GetInventory().AddItem('Schematic Long Leather Gloves');
thePlayer.GetInventory().AddItem('Schematic Long Studded Leather Gloves');
thePlayer.GetInventory().AddItem('Schematic Quality Long Gloves');
thePlayer.GetInventory().AddItem('Schematic High Quality Leather Pants');
thePlayer.GetInventory().AddItem('Schematic Heavy Leather Pants');
thePlayer.GetInventory().AddItem('Schematic Studded Leather Pants');
thePlayer.GetInventory().AddItem('Schematic Rune of Sun');
thePlayer.GetInventory().AddItem('Schematic Rune of Ysgith');
thePlayer.GetInventory().AddItem('Schematic Rune of Earth');
thePlayer.GetInventory().AddItem('Schematic Rune of Moon');
thePlayer.GetInventory().AddItem('Schematic Rune of Fire');
thePlayer.GetInventory().AddItem('Schematic Amethyst Armor Enhancement');
thePlayer.GetInventory().AddItem('Schematic Diamond Armor Enhancement');
thePlayer.GetInventory().AddItem('Schematic Tentadrake Armor Enhancement');
thePlayer.GetInventory().AddItem('Schematic Endriag Armor Enhancement');
thePlayer.GetInventory().AddItem('Schematic Mystic Armor Enhancement');

}

function allitems2( )
{

thePlayer.GetInventory().AddItem('Schematic Explosive Trap');
thePlayer.GetInventory().AddItem('Schematic Crippling Trap');
thePlayer.GetInventory().AddItem('Schematic Freezing Trap');
thePlayer.GetInventory().AddItem('Schematic Rage Trap');
thePlayer.GetInventory().AddItem('Schematic Grappling Trap');
thePlayer.GetInventory().AddItem('Schematic Harpy Bait Trap');
thePlayer.GetInventory().AddItem('Schematic Nekker Stun Trap');
thePlayer.GetInventory().AddItem('Schematic Tentadrake Trap');
thePlayer.GetInventory().AddItem('Schematic Dragon Trap');
thePlayer.GetInventory().AddItem('Schematic Arachas Trap');
thePlayer.GetInventory().AddItem('Schematic Draug Trap');
thePlayer.GetInventory().AddItem('Schematic Balanced Dagger');
thePlayer.GetInventory().AddItem('Schematic Caerme');
thePlayer.GetInventory().AddItem('Schematic Caingornian Steel Sword');
thePlayer.GetInventory().AddItem('Schematic Yspadenian Steel Sword');
thePlayer.GetInventory().AddItem('Schematic Temerian Steel Sword');
thePlayer.GetInventory().AddItem('Schematic Quality Short Steel Sword');
thePlayer.GetInventory().AddItem('Schematic Quality Hunting Steel Sword');
thePlayer.GetInventory().AddItem('Schematic Jagged Blade');
thePlayer.GetInventory().AddItem('Schematic Peacemaker');
thePlayer.GetInventory().AddItem('Schematic Kaedwenian Quality Sword');
thePlayer.GetInventory().AddItem('Schematic Dol Blathanna High Quality Steel Blade');
thePlayer.GetInventory().AddItem('Schematic Zerrikan Steel Sabre');
thePlayer.GetInventory().AddItem('Schematic Mahakaman Steel Sihil');
thePlayer.GetInventory().AddItem('Schematic Nilfgaardian Harphy Sword');
thePlayer.GetInventory().AddItem('Schematic Ceremonial Steel Sword of Deithwen');
thePlayer.GetInventory().AddItem('Schematic Quality Witcher Silver Sword');
thePlayer.GetInventory().AddItem('Schematic High Quality Witcher Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Quality Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Quality Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Quality Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic High Quality Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic High Quality Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic High Quality Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Schematic Unique Silver Meteorite Sword');
thePlayer.GetInventory().AddItem('Schematic Negotiator');
thePlayer.GetInventory().AddItem('Schematic Amethyst Dust');
thePlayer.GetInventory().AddItem('Schematic Diamond Dust');
thePlayer.GetInventory().AddItem('Schematic Quality cloth');
thePlayer.GetInventory().AddItem('Schematic Hardened leather');
thePlayer.GetInventory().AddItem('Schematic Studded leather');
thePlayer.GetInventory().AddItem('Schematic Leather');
thePlayer.GetInventory().AddItem('Schematic Elemental stone');
thePlayer.GetInventory().AddItem('Schematic Oil');
thePlayer.GetInventory().AddItem('Schematic Water essence');
thePlayer.GetInventory().AddItem('Schematic Blue meteorite ore');
thePlayer.GetInventory().AddItem('Schematic Red meteorite ore');
thePlayer.GetInventory().AddItem('Schematic Yellow meteorite ore');

thePlayer.GetInventory().AddItem('Light Leather Jacket');
thePlayer.GetInventory().AddItem('Quilted Leather');
thePlayer.GetInventory().AddItem('Temerian Armor');
thePlayer.GetInventory().AddItem('Leather Jacket');
thePlayer.GetInventory().AddItem('Studded Leather Jacket');
thePlayer.GetInventory().AddItem('Heavy Leather Jacket');
thePlayer.GetInventory().AddItem('Hardened Leather Jacket');
thePlayer.GetInventory().AddItem('Light Chainmail Shirt');

}

function allitems3( )
{

thePlayer.GetInventory().AddItem('Elven Armor');
thePlayer.GetInventory().AddItem('Kaedwenian Leather Jacket');
thePlayer.GetInventory().AddItem('Aedirnian Leather Jacket');
thePlayer.GetInventory().AddItem('Shiadhal Armor');
thePlayer.GetInventory().AddItem('Astrogarus Armor');
thePlayer.GetInventory().AddItem('Cahir Armor');
thePlayer.GetInventory().AddItem('Quality Leather Jacket');
thePlayer.GetInventory().AddItem('Light Leather Armor');
thePlayer.GetInventory().AddItem('Heavy Elven Armor');
thePlayer.GetInventory().AddItem('Ravens Armor');
thePlayer.GetInventory().AddItem('Tentadrake Armor');
thePlayer.GetInventory().AddItem('Quilted Armor');
thePlayer.GetInventory().AddItem('Thyssen Armor');
thePlayer.GetInventory().AddItem('Armor of Loc Muinne');
thePlayer.GetInventory().AddItem('Dragonscale Armor');
thePlayer.GetInventory().AddItem('Zireael Armor');
thePlayer.GetInventory().AddItem('Kaedwenian Leather Armor');
thePlayer.GetInventory().AddItem('Ban Ard Armor');
thePlayer.GetInventory().AddItem('Draug Armor');
thePlayer.GetInventory().AddItem('Dearg Ruadhri');
thePlayer.GetInventory().AddItem('Armor of Tir');
thePlayer.GetInventory().AddItem('Ysgith Armor');
thePlayer.GetInventory().AddItem('Armor of Ys');

thePlayer.GetInventory().AddItem('Worn Leather Boots');
thePlayer.GetInventory().AddItem('Reinforced Leather Boots');
thePlayer.GetInventory().AddItem('Worn Hardened Leather Boots');
thePlayer.GetInventory().AddItem('Hardened Leather Boots');
thePlayer.GetInventory().AddItem('Temerian Unique Leather Boots');
thePlayer.GetInventory().AddItem('High Quality Temerian Unique Leather Boots');
thePlayer.GetInventory().AddItem('Nilfgaardian Unique Leather Boots');
thePlayer.GetInventory().AddItem('High Quality Nilfgaardian Unique Leather Boots');
thePlayer.GetInventory().AddItem('Kaedwenian Unique Leather Boots');
thePlayer.GetInventory().AddItem('High Quality Kaedwenian Unique Leather Boots');

thePlayer.GetInventory().AddItem('Worn Leather Gloves');
thePlayer.GetInventory().AddItem('Short Leather Gloves');
thePlayer.GetInventory().AddItem('Long Leather Gloves');
thePlayer.GetInventory().AddItem('Worn Long Leather Gloves');
thePlayer.GetInventory().AddItem('Short Studded Leather Gloves');
thePlayer.GetInventory().AddItem('Long Studded Leather Gloves');
thePlayer.GetInventory().AddItem('Quality Long Gloves');
thePlayer.GetInventory().AddItem('Sorccerer Gloves');
thePlayer.GetInventory().AddItem('Elven Gloves');

thePlayer.GetInventory().AddItem('Hardened Fabric Enhancement');
thePlayer.GetInventory().AddItem('Mail Armor Enhancement');
thePlayer.GetInventory().AddItem('Runic Armor Enhancement');
thePlayer.GetInventory().AddItem('Armor Enhancement');
thePlayer.GetInventory().AddItem('Leather Enhancement');
thePlayer.GetInventory().AddItem('Hardened Leather Enhancement');
thePlayer.GetInventory().AddItem('Reinforced Leather Enhancement');
thePlayer.GetInventory().AddItem('Quality Leather Enhancement');
thePlayer.GetInventory().AddItem('Studded Leather Enhancement');
thePlayer.GetInventory().AddItem('Steel Plate Enhancement');
thePlayer.GetInventory().AddItem('Amethyst Armor Enhancement');
thePlayer.GetInventory().AddItem('Diamond Armor Enhancement');
thePlayer.GetInventory().AddItem('Elanie Bleidd');
thePlayer.GetInventory().AddItem('Dhu Bleidd');
thePlayer.GetInventory().AddItem('Quaility Steel Plate Enhancement');
thePlayer.GetInventory().AddItem('Vrans Armor Enhancement');
thePlayer.GetInventory().AddItem('Tentadrake Armor Enhancement');
thePlayer.GetInventory().AddItem('Endriag Armor Enhancement');
thePlayer.GetInventory().AddItem('Dwarven Armor Enhancement');
thePlayer.GetInventory().AddItem('Elven Armor Enhancement');
thePlayer.GetInventory().AddItem('Mystic Armor Enhancement');
thePlayer.GetInventory().AddItem('kokarda wojsk specjalnych temerii');
thePlayer.GetInventory().AddItem('kokarda wojsk specjalnych aedirn');

thePlayer.GetInventory().AddItem('Nekker contract');
thePlayer.GetInventory().AddItem('Endriag contract');
thePlayer.GetInventory().AddItem('Rotfiend contract');
thePlayer.GetInventory().AddItem('Bullvore contract');
thePlayer.GetInventory().AddItem('Harpy contract');
thePlayer.GetInventory().AddItem('Harpy Queen contract');
thePlayer.GetInventory().AddItem(StringToName("Ele'yas contract"));
thePlayer.GetInventory().AddItem('Gargoyle contract');
thePlayer.GetInventory().AddItem('Troll contract');
thePlayer.GetInventory().AddItem('a1_flotsam_notice_board_01');
thePlayer.GetInventory().AddItem('a1_flotsam_notice_board_02');
thePlayer.GetInventory().AddItem('a1_flotsam_notice_board_03');

}

exec function addherbs()
{
thePlayer.GetInventory().AddItem('White Myrtle Petals');
thePlayer.GetInventory().AddItem('Hellebore Petals');
thePlayer.GetInventory().AddItem('Celandine');
thePlayer.GetInventory().AddItem('Beggartick Blossoms');
thePlayer.GetInventory().AddItem('Mandrake Root');
thePlayer.GetInventory().AddItem('Wolfsbane');
thePlayer.GetInventory().AddItem('Bryony');
thePlayer.GetInventory().AddItem('Verbena');
thePlayer.GetInventory().AddItem('Balisse');
}

function allitems4( )
{

thePlayer.GetInventory().AddItem('a2_vergen_noticeboard_01');
thePlayer.GetInventory().AddItem('a3_loc_muinne_notice_board_01');

thePlayer.GetInventory().AddItem('White Myrtle Petals');
thePlayer.GetInventory().AddItem('Hellebore Petals');
thePlayer.GetInventory().AddItem('Celandine');
thePlayer.GetInventory().AddItem('Beggartick Blossoms');
thePlayer.GetInventory().AddItem('Mandrake Root');
thePlayer.GetInventory().AddItem('Wolfsbane');
thePlayer.GetInventory().AddItem('Bryony');
thePlayer.GetInventory().AddItem('Verbena');
thePlayer.GetInventory().AddItem('Balisse');

thePlayer.GetInventory().AddItem('Diamond Dust');
thePlayer.GetInventory().AddItem('Amethyst Dust');
thePlayer.GetInventory().AddItem('Cloth');
thePlayer.GetInventory().AddItem('Quality cloth');
thePlayer.GetInventory().AddItem('Leather');
thePlayer.GetInventory().AddItem('Hardened leather');
thePlayer.GetInventory().AddItem('Studded leather');
thePlayer.GetInventory().AddItem('Iron ore');
thePlayer.GetInventory().AddItem('Silver ore');
thePlayer.GetInventory().AddItem('Dragon scales');
thePlayer.GetInventory().AddItem('Draug essence');
thePlayer.GetInventory().AddItem('Wood lumber');
thePlayer.GetInventory().AddItem('Blue meteorite ore');
thePlayer.GetInventory().AddItem('Red meteorite ore');
thePlayer.GetInventory().AddItem('Yellow meteorite ore');
thePlayer.GetInventory().AddItem('Harphy claws');
thePlayer.GetInventory().AddItem('Tentadrake skin');
thePlayer.GetInventory().AddItem('Crab spider shell');
thePlayer.GetInventory().AddItem('Troll skin');
thePlayer.GetInventory().AddItem('Water essence');
thePlayer.GetInventory().AddItem('Elemental stone');
thePlayer.GetInventory().AddItem('Harphy feathers');
thePlayer.GetInventory().AddItem('Gargoyle Heart');
thePlayer.GetInventory().AddItem('Gargoyle dust');
thePlayer.GetInventory().AddItem('Necrophage blood');
thePlayer.GetInventory().AddItem('Necrophage skin');
thePlayer.GetInventory().AddItem('Death essence');
thePlayer.GetInventory().AddItem('Piece of Wraith Knight armor');
thePlayer.GetInventory().AddItem('Endriag skin');
thePlayer.GetInventory().AddItem('Endriag saliva');
thePlayer.GetInventory().AddItem('Endriag teeth');
thePlayer.GetInventory().AddItem('Nekker teeth');
thePlayer.GetInventory().AddItem('Nekker claws');
thePlayer.GetInventory().AddItem('Threads');
thePlayer.GetInventory().AddItem('Endriag embryo');
thePlayer.GetInventory().AddItem('Tentadrake eyes');
thePlayer.GetInventory().AddItem('Endriag venom');
thePlayer.GetInventory().AddItem('Wraith Knight Claws');
thePlayer.GetInventory().AddItem('Tentadrake Tissue');
thePlayer.GetInventory().AddItem('Crab spider eyes');
thePlayer.GetInventory().AddItem('Troll tongue');
thePlayer.GetInventory().AddItem('Harphy saliva');
thePlayer.GetInventory().AddItem('Harphy eyes');
thePlayer.GetInventory().AddItem('Necrophage eyes');
thePlayer.GetInventory().AddItem('Necrophage teeth');
thePlayer.GetInventory().AddItem('Endriag Mandible');
thePlayer.GetInventory().AddItem('Nekker Eyes');
thePlayer.GetInventory().AddItem('Nekker Heart');
thePlayer.GetInventory().AddItem('Piece of Dwarven Armor');
thePlayer.GetInventory().AddItem('Oil');
thePlayer.GetInventory().AddItem('Piece of Draug armor');
thePlayer.GetInventory().AddItem('Drowner Brain');
thePlayer.GetInventory().AddItem('Bruxa teeth');

thePlayer.GetInventory().AddItem('Rusty Keychain');
thePlayer.GetInventory().AddItem('Rusty Key');
thePlayer.GetInventory().AddItem('Gate Room Key');
thePlayer.GetInventory().AddItem('Storage key');
thePlayer.GetInventory().AddItem('Bandit hideout key');
thePlayer.GetInventory().AddItem('Upper shaft key');
thePlayer.GetInventory().AddItem('Ves key');
thePlayer.GetInventory().AddItem('Middle shaft key');
thePlayer.GetInventory().AddItem('Lower shaft key');
thePlayer.GetInventory().AddItem('Tower Key');
thePlayer.GetInventory().AddItem('Triss Prison Key');
thePlayer.GetInventory().AddItem('Nilfgaard Camp Key');
thePlayer.GetInventory().AddItem('Prison Key');
thePlayer.GetInventory().AddItem('Rune Key');
thePlayer.GetInventory().AddItem(StringToName("Baltimore's Key"));
thePlayer.GetInventory().AddItem(StringToName("Marietta's Key"));
thePlayer.GetInventory().AddItem(StringToName("Guard's Key"));
thePlayer.GetInventory().AddItem('Secret Passage Key');
thePlayer.GetInventory().AddItem('Old Tower Key');
thePlayer.GetInventory().AddItem(StringToName("Cecil's Rune Key"));
thePlayer.GetInventory().AddItem(StringToName("Detmold's Safe Key"));
thePlayer.GetInventory().AddItem('q214_passage_room_key');
thePlayer.GetInventory().AddItem(StringToName("Geralt's Cell Door"));
thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's key"));
thePlayer.GetInventory().AddItem('Royal Post key');
thePlayer.GetInventory().AddItem('Hideout key');

thePlayer.GetInventory().AddItem('Rotting Meat');
thePlayer.GetInventory().AddItem('Shiny Trinket');
thePlayer.GetInventory().AddItem('Endriag Gland Extract');
thePlayer.GetInventory().AddItem('Phosphorescent Crystal');
thePlayer.GetInventory().AddItem('Thumper');

thePlayer.GetInventory().AddItem('Trigger Mechanism');
thePlayer.GetInventory().AddItem('Iron Frame');
thePlayer.GetInventory().AddItem('Spyglass');
thePlayer.GetInventory().AddItem('Wood rope ladder');
thePlayer.GetInventory().AddItem('Iron rope ladder');
thePlayer.GetInventory().AddItem('Hatchet');
thePlayer.GetInventory().AddItem('Hunting horn');
thePlayer.GetInventory().AddItem('Chandelier');
thePlayer.GetInventory().AddItem('Silver chandelier');
thePlayer.GetInventory().AddItem('Rags');
thePlayer.GetInventory().AddItem('Wire rope');
thePlayer.GetInventory().AddItem('Grapnel');
thePlayer.GetInventory().AddItem('Fishing net');
thePlayer.GetInventory().AddItem('Precious ornament');
thePlayer.GetInventory().AddItem('Stone medallion');
thePlayer.GetInventory().AddItem('Shackles');
thePlayer.GetInventory().AddItem('Pear of anguish');
thePlayer.GetInventory().AddItem('Strange clamp');
thePlayer.GetInventory().AddItem('Iron bangle');
thePlayer.GetInventory().AddItem('Hinges');

}

function allitems5( )
{

thePlayer.GetInventory().AddItem('Tool blades');
thePlayer.GetInventory().AddItem('Precious figurine');
thePlayer.GetInventory().AddItem('Tongs');
thePlayer.GetInventory().AddItem('Primitive necklace');
thePlayer.GetInventory().AddItem('Silver necklace');
thePlayer.GetInventory().AddItem('Enriched silver necklace');
thePlayer.GetInventory().AddItem('Primitive enriched silver necklace');
thePlayer.GetInventory().AddItem('Silver ring');
thePlayer.GetInventory().AddItem('Enriched silver ring');
thePlayer.GetInventory().AddItem('Enriched iron ring');
thePlayer.GetInventory().AddItem('Iron ring');
thePlayer.GetInventory().AddItem('Wire');
thePlayer.GetInventory().AddItem('Chains');
thePlayer.GetInventory().AddItem('Sword blade');
thePlayer.GetInventory().AddItem('Primitive drill');
thePlayer.GetInventory().AddItem('Sword sheath');
thePlayer.GetInventory().AddItem('Enriched sword sheath');
thePlayer.GetInventory().AddItem('Silver sword sheath');
thePlayer.GetInventory().AddItem('Enriched silver sword sheath');
thePlayer.GetInventory().AddItem(StringToName("Kajetan's Talisman"));
thePlayer.GetInventory().AddItem('Heart of Melitele');
thePlayer.GetInventory().AddItem(StringToName("Young's Talisman"));
thePlayer.GetInventory().AddItem('Fish');
thePlayer.GetInventory().AddItem('Apple');
thePlayer.GetInventory().AddItem('Old cheese');
thePlayer.GetInventory().AddItem('Potato');
thePlayer.GetInventory().AddItem('Cucumber');
thePlayer.GetInventory().AddItem('Cup');
thePlayer.GetInventory().AddItem('Bowl');
thePlayer.GetInventory().AddItem('Spoon');
thePlayer.GetInventory().AddItem('Empty bottle');

thePlayer.GetInventory().AddItem('Minor Mutagen of Amplification');
thePlayer.GetInventory().AddItem('Mutagen of Amplification');
thePlayer.GetInventory().AddItem('Major Mutagen of Amplification');
thePlayer.GetInventory().AddItem('Minor Mutagen of Range');
thePlayer.GetInventory().AddItem('Mutagen of Range');
thePlayer.GetInventory().AddItem('Minor Mutagen of Critical Effect');
thePlayer.GetInventory().AddItem('Mutagen of Critical Effect');
thePlayer.GetInventory().AddItem('Major Mutagen of Critical Effect');
thePlayer.GetInventory().AddItem('Minor Mutagen of Vitality');
thePlayer.GetInventory().AddItem('Mutagen of Vitality');
thePlayer.GetInventory().AddItem('Major Mutagen of Vitality');
thePlayer.GetInventory().AddItem('Minor Mutagen of Power');
thePlayer.GetInventory().AddItem('Mutagen of Power');
thePlayer.GetInventory().AddItem('Major Mutagen of Power');
thePlayer.GetInventory().AddItem('Minor Mutagen of Strength');
thePlayer.GetInventory().AddItem('Mutagen of Strength');
thePlayer.GetInventory().AddItem('Major Mutagen of Strength');
thePlayer.GetInventory().AddItem('Mutagen of Concentration');
thePlayer.GetInventory().AddItem('Mutagen of Mutagen of Insanity');

thePlayer.GetInventory().AddItem('Brown Oil');
thePlayer.GetInventory().AddItem('Hangman Venom');
thePlayer.GetInventory().AddItem('Cinfrid Oil');
thePlayer.GetInventory().AddItem('Specter Grease');
thePlayer.GetInventory().AddItem('Caelm');
thePlayer.GetInventory().AddItem('Cerbin Blath');
thePlayer.GetInventory().AddItem('Argentia');
thePlayer.GetInventory().AddItem('Surge');

thePlayer.GetInventory().AddItem('Worn Pants');
thePlayer.GetInventory().AddItem('Quality Leather Pants');
thePlayer.GetInventory().AddItem('High Quality Leather Pants');
thePlayer.GetInventory().AddItem('Heavy Leather Pants');
thePlayer.GetInventory().AddItem('Quality Heavy Leather Pants');
thePlayer.GetInventory().AddItem('High Quality Heavy Leather Pants');
thePlayer.GetInventory().AddItem('Studded Leather Pants');
thePlayer.GetInventory().AddItem('Quality Studded Leather Pants');
thePlayer.GetInventory().AddItem('High Quality Studded Leather Pants');
thePlayer.GetInventory().AddItem('Temerian Unique Leather Pants');
thePlayer.GetInventory().AddItem('High Quality Temerian Unique Leather Pants');
thePlayer.GetInventory().AddItem('Nilfgaardian Unique Leather Pants');
thePlayer.GetInventory().AddItem('High Quality Nilfgaardian Unique Leather Pants');
thePlayer.GetInventory().AddItem('Kaedwenian Unique Leather Pants');

}

function allitems6( )
{

thePlayer.GetInventory().AddItem('Grapeshot');
thePlayer.GetInventory().AddItem('Devil Puffball');
thePlayer.GetInventory().AddItem('Samum');
thePlayer.GetInventory().AddItem('Dancing Star');
thePlayer.GetInventory().AddItem('Dragon Dream');
thePlayer.GetInventory().AddItem('Firefly');
thePlayer.GetInventory().AddItem('Flare');
thePlayer.GetInventory().AddItem('Stinker');
thePlayer.GetInventory().AddItem('Red Haze');

thePlayer.GetInventory().AddItem(StringToName("Candlemaker's Potion Real"));
thePlayer.GetInventory().AddItem('Cat');
thePlayer.GetInventory().AddItem('Swallow');
thePlayer.GetInventory().AddItem('Tawny Owl');
thePlayer.GetInventory().AddItem('Blizzard');
thePlayer.GetInventory().AddItem('Kiss');
thePlayer.GetInventory().AddItem('Marten');
thePlayer.GetInventory().AddItem('Maribor Forest');
thePlayer.GetInventory().AddItem('Shrike');
thePlayer.GetInventory().AddItem('Golden Oriole');
thePlayer.GetInventory().AddItem('Wolf');
thePlayer.GetInventory().AddItem('Wolverine');
thePlayer.GetInventory().AddItem('De Vries Extract');
thePlayer.GetInventory().AddItem('White Raffard Decoction');
thePlayer.GetInventory().AddItem('Petri Philter');
thePlayer.GetInventory().AddItem('Concretion');
thePlayer.GetInventory().AddItem('Thunderbolt');
thePlayer.GetInventory().AddItem('Anabolic');
thePlayer.GetInventory().AddItem('Shadow');
thePlayer.GetInventory().AddItem('Unknown Red Potion');
thePlayer.GetInventory().AddItem('Unknown Green Potion');
thePlayer.GetInventory().AddItem('Unknown Yellow Potion');
thePlayer.GetInventory().AddItem('Unknown Black Potion');

thePlayer.GetInventory().AddItem('q213_soldier_prayer');
thePlayer.GetInventory().AddItem(StringToName("Soldier's Letter"));
thePlayer.GetInventory().AddItem(StringToName("Candlemaker's Potion"));
thePlayer.GetInventory().AddItem('Candlemakers Bill');
thePlayer.GetInventory().AddItem('Gone Patient Charter');
thePlayer.GetInventory().AddItem('Manuscript Wild Gone');
thePlayer.GetInventory().AddItem(StringToName("Gone Explorer's Notes"));
thePlayer.GetInventory().AddItem('Song of Gone');
thePlayer.GetInventory().AddItem(StringToName("Thorak's Secret Notes"));
thePlayer.GetInventory().AddItem(StringToName("Priest's Notes"));
thePlayer.GetInventory().AddItem(StringToName("Garwena's Letter"));
thePlayer.GetInventory().AddItem('Medical Journal');
thePlayer.GetInventory().AddItem(StringToName("Baltimore's Map"));
thePlayer.GetInventory().AddItem(StringToName("Cecil's Map"));
thePlayer.GetInventory().AddItem('Medicine for Gridley');
thePlayer.GetInventory().AddItem('Heart and eyes of murderer');
thePlayer.GetInventory().AddItem('Heart of nekker');
thePlayer.GetInventory().AddItem('Eyes of nekker');
thePlayer.GetInventory().AddItem('Hearts and eyes of ox');
thePlayer.GetInventory().AddItem('Beaver Grass');
thePlayer.GetInventory().AddItem('Xeranthemum');
thePlayer.GetInventory().AddItem('Triss scarf');
thePlayer.GetInventory().AddItem('Troll horn');
thePlayer.GetInventory().AddItem(StringToName("Filippa's Medalion"));
thePlayer.GetInventory().AddItem('Royal Blood');
thePlayer.GetInventory().AddItem('Rose of Remembrance');
thePlayer.GetInventory().AddItem(StringToName("Dragon's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Sabrina's Spear"));
thePlayer.GetInventory().AddItem('Square Coin');
thePlayer.GetInventory().AddItem('Relic Nail');
thePlayer.GetInventory().AddItem('Magic Powder');
thePlayer.GetInventory().AddItem(StringToName("Part of Sabrina's Neckless"));
thePlayer.GetInventory().AddItem('Envoy Flag');
thePlayer.GetInventory().AddItem(StringToName("Sheala's Protection Amulet"));
thePlayer.GetInventory().AddItem('Armor Part');
thePlayer.GetInventory().AddItem('Banner');
thePlayer.GetInventory().AddItem(StringToName("Commander's Sword"));
thePlayer.GetInventory().AddItem('Medallion');
thePlayer.GetInventory().AddItem('Strange Liquid');
thePlayer.GetInventory().AddItem('Mucus Antidote');
thePlayer.GetInventory().AddItem(StringToName("Filippa's Dagger"));
thePlayer.GetInventory().AddItem(StringToName("Detmold's Cell Key"));
thePlayer.GetInventory().AddItem('Siegfrieds Signet Ring');
thePlayer.GetInventory().AddItem('Stuffed Troll Head');
thePlayer.GetInventory().AddItem(StringToName("Seltkirk's Chainmail"));
thePlayer.GetInventory().AddItem('Endriag Queen Pheromones');
thePlayer.GetInventory().AddItem('Elder Nekker Blood');
thePlayer.GetInventory().AddItem('True recipe');
thePlayer.GetInventory().AddItem('Fake recipe');
thePlayer.GetInventory().AddItem('Bullvore Brain');
thePlayer.GetInventory().AddItem('Harpy Egg');
thePlayer.GetInventory().AddItem(StringToName("Baltimore's Notes"));
thePlayer.GetInventory().AddItem(StringToName("Malget's Notes"));
thePlayer.GetInventory().AddItem('Enchanted Dream');
thePlayer.GetInventory().AddItem('Magical Crystal');
thePlayer.GetInventory().AddItem(StringToName("Leto's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Cecil's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Peasant's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Baltimore's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Iorweth's Dream"));
thePlayer.GetInventory().AddItem(StringToName("Metal fragment"));
thePlayer.GetInventory().AddItem(StringToName("Cedric's Map"));
thePlayer.GetInventory().AddItem('Pamphlet smearing Henselt');
thePlayer.GetInventory().AddItem('q201_magic_shield');
thePlayer.GetInventory().AddItem('magic_shield_no_buble');
thePlayer.GetInventory().AddItem('follower_observer_item');
thePlayer.GetInventory().AddItem('Surgical tools');
thePlayer.GetInventory().AddItem('Balista Part');
thePlayer.GetInventory().AddItem(StringToName("Filippa's Notes"));
thePlayer.GetInventory().AddItem(StringToName("Filippa's Poison"));
thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Journal"));
thePlayer.GetInventory().AddItem(StringToName("Petra Sillie Captain's Report"));
thePlayer.GetInventory().AddItem(StringToName("Eyla Tarn Captain's Journal"));
thePlayer.GetInventory().AddItem(StringToName("Loredo's Letter"));
thePlayer.GetInventory().AddItem(StringToName("Ludwig Merse's Report"));
thePlayer.GetInventory().AddItem(StringToName("Dun Banner's Cloak"));
thePlayer.GetInventory().AddItem(StringToName("Beaver's Hat"));

}

function allitems7( )
{

thePlayer.GetInventory().AddItem('Mysterious Tablet');

thePlayer.GetInventory().AddItem('Rusty Balanced Dagger');
thePlayer.GetInventory().AddItem('Balanced Dagger');
thePlayer.GetInventory().AddItem('Quality Balanced Dagger');
thePlayer.GetInventory().AddItem('High Quality Balanced Dagger');
thePlayer.GetInventory().AddItem('Silver Balanced Dagger');
thePlayer.GetInventory().AddItem('Quality Silver Balanced Dagger');
thePlayer.GetInventory().AddItem('High Quality Silver Balanced Dagger');
thePlayer.GetInventory().AddItem('Sting');
thePlayer.GetInventory().AddItem('Poisoned flying harphy claws');
thePlayer.GetInventory().AddItem('Rune of Sun');
thePlayer.GetInventory().AddItem('Rune of Ysgith');
thePlayer.GetInventory().AddItem('Rune of Earth');
thePlayer.GetInventory().AddItem('Rune of Moon');
thePlayer.GetInventory().AddItem('Rune of Fire');

thePlayer.GetInventory().AddItem('Witcher Silver Sword');
thePlayer.GetInventory().AddItem('Quality Witcher Silver Sword');
thePlayer.GetInventory().AddItem('High Quality Witcher Silver Sword');
thePlayer.GetInventory().AddItem('Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Quality Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Quality Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Quality Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('High Quality Blue Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('High Quality Red Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('High Quality Yellow Meteorite Silver Sword');
thePlayer.GetInventory().AddItem('Unique Silver Sword');
thePlayer.GetInventory().AddItem('Unique Silver Meteorite Sword');
thePlayer.GetInventory().AddItem('Fate');
thePlayer.GetInventory().AddItem('Negotiator');
thePlayer.GetInventory().AddItem('Naevde Seidhe');
thePlayer.GetInventory().AddItem('Caerme');
thePlayer.GetInventory().AddItem('Harpy');
thePlayer.GetInventory().AddItem('Moonblade');
thePlayer.GetInventory().AddItem('Blood Sword');
thePlayer.GetInventory().AddItem('Gvalchca');
thePlayer.GetInventory().AddItem('Gynvael aedd');
thePlayer.GetInventory().AddItem('Deithwen');
thePlayer.GetInventory().AddItem('Draug Testimony');
thePlayer.GetInventory().AddItem('Addan deith');

thePlayer.GetInventory().AddItem('Rusty Steel Sword');
thePlayer.GetInventory().AddItem('Aedirnian Short Sword');
thePlayer.GetInventory().AddItem('Aedirnian Light Sword');
thePlayer.GetInventory().AddItem('Aedirnian Red Sword');
thePlayer.GetInventory().AddItem('Caingornian Steel Sword');
thePlayer.GetInventory().AddItem('Yspadenian Steel Sword');
thePlayer.GetInventory().AddItem('Creydenian Steel Sword');
thePlayer.GetInventory().AddItem('Temerian Steel Sword');
thePlayer.GetInventory().AddItem('Temerian Elite Sword');
thePlayer.GetInventory().AddItem('Temerian Essenced Sword');
thePlayer.GetInventory().AddItem('Short Steel Sword');
thePlayer.GetInventory().AddItem('Quality Short Steel Sword'); 
thePlayer.GetInventory().AddItem('High Quality Short Steel Sword'); 
thePlayer.GetInventory().AddItem('Long Steel Sword'); 
thePlayer.GetInventory().AddItem('Quality Long Steel Sword'); 
thePlayer.GetInventory().AddItem('High Quality Long Steel Sword'); 
thePlayer.GetInventory().AddItem('Hunting Steel Sword'); 
thePlayer.GetInventory().AddItem('Quality Hunting Steel Sword');
thePlayer.GetInventory().AddItem('High Quality Hunting Steel Sword'); 
thePlayer.GetInventory().AddItem('Caerme');
thePlayer.GetInventory().AddItem('Jagged Blade');
thePlayer.GetInventory().AddItem('Peacemaker');
thePlayer.GetInventory().AddItem('Angivare');
thePlayer.GetInventory().AddItem('Deireadh');
thePlayer.GetInventory().AddItem('Kaedwenian Steel Sword');
thePlayer.GetInventory().AddItem('Kaedwenian Quality Sword');
thePlayer.GetInventory().AddItem('Kaedwenian Black Sword');
thePlayer.GetInventory().AddItem('Dol Blathanna Quality Steel Blade');
thePlayer.GetInventory().AddItem('Dol Blathanna High Quality Steel Blade');
thePlayer.GetInventory().AddItem('Zerrikan Steel Sabre');
thePlayer.GetInventory().AddItem('Zerrikan Poisoned Steel Sabre');
thePlayer.GetInventory().AddItem('Elven Short Sihil');
thePlayer.GetInventory().AddItem('Elven Sword');
thePlayer.GetInventory().AddItem('Elven Sword of Blue Mountains');
thePlayer.GetInventory().AddItem('Mahakaman Steel Sihil');
thePlayer.GetInventory().AddItem('Quality Dueling Steel Sword');
thePlayer.GetInventory().AddItem('High Quality Dueling Steel Sword');
thePlayer.GetInventory().AddItem('Gwyhyr');
thePlayer.GetInventory().AddItem('Harvall');
thePlayer.GetInventory().AddItem('Ceremonial Steel Sword of Deithwen');
thePlayer.GetInventory().AddItem('Forgotten Sword of Vrans');
thePlayer.GetInventory().AddItem('Executioner Rod');
thePlayer.GetInventory().AddItem('Nilfgaardian Steel Sword');
thePlayer.GetInventory().AddItem('Nilfgaardian Harphy Sword');
thePlayer.GetInventory().AddItem('Nilfgaardian Essenced Sword');
thePlayer.GetInventory().AddItem('Stennis Sword');

thePlayer.GetInventory().AddItem('Explosive Trap');
thePlayer.GetInventory().AddItem('Crippling Trap');
thePlayer.GetInventory().AddItem('Freezing Trap');
thePlayer.GetInventory().AddItem('Rage Trap');
thePlayer.GetInventory().AddItem('Grappling Trap');
thePlayer.GetInventory().AddItem('Trap Linker');
thePlayer.GetInventory().AddItem('Harpy Bait Trap');
thePlayer.GetInventory().AddItem('Nekker Stun Trap');
thePlayer.GetInventory().AddItem('Tentadrake Trap');
thePlayer.GetInventory().AddItem('Draug Trap');
thePlayer.GetInventory().AddItem('Dragon Trap');
thePlayer.GetInventory().AddItem('Animal Trap');
thePlayer.GetInventory().AddItem('Used Trap');

thePlayer.GetInventory().AddItem('Nekkers Trophy');
thePlayer.GetInventory().AddItem('Endriags Trophy');
thePlayer.GetInventory().AddItem('Harpy Trophy');
thePlayer.GetInventory().AddItem('Necrophage Trophy');
thePlayer.GetInventory().AddItem('Bulvore Trophy');
thePlayer.GetInventory().AddItem('Troll Trophy');
thePlayer.GetInventory().AddItem('Drowner Trophy');
thePlayer.GetInventory().AddItem('Tentadrake Trophy');
thePlayer.GetInventory().AddItem('Rotfiend Trophy');
thePlayer.GetInventory().AddItem('Draug Trophy');
thePlayer.GetInventory().AddItem('Wraith Trophy');
thePlayer.GetInventory().AddItem('Wraith Knight TrophyT');
thePlayer.GetInventory().AddItem('Golem Trophy');
thePlayer.GetInventory().AddItem('Gargoyle Trophy');
thePlayer.GetInventory().AddItem('Elemental Trophy');
thePlayer.GetInventory().AddItem('Arachas Trophy');
}


exec function allitems()
{
allitems1( );
allitems2( );
allitems3( );
allitems4( );
allitems5( );
}
