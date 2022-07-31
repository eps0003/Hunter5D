#include "Loading.as"

LoadingManager@ loadingManager;

void onInit(CRules@ this)
{
	this.addCommandID("player loaded");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@loadingManager = Loading::getManager();
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (loadingManager.isPlayerLoaded(player))
	{
		loadingManager.RemoveLoadedPlayer(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		if (loadingManager.isPlayerLoaded(player)) return;

		loadingManager.SetPlayerLoaded(player);
	}
}
