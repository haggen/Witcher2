/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009 m6a6t6i's Early Day R&D Home Center
/***********************************************************************/

// ------------------------------------------------------------------------
//                           FUNKCJE DO ENVIRO
// ------------------------------------------------------------------------

brix function GetEnviromentName(location_name : name, weather_intensity : float, out enviroment : CEntity)
{
	// weather intensity is not used yet. it should be use to blend two enviro each other (day <-> cloudy)

	var Time : GameTime;
	var currentHour : int;
	var time_name : string;
	var enviroment_name : name;
	Time = GameTimeCreate();
	currentHour = GameTimeHours(Time);
	
	// get current time
	if (currentHour >= 6 && currentHour < 8) time_name = "morning";
	if (currentHour >= 18 && currentHour < 20) time_name = "evening";
	if (currentHour >= 8 && currentHour < 18) time_name = "day";
	if (currentHour >= 20 || currentHour < 6) time_name = "night";
	
	// return
	enviroment_name = StringToName(location_name + "_" + time_name);
	enviroment = (CEntity) theGame.GetNodeByTag(enviroment_name);
	Log("Set enviroment with tag " + enviroment_name + " (EntityID: " + enviroment);
}