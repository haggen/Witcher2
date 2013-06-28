/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CDrowner class
/////////////////////////////////////////////

class CDrowner extends W2Monster
{
	editable var lowHealthPercentage   : int;   // (0,100]	If health is below this percentage than Rotfiend can hide
	editable var hiddenTeleportRange   : float; // >=0		The maximum range of teleport when Rotfiend is hiding
	editable var minRegenerationTime   : float; // >=0		The minimum regeneration time duration - the time when Rotfiend is hiding (is buried)
	editable var maxRegenerationTime   : float; // >=0		The maximum regeneration time duration - the time when Rotfiend is hiding (is buried)
	editable var retryRegenerationTime : float; // >=0		After regeneration Rotfiend will not regenerate again for this amount of time
	editable var regenerationChance    : int;   // (0, 100]	The chance (in percentages) that Rotfiend will hide and regenerate
	editable var regenerationFactor    : float; // (0, 1]	If equals 1 than after 'maxRegenerationTime' Rotfiend will regain full health
	
	default lowHealthPercentage = 20;   // 20%
	default hiddenTeleportRange = 15;   // in meters
	default minRegenerationTime = 3;    // in seconds
    default maxRegenerationTime = 7;    // in seconds
    default retryRegenerationTime = 15; // in seconds
    default regenerationChance = 75;    // 75%
    default regenerationFactor = 0.8;

	var lowHealthValue : float;
	var isHiding : bool;
	var retryRegenerationTimer : float;
	var unburyRequest : bool; // if true than stop hiding
	
	default isHiding = false;
	default unburyRequest = false;


	// Public methods for Rotfiend management (special monster behavior)
	function CanAct() : bool
	{
		return true;
	}
	function GetMonsterType() : EMonsterType
	{
		return MT_Drowner;
	}
	
	public function Unbury()
	{
		if ( isHiding )
		{
			unburyRequest = true;
		}
	}
	
	public function OnBullvoreSpitHit()
	{
		
	}
	
	// =================================================================


	// Initialize Rotfiend
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;		
		
		//GetBehTreeMachine().EnableDebugDumpRestart(true);
		
		super.OnSpawned(spawnData);
		actActions.PushBack(AA_Act1);
		actActions.PushBack(AA_Act2);
		actActions.PushBack(AA_Act3);
		actActions.PushBack(AA_Act4);
		GetInventory().AddItem( 'Rotfiend Guts', 1 );
		// calculate low health
		lowHealthValue = initialHealth * (lowHealthPercentage / 100.0);
		
		isHiding = false;
		retryRegenerationTimer = 0;
		unburyRequest = false;
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
	}
	
	function EnterCombat( params : SCombatParams )
	{	
		if ( !isHiding )
		{
			TreeCombatDrowner(params);
			OnEnteringCombat();
		}
	}
}
state Spawn in CDrowner extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		if(parent.usesSpawnAnimation)
		{
			parent.WaitForBehaviorNodeDeactivation('SpawnEnd', 3.0);
		}
		parent.SetAttackableByPlayerRuntime( true );
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.SetSpawnAnim(SA_Idle);
		MarkGoalFinished();
	}
};
