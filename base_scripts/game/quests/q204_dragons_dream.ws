//////////////////////////////////////////////////////////////////////////////////////////////////////////
// quest functions for q204_dragons_dream
//////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////
// MT - funkcje wlaczajace radial blura

quest function q204_radialBlurSetup( radialBlurTargetTag : name, radialBlurInitialValue : float )
{
	var radialBlurTarget : CNode;
	
	radialBlurTarget = theGame.GetNodeByTag( radialBlurTargetTag );
	
	thePlayer.activateRadialBlur( radialBlurTarget, radialBlurInitialValue);
}

quest function q204_radialBlurDisable()
{
	thePlayer.AddTimer( 'RadialBlurFade', 0.1f, true );
}

quest function q204_dragon_roar()
{
	theGame.GetEntityByTag( 'q204_dragon' ).RaiseForceEvent( 'fire_attack' );
}

quest function q204_dragon_claw()
{
	theGame.GetEntityByTag( 'q204_dragon' ).RaiseForceEvent( 'claw_attack' );
}