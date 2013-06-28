class W2LightsKeeper extends CNewNPC
{
	saved editable var switchLights_On_At		: int;
	saved editable var switchLights_Off_At		: int;
	saved editable var lookForLightsWithTag		: name;
	saved var currentFoundLight					: CSneakLights;
	saved var newFoundLight						: CSneakLights;
	saved var turnLightOn						: bool;
	saved var canIstopWorking					: bool;
	saved var lastPlayedVoiceset				: int;
		
	default switchLights_On_At = 20;
	default switchLights_Off_At = 5;
	default turnLightOn = false;
	default canIstopWorking = false;
	default lastPlayedVoiceset = 0;
	
	// HACK
	public function OnMeditationFinished()
	{
		var current_time	: GameTime;
		var time_hours		: int;
		var lights			: array< CNode >;
		var i				: int;
		var light			: CSneakLights;
		var shouldBeOn		: bool;

		current_time = theGame.GetGameTime();
		time_hours = GameTimeHours( current_time );
		
		if( time_hours >= this.switchLights_Off_At+2 && time_hours < this.switchLights_On_At ) // turn lights off
		{
			shouldBeOn = false;
		}
		else if( time_hours >= switchLights_On_At+2 || time_hours < switchLights_Off_At ) // turn lights on
		{
			shouldBeOn = true;
		}	
		else
		{
			return;
		}
		
		theGame.GetNodesByTag( LightTag(), lights );
		for ( i = 0; i < lights.Size(); i += 1 )
		{
			light = (CSneakLights)lights[i];
			if ( light && light.IsOn() != shouldBeOn )
			{
				if ( shouldBeOn )
				{
					light.PlayEffect( 'fire' );
				}
				else
				{
					light.StopEffect( 'fire' );
				}
				light.light_status = shouldBeOn;
			}
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		// HACK
		if ( FactsQuerySum("spawn_keeper_after_meditation") > 0 )
		{
			OnMeditationFinished();
			FactsAdd("spawn_keeper_after_meditation", -1);
		}
		
		AddTimer( 'KeepTorchInHand',1.f,true, false );
		AddTimer( 'LookForLights',0.5f,true, false );
		AddTimer( 'CheckForWork',1.f,true, false );
		AddTimer( 'MumbleSomething',10.f,true, true );
	}	
	
	event OnRainStarted()
	{
		RemoveTimer( 'KeepTorchInHand' );
		RemoveTimer( 'LookForLights' );
		RemoveTimer( 'CheckForWork' );
		IssueRequiredItems( 'None', 'None' );
		FactsAdd( "flotsam_lightkeeper_raining", 1 );
		ActionCancelAll();
	}
	
	event OnRainEnded()
	{	
		ActionCancelAll();
		FactsRemove( "flotsam_lightkeeper_raining" );
		AddTimer( 'KeepTorchInHand',1.f,true, false );
		AddTimer( 'LookForLights',1.f,true, false );
		AddTimer( 'CheckForWork',1.f,true, false );
		AddTimer( 'MumbleSomething',20.f,true, false );
	}	
		
	timer function KeepTorchInHand( timeDelta : float ) : void
	{
		if( turnLightOn )
		{
			if( !GetInventory().IsItemHeld( this.GetInventory().GetItemId( 'Torch' ) ) )
			{
				IssueRequiredItems( 'None', 'Torch' );
			}
		}			
		else	
		{
			IssueRequiredItems( 'None', 'Lamp Extinguisher' );
		}	
	}
	
	timer function LookForLights( timeDelta : float ) : void
	{
		var current_time		: GameTime;
		var time_hours			: int;

		current_time = theGame.GetGameTime();
		time_hours = GameTimeHours( current_time );

		if( time_hours >= this.switchLights_Off_At && time_hours < this.switchLights_On_At ) // gasze swiatla - jest miedzy 5 rano a 19 wieczor (default)
		{	
			newFoundLight = GetClosestLightSource(  LightTag(), true );
			turnLightOn = false;
		}
		else if( time_hours >= switchLights_On_At || time_hours < switchLights_Off_At ) // zapalam swiatla - jest miedzy 19 wieczor a 5 rano (default)
		{
			newFoundLight = GetClosestLightSource(  LightTag(), false );
			turnLightOn = true;
		}
		
		if( !newFoundLight )
		{
			canIstopWorking = true;
		}		
		else
		{
			if( currentFoundLight != newFoundLight )
			{
				GetArbitrator().AddGoalHandleCityLights();
			}	
		}
		currentFoundLight = newFoundLight;
	}	
	
	timer function CheckForWork( timeDelta : float ) : void
	{
		if( canIstopWorking )
		{
			RemoveTimer( 'LookForLights' );
			RemoveTimer( 'CheckForWork' );
			FactsAdd( "all_lights_handled", 1 );
			ActionCancelAll();
		}	
	}	

	timer function MumbleSomething( timeDelta : float ) : void
	{
		var voiceset 			: int;
		
		voiceset = Rand( 4 );
		
		if( voiceset == 0 )
		{
			PlayVoiceset( 100, "on_axii" );
		}	
		else if( voiceset == 1 )
		{
			PlayVoiceset( 100, "rain" );	
		}	
		else if( voiceset == 2 )	
		{
			PlayVoiceset( 100, "greeting_reply" );	
		}
		else if( voiceset == 3 )
		{
			PlayVoiceset( 100, "interested" );	
		}
	}
	
	private function LightTag()	: name // sprawdza tagi swiatel obslugiwanych
	{
		var light_tag :	name;
		
		if( lookForLightsWithTag == '' || lookForLightsWithTag == 'None' )
		{
			Log( "Nie podano poprawnego taga dla szukanych zrodel swiatla! - wyszukiwanie swiatel na lokacji jest niemozliwe!" );
		}
		else 
		{
			light_tag = lookForLightsWithTag;
		}
		return light_tag;
	}

	private function GetClosestLightSource( tag : name, lit : bool ) : CSneakLights //sprawdza, ktore zrodlo swiatla (wlaczane lub wylaczone) jest najblizsze
	{
		var light 				: CSneakLights;
		var x_light 			: CSneakLights;
		var chosen_light		: CSneakLights;
		var light_array			: array< CNode >;
		var x_light_array		: array< CSneakLights >;
		var i, size				: int;
		var x, num				: int;
		var dist_to				: float;
		var light_pos			: Vector;
		var keeper_pos			: Vector;
		var dist_array 			: array< float >;
		var min_dist			: int;
		
		keeper_pos = GetWorldPosition();
		theGame.GetNodesByTag( tag , light_array );
		size = light_array.Size();
		
		for( i=0; i<size; i+=1 )
		{
			light = (CSneakLights)light_array[i];
			if( lit )
			{
				if( light.light_status )
				{
					x_light_array.PushBack( light );
				}	
			}
			else 
			{
				if( !light.light_status )
				{
					x_light_array.PushBack( light );
				}
			}
		}	
		num = x_light_array.Size();
		
		for( x=0; x<num; x+=1 )
		{
			light_pos = x_light_array[x].GetWorldPosition();
			dist_to = VecDistance( light_pos, keeper_pos );
			dist_array.PushBack( dist_to );
		}
		min_dist = ArrayFindMinF( dist_array );
		chosen_light = (CSneakLights)x_light_array[ min_dist ];
				
		return chosen_light;			
	}
}	

state WorkingWithLights in W2LightsKeeper extends Base
{
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}

	event OnEnterState()
	{
		if( parent.turnLightOn )
		{
			parent.IssueRequiredItems( 'None', 'Torch' );
		}			
		else	
		{
			parent.IssueRequiredItems( 'None', 'Lamp Extinguisher' );
		}
	}	
	
	event OnLeaveState()
	{
	}
	
	entry function StartWorking( goalId : int )
	{
		var light : CSneakLights;
		var waypoint : CNode;
		
		light = parent.newFoundLight;
		waypoint = light.GetGoToNode();
		parent.ActionCancelAll();
		parent.ActionRotateToAsync( light.GetWorldPosition() );
		parent.ActionMoveToNodeWithHeading( waypoint, MT_Walk, 1, 0.1f );
		Sleep( 0.5f );
		parent.RaiseEvent('HandleCityLights'); // odpalenie eventu animacji odpalania pochodni
		parent.WaitForBehaviorNodeDeactivation('HandlingEnd'); // czekanie az event sie skonczy
		
		if( !parent.turnLightOn )	
		{
			if( light.light_status )
			{
				light.StopEffect( 'fire' );
				light.light_status = false;
			}
		}	
		else
		{
			if( !light.light_status )
			{
				light.PlayEffect( 'fire' );
				light.light_status = true;
			}
		}
		Sleep( 0.5f );
	}
}