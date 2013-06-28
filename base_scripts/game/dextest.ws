// Dex test file, do not fuck with it !
// Rychu was here ;-)

quest latent function DexQ_SavePointTest( msg : string )
{
	var i : int;
	
	Log ( "Started crap: " + msg );
	
	savepoint( 'pre', i );
	
	Sleep( 5.0f );
	
	for ( ;; )
	{
		Logf( "Iteration = %1 (%2)", i, msg );
		Sleep( 2.0f );
		i += 1;	
		
		savepoint( 'loop', i );
		
	}
}