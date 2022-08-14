#include "Map.as"

shared class MapSyncer
{
	private Map@ map = Map::getMap();
	private CRules@ rules = getRules();

	private uint blocksPerPacket = 30;
	private uint totalPackets = totalPackets = Maths::Ceil(map.blockCount / float(blocksPerPacket));

	private u16 index = 0;

	private dictionary syncPlayers;

	void AddPlayer(CPlayer@ player)
	{
		// No need to sync to localhost player
		if (player.isMyPlayer()) return;

		string username = player.getUsername();
		if (syncPlayers.exists(username))
		{
			debug("Attempted to add player to map syncer who is already being synced to: " + username);
			return;
		}

		u16 prevIndex = index == 0 ? totalPackets - 1 : index - 1;
		syncPlayers.set(username, prevIndex);

		print("Added sync player: " + username);
	}

	void RemovePlayer(CPlayer@ player)
	{
		string username = player.getUsername();
		if (!syncPlayers.exists(username))
		{
			debug("Attempted to remove player from map syncer who is isn't being synced to: " + username);
			return;
		}

		syncPlayers.delete(player.getUsername());

		print("Removed sync player: " + username);
	}

	void AddAllPlayers()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			AddPlayer(player);
		}
	}

	bool isSyncing(CPlayer@ player)
	{
		return syncPlayers.exists(player.getUsername());
	}

	void ServerSync()
	{
		if (syncPlayers.isEmpty()) return;

		CBitStream bs;

		// Get range of blocks to sync
		uint firstBlock = index * blocksPerPacket;
		uint lastBlock = Maths::Min(firstBlock + blocksPerPacket, map.blockCount);

		// Loop through these blocks and serialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			SColor block = map.getBlock(i);

			bool visible = map.isVisible(block);
			bs.write_bool(visible);

			if (visible)
			{
				bs.write_u32(block.color);
			}
		}

		// Sync to players
		// dictionary getKeys() causes crash so loop through online players instead
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			u16 playerIndex;
			if (!syncPlayers.get(player.getUsername(), playerIndex)) continue;

			rules.SendCommand(rules.getCommandID("sync map"), bs, player);
			print("Sync map index " + index + " to " + player.getUsername());

			// Remove player if they have finished syncing
			if (playerIndex == index)
			{
				RemovePlayer(player);
			}
		}

		// Increment index
		index = (index + 1) % totalPackets;
	}
}
