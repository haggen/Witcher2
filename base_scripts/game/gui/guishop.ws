/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Shop gui panel
/** Copyright © 2010
/***********************************************************************/


import class CGuiShop extends CGuiPanel
{
	var m_merchant : CActor;
	
	// Hide hud
	function GetPanelPath() : string { return " "; }
	
	event OnOpenPanel()
	{
		theHud.m_hud.setCSText( "", "" );
		super.OnOpenPanel();
		
		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
			
		theGame.SetActivePause( true );
	}
	
	event OnClosePanel()
	{
		theGame.SetActivePause( false );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		theHud.HideShop();
	}
	
	//////////////////////////////////////////////////////////////
	// Used by C++
	//////////////////////////////////////////////////////////////
	private final function GetActor( actorIdx : int ) : CActor
	{
		if ( actorIdx == 0 )
			return thePlayer;
		else
			return m_merchant;
	}
	private final function GetPrice( actorIdx : int, itemId : SItemUniqueId ) : int
	{
		if ( actorIdx == 0 )
			return theHud.m_utils.GetItemPrice( itemId, m_merchant.GetInventory() );
		else
			return theHud.m_utils.GetItemPrice( itemId, thePlayer.GetInventory() );
		return 0;
	}
	private final function NotEnoughMoney()
	{
		theHud.m_messages.ShowInformationText( "Not enough money!" );
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class CGuiShopNew extends CGuiPanel
{
	private var AS_shop		: int;
	private var m_merchant	: CActor;
	private var m_storage	: W2PlayerStorage;
	private var is_storage	: bool;
	
	
	private var m_playerInventory   : CInventoryComponent;
	private var m_merchantInventory : CInventoryComponent;
	
	// Merchant items
	private var m_mapMerchantItemsArrayIdxToItemIdx : array< int >;
	private var m_mapMerchantItemIdxToId : array< SItemUniqueId >;
	
	// Player items
	private var m_mapPlayerItemsArrayIdxToItemIdx : array< int >;
	private var m_mapPlayerItemIdxToId : array< SItemUniqueId >;
	
	// Hide hud
	//function GetPanelPath() : string { return "ui_trade.swf"; }
	
	function GetPanelPath() : string 
	{ 
		if( ! is_storage )
			return "ui_trade.swf";
		else
			return "ui_storage.swf"; 
	}
		
	event OnOpenPanel()
	{
		super.OnOpenPanel();
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		super.OnClosePanel();
		theHud.HideShopNew();
		//thePlayer.AddTimer( 'ShowTut', 2.0f, true );
		//theHud.m_hud.ShowTutorial("tut68", "", false);
		//theHud.ShowTutorialPanelOld( "tut68", "" );
	}
	
	timer function ShowTut( timeDelta : float )
	{
		//Log("----> TICK1");
	if ( thePlayer.GetCurrentPlayerState() == PS_Exploration && theHud.m_hud.ShowTutorial("tut71", "", false) ) 
	//if ( thePlayer.GetCurrentPlayerState() == PS_Exploration && theHud.ShowTutorialPanelOld( "tut71", "" ) ) 
		{
			thePlayer.RemoveTimer( 'Showtut' );
			Log("----> REMOVEEEEEEEEEEEED1");
		}
	}
	
	private final function FillShop()
	{
		var AS_playerItems : int;
		var AS_merchantItems : int;

		var slotItems			: array< SItemUniqueId > = thePlayer.GetItemsInQuickSlots();
		var itemId				: SItemUniqueId;
		var itemTags			: array< name >;
		var itemIdx				: int;
		var numItems			: int;
		var i					: int;
		var AS_item				: int;
		var m_playerStats 		: CCharacterStats;
		var m_merchantStats 	: CCharacterStats;

		m_playerInventory   = thePlayer.GetInventory();
		m_playerStats		= thePlayer.GetCharacterStats();
		
		if( ! is_storage )
		{
			m_merchantInventory	= m_merchant.GetInventory();
			m_merchantStats		= m_merchant.GetCharacterStats();
			//Log( "============= Shop used as Shop =================" );
		}
		else
		{
			m_merchantInventory	= m_storage.GetInventory();
			m_merchantStats		= m_storage.GetCharacterStats();
			//Log( "============= Shop used as Storage ==============" );
			
		}

		m_mapPlayerItemIdxToId.Clear();
		
		if ( !theHud.GetObject( "UserItems", AS_playerItems, AS_shop ) )
		{
			LogChannel( 'GUI', "FillShop: No UserItems found at the Scaleform side!" );
		}
		theHud.ClearElements( AS_playerItems );
		m_mapPlayerItemsArrayIdxToItemIdx.Clear();
		
		if ( !theHud.GetObject( "ShopItems", AS_merchantItems, AS_shop ) )
		{
			LogChannel( 'GUI', "FillShop: No ShopItems found at the Scaleform side!" );
		}
		theHud.ClearElements( AS_merchantItems );
		m_mapMerchantItemsArrayIdxToItemIdx.Clear();

		// Get items in player's inventory
		m_playerInventory.GetAllItems( m_mapPlayerItemIdxToId );
		numItems = m_mapPlayerItemIdxToId.Size();
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapPlayerItemIdxToId[i];
			
			// add to list items that have proper tags
			m_playerInventory.GetItemTags( itemId, itemTags );
			if ( ! itemTags.Contains( 'NoShow' ) && 
				 ! itemTags.Contains( 'nodrop' ) )
			{
				m_mapPlayerItemsArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( m_playerInventory, m_playerStats, itemId, i, AS_item, slotItems );
				
				theHud.PushObject( AS_playerItems, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}
		
		// Get items in merchant's inventory
		m_merchantInventory.GetAllItems( m_mapMerchantItemIdxToId );
		numItems = m_mapMerchantItemIdxToId.Size();
		for ( i = 0; i < numItems; i += 1 )
		{
			itemId = m_mapMerchantItemIdxToId[i];
			
			// add to list items that have proper tags
			m_merchantInventory.GetItemTags( itemId, itemTags );
			if ( ! itemTags.Contains( 'NoShow' ) && 
				 ! itemTags.Contains( 'nodrop' ) )
			{
				m_mapMerchantItemsArrayIdxToItemIdx.PushBack( i );
				
				AS_item = theHud.CreateAnonymousObject();
				
				theHud.m_utils.FillItemObject( m_merchantInventory, m_playerStats, itemId, i, AS_item, slotItems ); // TODO: slotItems?
				
				theHud.PushObject( AS_merchantItems, AS_item );
				theHud.ForgetObject( AS_item );
			}
		}
		
		// QuickSlots
		//FillQuickSlots( slotItems );
		
		// Orens
		theHud.SetFloat( "Orens", m_playerInventory.GetItemQuantityByName( 'Orens' ), AS_shop );
		
		// Mass
		theHud.SetString( "Mass", theHud.m_utils.GetCurrentWeightString(), AS_shop );
		
		theHud.ForgetObject( AS_playerItems );
		theHud.ForgetObject( AS_merchantItems );
		
		theHud.Invoke( "Commit", AS_shop );
	}

	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		//theGame.SetActivePause( true );
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mTrade", AS_shop ) )
		{
			LogChannel( 'GUI', "CGuiShopNew: No mTrade found at the Scaleform side!" );
		}
		
		FillShop();
	}
	
	private final function BuyItem( itemIdx : float, itemCount : float )
	{
		var itemId	: SItemUniqueId = m_mapMerchantItemIdxToId[ (int)itemIdx ];
		var itemsPrice : int;
		var playerOrensItemId : SItemUniqueId;
		var previousOrens : int;
		
		previousOrens = thePlayer.GetOrensCount();
		
		if( ! is_storage )		
			itemsPrice = theHud.m_utils.GetItemPrice(itemId, m_merchantInventory) * (int)itemCount;
		else
			itemsPrice = 0;
		
		playerOrensItemId = m_playerInventory.GetItemId( 'Orens' );
		
		if ( playerOrensItemId == GetInvalidUniqueId() )
		{
			LogChannel( 'GUI', "Shop: BuyItem(): invalid Orens player item id." );
			return;
		}
		
		if ( itemsPrice > thePlayer.GetOrensCount() )
		{
			theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("You don't have enough money") );
		}
		else
		{
			theHud.Invoke("vHUD.clearRecievedList");

			// Deal with money
			m_merchantInventory.AddItem( 'Orens', itemsPrice );
			m_playerInventory.RemoveItem( playerOrensItemId, itemsPrice );
			if(previousOrens <= thePlayer.GetOrensCount())
			{
				if(theGame.GetIsPlayerOnArena())
				{
					theGame.GetArenaManager().SetPlayerCheated(true);
				}
			}
			// Deal with item
			m_merchantInventory.GiveItem( m_playerInventory, itemId, (int)itemCount );
		
			FillShop();
			
			CheckForTutorial(itemId, m_playerInventory);

		}
	}
	
	private final function SellItem( itemIdx : float, itemCount : float )
	{
		var itemId	: SItemUniqueId = m_mapPlayerItemIdxToId[ (int)itemIdx ];
		var itemsPrice : int;
		var merchantOrensItemId : SItemUniqueId;
		var merchantOrens : int;
		var itemTags : array< name >;
		
		m_playerInventory.GetItemTags( itemId, itemTags );
		if ( itemTags.Contains( 'Quest' ) )
		{	
			if( is_storage )	
			{
				theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("[[locale.YouCantDoThisActionOnThisItem]]") );
				return;
			}
			else
			{
				theHud.m_messages.ShowInformationText( GetLocStringByKeyExt("You cannot sell quest item.") );
				return;
			}
		
		}
		
		if( ! is_storage )	
			itemsPrice = theHud.m_utils.GetItemPrice(itemId, m_playerInventory ) * (int)itemCount;
		else
			itemsPrice = 0;
		
		merchantOrensItemId = m_merchantInventory.GetItemId( 'Orens' );


		// Deal with money
		m_playerInventory.AddItem( 'Orens', itemsPrice );
		
		if ( merchantOrensItemId != GetInvalidUniqueId() )		
		{
			merchantOrens = m_merchantInventory.GetItemQuantityByName( 'Orens' );
			if ( merchantOrens >= itemsPrice )
			{
				m_merchantInventory.RemoveItem( merchantOrensItemId, itemsPrice );
			}
			else
			{
				// TODO: take all money if merchant doesn't have enough money - this is crap,
				// there should be no deal at all if merchant doesn't have money, but this should be
				// done on the Scaleform side
				m_merchantInventory.RemoveItem( merchantOrensItemId, merchantOrens );
			}
		}
		else
		{
			LogChannel( 'GUI', "Shop: SellItem(): merchant doesn't have orens." );
		}

		// Deal with item
		m_playerInventory.GiveItem( m_merchantInventory, itemId, (int)itemCount );
		
		theSound.PlaySound( "gui/other/sellitem" );
		
		FillShop();
	}
}
