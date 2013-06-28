
function GetSelectorTxt()
{

	//var args : array < CFlashValueScript >;
	
	/*args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector1" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector1t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector2" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector2t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector3" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector3t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector4" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector4t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector5" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector5t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector6" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelector6t" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelectorBtn1" ) ) );
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "panelSelectorBtn2" ) ) );
	
	theHud.InvokeManyArgs("pPanelClass.SetSelectorTxt", args);*/
    //SetSelectorTxt( s1, o1, s2, o2, s3, o3, s4, o4, s5, o5, s6, o6, b1, b2 : String) 
}


exec function PanelSelectorTrigger( val : string )
{
	//PanelSelectorClose();
	//Log(val);
	//if ( val == "0" ) theHud.ShowInventory();
	//if ( val == "1" ) theHud.ShowJournal();
	//if ( val == "2" ) theHud.ShowCharacter( false );
	//if ( val == "3" ) theHud.ShowNav();
	//if ( val == "4" ) theHud.ShowOverview();
}

exec function PanelSelectorShow()
{
	//theHud.SetPassEscKey( true );
	//thePlayer.SetHotKeysBlocked( true );
	//theHud.m_hud.SetMainFrame("ui_panelselector.swf");
	//theHud.EnableInput( false, false, true );
	//theGame.SetActivePause( true );
}

exec function PanelSelectorClose()
{
	//theHud.SetPassEscKey( false );
	//thePlayer.SetHotKeysBlocked( false );
	//theHud.m_hud.SetMainFrame("");
	//theHud.EnableInput( false, false, false );
	//theGame.SetActivePause( false );
}

