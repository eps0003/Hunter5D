#include "Loading.as"
#include "LoadSteps.as"

shared class ServerLoadStep1 : ServerLoadStep
{
	ServerLoadStep1()
	{
		super("Server load step 1");
	}

	u8 getType()
	{
		return LoadStepType::ServerLoadStep1;
	}

	void Update()
	{
		progress += 0.005f;
		complete = progress >= 1.0f;
	}
}
