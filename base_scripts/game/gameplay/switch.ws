/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Switchable entity and a switch that switches it
/** Copyright © 2010
/***********************************************************************/

class CSwitch extends CGameplayEntity
{
	editable var m_switchableEntityTag : name;

	event OnInteraction( actionName : name, activator : CEntity )
	{
		var nodes : array< CNode >;
		var i : int;
		var switchable : CSwitchableEntity;
		
		theGame.GetNodesByTag( m_switchableEntityTag, nodes );
		
		for ( i = nodes.Size() - 1; i >= 0; i -= 1 )
		{
			switchable = (CSwitchableEntity) nodes[ i ];
			if ( switchable )
			{
				switchable.ToggleSwitch( false );
			}
		}
	}
}

class CSwitchableEntity extends CGameplayEntity
{
	saved editable var m_locked			: bool;
	saved editable var m_switchedOn		: bool;

	editable var m_switchOnEvent		: name;
	editable var m_switchOffEvent		: name;
	editable var m_switchOnForceEvent	: name;
	editable var m_switchOffForceEvent	: name;
	
	default m_locked		= false;
	default m_switchedOn	= false;
	
	final function Switch( on : bool, force : bool )
	{
		var deniedAreas : array< CComponent >;
		var i			: int;
		var behEvent	: name;
		var success		: bool;
		
		
		if ( !force && m_locked )
		{
			return;
		}
		
		if ( m_switchedOn != on )
		{
			// Select behavior event
			if ( on )
			{
				if ( force )
					behEvent = m_switchOnForceEvent;
				else
					behEvent = m_switchOnEvent;
			}
			else
			{
				if ( force )
					behEvent = m_switchOffForceEvent;
				else
					behEvent = m_switchOffEvent;
			}
			
			// Raise event
			success = RaiseEvent( behEvent );
			
			// If success, perform logic
			if ( success )
			{
				m_switchedOn = on;
				
				deniedAreas = GetComponentsByClassName( 'CDeniedAreaComponent' );
				for ( i = deniedAreas.Size() - 1; i >= 0; i -= 1 )
				{
					if ( deniedAreas[i].HasTag( 'switched_on' ) )
					{
						deniedAreas[i].SetEnabled( m_switchedOn );
					}
					else
					if ( deniedAreas[i].HasTag( 'switched_off' ) )
					{
						deniedAreas[i].SetEnabled( ! m_switchedOn );
					}
				}
			}
		}
	}
	
	final function ToggleSwitch( force : bool )
	{
		Switch( ! m_switchedOn, force );
	}
	
	final function Lock( lock : bool )
	{
		m_locked = lock;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		m_switchedOn = ! m_switchedOn;
		Switch( !m_switchedOn, true );
	}
}
