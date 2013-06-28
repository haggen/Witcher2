/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Axii sign implementation
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/


/////////////////////////////////////////////
class CWitcherAxiiCastEffect extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('SafeStop', 5.0, false);
		this.PlayEffect('processing_fx');
	}
	timer function SafeStop(td : float)
	{
		this.StopFX();
	}
	function Success()
	{
		this.PlayEffect('axii_successful_fx');
		StopFX();
	}
	function Failure()
	{
		StopFX();
	}
	timer function DestroyFX(td : float)
	{
		this.Destroy();
	}
	function StopFX()
	{
		thePlayer.StopEffect('axii_fx_level1');
		this.RemoveTimer('SafeStop');
		this.StopEffect('processing_fx');
		this.AddTimer('DestroyFX', 5.0, false);
	}
}
class CWitcherSignAxii extends CEntity
{	
	editable var	successEffectLength 	: float;
	editable var	failureEffectLength 	: float;
	editable var 	fadeoutTime 			: float;
	editable var	castingEffectTemplate			: CEntityTemplate;
	var				level					: int;
	var				target					: CNewNPC;
	var				randomChance			: bool;
	var 			axiiSuccess				: bool;
	var 			castDuration			: float;
	var 			castingEffect 			: CWitcherAxiiCastEffect;
	var				maxTargets				: int;
	default 		castDuration 			= 2.0;
	
	function SetAxiiSuccess(success : bool)
	{
		axiiSuccess = success;
	}
	function GetAxiiSuccess() : bool
	{
		return axiiSuccess;
	}
	function Init( target : CNewNPC, randomChance : bool )
	{
	
		if(thePlayer.GetCharacterStats().HasAbility('magic_s3_2'))
		{
			level = 2;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s3'))
		{
			level = 1;
		}
		else
		{
			level = 0;
		}
		if(thePlayer.GetCharacterStats().HasAbility('magic_s7_2'))
		{
			level = 2;
			maxTargets = 3;
		}
		else if(thePlayer.GetCharacterStats().HasAbility('magic_s7'))
		{
			level = 1;
			maxTargets = 2;
		}
		else
		{
			level = 0;
			maxTargets = 1;
		}
		this.target 		= target;
		this.randomChance 	= randomChance;
		TryToTakeControl();
		
		//theHud.m_hud.ShowTutorial("tut36", "tut36_333x166", false); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut36", "tut36_333x166" );

	}
	function SetCastDuration(duration : float)
	{
		castDuration = duration;
	}
}

///////////////////////////////////////////////////////////////////////////
state Fadeing in CWitcherSignAxii
{
	entry function Fadeout()
	{
		thePlayer.SetIsCastingAxii(false);
		parent.AddTimer('FadeTimer', 3.0, false);
	}
	timer function FadeTimer(td : float)
	{
		parent.Destroy();
	}

}
state TryToTakeControl in CWitcherSignAxii
{
	private var controlDuration				: float;
	
	event OnEnterState()
	{	
		var fxName							: name;
		
		super.OnEnterState();
		
		// start the special effects
		fxName = GetPlayerFxName( parent.level );
		//thePlayer.PlayEffect( fxName, parent.target );
		
		fxName = GetTargetFxName( parent.level );
		//parent.target.PlayEffect( fxName );
		
		// rotate towards the target
		thePlayer.SetRotationTarget( parent.target, true );
	
	}
	
	event OnLeaveState()
	{
		var fxName							: name;
		
		super.OnLeaveState();
		
		// stop the special effects
		fxName = GetPlayerFxName( parent.level );
	
		//parent.target.StopEffect( fxName );
		
		// stop rotation towards the target
		thePlayer.ClearRotationTarget();
	}
	
	entry function TryToTakeControl()
	{		
		var stats 							: CCharacterStats;
		var duration						: float;
		var fxName 							: name;
		var diceThrow					 	: float;
		var resAxii 						: float;
		var loopCounter						: int;
		var time							: EngineTime;
		var axiiCastingDuration				: float;
		var castingTime						: EngineTime;
		
		axiiCastingDuration = parent.castDuration; 
		thePlayer.DecreaseStamina( 1.0 );
		fxName = GetPlayerFxName( parent.level );
		// start the projectile
		stats = thePlayer.GetCharacterStats();
		duration = 0.5; //stats.GetAttribute( 'axii_takeover_duration' );
		controlDuration = 15;//stats.GetAttribute( 'axii_control_duration' );
		if(parent.target)
		{
			parent.castingEffect = (CWitcherAxiiCastEffect)theGame.CreateEntity(parent.castingEffectTemplate, parent.target.GetWorldPosition(), parent.target.GetWorldRotation());
			thePlayer.PlayEffect( fxName, parent.castingEffect.GetComponent("fx_point") );
			
			diceThrow = RandRangeF(0.01, 0.99);
			resAxii = parent.target.GetCharacterStats().GetFinalAttribute('res_axii');
			if ( diceThrow > resAxii && parent.target.GetAttitude(thePlayer) == AIA_Hostile)
			{
				parent.SetAxiiSuccess(true);
			}
			else
			{
				parent.SetAxiiSuccess(false);
			}
			parent.target.OnAxiiHitReaction();
			//parent.AddTimer('CastTimer', 2.0, false);
			while(true)// && loopCounter < 50)
			{
				loopCounter += 1;
				Sleep(0.1);
				if(thePlayer.GetIsInAxiiLoop())
				{
					break;
				}
			}
			castingTime = theGame.GetEngineTime() + axiiCastingDuration;
			while(thePlayer.GetIsCastingAxii())
			{
				time = theGame.GetEngineTime();
				if(time >  castingTime)
				{
					break;
				}
				Sleep(0.1);
			}
			thePlayer.SetAxiiLoop(false);
			if(!thePlayer.GetIsCastingAxii())
			{
				parent.SetAxiiSuccess(false);
				CastEffect();
			}
			else
			{
				CastEffect();
			}
		}
		else
		{
	
			thePlayer.SetAxiiLoop(false);
			if(thePlayer.IsInCombatState())
			{
				thePlayer.PlayerActionForced(PCA_AxiiFail);
				thePlayer.PlayEffect('Axii_fail');
				thePlayer.StopEffect(fxName);
				parent.Fadeout();
			}
		}
	}
	
	// --------------------------------------------------------------------
	// lifetime management
	// --------------------------------------------------------------------
	function CastEffect()
	{
		var npcToCalm	: CNewNPC;
		var currentTargets : int;
		var fxName 		: name;
		
		parent.RemoveTimer( 'CastTimer' );
		
		fxName = GetPlayerFxName( parent.level );
		thePlayer.StopEffect(fxName);
		
		if(parent.GetAxiiSuccess())
		{
			parent.target.NotifySpellHit( 'Axii' );
			parent.target.HandleAxiiHit( parent );
			
			thePlayer.RaiseEvent('Axii_success');
			parent.castingEffect.Success();
			parent.target.OnAxiiHitResult(parent, true);
		
			currentTargets = thePlayer.GetAxiiTargetsNum();
			
			if(currentTargets > parent.maxTargets)
			{
				npcToCalm = thePlayer.GetFirstAxiiTarget();
				npcToCalm.CalmDown();
			}
			
			parent.Fadeout();
		}
		else
		{
			if(thePlayer.IsInCombatState())
			{
				thePlayer.PlayerActionForced(PCA_AxiiFail);
				parent.castingEffect.Failure();
				thePlayer.PlayEffect('Axii_fail');
				parent.target.OnAxiiHitResult(parent, false);
				parent.Fadeout();
			}
		}
		thePlayer.StopEffect(fxName);
		
	}
	
	// --------------------------------------------------------------------
	// effects
	// --------------------------------------------------------------------
	private function GetPlayerFxName( level : int ) : name
	{
		return StringToName( "axii_fx_level1" );
	}
	
	private function GetTargetFxName( level : int ) : name
	{
		return StringToName( "axii_level1" );
	}
};


