/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Spawn point manager
/** Copyright © 2010
/***********************************************************************/

import function IsPointSeenByPlayer( testPoint : Vector ) : bool;

import function GetRandomReachablePoint( center : Vector, minRadius : float, maxRadius : float, out spawnPoint : Vector ) : bool;

import function GetRandomReachablePointWithinArea( center : Vector, minRadius : float, maxRadius : float, area : CAreaComponent, out spawnPoint : Vector ) : bool;

// Path Engine -> GetClosestUnobstructedPosition with radius 0
import function IsPointFree( testPoint : Vector ) : bool;

// Tries to find an unobstructed path engine position close to the 'center' position, but no further than 'maxRadius'.
// The output position is put into 'spawnPoint' vector. Method returns true if free point has been found and only then
// position will be assigned to the 'spawnPoint' parameter.
import function GetFreeReachablePoint( center : Vector, maxRadius : float, out spawnPoint : Vector ) : bool;
