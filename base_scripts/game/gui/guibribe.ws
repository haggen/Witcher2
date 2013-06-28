/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Bribe gui panel
/** Copyright © 2010
/***********************************************************************/
/*
	Metody do wywo³ywania:
	
	Maksymalna wartosc lapowki, minimalna wartosc lapowki, tekst potwierdzenia, tekst anulacji.
	 Bribing(max:Number, min:Number, okText:String, cancelText:String)

	Wyswietla tekst nad suwakiem
	 ShowInformation(text:String)

	Ustawia ilosc kasy Geralta
	 SetGeraltMoney(v:Number)

	Chowa wszystko.
	 HideInformation()

	
	Metody zwrotne:

	Po wcisnieciu cancel:
	 callbackPlayerCancel()

	Po wcisnieciu ok:
	 callbackPlayerBet(bribeValue:Number)
*/

class CGuiBribe extends CGuiPanel
{
	var bribeAmount : int;
	var guiDone		: bool;

	// Hide hud
	function GetPanelPath() : string { return "ui_bribe.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		// I think we don't need game pausing during bribe...
		// theGame.SetActivePause( true );
		
		theGame.FadeInAsync( 1.0 );
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		
		super.OnClosePanel();
	}

	function Bribing( minValue : int, maxValue : int )
	{
		var arguments : array< CFlashValueScript >;

		arguments.PushBack( FlashValueFromInt( maxValue ) );
		arguments.PushBack( FlashValueFromInt( minValue ) );		
		arguments.PushBack( FlashValueFromString( "[[locale.Confirm]]" ) );
		arguments.PushBack( FlashValueFromString( "[[locale.Cancel]]" ) );
		theHud.InvokeManyArgs( "pPanelClass.Bribing", arguments );
	}
	
	function SetPlayerMoney( value : int )
	{
		var arguments : array< CFlashValueScript >;

		arguments.PushBack( FlashValueFromInt( value ) );
		theHud.InvokeManyArgs( "pPanelClass.SetGeraltMoney", arguments );
	}
	
	function ShowInformation( text : string )
	{
		var arguments : array< CFlashValueScript >;

		arguments.PushBack( FlashValueFromString( text ) );
		theHud.InvokeManyArgs( "pPanelClass.ShowInformation", arguments );
	}
	
	function HideInformation()
	{
		theHud.Invoke( "pPanelClass.HideInformation" );
	}
	
	latent function WaitForPlayer()
	{
		guiDone = false;
		while( ! guiDone )
		{
			Sleep( 0.1f );
		}
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function callbackPlayerCancel()
	{
		bribeAmount = 0;
		guiDone = true;
	}
	
	private final function callbackPlayerBet( bribeValue : float )
	{
		bribeAmount = ( int ) bribeValue;
		guiDone = true;
	}
}
