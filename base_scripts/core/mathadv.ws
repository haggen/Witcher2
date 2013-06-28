
// This file is not for designers

//////////////////////////////////////////////
// Engine Qs Transform functions			//
//////////////////////////////////////////////

import function t_Identity( /*inout*/ a : EngineQsTransform );
import function t_SetIdentity() : EngineQsTransform;

import function t_BuiltTrans( move : Vector ) : EngineQsTransform;
import function t_BuiltRotQuat( quat : Vector ) : EngineQsTransform;
import function t_BuiltRotAngles( x : float, y : float, z : float ) : EngineQsTransform;
import function t_BuiltScale( scale : Vector ) : EngineQsTransform;

import function t_Trans( /*inout*/ a : EngineQsTransform, move : Vector );
import function t_RotQuat( /*inout*/ a : EngineQsTransform, quat : Vector );
import function t_Scale( /*inout*/ a : EngineQsTransform, scale : Vector );

import function t_SetTrans( a : EngineQsTransform, move : Vector ) : EngineQsTransform;
import function t_SetRotQuat( a : EngineQsTransform, quat : Vector ) : EngineQsTransform;
import function t_SetScale( a : EngineQsTransform, scale : Vector ) : EngineQsTransform;

import function t_GetTrans( a : EngineQsTransform ) : Vector;
import function t_GetRotQuat( a : EngineQsTransform ) : Vector;
import function t_GetScale( a : EngineQsTransform ) : Vector;

import function t_SetMul( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;
import function t_SetMulMulInv( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;
import function t_SetMulInvMul( a : EngineQsTransform, b : EngineQsTransform ) : EngineQsTransform;

import function t_SetInterpolate( a : EngineQsTransform, b: EngineQsTransform, w : float ) : EngineQsTransform;
import function t_IsEqual( a : EngineQsTransform, b : EngineQsTransform ) : bool;

import function t_Inv( /*inout*/ a : EngineQsTransform );
import function t_SetInv( a : EngineQsTransform ) : EngineQsTransform;

import function t_NormalizeQuat( /*inout*/ a : EngineQsTransform );
import function t_BlendNormalize( /*inout*/ a : EngineQsTransform, w : float );
import function t_IsOk( a : EngineQsTransform ) : bool;


//////////////////////////////////////////////
// Quaternion functions						//
//////////////////////////////////////////////

import function q_SetIdentity() : Vector;
import function q_Identity( /*inout*/ a : Vector );

import function q_SetInv( a : Vector ) : Vector;
import function q_Inv( /*inout*/ a : Vector );

import function q_SetNormalize( a : Vector ) : Vector;
import function q_Normalize( /*inout*/ a : Vector );

import function q_SetMul( a : Vector, b : Vector ) : Vector;
import function q_SetMulMulInv( a : Vector, b : Vector ) : Vector;
import function q_SetMulInvMul( a : Vector, b : Vector ) : Vector;

import function q_SetShortestRotation( from : Vector, to : Vector ) : Vector;
import function q_SetShortestRotationDamped( from : Vector, to : Vector, w : float ) : Vector;

import function q_SetAxisAngle( axis : Vector, angle : float ) : Vector;
import function q_RemoveAxisComponent( /*inout*/ quat : Vector, axis : Vector );
import function q_DecomposeAxis( quat : Vector, axis : Vector ) : float;

import function q_SetSlerp( a : Vector, b : Vector, w : float ) : Vector;

import function q_GetAngle( a : Vector ) : float;
import function q_GetAxis( a : Vector ) : Vector;


//////////////////////////////////////////////
// Vector functions							//
//////////////////////////////////////////////

import function v_SetInterpolate( a : Vector, b : Vector, w : float ) : Vector;
import function v_SetRotatedDir( quat : Vector, dir : Vector ) : Vector;
import function v_SetTransformedPos( trans : EngineQsTransform, vec : Vector ) : Vector;
import function v_ZeroElement( /*inout*/ a : Vector , i : int );
