
/////////////////////////////////////////////
// Static Camera class
/////////////////////////////////////////////

enum EStaticCameraAnimState
{
	SCAS_Default,
	SCAS_Collapsed,
	SCAS_Window,
	SCAS_ShakeTower,
}

enum EStaticCameraGuiEffect
{
	SCGE_None = 0,
	SCGE_Hole,
}

import class CStaticCamera extends CCamera
{
	import final function Run( flag : bool ) : bool;
	import final function IsRunning() : bool;
	import final function AutoDeactivating() : bool;
	
	import latent final function RunAndWait( optional timeout : float ) : bool;
}

/////////////////////////////////////////////
// Static Camera Area class
/////////////////////////////////////////////

class CStaticCameraArea extends CEntity
{
    editable var cameraTag : name;
    editable var onlyForPlayer : bool;
	editable var activatorTag : name;
   
	default onlyForPlayer = true;
  
    event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
    {
		var camera : CStaticCamera;
		
		if ( !IsActivatorValid( activator ) )
		{
			return false;
		}
		
		camera = (CStaticCamera)theGame.GetNodeByTag( cameraTag );
		if ( camera )
		{
			camera.Run( true );
		}
		else
		{
			LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaEnter : Couldn't find static camera with tag " + cameraTag );
		}
    }
    
    event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
    {
        var camera : CStaticCamera;
		
		if ( !IsActivatorValid( activator ) )
		{
			return false;
		}
		
		camera = (CStaticCamera)theGame.GetNodeByTag( cameraTag );
		if ( camera )
		{
			if ( camera.IsRunning() )
			{
				camera.Run( false );
			}
			else if ( !camera.AutoDeactivating() )
			{
				LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaExit : Static camera with tag " + cameraTag  + " is deactivating twice" );
			}
		}
		else
		{
			LogChannel( 'StaticCamera', "CStaticCameraArea::OnAreaExit : Couldn't find static camera with tag " + cameraTag );
		}
    }
    
    private final function IsActivatorValid( activator : CComponent ) : bool
    {
		if ( onlyForPlayer )
		{
			return activator.GetEntity().IsA( 'CPlayer' );
		}
		else if ( activatorTag )
		{
			return activator.GetEntity().HasTag( activatorTag );
		}
		else
		{
			return true;
		}
    }
}
