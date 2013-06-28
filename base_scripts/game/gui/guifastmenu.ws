/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Fast menu gui panel
/** Copyright © 2010
/***********************************************************************/

enum EFastMenuSelection
{
	FMS_None,
	FMS_SignAard,
	FMS_SignYrden,
	FMS_SignIgni,
	FMS_SignQuen,
	FMS_SignAxii,
	FMS_SwordSteel,
	FMS_SwordSilver,
	FMS_Meditation,
	FMS_ItemPetard,
	FMS_ItemKnife,
	FMS_ItemTrap,
	FMS_ItemLure
}

class CGuiFastMenu extends CGuiPanel
{
	var m_potions : array< SItemUniqueId >;
	var m_blockProcessSelection : bool;
	default m_blockProcessSelection = true;
	
	var lastSelection : EFastMenuSelection;
	default lastSelection = FMS_None;
	
	var deniedSelection : array< EFastMenuSelection >;
	
	var meditation : bool;
	
	function GetLastSelection() : EFastMenuSelection { return lastSelection; }
	function ResetLastSelection() { lastSelection = FMS_None; }
	
	event OnOpenPanel()
	{
	
		var arenaDoor : CArenaDoor;
		//super.OnOpenPanel();
		theGame.EnableButtonInteractions( false );		
		
		FillData();
		
		thePlayer.SetManualControl( false, false );		
		
		if(theGame.GetIsPlayerOnArena())
		{
			
			//theGame.GetArenaManager().ShowArenaHUD(false);
			arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
			if(arenaDoor)
			{
				arenaDoor.EnableDoor(false);
			}
		}
	}
	
	event OnClosePanel()
	{
		var arenaDoor : CArenaDoor;
		theHud.m_hud.HideTutorial();
		theHud.m_hud.UnlockTutorial();
	
		theSound.RestoreAllSounds();
		theSound.PlaySound( "gui/other/gui_speedup" );
		theGame.SetTimeScale( 1.f );
		//theGame.SetDefaultAnimationTimeMultiplier( theGame.GetDefaultAnimationTimeMultiplier() * 10.f );
		theHud.InvokeOneArg( "setIsFastMenuActive", FlashValueFromBoolean( false ), theHud.m_hud.AS_hud );
		
		//super.OnClosePanel();
		theGame.EnableButtonInteractions( true );
		
		//thePlayer.SetCombatHotKeysBlocked(false);
		
		thePlayer.SetManualControl( true, true );
		
		if(theGame.GetIsPlayerOnArena())
		{
			if(!this.IsNestedPanel() && !meditation)
			{
				arenaDoor = (CArenaDoor)theGame.GetNodeByTag('arena_door');
				if(arenaDoor)
				{
					arenaDoor.EnableDoor(true);
				}
				if(!IsArenaPanel())
				{
					theGame.GetArenaManager().SetRoundStart(false);
					theGame.GetArenaManager().ShowArenaHUD(true);
					theGame.GetArenaManager().AddTimer('TimerUpdateArenaHud', 0.5, false);
				}
			}
			else if(meditation)
			{
				meditation = false;
			}
		}
	}
	
	event OnFocusPanel()
	{
		m_blockProcessSelection = true;
		theHud.GainFocus();
		super.OnFocusPanel();
		theHud.DisablePadLeftAxis( true );
	}
	
	event OnUnFocusPanel()
	{
		theHud.DisablePadLeftAxis( false );
		super.OnUnFocusPanel();
	}


	event OnGameInputEvent( key : name, value : float )
	{
		var AS_selection	: int;
		var selId, selType : float;
		if ( key == 'GI_Block' && value < 0.5f )
		{
			thePlayer.SetGuardBlock(false, true);
		}
		if ( key == 'GI_FastMenu' && value == 0.0f )
		{
			// If we navigate to the sign, sword or item and release trigger
			// then we treat it as A button press - choose that sign, etc.
			if ( theGame.IsUsingPad() )
			{
				theHud.InvokeOneArg ( "setFastMenuClick", FlashValueFromBoolean( true ), theHud.m_hud.AS_hud );
				theHud.InvokeMethod_rO( "getFastMenuSelection", AS_selection, theHud.m_hud.AS_hud );
				theHud.GetFloat( "ID",		selId,		AS_selection );
				theHud.GetFloat( "Kind",	selType,	AS_selection );
				theHud.ForgetObject( AS_selection );
				if ( selType != 0 ) // meditation
				{
					ProcessSelection( (int)selId, (int)selType );
				}
			}
			
			ClosePanel();
			return true;
		}

		// Block input, so for example player will not draw sword by using cross buttons on pad
		return true;
	}
	
	function TutorialClearFastMenuBlockedImputs()
	{
		deniedSelection.Clear();
	}
	
	private final function ProcessSelection( selId : float, selType : float )
	{
		var itemId			: SItemUniqueId;
		var weaponState		: EPlayerState;
		var spellName, itemName, category : string;
		var args : array <CFlashValueScript>;
		
		if ( m_blockProcessSelection )
		{
			return;
		}

		if ( selType == 4 ) // Potions
		{
			itemId = m_potions[ (int)selId ];
			category = thePlayer.GetInventory().GetItemCategory( itemId );
			switch( category )
			{
				case 'trap':
					if( deniedSelection.Contains( FMS_ItemTrap ) )
						return;
					lastSelection = FMS_ItemTrap;
					break;
					
				case 'lure':
					if( deniedSelection.Contains( FMS_ItemLure ) )
						return;
					lastSelection = FMS_ItemLure;
					break;
					
				case 'petard':
					if( deniedSelection.Contains( FMS_ItemPetard ) )
						return;
					lastSelection = FMS_ItemPetard;
					break;
				
				case 'rangedweapon':
					if( deniedSelection.Contains( FMS_ItemKnife ) )
						return;
					lastSelection = FMS_ItemKnife;
					break;
			}
			
			// selId - slot number
			thePlayer.SelectSlotItem( (int)selId );
			
			thePlayer.UseItem( itemId );
				
			itemName = thePlayer.GetInventory().GetItemName( itemId );
			theHud.PreloadIcon( "img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds" );
			args.PushBack(FlashValueFromString( "img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds" ));
			if ( itemId != GetInvalidUniqueId() )
			{			
				args.PushBack(FlashValueFromString( GetLocStringByKeyExt(itemName) ));
			} else
			{
				args.PushBack(FlashValueFromString( "" ));
			}
			args.PushBack( FlashValueFromInt( thePlayer.GetInventory().GetItemQuantity( itemId ) ) );
			theHud.InvokeManyArgs("vHUD.setItemQuickslot", args );
		}
		else if ( selType == 2 ) // Swords
		{
			if ( selId == 0 )
			{
				if( deniedSelection.Contains( FMS_SwordSteel ) )
					return;
				lastSelection = FMS_SwordSteel;
				weaponState = PS_CombatSteel;
			}
			else
			{
				if( deniedSelection.Contains( FMS_SwordSilver ) )
					return;
				lastSelection = FMS_SwordSilver;
				weaponState = PS_CombatSilver;
			}
				
			if ( !thePlayer.IsInGuardBlock() && !thePlayer.HasLatentItemAction() && !thePlayer.IsActionActive() && !thePlayer.GetIsCastingAxii() )
			{
				if ( thePlayer.GetCurrentPlayerState() != weaponState && !thePlayer.AreCombatHotKeysBlocked())
				{
					thePlayer.ChangePlayerState( weaponState );	
					thePlayer.SetCombatStyleFromWeaponState(weaponState);
				}
				else
				{
					if(thePlayer.AreCombatHotKeysBlocked() || thePlayer.IsCombatBlocked())
						{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
						}
					thePlayer.ChangePlayerState( PS_Exploration );
				}
			}
		}
		else if ( selType == 1 ) // Spell
		{
			if(!thePlayer.CanSelectNewSign())
			{
				return; //zabezpieczanie przed zmienianiem znaku podczas rzucania
			}
			if ( selId == 0 ) { if( deniedSelection.Contains( FMS_SignAard ) ){return;} thePlayer.SelectSign( ST_Aard, false ); spellName = "Aard"; lastSelection = FMS_SignAard; }
			else
			if ( selId == 1 ) { if( deniedSelection.Contains( FMS_SignYrden ) ){return;} thePlayer.SelectSign( ST_Yrden, false  ); spellName = "Yrden"; lastSelection = FMS_SignYrden; }
			else
			if ( selId == 2 ) { if( deniedSelection.Contains( FMS_SignIgni ) ){return;} thePlayer.SelectSign( ST_Igni, false  ); spellName = "Igni"; lastSelection = FMS_SignIgni; }
			else
			if ( selId == 3 ) { if( deniedSelection.Contains( FMS_SignQuen ) ){return;} thePlayer.SelectSign( ST_Quen, false  ); spellName = "Quen"; lastSelection = FMS_SignQuen; }
			else
			if ( selId == 4 ) { if( deniedSelection.Contains( FMS_SignAxii ) ){return;} thePlayer.SelectSign( ST_Axii, false  ); spellName = "Axii"; lastSelection = FMS_SignAxii; }
		
			//theHud.PreloadIcon( "img://globals/gui/icons/signs/" + spellName + "_64x64.dds" );
			//args.Clear();
			//args.PushBack(FlashValueFromString( 	"img://globals/gui/icons/signs/" + spellName + "_64x64.dds" ));
			//args.PushBack(FlashValueFromString( GetLocStringByKeyExt( spellName ) ) );
			//theHud.InvokeManyArgs("vHUD.setItemSign", args );
		}
		else if ( selType == 0 ) // Action
		{
			//if ( selId == 666 ) // Meditation
			{
				if( deniedSelection.Contains( FMS_Meditation ) )
					return;
					
				lastSelection = FMS_Meditation;
				if ( thePlayer.CanMeditate() )
				{
					meditation = true;
					theHud.SetHudVisibility( "false" );
					thePlayer.SetGuardBlock(false, true);
					thePlayer.ChangePlayerState( PS_Meditation );
				} else
				{
					theHud.m_messages.ShowInformationText( GetLocStringByKeyExt( "ActionBlockedHere" ) );
				}
			}
		}
		
		ClosePanel();
	}
	
	private final function FillItemObject( itemName : string, itemIdx, AS_obj : int )
	{
		theHud.SetFloat	( "ID",		itemIdx,							AS_obj );
		theHud.SetString( "Name",	GetLocStringByKeyExt( itemName ),	AS_obj );
		theHud.SetString( "Icon",	"img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds",	AS_obj );
		theHud.PreloadIcon( "img://globals/gui/icons/items/" + StrReplaceAll(itemName, " ", "") + "_64x64.dds" );
	}
	
	private final function FillSignObject( spellId : int, spellName : string, AS_array : int )
	{
		var AS_obj : int = theHud.CreateAnonymousObject();
		
		theHud.SetFloat	( "ID",		spellId,								AS_obj );
		theHud.SetString( "Name",	GetLocStringByKeyExt( spellName ),		AS_obj );
		theHud.SetString( "Icon",	"img://globals/gui/icons/signs/" + spellName + "_64x64.dds",	AS_obj );
		
		theHud.PreloadIcon( "img://globals/gui/icons/signs/" + spellName + "_64x64.dds" );
		
		theHud.PushObject( AS_array, AS_obj );
		theHud.ForgetObject( AS_obj );
	}
	
	private final function FillFastMenu()
	{
		var AS_feed, AS_array, AS_obj : int;
		var itemId		: SItemUniqueId;
		var invalidId	: SItemUniqueId = GetInvalidUniqueId();
		var items		: array< SItemUniqueId >;
		var i			: int;
		var inv			: CInventoryComponent = thePlayer.GetInventory();
		
		theHud.BeginPreloadIcons('FastMenu',12);
		
		AS_feed = theHud.CreateAnonymousObject();
		{ // Spells
			AS_array = theHud.CreateAnonymousArray();
			theHud.SetObject( "Spells", AS_array, AS_feed );
			
			FillSignObject( 0,	'Aard',			AS_array );
			FillSignObject( 1,	'Yrden',		AS_array );
			FillSignObject( 2,	'Igni',			AS_array );
			FillSignObject( 3,	'Quen',			AS_array );
			FillSignObject( 4,	'Axii',			AS_array );
			
			theHud.ForgetObject( AS_array );
		}
		{ // Potions
			m_potions.Clear();
			
			AS_array = theHud.CreateAnonymousArray();
			
			items = thePlayer.GetItemsInQuickSlots();
			for ( i = 0; i < items.Size(); i += 1 )
			{
				itemId = items[ i ];
				
				m_potions.PushBack( itemId );
				
				if ( itemId != invalidId )
				{
					AS_obj = theHud.CreateAnonymousObject();
					FillItemObject( inv.GetItemName( itemId ), i, AS_obj );
					theHud.PushObject( AS_array, AS_obj );
					theHud.ForgetObject( AS_obj );
				}
			}
			
			theHud.SetObject( "Potions", AS_array, AS_feed );
			theHud.ForgetObject( AS_array );
		}
		// Steel sword
		itemId = inv.GetItemByCategory( 'steelsword', true );
		if ( itemId != invalidId )
		{
			AS_obj = theHud.CreateAnonymousObject();
			FillItemObject( inv.GetItemName( itemId ), 0, AS_obj );
			theHud.SetObject( "SteelSword", AS_obj, AS_feed );
			theHud.ForgetObject( AS_obj );
		}
		// Silver sword
		itemId = inv.GetItemByCategory( 'silversword', true );
		if ( itemId != invalidId )
		{
			AS_obj = theHud.CreateAnonymousObject();
			FillItemObject( inv.GetItemName( itemId ), 1, AS_obj );
			theHud.SetObject( "SilverSword", AS_obj, AS_feed );
			theHud.ForgetObject( AS_obj );
		}
		
		theHud.EndPreloadIcons();		
		
		theHud.InvokeOneArg( "setFastMenuFeed", FlashValueFromHandle( AS_feed ), theHud.m_hud.AS_hud );
		theHud.ForgetObject( AS_feed );
	}
	
	///////////////////////////////////////////////////////////////////////////////////////
	// Functions called by flash
	///////////////////////////////////////////////////////////////////////////////////////
	private final function FillData()
	{
		FillFastMenu();

		if( !theGame.tutorialenabled )
		{
			/*
			if ( theGame.IsUsingPad() ) // <-- tutorial content is present in external tutorial - disabled
			{
				theHud.m_hud.ShowTutorial("tut10", "tut10_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut10", "tut10_333x166" );
				theHud.m_hud.ShowTutorial("tut112", "", false);
				//theHud.ShowTutorialPanelOld( "tut112", "" );
			}
			else
			{
				theHud.m_hud.ShowTutorial("tut10", "tut10_333x166", false);
				//theHud.ShowTutorialPanelOld( "tut10", "tut10_333x166" );
				theHud.m_hud.ShowTutorial("tut12", "", false);
				//theHud.ShowTutorialPanelOld( "tut12", "" );
			}
			*/
		}	
		// Show
		theHud.InvokeOneArg( "setIsFastMenuActive", FlashValueFromBoolean( true ), theHud.m_hud.AS_hud );
		//theGame.SetDefaultAnimationTimeMultiplier( theGame.GetDefaultAnimationTimeMultiplier() * 0.1f );
		theGame.SetTimeScale( 0.1f );
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		theSound.PlaySound( "gui/other/gui_slowdown" );		
		
		//thePlayer.SetCombatHotKeysBlocked(true);
		
		m_blockProcessSelection = false;
	}
}
