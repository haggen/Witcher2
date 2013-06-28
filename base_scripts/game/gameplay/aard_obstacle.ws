/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** AArd obstacle implementation
/** Copyright © 2010 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////

// An obstacle that can be destroyed with an Aard sign. Requires an interaction
// component with action 'SignTarget'
/*
class CInteractiveEntity extends CGameplayEntity
{		
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			//this.Highlight( true );
			this.SetGameplayParameter( 0, true, 0.f );
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			//this.Highlight( false );
			this.SetGameplayParameter( 0, false, 0.f );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{			
			Activate();
		}
	}
	
	function EnableInteraction( flag : bool )
	{
		var interactionComponent	: CInteractionComponent;
		
		// disable the interaction component
		interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
		if ( interactionComponent )
		{
			interactionComponent.SetEnabled( flag );
		}
	}
	
	abstract function SetState( flag : bool );
	abstract function Activate();
};
*/

import class CInteractiveEntity extends CGameplayEntity
{		
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer && !thePlayer.IsNotGeralt() )
		{
			//this.SetGameplayParameter( 0, true, 0.f );
			theHud.HudTargetEntityEx( this, NAPK_FocusPoint );
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer && !thePlayer.IsNotGeralt() )
		{
			//this.SetGameplayParameter( 0, false, 0.f );
			theHud.HudTargetEntityEx( NULL );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer && !thePlayer.IsNotGeralt() )
		{			
			Activate();
		}
	}
	
	function EnableInteraction( flag : bool )
	{
		var interactionComponent	: CInteractionComponent;
		
		// disable the interaction component
		interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
		if ( interactionComponent )
		{
			interactionComponent.SetEnabled( flag );
		}
	}
	
	abstract function SetState( flag : bool );
	abstract function Activate();
};

quest function QManageInteractiveEntity( tag : name, activate : bool )
{
	var entity : CInteractiveEntity;
	var entities : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(tag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{	
		entity = (CInteractiveEntity)(entities[i]);
		entity.EnableInteraction( activate );
	}
	
	
	/*entity = (CInteractiveEntity)theGame.GetEntityByTag( tag );
	entity.EnableInteraction( activate );*/
}

///////////////////////////////////////////////////////////////////////////

class CStaticMeshesAardObstacle extends CInteractiveEntity
{
	private var  entityId			: string;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		EnableInteraction( true );
	}
		
	function Activate()
	{	
		// play an obstacle destruction animation on the player
		if( thePlayer.UseAard( this ) )
		{
			EnableInteraction( false );	
		}
	}
}

///////////////////////////////////////////////////////////////////////////

class CSaveableInteractiveEntity extends CInteractiveEntity
{
	private var entityId	: string;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		entityId = GetEntityId();
		SelectState();
	}
	
	function Activate()
	{
		TransitionToNextState();
	}
	
	function TransitionToNextState()
	{
		FactsAdd( entityId, 1 );
		SelectState();
	}
	
	function TransitionToPreviousState()
	{
		var currStateIdx : int;
		currStateIdx = FactsQuerySum( entityId );
		if ( currStateIdx > 0 )
		{
			FactsAdd( entityId, -1 );
		}
		SelectState();
	}
	
	function TransitionToState( stateIdx : int )
	{
		var currStateIdx : int;
		var stateIdxDiff : int;
		currStateIdx = FactsQuerySum( entityId );
		
		stateIdxDiff = stateIdx - currStateIdx;
		FactsAdd( entityId, stateIdxDiff );
		
		SelectState();
	}
	
	function SelectState()
	{
		var stateIdx : int;
		stateIdx = FactsQuerySum( entityId );
		OnSelectState( stateIdx );
	}
	
	abstract function OnSelectState( stateIdx : int );
	
	private function GetEntityId() : string
    {
		var id : string;
		var tags : array<name>;
		var i, count : int;
		
		// Add an entry to the facts DB
		id = "CSaveableInteractiveEntity_";
		
		tags = GetTags();
		count = tags.Size();
		for ( i = 0; i < count; i += 1 )
		{
			id = id + tags[i] + "_";
		}
		id = id + "state";
		return id;
    }
};



///////////////////////////////////////////////////////////////////////////
quest function QEnableAardObstacle( tag : name, activate : bool )
{
	var entity : CQuestAardObstacle;
	var entities : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(tag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{	
		entity = (CQuestAardObstacle)(entities[i]);
		entity.EnableInteraction( activate );
	}
}

quest function QEnableIgniActivatedEntity( tag : name, activate : bool )
{
	var entity : CIgniActivatedEntity;
	var entities : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(tag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{	
		entity = (CIgniActivatedEntity)(entities[i]);
		entity.EnableInteraction( activate );
	}
}

quest function QDestroyAardObstacle( tag : name)
{
	var entity : CQuestAardObstacle;
	var entities : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(tag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{	
		entity = (CQuestAardObstacle)(entities[i]);
		entity.ForceDestroyThisObstacle();
	}
}
quest function QHitAardObstacle( tag : name, hitsNum : int)
{
	var entity : CQuestAardObstacle;
	var entities : array<CNode>;
	var i : int;
	
	theGame.GetNodesByTag(tag, entities);
	
	for (i = 0; i < entities.Size(); i += 1 )
	{	
		entity = (CQuestAardObstacle)(entities[i]);
		entity.HitAardObstacle(hitsNum);
	}
}
class CQuestAardObstacle extends CGameplayEntity
{	
	editable saved var aardHitCounter : int;
	editable var cooldownBetweenAardHits : float;
	editable var onlyInteraction : bool;
	editable saved var isEnabled : bool;
	editable var signTargetZ : float;
	
	default signTargetZ = 1.5;
	
	default isEnabled = true;
	var canBeDestroyed : bool;
	
	var lastHitTime : EngineTime;
	
	default cooldownBetweenAardHits = 0.0f;
	default aardHitCounter = 1;
	
	var destructionSystems	: array< CDestructionSystemComponent >;
	var allTags				:	array<name>;
	
	function GetSignTargetZ() : float
	{
		return signTargetZ;
	}
	function HandleAardHit(aard : CWitcherSignAard)
	{
		if(onlyInteraction)
		{
			if(canBeDestroyed)
			{
				DestroyThisObstacle();
			}
		}
		else
		{
			DestroyThisObstacle();
		}
	}
	function HitAardObstacle(hitsNum : int)
	{
		aardHitCounter -= hitsNum;
	}
	function HandleIgniHit(igni : CWitcherSignIgni)
	{
		if(onlyInteraction)
		{
			if(canBeDestroyed)
			{
				DestroyThisObstacle();
			}
		}
		else
		{
			DestroyThisObstacle();
		}
	}
	function ForceDestroyThisObstacle()
	{
		var i, size, sizeTags : int;

		
		size = destructionSystems.Size();
		sizeTags = allTags.Size();
		
		for(i = 0; i < size; i += 1)
		{
			destructionSystems[i].SetEnabled(true);
			destructionSystems[i].SetTakesDamage( true );
			destructionSystems[i].ApplyScriptedDamage( -1, 10000 );
		}
		for(i = 0; i < sizeTags; i += 1)
		{
			FactsAdd( allTags[i] + "_AARD_WALL_DESTROYED", 1); 
		}
		StopEffect('medalion_detection_fx');
		EnableInteraction(false);
		
	}
	function DestroyThisObstacle()
	{
		var i, size, sizeTags : int;
		if(!isEnabled)
		{
			return;
		}
		canBeDestroyed = false;
		if(cooldownBetweenAardHits < 1.0)
		{
			cooldownBetweenAardHits = 1.0;
		}
		if(theGame.GetEngineTime() >= lastHitTime + EngineTimeFromFloat(cooldownBetweenAardHits))
		{
			aardHitCounter -= 1;
			PlayEffect('destruction_fx');
		}
		
		size = destructionSystems.Size();
		sizeTags = allTags.Size();
		
		for(i = 0; i < sizeTags; i += 1)
		{
			FactsAdd( allTags[i] + "_AARD_WALL_HIT", 1); 
		}
		if(aardHitCounter <= 0)
		{
			for(i = 0; i < size; i += 1)
			{
				destructionSystems[i].SetEnabled(true);
				destructionSystems[i].SetTakesDamage( true );
				destructionSystems[i].ApplyScriptedDamage( -1, 10000 );
			}
			
			for(i = 0; i < sizeTags; i += 1)
			{
				FactsAdd( allTags[i] + "_AARD_WALL_DESTROYED", 1); 
			}
			StopEffect('medalion_detection_fx');
			EnableInteraction(false);
		}
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var dc : CDestructionSystemComponent;
		var i, count : int;
		EnableInteraction(isEnabled);
		components = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
		allTags = this.GetTags();
		count = components.Size();
		for ( i = 0; i < count; i += 1 )
		{
			dc = (CDestructionSystemComponent)components[i];
			if ( dc )
			{
			
				destructionSystems.PushBack( dc );
				dc.SetTakesDamage( false );
				dc.SetEnabled(false);
				
			}
		}
		super.OnSpawned( spawnData );
	}
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( this, NAPK_FocusPoint );
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( NULL );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			if(onlyInteraction)
			{
				canBeDestroyed = true;
				
			}
			thePlayer.UseAard(this);
		}
	}
	
	function EnableInteraction( flag : bool )
	{
		var interactionComponents	: array<CComponent>;
		var interactionComponent : CInteractionComponent;
		var i, size : int;
		
		isEnabled = flag;
		
		interactionComponents = this.GetComponentsByClassName( 'CInteractionComponent' );
		
		size = interactionComponents.Size();
		
		for(i = 0; i < size; i += 1)
		{
			interactionComponent = (CInteractionComponent)interactionComponents[i];
			if(interactionComponent)
			{
				interactionComponent.SetEnabled( flag );
			}
		}
		
		interactionComponents = this.GetComponentsByClassName( 'CInteractionAreaComponent' );
		
		size = interactionComponents.Size();
		
		for(i = 0; i < size; i += 1)
		{
			interactionComponent = (CInteractionComponent)interactionComponents[i];
			if(interactionComponent)
			{
				interactionComponent.SetEnabled( flag );
			}
		}
	}
}
///////////////////////////////////////////////////////////////////////////

class CAardWall extends CSaveableInteractiveEntity
{	
	editable var shouldAddFact : bool;
	
	var destructionSystems	: array< CDestructionSystemComponent >;
	
	default shouldAddFact	= true;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var dc : CDestructionSystemComponent;
		var i, count : int;
		components = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
		count = components.Size();
		for ( i = 0; i < count; i += 1 )
		{
			dc = (CDestructionSystemComponent)components[i];
			if ( dc )
			{
				destructionSystems.PushBack( dc );
			}
		}

		super.OnSpawned( spawnData );
	}
	
	function SetState( flag : bool )
	{
		if( flag )
		{
			TransitionToState( 2 );
		}
	}
	
	function OnSelectState( stateIdx : int )
    {		
		if ( stateIdx == 0 )
		{
			Inactive();
		}
		else if ( stateIdx == 1 )
		{
			BeingActivated();
		}
		else if ( stateIdx > 1 )
		{
			Active();
		}
    }
}

state Inactive in CAardWall
{
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( true );
	}
	
	entry function Inactive()
	{
	}
}

state BeingActivated in CAardWall
{
	private var noSaveLock : int;
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( false );
		theGame.CreateNoSaveLock( "CAardWall_BeingActivated", noSaveLock );
		
		parent.StopEffect('medalion_detection_fx');
		parent.isHighlightedByMedallion = false;
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		theGame.ReleaseNoSaveLock( noSaveLock );
		noSaveLock = -1;
		parent.EnableInteraction( false );
	}

	entry function BeingActivated()
	{
		var i, count : int;
		count = parent.destructionSystems.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( parent.destructionSystems[i] )
			{
				parent.destructionSystems[i].SetTakesDamage( true );
			}
		}
		
		// play an obstacle destruction animation on the player
		if( thePlayer.UseAard( parent, 'Aard_front' ) )
		{
			parent.NotifySpellHit( 'ard' );
		
			//Sleep( 3.0f );
		
			parent.TransitionToNextState();
		}
		else
		{
			parent.TransitionToPreviousState();
		}
	}
}

state Active in CAardWall
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnableInteraction( false );
	}
	
	entry function Active()
	{
		var i, count : int;
		count = parent.destructionSystems.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( parent.destructionSystems[i] )
			{
				parent.destructionSystems[i].SetTakesDamage( true );
				parent.destructionSystems[i].ApplyScriptedDamage( -1, 10000 );
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////

class CIgniActivatedEntity extends CSaveableInteractiveEntity
{
	editable saved var isEnabled : bool;
	editable var signTargetZ : float;
	
	default signTargetZ = 0.0;
	
	default isEnabled = true;
	
	var allTags				:	array<name>;
	
	function GetSignTargetZ() : float
	{
		return signTargetZ;
	}
	function HandleIgniHit(igni : CWitcherSignIgni)
	{
		if(isEnabled)
		{
			IgniActivate();
		}
	}
	function IgniActivate()
	{
		var i, sizeTags : int;
		sizeTags = allTags.Size();
		
		for(i = 0; i < sizeTags; i += 1)
		{
			FactsAdd( allTags[i] + "_WAS_IGNI_ACTIVATED", 1); 
		}
		StopEffect('medalion_detection_fx');
		EnableInteraction(false);
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var dc : CDestructionSystemComponent;
		var i, count : int;
		EnableInteraction(isEnabled);
		allTags = this.GetTags();
		super.OnSpawned( spawnData );
	}
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( this, NAPK_FocusPoint );
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			theHud.HudTargetEntityEx( NULL );
		}
	}
	
	event OnInteraction( actionName : name, activator : CEntity )
	{		
		if ( activator == thePlayer )
		{
			thePlayer.UseIgni(this);
		}
	}
	
	function EnableInteraction( flag : bool )
	{
		var interactionComponents	: array<CComponent>;
		var interactionComponent : CInteractionComponent;
		var i, size : int;
		
		isEnabled = flag;
		
		interactionComponents = this.GetComponentsByClassName( 'CInteractionComponent' );
		
		size = interactionComponents.Size();
		
		for(i = 0; i < size; i += 1)
		{
			interactionComponent = (CInteractionComponent)interactionComponents[i];
			if(interactionComponent)
			{
				interactionComponent.SetEnabled( flag );
			}
		}
		
		interactionComponents = this.GetComponentsByClassName( 'CInteractionAreaComponent' );
		
		size = interactionComponents.Size();
		
		for(i = 0; i < size; i += 1)
		{
			interactionComponent = (CInteractionComponent)interactionComponents[i];
			if(interactionComponent)
			{
				interactionComponent.SetEnabled( flag );
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////
//                  Q104 - Aard Wall Obstacle                            //
///////////////////////////////////////////////////////////////////////////

class CTrissWall extends CSaveableInteractiveEntity
{
    var destructionSystem    : CDestructionSystemComponent;
    
    event OnSpawned( spawnData : SEntitySpawnData )
    {
        destructionSystem = (CDestructionSystemComponent)this.GetComponentByClassName( 'CDestructionSystemComponent' );
        super.OnSpawned( spawnData );      
    }
    
    function SetState( flag : bool )
    {
		if ( flag )
		{
			TransitionToState( 4 );
		}
		else
		{
			Log ( "Dla tego entity nei mozemy przelaczyc na false" );
		}
    }

    private function OnSelectState( stateIdx : int )
    {		
		if ( stateIdx == 0 )
		{
			Initial();
		}
		else if ( stateIdx == 1 )
		{
			TransitionToTrissDialog();
		}
		else if ( stateIdx == 2 )
		{
			TrissDialog();
		}
		else if ( stateIdx == 3 )
		{
			BeforeBeingDestroyed();
		}
		else if ( stateIdx > 3 )
		{
			Destroyed();
		}
    }
}

state Initial in CTrissWall
{	
	event OnEnterState()
	{
		super.OnEnterState();
		
		if ( parent.destructionSystem )
        {
            parent.destructionSystem.SetTakesDamage( false );
        }
	}
	
	entry function Initial()
	{
	}
};

state TransitionToTrissDialog in CTrissWall
{	
	private var noSaveLock : int;
	
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( false );
		theGame.CreateNoSaveLock( "q104_triss_wall_TransitionToTrissDialog", noSaveLock );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		theGame.ReleaseNoSaveLock( noSaveLock );
		noSaveLock = -1;
		parent.EnableInteraction( true );
	}
	
	entry function TransitionToTrissDialog()
	{
		thePlayer.UseAard( parent );
        FactsAdd( 'q104_triss_dialog_ready', 1 );
        Sleep( 5.0f );
        parent.TransitionToNextState();
	}
};

state TrissDialog in CTrissWall
{	
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( true );
	}
	
	entry function TrissDialog()
	{
	}
};

state BeforeBeingDestroyed in CTrissWall
{	
	private var noSaveLock : int;
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( false );
		theGame.CreateNoSaveLock( "q104_triss_wall_BeforeBeingDestroyed", noSaveLock );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		
		theGame.ReleaseNoSaveLock( noSaveLock );
		noSaveLock = -1;
		parent.EnableInteraction( false );
	}
	
	entry function BeforeBeingDestroyed()
	{
		if ( parent.destructionSystem )
        {
            parent.destructionSystem.SetTakesDamage( true );
        }
        FactsAdd( 'q104_triss_wall_destroyed', 1 );
        // play an obstacle destruction animation on the player
        thePlayer.UseAard( parent );
        Sleep( 3.0f );
        
        parent.TransitionToNextState();
	}
};

state Destroyed in CTrissWall
{	
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.EnableInteraction( false );
	}
	
	
	entry function Destroyed()
	{
		if ( parent.destructionSystem )
        {
            parent.destructionSystem.SetTakesDamage( true );
            parent.destructionSystem.ApplyScriptedDamage( -1, 10000 );
        }
	}
};

///////////////////////////////////////////////////////////////////////////
//                  Q106 - Aard Wall Obstacle                            //
///////////////////////////////////////////////////////////////////////////

class CRishonWall extends CSaveableInteractiveEntity
{	
	var destructionSystems	: array< CDestructionSystemComponent >;
		
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var dc : CDestructionSystemComponent;
		var i, count : int;
		components = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
		count = components.Size();
		for ( i = 0; i < count; i += 1 )
		{
			dc = (CDestructionSystemComponent)components[i];
			if ( dc )
			{
				destructionSystems.PushBack( dc );
			}
		}

		super.OnSpawned( spawnData );
	}
	
	function SetState( flag : bool )
	{
		if( flag )
		{
			TransitionToState( 1 );
		}
	}
	
	function OnSelectState( stateIdx : int )
    {		
		if ( stateIdx == 0 )
		{
			Inactive();
		}
		else if ( stateIdx > 0 )
		{
			Destroyed();
		}
    }
}

state Inactive in CRishonWall
{
	entry function Inactive()
	{
	}
}


state Destroyed in CRishonWall
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.EnableInteraction( false );
	}
	
	entry function Destroyed()
	{
		var i, count : int;
		count = parent.destructionSystems.Size();
		for ( i = 0; i < count; i += 1 )
		{
			if ( parent.destructionSystems[i] )
			{
				parent.destructionSystems[i].SetTakesDamage( true );
				parent.destructionSystems[i].ApplyScriptedDamage( -1, 10000 );
			}
		}
	}
}
