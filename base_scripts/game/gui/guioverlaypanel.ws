/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Custom GUI overlay panel
/** Copyright © 2010
/***********************************************************************/

class CGuiOverlayPanel
{
	function GetPanelPath() : string { return ""; }
	
	private var AS_customPanel : int;
	
	final function OpenPanel()
	{
		var args : array< string >;
		
		if ( theHud.GetObject( "vCustomPanel", AS_customPanel ) )
		{
			if ( ! theHud.InvokeOneArg( "loadMovie", FlashValueFromString( GetPanelPath() ), AS_customPanel ) )
			{
				LogChannel( 'GUI', "There is no vCustomPanel.loadMovie" );
			}
		}
		
		OnOpenPanel();
	}
	
	final function ClosePanel()
	{
		OnClosePanel();
		
		if ( AS_customPanel >= 0 )
		{
			theHud.Invoke( "unloadMovie", AS_customPanel );
			theHud.ForgetObject( AS_customPanel );
			AS_customPanel = -1;
		}
		
		theHud.HideOverlayPanel();
		
		OnClosedPanel();
	}
	
	event OnOpenPanel()		{}
	event OnClosePanel()	{}
	event OnClosedPanel()	{}
}

class CGuiScopePanel extends CGuiOverlayPanel
{
	function GetPanelPath() : string { return "ui_scope.swf"; }
	
	event OnOpenPanel()		{ thePlayer.SetCanUseHud( false ); }
	event OnClosePanel()	{ thePlayer.SetCanUseHud( true ); }
}

class CGuiHolePanel extends CGuiOverlayPanel
{
	function GetPanelPath() : string { return "ui_hole.swf"; }
	
	event OnOpenPanel()		{ thePlayer.SetCanUseHud( false ); }
	event OnClosePanel()	{ thePlayer.SetCanUseHud( true ); }
	event OnClosedPanel()
	{
		// HACK: Restore shadow overlay
		if ( thePlayer.GetIsInShadow() )
		{
			theHud.m_fx.StealthAlphaStart();
		}
	}
}

class CGuiStealthPanel extends CGuiOverlayPanel
{
	function GetPanelPath() : string { return "ui_stealth.swf"; }
}
