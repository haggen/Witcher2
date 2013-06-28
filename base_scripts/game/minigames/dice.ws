/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Minigame Dice
/** Copyright © 2009 CD Projekt RED
/***********************************************************************/

class CMinigameDice
{
	var m_physics       : CPhysicsSystemComponent;
	var m_effectEntity  : CEntity;
	
	var m_index         : int;
	var m_rigidBodyIdx  : int;
	var m_component     : CDrawableComponent;
	
	var m_collectVector : Vector;
	var m_latentPosition : Vector;
	var m_positionIdx	: int;
	var	m_isDisabled	: bool; // Disabled dice is when it falls of the table
	var	m_isSelected : bool;

	default m_positionIdx = 0;
	default m_isDisabled = false;
	default m_isSelected = false;
	
	final function IsSelected() : bool { return m_isSelected; }
	
	final function Reset()
	{
		m_isDisabled = false;
		m_isSelected = false;
	}
	
	final function Disable()
	{
		m_isDisabled = true;
	}
	
	final function IsDisabled() : bool
	{
		return m_isDisabled;
	}
	
	final function SetHighlight( highlight : bool )
	{
		if( highlight )
		{
			m_effectEntity.PlayEffect( 'dices_fx', m_component );
		}
		else
		{
			m_effectEntity.StopEffect( 'dices_fx' );
		}
	}
	
	final function Select( select : bool, indicate : bool )
	{
		var entity : CGameplayEntity;
		
		m_isSelected = select;
		
		if(  m_isSelected && indicate )
		{
			m_effectEntity.PlayEffect( 'selection_fx', m_component );
			
			// TODO: it probably should be inserted into fx itself
			theSound.PlaySound( "global/global_dice_game/code_dice_select" );
		}
		else
		{
			if( indicate )
			{
				// TODO: it probably should be inserted into fx itself
				theSound.PlaySound( "global/global_dice_game/code_dice_select" );
			}

			m_effectEntity.StopEffect( 'selection_fx' );
		}
	}
	
	final function GetResult() : int
	{
		var EX, EY, EZ   : Vector;
		
		if( m_isDisabled )
		{
			return 0;
		}
		
		/*
		// DEBUG SHIT
		if( m_rigidBodyIdx == 0 )
		{
			return 6;
		}
		else if( m_rigidBodyIdx == 1 )
		{
			return 6;
		}
		else if( m_rigidBodyIdx == 2 )
		{
			return 6;
		}
		else if( m_rigidBodyIdx == 3 )
		{
			return 2;
		}
		else if( m_rigidBodyIdx == 4 )
		{
			return 2;
		}
		else if( m_rigidBodyIdx == 5 )
		{
			return 3;
		}
		else if( m_rigidBodyIdx == 6 )
		{
			return 3;
		}
		else if( m_rigidBodyIdx == 7 )
		{
			return 3;
		}
		else if( m_rigidBodyIdx == 8 )
		{
			return 3;
		}
		else if( m_rigidBodyIdx == 9 )
		{
			return 4;
		}*/

		RotAxes( m_component.GetWorldRotation(), EY, EX, EZ );
		
		// EX = 4, -EX = 3, EY = 5, -EY = 2, EZ = 1, -EZ = 6
		if ( AbsF( EX.Z ) > AbsF( EY.Z ) )
		{
			if ( AbsF( EX.Z ) > AbsF( EZ.Z ) )
			{
				if ( EX.Z > 0.f ) return 4;
				else              return 3;
			}
			else
			{
				if ( EZ.Z > 0.f ) return 1;
				else              return 6;
			}
		}
		else // EY.Z > EX.Z
		{
			if ( AbsF( EY.Z ) > AbsF( EZ.Z ) )
			{
				if ( EY.Z > 0.f ) return 5;
				else              return 2;
			}
			else
			{
				if ( EZ.Z > 0.f ) return 1;
				else              return 6;
			}
		}
	}
	
	final function RotationForResult( result : int ) : EulerAngles
	{
		switch( result )
		{
		case 1:
			return EulerAngles( 0.0f, 0.0f, 0.0f );
		case 2:
			return EulerAngles( 270.0f, 0.0f, 90.0f );
		case 3:
			return EulerAngles( 0.0f, 90.0f, 90.0f );
		case 4:
			return EulerAngles( 0.0f, 270.0f, 270.0f );
		case 5:
			return EulerAngles( 90.0f, 270.0f, 0.0f );
		case 6:
			return EulerAngles( 180.0f, 90.0f, 0.0f );
		}
	}

	final function Collect( collectPoint : Vector )
	{
		var rotation	: EulerAngles;
		
		DisablePhysics();
		
		rotation.Pitch = Rand( 360 ) - 180;
		rotation.Yaw   = Rand( 360 ) - 180;
		rotation.Roll  = Rand( 360 ) - 180;
		
		m_collectVector   = RotRight( rotation ) * ( 0.1f * ( m_index / 2 ) )
                 + RotUp( rotation )    * ( 0.1f * ( m_index % 2 ) );
		
		m_physics.TeleportRigidBody ( m_rigidBodyIdx, collectPoint + m_collectVector, rotation );
	}
	
	final function Throw( throwingPoint : Vector, strength : float )
	{
		var vector		: Vector;
		
		EnablePhysics();
		
		vector = throwingPoint - m_component.GetWorldPosition();
		m_physics.ApplyLinearImpulse( m_rigidBodyIdx, VecNormalize( vector ) * strength );
	}

	final function ResetPosition()
	{
		var result : int;

		// Save current result
		result = GetResult();

		// Reset transform
		m_physics.ResetTransform( m_rigidBodyIdx );
			
		// Set rotation according to result
		m_physics.TeleportRigidBody( m_rigidBodyIdx, m_component.GetWorldPosition(), RotationForResult( result ) );
		
		// LogChannel( 'Minigame', "Dice " + m_rigidBodyIdx + ": " + result );
	}
	
	final function EnablePhysics()
	{
		m_physics.SetBodyAsDynamic( m_rigidBodyIdx );
	}

	final function DisablePhysics()
	{
		m_physics.SetBodyAsStatic( m_rigidBodyIdx );
	}
	
	final function SetPositionRelative( position : Vector, clampBox : Box )
	{
		var targetPosition : Vector;
		
		targetPosition = m_component.GetWorldPosition() + position;
		targetPosition.X = ClampF( targetPosition.X, clampBox.Min.X, clampBox.Max.X );
		targetPosition.Y = ClampF( targetPosition.Y, clampBox.Min.Y, clampBox.Max.Y );
		
		m_physics.TeleportRigidBody ( m_rigidBodyIdx, targetPosition, m_component.GetWorldRotation() );
	}
	
	final function Teleport( position : Vector )
	{
		m_physics.TeleportRigidBody( m_rigidBodyIdx, position, m_component.GetWorldRotation() );
	}
}
