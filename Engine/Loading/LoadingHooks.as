#include "Loading.as"

LoadingManager@ loadingManager;

void onInit(CRules@ this)
{
	this.addCommandID("player loaded");
	this.addCommandID("sync load step");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@loadingManager = Loading::getManager();
}

void onTick(CRules@ this)
{
	loadingManager.Update();
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
	else if (!isServer() && cmd == this.getCommandID("sync load step"))
	{
		LoadStep@ step = loadingManager.getCurrentStep();
		if (step is null) return;

		ServerLoadStep@ serverStep = cast<ServerLoadStep>(step);
		if (serverStep is null) return;

		serverStep.deserialize(params);
	}
}
