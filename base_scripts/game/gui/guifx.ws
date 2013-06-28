/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Gui FX methods
/** Copyright © 2010
/***********************************************************************/

class CGuiFX
{
	final function MedalionStart()
	{}

	final function VomitStart()
	{}
	
	final function BloodSplatterStart()
	{}
	
	final function BlurShakeStart()
	{}
	
	final function StealthAlphaStart()
	{
		theHud.ShowOverlayPanel( new CGuiStealthPanel in theHud );
	}
	final function StealthAlphaStop()
	{
		theHud.HideOverlayPanel();
	}
	
	final function PlayerIsAttackedStart( attacker : CEntity )
	{}
	
	final function StaminaBlinkStart()
	{}
	
	final function CombatModeStart()
	{
		theHud.Invoke("vHUD.showCombatMode");
	}
	final function CombatModeStop()
	{
		theHud.Invoke("vHUD.hideCombatMode");
	}
	
	final function NoHudStart()
	{
		theHud.ShowCustomPanel( new CGuiEmptyGameplayPanel in theHud );
	}
	final function NoHudStop()
	{
		theHud.HideCustomPanel();
	}
	
	final function HoleStart()
	{
		theHud.m_hud.ShowFXHole();
	}
	final function HoleStop()
	{
		theHud.m_hud.HideFXHole();
	}
	
	final function ScopeStart()
	{
		if(theHud.CanShowMainMenu())
		{
			theHud.ForbidOpeningMainMenu();
		}
		thePlayer.SetManualControl(false, false);
		theHud.EnableInput( true, true, false, false );
		theHud.InvokeOneArg("setMouseCursorVisible", FlashValueFromBoolean( false ));
		theHud.m_hud.SetMainFrame("ui_scope.swf");
		theHud.EnableInput( true, true, false, false );
		theHud.m_hud.ShowTutorial("tut46", "", false);
		//theHud.ShowTutorialPanelOld( "tut46", "" );
	}
	final function ScopeStop()
	{
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
		theHud.m_hud.HideTutorial();
		thePlayer.SetManualControl(true, true);
		theHud.EnableInput( false, false, false, false );
		theHud.InvokeOneArg("setMouseCursorVisible", FlashValueFromBoolean( true ));
		theHud.m_hud.SetMainFrame("ui_dialog.swf");
	}

	final function DeathStart()
	{
		theHud.ShowCustomPanel( new CGuiDeathPanel in theHud );
	}
	final function DeathStop()
	{
		theHud.HideCustomPanel();
	}
	
	final function W2LogoStart( pauseGame : bool )
	{
		if ( pauseGame )
		{
			theHud.ShowCustomPanel( new CGuiDemoEndPanel in theHud );
		}
		else
		{
			theHud.ShowCustomPanel( new CGuiDemoStartPanel in theHud );
		}
	}
	final function W2LogoStop()
	{
		theHud.HideCustomPanel();
	}
}