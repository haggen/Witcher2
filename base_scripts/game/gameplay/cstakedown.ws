// ---------------------------------------------------------
//                  shitty CSTakedown class
// ---------------------------------------------------------

class CSTakedown extends CStateMachine
{	
	event OnCSTakedown_1ManDown( target : CActor );	
	event OnCSTakedown_1Man( target : CActor, adrenaline : bool );
	event OnCSTakedown_2Man( target1, target2 : CActor, adrenaline : bool );
	event OnCSTakedown_3Man( target1, target2, target3 : CActor, adrenaline : bool );
	var hideRange, showRange : float;
	var finisherNum1 : array<int>;
	var finisherNum2 : array<int>;
	var finisherNum3 : array<int>;
	var finisherPoints : float;
	default hideRange = 10.0;
	default showRange = 20.0;
	function Initialize()
	{
		Idle();
	}
}
state Idle in CSTakedown
{
	var wasImmortal : bool;
	var wasInvurnerable : bool;
	entry function Idle();
	
	function GetStringCSNumber( id : int ) : string
	{
		if ( id < 10 ) return "0" + id; else return "" + id;
	}

// ---------------------------------------------------------
//                     ONE MAN DOWN
// ---------------------------------------------------------

	function SetPlayerImmortal()
	{	
		//if(thePlayer.IsImmortal())
		//{
			//wasImmortal = true;
		//}
		//thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 5.0);
	}
	function SetPlayerMortal()
	{
		//if(wasImmortal)
		//{
		//	thePlayer.SetImmortalityModePersistent(AIM_Immortal);
		//}
		//else
		//{
		//	thePlayer.SetImmortalityModeRuntime(AIM_None, 0.0);
			//thePlayer.SetImmortalityModePersistent(AIM_None);
		//}
	}
	function FindFinisherSpot(out finisherRange : EFinisherDistance, startPosition : Vector, out spotPosition : Vector, out spotRotation : EulerAngles) : bool
	{
		var nearestPos : Vector;
		var rotation : EulerAngles;
		var nodePosition : Vector;
		var finisherSpots : array<CNode>;
		var closestDistanceToSpot, closestDistanceToSpotSqrt, distanceToSpotSqrt : float;
		var i, size : int;
		var maxZDiff : float;
		var foundSpot : bool;
		var cutceneRange : EFinisherDistance;
		var fSpot : CFinisherSpot;
		var geratlRot : EulerAngles;
		
		//Minimal distance for finding a finisher spot
		closestDistanceToSpot = 100.0;
		closestDistanceToSpotSqrt = closestDistanceToSpot*closestDistanceToSpot;
		
		//Maximum z difference between start position and spot position
		maxZDiff = 4.0;
		
		theGame.GetNodesByTag('fspot', finisherSpots);
		size = finisherSpots.Size();
		
		//Find nearest spot with Z difference test
		for(i = 0; i < size; i += 1)
		{
			nodePosition = finisherSpots[i].GetWorldPosition();
			distanceToSpotSqrt = VecDistanceSquared(startPosition, nodePosition);
			if( distanceToSpotSqrt < closestDistanceToSpotSqrt )
			{
				if( ZDif(startPosition, nodePosition, maxZDiff) )
				{
					fSpot = (CFinisherSpot)finisherSpots[i];
					//Test if the finisher spot is in the same finisher area as the player 
					//or player is outside of any finisher area
					if(fSpot.GetFinisherArea() == thePlayer.GetPlayerFinisherArea())
					{
						if((int)finisherRange >= (int)fSpot.GetFinisherDistance())
						{
							cutceneRange = fSpot.GetFinisherDistance();
							closestDistanceToSpotSqrt = distanceToSpotSqrt;
							nearestPos = nodePosition;
							rotation = fSpot.GetWorldRotation();
							foundSpot = true;
						}
					}
				}
			}
		}
		if(foundSpot)
		{
			finisherRange = cutceneRange;
			spotPosition = nearestPos;
			spotRotation = rotation;
		}
		else
		{
			spotPosition = thePlayer.GetWorldPosition();
			spotRotation = thePlayer.GetWorldRotation();
		}
		return foundSpot;
	}
	
	entry function CSTakedown_1ManDown( target : CActor ) 
	{
		var actors : array < CEntity >;
		var names : array < string >;
		var pos, pos2, csPos : Vector;
		var rot : EulerAngles;
		var cs : bool;
		var csIds : string;
		var enemiesClose : array < CActor >;
		var i : int;
		var deathData : SActorDeathData;
		var finisherRange : EFinisherDistance;
		
		finisherRange = FD_Medium;
		if ( ! target || target.IsBoss() ) return;
		csIds = GetStringCSNumber( RoundF( RandRangeF( 1, 4 ) ) );
		
		names.PushBack("witcher");
		names.PushBack("man1");
		actors.PushBack( (CEntity)thePlayer );
		actors.PushBack( (CEntity)target );
		
		deathData.deadState = true;
		
		pos = thePlayer.GetWorldPosition();
		if ( !FindFinisherSpot(finisherRange, pos, csPos, rot) )
		{
			rot = thePlayer.GetWorldRotation();
			csPos = pos;
			Log( "Couldn't find empty area for finisher" );
		}
		if ( target.IsMonster() && target.GetMonsterType() != MT_HumanGhost)
		{
			thePlayer.OnTakedownActor( target );		
		}
		else
		{
			//pos = thePlayer.GetWorldPosition();
			pos2 = target.GetWorldPosition();
			thePlayer.SetManualControl( false, false );
				Log("PLAYING CS FINISHER: fin_1down_" + csIds );
				thePlayer.SetTakedownCutscene(5.0);
				SetPlayerImmortal();
				ValidateWeapons(target);
				thePlayer.HideGui();
				if(theHud.CanShowMainMenu())
				{
					theHud.ForbidOpeningMainMenu();
				}
				cs = theGame.PlayCutscene( "fin_1down_" + csIds , names, actors, csPos, rot );
				thePlayer.ShowGui();
				thePlayer.SetPlayerCombatStance(PCS_High);
				thePlayer.SetTakedownCutscene(0.0);
			thePlayer.Teleport( pos );
			target.Teleport( pos2 );
			SetPlayerMortal();
			thePlayer.SetManualControl( true, true );
			target.noragdollDeath = true;
			target.EnterDead(deathData);
			CalculateGainedExperienceAfterKill(target, true, true, false);
			//thePlayer.SetAdrenaline( 0 );
			GetActorsInRange(enemiesClose, 30.0, '', thePlayer);	
			for( i=0; i < enemiesClose.Size(); i+=1 )
			{
				enemiesClose[i].SetHideInGame( false );
				enemiesClose[i].GetBehTreeMachine().Restart();
			}
			if(theGame.GetIsPlayerOnArena())
			{
				thePlayer.ShowArenaPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fin1_bonus'));
			}
			if(!theHud.CanShowMainMenu())
			{
				theHud.AllowOpeningMainMenu();
			}
		}
	}	
	
// ---------------------------------------------------------
//                     ONE MAN FINISHER
// ---------------------------------------------------------

	function GetFinisherCsId(enemiesNum : int, finisherDistance : EFinisherDistance) : string
	{
		var rand : int;
		var rangeFrom, rangeTo : int;
		var finihsherId, i, j, size, size2 : int;
		var finisherNumRand : array<int>;
		var elementFound : bool;
		var usesSecondaryWeapon : bool;
		var allFinishersUsed : bool;
		var finishersUsed : int;
		
		if(thePlayer.GetInventory().GetItemEntityUnsafe(thePlayer.GetCurrentWeapon()).IsWitcherSecondaryWeapon())
		{
			usesSecondaryWeapon = true;
		}
		
		finisherNumRand.Clear();
		if(enemiesNum == 3)
		{	
			if(finisherDistance == FD_Medium)
			{
				finihsherId = 6;
				return GetStringCSNumber(finihsherId);
			}
			rangeFrom = 1;
			if(FactsQuerySum("dlc_finishers") >= 1)
			{
				rangeTo = 9;
			}
			else
			{
				rangeTo = 8;
			}

			for(i = rangeFrom; i <= rangeTo; i += 1)
			{
				finisherNumRand.PushBack(i);
			}
			if(usesSecondaryWeapon)
			{
				finisherNumRand.Remove(2);
				finisherNumRand.Remove(3);
			}
			if(!thePlayer.HasSilverSword() || !thePlayer.HasSteelSword())
			{
				finisherNumRand.Remove(3);
			}
			
			
			size = finisherNumRand.Size();

			finishersUsed =  parent.finisherNum3.Size();
			if(finishersUsed >= size)
			{
				 parent.finisherNum3.Clear();
			}
			size = parent.finisherNum3.Size();
			for(j = 0; j < size; j += 1)
			{
				finisherNumRand.Remove(parent.finisherNum3[j]);
			}
			size = finisherNumRand.Size();
			i = Rand(size);
			finihsherId = finisherNumRand[i];
			parent.finisherNum3.PushBack(finihsherId);
		}
		else if(enemiesNum == 2)
		{
			size = parent.finisherNum2.Size();
			if(finisherDistance == FD_Medium)
			{
				finisherNumRand.PushBack(5);
				finisherNumRand.PushBack(3);
			}
			else
			{
				rangeFrom = 1;
				rangeTo = 5;
				for(i = rangeFrom; i <= rangeTo; i += 1)
				{
					finisherNumRand.PushBack(i);
				}
			}
			if(usesSecondaryWeapon)
			{
				finisherNumRand.Remove(4);
				
			}
			if(!thePlayer.HasSilverSword() || !thePlayer.HasSteelSword())
			{
				finisherNumRand.Remove(5);
			}
			size = finisherNumRand.Size();

			finishersUsed =  parent.finisherNum2.Size();
			if(finishersUsed >= size)
			{
				 parent.finisherNum2.Clear();
			}
			size = parent.finisherNum2.Size();
			for(j = 0; j < size; j += 1)
			{
				finisherNumRand.Remove(parent.finisherNum2[j]);
			}
			size = finisherNumRand.Size();
			i = Rand(size);
			finihsherId = finisherNumRand[i];
			parent.finisherNum2.PushBack(finihsherId);
		}
		else
		{
			if(finisherDistance == FD_Close)
			{
				//Add only finishers that work on close distance
				finisherNumRand.PushBack(1);
				finisherNumRand.PushBack(3);
				finisherNumRand.PushBack(11);
				finisherNumRand.PushBack(10);
			}
			else
			{
				//Add all 1man finishers
				rangeFrom = 1;
				if(FactsQuerySum("dlc_finishers") >= 1)
				{
					rangeTo = 20;
				}
				else
				{
					rangeTo = 18;
				}
				for(i = rangeFrom; i <= rangeTo; i += 1)
				{
					finisherNumRand.PushBack(i);
				}
				//Remove finishers that will not work on medium distance
				if(finisherDistance == FD_Medium)
				{
					finisherNumRand.Remove(4);
					finisherNumRand.Remove(18);
				}
			}
			if(usesSecondaryWeapon)
			{
				finisherNumRand.Remove(11);
				finisherNumRand.Remove(6);
				finisherNumRand.Remove(8);
				finisherNumRand.Remove(12);
				finisherNumRand.Remove(13);
				finisherNumRand.Remove(16);
				finisherNumRand.Remove(17);
				finisherNumRand.Remove(18);
				finisherNumRand.Remove(19);
				finisherNumRand.Remove(20);
			}
			if(!thePlayer.HasSilverSword() || !thePlayer.HasSteelSword())
			{
				finisherNumRand.Remove(11);
				finisherNumRand.Remove(16);
			}
			
			size = finisherNumRand.Size();
			finishersUsed =  parent.finisherNum1.Size();
			if(finishersUsed >= size)
			{
				 parent.finisherNum1.Clear();
			}
			size = parent.finisherNum1.Size();
			for(j = 0; j < size; j += 1)
			{
				finisherNumRand.Remove(parent.finisherNum1[j]);
			}
			size = finisherNumRand.Size();
			i = Rand(size);
			finihsherId = finisherNumRand[i];
			parent.finisherNum1.PushBack(finihsherId);
		}
		return GetStringCSNumber(finihsherId);
	}
	function IsMonsterFinisher(monster : CActor) : bool
	{
		var monsterType : EMonsterType;
		monsterType = monster.GetMonsterType();
		
		switch (monsterType)
		{
			case MT_Rotfiend:
			{
				return true;
				break;
			}
			case MT_Drowner:
			{
				return true;
				break;
			}
			case MT_Bullvore:
			{
				return true;
				break;
			}
			case MT_Troll:
			{
				return true;
				break;
			}
			case MT_Gargoyle:
			{
				return true;
				break;
			}
			case MT_Golem:
			{
				return true;
				break;
			}
			case MT_Elemental:
			{
				return true;
				break;
			}
			case MT_Harpie:
			{
				return true;
				break;
			}
			case MT_Nekker:
			{
				return true;
				break;
			}
			case MT_KnightWraith:
			{
				return true;
				break;
			}
			case MT_Wraith:
			{
				return true;
				break;
			}
			case MT_Bruxa:
			{
				return true;
				break;
			}
		}
		
		return false;
	}
	function GetMonsterFinisherCutscene(monster : CActor) : string
	{
		var monsterType : EMonsterType;
		var foundCutscene : bool;
		var cutsceneName : string;
		monsterType = monster.GetMonsterType();
		switch (monsterType)
		{
			case MT_Rotfiend:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_brukolak";
				break;
			}
			case MT_Drowner:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_brukolak";
				break;
			}
			case MT_Bullvore:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_bullvore";
				break;
			}
			case MT_Troll:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_bullvore";
				break;
			}
			case MT_Gargoyle:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_gargoyle";
				break;
			}
			case MT_Elemental:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_golem";
				break;
			}
			case MT_Golem:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_golem";
				break;
			}
			case MT_Harpie:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_harpy";
				break;
			}
			case MT_Nekker:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_nekker";
				break;
			}
			case MT_KnightWraith:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_knightwraith";
				break;
			}
			case MT_Wraith:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_wraith";
				break;
			}
			case MT_Bruxa:
			{
				foundCutscene = true;
				cutsceneName = "fin_mon_wraith";
				break;
			}
		}
		if(foundCutscene)
			return cutsceneName;
		else
		{
			Log("No cutscene for monster finisher found or character is not a monster");
			return "";
		}
	}
	latent function ValidateWeapons(target : CActor)
	{
		var npc : CNewNPC;
		var weaponRight, weaponLeft : SItemUniqueId;
		var weaponEnt : CItemEntity;
		var rigidComponent : CRigidMeshComponent;
		var force, forcePoint : Vector;
		force = Vector(RandRangeF(0.4, 0.8), RandRangeF(0.2, 0.8), RandRangeF(0.1, 0.2));
		npc = (CNewNPC)target;
		if((npc && !npc.IsMonster()) || (npc && npc.GetMonsterType() == MT_HumanGhost))
		{
			if(npc.HasCombatType(CT_ShieldSword))
			{
				weaponLeft = npc.GetCurrentWeapon(CH_Left);
				weaponEnt = npc.GetInventory().GetItemEntityUnsafe(weaponLeft);
				rigidComponent = (CRigidMeshComponent)weaponEnt.GetComponentByClassName('CRigidMeshComponent');
				npc.GetInventory().DropItem(weaponLeft, true);
				forcePoint = rigidComponent.GetCenterOfMassInWorld();
				forcePoint.Z += 0.3;
				//rigidComponent.ApplyLinearImpulseAtPoint(force, forcePoint);
				rigidComponent.SetAngularVelocity(force);
				weaponRight = npc.GetCurrentWeapon(CH_Right);
				if(weaponRight == GetInvalidUniqueId())
				{
					npc.DrawItemInstant(npc.GetInventory().GetItemByCategory('opponent_weapon', false));
				}
			}
			else if(npc.HasCombatType(CT_Bow) || npc.HasCombatType(CT_Bow_Walking))
			{
				weaponLeft = npc.GetCurrentWeapon(CH_Left);
				npc.HolsterItemInstant(weaponLeft); // sytuacja specjalna, musimy schowac luk / kusze na szybko
				weaponRight = npc.GetCurrentWeapon(CH_Right);
				if(weaponRight == GetInvalidUniqueId())
				{
					npc.DrawItemInstant(npc.GetInventory().GetItemByCategory('opponent_weapon', false));
				}
			}
			else if(npc.HasCombatType(CT_Dual) || npc.HasCombatType(CT_Dual_Assasin))
			{
				weaponLeft = npc.GetCurrentWeapon(CH_Left);
				npc.GetInventory().DropItem(weaponLeft, true);
				weaponRight = npc.GetCurrentWeapon(CH_Right);
				if(weaponRight == GetInvalidUniqueId())
				{
					npc.DrawItemInstant(npc.GetInventory().GetItemByCategory('opponent_weapon', false));
				}
			}
		}
	}
	function GetMonsterFinisherActorName(monster : CActor) : string
	{
		var monsterType : EMonsterType;
		var foundCutscene : bool;
		var actorName : string;
		monsterType = monster.GetMonsterType();
		switch (monsterType)
		{
			case MT_Rotfiend:
			{
				foundCutscene = true;
				actorName = "brukolak";
				break;
			}
			case MT_Drowner:
			{
				foundCutscene = true;
				actorName = "brukolak";
				break;
			}
			case MT_Bullvore:
			{
				foundCutscene = true;
				actorName = "bullvore";
				break;
			}
			case MT_Troll:
			{
				foundCutscene = true;
				actorName = "bullvore";
				break;
			}
			case MT_Gargoyle:
			{
				foundCutscene = true;
				actorName = "gargoyle";
				break;
			}
			case MT_Golem:
			{
				foundCutscene = true;
				actorName = "golem";
				break;
			}
			case MT_Elemental:
			{
				foundCutscene = true;
				actorName = "golem";
				break;
			}
			case MT_Harpie:
			{
				foundCutscene = true;
				actorName = "harpy";
				break;
			}
			case MT_Nekker:
			{
				foundCutscene = true;
				actorName = "nekker";
				break;
			}
			case MT_KnightWraith:
			{
				foundCutscene = true;
				actorName = "wraight_knight";
				break;
			}
			case MT_Wraith:
			{
				foundCutscene = true;
				actorName = "wraith";
				break;
			}
			case MT_Bruxa:
			{
				foundCutscene = true;
				actorName = "wraith";
				break;
			}
		}
		if(foundCutscene)
			return actorName;
		else
		{
			Log("No cutscene for monster finisher found or character is not a monster");
			return "";
		}
	}
	function ZDif(position1 : Vector, position2 : Vector, zdif : float) : bool
	{
		var z1, z2 : float;
		z1 = position1.Z;
		z2 = position2.Z;
		
		if(AbsF(z1 - z2) < zdif)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function GetMonsterCutsceneDistance(monsterType : EMonsterType) : EFinisherDistance
	{
		var finisherDist : EFinisherDistance;
		switch (monsterType)
		{
			case MT_Rotfiend:
			{
				finisherDist = FD_Close;
				break;
			}
			case MT_Drowner:
			{
				finisherDist = FD_Close;
				break;
			}
			case MT_Bullvore:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Troll:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Gargoyle:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Golem:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Elemental:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Harpie:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Nekker:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_KnightWraith:
			{
				finisherDist = FD_Medium;
				break;
			}
			case MT_Wraith:
			{
				finisherDist = FD_Close;
				break;
			}
			case MT_Bruxa:
			{
				finisherDist = FD_Close;
				break;
			}
		}
		return finisherDist;
	}
	entry function CSTakedown_1Man( target : CActor, adrenaline : bool ) 
	{
		var actors : array < CEntity >;
		var names : array < string >;
		var pos, pos2, posCut : Vector;
		var rot : EulerAngles;
		var cs : bool;
		var csIds : string;
		var deathData : SActorDeathData;
		var enemiesClose : array < CActor >;
		var i : int;
		var cutsceneName : string;
		var actorName : string;
		var targets : array<CActor>;
		var takedownParams : STakedownParams;
		var cutsceneRange : EFinisherDistance;
		targets.PushBack(target);
		if(adrenaline)
		{
			thePlayer.SetAdrenaline( 0 );
		}
		if ( ! target || target.IsBoss() )
		{
			if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
			{
				thePlayer.UseAnimationWithHeliotrop(true);
				thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
			}
			return;
		}
		names.PushBack("witcher");
		
		actors.PushBack( (CEntity)thePlayer );
		actors.PushBack( (CEntity)target );
		pos = thePlayer.GetWorldPosition();
		
		
		cutsceneRange = FD_Close;
		if(target.IsMonster() && target.GetMonsterType() != MT_HumanGhost)
		{
			cutsceneRange = GetMonsterCutsceneDistance(target.GetMonsterType());
		}
		
		if(!target.CanPlayFinisherCutscene())
		{
			target.PlayStrongBloodOnHit();
			target.Kill(false, thePlayer, deathData);
			if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
			{
				thePlayer.UseAnimationWithHeliotrop(true);
				thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
			}
			return;
		}
		if ( !FindFinisherSpot(cutsceneRange, pos, posCut, rot) )
		{
			posCut = pos;
			rot = thePlayer.GetWorldRotation();
			if(!adrenaline)
			{
				Log( "Couldn't find empty area for finisher" );
				target.PlayStrongBloodOnHit();
				target.Kill(false, thePlayer, deathData);
				if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
				{
					thePlayer.UseAnimationWithHeliotrop(true);
					thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
				}
				return;
			}
			else
			{
				if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
				{
					thePlayer.UseAnimationWithHeliotrop(true);
					thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
				}
				thePlayer.TriggerKillingSpell(target);
				return;
			}
		}
		if ( target.IsMonster() && !IsMonsterFinisher(target) && target.GetMonsterType() != MT_HumanGhost)
		{
			thePlayer.OnTakedownActor( target );		
		}
		else
		{
			csIds = GetFinisherCsId(1, cutsceneRange);
			target.StopEffect('stun_fx');
			pos = thePlayer.GetWorldPosition();
			pos2 = target.GetWorldPosition();
			//rot = thePlayer.GetWorldRotation();
			thePlayer.SetManualControl( false, false );
				Log("PLAYING CS FINISHER: fin_1man_" + csIds );
				thePlayer.SetTakedownCutscene(5.0);
			if(IsMonsterFinisher(target))
			{
				cutsceneName = GetMonsterFinisherCutscene(target);
				actorName = GetMonsterFinisherActorName(target);
				names.PushBack(actorName);
			}
			else
			{
				cutsceneName = "fin_1man_" + csIds;
				names.PushBack("man1");
			}
			SetPlayerImmortal();
			thePlayer.HideNearbyEnemies(posCut, parent.hideRange, targets);
			ValidateWeapons(target);
			thePlayer.HideGui();
			if(theHud.CanShowMainMenu())
			{
				theHud.ForbidOpeningMainMenu();
			}
			cs = theGame.PlayCutscene( cutsceneName , names, actors, posCut, rot );
			thePlayer.ShowGui();
			thePlayer.SetTakedownCutscene(0.0);
			thePlayer.SetPlayerCombatStance(PCS_High);
			thePlayer.Teleport( pos );
			target.Teleport( pos2 );
			SetPlayerMortal();
			thePlayer.SetManualControl( true, true );
			target.noragdollDeath = true;
			deathData.deadState = true;
			deathData.ragDollAfterDeath = false;//true;
			CalculateGainedExperienceAfterKill(target, true, true, false);
			target.EnterDead(deathData);
			thePlayer.ShowNearbyEnemies(posCut, parent.showRange);

		}
		
		if(theGame.GetIsPlayerOnArena())
		{
			if(theGame.GetIsPlayerOnArena())
			{
				thePlayer.ShowArenaPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fin1_bonus'));
			}
		}
		
		if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
		{
			thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
		}
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
	}	
	
// ---------------------------------------------------------
//                     TWO MAN FINISHER
// ---------------------------------------------------------
	entry function CSTakedown_2Man( target1, target2 : CActor, adrenaline : bool ) 
	{
		var actors : array < CEntity >;
		var names : array < string >;
		var pos, pos2, pos3, posCut : Vector;
		var rot : EulerAngles;
		var cs : bool;
		var csIds : string;
		var deathData : SActorDeathData;
		var targets : array<CActor>;
		var cutsceneRange : EFinisherDistance;

		cutsceneRange = FD_Medium;
		if(adrenaline)
		{
			thePlayer.SetAdrenaline( 0 );
		}
		targets.PushBack(target1);
		targets.PushBack(target2);
		deathData.deadState = true;
		deathData.ragDollAfterDeath = false;//true;
		if ( ( ! target1 || target1.IsBoss() ) && ( ! target2 || target2.IsBoss() ) )  
		{
			if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
			{
				thePlayer.UseAnimationWithHeliotrop(true);
				thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
			}
			return;
		}
		//GetStringCSNumber( RoundF( RandRangeF( 1, 5 ) ) );
		names.PushBack("witcher");
		names.PushBack("man1");
		names.PushBack("man2");
		actors.PushBack( (CEntity)thePlayer );
		actors.PushBack( (CEntity)target1 );
		actors.PushBack( (CEntity)target2 );
		pos = thePlayer.GetWorldPosition();
		if ( !FindFinisherSpot(cutsceneRange, pos, posCut, rot) )
		{
			posCut = pos;
			rot = thePlayer.GetWorldRotation();
			CSTakedown_1Man( target1, adrenaline ); 
			if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
			{
				thePlayer.UseAnimationWithHeliotrop(true);
				thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
			}
			return;
			
		}
		if ( (target1.IsMonster() && target1.GetMonsterType() != MT_HumanGhost) || (target2.IsMonster() && target2.GetMonsterType() != MT_HumanGhost) )
		{
			if ( target1.IsMonster() ) OnCSTakedown_1Man(target1, true);	
			if ( target2.IsMonster() ) OnCSTakedown_1Man(target2, true);
			return;
		}
		else
		{
			pos = thePlayer.GetWorldPosition();
			pos2 = target1.GetWorldPosition();
			pos3 = target2.GetWorldPosition();
			csIds = GetFinisherCsId(2, cutsceneRange);
			//rot = thePlayer.GetWorldRotation();
			thePlayer.SetManualControl( false, false );
				Log("PLAYING CS FINISHER: fin_2man_" + csIds );
				thePlayer.SetTakedownCutscene(5.0);
				SetPlayerImmortal();
				ValidateWeapons(target1);
				ValidateWeapons(target2);
				thePlayer.HideNearbyEnemies(posCut, parent.hideRange, targets);
				thePlayer.HideGui();
				if(theHud.CanShowMainMenu())
				{
					theHud.ForbidOpeningMainMenu();
				}
				cs = theGame.PlayCutscene( "fin_2man_" + csIds , names, actors, posCut, rot );
				thePlayer.ShowGui();
				thePlayer.SetTakedownCutscene(0.0);
				thePlayer.SetPlayerCombatStance(PCS_High);
			thePlayer.Teleport( pos );
			target1.Teleport( pos2 );
			target2.Teleport( pos3 );
			SetPlayerMortal();
			thePlayer.SetManualControl( true, true );
			target1.noragdollDeath = true;
			target1.EnterDead(deathData);
			target2.noragdollDeath = true;
			target2.EnterDead(deathData);
			CalculateGainedExperienceAfterKill(target1, true, true, false);
			CalculateGainedExperienceAfterKill(target2, true, true, false);
			thePlayer.ShowNearbyEnemies(posCut, parent.showRange);
		}
		
		if(theGame.GetIsPlayerOnArena())
		{
			if(theGame.GetIsPlayerOnArena())
			{
				thePlayer.ShowArenaPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fin2_bonus'));
			}
		}
		
		if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
		{
			thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
		}
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
	}	
	
// ---------------------------------------------------------
//                     THREE MAN FINISHER
// ---------------------------------------------------------
	entry function CSTakedown_3Man( target1, target2, target3 : CActor, adrenaline : bool ) 
	{
		var actors : array < CEntity >;
		var names : array < string >;
		var pos, pos2, pos3, pos4, posCut : Vector;
		var rot : EulerAngles;
		var cs : bool;
		var csIds : string;
		var enemiesClose : array < CActor >;
		var i : int;
		var deathData : SActorDeathData;
		var targets : array<CActor>;
		var cutsceneRange : EFinisherDistance;
				
		cutsceneRange = FD_Medium;
		if(adrenaline)
		{
			thePlayer.SetAdrenaline( 0 );
		}
		targets.PushBack(target1);
		targets.PushBack(target2);
		targets.PushBack(target3);
		deathData.deadState = true;
		deathData.ragDollAfterDeath = false;//true;
		
		if ( ( ! target1 || target1.IsBoss() ) && ( ! target2 || target2.IsBoss() ) && ( ! target3 || target3.IsBoss() ) )
		{
			if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
			{
				thePlayer.UseAnimationWithHeliotrop(true);
				thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
			}
			return;
		} 
		//GetStringCSNumber( RoundF( RandRangeF( 1, 9 ) ) );
		names.PushBack("witcher");
		names.PushBack("man1");
		names.PushBack("man2");
		names.PushBack("man3");
		actors.PushBack( (CEntity)thePlayer );
		actors.PushBack( (CEntity)target1 );
		actors.PushBack( (CEntity)target2 );
		actors.PushBack( (CEntity)target3 );
		
		if ( (target1.IsMonster() && target1.GetMonsterType() != MT_HumanGhost)  || (target2.IsMonster() && target2.GetMonsterType() != MT_HumanGhost) || (target3.IsMonster() && target3.GetMonsterType() != MT_HumanGhost) )
		{
			if ( target1.IsMonster() ) OnCSTakedown_1Man(target1, true);	
			if ( target2.IsMonster() ) OnCSTakedown_1Man(target2, true);		
			if ( target3.IsMonster() ) OnCSTakedown_1Man(target3, true);	
			return;
		}
		else
		{
			pos = thePlayer.GetWorldPosition();
			if ( !FindFinisherSpot(cutsceneRange, pos, posCut, rot) )
			{
				posCut = pos;
				rot = thePlayer.GetWorldRotation();
				CSTakedown_1Man( target1, adrenaline ); 
				if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
				{
					thePlayer.UseAnimationWithHeliotrop(true);
					thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
				}
				return;
			}
	
			csIds = GetFinisherCsId(3, cutsceneRange);
			pos = thePlayer.GetWorldPosition();
			pos2 = target1.GetWorldPosition();
			pos3 = target2.GetWorldPosition();
			pos4 = target3.GetWorldPosition();
			//rot = thePlayer.GetWorldRotation();
			thePlayer.SetManualControl( false, false );
				Log("PLAYING CS FINISHER: fin_3man_" + csIds );
				thePlayer.SetTakedownCutscene(5.0);
				SetPlayerImmortal();
				thePlayer.HideNearbyEnemies(posCut, parent.hideRange, targets);
				ValidateWeapons(target1);
				ValidateWeapons(target2);
				ValidateWeapons(target3);
				thePlayer.HideGui();
				if(theHud.CanShowMainMenu())
				{
					theHud.ForbidOpeningMainMenu();
				}
				cs = theGame.PlayCutscene( "fin_3man_" + csIds , names, actors, posCut, rot );
				theGame.UnlockAchievement('ACH_TRIANGLE');
				thePlayer.ShowGui();
				thePlayer.SetTakedownCutscene(0.0);
			thePlayer.Teleport( pos );
			target1.Teleport( pos2 );
			target2.Teleport( pos3 );
			target3.Teleport( pos4 );
			SetPlayerMortal();
			thePlayer.SetManualControl( true, true );
			target1.noragdollDeath = true;
			target1.EnterDead(deathData);
			target2.noragdollDeath = true;
			target2.EnterDead(deathData);
			target3.noragdollDeath = true;
			target3.EnterDead(deathData);
			CalculateGainedExperienceAfterKill(target1, true, true, false);
			CalculateGainedExperienceAfterKill(target2, true, true, false);
			CalculateGainedExperienceAfterKill(target3, true, true, false);
			thePlayer.ShowNearbyEnemies(posCut, parent.showRange);	
		}
		
		if(theGame.GetIsPlayerOnArena())
		{
			if(theGame.GetIsPlayerOnArena())
			{
				thePlayer.ShowArenaPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fin3_bonus'));
			}
		}
		
		if ( adrenaline && thePlayer.GetWitcherType( WitcherType_Magic ) )
		{
			thePlayer.AddTimer('TriggerHeliotropTimer', 0.2, false);
		}
		if(!theHud.CanShowMainMenu())
		{
			theHud.AllowOpeningMainMenu();
		}
	}	
	
	
// ---------------------------------------------------------
//                     ENTRY EVENTS
// ---------------------------------------------------------
	event OnCSTakedown_1ManDown( target : CActor )
	{
		CSTakedown_1ManDown( target );
	}	
	event OnCSTakedown_1Man( target : CActor, adrenaline : bool )
	{
		CSTakedown_1Man( target, adrenaline );
	}
	event OnCSTakedown_2Man( target1, target2 : CActor, adrenaline : bool )
	{
		CSTakedown_2Man( target1, target2, adrenaline );
	}
	event OnCSTakedown_3Man( target1, target2, target3 : CActor, adrenaline : bool )
	{
		CSTakedown_3Man( target1, target2, target3, adrenaline );
	}
};
