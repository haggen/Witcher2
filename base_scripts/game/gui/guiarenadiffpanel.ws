//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiArenaDiff extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_arena			: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_arenadif.swf"; }
	
	event OnOpenPanel()
	{
		var arenaDoor : CArenaDoor;
		theGame.FadeInAsync(0.5);
		theHud.m_hud.HideTutorial();
		/*theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );*/
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		//theHud.EnableWorldRendering( false );
		theHud.m_hud.setCSText( "", "" );
		arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		if(arenaDoor)
		{
			arenaDoor.EnableDoor(false);
		}
		theGame.GetArenaManager().ShowArenaHUD(true);
		super.OnOpenPanel();
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items
		var arenaDoor : CArenaDoor;
		theHud.ForgetObject( AS_arena );
	
		
		arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
		if(arenaDoor)
		{
			arenaDoor.EnableDoor(true);
		}
		
		
		
		theSound.RestoreAllSounds();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		
		super.OnClosePanel();
		
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillItems()
	{
		
	}
	private final function FillData()
	{
		ArenaGetDifficulty();
	}
	function ArenaGetDiff()
	{
		var args : array <CFlashValueScript>;
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "arena" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "ArenaDifTooltip" )  )); // klucz uzyc: ArenaDifTooltip
		//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryEasy" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyEasy"   ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyMedium" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyHard"   ) ));
		//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyInsane" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryHard"   ) ));
			
		//theHud.InvokeManyArgs("ArenaGetDiff", args);
		//theHud.InvokeManyArgs("pPanel.ArenaGetDiff", args);
		theHud.InvokeManyArgs("pPanelClass.ArenaGetDiff", args);
	}
	function ArenaGetDifficulty()
	{
		var args : array <CFlashValueScript>;
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "arena" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "ArenaDifTooltip" )  )); // klucz uzyc: ArenaDifTooltip
		//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryEasy" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyEasy"   ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyMedium" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyHard"   ) ));
		//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyInsane" ) ));
		args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryHard"   ) ));
			
		//theHud.InvokeManyArgs("ArenaGetDiff", args);
		//theHud.InvokeManyArgs("pPanel.ArenaGetDiff", args);
		theHud.InvokeManyArgs("pPanelClass.ArenaGetDiff", args);
	}
	function IsArenaPanel() : bool
	{
		//return true;
	}
	function CloseArenaDif( diff : string )
	{
		var selectedDif : int = StringToInt( diff ) - 1;
	
		if (selectedDif == 0) theGame.SetDifficultyLevel( 0 ); // easy 0
		if (selectedDif == 1) theGame.SetDifficultyLevel( 1 ); // med 1
		if (selectedDif == 2) theGame.SetDifficultyLevel( 2 ); // hard 2
		if (selectedDif == 3) theGame.SetDifficultyLevel( 4 ); // dark 4
		//if (selectedDif == 4) theGame.SetDifficultyLevel( 3 ); // insane 3
		//if (selectedDif == 5) theGame.SetDifficultyLevel( 4 ); // dark 4

		ClosePanel();
		
	}
	
}

