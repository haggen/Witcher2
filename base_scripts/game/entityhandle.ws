/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CWitcherGame
/** Copyright © 2009
/***********************************************************************/

// Entity handle is a persistent handle to entity that can be saved in savegames
// and will NOT be lost when layer is unstreamed. Also this type of handle to entity can be set
// in the Editor as a property using entity picker so it's a VERY GOOD WAY to point to entities
// on the map, way better thay using Tags and FindNodeByTag, also it's a way faster than that.
// 
// There are 3 types of entities that can be used with the EntityHandle stuff
//  1) all entities added to layers in editor ( it means all nodes, waypoints, action points, etc )
//  2) dynamicaly spawned entities of class CPersistentEntity if they have valid IdTag. 
//  3) player

// NOTE: missing the entity - calling EntityHandleGet when there's no entity to be found is VERY SLOW. So do not
// call this method as a replacer of some more sophisticated logic.

// Get entity associated with EntityHandle
// NOTE: as for optimization reason you need to pass L-value to this function
import function EntityHandleGet( out handle : EntityHandle ) : CEntity;

// Set entity handle
import function EntityHandleSet( out handle : EntityHandle, entity : CEntity );

// Get with waiting entity associated with EntityHandle (default timeout: infinity)
import latent function EntityHandleWaitGet( out handle : EntityHandle, optional timeout : float /*= -1.0f */ ) : CEntity;

