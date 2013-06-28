/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CNekker class
/////////////////////////////////////////////

class CHarpie extends W2Monster
{
	editable var nestTag : name;
	editable var useHighSpawnAnim : bool;
	private var grounded : bool;


	default useHighSpawnAnim = false;
	// Initialize Nekker
	function UseHighSpawn(useHighSpawn : bool)
	{
		useHighSpawnAnim = useHighSpawn;
		SetSpawnAnim(SA_Spawn3);
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;	
		actActions.PushBack(AA_Act1);
		actActions.PushBack(AA_Act2);
		actActions.PushBack(AA_Act3);
		actActions.PushBack(AA_Act4);
		super.OnSpawned(spawnData);
		grounded = false;
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
		
	}
	function CanAct() : bool
	{
		return true;
	}
	function EnterCombat( params : SCombatParams )
	{	
		TreeCombatHarpie(params);
		OnEnteringCombat();
	}
	
	function GetMonsterType() : EMonsterType
	{
		return MT_Harpie;
	}
	
	// Is grounded
	function IsGrounded() : bool { return grounded; }
	

	
	// Set grounded
	function SetGrounded( flag : bool ) { grounded = flag; }
	

}
state Spawn in CHarpie extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		if(parent.useHighSpawnAnim)
		{
			parent.SetSpawnAnim(SA_Spawn3);
		}
		SetGoalId( goalId );
		parent.WaitForBehaviorNodeDeactivation('SpawnEnd', 5.0);
		MarkGoalFinished();
		parent.SetAttackableByPlayerRuntime( true );
	}
};