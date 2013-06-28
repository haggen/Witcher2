/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** GUI Overview
/** Copyright © 2010
/***********************************************************************/

class CGuiOverview extends CGuiPanel
{
	private var AS_overview : int;

	// Hide hud
	function GetPanelPath() : string { return "ui_overview.swf"; }
	function IsNestedPanel()	: bool
	{
		return true;
	}
	event OnOpenPanel()
	{
		super.OnOpenPanel();
		//theGame.SetActivePause( true );
		
		theHud.m_hud.HideTutorial();
		
		// Find variable that already exists (ex. it has been created by AS) or create it, if hasn't been found
		if ( ! theHud.GetObject( "mOverview", AS_overview ) )
		{
			LogChannel( 'GUI', "CGuiElixirs: No mOverview found at the Scaleform side!" );
		}
		
		//FillOverview();
	}
	
	event OnClosePanel()
	{
		//theGame.SetActivePause( false );
		super.OnClosePanel();
		theHud.HideOverview();
	}
	
	private function FillOverview()
	{
		var baseXP : int = GetBaseExperienceForLevel( thePlayer.GetLevel() );
		var AS_gameTime : int;
		
		// N
		theHud.SetFloat( "PCLevel",		thePlayer.GetLevel(),										AS_overview );
		theHud.SetFloat( "PCTalents",	thePlayer.GetTalentPoints(),								AS_overview );
		theHud.SetFloat( "MinXP",		baseXP,														AS_overview ); // exp for prev level
		theHud.SetFloat( "CurXP",		baseXP + thePlayer.GetExp(),								AS_overview ); // exp now
		theHud.SetFloat( "MaxXP",		baseXP + GetExperienceForNextLevel( thePlayer.GetLevel() ),	AS_overview ); // exp needed for next level
		theHud.SetString( "PCTitle",	"Geralt", AS_overview ); // TODO

		// TIME - NE
		theHud.GetObject( "GameTime", AS_gameTime, AS_overview );
		theHud.SetFloat( "Minutes",	GameTimeMinutes( theGame.GetGameTime() ),	AS_gameTime );
		theHud.SetFloat( "Hours", 	GameTimeHours( theGame.GetGameTime() ),		AS_gameTime );
		theHud.ForgetObject( AS_gameTime );
		
		// TODO strings
		theHud.SetString( "GamePhase",		"Game Phase", 	AS_overview );
		theHud.SetString( "GameLocation",	"Game Location",	AS_overview );

		// STATS
		theHud.SetFloat( "NumKills", 		0,	AS_overview );
		theHud.SetFloat( "NumDeaths", 		0,	AS_overview );
		theHud.SetFloat( "NumMutations", 	0,	AS_overview );
		theHud.SetFloat( "NumCrafts",		0,	AS_overview );
		theHud.SetFloat( "NumDismantles", 	0,	AS_overview );
		theHud.SetFloat( "NumAchievements", 0,	AS_overview );

		UpdateBuffs();


		theHud.Invoke( "Commit", AS_overview );
	}
	
	final function UpdateBuffs()
	{
		var i,s				: int;
		var AS_buffs		: int;
		var AS_buff			: int;
		var activeBuffs		: array < SBuff >;
		var criticalEffects	: array < W2CriticalEffectBase >;
		var quen			: CWitcherSignQuen;
		
		theHud.GetObject( "Buffs", AS_buffs, AS_overview );
		theHud.ClearElements( AS_buffs );
		
		// Pass oils
		activeBuffs = thePlayer.GetActiveOils();
		s = activeBuffs.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( activeBuffs[ i ].m_name ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/buffs/" + StrReplaceAll(activeBuffs[ i ].m_name, " ", "") + "_64x64.dds",	AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration,	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	activeBuffs[ i ].m_duration,												AS_buff );
			theHud.SetString( "Flav", "", AS_buff ); // TODO: Flav
			
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}		
		
		// Pass elixirs
		activeBuffs = thePlayer.GetActiveElixirs();
		s = activeBuffs.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( activeBuffs[ i ].m_name ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/items/" + StrReplaceAll(activeBuffs[ i ].m_name, " ", "") + "_64x64.dds",	AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration,	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	activeBuffs[ i ].m_duration,												AS_buff );
			theHud.SetString( "Flav", "", AS_buff ); // TODO: Flav
			
			//LogChannel( 'GUI', "Idx: " + i );
			//LogChannel( 'GUI', "DurationPercent: " + (( 100.f * activeBuffs[ i ].m_duration ) / activeBuffs[ i ].m_maxDuration) );
			//LogChannel( 'GUI', "DurationSeconds: " + (activeBuffs[ i ].m_duration) );
		
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}
		
		// Pass critical effects
		criticalEffects = thePlayer.criticalEffects;
		s = criticalEffects.Size();
		for ( i = 0; i < s; i += 1 )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				criticalEffects[ i ].GetEffectName(),											AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/items/" + criticalEffects[ i ].GetEffectName() + "_64x64.dds",		AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * criticalEffects[ i ].GetTTL() ) / criticalEffects[ i ].GetDuration(),	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	criticalEffects[ i ].GetTTL(),													AS_buff );
			theHud.SetString( "Flav", "", AS_buff ); // TODO: Flav
	
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}
		
		quen = thePlayer.getActiveQuen();
		if ( quen )
		{
			AS_buff = theHud.CreateAnonymousObject();
			
			theHud.SetString( "Name",				GetLocStringByKeyExt( "Quen" ),							AS_buff );
			theHud.SetString( "Icon",				"img://globals/gui/icons/signs/quen_64x64.dds",			AS_buff );
			theHud.SetFloat	( "DurationPercent",	( 100.f * quen.GetTTL() ) / quen.GetTotalDuration(),	AS_buff );
			theHud.SetFloat	( "DurationSeconds",	quen.GetTTL(),											AS_buff );
			theHud.SetString( "Flav", "", AS_buff ); // TODO: Flav
	
			theHud.PushObject( AS_buffs, AS_buff );
			theHud.ForgetObject( AS_buff );
		}

		//theHud.InvokeMethod_O( "setBuffs", AS_buffs, AS_hud );
		
		theHud.ForgetObject( AS_buffs );
		
	}
	
	//////////////////////////////////////////////////////////////
	// Functions called by flash
	//////////////////////////////////////////////////////////////
	private final function FillData()
	{
		FillOverview();
	}
}
