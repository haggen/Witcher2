/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Poster GUI panel
/** Copyright © 2011
/***********************************************************************/

class CGuiPoster extends CGuiPanel
{
	//////////////////////////////////////////////////////////////
	// Public methods
	//////////////////////////////////////////////////////////////
	
	public function Init( posterVar : poster )
	{
		m_poster = posterVar;
	}
	
	//////////////////////////////////////////////////////////////
	
	function GetPanelPath() : string { return "ui_blank.swf"; }
	
	event OnOpenPanel()
	{		
		super.OnOpenPanel();
	}
	
	event OnClosePanel()
	{		
		super.OnClosePanel();
		
		m_poster.ClosePoster();
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		/*
		* settings [0] = icon ID : string
		* settings [1] = Left text: string
		* settings [2] = Right text: string
		* 
		*/
		//setInteractions (settings : Array) : Void
		// pPanelClass
	}

	//////////////////////////////////////////////////////////////
	
	private var m_poster : poster;
}
