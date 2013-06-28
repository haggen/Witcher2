enum EShrineType
{
	ST_SummerShrine,
	ST_WinterShrine
}

class W2Shrine extends CGameplayEntity
{
	editable var shrineType : EShrineType;
	var interactionComponent	: CInteractionComponent;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		if ( shrineType ==  ST_SummerShrine && thePlayer.GetCharacterStats().HasAbility('story_s31_1') )
		{
			interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
			interactionComponent.SetEnabled( false );
			StopEffect('shrine_fire');
			StopEffect('shrine_fire_use');
			StopEffect('shrine_fire_default');
		}
		else if( shrineType ==  ST_WinterShrine && thePlayer.GetCharacterStats().HasAbility('story_s32_1') )
		{
			interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
			interactionComponent.SetEnabled( false );
			StopEffect('shrine_ice');
			StopEffect('shrine_ice_use');
			StopEffect('shrine_ice_default');
		}
		else if( shrineType ==  ST_WinterShrine )
		{
			PlayEffect('shrine_ice_default');
		}
		else if( shrineType ==  ST_SummerShrine )
		{
			PlayEffect('shrine_fire_default');
		}
		
		super.OnSpawned( spawnData );
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			theHud.Invoke("vHUD.blinkMed");
			theSound.PlaySound("gui/hud/medalionwarning");
			if( shrineType ==  ST_SummerShrine )
			{
				PlayEffect('shrine_fire');
			}
			else if( shrineType ==  ST_WinterShrine )
			{
				PlayEffect('shrine_ice');
			}
		}
	}
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			if( shrineType ==  ST_SummerShrine )
			{
				StopEffect('shrine_fire');
			}
			else if( shrineType ==  ST_WinterShrine )
			{
				StopEffect('shrine_ice');
			}
		}
	}
	
	
	event OnInteraction( actionName : name, activator : CEntity )
	{			
		if ( activator == thePlayer )
		{
			interactionComponent = (CInteractionComponent)this.GetComponentByClassName( 'CInteractionComponent' );
			
			if( shrineType == ST_SummerShrine )
			{
				theGame.UnlockAchievement('ACH_SUMMER');
				AddStoryAbility("story_s31", 1);
				PlayEffect('shrine_fire_use');
				StopEffect('shrine_fire');
				StopEffect('shrine_fire_default');
			}
			else
			{
				theGame.UnlockAchievement('ACH_WINTER');
				AddStoryAbility("story_s32", 1);
				PlayEffect('shrine_ice_use');
				StopEffect('shrine_ice');
				StopEffect('shrine_ice_default');
			}
			
			interactionComponent.SetEnabled( false );
		}
	}
}