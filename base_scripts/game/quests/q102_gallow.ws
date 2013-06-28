// Klasa obslugujaca otwieranie i zamykanie zapadni w szubienicy

class q102_gallow extends CGameplayEntity
{
	var factHangingPhase : int;
	var jaskier, zoltan, woman_hanger, man_hanger, gallow, executioner : CEntity;
	var elfHanger, womanElfHanger, jaskier_component, zoltan_component : CAnimatedComponent;
	var ropeJaskier, ropeZoltan, ropeElfHanger, ropeWomanElfHanger : CAnimatedComponent;
	var leverElfHanger, leverWomanElfHanger : CAnimatedComponent;           
	var vectorJaskier, vectorZoltan, vectorElfHanger, vectorWomanElfHanger, vectorGallow, vectorWPhanger1, vectorWPhanger2, vectorExecutioner : Vector;
	var rotationJaskier, rotationZoltan, rotationElfHanger, rotationWomanElfHanger, rotationGallow, rotationWPhanger1, rotationWPhanger2, rotationExecutioner : EulerAngles;	
	var component : CDrawableComponent;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		q102_CheckFact();
	}
}

state q102_open_state in q102_gallow
{
	entry function q102_CheckFact()
	{
		parent.factHangingPhase = FactsQuerySum( "q102_factHangingPhase" );
		
		parent.vectorJaskier = theGame.GetNodeByTag('q102_dandelion').GetWorldPosition();
		parent.vectorZoltan = theGame.GetNodeByTag('q102_zoltan').GetWorldPosition();
		parent.vectorElfHanger = theGame.GetNodeByTag('q102_hanger01_wp').GetWorldPosition();
		parent.vectorWomanElfHanger = theGame.GetNodeByTag('q102_hanger02_wp').GetWorldPosition();
		parent.vectorGallow = theGame.GetNodeByTag('q102_gallow_wp').GetWorldPosition();	
		parent.vectorWPhanger1 = theGame.GetNodeByTag('q102_hanger1_hang').GetWorldPosition();
		parent.vectorWPhanger2 = theGame.GetNodeByTag('q102_hanger2_hang').GetWorldPosition();
		parent.vectorExecutioner = theGame.GetNodeByTag('q102_executioner_wp').GetWorldPosition();	
		
		parent.rotationJaskier = theGame.GetNodeByTag('q102_dandelion').GetWorldRotation();
		parent.rotationZoltan = theGame.GetNodeByTag('q102_zoltan').GetWorldRotation();
		parent.rotationElfHanger = theGame.GetNodeByTag('q102_hanger01_wp').GetWorldRotation();
		parent.rotationWomanElfHanger = theGame.GetNodeByTag('q102_hanger02_wp').GetWorldRotation();
		parent.rotationGallow = theGame.GetNodeByTag('q102_gallow_wp').GetWorldRotation();
		parent.rotationWPhanger1 = theGame.GetNodeByTag('q102_hanger1_hang').GetWorldRotation();
		parent.rotationWPhanger2 = theGame.GetNodeByTag('q102_hanger2_hang').GetWorldRotation();
		parent.rotationExecutioner = theGame.GetNodeByTag('q102_executioner_wp').GetWorldRotation();

		parent.jaskier = theGame.GetEntityByTag( 'Dandelion' );
		parent.zoltan = theGame.GetEntityByTag( 'Zoltan' );
		parent.woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
		parent.man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );  
		parent.elfHanger = (CAnimatedComponent) parent.man_hanger.GetRootAnimatedComponent();
		parent.womanElfHanger = (CAnimatedComponent) parent.woman_hanger.GetRootAnimatedComponent();
		parent.jaskier_component = (CAnimatedComponent)parent.jaskier.GetRootAnimatedComponent();
		parent.zoltan_component = (CAnimatedComponent)parent.zoltan.GetRootAnimatedComponent();
		


		parent.ropeJaskier = (CAnimatedComponent) parent.GetComponent('rope1');
		parent.ropeZoltan = (CAnimatedComponent) parent.GetComponent('rope2');
		parent.ropeElfHanger = (CAnimatedComponent) parent.GetComponent('rope3');
		parent.ropeWomanElfHanger = (CAnimatedComponent) parent.GetComponent('rope4');
		
		parent.leverElfHanger = (CAnimatedComponent) parent.GetComponent('lever3');
		parent.leverWomanElfHanger = (CAnimatedComponent) parent.GetComponent('lever4');  
		
		
		if( parent.factHangingPhase == 0)
		{
			while ( !parent.jaskier || !parent.zoltan || !parent.elfHanger || !parent.womanElfHanger || !parent.executioner )
			{
				parent.jaskier = theGame.GetEntityByTag( 'Dandelion' );
				parent.zoltan = theGame.GetEntityByTag( 'Zoltan' );
				parent.woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
				parent.man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );
	  
				parent.elfHanger = (CAnimatedComponent) parent.man_hanger.GetRootAnimatedComponent();
				parent.womanElfHanger = (CAnimatedComponent) parent.woman_hanger.GetRootAnimatedComponent();
				parent.jaskier_component = (CAnimatedComponent)parent.jaskier.GetRootAnimatedComponent();
				parent.zoltan_component = (CAnimatedComponent)parent.zoltan.GetRootAnimatedComponent();
				parent.executioner = theGame.GetEntityByTag('q102_executioner');		
				Sleep ( 0.5f );
			}
			
		
			parent.jaskier.TeleportWithRotation( parent.vectorJaskier, parent.rotationJaskier);
			parent.zoltan.TeleportWithRotation( parent.vectorZoltan, parent.rotationZoltan);
			parent.gallow.TeleportWithRotation( parent.vectorGallow, parent.rotationGallow);
			//theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( parent.vectorElfHanger, parent.rotationElfHanger);
			//theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( parent.vectorWomanElfHanger, parent.rotationWomanElfHanger);
			
			theGame.GetActorByTag('q102_hanger02').EnablePathEngineAgent( false );
			theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
			((CNewNPC)parent.zoltan).EnablePathEngineAgent( false );
			((CNewNPC)parent.jaskier).EnablePathEngineAgent( false );
			
			Sleep(0.01f);
			
			parent.ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
			parent.ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
			parent.ropeElfHanger.RaiseBehaviorForceEvent('hanging_off');
			parent.ropeWomanElfHanger.RaiseBehaviorForceEvent('hanging_off');

			parent.jaskier.RaiseForceEvent('hanging_jaskier_off');
			parent.zoltan.RaiseForceEvent('hanging_off');
			parent.woman_hanger.RaiseForceEvent('woman_hanger');
			parent.man_hanger.RaiseForceEvent('man_elf_hanger');
			
			parent.leverElfHanger.RaiseBehaviorForceEvent('hanging_off');
			parent.leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_off');
			
			((CActor) parent.executioner).EnablePathEngineAgent( false );
			parent.executioner.TeleportWithRotation( parent.vectorExecutioner, parent.rotationExecutioner);
			Sleep (0.1);
			((CActor) parent.executioner).EnablePathEngineAgent( true );
			theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( parent.vectorElfHanger, parent.rotationElfHanger);
			theGame.GetEntityByTag('q102_hanger02').TeleportWithRotation( parent.vectorWomanElfHanger, parent.rotationWomanElfHanger);
		}
		else if (  parent.factHangingPhase == 1 )
		{
			while ( !parent.jaskier || !parent.zoltan || !parent.elfHanger || !parent.executioner )
			{
				parent.jaskier = theGame.GetEntityByTag( 'Dandelion' );
				parent.zoltan = theGame.GetEntityByTag( 'Zoltan' );
				parent.woman_hanger = theGame.GetEntityByTag( 'q102_hanger02' );
				parent.man_hanger = theGame.GetEntityByTag( 'q102_hanger01' );
	  
				parent.elfHanger = (CAnimatedComponent) parent.man_hanger.GetRootAnimatedComponent();
				parent.womanElfHanger = (CAnimatedComponent) parent.woman_hanger.GetRootAnimatedComponent();
				parent.jaskier_component = (CAnimatedComponent)parent.jaskier.GetRootAnimatedComponent();
				parent.zoltan_component = (CAnimatedComponent)parent.zoltan.GetRootAnimatedComponent();
				parent.executioner = theGame.GetEntityByTag('q102_executioner');	
				Sleep ( 0.5f );
			}
			parent.component = (CDrawableComponent) parent.GetComponent( "rope4_mesh" );
			parent.component.SetVisible( false );

			theGame.GetActorByTag('q102_hanger01').EnablePathEngineAgent( false );
			
			parent.gallow.TeleportWithRotation( parent.vectorGallow, parent.rotationGallow);
			parent.jaskier.TeleportWithRotation( parent.vectorJaskier, parent.rotationJaskier);
			parent.zoltan.TeleportWithRotation( parent.vectorZoltan, parent.rotationZoltan);
			
			theGame.GetEntityByTag('q102_hanger01').TeleportWithRotation( parent.vectorElfHanger, parent.rotationElfHanger);
					
			parent.jaskier.RaiseForceEvent('hanging_jaskier_off');
			parent.zoltan.RaiseForceEvent('hanging_off');
			parent.man_hanger.RaiseForceEvent('man_elf_hanger');
			
			parent.ropeJaskier.RaiseBehaviorForceEvent('hanging_off');
			parent.ropeZoltan.RaiseBehaviorForceEvent('hanging_off');
			parent.ropeElfHanger.RaiseBehaviorForceEvent('hanging_off');
			
			parent.leverElfHanger.RaiseBehaviorForceEvent('hanging_off');
			parent.leverWomanElfHanger.RaiseBehaviorForceEvent('hanging_on');
			
			((CActor) parent.executioner).EnablePathEngineAgent( false );
			parent.executioner.TeleportWithRotation( parent.vectorExecutioner, parent.rotationExecutioner);
			Sleep (0.1);
			((CActor) parent.executioner).EnablePathEngineAgent( true );
		}
	}
}