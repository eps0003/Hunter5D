#include "Loading.as"
#include "Utilities.as"
#include "ServerLoadMagicaVoxelMap.as"
#include "ClientReceiveMap.as"
#include "ClientInitBlockFaces.as"
#include "ClientGenerateChunks.as"
#include "FlatMap.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerLoadMagicaVoxelMap("ephtracy.cfg"));
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
	loadingManager.AddStep(ClientInitBlockFaces());
	loadingManager.AddStep(ClientGenerateChunks());
}
