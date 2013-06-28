/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui meditation methods
/** Copyright © 2010
/***********************************************************************/

import class CGuiMeditation extends CGuiPanel
{
	private var AS_meditation : int;
	

	// Hide hud
	function GetPanelPath() : string { return "ui_meditation.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );

		//theGame.SetActivePause( true );
		theHud.m_hud.HideTutorial();
		theHud.m_hud.setCSText( "", "" );
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mMeditation", AS_meditation ) )
		{
			LogChannel( 'GUI', "CGuiMeditation: No mMeditation found at the Scaleform side!" );
		}
		
		theGame.TutorialPlayerInMeditation( true );
		
		thePlayer.SetImmortalityModePersistent( AIM_Invulnerable ); // hack
		//FillMeditation();
	}
	
	event OnClosePanel()
	{ 
		//theGame.SetActivePause( false );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		theHud.HideMeditation();
		
		// clean and clear if needed
		if ( !theHud.IsLaunchPanel() )
		{	
			thePlayer.StateMeditationExit();
		}
		
		theGame.TutorialPlayerInMeditation( false );
		
		thePlayer.SetImmortalityModePersistent( AIM_None );// hack
	}
	
	function GetActiveElixirs( out elixirs : array< name > )
	{
		var activeElixirs : array< SBuff > = thePlayer.GetActiveElixirs();
		var i : int;
		
		for ( i = 0; i < activeElixirs.Size(); i += 1 )
		{
			elixirs.PushBack( activeElixirs[ i ].m_name );
		}
	}
	
	function GetMaxActiveElixirs() : int
	{
		return 2;
	}
	
	function PerformMeditation( numHoursToWait : int, elixirsToDrink : array< SItemUniqueId > )
	{
		thePlayer.StateMeditationProcess( numHoursToWait, elixirsToDrink );
	}
	
	// Fill panel data
	private final function FillMeditation()
	{
		var baseXP : int = GetBaseExperienceForLevel( thePlayer.GetLevel() - 1 );
		var locale : string;
		var iconActiveN  : string;
		var iconPassiveN : string;
		var iconActiveE  : string;
		var iconPassiveE : string;
		var iconActiveS  : string;
		var iconPassiveS : string;
		var iconActiveW  : string;
		var iconPassiveW : string;
		    
		theHud.SetFloat( "PCLevel",		thePlayer.GetLevel(),										AS_meditation );
		theHud.SetFloat( "PCTalents",	thePlayer.GetTalentPoints(),								AS_meditation );
		theHud.SetFloat( "MinXP",		baseXP,														AS_meditation ); // exp for prev level
		theHud.SetFloat( "CurXP",		thePlayer.GetExp(),								AS_meditation ); // exp now
		theHud.SetFloat( "MaxXP",		GetExperienceForNextLevel( thePlayer.GetLevel()),	AS_meditation ); // exp needed for next level
		
		theHud.SetFloat( "CurrentTimeMinutes",	GameTimeMinutes( theGame.GetGameTime() ),	AS_meditation );
		theHud.SetFloat( "CurrentTimeHours", 	GameTimeHours( theGame.GetGameTime() ),		AS_meditation );
		
		locale = StrLower( theGame.GetCurrentLocale() );
		iconActiveN   = "img://globals/gui/icons/meditation/" + locale + "_icon_active_n_334x334.dds";
		iconPassiveN  = "img://globals/gui/icons/meditation/" + locale + "_icon_passive_n_334x334.dds";
		iconActiveE   = "img://globals/gui/icons/meditation/" + locale + "_icon_active_e_334x334.dds";
		iconPassiveE  = "img://globals/gui/icons/meditation/" + locale + "_icon_passive_e_334x334.dds";
		iconActiveS   = "img://globals/gui/icons/meditation/" + locale + "_icon_active_s_334x334.dds";
		iconPassiveS  = "img://globals/gui/icons/meditation/" + locale + "_icon_passive_s_334x334.dds";
		iconActiveW   = "img://globals/gui/icons/meditation/" + locale + "_icon_active_w_334x334.dds";
		iconPassiveW  = "img://globals/gui/icons/meditation/" + locale + "_icon_passive_w_334x334.dds";
		             
		theHud.SetString( "iconActiveN",  iconActiveN, 	AS_meditation );
		theHud.SetString( "iconPassiveN", iconPassiveN,	AS_meditation );
		theHud.SetString( "iconActiveE",  iconActiveE, 	AS_meditation );
		theHud.SetString( "iconPassiveE", iconPassiveE,	AS_meditation );
		theHud.SetString( "iconActiveS",  iconActiveS, 	AS_meditation );
		theHud.SetString( "iconPassiveS", iconPassiveS,	AS_meditation );
		theHud.SetString( "iconActiveW",  iconActiveW, 	AS_meditation );
		theHud.SetString( "iconPassiveW", iconPassiveW,	AS_meditation );
		                               
		theHud.SetBool( "bTutorialW", theGame.isMeditationDrinkingBlocked, AS_meditation );
		theHud.SetBool( "bTutorialS", theGame.isMeditationRestingBlocked, AS_meditation );
		theHud.SetBool( "bTutorialE", theGame.isMeditationCharacterBlocked, AS_meditation );
		theHud.SetBool( "bTutorialN", theGame.isMeditationAlchemyBlocked, AS_meditation );
		
		theHud.Invoke( "Commit", AS_meditation );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		FillMeditation();
	}
}
