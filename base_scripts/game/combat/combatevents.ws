/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** CombatEvents system
/** Copyright © 2010
/***********************************************************************/

enum W2CombatEventsType
{
	CECT_NPCSword,
	CECT_NPCSword_Skilled,
	CECT_NPCDual,
	CECT_NPCTwoHanded,
	CECT_NPCShielded,
	CECT_NPCPoleArm,
	CECT_NPCMage,
	CECT_NPCBow,
	CECT_NPCFist,
	CECT_Arachas,
	CECT_Bullvore,
	CECT_Drowner,
	CECT_Endriag,
	CECT_Gargoyle,
	CECT_Harpie,
	CECT_KnightWraith,
	CECT_Nekker,
	CECT_Rotfiend,
	CECT_Troll,
	CECT_Golem,
	CECT_Wraith,
	CECT_Bruxa,
	CECT_Draug,
	CECT_Riszon,
	CECT_Warewolf,
	CECT_NPCTwoHandedThrow,
	CECT_MAX	// MAX must be last
};

/////////////////////////////////////////////////////////////////////
// W2CombatEventsManager
/////////////////////////////////////////////////////////////////////
class W2CombatEventsManager extends CObject
{
	var combatEventsArray : array<W2CombatEvents>;
	
	function Initialize()
	{
		combatEventsArray.Grow(CECT_MAX);
	}

	function GetCombatEvents( type : W2CombatEventsType ) : W2CombatEvents
	{
		return combatEventsArray[type];
	}
	
	function CreateCombatEvents( type : W2CombatEventsType ) : W2CombatEvents
	{		
		combatEventsArray[type] = new W2CombatEvents in this;	
		combatEventsArray[type].type = type;
		return combatEventsArray[type];
	}
}

/////////////////////////////////////////////////////////////////////
// W2CombatEvents
/////////////////////////////////////////////////////////////////////
class W2CombatEvents extends CObject
{
	var type : W2CombatEventsType;	
	var idleEnums				: array<W2BehaviorCombatIdle>;	
	var attackEnums				: array<W2BehaviorCombatAttack>;	
	var circleLeftEnums			: array<W2BehaviorCombatAttack>;
	var circleRightEnums		: array<W2BehaviorCombatAttack>;
	var chargeEnums				: array<W2BehaviorCombatAttack>;
	var throwEnums				: array<W2BehaviorCombatAttack>;
	var chargeShortEnums		: array<W2BehaviorCombatAttack>;
	var hitLightEnums			: array<W2BehaviorCombatHit>;
	var hitHeavyEnums			: array<W2BehaviorCombatHit>;
	var hitParryEnums			: array<W2BehaviorCombatHit>;
	var hitReflectedEnums		: array<W2BehaviorCombatHit>;
	var dodgeBackEnums			: array<W2BehaviorCombatHit>;
	var dodgeLeftEnums			: array<W2BehaviorCombatHit>;
	var dodgeRightEnums			: array<W2BehaviorCombatHit>;
	var specialAttackEnums1		: array<W2BehaviorCombatAttack>;
	var specialAttackEnums2		: array<W2BehaviorCombatAttack>;
	var specialAttackEnums3		: array<W2BehaviorCombatAttack>;
	var specialAttackEnums4		: array<W2BehaviorCombatAttack>;
	var specialAttackEnums5		: array<W2BehaviorCombatAttack>;
	
	var idleEventNames 			: array<name>;		
	var attackEventNames 		: array<name>;	
	var circleLeftEventNames 	: array<name>;
	var circleRightEventNames 	: array<name>;
	var chargeEventNames 		: array<name>;
	var chargeShortEventNames 	: array<name>;
	var hitEventNames_t0		: array<name>;
	var hitEventNames_t1		: array<name>;
	var dodgeEventNames			: array<name>;
	
	function ClearAll()
	{
		idleEnums.Clear();
		attackEnums.Clear();		
		chargeEnums.Clear();
		chargeShortEnums.Clear();
		throwEnums.Clear();
		circleLeftEnums.Clear();
		circleRightEnums.Clear();
		hitLightEnums.Clear();
		hitHeavyEnums.Clear();
		hitParryEnums.Clear();
		hitReflectedEnums.Clear();
		dodgeBackEnums.Clear();
		dodgeLeftEnums.Clear();
		dodgeLeftEnums.Clear();
		
		specialAttackEnums1.Clear();
		specialAttackEnums2.Clear();
		specialAttackEnums3.Clear();
		specialAttackEnums4.Clear();
		specialAttackEnums5.Clear();
	
		idleEventNames.Clear();		
		attackEventNames.Clear();		
		circleLeftEventNames.Clear();
		circleRightEventNames.Clear();
		chargeEventNames.Clear();
		chargeShortEventNames.Clear();
		hitEventNames_t0.Clear();
		hitEventNames_t1.Clear();
		dodgeEventNames.Clear();
	}
}

/////////////////////////////////////////////////////////////////////
// W2CombatEventsProxy
/////////////////////////////////////////////////////////////////////
class W2CombatEventsProxy extends CObject 
{
	var combatEvents : W2CombatEvents;
	
	var circleDisabled : bool;
	var chargeDisabled : bool;
	
	var lastAttack		: byte;
	var lastIdle		: byte;
	var lastCircleLeft	: byte;
	var lastCircleRight : byte;
	var lastCharge		: byte;
	var lastThrow		: byte;
	var lastChargeShort : byte;
	var lastDodge		: byte;
	var lastHit_t0		: byte;
	var lastHit_t1		: byte;
	var lastHitLight	: byte;
	var lastHitHeavy	: byte;
	var lastHitParry	: byte;	
	var lastHitReflected: byte;
	var lastDodgeBack	: byte;
	var lastDodgeLeft	: byte;
	var lastDodgeRight	: byte;
	var lastSpecialAttack1	: byte;
	var lastSpecialAttack2	: byte;
	var lastSpecialAttack3	: byte;
	var lastSpecialAttack4	: byte;
	var lastSpecialAttack5	: byte;
	
	public function GetCombatEvents() : W2CombatEvents { return combatEvents; }
	public function EnableCircle( flag : bool ) { circleDisabled = !flag; }
	public function EnableCharge( flag : bool ) { chargeDisabled = !flag; }
	
	public function GetIdleEnum() : W2BehaviorCombatIdle
	{
		var s : int;
		s = combatEvents.idleEnums.Size();
		if( s == 0 )
			return BCI_None;
		else
		{
			lastIdle = RandDifferent( s, lastIdle );
			return combatEvents.idleEnums[Rand(s)];
		}
	}
	
	public function GetAttackEnum() : W2BehaviorCombatAttack
	{
		var s : int;		
		s = combatEvents.attackEnums.Size();
		if( s == 0 )
			return BCA_None;
		else
		{
			lastAttack = RandDifferent( s, lastAttack );
			return combatEvents.attackEnums[lastAttack];
		}
	}
		
	public function GetCircleEnum( offSlot : EOffSlot ) : W2BehaviorCombatAttack
	{
		var s : int;
		
		if( circleDisabled )
			return BCA_None;
		
		if( offSlot == OS_Right )
		{
			s = combatEvents.circleRightEnums.Size();
			if( s == 0 )			
				return BCA_None;			
			else
			{
				lastCircleRight = RandDifferent( s, lastCircleRight );
				return combatEvents.circleRightEnums[lastCircleRight];
			}
		}		
		else
		{
			s = combatEvents.circleLeftEnums.Size();
			if( s == 0 )			
				return BCA_None;			
			else
			{	
				lastCircleLeft = RandDifferent( s, lastCircleLeft );
				return combatEvents.circleLeftEnums[Rand(s)];	
			}
		}
	}
	
	public function GetChargeEnum() : W2BehaviorCombatAttack
	{
		var s : int;
		
		if( chargeDisabled )
			return BCA_None;
		
		s = combatEvents.chargeEnums.Size();
		if( s == 0 )
			return BCA_None;
		else
		{
			lastCharge = RandDifferent( s, lastCharge );
			return combatEvents.chargeEnums[lastCharge];
		}
	}
	public function GetSpecialAttackEnum(specialAttakSet : ESpecialAttackSet) : W2BehaviorCombatAttack
	{
		var s : int;
		
		if(specialAttakSet == SAS_Set1)
		{
			s = combatEvents.specialAttackEnums1.Size();
			if( s == 0 )
				return BCA_None;
			else
			{
				lastSpecialAttack1 = RandDifferent( s, lastSpecialAttack1 );
				return combatEvents.specialAttackEnums1[lastSpecialAttack1];
			}
		}
		else if(specialAttakSet == SAS_Set2)
		{
			s = combatEvents.specialAttackEnums2.Size();
			if( s == 0 )
				return BCA_None;
			else
			{
				lastSpecialAttack2 = RandDifferent( s, lastSpecialAttack2 );
				return combatEvents.specialAttackEnums2[lastSpecialAttack2];
			}
		}
		else if(specialAttakSet == SAS_Set3)
		{
			s = combatEvents.specialAttackEnums3.Size();
			if( s == 0 )
				return BCA_None;
			else
			{
				lastSpecialAttack3 = RandDifferent( s, lastSpecialAttack3 );
				return combatEvents.specialAttackEnums3[lastSpecialAttack3];
			}
		}
		else if(specialAttakSet == SAS_Set4)
		{
			s = combatEvents.specialAttackEnums4.Size();
			if( s == 0 )
				return BCA_None;
			else
			{
				lastSpecialAttack4 = RandDifferent( s, lastSpecialAttack4 );
				return combatEvents.specialAttackEnums4[lastSpecialAttack4];
			}
		}
		else if(specialAttakSet == SAS_Set5)
		{
			s = combatEvents.specialAttackEnums5.Size();
			if( s == 0 )
				return BCA_None;
			else
			{
				lastSpecialAttack5 = RandDifferent( s, lastSpecialAttack5 );
				return combatEvents.specialAttackEnums5[lastSpecialAttack5];
			}
		}
	}
	public function GetThrowEnum() : W2BehaviorCombatAttack
	{
		var s : int;
		
		
		s = combatEvents.throwEnums.Size();
		if( s == 0 )
			return BCA_None;
		else
		{
			lastThrow = RandDifferent( s, lastThrow );
			return combatEvents.throwEnums[lastThrow];
		}
	}
	
	public function GetChargeShortEnum() : W2BehaviorCombatAttack
	{
		var s : int;
		
		if( chargeDisabled )
			return BCA_None;
		
		s = combatEvents.chargeShortEnums.Size();
		if( s == 0 )
			return BCA_None;
		else
		{
			lastChargeShort = RandDifferent( s, lastChargeShort );
			return combatEvents.chargeShortEnums[lastChargeShort];
		}
	}
	
	public function GetHitLightEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.hitLightEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastHitLight = RandDifferent( s, lastHitLight );
			return combatEvents.hitLightEnums[lastHitLight];
		}
	}
	
	public function GetHitHeavyEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.hitHeavyEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastHitHeavy = RandDifferent( s, lastHitHeavy );
			return combatEvents.hitHeavyEnums[lastHitHeavy];
		}
	}
	
	public function GetHitParryEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.hitParryEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastHitParry = RandDifferent( s, lastHitParry );
			return combatEvents.hitParryEnums[lastHitParry];
		}
	}
	
	public function GetHitReflectedEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.hitReflectedEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastHitReflected = RandDifferent( s, lastHitReflected );
			return combatEvents.hitReflectedEnums[lastHitReflected];
		}
	}
	
	private final function GetDodgeBackEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.dodgeBackEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastDodgeBack = RandDifferent( s, lastDodgeBack );
			return combatEvents.dodgeBackEnums[lastDodgeBack];
		}	
	}
	
	private final function GetDodgeLeftEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.dodgeLeftEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastDodgeLeft = RandDifferent( s, lastDodgeLeft );
			return combatEvents.dodgeLeftEnums[lastDodgeLeft];
		}	
	}
	
	private final function GetDodgeRightEnum() : W2BehaviorCombatHit
	{
		var s : int;
				
		s = combatEvents.dodgeRightEnums.Size();
		if( s == 0 )
			return BCH_None;
		else
		{
			lastDodgeRight = RandDifferent( s, lastDodgeRight );
			return combatEvents.dodgeRightEnums[lastDodgeRight];
		}	
	}
	
	private final function GetDodgeEnum( dir : EDirection ) : W2BehaviorCombatHit
	{		
		if( dir == D_Back )
		{
			return GetDodgeBackEnum();
		}
		else if( dir == D_Left )
		{
			return GetDodgeLeftEnum();
		}
		else if( dir == D_Right )
		{
			return GetDodgeRightEnum();
		}
		
		return BCH_None;
	}
	
	//////////////////////////////////////////////////////////////
	public function GetAttackEventName() : name
	{
		var s : int;
		s = combatEvents.attackEventNames.Size();
		if( s == 0 )
			return '';
		else
		{
			lastAttack = RandDifferent( s, lastAttack );
			return combatEvents.attackEventNames[lastAttack];
		}
	}
		
	public function GetIdleEventName() : name
	{
		var s : int;
		s = combatEvents.idleEventNames.Size();
		if( s == 0 )
			return '';
		else
		{
			lastIdle = RandDifferent( s, lastIdle );
			return combatEvents.idleEventNames[lastIdle];
		}
	}
	
	public function GetCircleEventName( offSlot : EOffSlot ) : name
	{
		var s : int;
		
		if( circleDisabled )
			return '';
		
		if( offSlot == OS_Right )
		{
			s = combatEvents.circleRightEventNames.Size();
			if( s == 0 )			
				return '';			
			else
			{
				lastCircleRight = RandDifferent( s, lastCircleRight );
				return combatEvents.circleRightEventNames[lastCircleRight];
			}
		}		
		else
		{
			s = combatEvents.circleLeftEventNames.Size();
			if( s == 0 )			
				return '';			
			else
			{
				lastCircleLeft = RandDifferent( s, lastCircleLeft );
				return combatEvents.circleLeftEventNames[lastCircleLeft];	
			}
		}
	}
	
	public function GetChargeAttackEventName() : name
	{
		var s : int;
		
		if( chargeDisabled )
			return '';
		
		s = combatEvents.chargeEventNames.Size();
		if( s == 0 )
			return '';
		else
		{
			lastCharge = RandDifferent( s, lastCharge );
			return combatEvents.chargeEventNames[lastCharge];
		}
	}
	
	public function GetChargeAttackShortEventName() : name
	{
		var s : int;
		
		if( chargeDisabled )
			return '';
		
		s = combatEvents.chargeShortEventNames.Size();
		if( s == 0 )
			return '';
		else
		{
			lastChargeShort = RandDifferent( s, lastChargeShort );
			return combatEvents.chargeShortEventNames[lastChargeShort];
		}
	}
	
	private final function GetHitEventName_t0() : name
	{
		var s : int;
		s = combatEvents.hitEventNames_t0.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			lastHit_t0 = RandDifferent( s, lastHit_t0 );
			return combatEvents.hitEventNames_t0[lastHit_t0];
		}
	}
	
	private final function GetHitEventName_t1() : name
	{
		var s : int;
		s = combatEvents.hitEventNames_t1.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{
			lastHit_t1 = RandDifferent( s, lastHit_t1 );	
			return combatEvents.hitEventNames_t1[lastHit_t1];
		}
	}
	
		
	private final function GetDodgeEventName() : name
	{
		var s : int;
		s = combatEvents.dodgeEventNames.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			lastDodge = RandDifferent( lastDodge, lastDodge );
			return combatEvents.dodgeEventNames[lastDodge];
		}
	}
	
	private final function GetDodgeEventNameFiltered( subStrings : array<name> ) : name
	{
		var i,j,s : int;
		var filteredNames : array<name>;
		var ok : bool;
		s = combatEvents.dodgeEventNames.Size();
		
		if( subStrings.Size() == 0 )
		{
			return GetDodgeEventName();
		}
		
		for( i=0; i<s; i+=1 )
		{
			ok = true;
			for( j=0; j<subStrings.Size(); j+=1 )
			{
				if( StrFindFirst(combatEvents.dodgeEventNames[i], subStrings[j]) >= 0 )
				{
					ok = false;
					break;
				}
			}
			
			if( ok )
			{
				filteredNames.PushBack( combatEvents.dodgeEventNames[i]);
			}
		}
		
		s = filteredNames.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return filteredNames[Rand(s)];
		}
	}	
};
