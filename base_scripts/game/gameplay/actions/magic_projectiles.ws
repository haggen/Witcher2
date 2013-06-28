/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions
/** Copyright © 2009
/***********************************************************************/

latent quest function Q_ShootFireballAtTarget(fireballTemplate : CEntityTemplate, npcTag : name, targetTag : name) : bool
{
	var npc : CNewNPC;
	var targetNode : CNode;

	npc = theGame.GetNPCByTag(npcTag);
	targetNode = theGame.GetNodeByTag(targetTag);
	ShootFireballAtTarget( fireballTemplate, npc, targetNode );
}
//Supports only CQuestMagicProjectileWithDamage projectiles.
latent quest function Q_ShootMagicProjectilesAtTarget(magicProjectileTemplate : CEntityTemplate, startPointTag : name, targetTag : name, projectilesQuantity : int, delayBetweenProjectiles : float,  shootingAngle : float)
{
	var startPointNode : CNode;
	var targetNode : CNode;
	var startPosition, targetPosition : Vector;
	var magicProjectile : CMagicProjectileSpawned;
	var i :  int;
	if(delayBetweenProjectiles == 0.0f)
	{
		delayBetweenProjectiles = 0.5f;
	}
	
	targetNode = theGame.GetNodeByTag(targetTag);
	startPointNode = theGame.GetNodeByTag(startPointTag);
	
	if(startPointNode && targetNode)
	{
		startPosition = startPointNode.GetWorldPosition();
		targetPosition = targetNode.GetWorldPosition();
	
		if(projectilesQuantity > 0)
		{
			for(i = 0; i < projectilesQuantity; i += 1)
			{
				magicProjectile = (CMagicProjectileSpawned)theGame.CreateEntity(magicProjectileTemplate, startPosition, startPointNode.GetWorldRotation());
				if(magicProjectile)
				{
					magicProjectile.Start(NULL, targetPosition, false, shootingAngle, 10000.0);
				}
				Sleep(delayBetweenProjectiles);
			}
		}
		else
		{
			while(true)
			{
				magicProjectile = (CMagicProjectileSpawned)theGame.CreateEntity(magicProjectileTemplate, startPosition, startPointNode.GetWorldRotation());
				if(magicProjectile)
				{
					magicProjectile.Start(NULL, targetPosition, false, shootingAngle, 10000.0);
				}
				Sleep(delayBetweenProjectiles);
			}
		}
	}
}
class CActorLatentActionShootFireballAtTarget extends IActorLatentAction
{
	editable saved var fireballTemplate : CEntityTemplate;	
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		ShootFireballAtTarget( fireballTemplate, actor, actor.GetFocusedNode() );
	}	
}

latent function ShootFireballAtTarget(fireballTemplate : CEntityTemplate, npc : CActor, targetNode : CNode ) : bool
{
	var attackEvent : W2BehaviorCombatAttack;
	var attackEventInt : int;
	var fireball : CRegularProjectile;
	var targetPosition : Vector;
	var npcPosition : Vector;
	
	npcPosition = npc.GetWorldPosition();
	npcPosition.Z += 1.5;

	targetPosition = targetNode.GetWorldPosition();
	targetPosition.Z += 1.5;
	attackEvent = BCA_Special2;
	attackEventInt = (int)attackEvent;
	npc.SetBehaviorVariable("AttackEnum", (float)attackEventInt);
	if(npc.RaiseForceEvent('Attack'))
	{
		npc.WaitForBehaviorNodeDeactivation('AttackEnd');
		fireball = (CRegularProjectile)theGame.CreateEntity(fireballTemplate, npcPosition, npc.GetWorldRotation());
		fireball.Init(npc);
		fireball.Start(NULL, targetPosition, false);
		npc.WaitForBehaviorNodeDeactivation('CastEnd');
	}
	else
	{
		fireball = (CRegularProjectile)theGame.CreateEntity(fireballTemplate, npcPosition, npc.GetWorldRotation());
		fireball.Init(npc);
		fireball.Start(NULL, targetPosition, false);
	}
}

////////////////////////////////////////////////////////////////////

latent quest function Q_ShootLightningBoltAtTarget(lightningBoltTemplate : CEntityTemplate, npcTag : name, targetTag : name) : bool
{
	var npc : CNewNPC;
	var targetNode : CNode;
	
	npc = theGame.GetNPCByTag(npcTag);
	targetNode = theGame.GetNodeByTag(targetTag);
	
	ShootLightningBoltAtTarget( lightningBoltTemplate, npc, targetNode );
}

class CActorLatentActionShootLightningBoltAtTarget extends IActorLatentAction
{
	editable var lightningBoltTemplate : CEntityTemplate;
	
	public function Cancel( actor : CActor )
	{
		actor.ActionCancelAll();
	}
	
	latent public function Perform( actor : CActor )
	{
		ShootFireballAtTarget( lightningBoltTemplate, actor, actor.GetFocusedNode() );
	}	
}

latent function ShootLightningBoltAtTarget(lightningBoltTemplate : CEntityTemplate, npc : CActor, targetNode : CNode) : bool
{
	var bolt : CMagicBolt;
	var npcPosition : Vector;
	var attackEvent : W2BehaviorCombatAttack;
	var attackEventInt : int;
	var targetPosition : Vector;
	var fxName : name = 'lightning_bolt';

	npcPosition = npc.GetWorldPosition();
	npcPosition.Z += 1.5;
	npcPosition += VecRingRand(0.0, 3.0);

	attackEvent = BCA_Special2;
	attackEventInt = (int)attackEvent;
	npc.SetBehaviorVariable("AttackEnum", (float)attackEventInt);
	targetPosition = targetNode.GetWorldPosition();
	targetPosition.Z += 1.5;
	if(npc.RaiseForceEvent('Attack'))
	{
		npc.WaitForBehaviorNodeDeactivation('AttackEnd');
		bolt = (CMagicBolt)theGame.CreateEntity(lightningBoltTemplate, npcPosition, targetNode.GetWorldRotation());
		fxName = bolt.GetBoltFXName();
		npc.PlayEffect(fxName, targetNode);
		npc.WaitForBehaviorNodeDeactivation('CastEnd');
	}
	else
	{
		bolt = (CMagicBolt)theGame.CreateEntity(lightningBoltTemplate, npcPosition, targetNode.GetWorldRotation());
		fxName = bolt.GetBoltFXName();
		npc.PlayEffect(fxName, targetNode);
	}
}

////////////////////////////////////////////////////////////////////
