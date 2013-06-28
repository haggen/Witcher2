function CheckAbilityTutorial()
{
	//if ( thePlayer.GetCharacterStats().HasAbility('training_s3_2') ) theHud.m_hud.ShowTutorial("tut05", "tut05_333x166", false); // Parry Tutorial  // <-- tutorial content is present in external tutorial - disabled
	//if ( thePlayer.GetCharacterStats().HasAbility('training_s3_2') ) theHud.ShowTutorialPanelOld( "tut05", "tut05_333x166" ); // Parry Tutorial
	//if ( thePlayer.GetCharacterStats().HasAbility('sword_s2_2') ) theHud.m_hud.ShowTutorial("tut08", "", false); // Riposte Tutorial  // <-- tutorial content is present in external tutorial - disabled
	//if ( thePlayer.GetCharacterStats().HasAbility('sword_s2_2') ) theHud.ShowTutorialPanelOld( "tut08", "" ); // Riposte Tutorial
	
	//if ( !theGame.IsCurrentlyPlayingNonGameplayScene() && theGame.GetIsNight() && thePlayer.GetCurrentPlayerState() == PS_Exploration && thePlayer.GetLevel() > 1 ) theHud.m_hud.ShowTutorial("tut28", "", false); // Night/Day tutorial
	//if ( !theGame.IsCurrentlyPlayingNonGameplayScene() && theGame.GetIsNight() && thePlayer.GetCurrentPlayerState() == PS_Exploration && thePlayer.GetLevel() > 1 ) theHud.ShowTutorialPanelOld( "tut28", "" ); // Night/Day tutorial
}

function CheckIfUnlockAchievements()
{
	if ( thePlayer.GetLevel() > 9 ) theGame.UnlockAchievement('ACH_LEVEL_10');
	if ( thePlayer.GetLevel() > 34 ) theGame.UnlockAchievement('ACH_LEVEL_35');
	if ( thePlayer.GetCharacterStats().HasAbility('magic_s14') ) theGame.UnlockAchievement('ACH_MAGIC_MAN');
	if ( thePlayer.GetCharacterStats().HasAbility('sword_s14') ) theGame.UnlockAchievement('ACH_SWORD_MAN');
	if ( thePlayer.GetCharacterStats().HasAbility('alchemy_s14') ) theGame.UnlockAchievement('ACH_ALCHEMY_MAN');
	if ( thePlayer.GetInventory().GetItemQuantity( thePlayer.GetInventory().GetItemId('Orens') ) > 9999 ) theGame.UnlockAchievement('ACH_CHEAPSKATE');
	if ( thePlayer.GetInventory().HasItem('Tentadrake Armor') ) theGame.UnlockAchievement('ACH_DRAGON_ALIVE');
	if ( FactsDoesExist("Won_Dice") && FactsDoesExist("Won_Fistfight") && FactsDoesExist("Won_Wrestling") ) theGame.UnlockAchievement('ACH_GAMBLER');
}

function CheckAchievements()
{
	//var achievements : array <name>;
	//var i : int;
	
	CheckIfUnlockAchievements();
	//theGame.GetUnlockedAchievements( achievements );
	//for( i=0; i< achievements.Size(); i+=1 )
	//{
	//	theHud.m_hud.ShowAchievement( achievements[i], NameToString(achievements[i]), false );
	//}
	
}