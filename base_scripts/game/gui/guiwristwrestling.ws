/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Minigame Wrist Wrestling
/** Copyright © 2010
/***********************************************************************/

class CGuiWristWrestling extends CGuiPanel
{
	function GetPanelPath() : string { return "ui_wrist.swf"; }
	
	var m_initialized : bool;
	default m_initialized = false;
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		
		//theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		
		m_initialized = false;
	}

	event OnClosePanel()
	{
		//theHud.EnableWorldRendering( true );
		//theGame.SetActivePause( false );
		
		super.OnClosePanel();
		theHud.EnableInput( true, true, false );
		
		//theHud.HideJournal();
		m_initialized = false;
	}
	
	// Use OnGameInputEvent to close the panel with the GI that has opened it
	event OnGameInputEvent( key : name, value : float )
	{
		//if ( key == 'GI_Journal' && value > 0.5f )
		//{
			//ClosePanel();
			//return true;
		//}
		return true;
	}
	
	function CanBeClosedByEsc() : bool { return false; }
	
	//////////////////////////////////////////////////////////////
	// Public methods
	//////////////////////////////////////////////////////////////
	public function IsLoaded() : bool
	{
		return m_initialized;
	}

	public function SetArea( guiHotSpotPos : float, guiHotSpotWidth : float )
	{
		var AS_obj : int;
		/*
			SetArea(v:Object)
			{ guiHotSpotPos: 0, guiHotSpotWidth: 492}
		*/		
		//LogChannel( 'rython', guiHotSpotPos );
		guiHotSpotPos += guiHotSpotWidth/2;
		
		AS_obj = theHud.CreateAnonymousObject();
		theHud.SetFloat( "guiHotSpotPos", guiHotSpotPos, AS_obj );
		theHud.SetFloat( "guiHotSpotWidth", guiHotSpotWidth, AS_obj );
		theHud.InvokeOneArg( "pPanelClass.SetArea", FlashValueFromHandle( AS_obj ) );
		theHud.ForgetObject( AS_obj );
	}
	
	// guiPointerPos [-250, 250]
	public function SetPointer( guiPointerPos : float )
	{
		theHud.InvokeOneArg( "pPanelClass.SetPointer", FlashValueFromFloat( guiPointerPos ) );
		//LogChannel( 'rython', guiPointerPos );
	}
	
	public function SetPointerState( pointerState : int )
	{
		/*
			SetPointerState(a:Number)
			0 - safe
			1 - danger
		*/
		if ( pointerState >= 0 && pointerState <= 2 )
		{
			theHud.InvokeOneArg( "pPanelClass.SetPointerState", FlashValueFromFloat( pointerState ) );
		}
		else
		{
			LogChannel( 'GUI', "Wrist Wrestling: SetPointerState() unknown pointer state (arg): " + pointerState );
		}
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	public final function FillData()
	{
		theHud.EnableInput( true, false, true );
		theHud.InvokeOneArg("SetPointer", FlashValueFromFloat( 1.0 ) );
		theHud.InvokeOneArg("Wrist.setPointer", FlashValueFromFloat( 1.0 ) );
		m_initialized = true;
	}
}
