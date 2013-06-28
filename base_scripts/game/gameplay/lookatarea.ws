//klasa pozwalajaca na ustawienie LookAt dla kamery na specyficzny punkt.

class CLookAtArea extends CEntity
{
    editable var targetTag 	   : name;
    editable var stopAfterTime : bool;
    editable var time 		   : float;
   
    event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
    {
        var target : CNode;
        var affectedEntity : CEntity;
        
        Log( "ERROR - Do przerobienia CLookAtArea ");
       
        affectedEntity = activator.GetEntity();
       
        if( affectedEntity.IsA( 'CPlayer' ) )
        {
            target = theGame.GetNodeByTag( targetTag );
            theCamera.FocusOn( target );
            
            if(stopAfterTime)
            {
				AddTimer('StoppingAfterTime',time, false, false);
            }
        }
    }
    event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
    {
        var target : CNode;
        var affectedEntity : CEntity;
        
        Log( "ERROR - Do przerobienia CLookAtArea ");
       
        affectedEntity = activator.GetEntity();
       
        if( affectedEntity.IsA( 'CPlayer' ) )
        {
            theCamera.FocusDeactivation();
            RemoveTimer('StoppingAfterTime');
        }
    }
    private timer function StoppingAfterTime  (time : float)
    {
		var target : CNode;
		
		target = theGame.GetNodeByTag( targetTag );
		
		theCamera.FocusDeactivation();
    }

}



