#include "Utilities.as"
#include "LoadStep.as"

shared class LoadingManager
{
	private CPlayer@[] loadedPlayers;
	private LoadStep@[] loadSteps;
	private u8 index = 0;

	private CRules@ rules = getRules();

	~LoadingManager()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			rules.set_bool("_loaded" + player.getUsername(), false);
		}
	}

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
		if (isMyPlayerLoaded()) return;

		SkipSteps();

		LoadStep@ step = getCurrentStep();
		if (step is null)
		{
			// Set loaded the tick after the last step is complete
			if (getLocalPlayer() !is null)
			{
				SetMyPlayerLoaded();
			}
			return;
		}

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

	bool isServerLoaded()
	{
		return rules.get_u8("server load index") >= loadSteps.size();
	}

	bool isPlayerLoaded(CPlayer@ player)
	{
		return player !is null && rules.get_bool("_loaded" + player.getUsername());
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

		rules.set_bool("_loaded" + player.getUsername(), true);

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
		if (!isPlayerLoaded(player))
		{
			error("Attempted to remove loaded player who isn't loaded: " + player.getUsername());
			printTrace();
			return;
		}

		rules.set_bool("_loaded" + player.getUsername(), false);
	}

	bool areAllPlayersLoaded()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			if (!isPlayerLoaded(player))
			{
				return false;
			}
		}

		return true;
	}

	bool areAnyPlayersLoaded()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			if (isPlayerLoaded(player))
			{
				return true;
			}
		}

		return false;
	}

	uint getLoadedPlayerCount()
	{
		return getLoadedPlayers().size();
	}

	CPlayer@[] getLoadedPlayers()
	{
		CPlayer@[] players;

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			if (isPlayerLoaded(player))
			{
				players.push_back(player);
			}
		}

		return players;
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
