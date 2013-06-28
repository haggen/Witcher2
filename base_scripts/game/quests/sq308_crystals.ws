//////////////////////////////////////////////
// class for endriag nests

enum EVranCrystalType
{
	EAardActivated,
	EIgniActivated,
}

class CSQ308_CrystalManager extends CGameplayEntity
{
	editable var	m_crystals		: array< name >;
	var 			m_counter 		: int;
	var i : int;
	var count : int;
	var crystal  :CSQ308_Crystal;
			
			
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
			
		if( spawnData.restored )
		{
			count = m_crystals.Size();
		
			for (i = 0; i < count; i += 1)
			{
				crystal = (CSQ308_Crystal)theGame.GetEntityByTag(m_crystals[i]);
				
				if (crystal.m_isActive == true)
				{
					m_counter+=1;
				}
			
			}
		}
	}
	
	function Add ( tag : name )
	{
		if( m_crystals.Contains(tag) )
		{
			m_counter+= 1;
			Check();
		}
	}
	
	function Remove ()
	{
		m_counter = 0;
		DeactivateAllCrystals();
		
	}
	
	function Check()
	{
		var tags 			: array< name >;
		var tag				: name;
		var i, count 		: int;
		
		if( m_counter == m_crystals.Size() )
		{
			tags = GetTags();
			count = tags.Size();
			for ( i = 0; i < count; i += 1 )
			{				
				FactsAdd( "CrystalSequenceCompleted_" + tags[i], 1 );
				DeactivateAllCrystals();
				DisableAllCrystals();
			}
		}
	}
	
	function DeactivateAllCrystals()
	{
		var i, count : int;
		var crystal  :CSQ308_Crystal;
		count = m_crystals.Size();
		
		for (i = 0; i < count; i += 1)
		{
			crystal = (CSQ308_Crystal)theGame.GetEntityByTag(m_crystals[i]);
			if (crystal)
			{
				crystal.Deactivate();
			}	
		}
	}
	
	function DisableAllCrystals()
	{
		var i, count : int;
		var crystal  :CSQ308_Crystal;
		count = m_crystals.Size();
		
		for (i = 0; i < count; i += 1)
		{
			crystal = (CSQ308_Crystal)theGame.GetEntityByTag(m_crystals[i]);
			if (crystal)
			{
				crystal.Disable();
			}	
		}
	}
}

class CSQ308_Crystal extends CActor
{
	saved var 		m_isActive : bool;
	saved var		m_isEnabled : bool;
	editable var 	m_vranCrystalType : EVranCrystalType;
	editable var 	m_crystalManagerTag : name;
	
	default m_isEnabled = true;
	var playerHealth : float;
	var decreaseAmount : float;
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
		
		EnablePathEngineAgent(false);
		EnablePhysicalMovement(false);
		EnableRagdoll(false);
		
		if( m_isEnabled )
		{
			if( spawnData.restored )
			{
				if ( m_isActive )
				{
					NotifyManager( true );
					
					if( m_vranCrystalType == EAardActivated )
					{
						PlayEffect('aard_active');
					}	
					else if( m_vranCrystalType == EIgniActivated )
					{
						PlayEffect('igni_active');
					}
				}
			}
		}
	}
	
	// Being hit event - return false to reject hit
	event OnBeingHit( out hitParams : HitParams ) { return true; }
	
	// What happens when the actor fails to block the hit
	function OnHitDamage( attacker : CActor, attackType : name, hitParams : HitParams )
	{
		
	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		super.OnHit( hitParams );
		
		decreaseAmount = (playerHealth * 0.2);
		playerHealth = thePlayer.GetHealth();
		thePlayer.HitPosition(this.GetWorldPosition(), 'Attack', 0.0, true );
		thePlayer.DecreaseHealth(decreaseAmount, true, thePlayer);
		PlayEffect('electric_hit');
		thePlayer.PlayEffect('lightning_hit_fx');
	}
	
	function Deactivate()
	{
		m_isActive = false;
		StopEffect('aard_active');
		StopEffect('igni_active');
	}

	function Disable()
	{
		m_isEnabled = false;
		SetAttackableByPlayerPersistent( false );
	}
	
	function HandleAardHit( aard : CWitcherSignAard )
	{
		if( m_vranCrystalType == EAardActivated && m_isActive == false && m_isEnabled == true )
		{
			PlayEffect('aard_active');
			m_isActive = true;
			NotifyManager( true );
		}
			
		if( m_vranCrystalType == EIgniActivated && m_isEnabled == true )
		{
			StopEffect('igni_active');
			m_isActive = false;
			NotifyManager( false );
		}
	}
	
	function HandleIgniHit( igni : CWitcherSignIgni )
	{
		if( m_vranCrystalType == EIgniActivated && m_isActive == false && m_isEnabled == true )
		{
			PlayEffect('igni_active');
			m_isActive = true;
			NotifyManager( true );
		}
			
		if( m_vranCrystalType == EAardActivated && m_isEnabled == true )
		{
			StopEffect('aard_active');
			m_isActive = false;
			NotifyManager( false );
		}
	}
	
	function NotifyManager( activate : bool )
	{
		var crystalManager	: CSQ308_CrystalManager;
		var crystalTags 	: array< name >;
		var tag				: name;
		var i, count 		: int;
		
		
		crystalManager = (CSQ308_CrystalManager)theGame.GetNodeByTag( m_crystalManagerTag );
		if ( crystalManager )
		{
			crystalTags = GetTags();
			count = crystalTags.Size();
			for ( i = 0; i < count; i += 1 )
			{
				tag = crystalTags[i];
				
				if ( activate )
				{
					crystalManager.Add( tag );
				}
				else
				{
					crystalManager.Remove();
					
				}
			}
		}
	}
}

