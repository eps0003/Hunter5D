#include "Loading.as"
#include "LoadSteps.as"

shared class ClientLoadStep1 : ClientLoadStep
{
	ClientLoadStep1()
	{
		super("Client load step 1");
	}

	u8 getType()
	{
		return LoadStepType::ClientLoadStep1;
	}

	void Update()
	{
		progress += 0.01f;
		complete = progress >= 1.0f;
	}
}
