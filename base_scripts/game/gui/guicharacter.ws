/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Character gui panel
/** Copyright © 2010
/***********************************************************************/

enum EDisplayPercType
{
	DPT_Default,
	DPT_Perc,
	DPT_NoPerc,
}

class CGuiCharacter extends CGuiPanel
{
	private var AS_character		: int;
	private var m_mapItemIdxToId	: array< SItemUniqueId >;
	private var m_mapAbilityIdxToId	: array< string >;
	private var m_isInteractive		: bool;
	
	public function SetIsInteractive( isInteractive : bool )
	{
		m_isInteractive = isInteractive;
	}
	
	// Hide hud
	function GetPanelPath() : string { return "ui_character.swf"; }
	
	event OnOpenPanel()
	{
		super.OnOpenPanel();
	}
	function IsNestedPanel() : bool
	{
		if(GetPreviousPanel() == "meditation")
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnClosePanel()
	{
		theHud.ForgetObject( AS_character );
	
		//theHud.EnableWorldRendering( true );
		theGame.SetActivePause( false );
		
		theSound.RestoreAllSounds();
		
		super.OnClosePanel();
		
		theHud.HideCharacter();
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by C++
	private final function GetTalentPoints() : int
	{
		return thePlayer.GetTalentPoints();
	}
	private final function SetTalentPoints( num : int )
	{
		thePlayer.SetTalentPoints( num );
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	private final function FillData()
	{

		theHud.m_hud.HideTutorial();
		
		theSound.SetSoundsVolume(  SOUND_GAMEPLAY_VOICE_FLAG | SOUND_SCENE_VOICE_FLAG |
			SOUND_ANIMATION_FLAG | SOUND_AMBIENT_FLAG | SOUND_FX_FLAG | SOUND_SCENE_FLAG, -60.0f, 1.0f );
		
		theHud.m_hud.setCSText( "", "" );
		theGame.SetActivePause( true );
		//theHud.EnableWorldRendering( false );
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mCharacter", AS_character ) )
		{
			Log( "No mCharacter found at the Scaleform side!" );
		}
		
		FillCharacter();

		theHud.EnableInput( true, true, true, true );
	}
	
	private final function MutateAbility( abilityIdF, mutagenIdF : float )
	{
		var confirm : CGuiConfirmAbilityMutation = new CGuiConfirmAbilityMutation in theHud.m_messages;
		confirm.m_itemId		= m_mapItemIdxToId[ (int)mutagenIdF ];
		confirm.m_abilityName	= StringToName( m_mapAbilityIdxToId[ (int)abilityIdF ] );
		AddAchievementCounter('ACH_MUTANT', 1, 5);
		theHud.m_messages.ShowConfirmationBox( confirm );
	}
	
	private final function BuyAbilityLevel( abilityIdF : float )
	{
		var stats		: CCharacterStats	= thePlayer.GetCharacterStats();
		var abilityS	: string			= m_mapAbilityIdxToId[ (int)abilityIdF ];
		var abilityN	: name				= StringToName( abilityS );
		var i			: int;
		var confirm		: CGuiConfirmAbilityUpgrade;

		LogChannel( 'GUI_Ability', abilityS ); // temporary for debug only
		
		if ( thePlayer.GetTalentPoints() <= 0 )
		{
			return;
		}
		
		if ( ! stats.IsAbilityDefined( abilityN ) )
		{
			return;
		}
		
		if ( stats.HasAbility( abilityN ) )
		{
			for ( i = 2; true; i += 1 )
			{
				abilityN = StringToName( abilityS + "_" + i );
				if ( ! stats.IsAbilityDefined( abilityN ) )
					return;
				
				if ( ! stats.HasAbility( abilityN ) )
					break;
			}
		}
		
		if ( ! stats.IsAbilityAvailableToBuy( abilityN ) )
		{
			return;
		}
		
		confirm = new CGuiConfirmAbilityUpgrade in theHud.m_messages;
		confirm.m_abilityName = abilityN;
		theHud.m_messages.ShowConfirmationBox( confirm );
	}
	
	// Fill panel data
	private final function FillCharacter()
	{
		var AS_attribute			: int;
		var AS_attributes			: int;
		var stats					: CCharacterStats = thePlayer.GetCharacterStats();
		var attributes				: array< name >;
		var valMin, valMax			: float;
		var valueS					: string;
		var baseXP					: int = GetBaseExperienceForLevel( thePlayer.GetLevel() - 1 );
		
		var talentsSpentTrain		: int;
		var talentsSpentMagic		: int;
		var talentsSpentSword		: int;
		var talentsSpentAlche		: int;
		
		theHud.SetBool( "IsInteractive", m_isInteractive, AS_character );
		
		theHud.SetFloat( "PCLevel",		thePlayer.GetLevel(),								AS_character );
		theHud.SetFloat( "PCTalents",	thePlayer.GetTalentPoints(),						AS_character );
		theHud.SetFloat( "MinXP",		baseXP,												AS_character ); // exp for prev level
		theHud.SetFloat( "CurXP",		thePlayer.GetExp(),									AS_character ); // exp now
		theHud.SetFloat( "MaxXP",		GetExperienceForNextLevel( thePlayer.GetLevel() ),	AS_character ); // exp needed for next level

		// Attributes
		if ( theHud.GetObject( "Abilities", AS_attributes, AS_character ) )
		{
			theHud.ClearElements( AS_attributes );
			
			// Add damage min-max
			{
				valMin = stats.GetAttribute( 'damage_min' );	// DAMAGE
				valMax = stats.GetAttribute( 'damage_max' );	// DAMAGE
				if ( valMin != valMax )
					valueS = RoundF(valMin) + "-" + RoundF(valMax);
				else
					valueS = RoundF(valMin);
				
				AS_attribute = theHud.CreateAnonymousObject();
				theHud.SetFloat	( "ID",			0x00000041,								AS_attribute );
				//theHud.SetString( "Name",		GetLocStringByKeyExt( attrName ),		AS_attribute );
				//theHud.SetString( "Icon",		"icons/items/" + attrName + ".swf",		AS_attribute );
				theHud.SetString( "Value",		valueS,									AS_attribute );
				theHud.PushObject( AS_attributes, AS_attribute );
				theHud.ForgetObject( AS_attribute );
			}
			ListAttribute( stats, AS_attributes, 'damage_reduction', 0x00000011, DPT_NoPerc );	// ARMOR
			ListAttribute( stats, AS_attributes, 'damage_reduction_block', 0x00000021 );		// 
			ListAttribute( stats, AS_attributes, 'vitality', 0x00000101, DPT_NoPerc );			// VITALITY
			ListAttribute( stats, AS_attributes, 'endurance', 0x00000201, DPT_NoPerc );			// VIGOR (=STAMINA)

/*
			AS_attribute = theHud.CreateAnonymousObject();
			theHud.SetFloat	( "ID",			0x00000201,									AS_attribute );
			theHud.SetString( "Value",		FloatToString( thePlayer.GetStamina() ) ,	AS_attribute );
			theHud.PushObject( AS_attributes, AS_attribute );
			theHud.ForgetObject( AS_attribute );
*/
			// VIGOR
			attributes.Clear();
			stats.GetAttributesByType( 'vitality', attributes );
			ListAttributes( stats, AS_attributes, attributes, 0x00000100 );

			// REGENERATION
			attributes.Clear();
			stats.GetAttributesByType( 'endurance', attributes ); // regeneracje zywotnosci
			ListAttributes( stats, AS_attributes, attributes, 0x00000200, DPT_NoPerc, 2 );
			
			// RESISTANCE
			attributes.Clear();
			stats.GetAttributesByType( 'resistance', attributes );
			ListAttributes( stats, AS_attributes, attributes, 0x00001000 );
			
			// CRITICAL EFFECTS
			attributes.Clear();
			stats.GetAttributesByType( 'critical', attributes );
			ListAttributes( stats, AS_attributes, attributes, 0x00002000 );
			
			// BONUSES
			attributes.Clear();
			stats.GetAttributesByType( 'bonus', attributes );
			ListAttributes( stats, AS_attributes, attributes, 0x00004000 );
			
			theHud.ForgetObject( AS_attributes );
		}
		
		FillKnowledge();

		m_mapAbilityIdxToId.Clear();
		talentsSpentTrain = ListTreeSkills( stats, "SkillsTreeTraining",	"training",	1, 2 );
		talentsSpentMagic = ListTreeSkills( stats, "SkillsTreeMagic",		"magic",	2, 2 );
		talentsSpentSword = ListTreeSkills( stats, "SkillsTreeSwords",		"sword",	3, 2 );
		talentsSpentAlche = ListTreeSkills( stats, "SkillsTreeAlchemy",		"alchemy",	4, 2 );
		
		theHud.SetBool( "SkillsTreeTrainingAvailable",	true,					AS_character );
		theHud.SetBool( "SkillsTreeMagicAvailable",		talentsSpentTrain >= 6,	AS_character );
		theHud.SetBool( "SkillsTreeSwordsAvailable",	talentsSpentTrain >= 6,	AS_character );
		theHud.SetBool( "SkillsTreeAlchemyAvailable",	talentsSpentTrain >= 6,	AS_character );
		
		//                                               treeId, max allowed level, the number of skills
		ListStorySkills( stats, "QuestSkills",	"story", 5,      3,                 32 );
		
		ListMutagens();
		
		theHud.Invoke( "Commit", AS_character );
	}
	
	private final function ListMutagens()
	{
		var inventory		: CInventoryComponent = thePlayer.GetInventory();
		var stats			: CCharacterStats = thePlayer.GetCharacterStats();
		var AS_mutagens		: int;
		var AS_item			: int;
		var mutagens		: array< SItemUniqueId >;
		var i				: int;
		var emptyList		: array< SItemUniqueId >;
		
		m_mapItemIdxToId.Clear();
		
		if ( theHud.GetObject( "Mutagens", AS_mutagens, AS_character ) )
		{
			theHud.ClearElements( AS_mutagens );
			
			mutagens = inventory.GetItemsByCategory( 'skillupgrade' );
			for ( i = 0; i < mutagens.Size(); i += 1 )
			{
				AS_item = theHud.CreateAnonymousObject();
				
				m_mapItemIdxToId.PushBack( mutagens[ i ] );
				
				theHud.m_utils.FillItemObject( inventory, stats, mutagens[ i ], i, AS_item, emptyList );
				
				theHud.PushObject( AS_mutagens, AS_item );
				theHud.ForgetObject( AS_item );
			}
			
			theHud.ForgetObject( AS_mutagens );
		}
	}
	
	private final function ListAttributes( stats : CCharacterStats, AS_attributes : int , attributes : array< name >, mask : int, optional dispType : EDisplayPercType, optional floatPrecision : int )
	{
		var i : int;
		for ( i = attributes.Size()-1; i >= 0; i -= 1 )
		{
			ListAttribute( stats, AS_attributes, attributes[i], mask, dispType, floatPrecision );
		}
	}
	
	private final function ListAttribute( stats : CCharacterStats, AS_attributes : int , attrName : name, mask : int, optional dispType : EDisplayPercType, optional floatPrecision : int )
	{
		var AS_attribute	: int	= theHud.CreateAnonymousObject();
		//var val				: float	= stats.GetAttribute( attrName );
		var valueS			: string;
		//var maskFloat		: float	= ReinterpretIntAsFloat( mask );
		var val : float;
		var dispPerc : bool;
		
		stats.GetAttributeForDisplay( attrName, val, dispPerc );
		
		//LogChannel( 'char_stats', "Attr name: " + attrName + "   Value: " + value + "   Display perc: " + dispPerc );
		
		if ( dispType == DPT_NoPerc )
		{
			dispPerc = false;
		}
		else if ( dispType == DPT_Perc )
		{
			dispPerc = true;
		}

		//if ( val > 0.f && val < 1.f )
		if ( dispPerc )
		{
			valueS = FloatToStringPrec( val * 100, floatPrecision ) + "%";
		}
		else
		{
			valueS = FloatToStringPrec( val, floatPrecision );
		}
			
		
		theHud.SetFloat	( "ID",			mask,										AS_attribute );
		theHud.SetString( "Name",		GetLocStringByKeyExt( attrName ),			AS_attribute );
		theHud.SetString( "Icon",		"icons/attrs/" + attrName + "_64x64.dds",	AS_attribute );
		theHud.SetString( "Value",		valueS,										AS_attribute );
		
		Log("--> " + GetLocStringByKeyExt( attrName ) + " " + valueS);
		
		theHud.PushObject( AS_attributes, AS_attribute );
		theHud.ForgetObject( AS_attribute );
	}
	
	// Zakladka Wiedza (Knowledge)
	private final function FillKnowledge()
	{
		var AS_knowledge	: int;
		var AS_accum		: int;
		var i, j, size		: int;
		var accum			: SKnowledgeAccum;
		var baseName		: string;
		var description		: string;
		//var tmp : string;
		
		if ( theHud.GetObject( "Wisdom", AS_knowledge, AS_character ) )
		{
			theHud.ClearElements( AS_knowledge );
			
			size = thePlayer.GetKnowledgeAccumSize();
			for ( i = 0; i < size; i += 1 )
			{
				accum = thePlayer.GetKnowledgeAccum( i );
				
					baseName	= "Knowledge_" + (i + 1);
					description	= "";
				
			if ( i == 9 || i == 10 || i == 11 ) 
			{
				description += GetLocStringByKeyExt( baseName + " 0" ) + "<br/><br/><font color='#ff9900' size='12'>" + GetLocStringByKeyExt("[[locale.char.lbSkillLevel]]") + ": " + accum.m_level + "/1";
			} else
			{
				for ( j = 1; j < accum.m_level + 1; j += 1 )
				{
					description += GetLocStringByKeyExt( baseName + " " + j ) + "<br/><br/>";
				}
				description += "<font color='#ff9900' size='12'>" + GetLocStringByKeyExt("[[locale.char.lbSkillLevel]]") + ": " + accum.m_level + "/3";
			}
				
				
				if ( accum.m_level > 0 ) // omit skills with no level
				{
					AS_accum = theHud.CreateAnonymousObject();
				
					// ---
					//tmp = GetLocStringByKeyExt( baseName );
					// ---
				
					theHud.SetString( "Name",		GetLocStringByKeyExt( baseName ),	AS_accum );
					theHud.SetString( "Desc",		description,						AS_accum );
					//theHud.SetFloat	( "Level",		accum.m_level,						AS_accum );
					theHud.SetFloat	( "XPPercent",	RoundF( accum.m_experience * 10 ),	AS_accum );
				
					theHud.PushObject( AS_knowledge, AS_accum );
					theHud.ForgetObject( AS_accum );
				}
			}
		}
	}
	
	private final function ListStorySkills( stats : CCharacterStats, asTreeName, engineTreeName : string, treeId, maxAllowedLevel, skillsCount : int )
	{
		var AS_tree			: int;
		var AS_skill		: int;
		var i, k			: int;
		var description		: string;
		var abilityS		: string;
		var levelS			: string;
		var levelN			: name;
		var playerLevel		: int;
		
		if ( theHud.GetObject( asTreeName, AS_tree, AS_character ) )
		{
			theHud.ClearElements( AS_tree );
			
			
			// i = skill number
			// k = skill 'i' level number
			for ( i = 1; i <= skillsCount; i += 1 )
			{
				abilityS	= engineTreeName + "_s" + i;

				playerLevel = 0;

				for ( k = 1; k <= maxAllowedLevel; k += 1 )
				{
					levelS		= abilityS + "_" + k;
					levelN		= StringToName( levelS );
				
					//if ( ! stats.IsAbilityDefined( levelN ) ) continue;
					if ( ! stats.HasAbility( levelN ) ) continue;
					
					playerLevel = k;
					
					
				}
				
				if ( playerLevel > 0  )
				{
					//if ( i <> playerLevel ) 
					//{
						description = "<font color='#ffffff' size='12'>" + theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( abilityS + "_description" ) + "<br/><br/><font color='#ff9900' size='12'>" + GetLocStringByKeyExt("[[locale.char.lbSkillLevel]]") + ": " + playerLevel + "" );
					//} else
					//{
					//	description = "<font color='#ffffff' size='12'>" + theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( abilityS + "_description" ) ) + "<br/><br/>" ;
					//}

					AS_skill = theHud.CreateAnonymousObject();

					theHud.SetString( "Name",	GetLocStringByKeyExt( abilityS ),	AS_skill );
					theHud.SetString( "Desc",	description,						AS_skill );
					//theHud.SetFloat	( "Level",	playerLevel,						AS_skill );
				
					theHud.PushObject( AS_tree, AS_skill );
					theHud.ForgetObject( AS_skill );
				}
			}
			
			theHud.ForgetObject( AS_tree );
		}
	}
	
	private final function ListTreeSkills( stats : CCharacterStats, asTreeName, engineTreeName : string, treeId, maxAllowedLevel : int ) : int
	{
		var AS_tree			: int;
		var AS_skill		: int;
		var AS_descrArr		: int;
		var AS_mutations	: int;
		var i, j			: int;
		var abilityS		: string;
		var levelS			: string;
		var levelN			: name;
		var playerLevel		: int;
		var maxLevel		: int;
		var enhancements	: array< name >;
		var mutagentsSlotsNum : int;
		var attributes 		: array< name >;
		var valAdd 			: array< float >;
		var valMul 			: array< float >;
		var dispPercAdd 	: array< bool >;
		var dispPercMul 	: array< bool >;
		
		var talentsSpent	: int = 0;
		
		if ( theHud.GetObject( asTreeName, AS_tree, AS_character ) )
		{
			theHud.ClearElements( AS_tree );
			
			theHud.PushObject( AS_tree, -1 );
			
			for ( i = 1; true; i += 1 )
			{
				abilityS	= engineTreeName + "_s" + i;
				levelS		= abilityS;
				levelN		= StringToName( levelS );
				
				if ( ! stats.IsAbilityDefined( levelN ) )
					break;
				
				if ( stats.HasAbility( levelN ) )	playerLevel = 1;
				else								playerLevel = 0;

				AS_skill = theHud.CreateAnonymousObject();
				
				//theHud.SetFloat( "MaxMutations", stats.GetMaxEnhancementsForAbility( levelN ), AS_skill );
				mutagentsSlotsNum = stats.GetMaxEnhancementsForAbility( levelN );
				
				AS_descrArr = theHud.CreateArray( "LvlDesc", AS_skill );
				theHud.PushString( AS_descrArr, GetSkillTreeDescription( levelS + "_description" ) );
				
				
				maxLevel = 1;
				for ( j = 2; true; j += 1 )
				{
					levelS		= abilityS + "_" + j;
					levelN		= StringToName( levelS );
					
					if ( ! stats.IsAbilityDefined( levelN ) )
						break;
					
					theHud.PushString( AS_descrArr, GetSkillTreeDescription( levelS + "_description" ) );
					
					maxLevel = j;
					if ( stats.HasAbility( StringToName( levelS ) ) )
						playerLevel = j;
				}
				
				if ( playerLevel == 0 )
				{
					mutagentsSlotsNum = 0;
				}
				else if ( playerLevel == 1 && mutagentsSlotsNum > 1 )
				{
					mutagentsSlotsNum = 1;
				}
				theHud.SetFloat( "MaxMutations", mutagentsSlotsNum, AS_skill );
				
				
				theHud.SetFloat	( "ID",			m_mapAbilityIdxToId.Size(),						AS_skill );
				theHud.SetString( "Name",		GetLocStringByKeyExt( abilityS ),				AS_skill );
				theHud.SetString( "Icon",		"icons/abilities/" + abilityS + "_64x64.dds",	AS_skill );
				theHud.SetFloat	( "Level",		playerLevel,									AS_skill );
				theHud.SetFloat	( "LevelCap", 	maxLevel,										AS_skill );
				
				attributes.Clear();
				valAdd.Clear();
				valMul.Clear();
				dispPercAdd.Clear();
				dispPercMul.Clear();
				stats.GetAbilityEnhancements( StringToName( abilityS ), attributes, valAdd, valMul, dispPercAdd, dispPercMul );
			
				if ( attributes.Size() > 0 )
				{
					AS_mutations = theHud.CreateArray( "Mutations", AS_skill );
					for ( j = 0; j < attributes.Size(); j += 1 )
					{
						if ( attributes[j] != 'item_weight' && attributes[j] !=  'item_price' )
						{
							theHud.PushString( AS_mutations, GetLocStringByKeyExt( attributes[j] ) +
								" " + theHud.m_utils.ListAttributeBase( valAdd[j], valMul[j], dispPercMul[j], dispPercAdd[j] ) );
						}
					}
					theHud.ForgetObject( AS_mutations );
				}

				theHud.PushObject( AS_tree, AS_skill );
				theHud.ForgetObject( AS_descrArr );
				theHud.ForgetObject( AS_skill );
				
				m_mapAbilityIdxToId.PushBack( abilityS );
				talentsSpent += playerLevel;
			}
			
			theHud.ForgetObject( AS_tree );
		}
		
		return talentsSpent;
	}
	
	function GetSkillTreeDescription( key : string ) : string
	{
		var retValue : string;

		retValue = theHud.m_utils.ParseAbilitiesTokens( "@", GetLocStringByKeyExt( key ) );
		
		return retValue;
	}
}

class CGuiConfirmAbilityUpgrade extends CGuiConfirmationBox
{
	var m_abilityName	: name;
	
	function GetText()				: string	{ return GetLocStringByKeyExt("Upgrade anbility?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		theSound.PlaySound( "gui/chardev/skillbought" );

		thePlayer.GetCharacterStats().AddAbility( m_abilityName );
		thePlayer.SetTalentPoints( thePlayer.GetTalentPoints() - 1 );
		
		theHud.m_character.FillCharacter();
	}
	event OnNo() {}
}

class CGuiConfirmAbilityMutation extends CGuiConfirmationBox
{
	var m_abilityName	: name;
	var m_itemId		: SItemUniqueId;
	
	function GetText()				: string	{ return GetLocStringByKeyExt("Mutate ability?"); }
	function GetSelectionOfEscape()	: bool		{ return false; }
	
	event OnYes()
	{
		if ( thePlayer.GetCharacterStats().EnhanceAbility( m_abilityName, m_itemId, AET_AddAdjustModifiers ) )
		{
			theSound.PlaySound( "gui/chardev/mutagenapplied" );

			thePlayer.GetInventory().RemoveItem( m_itemId, 1 );
			
			theHud.m_character.FillCharacter();
		}	
	}
	event OnNo() {}
}
