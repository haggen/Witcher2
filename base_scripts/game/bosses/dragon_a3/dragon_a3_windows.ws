/*enum EDragonWindowsAction
{
	DWA_FireDown,
	DWA_FireUp,
	DWA_ClawAttack,
	DWA_FireForward,
	DWA_Wait,	
	DWA_WindowsEnd
}
enum EDragonWindowSlot
{
	DWS_Window1_1,
	DWS_Window1_2,
	DWS_Window1_3,
	DWS_Window1_4,
	DWS_Window1_5,
	DWS_Window2_1,
	DWS_Window2_2,
	DWS_Window2_3,
	DWS_Window2_4,
	DWS_Window2_5
}

enum EDragonAreaType
{
	DAT_AreaWindows1,
	DAT_AreaWindows2,
	DAT_StartAreaWindows1,
	DAT_EndAreaWindows1,
	DAT_StartAreaWindows2,
	DAT_EndAreaWindows2
}

class CDragonA3Windowss extends CDragonA3Base
{
	var dragonAction : EDragonWindowsAction;
	var playerInDragonSlot : EDragonWindowSlot;
	var playerIsDown : bool;
	var dragonDamageNormal, dragonDamageFirePerSecond, dragonFireUpdate : float;
	default dragonFireUpdate = 0.3;
	default playerIsDown = true;
	function SetDragonAction(newDragonAction : EDragonWindowsAction)
	{
		dragonAction = newDragonAction;
	}
	function SetDragonSlot(newDragonSlot : EDragonWindowSlot)
	{
		playerInDragonSlot = newDragonSlot;
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		DragonUpdate();
		//this.AddTimer('DragonInitialize', 1.0, false);
	}
	timer function DragonInitialize(timeDelta : float)
	{
		var dragonHead : CDragonHead;
		thePlayer.EnablePhysicalMovement(true);
		dragonHead = (CDragonHead)theGame.GetEntityByTag('dragon_head');
		dragonDamageNormal = dragonHead.GetCharacterStats().GetAttribute('damage_attack');
		dragonDamageFirePerSecond = dragonHead.GetCharacterStats().GetAttribute('damage_fire_per_sec');
	}
	//Timers used for looped fire attacks
	timer function FireCone(timeDelta : float)
	{
		theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
		theCamera.RaiseEvent('Camera_ShakeHit');
		
		if(PlayerInRange("FireAttack1"))
		{
			thePlayer.ForceCriticalEffect( CET_Burn, W2CriticalEffectParams( dragonDamageFirePerSecond, dragonDamageFirePerSecond, 5, 5 ) );
		}
	}
	function RemoveAllDragonTimers()
	{
		RemoveTimer('FireCone');
	}
	function StopAllDragonEffects()
	{
		StopEffect('fire_breath_1');
	}
}
state DragonWindows in CDragonA3Windowss
{
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if(animEventName == 'fire_start' && animEventType == AET_Tick)
		{
			parent.AddTimer('FireCone', parent.dragonFireUpdate, true);
			parent.PlayEffect('fire_breath_1');
		}
		else if(animEventName == 'attack' && animEventType == AET_Tick)
		{
			DragonAttack('Attack_t1', false);
		}
		else if(animEventName == 'attack_strong' && animEventType == AET_Tick)
		{
			DragonAttack('Attack_boss_t1', false);
		}
		else if(animEventName == 'camera_shake' && animEventType == AET_Tick)
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if(animEventName == 'camera_shake_light' && animEventType == AET_Tick)
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		else if(animEventName == 'fire_stop' && animEventType == AET_Tick)
		{
			parent.RemoveAllDragonTimers();
			parent.StopAllDragonEffects();
		}
	}
	function DragonAttackHitCheck() : bool
	{

		if(parent.PlayerInRange("ForwardAttack1"))
		{
			return true;
		}
	}
	//DragonAttack - handles dragon attacks
	function DragonAttack(dragonAttackType : name, overideAttackHitCheck : bool)
	{
		//HeavyHitUp
		var attackPos : Vector;
		var damage : float;
		var attackType : name;
		var hitParams : HitParams;
		damage = parent.ComputeDragonDamage(parent.dragonDamageNormal);
		if(DragonAttackHitCheck() || overideAttackHitCheck)
		{
			attackPos = thePlayer.GetWorldPosition();
			attackType = dragonAttackType;
			hitParams.outDamageMultiplier = 1.0f;
			//thePlayer.SetRotationTarget(dragonHead);
			thePlayer.HitPosition(attackPos, attackType, damage, true);
		}
	}
	event OnEnterState()
	{
		thePlayer.EnablePhysicalMovement(true);
	}
	function ChooseActionDuration() : float
	{
		var duration : float;
		duration = 1.0 + 2.0*RandF();
		return duration;
	}
	function ChooseDragonWindowAction() : EDragonWindowsAction
	{
		var random : int;
		var dragonAction : EDragonWindowsAction;
		if(parent.playerIsDown)
		{
			random = Rand(4);
			if(random == 0)
			{
				dragonAction = DWA_FireDown;
			}
			else if(random == 1)
			{
				dragonAction = DWA_Wait;
			}
			else if(random == 2)
			{
				dragonAction = DWA_ClawAttack;
			}
			else
			{
				dragonAction = DWA_FireForward;
			}
		}
		else
		{
			random = Rand(2);
			if(random == 0)
			{
				dragonAction = DWA_FireUp;
			}
			else
			{
				dragonAction = DWA_FireForward;
			}
		}
		return dragonAction;
	}
	latent function PerformDragonWindowAction(actionToPerform : EDragonWindowsAction)
	{
		var random : int;
		var actionDuration : float;
		if(actionToPerform == DWA_FireDown)
		{
			actionDuration = ChooseActionDuration();
			parent.RaiseEvent('fire_down');
			parent.WaitForBehaviorNodeDeactivation('fire_loop');
			Sleep(actionDuration);
			parent.RaiseEvent('fire_stop');
			parent.WaitForBehaviorNodeDeactivation('window_idle');
		}
		if(actionToPerform == DWA_FireUp)
		{
			actionDuration = ChooseActionDuration();
			parent.RaiseEvent('fire_up');
			parent.WaitForBehaviorNodeDeactivation('fire_loop');
			Sleep(actionDuration);
			parent.RaiseEvent('fire_stop');
			parent.WaitForBehaviorNodeDeactivation('window_idle');
		}
		if(actionToPerform == DWA_ClawAttack)
		{
			parent.RaiseEvent('attack_start');
			parent.WaitForBehaviorNodeDeactivation('attack_loop');
			random = Rand(2);
			if(random == 0)
			{
				parent.RaiseEvent('attack_up');
			}
			else if(random == 1)
			{
				parent.RaiseEvent('attack_down');
			}
			else
			{
				parent.RaiseEvent('attack_front');
			}
			parent.WaitForBehaviorNodeDeactivation('attack_loop');
			parent.RaiseEvent('attack_stop');
			parent.WaitForBehaviorNodeDeactivation('window_idle');
		}
		if(actionToPerform == DWA_FireForward)
		{
			parent.DragonLookatOff();
			actionDuration = ChooseActionDuration();
			parent.RaiseEvent('fire_front');
			parent.WaitForBehaviorNodeDeactivation('fire_loop');
			Sleep(actionDuration);
			parent.RaiseEvent('fire_stop');
			parent.WaitForBehaviorNodeDeactivation('window_idle');
		}
		else if(actionToPerform == DWA_Wait)
		{
			Sleep(1.5);
		}
		DragonUpdate();
	}
	function SetDragonPosition()
	{
		var dragonPosition : Vector;
		var dragonRotation : EulerAngles;
		var positionNode : CNode;
		if(parent.playerInDragonSlot == DWS_Window1_1)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window1_2');
		}
		else if(parent.playerInDragonSlot == DWS_Window1_2)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window1_3');
		}
		else if(parent.playerInDragonSlot == DWS_Window1_3)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window1_4');
		}
		else if(parent.playerInDragonSlot == DWS_Window1_4)
		{
			parent.playerIsDown = false;
			positionNode = theGame.GetNodeByTag('d_window1_5');
		}
		else if(parent.playerInDragonSlot == DWS_Window1_5)
		{
			parent.playerIsDown = false;
			positionNode = theGame.GetNodeByTag('d_window1_4');
		}
		else if(parent.playerInDragonSlot == DWS_Window2_1)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window2_2');
		}
		else if(parent.playerInDragonSlot == DWS_Window2_2)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window2_3');
		}
		else if(parent.playerInDragonSlot == DWS_Window2_3)
		{
			parent.playerIsDown = true;
			positionNode = theGame.GetNodeByTag('d_window2_4');
		}
		else if(parent.playerInDragonSlot == DWS_Window2_4)
		{
			parent.playerIsDown = false;
			positionNode = theGame.GetNodeByTag('d_window2_5');
		}
		else if(parent.playerInDragonSlot == DWS_Window2_5)
		{
			parent.playerIsDown = false;
			positionNode = theGame.GetNodeByTag('d_window2_4');
		}
		dragonPosition = positionNode.GetWorldPosition();
		dragonRotation = positionNode.GetWorldRotation();
		parent.TeleportWithRotation(dragonPosition, dragonRotation);
		
	}
	entry function DragonUpdate()
	{
		while (true)
		{
			SetDragonPosition();
			parent.dragonAction = ChooseDragonWindowAction();
			PerformDragonWindowAction(parent.dragonAction);
			Sleep(0.5);
		}
	}
}
class CDragonA3Area extends CEntity
{
	editable var dragonAreaType : EDragonAreaType;
	editable var coliderTemplate : CEntityTemplate;
	editable var dragonTemplate : CEntityTemplate;
	editable var dragonAreaSlot : EDragonWindowSlot;
	var dragon : CDragonA3Windowss;
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var areaName : string;
		var affectedEntity : CEntity;
		var coliderNode : CNode;
		var enterComponent, exitComponent : CTriggerAreaComponent;
		areaName = area.GetName();
		affectedEntity = activator.GetEntity();
		if(affectedEntity == thePlayer)
		{
			if((dragonAreaType == DAT_EndAreaWindows2 ||  dragonAreaType == DAT_EndAreaWindows1) && areaName == "Exit")
			{
				if(dragonAreaType == DAT_EndAreaWindows2)
				{
					coliderNode = theGame.GetNodeByTag('dragon_col_2');
				}
				else if(dragonAreaType == DAT_EndAreaWindows1)
				{
					coliderNode = theGame.GetNodeByTag('dragon_col_1');
				}
				theGame.CreateEntity(coliderTemplate, coliderNode.GetWorldPosition(), coliderNode.GetWorldRotation());
				area.SetEnabled(false);

			}
			else if((dragonAreaType == DAT_AreaWindows2 || dragonAreaType == DAT_AreaWindows1) && areaName == "Enter")
			{
				dragon = (CDragonA3Windowss)theGame.GetEntityByTag('dragon_a3');
				if(dragon)
				{
					dragon.SetDragonSlot(dragonAreaSlot);
				}
				else
				{
					Log("ERROR: CDragonA3Area - no dragon");
				}
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}

}*/