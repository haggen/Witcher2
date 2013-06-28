// klasa i funkcje do obslugi petard 

/* 		Kartacz / Grapeshot - wybuchowa (gotowa)
		Czarcia Purchawa / Puffball - rozpyla chmure trucizny (gotowa)
		Samum / Samum - dezorientuje przeciwnikow (gotowa)
		Ta�cz�ca Gwiazda / Dancing Star - podpala obszar (gotowa)
	Smoczy Sen / DragonDream - tworzy chmur� latwopalnego gazu
		�wietlik / Firefly - o�lepia przeciwnik�w ( troch� jak samum )(gotowa)
		G�szcz / WildGrowth - pn�cza unieruchamiaj�ce przeciwnik�w (gotowa)
		Flara / Flare - generuje �wiat�o (gotowe)
	Srebrny Py� / SilverDust - cia�a na kt�re u�yto tej bomby rani� trupojady, zamiast przywracac im HP (gdy u�ywaj� ich jako po�ywienia)
		Czerwona mg�a / Red Haze - nastawia przeciwnik�w w zasiegu ra�enia przeciwko sobie (gotowa)
	�mierdziuch / Stinker - tworzy chmur�, z kt�rej uciekaj� przeciwnicy + maj� modyfikator do cech
		Bomba Wodna / Water Bomb - gasi otwarte �r�d�a �wiat�a (gotowa)
		Krzyk / Screamer - og�usza przeciwnik�w w zasi�gu (wy��cza zmys� s�uchu na troch�)(gotowa)
*/

/*enum EBombType
{
	BT_Grapeshot,
	BT_Puffball,
	BT_Samum,
	BT_DancingStar,
	BT_DragonDream,
	BT_Firefly,
	BT_WildGrowth,
	BT_Flare,
	BT_SilverDust,
	BT_RedHaze,
	BT_Stinker,
	BT_WaterBomb,
	BT_Screamer,
	BT_Arachas_aoe,
};

class CBomb extends CProjectile
{
	editable var 	bombType 				: EBombType;
	editable var 	EffectRadius 			: float;
	editable var 	velocity				: float;
	editable var 	range					: float;
	editable var 	OverTimeEffectEntity 	: CEntityTemplate; // okresla tworzone entity w miejscu wybuchu

	private var		bombTarget				: CNode;
	
	default 		EffectRadius 			= 3;
	default 		velocity 				= 18;
	default			range					= 100;
	
	function ThrowAtNode( angle : float, target : CNode )
	{	
		this.bombTarget = target;
		ShootProjectileAtNode( angle, velocity, 0.0, target, range );

		// make the bomb leave a trail as it flies
		PlayEffect( 'trail' );
		PlayEffect( 'ignite' );
	}
	
	function ThrowAtPosition( angle : float, target : Vector )
	{		
		this.bombTarget = NULL;
		
		ShootProjectileAtPosition( angle, velocity, 0.0, target );
		
		// make the bomb leafe a trail as it flies
		PlayEffect( 'trail' );
		PlayEffect( 'ignite' );
	}
	
	// Event called when bomb reaches its target
	event OnRangeReached( inTheAir : bool )
	{
		var selectedTorch : CSneakLights;
		var area : CEntityTemplate;
		var areaPos : Vector;
		var targetPos : Vector;
		var effectArea : CEntity;
		var m : Matrix;
		
		m = GetLocalToWorld();
		
		if ( this.bombType == BT_WaterBomb )
		{
			if ( bombTarget )
			{
				selectedTorch = ( (CSneakLights)bombTarget );
				selectedTorch.PlayEffect( 'water_splash' );
				selectedTorch.TurnLightOff();
			}
			else
			{
				// kod na splash na ziemi
			}
		}
		else 
		{	
			area = this.OverTimeEffectEntity;
			targetPos = GetWorldPosition();
			effectArea = theGame.CreateEntity( area, targetPos );
			this.Destroy();
		}
	}
}

state Flying in CBomb
{
	entry function StartFlying()
	{
		var mat	:	Matrix;
		var pos	:	Vector;
		
		mat = thePlayer.GetBoneWorldMatrix( 'l_weapon' );
		parent.TeleportWithRotation( MatrixGetTranslation( mat ), MatrixGetRotation( mat ) );
		Sleep(0.0001);
		
		pos = ( RotForward( thePlayer.GetWorldRotation() ) * 15 ) + thePlayer.GetWorldPosition();
		parent.ThrowAtPosition( 15, pos );
	}
}*/