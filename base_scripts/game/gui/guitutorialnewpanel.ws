//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiTutorialNew extends CGuiPanel
{
	private var AS_tutnew			: int;
	var tutText 					: string;
	var tutText1 					: string;
	var tutText2 					: string;
	var tutText3 					: string;
	var tutText4 					: string;
	var tutIcon1 					: string;
	var tutIcon2 					: string;
	var tutIcon3 					: string;
	var tutIcon4 					: string;
	var tutTitle 					: string;
	var tutInfo 					: string;
	var tutButton 					: string;
	var tutImg 						: string;
	var tutorialId 					: string;
	var title 						: string;
	var text 						: string;
	var text1 						: string;
	var text2 						: string;
	var text3 						: string;
	var text4						: string;
	var icon1						: string;
	var icon2						: string;
	var icon3						: string;
	var icon4						: string;
	var info 						: string;
	var img							: string;
	
	function GetPanelPath() : string { return "ui_tutorial.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.FadeInAsync(0.5);
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
	
		theHud.EnableInput( true, true, true );
		theGame.SetActivePause( true );
		theGame.TutorialBlockGameInputsOnPanels( true );
		
		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}
		
		if( theHud.m_hud.m_fastMenu )
		{
			theHud.m_hud.HideFastMenu();
		}
		
		thePlayer.ResetPlayerMovement();
		
		theHud.m_hud.setCSText( "", "" );
	}
	
	event OnClosePanel()
	{
		// control the pause manually before process inventory changes,
		// so player will not see mounted and unmounted items

		theHud.ForgetObject( AS_tutnew );

		/*
		if( !theGame.IsUsingPad )
		{
			theHud.EnableInput( false, false, false );
		}
		*/

		theGame.TutorialBlockGameInputsOnPanels( false );
		theHud.EnableInput( false, false, false );
		theGame.SetActivePause( false );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure

		Log("");
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////

	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mTutorial", AS_tutnew ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No m_controls found at the Scaleform side!" );
		}

		// add tutorial fact

		if( !theGame.tutorialPanelByPlayer )
		{
			if ( !FactsDoesExist("tutorial_" + tutorialId) && tutorialId!="" && !FactsDoesExist("tutorial_showed") )
			{
				FactsAdd("tutorial_" + tutorialId, 1);
				FactsAdd("tutorial_showed", 1);
			}
		}
		
		//tutorial panel common data

		info = "[[tutinfo_pc]]";
		tutInfo = theHud.m_hud.ParseButtons(  GetLocStringByKeyExt( info ) );
		tutButton = theHud.m_hud.ParseButtons( "[[GI_TutorialHint,1]]" );
		img = theGame.tutorialImage;
		
		if ( img != "" ) 
		{
			img = "img://globals/gui/icons/tutorials/" + img + ".dds' width='256' height='256'>";
			theHud.PreloadIcon( img );
		}
		tutImg = "<img src='" + img + " '>" ;
		
		//prepare specific panel
		
		if( theGame.tutorialPanelNew ) // icons panel
		{
			// title
			title = theGame.tutorialText1 + "_title";
			tutTitle = StrUpperUTF( GetLocStringByKeyExt( title ) );
		
			//prepare texts	
		
			// textfield 1
			if( theGame.tutorialText1 == "" )	
				text1 = "NoText";
			else	
				text1 = theGame.tutorialText1 + "_text";
			//textfield 2
			if( theGame.tutorialText2 == "" )
				text2 = "NoText";
			else	
				text2 = theGame.tutorialText2 + "_text";
			//textfield 3
			if( theGame.tutorialText3 == "" )
				text3 = "NoText";
			else	
				text3 = theGame.tutorialText3 + "_text";	
			//textfield 4
			if( theGame.tutorialText4 == "" )
				text4 = "NoText";
			else	
				text4 = theGame.tutorialText4 + "_text";
					
				
			tutText1 = theHud.m_hud.ParseButtons( GetLocStringByKeyExt( text1 ) );
			tutText2 = theHud.m_hud.ParseButtons( GetLocStringByKeyExt( text2 ) );
			tutText3 = theHud.m_hud.ParseButtons( GetLocStringByKeyExt( text3 ) );
			tutText4 = theHud.m_hud.ParseButtons( GetLocStringByKeyExt( text4 ) );
			
			//prepare icons
			
			//icon 1
			if( theGame.tutorialIcon1 == "" )	
				icon1 = "NoIcon";
			else	
				icon1 = theGame.tutorialIcon1;
			//icon 2
			if( theGame.tutorialIcon2 == "" )
				icon2 = "NoIcon";
			else	
				icon2 = theGame.tutorialIcon2;
			//icon 3
			if( theGame.tutorialIcon3 == "" )
				icon3 = "NoIcon";
			else	
				icon3 = theGame.tutorialIcon3;	
			//icon 4
			if( theGame.tutorialIcon4 == "" )
				icon4 = "NoIcon";
			else	
				icon4 = theGame.tutorialIcon4;	

			tutIcon1 = theHud.m_hud.ParseButtons( icon1 );		
			tutIcon2 = theHud.m_hud.ParseButtons( icon2 );		
			tutIcon3 = theHud.m_hud.ParseButtons( icon3 );		
			tutIcon4 = theHud.m_hud.ParseButtons( icon4 );		
			
			//fill data
				
			theHud.SetString( "Title", tutTitle, AS_tutnew );
			theHud.SetString( "Img", tutImg, AS_tutnew );
			theHud.SetString( "Txt1", tutText1, AS_tutnew );
			theHud.SetString( "Txt2", tutText2, AS_tutnew );
			theHud.SetString( "Txt3", tutText3, AS_tutnew );
			theHud.SetString( "Txt4", tutText4, AS_tutnew );
			theHud.SetString( "Icon1", tutIcon1, AS_tutnew );
			theHud.SetString( "Icon2", tutIcon2, AS_tutnew );
			theHud.SetString( "Icon3", tutIcon3, AS_tutnew );
			theHud.SetString( "Icon4", tutIcon4, AS_tutnew );
			theHud.SetString( "Info", tutInfo, AS_tutnew );
			theHud.SetString( "ExitButton", tutButton, AS_tutnew );
			theHud.SetBool( "PlayerInput", theGame.tutorialPanelByPlayer, AS_tutnew );
			theHud.SetBool( "TutorialMode", true, AS_tutnew );
		}
		else	//fill standard panel
		{
			tutorialId = theGame.tutorialText;
			title = tutorialId + "_title";
			text = tutorialId + "_text";
			
			tutTitle = StrUpperUTF( GetLocStringByKeyExt( title ) );
			tutText = theHud.m_hud.ParseButtons(  GetLocStringByKeyExt( text ) );
			
			theHud.SetString( "Title", tutTitle, AS_tutnew );
			theHud.SetString( "Img", tutImg, AS_tutnew );
			theHud.SetString( "Txt", tutText, AS_tutnew );
			theHud.SetString( "Info", tutInfo, AS_tutnew );
			theHud.SetString( "ExitButton", tutButton, AS_tutnew );
			theHud.SetBool( "PlayerInput", theGame.tutorialPanelByPlayer, AS_tutnew );
			theHud.SetBool( "TutorialMode", false, AS_tutnew );
		}
		
		//call flash functions
		theHud.Invoke( "Commit", AS_tutnew );

		// Add to journal
		if( !theGame.tutorialPanelByPlayer )
		{
			if( thePlayer.AddNewTutorialEntry( tutTitle, tutText1, tutText2, tutText3, tutText4, tutIcon1, tutIcon2, tutIcon3, tutIcon4, tutImg ) )
				Log( "======================== NEW TUTORIAL ENTRY = " +tutorialId + " =================================" );
		}		
	}
}

