/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Video
/** Copyright © 2010
/***********************************************************************/

/**********************************************************************
Metody w skrypcie:
 - theHud.PlayVideo(name) - odpala i czeka (nie zmienia ustawien jezykowych)
 - theHud.PlayVideoEx(name, loop) - odpala i czeka, loop - zapetlenie
 - theHud.PlayVideoAsync - odpala i kontynuuje

 - theHud.StopVideo - zatrzymuje playback, takze zwalnia czekajaca funkcje (bo flesz puszcza "MovieStopped")

 - theHud.PauseVideo(pause:bool) - pauza/wznowienie odtwarzanego filmu
 - theHud.GetVideo().ShowStatus(show:bool) - wlacza/wylacza debugowe info z filmiku (np. ze go nie znalazl, albo ilosc sciezek audio)
 
 LOKALIZACJA: ogolnie jesli tego nie zrobimy sami to jezyki ustawia sie same podczas pierwszego odpalenia filmiku (pobrane z theGame.GetGameLanguage())
 - theHud.GetVideo()SetSubtitleLanguage(lang:int)
 - theHud.GetVideo()SetAudioLanguage(lang:int) - ustawiaja odpowiednio jezyk dzwiekow i jezyk napisow, obecna kolejnosc wyglada tak:
-1 - domyslne ustawienia (czyli bez jezykow)
0   NONE - bez lokalizacji
1	PL
2	EN
3	DE
4	IT
5	FR
6	CZ
7	ES
8	ZH
9	RU
10	HU
11	JP

Tu uwaga: z racji ulomnosci USMow napisy musza byc wszystkie!! bo jesli np. zabraknie DE, to reszta przesunie sie o jeden w dol i bedzie dupa.
Wiec jesli jakis jezyk ma byc nie obslugiwany to trzeba wstawic tam zaslepke w postaci pliku z jedna lijnijka lub wersja ang. raz jeszcze!


Oprocz tego z flasza mozna wolac:
 - pPanelClass.GetAudioLanguage - zwraca jezyk voicow
 - pPanelClass.GetSubtitleLanguage - zwraca jezyk npaiso
 - pPanelClass.GetDuration - zwraca duration

Ponadto hudInstance ma latentna funkcje 
 WaitForEvent(eventName)
ktora to czeka az przyjdzie event z flesza (np. "MovieStopped").
***********************************************************************/
	
class CGuiVideo extends CGuiPanel
{	
	var audioLanguage : int;
	var subtitleLanguage : int;
	var firstTime : bool;
	var isPanelLoaded : bool;
	var m_fadeInOnMovieStarted : bool;
	default m_fadeInOnMovieStarted = true;
	
	function IsVideoPanel() : bool
	{
		return true;
	}
	// Hide hud
	function GetPanelPath() : string { return "ui_video.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		isPanelLoaded = false;
		//theGame.SetActivePause( true );
		theHud.EnableInput(true, true, false, false);
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		super.OnClosePanel();
		//theHud.HideSleep();
		isPanelLoaded = false;
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float )
	{
		if ( action == IACT_Press && 
			( theHud.m_keys.m_ikExit == key || theHud.m_keys.m_ikDialogConfirmSkip == key ) )
		{
			theHud.StopVideo();
			return true;
		}
		return false; // pass to GameInputEvent
	}
	
	public function IsPanelLoaded() : bool
	{
		return isPanelLoaded;
	}
	
	public function PlayVideo( videoName : string, loop : bool, fadeInOnMovieStarted : bool )
	{
		var loopParam : string;
		var areaArgs : array< CFlashValueScript >;

		if ( loop )
		{
			loopParam = "1";
		}
		else
		{
			loopParam = "";
		}
		
		if (!firstTime)
		{
			theGame.GetGameLanguage(audioLanguage,subtitleLanguage);
			SetAudioLanguage( audioLanguage );
			SetSubtitleLanguage( subtitleLanguage );
			firstTime = true;
		}
		
		m_fadeInOnMovieStarted = fadeInOnMovieStarted;
	
		theHud.PlayVideoSave( videoName );

		areaArgs.PushBack( FlashValueFromString( videoName ) );
		areaArgs.PushBack( FlashValueFromString( loopParam ) );
		theHud.InvokeManyArgs("pPanelClass.PlayVideo", areaArgs );
	}
	
	public function StopVideo()
	{
		theHud.Invoke( "pPanelClass.StopVideo" );
	}
	
	public function PauseVideo(pause:bool)
	{
		theHud.InvokeOneArg( "pPanelClass.PauseVideo", FlashValueFromBoolean( pause ) );
	}
	
	public function SetSubtitleLanguage(lang:int)
	{
		subtitleLanguage = lang;
		theHud.InvokeOneArg( "pPanelClass.SetSubtitleLanguage", FlashValueFromInt( lang ) );
	}
	
	public function SetAudioLanguage(lang:int)
	{
		audioLanguage = lang;
		theHud.InvokeOneArg( "pPanelClass.SetAudioLanguage", FlashValueFromInt( lang ) );
	}
	
	public function ShowStatus(enable:bool)
	{
		theHud.InvokeOneArg( "pPanelClass.ShowStatus", FlashValueFromBoolean( enable ) );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		isPanelLoaded = true;
	}
	
	private final function MovieStarted()
	{
		if ( m_fadeInOnMovieStarted )
		{
			theGame.FadeInAsync( 2.0 );
		}
	}
}
