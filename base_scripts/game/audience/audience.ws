/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Audience
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

struct SAudienceAnimEntry
{
	editable var animationName : name;
	editable var blendIn       : float;
	editable var blendOut      : float;
	
	default blendIn  = 0;
	default blendOut = 0;
}

class CAudience extends CGameplayEntity
{
	editable var audienceJobTree           : CJobTree;
	editable var audienceJobTreeCategory   : name;
	editable var audienceSlotTag           : name;
	editable var audienceSlotRadius        : float; // don't teleport NPC if he is close enough to the slot
	editable var audienceNpcTag            : name;
	editable var audienceRadius            : float;
	editable var audienceAreaTag           : name; // optional
	editable var audienceCommunity         : CCommunity; // optional
	editable var audienceForceAnim         : SAudienceAnimEntry;
	editable var audienceForceAnimMinDelay : float;
	editable var audienceForceAnimMaxDelay : float;
	
	default audienceSlotTag = 'AudienceSlot';
	default audienceNpcTag  = 'Audience';
	default audienceRadius  = 4;
	default audienceAreaTag = '';
	default audienceForceAnimMinDelay = 0;
	default audienceForceAnimMaxDelay = 0;
	default audienceSlotRadius = 0;
	
	private saved var audienceNPCs : array< EntityHandle >;
	private var audienceSlots : array< CNode >;
	private var audienceAreaComponent : CAreaComponent;
	private var audienceNPCsUsedIdx : array< int >;
	private var actorsToExcludeFromAudience : array< CActor >;
	
	public function AddAudienceNPC( npc : CNewNPC )
	{
		var endIdx : int = audienceNPCs.Grow(1);
		EntityHandleSet( audienceNPCs[endIdx], npc );
	}
	
	public function GetAudienceNPC( index : int ) : CNewNPC
	{	
		return (CNewNPC)EntityHandleGet( audienceNPCs[index] );
	}

	public function StartAudience()
	{
		var actors : array< CActor >;
		var npcs : array< CNewNPC >;
		var radius : float;
		var nodes : array< CNode >;
		var i, k : int;
		var entityPos : Vector = GetWorldPosition();
		var audienceRadiusSquare : float = audienceRadius * audienceRadius;
		var audienceAreaEntity : CEntity;
		var components : array< CComponent >;
		var centerNode : CNode;
		
		// Clear members
		audienceNPCs.Clear();
		audienceSlots.Clear();
		audienceNPCsUsedIdx.Clear();
		
		// Find audience area
		if ( audienceAreaTag != '' )
		{
			audienceAreaEntity = theGame.GetEntityByTag( audienceAreaTag );
			if ( audienceAreaEntity )
			{
				audienceAreaComponent = (CAreaComponent)audienceAreaEntity.GetComponentByClassName( 'CAreaComponent' );
			}
		}
		
		// Calculate radius
		if ( IsAudienceAreaAvailable() )
		{
			// Get radius from area
			radius = audienceAreaComponent.GetBoudingAreaRadius();
			centerNode = audienceAreaComponent;
		}
		else
		{
			radius = audienceRadius;
			centerNode = this;
		}


		// Get the audience
		GetActorsInRange( actors, radius, audienceNpcTag, centerNode, audienceCommunity );
        ArrayActorsToNPCs( actors, npcs );
        if ( IsAudienceAreaAvailable() )
        {
			// filter actors in area
			for ( i = 0; i < npcs.Size(); i += 1 )
			{
				if ( audienceAreaComponent.TestPointOverlap( npcs[i].GetWorldPosition() ) 
                     && !IsNpcExcludedFromAudience( npcs[i] ) )
				{
					AddAudienceNPC( npcs[i] );
				}
			}
		}
		else
		{
			for ( i = 0; i < npcs.Size(); i += 1 )
			{
				if ( !IsNpcExcludedFromAudience( npcs[i] ) )
				{
					AddAudienceNPC( npcs[i] );					
				}
			}
		}


		// Get audience slots from world
		theGame.GetNodesByTag( audienceSlotTag, nodes );
		if ( IsAudienceAreaAvailable() )
		{
			// filter by area
			for ( i = 0; i < nodes.Size(); i += 1 )
			{
				if ( audienceAreaComponent.TestPointOverlap( nodes[i].GetWorldPosition() ) )
				{
					audienceSlots.PushBack( nodes[i] );
				}
			}
		}
		else
		{
			// Filter audience slots by radius
			for ( i = 0; i < nodes.Size(); i += 1 )
			{
				if ( VecDistanceSquared( entityPos, nodes[i].GetWorldPosition() ) < audienceRadiusSquare )
				{
					audienceSlots.PushBack( nodes[i] );
				}
			}
		}
		// Get audience slots from audience entity
		components = this.GetComponentsByClassName( 'CWayPointComponent' );
		for ( i = 0; i < components.Size(); i += 1 )
		{
			if ( components[i].HasTag( audienceSlotTag ) )
			{
				audienceSlots.PushBack( components[i] );
			}
		}
		
		
		// Put all audience into audience state
		for ( i = 0; i < audienceSlots.Size(); i += 1 )
		{
			if ( i == audienceNPCs.Size() ) break; // run out of audience
		
			if ( audienceSlotRadius > 0 )
			{
				k = GetClosestAudienceIdx( audienceSlots[i].GetWorldPosition() );
				if ( k == -1 )
				{
					LogChannel( 'audience', "ERROR: GetClosestAudienceIdx() returned -1. Strange, i've seen that error before." );
					break;
				}
				GetAudienceNPC(k).EnterAudienceState( audienceSlots[i], this );
			}
			else
			{
				GetAudienceNPC(i).EnterAudienceState( audienceSlots[i], this );
			}
		}
	}
	
	public function StopAudience()
	{
		var i : int;
		
		for ( i = 0; i < audienceNPCs.Size(); i += 1 )
		{
			GetAudienceNPC(i).ExitAudienceState();
		}
	}
	
	public function SetForceAnimName( animName : name )
	{
		audienceForceAnim.animationName = animName;
	}
	
	public function SetForceAnimStartDelay( minDelay : float, maxDelay : float )
	{
		audienceForceAnimMinDelay = minDelay;
		audienceForceAnimMaxDelay = maxDelay;
	}
	
	public function ForcePlayAnim()
	{
		var i : int;
		
		for ( i = 0; i < audienceNPCs.Size(); i += 1 )
		{
			GetAudienceNPC(i).OnForceAudienceAnim();
		}
	}
	
	public function SetActorsToExclude( actorsToExclude : array< CActor > )
	{
		actorsToExcludeFromAudience	= actorsToExclude;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// For Audience NPC State
	
	public function GetForceAnimStartDelay( out minDelay : float, out maxDelay : float )
	{
		minDelay = audienceForceAnimMinDelay;
		maxDelay = audienceForceAnimMaxDelay;
	}
	
	public function GetForceAnimDelay() : float
	{
		return RandRangeF( audienceForceAnimMinDelay, audienceForceAnimMaxDelay );
	}
	
	public function GetJobTree() : CJobTree
	{
		return audienceJobTree;
	}
	
	public function GetJobTreeCategory() : name
	{
		return audienceJobTreeCategory;
	}
	
	public function GetForceAnimInfo( out slotName : name, out animationName : name,
		out blendIn : float, out blendOut : float ) : bool
	{
		if ( audienceForceAnim.animationName == '' )
		{
			// animation not available
			return false;
		}
	
		slotName = 'NPC_ANIM_SLOT';
		animationName = audienceForceAnim.animationName;
		blendIn = audienceForceAnim.blendIn;
		blendOut = audienceForceAnim.blendOut;
		return true;
	}
	
	public function GetAudienceSlotRadius() : float
	{
		return audienceSlotRadius;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private function IsAudienceAreaAvailable() : bool
	{
		return audienceAreaComponent;
	}
	
	private function GetClosestAudienceIdx( position : Vector ) : int
	{
		var result : int = -1;
		var i : int;
		var minDist : float =  99999.9;
		var dist : float;
		
		for ( i = 0; i < audienceNPCs.Size(); i += 1 )
		{
			if ( audienceNPCsUsedIdx.Contains( i ) ) continue;
			
			dist = VecDistanceSquared( GetAudienceNPC(i).GetWorldPosition(), position );
			if ( dist < minDist )
			{
				result = i;
				minDist = dist;
			}
		}

		if ( result >= 0 )
		{
			audienceNPCsUsedIdx.PushBack( result ); // do not use that index again
		}

		return result;
	}
	
	private function IsNpcExcludedFromAudience( npc : CNewNPC ) : bool
	{
		var i : int;
		
		for ( i = 0; i < actorsToExcludeFromAudience.Size(); i += 1 )
		{
			if ( actorsToExcludeFromAudience[i] == npc )
			{
				return true;
			}
		}
		
		return false;
	}
}

state Audience in CNewNPC extends Base
{
	var m_initialPos : Vector;
	var m_initialRot : EulerAngles;
	var m_audience : CAudience;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnablePathEngineAgent( false );
		m_initialPos = parent.GetWorldPosition();
		m_initialRot = parent.GetWorldRotation();
	}
	
	event OnLeaveState()
	{
		parent.EnablePathEngineAgent( true );
		MarkGoalFinished();
		parent.TeleportWithRotation( m_initialPos, m_initialRot );
		super.OnLeaveState();
	}
	
	event OnForceAudienceAnim()
	{
		StateAudienceForcePlayAnim();
	}

	entry function StateAudience( pos : Vector, rot : EulerAngles, audience : EntityHandle, goalId : int )
	{
		SetGoalId( goalId );
		
		m_audience = (CAudience)EntityHandleGet(audience);
		
		parent.ActionCancelAll();
		
		//if ( behavior )
			//parent.ActivateBehavior( behavior );

		if ( m_audience )
		{
			if ( m_audience.GetAudienceSlotRadius() <= 0 || 
                 VecDistance( parent.GetWorldPosition(), pos ) > m_audience.GetAudienceSlotRadius() )
			{
				parent.TeleportWithRotation( pos, rot );
			}
		}
		
		StateAudienceWorkOnJobTree();
	}
	
	//entry function StateAudienceExit()
	//{
//		MarkGoalFinished();
	//}
	
	entry function StateAudienceWorkOnJobTree()
	{
		var res : bool;
		var jobTree : CJobTree;
		
		while ( true )
		{
			jobTree = m_audience.GetJobTree();
			res = parent.ActionWorkJobTree( jobTree, m_audience.GetJobTreeCategory(), false );
			if ( !res )
			{
				LogChannel( 'audience', "Cannot execute work job tree with category " + m_audience.GetJobTreeCategory() );
				Sleep( 2.0 );
			}
			
		}
	}
	
	entry function StateAudienceForcePlayAnim()
	{
		var delay : float;
		delay = m_audience.GetForceAnimDelay();
		// LogChannel( 'audience' , "Delay: " + delay );
		Sleep( delay );
		parent.ActionExitWork( true );
		PlayForcedAnims();
		StateAudienceWorkOnJobTree();
	}
	
	private latent function PlayForcedAnims()
	{
		var slotName : name;
		var animationName : name;
		var blendIn : float;
		var blendOut : float;
		
		if ( m_audience.GetForceAnimInfo(slotName, animationName, blendIn, blendOut) )
		{
			parent.ActionPlaySlotAnimation( slotName, animationName, blendIn, blendOut );
		}
	}
}
