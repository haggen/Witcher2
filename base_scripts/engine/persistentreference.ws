/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for PersistentRef
/** Copyright © 2010
/***********************************************************************/

import struct PersistentRef
{
};

// Create from entity
import function PersistentRefSetNode( out outPersistentRef : PersistentRef, node : CNode );

// Create from orientation
import function PersistentRefSetOrientation( out outPersistentRef : PersistentRef, position : Vector, rotation : EulerAngles );

// Get entity
import function PersistentRefGetEntity( out persistentRef : PersistentRef ) : CEntity;

// Get world position
import function PersistentRefGetWorldPosition( out persistentRef : PersistentRef ) : Vector;

// Get world rotation
import function PersistentRefGetWorldRotation( out persistentRef : PersistentRef ) : EulerAngles;

// Get world orientation
import function PersistentRefGetWorldOrientation( out persistentRef : PersistentRef, out outPosition : Vector, out outRotation : EulerAngles );
