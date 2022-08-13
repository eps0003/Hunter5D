#include "Loading.as"
#include "TestClientLoadStep.as"
#include "TestServerLoadStep.as"

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	LoadingManager@ loadingManager = Loading::getManager();
	// loadingManager.AddStep(TestClientLoadStep("Client 1"));
	// loadingManager.AddStep(TestServerLoadStep("Server 2"));
	// loadingManager.AddStep(TestClientLoadStep("Client 3"));
	// loadingManager.AddStep(TestServerLoadStep("Server 4"));
	// loadingManager.AddStep(TestClientLoadStep("Client 5"));
	// loadingManager.AddStep(TestServerLoadStep("Server 6"));
}
