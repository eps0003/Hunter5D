#include "Utilities.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	onTick(this);
}

void onTick(CRules@ this)
{
	this.set_f32("inter_frame_time", 0);
	this.set_f32("inter_game_time", getGameTime());
}

void onRender(CRules@ this)
{
	if (isTickPaused()) return;

	float correction = getRenderExactDeltaTime() * getTicksASecond();
	this.add_f32("inter_frame_time", correction);
	this.add_f32("inter_game_time", correction);
}
