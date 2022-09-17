#include "Loading.as"
#include "Utilities.as"
#include "ServerLoadCfgMap.as"
#include "ClientReceiveMap.as"
#include "ClientGenerateChunks.as"
#include "FlatMap.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerLoadCfgMap("ephtracy.cfg"));
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
	loadingManager.AddStep(ClientGenerateChunks());
}
