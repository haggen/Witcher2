/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui messages
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiMessages
{
	final function ShowInformationText( text : string )
	{
		theHud.InvokeOneArg( "setInformationBox", FlashValueFromString( text ), theHud.m_hud.AS_hud );
	}
	final function HideInformationText()
	{
		theHud.Invoke( "setInformationBox", theHud.m_hud.AS_hud );
	}
	
	final function ShowConfirmationBox( confirmationBox : CGuiPanel )
	{
		if ( m_confirmationBox )
			m_confirmationBox.ClosePanel();

		m_confirmationBox = confirmationBox;
		confirmationBox.OpenPanel( "", false, false, true );
	}
	final function HideConfirmationBox()
	{
		if ( m_confirmationBox )
		{
			m_confirmationBox.ClosePanel();
			m_confirmationBox = NULL;
		}
	}
	private var m_confirmationBox : CGuiPanel; // defined only when confirmation box is visible
	
	final function ShowCutsceneText( text1 : string, text2 : string )
	{}
	final function HideCutsceneText()
	{}
	
	final function ShowActText( text : string )
	{
		theHud.InvokeOneArg("vHUD.setActInfo", FlashValueFromString( GetLocStringByKeyExt( text ) ));
	}
	
	final function ShowCredits( lines : array< string > )
	{}
	final function HideCredits()
	{}
}