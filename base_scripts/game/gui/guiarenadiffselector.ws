function ShowArenaDiffSelector()
{
	theHud.m_hud.SetMainFrame("ui_arenadif.swf");
	theHud.EnableInput( true, false, true );
	//theGame.SetActivePause( true );

}

/*exec function CloseArenaDif( diff : string )
{
	var selectedDif : int = StringToInt( diff ) - 1;
	
	thePlayer.SetManualControl(true, true);
	theHud.EnableInput( false, false, false, false );
	theGame.SetActivePause( false );
	theHud.m_hud.SetMainFrame("");
	
		if (selectedDif == 0) theGame.SetDifficultyLevel( 5 ); // casual 5
		if (selectedDif == 1) theGame.SetDifficultyLevel( 0 ); // easy 0
		if (selectedDif == 2) theGame.SetDifficultyLevel( 1 ); // med 1
		if (selectedDif == 3) theGame.SetDifficultyLevel( 2 ); // hard 2
		if (selectedDif == 4) theGame.SetDifficultyLevel( 3 ); // insane 3
		if (selectedDif == 5) theGame.SetDifficultyLevel( 4 ); // dark 4
	
}*/

/*exec function ArenaGetDiff()
{
	var args : array <CFlashValueScript>;
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "arena" ) ));
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "ArenaDifTooltip" )  )); // klucz uzyc: ArenaDifTooltip
	//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryEasy" ) ));
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyEasy"   ) ));
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyMedium" ) ));
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyHard"   ) ));
	//args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyInsane" ) ));
	args.PushBack( FlashValueFromString( GetLocStringByKeyExt( "menuDifficultyVeryHard"   ) ));
		
	//theHud.InvokeManyArgs("ArenaGetDiff", args);
	//theHud.InvokeManyArgs("pPanel.ArenaGetDiff", args);
	theHud.InvokeManyArgs("pPanelClass.ArenaGetDiff", args);
}*/
