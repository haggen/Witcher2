/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Array functions list
/** Copyright © 2010
/***********************************************************************/

/*array< T >
{
	// Element access
	operator[int index] : T;

	// Clear array
	function Clear();

	// Get array size
	function Size() : int;
	
	// Add element at the end of array
	function PushBack( element : T );
	
	// Remove element at the end of array
	function PopBack() : T;

	// Resize array
	function Resize( newSize : int );
	
	// Remove given element, returns false if not found
	function Remove( element : T ) : bool;
	
	// Does array contain element?
	function Contains( element : T ) : bool;

	// Find first element, returns -1 if not found
	function FindFirst( element : T ) : int;

	// Find last element, returns -1 if not found
	function FindLast( element : T ) : int;
	
	// Add space to array, returns new size
	function Grow( numElements : int ) : int;
	
	// Erase place in array
	function Erase( index : int );
	
	// Insert item at given position
	function Insert( index : int, element : T );
	
	// Get last element
	function Last() : T;
};*/

// Returns index of highest element
function ArrayFindMaxF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

// Returns index of highest element using a mask to mask out some of the values
function ArrayMaskedFindMaxF( a : array< float >, thresholdVal : float ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		val = a[0];
		if ( val < thresholdVal )
		{
			index = 0;
		}
		else
		{
			index = -1;
			val = -100000000;
		}
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val && a[i] < thresholdVal )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}


// Returns index of lowest element
function ArrayFindMinF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

import function ArraySortInts   ( out arrayToSort : array< int > );
import function ArraySortFloats ( out arrayToSort : array< float > );
import function ArraySortStrings( out arrayToSort : array< string > );
