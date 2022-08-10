#include "Loading.as"
#include "LoadSteps.as"

shared class TestClientLoadStep : ClientLoadStep
{
	TestClientLoadStep(string message)
	{
		super(message);
	}

	void Update()
	{
		progress += 0.01f;
		complete = progress >= 1.0f;
	}
}
