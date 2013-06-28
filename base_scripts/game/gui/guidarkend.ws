//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiDarkEnd extends CGuiPanel
{
		
	function GetPanelPath() : string { return "ui_darkmodeend.swf"; }
		
	event OnOpenPanel()
	{
		theGame.FadeInAsync(3.5);
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );

		theHud.m_hud.setCSText( "", "" );
		super.OnOpenPanel();
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items

		//theSound.RestoreAllSounds();
		
		theGame.FadeOutAsync(0.01);
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
		
		theHud.HideHud();
		//super.OnClosePanel();
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillItems()
	{
		
	}
	private final function FillData()
	{
	}

	function CloseDarkPanel( diff : string )
	{
		theGame.FadeOutAsync(0.0);
		if(theGame.IsActivelyPaused())
		{
			theGame.SetActivePause(false);
		}
		ClosePanel();
	}
	
}

