/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the actors storage
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Actors Storage functions
/////////////////////////////////////////////

// Queries the storage for actors closest to the specified actor.
//
// The query is executed over an axis aligned bounding box, specified
// relative to the central actor's position.
// One can also specify how many actors is he interested in querying 
// - the query will stop as soon as that many actors are found. This
// can significantly improve query time.
//
// This method is optimized for speed.
import function ActorsStorageGetClosestByActor( centralActor : CActor, 
												out output : array< CActor >,
												optional relMinBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
												optional relMaxBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
												optional actorToExclude : CActor,	/* = NULL */
												optional useZBounds : bool,			/* = true */
												optional onlyAlive : bool,			/* = true */
												optional maxActors : int			/* = INT_MAX */);

// Queries the storage for actors closest to the specified actor.
//
// As the other one, this qery is executed over an AABB. However
// it's slower than it's predecessor.
import function ActorsStorageGetClosestByPos(	position : Vector, 
												out output : array< CActor >,
												optional relMinBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
												optional relMaxBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
												optional actorToExclude : CActor,	/* = NULL */
												optional useZBounds : bool,			/* = true */
												optional onlyAlive : bool,			/* = true */
												optional maxActors : int			/* = INT_MAX */);

// Get actors in selected range around selected center, use tag to filter actors
import function GetActorsInRange( out      actors    : array< CActor >,
                                  optional range     : float /*=15*/,
                                  optional tag       : name  /*=''*/,
                                  optional center    : CNode /*=Player*/,
                                  optional community : CCommunity /*=NULL*/ );
                                  
/////////////////////////////////////////////
// Nodes Storage functions
/////////////////////////////////////////////
import class CNodesBinaryStorage extends CObject
{
	// Initializes the storage with nodes tagged with the selected tag.
	// Returns the number of nodes added to the storage.
	import final function InitializeFromTag( tag : name ) : int;
	
	// Initializes the storage with the specified nodes.
	// Returns the number of nodes added to the storage.
	import final function InitializeWithNodes( nodes : array< CNode > ) : int;
	
	// Returns the nodes closest to the specified node
	import final function GetClosestToNode( centralNode : CNode, 
											out output : array< CNode >,
											optional relMinBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
											optional relMaxBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
											optional useZBounds : bool,			/* = true */
											optional maxNodes : int				/* = INT_MAX */);

	// Returns the nodes closest to the specified position
	import final function GetClosestToPosition( position : Vector, 
											out output : array< CNode >,
											optional relMinBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
											optional relMaxBound : Vector,		/* = ( FLT_MAX, FLT_MAX, FLT_MAX ) */
											optional useZBounds : bool,			/* = true */
											optional maxNodes : int				/* = INT_MAX */);

};

// Convert array of CActors to array of CNewNPC
function ArrayActorsToNPCs( out inActors : array< CActor >, out outNPCs : array< CNewNPC > )
{
	var i,s : int;
	var npc : CNewNPC;
	
	outNPCs.Clear();
	s = inActors.Size();	
	
	for( i=0; i<s; i+=1 )
	{
		npc = (CNewNPC)inActors[i];
		if( npc )
		{
			outNPCs.PushBack(npc);
		}
	}
}
                                  