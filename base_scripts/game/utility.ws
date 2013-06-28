/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Various useful functions
/** Copyright © 2010
/***********************************************************************/

// Use FindClosestNode from node.ws

/*private function GetClosestNodeFromNodes( position : Vector, nodes : array< CNode > ) : CNode
{
	var shortestDist : float = 999999.9;
	var dist : float;
	var shortestIdx : int = -1;
	var i : int;
	
	for ( i = 0; i < nodes.Size(); i += 1 )
	{
		dist = VecDistanceSquared( position, nodes[i].GetWorldPosition() );
		if ( dist < shortestDist )
		{
			shortestDist = dist;
			shortestIdx = i;
		}
	}
	
	if ( shortestIdx >= 0 )
	{
		return nodes[ shortestIdx ];
	}
	else
	{
		return NULL;
	}
}*/
