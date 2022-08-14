#include "Loading.as"
#include "Utilities.as"
#include "ServerGenerateMap.as"
#include "ClientReceiveMap.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerGenerateMap());
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
}
