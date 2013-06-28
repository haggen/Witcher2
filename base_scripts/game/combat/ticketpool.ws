/////////////////////////////////////////////
// Ticket
///////////////////////////////////////////// 
struct W2Ticket
{
	var actor : CActor;
	var assignTime : EngineTime;
};

enum W2TicketPoolType
{
	TPT_Attack,
	TPT_SecondaryAttack,
};

class W2TicketPool extends CObject
{
	private var m_poolType 				: W2TicketPoolType;
	
	private var m_tickets				: array< W2Ticket >;
	private var m_agents 				: array< CActor >;
	private var m_rangeMin, m_rangeMax 	: Vector;
	
	
	function Init( type : W2TicketPoolType, size : int )
	{
		m_poolType = type;
		m_tickets.Clear();
		m_tickets.Grow(size);		
		
		m_rangeMin = Vector( -20, -20, -2 );
		m_rangeMax = Vector(  20, 20, 2 );
	}
	
	// Registers an agent as a client for a ticket
	function RequestTicket( actor : CActor )
	{
		m_agents.PushBack( actor );
	}
	
	// Unregisters an agent as a ticket client
	function ReleaseTicket( actor : CActor )
	{
		var i, count : int;
	
		m_agents.Remove( actor );
		
		count = m_tickets.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( m_tickets[ i ].actor == actor )
			{
				m_tickets[ i ].actor = NULL;
				break;
			}
		}
	}
	
	// Checks if an agent has a ticket assigned
	function HasTicket( agent : CActor ) : bool 
	{		
		return FindTicket( agent, m_tickets ) >= 0;
	}
	
	// Returns the index of a ticket assigned to the agent
	function GetTicketIndex( agent : CActor ) : int 
	{
		return FindTicket( agent, m_tickets );
	}
	
	// Assigns tickets to agents that have the best chance of scoring an attack
	function UpdateAgents()
	{
		var nearbyAgents 												: array< CActor >;
		var testedAgent 												: CActor;
		var i, count, ticketsCount, bestAgentIdx, currHolderIdx 		: int;
		var priority 													: float;
		var ticketCandidates 											: array< CActor >;
		var priorities 													: array< float >;
		var newTickets													: array< W2Ticket >;
		var ticketChanges 												: array< CActor >;
		
		// aquire a sorted list of all nearby agents, and assign tickets to agents that are the closest
		ActorsStorageGetClosestByActor( GetOwner(), nearbyAgents, m_rangeMin, m_rangeMax, GetOwner(), false, true );
		count = nearbyAgents.Size();
		for ( i = 0; i < count; i += 1 )
		{
			testedAgent = nearbyAgents[ i ];
			if ( m_agents.Contains( testedAgent ) )
			{
				ticketCandidates.PushBack( testedAgent );
			}
		}
		
		// now that we have the candidates, it's time to fid out their priorities
		count = ticketCandidates.Size();
		for ( i = 0; i < count; i += 1 )
		{
			testedAgent = ticketCandidates[ i ];
			
			//distance based priority
			priority = VecDistance( GetOwner().GetWorldPosition(), testedAgent.GetWorldPosition() ) * 0.3f;
			
			// current ticket holders get a priority boost in order to minimize ticket switching
			if ( HasTicket( testedAgent ) )
			{
				priority -= 1.0;
			}
			priorities.PushBack( priority );
		}
		
		// prioritize the agents (it's O(n*m) now - OPTIMIZE )
		count = m_tickets.Size();
		newTickets.Grow( count );
		for ( i = 0; i < count; i += 1 )
		{
			if ( ticketCandidates.Size() <= 0 )
			{
				break;
			}
			bestAgentIdx = ArrayFindMinF( priorities );
			testedAgent = ticketCandidates[ bestAgentIdx ];
			ticketCandidates.Erase( bestAgentIdx );
			priorities.Erase( bestAgentIdx );
			
			newTickets[ i ].actor = testedAgent;
			newTickets[ i ].assignTime = theGame.GetEngineTime();
			
			currHolderIdx = FindTicket( testedAgent, m_tickets );
			if ( currHolderIdx < 0 )
			{
				// a new ticket holder - notify him about it
				ticketChanges.PushBack( testedAgent );
			}
			else
			{
				// erase the holder record for a bit - after this pass
				// the array should hold only holders we didn't find in the range query
				m_tickets.Erase( currHolderIdx );
			}
			
		}
		
		// leave surplus old ticket holders
		for ( ; i < count; i += 1 )
		{
			if ( m_tickets.Size() <= 0 )
			{
				break;
			}
			
			newTickets[ i ] = m_tickets[0];
			m_tickets.Erase( 0 );
		}
		
		// at this point the m_tickets array contains only records of agents
		// that are about to loose their tickets - notify them about it
		count = m_tickets.Size();
		for ( i = 0; i < count; i += 1 )
		{
			ticketChanges.PushBack( m_tickets[ i ].actor );
		}
		
		// memorize the new tickets table
		m_tickets = newTickets;
		
		// send the notifications out
		count = ticketChanges.Size();
		for ( i = 0; i < count; i += 1 )
		{
			ticketChanges[i].OnTicketChanged( m_poolType );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function GetOwner() : CActor
	{
		return thePlayer;
	}
		
	private function FindTicket( agent : CActor, arr : array< W2Ticket > ) : int 
	{
		var i, count : int;
			
		count = arr.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( arr[ i ].actor == agent )
			{
				return i;
			}
		}
		
		return -1;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// VISUAL DEBUG
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function UpdateVisualDebug( vd : CVisualDebug )
	{
		var dbgName : name;
		var actorPos : Vector;
	
		var i, s : int = m_tickets.Size();
		for( i = 0; i < s; i += 1 )
		{
			if( m_tickets[i].actor )
			{
				actorPos = m_tickets[i].actor.GetWorldPosition();
				dbgName = StringToName( StrFormat( "%1 %2", m_poolType, i ) );
				actorPos.Z += 1.9;
				vd.AddText( dbgName, dbgName, actorPos, true, 0, Color( 255, 128, 0), 0.5f );
			}
		}
	}
}
