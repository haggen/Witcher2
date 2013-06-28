/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
 
/////////////////////////////////////////////
// Zagnica class
/////////////////////////////////////////////

class Zagnica extends CActor 
{
	var ZagnicaPosition,ZagnicaDebugTextPosition, PlayerPosition : Vector;
	
	var ExclusiveAttackInProgress 															: bool;
	var HorizontalAttackInProgress, arenaHolderInProgress, FishermanSceneInProgress 		: bool;
	var rodeoCheckInProgress, rodeoCanBeStarted, rodeoIsFailed 		: bool;

	var CutMackasCount, MissedAttacksCount, BridgeHitsCount 								: int;
	var defaultRotationPoint 																: Vector;
	var zgnBridge, Sheala																	: CEntity;
	var magicBarrier																		: CForceField;
	var lastCutsceneTrigger, deadlyPoisonTrigger											: CTriggerAreaComponent;
	var zgnBridgeCrumbleEvent 																: name;
	var bossMaxHealth, attackDelay, blurValue												: float;
	var bossHealthPercent																	: int;
	var poisonDuration																		: float;
	var yrdenHoldTime																		: float;

	var ArenaHolderHasHit, playerHasBeenHit, playerHasUsedYrden, sweepAttackInProgress, spitHasHit	: bool;

	var VerticalAttackMouthEvent, HorizontalAttackMouthEvent 								: name;
	var mouthWpComponent																	: CComponent;
	
	editable inlined var Macka1 															: ZagnicaMackaSmall;
	editable inlined var Macka2 															: ZagnicaMackaMid;
	editable inlined var Macka3 															: ZagnicaMackaBig;
	editable inlined var Macka4 															: ZagnicaMackaBig;
	editable inlined var Macka5 															: ZagnicaMackaMid;
	editable inlined var Macka6 															: ZagnicaMackaSmall;
	editable inlined var Paszcza 															: ZagnicaPaszcza;
	editable var SpecialTrap																: CEntityTemplate;
	editable var Remains																	: CEntityTemplate;
	
	var Mackas : array<ZagnicaMacka>;
	var MackasSize, i : int;
	
	timer function UpdateDebug( time : float )
	{
		var point : Vector;
	
		point = Macka1.GetMackaBubblePosition();
		thePlayer.GetVisualDebug().AddSphere( 'macka1_bubble', 2.0f, point, true, Color( 255, 0, 0 ) );
		
		point = Macka2.GetMackaBubblePosition();
		thePlayer.GetVisualDebug().AddSphere( 'macka2_bubble', 2.0f, point, true, Color( 255, 0, 0 ) );
		
		point = Macka5.GetMackaBubblePosition();
		thePlayer.GetVisualDebug().AddSphere( 'macka5_bubble', 2.0f, point, true, Color( 255, 0, 0 ) );
		
		point = Macka6.GetMackaBubblePosition();
		thePlayer.GetVisualDebug().AddSphere( 'macka6_bubble', 2.0f, point, true, Color( 255, 0, 0 ) );
	}
	
	function IsBoss() : bool
	{
		return true;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var game : CWitcherGame = theGame;
		thePlayer.SetBigBossFight( true );
		super.OnSpawned(spawnData);
		game.zagnica = this;
	}
	
	event OnDestroyed()
	{
		var game : CWitcherGame = theGame;
		thePlayer.SetBigBossFight( false );
		super.OnDestroyed();
		game.zagnica = NULL;
	}
	
	private function UpdateBossHealth()
	{
		var bossCurrentHealth : float;
		var bubbles : array<CNode>;
		
		theGame.GetNodesByTag( 'tentadrake_bubble', bubbles );
		
		for( i = 0; i < 4; i += 1 )
		{
			bossCurrentHealth += ((TentadrakeBubble)bubbles[i]).health;
		}
		
		bossCurrentHealth += health;
		
		bossHealthPercent = RoundF( bossCurrentHealth/bossMaxHealth * 100 );
		theHud.m_hud.SetBossHealthPercent( bossHealthPercent );
	}
	
	private function BindMackas()
	{
		//Tworzenie kulek//this.GetVisualDebug().AddSphere( 'xxx', 1.0f, Vector);
		var i: int;
		
		//informing Mackas that they are parts of Zagnica
		Mackas.PushBack(Macka1);
		Mackas.PushBack(Macka2);
		Mackas.PushBack(Macka3);
		Mackas.PushBack(Macka4);
		Mackas.PushBack(Macka5);
		Mackas.PushBack(Macka6);
		MackasSize = Mackas.Size();
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			Mackas[i].zgn = this;
			Mackas[i].MacIndexNumber = i + 1;
			Mackas[i].BindVariables();
		}
		
		Paszcza.zgn = this;
		Paszcza.BindVariables();
	}
	
	// setting default variables values for Zagnica
	private function BindVariables()
	{
		this.DrawWeaponInstant( GetInventory().GetFirstLethalWeaponId() );
		
		attackDelay = 5.f;
		
		defaultRotationPoint = GetComponent( "default_rotation_wp" ).GetWorldPosition();
		
		FishermanSceneInProgress = false;
		
		blurValue = 0.5f;
		
		lastCutsceneTrigger = (CTriggerAreaComponent) GetComponent( "last_cutscene_trigger" );
		
		deadlyPoisonTrigger = (CTriggerAreaComponent) GetComponent( "deadly_poison_trigger" );
		
		mouthWpComponent = GetComponent("FX_mouth01");
		
		magicBarrier = (CForceField) theGame.GetNodeByTag( 'electric_obstacle' );
		
		zgnBridge = (CEntity) theGame.GetNodeByTag( 'zgn_bridge' );
		
		Sheala = (CEntity) theGame.GetNodeByTag( 'sheala' );
		
		poisonDuration = GetCharacterStats().GetFinalAttribute( 'poison_duration' );
		
		yrdenHoldTime = GetCharacterStats().GetFinalAttribute( 'TentacleYrdenDelay' );
		if( theGame.GetDifficultyLevel() > 1 )
			yrdenHoldTime *= 0.5f;
		else if( theGame.GetDifficultyLevel() < 1 )
			yrdenHoldTime *= 1.5f;
			
		health = GetCharacterStats().GetFinalAttribute( 'vitality' );
		bossMaxHealth += health;
		bossHealthPercent = 100;
		
		BridgeHitsCount = 0;
	}
	
	// rotates Zagnica back to default rotation
	private latent function ReturnToStartPos()
	{
		var zgnPos, playerPos : Vector;
		var csRot : EulerAngles;
		
		//ActionRotateTo( defaultRotationPoint );
		
		zgnPos = GetWorldPosition();
		playerPos = thePlayer.GetWorldPosition();
		
		zgnPos = defaultRotationPoint - zgnPos; 
		
		csRot = VecToRotation( zgnPos );

		//parent.TeleportWithRotation( parentPos, csRot );
		ActionSlideToWithHeadingAsync( GetWorldPosition(), csRot.Yaw, 3.f );
	}
	
	private function UpdateDummies()
	{
		var wpp1 : Vector;
		var wpp2 : Vector;
		var wpp5 : Vector;
		var wpp6 : Vector;
		var wpr1 : EulerAngles;
		var wpr2 : EulerAngles;
		var wpr5 : EulerAngles;
		var wpr6 : EulerAngles;
		var dummy1 : CComponent;
		var dummy2 : CComponent;
		var dummy5 : CComponent;
		var dummy6 : CComponent;
		
		var ent : CEntity;
		var tags : array< name >;
		
		var nodes : array<CNode>;
		var i, arraySize : int;
		
		theGame.GetNodesByTag( 'trap_dummy', nodes );
		arraySize = nodes.Size();
		
		for ( i = 0; i < arraySize; i += 1 )
		{			
			if ( ((CEntity)nodes[i]).GetAppearance() == '1_dummy' )
			{
				((CEntity)nodes[i]).Destroy();
			}
		}
		
		if ( thePlayer.GetInventory().HasItem( 'Tentadrake Trap' ) == true )
		{		
			dummy1 = (CComponent)GetComponent( "trap_dummy_1" );
			dummy2 = (CComponent)GetComponent( "trap_dummy_2" );
			dummy5 = (CComponent)GetComponent( "trap_dummy_5" );
			dummy6 = (CComponent)GetComponent( "trap_dummy_6" );
			
			wpp1 = dummy1.GetWorldPosition();
			wpr1 = dummy1.GetLocalRotation();
			wpp2 = dummy2.GetWorldPosition();
			wpr2 = dummy2.GetLocalRotation();
			wpp5 = dummy5.GetWorldPosition();
			wpr5 = dummy5.GetLocalRotation();
			wpp6 = dummy6.GetWorldPosition();
			wpr6 = dummy6.GetLocalRotation();
			
			if ( Macka2.isCut == false )
			{
				ent = theGame.CreateEntity( SpecialTrap, wpp2, wpr2 );
				tags = ent.GetTags();
				tags.PushBack('dummy_trap_2');
				ent.SetTags(tags);
			}
			else if ( Macka1.isCut == false )
			{
				ent = theGame.CreateEntity( SpecialTrap, wpp1, wpr1 );
				tags = ent.GetTags();
				tags.PushBack('dummy_trap_1');
				ent.SetTags(tags);
			}
			
			if ( Macka5.isCut == false )
			{
				ent = theGame.CreateEntity( SpecialTrap, wpp5, wpr5 );
				tags = ent.GetTags();
				tags.PushBack('dummy_trap_5');
				ent.SetTags(tags);
			}
			else if ( Macka6.isCut == false )
			{
				ent = theGame.CreateEntity( SpecialTrap, wpp6, wpr6 );
				tags = ent.GetTags();
				tags.PushBack('dummy_trap_6');
				ent.SetTags(tags);
			}
		}
	}
	
	private function RemoveDummies()
	{
		var nodes : array<CNode>;
		var i, arraySize : int;
		var nodeAppearance : name;
		
		theGame.GetNodesByTag( 'trap_dummy', nodes );
		arraySize = nodes.Size();
		
		for ( i = 0; i < arraySize; i += 1 )
		{
			nodeAppearance = ((CEntity)nodes[i]).GetAppearance();
			if ( nodeAppearance == '1_dummy' )
			{
				((CEntity)nodes[i]).Destroy();
				Log("Usun¹³em dummy " + nodes[i] );
			}
		}
	}
	
	// OLD // event when Macka was hit by Player
/*	event OnHitMac( AttackedMackaIdx : int )
	{
		Mackas[ AttackedMackaIdx - 1 ].MackaHasBeenHit();
	}
*/	

	// starts cutting macka animation
	function StartCuttingMacka()
	{
		thePlayer.ClearImmortality();
		if ( Macka1.IsBeingCut )
		{
			Macka1.IsBeingCut = false;
		}
		if ( Macka2.IsBeingCut )
		{
			Macka2.IsBeingCut = false;
		}
		if ( Macka5.IsBeingCut )
		{
			Macka5.IsBeingCut = false;
		}
		if ( Macka6.IsBeingCut )
		{
			Macka6.IsBeingCut = false;
		}
	}
		
	//stopping attacks for each macka
	private function StopMackasAttacks()
	{	
		var i: int;
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			if ( !Mackas[i].isCut )
			{
				Mackas[i].StopAttack();
			}
		}
	}
		
	//stopping attacks for each macka
	private function StopMackasAttacksCutscene( excludedMacIdx : int )
	{	
		var i: int;
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			if ( i == excludedMacIdx )
			{
				continue;
			}
			else if ( !Mackas[i].isCut )
			{
				Mackas[i].StopAttack();
			}
		}
	}
	
	// checking if any macka is attacking
	function AnyMackaAttacking() : bool
	{
		var i: int;
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			if( Mackas[i].isAttacking )
			{
				return true;
			}
			continue;
		}
		return false;
	}
	
	// checking if any macka is immobilized
	function AnyMackaImmobilized() : bool
	{
		var i: int;
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			if( Mackas[i].isImmobilized )
			{
				return true;
			}
			continue;
		}
		return false;
	}
	
	// returning target macka
	function GetMacka( TargetMackaIndex : int ) : ZagnicaMacka
	{
		return Mackas[ TargetMackaIndex - 1 ];
	}
	
	// checking if target macka is attacking
	function IsTargetMackaAttacking( TargetMackaIndex : int ) : bool
	{
		return Mackas[ TargetMackaIndex - 1 ].isAttacking;
	}
	
	// checking if target macka is cut
	function IsTargetMackaCut( TargetMackaIndex : int ) : bool
	{
		return Mackas[ TargetMackaIndex - 1 ].isCut;
	}
	
	// extracting constrain target from selected macka
	function TargetMackaConstrainExtract ( TargetMackaIndex : int ) : Vector
	{
		return Mackas[ TargetMackaIndex - 1 ].MackaConstraintTarget;
	}
	
	//checking are mackas crossing
	function TentaclesCross( v1, v2 : Vector, ParentMacId, CurrentMacId : int ) : bool
	{
		var z : float;
		var CrossVectorProduct : Vector;
		
		CrossVectorProduct = VecCross( v1, v2 );		
		z = CrossVectorProduct.Z;
		
		if ( ( ParentMacId > CurrentMacId && z > -0.2 ) || ( ParentMacId < CurrentMacId && z < 0.2 ) )
		{
			return true;
		}
		
		else
		{
			return false;
		}
	}
	
	function GetImmobilizedMackas() : array<int>
	{
		var i : int;
		var immMac : array<int>;
		
		for ( i=0; i<MackasSize; i+=1 )
		{
			if ( Mackas[i].isImmobilized )
			{
				immMac.PushBack( i + 1 );
			}
		}
		
		return immMac;
	}
	
	function HasMackaBubble( macNum : int ) : bool
	{
		return Mackas[ macNum - 1 ].HasMackaBubble();
	}
	
	function GetMackaBubblePosition( macNum : int ) : Vector
	{
		return Mackas[ macNum - 1 ].GetMackaBubblePosition();
	}
	
	function GetMackaBubbleRotation( macNum : int ) : EulerAngles
	{
		return Mackas[ macNum - 1 ].GetMackaBubbleRotation();
	}
	
	function GetMackaPositionStart( macNum : int ) : Vector
	{
		return Mackas[ macNum - 1 ].GetMackaStartPosition();
	}
	
	function GetMackaPositionEnd( macNum : int ) : Vector
	{
		return Mackas[ macNum - 1 ].GetMackaEndPosition();
	}
	
	timer function YrdenComment1( timeDelta : float )
	{
		if( !playerHasUsedYrden )
		{
			((CActor)Sheala).PlayScene( "Yrden2" ); 
			AddTimer( 'YrdenComment2', 10.f );
		}
	}
	
	timer function YrdenComment2( timeDelta : float )
	{
		if( !playerHasUsedYrden )
		{
			((CActor)Sheala).PlayScene( "Yrden1" ); 
			AddTimer( 'YrdenComment1', 10.f );
		}
	}
	
	timer function HitDelay( TimeDelta : float )
	{
		playerHasBeenHit = false;
	} 
	
	timer function Blur( timeDelta : float )
	{
		if( blurValue >= 0 )
		{
			blurValue -= 0.05;
			RadialBlurSetup( mouthWpComponent.GetWorldPosition(), blurValue, blurValue, blurValue, blurValue );
		}
		else
		{
			blurValue = 0;
			RadialBlurDisable();
			RemoveTimer( 'Blur' );
		}
	}
	
	timer function Mac1CameraControl( timeDelta : float )
	{
		var dist : float;
		var vector : Vector;
		var focusActive : bool;
	
		dist = VecDistance2D( thePlayer.GetWorldPosition(), Macka1.mackaBubble.GetWorldPosition() );
	
		if( dist > 10.f )
		{
			focusActive = false;
		
			theCamera.FocusOn( GetComponent( "mouth_focus" ), 2.f );
		}
		else if( !focusActive )
		{
			focusActive = true;
		
			vector = Macka1.mackaBubble.GetWorldPosition();
			
			vector.X += 1.f;	
			vector.Z = 2.f;
			
			theCamera.FocusOnStatic( vector, 2.f );
		}
	}
	
	timer function Mac2CameraControl( timeDelta : float )
	{
		var dist : float;
		var vector : Vector;
		var focusActive : bool;
	
		dist = VecDistance2D( thePlayer.GetWorldPosition(), Macka2.mackaBubble.GetWorldPosition() );
	
		if( dist > 10.f )
		{
			focusActive = false;
		
			theCamera.FocusOn( GetComponent( "mouth_focus" ), 2.f );
		}
		else if( !focusActive )
		{
			focusActive = true;
		
			vector = Macka2.mackaBubble.GetWorldPosition();
			
			vector.X += 0.8f;	
			vector.Z = 2.f;
			
			theCamera.FocusOnStatic( vector, 2.f );
		}
	}
	
	timer function Mac5CameraControl( timeDelta : float )
	{
		var dist : float;
		var vector : Vector;
		var focusActive : bool;
	
		dist = VecDistance2D( thePlayer.GetWorldPosition(), Macka5.mackaBubble.GetWorldPosition() );
	
		if( dist > 10.f )
		{
			focusActive = false;
		
			theCamera.FocusOn( GetComponent( "mouth_focus" ), 2.f );
		}
		else if( !focusActive )
		{
			focusActive = true;
		
			vector = Macka5.mackaBubble.GetWorldPosition();
			
			vector.X += 0.5f;
			vector.Z = 2.f;
			
			theCamera.FocusOnStatic( vector, 2.f );
		}
	}
	
	timer function Mac6CameraControl( timeDelta : float )
	{
		var dist : float;
		var vector : Vector;
		var focusActive : bool;
	
	
		dist = VecDistance2D( thePlayer.GetWorldPosition(), Macka6.mackaBubble.GetWorldPosition() );
	
		if( dist > 10.f )
		{
			focusActive = false;
		
			theCamera.FocusOn( GetComponent( "mouth_focus" ), 2.f );
		}
		else if( !focusActive )
		{
			focusActive = true;
		
			theCamera.FocusDeactivation( 2.f );
			vector = Macka6.mackaBubble.GetWorldPosition();
			
			vector.X += 0.5f;
			vector.Z = 2.f;
			
			theCamera.FocusOnStatic( vector, 2.f );
		}
	}
	
	function AreMackasCrossing( ParentMackaIndex : int ) : bool
	{
		var ParentMackaBoneName : name;
		var ParentMackaBoneMatrix : Matrix;
		var ParentMackaBoneVector : Vector;
		var VectorParent : Vector;
		
		var CurrentMackaBoneName : name;
		var CurrentMackaBoneVector : Vector;
		var CurrentMackaBoneMatrix : Matrix;
		var CheckInProgress : bool;
		var CurrentMackaIndex : int;
		var VectorCurrent : Vector;
		
		var CurrentMackaBoneName2 : name;
		var CurrentMackaBoneMatrix2 : Matrix;
		var CurrentMackaBoneVector2 : Vector;
		
		//setting variable values for parent macka
		if( ParentMackaIndex == 1 )
		{
			ParentMackaBoneName = 'k_mac1_AIM';
		}
		else if( ParentMackaIndex == 2 )
		{
			ParentMackaBoneName = 'k_mac2_AIM';
		}
		else if( ParentMackaIndex == 3 )
		{
			ParentMackaBoneName = 'k_mac3_AIM';
		}
		else if( ParentMackaIndex == 4 )
		{
			ParentMackaBoneName = 'k_mac4_AIM';
		}
		else if( ParentMackaIndex == 5 )
		{
			ParentMackaBoneName = 'k_mac5_AIM';
		}
		else if( ParentMackaIndex == 6 )
		{
			ParentMackaBoneName = 'k_mac6_AIM';
		}
		
		ParentMackaBoneMatrix = GetBoneWorldMatrix( ParentMackaBoneName ); 
		ParentMackaBoneVector = MatrixGetTranslation( ParentMackaBoneMatrix );
		
		VectorParent = VecNormalize2D( PlayerPosition - ParentMackaBoneVector );
		
		for ( CurrentMackaIndex=1; CurrentMackaIndex<=6; CurrentMackaIndex+=1 )
		{
			if ( CurrentMackaIndex == ParentMackaIndex || !IsTargetMackaAttacking( CurrentMackaIndex ) || IsTargetMackaCut( CurrentMackaIndex ) )
			{
				continue;				
			}
			
			//setting variable values for checked macka
			if( CurrentMackaIndex == 1 )
			{
				CurrentMackaBoneName = 'k_mac1_AIM';
			}
			else if( CurrentMackaIndex == 2 )
			{
				CurrentMackaBoneName = 'k_mac2_AIM';
			}
			else if( CurrentMackaIndex == 3 )
			{
				CurrentMackaBoneName = 'k_mac3_AIM';
			}
			else if( CurrentMackaIndex == 4 )
			{
				CurrentMackaBoneName = 'k_mac4_AIM';
			}
			else if( CurrentMackaIndex == 5 )
			{
				CurrentMackaBoneName = 'k_mac5_AIM';
			}
			else if( CurrentMackaIndex == 6 )
			{
				CurrentMackaBoneName = 'k_mac6_AIM';
			}
			
			CurrentMackaBoneMatrix = GetBoneWorldMatrix( CurrentMackaBoneName );
			CurrentMackaBoneVector = MatrixGetTranslation( CurrentMackaBoneMatrix );
			
			PlayerPosition = thePlayer.GetWorldPosition();
			
			CurrentMackaBoneVector2 = TargetMackaConstrainExtract(CurrentMackaIndex);
					
			VectorCurrent = VecNormalize2D( CurrentMackaBoneVector2 - CurrentMackaBoneVector );
			
			if( TentaclesCross( VectorParent, VectorCurrent, ParentMackaIndex, CurrentMackaIndex ) )
			{
				return true;
			}
			else
			{
				continue;
			}
		} 
		
		return false;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
			return false;
			
		if( area.GetName() == "deadly_poison_trigger" )
		{
			thePlayer.HitPosition( GetWorldPosition(), 'Attack', thePlayer.GetInitialHealth() * 0.1f, true, NULL, true );
			thePlayer.PlayEffect( 'lightning_hit_fx' );
			AddTimer( 'DeadlyPoisonDamage', 1.0f, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
			return false;
			
		if( area.GetName() == "deadly_poison_trigger" )
		{
			RemoveTimer( 'DeadlyPoisonDamage' );
		}
	}
	
	timer function DeadlyPoisonDamage( time : float )
	{
		thePlayer.HitPosition( GetWorldPosition(), 'Attack', thePlayer.GetInitialHealth() * 0.1f, true, NULL, true );
		thePlayer.PlayEffect( 'lightning_hit_fx' );
	}
	
	timer function KeepPlayerInCombat( time : float )
	{
		thePlayer.KeepCombatMode();
	}
}

/////////////////////////////////////////////
// First phase of bossfight
/////////////////////////////////////////////

state Phase1 in Zagnica
{
	// Event for spawning potencial tap dummies if Geralt carries a Tentadrake Trap
	event OnEnterState()
	{
		parent.UpdateDummies();
		Log( "POZYCJA ¯AGNICY PO WYSPAWNOWANIU      #########" + VecToString( MatrixGetTranslation(parent.GetBoneWorldMatrix('k_torso_g'))) );
		
		parent.GetCharacterStats().LogStats();
	}
	
	entry function StartPhase1()	
	{
		theHud.m_hud.HideMinimap();
		
		parent.EnablePathEngineAgent( false );
		
		parent.BindMackas();
		parent.BindVariables();
		
		parent.PlayEffect( 'poison_cloud' );
	
		((ZagnicaMacka)parent.Macka1).ReturnToIdle();
		((ZagnicaMacka)parent.Macka2).ReturnToIdle();
		((ZagnicaMacka)parent.Macka3).ReturnToIdle();
		((ZagnicaMacka)parent.Macka4).ReturnToIdle();
		((ZagnicaMacka)parent.Macka5).ReturnToIdle();
		((ZagnicaMacka)parent.Macka6).ReturnToIdle();
		parent.Paszcza.ReturnToIdle();
		
		theHud.m_hud.SetBossName( parent.GetDisplayName() );
		theHud.HudTargetActorEx( parent, true );
		theHud.m_hud.SetBossHealthPercent( 100.f );
		theHud.m_hud.SetBossArmorPercent( 0.f );
		
		parent.AddTimer( 'YrdenComment1', 20.f );
		
		((CActor)parent.Sheala).EnablePathEngineAgent( false );
		((CActor)parent.Sheala).EnablePhysicalMovement( false );
		parent.Sheala.TeleportWithRotation( theGame.GetNodeByTag('zgn_spawnpoint').GetWorldPosition(), theGame.GetNodeByTag('zgn_spawnpoint').GetWorldRotation() );
		parent.Sheala.ActivateBehavior( 'q105_sheala' );
		parent.Sheala.PlayEffect( 'levitation_fx' );
		
		Sleep( 3.f );
		
		parent.deadlyPoisonTrigger.SetEnabled( true );
		parent.StartAttackLoop();
	}
	
	entry function SpecialAttackDelay( delay : float )
	{
		Sleep( 0.1f );
		parent.ExclusiveAttackInProgress = false;
		parent.HorizontalAttackInProgress = false;
		
		((ZagnicaMacka)parent.Macka1).ReturnToIdle();
		((ZagnicaMacka)parent.Macka2).ReturnToIdle();
		((ZagnicaMacka)parent.Macka3).ReturnToIdle();
		((ZagnicaMacka)parent.Macka4).ReturnToIdle();
		((ZagnicaMacka)parent.Macka5).ReturnToIdle();
		((ZagnicaMacka)parent.Macka6).ReturnToIdle();
		parent.Paszcza.ReturnToIdle();
		
		parent.UpdateDummies();
		
		Sleep( delay );
		
		Log( "Macka 1 state                  " + parent.Macka1.GetCurrentState().ToString() );
		Log( "Macka 2 state                  " + parent.Macka2.GetCurrentState().ToString() );
		Log( "Macka 3 state                  " + parent.Macka3.GetCurrentState().ToString() );
		Log( "Macka 4 state                  " + parent.Macka4.GetCurrentState().ToString() );
		Log( "Macka 5 state                  " + parent.Macka5.GetCurrentState().ToString() );
		Log( "Macka 6 state                  " + parent.Macka6.GetCurrentState().ToString() );
		Log( "Paszcza state                  " + parent.Paszcza.GetCurrentState().ToString() );
		
		StartAttackLoop();
	}
	
	// attack loop
	entry function StartAttackLoop()
	{
		while ( 1 )		
		{
			if ( parent.CutMackasCount >= 4 )
			{
				parent.Macka3.DoTryingEscapeM3();
			}
			else
			{
				if ( parent.Macka1.ArenaHolderCanOccur() )
				{
					parent.Macka1.ArenaHolderAttack();
				} 
				
				if ( parent.Macka6.ArenaHolderCanOccur() )
				{
					parent.Macka6.ArenaHolderAttack();
				} 
				
				if ( parent.Macka3.ArenaHolderCanOccur() )
				{
					parent.Macka3.DoArenaHolderAttack();
				}
				
				if ( parent.Macka4.ArenaHolderCanOccur() )
				{
					parent.Macka4.DoArenaHolderAttack();
				}

				if ( parent.Paszcza.ScreamCanOccur() )
				{
					parent.Paszcza.DoRoarAttack();
				}
				
				if ( parent.Macka6.MackaCanAttack() && parent.Macka5.isCut )
				{
					parent.Macka6.StartAttack();
				}
				
				if ( parent.Macka1.MackaCanAttack() && parent.Macka2.isCut )
				{ 
					parent.Macka1.StartAttack();
				}
				
				if ( parent.Macka1.MackaCanThrow() )
				{
					parent.Macka1.ThrowAttack();
				}
					
				if ( parent.Macka6.MackaCanThrow() )
				{
					parent.Macka6.ThrowAttack();
				}
					
				if ( parent.Paszcza.SpitCanOccur() )
				{
					parent.Paszcza.DoSpitAttack();
				}
				
				if ( parent.Macka2.MackaCanAttack() )
				{
					parent.Macka2.StartAttack();
				}

				if ( parent.Macka5.MackaCanAttack() )
				{
					parent.Macka5.StartAttack();
				}
				
				if ( parent.Macka3.MackaCanAttack() )
				{
					parent.Macka3.StartAttack();
				}
					
				if ( parent.Macka4.MackaCanAttack() )
				{
					parent.Macka4.StartAttack();
				}
			}
			
			thePlayer.KeepCombatMode();
			Sleep( 0.01f );
		}	
	}
	
	// Checking if player was hit by finisher attack
	private final function CheckZgnHitFinisher() : bool
	{
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point, YrdenPosition : Vector;
		var K, X, Y, A, B, C, D : Vector;
		var dist, dist1, dist2, macLength1, macLength2 : float;
		
		if( thePlayer.GetCurrentStateName() == 'ZgnSpitQTE' )
		{
			thePlayer.ZgnHit( parent, 'finisher', X );
			parent.playerHasBeenHit = true;
			parent.AddTimer( 'HitDelay', parent.attackDelay );
			return true;
		}
		
		parent.PlayerPosition = thePlayer.GetWorldPosition();
		Bone1Mat = parent.GetBoneWorldMatrix( 'k_mac3_AIM' );
		Bone1Point = MatrixGetTranslation( Bone1Mat );
		
		Bone2Mat = parent.GetBoneWorldMatrix( 'k_mac4_AIM' );
		Bone2Point = MatrixGetTranslation( Bone2Mat );
		
		A = parent.PlayerPosition - Bone1Point;
		B = VecNormalize2D( parent.Macka3.MackaConstraintTarget - Bone1Point );
		B.Z = 0;
			
		C = parent.PlayerPosition - Bone2Point;
		D = VecNormalize2D( parent.Macka4.MackaConstraintTarget - Bone2Point );
		D.Z = 0;
				
		X = Bone1Point + B * VecDot2D( A, B ); 
		K = Bone2Point + D * VecDot2D( C, D ); 
				
		dist1 = VecDistance2D( X, parent.PlayerPosition );
		dist2 = VecDistance2D( K, parent.PlayerPosition );
		macLength1 = VecDistance2D( Bone1Point, parent.PlayerPosition );
		macLength2 = VecDistance2D( Bone2Point, parent.PlayerPosition );
				
		if ( (dist1 < 2.0f || dist2 < 2.0f) && (macLength1 < 43 || macLength2 < 43) )
		{
			thePlayer.ZgnHit( parent, 'finisher', X );
			parent.playerHasBeenHit = true;
			parent.AddTimer( 'HitDelay', parent.attackDelay );
			return true;
		}
		
		return false;
	}

	// Checking if player was hit by special attack
	private final function CheckZgnHitSpecial( macka : ZagnicaMacka, mackaIdx : int, attackType : name ) : bool
	{
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point, PlayerPosition : Vector;
		var K, X, A, B, C, D : Vector;
		var dist, dist1, macLength1 : float;
		
		PlayerPosition = thePlayer.GetWorldPosition();

		Bone1Point = macka.GetMackaStartPosition();
		Bone2Point = macka.GetMackaEndPosition();

		A = PlayerPosition - Bone1Point;
		B = VecNormalize2D( Bone2Point - Bone1Point );
		B.Z = 0;

		X = Bone1Point + B * VecDot2D( A, B ); 
		
		dist = VecDistance2D( X, PlayerPosition );
		macLength1 = VecDistance2D( Bone1Point, PlayerPosition );
		
		if ( mackaIdx == 3 || mackaIdx == 4 )
		{
			if ( dist < 2.0f && macLength1 < 43 )
			{
				thePlayer.ZgnHit( parent, attackType, X );
			}
		}
		
		else
		{
			if ( dist < 1.5f && macLength1 < 35 )
			{
				thePlayer.ZgnHit( parent, attackType, X );
			}
		}
	}
	
	// checking if player was hit by vertical attack
	private final function CheckZgnHitVertical( macka : ZagnicaMacka, mackaIdx : int )
	{
		var X, Y, A, B : Vector;
		var YrdenTrapInstance : CWitcherSignYrden;
		var Bone1Point, YrdenPosition : Vector;
		var dist, macLength1 : float;
		
		parent.PlayerPosition = thePlayer.GetWorldPosition();
			
		Bone1Point = macka.GetMackaStartPosition();
		
		//Bone1Point = parent.GetMackaPosition( 1 );
	
		YrdenTrapInstance = ( CWitcherSignYrden ) theGame.GetNodeByTag( 'Yrden_trap' );
		
		YrdenPosition = YrdenTrapInstance.GetWorldPosition();
		
		A = parent.PlayerPosition - Bone1Point;
		B = VecNormalize2D( macka.MackaConstraintTarget - Bone1Point );
		B.Z = 0;
			
		X = Bone1Point + B * VecDot2D( A, B ); 
		
		dist = VecDistance2D( X, parent.PlayerPosition );
		macLength1 = VecDistance2D( Bone1Point, parent.PlayerPosition );
		
		if ( mackaIdx != 3 && mackaIdx != 4 && !macka.IsBeingCut )
		{
			if ( dist < 2.0f && macLength1 < 35 )
			{
				thePlayer.ZgnHit( parent, 'vertical', X );
				parent.playerHasBeenHit = true;
				parent.AddTimer( 'HitDelay', 4.f );
			}
			else
			{
				parent.MissedAttacksCount += 1;
			}
			
			Y = YrdenPosition - Bone1Point;
			X = Bone1Point + B * VecDot2D( Y, B );
			
			parent.GetVisualDebug().AddSphere( 'YrdenPosition', 4.0f, X);
			parent.GetVisualDebug().AddSphere( 'YrdenPosition', 4.0f, YrdenPosition);
			
			dist = VecDistance2D( X, YrdenPosition);
			
			if ( dist < 3.f && macLength1 < 35 && YrdenTrapInstance && !macka.IsBeingCut )
			{	
				((ZagnicaMacka)macka).DoMackaImmobilized();
				
				YrdenTrapInstance.PlayEffect( 'yrden_explosion01' );
			//	YrdenTrapInstance.mgr.RemoveTrap( YrdenTrapInstance );
			//	YrdenTrapInstance.Destroy();
			}
		}
		else
		{
			if ( dist < 2.0f && macLength1 < 43 && !macka.IsBeingCut )
			{
				thePlayer.ZgnHit( parent, 'vertical', X );
				parent.playerHasBeenHit = true;
				parent.AddTimer( 'HitDelay', parent.attackDelay );
			}
			else
			{
				parent.MissedAttacksCount += 1;
			}
		}
	}
	
	// extracting macka's array index from event name
	function GetMackaIdxFromEvent( eventName : name ) : int
	{
		var str : string;
		var pos : int;
		
		str = eventName;
		str = StrLower( str );
		pos = StrFindFirst( str, "mac" );
		if ( pos != -1 )
		{
			str = StrMid( str, pos+3, 1 );
			return StringToInt( str, -1 );
		}
		else
		{
			return -1;
		}
	}
	
	// extracting event action name (without macka fragment)
	function GetEventAction( eventName : name ) : string
	{
		var str : string;
		var outStr : string;
		var pos : int;
		
		str = eventName;
		
		pos = StrFindFirst( str, "mac" );
		if ( pos != -1 )
		{
			outStr = StrLeft( str, pos ) + StrRight( str, StrLen(str) - pos - 4 );
			return outStr;
		}
	
		pos = StrFindFirst( str, "Mac" );
		if ( pos != -1 )
		{
			outStr = StrLeft( str, pos ) + StrRight( str, StrLen(str) - pos - 4 );
			return outStr;
		}
		
		return outStr;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////
	// Zagnica's animation events
	/////////////////////////////////////////////////////////////////////////////////////////
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		var macka : ZagnicaMacka;
		var mackaIdx : int;
		var eventAction : string;
		var mackaSmall : ZagnicaMackaSmall;
		var previousPlayerState : EPlayerState;
		
		mackaIdx = GetMackaIdxFromEvent( eventName );
		
		////////////////////////////////////////////////////////////
		// Events for macka
		if ( mackaIdx != -1 )
		{		
			macka = parent.GetMacka( mackaIdx );
			eventAction = GetEventAction( eventName );
			
			// Activates macka's look at constraint
			if ( eventAction == "_StartLookat" ) // full event name 'Mac3_StartLookat'
			{
				macka.MackaConstraintTarget = thePlayer.GetWorldPosition();
				parent.ActivateStaticAnimatedConstraint( macka.MackaConstraintTarget, macka.Lookat_Weight, macka.Lookat );
			}
			
			// Stops checking if player was hit by arena holder attack
			else if ( eventAction == "_attack2_holder" && eventType == AET_DurationEnd )
			{
				//parent.ArenaHolderHasHit = false;
				parent.arenaHolderInProgress = false;
				macka.arenaHolderStarted = false;
			}
			
			// Starts checking if player was hit by special attack
			else if ( eventAction == "_attack2_holder" && eventType == AET_DurationStart )
			{
				//CheckZgnHitHolder( macka, mackaIdx, 'arenaHolder' );
				parent.arenaHolderInProgress = true;
				macka.arenaHolderStarted = true;
			}
			
			// Starts checking if player was hit by vertical attack
			else if ( eventAction == "_attack1_vertical_FX" )
			{
				theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
				CheckZgnHitVertical( macka, mackaIdx );
				parent.PlayEffect( macka.smokeEffectName );
				//parent.EnableCollisionInfoReportingForComponent( parent.GetComponent(macka.tentacleComponentName), false );
			}
						
			// Starts checking if player was hit by special vertical attack
			else if ( eventAction == "_attack1_vertical_special" )
			{
				theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
				CheckZgnHitSpecial( macka, mackaIdx, 'vertical' );
				parent.PlayEffect( macka.smokeEffectName );
			}
			
			// Changes flag when macka grabbed an item
			else if ( eventAction == "_attack_throw_grab" )
			{
				mackaSmall = ( ZagnicaMackaSmall ) macka;
				mackaSmall.isGrabbing = false;
			}
			
			// Changes flag when macka releases hold of object
			else if ( eventAction == "_attack_throw_release" )
			{
				mackaSmall = ( ZagnicaMackaSmall ) macka;
				mackaSmall.isThrowing = false;			
			}
			
			// Starts checking if player was hit by horizontal attack
			else if ( eventAction == "Attack2__Start" ) // full event name 'Attack2_Mac3_Start'
			{
				theCamera.RaiseEvent( 'Camera_Shake_horizontal_loop' );
				macka.horizontalStarted = true;
			}
			
			// Ends checking if player was hit by horizontal attack
			else if ( eventAction == "Attack2__End" ) // full event name 'Attack2_Mac3_End'
			{
				parent.HorizontalAttackInProgress = false;
			}
		}
		///////////////////////////////////////////////////////////
		// Events for paszcza
		
		// Starts spit QTE
		else if ( eventName == 'Ranged_Attack' )
		{
			if( parent.CheckInteractionPlayerOnly( "spit_range" ) )
			{
				parent.spitHasHit = true;
				previousPlayerState = thePlayer.GetCurrentPlayerState();
				thePlayer.ApplyCriticalEffect( CET_Poison, parent, parent.poisonDuration );
				thePlayer.StartZgnSpitQTE( previousPlayerState );
				theHud.m_fx.VomitStart();
			}
		}
		
		// Deals scream hit to player
		else if ( eventName == 'Scream_Start' )
		{
			thePlayer.ZgnHit( parent, 'roar', parent.GetWorldPosition() );
			
			parent.PlayEffect( 'scream' );
			
			//RadialBlurSetup( parent.mouthWpComponent.GetWorldPosition(), 0.5f, 0.5f, 0.5f, 0.5f );
			
			parent.blurValue = 0.4f;
			parent.AddTimer( 'Blur', 0.2f, true );
		}
		
		else if ( eventName == 'Scream_Stop' )
		{
			//RadialBlurDisable();
		}
		
		// Starts checking if player was hit by finisher attack
		else if ( eventName == 'shake_finisher' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_Hit_double' );
			parent.PlayEffect( parent.Macka3.smokeEffectName );
			parent.PlayEffect( parent.Macka4.smokeEffectName );
			
			CheckZgnHitFinisher();
		}	
		
		// Starts camera lookat when finisher starts
		else if ( eventName == 'finisher_camera' )
		{
			theCamera.FocusOn( parent.GetComponent( "finisher_focus" ), 5 );
		}
		
		// Stops camera lookat when finisher hits
		else if ( eventName == 'finisher_camera_stop' )
		{
			theCamera.FocusDeactivation();
			//theCamera.FocusOn( parent.GetComponent( "mouth_focus" ) );
		}
	}
}

///////////////////////////////////////////////////
// State for Cutting Macka CS
///////////////////////////////////////////////////

state CutMacCutscene in Zagnica
{
	var counter : int;
	var Camera : CCamera;
	var timeout : int;
	
	event OnEnterState()
	{
		parent.RemoveTimers();
		parent.playerHasBeenHit = false;
		parent.MissedAttacksCount = 0;
	}
	
	event OnLeaveState()
	{
		if( !parent.playerHasUsedYrden )
		{
			((CActor)parent.Sheala).PlayScene( "Yrden1" ); 
			parent.AddTimer( 'YrdenComment1', 10.f );
		}
		
		parent.playerHasBeenHit = false;
		parent.MissedAttacksCount = 0;
	}
	
	entry function CutMacCutsceneZgn( cuttedMackaIndex : int )
	{
		parent.StopMackasAttacksCutscene( cuttedMackaIndex - 1 );
		timeout = 0;
		
		if( cuttedMackaIndex == 1 )
		{
			parent.Macka1.CutMacCutscene( 1 );
		}
		else if( cuttedMackaIndex == 2 )
		{
			parent.Macka2.CutMacCutscene( 2 );
		}
		else if( cuttedMackaIndex == 5 )
		{
			parent.Macka5.CutMacCutscene( 5 );
		}
		else if( cuttedMackaIndex == 6 )
		{
			parent.Macka6.CutMacCutscene( 6 );
		}
		
		while (true)
		{
			if( timeout == 8 )
				parent.StartCuttingMacka();
				
			timeout += 1;
			thePlayer.KeepCombatMode();
			Sleep( 1.f );
		}
	}
	
	entry function TrapCutMacCutsceneZgn( cuttedMackaIndex : int )
	{
		parent.StopMackasAttacksCutscene( cuttedMackaIndex - 1 );
		timeout = 0;
		
		if( cuttedMackaIndex == 1 )
		{
			parent.Macka1.TrapCutMacCutscene( 1 );
		}
		else if( cuttedMackaIndex == 2 )
		{
			parent.Macka2.TrapCutMacCutscene( 2 );
		}
		else if( cuttedMackaIndex == 5 )
		{
			parent.Macka5.TrapCutMacCutscene( 5 );
		}
		else if( cuttedMackaIndex == 6 )
		{
			parent.Macka6.TrapCutMacCutscene( 6 );
		}
		
		while (true)
		{
//			if( timeout == 8 )
//				parent.StartCuttingMacka();
				
			timeout += 1;
			thePlayer.KeepCombatMode();
			Sleep( 1.f );
		}
	}
	
	entry function enterCsMode()
	{
		while( true )
		{
			thePlayer.KeepCombatMode();
			Sleep( 1.0f );
		}
	}
	
	// Checking if player was hit by special attack
	private final function CheckZgnHitSpecial( macka : ZagnicaMacka, mackaIdx : int, attackType : name ) : bool
	{
		var Bone1Mat, Bone2Mat : Matrix;
		var Bone1Point, Bone2Point, PlayerPosition : Vector;
		var K, X, A, B, C, D : Vector;
		var dist, dist1, macLength1 : float;
		
		PlayerPosition = thePlayer.GetWorldPosition();

		Bone1Point = macka.GetMackaStartPosition();
		Bone2Point = macka.GetMackaEndPosition();

		A = PlayerPosition - Bone1Point;
		B = VecNormalize2D( Bone2Point - Bone1Point );
		B.Z = 0;

		X = Bone1Point + B * VecDot2D( A, B ); 
		
		dist = VecDistance2D( X, PlayerPosition );
		macLength1 = VecDistance2D( Bone1Point, PlayerPosition );
		
		if ( mackaIdx == 3 || mackaIdx == 4 )
		{
			if ( dist < 2.0f && macLength1 < 43 )
			{
				thePlayer.ZgnHit( parent, attackType, X );
			}
		}
		else
		{
			if ( dist < 1.5f )
			{
				if( macka.isCut )
				{
					if( macLength1 < 17 )
						thePlayer.ZgnHit( parent, attackType, X );
				}
				else if( macLength1 < 35 )
					thePlayer.ZgnHit( parent, attackType, X );
			}
		}
	}
	
	// Animation events for Rodeo QTE
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		var camera : CStaticCamera;
		var qteStartInfo : SSinglePushQTEStartInfo = SSinglePushQTEStartInfo();

		if ( eventName == 'macka_cutoff' )
		{
			parent.StartCuttingMacka();
		}
		else if ( eventName == 'rodeo_sweep_duration' && eventType == AET_DurationStart )
		{
			parent.rodeoCheckInProgress = true;
		}
		else if ( eventName == 'trying_escape_FX' && eventType == AET_DurationStart )
		{
			parent.PlayEffect( 'electric_obstacle_hit' );
			parent.magicBarrier.PlayEffect( 'zagnica_hit_obstacle' );
		}
		
		else if ( eventName == 'trying_escape_FX' && eventType == AET_DurationEnd )
		{
			parent.StopEffect( 'electric_obstacle_hit' );
			parent.magicBarrier.StopEffect( 'zagnica_hit_obstacle' );
		}
		
		else if ( eventName == 'rodeo_sweep_duration' && eventType == AET_DurationEnd )
		{
			parent.rodeoCheckInProgress = false;
		}
		
		else if ( eventName == 'camera_shakes' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
		//	theCamera.RaiseEvent( 'Camera_Shake_horizontal_loop' );
		}
		
		else if ( eventName == 'scream_duration' && eventType == AET_DurationStart )
		{
			parent.Paszcza.screamInProgress = true;
		}
		
		else if ( eventName == 'scream_duration' && eventType == AET_DurationEnd )
		{
			parent.Paszcza.screamInProgress = false;
		}

		else if ( eventName == 'Mac1_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka1, 1, 'vertical' );
			parent.PlayEffect( parent.Macka1.smokeEffectName );
		}
		
		else if ( eventName == 'Mac2_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka2, 2, 'vertical' );
			parent.PlayEffect( parent.Macka2.smokeEffectName );
		}
		
		else if ( eventName == 'Mac3_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka3, 3, 'vertical' );
			parent.PlayEffect( parent.Macka3.smokeEffectName );
		}
		
		else if ( eventName == 'Mac4_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka4, 4, 'vertical' );
			parent.PlayEffect( parent.Macka4.smokeEffectName );
		}
		
		else if ( eventName == 'Mac5_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka5, 5, 'vertical' );
			parent.PlayEffect( parent.Macka5.smokeEffectName );
		}
		
		else if ( eventName == 'Mac6_attack1_vertical' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka6, 6, 'vertical' );
			parent.PlayEffect( parent.Macka6.smokeEffectName );
		}
		
	/*	
		else if ( eventName == 'rodeo_fall_moment' )
		{
			counter += 1;
			
			if ( parent.rodeoIsFailed )
			{
				thePlayer.TeleportWithRotation( thePlayer.GetWorldPosition(), EulerAngles(0,0,0) );
				counter = 0;
			}
			else if ( counter == 2 )
			{
				counter = 0;
				thePlayer.RodeoWon();
			}
		}
	*/	
		else if ( eventName == 'zgn_pre_hit_bridge' )
		{
			//theGame.SetTimeScale( 0.3f );
			
		//	parent.SetAnimationTimeMultiplier( 0.3f );
		//	thePlayer.SetAnimationTimeMultiplier( 0.3f );
		//	((CAnimatedComponent)Camera.GetComponentByClassName( 'CAnimatedComponent' )).SetAnimationTimeMultiplier( 0.3f );
			qteStartInfo.action = 'Dodge';
			qteStartInfo.timeOut = 10;
			thePlayer.StartSinglePressQTEAsync( qteStartInfo );
		}
		
	/*	else if ( eventName == 'zgn_jump_moment' )
		{
			if ( parent.Macka3.LastQteIsWon )
			{
				parent.zgn.rodeoLastQteInProgress = false;
			}
			else
			{
				parent.rodeoLastQteInProgress = false;
				
				theGame.SetTimeScale( 1.f );

			}
		}
	*/	else if ( eventName == 'zgn_camera_bridge_focus' && parent.BridgeHitsCount < 3 )
		{
			camera = (CStaticCamera)theGame.GetNodeByTag( 'q105_bridge_focus_camera' );
			camera.Run(true);
		}
		else if ( eventName == 'zgn_hit_bridge' ) 
		{
			parent.BridgeHitsCount += 1;
			
			if( parent.BridgeHitsCount == 1 )
			{
				//theCamera.LookAt( theGame.GetNodeByTag('bridge_focus'), 2 );
				//theCamera.FocusOn( theGame.GetNodeByTag('bridge_focus'), true, 0 );
				parent.zgnBridgeCrumbleEvent = 'destruct1';
				theGame.GetWorld().ShowLayerGroup( "boss_arena\scripts\phase1" );
				theGame.GetWorld().HideLayerGroup( "boss_arena\scripts\phase0" );
				//theGame.GetWorld().LoadLayerAsync( "boss_arena\scripts\phase1", false ); // DEPRECATED
			}
			
			else if( parent.BridgeHitsCount == 2 )
			{
				//theCamera.LookAt( theGame.GetNodeByTag('bridge_focus'), 2 );
				parent.zgnBridgeCrumbleEvent = 'destruct2';
				theGame.GetWorld().ShowLayerGroup( "boss_arena\scripts\phase2" );
				theGame.GetWorld().HideLayerGroup( "boss_arena\scripts\phase1" );
				//theGame.GetWorld().LoadLayerAsync( "boss_arena\scripts\phase2", false ); // DEPRECATED
			}
			
			else if( parent.BridgeHitsCount == 3 )
			{
				parent.zgnBridgeCrumbleEvent = 'destruct3';
				theGame.GetWorld().ShowLayerGroup( "boss_arena\scripts\phase3" );
				theGame.GetWorld().HideLayerGroup( "boss_arena\scripts\phase2" );
				FactsAdd('q105_bridge_collapsed', 1);
				// theGame.GetWorld().LoadLayerAsync( "boss_arena\scripts\phase3", false ); // DEPRECATED
			}
			
			parent.zgnBridge.RaiseEvent( parent.zgnBridgeCrumbleEvent );
		}
		
		else if ( eventName == 'zgn_hit_bridge_post' )
		{
			//theCamera.FocusOn( parent.GetComponent( "mouth_focus" ), false, 0 );
			//theCamera.FocusOn( parent.GetComponent( "mouth_focus" ), 2 );
		}
		
		else if( eventName == 'hit_bridge' )
		{
			thePlayer.SetHealth( 0, true, parent );
		}
		
		//else if ( eventName == 'death' )
		//{
			//thePlayer.EnterDead();
			//CalculateDamage( parent, thePlayer, false, true, true, true, 20 );
			//theGame.FadeOutAsync();
		//}
		
		// Starts checking if player was hit by special vertical attack
		else if ( eventName == 'mac3_attack1_vertical_special' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka3, 3, 'vertical' );
			parent.PlayEffect( parent.Macka3.smokeEffectName );
		}
		
		else if ( eventName == 'mac4_attack1_vertical_special' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitSpecial( parent.Macka4, 4, 'vertical' );
			parent.PlayEffect( parent.Macka4.smokeEffectName );
		}
	}
}

///////////////////////////////////////////////////
// Second phase of bossfight
///////////////////////////////////////////////////

state Phase2 in Zagnica 
{
	var actors : array<CEntity>;
	var actorNames : array<string>;
	var csNode : CNode;
	var csPos :	Vector;
	var csRot : EulerAngles;
	var groundTriggerOn, lastCutsceneStarted : bool;
	var isPlayingCutscene : bool;
	var lastRockAttack : EngineTime;
	var attackCooldown : float;
	default lastCutsceneStarted = false;
	default isPlayingCutscene = false;
	default attackCooldown =  7.0;
	
	function SetLastRockAttackTime()
	{
		lastRockAttack = theGame.GetEngineTime();
	}
	function CanPerformRockAttack() : bool
	{
		if( theGame.GetEngineTime() > lastRockAttack + attackCooldown )
		{
			return true;
		}
		else return false;
	}
	event OnEnterState()
	{
		parent.RemoveTimers();
		parent.RemoveDummies();
		
		actorNames.PushBack( "witcher" );
		actorNames.PushBack( "sheala" );
		actorNames.PushBack( "zagnica" );
		
		actors.PushBack( thePlayer );
		actors.PushBack( parent.Sheala );
		actors.PushBack( parent );
		
		csNode = theGame.GetNodeByTag( 'point_cs1_bomb' );
		csPos = /*parent.zgnBridge.GetWorldPosition();*/csNode.GetWorldPosition();
		csRot = /*parent.zgnBridge.GetWorldRotation();*/csNode.GetWorldRotation();
		theHud.EnableTrackedMapPinTag( 'q105_mappin_tenta_bridge' );
		theHud.DisableTrackedMapPinTag( 'q105_tenta_lair_mappin' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		var areaName : string;
		
		if ( isPlayingCutscene )
			return false; // do not change entry function if cutscene is playing
		
		if( activator.GetEntity() != thePlayer )
			return false;
		
		areaName = area.GetName();
		
		if( areaName == "bridge_hits_trigger" )
		{
			BridgeAttackLoop();
		}
		else if( areaName == "ground_ready_trigger" )
		{
			parent.RaiseForceEvent( 'mac4_sweep_bridge' );
		}
		else if( areaName == "ground_hits_trigger" )
		{
			groundTriggerOn = true;
		}
		else if( areaName == "last_cutscene_trigger" )
		{
			parent.DieZagnica();
		}
		else
			parent.OnAreaEnter( area, activator );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		var areaName : string;
		
		if( isPlayingCutscene )
			return false; // do not change entry function if cutscene is playing
		
		if( activator.GetEntity() == thePlayer )
			return false;
			
		areaName = area.GetName();
		
		/*HACKED FOR PRESS RELEASE!!!
		if( areaName == "bridge_hits_trigger" && !lastCutsceneStarted )
		{
			if( area.TestPointOverlap( thePlayer.GetWorldPosition() ) )
				return false;
			parent.RaiseForceEvent( 'bridge_sequence_end' );
			SecondPhaseAttackLoop();
		}
		else */if( areaName == "ground_ready_trigger" )
		{
			parent.RaiseForceEvent( 'mac4_sweep_end' );
		}
		else if( areaName == "ground_hits_trigger" )
		{
			groundTriggerOn = false;
		}
		else
			parent.OnAreaExit( area, activator );
	}
	
	// Checking hits on player
	private final function CheckZgnHitBridge ( macka : ZagnicaMacka, mackaIdx : int )
	{
		var eventProcessed : bool;
		var A, B, wpPos : Vector;
		var dist : float;
		var i, arraySize : 	int;
	
		arraySize = macka.mackasBones.Size();
		
		parent.PlayerPosition = thePlayer.GetWorldPosition();
		A = parent.PlayerPosition;
		wpPos = parent.GetComponent( "explosionwaypoint" ).GetWorldPosition();
		
		for( i = 0; i < arraySize; i += 1 )
		{
			B = MatrixGetTranslation( parent.GetBoneWorldMatrix( macka.mackasBones[i]) );
		
			dist = VecDistance( A, B );
		
			if ( dist < 4.0f )
			{
				thePlayer.BreakQTE();
				thePlayer.ZgnHit( parent, 'arenaHolder', wpPos );		
				
				((ZagnicaMacka)macka).ReturnToIdle();
				break;
			}
		}
	}
	
	entry function EnterPhase2()
	{
		parent.Paszcza.ReturnToIdle();
		((ZagnicaMacka)parent.Macka1).ReturnToIdle();
		((ZagnicaMacka)parent.Macka2).ReturnToIdle();
		((ZagnicaMacka)parent.Macka3).ReturnToIdle();
		((ZagnicaMacka)parent.Macka4).ReturnToIdle();
		((ZagnicaMacka)parent.Macka5).ReturnToIdle();
		((ZagnicaMacka)parent.Macka6).ReturnToIdle();
		
		parent.SecondPhaseAttackLoop();
	}
	
	entry function SecondPhaseAttackLoop()
	{
		while ( 1 )		
		{
			if( groundTriggerOn && !parent.sweepAttackInProgress  )
			{
				parent.sweepAttackInProgress = true;
				parent.Macka4.DoSweepAttack();
			}
			if( !parent.Macka3.isAttacking && CanPerformRockAttack() )
			{
				SetLastRockAttackTime();
				parent.Macka3.DoThrowAttack();
			}
			
			thePlayer.KeepCombatMode();
			Sleep( 0.01f );
		}
	}

	entry function BridgeAttackLoop()
	{
		var area : CTriggerAreaComponent;
		
		area = (CTriggerAreaComponent)parent.GetComponent( 'bridge_hits_trigger' );
		
		if( parent.Macka3.isAttacking )
		{
			parent.RaiseForceEvent( 'force_bridge_idle3' );
			((ZagnicaMacka)parent.Macka3).ReturnToIdle();
		}
		
		parent.RaiseForceEvent( 'bridge_sequence' );
		
		while ( 1 )
		{
			thePlayer.KeepCombatMode();
			Sleep( 1.0f );
			
			//HACKED FOR PRESS RELEASE!!!
			if( !area.TestPointOverlap( thePlayer.GetWorldPosition() ) )
			{
				parent.RaiseForceEvent( 'bridge_sequence_end' );
				parent.SecondPhaseAttackLoop();
			}
		}
	} 
	
	entry function DieZagnica()
	{
		isPlayingCutscene = true; // block changing entry function

		parent.SetBodyPartState( 'Mesh zagnica__body_b1', 'Destroyed', true );
		
		theHud.m_hud.HideBossHealth();
		parent.RemoveTimers();
		theCamera.FocusDeactivation();
		
		lastCutsceneStarted = true;
		parent.Sheala.StopEffect( 'levitation_fx' );
		thePlayer.SetImmortalityModeRuntime(AIM_Invulnerable, 15.0);
		theGame.PlayCutscene( "cs1_bomb", actorNames, actors, csPos, csRot );
		thePlayer.ClearImmortality();
		
		//parent.Sheala.GetRootAnimatedComponent().PopBehaviorGraph( 'q105_sheala' );
		
		csRot.Yaw += 180;
		
		theGame.GetWorld().ShowLayerGroup( "boss_arena\scripts\phase4" );
		theGame.GetWorld().HideLayerGroup( "boss_arena\scripts\phase3" );
		parent.EnablePathEngineAgent( false );
		parent.EnablePhysicalMovement( false );
		parent.TeleportWithRotation( csPos, csRot );
		
		parent.RaiseForceEvent( 'death' );
		
		isPlayingCutscene = false;
		
		EnterDead();
	}
	
	private function EnterDead( optional onlyDestruct : bool )
	{
		parent.StateDead();
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if ( eventName == 'side_attack' && eventType == AET_DurationStart )
		{
			parent.arenaHolderInProgress = true;
		}
		else if ( eventName == 'side_attack' && eventType == AET_DurationEnd )
		{
			parent.arenaHolderInProgress = false;
		}
		// Changes flag when macka grabbed an item
		else if ( eventName == 'Mac3_attack_throw_grab' )
		{
			parent.Macka3.isGrabbing = false;
		}
		
		// Changes flag when macka releases hold of object
		else if ( eventName == 'Mac3_attack_throw_release' )
		{
			parent.Macka3.isThrowing = false;			
		}
		
		else if ( eventName == 'mac3_fx' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitBridge( parent.Macka3, 3 );
			parent.PlayEffect( parent.Macka3.smokeEffectName );
		}
		
		else if ( eventName == 'mac4_fx' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
			CheckZgnHitBridge( parent.Macka3, 3 );
			parent.PlayEffect( parent.Macka3.smokeEffectName );
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////
// State Dead 
//////////////////////////////////////////////////////////////////////////////////////////////

state Dead in Zagnica
{
	event OnEnterState()
	{
		super.OnEnterState();
		Log( parent.GetName()+" dead" );
		
		theHud.DisableTrackedMapPinTag( 'q105_mappin_tenta_bridge' );
		theHud.DisableTrackedMapPinTag( 'q105_mappin_tenta_bridge1' );
		
		//parent.GetInventory().ThrowAwayAllItems();

		FactsAdd( "q105_tenta_dead", 1 );
		
		theGame.CreateEntity( parent.Remains, parent.GetWorldPosition() );
		
		//thePlayer.ExitCombatZagnica( PS_Exploration );
		thePlayer.ChangePlayerState( PS_Exploration );
				
		theHud.m_hud.CombatLogAdd( "<span class='orange'>" + parent.GetDisplayName() + "</span><span class='white'> " + GetLocStringByKeyExt( "cl_death" ) + ".</span>" );
		// add exp
		CalculateGainedExperienceAfterKill(parent, true, true, false);
		
		// theGame.GetWorld().LoadLayerAsync( "boss_arena\scripts\phase4", false ); // DEPRECATED
//		thePlayer.PlaySound( 'Stop_music_l02_tentadrake' );
	}
	
	entry function StateDead()
	{
		var usedtrap : CEntity;
		
		theHud.m_hud.ShowMinimap();
		thePlayer.SetBigBossFight( false );
		parent.magicBarrier.StopEffect( 'electric' );
		parent.magicBarrier.SetActive( false );
		thePlayer.EnablePhysicalMovement( false );
		thePlayer.EnablePathEngineAgent( true );
		usedtrap = theGame.GetEntityByTag( 'tentadrake_trap' );
		usedtrap.Destroy();
		
		parent.Mackas.Clear();
		
		theGame.GetWorld().HideLayerGroup( "boss_arena\scripts\zgn_fight" );
		parent.Destroy();
	}
}

exec function zgnp2()
{
	theGame.zagnica.EnterPhase2();
	theGame.zagnica.zgnBridge.RaiseForceEvent( 'collapse' );
}
