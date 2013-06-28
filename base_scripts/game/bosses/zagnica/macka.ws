/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Zagnica's Macka classes
/////////////////////////////////////////////

class ZagnicaAttack extends CStateMachine
{
	var zgn : Zagnica;
	var isAttacking : bool;

	function MackaCanAttack() : bool;
	function PaszczaCanAttack() : bool;
	function StartAttack();
	function StopAttack();
}

//////////////////////////////////////////////
// Base Macka class
//////////////////////////////////////////////

class ZagnicaMacka extends ZagnicaAttack
{
	private var MacIndexNumber : int;
	private var isCut, horizontalStarted, arenaHolderStarted, isImmobilized, isThrowing : bool;
	private var MackaConstraintTarget : Vector;
	private var mackaBubble : TentadrakeBubble;

	private var attackEventV, VerticalAttackNotifier, VerticalAttackLookatEvent, VerticalLoopEvent : name;
	private var IdleActivateNotifier, IdleCutActivateNotifier, IdleDeactivateNotifier, CutCutsceneEvent, CutTrapCutsceneEvent : name;
	private var forceEndAnimation, bridgeAttackEvent1, bridgeAttackEvent2, bridgeAttackEvent3, bridgeAttackEvent4 : name;
	
	private var Lookat_Weight, Lookat, MacBodyPartName, MacStateWounded, MacStateDecapitated, MacStateCuted : name;
	private var ArenaHolderZone, ArenaHolderEvent, throwZone : name;
	private var yrdenEffectName, yrdenEffectName2, smokeEffectName, bubbleExplodeEffectName, bloodTrailsEffectName, hitEffectName : name;
	private var ThrowAttackEvent, startRodeoEvent, startRodeoBridgeEvent : name;
	
	private var attackZone, exitEventV, attackEventH, bubbleBoneName, hitEventName, immobilizedMouthEvent : name;
	private var FocusPointName : string;
	private var mackasBones : array<name>;
	
	private var IsBeingCut : bool;

	//checking if Macka can attack
	function MackaCanAttack() : bool
	{	
		if ( isAttacking || isCut || zgn.AreMackasCrossing( MacIndexNumber ) || zgn.ExclusiveAttackInProgress || zgn.HorizontalAttackInProgress || zgn.playerHasBeenHit )
		{
			return false;
		}
		else
		{
			return zgn.CheckInteractionPlayerOnly( attackZone );
		}
	}
	
	abstract function GetMackaBubblePosition() : Vector;
	abstract function BindVariables();
	abstract function GetMackaStartPosition() : Vector;
	abstract function GetMackaEndPosition() : Vector;
	abstract function GetMackaBubbleRotation() : EulerAngles;
	abstract function GetMackaStartRotation() : EulerAngles;
	abstract function GetMackaEndRotation() : EulerAngles;
	abstract function HasMackaBubble() : bool;
	abstract function StartAttack();
	
	function CanDoFinisherAttack() : bool 
	{ 
		return false; 
	}
	
	//checking from which side we are cutting macka
	function IsPlayerCutPositionLeft() : bool
	{
		var PointA, PointB, PlayerPosition : Vector;
		var Line, CheckedVector, Result : Vector;
		
		PointA = zgn.GetWorldPosition();
		PointA.Z = 0;
		PointB = GetMackaBubblePosition();
		PointB.Z = 0;
		PlayerPosition = thePlayer.GetWorldPosition();
		PlayerPosition.Z = 0;
		/*
		thePlayer.GetVisualDebug().AddSphere( 'macka_bubble_pos', 3, PointB, true, Color( 255, 0, 0 ) );
		thePlayer.GetVisualDebug().AddSphere( 'macka_player_pos', 3, PlayerPosition, true, Color( 0, 255, 0 ) );
		thePlayer.GetVisualDebug().AddLine( 'macka_bubble_line', PointA, PointB, true, Color( 255, 0, 0 ) );
		thePlayer.GetVisualDebug().AddLine( 'macka_player_line', PointA, PlayerPosition, true, Color( 0, 255, 0 ) );
		*/
		Line = PointB - PointA;
		CheckedVector = PlayerPosition - PointA;
		
		Result = VecCross( Line, CheckedVector );
		
		if( Result.Z > 0 )
			return true;
		else
			return false;
	}
	
	function ToIdle()
	{
		ReturnToIdle();
	}
	
	function StopAttack()
	{
		if( !isCut )
		{
			DoStopAttacks();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// Smallest Macka class
//////////////////////////////////////////////////////////////////////////////////////////

class ZagnicaMackaSmall extends ZagnicaMacka
{
	editable var CuttedMackaTemplate, bubble, ThrashEntityTemplate1, ThrashEntityTemplate2 : CEntityTemplate;
	
	var isGrabbing : bool;
	var cutDeactivateNotifier : name;
	
	function StartAttack()
	{
		Log( "Starting attack " );
		
		((ZagnicaMacka)this).DoVerticalAttack();
	}
	
	function BindVariables()
	{
		//setting default variables for each macka
		isCut = false;
		
		if( MacIndexNumber == 1 )
		{
			hitEventName = 'mac1_hit';
		
			bubbleBoneName = 'k_mac1_08';
			
			isImmobilized = false;
			
			immobilizedMouthEvent = 'vertical_loop_mouth_m1';
			
			attackZone = 'Tentacle1_range';
			
			exitEventV = 'mac1_Attack_End';
			
			MacStateWounded = 'wounded';
			
			cutDeactivateNotifier = 'cut_cutscene_deactivate_m1';
			
			ThrowAttackEvent = 'mac1_ThrowAttack' ;
			throwZone = 'Throw_m1_range';
			ArenaHolderZone = 'ArenaHolder_m1_range';
			ArenaHolderEvent = 'mac1_Attack2_horizontal';
			
			startRodeoEvent = 'rodeo_loop_start_m1';
			
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m1';
			
			FocusPointName = "mac1_cuted";//"trap_dummy_1";//"tentacle1_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle1_t1';
			
			MacStateDecapitated = 'decapitated';
			
			MacStateCuted = 'cuted';
			
			yrdenEffectName = 'mac1_yrden'; 
			
			yrdenEffectName2 = 'shader_fx_mac1'; 
			
			smokeEffectName = 'smoke_hit_mac1';
			
			bloodTrailsEffectName = 'blood_trials_mac1';
			
			bubbleExplodeEffectName = 'mac1_bubble_explosion';
			
			hitEffectName = 'hit_mac1';
		
			CutCutsceneEvent = 'mac1_cutscene';
			CutTrapCutsceneEvent = 'mac1_cutscene_trap';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m1';
			
			VerticalAttackLookatEvent = 'Mac1_StartLookat' ;
			
			VerticalLoopEvent =  'mac1_Attack_Loop';
			
			IdleActivateNotifier = 'Idle_activate_m1';
			
			IdleCutActivateNotifier = 'cut_Idle_activate_m1';
			
			IdleDeactivateNotifier = 'Idle_deactivate_m1';
			
			forceEndAnimation =  'force_idle1';
			
			Lookat =  'mac1_Lookat';
			
			Lookat_Weight = 'mac1_Lookat_Weight';
			
			attackEventV = 'mac1_Attack1_vertical';
			
			//Creating tentacle bubble
			mackaBubble = (TentadrakeBubble) theGame.CreateEntity( bubble, GetMackaBubblePosition(), GetMackaBubbleRotation(), true, false, true ); 
			if ( !mackaBubble )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "Bubble is NULL" );
				Log( "======================================================================" );
			}
			
			mackasBones.PushBack('k_mac1_AIM_Pre');
			mackasBones.PushBack('k_mac1_AIM');
			mackasBones.PushBack('k_mac1_00');
			mackasBones.PushBack('mac1_aim1');
			mackasBones.PushBack('k_mac1_01');
			mackasBones.PushBack('mac1_aim2');
			mackasBones.PushBack('k_mac1_02');
			mackasBones.PushBack('mac1_aim3');
			mackasBones.PushBack('k_mac1_03');
			mackasBones.PushBack('k_mac1_04');
			mackasBones.PushBack('k_mac1_05');
			mackasBones.PushBack('k_mac1_06');
			mackasBones.PushBack('k_mac1_07');
			mackasBones.PushBack('k_mac1_08');
			mackasBones.PushBack('k_mac1_09');
			mackasBones.PushBack('k_mac1_10');
			mackasBones.PushBack('k_mac1_11');
			mackasBones.PushBack('k_mac1_12');
		}	
		else if ( MacIndexNumber == 6 )
		{
			hitEventName = 'mac6_hit';
			
			bubbleBoneName = 'k_mac6_08';
			
			isImmobilized = false;
			immobilizedMouthEvent = 'vertical_loop_mouth_m6';
			
			attackZone = 'Tentacle6_range';
			
			exitEventV = 'mac6_Attack_End';
			
			MacStateWounded = 'wounded';
			
			cutDeactivateNotifier = 'cut_cutscene_deactivate_m6';
			
			ThrowAttackEvent = 'mac6_ThrowAttack' ;
			throwZone = 'Throw_m6_range';
			ArenaHolderZone = 'ArenaHolder_m6_range';
			ArenaHolderEvent = 'mac6_Attack2_horizontal';
			
			startRodeoEvent = 'rodeo_loop_start_m6';
			
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m6';
			
			FocusPointName = "mac6_cuted";//"trap_dummy_6";//"tentacle6_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle6_t1';
			
			MacStateDecapitated = 'decapitated';
			
			MacStateCuted = 'cuted';
			
			yrdenEffectName = 'mac6_yrden'; 
			
			yrdenEffectName2 = 'shader_fx_mac6'; 
			
			smokeEffectName = 'smoke_hit_mac6';
			
			bloodTrailsEffectName = 'blood_trials_mac6';
			
			bubbleExplodeEffectName = 'mac6_bubble_explosion';
			
			hitEffectName = 'hit_mac6';
		
			CutCutsceneEvent = 'mac6_cutscene';
			CutTrapCutsceneEvent = 'mac6_cutscene_trap';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m6';
			
			VerticalAttackLookatEvent = 'Mac6_StartLookat' ;
			
			VerticalLoopEvent =  'mac6_Attack_Loop';
			
			IdleActivateNotifier = 'Idle_activate_m6';
			
			IdleCutActivateNotifier = 'cut_Idle_activate_m6';
			
			IdleDeactivateNotifier = 'Idle_deactivate_m6';
			
			forceEndAnimation =  'force_idle6';
			
			Lookat =  'mac6_Lookat';
			
			Lookat_Weight = 'mac6_Lookat_Weight';
			
			attackEventV = 'mac6_Attack1_vertical';
			
			//Creating tentacle bubble
			mackaBubble = (TentadrakeBubble) theGame.CreateEntity( bubble, GetMackaBubblePosition(), GetMackaBubbleRotation(), true, false, true );
			if ( !mackaBubble )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "Bubble is NULL" );
				Log( "======================================================================" );
			}
			
			mackasBones.PushBack('k_mac6_AIM_Pre');
			mackasBones.PushBack('k_mac6_AIM');
			mackasBones.PushBack('k_mac6_00');
			mackasBones.PushBack('mac6_aim1');
			mackasBones.PushBack('k_mac6_01');
			mackasBones.PushBack('mac6_aim2');
			mackasBones.PushBack('k_mac6_02');
			mackasBones.PushBack('mac6_aim3');
			mackasBones.PushBack('k_mac6_03');
			mackasBones.PushBack('k_mac6_04');
			mackasBones.PushBack('k_mac6_05');
			mackasBones.PushBack('k_mac6_06');
			mackasBones.PushBack('k_mac6_07');
			mackasBones.PushBack('k_mac6_08');
			mackasBones.PushBack('k_mac6_09');
			mackasBones.PushBack('k_mac6_10');
			mackasBones.PushBack('k_mac6_11');
			mackasBones.PushBack('k_mac6_12');
		}
	}
	
	function BindVariablesCutted()
	{
		isCut = true;
		isImmobilized = false;
		
		if( MacIndexNumber == 1 ) 
		{
			forceEndAnimation = 'force_idle_cut_m1';
		}
		else if( MacIndexNumber == 6 ) 
		{
			forceEndAnimation = 'force_idle_cut_m6';
		}
	}
	
	function ArenaHolderCanOccur() : bool
	{
		if ( zgn.CheckInteractionPlayerOnly( ArenaHolderZone ) && !zgn.ExclusiveAttackInProgress && !isAttacking && !zgn.playerHasBeenHit )
		{
			return true;
		}
		else 
		{
			return false;
		}
	}
	
	private function MackaCanThrow() : bool
	{
		if ( zgn.playerHasBeenHit || isAttacking || isCut || zgn.ExclusiveAttackInProgress || zgn.HorizontalAttackInProgress || zgn.CheckInteractionPlayerOnly( attackZone ) )
		{
			return false;
		}
		
		if ( zgn.CheckInteractionPlayerOnly( zgn.Macka2.attackZone )|| zgn.CheckInteractionPlayerOnly( zgn.Macka3.attackZone ) || zgn.CheckInteractionPlayerOnly( zgn.Macka4.attackZone ) || zgn.CheckInteractionPlayerOnly( zgn.Macka5.attackZone ) )
		{
			if( RandF() < 0.01 && zgn.MissedAttacksCount >= 4 && zgn.CheckInteractionPlayerOnly( throwZone ) )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		else if ( zgn.CheckInteractionPlayerOnly( throwZone ) ) 
		{
			return true;
		}
	}
	
	private function ThrowAttack()
	{
		DoThrowAttack();
	}
	
	function ArenaHolderAttack()
	{
		if( !isCut )
		{
			DoArenaHolderAttack();
		}
	}
	
	function HasMackaBubble() : bool
	{
		return true;
	}
	
	function GetMackaBubblePosition() : Vector
	{
		var mat : Matrix;
		mat = zgn.GetBoneWorldMatrix( bubbleBoneName );
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaStartPosition() : Vector
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 1 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac1_AIM' );
		}
		else if( MacIndexNumber == 6 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac6_AIM' );
		}
		
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaEndPosition() : Vector
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 1 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac1_12' );
		}
		else if( MacIndexNumber == 6 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac6_12' );
		}
		
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaBubbleRotation() : EulerAngles
	{
		var mat : Matrix;
		mat = zgn.GetBoneWorldMatrix( bubbleBoneName );
		return MatrixGetRotation( mat );
	}
	
	function GetMackaStartRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 1 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac1_AIM' );
		}
		else if( MacIndexNumber == 6 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac6_AIM' );
		}
		
		return MatrixGetRotation( mat );
	}
	
	function GetMackaEndRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 1 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac1_12' );
		}
		else if( MacIndexNumber == 6 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac6_12' );
		}
		
		return MatrixGetRotation( mat );
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// Medium Macka class
//////////////////////////////////////////////////////////////////////////////////////////

class ZagnicaMackaMid extends ZagnicaMacka
{
	editable var CuttedMackaTemplate, bubble : CEntityTemplate;
	
	var cutDeactivateNotifier : name;
	
	function BindVariables()
	{
		//setting default variables for each macka
		isCut = false;
		isImmobilized = false;
		
		if( MacIndexNumber == 2 )
		{
			hitEventName = 'mac2_hit';
			
			immobilizedMouthEvent = 'vertical_loop_mouth_m2';
			
			bubbleBoneName = 'k_mac2_06';
			startRodeoEvent = 'rodeo_loop_start_m2';
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m2' ;
			
			attackZone = 'Tentacle2_range';
			exitEventV = 'mac2_Attack_End';
			FocusPointName = "mac2_cuted";//"trap_dummy_2";//"tentacle2_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle2_t1';
			cutDeactivateNotifier = 'cut_cutscene_deactivate_m2';
			
			MacStateWounded = 'wounded';
			MacStateDecapitated = 'decapitated';
			yrdenEffectName = 'mac2_yrden'; 
			
			yrdenEffectName2 = 'shader_fx_mac2'; 
			smokeEffectName = 'smoke_hit_mac2';
			bubbleExplodeEffectName = 'mac2_bubble_explosion';
			
			hitEffectName = 'hit_mac2';
			
			bloodTrailsEffectName = 'blood_trials_mac2';
			MacStateCuted = 'cuted';
			
			CutCutsceneEvent = 'mac2_cutscene';
			CutTrapCutsceneEvent = 'mac2_cutscene_trap';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m2';
			VerticalAttackLookatEvent = 'Mac2_StartLookat';
			
			VerticalLoopEvent = 'mac2_Attack_Loop';
			IdleActivateNotifier = 'Idle_activate_m2';
			IdleCutActivateNotifier = 'cut_Idle_activate_m2';
			
			IdleDeactivateNotifier = 'Idle_deactivate_m2';
			forceEndAnimation = 'force_idle2';
			Lookat = 'mac2_Lookat';
			
			Lookat_Weight = 'mac2_Lookat_Weight';
			attackEventV = 'mac2_Attack1_vertical';
			
			//Creating tentacle bubble
			mackaBubble = (TentadrakeBubble) theGame.CreateEntity( bubble, GetMackaBubblePosition(), GetMackaBubbleRotation(), true, false, true ); 
			if ( !mackaBubble )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "Bubble is NULL" );
				Log( "======================================================================" );
			}
		}
		if( MacIndexNumber == 5 )
		{
			hitEventName = 'mac5_hit';
		
			immobilizedMouthEvent = 'vertical_loop_mouth_m5';
			
			bubbleBoneName = 'k_mac5_06';
			startRodeoEvent = 'rodeo_loop_start_m5';
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m5' ;
			
			attackZone = 'Tentacle5_range';
			exitEventV = 'mac5_Attack_End';
			FocusPointName = "mac5_cuted";//"trap_dummy_5";//"tentacle5_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle5_t1';
			cutDeactivateNotifier = 'cut_cutscene_deactivate_m5';
			
			MacStateWounded = 'wounded';
			MacStateDecapitated = 'decapitated';
			yrdenEffectName = 'mac5_yrden'; 
			
			yrdenEffectName2 = 'shader_fx_mac5'; 
			smokeEffectName = 'smoke_hit_mac5';
			bubbleExplodeEffectName = 'mac5_bubble_explosion';
			
			hitEffectName = 'hit_mac5';
			
			bloodTrailsEffectName = 'blood_trials_mac5';
			MacStateCuted = 'cuted';
			
			CutCutsceneEvent = 'mac5_cutscene';
			CutTrapCutsceneEvent = 'mac5_cutscene_trap';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m5';
			VerticalAttackLookatEvent = 'Mac5_StartLookat';
			
			VerticalLoopEvent = 'mac5_Attack_Loop';
			IdleActivateNotifier = 'Idle_activate_m5';
			IdleCutActivateNotifier = 'cut_Idle_activate_m5';
			
			IdleDeactivateNotifier = 'Idle_deactivate_m5';
			forceEndAnimation = 'force_idle5';
			Lookat = 'mac5_Lookat';
			
			Lookat_Weight = 'mac5_Lookat_Weight';
			attackEventV = 'mac5_Attack1_vertical';
			
			//Creating tentacle bubble
			mackaBubble = (TentadrakeBubble) theGame.CreateEntity( bubble, GetMackaBubblePosition(), GetMackaBubbleRotation(), true, false, true ); 
			if ( !mackaBubble )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "Bubble is NULL" );
				Log( "======================================================================" );
			}
		}
	}
	
	function BindVariablesCutted()
	{
		isCut = true;
		isImmobilized = false;
		
		if( MacIndexNumber == 2 )
		{
			forceEndAnimation = 'force_idle_cut_m2';
		}	
		if( MacIndexNumber == 5 )
		{
			forceEndAnimation = 'force_idle_cut_m5';
		}
	}
	
	function StartAttack()
	{
		Log( "Starting attack " );
		
		((ZagnicaMacka)this).DoVerticalAttack();
	}
	
	function HasMackaBubble() : bool
	{
		return true;
	}
	
	function GetMackaBubblePosition() : Vector
	{
		var mat : Matrix;
		mat = zgn.GetBoneWorldMatrix( bubbleBoneName );
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaStartPosition() : Vector
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 2 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac2_AIM' );
		}
		else if( MacIndexNumber == 5 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac5_AIM' );
		}
		
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaEndPosition() : Vector
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 2 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac2_12' );
		}
		else if( MacIndexNumber == 5 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac5_12' );
		}

		return MatrixGetTranslation( mat );
	}
	
	function GetMackaBubbleRotation() : EulerAngles
	{
		var mat : Matrix;
		mat = zgn.GetBoneWorldMatrix( bubbleBoneName );
		return MatrixGetRotation( mat );
	}
	
	function GetMackaStartRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 2 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac2_AIM' );
		}
		else if( MacIndexNumber == 5 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac5_AIM' );
		}
		
		return MatrixGetRotation( mat );
	}
	
	function GetMackaEndRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 2 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac2_12' );
		}
		else if( MacIndexNumber == 5 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac5_12' );
		}
		
		return MatrixGetRotation( mat );
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// Biggest Macka class
//////////////////////////////////////////////////////////////////////////////////////////

class ZagnicaMackaBig extends ZagnicaMacka
{
	editable var ThrashEntityTemplate1, ThrashEntityTemplate2 : CEntityTemplate;
	
	var RodeoIsFailed, isGrabbing : bool;

	function StartAttack()
	{
		//randomisation of mackas attacks
		if ( zgn.MissedAttacksCount >= 2 && !zgn.AnyMackaAttacking() && !zgn.AnyMackaImmobilized() && zgn.CutMackasCount >= 1 )
		{
			DoHorizontalAttack();
		}
		else
		{
			((ZagnicaMacka)this).DoVerticalAttack();
		}
	}
	
	function BindVariables()
	{
		//setting default variables for each macka
		isCut = false;
		
		isImmobilized = false;
			
		if( MacIndexNumber == 3 )
		{	
			bridgeAttackEvent1 = 'mac3_attack1_bridge';
			bridgeAttackEvent2 = 'mac3_attack2_bridge';
			bridgeAttackEvent3 = 'mac3_attack3_bridge';
			bridgeAttackEvent4 = 'mac3_attack4_bridge';
			
			ArenaHolderEvent = 'arenaholder_m3';
			ArenaHolderZone = 'ArenaHolder_m3_range';
			
			attackZone = 'Tentacle3_range';
			attackEventH = 'mac3_Attack2_horizontal';
			FocusPointName = "tentacle3_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle3_t1';
			startRodeoEvent = 'rodeo_loop_start_m3';
			
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m3';
			smokeEffectName = 'smoke_hit_mac3';
			MacStateDecapitated = 'decapitated';
			
			MacStateCuted = 'cuted';
			CutCutsceneEvent = 'mac3_cutscene';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m3';
			VerticalAttackLookatEvent = 'Mac3_StartLookat';
			VerticalLoopEvent = 'mac3_Attack_Loop';
			
			IdleActivateNotifier = 'Idle_activate_m3';
			IdleCutActivateNotifier = 'cut_Idle_activate_m3';
			IdleDeactivateNotifier = 'Idle_deactivate_m3';
			
			forceEndAnimation = 'force_idle3';
			Lookat = 'mac3_Lookat';
			Lookat_Weight = 'mac3_Lookat_Weight';
		
			attackEventV = 'mac3_Attack1_vertical';
			
			mackasBones.PushBack('k_mac3_AIM_Pre');
			mackasBones.PushBack('k_mac3_AIM');
			mackasBones.PushBack('k_mac3_00');
			mackasBones.PushBack('mac3_aim1');
			mackasBones.PushBack('k_mac3_01');
			mackasBones.PushBack('mac3_aim2');
			mackasBones.PushBack('k_mac3_02');
			mackasBones.PushBack('mac3_aim3');
			mackasBones.PushBack('k_mac3_03');
			mackasBones.PushBack('k_mac3_04');
			mackasBones.PushBack('k_mac3_05');
			mackasBones.PushBack('k_mac3_06');
			mackasBones.PushBack('k_mac3_07');
			mackasBones.PushBack('k_mac3_08');
			mackasBones.PushBack('k_mac3_09');
			mackasBones.PushBack('k_mac3_10');
			mackasBones.PushBack('k_mac3_11');
			mackasBones.PushBack('k_mac3_12');
			mackasBones.PushBack('k_mac3_13');
			mackasBones.PushBack('k_mac3_14');
			mackasBones.PushBack('k_mac3_15');
			mackasBones.PushBack('Bone23');
			mackasBones.PushBack('Bone24');
			mackasBones.PushBack('Bone25');
			mackasBones.PushBack('Bone26');
			mackasBones.PushBack('Bone27');
			mackasBones.PushBack('Bone28');
		}
		else if ( MacIndexNumber == 4 )
		{
			bridgeAttackEvent1 = 'mac4_attack1_bridge';
			bridgeAttackEvent2 = 'mac4_attack2_bridge';
			bridgeAttackEvent3 = 'mac4_attack3_bridge';
			bridgeAttackEvent4 = 'mac4_attack4_bridge';
			
			ArenaHolderEvent = 'arenaholder_m4';
			ArenaHolderZone = 'ArenaHolder_m4_range';
			
			attackZone = 'Tentacle4_range';
			attackEventH = 'mac4_Attack2_horizontal';
			FocusPointName = "tentacle4_focus";
			
			MacBodyPartName = 'Mesh zagnica__tentacle4_t1';
			startRodeoEvent = 'rodeo_loop_start_m4';
			
			startRodeoBridgeEvent = 'rodeo_hit_bridge_m4';
			smokeEffectName = 'smoke_hit_mac4';
			MacStateDecapitated = 'decapitated';
			
			MacStateCuted = 'cuted';
			CutCutsceneEvent = 'mac4_cutscene';
			
			VerticalAttackNotifier = 'VerticalLoopActive_m4';
			VerticalAttackLookatEvent = 'Mac4_StartLookat';
			VerticalLoopEvent = 'mac4_Attack_Loop';
			
			IdleActivateNotifier = 'Idle_activate_m4';
			IdleCutActivateNotifier = 'cut_Idle_activate_m4';
			IdleDeactivateNotifier = 'Idle_deactivate_m4';
			
			forceEndAnimation = 'force_idle4';
			Lookat = 'mac4_Lookat';
			Lookat_Weight = 'mac4_Lookat_Weight';
		
			attackEventV = 'mac4_Attack1_vertical';
		
			mackasBones.PushBack('k_mac4_AIM_Pre');
			mackasBones.PushBack('k_mac4_AIM');
			mackasBones.PushBack('k_mac4_00');
			mackasBones.PushBack('mac4_aim1');
			mackasBones.PushBack('k_mac4_01');
			mackasBones.PushBack('mac4_aim2');
			mackasBones.PushBack('k_mac4_02');
			mackasBones.PushBack('mac4_aim3');
			mackasBones.PushBack('k_mac4_03');
			mackasBones.PushBack('k_mac4_04');
			mackasBones.PushBack('k_mac4_05');
			mackasBones.PushBack('k_mac4_06');
			mackasBones.PushBack('k_mac4_07');
			mackasBones.PushBack('k_mac4_08');
			mackasBones.PushBack('k_mac4_09');
			mackasBones.PushBack('k_mac4_10');
			mackasBones.PushBack('k_mac4_11');
			mackasBones.PushBack('k_mac4_12');
			mackasBones.PushBack('k_mac4_13');
			mackasBones.PushBack('k_mac4_14');
			mackasBones.PushBack('k_mac4_15');
			mackasBones.PushBack('Bone29');
			mackasBones.PushBack('Bone30');
			mackasBones.PushBack('Bone31');
			mackasBones.PushBack('Bone32');
			mackasBones.PushBack('Bone33');
			mackasBones.PushBack('Bone34');
		}
	}
	
	function ArenaHolderCanOccur() : bool
	{
		if( MacIndexNumber == 3 )
		{
			if ( zgn.CheckInteractionPlayerOnly( ArenaHolderZone ) && !zgn.ExclusiveAttackInProgress && !isAttacking && !zgn.playerHasBeenHit && zgn.Macka1.isCut && zgn.Macka2.isCut )
			{
				return true;
			}
			else 
			{
				return false;
			}
		}
		if( MacIndexNumber == 4 )
		{
			if ( zgn.CheckInteractionPlayerOnly( ArenaHolderZone ) && !zgn.ExclusiveAttackInProgress && !isAttacking && !zgn.playerHasBeenHit && zgn.Macka5.isCut && zgn.Macka6.isCut )
			{
				return true;
			}
			else 
			{
				return false;
			}
		}
	}	
	
	function HasMackaBubble() : bool
	{
		return false;
	}
	
	function GetMackaBubblePosition() : Vector
	{
		return Vector(0,0,0);
	}
	
	function GetMackaStartPosition() : Vector
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 3 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac3_AIM' );
		}
		else if( MacIndexNumber == 4 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac4_AIM' );
		}
		
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaEndPosition() : Vector
	{
		var mat : Matrix;
		
		if ( MacIndexNumber == 3 )
		{
			mat = zgn.GetBoneWorldMatrix( 'Bone28' );
		}
		else if ( MacIndexNumber == 4 )
		{
			mat = zgn.GetBoneWorldMatrix( 'Bone34' );
		}
				
		return MatrixGetTranslation( mat );
	}
	
	function GetMackaBubbleRotation() : EulerAngles
	{
		return EulerAngles(0,0,0);
	}
	
	function GetMackaStartRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if( MacIndexNumber == 3 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac3_AIM' );
		}
		else if( MacIndexNumber == 4 )
		{
			mat = zgn.GetBoneWorldMatrix( 'k_mac4_AIM' );
		}
		
		return MatrixGetRotation( mat );
	}
	
	function GetMackaEndRotation() : EulerAngles
	{
		var mat : Matrix;
		
		if ( MacIndexNumber == 3 )
		{
			mat = zgn.GetBoneWorldMatrix( 'Bone28' );
		}
		else if ( MacIndexNumber == 4 )
		{
			mat = zgn.GetBoneWorldMatrix( 'Bone34' );
		}
				
		return MatrixGetRotation( mat );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
// Macka's Bubble class
/////////////////////////////////////////////////////////////////////////////////////////

class TentadrakeBubble extends CActor
{
	editable var parentMacIndex : int;
	
	var index : int;
	var tentadrake : Zagnica;
	var macHealthPercent : float;
	//var tentacleIsWounded : bool;
	var isCutByTrap, constraintActive : bool;
	
	function IsBoss() : bool
	{
		return true;
	}
	
	function IsMonster() : bool
	{
		return true;
	}
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	
		EnablePathEngineAgent( false );
		EnablePhysicalMovement( false );
	
		tentadrake = theGame.zagnica;
		
		if( !tentadrake )
		{
			Log( " NIE MA ¯AGNICY             !!!!!!!!!!!!!!!!!!!!!  " );
		}
		 
		isCutByTrap = false;
		index = parentMacIndex - 1;
		tentadrake.bossMaxHealth += health;
		
		constraintActive = ActivateBoneAnimatedConstraint( tentadrake, tentadrake.Mackas[parentMacIndex-1].bubbleBoneName, 'shiftWeight', 'shift' );
		if( !constraintActive )
		{
			Logf("ActivateBoneAnimatedConstraint failed for macka %1", parentMacIndex);
		}
		
		this.SetAttackableByPlayerPersistent( false );
	}
	
	private function HitDamage( hitParams : HitParams )
	{
		hitParams.outDamageMultiplier = 1.0f;
		super.HitDamage( hitParams );
	}
	
	event OnHit( hitParams : HitParams )
	{
		var myargs : array <string>;
		
		if ( tentadrake.GetMacka(parentMacIndex).isImmobilized && IsAlive() )
		{
			health -= hitParams.damage;
			
			tentadrake.PlayEffect( tentadrake.Mackas[index].hitEffectName );
			//thePlayer.GetInventory().PlayItemEffect( thePlayer.GetCurrentWeapon(), 'zagnica_blood_hit' );
			
			macHealthPercent = health / initialHealth;
			
			tentadrake.UpdateBossHealth();
			
			tentadrake.RaiseEvent( tentadrake.Mackas[index].hitEventName );
		}
	}
	
	function DecreaseHealth( amount : float, lethal : bool, attacker : CActor, optional deathData : SActorDeathData )
	{
		SetHealth( health, lethal, attacker, deathData );
	}
	
	timer function ChangeMacState( timeDelta : float )
	{
		tentadrake.SetBodyPartState( tentadrake.Mackas[index].MacBodyPartName, tentadrake.Mackas[index].MacStateWounded, true );
	}
	
	function IsBubbleParentImmobilized() : bool
	{
		return tentadrake.Mackas[index].isImmobilized;
	}
	
	private function EnterDead( optional deathData : SActorDeathData )
	{		
		//macka has been hit
		health = 0;
		
		SetAlive( false );
		tentadrake.UpdateBossHealth();

		tentadrake.PlayEffect( tentadrake.Mackas[index].bubbleExplodeEffectName );
		tentadrake.SetBodyPartState( tentadrake.Mackas[index].MacBodyPartName, tentadrake.Mackas[index].MacStateWounded, true );
		
		tentadrake.Mackas[index].DeadImmobilized();
		
		AddTimer( 'DelayedPlayCutscene', 1.0f, false );
	}
	
	timer function DelayedPlayCutscene( time : float )
	{
		var IsPlayerPositionLeft : bool;
		var csRot	: EulerAngles;
		var csPos	: Vector;
		var tnorm	: EulerAngles;
		
		var actors		: array<CEntity>;
		var actorNames	: array<string>;
		var csName		: string;
		
		var i, size		: int;
		
		IsPlayerPositionLeft = tentadrake.Mackas[index].IsPlayerCutPositionLeft();

		tentadrake.StopEffect( tentadrake.Mackas[index].yrdenEffectName );
		tentadrake.StopEffect( tentadrake.Mackas[index].yrdenEffectName2 );
		
		if( tentadrake.CutMackasCount <= 2 )
		{
			tentadrake.attackDelay -= 1.f;
		}
		
		if( !isCutByTrap )
		{
			if ( IsPlayerPositionLeft )
			{
				csPos = tentadrake.GetComponent( "mac" + parentMacIndex + "_cutscene_point" ).GetWorldPosition();
				csRot = tentadrake.GetComponent( "mac" + parentMacIndex + "_cutscene_point" ).GetWorldRotation();

				csName = "witcher_cut_tentacle_left";
			}
			else
			{
				csPos = tentadrake.GetComponent( "mac" + parentMacIndex + "_cutscene_point_r" ).GetWorldPosition();
				csRot = tentadrake.GetComponent( "mac" + parentMacIndex + "_cutscene_point_r" ).GetWorldRotation();

				csName = "witcher_cut_tentacle_right";
			}
			
			theGame.GetWorld().PointProjectionTest( csPos, tnorm, 2.0f );
			
			actors.PushBack( thePlayer );
			actorNames.PushBack( "witcher" );
			
			thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 8.0);
			if( !theGame.PlayCutsceneAsync( csName, actorNames, actors, csPos, csRot ) )
			{
				Log( "-----------------------------------------------------------------" );
				Log( "Error while trying to play cutscene:" );
				Log( "Cutscene name: " + csName );
				Log( "Actors:" );
				size = actors.Size();
				for( i = 0; i < size; i += 1 )
				{
					Log( "****************************" );
					Log( "actor - " + actors[i] );
					Log( "name - " + actorNames[i] );
				}
				Log( "****************************" );
				Log( "Cutscene position: " + VecToString(csPos) );
				Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
				Log( "-----------------------------------------------------------------" );
			}
			
			tentadrake.CutMacCutsceneZgn( parentMacIndex );
		}
		else
		{
			tentadrake.TrapCutMacCutsceneZgn( parentMacIndex );
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
// Macka's States
/////////////////////////////////////////////////////////////////////////////////////////

state Idle in ZagnicaMacka
{
	entry function ReturnToIdle()
	{
		parent.isAttacking = false;
	}
}

state VerticalAttack in ZagnicaMacka
{
	entry function DoVerticalAttack()
	{
		var eventProcessed : bool;
		
		if( parent.MacIndexNumber == 1 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac1_Attack1_vertical_mouth';
		}
		else if( parent.MacIndexNumber == 2 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac2_Attack1_vertical_mouth';
		}
		else if( parent.MacIndexNumber == 3 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac3_Attack1_vertical_mouth';
		}
		else if( parent.MacIndexNumber == 4 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac4_Attack1_vertical_mouth';
		}
		else if( parent.MacIndexNumber == 5 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac5_Attack1_vertical_mouth';
		}
		else if( parent.MacIndexNumber == 6 )
		{
			parent.zgn.VerticalAttackMouthEvent = 'mac6_Attack1_vertical_mouth';
		}
		
		eventProcessed = parent.zgn.RaiseEvent( parent.attackEventV );
		
		if ( eventProcessed )
		{
			// Set attack flag
			parent.isAttacking = true;
			
			parent.MackaConstraintTarget = thePlayer.GetWorldPosition();
			
			parent.zgn.GetVisualDebug().AddSphere( 'TentacleConstraintTarget', 2, parent.MackaConstraintTarget, true );
			
	//		parent.zgn.EnableCollisionInfoReportingForComponent( parent.tentacleComponent, true );
			
			if( !parent.zgn.Paszcza.isAttacking && !parent.zgn.AnyMackaImmobilized() )
			{
				parent.zgn.Paszcza.DoVerticalAttackMouth();
			}
			
			parent.zgn.WaitForEventProcessing ( parent.attackEventV );
			
			parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier );
			
			// Deactivate animation look at constraint
			parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		}
	
		parent.ReturnToIdle();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state Immobilized in ZagnicaMacka
{
	var vector : Vector;
	var focusActive : bool;
	
	var trap : CTrapDummy;
	var component : CInteractionComponent;
	
	event OnEnterState()
	{
		parent.zgn.playerHasUsedYrden = true;
		
		parent.zgn.PlayEffect( parent.yrdenEffectName );
		parent.zgn.PlayEffect( parent.yrdenEffectName2 );
		
		parent.mackaBubble.SetAttackableByPlayerPersistent( true );
		
		switch( parent.MacIndexNumber )
		{
			case 1:
			{
				trap = (CTrapDummy)theGame.GetNodeByTag( 'dummy_trap_1' );
				component = (CInteractionComponent)trap.GetComponentByClassName( 'CInteractionComponent' );
				component.SetEnabled( false );
				break;
			}
			case 2:
			{
				trap = (CTrapDummy)theGame.GetNodeByTag( 'dummy_trap_2' );
				component = (CInteractionComponent)trap.GetComponentByClassName( 'CInteractionComponent' );
				component.SetEnabled( false );
				break;
			}
			case 5:
			{
				trap = (CTrapDummy)theGame.GetNodeByTag( 'dummy_trap_5' );
				component = (CInteractionComponent)trap.GetComponentByClassName( 'CInteractionComponent' );
				component.SetEnabled( false );
				break;
			}
			case 6:
			{
				trap = (CTrapDummy)theGame.GetNodeByTag( 'dummy_trap_6' );
				component = (CInteractionComponent)trap.GetComponentByClassName( 'CInteractionComponent' );
				component.SetEnabled( false );
				break;
			}
		}
	/*	theCamera.FocusOn( parent.zgn.GetComponent( "mouth_focus" ), false );
		//theCamera.FocusOn( parent.zgn.GetComponent( parent.FocusPointName ), true );
		//theCamera.FocusOn( parent.mackaBubble, true );
		vector = parent.mackaBubble.GetWorldPosition();
		
		if( parent.MacIndexNumber == 1 || parent.MacIndexNumber == 2 )
		{
			vector.X += 1.f;
			//theCamera.SetBehaviorVariable( "cameraFurther", (theCamera.GetBehaviorVariable("cameraFurther") + 0.5) );			
		}
		else
		{
			vector.X += 0.5f;
		}

		vector.Z = 2.f;
		
		theCamera.FocusOnStatic( vector, true );
		
		focusActive = true;
	*/
	/*
		if( parent.MacIndexNumber == 1 )
		{
			parent.zgn.AddTimer( 'Mac1CameraControl', 0.01f, true );
		}
		else if( parent.MacIndexNumber == 2 )
		{
			parent.zgn.AddTimer( 'Mac2CameraControl', 0.01f, true );
		}
		else if( parent.MacIndexNumber == 5 )
		{
			parent.zgn.AddTimer( 'Mac5CameraControl', 0.01f, true );
		}
		else if( parent.MacIndexNumber == 6 )
		{
			parent.zgn.AddTimer( 'Mac6CameraControl', 0.01f, true );
		}
	*/
	}
	
	event OnLeaveState()
	{
		parent.zgn.StopEffect( parent.yrdenEffectName );
		parent.zgn.StopEffect( parent.yrdenEffectName2 );
		
		parent.mackaBubble.SetAttackableByPlayerPersistent( false );
		
		component.SetEnabled( true );		
		//parent.zgn.RemoveTimer( 'MacCameraControl' );
		//theHud.m_hud.HideBossHealth();
	}
	
	entry function DoMackaImmobilized()
	{	
		parent.isImmobilized = true;
		parent.zgn.MissedAttacksCount = 0;
		
		parent.zgn.RaiseForceEvent( parent.VerticalLoopEvent );
		parent.zgn.RaiseForceEvent( parent.immobilizedMouthEvent );
		
		parent.zgn.RaiseForceEvent( parent.zgn.Paszcza.ForceIdleEvent );
		parent.zgn.Paszcza.ReturnToIdle();
		
		Sleep ( parent.zgn.yrdenHoldTime );
		
		/*
		if( parent.MacIndexNumber == 1 )
		{
			parent.zgn.RemoveTimer( 'Mac1CameraControl' );
		}
		else if( parent.MacIndexNumber == 2 )
		{
			parent.zgn.RemoveTimer( 'Mac2CameraControl' );
		}
		else if( parent.MacIndexNumber == 5 )
		{
			parent.zgn.RemoveTimer( 'Mac5CameraControl' );
		}
		else if( parent.MacIndexNumber == 6 )
		{
			parent.zgn.RemoveTimer( 'Mac6CameraControl' );
		}
		*/
	
		//theCamera.FocusOn( parent.zgn.GetComponent( "mouth_focus" ) );
		
		focusActive = false;
		parent.isImmobilized = false;
		
		parent.zgn.RaiseForceEvent( parent.exitEventV );
		
		parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier );
		parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		parent.ReturnToIdle();
	}
	
	entry function DeadImmobilized()
	{
		//do nothing, we just dont want the delay to stop being immobilized
	}
}

/////////////////////////////////////////////////////////////////////////////////////////

state StoppingAttacks in ZagnicaMacka
{
	entry function DoStopAttacks()
	{
		var stoppedAttacking : bool;
		
		parent.zgn.DeactivateAnimatedConstraint ( parent.Lookat_Weight );
		
		if ( parent.isAttacking )
		{
			parent.zgn.DeactivateAnimatedConstraint ( parent.Lookat_Weight );

			parent.zgn.RaiseForceEvent( parent.forceEndAnimation );
			
			if( parent.isImmobilized )
			{
				//theCamera.FocusOn( parent.zgn.GetComponent( "mouth_focus" ) );
				
				parent.zgn.StopEffect( parent.yrdenEffectName );
				parent.zgn.StopEffect( parent.yrdenEffectName2 );
			}
			
			if( parent.isThrowing )
			{
				theGame.GetEntityByTag( 'tentadrake_thrash' ).Destroy();
			}
	
			stoppedAttacking = parent.zgn.WaitForBehaviorNodeActivation( parent.IdleActivateNotifier, 10 );
				
			if ( stoppedAttacking )
			{
				parent.isImmobilized = false;
				parent.zgn.HorizontalAttackInProgress = false;
				parent.ReturnToIdle();
			}
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state EndRodeo in ZagnicaMacka
{
	entry function EndRodeo()
	{
		if( parent.isCut )
		{
			parent.zgn.RaiseEvent( parent.forceEndAnimation );
		}
		
		parent.ReturnToIdle();
	}
}

/////////////////////////////////////////////////////////////////////////////////////////

state HorizontalAttack in ZagnicaMackaBig
{
	var Bone1Mat, Bone2Mat : Matrix;
	var Bone1Point, Bone2Point : Vector;
	var K, X, A, B, C, D : Vector;
	var dist, dist1, dist2, macLength1, macLength2 : float;
	var gate1 : bool;
		
	entry function DoHorizontalAttack()
	{
		var eventProcessed : bool;
		var i, arraySize : 	int;
		
		parent.isAttacking = true;
		parent.zgn.HorizontalAttackInProgress = true;
		
		if( parent.MacIndexNumber == 3 )
		{
			parent.zgn.HorizontalAttackMouthEvent = 'mac3_Attack2_horizontal_mouth';
		}
		else if( parent.MacIndexNumber == 4 )
		{
			parent.zgn.HorizontalAttackMouthEvent = 'mac4_Attack2_horizontal_mouth';
		}
		
		//Raising attack event
		eventProcessed = parent.zgn.RaiseEvent( parent.attackEventH );
		gate1 = true;
		
		if ( eventProcessed )
		{		
			//preventing other mackas from attacking
			parent.horizontalStarted = false;
			
			if( !parent.zgn.Paszcza.isAttacking )
			{
				parent.zgn.Paszcza.DoHorizontalAttackMouth();
			}
			while ( !parent.horizontalStarted )
			{
				Sleep ( 0.1f );
			}
			
			while ( parent.zgn.HorizontalAttackInProgress )
			{
				parent.zgn.PlayerPosition = thePlayer.GetWorldPosition();
			
				arraySize = parent.mackasBones.Size();
		
				for( i = 0; i < arraySize; i += 1 )
				{
					A = parent.zgn.PlayerPosition;
					B = MatrixGetTranslation( parent.zgn.GetBoneWorldMatrix( parent.mackasBones[i]) );
					
					dist = VecDistance2D( A, B );
					
					if ( dist < 3.5f )
					{
						thePlayer.BreakQTE();
						thePlayer.ZgnHit( parent.zgn, 'horizontal', B );
						
						parent.zgn.playerHasBeenHit = true;
						parent.zgn.AddTimer( 'HitDelay', parent.zgn.attackDelay);
//						parent.zgn.PlaySound( 'stop_code_tentadrake_slide' );
						
						parent.zgn.RaiseEvent( parent.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Macka1.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Macka2.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Macka4.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Macka5.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Macka6.forceEndAnimation );
						parent.zgn.RaiseEvent( parent.zgn.Paszcza.ForceIdleEvent );
						
						parent.zgn.HorizontalAttackInProgress = false;
						parent.zgn.MissedAttacksCount = 0;
						break;
					}
				
				}
				
				Sleep ( 0.0000000000001f );
			}
			
		//	parent.zgn.SetAnimationTimeMultiplier( 1.0f );
		//	thePlayer.SetAnimationTimeMultiplier( 1.0f );
			
			parent.zgn.WaitForBehaviorNodeActivation( parent.IdleActivateNotifier, 30 );
			parent.zgn.HorizontalAttackInProgress = false;
			((ZagnicaMacka)parent).ReturnToIdle();
		}
		
		else
		{
			parent.zgn.HorizontalAttackInProgress = false;
			parent.zgn.MissedAttacksCount = 0;
			((ZagnicaMacka)parent).ReturnToIdle();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state TryingEscapeM3 in ZagnicaMackaBig
{
	entry function DoTryingEscapeM3()
	{
		var Bone1Mat, Bone2Mat 							:	 Matrix;
		var Bone1Point, Bone2Point					 	:	 Vector;
		var K, X, A, B, C, D 							: 	 Vector;
		var dist, dist1, dist2, macLength1, macLength2  :	 float;
		var gate1 										:	 bool;
		var i, arraySize								: 	 int;
		var qteStartInfo								:	 SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();
		var breakRodeo									:	 bool;
	
		parent.zgn.ExclusiveAttackInProgress = true;
		parent.zgn.rodeoCheckInProgress = false;
		parent.isAttacking = true;
		gate1 = true;
		
		parent.zgn.enterCsMode();
		
		// starting "Trying escape" animation on Zagnica
		parent.zgn.RaiseForceEvent( 'trying_escape' );
		
		parent.zgn.Paszcza.TryingEscape();
		
		parent.zgn.RemoveTimer( 'YrdenComment1' );
		parent.zgn.RemoveTimer( 'YrdenComment2' );
		
		if( RandF() > 0.5f )
		{
			((CActor)parent.zgn.Sheala).PlayScene( "Mock1" ); 
		}
		else
		{
			((CActor)parent.zgn.Sheala).PlayScene( "SpeedUp1" );
		}
		
		while ( !parent.zgn.rodeoCheckInProgress )
		{
			Sleep ( 0.001f );
		}
		
		while ( parent.zgn.rodeoCheckInProgress )
		{
			parent.zgn.PlayerPosition = thePlayer.GetWorldPosition();
		
			arraySize = parent.mackasBones.Size();
			
			if( parent.zgn.rodeoCanBeStarted && thePlayer.GetLastQTEResult() == QTER_Succeeded )
			{
				theGame.SetTimeScale( 1.f );
				parent.zgn.rodeoCheckInProgress = false;
				parent.zgn.rodeoCanBeStarted = false;
				parent.startRodeoM3();
			}
			
			//initialy set to break rodeo. If any bone is closer then 15 units it'll be set to false.
			breakRodeo = true;
		
			for( i = 0; i < arraySize; i += 1 )
			{
				A = parent.zgn.PlayerPosition;
				B = MatrixGetTranslation( parent.zgn.GetBoneWorldMatrix( parent.mackasBones[i]) );
			
				dist = VecDistance2D( A, B );
				
				if( parent.zgn.rodeoCanBeStarted )
				{
					if( dist < 15.f )
						breakRodeo = false;
				}
				else
					breakRodeo = false;
				
				if ( dist < 15.f && gate1 )
				{
					gate1 = false;
					qteStartInfo.action = 'AttackStrong';
					qteStartInfo.timeOut = 4;
					qteStartInfo.ignoreWrongInput = true;
					thePlayer.StartSinglePressQTEAsync( qteStartInfo );
					
					theGame.SetTimeScale( 0.3f );
					//parent.zgn.SetAnimationTimeMultiplier( 0.3f );
					//thePlayer.SetAnimationTimeMultiplier( 0.3f );
					
					parent.zgn.rodeoCanBeStarted = true;
				}
			
				if ( dist < 4.f )
				{
					thePlayer.BreakQTE();
					thePlayer.ZgnHit( parent.zgn, 'horizontal', X );		
					
					theGame.SetTimeScale( 1.f );
					//parent.zgn.SetAnimationTimeMultiplier( 1.f );
					//thePlayer.SetAnimationTimeMultiplier( 1.f );
					
					parent.zgn.rodeoCanBeStarted = false;
				/*	
					parent.zgn.RaiseEvent( parent.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Macka1.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Macka2.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Macka4.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Macka5.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Macka6.forceEndAnimation );
					parent.zgn.RaiseEvent( parent.zgn.Paszcza.ForceIdleEvent );
				*/	
					parent.zgn.WaitForBehaviorNodeDeactivation( 'escape_end', 20 );
					
					parent.zgn.SpecialAttackDelay( 0.f );
					
					parent.zgn.rodeoCheckInProgress = false;
					break;
				}
			}
			
			if( breakRodeo )
			{
				thePlayer.BreakQTE();
				
				theGame.SetTimeScale( 1.f );
					
				parent.zgn.rodeoCanBeStarted = false;

				parent.zgn.WaitForBehaviorNodeDeactivation( 'escape_end', 20 );
				
				parent.zgn.SpecialAttackDelay( 0.f );
				
				parent.zgn.rodeoCheckInProgress = false;
			}
			
			Sleep( 0.0001f );
		}
		
		theGame.SetTimeScale( 1.f );
//		parent.zgn.SetAnimationTimeMultiplier( 1.0f );
//		thePlayer.SetAnimationTimeMultiplier( 1.0f );
		
		parent.zgn.WaitForBehaviorNodeDeactivation( 'escape_end', 20 );
		
		parent.isAttacking = false;
		parent.zgn.ExclusiveAttackInProgress = false;
		
		parent.zgn.SpecialAttackDelay( 3.f );
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state RodeoQTEM3 in ZagnicaMackaBig
{
	var actors : array<CEntity>;
	var actorNames : array<string>;
	var csName: string;
	var csPos : Vector;
	var csRot : EulerAngles;
	var Camera : CCamera;
	
	event OnLeaveState()
	{
		parent.zgn.RemoveTimer( 'KeepPlayerInCombat' );
		parent.zgn.magicBarrier.SetActive( true );
		parent.zgn.deadlyPoisonTrigger.SetEnabled( true );
	}
	
	entry function startRodeoM3()
	{
		var playerState : EPlayerState;
		var CSSucceeded : bool;
		var i, size : int;
		var tmpNode : CNode;
		
		parent.zgn.magicBarrier.SetActive( false );
		parent.zgn.deadlyPoisonTrigger.SetEnabled( false );
		
		csPos = parent.zgn.GetWorldPosition();
		csRot = parent.zgn.GetWorldRotation();
		
		/*actors.PushBack( parent.zgn );
		actors.PushBack( thePlayer );
		//actors.PushBack( Camera );
		actorNames.PushBack( "Root" );
		actorNames.PushBack( "witcher" );
		//actorNames.PushBack( "camera1" );
		thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
		parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
		CSSucceeded = theGame.PlayCutscene( "rodeo_start", actorNames, actors, csPos, csRot );
		thePlayer.ClearImmortality();
		if( !CSSucceeded )
		{
			Log( "-----------------------------------------------------------------" );
			Log( "Error while trying to play cutscene:" );
			Log( "Cutscene name: rodeo_start" );
			Log( "Actors:" );
			size = actors.Size();
			for( i = 0; i < size; i += 1 )
			{
				Log( "****************************" );
				Log( "actor - " + actors[i] );
				Log( "name - " + actorNames[i] );
			}
			Log( "****************************" );
			Log( "Cutscene position: " + VecToString(csPos) );
			Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
			Log( "-----------------------------------------------------------------" );
		}

		actors.Clear();
		actorNames.Clear();*/
		
		actors.PushBack( parent.zgn );
		actors.PushBack( thePlayer );
		//actors.PushBack( Camera );
		actorNames.PushBack( "Root" );
		actorNames.PushBack( "witcher" );
		//actorNames.PushBack( "camera1" );
		
		//playerState = thePlayer.GetCurrentPlayerState();
		//thePlayer.StartZgnRodeoQTE();
		thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
		parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
		CSSucceeded = theGame.PlayCutscene( "rodeo_qta", actorNames, actors, csPos, csRot );
		thePlayer.ClearImmortality();
		if( !CSSucceeded )
		{
			Log( "-----------------------------------------------------------------" );
			Log( "Error while trying to play cutscene:" );
			Log( "Cutscene name: rodeo_to1fall" );
			Log( "Actors:" );
			size = actors.Size();
			for( i = 0; i < size; i += 1 )
			{
				Log( "****************************" );
				Log( "actor - " + actors[i] );
				Log( "name - " + actorNames[i] );
			}
			Log( "****************************" );
			Log( "Cutscene position: " + VecToString(csPos) );
			Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
			Log( "-----------------------------------------------------------------" );
		}
		
		if( thePlayer.GetLastQTEResult() != QTER_Succeeded )
		{			
			actors.Clear();
			actorNames.Clear();
			
			actors.PushBack( parent.zgn );
			actors.PushBack( thePlayer );
			//actors.PushBack( Camera );
			actorNames.PushBack( "Root" );
			actorNames.PushBack( "witcher" );
			//actorNames.PushBack( "camera1" );
			
			//thePlayer.EndRodeo();
			thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
			parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
			CSSucceeded = theGame.PlayCutscene( "rodeo_fall", actorNames, actors, csPos, csRot );
			tmpNode = theGame.GetNodeByTag( 'fall_wp' );
			if( tmpNode )
			{
				thePlayer.TeleportWithRotation( tmpNode.GetWorldPosition(), tmpNode.GetWorldRotation() );
				theCamera.ResetRotationTo( false, tmpNode.GetHeading(), 0.f, 0.5f );
			}
			thePlayer.ClearImmortality();
			if( !CSSucceeded )
			{
				Log( "-----------------------------------------------------------------" );
				Log( "Error while trying to play cutscene:" );
				Log( "Cutscene name: rodeo_fall" );
				Log( "Actors:" );
				size = actors.Size();
				for( i = 0; i < size; i += 1 )
				{
					Log( "****************************" );
					Log( "actor - " + actors[i] );
					Log( "name - " + actorNames[i] );
				}
				Log( "****************************" );
				Log( "Cutscene position: " + VecToString(csPos) );
				Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
				Log( "-----------------------------------------------------------------" );
			}
			
			parent.zgn.RaiseForceEvent( parent.zgn.Macka1.forceEndAnimation );
			parent.zgn.RaiseForceEvent( parent.zgn.Macka2.forceEndAnimation );
			parent.zgn.RaiseForceEvent( parent.zgn.Macka3.forceEndAnimation );
			parent.zgn.RaiseForceEvent( parent.zgn.Macka4.forceEndAnimation );
			parent.zgn.RaiseForceEvent( parent.zgn.Macka5.forceEndAnimation );
			parent.zgn.RaiseForceEvent( parent.zgn.Macka6.forceEndAnimation );
			
			parent.zgn.rodeoIsFailed = false;
			//thePlayer.FinalizeRodeo();
			//thePlayer.ChangePlayerState( playerState );
			parent.zgn.SpecialAttackDelay( 3.f );
		}
		else
		{
			actors.Clear();
			actorNames.Clear();
			
			actors.PushBack( parent.zgn );
			actors.PushBack( thePlayer );
			//actors.PushBack( Camera );
			actorNames.PushBack( "Root" );
			actorNames.PushBack( "witcher" );
			//actorNames.PushBack( "camera1" );
			
			//thePlayer.EndRodeo();
			thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
			parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
			CSSucceeded = theGame.PlayCutscene( "rodeo_tojump", actorNames, actors, csPos, csRot );
			thePlayer.ClearImmortality();
			if( !CSSucceeded )
			{
				Log( "-----------------------------------------------------------------" );
				Log( "Error while trying to play cutscene:" );
				Log( "Cutscene name: rodeo_tojump" );
				Log( "Actors:" );
				size = actors.Size();
				for( i = 0; i < size; i += 1 )
				{
					Log( "****************************" );
					Log( "actor - " + actors[i] );
					Log( "name - " + actorNames[i] );
				}
				Log( "****************************" );
				Log( "Cutscene position: " + VecToString(csPos) );
				Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
				Log( "-----------------------------------------------------------------" );
			}
	
			thePlayer.BreakQTE();
			
			if( thePlayer.GetLastQTEResult() != QTER_Succeeded )
			{
				actors.Clear();
				actorNames.Clear();
				
				actors.PushBack( parent.zgn );
				actors.PushBack( thePlayer );
				//actors.PushBack( Camera );
				actorNames.PushBack( "Root" );
				actorNames.PushBack( "witcher" );
				//actorNames.PushBack( "camera1" );
				thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
				parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
				CSSucceeded = theGame.PlayCutscene( "rodeo_death", actorNames, actors, csPos, csRot );
				thePlayer.ClearImmortality();
				if( !CSSucceeded )
				{
					Log( "-----------------------------------------------------------------" );
					Log( "Error while trying to play cutscene:" );
					Log( "Cutscene name: rodeo_death" );
					Log( "Actors:" );
					size = actors.Size();
					for( i = 0; i < size; i += 1 )
					{
						Log( "****************************" );
						Log( "actor - " + actors[i] );
						Log( "name - " + actorNames[i] );
					}
					Log( "****************************" );
					Log( "Cutscene position: " + VecToString(csPos) );
					Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
					Log( "-----------------------------------------------------------------" );
				}
				//thePlayer.FinalizeRodeo();
				//thePlayer.EnterDead();
				
				theSound.PlaySound("gui/other/gameover");
				theHud.m_hud.SetGameOver();
			}
			else if( parent.zgn.BridgeHitsCount < 2 )
			{					
				actors.Clear();
				actorNames.Clear();
				
				actors.PushBack( parent.zgn );
				actors.PushBack( thePlayer );
				//actors.PushBack( Camera );
				actorNames.PushBack( "Root" );
				actorNames.PushBack( "witcher" );
				//actorNames.PushBack( "camera1" );
				thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
				parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
				CSSucceeded = theGame.PlayCutscene( "rodeo_jump", actorNames, actors, csPos, csRot );
				tmpNode = theGame.GetNodeByTag( 'fall_wp' );
				if( tmpNode )
				{
					thePlayer.TeleportWithRotation( tmpNode.GetWorldPosition(), tmpNode.GetWorldRotation() );
					theCamera.ResetRotationTo( false, tmpNode.GetHeading(), 0.f, 0.5f );
				}
				thePlayer.ClearImmortality();
				if( !CSSucceeded )
				{
					Log( "-----------------------------------------------------------------" );
					Log( "Error while trying to play cutscene:" );
					Log( "Cutscene name: rodeo_jump" );
					Log( "Actors:" );
					size = actors.Size();
					for( i = 0; i < size; i += 1 )
					{
						Log( "****************************" );
						Log( "actor - " + actors[i] );
						Log( "name - " + actorNames[i] );
					}
					Log( "****************************" );
					Log( "Cutscene position: " + VecToString(csPos) );
					Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
					Log( "-----------------------------------------------------------------" );
				}
				
				//thePlayer.FinalizeRodeo();
				//thePlayer.ChangePlayerState( playerState );
				parent.zgn.SpecialAttackDelay( 1.f );
			}
			else
			{					
				actors.Clear();
				actorNames.Clear();
				
				actors.PushBack( thePlayer );
				//actors.PushBack( Camera );
				actorNames.PushBack( "witcher" );
				//actorNames.PushBack( "camera1" );
				
				parent.zgn.RaiseForceEvent( 'bridge_hit' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m1' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m2' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m3' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m4' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m5' );
				parent.zgn.RaiseForceEvent( 'bridge_hit_m6' );
				thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
				parent.zgn.AddTimer( 'KeepPlayerInCombat', 1.0f, true );
				CSSucceeded = theGame.PlayCutscene( "rodeo_jump2", actorNames, actors, csPos, csRot );
				tmpNode = theGame.GetNodeByTag( 'fall_wp' );
				if( tmpNode )
				{
					thePlayer.TeleportWithRotation( tmpNode.GetWorldPosition(), tmpNode.GetWorldRotation() );
					theCamera.ResetRotationTo( false, tmpNode.GetHeading(), 0.f, 0.5f );
				}
				thePlayer.ClearImmortality();
				if( !CSSucceeded )
				{
					Log( "-----------------------------------------------------------------" );
					Log( "Error while trying to play cutscene:" );
					Log( "Cutscene name: rodeo_jump2" );
					Log( "Actors:" );
					size = actors.Size();
					for( i = 0; i < size; i += 1 )
					{
						Log( "****************************" );
						Log( "actor - " + actors[i] );
						Log( "name - " + actorNames[i] );
					}
					Log( "****************************" );
					Log( "Cutscene position: " + VecToString(csPos) );
					Log( "Cutscene rotation: Yaw = " + csRot.Yaw + ", Pitch = " + csRot.Pitch + ", Roll = " + csRot.Roll );
					Log( "-----------------------------------------------------------------" );
				}
				
				//thePlayer.FinalizeRodeo();
				//thePlayer.ChangePlayerState( playerState );
				parent.zgn.WaitForBehaviorNodeDeactivation( 'bridge_hit_deactivate', 20 );
				parent.zgn.EnterPhase2();
			}
		}
		
		parent.zgn.SpecialAttackDelay( 3.f );
	}
}
//////////////////////////////////////////////////////////////////////////////////////////

state SweepAttack in ZagnicaMackaBig
{
	entry function DoSweepAttack()
	{
		var eventProcessed : bool;
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point : Vector;
		var A, B : Vector;
		var dist : float;
		var gate1 : bool;
		var Player : CPlayer;
		var i, arraySize : 	int;
		
		parent.zgn.RaiseEvent( 'mac4_sweep_attack' );
		
		parent.zgn.arenaHolderInProgress = false;
		Player = thePlayer;
		
		while ( !parent.zgn.arenaHolderInProgress )
		{
			Sleep ( 0.1f );
		}
		
		while ( parent.zgn.arenaHolderInProgress )
		{
			parent.zgn.PlayerPosition = Player.GetWorldPosition();
		
			arraySize = parent.mackasBones.Size();
	
			for( i = 0; i < arraySize; i += 1 )
			{
				A = parent.zgn.PlayerPosition;
				B = MatrixGetTranslation( parent.zgn.GetBoneWorldMatrix( parent.mackasBones[i]) );
			
				dist = VecDistance2D( A, B );
			
				if ( dist < 4.0f )
				{
					i = arraySize;
					parent.zgn.arenaHolderInProgress = false;
					
					thePlayer.ZgnHit( parent.zgn, 'arenaHolder', parent.zgn.GetWorldPosition() );		
					break;
				}
			}
			
			Sleep ( 0.0000000000001f );
		}
		
		parent.zgn.WaitForBehaviorNodeDeactivation( 'bridge_attack_end', 20 );
		
		parent.zgn.arenaHolderInProgress = false;
		parent.zgn.sweepAttackInProgress = false;
		
		((ZagnicaMacka)parent).ReturnToIdle();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state ThrowAttack in ZagnicaMackaBig
{
	var attachedThrashEntity : CEntity;
	
	event OnLeaveState()
	{
		parent.isGrabbing = false;
		parent.isThrowing = false;
		
		if( attachedThrashEntity )
			attachedThrashEntity.Destroy();
	}
	
	entry function DoThrowAttack()
	{
		var eventProcessed : bool;
		var thrashRot : EulerAngles;
		var thrashEntity : CEntity;
		var thrashSpawnPosition, currentPlayerPos, thrashMassCenter, thrashDir : Vector;		
		var thrashComp : CRigidMeshComponent;

		parent.isGrabbing = true;
		parent.isThrowing = true;
		
		parent.isAttacking = true;
		
		eventProcessed = parent.zgn.RaiseEvent( 'mac3_bridge_throw1' );
		
		if ( eventProcessed )
		{	
			while( parent.isGrabbing )
			{
				Sleep( 0.01f );
			}
			
			thrashSpawnPosition = parent.zgn.GetComponent( "thrash_spawnpoint3" ).GetWorldPosition();
			
			attachedThrashEntity = theGame.CreateEntity( parent.ThrashEntityTemplate1, thrashSpawnPosition, VecToRotation( thrashSpawnPosition ) );
			if ( !attachedThrashEntity )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "thrashEntity is NULL" );
				Log( "======================================================================" );
			}
			
			parent.zgn.AttachEntityToBone( attachedThrashEntity, ("Bone26") );

			while( parent.isThrowing )
			{
				Sleep( 0.01f );
			}
			
			attachedThrashEntity.Destroy();
			
			thrashSpawnPosition = parent.zgn.GetComponent( "thrash_spawnpoint3" ).GetWorldPosition();
					
			currentPlayerPos = thePlayer.GetWorldPosition();
			thrashDir = currentPlayerPos - thrashSpawnPosition;
			thrashDir = VecNormalize(thrashDir) * 1.5f;
			thrashDir.W = 0;
			thrashSpawnPosition = thrashSpawnPosition + thrashDir;
			currentPlayerPos.Z += 0.5f;
			
			thrashEntity = theGame.CreateEntity( parent.ThrashEntityTemplate2, thrashSpawnPosition, VecToRotation( thrashSpawnPosition ) );
			if ( !thrashEntity )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "thrashEntity is NULL" );
				Log( "======================================================================" );
			}
		//	parent.zgn.DetachEntityFromSkeleton( thrashEntity );
			
			Sleep( 0.000001f );
			
			ThrowEntityWithHorizontalVelocity( thrashEntity, 40, currentPlayerPos );
			
	//		thrashRot.Yaw = VecHeading( currentPlayerPos );
			
	//		thrashComp = (CRigidMeshComponent) thrashEntity.GetComponentByClassName( 'CRigidMeshComponent' );
			
	//		ThrowEntity( thrashEntity, 20, currentPlayerPos );
			
			/*
			thrashMassCenter = thrashComp.GetCenterOfMassInWorld();
			
			thrashMassCenter.Z += 0.4f;
			
			thrashDir = currentPlayerPos - thrashMassCenter ;
			thrashDir.Z += 5.0f;
			
			thrashComp.ApplyLinearImpulseAtPoint( thrashDir, thrashMassCenter );
			*/
			
			((CThrashProjectile)thrashEntity).StartFlying();
 
			parent.zgn.WaitForBehaviorNodeActivation ( 'bridge_idle' );
			((ZagnicaMacka)parent).ReturnToIdle();
		}
		else
		{
			((ZagnicaMacka)parent).ReturnToIdle();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state ArenaHolderAttack in ZagnicaMackaSmall
{
	entry function DoArenaHolderAttack()
	{
		var eventProcessed : bool;
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point : Vector;
		var A, B : Vector;
		var dist : float;
		var gate1 : bool;
		var Player : CPlayer;
		var i, arraySize : 	int;
		var timeout : float;
		timeout = 0.0f;
		
		parent.isAttacking = true;
		
		eventProcessed = parent.zgn.RaiseEvent( parent.ArenaHolderEvent );
		
		if ( eventProcessed )
		{
			while ( !parent.arenaHolderStarted && timeout < 2.0f )
			{
				timeout += 0.1f;
				Sleep ( 0.1f );
			}
			
			while ( parent.zgn.arenaHolderInProgress )
			{
				parent.zgn.PlayerPosition = Player.GetWorldPosition();
			
				arraySize = parent.mackasBones.Size();
		
				for( i = 0; i < arraySize; i += 1 )
				{
					A = parent.zgn.PlayerPosition;
					B = MatrixGetTranslation( parent.zgn.GetBoneWorldMatrix( parent.mackasBones[i]) );
				
					dist = VecDistance2D( A, B );
				
					if ( dist < 1.0f )
					{
						thePlayer.BreakQTE();
						thePlayer.ZgnHit( parent.zgn, 'arenaHolder', parent.zgn.GetComponent( "Mac" + parent.MacIndexNumber + "_arenaholder_wp" ).GetWorldPosition() );		
						
						parent.zgn.playerHasBeenHit = true;
						parent.zgn.AddTimer( 'HitDelay', 3.f );
						parent.zgn.arenaHolderInProgress = false;
						break;
					}
				}
				
				Sleep ( 0.0000000000001f );
			}
			
			parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier, 10.0f );
			((ZagnicaMacka)parent).ReturnToIdle();
		}
		
		else
		{
			((ZagnicaMacka)parent).ReturnToIdle();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state ArenaHolderAttack in ZagnicaMackaBig
{
	entry function DoArenaHolderAttack()
	{
		var eventProcessed : bool;
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point : Vector;
		var A, B : Vector;
		var dist : float;
		var gate1 : bool;
		var Player : CPlayer;
		var i, arraySize : 	int;
		var timeout : float;
		timeout = 0.0f;
		
		parent.isAttacking = true;
		parent.zgn.ExclusiveAttackInProgress = true;
		
		eventProcessed = parent.zgn.RaiseEvent( parent.ArenaHolderEvent );
		
		if ( eventProcessed )
		{
			while ( !parent.arenaHolderStarted && timeout < 2.0f )
			{
				timeout += 0.1f;
				Sleep ( 0.1f );
			}
			
			while ( parent.zgn.arenaHolderInProgress )
			{
				parent.zgn.PlayerPosition = Player.GetWorldPosition();
			
				arraySize = parent.mackasBones.Size();
		
				for( i = 0; i < arraySize; i += 1 )
				{
					A = parent.zgn.PlayerPosition;
					B = MatrixGetTranslation( parent.zgn.GetBoneWorldMatrix( parent.mackasBones[i]) );
				
					dist = VecDistance2D( A, B );
				
					if ( dist < 2.0f )
					{
						thePlayer.BreakQTE();
						thePlayer.ZgnHit( parent.zgn, 'arenaHolderBig', parent.zgn.GetComponent( "Mac" + parent.MacIndexNumber + "_arenaholder_wp" ).GetWorldPosition() );		
						
						parent.zgn.playerHasBeenHit = true;
						parent.zgn.AddTimer( 'HitDelay', 3.f );
						parent.zgn.arenaHolderInProgress = false;
						break;
					}
				}
				
				Sleep ( 0.0000000000001f );
			}
			
			parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier, 10.0f );
			parent.zgn.ExclusiveAttackInProgress = false;
			((ZagnicaMacka)parent).ReturnToIdle();
		}
		
		else
		{
			((ZagnicaMacka)parent).ReturnToIdle();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state ThrowAttack in ZagnicaMackaSmall
{
	entry function DoThrowAttack()
	{
		var eventProcessed : bool;
		var thrashRot : EulerAngles;
		var thrashEntity : CEntity;
		var thrashSpawnPosition, currentPlayerPos, thrashMassCenter, thrashDir : Vector;		
		var thrashComp : CRigidMeshComponent;
		
		parent.isGrabbing = true;
		parent.isThrowing = true;
		
		parent.isAttacking = true;
		
		eventProcessed = parent.zgn.RaiseEvent( parent.ThrowAttackEvent );
		
		if ( eventProcessed )
		{	
			while( parent.isGrabbing )
			{
				Sleep( 0.01f );
			}
			
			thrashSpawnPosition = parent.zgn.GetComponent( "thrash_spawnpoint" + parent.MacIndexNumber ).GetWorldPosition();
			
			thrashEntity = theGame.CreateEntity( parent.ThrashEntityTemplate1, thrashSpawnPosition, VecToRotation( thrashSpawnPosition ) );
			if ( !thrashEntity )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "thrashEntity is NULL" );
				Log( "======================================================================" );
			}
			
			parent.zgn.AttachEntityToBone( thrashEntity, ("k_mac" + parent.MacIndexNumber + "_11") );
			
			while( parent.isThrowing )
			{
				Sleep( 0.01f );
			}
			
			thrashEntity.Destroy();

			thrashSpawnPosition = parent.zgn.GetComponent( "thrash_spawnpoint" + parent.MacIndexNumber ).GetWorldPosition();
			
			currentPlayerPos = thePlayer.GetWorldPosition();
			thrashDir = currentPlayerPos - thrashSpawnPosition;
			thrashDir = VecNormalize(thrashDir) * 3;
			thrashDir.W = 0;
			thrashSpawnPosition = thrashSpawnPosition + thrashDir;
			currentPlayerPos.Z += 1.0f;
			
			thrashEntity = theGame.CreateEntity( parent.ThrashEntityTemplate2, thrashSpawnPosition, VecToRotation( thrashSpawnPosition ) );
			if ( !thrashEntity )
			{
				Log( "======================================================================" );
				Log( "ZAGNICA ERROR" );
				Log( "thrashEntity is NULL" );
				Log( "======================================================================" );
			}
			
		//	parent.zgn.DetachEntityFromSkeleton( thrashEntity );
			
			Sleep( 0.00001f );
			
	//		thrashRot.Yaw = VecHeading( currentPlayerPos );
			
			//thrashComp = (CRigidMeshComponent) thrashEntity.GetComponentByClassName( 'CRigidMeshComponent' );
			
			ThrowEntityWithHorizontalVelocity( thrashEntity, 35, currentPlayerPos );
			
			/*
			thrashMassCenter = thrashComp.GetCenterOfMassInWorld();
			thrashMassCenter.Z -= 0.05f;
			
			thrashDir = currentPlayerPos - thrashMassCenter ;
			thrashDir.Z += 5.0f;
			
			thrashComp.ApplyLinearImpulseAtPoint( thrashDir, thrashMassCenter );
			*/
			((CThrashProjectile)thrashEntity).StartFlying();
			
 
			parent.zgn.WaitForBehaviorNodeActivation ( parent.IdleActivateNotifier );
			((ZagnicaMacka)parent).ReturnToIdle();
		}
		else
		{
			((ZagnicaMacka)parent).ReturnToIdle();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state MacIsBeingCut in ZagnicaMackaSmall
{
	entry function CutMacCutscene( optional MacIndex : int )
	{	
		var MackaRotation : EulerAngles;
		var MackaPosition : Vector;
		
		parent.IsBeingCut = true;
		
		parent.zgn.RemoveDummies();
		
		//theCamera.FocusOn( parent.zgn.GetComponent( "mouth_focus" ) );
		
		//parent.zgn.RaiseEvent( parent.zgn.Paszcza.ForceIdleEvent );
		
		parent.zgn.RaiseForceEvent( parent.CutCutsceneEvent );
		parent.zgn.RaiseForceEvent( 'cut_cutscene' );
		
		parent.zgn.PlayEffect( parent.bloodTrailsEffectName );
		
		while ( parent.IsBeingCut )
		{
			Sleep ( 0.1f );
		}
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateDecapitated, true );
		
		MackaRotation = parent.GetMackaBubbleRotation();
		MackaRotation.Pitch = 0;
		MackaRotation.Roll = 0;
		if( parent.MacIndexNumber == 1 )
		{
			MackaRotation.Yaw += 180;
		}
		else if( parent.MacIndexNumber == 6 )
		{
		}
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateCuted, true );
		
		parent.zgn.PlayEffect( parent.bloodTrailsEffectName );
		
		MackaPosition = parent.GetMackaBubblePosition();
		theGame.CreateEntity( parent.CuttedMackaTemplate, MackaPosition, MackaRotation, false, false, true );
		
		parent.zgn.WaitForBehaviorNodeDeactivation( parent.cutDeactivateNotifier, 10 );
		
		parent.zgn.StopEffect( parent.bloodTrailsEffectName );
		
		parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		
		parent.BindVariablesCutted();
		
		parent.zgn.CutMackasCount += 1;
		
		if( parent.zgn.CutMackasCount == 4 )
		{
			//theGame.UnlockAchievement( 'ACH_TENTAKILLER' );
		}
		
		Sleep ( 0.1f );
		
		if(parent.zgn.BridgeHitsCount == 2)
		{
			parent.zgn.Macka3.DoTryingEscapeM3();
		}
		else
		{
			parent.zgn.Paszcza.RageAttack();
		}
	}
	
	entry function TrapCutMacCutscene( optional MacIndex : int )
	{	
		var MackaRotation : EulerAngles;
		
		parent.IsBeingCut = true;
		parent.zgn.enterCsMode();
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateDecapitated, true );
		parent.zgn.RaiseForceEvent( parent.CutTrapCutsceneEvent );
		//parent.zgn.RaiseForceEvent( 'cut_cutscene' );
		
		MackaRotation = parent.GetMackaBubbleRotation();
		MackaRotation.Pitch = 0;
		MackaRotation.Roll = 0;
		
		if( parent.MacIndexNumber == 1 )
		{
			//MackaRotation.Yaw += 180;
		}
		else if( parent.MacIndexNumber == 6 )
		{
			MackaRotation.Yaw += 90;
		}
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateCuted, true );
		
		parent.zgn.PlayEffect( parent.bloodTrailsEffectName );
		
		theGame.CreateEntity( parent.CuttedMackaTemplate, parent.GetMackaBubblePosition(), MackaRotation );
		
		parent.zgn.WaitForBehaviorNodeDeactivation( parent.cutDeactivateNotifier, 10 );
		
		parent.zgn.StopEffect( parent.bloodTrailsEffectName );
		
		parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		
		parent.BindVariablesCutted();
		
		parent.zgn.CutMackasCount += 1;
		
		if( parent.zgn.CutMackasCount == 4 )
		{
			//theGame.UnlockAchievement( 'ACH_TENTAKILLER' );
		}
		
		Sleep ( 0.1f );
		
		if(parent.zgn.BridgeHitsCount == 2)
		{
			parent.zgn.Macka3.DoTryingEscapeM3();
		}
		else
		{
			parent.zgn.Paszcza.RageAttack();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

state MacIsBeingCut in ZagnicaMackaMid
{
	entry function CutMacCutscene( optional MacIndex : int )
	{	
		var MackaRotation : EulerAngles;
		var MackaPosition : Vector;
		
		parent.IsBeingCut = true;
		
		parent.zgn.RemoveDummies();
		
		if( parent.MacIndexNumber == 2 )
		{
			//parent.zgn.Macka1.ArenaHolderZone = 'ArenaHolder_m1_range_n';
			parent.zgn.Macka3.attackZone = 'Tentacle3_range_n' ;
		}
		else if ( parent.MacIndexNumber == 5 )
		{
			//parent.zgn.Macka6.ArenaHolderZone = 'ArenaHolder_m6_range_n';
			parent.zgn.Macka4.attackZone = 'Tentacle4_range_n';
		}
		
		//parent.zgn.RaiseEvent( parent.zgn.Paszcza.ForceIdleEvent );

		//theCamera.FocusOn( parent.zgn.GetComponent( "mouth_focus" ) );
		
		parent.zgn.RaiseForceEvent( 'cut_cutscene' );
		parent.zgn.RaiseForceEvent( parent.CutCutsceneEvent );
		
		parent.zgn.PlayEffect( parent.bloodTrailsEffectName );
		
		while ( parent.IsBeingCut )
		{
			Sleep ( 0.01f );
		}
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateDecapitated, true );
		
		MackaRotation = parent.GetMackaBubbleRotation();
		
		MackaRotation.Pitch = 0;
		MackaRotation.Roll = 0;
		MackaRotation.Yaw += 180;
		
		if( MacIndex == 5 )
		{
			MackaRotation.Yaw += 30;
		}
		else if( MacIndex == 2 )
		{
			MackaRotation.Yaw -= 25;
		}
			
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateCuted, true );
		
		MackaPosition = parent.GetMackaBubblePosition();
		//MackaPosition.Z += 1.0f;
		theGame.CreateEntity( parent.CuttedMackaTemplate, MackaPosition, MackaRotation, false, false, true );
		
		parent.zgn.WaitForBehaviorNodeDeactivation( parent.cutDeactivateNotifier, 20 );
		
		parent.zgn.StopEffect( parent.bloodTrailsEffectName );
		
		parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		
		parent.BindVariablesCutted();
		
		parent.zgn.CutMackasCount += 1;
		
		if( parent.zgn.CutMackasCount == 4 )
		{
			//theGame.UnlockAchievement( 'ACH_TENTAKILLER' );
		}
		
		Sleep ( 0.1f );
		
		if(parent.zgn.BridgeHitsCount == 2)
		{
			parent.zgn.Macka3.DoTryingEscapeM3();
		}
		else
		{
			parent.zgn.Paszcza.RageAttack();
		}
	}
	
	entry function TrapCutMacCutscene( optional MacIndex : int )
	{	
		var MackaRotation : EulerAngles;
		
		parent.IsBeingCut = true;
		parent.zgn.enterCsMode();
		
		if( parent.MacIndexNumber == 2 )
		{
			//parent.zgn.Macka1.ArenaHolderZone = 'ArenaHolder_m1_range_n';
			parent.zgn.Macka3.attackZone = 'Tentacle3_range_n';
		}
		else if ( parent.MacIndexNumber == 5 )
		{
			//parent.zgn.Macka6.ArenaHolderZone = 'ArenaHolder_m6_range_n';
			parent.zgn.Macka4.attackZone = 'Tentacle4_range_n';
		}
		
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateDecapitated, true );
		parent.zgn.RaiseForceEvent( parent.CutTrapCutsceneEvent );
		//parent.zgn.RaiseForceEvent( 'cut_cutscene' );
		
		MackaRotation = parent.GetMackaBubbleRotation();
		
		MackaRotation.Pitch = 0;
		MackaRotation.Roll = 0;
		
		if( parent.MacIndexNumber == 5 )
		{
			MackaRotation.Yaw += 180;
		}
			
		parent.zgn.SetBodyPartState( parent.MacBodyPartName, parent.MacStateCuted, true );
		
		parent.zgn.PlayEffect( parent.bloodTrailsEffectName );
		
		theGame.CreateEntity( parent.CuttedMackaTemplate, parent.GetMackaBubblePosition(), MackaRotation );
		
		parent.zgn.WaitForBehaviorNodeDeactivation( parent.cutDeactivateNotifier, 10 );
		
		parent.zgn.StopEffect( parent.bloodTrailsEffectName );
		
		parent.zgn.DeactivateAnimatedConstraint( parent.Lookat_Weight );
		
		parent.BindVariablesCutted();
		
		parent.zgn.CutMackasCount += 1;
		
		if( parent.zgn.CutMackasCount == 4 )
		{
			//theGame.UnlockAchievement( 'ACH_TENTAKILLER' );
		}
		
		Sleep ( 0.1f );
		
		if(parent.zgn.BridgeHitsCount == 2)
		{
			parent.zgn.Macka3.DoTryingEscapeM3();
		}
		else
		{
			parent.zgn.Paszcza.RageAttack();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
quest function AAAAddTrap()
{
	thePlayer.GetInventory().AddItem( 'Tentadrake Trap' );
}

exec function ShowZgnDbg()
{
	theGame.zagnica.AddTimer( 'UpdateDebug', 0.0001f, true );
}

exec function HideZgnDbg()
{
	theGame.zagnica.RemoveTimer( 'UpdateDebug' );
}
