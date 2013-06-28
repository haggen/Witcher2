/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Formations management functions
/** Copyright © 2009
/***********************************************************************/

import class CFormation
{	
	// Sets a new formation pattern
	import final function SetPattern( pattern : IFormationPattern, anchorNode : CNode );
	
	// Returns the currently used pattern
	import final function GetPattern() : IFormationPattern;
	
	// Sets the movement mode
	import final function SetMovementMode( mode : IFormationMovementMode );
	
	// Add formation follower. Returns 'true' if the formation successfully 
	// accommodated the actor
	import final function AddMember( actor : CActor ) : bool;
	
	// Remove formation follower
	import final function RemoveMember( actor : CActor );
	
	// Checks if an actor is a member of the formation
	import final function IsMember( actor : CActor ) : bool;
	
	// Has player?
	import final function HasPlayer() : bool;
}

/////////////////////////////////////////////

import class CTeleporter extends CEntity
{	
	// Teleports an actor tothe specified destination
	import final function UseTeleporter( actor : CActor, destination : CNode );
	
	// Called when an actor is about to be teleported to the specified destination
	event OnTeleported( actor : CActor, destination : CNode );
}

/////////////////////////////////////////////
// Formation helpers
/////////////////////////////////////////////

enum EFormationType // do wywalenia
{
	FM_Invalid,
	FM_Lead,
	FM_LeadToTarget,
	FM_LeadOnTaggedPath,
	FM_LeadOnPath,
	FM_FollowLeader,
	FM_FollowFormation,
};

// Funkcja zak³adaj¹ca fomracjê w scenie
storyscene function SetFormation ( player: CStoryScenePlayer, FormationLeaderTag : name, formationFollowerTags : array<name>, formationType : EFormationType, noCombat : bool ) : bool
{
	return true;
}
