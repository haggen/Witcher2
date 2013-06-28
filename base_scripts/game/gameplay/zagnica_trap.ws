////////////////////////////////////////////////////
//												  //
// funkcje brixowe do obslugi pulapki na zagnice  //
//												  //	
////////////////////////////////////////////////////
/*
function SetTentadrakeTrapDummy( zagnica : CEntity, trap_dummy : CEntityTemplate )
{
	var player : Vector; 
	var wpp1 : Vector;
	var wpp2 : Vector;
	var wpr1 : EulerAngles;
	var wpr2 : EulerAngles;
	var macka1 : CComponent;
	var macka2 : CComponent;
			
	macka1 = (CComponent)zagnica.GetComponent( "trap_dummy_2" );
	macka2 = (CComponent)zagnica.GetComponent( "trap_dummy_5" );
		
	if ( thePlayer.GetInventory().HasItem( 'Tentadrake Trap' ) == true )
	{
		player = thePlayer.GetWorldPosition();
		wpp1 = macka1.GetWorldPosition();
		wpr1 = macka1.GetWorldRotation();
		wpp2 = macka2.GetWorldPosition();
		wpr2 = macka2.GetWorldRotation();
		
		theGame.CreateEntity( trap_dummy, wpp1, wpr1 );
		theGame.CreateEntity( trap_dummy, wpp2, wpr2 );
	}
}

brix function SettingTentadrakeTrapDummy( trap_dummy : CEntityTemplate )
{
	var wpp1 : Vector;
	var wpp2 : Vector;
	var wpr1 : EulerAngles;
	var wpr2 : EulerAngles;
	var macka1 : CComponent;
	var macka2 : CComponent;
	var dummy1 : CEntity;
	var dummy2 : CEntity;
	var zagnica : CEntity;
	
	zagnica = (CEntity)theGame.GetNodeByTag( 'zagnica' );
	//Log ("Znalaz³em ¿agnicê, to obiekt: " +zagnica );
			
	macka1 = (CComponent) zagnica.GetComponent( 'trap_spwn_1' );
	macka2 = (CComponent) zagnica.GetComponent( 'trap_spwn_2' );
	
	if ( thePlayer.GetInventory().HasItem( 'Tentadrake Trap' ) == true )
	{
		wpp1 = macka1.GetWorldPosition();
		wpr1 = macka1.GetWorldRotation();
		wpp2 = macka2.GetWorldPosition();
		wpr2 = macka2.GetWorldRotation();
		Log( "Geralt ma pu³apkê");
		//Log( "Wspó³rzedne punktów to: " +wpp1 +wpr1 +"i " +wpp2 +wpr2);
		dummy1 = theGame.CreateEntity( trap_dummy, wpp1, wpr1 );
		dummy2 = theGame.CreateEntity( trap_dummy, wpp2, wpr2 );
		Log( "Spawnuje obiekty " +dummy1 +" i " + dummy2);
	}
	else 
	{
		Log ( "Nie masz pu³apki!");
	}
}
*/	