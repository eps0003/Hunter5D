#include "Loading.as"

LoadingManager@ loadingManager;

void onInit(CRules@ this)
{
	Command::Add("player loaded");
	Command::Add("sync load step");

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
	if (Command::equals(cmd, "player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		if (loadingManager.isPlayerLoaded(player)) return;

		loadingManager.SetPlayerLoaded(player);
	}
	else if (!isServer() && Command::equals(cmd, "sync load step"))
	{
		LoadStep@ step = loadingManager.getCurrentStep();
		if (step is null) return;

		ServerLoadStep@ serverStep = cast<ServerLoadStep>(step);
		if (serverStep is null) return;

		serverStep.deserialize(params);
	}
}
