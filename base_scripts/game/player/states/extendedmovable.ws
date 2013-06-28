state ExtendedMovable in CPlayer extends Movable
{
	private var objectToKick  : CKickAbleObject;
	private var changeStyleTime : EngineTime;
	private var changeStyleCooldown : float;
	
	default changeStyleCooldown = 2.0;
	
	event OnGameInputEvent( key : name, value : float )
	{		
		if ( theGame.IsBlackscreen() )
		{
			return true;
		}
		
		// keys that are available always nomatter if hotkeys blocked
		// DEBUG
		if ( theGame.IsCheatEnabled( CHEAT_InstantKill ) )
		{
			if ( key == 'GI_Y' && IsKeyPressed( value ) )
			{
				KillAllEnemies( true );
				return true;
			}
			else if ( key == 'GI_N' && IsKeyPressed( value ) )
			{
				KillAllEnemies( false );
				return true;
			}
		}
		
		// What the hell is this?????
		// This was a custom script fired on backspace press down, it was very usefull for
		// a quick script launching (for debug and testing).
		/*else if ( key == 'GI_CustomScript' )
		{
			if( value > 0.5f )
			{
				CustomScript();
				return true;
			}
			return false;
		}*/
		
		if ( parent.AreHotKeysBlocked() ) return false;

		if ( key == 'GI_Adrenaline' )
		{
			if( !thePlayer.AreCombatHotKeysBlocked() && value > 0.5f && !thePlayer.IsNotGeralt())
			{
				parent.TriggerAdrenalineBoost();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_FastMenu' )
		{
			if( value == 1.0f ) // equals 1 so it will work on PAD too
			{
				if( !theGame.tutorialOldPanelShown )
				{
					parent.ShowFastMenu();
				}
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Journal' )
		{
			if( value > 0.5f )
			{
				theHud.ShowJournal();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Nav' )
		{
			if( value > 0.5f )
			{
				theHud.ShowNav();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Medallion' )
		{
			if( value > 0.5f )
			{
				parent.TriggerMedallion();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_CircleOfPower' )
		{
			if ( value > 0.5f )
			{
				theCamera.ResetRotation();
				return true;
			}
			return false;
		}
		else if( key == 'GI_TutorialHint' && value > 0.5f )
		{
			if( thePlayer.enableTutorialButton && theGame.tutorialenabled )
			{
				theGame.TutorialPanelOpenByPlayer( true );
				if( theGame.tutorialPanelNew )
					thePlayer.ToggleTutorialPanel( true );
				else	
					thePlayer.ToggleTutorialPanel( false );
			}
			return true;
		}
		else if( key == 'GI_ControlsHint')
		{
		/*
			if( value > 0.5f)
			{
				theHud.ShowControls();
				return true;
			}
			return false;
		*/	
		}

		else if ( key == 'GI_Character' )
		{
			if( value > 0.5f )
			{
				theHud.ShowCharacter( false );
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Inventory' )
		{
			if( value > 0.5f && !parent.HasLatentItemAction() )
			{
				theHud.ShowInventory();
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Overview' )
		{
			if( value > 0.5f )
			{
				theHud.ShowOverview();
				return true;
			}
			return false;
		}
// We don't have panel selector
/*		else if ( key == 'GI_PanelSelector' )
		{
			if( value > 0.5f )
			{
				PanelSelectorShow();
				return true;
			}
			return false;
		}
*/
		else if ( key == 'GI_Hotkey01' )
		{
			if(!thePlayer.IsInGuardBlock() && value > 0.5 && theGame.GetEngineTime() > changeStyleTime + changeStyleCooldown )
			{
				changeStyleTime = theGame.GetEngineTime();
				if ( thePlayer.GetCurrentPlayerState() == PS_Exploration ||  thePlayer.GetCurrentPlayerState() == PS_Sneak)
				{
					if ( !thePlayer.AreCombatHotKeysBlocked() &&!parent.HasLatentItemAction())
					{
						parent.SetLastCombatStyle(PCS_Steel);
						parent.ChangePlayerState( PS_CombatSteel );
					}
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
				}
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey02' )
		{
			if( !thePlayer.IsInGuardBlock() && value > 0.5 && theGame.GetEngineTime() > changeStyleTime + changeStyleCooldown )
			{
				changeStyleTime = theGame.GetEngineTime();
				if ( thePlayer.GetCurrentPlayerState() == PS_Exploration ||  thePlayer.GetCurrentPlayerState() == PS_Sneak)
				{
					if ( !thePlayer.AreCombatHotKeysBlocked() &&!parent.HasLatentItemAction())
					{
						parent.SetLastCombatStyle(PCS_Silver);
						parent.ChangePlayerState( PS_CombatSilver );
					}
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
				}
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey03' && !thePlayer.IsNotGeralt()  )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
				if ( thePlayer.selectedSign == ST_Aard ) 
				{
					thePlayer.SelectSign( ST_Yrden, false );
				}
				else if ( thePlayer.selectedSign == ST_Yrden ) 
				{
					thePlayer.SelectSign( ST_Igni, false );
				}
				else if ( thePlayer.selectedSign == ST_Igni )
				{
					thePlayer.SelectSign( ST_Quen, false );
				}
				else if ( thePlayer.selectedSign == ST_Quen ) 
				{
					thePlayer.SelectSign( ST_Axii, false );	
				}
				else if ( thePlayer.selectedSign == ST_Axii ) 
				{
					thePlayer.SelectSign( ST_Aard, false);	
				}
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey05' && !thePlayer.IsNotGeralt() && !thePlayer.AreCombatHotKeysBlocked() )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
					thePlayer.SelectSign( ST_Aard, false);	
					parent.TriggerSelectedSign( parent.GetEnemy() );
					return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey06' && !thePlayer.IsNotGeralt()  && !thePlayer.AreCombatHotKeysBlocked()  )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
					thePlayer.SelectSign( ST_Yrden, false);	
					parent.TriggerSelectedSign( parent.GetEnemy() );
					return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey07' && !thePlayer.IsNotGeralt()  && !thePlayer.AreCombatHotKeysBlocked()  )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
					thePlayer.SelectSign( ST_Igni, false);	
					parent.TriggerSelectedSign( parent.GetEnemy() );
					return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey08' && !thePlayer.IsNotGeralt()  && !thePlayer.AreCombatHotKeysBlocked()  )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
					thePlayer.SelectSign( ST_Quen, false);	
					parent.TriggerSelectedSign( parent.GetEnemy() );
					return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey09' && !thePlayer.IsNotGeralt()  && !thePlayer.AreCombatHotKeysBlocked()  )
		{
			if( value > 0.5 && thePlayer.CanSelectNewSign())
			{
					thePlayer.SelectSign( ST_Axii, false);	
					parent.TriggerSelectedSign( parent.GetEnemy() );
					parent.SetBehaviorVariable("AxiiHold", 1.0);
					parent.SetIsCastingAxii(true);
					return true;
			} else
			if ( value < 0.5 )
			{
					parent.SetBehaviorVariable("AxiiHold", 0.0);
					parent.SetIsCastingAxii(false);
			}
			return false;
		}
		else if ( key == 'GI_UseAbility' ) 
		{
			if( value > 0.5 )
			{
				if ( ! parent.IsNotGeralt() )
				{
					if (  thePlayer.IsManualControl()  && !thePlayer.AreCombatHotKeysBlocked() )//&& !thePlayer.IsDodgeing()) 
					{
						if(thePlayer.GetCurrentPlayerState() != PS_CombatSteel && thePlayer.GetCurrentPlayerState() != PS_CombatSilver && thePlayer.GetCurrentPlayerState() != PS_CombatFistfightDynamic)
						{
							if(!parent.HasLatentItemAction() && !parent.AreCombatHotKeysBlocked())
							thePlayer.ChangePlayerState(thePlayer.GetLastCombatStyle());
						}
						else
						{
							parent.TriggerSelectedSign( parent.GetEnemy() );
							if(parent.GetSelectedSign() == ST_Axii)
							{
								parent.SetBehaviorVariable("AxiiHold", 1.0);
								parent.SetIsCastingAxii(true);
							}
						}
					}
					else if(thePlayer.AreCombatHotKeysBlocked()&& thePlayer.IsCombatBlocked())
					{
						theHud.m_messages.ShowInformationText(GetLocStringByKeyExt( "ActionBlockedHere" ));
					}
				}
				return true;
			}
			else if( value < 0.5 && !thePlayer.AreCombatHotKeysBlocked() )
			{
				if(parent.GetSelectedSign() == ST_Axii)
				{
					parent.SetBehaviorVariable("AxiiHold", 0.0);
					parent.SetIsCastingAxii(false);
				}
				return true;
			}
			return false;
		}
		else if ( key == 'GI_Hotkey04' && !thePlayer.IsNotGeralt()  )
		{
			if( value > 0.5 )
			{
				thePlayer.SelectNextSlotItem( true );
				return true;
			}
			return false;
		}
		
		// Not handled
		return super.OnGameInputEvent( key, value );
	}
	
	final function KillAllEnemies( lethal : bool )
	{
		var enemies : array< CActor >;
		var size, i : int;
		
		enemies = parent.FindEnemiesInCombatArea();	
			
		size = enemies.Size();
		for ( i = size-1; i >=0; i -= 1 )
		{
			if ( enemies[i].IsAlive() )
			{
				if( lethal )
				{
					enemies[i].Kill(false, parent);
					Logf("KILL: %1", enemies[i].GetName() );
				}
				else
				{
					enemies[i].Stun(false, parent);
					Logf("STUN: %1", enemies[i].GetName() );
				}
			}
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{	
		/*var thrownItemCat : name = parent.GetInventory().GetItemCategory( parent.thrownItemId );
		
		if ( ! parent.IsNotGeralt() )
		{
			if ( actionName == 'UseSign' && thePlayer.IsManualControl() ) 
			{
				if ( thePlayer.selectedSign == ST_Heliotrop ) 
				{
					thePlayer.SelectSign( ST_Aard, false );
				}
				parent.TriggerSelectedSign( parent.GetEnemy() );
			}
		}*/
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if ( animEventName == 'KickMoment' && objectToKick )
		{
			objectToKick.ProcessKick();
			objectToKick = NULL;
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}

	event OnKickObject( heading : float, kickObject : CKickAbleObject )
	{
		if ( parent.ActionSlideToWithHeadingAsync( parent.GetWorldPosition(), heading, 0.2) == false )
		{
			return false;
		}
		
		if ( parent.RaiseForceEvent('Kick') == false )
		{
			return false;
		}
		
		if ( objectToKick )
		{
			Log( "error" );
			return false;
		}
		
		objectToKick = kickObject;
		
		return true;
	}
}
