/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CHudPanel
/** Copyright © 2010
/***********************************************************************/

import class CGuiPanel
{
	
	import final function OpenPanel( background : string, controlRender : bool, controlPause : bool, controlHud : bool );
	import final function ClosePanel( optional removePanelsFromFlash : bool /* = true */ );
	

	function GetPanelPath() : string { return ""; }
	
	// returns panel that has to be launched if this panel is closed
	function GetPreviousPanel() : string { return prevPanelName; }
	function SetPreviousPanel( prevPanelNameArg : string ) { prevPanelName = prevPanelNameArg; }
	
	// default, derived panels can set whatever they like
	function CanBeClosedByEsc() : bool { return true; }
	
	event OnOpenPanel()
	{
		var arenaDoor : CArenaDoor;
		theGame.EnableButtonInteractions( false );
		thePlayer.SetHotKeysBlocked( true );
		
		//Hiding arena hud
		if(theGame.GetIsPlayerOnArena())
		{
			theHud.ArenaFollowersGuiEnabled( false );
			theGame.GetArenaManager().ShowArenaHUD(false);
		}
		/*
		if( theGame.tutorialenabled )
		{
			if( !theGame.tutorialPanelHidden )
			{
				if( theGame.tutorialPanelNew )
					thePlayer.ToggleTutorialPanel( true );
				else	
					thePlayer.ToggleTutorialPanel( false );
			}		
		}
		*/
	}

	function IsNestedPanel() : bool
	{
		return false;
	}
	function IsVideoPanel() : bool
	{
		return false;
	}
	function IsArenaPanel() : bool
	{
		return false;
	}
	event OnClosePanel()
	{
		var arenaDoor : CArenaDoor;
		
		theGame.EnableButtonInteractions( true );
		thePlayer.SetHotKeysBlocked( false );
		
		
		//theHud.UnloadBG();
		
		// Little hack for restoring combat mode indication
		if( thePlayer.IsInCombat() )
		{
			thePlayer.ShowCombatMode();
		}
		
		// Open previous panel
		if ( prevPanelName != "" )
		{
			theHud.LaunchPanel( prevPanelName );
		}
		
		//Showing arena hud
		if(theGame.GetIsPlayerOnArena())
		{
			if(!this.IsNestedPanel())
			{
				if(theGame.GetArenaManager().HasArenaWingman())
				{
					theHud.ArenaFollowersGuiEnabled( true );
				}
				if(!IsArenaPanel() && !IsVideoPanel())
				{
					theGame.GetArenaManager().SetRoundStart(false);
					theGame.GetArenaManager().ShowArenaHUD(true);
					theGame.GetArenaManager().AddTimer('TimerUpdateArenaHud', 0.5, false);
				}
			}
		}
	}
	
	event OnFocusPanel()
	{
		LogChannel( 'GUI', "Focus panel: " + GetPanelPath() );
		theHud.EnableInput( true, true, true, theHud.IsResetCursorEnabled() );
		theHud.SetResetCursor( true );
	}
	event OnUnFocusPanel()
	{
		LogChannel( 'GUI', "Unfocus panel: " + GetPanelPath() );
		theHud.EnableInput( false, false, false, false );
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if ( key == 'GI_Block' && value < 0.5f )
		{
			thePlayer.SetGuardBlock(false, true);
		}
		return true;
	}
	
	import private var prevPanelName : string;
}
