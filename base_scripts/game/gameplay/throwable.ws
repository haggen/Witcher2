abstract class CThrowable extends CGameplayEntity
{
	editable var ThrownTemplate	:	CEntityTemplate;
}

state Flying in CThrowable
{
	entry function StartFlying( destination : Vector );
}