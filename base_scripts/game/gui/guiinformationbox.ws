/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Information box gui panel
/** Copyright © 2011
/***********************************************************************/

class CGuiInformationBox extends CGuiPanel
{
	function GetText()				: string	{ return ""; }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnOk() {}
	
	event OnOpenPanel()
	{
		var AS_params : int = theHud.CreateAnonymousObject();

		super.OnOpenPanel();
		
		theHud.EnableInput( true, true, true, false );
		
		// Sets both buttons to the same value - flash interprets it as showing one button
		theHud.SetString( "Label",	GetText(),					AS_params );
		theHud.SetString( "Yes",	GetLocStringByKeyExt("[[locale.Confirm]]"),	AS_params );
		theHud.SetString( "No",		GetLocStringByKeyExt("[[locale.Confirm]]"),	AS_params );
	
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
	
	private final function ConfirmationBoxSelection( v : bool )
	{
		OnOk();
		ClosePanel();
	}
	
	private final function HightlightOkButton()
	{
		// select OK option
		theHud.InvokeOneArg( "setConfirmationBoxState", FlashValueFromBoolean( true ), theHud.m_hud.AS_hud );
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

// showed when player wants to load save game, when he is dead on insane difficulty
class CGuiCannotLoadSave extends CGuiInformationBox
{
	public var exitAfterOk : bool;
	default exitAfterOk = false;
	
	function GetText()				: string	{ return GetLocStringByKeyExt( "menuCannotLoadInsane" ); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnOk()
	{
		if( exitAfterOk )
		{
			theGame.ExitGame();
		}
	}
}

class CGuiNotEnoughSpaceOnSteamCloud extends CGuiInformationBox
{
	function GetText(): string { return GetLocStringByKeyExt( "not.enough.space.on.steam.cloud" ); }
}
