class q214_minigame extends CGameplayEntity
{
	var countClicks, factA, factB, factC, factD, factE, factF, factG, factChoice, currentA, currentB, currentC, currentD, currentE, currentF, currentG : int;
	var sequence : name;
	var ea, eb, ec, ed, ee, ef, eg	: CEntity;
	
	default countClicks = 0;
	
	function miniGameStart()
	{	
		ea = theGame.GetEntityByTag( 'q214_selection_a' );
		eb = theGame.GetEntityByTag( 'q214_selection_b' );	
		ec = theGame.GetEntityByTag( 'q214_selection_c' );
		ed = theGame.GetEntityByTag( 'q214_selection_d' );
		ee = theGame.GetEntityByTag( 'q214_selection_e' );
		ef = theGame.GetEntityByTag( 'q214_selection_f' );
		eg = theGame.GetEntityByTag( 'q214_selection_g' );
		
		ea.StopEffect('seletion');
		eb.StopEffect('seletion');	
		ec.StopEffect('seletion');	
		ed.StopEffect('seletion');
		ee.StopEffect('seletion');
		ef.StopEffect('seletion');
		eg.StopEffect('seletion');
	
	
		factA = FactsQuerySum( "q214_object_a" );
		factB = FactsQuerySum( "q214_object_b" );
		factC = FactsQuerySum( "q214_object_c" );
		factD = FactsQuerySum( "q214_object_d" );
		factE = FactsQuerySum( "q214_object_e" );
		factF = FactsQuerySum( "q214_object_f" );
		factG = FactsQuerySum( "q214_object_g" );
		
		currentA = FactsQuerySum( "q214_current_a" );
		currentB = FactsQuerySum( "q214_current_b" );
		currentC = FactsQuerySum( "q214_current_c" );
		currentD = FactsQuerySum( "q214_current_d" );
		currentE = FactsQuerySum( "q214_current_e" );
		currentF = FactsQuerySum( "q214_current_f" );
		currentG = FactsQuerySum( "q214_current_g" );
		
		//FactsRemove( "q214_minigame_loose" );
		
		checkMinigame();
	}
	
	function checkMinigame()
	
	{
		var checkResult : bool;
		
		countClicks += 1;
		
		if( !sequence || sequence == 'NULL' )
		{
			if ( currentF >= 1)
			{
				//FactsRemove( "q214_current_f" );
				FactsAdd( "q214_path_f", 1 );
				sequence = 'F';
			}
			else if ( currentG >= 1)
			{
				//FactsRemove( "q214_current_g" );
				FactsAdd( "q214_path_g", 1 );
				sequence = 'G';
			}
		}
		
		checkResult = checkSequence( sequence );
		
		if( checkResult && countClicks >= 7 )
		{
			FactsAdd( "q214_minigame_win", 1 );
		}
		else
		{
			if ( checkResult && countClicks < 7 )
			{
				
			}
			else
			{
				FactsAdd( "q214_minigame_loose", 1 );
				
				clearFacts();
			}
		}
	}


	function checkSequence( sequenceLetter : name ) : bool
	{
		if( sequenceLetter == 'F' )
		{
			if( factF == 1 )
			{	if ( countClicks == 1 )
				{ 
					return true;
				}
				else if( factE == 1 )
				{
					if ( countClicks == 2 )
					{
						return true;
					}
					else if( factC == 1 )
					{
						if ( countClicks == 3 )
						{
							return true;
						}
						else if( factD == 1 )
						{
							if ( countClicks == 4 )
							{
								return true;
							}
							else if( factB == 1 )
							{
								if ( countClicks == 5 )
								{
									return true;
								}
								else if( factG == 1 )
								{
									if ( countClicks == 6 )
									{
										return true;
									}
									else if( factA == 1 )
									{
										return true;
									}
									else if ( factA != 1 )
									{
										return false;
									}
								}
								else if ( factG != 1 )
								{
									return false;
								}
							}
							else if ( factB != 1 )
							{
								return false;
							}
						}
						else if ( factD != 1 )
						{
							return false;
						}
					}
					else if ( factC != 1 )
					{
						return false;
					}
				}
				else if ( factE != 1 )
				{
					return false;
				}	
			}
		}
		
		if( sequenceLetter == 'G' )
		{
			if( factG == 1 )
			{
				if ( countClicks == 1 )
				{ 
					return true;
				}
				else if( factB == 1 )
				{
					if ( countClicks == 2 )
					{ 
						return true;
					}
					else if( factD == 1 )
					{
						if ( countClicks == 3 )
						{ 
							return true;
						}
						else if( factC == 1 )
						{
							if ( countClicks == 4 )
							{ 
								return true;
							}
							else if( factE == 1 )
							{
								if ( countClicks == 5 )
								{ 
									return true;
								}
								else if( factF == 1 )
								{
									if ( countClicks == 6 )
									{ 
										return true;
									}
									else if( factA == 1 )
									{
										return true;
									}
									else if ( factA != 1 )
									{
										return false;
									}
								}
								else if ( factF != 1 )
								{
									return false;
								}
							}
							else if ( factE != 1 )
							{
								return false;
							}
						}
						else if ( factC != 1 )
						{
							return false;
						}
					}
					else if ( factD != 1 )
					{
						return false;
					}
				}
				else if ( factB != 1 )
				{
					return false;
				}
			}
		}
	}

	function clearFacts()
	{
		sequence = 'NULL';
		
		ea.StopEffect('seletion');
		eb.StopEffect('seletion');	
		ec.StopEffect('seletion');	
		ed.StopEffect('seletion');
		ee.StopEffect('seletion');
		ef.StopEffect('seletion');
		eg.StopEffect('seletion');
		
		FactsRemove( "q214_object_a" );
		FactsRemove( "q214_object_b" );
		FactsRemove( "q214_object_c" );
		FactsRemove( "q214_object_d" );
		FactsRemove( "q214_object_e" );
		FactsRemove( "q214_object_f" );
		FactsRemove( "q214_object_g" );
		
		FactsRemove( "q214_current_a" );
		FactsRemove( "q214_current_b" );
		FactsRemove( "q214_current_c" );
		FactsRemove( "q214_current_d" );
		FactsRemove( "q214_current_e" );
		FactsRemove( "q214_current_f" );
		FactsRemove( "q214_current_g" );
		FactsRemove( "q214_path_f" );
		FactsRemove( "q214_path_g" );
		countClicks = 0;
	}
}
