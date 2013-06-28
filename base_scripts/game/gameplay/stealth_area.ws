
enum EStealthArea
{
	Stealth_Area_cover,
	Stealth_Area,
};

enum EStealthCoverType
{
	SCT_High,
	SCT_Low,
	SCT_Niche,
};

enum EStealthCoverSide
{
	SCS_Right,
	SCS_Left,
	SCS_Both,
};

struct SStealthCoverParams
{
	editable var type : EStealthCoverType;
	editable var side : EStealthCoverSide;
	editable var hidesPlayer : bool;
	
	default hidesPlayer = true;
};

//StealthArea sets sneak state on player
class CStealthArea extends CEntity
{
	editable var stealthAreaType : EStealthArea;
	editable var coverParams : SStealthCoverParams;	
	
	function IsHigh() : bool
	{
		return coverParams.type == SCT_High;
	}
		
	function IsLow() : bool
	{
		return coverParams.type == SCT_Low;
	}
	
	function IsNiche() : bool
	{
		return coverParams.type == SCT_Niche;
	}
	
	function IsBoth() : bool
	{
		return coverParams.side == SCS_Both;
	}
	
	function GetOpositeSide( params : SStealthCoverParams ) : SStealthCoverParams
	{
		if( params.side == SCS_Right )
			params.side = SCS_Left;
		else
			params.side = SCS_Right;
			
		return params;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity = activator.GetEntity();			
		var currentPlayerState : EPlayerState;
				
		if( affectedEntity.IsA( 'CPlayer' ) )
		{		
			if (stealthAreaType == Stealth_Area)
			{
				theHud.m_hud.ShowTutorial("tut50", "", false);
				//theHud.ShowTutorialPanelOld( "tut50", "" );
				thePlayer.SetSneakMode( true );
				currentPlayerState = thePlayer.GetCurrentPlayerState();
				
				if( currentPlayerState != PS_Sneak && currentPlayerState != PS_PlayerCarry )
				{
					thePlayer.ChangePlayerState( PS_Sneak );
					theSound.PlayMusicNonQuest( "sneak" );
				}
			}
			else if( thePlayer.GetCurrentPlayerState() == PS_Sneak && !thePlayer.IsEnteringObstacle() )
			{
				if( area.GetName() != "inner_trigger" )
				{
					thePlayer.EnterObstacle( this );
				}
			}
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity = activator.GetEntity();
		
		if( affectedEntity.IsA( 'CPlayer' ))
		{
			if (stealthAreaType == Stealth_Area)
			{
				thePlayer.SetSneakMode( false );
				
				if( thePlayer.GetCurrentPlayerState() == PS_Sneak )
				{
					thePlayer.ChangePlayerState( PS_Exploration );			
				}
				theSound.StopMusic( "sneak" );
			}
			else if( thePlayer.GetCurrentPlayerState() == PS_Sneak )
			{	
				//if( area.GetName() == "inner_trigger" )
				//{
					thePlayer.ExitObstacle( coverParams.hidesPlayer, false );
				//}
			}
		}
	}
		
	private function GetOuterTriggerArea() : CTriggerAreaComponent
	{
		return (CTriggerAreaComponent)GetComponent("outer_trigger");
	}
	
	private function GetInnerTriggerArea() : CTriggerAreaComponent
	{
		return (CTriggerAreaComponent)GetComponent("inner_trigger");
	}

	function GetWallSidePoints( out a,b, normal : Vector ) : bool
	{
		var area : CTriggerAreaComponent = GetInnerTriggerArea();
		var points : array<Vector>;		
		var i,s : int;
		var wallSide : CComponent;
		var wallSidePos : Vector;
		
		area.GetWorldPoints( points );
		wallSide = GetComponent('wall_side');		
		
		s = points.Size();
		if( s == 4 && wallSide )
		{
			points.PushBack(points[0]); // append first at end
			points.PushBack(points[1]); // append second at end
			wallSidePos = wallSide.GetWorldPosition();
			for( i=0; i<s; i+=1 )
			{
				if( VecDistanceToEdge( wallSidePos, points[i], points[i+1] ) < 0.1 )
				{
					a = points[i];
					b = points[i+1];
					normal = VecNormalize( points[i+2]-b );
					return true;
				}
			}
			
		}
		
		return false;
	}
}
