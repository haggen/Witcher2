/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Scripted quest character customization operations
/** Copyright © 2011
/***********************************************************************/

import class CCCOpScript extends ICharacterCustomizationOperation
{
	// Implement with your character customization code.
	public abstract function Execute( entity : CGameplayEntity );
};

/////////////////////////////////////////////////////////////////////////


//resets player level to 1
class CCCOpResetLevel extends CCCOpScript
{
	public function Execute( entity : CGameplayEntity )
	{
		var level, talents, experience : int;
		
		thePlayer.ResetLevel();
		thePlayer.IncreaseExp( - thePlayer.GetExp() );
		thePlayer.ClearBuild();
	}
};
// raises level by given number = adding talent poi
class CCCOpAddLevels extends CCCOpScript
{
	editable var raiseLevelByNumber : int;
	
	public function Execute( entity : CGameplayEntity )
	{
		var i : int;
		
		for( i = 0; i < raiseLevelByNumber; i += 1 )
		{
			thePlayer.IncreaseExp( 1000 );
		}

	}
};

// resets talent points that are already distributed without, so player can make a different distribution
class CCCOpResetDistributedTalents extends CCCOpScript
{
	// Implement with your character customization code.
	public function Execute( entity : CGameplayEntity )
	{
		thePlayer.ClearBuild();
	}
};

// set talent points
class CCCOpSetTalentPoints extends CCCOpScript
{
	editable var points : int;

	// Implement with your character customization code.
	public function Execute( entity : CGameplayEntity )
	{
		thePlayer.SetTalentPoints( points );
	}
};