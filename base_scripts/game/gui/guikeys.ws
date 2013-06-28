/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui key mappings
/** Copyright © 2010
/***********************************************************************/

class CGuiKeys
{
	var m_ikExit				: int;
	var m_ikGameExit			: int;
	var m_ikAccept				: int;
	var m_ikCancel				: int;
	var m_ikLeft				: int;
	var m_ikRight				: int;
	var m_ikDialogConfirmSkip	: int;
	
	var m_ikBoxAccept : int; // for confirmation boxes
	var m_ikBoxCancel : int; // for confirmation boxes
	
	final function UpdateKeyBindings()
	{
		m_ikGameExit = theGame.GetInputKeyForAction( "GuiGameExit" );
		
		m_ikExit = theGame.GetInputKeyForAction( "GuiExit" );
		
		m_ikAccept = theGame.GetInputKeyForAction( "GuiAccept" );
		
		m_ikCancel = theGame.GetInputKeyForAction( "GuiCancel" );
		
		m_ikLeft = theGame.GetInputKeyForAction( "GuiLeft" );
		
		m_ikRight = theGame.GetInputKeyForAction( "GuiRight" );
		
		m_ikBoxAccept = theGame.GetInputKeyForAction( "GuiBoxAccept" );
		
		m_ikBoxCancel = theGame.GetInputKeyForAction( "GuiBoxCancel" );
		
		m_ikDialogConfirmSkip = theGame.GetInputKeyForAction( "GuiDialogConfirmSkip" );
		
		BindGuiActions();
	}
	
	private final function BindGuiActions()
	{
		// unique ID defined in flash, 
		
		// Inventory panel
		theHud.BindAction( "inv.EXIT",			"GuiExit" );
		theHud.BindAction( "inv.USE",			"GuiInventoryEq" );		// New inventory Drop button
		theHud.BindAction( "inv.REMOVE",		"GuiInventoryRemove" );
		theHud.BindAction( "inv.UPGRADE",		"GuiInventoryUpgrade" );
		theHud.BindAction( "inv.DROP",			"GuiInventoryDrop" );
		
		theHud.BindAction( "inv.EQ",			"GuiInventoryUse" );  	// New inventory Equip button
		theHud.BindAction( "inv.CTX",			"GuiInventoryCtx" ); 	// New inventory Use button
		
		// Journal panel
		theHud.BindAction( "j.EXIT",			"GuiExit" );
		theHud.BindAction( "j.TRACK",			"GuiAccept" );
		
		// Character panel
		theHud.BindAction( "char.EXIT",			"GuiExit" );
		theHud.BindAction( "char.TREE",			"GuiCharacterSelect" );
		theHud.BindAction( "char.BUY",			"GuiCharacterSelect" );
		theHud.BindAction( "char.STAT",			"GuiCharacterAlternative" );
		theHud.BindAction( "char.MUTAGEN",		"GuiCharacterAlternative" );
		
		// Meditation panel
		theHud.BindAction( "meditation.USE",	"GuiMeditationUse" );
		theHud.BindAction( "meditation.EXIT",	"GuiExit" );
		
		// Sleep panel
		theHud.BindAction( "sleep.USE",			"GuiSleepUse" );
		theHud.BindAction( "sleep.EXIT",		"GuiExit" );
		
		// Dice panel
		theHud.BindAction( "dice.USE",			"GuiDiceUse" );
		theHud.BindAction( "dice.EXIT",			"GuiExit" );
		
		// Elixirs panel
		theHud.BindAction( "elixirs.CLEAR",		"GuiElixirsClear" );
		theHud.BindAction( "elixirs.ADD",		"GuiElixirsAdd" );
		theHud.BindAction( "elixirs.CREATE",	"GuiElixirsCreate" );
		theHud.BindAction( "elixirs.EXIT",		"GuiExit" );
		
		// Alchemy panel
		theHud.BindAction( "alch.ADD", 			"GuiAlchAdd" );
		theHud.BindAction( "alch.AUTO", 		"GuiAlchAuto" );
		theHud.BindAction( "alch.CLEAR", 		"GuiAlchClear" );
		theHud.BindAction( "alch.CREATE", 		"GuiAlchCreate" );
		theHud.BindAction( "alch.EXIT", 		"GuiExit" );
		
		// Select panel
		theHud.BindAction( "ps.SELECT", 		"GuiSelect" );
		
		// Overview panel
		theHud.BindAction( "ov.EXIT",			"GuiExit" );
		
		// Crafting panel
		theHud.BindAction( "craft.ADD",			"GuiCraftAdd" );
		theHud.BindAction( "craft.AUTO",		"GuiCraftAuto" );
		theHud.BindAction( "craft.CLEAR",		"GuiCraftClear" );
		theHud.BindAction( "craft.CREATE",		"GuiCraftCreate" );
		theHud.BindAction( "craft.EXIT",		"GuiExit" );
		
		// Map panel
		theHud.BindAction( "nav.EXIT",			"GuiExit" );
		
		// Shop panel
		theHud.BindAction( "trade.EXIT",		"GuiExit" );
		theHud.BindAction( "trade.SWITCH",		"GuiTradeSwitch" );
		theHud.BindAction( "trade.ACTION", 		"GuiTradeAction" );
		
		// Board panel
		theHud.BindAction( "board.USE",			"GuiBoardUse" );
		theHud.BindAction( "board.EXIT",		"GuiExit" );
	}
}
