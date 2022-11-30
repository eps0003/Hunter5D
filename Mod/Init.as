#include "Loading.as"
#include "Utilities.as"
#include "ServerLoadCfgMap.as"
#include "ClientReceiveMap.as"
#include "ClientGenerateChunks.as"
#include "ModChatCommands.as"

void onInit(CRules@ this)
{
	onRestart(this);

	ChatCommands::RegisterCommand(FOVCommand());
	ChatCommands::RegisterCommand(RenderDistanceCommand());
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerLoadCfgMap(getMap().getMapName()));
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
	loadingManager.AddStep(ClientGenerateChunks());
}
