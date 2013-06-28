
/////////////////////////////////////////////
// Behavior combo attack
/////////////////////////////////////////////

import struct SBehaviorComboAttack
{
	import public var level, type : int;
	import public var attackTime, parryTime : float;
	import public var attackAnimation, parryAnimation : name;
	
	import public var attackHitTime, parryHitTime : float;
	import public var attackHitLevel, parryHitLevel : float;
	
	import public var direction : EAttackDirection;
	import public var distance : EAttackDistance;
	
	import public var attackHitTime1, parryHitTime1 : float;
	import public var attackHitLevel1, parryHitLevel1 : float;
	
	import public var attackHitTime2, parryHitTime2 : float;
	import public var attackHitLevel2, parryHitLevel2 : float;
	
	import public var attackHitTime3, parryHitTime3 : float;
	import public var attackHitLevel3, parryHitLevel3 : float;
};

enum EComboAttackResponse
{
	CAR_HitFront,
	CAR_HitBack,
	CAR_ParryFront,
	CAR_ParryBack,
};

////////////////////////////////////////////////////////////////////

import struct SBehaviorScriptContext
{
	import public var poseLS 			: array< EngineQsTransform >;
	import public var poseMS 			: array< EngineQsTransform >;
	import public var floatTracks 		: array< float >;
	
	import public var inputParamsF 		: array< float >;
	import public var inputParamsV 		: array< Vector >;
	
	import public var localParamsF 		: array< float >;
	import public var localParamsV 		: array< Vector >;
	import public var localParamsM 		: array< Matrix >;
	import public var localParamsT 		: array< EngineQsTransform >;

	import public var timeDelta 		: float;
	//import public var visualDebug		: CVisualDebug;
};

////////////////////////////////////////////////////////////////////

import class IBehaviorScript extends CObject 
{
	import function DrawSphere( scriptContext : SBehaviorScriptContext, center : Vector, radius : float, optional color : Color );
	import function DrawLine( scriptContext : SBehaviorScriptContext, start : Vector, end : Vector, optional color : Color );
	import function DrawBoxRadius( scriptContext : SBehaviorScriptContext, center : Vector, radius : float, optional color : Color );
	import function DrawBox( scriptContext : SBehaviorScriptContext, position : Vector, x : float, y : float, z : float, optional color : Color );
	
	// Tomsin TODO
	//...
};

class CBehaviorScriptText extends IBehaviorScript
{
	function Run( context : SBehaviorScriptContext )
	{
		if ( context.inputParamsF.Size() > 0 )
		{
			Log("BH: " + context.inputParamsF[ 0 ] );
		}
		else
		{
			Log("Behavior script");
		}
	}
};

class CBehaviorScriptTranslate extends IBehaviorScript
{
	editable public var boneIndex : int;
	editable public var boneParentIndex : int;

	function Run( context : SBehaviorScriptContext )
	{
		var trans : EngineQsTransform;
		
		if ( boneIndex != -1 && boneParentIndex != -1 && context.poseLS.Size() > boneIndex && context.inputParamsV.Size() > 0 )
		{
			trans = t_SetIdentity();
			t_Trans( trans, context.inputParamsV[ 0 ] );
			t_RotQuat( trans, t_GetRotQuat( context.poseMS[ boneIndex ] ) );
			
			context.poseLS[ boneIndex ] = t_SetMulInvMul( context.poseMS[ boneParentIndex ], trans );
		}
	}
};

class CBehaviorScriptTranslateCircle extends IBehaviorScript
{
	editable public var boneIndex : int;
	editable public var speed : float;

	function Run( context : SBehaviorScriptContext )
	{
		var trans : EngineQsTransform;
		var angle : float;
		
		if ( context.localParamsF.Size() == 0 )
		{
			context.localParamsF.Resize( 1 ); 
		}
		
		if ( context.localParamsF.Size() > 0 )
		{
			context.localParamsF[ 0 ] += speed * context.timeDelta;
			if ( context.localParamsF[ 0 ] > 360.f )
			{
				context.localParamsF[ 0 ] -= 360.f;
			}
			
			trans = t_BuiltRotAngles( context.localParamsF[ 0 ], 0, 0 );
			
			context.poseLS[ boneIndex ] = t_SetMul( context.poseLS[ boneIndex ], trans );
		}
	}
};

class CBehaviorScriptTest extends IBehaviorScript
{
	editable public var boneA : int;
	editable public var boneB : int;
	editable public var weight : float;

	function Run( context : SBehaviorScriptContext )
	{
		var quat : Vector;
		var dirToParent1, dirToParent2, posA, posB1, newPos : Vector;
		
		if ( context.localParamsV.Size() == 0 )
		{
			context.localParamsV.Resize( 1 );
			
			context.localParamsV[ 0 ] = Vector(0,0,0);
		}
		
		posA = t_GetTrans( context.poseMS[ boneA ] );
		posB1 = context.localParamsV[ 0 ];
		
		dirToParent1 = posB1 - posA;
		dirToParent2 = t_GetTrans( context.poseLS[ boneB ] );
		
		// MS -> LS
		dirToParent1 = v_SetTransformedPos( t_SetInv( context.poseMS[ boneA ] ), dirToParent1 );
		
		dirToParent1 = VecNormalize( dirToParent1 );
		dirToParent2 = VecNormalize( dirToParent2 );
		
		quat = q_SetShortestRotationDamped( dirToParent2, dirToParent1, 1.f - context.timeDelta * weight );
		quat = q_SetMul( t_GetRotQuat( context.poseLS[ boneB ] ), quat );
		
		t_RotQuat( context.poseLS[ boneB ], quat );
		
		// Save old
		context.localParamsV[ 0 ] = t_GetTrans( t_SetMul( context.poseMS[ boneA ], context.poseLS[ boneB ] ) );
		
		DrawSphere( context, context.localParamsV[ 0 ], 0.1 );
	}
};






