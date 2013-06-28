/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Custom GUI panel
/** Copyright © 2010
/***********************************************************************/

class CGuiCustomPanel extends CGuiPanel
{
	event OnOpenPanel()		{} // disable default implementation
	event OnClosePanel()
	{ 
		theHud.HideCustomPanel();
		// disable default implementation
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float ) { return false; }
}

class CGuiCustomPanelWithPause extends CGuiCustomPanel
{
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.SetActivePause( true );
		theGame.EnableButtonInteractions( false );
		theHud.SetHudVisibility( false);
		thePlayer.setHUDTimerBlock( true );
	}
	
	event OnClosePanel()
	{
		theGame.EnableButtonInteractions( true );
		theGame.SetActivePause( false );
		super.OnClosePanel();
		thePlayer.setHUDTimerBlock( false );
	}
	
	event OnGameInputEvent( key : name, value : float )	{ return true; }
}

class CGuiDemoStartPanel extends CGuiCustomPanel // no pause
{
	function GetPanelPath() : string { return "demo_endpanel.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.EnableButtonInteractions( false );
	}
	
	event OnClosePanel()
	{
		theGame.EnableButtonInteractions( true );
		super.OnClosePanel();
	}
}

class CGuiDemoEndPanel extends CGuiCustomPanelWithPause
{
	function GetPanelPath() : string { return "demo_endpanel.swf"; }
}

class CGuiDeathPanel extends CGuiCustomPanelWithPause
{
	function GetPanelPath() : string { return "demo_endpanel.swf"; }
}

class CGuiCustomPanelThatLocksPanels extends CGuiCustomPanel
{
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		thePlayer.SetCanUseHud( false );
	}
	
	event OnClosePanel()
	{
		thePlayer.SetCanUseHud( true );
		super.OnClosePanel();
	}
}

class CGuiEmptyGameplayPanel extends CGuiCustomPanelThatLocksPanels
{
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theHud.SetGuiVisibility( false );
	}
	
	event OnClosePanel()
	{
		thePlayer.SetCanUseHud( true );
		theHud.SetGuiVisibility( true );
	}
}
