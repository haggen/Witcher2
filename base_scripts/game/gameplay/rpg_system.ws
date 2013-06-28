/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009 m6a6t6i's Early Day R&D Home Center
/***********************************************************************/

//class CRpgSystem
//{
// ---------------------------------------------------------------------
//					   		    OTHER
// ---------------------------------------------------------------------

exec function dif( level : int )
{
	theGame.SetDifficultyLevel( level ) ;
}


exec function lvl()
{
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
	thePlayer.SetLevelUp();
}
exec function lvl1()
{
	thePlayer.SetLevelUp();
}

// ---------------------------------------------------------------------
//					   		    STORY SKILLS
// ---------------------------------------------------------------------

function AddStoryAbility( skillName : string, skillLevel : int )
{
	var outputName : string;
	outputName = skillName + "_" + skillLevel;
	thePlayer.GetCharacterStats().AddAbility( StringToName ( outputName ) );
	theHud.m_hud.setJournalEntryText( GetLocStringByKeyExt( "NewAbilityAdded" ), GetLocStringByKeyExt( skillName ) );
	//theHud.m_hud.setCSText( "", StrUpperUTF( GetLocStringByKeyExt( "NewAbilityAdded" ) ) + ": " + GetLocStringByKeyExt( skillName ),  );
	//thePlayer.AddTimer( 'clearHudTextField', 2.0f, false );
}

// ---------------------------------------------------------------------
//					   		    EXPERIENCE functions
// ---------------------------------------------------------------------

function GetExperienceForNextLevel( currentLevel : int ) : int
{
	return currentLevel * 1000;
}

function GetBaseExperienceForLevel( currentLevel : int ) : int
{
	//var i	: int;
	//var xp	: int = 0;
	//for ( i = 0; i < currentLevel; i += 1 )
	//{
	//	xp += i * 1000;
	//}
	//return xp;
	return currentLevel * 1000;
}

function CalculateGainedExperienceAfterKill(actor : CActor, apply_when_calculated : bool, add_to_combat_log : bool, half : bool) : int
{
	var level_player : int;
	var level_opponent : int;
	var level_diff : int;
	var experience_basic : int;
	var experience_final : int;
	var experienceBonus : float;
	
	experienceBonus = thePlayer.GetCharacterStats().GetFinalAttribute('experience_bonus');
	if(experienceBonus < 1.0f)
	{
		experienceBonus = 1.0f;
	}
	
	AddAchievementCounter('ACH_BUTCHER', 1, 500);
	
	level_player = thePlayer.GetLevel();
	level_opponent = RoundF( actor.GetCharacterStats().GetFinalAttribute('level') );
	experience_basic = RoundF( actor.GetCharacterStats().GetFinalAttribute('experience') * experienceBonus );

	level_diff = RoundF((level_opponent - level_player) / 2) + 1;
	
	if (level_diff <= 0)
	{
		// no experience gained - player have to high level
	}
	else
	{
		// give some experience points
		experience_final = RoundF( RandRangeF( (( experience_basic * level_diff ) / 2 ) + 1, ( experience_basic * level_diff ) + 2 ) );
	}
	
	if (half)
	{
		experience_final = RoundF( experience_final / 20 );
	}
	
	if (apply_when_calculated)
	{
		if (experience_final > 1) 
		{
			thePlayer.IncreaseExp(experience_final);
			if (add_to_combat_log)
				theHud.m_hud.CombatLogAdd( "<span class='orange'>" + thePlayer.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt( "cl_exp" ) + " </span><span class='red'>" + experience_final + ".</span>");
		}
	}
	
	return experience_final; 
}

// ---------------------------------------------------------------------
//					   		DAMAGE functions
// ---------------------------------------------------------------------
/*
function CheckIfShieldShatter( attacker_chance : float, defender_res : float, add_to_log : bool ) : bool
{
	var chance : float;
	chance = 100 * attacker_chance;
	if (  chance > (100 * defender_res) )
	{
		theHud.m_hud.CombatLogAdd("Shield is crushing!");	
		return true;
	}
		else
	{
		return false;
	}
}
*/
function TryToApplyAllCritEffectsOnHit( defender : CActor, attacker : CActor, add_to_combat_log : bool) : bool
{
	var itemId : SItemUniqueId;
	var tags : array < name > ;
	var i,t			: int;	
	var playerIsSource : bool;
	
	if ( defender != thePlayer && attacker != thePlayer ) return false;
	
	if (attacker == thePlayer)
	{
		playerIsSource = true;
	}
	else
	{
		playerIsSource = false;
	}
	
	itemId = attacker.GetCurrentWeapon(CH_Right);
	if ( !attacker.IsMonster() && attacker.GetInventory().GetItemTags(itemId, tags ) && attacker.GetCurrentWeapon() == itemId )
	{
		for ( t = tags.Size()-1; t >= 0; t-=1 )
		{
			if ( StrBeginsWith( NameToString( tags[t] ), "crt_" ) )
			{
				if ( tags[t] == 'crt_burn' ) defender.ApplyCriticalEffect(CET_Burn, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('burn_time'), playerIsSource);
				else if ( tags[t] == 'crt_poison' ) defender.ApplyCriticalEffect(CET_Poison, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('poison_time'), playerIsSource);
				else if ( tags[t] == 'crt_bleed' ) defender.ApplyCriticalEffect(CET_Bleed, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('bleed_time'), playerIsSource);
				
			//	if ( tags[t] == 'crt_laming' ) defender.ApplyCriticalEffect(CET_Laming, attacker);
				
				
				else if ( tags[t] == 'crt_knockdown' ) defender.ApplyCriticalEffect(CET_Knockdown, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('knockdown_time'), playerIsSource);
				//if ( tags[t] == 'crt_disarm' ) defender.ApplyCriticalEffect(CET_Disarm, attacker);
				//if ( tags[t] == 'crt_disorientation' ) defender.ApplyCriticalEffect(CET_Disorientation, attacker);
				//if ( tags[t] == 'crt_immobile' ) defender.ApplyCriticalEffect(CET_Immobile, attacker);
				//if ( tags[t] == 'crt_fear' ) defender.ApplyCriticalEffect(CET_Fear, attacker);
				else if ( tags[t] == 'crt_stun' ) defender.ApplyCriticalEffect(CET_Stun, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('stun_time'), playerIsSource);
				//if ( tags[t] == 'crt_unbalance' ) defender.ApplyCriticalEffect(CET_Unbalance, attacker);
				//if ( tags[t] == 'crt_falter' ) defender.ApplyCriticalEffect(CET_Falter, attacker);
				else if ( tags[t] == 'crt_freeze' ) defender.ApplyCriticalEffect(CET_Freeze, attacker, thePlayer.GetCharacterStats().GetFinalAttribute('freeze_time'), playerIsSource);
			}
		}
				
	}
	else if(attacker.IsMonster())
	{
		defender.ApplyCriticalEffect(CET_Poison, attacker);
		defender.ApplyCriticalEffect(CET_Bleed, attacker);
		
	}

	return true;
}

function CalculateWeatherDmgBonus( ) : float
{
	var typeMult : float;
	var strMult : float;
	var bonus : float;
		if ( GetWeatherType() == WT_Rain ) typeMult = 1.1;
		if ( GetWeatherType() == WT_Storm ) typeMult = 1.2;
		strMult = GetRainStrength();
		bonus = typeMult + strMult;
		if ( bonus > 1.5 ) bonus = 1.5;
	return bonus;
}

function AddMonsterTypeDamageBonus( attacker : CActor, defender : CActor ) : int
{
	var i,t			: int;	
	var tags : array < name > ;
	var allItems	: array< SItemUniqueId >;
	var itemId : SItemUniqueId;
	
	attacker.GetInventory().GetAllItems( allItems );
	for ( i = allItems.Size()-1; i >= 0; i-=1 )
	{
		itemId = allItems[i];
		if ( attacker.GetInventory().GetItemTags(itemId, tags ) && attacker.GetCurrentWeapon() == itemId )
		{
			for ( t = tags.Size()-1; t >= 0; t-=1 )
			{
				if ( StrBeginsWith( NameToString( tags[t] ), "damage_bonus_" ) )
				{
					if ( defender.HasTag( tags[t] ) )
					{
						return RoundF( attacker.GetCharacterStats().GetAttribute( tags[t] ) );
					}
				}
			}
		}
	}
	return 0;
}

function CalculateDamage(attacker : CActor, defender : CActor, is_player_combo_hit : bool, apply_when_calculated : bool, show_splatter : bool, add_to_combat_log : bool, optional damage_mult_bonus : float, optional is_non_lethal : bool, optional defenderBlocksHit : bool, optional impossibleToBlock : bool, optional backDamage : bool) : float
{
	var Attacker_Damage, init_attacker_dmg  : float;
	var Defender_Reduction 					: float;
	var Defender_Reduction_Perc 			: float;
	var Final_Damage      					: float;
	var Night_Bonus	      		 			: float;
	var Attacker_Name     		 			: string;
	var Defender_Name     		 			: string;
	var Attacker_Damage_Stamina_Bonus 		: float;
	var Attacker_Damage_Toxicity_Bonus 		: float;
	var Damage_Reduction_Toxicity_Bonus 	: float;
	var Damage_Reduction_Magic_Bonus 		: float;
	var isBlockingHit 						: bool = false;
	var isNpcVsNpcCombat 					: bool = false;
	var toxicityThreshold 					: float;
	var monsterType : EMonsterType;
	var attackerNPC : CNewNPC;
	var damageWraithBonus,  damageHumanBonus, damageGargoyleBonus, damageHugeOppBonus, damageHarpyBonus: float;
	var attackerDmgInt, defenderRedInt, attackerBasicDmgInt, blockPerc, staminaBonus : int;
	var tempIntVariable : int;
		
	if ( theGame.GetIsNight() ) Night_Bonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_nightmult');
	
	attackerNPC = (CNewNPC)attacker;
	damageHarpyBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_bonus_harpy');
	if(damageHarpyBonus <= 0.0f)
	{
		damageHarpyBonus = 0.0f;
	}
	
	damageHugeOppBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_bonus_huge');
	if(damageHugeOppBonus <= 0.0f)
	{
		damageHugeOppBonus = 0.0f;
	}
	
	damageGargoyleBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_bonus_gargoil');
	if(damageGargoyleBonus <= 0.0f)
	{
		damageGargoyleBonus = 0.0f;
	}
	
	damageHumanBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_bonus_human');
	if(damageHumanBonus <= 0.0f)
	{
		damageHumanBonus = 0.0f;
	}
	
	damageWraithBonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_bonus_wraith');
	if(damageWraithBonus <= 0.0f)
	{
		damageWraithBonus = 0.0f;
	}
	
	toxicityThreshold = thePlayer.GetCharacterStats().GetFinalAttribute('toxicity_threshold');
	if(toxicityThreshold <= 0.0f)
	{
		toxicityThreshold = 1.0f;
	}
	isBlockingHit = defender.IsBlockingHit();
	if (damage_mult_bonus == 0) damage_mult_bonus = 1.0;
	if ( defender != thePlayer && attacker != thePlayer )
	{
		isNpcVsNpcCombat = true;
		add_to_combat_log = false;
	}
	
	Attacker_Name = attacker.GetDisplayName();
	Defender_Name = defender.GetDisplayName();
		
	// Get attacker damage 
	Attacker_Damage = attacker.GetCharacterStats().ComputeDamageOutputPhysical(isNpcVsNpcCombat);
	
	if ( Night_Bonus > 1 && attacker.IsMonster() ) Attacker_Damage = Attacker_Damage * Night_Bonus;
	
	if ( attacker == thePlayer && !thePlayer.IsNotGeralt())
	{
		if (attacker.GetInventory().ItemHasTag(attacker.GetCurrentWeapon(), 'SilverSword') && !defender.IsMonster())
		{
			Attacker_Damage = Attacker_Damage * 0.3;
			if ( RandRangeF( 0.0, 100.0 ) < 40.0 )theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "CombatLog_silverWarning" ));
		}
		if (attacker.GetInventory().ItemHasTag(attacker.GetCurrentWeapon(), 'SteelSword') && defender.IsMonster())
		{
			Attacker_Damage = Attacker_Damage * 0.3;
			if ( RandRangeF( 0.0, 100.0 ) < 40.0 )theHud.m_hud.CombatLogAdd( GetLocStringByKeyExt( "CombatLog_steelWarning" ));
		}
		if(thePlayer.GetToxicity() > toxicityThreshold)
		{
			Attacker_Damage_Toxicity_Bonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_toxbonus');
			if(Attacker_Damage_Toxicity_Bonus > 0.0f)
			{
				Attacker_Damage = Attacker_Damage * (1+Attacker_Damage_Toxicity_Bonus);
			}
		}
		if(defender.IsMonster())
		{
			monsterType = defender.GetMonsterType();
			if(monsterType == MT_Wraith || monsterType == MT_KnightWraith || monsterType == MT_Bruxa)
			{
				Attacker_Damage = Attacker_Damage*(1+damageWraithBonus);
			}
			if(monsterType == MT_Troll || monsterType == MT_Bullvore || monsterType == MT_Golem || monsterType == MT_Elemental)
			{
				Attacker_Damage = Attacker_Damage*(1+damageHugeOppBonus);
			}
			if(monsterType == MT_Gargoyle )
			{
				Attacker_Damage = Attacker_Damage*(1+damageGargoyleBonus);
			}
			if(monsterType == MT_Harpie )
			{
				Attacker_Damage = Attacker_Damage*(1+damageHarpyBonus);
			}
		}
		else
		{
			Attacker_Damage = Attacker_Damage*(1+damageHumanBonus);
		}
		
	}

	
	//TO ADD - calculate Attacker_Damage_Stamina_Bonus  for each players hit when in alchemical build is under intoxication effect
	Attacker_Damage_Stamina_Bonus = 1.0;
	if(attacker == thePlayer)
	{
		Attacker_Damage_Stamina_Bonus = thePlayer.GetStaminaDamageMult();
	}
	
	if (!defenderBlocksHit || impossibleToBlock)
	{ 	// Defender is not blocking right now
		Defender_Reduction = defender.GetCharacterStats().GetFinalAttribute('damage_reduction');
	}
	else
	{	// Defender is blocking right now
		Defender_Reduction = defender.GetCharacterStats().GetFinalAttribute('damage_reduction_block') + defender.GetCharacterStats().GetFinalAttribute('damage_reduction');
		Defender_Reduction_Perc = defender.GetCharacterStats().GetFinalAttribute('damage_reduction_block_perc');		
		/*if ( defender == thePlayer && defender.GetStamina() < 0.5 ) 
		{
			defender.SetBlockingHit( false, 0.0 );
			//Defender_Reduction = defender.GetCharacterStats().GetFinalAttribute('damage_reduction')*1.25;
		}*/
	}
	
	Defender_Reduction = Defender_Reduction*theGame.GetArmorDifficultyLevelMult(attacker, defender);
	
	if(defender == thePlayer)
	{
		if(thePlayer.GetToxicity() > toxicityThreshold)
		{
			Damage_Reduction_Toxicity_Bonus = thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction_toxbonus');
			if(Damage_Reduction_Toxicity_Bonus > 0.0f)
			{
				Defender_Reduction = Defender_Reduction * (1+Damage_Reduction_Toxicity_Bonus);
			}
		}
	}
	
	//if NPC fights another NPC, we use basic damage
	if(isNpcVsNpcCombat)
	{
		Attacker_Damage = attacker.GetCharacterStats().ComputeDamageOutputPhysical(isNpcVsNpcCombat);
		damage_mult_bonus = 1.0;
		Defender_Reduction = 0.0f;
	}
	
   	//if ( defender != thePlayer ) Defender_Reduction = Defender_Reduction * ( thePlayer.GetDifficultyLevelMult() );
	if ( Defender_Reduction < 0 )  Defender_Reduction = 0;
	
	// Calc final damage
	if(attacker == thePlayer)
	{ 
		init_attacker_dmg = Attacker_Damage;
		Attacker_Damage  = Attacker_Damage * Attacker_Damage_Stamina_Bonus;
	}
	
	Attacker_Damage = Attacker_Damage * damage_mult_bonus + AddMonsterTypeDamageBonus( attacker, defender );
	init_attacker_dmg = init_attacker_dmg * damage_mult_bonus + AddMonsterTypeDamageBonus( attacker, defender );
	if(defender == thePlayer)
	{
		Attacker_Damage = Attacker_Damage * theGame.GetDamageDifficultyLevelMult(attacker, defender);
	}
	if(thePlayer.GetCombatV2())
	{
		if(Defender_Reduction_Perc > 1.0)
		{
			Defender_Reduction_Perc = 1.0;
		}
		
		Defender_Reduction_Perc = Defender_Reduction_Perc * thePlayer.GetStaminaBlockMult();
		
		Defender_Reduction_Perc = 1 - Defender_Reduction_Perc;
		
		Final_Damage = ( Attacker_Damage * Defender_Reduction_Perc ) - Defender_Reduction;
	}
	else
	{
		Final_Damage = Attacker_Damage - Defender_Reduction; 
	}
	
	
	//Dark swords add vitality on hit
	
	if(attacker == thePlayer && Final_Damage > 0.0f)
	{
		if ( thePlayer.IsDarkWeaponAddVitality() ) 
		{
			thePlayer.IncreaseHealth( Final_Damage * thePlayer.GetCharacterStats().GetAttribute('dark_add_vitality') );
			if ( !thePlayer.IsNotGeralt() ) thePlayer.PlayEffect('dark_difficulty_hit');
			if ( !thePlayer.IsNotGeralt() ) thePlayer.GetInventory().PlayItemEffect(thePlayer.GetCurrentWeapon(), 'dark_difficulty_hit');
			//defender.PlayEffect('dark_difficulty_hit', thePlayer.GetComponent("hit_point_fx"));
			
		}
	}
	
	//Final_Damage = Final_Damage * theGame.GetDamageDifficultyLevelMult(attacker, defender);
	
//	if ( !defenderBlocksHit && defender != thePlayer && Final_Damage<=1 && RandRangeF( 0.0, 100.0 ) < (50 - ( thePlayer.GetDifficultyLevelMult() * 10) ) ) // small chance to hit high level opponent
//	{
		//Final_Damage  = RandRangeF( attacker.GetCharacterStats().GetFinalAttribute('damage_min'), attacker.GetCharacterStats().GetFinalAttribute('damage_max') );
	//}
	//else 
	
	if(thePlayer.GetCurrentPlayerState() == PS_CombatFistfightStatic)
	{
		if(attacker == thePlayer)
		{
			Attacker_Damage = RandRangeF(attacker.GetCharacterStats().GetFinalAttribute('ff_damage_min'), attacker.GetCharacterStats().GetFinalAttribute('ff_damage_max'));
			Attacker_Damage = Attacker_Damage * damage_mult_bonus;
		}
		Defender_Reduction = defender.GetCharacterStats().GetFinalAttribute('damage_reduction');
		
		Final_Damage = Attacker_Damage - Defender_Reduction;
	}
	
	if (Final_Damage <= 5.0 && Final_Damage < defender.GetHealth()) 
	{
		// Critical Miss
		//theHud.m_hud.CombatLogAdd("<span class='orange'>"+Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_miss") + ".</span>" );
	
		if(defenderBlocksHit)
		{
			if(defender != thePlayer || !thePlayer.IsDodgeing())
			{
				if (add_to_combat_log) theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Defender_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_absorbs") + "</span>. ");
			}
			
			Final_Damage = 0;
		}
		else
		{
			attackerDmgInt = 0;
			defenderRedInt = RoundF(Defender_Reduction);
			attackerBasicDmgInt = RoundF(Attacker_Damage);
			if (add_to_combat_log) theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_crtmiss") + "</span>. ");
		
			if(defender == thePlayer)
			{
				if((!thePlayer.IsDodgeing() && !thePlayer.IsInGuardBlock()) || impossibleToBlock)
					Final_Damage = MaxF(5.0f, 5.0f*theGame.GetDamageDifficultyLevelMult(attacker, defender)); //Minimum damage is always 5 pt.
			}
			else
			{
				Final_Damage = MaxF(5.0f, 5.0f*theGame.GetDamageDifficultyLevelMult(attacker, defender)); //Minimum damage is always 5 pt.
			}
		}
		
	}
	else if (add_to_combat_log && Final_Damage < defender.GetHealth())
	{
		defenderRedInt = RoundF(Defender_Reduction);
		attackerBasicDmgInt = RoundF(Attacker_Damage);
		attackerDmgInt = attackerBasicDmgInt - defenderRedInt;
		if(defenderBlocksHit && defender == thePlayer)
		{
			attackerDmgInt = RoundF(Final_Damage);
			blockPerc = RoundF(Defender_Reduction_Perc * 100);
			tempIntVariable = 100 - blockPerc;
			theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " * <font color='#FF9900'>" + blockPerc + "%</font> - " + AddArmorIcon() + defenderRedInt + ") <font color='#FFFFFF'>"+ GetLocStringByKeyExt("cl_block_perc") +":</font> <font color='#FF9900'>"+ tempIntVariable +"%</font></span>. ");
		}
		else if(backDamage)
		{
			if(attacker == thePlayer)
			{
				
				staminaBonus = RoundF(100 * Attacker_Damage_Stamina_Bonus);
				
				if(staminaBonus >= 100)
				{
					theHud.m_hud.CombatLogAdd("<span class='orange'><font color='#FFFFFF'>"+GetLocStringByKeyExt("cl_back")+"</font></span>");
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " - " + AddArmorIcon() + defenderRedInt + ")</span>.");
				}
				else
				{
					attackerBasicDmgInt = RoundF(init_attacker_dmg);
					tempIntVariable = 100 - staminaBonus;
					theHud.m_hud.CombatLogAdd("<span class='orange'><font color='#FFFFFF'>"+GetLocStringByKeyExt("cl_back")+"</font></span>");
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " * <font color='#FF9900'>" + staminaBonus + "%</font>" + " - " + AddArmorIcon() + defenderRedInt + ") <font color='#FFFFFF'>"+ GetLocStringByKeyExt("cl_fatigue") +":</font> <font color='#FF9900'>"+ tempIntVariable +"%</font></span>. ");
				}
				
				
			}
			else
			{
				theHud.m_hud.CombatLogAdd("<span class='orange'><font color='#FFFFFF'>"+GetLocStringByKeyExt("cl_back")+"</font></span>");
				theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " - " + AddArmorIcon() + defenderRedInt + ")</span>. ");
			}
			
		}
		else
		{
			if(attacker == thePlayer)
			{
				staminaBonus = RoundF(100 * Attacker_Damage_Stamina_Bonus);
				
				if(staminaBonus >= 100)
				{
					
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " - " + AddArmorIcon() + defenderRedInt + ")</span>.");
				}
				else
				{
					attackerBasicDmgInt = RoundF(init_attacker_dmg);
					tempIntVariable = 100 - staminaBonus;
					theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " * <font color='#FF9900'>" + staminaBonus + "%</font>" + " - " + AddArmorIcon() + defenderRedInt + ") <font color='#FFFFFF'>"+ GetLocStringByKeyExt("cl_fatigue") +":</font> <font color='#FF9900'>"+ tempIntVariable +"%</font></span>. ");
				}
			}
			else
			{
				theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_hitfor") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " - " + AddArmorIcon() + defenderRedInt + ")</span>. ");
			}
		}
	}
	
	if (Final_Damage >= defender.GetHealth() )
	{
		// Takedown Hit
		defender.allowToCut.LeftArm = true;
		defender.allowToCut.RightArm = true;
		defender.TakedownReady = true;
		
		defenderRedInt = RoundF(Defender_Reduction);
		attackerBasicDmgInt = RoundF(Attacker_Damage);
		attackerDmgInt = attackerBasicDmgInt - defenderRedInt;
		if (add_to_combat_log) theHud.m_hud.CombatLogAdd("<span class='orange'>"+ Attacker_Name + "</span><span class='white'> " + GetLocStringByKeyExt("cl_deadly") + " </span><span class='red'>" + attackerDmgInt + " (" + AddDamageIcon() + attackerBasicDmgInt + " - " + AddArmorIcon() + defenderRedInt + ")</span>. ");
	} 
	if(Final_Damage < 0)
	{
		Final_Damage = 0;
	}
	if (apply_when_calculated)
	{
		// Apply vitiality 
		if ( !defender.IsInvulnerable() )
		{	
			defender.DecreaseHealth(Final_Damage, is_non_lethal, attacker);
			
		}
	}

	if (show_splatter) theHud.m_fx.BloodSplatterStart();
	
	return Final_Damage;
}

// END CLASS
//}
