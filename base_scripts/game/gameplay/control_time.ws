exec function GoFaster( multi : int )
{
	theGame.SetHoursPerMinute( 1*multi );
}	

exec function GoSlower( multi : int )
{
	theGame.SetHoursPerMinute( 1/multi );
}

exec function GoNormal()
{
	theGame.ResetHoursPerMinute();
}