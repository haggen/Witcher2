
enum CPowerSourceType 
{
	COP_Vitality,
	COP_Endurance,
	COP_Signs,
	COP_Damage,
	COP_Armor,
}

class CPowerSource extends CGameplayEntity
{
	editable var type			: CPowerSourceType;
	editable var timeToReset	: int;
	var wasUsed 				: bool;
	var isVisible 				: bool;
	var isInside				: bool;
	default timeToReset = 3600;
	
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		PlayEffect('default_fx');
	}
	
	timer function GlowLifeTimer( timeDelta : float )
	{
		StopEffect('armor_life_source_fx');
		StopEffect('damage_life_source_fx');
		StopEffect('endurance_life_source_fx');
		StopEffect('signs_life_source_fx');
		StopEffect('vitality_life_source_fx');
			
		isVisible = false;
	}
	
	timer function ResetTimer( timeDelta : float )
	{
		wasUsed = false;
	}
	
	function onMedalionGlow()
	{
		if ( type == COP_Vitality )
		{
			PlayEffect('vitality_life_source_fx');
		}
		if ( type == COP_Endurance )
		{
			PlayEffect('endurance_life_source_fx');
		}
		if ( type == COP_Signs )
		{
			PlayEffect('signs_life_source_fx');
		}
		if ( type == COP_Damage )
		{
			PlayEffect('damage_life_source_fx');
		}
		if ( type == COP_Armor )
		{
			PlayEffect('armor_life_source_fx');
		}
		
		
		PlayEffect('medalion_detecton_fx');
		
		theSound.PlaySound("gui/chardev/gui_chardev_addmutagen");

		AddTimer('GlowLifeTimer', 10.0, false );
		AddTimer('ResetTimer', timeToReset, false );
		isVisible = true;
		if ( isInside ) onUse();
	}
	
	function onUse()
	{
		theHud.m_hud.HideTutorial();
		theHud.m_hud.UnlockTutorial();
		theHud.m_hud.ShowTutorial("tut22", "tut22_333x166", false);
		//theHud.ShowTutorialPanelOld( "tut22", "tut22_333x166" );
		
		
		StopEffect('armor_life_source_fx');
		StopEffect('damage_life_source_fx');
		StopEffect('endurance_life_source_fx');
		StopEffect('signs_life_source_fx');
		StopEffect('vitality_life_source_fx');
		StopEffect('default_fx');
		
		if ( type == COP_Vitality )
		{
			PlayEffect('vitality_use_fx');
			thePlayer.GetInventory().AddItem('COP_Vitality', 1);
			thePlayer.UseItem(thePlayer.GetInventory().GetItemId('COP_Vitality'));
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "COP_Used" ) + ": " + GetLocStringByKeyExt( "COP_Vitality" ),  );
		}
		if ( type == COP_Endurance )
		{
			PlayEffect('endurance_use_fx');
			thePlayer.GetInventory().AddItem('COP_Endurance', 1);
			thePlayer.UseItem(thePlayer.GetInventory().GetItemId('COP_Endurance'));
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "COP_Used" ) + ": " + GetLocStringByKeyExt( "COP_Endurance" ),  );
		}
		if ( type == COP_Signs )
		{
			PlayEffect('signs_use_fx');
			thePlayer.GetInventory().AddItem('COP_Signs', 1);
			thePlayer.UseItem(thePlayer.GetInventory().GetItemId('COP_Signs'));
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "COP_Used" ) + ": " + GetLocStringByKeyExt( "COP_Signs" ),  );
		}
		if ( type == COP_Damage )
		{
			PlayEffect('damage_use_fx');
			thePlayer.GetInventory().AddItem('COP_Damage', 1);
			thePlayer.UseItem(thePlayer.GetInventory().GetItemId('COP_Damage'));
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "COP_Used" ) + ": " + GetLocStringByKeyExt( "COP_Damage" ),  );
		}
		if ( type == COP_Armor )
		{
			PlayEffect('armor_use_fx');
			thePlayer.GetInventory().AddItem('COP_Armor', 1);
			thePlayer.UseItem(thePlayer.GetInventory().GetItemId('COP_Armor'));
			theHud.m_hud.setCSText( "", GetLocStringByKeyExt( "COP_Used" ) + ": " + GetLocStringByKeyExt( "COP_Armor" ),  );
		}
		
		theSound.PlaySound("gui/chardev/gui_chardev_sword");
		thePlayer.AddTimer( 'clearHudTextField', 2.0f, false );
		
		wasUsed = true;
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			isInside = true;
			theHud.m_hud.ShowTutorial("tut21", "tut21_333x166", false);
			//theHud.ShowTutorialPanelOld( "tut21", "tut21_333x166" );
			theHud.Invoke("vHUD.blinkMed");
			theSound.PlaySound("gui/hud/medalionwarning");
			if ( !wasUsed && isVisible)
			{
				onUse();
			}
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			isInside = false;
		}
	}
	
}

exec function buff_adrenaline_start()
{
	theCamera.PlayEffect('overdose', theCamera );
	thePlayer.StopAdrenalineBuff( thePlayer.GetInventory().GetItemAttributeAdditive( (thePlayer.GetInventory().GetItemId('AlchemyAdrenaline')), 'durration' ));
}

exec function buff_adrenaline_end()
{
	if(thePlayer.canDisableBerserk)
	{
		theCamera.StopEffect('overdose');
		thePlayer.SetAdrenalineBuffFlag( false );
	}
}