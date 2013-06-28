/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Confirmation box gui panel
/** Copyright © 2010
/***********************************************************************/

class CGuiConfirmationBox extends CGuiPanel
{
	function GetText()				: string	{ return ""; }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes() {}
	event OnNo()  {}
	function IsNestedPanel() : bool
	{
		return true;
	}
	event OnOpenPanel()
	{
		var AS_params : int = theHud.CreateAnonymousObject();

		super.OnOpenPanel();
		
		theHud.EnableInput( true, true, true, false );
		
		theHud.SetString( "Label",	GetText(),						AS_params );
		theHud.SetString( "Yes",	GetLocStringByKeyExt("Yes"),	AS_params );
		theHud.SetString( "No",		GetLocStringByKeyExt("No"),		AS_params );
	
		theHud.InvokeOneArg( "setConfirmationBox", FlashValueFromHandle( AS_params ), theHud.m_hud.AS_hud );
		theHud.ForgetObject( AS_params );
		
		theGame.SetActivePause( true );
		
		HightlightOkButton(); // default selected button
	}
	
	event OnClosePanel()
	{
		theGame.SetActivePause( false );
		
		theHud.Invoke( "setConfirmationBox", theHud.m_hud.AS_hud );
		
		theHud.m_messages.HideConfirmationBox();
		
		super.OnClosePanel();
		
		theHud.EnableInput( true, true, true, false );
		
		theHud.SetResetCursor( false );
	}
	
	event OnViewportInput( key : int, action : EInputAction, data : float )
	{
		return false;
	}
	
	private final function ConfirmationBoxSelection( v : bool )
	{
		if ( v )
		{
			OnYes();
		}
		else
		{
			OnNo();
		}
		ClosePanel();
	}
	
	private final function HightlightOkButton()
	{
		// select OK option
		theHud.InvokeOneArg( "setConfirmationBoxState", FlashValueFromBoolean( true ), theHud.m_hud.AS_hud );
	}
	
	private final function HightlightCancelButton()
	{
		// select Cancel option
		theHud.InvokeOneArg( "setConfirmationBoxState", FlashValueFromBoolean( false ), theHud.m_hud.AS_hud );
	}
	
	event OnFocusPanel()
	{
		theHud.EnableInput( true, true, true, false );
	}
	event OnUnFocusPanel()
	{
		theHud.EnableInput( false, false, false, false );
	}
}

class CGuiConfirmGameExit extends CGuiConfirmationBox
{
	function GetText()				: string	{ return GetLocStringByKeyExt("Exit game?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes() { theGame.ExitGame(); }
	event OnNo()  {}
}

// endgame confirmation box - showed when player dies
class CGuiConfirmGameEnd extends CGuiConfirmationBox
{
	function GetText()				: string	{ return GetLocStringByKeyExt("Restart game?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		if (!theGame.LoadLastGame())
		{
			theGame.ExitGame();
		}		
	}
	
	event OnNo()
	{
		theGame.ExitGame();		
	}
}

// showed when player want's to change difficulty
class CGuiConfirmChangeDifficulty extends CGuiConfirmationBox
{
	public var difficulty : int;

	function GetText()				: string	{ return GetLocStringByKeyExt("menuWantChangeDifficulty"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		// Change difficulty
		theGame.SetDifficultyLevel( difficulty );
	}
	
	event OnNo()
	{
		// Refresh main menu
		if( theHud.m_mainMenu )
		{
			theHud.m_mainMenu.FillData();
		}
	}
}

// Showed when enabling steam cloud saving
class CGuiCopyLocalSavesToSteamCloud extends CGuiConfirmationBox
{
	public var menu : CGuiMainMenu;
	
	function GetText()				: string	{ return GetLocStringByKeyExt("copy.saves.onto.steam.cloud"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		var message : CGuiNotEnoughSpaceOnSteamCloud;
		
		if( !menu.CopySavesToSteamCloud() )
		{
			message = new CGuiNotEnoughSpaceOnSteamCloud in theHud.m_messages;
			theHud.m_messages.ShowConfirmationBox( message );
		}
	}
	
	event OnNo()
	{
	}
}

