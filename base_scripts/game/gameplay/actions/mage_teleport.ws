latent quest function QMageTeleport( mageTag, placeTag : name )
{
	var 	npc 						: CNewNPC = theGame.GetNPCByTag( mageTag );
	var		place						: CNode = theGame.GetNodeByTag(placeTag);
	
	MageTeleport (npc, place);
	
}

class CActorLatentActionMageTeleport extends IActorLatentAction
{
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		MageTeleport(actor, actor.GetFocusedNode() );
	}	
}


latent function MageTeleport( npc : CActor, place : CNode )
{
	
	var 	appearEffectTemplate 		: CEntityTemplate; 
	var	 	disappearEffectTemplate 	: CEntityTemplate; 
	var 	disappearanceFX 			: name;
	var 	disappearanceDuration		: float;
	
	var 	appearanceFX 				: name;
	var 	appearanceDuration 			: float;

	var		teleportPos					: Vector;
	var		teleportRot					: EulerAngles;
	var		wasBlockingHit				: bool;
	
	var		mage						: CNewNPC;
	var 	params						: SCombatParams;
	
	npc.ActivateBehavior('npc_mage');

	disappearEffectTemplate= (CEntityTemplate)LoadResource( "fx\mage_teleport_pre" );
	appearEffectTemplate = (CEntityTemplate)LoadResource( "fx\mage_teleport_post" );
	disappearanceFX					= 'mage_disappear_fx';
	appearanceFX					= 'mage_appear_fx';
	teleportPos = place.GetWorldPosition();
	teleportRot = place.GetWorldRotation();
	
	// disable AI params for the teleport time being
	npc.ActionCancelAll();
	wasBlockingHit = npc.IsBlockingHit();
	
	npc.SetBlockingHit( true, 30 );

	// make the NPC disappear
		
		npc.RaiseForceEvent ('Teleport');
		npc.StopEffect('default_fx');
		Sleep(1.3f);
		theGame.CreateEntity(disappearEffectTemplate, npc.GetWorldPosition(), npc.GetWorldRotation());
		Sleep(0.4);
		npc.PlayEffect( disappearanceFX );
		Sleep(0.3);
		//npc.WaitForBehaviorNodeDeactivation('TeleportEnd');
		((CNewNPC)npc).SetVisibility( false );
		Sleep( 1.f );
		// teleport
		npc.TeleportWithRotation( teleportPos, teleportRot );
		theGame.CreateEntity(appearEffectTemplate, teleportPos, npc.GetWorldRotation());
		
		// make the NPC appear
		npc.PlayEffect( appearanceFX );
		Sleep( 1.f );
		((CNewNPC)npc).SetVisibility( true );

		npc.WaitForBehaviorNodeDeactivation ('TeleportEnded');
	
		npc.PlayEffect('default_fx');
	
	// restore attack state
	npc.SetBlockingHit( wasBlockingHit );
	mage = (CNewNPC)npc;
	// mage.EnterCombat(params);
}
