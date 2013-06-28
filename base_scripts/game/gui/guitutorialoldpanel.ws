//inv
/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Inventory gui panel
/** Copyright © 2010 CD Projekt Red.
/***********************************************************************/

class CGuiTutorialOld extends CGuiPanel
{
	private var tutorialId 		: string;
	private var title 			: string;
	private var text 			: string;
	private var img 			: string;
		
	private var tutText 		: string;
	private var tutTitle 		: string;
	private var tutImg 			: string;
	
	private var res 			: bool;
		
	private var AS_tutold		: int;
	
	function GetPanelPath() : string { return "ui_tutsmall.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		theGame.FadeInAsync(0.5);
				
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );

		if( theHud.m_hud.m_fastMenu )
		{
			theHud.m_hud.HideFastMenu();
		}

		tutorialId = theGame.oldTutorialId;
	
		// transfer data to theGame
		
		title = tutorialId + "_title";
		text = tutorialId + "_text";
		img = theGame.oldTutorialImg;

		if ( img != "" ) 
		{
			img = "img://globals/gui/icons/tutorials/" + img + ".dds";
			theHud.PreloadIcon( img );
		}				
		
		tutTitle = StrUpperUTF( GetLocStringByKeyExt( title ) );
		tutText = theHud.m_hud.ParseButtons(  GetLocStringByKeyExt( text ) );
		tutImg = "<img src='" + img + "'>" ;

		thePlayer.ResetPlayerMovement();
		theHud.EnableInput( true, true, true );	
		theGame.SetActivePause( true );

		// Add to journal
		thePlayer.AddTutorialEntry( title, text, img );
	}

	
	event OnClosePanel()
	{

		theGame.SetActivePause( false );
		theHud.EnableInput( false, false, false );
		thePlayer.ResetPlayerMovement();
		
		theHud.ForgetObject( AS_tutold );
		
		theSound.RestoreAllSounds();
		thePlayer.ResetPlayerMovement();
		
		super.OnClosePanel();
		
		theHud.m_messages.HideConfirmationBox(); // Just for sure
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////

	private final function FillData()
	{
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mTutSmall", AS_tutold ) )
		{
			LogChannel( 'GUI', "CGuiInventory: No m_controls found at the Scaleform side!" );
		}

		//tutorial panel data
		theHud.SetString( "Title", tutTitle, AS_tutold );
		theHud.SetString( "Img", tutImg, AS_tutold );
		theHud.SetString( "Txt", tutText, AS_tutold );

		//call flash functions
		theHud.Invoke( "Commit", AS_tutold );
	}
}

