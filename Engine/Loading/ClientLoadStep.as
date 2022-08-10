#include "LoadStep.as"

shared class ClientLoadStep : LoadStep
{
	ClientLoadStep(string message)
	{
		super(message);
	}

	bool isComplete()
	{
		return LoadStep::isComplete() || !isClient();
	}
}
