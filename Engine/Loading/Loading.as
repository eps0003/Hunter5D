#include "Utilities.as"

shared class LoadingManager
{
	private CPlayer@[] loadedPlayers;

	private CRules@ rules = getRules();

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
		else if (player.isMyPlayer())
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
