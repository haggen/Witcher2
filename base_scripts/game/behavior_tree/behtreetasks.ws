/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree Machine Tasks
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////
// DebugLog
/////////////////////////////////////////////////////////////////////
class CBTTaskDebugLog extends IBehTreeTask
{
	editable var text : string;
	
	function OnBegin() : EBTNodeStatus
	{
		Log( text );
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// InitTree
/////////////////////////////////////////////////////////////////////
class CBTTaskInitTree extends IBehTreeTask
{
	editable var clearRotationTarget : bool;
	editable var disableLookAt : bool;
	editable var keepCombatMode : bool;
	editable var forceIdle : bool;
	
	default clearRotationTarget = true;
	default disableLookAt = true;
	default keepCombatMode = true;
	default forceIdle = true;
	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		
		if( clearRotationTarget )
		{
			npc.ClearRotationTarget();
		}
		
		if( disableLookAt )
		{
			npc.DisableLookAt();
		}
		
		if( keepCombatMode )
		{
			if( npc.GetTarget() == thePlayer )
			{
				//thePlayer.KeepCombatMode();
			}
		}
		
		if( forceIdle )
		{
			npc.RaiseForceEvent( 'Idle' );
		}
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// RaiseEvent
/////////////////////////////////////////////////////////////////////
class CBTTaskRaiseEvent extends IBehTreeTask
{
	editable var eventName : name;
	editable var forced : bool;
	editable var wait : bool;
	editable var deactivationName : name;
	
	default forced = false;
	default wait = false;
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", eventName );
	}
	
	function OnBegin() : EBTNodeStatus
	{
		var res : bool;
		
		GetActor().ActionCancelAll();
		
		if( forced )		
			res = GetActor().RaiseForceEvent( eventName );		
		else		
			res = GetActor().RaiseEvent( eventName );		
		
		if( !res )
			return BTNS_Failed;
			
		if( wait )		
			return BTNS_Active;		
		else
			return BTNS_Completed;
	}

	latent function Main() : EBTNodeStatus
	{		
		var actor : CActor;
		var res : bool;
		actor = GetActor();
		res = actor.WaitForBehaviorNodeDeactivation( deactivationName );
		if( res )
			return BTNS_Completed;
		else
			return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// SetBehaviorVariable
/////////////////////////////////////////////////////////////////////
class CBTTaskSetBehaviorVariable extends IBehTreeTask
{
	editable var variableName : string;
	editable var value : float;
	
	default value = 0.0;
	
	function OnBegin() : EBTNodeStatus
	{		
		GetActor().SetBehaviorVariable( variableName, value );
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// FindCombatSlotPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskFindCombatSlotPosition extends IBehTreeTask
{
	editable var exclusive : bool;
	default exclusive = false;
	
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		var dest : Vector;
		
		npc = GetNPC();		
		target = npc.GetTarget();
		
		if( target.GetCombatSlots().LoadCombatSlotPosition( npc, exclusive, dest ) )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// FindCombatSlotNoPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskFindCombatSlotNoPosition extends IBehTreeTask
{
	editable var exclusive : bool;
	default exclusive = false;
	
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;		
		
		npc = GetNPC();		
		target = npc.GetTarget();
		
		if( target.GetCombatSlots().FindCombatSlotNoPosition( npc, exclusive ) )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// AssignFarSlot
/////////////////////////////////////////////////////////////////////
class CBTTaskAssignFarSlot extends IBehTreeTask
{	
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;
		
		npc = GetNPC();		
		target = npc.GetTarget();
		
		if( target.GetCombatSlots().AssignFarSlot( npc ) )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// LeaveCombatIdle
/////////////////////////////////////////////////////////////////////
class CBTTaskLeaveCombatIdle extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{			
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		
		target.GetCombatSlots().LeaveCombatIdle( npc );
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// PlayCombatIdleAnim
/////////////////////////////////////////////////////////////////////
class CBTTaskPlayCombatIdleAnim extends IBehTreeTask
{
	editable var useEnum : bool;
	function DrawWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawShield()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_shield', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawSecondaryWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon_secondary', false);
		npc.DrawItemInstant(weapon);
	}
	latent function Main() : EBTNodeStatus
	{
		var idleEvent : name;
		var npc : CNewNPC;
		var idleEnum : W2BehaviorCombatIdle;
		npc = GetNPC();
				//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.
		if( npc.GetCurrentCombatType() == CT_ShieldSword )
		{
			if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawShield();
			}
		}
		else if( npc.GetCurrentCombatType() == CT_Dual || npc.GetCurrentCombatType() == CT_Dual_Assasin )
		{
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawSecondaryWeapon();
			}
		}
		else if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId() && !npc.IsMonster())
		{
			DrawWeapon();
		}
		npc.ActionCancelAll();
		
		if( useEnum )
		{
			idleEnum = npc.GetCombatEventsProxy().GetIdleEnum();
			npc.SetBehaviorVariable( 'IdleEnum', (int)idleEnum );
			idleEvent = 'CombatIdle';
		}
		else
		{
			idleEvent = npc.GetCombatEventsProxy().GetIdleEventName();	
		}
		
		if( idleEvent == '' )
		{
			Sleep( 0.2 );
		}
		else
		{
			if( npc.RaiseForceEvent( idleEvent ) )
			{
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'CombatIdleEnd' );
			}
			else
			{
				return BTNS_Failed;
			}
		}
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// ToSlotAttack
/////////////////////////////////////////////////////////////////////
class CBTTaskToSlotAttack extends IBehTreeTask
{
	editable var useEnum : bool;
	editable var noAngleTest : bool;
	default noAngleTest = false;
	editable var MinDist : float;
	editable var MaxDist : float;
	
	default MinDist = 1.5;
	default MaxDist = 7.0;

	function DrawWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawShield()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_shield', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawSecondaryWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon_secondary', false);
		npc.DrawItemInstant(weapon);
	}
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}

	latent function Main() : EBTNodeStatus
	{
		var dist, dot : float;
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var npcPos, targetPos, slotPos : Vector;
		var targetToSlotVec, targetToNPCVec : Vector;
		var idx, subIndex : int;
		var offset : float;
		var res : bool;
		var chargeEnum : W2BehaviorCombatAttack;
		
		npc = GetNPC();
		target = npc.GetTarget();	
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.
		if( npc.GetCurrentCombatType() == CT_ShieldSword )
		{
			if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawShield();
			}
		}
		else if( npc.GetCurrentCombatType() == CT_Dual || npc.GetCurrentCombatType() == CT_Dual_Assasin )
		{
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawSecondaryWeapon();
			}
		}
		else if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId() && !npc.IsMonster()&& !npc.HasCombatType(CT_Bow) && !npc.HasCombatType(CT_Bow_Walking))
		{
			DrawWeapon();
		}	
		if(target == thePlayer)
		{
			//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje ataku na gracza
			thePlayer.KeepCombatMode();
		}
		npcPos = npc.GetWorldPosition();
		targetPos = target.GetWorldPosition();
		dist = VecDistance( targetPos, npcPos );		
		if( dist > MinDist && dist < MaxDist )
		{
			idx = target.GetCombatSlots().GetCombatSlotIndex( npc, subIndex );
			if( ( idx < 0 ) || !target.GetCombatSlots().GetCombatSlotNavMeshPosition( npc, idx, subIndex, slotPos ) )
			{
				return BTNS_Failed;
			}
		
			targetToSlotVec = slotPos - targetPos;
			targetToNPCVec = VecNormalize( npcPos - targetPos );
			dot = VecDot( VecNormalize( targetToSlotVec ), targetToNPCVec );
			
			if( dot > 0.707 || noAngleTest )
			{
				offset = target.GetRadius() + npc.GetRadius() + 0.2;
				if( npc.GetMovingAgentComponent().CanGoStraightToDestination( targetPos + targetToNPCVec*offset ) )
				{
					npc.ActionCancelAll();
					npc.SetRotationTarget( target );
					npc.SetAttackTarget( target );
					npc.offSlot = OS_None;
					
					if( useEnum )
					{
						eventName = 'Attack';
						chargeEnum = npc.GetCombatEventsProxy().GetChargeEnum();
						npc.SetBehaviorVariable( 'AttackEnum', (int)chargeEnum );
					}
					else
					{
						eventName = npc.GetCombatEventsProxy().GetChargeAttackShortEventName();					
					}
					res = npc.RaiseForceEvent( eventName );
					if( res )
					{					
						if( useEnum )
						{
							Sleep(0.1);
							npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
						}
						else
						{
							Sleep(0.1);
							npc.WaitForBehaviorNodeDeactivation( 'ChargeEnd' );			
						}
					}				
					npc.ClearRotationTarget();
					if( res )
					{
						return BTNS_Completed;
					}
				}
			}
		}
		
		return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// CombatTeleport
/////////////////////////////////////////////////////////////////////
class CBTTaskCombatTeleport extends IBehTreeTask
{	
	editable inlined var provider : IAIPositionProvider;
	editable inlined var conditions : array< IAIPositionCondition >;
	editable var maxTests : int;
	editable var baseScore : float;
	editable var minScore : float;
		
	default maxTests = 10;
	default minScore = 0;


	editable var 	disappearanceFX 			: name;
	editable var 	disappearanceDuration		: float;
	editable var	disappearanceEntityAlias	: string;
	
	editable var 	appearanceFX 				: name;
	editable var 	appearanceDuration 			: float;
	editable var	appearanceEntityAlias		: string;
		
	editable var	useAnimEvents				: bool;

	private var		teleportPos					: Vector;
	private var		wasAttackable				: bool;
	private var		wasBlockingHit				: bool;
	
	private var 	disappearanceEntityTemplate : CEntityTemplate;
	private var 	appearanceEntityTemplate : CEntityTemplate;
	
	
	default disappearanceFX					= 'teleport_disappear';
	default disappearanceDuration 			= 1.0;
	default disappearanceEntityAlias		= "fx\mage_teleport_pre";
	
	default appearanceFX					= 'teleport_appear';
	default appearanceDuration 				= 1.0;	
	default appearanceEntityAlias			= "fx\mage_teleport_post";
	
	default useAnimEvents = true;
	
	var teleported	: bool;
	
	// --------------------------------------------------------------------
	// IBehTreeTask implementation
	// --------------------------------------------------------------------
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", maxTests );
	}
	
	function OnBegin() : EBTNodeStatus
	{
		if( GetTeleportPosition() )
		{		
			return BTNS_Active;
		}
		else
		{
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc 		: CNewNPC 	= GetNPC();
		var entity		: CEntity;
		var aoe			: CAreaOfEffect;		
		// disable AI params for the teleport time being
		if(!npc.CanTeleport())
		{	
			return BTNS_Failed;
		}
		
		npc.SetDamageReaction( false );

		disappearanceEntityTemplate = LoadTemplate( disappearanceEntityAlias );
		appearanceEntityTemplate = LoadTemplate( appearanceEntityAlias );

		// make the NPC disappear
				
		if( useAnimEvents )
		{
			npc.RaiseForceEvent ('Teleport');
			
			Sleep(2.15);
			npc.ActionCancelAll();
			npc.SetIsTeleporting( true );
			npc.SetImmortalityModeRuntime( AIM_Invulnerable );
			npc.SetAttackableByPlayerRuntime( false );
			wasBlockingHit =  npc.IsBlockingHit();
			npc.SetBlockingHit( true, 30 );
			teleported = true;
			
			npc.WaitForBehaviorNodeDeactivation ('TeleportEnded');
		}	
		else
		{
			//first we need to spawn despawn entity first.
			CreateEntity( disappearanceEntityTemplate, npc.GetWorldPosition() );
			npc.RaiseForceEvent ('Teleport');
			npc.StopEffect('default_fx');
			Sleep(0.7);
			
			npc.ActionCancelAll();
			npc.SetIsTeleporting( true );
			npc.SetImmortalityModeRuntime( AIM_Invulnerable );
			npc.SetAttackableByPlayerRuntime( false );
			wasBlockingHit =  npc.IsBlockingHit();
			npc.SetBlockingHit( true, 30 );
			
			npc.PlayEffect( disappearanceFX );
			
			Sleep(0.3);
			//npc.WaitForBehaviorNodeDeactivation('TeleportEnd');
			
			npc.SetVisibility( false );
			Sleep( disappearanceDuration );
			
			PerformTeleport();
			
			// make the NPC appear
							
			// if area of effect set owner

			entity = CreateEntity( appearanceEntityTemplate, teleportPos );
			aoe = (CAreaOfEffect)entity;
			if( aoe )
			{
				aoe.SetOwner( npc );
			}
			npc.PlayEffect( appearanceFX );
			Sleep( appearanceDuration );
			npc.SetVisibility( true );
			if( npc.RaiseForceEvent ('TeleportEnd') )
			{
				npc.WaitForBehaviorNodeDeactivation ('TeleportEnded');
			}
			npc.PlayEffect('default_fx');
		}

		npc.SetVisibility( true );
		// restore attack state
		npc.SetImmortalityModeRuntime( AIM_None );
		npc.SetAttackableByPlayerRuntime( true );
		npc.SetIsTeleporting( false );
		npc.SetBlockingHit( wasBlockingHit );
		teleported = false;
		npc.SetDamageReaction( true );
		
		return BTNS_Completed;
	}
	
	function OnAbort()
	{
		var npc 		: CNewNPC 	= GetNPC();
		
		if (teleported)
		{
			npc.SetDamageReaction( true );
			teleported = false;
		}
		npc.SetImmortalityModeRuntime( AIM_None );
		npc.SetAttackableByPlayerRuntime(true);
		npc.SetIsTeleporting( false );		
		npc.SetBlockingHit( wasBlockingHit );
		npc.SetVisibility( true );
	}
		
	event OnAnimEvent( animEventName : name, animEventType : EAnimationEventType )
	{
		var entity		: CEntity;
		var aoe			: CAreaOfEffect;
	
		if( animEventName == 'TeleportPreFx' )
		{
			GetNPC().PlayEffect( disappearanceFX );
		}
		else if( animEventName == 'TeleportPostFx' )
		{
			GetNPC().PlayEffect( appearanceFX );
		}
		else if( animEventName == 'TeleportPreEntity' )
		{
			CreateEntity( disappearanceEntityTemplate, GetNPC().GetWorldPosition() );
		}
		else if( animEventName == 'TeleportPostEntity' )
		{
			entity = CreateEntity( appearanceEntityTemplate, teleportPos );
			aoe = (CAreaOfEffect)entity;
			if( aoe )
			{
				aoe.SetOwner( GetNPC() );
			}
		}
		else if( animEventName == 'TeleportBegin' )
		{
			GetNPC().SetVisibility( false );
			PerformTeleport();
		}
		else if( animEventName == 'TeleportEnd' )
		{
			GetNPC().SetVisibility( true );
		}
	}
	
	// --------------------------------------------------------------------
	// helper methods
	// --------------------------------------------------------------------
	
	private function PerformTeleport()
	{
		var npc : CNewNPC = GetNPC();
		var rot	: EulerAngles;
		
		if( !GetTeleportPosition() )
		{		
			teleportPos = npc.GetWorldPosition();
		}
		
		rot = VecToRotation( npc.GetTarget().GetWorldPosition() - teleportPos );
		rot.Pitch = 0.0;
		rot.Roll = 0.0;		
		npc.TeleportWithRotation( teleportPos, rot );
	}
	
	private function GetTeleportPosition() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = npc.GetTarget();
		var score : float;
		var eval : CAIPositionEvaluator = theGame.GetAIPositionEvaluator();
		score = eval.FindPosition( target, npc, provider, conditions, maxTests, baseScore, teleportPos );
		
		if( score >= minScore )
			return true;
		else
			return false;
	}
	
	private latent function LoadTemplate( alias : string ) : CEntityTemplate
	{
		var entityTemplate : CEntityTemplate;
		if( alias != "" )
		{
			entityTemplate = (CEntityTemplate)LoadResource( alias );
			return entityTemplate;
		}
		else
		{
			return NULL;
		}
	}
	
	private function CreateEntity( templ : CEntityTemplate, pos : Vector ) : CEntity
	{
		if( templ )
		{
			return theGame.CreateEntity(templ, pos, GetNPC().GetWorldRotation());
		}	
		return NULL;
	}
}
/////////////////////////////////////////////////////////////////////
// TaskKeepCombatMode
/////////////////////////////////////////////////////////////////////
class CBTTaskKeepCombatMode extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;	
		var target : CActor;
		npc = GetNPC();
		target = npc.GetTarget();
		Sleep(0.1);
		if( npc.IsMoving() )
		{
			if(target == thePlayer && npc.GetMovingAgentComponent().GetMoveSpeedAbs() > 0)
			{
				//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje podazania za graczem w combat.
				//Dzieki wywolaniu tej metody tutaj, unikamy koniecznosci wstawienia sekwencji 
				//w kazdym drzewku (behtree) combatowym i wywolywania oddzielnej akcji podtrzymania
				//combat mode
				if(npc.GetCurrentCombatType()!=CT_Bow && npc.GetCurrentCombatType()!=CT_Bow_Walking)
					thePlayer.KeepCombatMode();
			}
			return BTNS_Completed;
		}
			
		return BTNS_Failed;
	}
}
/////////////////////////////////////////////////////////////////////
// Attack
/////////////////////////////////////////////////////////////////////
class CBTTaskAttack extends IBehTreeTask
{
	editable var blockHitTime : float;
	editable var attackRangeTest : bool;
	editable var useEnum : bool;
	var playerState : EPlayerState;
	default blockHitTime = 0.0;
	default attackRangeTest = true;


	function DrawWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawShield()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_shield', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawSecondaryWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon_secondary', false);
		npc.DrawItemInstant(weapon);
	}
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;		
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.
		if( npc.GetCurrentCombatType() == CT_ShieldSword )
		{
			if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawShield();
			}
		}
		else if( npc.GetCurrentCombatType() == CT_Dual || npc.GetCurrentCombatType() == CT_Dual_Assasin )
		{
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawSecondaryWeapon();
			}
		}
		else if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId() && !npc.IsMonster() && !npc.HasCombatType(CT_Bow) && !npc.HasCombatType(CT_Bow_Walking))
		{
			DrawWeapon();
		}
		if( attackRangeTest == false || npc.InAttackRange( target ) )
		{
			if(target == thePlayer)
			{
				//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje ataku na gracza i nie jest to lucznik
				if(npc.GetCurrentCombatType()!=CT_Bow && npc.GetCurrentCombatType()!=CT_Bow_Walking)
				{
					thePlayer.KeepCombatMode();
				}
			}
			if(target == thePlayer)
			{
				playerState = thePlayer.GetCurrentPlayerState();
				if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
					return BTNS_Failed;
			}
			if( ExtraTest() )
			{
				return BTNS_Active;
			}
			
		}
		
		return BTNS_Failed;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var attackEnum : W2BehaviorCombatAttack;
		var res : EBTNodeStatus = BTNS_Failed;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		npc.ActionCancelAll();
		
		if( blockHitTime > 0.0 )
		{
			npc.SetBlockingHit(true, blockHitTime);
		}

		npc.SetAttackTarget( target );
		if( useEnum )
		{		
			eventName = 'Attack';
			attackEnum = npc.GetCombatEventsProxy().GetAttackEnum();
			npc.SetBehaviorVariable( 'AttackEnum', (int)attackEnum );
		}
		else
		{
			eventName = npc.GetCombatEventsProxy().GetAttackEventName();
		}
		
		if( npc.RaiseForceEvent( eventName ) )
		{
			Sleep(0.1);
			npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );	
			res = BTNS_Completed;
		}
			
		Cleanup();
		
		return res;
	}
	
	private function ExtraTest() : bool { return true; }
	private function Cleanup();
}

/////////////////////////////////////////////////////////////////////
// Charge
/////////////////////////////////////////////////////////////////////
class CBTTaskCharge extends IBehTreeTask
{
	editable var useRotationTarget : bool;
	editable var blockHitTime : float;
	editable var useEnum : bool;

	default useRotationTarget = true;
	default blockHitTime = 0.0;
	
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}
	function DrawWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawShield()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_shield', false);
		npc.DrawItemInstant(weapon);
	}
	function DrawSecondaryWeapon()
	{
		var weapon : SItemUniqueId;
		var npc : CNewNPC;
		npc = GetNPC();
		weapon = npc.GetInventory().GetItemByCategory('opponent_weapon_secondary', false);
		npc.DrawItemInstant(weapon);
	}
	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		// we need to make sure the npc can use charge attacks
		if ( npc.CanUseChargeAttack() == false )
		{
			return BTNS_Failed;
		}
		else
		{
			return BTNS_Active;
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var playerState : EPlayerState;
		var chargeEnum : W2BehaviorCombatAttack;
		
		npc = GetNPC();
		target = npc.GetTarget();
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.
		if( npc.GetCurrentCombatType() == CT_ShieldSword )
		{
			if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawShield();
			}
		}
		else if( npc.GetCurrentCombatType() == CT_Dual || npc.GetCurrentCombatType() == CT_Dual_Assasin )
		{
			if(npc.GetCurrentWeapon(CH_Left) == GetInvalidUniqueId())
			{
				DrawWeapon();
			}
			if(npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId())
			{
				DrawSecondaryWeapon();
			}
		}
		else if( npc.GetCurrentWeapon(CH_Right) == GetInvalidUniqueId() && !npc.IsMonster()&& !npc.HasCombatType(CT_Bow) && !npc.HasCombatType(CT_Bow_Walking))
		{
			DrawWeapon();
		}
		if(target == thePlayer)
		{
			//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje szarzy na gracza
			thePlayer.KeepCombatMode();
		}
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
		
		npc.ActionCancelAll();
		
		if( blockHitTime > 0.0 )
		{
			npc.SetBlockingHit(true, blockHitTime);
		}
						
		npc.SetAttackTarget( target );
		if( useRotationTarget )
		{
			npc.SetRotationTarget( target );
		}
		else
		{
			npc.ClearRotationTarget();
		}
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
		if( useEnum )
		{
			eventName = 'Attack';
			chargeEnum = npc.GetCombatEventsProxy().GetChargeEnum();
			npc.SetBehaviorVariable( 'AttackEnum', (int)chargeEnum );
		}
		else
		{
			eventName = npc.GetCombatEventsProxy().GetChargeAttackEventName();
		}
		
		
		if( npc.RaiseForceEvent( eventName ) )
		{
			if( useEnum )
			{
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
			}
			else
			{
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'ChargeEnd' );			
			}
			npc.ClearRotationTarget();
			return BTNS_Completed;	
		}
		
		npc.ClearRotationTarget();
		
		return BTNS_Failed;
	}
}
/////////////////////////////////////////////////////////////////////
// SpecialAttack
/////////////////////////////////////////////////////////////////////
enum ESpecialAttackSet
{
	SAS_Set1,
	SAS_Set2,
	SAS_Set3,
	SAS_Set4,
	SAS_Set5
};
class CBTTaskAttackSpecial extends IBehTreeTask
{
	editable var useRotationTarget : bool;
	editable var blockHitTime : float;
	editable var specialAttackSet : ESpecialAttackSet;

	default specialAttackSet = SAS_Set1;
	default useRotationTarget = true;
	default blockHitTime = 0.0;
	
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}
	function OnBegin() : EBTNodeStatus
	{
		var target : CActor;
		var npc : CNewNPC;		
		
		npc = GetNPC();
		target = npc.GetTarget();
		//MSZ: ja to jednak zabezpiecze, bo wciaz zdarzaja sie sytuacje, gdzie NPC walczy bez broni.

		
		if(target == thePlayer)
		{
				//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje ataku na gracza i nie jest to lucznik
			if(npc.GetCurrentCombatType()!=CT_Bow && npc.GetCurrentCombatType()!=CT_Bow_Walking)
			{
				thePlayer.KeepCombatMode();
				
			}
		}
		if( ExtraTest() )
		{
			return BTNS_Active;
		}

		return BTNS_Failed;
	}
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var specialAttackEnum : W2BehaviorCombatAttack;
		var res : EBTNodeStatus = BTNS_Failed;
		var playerState : EPlayerState;
		
		npc = GetNPC();
		target = npc.GetTarget();
		if(target == thePlayer)
		{
			//MSZ: Podtrzymujemy combat mode, gdy ktos ma akcje ataku na gracza
			thePlayer.KeepCombatMode();
		}
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
		
		npc.ActionCancelAll();
		
		if( blockHitTime > 0.0 )
		{
			npc.SetBlockingHit(true, blockHitTime);
		}
						
		npc.SetAttackTarget( target );
		if( useRotationTarget )
		{
			npc.SetRotationTarget( target );
		}
				
		eventName = 'Attack';
		specialAttackEnum = npc.GetCombatEventsProxy().GetSpecialAttackEnum(specialAttackSet);
		if( specialAttackEnum != BCA_None )
		{
			npc.SetBehaviorVariable( 'AttackEnum', (int)specialAttackEnum );
			
			if( npc.RaiseForceEvent( eventName ) )
			{
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );						
				npc.ClearRotationTarget();
				npc.StartsWithCombatIdle(false);
				res =  BTNS_Completed;	
			}
		}
		
		npc.ClearRotationTarget();
		Cleanup();
		return res;
	}
	private function ExtraTest() : bool { return true; }
	private function Cleanup();
}
/////////////////////////////////////////////////////////////////////
// Throw
/////////////////////////////////////////////////////////////////////
class CBTTaskThrow extends IBehTreeTask
{
	editable var useRotationTarget : bool;
	editable var blockHitTime : float;

	default useRotationTarget = true;
	default blockHitTime = 0.0;
	
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var throwEnum : W2BehaviorCombatAttack;
		var playerState : EPlayerState;
		npc = GetNPC();
		target = npc.GetTarget();
		
		npc.ActionCancelAll();
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return BTNS_Failed;
		}
		
		if( blockHitTime > 0.0 )
		{
			npc.SetBlockingHit(true, blockHitTime);
		}
						
		npc.SetAttackTarget( target );
		if( useRotationTarget )
		{
			npc.SetRotationTarget( target );
		}
				
		eventName = 'Attack';
		throwEnum = npc.GetCombatEventsProxy().GetThrowEnum();
		if( throwEnum != BCA_None )
		{
			npc.SetBehaviorVariable( 'AttackEnum', (int)throwEnum );
			
			if( npc.RaiseForceEvent( eventName ) )
			{
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );						
				npc.ClearRotationTarget();
				return BTNS_Completed;	
			}
		}
		
		
		npc.ClearRotationTarget();
		
		return BTNS_Failed;
	}
}
/////////////////////////////////////////////////////////////////////
// StartWithTaunt
/////////////////////////////////////////////////////////////////////
class CBTTaskStartWithTaunt extends IBehTreeTask
{
	editable var useRotationTarget : bool;

	default useRotationTarget = true;
	
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;
		var eventName : name;
		var tauntEnum : W2BehaviorCombatIdle;
		var playerState : EPlayerState;
		npc = GetNPC();
		target = npc.GetTarget();
		
		npc.ActionCancelAll();
		
		
		if(!npc.ShouldStartFightWithCombatIdle())
		{
			npc.StartsWithCombatIdle(false);
			return BTNS_Failed;
		}
		
		npc.StartsWithCombatIdle(false);				
		npc.SetAttackTarget( target );
		if( useRotationTarget )
		{
			npc.SetRotationTarget( target );
		}
				
		eventName = 'CombatIdle';
		tauntEnum = npc.GetCombatEventsProxy().GetIdleEnum();
		if( tauntEnum != BCI_None )
		{
			npc.SetBehaviorVariable( 'IdleEnum', (int)tauntEnum );
			
			if( npc.RaiseForceEvent( eventName ) )
			{
				npc.StartsWithCombatIdle(false);
				Sleep(0.1);
				npc.WaitForBehaviorNodeDeactivation( 'CombatIdleEnd', 4.0 );						
				npc.ClearRotationTarget();
				return BTNS_Completed;	
			}
		}
		
		npc.StartsWithCombatIdle(false);
		npc.ClearRotationTarget();
		
		return BTNS_Failed;
	}
}
/////////////////////////////////////////////////////////////////////
// Block
/////////////////////////////////////////////////////////////////////
class CBTTaskBlock extends IBehTreeTask
{
	editable var startEvent : name;
	editable var stopEvent : name;
	editable var startDeactivationNotification : name;
	editable var stopDeactivationNotification : name;
	editable var time : float;

	default time = 5.0;
	
	function OnAbort()
	{
		GetNPC().SetBlockingHit( false );
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.ActionCancelAll();
		
		npc.SetBlockingHit(true, time);		
		
		if( !npc.RaiseForceEvent( startEvent ) )
		{
			return BTNS_Failed;
		}
		
		if( IsNameValid( startDeactivationNotification ) )
		{
			npc.WaitForBehaviorNodeDeactivation( startDeactivationNotification );	
		}
		
		Sleep( time );
		
		if( !npc.RaiseEvent( stopEvent ) )
		{
			return BTNS_Failed;
		}
		
		if( IsNameValid( stopDeactivationNotification ) )
		{
			npc.WaitForBehaviorNodeDeactivation( stopDeactivationNotification );	
		}
				
		npc.SetBlockingHit( false );
		
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// CircleTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskCircleTarget extends IBehTreeTask
{	
	function OnAbort()
	{
		GetNPC().ClearRotationTarget();
	}
	
	// TEMPSHIT CIRCLE OFF
	/*function OnBegin() : EBTNodeStatus
	{
		
		return BTNS_Completed;
	}*/

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var target : CActor;		
		var slotIndex, slotSubIndex : int;
		var slotPosition : Vector;
		var slide : bool;
		var eventName : name;
		var mat : Matrix;
		var vec : Vector;
		var rot : EulerAngles;
		var dist : float;
		var result : bool;
		var oldOffSlot : EOffSlot;
		
		npc = GetNPC();
		target = npc.GetTarget();
		
		npc.ActionCancelAll();
		
		slotIndex = target.GetCombatSlots().GetCombatSlotIndex( npc, slotSubIndex );
		if( slotIndex < 0 )
		{
			//Log("CBTTaskCircleTarget invalid slotIndex");
			return BTNS_Failed;
		}
		
		// only from primary slot
		if( slotSubIndex != 0 )
		{
			return BTNS_Failed;
		}
		
		
		slide = false;
		
		oldOffSlot = npc.offSlot;
		
		if( npc.offSlot == OS_None )
		{
			if( Rand(2) == 1 )				
				npc.offSlot = OS_Right;
			else
				npc.offSlot = OS_Left;
				
			eventName = npc.GetCombatEventsProxy().GetCircleEventName( npc.offSlot );
		}
		else if( npc.offSlot == OS_Left )
		{
			eventName = npc.GetCombatEventsProxy().GetCircleEventName( OS_Right );
			npc.offSlot = OS_None;
			slide = true;
		}
		else
		{
			eventName = npc.GetCombatEventsProxy().GetCircleEventName( OS_Left );
			npc.offSlot = OS_None;
			slide = true;
		}
		
		if( eventName != '' )
		{			
			if( slide )
			{
				if( !target.GetCombatSlots().GetCombatSlotNavMeshPosition( npc, slotIndex, slotSubIndex, slotPosition ) )
				{
					slide = false;
				}
			}
			
			npc.SetRotationTarget( target );
			if( npc.RaiseForceEvent( eventName ) )
			{
				npc.WaitForBehaviorNodeDeactivation( 'CircleEnd' );		
			}
			else
			{
				npc.offSlot = oldOffSlot;
			}
			
			npc.ClearRotationTarget();			
			
			if( slide )
			{
				dist = VecDistance2D( slotPosition, npc.GetWorldPosition() );
				if( dist > 0.1 && dist < 0.5f )
				{
					vec = VecNormalize( target.GetWorldPosition() - npc.GetWorldPosition() );
					rot = VecToRotation( vec );
					npc.ActionSlideToWithHeading( slotPosition, rot.Yaw, 0.2 );
				}
				//parent.ActionMoveToWithHeading( slotPosition, rot.Yaw, MT_Walk, 1.0, 0.5, 0 );
			}
			
			result = true;
		}
		else
		{
			//npc.offSlot = OS_None;
			result = false;
		}
		
		if( result )
			return BTNS_Completed;
		else
			return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// PlayVoiceset
/////////////////////////////////////////////////////////////////////
class CBTTaskPlayVoiceset extends IBehTreeTask
{
	editable var emotion : name;	
	editable var wait : bool;
	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();		
		
		if ( npc.PlayVoiceset( npc.GetCurrentActionPriority()+1, emotion ) )
		{
			if( wait )
				return BTNS_Active;
			else
				return BTNS_Completed;
		}
		
		return BTNS_Failed;
	}

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		npc.WaitForEndOfSpeach();
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// SetRotationTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskSetRotationTarget extends IBehTreeTask
{	
	editable var clamping : bool;
	default clamping = true;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		npc.SetRotationTarget( npc.GetTarget(), clamping );	
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// ClearRotationTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskClearRotationTarget extends IBehTreeTask
{	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		npc.ClearRotationTarget();
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// SetHeadingTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskSetHeadingTarget extends IBehTreeTask
{
	function GetLabel( out label : string )
	{
		label += " OBSOLETE";
	}

	function OnBegin() : EBTNodeStatus
	{		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// ClearHeadingTarget
/////////////////////////////////////////////////////////////////////
class CBTTaskClearHeadingTarget extends IBehTreeTask
{
	function GetLabel( out label : string )
	{
		label += " OBSOLETE";
	}

	function OnBegin() : EBTNodeStatus
	{		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// EnableLookAt
/////////////////////////////////////////////////////////////////////
class CBTTaskEnableLookAt extends IBehTreeTask
{	
	var duration : float;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		npc.EnableDynamicLookAt( npc.GetTarget(), duration );	
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// DisableLookAt
/////////////////////////////////////////////////////////////////////
class CBTTaskDisableLookAt extends IBehTreeTask
{	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		npc.DisableLookAt();
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// ExitWork 
/////////////////////////////////////////////////////////////////////
class CBTTaskExitWork extends IBehTreeTask
{
	editable var mode : EExitWorkMode;

	latent function Main() : EBTNodeStatus
	{
		if( mode == EWM_Break )
			GetActor().ActionCancelAll();
		else if( mode == EWM_Exit )
			GetActor().ActionExitWork( false );
		else if( mode == EWM_ExitFast )
			GetActor().ActionExitWork( true );
		else if( mode == EWM_None )
		{
		}
		else		
		{
			Log("ERROR: CBTTaskExitWork unknown mode" );
			return BTNS_Failed;
		}			
			
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// BlackboardOperation
/////////////////////////////////////////////////////////////////////
enum EBlackboardOp
{
	BO_SetFloat,
	BO_AddFloat,
	BO_SetTimeNow,
	BO_SetTimeNowIfCleared,
	BO_ClearTime,
	BO_MarkCooldownTime,
};

class CBTTaskBlackboardOperation extends IBehTreeTask
{	
	editable var globalBlackboard : bool;
	editable var entryName : name;
	editable var operation : EBlackboardOp;
	editable var valueFloat : float;
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", entryName );
	}

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var bb : CBlackboard;
		var tempFloat : float;
		var tm : EngineTime;
		
		if( !IsNameValid( entryName ) )
			return BTNS_Failed;
		
		if( globalBlackboard )		
			bb = theGame.GetBlackboard();		
		else		
			bb = npc.GetLocalBlackboard();

		if( operation == BO_SetFloat )
		{
			bb.AddEntryFloat( entryName, valueFloat );
		}
		else if( operation == BO_AddFloat )
		{
			bb.GetEntryFloat(entryName, tempFloat );
			bb.AddEntryFloat(entryName, tempFloat + valueFloat );
		}
		else if( operation == BO_SetTimeNow )
		{
			bb.AddEntryTime( entryName, theGame.GetEngineTime() );
		}
		else if( operation == BO_SetTimeNowIfCleared )
		{
			if( !bb.GetEntryTime( entryName, tm ) || tm == EngineTime() )
			{
				bb.AddEntryTime( entryName, theGame.GetEngineTime() );
			}
		}	
		else if( operation == BO_ClearTime )
		{
			bb.AddEntryTime( entryName, EngineTime() );
		}
		else if( operation == BO_MarkCooldownTime )
		{
			bb.AddEntryTime( entryName, theGame.GetEngineTime() );
		}			
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// Battlecry
/////////////////////////////////////////////////////////////////////
class CBTTaskBattlecry extends IBehTreeTask
{	
	editable var cooldown : float;
	default cooldown = 10.0;

	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var tm, currentTime : EngineTime;
		
		currentTime = theGame.GetEngineTime();
		theGame.GetBlackboard().GetEntryTime( 'battlecryTask', tm );

		if( currentTime > tm + cooldown )
		{
			npc = GetNPC();		
			npc.PlayVoiceset( 100, "battlecry" );
			theGame.GetBlackboard().AddEntryTime( 'battlecryTask', currentTime );
		}
		
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// PlaySlotAnimation
/////////////////////////////////////////////////////////////////////
class CBTTaskPlaySlotAnimation extends IBehTreeTask
{	
	editable var animation : name;
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var res : bool;
		res = npc.ActionPlaySlotAnimation( 'NPC_ANIM_SLOT', animation );
		if( res )
			return BTNS_Completed;
		else
			return BTNS_Failed;
	}
}

/////////////////////////////////////////////////////////////////////
// MageActionSet
/////////////////////////////////////////////////////////////////////
enum EMageAction
{
	MA_Heal,
	MA_ShieldsUp,
	MA_RangedAttack,
	MA_MeleeAttack
}

class CBTTaskMageActionSet extends IBehTreeTask
{		
	editable var	action		: EMageAction;
	default	action				= MA_Heal;
	
	
	// --------------------------------------------------------------------
	// IBehTreeTask implementation
	// --------------------------------------------------------------------
	
	function GetLabel( out label : string )
	{
		label = StrFormat(" [%1]", action );
	}
	
	latent function Main() : EBTNodeStatus
	{
		var mage		: CNewNPC;
		var result		: bool				= false;
		
		mage = (CNewNPC)GetNPC();
		if ( !mage )
		{
			return BTNS_Failed;
		}
		else
		{
			switch( action )
			{
				case MA_Heal:
				{
					result = Heal();
					break;
				}
			
				case MA_ShieldsUp:
				{
					result = ShieldsUp();
					break;
				}
				
				case MA_RangedAttack:
				{
					result = RangedAttack();
					break;
				}
				case MA_MeleeAttack:
				{
					result = MeleeAttack();
					break;
				}
			}
		}
		
		if ( result )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Failed;
		}
	}
	function AttackEvent(attackEvent : W2BehaviorCombatAttack, mage : CNewNPC)
	{
		var attackEventInt : int;
		attackEventInt = (int)attackEvent;
		mage.SetBehaviorVariable("AttackEnum", (float)attackEventInt);
		mage.RaiseForceEvent('Attack');
	}
	latent function RangedAttack() : bool
	{	
		var magicTrap, magicBolt, magicFireball : SItemUniqueId;
		var npc : CNewNPC = GetNPC();
		var canUseMagicTrap, canUseMagicBolt, canUseFireball : bool;
		var target : CActor;
		var playerState : EPlayerState;
		
		npc.ActionCancelAll();
		target = npc.GetTarget();
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return false;
		}
		
		if(target == thePlayer)
		{
			//MSZ: Podtrzymujemy combat mode, gdy mag atakuje gracza
			thePlayer.KeepCombatMode();
		}
		magicBolt = npc.GetInventory().GetItemByCategory('magic_bolts', false);
		magicTrap = npc.GetInventory().GetItemByCategory('trap', false);
		magicFireball = npc.GetInventory().GetItemByCategory('projectile', false);
		if(canUseMagicTrap && Rand(4) == 1)
		{
			AttackEvent(BCA_Special3, npc);
		}
		else
		{
			AttackEvent(BCA_Special2, npc);
			npc.GetLocalBlackboard().AddEntryVector('rangedTargetPos', npc.GetTarget().GetWorldPosition());
		}
		Sleep(0.1);
		npc.WaitForBehaviorNodeDeactivation('AttackEnd');
		return true;
	}
	latent function MeleeAttack() : bool
	{
		var npc : CNewNPC;
		var target : CActor;
		var attackEnum : W2BehaviorCombatAttack;
		var res, canUseMagicAttack : bool;
		var aoeSpell : SItemUniqueId;
		var playerState : EPlayerState;
		
		
		npc = GetNPC();
		npc.ActionCancelAll();
		aoeSpell = npc.GetInventory().GetItemByCategory('magic', false);
		if(aoeSpell != GetInvalidUniqueId())
		{
			canUseMagicAttack = true;
		}
		else
		{
			canUseMagicAttack = false;
		}
		
		target = npc.GetTarget();
		
		if(target == thePlayer)
		{
			playerState = thePlayer.GetCurrentPlayerState();
			if(playerState == PS_Meditation || playerState == PS_Cutscene || thePlayer.IsInTakedownCutscene())	
				return false;
		}
		
		if(target == thePlayer)
		{
			//MSZ: Podtrzymujemy combat mode, gdy mag atakuje gracza
			thePlayer.KeepCombatMode();
		}			
		npc.SetAttackTarget( target );
		if(canUseMagicAttack && Rand(3)<2)
		{
			attackEnum = BCA_MeleeAttack4;
		}
		else
		{
			attackEnum = npc.GetCombatEventsProxy().GetAttackEnum();	
		}
		
		AttackEvent(attackEnum, npc);
		Sleep(0.1);
		npc.WaitForBehaviorNodeDeactivation( 'AttackEnd' );	
		res = true;
		
		
		return res;		 
	}
	latent function Heal() : bool
	{	
		var healRate : float;
		var npc : CNewNPC = GetNPC();
		npc.ActionCancelAll();
		healRate = npc.GetCharacterStats().GetAttribute('heal_spell');
		if(healRate <=0)
		{
			healRate = 5.0;
		}
		AttackEvent(BCA_Special1, npc);
		Sleep(1.0);
		npc.PlayEffect('heal_fx');
		npc.IncreaseHealth(healRate);
		Sleep(0.1);
		npc.WaitForBehaviorNodeDeactivation('AttackEnd');
		npc.StopEffect('heal_fx');
		return true;
	}
	latent function ShieldsUp() : bool
	{	
		var npc : CNewNPC = GetNPC();
		
		AttackEvent(BCA_Special1, npc);
		Sleep(0.1);
		npc.WaitForBehaviorNodeDeactivation('AttackEnd');		
		return true;
	}
	
}
/////////////////////////////////////////////////////////////////////
// ClearStartWithTaunt
/////////////////////////////////////////////////////////////////////
class CBTTaskClearStartWithTaunt extends IBehTreeTask
{	
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC;
		npc = GetNPC();
		npc.StartsWithCombatIdle(false);
		return BTNS_Completed;
	}
}

/////////////////////////////////////////////////////////////////////
// TeleportToFocusedPosition
/////////////////////////////////////////////////////////////////////
class CBTTaskTeleportToFocusedPosition extends IBehTreeTask
{
	function OnBegin() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var pos : Vector = npc.GetFocusedPositionRaw();		
		npc.Teleport( pos );
		return BTNS_Completed;
	}	
}
