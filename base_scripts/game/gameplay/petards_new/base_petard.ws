/*
DONE:
		Kartacz / Grapeshot - wybuchowa
		Czarcia Purchawa / Puffball - rozpyla chmure trucizny ( chmura zielona )
		Samum / Samum - dezorientuje przeciwnikow  ( immobile )
		Tañcz¹ca Gwiazda / Dancing Star - podpala obszar ( efekt ognia )
		Smoczy Sen / DragonDream - tworzy chmurê latwopalnego gazu ( chmura zolta )
		Œwietlik / Firefly - oœlepia przeciwników ( trochê jak samum ) ( efekt blysku + blind )
		Flara / Flare - generuje œwiat³o 
		Czerwona mg³a / Red Haze - nastawia przeciwników w zasiegu ra¿enia przeciwko sobie ( chmura czerwona )
		Œmierdziuch / Stinker - tworzy chmurê, z której uciekaj¹ przeciwnicy + maj¹ modyfikator do cech (  chmura szara )
*/

//////////////////////////////////////////////////////
//		Base class for all petards.					//
//		This class is only for initial purposes.	//
//		It spawnes the real petard after the 		//
//		throw animation has finished.				//
//////////////////////////////////////////////////////

class CPetardBase extends CThrowable
{
	var petardItem : SItemUniqueId;
	function InitThrowEntity(item : SItemUniqueId)
	{
		petardItem = item;
	}
}

state Flying in CPetardBase
{
	entry function StartFlying( destination : Vector )
	{
		var mat			:	Matrix;
		var pos			:	Vector;
		var rigid		:	CEntity;
		var distance	:	float;
		
		if( thePlayer.HasSilverSword() || thePlayer.HasSteelSword() )
			mat = thePlayer.GetBoneWorldMatrix( 'l_weapon' );
		else
			mat = thePlayer.GetBoneWorldMatrix( 'l_thumb1' );
			
		rigid = theGame.CreateEntity( parent.ThrownTemplate, MatrixGetTranslation( mat ), MatrixGetRotation( mat ) );
		if ( !rigid )
		{
			Log( "======================================================================" );
			Log( "PETARD ERROR" );
			Log( "Could not create RigidMeshEntity." );
			Log( "======================================================================" );
			
			return;
		}
		Sleep(0.0001);
		
		((CPetardRigid)rigid).SetCharacterStats( parent.petardItem );
		
		if( VecLength( destination ) > 0 )
		{
			distance = VecLength( thePlayer.GetWorldPosition() - destination );
			ThrowEntityWithHorizontalVelocity( rigid, 4 * SqrtF(distance), destination );
		}
		else
		{
			pos = ( RotForward( thePlayer.GetWorldRotation() ) * 15 ) + thePlayer.GetWorldPosition();
			ThrowEntityWithHorizontalVelocity( rigid, 20, pos );
		}
		
		parent.Destroy();
	}
}

//////////////////////////////////////////////////
//		This is the harmfull petard class.		//
//////////////////////////////////////////////////

class CPetardRigid extends CEntity
{
	editable var destroyOnActivation	:	bool;
	editable var activationDelay		:	float;
	editable var durationOfEmmiting		:	float;
	editable var hasCriticalEffect		:	bool;
	editable var criticalEffectType		:	ECriticalEffectType;
	
	private var rigidComponent	:	CRigidMeshComponent;

	//Stats
	private var boundMin		:	Vector;
	private var boundMax		:	Vector;
	private var	minInitialDmg	:	float;
	private var	maxInitialDmg	:	float;
	private var minInidialDmgMult : float;
	private var maxInidialDmgMult : float;
	private var	minDmgOnTick	:	float;
	private var	maxDmgOnTick	:	float;
	private var	effectDuration	:	float;
	private var emmitingStopped	:	bool;
	private var dispPerc		: 	bool;
	private var dispAdd			: 	bool;
	private var damagedActors	: array<CActor>;
	private var criticalEffectChance : float;
	private var criticalEffectChanceMult : float;
	
	function SetCharacterStats( item : SItemUniqueId)
	{
		var abilities : array<name>;
		var range : float;
		var i : int;
		
		range = 5.0;
		
		boundMin.X = -range;
		boundMin.Y = -range;
		boundMin.Z = -range;
		boundMax.X = range;
		boundMax.Y = range;
		boundMax.Z = range;
		
		thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'damage_min', minInitialDmg, minInidialDmgMult, dispPerc, dispAdd);//thePlayer.GetInventory().GetItemGetItemAttributeAdditive(item, 'damage_min');
		thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'damage_max', maxInitialDmg, maxInidialDmgMult, dispPerc, dispAdd);
		minDmgOnTick	= 0.0f;
		maxDmgOnTick	= 0.0f;
		effectDuration	= 0.0f;
		
		if(hasCriticalEffect)
		{
			if(criticalEffectType == CET_Stun)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_stun', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Poison)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_poison', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Burn)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_burn', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
			else if(criticalEffectType == CET_Freeze)
			{
				thePlayer.GetCharacterStats().GetItemAttributeValuesWithPrerequisites(item, 'crt_freeze', criticalEffectChance, criticalEffectChanceMult, dispPerc, dispAdd);
			}
		}
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		rigidComponent = (CRigidMeshComponent)GetComponentByClassName('CRigidMeshComponent');
		
		if( !rigidComponent )
		{
			Log("Can not find RigidMeshComponent in petard entity");
			Destroy();
			return false;
		}

		EnableCollisionInfoReportingForComponent( rigidComponent, true, true );
		PlayEffect( 'trail_fx' );
	} 
	
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		var ent : CEntity;
		
		ent = collidingComponent.GetEntity();
		if( collidingComponent.GetEntity() != thePlayer )
		{
			thePlayer.GetVisualDebug().AddSphere( 'kurwajapierdole', 0.3f, rigidComponent.GetCenterOfMassInWorld(), true, Color(255,0,0), 20.0f );
			Exploade();
		}
	}
	function CriticalEffectTest(target : CActor, effectType : ECriticalEffectType) : bool
	{
		var res : float;
		var chanceBasic : float;
		var chance : float;
		var diceThrow : float = RandRangeF(0.0, 1.0);
		chanceBasic = criticalEffectChance;
		if(criticalEffectType == CET_Stun)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_stun' );
		}
		else if(criticalEffectType == CET_Poison)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_poison' );
		}
		else if(criticalEffectType == CET_Burn)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_burn' );
		}
		else if(criticalEffectType == CET_Freeze)
		{
			res = target.GetCharacterStats().GetFinalAttribute( 'res_freeze' );
		}
		chance = chanceBasic - res;
		if(diceThrow < chance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	private function GetActorsInRange() : array< CActor >
	{
		var i, size		: int;
		var actors		: array< CActor >;
		var casulties	: array< CActor >;
		var npc			: CNewNPC;
		
		ActorsStorageGetClosestByPos( GetWorldPosition(), actors, boundMin, boundMax, NULL, true );
		
		size = actors.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( actors[i].IsAlive() )
			{
				if( actors[i].IsBoss() )
				{
					casulties.PushBack( actors[i] );
				}
				else if( actors[i].IsA( 'CNewNPC' ) )
				{
					npc = (CNewNPC)actors[i];
					if( npc.GetAttitude( thePlayer ) != AIA_Friendly )
					{
						casulties.PushBack( actors[i] );
					}
				}
				else if (actors[i] == thePlayer)
				{
					if(VecDistanceSquared(thePlayer.GetWorldPosition(), this.GetWorldPosition()) < 4.0)
					{
						casulties.PushBack( thePlayer );
					}
				}
			}
		}
		
		return casulties;
	}
	private function CriticalEffectCheckAndApply()
	{
		var i, size	:	int;
		var targets	:	array< CActor >;
		targets = GetActorsInRange();
		for( i = 0; i < size; i += 1 )
		{
			if( hasCriticalEffect && CriticalEffectTest(targets[i], criticalEffectType))
			{
				targets[i].ForceCriticalEffect(criticalEffectType, W2CriticalEffectParams(0,0,0,0), true);
			}
		}
		
	}
	private function ApplyAdditionalEffectsInRange()
	{
		var i, size	:	int;
		var targets	:	array< CActor >;
		
		var finalDmg, damageSkillMult, damageAvoidChance, diceThrow	:	float;
		var damage				: 	float;
		var damageInt, damageBaseInt, resInt : int;
		
		targets = GetActorsInRange();
		size = targets.Size();
					
		for( i = 0; i < size; i += 1 )
		{
			if( hasCriticalEffect && CriticalEffectTest(targets[i], criticalEffectType))
			{
				targets[i].ForceCriticalEffect(criticalEffectType, W2CriticalEffectParams(0,0,0,0), true);
			}	
		}
	}
	private function HarmActorsInRange()
	{
		var i, size, killedActors	:	int;
		var targets	:	array< CActor >;
		
		var finalDmg, damageSkillMult, damageAvoidChance, diceThrow	:	float;
		var damage				: 	float;
		var damageInt, damageBaseInt, resInt : int;
		var reduction, damageTemp, health : float;
		
		targets = GetActorsInRange();
		size = targets.Size();
		
		
		damageSkillMult = thePlayer.GetCharacterStats().GetFinalAttribute('petards_damage_mult');
		if(damageSkillMult < 1)
			damageSkillMult = 1;
			
		for( i = 0; i < size; i += 1 )
		{
			/*if(targets[i] != thePlayer)
			{
				minInitialDmg = minInitialDmg*damageSkillMult;
				maxInitialDmg = maxInitialDmg*damageSkillMult;
				minDmgOnTick = minDmgOnTick*damageSkillMult;
				maxDmgOnTick = maxDmgOnTick*damageSkillMult;
			}*/
			if(targets[i] == thePlayer)
			{
				if(thePlayer.GetCharacterStats().HasAbility('story_s19_1'))
				{
					damageAvoidChance = thePlayer.GetCharacterStats().GetFinalAttribute('trap_avoid_chance');
					diceThrow = RandRangeF(0.01, 1.0);
					if(diceThrow < damageAvoidChance)
						continue;
				}
			}
			if( hasCriticalEffect && CriticalEffectTest(targets[i], criticalEffectType))
			{
				targets[i].ForceCriticalEffect(criticalEffectType, W2CriticalEffectParams(0,0,0,0), true);
			}
			damage = RandRangeF( minInitialDmg, maxInitialDmg );
			finalDmg =  damage - targets[i].GetCharacterStats().GetFinalAttribute( 'damage_reduction' );

			if( finalDmg < 1 )
				finalDmg = 1;
				
				
			damageBaseInt = RoundF(damage);
			resInt = RoundF(targets[i].GetCharacterStats().GetFinalAttribute( 'damage_reduction' ));
			damageInt = damageBaseInt - resInt;
			if(damageInt <=0)
			{
				damageInt = 0;
			}
			if(!damagedActors.Contains(targets[i]))
			{
				theHud.m_hud.CombatLogAdd("<span class='white'> " + GetLocStringByKeyExt("cl_bombdmg") + " </span><span class='red'>" + damageInt + " (" + AddDamageIcon() + damageBaseInt + " - " + AddArmorIcon() + resInt + ")</span>. ");
				targets[i].HitPosition( GetWorldPosition(), 'Attack', finalDmg, true, thePlayer, false, true, false );
	
				if(targets[i] != thePlayer)
				{
					
					health = targets[i].GetHealth();
					if(finalDmg >= health)
					{
						killedActors += 1;
						if(killedActors > 1)
						{
							Log("Achievement unlocked : ACH_EXPLOSIVE");
							theGame.UnlockAchievement('ACH_EXPLOSIVE');
						}
					}
				}
				damagedActors.PushBack(targets[i]);
			}
			/*else
			{
				targets[i].DecreaseHealth( finalDmg, true, thePlayer );		
			}*/
			ApplyAdditionalEffect( targets[i] );
		
		}
		damagedActors.Clear();
	}
	
	private function ApplyAdditionalEffect( target : CActor )
	{
	}
	
	private function ApplyAdditionalGlobalEffect()
	{
	}
	
	private function PlayAdditionalEffect()
	{
	}
	
	private function StopAdditionalEffect()
	{
	}
	
	private function ApplyTimerForEmmiting()
	{
		AddTimer( 'StartEmmiting', 0.5f, true );
	}
	
	private function RemoveTimerForEmmiting()
	{
		RemoveTimer( 'StartEmmiting' );
	}
	
	timer function StartEmmiting( time : float )
	{
		//Sprawdzanie, czy postac ma dany efekt nalozony, jesli nie, to nakladamy
		CriticalEffectCheckAndApply();
	}
	
	private function CheckFireTriggers()
	{
		var nodes	: array<CNode>;
		var i, size	: int;
		
		var trap	: CBaseTrap;
		var ddream	: CPetardDragonDream;
		var delay	: float;
		
		theGame.GetNodesByTag( 'TriggeredByFire', nodes );
		size = nodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			delay = CheckTriggeredNode( nodes[i] );
			if( delay == -1 )
				continue;
			
			delay = delay / 30;
				
			if( nodes[i].IsA('CBaseTrap') )
			{
				trap = (CBaseTrap)nodes[i];
				trap.RemoteTriggerTrap(delay);
			}
			else if( nodes[i].IsA('CPetardDragonDream') )
			{
				ddream = (CPetardDragonDream)nodes[i];
				ddream.AddTimer('TriggerFireWithDelay', delay, false);
			}
		}
	}
	
	private function CheckTriggeredNode( node : CNode ) : float
	{
		var area : CInteractionAreaComponent;
		var dist : float;
		
		if( node == this )
			return -1;
		
		area = (CInteractionAreaComponent)((CEntity)node).GetComponent('FireTrigger');
		if( !area )
		{
			Log("TriggeredByFire entity doesn't have FireTrigger component.");
			return 0.0f;
		}
		
		dist = VecLength( area.GetWorldPosition() - GetWorldPosition() );
		if( dist < area.GetRangeMax() + boundMax.X )
		{
			return dist;
		}
		
		return -1;
	}
}

state Exploading in CPetardRigid
{
	event OnEnterState()
	{
		parent.EnableCollisionInfoReportingForComponent( parent.rigidComponent, false, true );
	}
	
	entry function Exploade()
	{
		var temp : EulerAngles;
		
		Sleep( parent.activationDelay );
		parent.TeleportWithRotation( parent.rigidComponent.GetCenterOfMassInWorld(), temp );
		Sleep( 0.01f );
		parent.PlayEffect( 'effect' );
		parent.StopEffect( 'trail_fx' );
		
		virtual_parent.ApplyAdditionalGlobalEffect();
		
		if( parent.destroyOnActivation )
		{
			parent.rigidComponent.DisablePhysics();//.StopMovement();
			parent.StopEffect( 'trail_fx' );
			parent.ApplyAppearance( "destroyed" );
		}
			
		if( parent.durationOfEmmiting > 0 )
		{
			virtual_parent.PlayAdditionalEffect();
			virtual_parent.ApplyTimerForEmmiting();
			//MSZ - tu mamy tylko obrazenia plus jednorazowe nalozenie efektu, w timerze bedzie tylko sprawdzanie, czy aktorzy maja efekt
			parent.HarmActorsInRange();
			Sleep( parent.durationOfEmmiting );
			virtual_parent.RemoveTimerForEmmiting();
			parent.StopEffect( 'effect' );
			parent.emmitingStopped = true;
			virtual_parent.StopAdditionalEffect();
		}
		else
			parent.HarmActorsInRange();

		Sleep( 5.0f );
		parent.Destroy();
	}
}

//////////////////////////////////////////////////////////////////////////
//							Extended petards.							//
//		Usualy it should extend the ApplyAdditionalEffect function.		//
//////////////////////////////////////////////////////////////////////////

class CPetardExplosive extends CPetardRigid
{
	
	private function ApplyAdditionalGlobalEffect()
	{
		CheckFireTriggers();
	}
}

class CPetardRedHaze extends CPetardRigid
{
	private function ApplyAdditionalEffect( target : CActor )
	{
		var npc : CNewNPC;
		
		if( target.IsA( 'CNewNPC' ) )
		{
			npc = (CNewNPC)target;
			if(Rand(2) == 1)
			{
				if( npc.TestResByName( 'res_axii' ) )
					npc.EnterBerserk( 15.0 );
			}
		}
	}
}

class CPetardStinker extends CPetardRigid
{
	private function ApplyAdditionalEffect( target : CActor )
	{
		var npc : CNewNPC;
		npc = (CNewNPC)target;
		if(npc && npc.GetAttitude(thePlayer) == AIA_Hostile)
		{
			if(!target.GetCharacterStats().HasAbility('Stinker _Debuf') && !target.IsBoss())
			{
				target.AddTimer('StinkerDebufRemove', 60.0, false);
				target.GetCharacterStats().AddAbility('Stinker _Debuf');
			}
		}
	}
}

class CPetardDragonDream extends CPetardRigid
{
	var triggered : bool;
	
	timer function TriggerFireWithDelay( time : float )
	{
		TriggerFire();
	}
	
	function TriggerFire()
	{
		if( triggered || emmitingStopped || GetCurrentStateName() != 'Exploading' )
			return;
			
		triggered = true;
		
		StopEffect('effect');
		PlayEffect('explosion');
		
		HarmActorsInRange();
		
		CheckFireTriggers();
	}
	
	private function ApplyTimerForEmmiting()
	{
	}
	
	private function HarmActorsInRange()
	{
		if( triggered )
			super.HarmActorsInRange();
	}
}

class CPetardDancingStar extends CPetardRigid
{
	private function PlayAdditionalEffect()
	{
		var components	:	array<CComponent>;
		var position : Vector;
		var temp : EulerAngles;
		var i : int;
		
		components.PushBack( GetComponent( 'test_fire_1' ) );
		components.PushBack( GetComponent( 'test_fire_2' ) );
		components.PushBack( GetComponent( 'test_fire_3' ) );
		components.PushBack( GetComponent( 'test_fire_4' ) );
		components.PushBack( GetComponent( 'test_fire_5' ) );

		for( i = 0; i < 5; i += 1 )
		{
			position = components[i].GetWorldPosition();
			position.Z += 1;
			if( theGame.GetWorld().PointProjectionTest( position, temp, 2 ) )
			{
				position -= GetWorldPosition();
				components[i].SetPosition( position );
				PlayEffect( StringToName("fire_" + (i + 1)) );
			}
		}
	}
	
	private function StopAdditionalEffect()
	{
		StopEffect( 'fire_1' );
		StopEffect( 'fire_2' );
		StopEffect( 'fire_3' );
		StopEffect( 'fire_4' );
		StopEffect( 'fire_5' );
	}
	
	private function ApplyTimerForEmmiting()
	{
		AddTimer( 'HarmOnTime', 0.5f, true );
	}
	
	private function RemoveTimerForEmmiting()
	{
		RemoveTimer( 'HarmOnTime' );
	}
	
	timer function HarmOnTime( time : float )
	{
		ApplyAdditionalEffectsInRange();
	}
	
	private function ApplyAdditionalGlobalEffect()
	{
		CheckFireTriggers();
	}
}
