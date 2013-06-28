// Klasa obiektów typu oœwietlenie lokacji - pochodnie, okna domostw itp.

class CLocationLights extends CInteractiveEntity
{
	editable var SwitchOnHour : int;
	editable var SwitchOffHour : int;
	editable var MaxSwitchDelaySeconds : float;
	editable var IsOnAtGameStart : bool;
	editable var AutoSwitch : bool;
	saved var LightWillBeOn : bool;
	editable var IsAffectedByRain : bool;
	var is_raining : bool;
	saved var light_status : bool;
	
	default SwitchOnHour = 20;
	default SwitchOffHour = 5;
	default MaxSwitchDelaySeconds = 5;
	default IsOnAtGameStart = true;
	default AutoSwitch = false;
	default IsAffectedByRain = false;
	
	event OnRainStarted()
	{
		if( IsAffectedByRain )
		{
			is_raining = true;
			this.StopEffect( 'fire' );
			light_status = false;
			//Log( "=================== IS RAINING ================ is_raining = " +is_raining );
		}	
	}
	
	event OnRainEnded()
	{
		if( IsAffectedByRain )
		{
			is_raining = false;
			//Log( "================= STOPPED RAINING ============== is_raining = " +is_raining );
		}	
	}	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( light_status )
		{
			this.PlayEffect( 'fire' );
		} else
		{
			this.StopEffect( 'fire' );
		}
		if ( ! spawnData.restored )
		{	
			if( IsOnAtGameStart == true )
			{ 
				this.PlayEffect( 'fire' );
				light_status = true;
			}
			else 
			{
				this.StopEffect( 'fire' );
				light_status = false;
			}
		}	
		if ( AutoSwitch == true )
		{
			AddTimer( 'WhenToSwitch', 10.0f, true, false );		
		}
	}

	timer function WhenToSwitch( TimeDelta : float)
	{	
		var current_time : int;
		var game_time : GameTime;
	
		game_time = GameTimeCreate();
		current_time = GameTimeHours( game_time );
		//Log("================== TIMER ==================== is_raining = " +is_raining );
		
		if( is_raining )
		{
			TurnLightOff();
		}
	
		if( light_status )
		{
			if( current_time >= SwitchOffHour )
			{
				if( current_time < SwitchOnHour )
				{
					TurnLightsOff();
				}
			}	
		}
		else
		{
			if( current_time >= SwitchOnHour || current_time < SwitchOffHour )
			{
				if( !is_raining )
				{
					TurnLightsOn();
				}	
			}	
		}
	}
	
	function AutoSwitchOff()
	{
		AutoSwitch = true;
		RemoveTimer( 'WhenToSwitch' );
	}
	
	function AutoSwitchOn()
	{
		AutoSwitch = false;
		AddTimer( 'WhenToSwitch', 10.0f, true );	 
	}	
	
	function Activate()
	{
		if(thePlayer.IsNotGeralt())
		{
			return;
		}
		if( light_status )
		{
			TurnLightOff();
		}
		else
		{
			TurnLightOn();
		}
	}
}	

state Switching in CLocationLights
{
	entry function TurnLightsOff()
	{		
		var delay : float;
		
		parent.light_status = false;
		
		delay = RandRangeF( 0.f, parent.MaxSwitchDelaySeconds );
		Sleep( delay );
		parent.StopEffect( 'fire' );
		parent.light_status = false;
	}
	
	entry function TurnLightsOn()
	{
		var delay : float;
		
		parent.light_status = true;
	
		delay = RandRangeF( 0.f, parent.MaxSwitchDelaySeconds );
		Sleep ( delay );
		parent.PlayEffect( 'fire' );
		parent.light_status = true;
	}

	entry function TurnLightOn()
	{
		var res : bool;
		
		parent.EnableInteraction( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('igni_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( false );
		parent.PlayEffect('sneak_igni');
		parent.PlayEffect( 'fire' );
		parent.EnableInteraction( true );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}

		
		parent.light_status = true;
		parent.LightWillBeOn = false;
	
		Sleep( 0.5f );
	}
	
	entry function TurnLightOff()
	{
		var res : bool;
		
		parent.EnableInteraction( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('aard_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( true );
		parent.PlayEffect('sneak_aard');
		parent.StopEffect( 'fire' );
		parent.EnableInteraction( true );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}
		
		parent.light_status = false;			
		
		Sleep( 0.5f );
	}
	
}

class CSneakLights extends CLocationLights
{
	//editable saved var LightIsOn : bool;
	editable var SneakLightsArea_Tag 	: CName;
	private var setupDone 				: bool;
	private var m_goToNode				: CNode;
	
	//public var LightWillBeOn : bool;
	
	//default LightIsOn = true;
	default LightWillBeOn = false;
	
	function IsOn() : bool
	{
		return light_status;
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Setup();
		
		if( light_status )
		{
//		FactsAdd(this.SneakLightsArea_Tag + "_torch_off", -1);
		}
		
		else
		{
	//	FactsAdd(this.SneakLightsArea_Tag + "_torch_off", 1);
		}
		
		m_goToNode = FindGoToNode();
		super.OnSpawned( spawnData );
	}
	

	function Setup()
	{
		if( !setupDone )
		{
			setupDone = true;
			//if( LightIsOn )
			//{
			//	this.PlayEffect( 'fire' );
			//}
		}	
	}
	
	
	function Activate()
	{
		if(thePlayer.IsNotGeralt())
		{
			return;
		}
		if( light_status )
		{
			TurnLightOff();
		}
		else
		{
			TurnLightOn();
		}
	}
	
	function SwitchLightState(enable:bool)
	{
		if( enable )
		{
			PlayEffect( 'fire' );
			light_status = false;
			LightWillBeOn = true;
			
		}
		else
		{
			StopEffect( 'fire' );
			light_status = true;
			LightWillBeOn = false;
		}
	}
	
	function GetLightArea() : CSneakLightsArea
	{
		var node : CNode = theGame.GetNodeByTag( SneakLightsArea_Tag );
		return (CSneakLightsArea)node;
	}
	
	function GetGoToNode() : CNode
	{
		return m_goToNode;
	}
	
	private function FindGoToNode() : CNode
	{
		var comps : array< CComponent >;
		var i, count : int;
		var nodeName : string;
		
		comps = GetComponentsByClassName('CWayPointComponent');
		count = comps.Size();
		for ( i = 0; i < count; i += 1 )
		{
			nodeName = comps[i].GetName();
			if ( nodeName == "GoToWaypoint" )
			{
				return comps[i];
			}
		}
		return (CNode)NULL;
	}
	
}	

state SwitchingLights in CSneakLights
{	
	entry function TurnLightOn()
	{
		var res : bool;

		
		parent.EnableInteraction( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('igni_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		parent.EnableInteraction( true );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( false );
		parent.PlayEffect('sneak_igni');
		parent.PlayEffect( 'fire' );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}

		
		parent.light_status = true;
		parent.LightWillBeOn = false;
		parent.GetLightArea().TurnOn();
	
		Sleep( 0.5f );
		FactsAdd(parent.SneakLightsArea_Tag + "_torch_off", -10);
	}
	
	
	
	entry function TurnLightOff()
	{
		var res : bool;
		
		parent.EnableInteraction( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('aard_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		parent.EnableInteraction( true );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( true );
		parent.PlayEffect('sneak_aard');
		parent.StopEffect( 'fire' );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}
		
		parent.light_status = false;			
		parent.GetLightArea().TurnOff();
		
		Sleep( 0.5f );
		FactsAdd(parent.SneakLightsArea_Tag + "_torch_off", 10);
	}
	
	entry function GuardTurnLightOn()
	{
		parent.EnableInteraction( false );
		
		parent.PlayEffect( 'fire' );
		
		parent.light_status = true;
		parent.LightWillBeOn = false;			
		parent.GetLightArea().TurnOn();
		
		Sleep( 2.f );
		parent.EnableInteraction( true );
	}
	
}

class CSneakLightsArea extends CGameplayEntity
{
	editable saved var LightAreaIsOn : bool;
		
	default LightAreaIsOn = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( LightAreaIsOn )
		{
			TurnOn();
		}
	}
	
	function GetAreaComponent() : CAreaComponent
	{
		var area : CAreaComponent;
		area = (CAreaComponent)GetComponentByClassName( 'CAreaComponent') ;
		return area;
	}
	
	event OnDestroyed()
	{		
		theGame.UnregisterStaticAILight( GetAreaComponent() );
	}
	
	function TurnOn()
	{		
		theGame.RegisterStaticAILight( GetAreaComponent() );
		LightAreaIsOn = true;
	}
	
	function TurnOff()
	{		
		theGame.UnregisterStaticAILight( GetAreaComponent() );
		LightAreaIsOn = false;
	}
	
	final function GetTriggerArea() : CTriggerAreaComponent
	{
		return (CTriggerAreaComponent)GetComponentByClassName( 'CTriggerAreaComponent' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if (activator.GetEntity().HasTag('PLAYER') && thePlayer.GetCurrentStateName() == 'Sneak' )
		{
			thePlayer.SetIsInShadow( ! LightAreaIsOn );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if (activator.GetEntity().HasTag('PLAYER') && thePlayer.GetCurrentStateName() == 'Sneak' )
		{
			thePlayer.SetIsInShadow( true );
		}
	}
}

///////////////////////////////////// quest torch /////////////////////////////////////////

class CQuestLights extends CGameplayEntity
{
	editable saved var LightIsOn : bool;
	private var setupDone : bool;	
	editable var lightsTag : name;	
	editable var lightsAr : array<CNode>;
	editable var lightId : string;
	

	
	
	public var LightWillBeOn : bool;
	default LightIsOn = true;
	default LightWillBeOn = false;
	var Interakcja : CComponent; 
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Setup();

			if( LightIsOn )
			{
				// FactsAdd( this.lightId + "_toggle", 1);
			}
			else
			{
				// FactsAdd( this.lightId + "_toggle", -1);
			}
		
	}
	
/*
	event OnInteraction( actionName : name, activator : CEntity )
	{
		QuestToggle();
	}
	*/
	
	
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
		if ( activator == thePlayer && !thePlayer.IsNotGeralt() )
		{	

			ActivateBraz();
			QuestToggle();

		}
	}

	function Setup()
	{
		if( !setupDone )
		{
			setupDone = true;
			if( LightIsOn )
			{
				this.PlayEffect( 'fire' );
			}
		}	
	}
	
	
	
	function ActivateBraz()
	{
		if( LightIsOn )
		{
			this.TurnLightOff();
			FactsAdd( this.lightId + "_toggle", -1);
		}
		else
		{
			this.TurnLightOn();
			FactsAdd( this.lightId + "_toggle", 1);
		}
	}
	
	function Background_Activate()
	{
		if( LightIsOn )
		{
			this.B_TurnLightOff();
			FactsAdd( this.lightId + "_toggle", -1);
		}
		else
		{
			this.B_TurnLightOn();
			FactsAdd( this.lightId + "_toggle", 1);
		}
	}
	
	function QuestToggle()
	{
		var BrazTag : name;
		var Braz : CNode;
		var BrazAr : array<CNode>;
		var BT_1_tag : name;
		var BT_2_tag : name;
		var BT_3_tag : name;
		var BT_4_tag : name;
		var BT_5_tag : name;
		var BT_6_tag : name;
		var BT_7_tag : name;
		var BT_1 : CQuestLights;
		var BT_2 : CQuestLights;
		var BT_3 : CQuestLights;
		var BT_4 : CQuestLights;
		var BT_5 : CQuestLights;
		var BT_6 : CQuestLights;
		var BT_7 : CQuestLights;

		
		
		BT_1_tag = 'braz_1';
		BT_2_tag = 'braz_2';
		BT_3_tag = 'braz_3';
		BT_4_tag = 'braz_4';
		BT_5_tag = 'braz_5';
		BT_6_tag = 'braz_6';
		BT_7_tag = 'braz_7';
		


		BrazTag = 'sq208_brazzier'; 
		Braz = theGame.GetNodeByTag(BrazTag);
		BT_1 = (CQuestLights)(theGame.GetNodeByTag(BT_1_tag));
		BT_2 = (CQuestLights)(theGame.GetNodeByTag(BT_2_tag));
		BT_3 = (CQuestLights)(theGame.GetNodeByTag(BT_3_tag));
		BT_4 = (CQuestLights)(theGame.GetNodeByTag(BT_4_tag));
		BT_5 = (CQuestLights)(theGame.GetNodeByTag(BT_5_tag));
		BT_6 = (CQuestLights)(theGame.GetNodeByTag(BT_6_tag));
		BT_7 = (CQuestLights)(theGame.GetNodeByTag(BT_7_tag));

		theGame.GetNodesByTag(BrazTag, BrazAr);
		
	
		if( this.lightId == "braz_1")
		{
			BT_3.Background_Activate();
			BT_6.Background_Activate();
		}
		
		else if( this.lightId == "braz_2")
		{
			BT_1.Background_Activate();
			BT_4.Background_Activate();
		}
		
		else if( this.lightId == "braz_3")
		{
			BT_2.Background_Activate();
			BT_6.Background_Activate();
		}
		
		else if( this.lightId == "braz_4")
		{
			BT_5.Background_Activate();
			BT_7.Background_Activate();
		}
		
		else if( this.lightId == "braz_5")
		{
			BT_3.Background_Activate();
			BT_6.Background_Activate();
		}
		
		else if( this.lightId == "braz_6")
		{
			BT_4.Background_Activate();
			BT_7.Background_Activate();
		}
		
		else if( this.lightId == "braz_7")
		{
			BT_1.Background_Activate();
			BT_2.Background_Activate();
		}

		
		
	}

	
}	

state SwitchingLights in CQuestLights
{	
	entry function TurnLightOn()
	{
		var res : bool;
//		parent.Interakcja = parent.GetComponent("LightSwitch");
//		parent.Interakcja.SetEnabled( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('igni_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( false );
		parent.PlayEffect('sneak_igni');
		parent.PlayEffect( 'fire' );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}
		parent.LightIsOn = true;
		parent.LightWillBeOn = false;
		
	//	parent.Interakcja.SetEnabled( true );
		Sleep( 0.5f );
		
	}
	
	entry function TurnLightOff()
	{
		var res : bool;
	//	parent.Interakcja = parent.GetComponent("LightSwitch");
	//	parent.Interakcja.SetEnabled( false );
		
		thePlayer.AttachBehavior('Stealth');
		res = thePlayer.RaiseForceEvent('torch_extinguish');
		thePlayer.PlayEffect('aard_sneak');
		thePlayer.RotateTo( parent.GetWorldPosition(), 0.1 );
		Sleep( 0.5f );
		if ( thePlayer.GetCurrentStateName() == 'Sneak' )
			thePlayer.SetIsInShadow( true );
		parent.PlayEffect('sneak_aard');
		parent.StopEffect( 'fire' );
		if( res )
		{
			thePlayer.WaitForBehaviorNodeDeactivation('ExtinguishEnd');
		}
		parent.LightIsOn = false;	
		parent.LightWillBeOn = true;		
	//	parent.Interakcja.SetEnabled( true );
		Sleep( 0.5f );

	}
	
	entry function B_TurnLightOn()
	{
		var res : bool;
	//	parent.Interakcja = parent.GetComponent("LightSwitch");
	//	parent.Interakcja.SetEnabled( false );
		parent.PlayEffect('sneak_igni');
		parent.PlayEffect( 'fire' );
		parent.LightIsOn = true;
		parent.LightWillBeOn = false;
		Sleep( 0.5f );
	//	parent.Interakcja.SetEnabled( true );
	}
	
	entry function B_TurnLightOff()
	{
		var res : bool;
	//	parent.Interakcja = parent.GetComponent("LightSwitch");
	//	parent.Interakcja.SetEnabled( false );
		parent.PlayEffect('sneak_aard');
		parent.StopEffect( 'fire' );
		parent.LightIsOn = false;			
		Sleep( 0.5f );
	//	parent.Interakcja.SetEnabled( true );
	}
	

	

}
/*
quest function QActivateBraz(shouldBeEnabled : bool, objectTag : name)

	{
	var single_entity : CNode;
	
	single_entity = theGame.GetNodeByTag( objectTag );
		
	if(shouldBeEnabled)
			{
			((CQuestLights)single_entity).B_TurnLightOn();
			}
		else
			{
			((CQuestLights)single_entity).B_TurnLightOff();
			}
			
	}
*/