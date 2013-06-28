/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for 2DArray
/** Copyright © 2010
/***********************************************************************/

import class C2dArray extends CResource
{	
	// Get value by column, row
	import final function GetValueAt( column : int, row : int ) : string;
	
	// Get value using column header and row
	import final function GetValue( header : string, row : int ) : string;
	
	// Get number of rows
	import final function GetNumRows() : int;
	
	// Get index of row with given value in given colum
	import final function GetRowIndexAt( column : int, value : string ) : int;
	
	// Get index of row with given value in given colum
	import final function GetRowIndex( header : string, value : string ) : int;
}

import function LoadCSV( filePath : string ) : C2dArray;
