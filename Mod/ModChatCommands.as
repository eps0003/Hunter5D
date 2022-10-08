#include "ChatCommand.as"
#include "Camera.as"

class FOVCommand : ChatCommand
{
	FOVCommand()
	{
		super("fov", "Change camera field of view.");
		AddAlias("fieldofview");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!player.isMyPlayer()) return;

		Camera@ camera = Camera::getCamera();

		if (args.size() == 0)
		{
			client_AddToChat("Your current field of view is " + camera.getFOV(), ConsoleColour::INFO);
		}
		else
		{
			float val = parseFloat(args[0]);
			if (val > 0 && val <= 140)
			{
				camera.SetFOV(val);
				client_AddToChat("Your field of view has been set to " + val, ConsoleColour::INFO);
			}
			else
			{
				client_AddToChat("Please specify a field of view between 0 and 140", ConsoleColour::ERROR);
			}
		}
	}
}

class RenderDistanceCommand : ChatCommand
{
	RenderDistanceCommand()
	{
		super("distance", "Change render distance.");
		AddAlias("renderdistance");
		AddAlias("dist");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!player.isMyPlayer()) return;

		Camera@ camera = Camera::getCamera();

		if (args.size() == 0)
		{
			client_AddToChat("Your current render distance is " + camera.getRenderDistance(), ConsoleColour::INFO);
		}
		else
		{
			float val = parseFloat(args[0]);
			if (val > 0)
			{
				camera.SetRenderDistance(val);
				client_AddToChat("Your render distance has been set to " + val, ConsoleColour::INFO);
			}
			else
			{
				client_AddToChat("Please specify a render distance larger than 0", ConsoleColour::ERROR);
			}
		}
	}
}
