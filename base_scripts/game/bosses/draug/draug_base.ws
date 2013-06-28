/////////////////////////////////////////////
// Draug class
/////////////////////////////////////////////
/*
enum EDraugAttack
{
	DA_Normal,
	DA_Strong,
	DA_Charge,
	DA_Tornado
};
enum EDraugState
{
	DS_Shield,
	DS_TwoHanded,
	DS_GCBattle
};

class CDraugBossBase extends CNewNPC
{
	var attackDistance : float;
	var currentDraugState : EDraugState;
	var currentHealth, maxHealth, currentShield, maxShield : float;
	var showHealth, showShield : int;
	var tornadoSwitch, chargeSwitch, distantAttackSwitch : bool;
	var startTime, currentTime: float;
	var counterAttackMeter, counterAttackMeterMax : int;
	var startPosition : Vector;
	var canBeHit : bool;
	var canPlayDamageAnim : bool;
	var tornadoCooldown, chargeCooldown, specialAttackForce, rocksCooldown, arrowsCooldown, distantAttackCooldown : bool;
	var actionCooldownDefault, distantAttackCooldownDefault, specialAttackCooldownDefault, arrowsCooldownDefault, rockCooldownDefault : float;
	editable var draugArrows : CEntityTemplate;
	editable var draugCaveRockSelector : CEntityTemplate;
	
	default currentDraugState = DS_Shield;
	default tornadoCooldown = false;
	default canPlayDamageAnim = true;
	default specialAttackForce = false;
	default chargeCooldown = false;
	default attackDistance = 2.5;
	default tornadoSwitch = false;
	default chargeSwitch = false;
	default distantAttackSwitch = false;
	default arrowsCooldown = false;
	default rocksCooldown = false;	
	default distantAttackCooldown = false;
	default actionCooldownDefault = 10.0;
	default arrowsCooldownDefault = 10.0;
	default rockCooldownDefault = 10.0;
	default distantAttackCooldownDefault = 10.0;
	default specialAttackCooldownDefault = 10.0;
	default canBeHit = true;
	default counterAttackMeterMax = 10;
	default counterAttackMeter = 0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		DraugInitialize();
	}
	event OnBeingHit(out hitParams : HitParams);
	event OnHit(hitParams : HitParams);
	
	function IsBoss() : bool
	{
		return true;
	}
	
	function SetDistantAttackSwitch(flag : bool)
	{
		distantAttackSwitch = flag;
	}
	
	function UpdateBossHealth()
	{
		var healthToMaxHealth, shieldToMaxShield : float;
		healthToMaxHealth = currentHealth/maxHealth;
		shieldToMaxShield = currentShield/maxShield;
		showShield = RoundF(100 * shieldToMaxShield);
		showHealth = RoundF(100 * healthToMaxHealth);
		theHud.m_hud.SetBossHealthPercent( showHealth );
		theHud.m_hud.SetBossArmorPercent( showShield );
	}
	
	function DraugGetIsCharge() : bool
	{
		return chargeSwitch;
	}
	
	function DraugInitialize();
	
	function StopCharge();
	
	function DraugSetImmortal(flag : bool)
	{
		canBeHit = !flag;
	}
	function DraugEquipItems();
	function DraugUnequipItems()
	{
		var shield : SItemUniqueId;
		var sword : SItemUniqueId;
		shield = GetInventory().GetItemId('DraugShield1');
		sword = GetInventory().GetItemId('DraugSword');
		GetInventory().UnmountItem(shield);
		GetInventory().UnmountItem(sword);
	}
	function DraugUnequipShield()
	{
		var shield : SItemUniqueId;
		shield = GetInventory().GetItemId('DraugShield1');
		GetInventory().UnmountItem(shield);
	}
	//PlayerInRange - checks if player is in specified dragon action range
	function PlayerInRange( rangeNameString : string ) : bool
	{
		var playerPosition : Vector;
		var range : CInteractionAreaComponent;
		playerPosition = thePlayer.GetWorldPosition();
		range = (CInteractionAreaComponent)this.GetComponent( rangeNameString );
		if( range )
		{
			return range.ActivationTest( thePlayer );
		}
		else
		{
			Log( "DRAUG BOSS ERROR: No -- "+ rangeNameString +" -- CInteractionAreaComponent in draug entity" );
			return false;			
		}			
	}
	timer function DraugTornadoTimer(timeDelta : float)
	{
		tornadoSwitch = false;
	}
	timer function TornadoCooldownOff(timeDelta : float)
	{
		tornadoCooldown = false;
	}
	function TornadoCooldown(cooldownTime : float)
	{
		tornadoCooldown = true;
		AddTimer('TornadoCooldownOff', cooldownTime, false);
	}
	timer function ChargeCooldownOff(timeDelta : float)
	{
		chargeCooldown = false;
	}
	timer function SpecialAttackForceOn(timeDelta : float)
	{
		specialAttackForce = true;
	}
	timer function ArrowsAttackCooldownOff(timeDelta : float)
	{
		arrowsCooldown = false;
	}
	function ArrowsAttackCooldown(cooldownTime : float)
	{
		arrowsCooldown = true;
		AddTimer('ArrowsAttackCooldownOff', cooldownTime, false);
	}
	timer function RocksAttackCooldownOff(timeDelta : float)
	{
		rocksCooldown = false;
	}
	function RocksAttackCooldown(cooldownTime : float)
	{
		rocksCooldown = true;
		AddTimer('RocksAttackCooldownOff', cooldownTime, false);
	}
	timer function DistantAttackCooldownOff(timeDelta : float)
	{
		distantAttackCooldown = false;
	}
	function DistantAttackCooldown(cooldownTime : float)
	{
		distantAttackCooldown = true;
		AddTimer('DistantAttackCooldownOff', cooldownTime, false);
	}
	function SpecialAttackForceCooldown(cooldownTime : float)
	{
		specialAttackForce = false;
		AddTimer('SpecialAttackForceOn', cooldownTime, false);
	}
	function ChargeCooldown(cooldownTime : float)
	{
		chargeCooldown = true;
		AddTimer('ChargeCooldownOff', cooldownTime, false);
	}
	function RemoveAllTimers()
	{
		chargeCooldown = false;
		tornadoCooldown = false;
		RemoveTimer('TornadoCooldownOff');
		RemoveTimer('ChargeCooldownOff');
	}
	//StartTimeCounting - sets current engine time as startTime variable for CheckTimePassed() method.
	function StartTimeCounting()
	{
		startTime = EngineTimeToFloat(theGame.GetEngineTime());
	}
	//CheckTimePassed - checks if given time has passed. Must be preceded by StartTimeCounting() method call. 
	function CheckTimePassed(time : float) : bool
	{
		var currentTime: float;
		currentTime = EngineTimeToFloat(theGame.GetEngineTime());
		if(currentTime - startTime > time)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function StartDistanceMeasurement()
	{
		startPosition = this.GetWorldPosition();
	}
	function CheckDistanceGreaterThen(distanceToCheck : float) : bool
	{
		var currentPosition : Vector;
		var currentDistance : float;
		currentPosition = this.GetWorldPosition();
		currentDistance = VecDistance(startPosition, currentPosition);
		if(currentDistance > distanceToCheck)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function ChooseDraugAttackType(draugAttack : EDraugAttack) : name
	{
		var attackType : name;
		if(draugAttack == DA_Normal)
		{
			attackType = 'Attack_t1';
		}
		else if(draugAttack == DA_Charge)
		{
			attackType = 'Attack_boss_t1';
		}
		else if(draugAttack == DA_Tornado)
		{
			attackType = 'Attack_boss_t1';
		}
		else if(draugAttack == DA_Strong)
		{
			attackType = 'Attack_boss_t1';
		}
		else
		{
			attackType = 'Attack_t1';
		}
		return attackType;
	}
	function ComputeDraugDamage(draugAttack : EDraugAttack) : float
	{
		var player_Reduction : float;
		var draugFinalDamage, draugDamage : float;
		
		if(draugAttack == DA_Normal)
		{
			draugDamage = this.GetCharacterStats().GetAttribute('damage_normal');
		}
		else if(draugAttack == DA_Strong)
		{
			draugDamage = this.GetCharacterStats().GetAttribute('damage_strong');
		}
		else if(draugAttack == DA_Charge)
		{
			draugDamage = this.GetCharacterStats().GetAttribute('damage_charge');
		}
		else if(draugAttack == DA_Tornado)
		{
			draugDamage = this.GetCharacterStats().GetAttribute('damage_tornado');
		}
		else
		{
			draugDamage = this.GetCharacterStats().GetAttribute('damage_normal');
		}
		
		player_Reduction = thePlayer.GetCharacterStats().GetFinalAttribute('damage_reduction');
		draugFinalDamage = draugDamage - player_Reduction;
		if (draugFinalDamage <= 0)
		{
			draugFinalDamage = 0;
		}
		return draugFinalDamage;
	}
	function DraugHitCheck(draugAttack : EDraugAttack) : bool
	{
		if(draugAttack == DA_Normal && this.InAttackRange(thePlayer))
		{
			return true;
		}
		else if(draugAttack == DA_Strong && this.InAttackRange(thePlayer))
		{
			return true;
		}
		else if(draugAttack == DA_Charge && PlayerInRange("CLOSE_ATTACK"))
		{
			return true;
		}
		else if(draugAttack == DA_Tornado && PlayerInRange("TORNADO_ATTACK"))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function DraugAttack(draugAttack : EDraugAttack, target : CActor)
	{
		var damage : float;
		var attackType : name;
		var draugPos : Vector;
		if(DraugHitCheck(draugAttack))
		{
			draugPos = this.GetWorldPosition();
			damage = ComputeDraugDamage(draugAttack);
			attackType = ChooseDraugAttackType(draugAttack);
			target.HitPosition(draugPos, attackType, damage, true);
		}
	}
}*/