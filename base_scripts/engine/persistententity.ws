/////////////////////////////////////////////
// Persistent Entity class
/////////////////////////////////////////////
import class CPeristentEntity extends CEntity
{
	event OnBehaviorSnaphot() { return false; }
	
	// Checks if the entity is virtually destroyed
	import function IsVirtuallyDestroyed() : bool;
}