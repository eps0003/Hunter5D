#include "Utilities.as"
#include "LoadStep.as"

shared class LoadingManager
{
	private LoadStep@[] loadSteps;
	private u8 index = 0;
	private dictionary loadedPlayers;
	private LoadStep@ prevStep;

	private CRules@ rules = getRules();

	LoadingManager()
	{
		rules.set_u8("server load index", 0);
		rules.Sync("server load index", true);
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
		if (isClient() && isMyPlayerLoaded()) return;
		if (!isClient() && isServerLoaded()) return;

		SkipSteps();

		LoadStep@ step = getCurrentStep();
		if (step is null)
		{
			// Set loaded the tick after the last step is complete
			if (getLocalPlayer() !is null)
			{
				SetMyPlayerLoaded();
				rules.AddScript("Client.as");
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
			if (prevStep !is step)
			{
				step.Init();
			}

			step.Load();

			if (step.isComplete())
			{
				index++;
				SkipSteps();
			}

			if (serverStep !is null)
			{
				CBitStream bs;
				serverStep.Serialize(bs);
				Command::Send("sync load step", bs, true);
			}
		}

		if (isServer())
		{
			rules.set_u8("server load index", index);
			rules.Sync("server load index", true);

			rules.AddScript("Server.as");
		}

		@prevStep = step;
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
		return player !is null && loadedPlayers.exists(player.getUsername());
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

		loadedPlayers.set(player.getUsername(), true);

		if (isServer())
		{
			print("Player loaded: " + player.getUsername());
		}

		if (player.isMyPlayer())
		{
			CBitStream bs;
			bs.write_netid(player.getNetworkID());
			Command::Send("player loaded", bs, true);
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

		loadedPlayers.delete(player.getUsername());
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
