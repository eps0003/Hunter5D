#include "Mouse.as"

#define CLIENT_ONLY

Mouse@ mouse;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@mouse = Mouse::getMouse();
}

void onTick(CRules@ this)
{
	mouse.CalculateVelocity();
}

void onRender(CRules@ this)
{
	if (mouse !is null)
	{
		// Called in onRender because onTick doesn't run when paused in localhost
		mouse.UpdateVisibility();
	}
}
