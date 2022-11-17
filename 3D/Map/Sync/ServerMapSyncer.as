shared class ServerMapSyncer
{
	private uint blocksPerPacket = 20000;

	private u16 packetIndex = 0;
	private dictionary packetsSynced;

	private u16 totalPackets = 0;

	private Map@ map = Map::getMap();
	private CRules@ rules = getRules();

	void RemovePlayer(CPlayer@ player)
	{
		string username = player.getUsername();
		packetsSynced.delete(username);
		print("Removed sync player: " + username);
	}

	bool isSyncing(CPlayer@ player)
	{
		u16 packetCount;
		return packetsSynced.get(player.getUsername(), packetCount) && packetCount < totalPackets;
	}

	bool isSynced(CPlayer@ player)
	{
		u16 packetCount;
		return packetsSynced.get(player.getUsername(), packetCount) && packetCount >= totalPackets;
	}

	private CPlayer@[] getPlayersNotSynced()
	{
		CPlayer@[] players;

		// dictionary getKeys() causes crash so loop through online players instead
		uint n = getPlayerCount();
		for (uint i = 0; i < n; i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null || isSynced(player)) continue;

			players.push_back(player);
		}

		return players;
	}

	void Sync()
	{
		CPlayer@[] players = getPlayersNotSynced();
		if (players.empty()) return;

		// Initialize total packet count
		if (totalPackets == 0)
		{
			totalPackets = Maths::Ceil(map.blockCount / float(blocksPerPacket));
		}

		CBitStream bs;

		// Get range of blocks to sync
		uint firstBlock = packetIndex * blocksPerPacket;
		uint lastBlock = Maths::Min(firstBlock + blocksPerPacket, map.blockCount);

		uint airCount = 0;

		// Loop through these blocks and serialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			SColor block = map.getBlock(i);

			// Count air blocks
			if (!map.isVisible(block))
			{
				airCount++;
				continue;
			}

			// Write air
			if (airCount > 0)
			{
				// Assumes last octet is all zeros
				bs.write_u32(airCount);
				airCount = 0;
			}

			// Write block
			bs.write_u32(block.color);
		}

		// Write remaining air
		if (airCount > 0)
		{
			bs.write_u32(airCount);
			airCount = 0;
		}

		// Make stream with initial data for players being sent their first packet
		CBitStream bsInit;
		bsInit.write_u16(map.dimensions.x);
		bsInit.write_u16(map.dimensions.y);
		bsInit.write_u16(map.dimensions.z);
		bsInit.write_u32(firstBlock);
		bsInit.writeBitStream(bs, 0, bs.getBitsUsed());

		// Sync to players
		// dictionary getKeys() causes crash so loop through online players instead
		uint n = players.size();
		for (uint i = 0; i < n; i++)
		{
			CPlayer@ player = players[i];
			string username = player.getUsername();

			u16 packetCount;
			if (!packetsSynced.get(username, packetCount))
			{
				packetCount = 0;
			}

			CBitStream bsToSync = packetCount == 0 ? bsInit : bs;

			CBitStream bsWithSize;
			bsWithSize.write_u32(bsToSync.getBitsUsed());
			bsWithSize.writeBitStream(bsToSync, 0, bsToSync.getBitsUsed());

			rules.SendCommand(rules.getCommandID("sync map"), bsWithSize, player);

			packetsSynced.set(username, packetCount + 1);
		}

		// Increment packet index
		packetIndex++;
		if (packetIndex >= totalPackets)
		{
			packetIndex = 0;
		}
	}
}
