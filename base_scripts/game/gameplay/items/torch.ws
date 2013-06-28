/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Torch weapon
/** Copyright © 2010
/***********************************************************************/

class CItemTorch extends CItemEntity
{
	event OnMount( parentEntity : CEntity, slot : name )
	{
		Log( "nazwa kosci " + NameToString(slot) );
		if ( slot != 'r_weapon' && slot != 'l_weapon' )
		{
			RemoveTimer( 'TorchTimer' );
			StopEffect( 'torch_fire' );
		} else
		{
			RemoveTimer( 'TorchTimer' );
			PlayEffect( 'torch_fire' );
		}
	}
	
	event OnDraw( parentEntity : CEntity )
	{
			RemoveTimer( 'TorchTimer' );
			PlayEffect( 'torch_fire' );
	}
	
	event OnDetach( parentEntity : CEntity )
	{
		AddTimer( 'TorchTimer', 2.5f, false );
	}
	
	timer function TorchTimer( t : float )
	{	
		StopEffect( 'torch_fire' );
	}
}