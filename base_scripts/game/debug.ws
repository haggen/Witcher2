/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Functions used for debug purposes
/** Copyright © 2009
/***********************************************************************/

////////////////////////////////////////////////////////////////////////////////
// ENGINE
////////////////////////////////////////////////////////////////////////////////

// Enable all loaded explorations
exec function EnableAllExplorations()
{
	var explorations : array<CNode>;
	var singleEntity : CEntity;
	var i : int;
	
	theGame.GetNodesByTag( 'exploration', explorations );
	
	for( i=0; i<explorations.Size(); i+=1 )
	{
		explorations[i] = (CEntity) singleEntity;
		
		singleEntity.GetComponentByClassName( 'CExplorationAreaComponent' ).SetEnabled(true);
	}
}

// Toggle show flags
exec function ShowFlags( showFlags : EShowFlags )
{
	var enabled : bool;
	enabled = theGame.IsShowFlagEnabled( showFlags );
	theGame.SetShowFlag( showFlags, !enabled );
}

exec function ShowLayer( tag : name )
{
	// DEPRECATED, use ShowLayerGroup() instead
	//theGame.GetWorld().ShowLayers( tag, true );
}

exec function HideLayer( tag : name )
{
	// DEPRECATED, use ShowLayerGroup() instead
	// theGame.GetWorld().ShowLayers( tag, false );
}

exec function ActivePause()
{
	theGame.SetActivePause( !theGame.IsActivelyPaused() );
}

exec function DumpClasses( baseClass : name )
{
	if( !DumpClassHierarchy( baseClass ) )
	{
		Logf("DebugDumpClasses: class %1 not found", baseClass );
	}
}

exec function DebugPlayCutscene( csName : string, tag : name )
{
	var aNames : array< string >;
	var aEnt : array< CEntity >;
	var csPos : Vector;
	var csRot : EulerAngles;
	
	csPos = theGame.GetNodeByTag( tag ).GetWorldPosition();
	csRot = theGame.GetNodeByTag( tag ).GetWorldRotation();
	
	theGame.PlayCutsceneAsync( csName, aNames, aEnt, csPos, csRot );
}

exec function DebugActor( tag : name, flag : bool )
{
	var actor : CActor;
	
	actor = theGame.GetNPCByTag( tag );
	
	if ( actor )
	{
		actor.DebugDumpEntryFunctionCalls( flag );
		Log( "DebugActor " + tag + flag );
	}
	else
	{
		Log( "DebugActor ERROR - Couldn't find actor " + tag );
	}
}

exec function DebugForceRain()
{
	theGame.GetReactionsMgr().DebugForceRain();
}

////////////////////////////////////////////////////////////////////////////////
// CAMERA
////////////////////////////////////////////////////////////////////////////////

exec function CameraInfo()
{
	var camPos, diff : Vector;
	var posStr : string;
	
	//camPos = MatrixGetTranslation( theCamera.GetCameraMatrixWorldSpace() );
	//Log( theCamera.GetCurrentBehaviorState() );
	//Log( theCamera.GetFov() );
	
	//diff = thePlayer.GetWorldPosition() - camPos;
	//posStr = VecToString( diff );
	
	//Log( posStr );
}

exec function CameraInterior()
{
	theCamera.RaiseEvent( 'Camera_Interior' );
}

exec function CameraExploration()
{
	theCamera.RaiseEvent( 'Camera_Exploration' );
}

exec function CameraWide()
{
	theCamera.RaiseEvent( 'Camera_Zagnica' );
}

exec function cameraSetFOV(lFOV : float)
{
	theCamera.SetFov(lFOV);
}

// Toggle free camera
exec function FreeCamera()
{
	theGame.EnableFreeCamera( !theGame.IsFreeCameraEnabled() );
}

////////////////////////////////////////////////////////////////////////////////
// PLAYER
////////////////////////////////////////////////////////////////////////////////

exec function F12( enable : bool )
{
	thePlayer.EnablePhysicalMovement( enable );
}

exec function TestRagdoll( enable : bool )
{	
	if ( enable )
	{
		thePlayer.SetBehaviorVariable( "Ragdoll_Weight", 1.0f );
	}
	else
	{
		thePlayer.SetBehaviorVariable( "Ragdoll_Weight", 0.0f );
	}
}

// Toggle god mode
exec function GodMode()
{
	if( thePlayer.GetImmortalityModePersistent() != AIM_Invulnerable )
		thePlayer.SetImmortalityModePersistent( AIM_Invulnerable );
	else
		thePlayer.SetImmortalityModePersistent( AIM_None );
}

// Resurrect player
exec function Resurrect()
{
	thePlayer.OnResurect();
	thePlayer.PlayerStateCallEntryFunction( PS_Exploration, '' );
}

// Resurrect player short version
exec function Res()
{
	thePlayer.OnResurect();
	thePlayer.PlayerStateCallEntryFunction( PS_Exploration, '' );
}

// Toggle immortal mode
exec function Immortal()
{
	if( thePlayer.GetImmortalityModePersistent() != AIM_Immortal )
		thePlayer.SetImmortalityModePersistent( AIM_Immortal );
	else
		thePlayer.SetImmortalityModePersistent( AIM_None );
}

exec function Cat()
{
	thePlayer.EnableCatEffect( !thePlayer.IsCatEffectEnabled() );
}

exec function Stamia()
{
	thePlayer.IncreaseStamina( thePlayer.initialStamina );
}

exec function PlayerInfo()
{
	PlayerState();
}

exec function LogCombatArea()
{
	var aiParams : CAIParams;
	aiParams = theGame.GetAIParams();
	aiParams.debugLogCombatArea = !aiParams.debugLogCombatArea;
}

exec function KillPlayer()
{
	thePlayer.Kill();
}

exec function SetPlayerState( newState : EPlayerState )
{
	thePlayer.UnblockPlayerState( newState );
	thePlayer.ChangePlayerState( newState );
};

exec function Fists()
{
	thePlayer.UnblockPlayerState( PS_CombatFistfightDynamic );
	thePlayer.ChangePlayerState( PS_CombatFistfightDynamic );
}

exec function SetSneakMode()
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

exec function PlayerIdle()
{
	thePlayer.RaiseForceEvent('Idle');
	thePlayer.RaiseEvent('Idle');
}

exec function ResetPlayer()
{
	thePlayer.SetAllPlayerStatesBlocked( false );
	thePlayer.PlayerStateCallEntryFunction(PS_Exploration, '' );	
}

//SL: skrocona wersja Reset Player
exec function RP()
{
	thePlayer.SetAllPlayerStatesBlocked( false );
	thePlayer.PlayerStateCallEntryFunction(PS_Exploration, '' );	
}


exec function Hidden()
{
	thePlayer.SetIsHidden( !thePlayer.IsHidden() );
}

exec function DebugTakedown()
{
	var takedownParams : STakedownParams;
	var st : EPlayerState;
	if( thePlayer.GetEnemy() )
	{
		SetupTakedownParamsDefault( thePlayer.GetEnemy(), takedownParams, );
		st = thePlayer.GetCurrentPlayerState();
		thePlayer.TakedownActor( st, takedownParams );
	}
}

////////////////////////////////////////////////////////////////////////////////
// NPC
////////////////////////////////////////////////////////////////////////////////
exec function KillNPC( npcName : string )
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByName( npcName );	
	npc.Kill(true);
}

exec function StunNPC( npcName : string )
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByName( npcName );	
	npc.Stun(true);
}

exec function NPCHostile( npcName : string )
{
	var npc : CNewNPC;
	npc = theGame.GetNPCByName( npcName );
	npc.SetAlive(true);
	npc.SetAttitude( thePlayer, AIA_Hostile );
}

exec function NPCInfo()
{
	AIState();
}

exec function AIInfo( mode : name )
{
	var game : CWitcherGame;	
	game = theGame;
	game.aiInfoDisplayMode = mode;
}

exec function BTLog( flag : int )
{
	var b : bool;
	var aiParams : CAIParams;
	aiParams = theGame.GetAIParams();
	b = false;
	if( flag != 0 )
		b = true;
	aiParams.debugLogBehTree = b;
}

exec function BTDebug( npcName : string )
{
	var npc : CNewNPC;	
	npc = theGame.GetNPCByName( npcName );
	DebugBehTreeStart( npc.GetBehTreeMachine() );
}

exec function BTDebugStop()
{
	DebugBehTreeStopAll();
}

////////////////////////////////////////////////////////////////////////////////
// TIME
////////////////////////////////////////////////////////////////////////////////

// Sets engine time scale
exec function SetTimeScale( ts : float )
{
	theGame.SetTimeScale( ts );
}

exec function SetHoursPerMin( f : float )
{
	theGame.SetHoursPerMinute( f );
}

exec function SetWorldTime(hr: int, min : int, sec : int)
{
	var time : GameTime;
	 
	time = GameTimeCreate( hr, min, sec );
	
	theGame.SetGameTime (time, false);
}

exec function StartSepia( f : float )
{
	theGame.StartSepiaEffect( f );
}

exec function StopSepia( f : float )
{
	theGame.StopSepiaEffect( f );
}

////////////////////////////////////////////////////////////////////////////////
// DEBUG MENU
////////////////////////////////////////////////////////////////////////////////

function DebugMenuEntriesGet( out entries : array< string > )
{
	entries.PushBack( "Exit" );
	entries.PushBack( "Inventory" );
	entries.PushBack( "Character" );
	entries.PushBack( "Journal" );
	entries.PushBack( "Alchemy" );
	entries.PushBack( "Crafting" );
	entries.PushBack( "" );
	entries.PushBack( "Toggle free camera" );
	entries.PushBack( "Teleport to camera" );
	entries.PushBack( "Custom script" );
}

function DebugMenuEntrySelect( selection : int )
{
	if ( selection == 0 )
	{
		theGame.ExitGame();
	}
	else if ( selection == 1 )
	{
		theHud.ShowInventory();
	}
	else if ( selection == 2 )
	{
		theHud.ShowCharacter( true );
	}
	else if ( selection == 3 )
	{
		theHud.ShowJournal();
	}
	else if ( selection == 4 )
	{
		theHud.ShowAlchemyNew();
	}
	else if ( selection == 5 )
	{
		theHud.ShowCraft();
	}
	else if ( selection == 7 )
	{
		theGame.EnableFreeCamera( ! theGame.IsFreeCameraEnabled() );
	}
	else if ( selection == 8 )
	{
		thePlayer.Teleport( theGame.GetActiveCameraComponent().GetWorldPosition() );
		theGame.EnableFreeCamera( false );
	}
	else if ( selection == 9 )
	{
		CustomScript();
	}
}

//SL: tempshit na czas problemow z literkami w konsoli -> GodMode
exec function G()
{
	GodMode();
}

exec function SWT(hr: int, min : int, sec : int)
{
	var time : GameTime;
	 
	time = GameTimeCreate( hr, min, sec );
	
	theGame.SetGameTime (time, false);
}

exec function AddFactDebug( fact : string, value : int )
{
	FactsAdd( fact, value );
}

exec function Sq303DebugItems()
{
	thePlayer.GetInventory().AddItem('Elder Nekker Blood', 1);
	thePlayer.GetInventory().AddItem('Endriag Queen Pheromones', 1);
	thePlayer.GetInventory().AddItem('Bullvore Brain', 1);
	thePlayer.GetInventory().AddItem('Rotfiend Tongue', 1);
}

exec function domek( on : bool )
{
	if ( on )
	{
		theGame.StreamWorldPartition( "house02_interior" );
	}
	else
	{
		theGame.StreamWorldPartition( "always_loaded" );
	}
}

exec function ImBroke()
{
	var orensId : SItemUniqueId;
	var orensQt : int;
	
	orensId = thePlayer.GetInventory().GetItemId( 'Orens' );
	orensQt = thePlayer.GetInventory().GetItemQuantity( orensId );
	thePlayer.GetInventory().RemoveItem( orensId, orensQt );
}

exec function XXX()
{
	var jaskier : CEntity;
	var zoltan : CEntity;
	var woman_hanger : CEntity;
	var man_hanger : CEntity;
	
	var elfHanger : CAnimatedComponent;
	var womanElfHanger : CAnimatedComponent;
	var jaskier_component: CAnimatedComponent;
	var zoltan_component: CAnimatedComponent;
	
	var ropeJaskier : CAnimatedComponent;
	var ropeZoltan : CAnimatedComponent;
	var ropeElfHanger : CAnimatedComponent;            
	var ropeWomanElfHanger : CAnimatedComponent;
	
	jaskier = theGame.GetEntityByTag( 'Dandelion' );
	zoltan = theGame.GetEntityByTag( 'Zoltan' );
	woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
	man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );  
	
	elfHanger = (CAnimatedComponent) man_hanger.GetRootAnimatedComponent();
	womanElfHanger = (CAnimatedComponent) woman_hanger.GetRootAnimatedComponent();
	jaskier_component = (CAnimatedComponent)jaskier.GetRootAnimatedComponent();
	zoltan_component = (CAnimatedComponent)zoltan.GetRootAnimatedComponent();
	
	ropeJaskier = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope1');
	ropeZoltan = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope2');
	ropeElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope3');
	ropeWomanElfHanger = (CAnimatedComponent) theGame.GetEntityByTag('q102_gallow').GetComponent('rope4');
	
	if ( !ropeJaskier.RaiseBehaviorForceEvent('hanging_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na linie jaskra"); }
	if ( !ropeZoltan.RaiseBehaviorForceEvent('hanging_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na linie zoltana"); }
	if ( !ropeElfHanger.RaiseBehaviorForceEvent('hanging_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na linie elfa"); }
	if ( !ropeWomanElfHanger.RaiseBehaviorForceEvent('hanging_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na linie elfki"); }

	if ( !jaskier.RaiseForceEvent('hanging_jaskier_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na jaskrze"); }
	if ( !zoltan.RaiseForceEvent('hanging_off') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na zoltanie"); }
	if ( !woman_hanger.RaiseForceEvent('woman_hanger') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na elfce"); }
	if ( !man_hanger.RaiseForceEvent('man_elf_hanger') ) { Log("ERRRRRRRRRRROOOOOOOORRRRRRRRRRRRRRR - beh event na elfie"); }
}

exec function CounterTest( id: int )
{
	theHud.m_hud.SetTrackQuestInfo( "ZLECENIE NA Nekkery", "Zniszcz gniazda nekkerow." );
	theHud.m_hud.SetTrackQuestProgress( id );
}

exec function IsShitOn()
{
	Log( "the shit is: " + theGame.GetGameplayChoice() );
}

exec function dbg_gui_msg( msg : string )
{
	theHud.m_messages.ShowInformationText( msg );
}

exec function AddAbility(ablName : name)
{
	thePlayer.GetCharacterStats().AddAbility(ablName);
}

////////////////////////////////////////////////////////////////////////////////
// DEBUG GUI
////////////////////////////////////////////////////////////////////////////////

exec function testgui()
{
	guitest();
}

exec function guitest()
{
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	
	thePlayer.GetInventory().AddItem( 'Orens', 10000 );
	
	// mutagens
	thePlayer.GetInventory().AddItem( 'Mutagen of Range' );
	thePlayer.GetInventory().AddItem( 'Minor Mutagen of Range' );
	thePlayer.GetInventory().AddItem( 'Mutagen of Amplification' );
	thePlayer.GetInventory().AddItem( 'Mutagen of Critical Effect' );
	thePlayer.GetInventory().AddItem( 'Mutagen of Vitality' );
	
	// elixirs
	thePlayer.GetInventory().AddItem( 'Tawny Owl' );
	thePlayer.GetInventory().AddItem( 'Swallow' );
	thePlayer.GetInventory().AddItem( 'Thunderbolt' );
	thePlayer.GetInventory().AddItem( 'Concretion' );
	
	// recipes
	thePlayer.GetInventory().AddItem( 'Recipe Wolverine' );
	thePlayer.GetInventory().AddItem( 'Recipe Marten' );
	thePlayer.GetInventory().AddItem( 'Recipe Blizzard' );
	thePlayer.GetInventory().AddItem( 'Recipe Maribor Forest' );
	thePlayer.GetInventory().AddItem( 'Recipe Golden Oriole' );
	thePlayer.GetInventory().AddItem( 'Recipe De Vries Extract' );
	
	
	// alchemy ingridients
	thePlayer.GetInventory().AddItem( 'Diamond Dust', 2 );
	thePlayer.GetInventory().AddItem( 'Amethyst Dust', 3 );
	thePlayer.GetInventory().AddItem( 'Endriag saliva', 1 );
	thePlayer.GetInventory().AddItem( 'Endriag teeth', 2 );
	thePlayer.GetInventory().AddItem( 'Nekker teeth', 1 );
	thePlayer.GetInventory().AddItem( 'Endriag embryo', 3 );
	thePlayer.GetInventory().AddItem( 'Wraith Knight Claws', 4 );
	thePlayer.GetInventory().AddItem( 'Tentadrake Tissue', 2 );
	thePlayer.GetInventory().AddItem( 'Crab spider eyes', 1 );
	thePlayer.GetInventory().AddItem( 'Troll tongue' );
	thePlayer.GetInventory().AddItem( 'Harphy saliva' );
	thePlayer.GetInventory().AddItem( 'Harphy eyes' );
	thePlayer.GetInventory().AddItem( 'Necrophage eyes' );
	thePlayer.GetInventory().AddItem( 'Necrophage teeth' );
	thePlayer.GetInventory().AddItem( 'Endriag Mandible' );
	thePlayer.GetInventory().AddItem( 'Nekker Eyes' );
	thePlayer.GetInventory().AddItem( 'Nekker Heart' );
	thePlayer.GetInventory().AddItem( 'Piece of Dwarven Armor' );
	thePlayer.GetInventory().AddItem( 'Drowner Brain', 5 );
	thePlayer.GetInventory().AddItem( 'Bruxa teeth' );
	thePlayer.GetInventory().AddItem( 'Wolfsbane', 5 );
	thePlayer.GetInventory().AddItem( 'Verbena', 5 );
	
	// crafting schematics
	thePlayer.GetInventory().AddItem( 'Schematic Vran Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Leather Jacket' );
	thePlayer.GetInventory().AddItem( 'Schematic Heavy Leather Jacket' );
	thePlayer.GetInventory().AddItem( 'Schematic Quality Leather Jacket' );
	thePlayer.GetInventory().AddItem( 'Schematic Light Leather Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Heavy Elven Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Ravens Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Tentadrake Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Draug Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Dearg Ruadhri' );
	thePlayer.GetInventory().AddItem( 'Schematic Armor of Tir' );
	thePlayer.GetInventory().AddItem( 'Schematic Ysgith Armor' );
	thePlayer.GetInventory().AddItem( 'Schematic Armor of Ys' );
	thePlayer.GetInventory().AddItem( 'Schematic Reinforced Leather Boots' );
	thePlayer.GetInventory().AddItem( 'Schematic Hardened Leather Boots' );
	thePlayer.GetInventory().AddItem( 'Schematic Long Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Schematic Long Studded Leather Gloves' );
	thePlayer.GetInventory().AddItem( 'Schematic Quality Long Gloves' );
	thePlayer.GetInventory().AddItem( 'Schematic High Quality Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Schematic Heavy Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Schematic Studded Leather Pants' );
	thePlayer.GetInventory().AddItem( 'Schematic Rune of Sun' );
	thePlayer.GetInventory().AddItem( 'Schematic Rune of Ysgith' );
	thePlayer.GetInventory().AddItem( 'Schematic Rune of Earth' );
	thePlayer.GetInventory().AddItem( 'Schematic Rune of Moon' );
	thePlayer.GetInventory().AddItem( 'Schematic Rune of Fire' );
	thePlayer.GetInventory().AddItem( 'Schematic Amethyst Armor Enhancement' );
	thePlayer.GetInventory().AddItem( 'Schematic Diamond Armor Enhancement' );
	thePlayer.GetInventory().AddItem( 'Schematic Tentadrake Armor Enhancement' );
	thePlayer.GetInventory().AddItem( 'Schematic Endriag Armor Enhancement' );
	thePlayer.GetInventory().AddItem( 'Schematic Mystic Armor Enhancement' );
	thePlayer.GetInventory().AddItem( 'Schematic Explosive Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Crippling Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Freezing Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Rage Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Grappling Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Harpy Bait Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Nekker Stun Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Tentadrake Trap' );
	thePlayer.GetInventory().AddItem( 'Schematic Balanced Dagger' );
	thePlayer.GetInventory().AddItem( 'Schematic Caerme' );
	
	// crafting ingredients
	thePlayer.GetInventory().AddItem('Ysgith Armor', 1 );
	thePlayer.GetInventory().AddItem('Vrans Armor Enhancement', 10 );
	thePlayer.GetInventory().AddItem('Studded leather', 10 );
	thePlayer.GetInventory().AddItem('Cloth', 10);
	thePlayer.GetInventory().AddItem('Leather', 15);
	thePlayer.GetInventory().AddItem('Threads', 20);
	thePlayer.GetInventory().AddItem('Hardened leather', 10);
	thePlayer.GetInventory().AddItem('Endriag skin', 10);
	thePlayer.GetInventory().AddItem('Oil', 10);
	
	// enchancements
	thePlayer.GetInventory().AddItem( 'Rune of Sun', 10 );
	thePlayer.GetInventory().AddItem( 'Brown Oil', 10 );
	thePlayer.GetInventory().AddItem( 'Hangman Venom', 10 );
	thePlayer.GetInventory().AddItem( 'Crinfrid Oil', 10 );

	// weapons
	thePlayer.GetInventory().AddItem('Forgotten Sword of Vrans');
	thePlayer.GetInventory().AddItem('Rusty Steel Sword');
	thePlayer.GetInventory().AddItem('Witcher Silver Sword');
	thePlayer.GetInventory().AddItem('Negotiator');
	
	// bombs
	thePlayer.GetInventory().AddItem('Dancing Star', 3);
	thePlayer.GetInventory().AddItem('Samum', 1);
	thePlayer.GetInventory().AddItem('Dragon Slumber', 3);
	
	// lures
	thePlayer.GetInventory().AddItem('Rotting Meat');
}

exec function test_journal_entry()
{
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Jessica", "Alba", 'Beautiful', "filippanotes_256x512" );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry", "Winstead", 'Beautiful', "filippanotes_512x512" );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry1", "Winstead1", 'Beautiful', "map_quest_560x560" );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry2", "Winstead2", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry3", "Winstead3", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry4", "Winstead4", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry5", "Winstead5", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry6", "Winstead6", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Monsters, "Merry7", "Winstead7", 'Beautiful' );
	
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful1' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "Merry7", "Winstead7", 'Beautiful' );
}

exec function test_journal_categories()
{
	thePlayer.AddJournalEntry( JournalGroup_Places,     "places", 		"places1", 		'place', 		"" );
	thePlayer.AddJournalEntry( JournalGroup_Characters, "characters", 	"characters1", 	'character', 	"" );
	thePlayer.AddJournalEntry( JournalGroup_Monsters,   "monsters", 	"monsters1", 	'monster', 		"" );
	thePlayer.AddJournalEntry( JournalGroup_Crafting,   "crafting", 	"crafting1", 	'crafting', 	"" );
	thePlayer.AddJournalEntry( JournalGroup_Tutorial,   "tutorials", 	"tutorials1", 	'tutorial', 	"" );
	thePlayer.AddJournalEntry( JournalGroup_Alchemy,    "alchemy", 		"alchemy1", 	'alchemy', 		"" );
	thePlayer.AddJournalEntry( JournalGroup_Glossary,   "glossary", 	"glossary1", 	'glossary', 	"" );
	thePlayer.AddJournalEntry( JournalGroup_Flashback,  "flashback", 	"flashback1", 	'flashback', 	"" );	
}

exec function open_nav()
{
	theHud.ShowNav();
}

exec function close_nav()
{
	theHud.HideNav();
}

exec function open_alch()
{
	theHud.ShowAlchemyNew();
}

exec function close_alch()
{
	theHud.HideAlchemyNew();
}

exec function open_med()
{
	theHud.ShowMeditation();
}

exec function close_med()
{
	theHud.HideMeditation();
}

exec function open_elix()
{
	theHud.ShowElixirs();
}

exec function close_elix()
{
	theHud.HideElixirs();
}

exec function open_over()
{
	theHud.ShowOverview();
}

exec function close_over()
{
	theHud.HideOverview();
}

exec function open_char()
{
	theHud.ShowCharacter(true);
}

exec function close_char()
{
	theHud.HideCharacter();
}

exec function open_sleep()
{
	theHud.ShowSleep();
}

exec function close_sleep()
{
	theHud.HideSleep();
}

exec function show_hud()
{
	theHud.ShowHud();
}

exec function hide_hud()
{
	theHud.HideHud();
}

exec function open_crafting()
{
	theHud.ShowCraft();
}

exec function close_crafting()
{
	theHud.HideCraft();
}

exec function ClearPlayerInventory()
{
	thePlayer.GetInventory().RemoveAllItems();
}

exec function StartEnvironment( AreaEnvironment: string )
{
	AreaEnvironmentActivate(AreaEnvironment);
}

exec function LogTime()
{
	Log( "Current game time : " + GameTimeHours( theGame.GetGameTime() ) + ":" + GameTimeMinutes( theGame.GetGameTime() ) );
}
////////////////////////////////////////////////////////////////////////////////

exec function IsGodModeEnabled()
{
	if( thePlayer.GetImmortalityModePersistent() != AIM_Invulnerable )
	{
		LogChannel( 'debug', "GOD mode is disabled" );
	}
	else
	{
		LogChannel( 'debug', "GOD mode is enabled" );
	}
}

exec function HideGui()
{
	theHud.HideGui();
}

exec function ShowGui()
{
	theHud.ShowGui();
}

exec function KK()
{
	var npcs : array< CNewNPC >;
	theGame.GetAllNPCs( npcs );	
	npcs[ 0 ].Kill(true);	
}

exec function EnableRagdolls( decision: bool )
{
	var i : int;
	var npcs : array< CNewNPC >;
	theGame.GetAllNPCs( npcs );	
	for( i=0; i<npcs.Size(); i+=1 )
	{
		npcs[ 0 ].EnableRagdoll( decision );	

	}
	
	thePlayer.EnableRagdoll( decision );
}

exec function testServer()
{
	theServer.Connect();
	if ( theServer.IsConnected() )
	{
		Log( "KONEKTED!" );
	}
	else
	{
		Log( "NIEKONIECZNIE KONEKTED..." );
	}
	
	theServer.ArenaLogWave( 1, 102, 2 );
	theServer.ArenaLogWave( 2, 240, 3 );
	
	if ( theServer.SendPoints( 100 ) )
	{
		Log( "SEND SUCCESSFUL" );
	}
	else
	{
		Log( "SHIT HAPPENED" );
	}
	
	theServer.Disconnect();
}

exec function TestRel()
{
	var release : string = theGame.GetGameRelease();
	
	Log( "+++++++++++++++++++++RELEASE = >" +release +"<" );
}
