#include "Loading.as"
#include "ClientLoadStep1.as"
#include "ServerLoadStep1.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ClientLoadStep1());
	loadingManager.AddStep(ServerLoadStep1());
	loadingManager.AddStep(ClientLoadStep1());
	loadingManager.AddStep(ServerLoadStep1());
	loadingManager.AddStep(ClientLoadStep1());
	loadingManager.AddStep(ServerLoadStep1());
}
