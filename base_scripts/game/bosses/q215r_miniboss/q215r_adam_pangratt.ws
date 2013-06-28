/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////

class CDetmold extends CNewNPC
{
	editable var electricalShieldDmgMin, electricalShieldDmgMax : float;
	var electricalShieldInProgress : bool;
	
	function EnterCombat( params : SCombatParams )
	{
		attackPriority = 5;
		super.EnterCombat( params );
		//EnterDetmoldMageCombat( params );
	}
	
	function StartBossFight()
	{
		theHud.m_hud.SetBossName( this.GetDisplayName() );
		//theHud.HudTargetActorEx( this, true );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
	}	
	
	function StopBossFight()
	{
		theHud.m_hud.HideBossHealth();
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
	
	/*
	function IsBoss() : bool
	{
		return true;
	}
	*/
	
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

state DetmoldMageCombat in CDetmold extends TreeCombatMage
{
	timer function ShieldOff( timeDelta : float )
	{
		parent.StopEffect('electric_shield_fx');
		parent.electricalShieldInProgress = false;
	}
	
	event OnHit( hitParams : HitParams )
	{
		var parentPos : Vector;
		var damageFinal : float;
		
		if( parent.electricalShieldInProgress )
		{
			parent.PlayEffect('electric_shield_hit');
			//thePlayer.PlayEffect('burning_fx');
			
			parentPos = parent.GetWorldPosition();
			damageFinal = RandRangeF( parent.electricalShieldDmgMin, parent.electricalShieldDmgMax );
			
			thePlayer.HitPosition( parentPos, 'Attack_t1', damageFinal, true );
		}
		
		super.OnHit( hitParams );
	}

	entry function EnterDetmoldMageCombat( params : SCombatParams )
	{
		parent.attackPriority = 5;
		TreeCombatMage( params );
	}
}

quest function Q215r_DetmoldElectricShield( targetTag : name, enable : bool ) : bool
{
	var target : CDetmold;
	
	target = (CDetmold) theGame.GetNPCByTag( targetTag );
	
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

quest function Q215r_DetmoldBossBar( bossTag : name, enable : bool )
{
	var detmold : CDetmold;

	detmold = (CDetmold) theGame.GetNPCByTag( bossTag );
	
	if( enable )
	{
		detmold.StartBossFight();
	}
	else
	{
		detmold.StopBossFight();
	}
}

quest function Q215r_DetmoldBossBarReset( bossTag : name )
{
	var target : CDetmold;
	
	target = (CDetmold) theGame.GetNPCByTag( bossTag );

	theHud.m_hud.SetBossHealthPercent( target.GetHealthPercentage() );
}

///////////////////////////////////////////////////////////////////////////////////////
// Class for generic boss NPC
///////////////////////////////////////////////////////////////////////////////////////

class CBossNpc extends CNewNPC
{
	function StopBossFight()
	{
		theHud.m_hud.HideBossHealth();
	}
	
	function StartBossFight()
	{
		theHud.m_hud.SetBossName( this.GetDisplayName() );
		theHud.m_hud.SetBossHealthPercent( GetHealthPercentage() );
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
}

quest function QShowBossNpcBar( bossTag : name, show : bool )
{
	var boss : CBossNpc;

	boss = (CBossNpc) theGame.GetNPCByTag( bossTag );
	
	if( show )
	{
		boss.StartBossFight();
	}
	else
	{
		boss.StopBossFight();
	}
}