#include "Utilities.as"
#include "LoadStep.as"

shared class LoadingManager
{
	private CPlayer@[] loadedPlayers;
	private LoadStep@[] loadSteps;
	private u8 index = 0;

	private CRules@ rules = getRules();

	void AddStep(LoadStep@ step)
	{
		loadSteps.push_back(step);
		print("Added load step: " + step.getMessage());
	}

	u8 getStepIndex()
	{
		return index;
	}

	LoadStep@ getCurrentStep()
	{
		return index < loadSteps.size() ? loadSteps[index] : null;
	}

	void Update()
	{
		SkipSteps();

		LoadStep@ step = getCurrentStep();
		if (step is null) return;

		ClientLoadStep@ clientStep = cast<ClientLoadStep>(step);
		ServerLoadStep@ serverStep = cast<ServerLoadStep>(step);

		// Client: Update client steps
		// Server: Update server steps
		// Localhost: Update all steps
		bool updateClient = isClient() && clientStep !is null;
		bool updateServer = isServer() && serverStep !is null;
		if (updateClient || updateServer)
		{
			step.Update();

			if (step.isComplete())
			{
				index++;
				SkipSteps();
			}

			if (serverStep !is null)
			{
				CBitStream bs;
				serverStep.Serialize(bs);
				rules.SendCommand(rules.getCommandID("sync load step"), bs, true);
			}
		}

		if (isServer())
		{
			rules.set_u8("server load index", index);
			rules.Sync("server load index", true);
		}

		if (getGameTime() % (getTicksASecond() / 2) == 0)
		{
			print(step.getMessage() + " (" + Maths::Floor(step.getProgress() * 100) + "%)");
		}
	}

	private void SkipSteps()
	{
		while (index < loadSteps.size())
		{
			LoadStep@ step = loadSteps[index];
			ClientLoadStep@ clientStep = cast<ClientLoadStep>(step);
			ServerLoadStep@ serverStep = cast<ServerLoadStep>(step);

			// Server
			if (!isClient())
			{
				if (clientStep is null)
				{
					// Cannot skip server steps
					break;
				}
				else
				{
					// Skip client step
					index++;
					continue;
				}
			}

			// Client
			if (!isServer())
			{
				if (serverStep is null)
				{
					// Cannot skip client steps
					break;
				}
				else if (index < rules.get_u8("server load index"))
				{
					// Skip completed server step
					index++;
					continue;
				}
			}

			break;
		}
	}

	bool isLoaded()
	{
		return index >= loadSteps.size();
	}

	bool isPlayerLoaded(CPlayer@ player)
	{
		for (uint i = 0; i < loadedPlayers.size(); i++)
		{
			if (loadedPlayers[i] is player)
			{
				return true;
			}
		}
		return false;
	}

	bool isMyPlayerLoaded()
	{
		return isPlayerLoaded(getLocalPlayer());
	}

	void SetPlayerLoaded(CPlayer@ player)
	{
		if (isPlayerLoaded(player))
		{
			error("Attempted to set player loaded who is already loaded: " + player.getUsername());
			printTrace();
			return;
		}

		loadedPlayers.push_back(player);

		if (isServer())
		{
			print("Player loaded: " + player.getUsername());
		}

		if (player.isMyPlayer())
		{
			CBitStream bs;
			bs.write_netid(player.getNetworkID());
			rules.SendCommand(rules.getCommandID("player loaded"), bs, true);
		}
	}

	void SetMyPlayerLoaded()
	{
		SetPlayerLoaded(getLocalPlayer());
	}

	void RemoveLoadedPlayer(CPlayer@ player)
	{
		for (uint i = 0; i < loadedPlayers.size(); i++)
		{
			if (loadedPlayers[i] is player)
			{
				loadedPlayers.removeAt(i);
				break;
			}
		}

		error("Attempted to remove loaded player who isn't loaded: " + player.getUsername());
		printTrace();
	}

	bool areAllPlayersLoaded()
	{
		return loadedPlayers.size() == getPlayerCount();
	}

	bool areAnyPlayersLoaded()
	{
		return loadedPlayers.size() > 0;
	}

	uint getLoadedPlayerCount()
	{
		return loadedPlayers.size();
	}

	CPlayer@[] getLoadedPlayers()
	{
		return loadedPlayers;
	}
}

namespace Loading
{
	shared LoadingManager@ getManager()
	{
		LoadingManager@ manager;
		if (!getRules().get("loading manager", @manager))
		{
			@manager = LoadingManager();
			getRules().set("loading manager", @manager);
		}
		return manager;
	}
}
