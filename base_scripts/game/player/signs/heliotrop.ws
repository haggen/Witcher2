/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Heliotrop sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////

class CWitcherSignHeliotrop extends CGameplayEntity
{
	var m_affectedActors : array< CNewNPC >;
	
	editable var	heliotropEnterFx : CEntityTemplate;
	
	saved var 		elapsedTime	: float;
	saved var		duration	: float;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var heliotropSigns : array<CNode>;
		var otherHeliotrop : CWitcherSignHeliotrop;
		var i, size : int;
		theGame.GetNodesByTag('sign_heliotrop', heliotropSigns);
		size = heliotropSigns.Size();
		for(i = 0; i < size; i += 1)
		{
			otherHeliotrop = (CWitcherSignHeliotrop)heliotropSigns[i];
			if(otherHeliotrop && otherHeliotrop != this)
			{
				otherHeliotrop.Destroy();
			}
		}
		super.OnSpawned( spawnData );
		
		if( spawnData.restored )
		{
			AddTimer( 'LifetimeCounter', 1.0f, true );		
			PlayEffect('heliotrop_fx');
		}
	}

	final function Init()
	{
		var stats 			: CCharacterStats;
		var signsPower		: float;
		
		signsPower = thePlayer.GetSignsPowerBonus(SPBT_Time);
		stats		= thePlayer.GetCharacterStats();
		
		duration	= MaxF( 5.f, (float)stats.GetAttribute( 'heliotrop_duration' )*signsPower ); // MATI TODO: 10
		duration	-= 0.1f;
		elapsedTime = 0.f;
		
		AddTimer( 'LifetimeCounter', 1.0f, true );
		
		thePlayer.SetAdrenaline( 0 );
		
		PlayEffect('heliotrop_fx');

	}
	
	// --------------------------------------------------------------------
	// lifetime management
	// --------------------------------------------------------------------
	timer function LifetimeCounter( timeElapsed : float )
	{
		elapsedTime += 1.0f;
		if( elapsedTime > duration )
			Destroy();
	}
	
	event OnDestroyed()
	{
		var i : int;
		
		for ( i = 0; i < m_affectedActors.Size(); i += 1 )
		{
			m_affectedActors[ i ].OnHeliotropExit();
			m_affectedActors[ i ].StopEffect('heliotrop_fx');
		}
		theCamera.StopEffect('heliotrop');
		this.StopEffect('heliotrop_fx');
		
		
		super.OnDestroyed();
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CActor;
		var npc : CNewNPC;
		affectedEntity = (CActor) activator.GetEntity();
		
		if ( affectedEntity )
		{
			npc = (CNewNPC)affectedEntity;
			if(npc)
			{
				if ( npc.GetAttitude( thePlayer ) == AIA_Hostile )
				{
					m_affectedActors.PushBack( npc );
					npc.OnHeliotropEnter();
					npc.PlayEffect('heliotrop_fx');
					theGame.CreateEntity(heliotropEnterFx, npc.GetWorldPosition(), npc.GetWorldRotation());
					
				}
			}
			if( affectedEntity == thePlayer)
			{
				theCamera.PlayEffect('heliotrop');
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CActor;
		var npc : CNewNPC;
		affectedEntity = (CActor) activator.GetEntity();
		
		if ( affectedEntity )
		{
			npc = (CNewNPC)affectedEntity;
			if(npc)
			{
				if ( m_affectedActors.Contains( npc ) )
				{
					npc.OnHeliotropExit();
					m_affectedActors.Remove( npc );
					npc.StopEffect('heliotrop_fx');
					theGame.CreateEntity(heliotropEnterFx, npc.GetWorldPosition(), npc.GetWorldRotation());
				}
			}
			if( affectedEntity == thePlayer)
			{
				theCamera.StopEffect('heliotrop'); 
			}
		}
	}
}

exec function Adrenaline()
{
	thePlayer.SetAdrenaline( 150.f );
}
