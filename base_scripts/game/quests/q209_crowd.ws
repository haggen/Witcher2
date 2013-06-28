/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Formations management functions
/** Copyright © 2010
/***********************************************************************/

struct SQ209_MainAssault_Teleporter_Data
{
	var	actor 			: CActor;
	var	destination 	: CNode;
	var time			: float;
	var animationPlayed : bool;
};

class CQ209_MainAssault_Teleporter extends CTeleporter
{
	editable var m_deathDuration 	: float;
	private var	m_actors			: array< SQ209_MainAssault_Teleporter_Data >;
	
	default m_deathDuration 		= 3.0f;
	
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		AddTimer( 'Teleportation', 1.0f, true );
	}
	
	event OnTeleported( actor : CActor, destination : CNode )
	{
		var data : SQ209_MainAssault_Teleporter_Data;
		
		data.actor 				= actor;
		data.destination 		= destination;
		data.time 				= m_deathDuration + RandRangeF( 0.0, 2.0 );
		data.animationPlayed 	= false;
		
		m_actors.PushBack( data );
		
		return true;
	}
	
	timer function Teleportation( timeDelta : float )
	{
		var i, count : int;
		count = m_actors.Size();
		for ( i = count - 1; i >= 0; i -= 1 )
		{
			m_actors[i].time = m_actors[i].time - timeDelta;
			
			if ( m_actors[i].time <= 0.0 )
			{
				UseTeleporter( m_actors[i].actor, m_actors[i].destination );
				m_actors[i].actor.RaiseForceEvent( 'Idle' );	
				m_actors.Erase( i );
			}
			else if ( m_actors[i].time <= m_deathDuration && m_actors[i].animationPlayed == false )
			{
				m_actors[i].animationPlayed = true;
				m_actors[i].actor.RaiseForceEvent( 'Death' );	
			}
		}
	}
};
