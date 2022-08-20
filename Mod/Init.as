#include "Loading.as"
#include "Utilities.as"
#include "ServerGenerateMap.as"
#include "ClientReceiveMap.as"
#include "ClientInitBlockFaces.as"
#include "ClientGenerateChunks.as"
#include "TestMapGenerator.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	loadingManager.AddStep(ServerGenerateMap(TestMapGenerator(24, 8, 24)));
	if (!isLocalHost()) loadingManager.AddStep(ClientReceiveMap());
	loadingManager.AddStep(ClientInitBlockFaces());
	loadingManager.AddStep(ClientGenerateChunks());
}
