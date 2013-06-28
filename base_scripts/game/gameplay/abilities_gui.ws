exec function FakeBuildSNoLevel(levelUpCount : int)
{
	var i : int;
	RemoveAllAbilities();
	thePlayer.IncreaseExp( 1001);
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.GetCharacterStats().AddAbility( StringToName( "level_" + i ) );
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-23) + "_2" ) );
		}
	}
	
	thePlayer.SetHealthToMax();
}
exec function FakeBuildANoLevel(levelUpCount : int)
{
	var i : int;
	RemoveAllAbilities();
	thePlayer.IncreaseExp( 1001);
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.GetCharacterStats().AddAbility( StringToName( "level_" + i ) );
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-23) + "_2" ) );
		}
	}
	
	thePlayer.SetHealthToMax();
}
exec function FakeBuildMNoLevel(levelUpCount : int)
{
	var i : int;
	RemoveAllAbilities();
	thePlayer.IncreaseExp( 1001);
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.GetCharacterStats().AddAbility( StringToName( "level_" + i ) );
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-23) + "_2" ) );
		}
	}
	
	thePlayer.SetHealthToMax();
}
exec function FakeBuildS(levelUpCount : int)
{
	var i : int;
	//RemoveAllAbilities();
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.IncreaseExp( 1001);
		
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-23) + "_2" ) );
		}
	}
	
	thePlayer.SetHealthToMax();
}
exec function FakeBuildM(levelUpCount : int)
{
	var i : int;
	//RemoveAllAbilities();
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.IncreaseExp( 1001);
		
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-23) + "_2" ) );
		}
	}
}
exec function GiveAllBuilds()
{
	var i : int;
		for(i = 1; i <= 35; i += 1)
		{
			if ( i < 6 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
			}
			else if ( i >= 6 && i < 8 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
			}
			else if ( i > 8 && i < 24 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-8) ) );
			}
			else if ( i >= 24 && i <= 35 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-23) + "_2" ) );
			}
		}
		for(i = 1; i <= 35; i += 1)
		{

			if ( i > 8 && i < 24 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-8) ) );
			}
			else if ( i >= 24 && i <= 35 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-23) + "_2" ) );
			}
		}
		for(i = 1; i <= 35; i += 1)
		{

			if ( i > 8 && i < 24 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-8) ) );
			}
			else if ( i >= 24 && i <= 35 )
			{
				thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-23) + "_2" ) );
			}
		}
}

exec function AblOne()
{
	var i : int;
	
	for(i = 1; i <= 6; i += 1)
	{
		thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
	}
	for(i = 1; i <= 15; i += 1)
	{
		thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + i ) );
		thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + i ) );
		thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + i ) );
	}
}

exec function FakeBuildA(levelUpCount : int)
{
	var i : int;
	//RemoveAllAbilities();
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		
		thePlayer.IncreaseExp( 1001);
		
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 24 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 24 && thePlayer.GetLevel() < 50 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-23) + "_2" ) );
		}
	}
}
exec function PrintStats()
{
	var damageMax, damageMin, vitality, endurance, enduranceRegen, damageReduction : float;
	var level : int;
	damageMax = thePlayer.GetCharacterStats().GetFinalAttribute('damage_max');
	damageMin = thePlayer.GetCharacterStats().GetFinalAttribute('damage_min');
	vitality = thePlayer.GetCharacterStats().GetFinalAttribute('vitality');
	endurance = thePlayer.GetCharacterStats().GetFinalAttribute('endurance');
	enduranceRegen = thePlayer.GetCharacterStats().GetFinalAttribute('endurance_combat_regen');
	damageReduction = thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction');
	level = thePlayer.GetLevel();
	Log("-------------------- GERALT STATS ------------------------");
	Log("VITALITY:        " + vitality);
	Log("ENDURANCE:       " + endurance);
	Log("ENDURANCE REGEN: " + enduranceRegen +"/s in combat");
	Log("DAMAGE:          from " + damageMin + " to " + damageMax);
	Log("DAMAGE RED:      " + damageReduction);
	Log("LEVEL:           " + level);
}
function RemoveAllAbilities()
{
	var i : int;
	thePlayer.ResetLevel();
	for(i=1; i<=35; i+=1)
	{
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("Level" + i));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("training_s" + i));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("training_s" + i + "_2"));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("alchemy_s" + i));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("alchemy_s" + i + "_2"));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("magic_s" + i));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("magic_s" + i + "_2"));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("sword_s" + i));
		thePlayer.GetCharacterStats().RemoveAbility(StringToName("sword_s" + i + "_2"));
	}
}


exec function FakeLevel( levelUpCount : int )
{
	var i : int;
	RemoveAllAbilities();
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.IncreaseExp( i * 1001);
		
	/*	if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 20 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 20 && thePlayer.GetLevel() < 30 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-20) ) );
		}
		else if ( thePlayer.GetLevel() >= 30 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-30) ) );
		} */
	}
	
	thePlayer.SetHealthToMax();
}
//SL: tempshit na czas problemow z literkami -> FakeLevel
exec function FL( levelUpCount : int )
{
	var i : int;
	
	for (i = 0; i < levelUpCount; i += 1 )
	{	
		thePlayer.SetLevelUp();
		
		if ( thePlayer.GetLevel() < 6 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + i ) );
		}
		else if ( thePlayer.GetLevel() >= 6 && thePlayer.GetLevel() < 8 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "training_s" + (i-5) + "_2" ) );
		}
		else if ( thePlayer.GetLevel() > 8 && thePlayer.GetLevel() < 20 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "sword_s" + (i-8) ) );
		}
		else if ( thePlayer.GetLevel() >= 20 && thePlayer.GetLevel() < 30 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "magic_s" + (i-20) ) );
		}
		else if ( thePlayer.GetLevel() >= 30 && thePlayer.GetLevel() < 35 )
		{
			thePlayer.GetCharacterStats().AddAbility( StringToName( "alchemy_s" + (i-30) ) );
		}
	}
}
