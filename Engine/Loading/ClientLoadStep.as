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

	float getFPS()
	{
		// Clamp the framerate because it uncaps while the window is not in focus
		float t = getRenderSmoothDeltaTime();
		return t > 0.0f ? Maths::Min(1.0f / t, 144.0f) : 0.0f;
	}
}
