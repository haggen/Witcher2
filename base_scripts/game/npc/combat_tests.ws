class CKnightTest extends CEntity
{
	//Camera test.
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('ChangeCamera', 1.0, true);
		//this.AddTimer('ApplyAppearance', 10.0, false);
		super.OnSpawned(spawnData);
	}
	timer function ChangeCamera(td : float)
	{
		theCamera.SetCameraState(CS_Draug);
		Log("CAMERA DRAUG");
	}
	timer function ChangeAppearance(td : float)
	{
		//thePlayer.ApplyAppearance("FPP_test");
	}
}

