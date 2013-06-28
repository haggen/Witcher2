/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for various math functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Types
/////////////////////////////////////////////

// 4 component vector
import struct Vector
{
	import public var X,Y,Z,W : float;
}

// Euler angles, used for rotation
import struct EulerAngles
{
	import public var Pitch, Yaw, Roll : float;
}

// Matrix
import struct Matrix
{
	import public var X,Y,Z,W : Vector;
}

// Bounding box
import struct Box
{
	import public var Min, Max : Vector;
}

// Simple color
import struct Color
{
 	import public var Red, Green, Blue, Alpha : byte;
};

// Sphere
import struct Sphere
{
	import public var CenterRadius2 : Vector;
}

/////////////////////////////////////////////
// Scalar functions
/////////////////////////////////////////////

// Pi value
function Pi() : float
{
	return 3.14159265;
}

// Random value [0, Max-1]
import function Rand( range : int ) : int;

// Random value [0, Max-1] different than lastValue if possible
import function RandDifferent( range, lastValue : int ) : int;

// Absolute value
import function Abs( a : int ) : int;

// Minimum of two numbers
import function Min( a,b : int ) : int;

// Maximum of two numbers
import function Max( a,b : int ) : int;

// Clamp value to given range
import function Clamp( v, min, max : int ) : int;

// Convert between angles and radians
import function Deg2Rad( deg : float ) : float;

// Convert between radians and angle
import function Rad2Deg( rad : float ) : float;

// Absolute value
import function AbsF( a : float ) : float;

// Sinus (angle in radians)
import function SinF( a : float ) : float;

// Arcus Sinus
import function AsinF( a : float ) : float;

// Cosinus (angle in radians)
import function CosF( a : float ) : float;

// Arcus cosinus, result in radians
import function AcosF( a : float ) : float;

// Tangens (angle in radians)
import function TanF( a : float ) : float;

// Arcus tangens a/b
import function AtanF( a,b : float ) : float;

// Exponent (e^a)
import function ExpF( a : float ) : float;

// Power (a^x)
import function PowF( a,x : float ) : float;

// Natural logarithm of a
import function LogF( a : float ) : float;
 
// Square root from A
import function SqrtF( a : float ) : float;

// Squared A
import function SqrF( a : float ) : float;

// Random value from <0, 1)
import function RandF() : float;

// Random value from given range
import function RandRangeF( min,max : float ) : float;

// Random value from <-1, 1>
import function RandStaticF( seed : int ) : float;

// Random value from given range
import function RandRangeStaticF( seed : int, min,max : float ) : float;

// Make seed from object handle
import function CalcSeed( object : CObject ) : int;

// Minimum of two values
import function MinF( a,b : float ) : float;

// Maximum of two values
import function MaxF( a,b : float ) : float;

// Clamp value
import function ClampF( v, min, max : float ) : float;

// Interpolate
import function LerpF( alpha, a, b : float, optional clamp : bool ) : float;

// Round to nearest larger integer
import function CeilF( a : float ) : int;

// Round to nearest smaller integer
import function FloorF( a : float ) : int;

// Round to integer (simple cuts fractional part so it works as cast to int)
import function RoundF( a : float ) : int;

// Round float to integer
import function RoundFEx( a : float ) : int;

// Reinterpret int data as float (needed for passing masks to Scaleform)
import function ReinterpretIntAsFloat( a : int ) : float;

/////////////////////////////////////////////
// Angle functions
/////////////////////////////////////////////

// Normalize angle to 0 - 360 range
import function AngleNormalize( a : float ) : float;

// Get distance between angles ( result in -180 to 180 range )
import function AngleDistance( a, b : float ) : float;

// Approach target angle with given step
import function AngleApproach( target, cur, step : float ) : float;

/////////////////////////////////////////////
// Vector functions
/////////////////////////////////////////////

// Calculate 2 component dot product of two vectors
import function VecDot2D( a, b : Vector ) : float;

// Calculate 3 component dot product of two vectors
import function VecDot( a, b : Vector ) : float;

// Calculate cross product of two vectors
import function VecCross( a, b : Vector ) : Vector;

// Calculate 2D length of Vector
import function VecLength2D( a : Vector ) : float;

// Calculate 3D length of Vector
import function VecLength( a : Vector ) : float;

// Return 2D normalized Vector 
import function VecNormalize2D( a : Vector ) : Vector;

// Return 3D normalized Vector 
import function VecNormalize( a : Vector ) : Vector;

// Return 2D random Vector
import function VecRand2D() : Vector;

// Return 3D random Vector
import function VecRand() : Vector;

// Random position in ring on XY plane
function VecRingRand( minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandRangeF( minRadius, maxRadius );
	angle = RandRangeF( 0, 6.28318530 );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}

// Random position in ring on XY plane
function VecRingRandStatic( seed : int, minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandRangeStaticF( seed, minRadius, maxRadius );
	angle = RandRangeStaticF( seed, 0, 6.28318530 );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}

// Mirror vector by given normal
import function VecMirror( dir, normal : Vector ) : Vector;

// Calculate 3D distance between two vectors
import function VecDistance( from, to : Vector ) : float;

// Calculate squared 3D distance between two vectors
import function VecDistanceSquared( from, to : Vector ) : float;

// Calculate 2D distance between two vectors
import function VecDistance2D( from, to : Vector ) : float;

// Calculate squared 2D distance between two vectors
import function VecDistanceSquared2D( from, to : Vector ) : float;

// Calculate distance to edge
import function VecDistanceToEdge( point, a, b : Vector ) : float;

// Calculate nearest point on edge
import function VecNearestPointOnEdge( point, a, b : Vector ) : Vector;

// Calculate rotation that transforms "forward" to given vector
import function VecToRotation( dir : Vector ) : EulerAngles;

// Calculate yaw rotation ( heading )that transforms "forward" to given vector
import function VecHeading( dir : Vector ) : float;

// Calculate vector from heading ( yaw rotation )
import function VecFromHeading( heading : float ) : Vector;

// Transform vector as point by given matrix
import function VecTransform( m : Matrix, point : Vector ) : Vector;

// Transform vector as direction by given matrix
import function VecTransformDir( m : Matrix, point : Vector ) : Vector;

// Transform 4 component vector and project back by diving by W component
import function VecTransformH( m : Matrix, point : Vector ) : Vector;

// Convert vector to string
function VecToString( vec : Vector ) : string
{
	return StrFormat("%1 %2 %3 %4", vec.X, vec.Y, vec.Z, vec.W );	
}

/////////////////////////////////////////////
// EulerAngles functions
/////////////////////////////////////////////

// Constructor. WATCH OUT FOR DIFFERENT PARAMETERS ORDER
// EulerAngles( pitch, yaw, roll )

// Get X axis for given rotation
import function RotX( rotation : EulerAngles ) : Vector;

// Get Y axis for given rotation
import function RotY( rotation : EulerAngles ) : Vector;

// Get Z axis for given rotation
import function RotZ( rotation : EulerAngles ) : Vector;

// Get the forward direction for given rotation
import function RotForward( rotation : EulerAngles ) : Vector;

// Get the right direction for given rotation
import function RotRight( rotation : EulerAngles ) : Vector;

// Get the up direction for given rotation
import function RotUp( rotation : EulerAngles ) : Vector;

// Convert euler angles to matrix
import function RotToMatrix( rotation : EulerAngles ) : Matrix;

// Decompose rotator into axes
import function RotAxes( rotation : EulerAngles, out foward, right, up : Vector );

// Calculate dot product betwen two rotations ( i.e. dot product between forward vectors of rotations )
import function RotDot( a, b : EulerAngles );

// Calculate random rotation
import function RotRand( min, max : float );

/////////////////////////////////////////////
// Matrix functions
/////////////////////////////////////////////

// Build identity matrix
import function MatrixIdentity() : Matrix;

// Build translation matrix
import function MatrixBuiltTranslation( move : Vector ) : Matrix;

// Build rotation matrix
import function MatrixBuiltRotation( rot : EulerAngles ) : Matrix;

// Build scale matrix
import function MatrixBuiltScale( scale : Vector ) : Matrix;

// Build prescale matrix
import function MatrixBuiltPreScale( scale : Vector ) : Matrix;

// Build TRS matrix
import function MatrixBuiltTRS( optional translation : Vector, optional rotation : EulerAngles, optional scale : Vector ) : Matrix;

// Build RTS matrix
import function MatrixBuiltRTS( optional rotation : EulerAngles, optional translation : Vector, optional scale : Vector ) : Matrix;

// Build matrix with EY from given direction vector
import function MatrixBuildFromDirectionVector( dirVec : Vector ) : Matrix;

// Extract translation from matrix
import function MatrixGetTranslation( m : Matrix  ) : Vector;

// Extract rotation from matrix
import function MatrixGetRotation( m : Matrix ) : EulerAngles;

// Extract scale from matrix
import function MatrixGetScale( m : Matrix ) : Vector;

/////////////////////////////////////////////
// Sphere functions
/////////////////////////////////////////////

// Check if ray intersects sphere: 0 not found, 1 only exits (enterPoint same as origin), 2 enters and exits
import function SphereIntersectRay( sphere : Sphere, orign : Vector, direction : Vector, out enterPoint : Vector, out exitPoint : Vector ) : int;

// Check edge-sphere intersection, returs number of intersection points
import function SphereIntersectEdge( sphere : Sphere, a : Vector, b : Vector, out intersectionPoint0 : Vector, out intersectionPoint1 : Vector ) : int;

/////////////////////////////////////////////
// Conversions
/////////////////////////////////////////////
import function Int8ToInt( i : Int8 ) : int;
import function IntToInt8( i : int ) : Int8;
