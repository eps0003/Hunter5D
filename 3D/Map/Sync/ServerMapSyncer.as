shared class ServerMapSyncer
{
	private uint blocksPerPacket = 30000;

	private u16 packetIndex = 0;
	private dictionary packetsSynced;

	private u16 totalPackets;
	private SColor block;
	private CBitStream bs;
	private uint firstBlock;
	private uint lastBlock;
	private uint airCount = 0;

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
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null || isSynced(player)) continue;

			players.push_back(player);
		}

		return players;
	}

	void Init()
	{
		totalPackets = Maths::Ceil(map.blockCount / float(blocksPerPacket));
	}

	void Sync()
	{
		CPlayer@[] players = getPlayersNotSynced();
		if (players.empty()) return;

		bs.Clear();

		// Get range of blocks to sync
		firstBlock = packetIndex * blocksPerPacket;
		lastBlock = Maths::Min(firstBlock + blocksPerPacket, map.blockCount);

		// Loop through these blocks and serialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			block = map.getBlock(i);

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
		for (uint i = 0; i < players.size(); i++)
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
