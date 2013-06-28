/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions
/** Copyright © 2009
/***********************************************************************/

import class IActorLatentAction
{
	latent public function Perform( actor : CActor ) {}
	
	public function Cancel( actor : CActor ) {}
	
	// Passed from acting state
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType );	
}

class CActorLatentActionVoiceSet extends IActorLatentAction
{
	editable saved var emotion : name;
	
	latent public function Perform( actor : CActor )
	{
		actor.PlayVoiceset( actor.GetCurrentActionPriority() , emotion );
	}
}

class CActorLatentActionSetAttitude extends IActorLatentAction
{
	editable saved var attitude : EAIAttitude;
	default attitude = AIA_Neutral;
	
	latent public function Perform( actor : CActor )
	{
		var npc   : CNewNPC;
		var other : CActor;
		
		npc   = (CNewNPC) actor;
		other = (CActor) actor.GetFocusedNode();
		if ( npc && other )
			npc.SetAttitude( other, attitude );
	}
}

class CActorLatentActionAddFact extends IActorLatentAction
{
	editable saved var ID : string;
	editable saved var value : int;
	editable saved var validFor : int;
	editable saved var time : int;
	
	default value    = 1;
	default validFor = 0;
	default time     = 0;
	
	latent public function Perform( actor : CActor )
	{
		if ( validFor == 0 )
			validFor = -1;
		
		if ( time > 0 )
			FactsAdd( ID, value, validFor, time );
		else
			FactsAdd( ID, value, validFor );
	}
}

class CActorLatentActionNotifyQuest extends IActorLatentAction
{
	editable saved var reactionName : string;
	
	latent public function Perform( actor : CActor )
	{
		if ( reactionName == "" )
			return;
	}
}

class CActorLatentActionLookAt extends IActorLatentAction
{
	editable saved var timeout : float;
	default timeout = 5.f;
	
	public function Cancel( actor : CActor )
	{
		actor.DisableLookAt();
	}
	
	latent public function Perform( actor : CActor )
	{
		var target   : CNode;
		var timeLeft : float;
		
		target = actor.GetFocusedNode();
		if ( target )
		{
			actor.EnableDynamicLookAt( target, timeout );
			Sleep( timeout );
			actor.DisableLookAt();
		}
	}
}

class CActorLatentActionPlayAnimation extends IActorLatentAction
{
	editable saved var animationName : name;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		actor.ActionPlaySlotAnimation( 'NPC_ANIM_SLOT', animationName, 0.2f, 0.3f, true );
	}	
}

class CActorLatentActionRotateTowards extends IActorLatentAction
{	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var node   		: CNode;
		node = actor.GetFocusedNode();
	
		if( node )
		{
			actor.ActionRotateTo( node.GetWorldPosition() );
		}
	}	
}


class CActorLatentActionMoveTo extends IActorLatentAction
{
	editable saved var moveType : EMoveType;
	editable saved var radius : float;
	editable saved inlined var modifiers : array< IMoveParamModifier >;
	
	default moveType = MT_Walk;
	default radius = 1.0;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var node   : CNode;		
		
		node = actor.GetFocusedNode();
	
		if( node )
		{
			actor.ActionMoveToNodeWithHeading( node, moveType, 1.0, radius, MFA_REPLAN, modifiers );
		}
	}	
}

class CActorLatentActionMoveAlongPath extends IActorLatentAction
{
	editable saved var pathTag : name;
	editable saved var moveType : EMoveType;
	editable saved var absSpeed : float;
	editable saved var alongThePath : bool;
	editable saved var fromBeginning : bool;
	editable saved inlined var modifiers : array< IMoveParamModifier >;
	
	default moveType = MT_Walk;
	default absSpeed = 2.0;
	default alongThePath = true;
	default fromBeginning = false;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		var pathEntity : CEntity;
		var path   : CPathComponent;		
		var node   : CNode;
		
		path = (CPathComponent)theGame.GetNodeByTag( pathTag );
		if( !path )
		{
			pathEntity = (CEntity)theGame.GetNodeByTag( pathTag );
			if( pathEntity )
			{
				path = (CPathComponent)pathEntity.GetComponentByClassName('CPathComponent');
			}
		}
		node = actor.GetFocusedNode();
	
		if( path )
		{
			actor.ActionMoveAlongPath( path, alongThePath, fromBeginning, 1.0, moveType, absSpeed, MFA_REPLAN, modifiers );
		}
		else
		{
			actor.SetErrorState("CActorLatentActionMoveAlongPath ERROR: no path");
		}
		
		if( node )
		{
			actor.ActionMoveToNodeWithHeading( node, moveType, absSpeed, 0.1, MFA_REPLAN, modifiers );
		}
	}	
}

class CActorLatentClearHeldItems extends IActorLatentAction
{
	latent public function Perform( actor : CActor )
	{
		actor.IssueRequiredItems('None','None');
	}
}
