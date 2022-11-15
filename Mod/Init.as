#include "Loading.as"
#include "Utilities.as"
#include "ServerLoadCfgMap.as"
#include "ClientReceiveMap.as"
#include "ClientGenerateChunks.as"
#include "FlatMap.as"
#include "ModChatCommands.as"

uint mapIndex = 0;
const string[] maps = {
	"ephtracy.cfg",
	"Arab.cfg"
};

void onInit(CRules@ this)
{
	onRestart(this);

	ChatCommands::RegisterCommand(FOVCommand());
	ChatCommands::RegisterCommand(RenderDistanceCommand());
}

void onRestart(CRules@ this)
{
	string map = maps[mapIndex];
	mapIndex = (mapIndex + 1) % maps.size();

	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerLoadCfgMap(map));
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
	loadingManager.AddStep(ClientGenerateChunks());
}
