class CKickAbleObject extends CEntity
{

	editable var forceValue  : float;
	editable var time        : float;
	editable var DB_fact     : name;
	editable var Fact_Value  : int;
	editable var Fact_valid_for  : int;
	editable var Fact_time  : int;
	editable var destinationTag : name;
	editable var angleInDegrees : float;
	editable var allowCombat : bool;
	editable var dontDisableInteraction : bool;
	var kickObject: CRigidMeshComponent;
	var forceDirection : Vector;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		kickObject = NULL;
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{
		var player : CPlayer;
		var bestKickPoint: CComponent;
		var kickObjCentre : Vector;
		var kickDirection : float;
		var playerState : EPlayerState;
		
		player = thePlayer;
		playerState = player.GetCurrentPlayerState();
		
		
		kickObject = (CRigidMeshComponent)GetComponentByClassName('CRigidMeshComponent');
		player = thePlayer;

		if( !kickObject )
		{
			return false;
		}
		
		kickObjCentre = kickObject.GetWorldPosition();
		forceDirection = VecNormalize2D( kickObjCentre - player.GetWorldPosition() );
		kickDirection = VecHeading( forceDirection );
		
		if (allowCombat)
		{
			if ( player.OnKickObject( kickDirection, this ) == false )
			{
				return true;
			}
		}
		if (!allowCombat)
		{
			if (playerState == PS_Exploration)
			{
				if ( player.OnKickObject( kickDirection, this ) == false )
				{
					return true;
				}
			
			}
			else
			{
				Log ("Player is in combat");
				return false;
			}
		}
	}
	
	 event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, otherComponent : CComponent )
	 { 
		var destination : Vector;
		var kickObjCentre : Vector;
		var currentDistance : float;
	 
		kickObject = (CRigidMeshComponent)GetComponentByClassName('CRigidMeshComponent');
		destination = theGame.GetNodeByTag(destinationTag).GetWorldPosition();
		kickObjCentre = kickObject.GetWorldPosition();
		
		
		
		if (destinationTag)
		{
			if (reportingComponent == kickObject)
			{
				currentDistance == VecDistance2D(destination, kickObjCentre);
				
				if (currentDistance <= 1.5)
				{
					kickObject.SetLinearVelocity(Vector (0,0,0));
					kickObject.SetAngularVelocity(Vector (0,0,0));;
					EnableCollisionInfoReportingForComponent(kickObject, false, true);
					//tu trzeba dodac wylaczanie fizyki
					
				}
				
			}
		}
		
	 }

	function ProcessKick()
	{
		var force : Vector;
		var destination : Vector;
		var kickObjCentre : Vector;
		var currentDistance : float;
		var kickInteraction : CInteractionComponent;
		
		kickObject = (CRigidMeshComponent)GetComponentByClassName('CRigidMeshComponent');
		kickInteraction = (CInteractionComponent)GetComponentByClassName('CInteractionComponent');
		
		
		if ( !kickObject )
		{
			Log( "Kick object should be initialized at this point" );
			return;
		}
		
		if (!destinationTag)
		{
		force = forceDirection * forceValue;
		Log ( "Kicking [" + force.X + ", " + force.Y + ", " + force.Z +"]" );
		//kickObject.ApplyLinearImpulse( force );
		kickObject.ApplyForce( force, time );
		}
		
		if (destinationTag)
		{
			destination = theGame.GetNodeByTag(destinationTag).GetWorldPosition();
			
			EnableCollisionInfoReportingForComponent(kickObject, true, true);
			ThrowEntity(((CEntity)this), angleInDegrees, destination, forceValue);	
			
		}
		
		if (DB_fact)
		{
			FactsAdd( DB_fact, Fact_Value, Fact_valid_for, Fact_time);		
		}
		
		if (!dontDisableInteraction)
		{
			kickInteraction.SetEnabled(false);
		}
		
	}
}

