class CArenaCrowdMonster extends CEntity
{
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if(theGame.GetIsPlayerOnArena() && theGame.GetArenaManager().GetIsFighting())
		{
			if( eventType == AET_Tick && eventName == 'Shake' )
			{						
				if(VecDistanceSquared(thePlayer.GetWorldPosition(), this.GetWorldPosition()) < 36.0)
				{
					theCamera.SetBehaviorVariable('cameraShakeStrength', 0.3);
					theCamera.RaiseEvent('Camera_ShakeHit');
				}
				else if(VecDistanceSquared(thePlayer.GetWorldPosition(), this.GetWorldPosition()) >= 36.0 && VecDistanceSquared(thePlayer.GetWorldPosition(), this.GetWorldPosition()) < 100.0)
				{
					theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
					theCamera.RaiseEvent('Camera_ShakeHit');
				}				
			}
		}
		
		super.OnAnimEvent(eventName, eventTime, eventType);
	}
}


class CArenaRigidProjectile extends CEntity
{
	var rigidComp : CRigidMeshComponent;
	var impulse : Vector;
	var impulseStrength : float;
	var rigidCompGlobal : CRigidMeshComponent;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		ThrowProjectile();
	}
	function ThrowProjectile()
	{
		this.AddTimer('TimerThrowProjectile', 0.1 + RandF()*0.6, false);
	}
	timer function TimerThrowProjectile( td : float )
	{
		var angularVelocity : Vector;
		rigidComp = (CRigidMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		impulse = thePlayer.GetWorldPosition() - this.GetWorldPosition();
		impulse += VecRingRand(1.0, 7.0);
		impulse.Z += RandF()*4 + 10;
		
		impulseStrength = 0.2f*VecDistance(thePlayer.GetWorldPosition(), this.GetWorldPosition());
		impulse = VecNormalize(impulse);
		impulse = impulseStrength*impulse;
		rigidComp.ApplyLinearImpulse(impulse);
		rigidCompGlobal = rigidComp;
		
		angularVelocity = Vector(1*RandF() + 1, 1*RandF() + 1, 1*RandF() + 1);
		
		rigidComp.SetAngularVelocity(angularVelocity);
		
		this.AddTimer('TimerDestroyProjectile', 25.0 + 10*RandF(), false);
	}
	timer function TimerDestroyProjectile( td : float )
	{
		this.Destroy();
	}
}
class CArenaProjectile extends CRegularProjectile
{
	editable var explosionFX : CEntityTemplate;
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		ThrowProjectile();
	}
	function ThrowProjectile()
	{
		this.AddTimer('TimerThrowProjectile', 0.1 + RandF()*0.6, false);
	}
	timer function TimerThrowProjectile( td : float )
	{
		var target : Vector;
		this.ApplyAppearance("tomatto");
		target = thePlayer.GetWorldPosition();
		target += VecRingRand(1.0, 7.0);
		this.Start(NULL, target, false, 40.0 + 20.0*RandF());
	}
	timer function TimerDestroyProjectile( td : float )
	{
		this.Destroy();
	}
	function SmashProjectile()
	{
		var rotation : EulerAngles;
		rotation = this.GetWorldRotation();
		rotation.Roll = 0;
		rotation.Pitch = 0;
		theGame.CreateEntity(explosionFX, this.GetWorldPosition(), rotation);
		this.AddTimer('TimerDestroyProjectile', 0.1, false);
	}
	event OnProjectileCollision(comp : CComponent, pos : Vector, normal : Vector)
	{
		//SmashProjectile();
	}
	event OnRangeReached(inTheAir : bool)
	{
		SmashProjectile();
	}
}
class CArenaCrowdManager extends CEntity
{
	var arenaCrowdEntites : array<CNode>;
	var startPoints : array<CNode>;
	
	editable var arenaProjectiles : array<CEntityTemplate>;
	
	latent function ThrowProjectiles()
	{
		var totalProjectiles : int;
		var i, j, sizeStartPoints, sizeProjectiles : int;
		
		if(theGame.GetArenaManager().GetIsFighting())
		{
		
			totalProjectiles = 200;
			
			sizeProjectiles = arenaProjectiles.Size();
			
			if(arenaCrowdEntites.Size() <= 0)
			{
				GatherCrowd();
			}
			
			sizeStartPoints = startPoints.Size();
			
			if(sizeStartPoints <= 0)
			{
				GatherProjectilesStartPoints();
			}
			

			
			for(i = 0; i < totalProjectiles; i += 1)
			{
				Sleep(0.1);
				j = Rand(sizeStartPoints);
				if(theGame.GetArenaManager().GetIsFighting())
				{
					theGame.CreateEntity(arenaProjectiles[Rand(sizeProjectiles)], startPoints[j].GetWorldPosition(), EulerAngles(0,0,0));
				}
			}
		}
	}
	function GatherProjectilesStartPoints()
	{
		var i, j, size : int;
		var crowdEntity : CEntity;
		var components : array<CComponent>; 
		size = arenaCrowdEntites.Size();
		startPoints.Clear();
		for( i = 0; i < size; i += 1 )
		{
			crowdEntity = (CEntity)arenaCrowdEntites[i];
			components.Clear();
			components = crowdEntity.GetComponentsByClassName('CSpriteComponent');
			for(j = 0; j < components.Size(); j += 1)
			{
				startPoints.PushBack(components[j]);
			}
		}
		Log("Gathered");
		
	}
	function GatherCrowd()
	{
		if(arenaCrowdEntites.Size() <= 0)
		{
			theGame.GetNodesByTag('arena_crowd', arenaCrowdEntites);
		}
	}
}
state Default in CArenaCrowdManager
{
	entry function CrowdReactionAnim(reactionType : EArenaCrowdReactionType)
	{
		var arenaCrowdSize, i : int;
		var reactionName : name;
		var crowdEntity : CEntity;
		parent.GatherCrowd();
		reactionName = 'None';
		if(reactionType == ACR_Win || reactionType == ACR_Kill)
		{
			reactionName = 'Cheer';
		}
		else if(reactionType == ACR_Boo)
		{
			reactionName = 'Boo';
		}
		
		arenaCrowdSize = parent.arenaCrowdEntites.Size();
		if(reactionName != 'None' && arenaCrowdSize > 0)
		{
			for(i = 0; i < arenaCrowdSize; i += 1)
			{
				
				crowdEntity = (CEntity)parent.arenaCrowdEntites[i];
				if(crowdEntity)
				{
					Sleep(RandF()*0.02);
					crowdEntity.RaiseForceEvent(reactionName);
				}
			}
		}
		if(reactionType == ACR_Boo)
		{
			parent.ThrowProjectiles();
		}
	}
}
class CArenaContainter extends CContainer
{
	var chosenPrizes : array<name>;
	
	//Chooses a random 3 prizes from the list specified in CArenaWave class
	function ChoosePrize(prizes : array<name>)
	{
		var i, prizesToChoose : int;
		var randPrize : int;
		var prizesArray : array<name>;
		
		prizesArray = prizes;
		
		prizesToChoose = 3;
	
		if(prizesArray.Size() >= prizesToChoose)
		{
			for(i = 0; i < prizesToChoose; i += 1)
			{
				randPrize = Rand(prizesArray.Size());
				chosenPrizes.PushBack(prizesArray[randPrize]);
				prizesArray.Erase(randPrize);
			}
			FillPrize();
		}
		else
		{
			//If we have < 3 prizes, we should clear the prize array (and we shouldn't show anything in the prize panel)
			ClearChosenPrizes();
		}
		
	}
	
	//Fills the container with actual items 
	function FillPrize()
	{
		var inventory : CInventoryComponent;
		var i : int;
		inventory = this.GetInventory();
		
		ClearArenaContainer();
		if(chosenPrizes.Size() > 0)
		{
			for(i = 0; i < chosenPrizes.Size(); i += 1)
			{
				inventory.AddItem(chosenPrizes[i], 1, false);
			}
		}
		ClearChosenPrizes();
	}
	
	//Removes all items from area container
	function ClearArenaContainer()
	{
		var inventory : CInventoryComponent;
		inventory = this.GetInventory();
		inventory.RemoveAllItems();
	}
	function ClearChosenPrizes()
	{
		chosenPrizes.Clear();
	}
}

//Arena door class is responsible for teleporting player to arena and triggering waves
class CArenaDoor extends CGameplayEntity
{
	var arenaManager : CArenaManager;
	var arenaContainer : CArenaContainter;
	//Show interaction
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( this, NAPK_Door );
		}
	}
	//Hide interaction
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( NULL );
		}
	}
	function EnableDoor(enable : bool)
	{
		this.GetComponentByClassName('CInteractionComponent').SetEnabled(enable);
	}
	event OnSpawned(spawn : SEntitySpawnData)
	{
		EnableDoor(false);
		super.OnSpawned(spawn);
	}
	//Start new wave on arena
	event OnInteraction( actionName : name, activator : CEntity )
	{	
		var currentWave : int;
		
		if ( activator == thePlayer )
		{
			arenaManager = (CArenaManager)theGame.GetNodeByTag('arena_manager');
			arenaContainer = (CArenaContainter)theGame.GetNodeByTag('arena_container');
			if(arenaManager && !theGame.IsActivelyPaused())
			{
				arenaManager.ConnectToArenaCrowd();
				currentWave = arenaManager.currentWave;
				
				if(arenaManager.currentWaveText >= arenaManager.totalWavesQuantity)
				{
					//After waive loop, arena chooses predefined "global" prizes
					if(!theGame.GetArenaManager().GetRewardWasRandomized())
					{
						arenaManager.InitAfterLoopPrizes();
						arenaContainer.ChoosePrize(arenaManager.afterLoopPrizes);
					}
				}
				else
				{
					//Before waive loop, arena chooses prizes defined in waive descriptions
					if(!theGame.GetArenaManager().GetRewardWasRandomized())
					{
						arenaContainer.ChoosePrize(arenaManager.arenaWaves[currentWave].prizes);
					}
				}
				this.GetComponentByClassName('CInteractionComponent').SetEnabled(false);
				theGame.EnableButtonInteractions(false);
				theGame.FadeOutAsync(0.5);
				AddTimer('TimerShowArena', 0.5);
				//thePlayer.ChangePlayerState(PS_CombatSteel);
			}
		}
	}
	timer function TimerShowArena(td : float)
	{
		theHud.ShowArena();
	}
}
//Arena data
struct SStartPanelData
{
	var waiveNumber : int;
	
	var points : int;
	
	var killedEnemies : int;
	
	var time : string;
	
	var oppNamesRound1 : array<string>;
	var oppNumRound1 : array<int>;
	
	var oppNamesRound2 : array<string>;
	var oppNumRound2 : array<int>;
	
	var oppNamesRound3 : array<string>;
	var oppNumRound3 : array<int>;
	
	var bonusTime : string;
	
	var waiveInitialPoints : int;
	
	var waiveBonusPoints : int;
	
	var gold : int;
	
	var totalPoints : int;
	
};

enum EArenaCrowdReactionType
{
	ACR_Start,
	ACR_Boo,
	ACR_Win,
	ACR_Failed,
	ACR_Finisher,
	ACR_Kill,
	ACR_Sign,
	ACR_Chant
};
enum EArenaMusicType
{
	AMT_Music1,
	AMT_Music2,
	AMT_Music3,
	AMT_Music4,
	AMT_Music5
};
//Arena manager class responsible for arena gameplay
class CArenaManager extends CGameplayEntity
{

	editable var mageFollowerTemplate : CEntityTemplate;
	editable var dwarfFollowerTemplate : CEntityTemplate;
	editable var knightFollowerTemplate : CEntityTemplate;
	//Array responsible for all wave definitions
	editable inlined var arenaWaves : array<CArenaWave>;
	//Current wave numver
	var currentWave : int;
	var currentWaveText : int;
	//total player score
	var playerScore : int;
	//Tier is incremented when currentWave > totalWavesQuantity, it's used to loop waves
	var tierNumber : int;
	
	//Wingman tier is incremented after certain amount of waves, it's used to increase wingmen combat abilities.
	var wingmanTier : int;
	//spawnNodes
	var spawnNodes : array<CNode>;
	editable var maxTierNumer : int;
	editable var maxWingmanTier : int;
	editable var changeWingmanTierWave: int;
	
	//Total defined waves
	var totalWavesQuantity : int;
	
	var playerWaveTotalScore : int;
	var playerWaveBonusTime : int;
	var playerWaveBonusScore : int;
	
	var opponentsNamesRound1 : array<string>;
	var opponentsNumRound1 : array<int>;
	
	var opponentsNamesRound2 : array<string>;
	var opponentsNumRound2 : array<int>;
	
	var opponentsNamesRound3 : array<string>;
	var opponentsNumRound3 : array<int>;
	
	var temporaryNpc : CNewNPC;
	
	var startPanelData : SStartPanelData;
	
	var afterLoopPrizes : array<name>;
	
	var roundStart, isFighting : bool;
	
	var arenaReactionCooldown : float;
	
	var waiveTime : int;
	
	var winFact : string;
	
	var killedWaveEnemies, totalKilledEnemies : int;
	
	var lastArenaReaction, lastPlayerAttack : EngineTime;
	
	var arenaCrowdManager : CArenaCrowdManager;
	
	var bonusStyleScore : float;
	
	var rewardWasRandomized : bool;
	
	var playerWasDead : bool;
	
	var playerIsCheating : bool;
	
	default arenaReactionCooldown = 1.0f;
	default playerWaveTotalScore = 0;
	default playerWaveBonusTime = 0;
	default playerWaveBonusScore = 0;
	default playerScore = 0;
	default currentWave = 0;
	default currentWaveText = 0;
	default tierNumber = 0;
	default waiveTime = 0;
	default killedWaveEnemies = 0;
	default totalKilledEnemies = 0;
	
	
	function SetPlayerCheated(flag : bool)
	{
		playerIsCheating = flag;
	}
	
	function GetPlayerCheated() : bool
	{
		return playerIsCheating;
	}
	
	function CheckPlayerCheat(opponent : CActor)
	{
		var damageMax : float;
		var vitalityMax : float;
		var armorMax : float;
		var maxQuenTime : float;
		
		
		var playerDamage : float;
		var playerVit : float;
		var playerArmor : float;
		var playerQuenTime : float;
		
		var opponentVitalityMin : float;
		var opponentDamageMin : float;
		
		var oppVit : float;
		var oppDam : float;
		
		oppVit = opponent.GetCharacterStats().GetAttribute('vitality');
		oppDam = opponent.GetCharacterStats().GetAttribute('damage_max');
		
		playerDamage = thePlayer.GetCharacterStats().GetAttribute('damage_max');
		playerVit = thePlayer.GetCharacterStats().GetAttribute('vitality');
		playerArmor = thePlayer.GetCharacterStats().GetAttribute('damage_reduction');
		playerQuenTime = thePlayer.GetCharacterStats().GetAttribute('quen_duration');
		
		if(opponent.GetMonsterType() == MT_Nekker)
		{
			opponentVitalityMin = 25;
			opponentDamageMin = 10;
		}
		else if(opponent.GetMonsterType() == MT_Endriaga)
		{
			opponentVitalityMin = 50;
			opponentDamageMin = 10;
		}
		else if(opponent.GetMonsterType() == MT_Rotfiend)
		{
			opponentVitalityMin = 125;
			opponentDamageMin = 20;
		}
		else if(opponent.GetMonsterType() == MT_Troll)
		{
			opponentVitalityMin = 400;
			opponentDamageMin = 40;
		}		
		else if(opponent.GetMonsterType() == MT_Wraith)
		{
			opponentVitalityMin = 175;
			opponentDamageMin = 20;
		}
		else if(opponent.GetMonsterType() == MT_Golem)
		{
			opponentVitalityMin = 375;
			opponentDamageMin = 40;
		}
		else if(opponent.GetMonsterType() == MT_Gargoyle)
		{
			opponentVitalityMin = 275;
			opponentDamageMin = 50;
		}
		else if(opponent.GetMonsterType() == MT_Elemental)
		{
			opponentVitalityMin = 900;
			opponentDamageMin = 80;
		}
		else if(opponent.GetMonsterType() == MT_Drowner)
		{
			opponentVitalityMin = 60;
			opponentDamageMin = 15;
		}
		else
		{
			opponentVitalityMin = 20;
			opponentDamageMin = 5;
		}
		
		damageMax = 300;
		vitalityMax = 1500;
		armorMax = 150;
		maxQuenTime = 300; 
		
		if(playerDamage > damageMax)
		{
			SetPlayerCheated(true);
		}
		if(playerVit > vitalityMax)
		{
			SetPlayerCheated(true);
		}
		if(playerArmor > armorMax)
		{
			SetPlayerCheated(true);
		}
		if(playerQuenTime > maxQuenTime)
		{
			SetPlayerCheated(true);
		}
		if(oppVit < opponentVitalityMin)
		{
			SetPlayerCheated(true);
		}
		if(oppDam < opponentDamageMin)
		{
			SetPlayerCheated(true);
		}
	}
	
	function GetWasPlayerDead() : bool
	{
		return playerWasDead;
	}
	
	function SetWasPlayerDead(flag : bool)
	{
		playerWasDead = flag;
	}
	
	function GetIsFighting() : bool
	{
		return isFighting;
	}
	function SetCurrentWave(wave : int, waveText : int)
	{
		currentWave = wave;
		currentWaveText = waveText;
	}
	function SetRewardWasRandomized(wasRandomized : bool)
	{
		rewardWasRandomized = wasRandomized;
	}
	function GetRewardWasRandomized() : bool
	{
		return rewardWasRandomized;
	}
	function ConnectToArenaCrowd()
	{
		arenaCrowdManager = (CArenaCrowdManager)theGame.GetNodeByTag('arena_crowd_manager');
		arenaCrowdManager.GatherCrowd();
	}
	
	function HasArenaWingman() : bool
	{
		if(FactsQuerySum("arena_dwarf") >= 1 || FactsQuerySum("arena_knight") >= 1 ||FactsQuerySum("arena_mage") >= 1)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	timer function TimerStartFight(td : float)
	{
		StartCurrentWave();
		theSound.UpdateParameter( "health_sts", thePlayer.GetHealth() / thePlayer.GetInitialHealth() );
		theSound.PlayMusic(GetArenaMusic());
		UpdateArenaHUD(true);
		//arenaManager.ShowArenaHUD(false);
		SetRoundStart(true);
		SetIsFighting(true);
		ShowArenaHUD(true);
	}
	
	//Initialize arena
	function InitArena()
	{
		var i : int;
		var startPoint : CNode;
		
		currentWave = 0;
		currentWaveText = 0;
		
		playerScore = 0;
		playerWaveTotalScore = 0;
		playerWaveBonusTime = 0;
		playerWaveBonusScore = 0;
		
		tierNumber = 0;
		waiveTime = 0;
		totalKilledEnemies = 0;
		killedWaveEnemies = 0;
		
		totalWavesQuantity = arenaWaves.Size();
		
		for(i = 0; i < totalWavesQuantity; i += 1)
		{
			arenaWaves[i].InitWave(this);
		}
		startPoint = theGame.GetNodeByTag('player_start_point');
		theGame.SetPlayerOnArena(true, this);

		//theSound.PlayMusic("prep_room");
		
		InitAfterLoopPrizes();
		InitArenaHUD();
	}
	function AddBonusPoints(points : float)
	{
		var AS_ArenaHUD : int;
		var totalPoints : float;
		var intTotalPoints : int;
		
		if(GetWasPlayerDead())
		{
			return;
		}
		
		totalPoints = points*GetDifficultyPointsMult()*(currentWaveText + 1);
		intTotalPoints = RoundF(totalPoints);
		if ( ! theHud.GetObject( "mHUDArena", AS_ArenaHUD ) )
		{
			Log( "No mHUDArena found at the Scaleform side!" );
		}
		theHud.SetFloat("AddPoints", intTotalPoints, AS_ArenaHUD);
		bonusStyleScore += intTotalPoints;
		//theHud.Invoke( "Commit", AS_ArenaHUD );
		theHud.Invoke("pHUD.AddPoints");
		UpdateArenaHUD(false);
		theSound.PlaySound("gui/arena_jingles/points_msg");
	}
	function RemoveAllTraps()
	{
		var traps : array<CNode>;
		var trap : CEntity;
		var i : int;
		
		theGame.GetNodesByTag('trap', traps);
		
		for( i = 0; i < traps.Size(); i += 1 )
		{
			trap = (CEntity)traps[i];
			trap.Destroy();
		}
		
	}
	function GetWinFact() : string
	{
		return winFact;
	}
	function SetWinFact(win : string)
	{
		winFact = win;
	}
	function ResetSpawnedOpponents()
	{
		var opponents, followers : array<CNode>;
		var opponent : CActor;
		var i, size : int;
		var followerNPC : CNewNPC;
		theGame.GetNodesByTag('arena_opponent', opponents);
	
		size = opponents.Size();
		for( i = 0; i < size; i += 1)
		{
			opponent = (CActor)opponents[i];
			if(opponent)
			{
				opponent.Destroy();
			}
		}
		
		GetCurrentWave().GetCurrentRound().ClearSpawnedOpponents();
		
		theGame.GetNodesByTag('arena_wingman', followers);
		
		for(i = 0; i < followers.Size(); i += 1)
		{
		
			followerNPC = (CNewNPC)followers[i];
	
			followerNPC.Destroy();
		}
	}
	function InitArenaHUD()
	{
		var AS_ArenaHUD : int;
		var arguments : array<CFlashValueScript>;
		if ( ! theHud.GetObject( "mHUDArena", AS_ArenaHUD ) )
		{
			Log( "No mHUDArena found at the Scaleform side!" );
		}
		theHud.SetBool("ArenaExist", true, AS_ArenaHUD);
		theHud.Invoke( "Commit", AS_ArenaHUD );
		UpdateArenaHUD(false);
		ShowArenaHUD(false);
	}
	
	function ResetRounds()
	{
		
		GetCurrentWave().ResetRoundNumber();
	}
	
	function GetArenaMusic() : string
	{
		if(GetCurrentWave().arenaMusicType == AMT_Music1)
		{
			return "arena_1";
		}
		else if(GetCurrentWave().arenaMusicType == AMT_Music2)
		{
			return "arena_2";
		}
		else if(GetCurrentWave().arenaMusicType == AMT_Music3)
		{
			return "arena_3";
		}
		else if(GetCurrentWave().arenaMusicType == AMT_Music4)
		{
			return "arena_4";
		}
		else if(GetCurrentWave().arenaMusicType == AMT_Music5)
		{
			return "arena_5";
		}
		else
		{
			return "arena_1";
		}
	}
	function InitAfterLoopPrizes()
	{
		var inventory : CInventoryComponent;
		inventory = thePlayer.GetInventory();
		afterLoopPrizes.Clear();
		
		if(!inventory.HasItem('Elemental Trophy'))
			afterLoopPrizes.PushBack('Elemental Trophy');
		
		if(!inventory.HasItem('Unique Silver Meteorite Sword'))
			afterLoopPrizes.PushBack('Unique Silver Meteorite Sword');
		
		if(!inventory.HasItem('Unique Essenced Pants'))
			afterLoopPrizes.PushBack('Unique Essenced Pants');
		
		if(!inventory.HasItem('Mutagen of Concentration'))
			afterLoopPrizes.PushBack('Mutagen of Concentration');
		
		if(!inventory.HasItem('Sorccerer Gloves'))
			afterLoopPrizes.PushBack('Sorccerer Gloves');
		
		if(!inventory.HasItem('Dhu Bleidd'))
			afterLoopPrizes.PushBack('Dhu Bleidd');
			
		if(!inventory.HasItem('Ysgith Armor'))
			afterLoopPrizes.PushBack('Ysgith Armor');
		
		if(!inventory.HasItem('Vran Armor'))
			afterLoopPrizes.PushBack('Vran Armor');
			
		if(!inventory.HasItem('Addan deith'))	
			afterLoopPrizes.PushBack('Addan deith');
		
		if(!inventory.HasItem('Forgotten Sword of Vrans'))	
			afterLoopPrizes.PushBack('Forgotten Sword of Vrans');
		
		if(!inventory.HasItem('Unique Leather Boots of Elder Blood'))	
			afterLoopPrizes.PushBack('Unique Leather Boots of Elder Blood');
			
		if(!inventory.HasItem('Caerme'))	
			afterLoopPrizes.PushBack('Caerme');
			
		if(!inventory.HasItem('Unique Leather Pants of Elder Blood'))
			afterLoopPrizes.PushBack('Unique Leather Pants of Elder Blood');
			
		if(!inventory.HasItem('Unique Leather Gloves of Elder Blood'))
			afterLoopPrizes.PushBack('Unique Leather Gloves of Elder Blood');
			
		if(!inventory.HasItem('W_OperatorStaff'))
			afterLoopPrizes.PushBack('W_OperatorStaff');
		
		afterLoopPrizes.PushBack('Rune of Ysgith');
		afterLoopPrizes.PushBack('Rune of Fire');
		afterLoopPrizes.PushBack('Rune of Moon');
		afterLoopPrizes.PushBack('Rune of Earth');
		afterLoopPrizes.PushBack('Rune of Sun');
		
		afterLoopPrizes.PushBack('Mutagen of Mutagen of Insanity');
		afterLoopPrizes.PushBack('Major Mutagen of Strength');
		afterLoopPrizes.PushBack('Major Mutagen of Vitality');
		afterLoopPrizes.PushBack('Major Mutagen of Power');
		afterLoopPrizes.PushBack('Major Mutagen of Critical Effect');
		afterLoopPrizes.PushBack('Major Mutagen of Amplification');
		afterLoopPrizes.PushBack('Diamond Armor Enhancement');
		afterLoopPrizes.PushBack('Steel Plate Enhancement');
		afterLoopPrizes.PushBack('Mystic Armor Enhancement');
		afterLoopPrizes.PushBack('Unique Whetstone');
		

		

	}
	function ShowArenaHUD(hudVisible : bool)
	{
		var arguments : array<CFlashValueScript>;
		arguments.Clear();
		arguments.PushBack(FlashValueFromBoolean(false));
		arguments.PushBack(FlashValueFromBoolean(hudVisible));
		arguments.PushBack(FlashValueFromBoolean(roundStart && hudVisible));
		arguments.PushBack(FlashValueFromBoolean(isFighting && hudVisible && !GetWasPlayerDead()));
		arguments.PushBack(FlashValueFromBoolean(hudVisible));
		theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);
	}
	
	function SetIsFighting(flag : bool)
	{
		isFighting = flag;
	}
	function SetRoundStart(flag : bool)
	{
		roundStart = flag;
	}
	timer function TimerUpdateArenaHud(td : float)
	{
		var audioLang, textLang : string;
		
		
		UpdateArenaHUD(false);
		
		if ( Rand(20) < 5 && ( thePlayer.GetCurrentPlayerState() == PS_CombatSteel || thePlayer.GetCurrentPlayerState() == PS_CombatSilver ) )
		{
			theGame.GetGameLanguageName(audioLang, textLang);
			PlaySoundLoc("dlc_arena/global_arena_crowd/crowd_cries/arena_enthusiasm",audioLang);
		}
	}
	function UpdateArenaHUD(animateTimer : bool)
	{
		var AS_ArenaHUD : int;
		var arguments : array<CFlashValueScript>;
		var playerScoreTxt : int;
		var orensNum : int;
		var timerFrame : int;
		if ( ! theHud.GetObject( "mHUDArena", AS_ArenaHUD ) )
		{
			Log( "No mHUDArena found at the Scaleform side!" );
		}
		theHud.SetFloat("Points", CalculateTotalWaveScore(), AS_ArenaHUD);	

		orensNum = thePlayer.GetInventory().GetItemQuantityByName( 'Orens' );
		theHud.SetFloat("TotalOrens", orensNum, AS_ArenaHUD);
		playerScoreTxt = playerScore;
		theHud.SetFloat("TotalPoints", playerScoreTxt, AS_ArenaHUD);
		theHud.SetFloat("Waive", GetCurrentWaveText(), AS_ArenaHUD);
		theHud.SetFloat("Round", GetCurrentWave().GetCurrentRoundText(), AS_ArenaHUD);
		if(animateTimer)
		{
			timerFrame = TimerAnimation();
			theHud.SetFloat("TimerFrame", timerFrame, AS_ArenaHUD);
		}
		
		/*arguments.PushBack(FlashValueFromBoolean(false));
		arguments.PushBack(FlashValueFromBoolean(hudVisible));
		arguments.PushBack(FlashValueFromBoolean(roundStart));
		arguments.PushBack(FlashValueFromBoolean(onArena));
		theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);*/
		theHud.Invoke( "Commit", AS_ArenaHUD );
	}
	
	function ClearArenaHUD()
	{
		var AS_ArenaHUD : int;
		var arguments : array<CFlashValueScript>;
		var playerScoreTxt : int;
		var orensNum : int;
		if ( ! theHud.GetObject( "mHUDArena", AS_ArenaHUD ) )
		{
			Log( "No mHUDArena found at the Scaleform side!" );
		}
		theHud.SetFloat("Points", CalculateTotalWaveScore(), AS_ArenaHUD);	

		orensNum = thePlayer.GetInventory().GetItemQuantityByName( 'Orens' );
		theHud.SetFloat("TotalOrens", orensNum, AS_ArenaHUD);
		playerScoreTxt = playerScore;
		theHud.SetFloat("TotalPoints", playerScoreTxt, AS_ArenaHUD);
		theHud.SetFloat("Waive", 0, AS_ArenaHUD);
		theHud.SetFloat("Round", 0, AS_ArenaHUD);
		/*arguments.PushBack(FlashValueFromBoolean(false));
		arguments.PushBack(FlashValueFromBoolean(hudVisible));
		arguments.PushBack(FlashValueFromBoolean(roundStart));
		arguments.PushBack(FlashValueFromBoolean(onArena));
		theHud.InvokeManyArgs("pHUD.ArenaHUDController", arguments);*/
		theHud.Invoke( "Commit", AS_ArenaHUD );
	}
	
	
	//Returns tier number - used for adding new abilities for opponents
	function GetTierNumber() : int
	{
		return tierNumber;
	}
	
	//Panel data - for UI purposes
	function GetStartPanelData() : SStartPanelData
	{
		return startPanelData;
	}
	
	//Utility function for array filling
	function FillArrayInt(element : int, out arrayToFill : array<int>)
	{
		var i : int;
		for(i = 0; i < arrayToFill.Size(); i += 1)
		{
			arrayToFill[i] = element;
		}
	}
	
	//Utility function for array filling
	function FillArrayString(element : string, out arrayToFill : array<string>)
	{
		var i : int;
		for(i = 0; i < arrayToFill.Size(); i += 1)
		{
			arrayToFill[i] = element;
		}
	}
	function SetStartPanelData(spawnOpponents : bool)
	{
		var i, j, waveRoundsSize, oppSize : int;
		var tempNPCSpawnPoint : Vector;
		var tempNPCRotation : EulerAngles;
		var opponents : SOpponentDefinition;

		if(spawnOpponents)
		{
			//Temporary NPC spawn point 
			tempNPCSpawnPoint = Vector(0, 0, 0);

			opponentsNamesRound1.Resize(3);
			FillArrayString("", opponentsNamesRound1);
			opponentsNumRound1.Resize(3);
			FillArrayInt(0, opponentsNumRound1);
		
			opponentsNamesRound2.Resize(3);
			FillArrayString("", opponentsNamesRound2);
			opponentsNumRound2.Resize(3);
			FillArrayInt(0, opponentsNumRound2);
		
			opponentsNamesRound3.Resize(3);
			FillArrayString("", opponentsNamesRound3);
			opponentsNumRound3.Resize(3);
			FillArrayInt(0, opponentsNumRound3);
			
			waveRoundsSize = arenaWaves[currentWave].waveRounds.Size();
			
			//Maximum number of rounds defined in single wave is 3
			if(waveRoundsSize > 3)
			{
				waveRoundsSize = 3;
			}
			
			for (i = 0; i < waveRoundsSize; i += 1)
			{
				oppSize = arenaWaves[currentWave].waveRounds[i].definedOpponents.Size();
				
				//Maximum number of opponents that can be defined in a round is 3
				if(oppSize > 3)
				{
					oppSize = 3;
				}
				
				for(j = 0; j < oppSize; j += 1)
				{
					opponents = arenaWaves[currentWave].waveRounds[i].definedOpponents[j];
					if(i == 0)
					{
						temporaryNpc = (CNewNPC)theGame.CreateEntity(opponents.template, tempNPCSpawnPoint, tempNPCRotation);
						opponentsNamesRound1[j] = temporaryNpc.GetDisplayName();
						opponentsNumRound1[j] = opponents.quantity;
						temporaryNpc.Destroy();
					}
					else if(i == 1)
					{
						temporaryNpc = (CNewNPC)theGame.CreateEntity(opponents.template, tempNPCSpawnPoint, tempNPCRotation);
						opponentsNamesRound2[j] = temporaryNpc.GetDisplayName();
						opponentsNumRound2[j] = opponents.quantity;
						temporaryNpc.Destroy();
					}
					else if(i == 2)
					{
						temporaryNpc = (CNewNPC)theGame.CreateEntity(opponents.template, tempNPCSpawnPoint, tempNPCRotation);
						opponentsNamesRound3[j] = temporaryNpc.GetDisplayName();
						opponentsNumRound3[j] = opponents.quantity;
						temporaryNpc.Destroy();
					}
				}
			}
		}
		//Fill waive number data
		startPanelData.waiveNumber = GetCurrentWaveText();
		
		//Fill opponents data
		startPanelData.oppNamesRound1 = opponentsNamesRound1;
		startPanelData.oppNumRound1 = opponentsNumRound1;
	
		startPanelData.oppNamesRound2 = opponentsNamesRound2;
		startPanelData.oppNumRound2 = opponentsNumRound2;
		
		startPanelData.oppNamesRound3 = opponentsNamesRound3;
		startPanelData.oppNumRound3 = opponentsNumRound3;
		

		startPanelData.killedEnemies = killedWaveEnemies;
		
		
		
		if(GetWasPlayerDead())
		{
			startPanelData.time = 0;
			startPanelData.waiveInitialPoints = 0;
			startPanelData.points = 0;
			startPanelData.waiveBonusPoints = 0;
			startPanelData.bonusTime = 0;
		}
		else
		{
			startPanelData.time = GetStringTime(waiveTime);
			startPanelData.waiveInitialPoints = RoundF((arenaWaves[currentWave].wavePoints + GetTierWavePoints()) * GetDifficultyPointsMult());
			startPanelData.points = playerWaveTotalScore;
			startPanelData.waiveBonusPoints = RoundF((arenaWaves[currentWave].waveBonusPoints + GetTierBonusPoints())* GetDifficultyPointsMult());
			startPanelData.bonusTime = GetStringTime(RoundF(arenaWaves[currentWave].waveBonusTime*GetDifficultyTimeMult()));
		}
		
		startPanelData.gold = GetCurrentWave().goldForWin;
		startPanelData.totalPoints = playerScore;
		
	}
	function GetStringTime(time : int) : string
	{
		var minutes, seconds : int;
		var sMinutes, sSeconds : string;
		
		minutes = time / 60;
		seconds = time % 60;
		if(minutes < 10)
		{
			sMinutes = "0" + IntToString(minutes);
		}
		else
		{
			sMinutes = IntToString(minutes);
		}
		if(seconds < 10)
		{
			sSeconds = "0" + IntToString(seconds);
		}
		else
		{
			sSeconds = IntToString(seconds);
		}
		return sMinutes + ":" + sSeconds;

	}
	function SetLastPlayerAttack()
	{
		lastPlayerAttack = theGame.GetEngineTime();
	}
	function GetLastPlayerAttack() : EngineTime
	{
		return lastPlayerAttack;
	}
	function StopChantSounds()
	{
		theSound.StopSoundByNameWithFade("dlc_arena/global_arena_crowd/crowd_chant_loop");
		theSound.StopSoundByNameWithFade("dlc_arena/global_arena_crowd/crowd_chant_loop_background");
		RemoveTimer('TimerPlayChantCommentart');
	}
	function GetSoundNode() : CNode
	{
		var i, size : int;
		var nodesArray : array<CNode>;
		
		theGame.GetNodesByTag('arenaSoundNode', nodesArray);
		
		size = nodesArray.Size();
		
		i = Rand(size);
		
		return nodesArray[i];
	}
	
	timer function TimerPlayChantCommentart( td : float )
	{
		var audioLang, textLang : string;
		
		theGame.GetGameLanguageName(audioLang, textLang);
		PlaySoundLocOnNode(GetSoundNode(), "dlc_arena/global_arena_crowd/crowd_cries/arena_oneleft", audioLang);
	}
	
	function ArenaCrowdReaction(reactionType : EArenaCrowdReactionType)
	{
		var audioLang, textLang : string;
		
		theGame.GetGameLanguageName(audioLang, textLang);
		
		if(reactionType == ACR_Failed)
		{
			theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 2);
			arenaCrowdManager.CrowdReactionAnim(ACR_Boo);
		}
		else if(reactionType == ACR_Win)
		{
			//theHud.m_messages.ShowActText("WIN!" );
			theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 1);
			arenaCrowdManager.CrowdReactionAnim(ACR_Win);
		}
		else if(reactionType == ACR_Chant)
		{
			StopChantSounds();
			
			if(Rand(4) == 1)
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction_background", "arena_reaction", 3);
				RemoveTimer('TimerPlayChantCommentart');
				AddTimer('TimerPlayChantCommentart', 3 + Rand(4), true);
				theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_chant_loop_background");
			}
			else
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 3);
				theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_chant_loop");
			}
				arenaCrowdManager.CrowdReactionAnim(ACR_Win);
			
		}
		arenaReactionCooldown = 5.0;
		if(theGame.GetEngineTime() < lastArenaReaction + arenaReactionCooldown)
		{
			return;
		}
		//dlc_arena/global_arena_crowd/crowd_chant_loop
		//dlc_arena/global_arena_crowd/crowd_stomping
		
		lastArenaReaction = theGame.GetEngineTime();
		
		if(reactionType == ACR_Kill)
		{
			//theHud.m_messages.ShowActText("CHEER!" );
		
			arenaCrowdManager.CrowdReactionAnim(ACR_Win);
			
			if(Rand(4) == 1)
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction_background", "arena_reaction", 3);
				PlaySoundLocOnNode(GetSoundNode(), "dlc_arena/global_arena_crowd/crowd_cries/arena_enthusiasm",audioLang);
			}
			else
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 3);
			}
			
		}
		else if(reactionType == ACR_Boo)
		{
			//theHud.m_messages.ShowActText("BOOO!" );
			
			if(Rand(4) == 1)
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction_background", "arena_reaction", 4);
				PlaySoundLocOnNode(GetSoundNode(), "dlc_arena/global_arena_crowd/crowd_cries/arena_lazy", audioLang);
				//theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_boo_background");
			}
			else
			{
				theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 4);
				//theSound.PlaySound("dlc_arena/global_arena_crowd/crowd_boo");
			}
			
			StopChantSounds();
			arenaCrowdManager.CrowdReactionAnim(ACR_Boo);
			
		}
		else if(reactionType == ACR_Sign)
		{

			theSound.PlaySoundWithParameter("dlc_arena/global_arena_crowd/crowd_reaction", "arena_reaction", 5);
			arenaCrowdManager.CrowdReactionAnim(ACR_Win);
		}
	}
	
	//Ends current wave
	function EndCurrentWave()
	{
		var waiveTimeInMinutes : int;
		
		waiveTimeInMinutes = waiveTime / 60;
		
		if(thePlayer.IsAlive())
		{
			if(FactsQuerySum(GetWinFact()) < 1)
			{
				FactsAdd(GetWinFact(), 1);
			}
			playerWaveTotalScore = CalculateTotalWaveScore();
			playerScore += playerWaveTotalScore;
			thePlayer.AddOrens(GetCurrentWave().goldForWin);
			//theGame.EnableButtonInteractions(true);
			ShowWaveEndInformation();
			theHud.ArenaFollowersGuiHealth( 100 );
			UpdateArenaHUD(false);
			theSound.PlaySound("gui/arena_jingles/end_wave");
			if(!thePlayer.CanUseHud())
			{
				thePlayer.SetCanUseHud(true);
			}
			
			theServer.ArenaLogWave( currentWaveText + 1, playerWaveTotalScore,  waiveTimeInMinutes);
			
			theHud.ShowArenaEnd();
			currentWave += 1;
			currentWaveText += 1;
			
			if(currentWave >= totalWavesQuantity)
			{
				currentWave = 0;
				//tierNumber += 1;
			}
			//if(currentWaveText + 1 % changeWingmanTierWave == 0)
			//{
				//if(wingmanTier < maxWingmanTier)
				//{
				//	wingmanTier += 1;
				//}
			//}
			thePlayer.RemoveCriticalEffects();
			thePlayer.RemoveQuen();
			SetRewardWasRandomized(false);
			RemoveAllTraps();
			//SetStartPanelData();
		}
	}
	function GetTierWavePoints() : float
	{
		var maxWaveNumber : int;
		maxWaveNumber = arenaWaves.Size() - 1;
		if(maxWaveNumber >= 0)
		{
			return tierNumber*arenaWaves[maxWaveNumber].wavePoints;
		}
		else
		{
			return 0.0f;
		}
	}
	function GetTierBonusPoints() : float
	{	
		var maxWaveNumber : int;
		maxWaveNumber = arenaWaves.Size() - 1;
		if(maxWaveNumber >= 0)
		{
			return tierNumber*arenaWaves[maxWaveNumber].waveBonusPoints;
		}
		else
		{
			return 0.0f;
		}
		
	}
	function ShowWaveEndInformation()
	{
		var currentWaveText : int;
		SetRoundStart(false);
		SetIsFighting(false);
		ShowArenaHUD(true);
		//UpdateArenaHUD();
		//currentWaveText = GetCurrentWaveText();
		//theHud.Invoke("pHUD.hideArenaHUD");
		//theHud.m_messages.ShowInformationText("Wave score: " + playerWaveTotalScore + "  /  Total score: " + playerScore);
		//theHud.m_messages.ShowActText("Wave "+ currentWaveText+ " completed" );
		//theHud.InvokeOneArg("pHUD.setPointsNumber", FlashValueFromInt(playerScore));
		
	}
	//Starts new wave
	function StartCurrentWave()
	{
		SetWinFact("");
		waiveTime = 0;
		//UpdateArenaHUD();
		if(spawnNodes.Size() <= 0)
		{
			theGame.GetNodesByTag('spawnPointNode', spawnNodes);
		}
		//SetStartPanelData();
		//FactsAdd("fight_started", 1);
		
		wingmanTier = currentWaveText / changeWingmanTierWave;
		if(wingmanTier > maxWingmanTier)
		{
			wingmanTier = maxWingmanTier;
		}
		
		tierNumber = currentWaveText / totalWavesQuantity;
		
		if(tierNumber > maxTierNumer)
		{
			tierNumber = maxTierNumer;
		}
		
		playerWaveBonusTime = RoundF(arenaWaves[currentWave].waveBonusTime * GetDifficultyTimeMult());
		arenaWaves[currentWave].StartThisWave();
		killedWaveEnemies = 0;
		bonusStyleScore = 0;
		
	}
	function GetSpawnNodes() : array<CNode>
	{
		return spawnNodes;
	}
	function GetCurrentWave() : CArenaWave
	{
		return arenaWaves[currentWave];
	}
	function GetCurrentWaveText() : int
	{
		return currentWaveText + 1;
	}
	function TimerAnimation() : int
	{
		var frameNumber, returnFrameNumber : int;
		var maxFrameNumber, minFrameNumber : int;
		var floatFrameNumber : float;
		var maxBonusTime : int;
		
		maxBonusTime = RoundF(arenaWaves[currentWave].waveBonusTime * GetDifficultyTimeMult());
		
		minFrameNumber = 1;
		maxFrameNumber = 37;
		
		floatFrameNumber = (float)maxFrameNumber - ((playerWaveBonusTime*maxFrameNumber)/maxBonusTime);
		
		frameNumber = RoundF(floatFrameNumber);
		
		if(frameNumber < minFrameNumber)
		{
			frameNumber = minFrameNumber;
		}
		else if(frameNumber > maxFrameNumber)
		{
			frameNumber = maxFrameNumber;
		}
		return frameNumber;
	}
	timer function TimerWaveBonusTime(td : float)
	{
		waiveTime += 1;
		if(playerWaveBonusTime > 0)
		{
			playerWaveBonusTime -= 1;
		}
		else
		{
			
			playerWaveBonusTime = 0;
		}
		//Arena reaction: boo, if player doesn't want to attack
		if(theGame.GetEngineTime() > GetLastPlayerAttack() + 10.0)
		{
			ArenaCrowdReaction(ACR_Boo);
			SetLastPlayerAttack();
		}
		
		playerWaveBonusScore = CalculateBonusScore();
		UpdateArenaHUD(true);
	}
	function CalculateBonusScore() : int
	{
		var bonusScore : int;
		var floatBonusScore, floatBonusTime, floatDefinedBonusScore, floatDefinedBonusTime : float;
		
		if(GetWasPlayerDead())
		{
			return 0;
		}
		
		floatDefinedBonusTime = (float)arenaWaves[currentWave].waveBonusTime;
		floatDefinedBonusTime = floatDefinedBonusTime*GetDifficultyTimeMult();
		floatDefinedBonusScore = (float)arenaWaves[currentWave].waveBonusPoints;
		floatBonusTime = (float)playerWaveBonusTime;
		
		if(arenaWaves[currentWave].waveBonusTime > 0)
		{
			//floatBonusScore = (floatDefinedBonusScore*floatBonusTime) / (floatDefinedBonusTime*GetDifficultyPointsMult());
			//bonusScore = RoundF((floatBonusScore + GetTierBonusPoints())*GetDifficultyPointsMult());
			
			floatBonusScore = ((floatDefinedBonusScore + GetTierBonusPoints())*GetDifficultyPointsMult()*floatBonusTime) / floatDefinedBonusTime;
			
			bonusScore = RoundF(floatBonusScore);
			
			//bonusScore += RoundF(bonusStyleScore*GetDifficultyPointsMult());
		}
		else
		{
			bonusScore = 0;
		}
		bonusScore += RoundF(bonusStyleScore);
		return bonusScore;
	}
	function CalculateTotalWaveScore() : int
	{
		var waveScore : int;
		var floatWavePoints : float;
		
		if(GetWasPlayerDead())
		{
			return 0;
		}

		floatWavePoints = (arenaWaves[currentWave].wavePoints + GetTierWavePoints())*GetDifficultyPointsMult();
		waveScore = CalculateBonusScore() + RoundF(floatWavePoints);
		return waveScore;
	}
	
	function GetDifficultyTimeMult() : float
	{
		var diff : int;
		diff = theGame.GetDifficultyLevel();
		//temp
		//return 1.0;
		

		if(diff == 0)
		{
			return 1.0;
		}
		else if(diff == 1)
		{
			return 1.0;
		}
		else if(diff == 2)
		{
			return 1.5;
		}
		else if(diff == 3)
		{
			return 1.5;
		}
		else if(diff == 4)
		{
			return 1.5;
		}
		else
		{
			return 1.0;
		}
	}
	function GetDifficultyPointsMult() : float
	{
		var diff : int;
		diff = theGame.GetDifficultyLevel();
		//temp
		//return 1.0;
		
		if(diff == 5)
		{
			return 0.25;
		}
		if(diff == 0)
		{
			return 0.5;
		}
		else if(diff == 1)
		{
			return 1.0;
		}
		else if(diff == 2)
		{
			return 2.0;
		}
		else if(diff == 3)
		{
			return 3.0;
		}
		else if(diff == 4)
		{
			return 3.0;
		}
		else
		{
			return 1.0;
		}
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		InitArena();
		ShowArenaHUD(false);
	}
	
}

enum EWaveType
{
	WT_Human,
	WT_Monster
};

//Arena wave class responsible for current wave definition and management
class CArenaWave extends CStateMachine
{
	editable inlined var waveRounds : array<CArenaWaveRound>;
	editable var prizes : array<name>;
	editable var wavePoints : int;
	editable var waveBonusTime : int;
	editable var waveBonusPoints : int;
	editable var goldForWin : int;
	editable var arenaMusicType : EArenaMusicType;
	editable var waveType : EWaveType;
	var totalRounds : int;
	var currentRoundNumber : int;
	var arenaManager : CArenaManager;	
	
	default arenaMusicType = AMT_Music1;
	
	function ResetRoundNumber()
	{
		currentRoundNumber = 0;
	}
	
	function InitWave(currentArenaManager : CArenaManager)
	{
		var i : int;
		
		//currentRoundNumber = 0;
		//wavePoints = 0;
		//waveBonusTime = 0;
		//waveBonusPoints = 0;
		
		totalRounds = waveRounds.Size();
		for(i = 0; i < totalRounds; i += 1)
		{
			waveRounds[i].InitRound(this, currentRoundNumber);
		}
		arenaManager = currentArenaManager;
	}
	function RoundEnded(waveRound : CArenaWaveRound)
	{
		if(thePlayer.IsAlive())
		{
			currentRoundNumber += 1;
			if(currentRoundNumber >= totalRounds)
			{
				currentRoundNumber = 0;
				EndThisWave();
			}
			else
			{
				//theGame.FadeInAsync(0.5);
				StartCurrentRound();
			}
		}
	}
	function GetCurrentRound() : CArenaWaveRound
	{
		return waveRounds[currentRoundNumber];
	}
	function StartCurrentRound()
	{
		arenaManager.SetLastPlayerAttack();
		if(currentRoundNumber > 0)
		{
			//showing arena hud between rounds
			arenaManager.UpdateArenaHUD(true);
			arenaManager.SetRoundStart(true);
			arenaManager.SetIsFighting(true);
			arenaManager.ShowArenaHUD(true);
			theSound.PlaySound("gui/arena_jingles/new_wave");
		}
		arenaManager.AddTimer('TimerWaveBonusTime', 1.0, true);
		waveRounds[currentRoundNumber].StartThisRound();
	}
	function GetCurrentRoundText() : int
	{
		return currentRoundNumber + 1;
	}
	function GetTotalRoundsNumber() : int
	{
		return totalRounds;
	}
	function GetWaveRoundsSize() : int
	{
		return waveRounds.Size();
	}
}
state Default in CArenaWave
{
	entry function StartThisWave()
	{
		var followerSpawnPoint : CNode;
		var followerSpawnPointRotation : EulerAngles;
		var followerSpawnPointPosition : Vector;
		var follower : CNewNPC;
		var i : int;
		var abilityName : name;
		var abilityString : string;
		//if(theHud.m_arena)
		//{
		//	theHud.m_arena.FillItems();
		//}
		
		//arena_follower
		
		followerSpawnPoint = theGame.GetNodeByTag('arena_follower');

		if(followerSpawnPoint)
		{
			followerSpawnPointRotation = followerSpawnPoint.GetWorldRotation();
			followerSpawnPointPosition = followerSpawnPoint.GetWorldPosition();
			if(FactsQuerySum("arena_knight") >= 1)
			{
				parent.arenaManager.SetWinFact("knight_win");
				//FactsRemove("arena_knight");
				follower = (CNewNPC)theGame.CreateEntity(parent.arenaManager.knightFollowerTemplate, followerSpawnPointPosition, followerSpawnPointRotation);
			}
			if(FactsQuerySum("arena_dwarf") >= 1)
			{
				parent.arenaManager.SetWinFact("dwarf_win");
				//FactsRemove("arena_dwarf");
				follower = (CNewNPC)theGame.CreateEntity(parent.arenaManager.dwarfFollowerTemplate, followerSpawnPointPosition, followerSpawnPointRotation);
			}
			if(FactsQuerySum("arena_mage") >= 1)
			{
				parent.arenaManager.SetWinFact("mage_win");
				//FactsRemove("arena_mage");
				follower = (CNewNPC)theGame.CreateEntity(parent.arenaManager.mageFollowerTemplate, followerSpawnPointPosition, followerSpawnPointRotation);
			}
			for(i = 1; i <= parent.arenaManager.wingmanTier; i += 1)
			{
				abilityString = "OppE_ArenaWingmanTier" + IntToString(i);
				abilityName = StringToName(abilityString);
				follower.GetCharacterStats().AddAbility(abilityName);
			}
		}
		if(parent.waveType == WT_Monster)
		{
			thePlayer.ChangePlayerState(PS_CombatSilver);
		}
		else
		{
			thePlayer.ChangePlayerState(PS_CombatSteel);
		}
		
		parent.StartCurrentRound();
	}
	entry function EndThisWave()
	{
		var currentWave : int;
		var arenaManager : CArenaManager;
		var arenaContainer : CArenaContainter;
		var followerNPC : CNewNPC;
		if(thePlayer.IsAlive())
		{
			arenaManager = parent.arenaManager;//(CArenaManager)theGame.GetNodeByTag('arena_manager');
			arenaContainer = (CArenaContainter)theGame.GetNodeByTag('arena_container');
			//parent.arenaManager.RemoveTimer('TimerWaveBonusTime');
			
			parent.arenaManager.ResetSpawnedOpponents();
			//Sleep(1.0);
			//theGame.FadeOut(1.5);
			arenaManager.StopChantSounds();
			//Sleep(2.0);
			//theGame.FadeOut(1.0);
			FactsAdd("arena_room", 1);
			
			//thePlayer.ChangePlayerState(PS_Exploration);
			//if(arenaManager)
			//{				
				//currentWave = arenaManager.currentWave;
				
				//if(arenaManager.currentWaveText >= arenaManager.totalWavesQuantity)
				//{
					//After waive loop, arena chooses predefined "global" prizes
					//arenaContainer.ChoosePrize(arenaManager.afterLoopPrizes);
				//}
				//else
				//{
					//Before waive loop, arena chooses prizes defined in waive descriptions
					//arenaContainer.ChoosePrize(arenaManager.arenaWaves[currentWave].prizes);
				//}
			//}
			//thePlayer.RemoveAllBuffs();
			thePlayer.RemoveQuen();
			parent.arenaManager.EndCurrentWave();
			theGame.GetArenaManager().UpdateArenaHUD(false);
		}
	}
}

//Arena wave round class responsible for current round definition and management
class CArenaWaveRound extends CStateMachine
{
	editable var definedOpponents : array< SOpponentDefinition >;
	var definedOpponentsNumber : int;
	var spawnedOpponents : array<CNewNPC>;
	var arenaWave : CArenaWave;
	var thisRoundNumber : int;
	var usedSpawnNodes : array<CNode>;
	
	function ClearSpawnedOpponents()
	{
		spawnedOpponents.Clear();
	}
	
	function InitRound(currentArenaWave : CArenaWave, currentRoundNumber : int)
	{
		arenaWave = currentArenaWave;
		thisRoundNumber = currentRoundNumber;
		definedOpponentsNumber = definedOpponents.Size();
	}
	function FindSpawnPoint(spawnLocation : EArenaSpawnLocation) : CNode
	{
		var spawnNodes, validSpawnNodes : array<CNode>;
		var arenaSpawnNode : CArenaSpawnNode;
		var i, nodesSize, validNodesSize, usedNodesSize : int;
		var shouldClearUsedNodes : bool;
		
		spawnNodes = arenaWave.arenaManager.GetSpawnNodes();
		nodesSize = spawnNodes.Size();
		
		if(spawnLocation == SpawnLocationRandom)
		{
			i = Rand(nodesSize);
			return spawnNodes[i];
		}
		else
		{
			for(i = 0; i < nodesSize; i += 1)
			{
				arenaSpawnNode = (CArenaSpawnNode)spawnNodes[i];
				if(arenaSpawnNode && arenaSpawnNode.GetSpawnLocation() == spawnLocation)
				{
					validSpawnNodes.PushBack(spawnNodes[i]);
				}
			}
			
			usedNodesSize = usedSpawnNodes.Size();
			shouldClearUsedNodes = true;
			
			for(i = 0; i < usedNodesSize; i += 1)
			{
				if(!validSpawnNodes.Contains(usedSpawnNodes[i]))
				{
					shouldClearUsedNodes = false;
				}
				else
				{
					validSpawnNodes.Remove(usedSpawnNodes[i]);
				}
			}
			if(shouldClearUsedNodes)
			{
				usedSpawnNodes.Clear();
			}
			validNodesSize = validSpawnNodes.Size();
			return validSpawnNodes[Rand(validNodesSize)];
		}
	}
	function RemoveKilledEnemy(enemy : CNewNPC)
	{
		var opponentsLeft : int;
		
		spawnedOpponents.Remove(enemy);
		opponentsLeft = spawnedOpponents.Size();
		
		arenaWave.arenaManager.killedWaveEnemies += 1;
		arenaWave.arenaManager.totalKilledEnemies += 1;
		
		if(opponentsLeft == 1)
		{
			arenaWave.arenaManager.ArenaCrowdReaction(ACR_Chant);
		}
		if(opponentsLeft <= 0)
		{
			arenaWave.arenaManager.StopChantSounds();
			arenaWave.arenaManager.RemoveTimer('TimerWaveBonusTime');
			if(thePlayer.IsAlive())
			{
				EndThisRound();
			}
		}
		else
		{
			arenaWave.arenaManager.ArenaCrowdReaction(ACR_Kill);
		}
	}
	function SpawnEnemies()
	{
		var spawnPoint : CNode;
		var i, j, n, k, opponentsQuant : int;
		var spawnedOpponent : CNewNPC;
		var tierNum : int;
		var characterStats : CCharacterStats;
		var abilities : array<name>;
		var abilityName : name;
		var tags : array<name>;
		var inventory : CInventoryComponent;
		var items : array<SItemUniqueId>;
		
		tierNum = arenaWave.arenaManager.GetTierNumber();
	
		for(i = 0; i < definedOpponentsNumber; i += 1)
		{
			opponentsQuant = definedOpponents[i].quantity;
			
			for(j = 0; j < opponentsQuant; j += 1)
			{
				spawnPoint = FindSpawnPoint(definedOpponents[i].spawnLocation);
				spawnedOpponent = (CNewNPC)theGame.CreateEntity(definedOpponents[i].template, spawnPoint.GetWorldPosition(), spawnPoint.GetWorldRotation());
				spawnedOpponent.NoticeActor(thePlayer);
				//spawnedOpponent.StartsWithCombatIdle(true);
				spawnedOpponents.PushBack(spawnedOpponent);
				
				tags = spawnedOpponent.GetTags();
				tags.PushBack('arena_opponent');
				spawnedOpponent.SetTags(tags);
				//inventory = spawnedOpponent.GetInventory();
				//inventory.GetAllItems(items);
				//troche taki hack, ale trzeba tak
				/*for(k = 0; k < items.Size(); k += 1)
				{
					if(!inventory.ItemHasTag(items[k], 'NoShow') && !inventory.ItemHasTag(items[k], 'NoDrop'))
					{
						inventory.RemoveItem(items[k]);
					}
				}*/
				
				characterStats = spawnedOpponent.GetCharacterStats();
				if(tierNum > arenaWave.arenaManager.maxTierNumer)
				{
					tierNum = arenaWave.arenaManager.maxTierNumer;
				}
				for(n = 1; n <= tierNum; n += 1)
				{
					abilityName = StringToName("OppE_ArenaTierMult" + IntToString(n));
					characterStats.AddAbility(abilityName);
				}
				characterStats.GetAbilities(abilities);
				Log("abilities");
			}
		}
	}
	function ShowRoundStartInformation()
	{
		var currentWaveText : int;
		currentWaveText = arenaWave.arenaManager.GetCurrentWaveText();
		//arenaWave.arenaManager.UpdateArenaHUD();
		//theHud.m_messages.ShowActText(GetLocStringByKeyExt( "Wave "+ currentWaveText+ " Round " + arenaWave.GetCurrentRoundText() + "/" + arenaWave.GetTotalRoundsNumber()));
		/*theHud.Invoke("pHUD.hideArenaHUD");
		theHud.Invoke("pHUD.setArenaHUD");
		theHud.InvokeOneArg("pHUD.setRoundNumber", FlashValueFromString(IntToString(arenaWave.GetCurrentRoundText()) + " / " + IntToString(arenaWave.GetTotalRoundsNumber())));
		//theHud.InvokeOneArg("pHUD.setPointsNumber", FlashValueFromInt(arenaWave.arenaManager.playerScore));
		theHud.InvokeOneArg("pHUD.setWaiveNumber", FlashValueFromInt(currentWaveText));
		theHud.InvokeOneArg("pHUD.setRoundNumber", FlashValueFromString(IntToString(arenaWave.GetCurrentRoundText()) + " / " + IntToString(arenaWave.GetTotalRoundsNumber())));*/
	}	
}
state Default in CArenaWaveRound
{
	entry function StartThisRound()
	{
		var teleportPoint : CNode;
		
		teleportPoint = theGame.GetNodeByTag('player_arena_spawn');
		//theGame.FadeOut(1.0);
		//theGame.GetArenaManager().ShowArenaHUD(true);
		thePlayer.TeleportWithRotation(teleportPoint.GetWorldPosition(), teleportPoint.GetWorldRotation());
		theCamera.ResetRotation(false, true, true, 0.0f);
		FactsAdd("arena_camera1", 1);
		parent.SpawnEnemies();
	
		theGame.FadeInAsync(1.0);
		
		parent.ShowRoundStartInformation();
	}
	entry function EndThisRound()
	{
		var currentWave : int;
		var arenaManager : CArenaManager;
		var arenaContainer : CArenaContainter;
		if(thePlayer.IsAlive())
		{
			thePlayer.SetCanUseHud(false);
			parent.arenaWave.arenaManager.ArenaCrowdReaction(ACR_Win);
			
			//LastRound - wave ended
			if(parent.arenaWave.currentRoundNumber + 1 >= parent.arenaWave.totalRounds) //temp increase round number
			{
				theSound.StopMusic("arena_1", true);
				theSound.StopMusic("arena_2", true);
				theSound.StopMusic("arena_3", true);
				theSound.StopMusic("arena_4", true);
				theSound.StopMusic("arena_5", true);
			}
		}
		Sleep(1.0);
		if(thePlayer.IsAlive())
		{
			thePlayer.SetGuardBlock(false, true);
			thePlayer.SetCombatEndAnimRequest(true);
			thePlayer.SetManualControl(false, true);
		}
		Sleep(1.0);
		if(thePlayer.IsAlive())
		{
			theGame.FadeOut(2.0);
		}
		Sleep(1.0);
		if(thePlayer.IsAlive())
		{
			parent.arenaWave.RoundEnded(parent);
			thePlayer.SetCombatEndAnimRequest(false);
			thePlayer.SetManualControl(true, true);
		}
	}
	
}
class CArenaSpawnNode extends CEntity
{
	editable var spawnLocation : EArenaSpawnLocation;
	
	function GetSpawnLocation() : EArenaSpawnLocation
	{
		return spawnLocation;
	}
}
struct SOpponentDefinition
{
	editable var template : CEntityTemplate;
	editable var quantity : int;
	editable var spawnLocation : EArenaSpawnLocation;
}
enum EArenaSpawnLocation
{
	SpawnLocationRandom,
	SpawnLocation1,
	SpawnLocation2,
	SpawnLocation3,
	SpawnLocation4,
	SpawnLocation5
}

exec function ArenaPlayCS()
{
	var actors : array < CEntity >;
	var names : array < string >;
	var waypoint : CNode;
	var pos, pos2, csPos : Vector;
	var rot : EulerAngles;
	var cs : bool;		

	names.PushBack("witcher");
	actors.PushBack( (CEntity)thePlayer );
	waypoint = theGame.GetNodeByTag('cs_arena');
	csPos = waypoint.GetWorldPosition();
	rot = waypoint.GetWorldRotation();
	cs = theGame.PlayCutsceneAsync( "cs_arena" , names, actors, csPos, rot );
}
