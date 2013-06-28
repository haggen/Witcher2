//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiTutorialFinish extends CGuiPanel
{
	var bgSound : CSound;
	
	private var AS_tutorial				: int;
	private var m_mapItemIdxToId		: array< SItemUniqueId >;
	private var m_mapArrayIdxToItemIdx	: array< int >;
	
	function GetPanelPath() : string { return "ui_tutorialend.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.FadeInAsync(0.5);
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	
		theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		theHud.m_hud.setCSText( "", "" );
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items
		theGame.SetActivePause( false );
		theHud.ForgetObject( AS_tutorial );
	
		//theHud.EnableWorldRendering( true );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.HideControls();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		//theHud.HideInventory();
		Log("");
		
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////

	private final function FillData()
	{
		var diff : string;
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mTutorialEnd", AS_tutorial ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No m_controls found at the Scaleform side!" );
		}

		diff = SetTutorialProposedDifficulty();
		
		// Tutorial finish prompt data
		theHud.SetBool( "ConfMode", theGame.newGameAfterTutorial, AS_tutorial );
		theHud.SetString( "ConfInfo", diff, AS_tutorial );
		
		//Difficulty selection panel data
		theHud.SetString( "DiffEasy", GetLocStringByKeyExt( "menuDifficultyEasy" ), AS_tutorial );
		theHud.SetString( "DiffMedium", GetLocStringByKeyExt( "menuDifficultyMedium" ), AS_tutorial );
		theHud.SetString( "DiffHard", GetLocStringByKeyExt( "menuDifficultyHard" ), AS_tutorial );
		theHud.SetString( "DiffVeryHard", GetLocStringByKeyExt( "menuDifficultyVeryHard" ), AS_tutorial );
		theHud.SetString( "DiffInsane", GetLocStringByKeyExt( "menuDifficultyInsane" ), AS_tutorial );

		//call flash functions
		theHud.Invoke( "Commit", AS_tutorial );
		//theHud.Invoke( "pPanelClass.ShowConfirm" );
	}
	
	private function SetTutorialProposedDifficulty() : string
	{
		var diffLevel 		: int;
		var suggestedDiff 	: string;
		var enemyCount 		: int;
		var value			: float;
		var hud     		: CHudInstance;		
		
		//theHud.EnableInput( true, true, true );
		//thePlayer.SetManualControl( false, false );
		//theGame.SetActivePause( true );	
		
		enemyCount = FactsQuerySum( "skirmish_enemy_killed" ); 
		
		if( enemyCount >= 20 )
		{
			diffLevel =  3;
			suggestedDiff = GetLocStringByKeyExt( "menuDifficultyInsane" );
		}
		else if( enemyCount >= 10 )
		{
			diffLevel =  4;
			suggestedDiff = GetLocStringByKeyExt( "menuDifficultyVeryHard" );
		}
		else if( enemyCount >= 7 )
		{
			diffLevel =  2;
			suggestedDiff = GetLocStringByKeyExt(  "menuDifficultyHard" );		
		}		
		else if( enemyCount > 3 )
		{
			diffLevel = 1;
			suggestedDiff = GetLocStringByKeyExt( "menuDifficultyMedium" );
		}
		else if( enemyCount <= 3 )
		{
			diffLevel = 0;
			suggestedDiff = GetLocStringByKeyExt( "menuDifficultyEasy" );
		}
		
		//set user.ini data - tutorial has been played - do not start with tutorial if value == 1
		
		hud.m_hud.isTutorialPlayed = ( value == 1.0f );
		theGame.WriteConfigParamFloat( "User", "Tutorial", "Played", value ); 
		
		theGame.SetDifficultyLevel( diffLevel );
		return suggestedDiff;	
	}
}

