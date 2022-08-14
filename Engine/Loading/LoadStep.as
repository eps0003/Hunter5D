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

	string getMessage()
	{
		return message;
	}

	float getProgress()
	{
		return Maths::Clamp01(progress);
	}

	bool isComplete()
	{
		return complete;
	}

	void Load()
	{

	}
}
