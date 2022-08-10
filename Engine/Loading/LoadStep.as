#include "ClientLoadStep.as"
#include "ServerLoadStep.as"

shared class LoadStep
{
	private string message = "Loading...";
	private f32 progress = 0.0f;
	private bool complete = false;

	LoadStep(string message)
	{
		this.message = message;
	}

	u8 getType()
	{
		error("Load step doesn't have a type set: " + message);
		return 0;
	}

	string getMessage()
	{
		return message;
	}

	float getProgress()
	{
		return progress;
	}

	bool isComplete()
	{
		return complete;
	}

	void Init()
	{

	}

	void Update()
	{

	}
}
