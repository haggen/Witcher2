
////////////////////////////////////////////////////////////
////	class for lures that attract nearby monsters	////
////////////////////////////////////////////////////////////

class CLure extends CEntity
{
	editable var range						:	float;
	editable var attractedMonsterClasses	:	array<name>;
	
	private var lureFightManager : CLureFightManager;
	private var attractedMonsters : array<W2Monster>;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		lureFightManager = new CLureFightManager in this;
		lureFightManager.Init( this );
		lureFightManager.Begin();
	}
	
	function Deactivate()
	{
		var i, size : int;
		var triggers : array<CComponent>;
		
		((CDrawableComponent)GetComponentByClassName('CDrawableComponent')).SetVisible(false);
		
		triggers = GetComponentsByClassName( 'CTriggerAreaComponent' );
		size = triggers.Size();
		for( i = 0; i < size; i += 1 )
		{
			((CTriggerAreaComponent)triggers[i]).SetEnabled(false);
		}
		
		size = attractedMonsters.Size();
		for( i = 0; i < size; i += 1 )
		{
			attractedMonsters[i].GetArbitrator().MarkGoalsFinishedByClassName('CAIGoalAttractedByLure');
			attractedMonsters[i].SetAttractedByLure(false, NULL);
			attractedMonsters[i].SetFightingForLure(false);
		}
	}
	timer function TimerDestroyLure(td : float)
	{	
		this.Destroy();
	}
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i, size : int;
		var monster : W2Monster;
		
		size = attractedMonsterClasses.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( activator.GetEntity().IsA( attractedMonsterClasses[i] ) )
			{
				monster = (W2Monster)activator.GetEntity();
				if( monster.IsFightingForLure() )
					return false;
				
				/*if( area.GetName() == "fight" )
				{
					Fight( monster );
				}
				else */if( !monster.IsAttractedByLure() )
					AttractMonster( monster );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i, size : int;
		var monster : W2Monster;
		
		size = attractedMonsterClasses.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( activator.GetEntity().IsA( attractedMonsterClasses[i] ) )
			{
				monster = (W2Monster)activator.GetEntity();
				monster.SetAttractedByLure( false, this );
			}
		}
	}
	
	function AttractMonster( monster : W2Monster )
	{
		monster.SetAttractedByLure( true, this );
		attractedMonsters.PushBack( monster );
		monster.GetArbitrator().AddGoalAttractedByLure( this );
	}
	
	function Fight( monster : W2Monster )
	{
		var size, i : int;
		
		size = attractedMonsters.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( attractedMonsters[i].IsAlive() && attractedMonsters[i] != monster && !attractedMonsters[i].IsFightingForLure() && !monster.IsFightingForLure() )
			{
				lureFightManager.EnterFight( attractedMonsters[i], monster );
			}
		}
	}
}

state Destroyed in CLure
{
	entry function MarkAsDestroyed()
	{
		parent.Deactivate();
		
		while( parent.lureFightManager.AreFightsActive() )
		{
			Sleep( 0.5 );
		}
		
		parent.Destroy();
	}
}

struct SLureFightPair
{
	var fighter1 : W2Monster;
	var fighter2 : W2Monster;
}

class CLureFightManager extends CStateMachine
{
	private var fightingPairs : array<SLureFightPair>;
	private var arraySize : int;
	private var parentLure : CLure;
	
	
	function Init( lure : CLure )
	{
		parentLure = lure;
		arraySize = 0;
	}
	
	function EnterFight( fighter1, fighter2 : W2Monster )
	{
		fighter1.SetFightingForLure( true );
		fighter2.SetFightingForLure( true );
		fighter1.SetAttitude( fighter2, AIA_Hostile );
		fighter2.SetAttitude( fighter1, AIA_Hostile );
		fightingPairs.PushBack( SLureFightPair( fighter1, fighter2 ) );
		arraySize += 1;
	}
	
	function AreFightsActive() : bool
	{
		return arraySize > 0;
	}
}

state Active in CLureFightManager
{
	entry function Begin()
	{
		var i : int;
		
		while( true )
		{
			for( i = parent.arraySize - 1; i > -1; i -= 1 )
			{
				UpdateFight( parent.fightingPairs[i] );
			}
			Sleep(0.5);
		}
	}
	
	private latent function UpdateFight( pair : SLureFightPair )
	{
		if( pair.fighter1.GetHealthPercentage() < 50 )
		{
			StopFight(pair);
			pair.fighter1.ForceCriticalEffect( CET_Fear, W2CriticalEffectParams( 0, 0, 4, 4 ) );
			pair.fighter1.GetArbitrator().MarkGoalsFinishedByClassName('CAIGoalAttractedByLure');
		}
		else if( pair.fighter2.GetHealthPercentage() < 50 )
		{
			StopFight(pair);
			pair.fighter2.ForceCriticalEffect( CET_Fear, W2CriticalEffectParams( 0, 0, 4, 4 ) );
			pair.fighter2.GetArbitrator().MarkGoalsFinishedByClassName('CAIGoalAttractedByLure');
		}
	}
	
	private function StopFight( pair : SLureFightPair )
	{
		pair.fighter1.SetAttitude( pair.fighter2, AIA_Neutral );
		pair.fighter1.SetFightingForLure( false );
		pair.fighter2.SetAttitude( pair.fighter1, AIA_Neutral );
		pair.fighter2.SetFightingForLure( false );
		parent.fightingPairs.Remove( pair );
		parent.arraySize -= 1;
	}
}

class CLureSpawner extends CEntity
{
	editable var lureToSpawn : CEntityTemplate;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		theGame.CreateEntity( lureToSpawn, GetWorldPosition(), GetWorldRotation() );
	}
}