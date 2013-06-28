/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Renderer exports
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

import function RendererDecalSpawn( orign, dirFront, dirUp : Vector, width, height, farZ, lifeLength, fadeTime : float, material : IMaterial ) : bool;

/*latent function DecalSpawnTest()
{
	var mat : IMaterial;		
	var res : bool;
	mat=(IMaterial)LoadResource("materials\testdecal"); 
	res = RendererDecalSpawn( thePlayer.GetWorldPosition()+Vector(0,0,1), Vector(0,0,-1), Vector(1,0,0), 1.0, 1.0, 2.0, mat );
	Log("RendererDecalSpawn "+res);
}*/