/////////////////////////////////////////////////////
// Class for trbuchet exploding balls

enum ETrebuchetBallHit
{
	E_AnimationDmg,
	E_DirectionalDmg,
	E_ScriptedDmg,
};
class CTrebuchetBall extends CEntity
{
	editable var appearance : string;
	editable var rubbleTag: name;
	editable var dmgType: ETrebuchetBallHit;
	editable var scriptedDmg : float;
	editable var forceValue : float;
	var	rubble : CEntity;
	var destructionComponent : CDestructionSystemComponent;
	var rubblePosition : Vector;
	var ballPosition : Vector;
	var forceDirection : Vector;
	var force : Vector;

	event OnAnimEvent( eventName: name, eventTime: float, eventType: EAnimationEventType )
	{
		if( eventName == 'ballHit' )
		{
			rubble = theGame.GetEntityByTag( rubbleTag );
			
			if (dmgType == E_ScriptedDmg)
			{
				destructionComponent = (CDestructionSystemComponent) rubble.GetComponentByClassName( 'CDestructionSystemComponent' );
				destructionComponent.ApplyScriptedDamage( -1, scriptedDmg );
			}
			else 
{
if (dmgType == E_AnimationDmg)
			{
				rubble.ApplyAppearance(appearance);
			}
			else if (dmgType == E_DirectionalDmg)
			{
				rubblePosition = rubble.GetWorldPosition();
				ballPosition = this.GetWorldPosition();
				forceDirection = VecNormalize(rubblePosition - ballPosition);
				force = forceDirection * forceValue;
				
				destructionComponent = (CDestructionSystemComponent) rubble.GetComponentByClassName( 'CDestructionSystemComponent' );
				destructionComponent.ApplyLinearImpulseAtPoint(-1, force, rubblePosition);
		
				
			}
}
		}
	}
}
