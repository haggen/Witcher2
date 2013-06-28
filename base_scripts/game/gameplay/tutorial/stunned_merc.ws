class W2TutorialMercenary extends CNewNPC
{
	editable var stunDamageMin 		: float;
	editable var stunDamageMax 		: float;
	editable var stunDurationMin 	: float;
	editable var stunDurationMax 	: float;
	editable var isStunInfinite		: bool;

	default stunDamageMin = 0;
	default stunDamageMax = 0;
	default stunDurationMin = 5;
	default stunDurationMax = 10;
	default isStunInfinite = true;
		
	function HandleAardHit( aard : CWitcherSignAard )
	{
		if( isStunInfinite )
			ForceCriticalEffect( CET_Stun, W2CriticalEffectParams( 0, 0, 100000, 100000 ) );
		else	
			ForceCriticalEffect( CET_Stun, W2CriticalEffectParams( stunDamageMin, stunDamageMax, stunDurationMin, stunDurationMax ) );
	}
}