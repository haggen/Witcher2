/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Board
/** Copyright © 2010
/***********************************************************************/

class CGuiBoard extends CGuiPanel
{
	private var AS_board : int;
	
	// Board data from board entity
	var m_boardDataContent 	: array< string >;		   // messages
	var m_boardDataIds 		: array< SItemUniqueId >;  // messages ids
	var m_questBoard		: CQuestBoard;             // associated quest board entity


	public function SetBoardData( content : array< string >, ids : array< SItemUniqueId >, questBoard : CQuestBoard )
	{
		m_boardDataContent	= content;
		m_boardDataIds		= ids;
		m_questBoard		= questBoard;
	}


	function GetPanelPath() : string { return "ui_board.swf"; }

	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.SetActivePause( true );
		
		theHud.m_hud.HideTutorial();
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mBoard", AS_board ) )
		{
			LogChannel( 'GUI', "CGuiBoard: No mBoard found at the Scaleform side!" );
		}
		
		theGame.EnableButtonInteractions( false );
		thePlayer.SetHotKeysBlocked( true );
		if(theHud.CanShowMainMenu())
		{
			theHud.ForbidOpeningMainMenu();
		}
		
		//FillBoard();
	}

	event OnClosePanel()
	{
		super.OnClosePanel();
		
		theGame.SetActivePause( false );
		thePlayer.GetLastBoard().GetComponent ("Look at board").SetEnabled(true);
		thePlayer.GetLastBoard().SetProperApearance();
		theHud.EnableInput( false, false, false );
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
		thePlayer.SetHotKeysBlocked( false );
		theGame.EnableButtonInteractions( true );
	}

	private function FillBoard()
	{
		var AS_messages : int;
		var AS_message : int;
		var i : int;

		if ( !theHud.GetObject( "Messages", AS_messages, AS_board ) )
		{
			LogChannel( 'GUI', "CGuiBoard: No Messages found at the Scaleform side!" );
		}
		
		theHud.ClearElements( AS_messages );
		
		for ( i = 0; i < m_boardDataContent.Size(); i += 1 )
		{
			AS_message = theHud.CreateAnonymousObject();
			
			// voGameObject
			theHud.SetString( "Name", "title", AS_message ); // not used now
			theHud.SetFloat( "ID", (float)i, AS_message ); // id

			// voBoardMessage extends voGameObject
			theHud.SetString( "Value", m_boardDataContent[i], AS_message );
			
			theHud.PushObject( AS_messages, AS_message );
			theHud.ForgetObject( AS_message );
		}
		
		theHud.ForgetObject( AS_messages );
	
		theHud.Invoke( "Commit", AS_board );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		FillBoard();
	}
	
	private function TakeQuest( id : float )
	{
		m_questBoard.GetInventory().GiveItem( thePlayer.GetInventory(), m_boardDataIds[(int)id], 1 );
	}
}
