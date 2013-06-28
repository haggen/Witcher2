/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////

class CSq308Operator extends CNewNPC
{
	editable var electricalShieldDmgMin, electricalShieldDmgMax : float;
	var electricalShieldInProgress                              : bool;
	private saved var m_isFightStarted                          : bool;
	
	default m_isFightStarted = false;
	
	function EnterCombat( params : SCombatParams )
	{
		super.EnterCombat( params );
		attackPriority = 5;
		//EnterSq308OperatorMageCombat( params );
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		if ( spawnData.restored )
		{
			if ( m_isFightStarted )
			{
				theHud.HudTargetActorEx( this, true );
				theHud.m_hud.SetBossName( GetDisplayName() );
				theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
			}
		}
	}

	function StartBossFight()
	{
		theHud.HudTargetActorEx( this, true );
		theHud.m_hud.SetBossName( GetDisplayName() );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
		m_isFightStarted = true;
	}
	
	function EndBossFight()
	{
		theHud.m_hud.HideBossHealth();
		m_isFightStarted = false;
	}
	
	function IsMonster() : bool
	{
		return false;
	}
	
	private function HitDamage( hitParams : HitParams )
	{
		super.HitDamage( hitParams );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}
	
	
	private function HitPosition( hitPosition : Vector, attackType : name, damage : float, lethal : bool, optional source : CActor, optional forceHitEvent : bool, optional rangedAttack : bool, optional magicAttack : bool )
	{
		super.HitPosition( hitPosition, attackType, damage, lethal, source, forceHitEvent, rangedAttack, magicAttack );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}

	/*timer function ShieldOff( timeDelta : float )
	{
		parent.StopEffect('electric_shield_fx');
		parent.electricalShieldInProgress = false;
	}*/
	
	event OnHitAdditional( hitParams : HitParams )
	{
		var parentPos : Vector;
		var damageFinal : float;
		
		if( electricalShieldInProgress )
		{
			PlayEffect('electric_shield_hit');
			//thePlayer.PlayEffect('burning_fx');
			
			parentPos = GetWorldPosition();
			damageFinal = RandRangeF( electricalShieldDmgMin, electricalShieldDmgMax );
			
			thePlayer.HitPosition( parentPos, 'Attack_t1', damageFinal, true );
		}
	}
}

quest function SQ308_OperatorElectricShield( targetTag : name, enable : bool ) : bool
{
	var target : CSq308Operator;
	
	target = (CSq308Operator) theGame.GetNPCByTag( targetTag );
	
	if( enable )
	{
		target.electricalShieldInProgress = true;
		target.PlayEffect('electric_shield_fx');
		//target.AddTimer( 'ShieldOff', period, false );
	}
	else
	{
		target.electricalShieldInProgress = false;
		target.StopEffect('electric_shield_fx');
	}
	
	return true;
}


quest function QStartSq308OperatorBossFight()
{
	((CSq308Operator)theGame.GetEntityByTag( 'sq308_operator' )).StartBossFight();
}
quest function QEndSq308OperatorBossFight()
{
	((CSq308Operator)theGame.GetEntityByTag( 'sq308_operator' )).EndBossFight();
}
