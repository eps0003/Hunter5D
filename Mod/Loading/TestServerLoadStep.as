#include "Loading.as"

shared class TestServerLoadStep : ServerLoadStep
{
	TestServerLoadStep(string message)
	{
		super(message);
	}

	void Update()
	{
		progress += 0.005f;
		complete = progress >= 1.0f;
	}
}
