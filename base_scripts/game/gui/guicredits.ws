/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Credits
/** Copyright © 2011
/***********************************************************************/

class CGuiCredits extends CGuiPanel
{
	// Could credits be skipped
	var canBeSkipped : bool;
	
	// Defaults
	default canBeSkipped = true;
	
	var musicSwitched : bool;
	
	var m_restoreMainMenuOnExit : bool;
	default m_restoreMainMenuOnExit = false;

	var music : CSound;

	// Panel
	function GetPanelPath() : string { return "ui_credits.swf"; }
	
	public function SetRestoreMainMenuOnExit( restore : bool )
	{
		m_restoreMainMenuOnExit = restore;
	}
	
	
	event OnOpenPanel()
	{
		// Remove black screen
		theGame.FadeOutAsync( 0.0f );
		
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		// Remove black screen
		//theGame.FadeInAsync( 0.5f );
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		
		// Hide cursor
		theHud.EnableInput( true, true, false );
		//theSound.PlayMainMenuMusic("arena_5");
		theHud.stopMainMenuMusicMcinekHack();
		music = theSound.PlayMainMenuMusic( "gui/credits_music/credits" );
		musicSwitched = false;
	}
	
	event OnClosePanel()
	{
		// Stop music
		theSound.StopSound( music );
	
		theSound.RestoreAllSounds();

		super.OnClosePanel();
		
		if ( m_restoreMainMenuOnExit )
		{
			theHud.ShowMenuBeforeGame( MM_MAIN );
		}
		else
		{
			// Set black screen at the end of game credits
			theGame.FadeOutAsync( 0.0f );
		}
	}
	
	final function GetCreditsName() : string
	{
		var release : string;
		var outputname : string;
		var audioLang : string;
		var textLang : string;

		release = theGame.GetGameRelease();
		
		theGame.GetGameLanguageName(audioLang, textLang);
		
		outputname = "globals/wb_credits_scroll.csv";
		
		if ( textLang == "ZH" || textLang == "ZH " || textLang == "JP" || textLang == "JP " || textLang == "KR" || textLang == "KR " )
		{
			if ( release == "EFIGS" || release == "EFIGS " )
			{
				outputname = "globals/ch_namco_credits_scroll.csv";
			}
			else if ( release == "JP" || release == "JP " )
			{
				outputname = "globals/ch_jp_credits_scroll.csv";
			}
			else if ( release == "AU" || release == "AU " )
			{
				outputname = "globals/ch_namcoau_credits_scroll.csv";
			}
			else if ( release == "NA" || release == "NA " )
			{
			outputname = "globals/ch_wb_credits_scroll.csv";
			}
			else if ( release == "PL" || release == "PL " )
			{
				outputname = "globals/ch_pl_credits_scroll.csv";
			}
			else if ( release == "HU" || release == "HU " )
			{
				outputname = "globals/ch_hu_credits_scroll.csv";
			}
			else if ( release == "RU" || release == "RU " )
			{
			outputname = "globals/ch_ru_credits_scroll.csv";
			}
			else if ( release == "CZ" || release == "CZ " )
			{
				outputname = "globals/ch_cz_credits_scroll.csv";
			}
			else if ( release == "GOG" || release == "GOG " )
			{
				outputname = "globals/ch_gog_credits_scroll.csv";
			}		
			else if ( release == "DD" || release == "DD " )
			{
				outputname = "globals/ch_d2d_credits_scroll.csv";
			}
		}
		else
		{
			if ( release == "EFIGS" || release == "EFIGS " )
			{
				outputname = "globals/namco_credits_scroll.csv";
			}
			else if ( release == "AU" || release == "AU " )
			{
				outputname = "globals/namcoau_credits_scroll.csv";
			}
			else if ( release == "JP" || release == "JP " )
			{
				outputname = "globals/jp_credits_scroll.csv";
			}			
			else if ( release == "NA" || release == "NA " )
			{
				outputname = "globals/wb_credits_scroll.csv";
			}
			else if ( release == "PL" || release == "PL " )
			{
				outputname = "globals/pl_credits_scroll.csv";
			}
			else if ( release == "HU" || release == "HU " )
			{
				outputname = "globals/hu_credits_scroll.csv";
			}
			else if ( release == "RU" || release == "RU " )
			{
				outputname = "globals/ru_credits_scroll.csv";
			}
			else if ( release == "CZ" || release == "CZ " )
			{
				outputname = "globals/cz_credits_scroll.csv";
			}
			else if ( release == "GOG" || release == "GOG " )
			{
				outputname = "globals/gog_credits_scroll.csv";
			}		
			else if ( release == "DD" || release == "DD " )
			{
				outputname = "globals/d2d_credits_scroll.csv";
			}
		}	
		return outputname;
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if( key == 'GI_Exit' && canBeSkipped )
		{
			ClosePanel();
			return true;
		}
		return false;
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	private final function switchMusic()
	{
		if( musicSwitched )
		{
			return;
		}
		
		musicSwitched = true;
		
		// Stop first music
		theSound.StopSound( music );
		
		music = theSound.PlayMainMenuMusic( "gui/credits_music/credits_2" );
	}
	
	private final function getCredits() : string
	{
		var i : int;
		var credits : string;
		var loottable : C2dArray = LoadCSV( GetCreditsName() );	
		var itemTagBefore : string;
		var withouttag : string;
		var output : string;
		
		for ( i=0; i<loottable.GetNumRows(); i+=1 )
		{
			credits = credits + StringToName(loottable.GetValueAt(0, i));
		}
		
		for ( i=0; i< RoundF( ( loottable.GetNumRows() / 2) ); i+=1 )
		{		
			itemTagBefore = StrAfterFirst( credits, "[[" ); withouttag = StrBeforeFirst( itemTagBefore, "]]" );	
			if ( withouttag != "" ) credits = StrReplaceAll( credits, "[[" + withouttag + "]]", "<font size='16' color='#FFFFFF'>" + GetLocStringByKeyExt( withouttag ) + "<font size='20' color='#FF9900'> " );
			itemTagBefore = "";
		}
		
		credits = StrReplaceAll( credits, ":", "" );
		return credits;
	}
	
	private final function getCreditsToP( id : int ) : string
	{
		var i : int;
		var credits : string;
		var loottable : C2dArray = LoadCSV("globals/credits_main.csv");	
		var itemTagBefore : string;
		var withouttag : string;
		var output : string;
		var audioLang : string;
		var textLang : string;
		
		theGame.GetGameLanguageName(audioLang, textLang);

		if ( textLang == "ZH" || textLang == "JP" || textLang == "KR" )
		{
			loottable = LoadCSV("globals/ch_credits_main.csv");
		}
		
		credits = StringToName(loottable.GetValueAt(0, id));
		
		for ( i=0; i<9; i+=1 )
		{		
			itemTagBefore = StrAfterFirst( credits, "[[" ); withouttag = StrBeforeFirst( itemTagBefore, "]]" );	
			if ( withouttag != "" ) credits = StrReplaceAll( credits, "[[" + withouttag + "]]", "<font size='16' color='#FFFFFF'>" + GetLocStringByKeyExt( withouttag ) + "<font size='20' color='#FF9900'> " );
			itemTagBefore = "";
		}
		theGame.FadeInAsync(0.5);
		if(thePlayer && thePlayer.GetGameEnded())
		{
			theHud.Invoke("ShowCreditsInfo");
		}
		credits = StrReplaceAll( credits, ":", "" );
		
		return credits;
	}
	private final function getCredits_p1() : string { return getCreditsToP( 0 ); }
	private final function getCredits_p2() : string { return getCreditsToP( 1 ); }
	private final function getCredits_p3() : string { return getCreditsToP( 2 ); }
	private final function getCredits_p4() : string { return getCreditsToP( 3 ); }
	private final function getCredits_p5() : string { return getCreditsToP( 4 ); }
	private final function getCredits_p6() : string { return getCreditsToP( 5 ); }
	private final function getCredits_p7() : string { return getCreditsToP( 6 ); }
	private final function getCredits_p8() : string { return getCreditsToP( 7 ); }
	private final function getCredits_p9() : string { return getCreditsToP( 8 ); }
	private final function getCredits_p10() : string { return getCreditsToP( 9 ); }
	private final function getCredits_p11() : string { return getCreditsToP( 10 ); }
	private final function getCredits_p12() : string { return getCreditsToP( 11 ); }
	private final function getCredits_p13() : string { return getCreditsToP( 12 ); }
	private final function getCredits_p14() : string { return getCreditsToP( 13 ); }
	private final function getCredits_p15() : string { return getCreditsToP( 14 ); }
	private final function getCredits_p16() : string { return getCreditsToP( 15 ); }
	private final function getCredits_p17() : string { return getCreditsToP( 16 ); }
	

	private final function FillData()
	{
	}
	
	private final function endCredits()
	{
		ClosePanel();
	}
}
