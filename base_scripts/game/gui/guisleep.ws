/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Sleep
/** Copyright © 2010
/***********************************************************************/

// wybierany z panelu medytacji
class CGuiSleep extends CGuiPanel
{
	private var AS_sleep : int;


	// Hide hud
	function GetPanelPath() : string { return "ui_sleep.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		//theGame.SetActivePause( true );
		theGame.TutorialIsPlayerResting( true );
		FillSleep();
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		super.OnClosePanel();
		theGame.TutorialIsPlayerResting( false );
		//theHud.HideSleep();
	}

	private function FillSleep()
	{
		//var AS_CurrentTime : int;
		var gameTimeMinutes : int;
		var gameTimeHours : int;
		var locale : string;
		var iconPassiveNImgPath : string;
		var iconPassiveEImgPath : string;
		var iconPassiveSImgPath : string;
		var iconPassiveWImgPath : string;
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mSleep", AS_sleep ) )
		{
			LogChannel( 'GUI', "CGuiSleep: No mSleep found at the Scaleform side!" );
		}
		
		gameTimeMinutes = GameTimeMinutes( theGame.GetGameTime() );
		gameTimeHours = GameTimeHours( theGame.GetGameTime() );
		
		theHud.SetFloat( "CurrentTimeMinutes", gameTimeMinutes, AS_sleep );
		theHud.SetFloat( "CurrentTimeHours", gameTimeHours, AS_sleep );
		
		// Icons paths
		
		locale = StrLower( theGame.GetCurrentLocale() );
		iconPassiveNImgPath = "img://globals/gui/icons/sleep/" + locale + "_icon_passive_n_334x334.dds";
		iconPassiveEImgPath = "img://globals/gui/icons/sleep/" + locale + "_icon_passive_e_334x334.dds";
		iconPassiveSImgPath = "img://globals/gui/icons/sleep/" + locale + "_icon_passive_s_334x334.dds";
		iconPassiveWImgPath = "img://globals/gui/icons/sleep/" + locale + "_icon_passive_w_334x334.dds";
		
		theHud.SetString( "iconPassiveN", iconPassiveNImgPath, AS_sleep );
		theHud.SetString( "iconPassiveE", iconPassiveEImgPath, AS_sleep );
		theHud.SetString( "iconPassiveS", iconPassiveSImgPath, AS_sleep );
		theHud.SetString( "iconPassiveW", iconPassiveWImgPath, AS_sleep );

		// Tutorial SetOnlyDawn
		theHud.SetBool( "bTutorialSleep", theGame.isSleepToDawn, AS_sleep );
											
		//theHud.ForgetObject( AS_CurrentTime );
		theHud.Invoke( "Commit", AS_sleep );
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	
	// Player should sleep for 'sleepTime' minutes (gameplay time)
	private final function Sleep( sleepTime : float )
	{
		var numHoursToWait : int;
		var elixirsToDrink : array< SItemUniqueId >;
		
		LogChannel( 'GUI', "Sleep" );
		
		numHoursToWait = (int)(sleepTime / 60);
		thePlayer.StateMeditationProcess( numHoursToWait, elixirsToDrink );
	}
}
