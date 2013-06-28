/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////////////////////////////////
// class for hiding / showing layers on area enter
/////////////////////////////////////////////////////////////////////////

class CShowLayersArea extends CGameplayEntity
{
	editable var layerGroupName : string;
	editable var show : bool;

	event OnAreaEnter( area: CTriggerAreaComponent, activator: CComponent )
	{
		var activatorEntity : CEntity;
		
		activatorEntity = activator.GetEntity();
		
		if( activatorEntity.IsA( 'CPlayer' ) )
		{
			if( show )
			{
				theGame.GetWorld().ShowLayerGroup( layerGroupName );
			}
			else
			{
				theGame.GetWorld().HideLayerGroup( layerGroupName );
			}
		}
	}
}
