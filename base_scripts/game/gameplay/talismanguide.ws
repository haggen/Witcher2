/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Witcher's talisman guide
/** Copyright © 2011
/***********************************************************************/

class CTalismanGuide extends CActor
{
	editable var	m_speed					: float;
	editable var	m_lifetime				: float;
	var				m_targetTag				: name;
	default 		m_speed					= 5.0;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned( spawnData );
		Guiding();
	}
	
	private function PlayGuidingEffects()
	{
		// LUKASZ TODO: adjust me
		this.PlayEffect( 'default_glow', this );
	}
	
	private function PlayFailureEffects()
	{
		// LUKASZ TODO: adjust me
		this.PlayEffect( '', this );
		this.StopEffect( 'default_glow');
	}
	
	private function PlaySuccessEffects()
	{
		// LUKASZ TODO: adjust me
		this.PlayEffect( '', this );
		this.StopEffect( 'default_glow');
	}
	
	private function MoveToTarget() : bool
	{
		var targetNode					: CNode;
		var targetPath					: CPathComponent;
		var pathEntity					: CEntity;
		
		// aquire the node identified by the 'targetTag'
		targetNode = theGame.GetNodeByTag( m_targetTag );
		if ( !targetNode )
		{
			return false;
		}
		
		// check - maybe it's a path
		targetPath = (CPathComponent)targetNode;
		if( !targetPath )
		{
			pathEntity = (CEntity)targetNode;
			if( pathEntity )
			{
				targetPath = (CPathComponent)pathEntity.GetComponentByClassName('CPathComponent');
			}
		}
		
		if( targetPath )
		{
			ActionMoveAlongPathAsync( targetPath, true, false, 1.0, MT_AbsSpeed, m_speed );
		}
		else
		{
			ActionMoveToNodeWithHeadingAsync( targetNode, MT_AbsSpeed, m_speed, 0.1 );
		}
		
		return true;
	}
}

state Guiding in CTalismanGuide
{
	event OnEnterState()
	{
		super.OnEnterState();
		
		// playe the eentity effects
		parent.PlayGuidingEffects();
		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}

	entry function Guiding()
	{
		var	timeLeft		: float;
		var mac				: CMovingAgentComponent = parent.GetMovingAgentComponent();
		
		// move the entity
		if ( parent.MoveToTarget() == false )
		{
			// ups - no target node or path found - abort
			parent.NowhereToGo();
		}
		
		// wait until the object starts moving
		timeLeft = 3.0;
		while( timeLeft > 0 && mac.GetSpeed() <= 0 )
		{
			// wait
			Sleep( 0.5 );
			timeLeft -= 0.5;
		}
		
		if ( mac.GetSpeed() <= 0 )
		{
			// something went wrong and the object didn't start moving - flag it
			// as a failure
			parent.NowhereToGo();
		}
		else
		{
			// monitor entity's lifetime
			timeLeft = parent.m_lifetime;
			while( timeLeft > 0 && mac.GetSpeed() > 0 )
			{
				// wait
				Sleep( 0.5 );
				timeLeft -= 0.5;
			}
			
			// ok - time to fade
			parent.Dissolving();
		}
	}
}

state NowhereToGo in CTalismanGuide
{
	event OnEnterState()
	{
		super.OnEnterState();
		
		// play appropriate effects
		parent.PlayFailureEffects();
	}
	
	entry function NowhereToGo() 
	{
		Sleep( 3.0f );
		thePlayer.DestroyTalismanGuide();
	}
}

state Dissolving in CTalismanGuide
{
	event OnEnterState()
	{
		super.OnEnterState();
		
		// play appropriate effects
		parent.PlaySuccessEffects();
	}
	
	entry function Dissolving() 
	{
		Sleep( 3.0f );
		thePlayer.DestroyTalismanGuide();
	}
}

////////////////////////////////////////////////////////////////////////
// Control API
////////////////////////////////////////////////////////////////////////

latent quest function QActionFogGuiding( targetTag : name ) : bool
{
	thePlayer.SetTalismanTargetTag( targetTag );
}
