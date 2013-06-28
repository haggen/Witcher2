// BASICS

function IncFactCounter( factName : string, value : int )
{
	Log("FactCounter: " + factName + " + " + value);
	FactsAdd( factName, value );
}

function DecFactCounter( factName : string, value : int )
{
	Log("FactCounter: " + factName + " - " + value);
	FactsAdd( factName, -value );
}

function GetFactCounterValue ( factName : string ) : int
{
	var output : int = FactsQuerySum( factName );
	Log("FactCounter: " + factName + " = " + output);
	return output;
}

// STORY ABILITIES

function AddStoryAbilityCounter( abilityName : string, value : int, max_value : int )
{
	IncFactCounter( abilityName+"_counter", 1);
	if ( FactsQuerySum( abilityName+"_counter" ) <= max_value )	AddStoryAbility( abilityName, 1 );
}

// ACHIEVEMENTS

function AddAchievementCounter( achievementName : string, value : int, max_value : int )
{
	IncFactCounter( achievementName+"_counter", 1);
	if ( FactsQuerySum( achievementName+"_counter" ) >= max_value ) theGame.UnlockAchievement( StringToName( achievementName ) );
}