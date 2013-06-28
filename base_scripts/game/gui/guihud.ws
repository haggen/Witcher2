/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui hud methods
/** Copyright © 2010
/***********************************************************************/

enum ENpcAimPointKind
{
	NAPK_Hostile             = 0,
	NAPK_Riposte             = 1,
	NAPK_Talk                = 2,
	NAPK_Container           = 3,
	NAPK_FocusPoint          = 4,
	NAPK_Door                = 5,
	NAPK_Exploration         = 6,
	NAPK_ExplorationDisabled = 7,
	NAPK_HostileLocked		 = 8,
}

class CGuiHud
{
	var AS_hud				: int;
	var isInteractive		: bool;
	default isInteractive = true;

	public var tutorialEnabled : bool;
	default tutorialEnabled = true;

	public var isTutorialPlayed : bool;
	default isTutorialPlayed = false;

	public var combatLogEnabled : bool;
	default combatLogEnabled = true;
	
	event OnGameStarting()
	{
		var value : float;
		var game  : CWitcherGame;
		
		game = theGame;
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mHUD", AS_hud ) )
		{
			Log( "No mHUD found at the Scaleform side!" );
		}
		
		theHud.InvokeOneArg( "setIsFastMenuActive", FlashValueFromBoolean( false ), AS_hud );
		
		// Read from game config
		if( theGame.ReadConfigParamFloat( "User", "Gameplay", "ShowTutorial", value ) )
		{
			tutorialEnabled = value == 1.0f;
		}
		
		if( theGame.ReadConfigParamFloat( "User", "Gameplay", "ShowCombatLog", value ) )
		{
			combatLogEnabled = value == 1.0f;
		}
		
		if( theGame.ReadConfigParamFloat( "User", "Gameplay", "HardQte", value ) )
		{
			game.hardQte = value == 1.0f;
		}

		if( theGame.ReadConfigParamFloat( "User", "Gameplay", "UsePad", value ) )
		{
			theGame.TogglePad( value == 1.0f && theGame.IsPadConnected() );
		}

		if( theGame.ReadConfigParamFloat( "User", "Gameplay", "ShowSubtitles", value ) )
		{
			game.subtitlesEnabled = value == 1.0f;
		}
		
		if( theGame.ReadConfigParamFloat( "User", "Tutorial", "Played", value ) )
		{
			isTutorialPlayed = value == 1.0f;
		}	
	}
	
	final function UpdateKeyBindings()
	{
		var ikName : string;
		
		ikName = StrMid( theGame.GetFirstKeyForGameInput( 'GI_Adrenaline' ), 3 );
		SetAdrenalineActionIK( ikName );
		ikName = StrMid( theGame.GetFirstKeyForGameInput( 'GI_Medallion' ), 3 );
		SetMedallionActionIK( ikName );
	}
	
	// ---------------------------------------------------------------------------------------------------
	//
	// Hud stats indicators
	//
	// ---------------------------------------------------------------------------------------------------

	// Health
	final function SetPCHealth( current, maximal : float )
	{
		var params		: array< CFlashValueScript >;
		
		params.PushBack( FlashValueFromFloat( current ) );
		params.PushBack( FlashValueFromFloat( maximal ) );
		theHud.InvokeManyArgs( "setPCHealth", params, AS_hud );
	}
	// Adrenaline
	final function SetPCAdrenalinePercent( value : float )
	{
		theHud.InvokeOneArg( "setPCAdrenalinePercent", FlashValueFromFloat( value ), AS_hud );
	}
	final function SetIsAdrenalineActive( value : bool )
	{
		theHud.InvokeOneArg( "setIsAdrenalineActive", FlashValueFromBoolean( value ), AS_hud );
	}
	final function SetAdrenalineActionIK( value : string )
	{
		theHud.InvokeOneArg( "setAdrenalineActionIK", FlashValueFromString( value ), AS_hud );
	}
	// Toxicity
	final function SetPCToxicityPercent( value : float )
	{
		theHud.InvokeOneArg( "setPCToxicPercent", FlashValueFromFloat( value ), AS_hud );
	}
	// Stamina
	final function SetPCStaminaCurrentLevel( value : float )
	{
		theHud.InvokeOneArg( "setPCStaminaCurrentLevel", FlashValueFromFloat( value ), AS_hud );
	}
	final function SetPCStaminaMaximumLevel( value : float )
	{
		theHud.InvokeOneArg( "setPCStaminaMaximumLevel", FlashValueFromFloat( value ), AS_hud );
	}
	final function SetPCStaminaBlink()
	{
		theHud.Invoke("vHUD.setStaminaBlink");
	}
	
	// FX Hole
	final function ShowFXHole()
	{
		theHud.Invoke("vHUD.showHole");
	}
	final function HideFXHole()
	{
		theHud.Invoke("vHUD.hideHole");
	}

	
	//SelectedItems
	final function SetItemAlpha( val1 : bool, val2 : int)
	{
		var args : array < CFlashValueScript >;
		args.PushBack( FlashValueFromBoolean(val1) );
		args.PushBack( FlashValueFromFloat(val2) );
		theHud.InvokeManyArgs("vHUD.setItemAlpha", args);
	}
	final function setItemBlink( val1 : bool )
	{
		theHud.InvokeOneArg("vHUD.setItemBlink", FlashValueFromBoolean(val1) );
	}	
		
	// Medallion
	final function SetIsMedallionActive( value : bool )
	{
		theHud.InvokeOneArg( "setIsMedallionActive", FlashValueFromBoolean( value ), AS_hud );
	}
	final function SetMedallionActionIK( value : string )
	{
		theHud.InvokeOneArg( "setMedallionActionIK", FlashValueFromString( value ), AS_hud );
	}
	
	// Loot
	final function SetLootTable( AS_lootArray : int )
	{
		theHud.InvokeOneArg( "setLootTable", FlashValueFromHandle( AS_lootArray ), AS_hud );
	}
	
	// Level up
	final function NotifyLevelUp( level : float )
	{
		theHud.InvokeOneArg( "setLevelInfo", FlashValueFromFloat( level ), AS_hud );
	}
	
	// Show game over screen
	final function SetGameOver()
	{
		var confirm : CGuiConfirmGameEnd;
		var cannotLoadSaveMsgBox : CGuiCannotLoadSave;

		//theHud.ShowArenaFail();
		theGame.FadeOutAsync(0.0);
		theGame.FadeInAsync(9.0);
		theSound.PlaySound("gui/other/gameover");
		theHud.InvokeOneArg( "setGameOver", FlashValueFromBoolean( true ), AS_hud );
		
		
		if( theGame.GetDifficultyLevel() == 3 /* Insane */ )
		{
			cannotLoadSaveMsgBox = new CGuiCannotLoadSave in theHud.m_messages;
			cannotLoadSaveMsgBox.exitAfterOk = true;
			theHud.m_messages.ShowConfirmationBox( cannotLoadSaveMsgBox );
		}
		else
		{
			confirm = new CGuiConfirmGameEnd in theHud.m_messages;
			theHud.m_messages.ShowConfirmationBox( confirm );
		}
	}
	
	function SetMainFrame( panelName : string )
	{
		OpenPanel( panelName, "", "", false, false, true );
	}

	public function OpenPanel( panelPath : string, fadePath : string, videoName : string, controlRender : bool, controlPause : bool, controlHud : bool )
	{
		var areaArgs : array< CFlashValueScript >;
		
		areaArgs.PushBack( FlashValueFromString( panelPath ) );
		areaArgs.PushBack( FlashValueFromString( fadePath ) );
		areaArgs.PushBack( FlashValueFromString( videoName ) );
		areaArgs.PushBack( FlashValueFromBoolean( controlRender ) );
		areaArgs.PushBack( FlashValueFromBoolean( controlPause ) );
		areaArgs.PushBack( FlashValueFromBoolean( controlHud ) );
		theHud.InvokeManyArgs( "OpenPanel", areaArgs );
	}
	function DisableTutorial()
	{
		tutorialEnabled = false;
	}
	
	function EnableTutorial()
	{
		tutorialEnabled = true;
	}
	// ---------------------------------------------------------------------------------------------------
	//
	// Text fields
	//
	// ---------------------------------------------------------------------------------------------------

	function clearEntryText()
	{
		setJournalEntryText( "", "");
		setAbilityEntryText( "", "");
	}
	function setJournalEntryText( txtTitle : string, txtDesc : string)
	{
		theSound.PlaySound("chardev/gui_chardev_addmutagen");
		setKnowledgeEntryText( txtTitle , txtDesc );
		/*var arrayData   : array < CFlashValueScript >;
		
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtTitle ) ) );
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtDesc ) ) );
				
		theHud.InvokeManyArgs("vHUD.playJorunalEntry", arrayData );*/
	}	
	function setKnowledgeEntryText( txtTitle : string, txtDesc : string)
	{
		var arrayData   : array < CFlashValueScript >;
		
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtTitle ) ) );
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtDesc ) ) );
				
		theHud.InvokeManyArgs("vHUD.playKnowledgeEntry", arrayData );
	}
	function setAbilityEntryText( txtTitle : string, txtDesc : string)
	{
		var arrayData   : array < CFlashValueScript >;
		
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtTitle ) ) );
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtDesc ) ) );
				
		theHud.InvokeManyArgs("vHUD.playAbilityEntry", arrayData );
	}		
	
	function setCSText( txtTitle : string, txtDesc : string)
	{
		var arrayData   : array < CFlashValueScript >;
		
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtTitle ) ) );
		arrayData.PushBack( FlashValueFromString( StrUpperUTF( txtDesc ) ) );
				
		theHud.InvokeManyArgs("vHUD.playCSText", arrayData );
	}
	
	function clearCSText( )
	{
		theHud.Invoke("vHUD.stopCSText" );
	}	
	
	// Shows text on hud, fieldNum {0,1}, returns true on success
	function SetTextField( fieldNum : int, text : string, x : int, y : int ) : bool
	{
		var textFieldName : string;

		if ( fieldNum == 0 )
		{
			textFieldName = "lb12";
		}
		else if ( fieldNum == 1 )
		{
			textFieldName = "lb16";
		}
		else
		{
			return false;
		}

		theHud.SetString( textFieldName + ".htmlText", text );
		theHud.SetFloat ( textFieldName + "._x", x );
		theHud.SetFloat ( textFieldName + "._y", y );

		return true;
	}
	
	// ---------------------------------------------------------------------------------------------------
	//
	// Combat, NPC and BOSS health and targeting
	//
	// ---------------------------------------------------------------------------------------------------
	
	final function CombatLogAdd( text : string )
	{
		if( combatLogEnabled )
		{
			theHud.InvokeOneArg( "addCombatLog", FlashValueFromString( text ), AS_hud );
		}
	}
	final function CombatLogSet( text : string )
	{
		if( combatLogEnabled )
		{
			theHud.InvokeOneArg( "setCombatLog", FlashValueFromString( text ), AS_hud );
		}
	}
	final function CombatLogClear()
	{
		if( combatLogEnabled )
		{
			theHud.Invoke( "setCombatLog", AS_hud );
		}
	}
	
	final function EnableRiposte( enable : bool )
	{
		if ( enable )
		{
			theHud.InvokeOneArg( "setNPCAimPointKind", FlashValueFromFloat( 1.0f ), AS_hud );
		}
		else
		{
			theHud.InvokeOneArg( "setNPCAimPointKind", FlashValueFromFloat( 0.0f ), AS_hud );
		}
	}
	
	final function SetNPCAimPointKind( aimPointKind : ENpcAimPointKind )
	{
		if ( thePlayer.GetIsEnemyLocked() && aimPointKind == NAPK_Hostile )
		{
			aimPointKind = NAPK_HostileLocked;
			theHud.InvokeOneArg( "setNPCAimPointKind", FlashValueFromFloat( (int)aimPointKind ), AS_hud );
		} else
		{
			theHud.InvokeOneArg( "setNPCAimPointKind", FlashValueFromFloat( (int)aimPointKind ), AS_hud );
		}
	}

	//
	// NPC health
	//

	final function SetNPCBarPos( worldPos : Vector )
	{
		var x, y: int;
		var args : array <CFlashValueScript>;
		
		args.PushBack(FlashValueFromInt(x));
		args.PushBack(FlashValueFromInt(y));
		
		theGame.GetActiveCameraComponent().WorldVectorToViewCoords( worldPos, x, y );
		theHud.InvokeManyArgs( "vHUD.setNPCBarPos", args );
	}	
	
	final function SetNPCName( value : string )
	{
		theHud.InvokeOneArg( "setNPCName", FlashValueFromString( value ), AS_hud );
	}
	final function SetNPCHealthPercent( value : float )
	{
		theHud.InvokeOneArg( "setNPCHealthPercent", FlashValueFromFloat( value ), AS_hud );
	}
	//// Use imported theHud.HudTargetActor( actor : CActor, isBoss : bool );
	//final function SetNPCAimPoint( worldPos : Vector )
	//{
	//	var x, y: int;
	//	
	//	theGame.GetActiveCameraComponent().WorldVectorToViewCoords( worldPos, (int)guiWidth, (int)guiHeight, x, y );
	//	theHud.InvokeMethod_FF( "setNPCAimPoint", x, y, AS_hud );
	//}
	final function HideNPCHealth()
	{
		theHud.Invoke( "setNPCName", AS_hud );
		//theHud.InvokeMethod( "setNPCAimPoint", AS_hud );
		theHud.HudTargetActorEx( NULL, false );
	}
	
	//
	// BOSS health
	//
	
	// This shows boss name and hides armor bar, for bosses with armor, call SetBossArmorPercent after SetBossName
	final function SetBossName( value : string )
	{
		theHud.InvokeOneArg( "setBossName", FlashValueFromString( value ), AS_hud );
	}
	final function SetBossHealthPercent( value : float )
	{
		theHud.InvokeOneArg( "setBossHealthPercent", FlashValueFromFloat( value ), AS_hud );
	}
	final function SetBossArmorPercent( value : float )
	{
		theHud.InvokeOneArg( "setBossArmorPercent", FlashValueFromFloat( value ), AS_hud );
	}
	//// Use imported theHud.HudTargetActor( actor : CActor, isBoss : bool );
	//final function SetBossAimPoint( worldPos : Vector )
	//{
	//	var x, y: int;
	//	
	//	theGame.GetActiveCameraComponent().WorldVectorToViewCoords( worldPos, (int)guiWidth, (int)guiHeight, x, y );
	//	theHud.InvokeMethod_FF( "setBossAimPoint", x, y, AS_hud );
	//}
	final function HideBossHealth()
	{
		theHud.Invoke( "setBossName", AS_hud );
		//theHud.InvokeMethod( "setBossAimPoint", AS_hud );
		theHud.HudTargetActorEx( NULL, true );
	}
	
	// ---------------------------------------------------------------------------------------------------
	//
	// Fast menu
	//
	// ---------------------------------------------------------------------------------------------------
	
	var m_fastMenu : CGuiFastMenu;
	
	final function ShowFastMenu()
	{
		if ( ! m_fastMenu )
		{
			m_fastMenu = new CGuiFastMenu in this;
		}
		m_fastMenu.OpenPanel( "", false, false, true );
	}
	
	final function HideFastMenu()
	{
		if( m_fastMenu )
		{
			m_fastMenu.ClosePanel();
		}
	}
	
	// ---------------------------------------------------------------------------------------------------
	//
	// Minimap
	//
	// ---------------------------------------------------------------------------------------------------
	
	final function ShowMinimap()
	{
		// TODO: DM: Implement
		// Do zrobienia po stronie Mikolaja
	}
	
	final function HideMinimap()
	{
		// TODO: DM: Implement
		// Do zrobienia po stronie Mikolaja
	}
	
	//// Use imported theHud.LoadMap( mapIndex : int );
	//final function SetNavMap( file : string )
	//{
	//	theHud.InvokeMethod_S( "setNavMap", file, AS_hud );
	//}
	
	final function SendNavigationDataToGUI( master : CEntity )
	{
		var playerPos	    : Vector		= master.GetWorldPosition();
		var playerRot	    : EulerAngles	= master.GetWorldRotation();
		var cameraRot	    : EulerAngles	= theGame.GetActiveCameraComponent().GetWorldRotation();
		
		var questEntities   : array< CEntity >;
		var questEntity     : CEntity;
		var questPos	    : Vector;
		var questVec	    : Vector;
		var questDist	    : float;
		var questYaw	    : float;
		var questAlpha	    : float;
		
		var params		    : array< CFlashValueScript >;
		var AS_navHintArray : int;
		var AS_navHintObj	: int;
		
		var questMapPinsPositions : array< Vector >;
		
		var i			    : int;
	
		var x, y		    : float;
		x = ( playerPos.X-theHud.miniMapMinX ) * theHud.miniMapScaleX;
		y = ( playerPos.Y-theHud.miniMapMinY ) * theHud.miniMapScaleY;
		
		// Send rotations
		theHud.InvokeOneArg( "setNavCameraDirection",	FlashValueFromFloat( cameraRot.Yaw ), AS_hud );
		theHud.InvokeOneArg( "setNavActorDirection",	FlashValueFromFloat( cameraRot.Yaw-playerRot.Yaw ), AS_hud );
		// Send player position
		params.Clear();
		params.PushBack( FlashValueFromFloat( x ) );
		params.PushBack( FlashValueFromFloat( y ) );
		theHud.InvokeManyArgs( "setNavPosition", params, AS_hud );

		// Send quest position
		// TODO: Move this method to the code - code updating mappin positions 
		// should have this code - just iterate through all QUEST mappins in code
		// and update this
		//questEntities = thePlayer.GetTrackedQuestEntities();
		
		theHud.GetQuestMapPinsPositions( questMapPinsPositions );
		if ( questMapPinsPositions.Size() > 0 )
		{
			AS_navHintArray = theHud.CreateArray( "m_arrayOfNumbers" );
			
			for ( i = 0; i < questMapPinsPositions.Size(); i += 1 )
			{
				questPos	= questMapPinsPositions[i];
				questVec	= questPos - playerPos;
			
				questDist	= VecLength( questVec );
				questYaw	= VecHeading( questVec );
			
				questAlpha	= AbsF( MinF( 1.f, ( questDist * theHud.miniMapScaleX ) / 70.f ) * 100.f );
				if ( questAlpha > 70 ) questAlpha = 70;
				
				AS_navHintObj = theHud.CreateObject( "NavHintDirection" );
				theHud.SetFloat( "Direction", cameraRot.Yaw-questYaw, AS_navHintObj );
				theHud.SetFloat( "Distance", questAlpha,             AS_navHintObj );
				theHud.PushObject( AS_navHintArray, AS_navHintObj );
				theHud.ForgetObject( AS_navHintObj );
			}
			
			theHud.InvokeOneArg( "setNavHintDirection", FlashValueFromHandle(AS_navHintArray) , AS_hud );	
			
			theHud.ForgetObject( AS_navHintArray );
		}
		else
		{
			theHud.Invoke( "setNavHintDirection", AS_hud );
		}
		
		
		/*
		if ( questEntities.Size() > 0 )
		{
			AS_navHintArray = theHud.CreateArray( "m_arrayOfNumbers" );
			
			for ( i = 0; i < questEntities.Size(); i += 1 )
			{
				questEntity = questEntities[i];
				//if ( questEntity.IsA('CNewNPC') )
				//{
					//continue;
				//}
			
				questPos	= questEntity.GetWorldPosition();
				questVec	= questPos - playerPos;
			
				questDist	= VecLength( questVec );
				questYaw	= VecHeading( questVec );
			
				questAlpha	= AbsF( MinF( 1.f, ( questDist * theHud.miniMapScaleX ) / 70.f ) * 100.f );
				if ( questAlpha > 70 ) questAlpha = 70;
				
				AS_navHintObj = theHud.CreateObject( "NavHintDirection" );
				theHud.SetFloat( "Direction", cameraRot.Yaw-questYaw, AS_navHintObj );
				theHud.SetFloat( "Distance", questAlpha,             AS_navHintObj );
				theHud.PushObject( AS_navHintArray, AS_navHintObj );
				theHud.ForgetObject( AS_navHintObj );
			}
			
			
			//params.Clear();
			//params.PushBack( FlashValueFromFloat( cameraRot.Yaw-questYaw ) );
			//params.PushBack( FlashValueFromFloat( questAlpha ) );
			//theHud.InvokeManyArgs( "setNavHintDirection",ims, AS_hud );
			
			theHud.InvokeOneArg( "setNavHintDirection", FlashValueFromHandle(AS_navHintArray) , AS_hud );	
			
			theHud.ForgetObject( AS_navHintArray );
		}
		else
		{
			//theHud.InvokeMethod_F( "setNavHintDirection", cameraRot.Yaw-playerRot.Yaw, AS_hud );
			theHud.Invoke( "setNavHintDirection", AS_hud );
		}
		*/
		
		//SetTestTrack();
	}
	
	// ---------------------------------------------------------------------------------------------------
	//
	// Buffs
	//
	// ---------------------------------------------------------------------------------------------------
	
	final function UpdateBuffsTimes( AS_buffsTimes : int )
	{
		theHud.InvokeOneArg( "refreshBuffs", FlashValueFromHandle( AS_buffsTimes ), AS_hud );
		// LogChannel( 'GUI', "Update buffs: " + AS_buffsTimes );
	}
	
	final function UpdateBuffs()
	{
		var i,s				: int;
		var AS_buffs		: int;
		var AS_buff			: int;
		var activeBuffs		: array < SBuff >;
		var criticalEffects	: array < W2CriticalEffectBase >;
		var quen			: CWitcherSignQuen;
		
		AS_buffs = theHud.CreateAnonymousArray();
		
		// Pass oils
		activeBuffs = thePlayer.GetActiveOils();
		s = activeBuffs.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( activeBuffs[ i ].m_name ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/items/" + StrReplaceAll(activeBuffs[ i ].m_name, " ", "") + "_64x64.dds",	AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration,	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	activeBuffs[ i ].m_duration,												AS_buff );
			
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}		
		
		// Pass elixirs
		activeBuffs = thePlayer.GetActiveElixirs();
		s = activeBuffs.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( activeBuffs[ i ].m_name ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/items/" + StrReplaceAll(activeBuffs[ i ].m_name, " ", "") + "_64x64.dds",	AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration,	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	activeBuffs[ i ].m_duration,												AS_buff );
			
			//LogChannel( 'GUI', "Idx: " + i );
			//LogChannel( 'GUI', "DurationPercent: " + (( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration) );
			//LogChannel( 'GUI', "DurationSeconds: " + (activeBuffs[ i ].m_duration) );
		
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}
		
		// Pass critical effects
		criticalEffects = thePlayer.criticalEffects;
		s = criticalEffects.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				criticalEffects[ i ].GetEffectName(),											AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/items/" + criticalEffects[ i ].GetEffectName() + "_64x64.dds",		AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * criticalEffects[ i ].GetTTL() ) / criticalEffects[ i ].GetDuration(),	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	criticalEffects[ i ].GetTTL(),													AS_buff );
	
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}
		
		quen = thePlayer.getActiveQuen();
		if ( quen )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( "Quen" ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/signs/quen_64x64.dds",			AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * quen.GetTTL() ) / quen.GetTotalDuration(),	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	quen.GetTTL(),											AS_buff );
	
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}

		theHud.InvokeOneArg( "setBuffs", FlashValueFromHandle( AS_buffs ), AS_hud );
		
		theHud.ForgetObject( AS_buffs );
	}
	
	// ############## TUTORIAL STUFF HERE ################
	
	function GetImagePathForIK( input_key : string ) : string
	{
		var path : string;
		var currentLocale : string;
		
		currentLocale = theGame.GetCurrentLocale();
		
		path = " <img src='img://globals/gui/icons/buttons/" + currentLocale + "/" + currentLocale + "_";
		path += StrMid( input_key, 3 ); // Remove IK_ part
		path += "_64x64.dds' width='32' height='32'> ";
		
		theHud.PreloadIcon( path );
		
		return path;
	}
	
	function ParseButtons( str : string ) : string
	{
		var output : string = str;
		var gameInputMappings : array< SGameInputMapping >;
		var i : int;
		var path : string;
		var replacedText : string;
		var currentLocale : string;
		var localeDependedPathPart : string;
		var input_key : string;
		
		theGame.GetGameInputMappings( gameInputMappings );
		currentLocale = theGame.GetCurrentLocale();
		
		localeDependedPathPart = currentLocale + "/" + currentLocale + "_";
		
		for ( i=0; i<gameInputMappings.Size(); i+=1 )
		{
			input_key = gameInputMappings[i].inputKey;
			path = " <img src='img://globals/gui/icons/buttons/";
			path += localeDependedPathPart;
			path += StrMid( gameInputMappings[i].inputKey, 3 ); // Remove IK_ part
			path += "_64x64.dds' width='32' height='32'> ";
	
			theHud.PreloadIcon( path );
			
			replacedText = "[[" + gameInputMappings[i].gameInputName + "," + (int)gameInputMappings[i].activation +  "]]";
			
			//Log( "to be replaced: " + replacedText );
			//Log( "replaced by   : " + path );
			
			output = StrReplaceAll( output, replacedText, path );
		}
		
		return output;
	}

	function ShowTutorial( tutorialId : string, img : string, slowTime : bool, optional additionalTime : float ) : bool
	{
		var args : array < CFlashValueScript >;
		var title : string = tutorialId + "_title";
		var text : string  = tutorialId + "_text";
		
		var tutText : string;
		var tutTitle : string;
		var tutImg : string;
		
		var time : float = additionalTime + 6;
		var res : bool;
		//var cam : CStaticCamera;  //= (CStaticCamera)theGame.GetActiveCameraComponent().GetEntity();
		
		if( theGame.tutorialHideOldPanels )
		{
			return true;
		}
		
		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}

		//cam = (CStaticCamera)theGame.GetActiveCameraComponent().GetEntity();
		//if( theGame.GetActiveCameraComponent().GetCurrentStateName() == theCamera.GetComponent() )		

		//if( cam )
		//{
		//	return true;
		//}
		
		if ( !FactsDoesExist("tutorial_" + tutorialId) && tutorialId!="" && !FactsDoesExist("tutorial_showed") )
		{
			FactsAdd("tutorial_" + tutorialId, 1);
			FactsAdd("tutorial_showed", 1);
			if ( img != "" ) 
			{
				img = "img://globals/gui/icons/tutorials/" + img + ".dds";
				theHud.PreloadIcon( img );
			}

			if( tutorialEnabled )
			{
				// transfer data to theGame
				
				//tutTitle = StrUpperUTF( GetLocStringByKeyExt( title ) );
				//tutText = ParseButtons(  GetLocStringByKeyExt( text ) );
				//tutImg = "<img src='" + img + "'>" ;
				
				//theGame.SetOldTutorialData( tutImg, tutTitle, tutText );

				// Show on screen

				args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( title ) ) ) );
				args.PushBack( FlashValueFromString( ParseButtons(  GetLocStringByKeyExt( text ) ) ) );
				args.PushBack( FlashValueFromString( "<img src='" + img + "'>" ) );
				
				theHud.InvokeManyArgs( "ShowTutorial", args );
			}

			// Add to journal
			thePlayer.AddTutorialEntry( title, text, img );
			
			if ( slowTime ) 
			{	
				//theGame.SetTimeScale( 0.6 );	
			} else
			{	
				time = time + 4;
			}
			thePlayer.AddTimer('ClearTutorial', time, false );
			thePlayer.AddTimer('UnlockTutorial', time + 1, false );
			return true;
		}
	
		
		return false;
	}
	
	function ShowNewTutorial( byPlayer : bool ) : bool
	{
		var tutorialId : string = theGame.tutorialText;
		var img : string = theGame.tutorialImage;
		var args : array < CFlashValueScript >;
		var title : string = tutorialId + "_title";
		var text : string  = tutorialId + "_text";
		var info : string = "[[tutinfo]]";
		var fastMenu : CGuiFastMenu;
		
		
			
		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}
		
		thePlayer.ResetPlayerMovement();
		
		if ( img != "" ) 
		{
			img = "img://globals/gui/icons/tutorials/" + img + ".dds' width='256' height='256'> ";
			theHud.PreloadIcon( img );
		}
		// Show on screen
		args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( title ) ) ) );
		args.PushBack( FlashValueFromString( ParseButtons(  GetLocStringByKeyExt( text ) ) ) );
		args.PushBack( FlashValueFromString( "<img src='" + img + "'>" ) );
		args.PushBack( FlashValueFromBoolean( byPlayer ) );
		args.PushBack( FlashValueFromString( ParseButtons(  GetLocStringByKeyExt( info ) ) ) );
		args.PushBack( FlashValueFromString( ParseButtons( "[[GI_TutorialHint,1]]" ) ) );								//const enter icon		
		
		if( m_fastMenu )
		{
			HideFastMenu();
		}
	
		theHud.EnableInput( true, true, true );
		theGame.SetActivePause( true );
		theGame.TutorialBlockGameInputsOnPanels( true );
		theHud.InvokeManyArgs( "vHUD.Tutorial1", args );
		return false;
	}

	function ShowNewTutorialNew( byPlayer : bool, isNew : bool ) : bool
	{
		var tutIds : array< string > = theGame.tutorialNewText;
		var iconIds : array< string > = theGame.tutorialNewIcon;
		var img : string = theGame.tutorialImage;
		var args : array < CFlashValueScript >;
		var title, text, icon : string;
		var info : string = "[[tutinfo]]";
		var i, size : int;
		var x, count : int;
		var fastMenu : CGuiFastMenu;
		
		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}

		if( m_fastMenu )
		{
			HideFastMenu();
		}
		
		thePlayer.ResetPlayerMovement();

		// Show on screen
		
		//title 
		title = tutIds[0] + "_title";
		args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( title ) ) ) );
		
		//image
		if ( img != "" ) 
		{
			img = "img://globals/gui/icons/tutorials/" + img + ".dds' width='256' height='256'> ";
			theHud.PreloadIcon( img );
		}
		args.PushBack( FlashValueFromString( "<img src='" + img + "'>" ) );
		
		//texts
		size = tutIds.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( tutIds[i] == "" )
				text = "NoText";
			else	
				text = tutIds[i] + "_text";
			args.PushBack( FlashValueFromString( ParseButtons(  GetLocStringByKeyExt( text ) ) ) );
		}	
		
		//icons
		count = iconIds.Size();
		for( x = 0; x < count; x += 1 )
		{
			if( iconIds[x] == "" )
				icon = "NoIcon";
			else
				icon = iconIds[x];
			args.PushBack( FlashValueFromString( ParseButtons( icon ) ) );
		}		
		
		// other stuff
		args.PushBack( FlashValueFromBoolean( byPlayer ) );											//is turned by player
		args.PushBack( FlashValueFromString( ParseButtons( GetLocStringByKeyExt( info ) ) ) );		// const info text
		args.PushBack( FlashValueFromString( ParseButtons( "[[GI_TutorialHint,1]]" ) ) );			//const enter icon
		theHud.EnableInput( true, true, true );
		theGame.TutorialBlockGameInputsOnPanels( true );
		theGame.SetActivePause( true );
		theHud.InvokeManyArgs( "vHUD.Tutorial2", args );
		return false;
	}

	
	function TutorialSendCheckNameInSlot( itemName : name ) : bool
	{
		var arg : CFlashValueScript;
		var item : string; 
		var inv : CInventoryComponent = thePlayer.GetInventory();
		
		item = UniqueIdToString( inv.GetItemId( itemName ) );
		
		// Check for item in flash
		arg = FlashValueFromString( item );
		theHud.InvokeOneArg("TutorialTestSlots", arg );
		return false;
	}

	function ShowTutorialTask( isDisplayed : bool ) : bool
	{
		var tutorialId : string = theGame.tutorialTask;
		var args : array < CFlashValueScript >;
		var title : string = tutorialId + "_title";
		var text : string  = tutorialId + "_text";
		
		if( theGame.IsCurrentlyPlayingNonGameplayScene() )
		{
			return true;
		}
		// Show on screen
		args.PushBack( FlashValueFromBoolean( isDisplayed ) );
		args.PushBack( FlashValueFromString( ParseButtons(  GetLocStringByKeyExt( text ) ) ) );
		theHud.InvokeManyArgs( "vHUD.TaskTutorial", args );
		return false;
	}

	function KillTutorialTask() : bool
	{
		theHud.Invoke( "vHUD.CloseTask" );
	}
	
	function TutorialFlashReturnTrue() : bool
	{
		return true;
	}
	
	function HideTutorial()
	{
		//theGame.SetTimeScale( 1.0 );
		theHud.Invoke( "HideTutorial" );
	}

	function HideNewTutorial( isNew : bool )
	{
		if( isNew )
			theHud.Invoke( "vHUD.CloseTutorial2" );
		else	
			theHud.Invoke( "vHUD.CloseTutorial1" );
		
		theGame.TutorialBlockGameInputsOnPanels( false );
		theHud.EnableInput( false, false, false );
		theGame.SetActivePause( false );
		//thePlayer.AddTimer( 'TutorialDisableActiveInteractions', 0.001f, false, false );
		
	}	
	
	function UnlockTutorial()
	{
		FactsRemove("tutorial_showed");
	}	
	
	// QUEST TRACKING INFO FUNCTIONS
	
	function SetTrackQuestInfo( questName : string, questDesc : string )
	{
		var args : array < CFlashValueScript >;
		args.PushBack( FlashValueFromString( StrUpperUTF(questName) ) );
		args.PushBack( FlashValueFromString( questDesc ) );
		theHud.InvokeManyArgs( "vHUD.setQuestTrackInfo", args );
	}
	function ClearTrackQuestInfo(  )
	{
		SetTrackQuestInfo( "","" );
	}
	
	function SetTrackQuestProgress( questTrackIndex : int ) : bool
	{
		var valMin, valMax : int;
		var valStr : string;
		var outStr : string;
		var currQuestName, currQuestTodo : string;
		var currQuestTag : name;
		var questTrackId : string;
		
		if ( theGame.GetQuestLogManager().GetTrackedQuestInfo( currQuestName, currQuestTodo, currQuestTag ) )
		{
			questTrackId = thePlayer.GetQuestTrackId( questTrackIndex );
		
			if ( questTrackId == NameToString(currQuestTag) )
			{
				valStr = GetLocStringByKeyExt( "track_q" + ( questTrackIndex + 1 ) );
				valMin = FactsQuerySum( questTrackId + "_progress" );
				valMax = thePlayer.GetQuestTrackMax( questTrackIndex );
		
				outStr = valStr + ": " + valMin + " / " + valMax;
		
				Log( outStr );
		
				theHud.InvokeOneArg( "vHUD.setQuestProgress", FlashValueFromString( outStr ) );
				return true;
			}
		}

		return false;
	}

	function ClearTrackQuestProgress(  )
	{
		theHud.InvokeOneArg( "vHUD.setQuestProgress", FlashValueFromString( "" ) );
	}
	
	function SetTestTrack( questTag : name )
	{
		var questName, questTodo : string;
		var currentQuestTag : name;
		var qId : int;
		if ( theGame.GetQuestLogManager().GetTrackedQuestInfo( questName, questTodo, currentQuestTag ) )
		{
			theHud.m_hud.SetTrackQuestInfo( StrUpperUTF(questName), questTodo );
			qId = thePlayer.GetQuestTrackIdIndex( NameToString( questTag ) );
				
			Log( "questName " + questName );
			Log( "questTag " + NameToString( questTag ) );
			Log( "qId" + qId );
				
			if ( qId > -1 ) 
			{
				SetTrackQuestProgress( qId );
			}
			else
			{
				theHud.InvokeOneArg( "vHUD.setQuestProgress", FlashValueFromString( "" ) );
			}
		}
		else
		{
			theHud.m_hud.ClearTrackQuestInfo();
			theHud.InvokeOneArg( "vHUD.setQuestProgress", FlashValueFromString( "" ) );
		}
	}
	
	// ############## ACHIEVEMENTS STUFF HERE ################
	
	
	function ShowAchievement( tutorialId : string, img : string, slowTime : bool, optional additionalTime : float ) : bool
	{
		var args : array < CFlashValueScript >;
		var title : string = "ACH_UNLOCKED";
		var text : string  = StrUpperUTF( GetLocStringByKeyExt( tutorialId ) ) + "<br>" + GetLocStringByKeyExt( tutorialId + "_t" );
		var time : float = additionalTime + 6;
		
	
		if ( !FactsDoesExist("achievement_" + tutorialId) && tutorialId!="" && !FactsDoesExist("achievement_showed") )
		{
			FactsAdd("achievement_" + tutorialId, 1, -1);
			FactsAdd("achievement_showed", 1, -1);
			//thePlayer.AddJournalEntry( JournalGroup_Tutorial, title, ParseButtons(text), "[[locale.jou.TUTORIAL]]", "");
			args.PushBack( FlashValueFromString( StrUpperUTF( GetLocStringByKeyExt( title ) ) ) );
			args.PushBack( FlashValueFromString( text ) );
			if ( img != "" ) 
			{
				args.PushBack( FlashValueFromString( "<br><img src='img://globals/gui/icons/achievements/" + img + "_64x64.dds'>" ) ) ;
			} else
			{
				args.PushBack(FlashValueFromString( "" ));
			}
			if ( slowTime ) 
			{	
				//theGame.SetTimeScale( 0.6 );	
			} else
			{	
				time = time + 4;
			}
			theHud.InvokeManyArgs( "ShowAchievement", args );
			thePlayer.AddTimer('ClearAchievement', time, false );
			return true;
		}
		
		return false;
	}
	

	function HideAchievement()
	{
		//theGame.SetTimeScale( 1.0 );	
		FactsRemove("achievement_showed");
		theHud.Invoke( "HideAchievement" );
	}	
	
}

function HideSmallTutorial()
{
	theHud.m_hud.HideTutorial();
}

public function TutExitGame()
{
	theGame.SetActivePause( false );
	if( theGame.newGameAfterTutorial )
		FactsAdd( "load_prologue_after_tutorial", 1 );
	else
		theGame.ExitGame();
	theGame.SetNewGameAfterTutorial( false );	
}

function TutorialSetDiffAndStartGame( diffLevel : string )
{
	var num : int;
	
	num = StringToInt( diffLevel, 0 );
	
	switch( num )
	{
		case 0:
		{
			theGame.SetDifficultyLevel( 0 );
			break;
		}
		case 1:
		{
			theGame.SetDifficultyLevel( 1 );
			break;
		}
		case 2:
		{
			theGame.SetDifficultyLevel( 2 );
			break;
		}
		case 3:
		{
			theGame.SetDifficultyLevel( 4 );
			break;
		}
		case 4:
		{
			theGame.SetDifficultyLevel( 3 );
			break;
		}
	}
	FactsAdd( "load_prologue_after_tutorial", 1 );
	theGame.SetActivePause( false );
	theGame.SetNewGameAfterTutorial( false );
}

function SetGamePadBlock( isBlocked : bool )
{
	
}




function AddArmorIcon() : string
{
	return "<img src='img://globals/gui/icons/combatlog/arm_12x12.dds'>";
}

function AddDamageIcon() : string
{
	return "<img src='img://globals/gui/icons/combatlog/dmg_12x12.dds'>";
}
