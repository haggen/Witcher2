/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** String processing functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// String processing functions
/////////////////////////////////////////////

// Get string length
import function StrLen( str : string ) : int;

// Compare strings
import function StrCmp( str, with : string, optional length : int, optional noCase : bool ) : int;

// Find substring, from left
import function StrFindFirst( str, match : string ) : int;

// Find substring, from right
import function StrFindLast( str, match : string ) : int;

// Divide string using splitter
import function StrSplitFirst( str, divider : string, out left, right : string ) : bool;

// Divide string using splitter
import function StrSplitLast( str, divider : string, out left, right : string ) : bool;

// Replate pattern with something else (only the first find)
import function StrReplace( str, match, with : string ) : string;

// Replate pattern with something else
import function StrReplaceAll( str, match, with : string ) : string;

// Get string part starting from i-th char (j is the length)
import function StrMid( str : string, first : int, optional length : int ) : string;

// Get string before given char
import function StrLeft( str : string, length : int ) : string;

// Get string after given char
import function StrRight( str : string, length : int ) : string;

// Get string before first occurence of given substring
import function StrBeforeFirst( str, match : string ) : string;

// Get string before last occurence of given substring
import function StrBeforeLast( str, match : string ) : string;

// Get string after first occurence of given substring
import function StrAfterFirst( str, match : string ) : string;

// Get string after last occurence of given substring
import function StrAfterLast( str, match : string ) : string;

// Check if string starts with given substring
import function StrBeginsWith( str, match  : string ) : bool;

// Check if string ends with given substring
import function StrEndsWith( str, match  : string ) : bool;

// Convert string to upper case
import function StrUpper( str  : string ) : string;

// Convert string to lower case
import function StrLower( str  : string ) : string;

// Format string (printf like but using %1, %2, %3, etc)
import function StrFormat( str : string , optional a, b, c, d  : string ) : string;

// Create string for single char 
import function StrChar( i : int ) : string;

// Convert name to string 
import function NameToString( n : name ) : string;

// Convert string to name 
import function StringToName( str : string ) : name;

// Convert float to string
import function FloatToString( value : float ) : string;

// Convert float to string with precision
import function FloatToStringPrec( value : float, precision : int ) : string;

// Convert int to string
import function IntToString( value : int ) : string;

// Convert string to int
import function StringToInt( value : string, optional defValue : int) : int;

// Convert string to float
import function StringToFloat( value : string, optional defValue : float ) : float;

// Convert string to upper case including diacritic characters 
import function StrUpperUTF( str : string ) : string;

// Convert string to lower case including diacritic characters
import function StrLowerUTF( str : string ) : string;




