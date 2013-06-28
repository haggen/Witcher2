/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the facts DB
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Facts DB functions
/////////////////////////////////////////////

// Adds a new fact.
import function FactsAdd( ID : string, optional value : int, optional validFor : int, optional time : int );

// Returns a sum of values of all the facts with the specified id.
import function FactsQuerySum( ID : string ) : int;

// Returns a sum of values of all the facts with the specified id
// that were added after the 'sinceTime'
import function FactsQuerySumSince( ID : string, sinceTime : int ) : int;

// Returns the value of the most recently added fact with the specified id.
import function FactsQueryLatestValue( ID : string ) : int;

// Checks if the specified fact is defined in the DB.
import function FactsDoesExist( ID : string ) : bool;

// Removes a single fact from the facts db.
import function FactsRemove( ID : string ) : bool;

/////////////////////////////////////////////
// Facts DB brices
/////////////////////////////////////////////

// Adds a new fact.
brix function Add_New_Fact( ID : string, optional value : int, optional validFor : int, optional time : int )
{
	FactsAdd( ID, value, validFor, time );
}

// Checks if the specified fact is defined in the DB.
brix function Check_If_Fact_Exists( ID : string, out exists : bool )
{
	exists = FactsDoesExist( ID );
}