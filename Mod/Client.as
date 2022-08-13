#include "Loading.as"

#define CLIENT_ONLY

LoadingManager@ loadingManager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@loadingManager = Loading::getManager();
}

void onRender(CRules@ this)
{
	if (loadingManager is null) return;

	CPlayer@[] players = loadingManager.getLoadedPlayers();

	GUI::DrawText("Loaded: " + players.size(), Vec2f(10, 10), color_white);

	for (uint i = 0; i < players.size(); i++)
	{
		GUI::DrawText(players[i].getUsername(), Vec2f(10, 25 + 15 * i), color_white);
	}
}
