#include "Map.as"

shared class MapSyncer
{
	private Map@ map = Map::getMap();
	private CRules@ rules = getRules();

	private uint blocksPerPacket = 20000;

	private u16 index = 0;
	private CBitStream@[] clientPackets;

	private dictionary packetsSynced;

	void AddPlayer(CPlayer@ player)
	{
		// No need to sync to localhost player
		if (player.isMyPlayer()) return;

		string username = player.getUsername();

		if (isSyncing(player))
		{
			debug("Attempted to add player to map syncer who is already being synced to: " + username);
			return;
		}

		packetsSynced.set(username, 0);
		print("Added sync player: " + username);

		// Sync map dimensions
		CBitStream bs;
		map.dimensions.Serialize(bs);
		rules.SendCommand(rules.getCommandID("init map"), bs, player);
	}

	void RemovePlayer(CPlayer@ player)
	{
		string username = player.getUsername();
		if (!isSyncing(player))
		{
			debug("Attempted to remove player from map syncer who is isn't being synced to: " + username);
			return;
		}

		packetsSynced.delete(player.getUsername());
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
		return packetsSynced.exists(player.getUsername());
	}

	bool isSynced(CPlayer@ player)
	{
		uint totalPackets = getTotalPackets();
		u16 count;
		return (
			totalPackets > 0 &&
			packetsSynced.get(player.getUsername(), count) &&
			count >= totalPackets
		);
	}

	float getProgress(CPlayer@ player)
	{
		uint totalPackets = getTotalPackets();
		if (totalPackets == 0) return 0.0f;

		u16 count = 0;
		packetsSynced.get(player.getUsername(), count);
		return count / float(totalPackets);
	}

	uint getTotalPackets()
	{
		return Maths::Ceil(map.blockCount / float(blocksPerPacket));
	}

	void ServerSync()
	{
		CPlayer@[] players = getSyncPlayers();
		if (players.empty()) return;

		uint totalPackets = getTotalPackets();

		// Serialize the index
		CBitStream bs;
		bs.write_u16(index);

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
		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ player = players[i];
			string username = player.getUsername();

			u16 count;
			if (!packetsSynced.get(username, count)) continue;

			rules.SendCommand(rules.getCommandID("sync map"), bs, player);

			packetsSynced.set(username, count + 1);
		}

		// Increment index
		index = (index + 1) % totalPackets;
	}

	private CPlayer@[] getSyncPlayers()
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

	void ClientReceivePacket(CBitStream@ packet)
	{
		CBitStream bs = packet;
		bs.SetBitIndex(packet.getBitIndex());
		clientPackets.push_back(bs);
	}

	void ClientProcessPackets()
	{
		// No packets to process
		if (clientPackets.empty()) return;

		// Local player doesn't exist yet
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;

		string username = player.getUsername();

		// Get number of packets processed
		u16 count;
		if (!packetsSynced.get(username, count))
		{
			count = 0;
		}

		// Check if sync is complete
		if (count >= getTotalPackets()) return;

		// Get and remove next packet
		CBitStream@ packet = clientPackets[0];
		clientPackets.removeAt(0);

		// Begin processing packet
		u16 index;
		if (!packet.saferead_u16(index)) return;

		// Get range of blocks to initialize
		uint firstBlock = index * blocksPerPacket;
		uint lastBlock = Maths::Min(firstBlock + blocksPerPacket, map.blockCount);

		Vec3f pos = map.indexToPos(firstBlock);

		// Loop through these blocks and initialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			bool visible;
			if (!packet.saferead_bool(visible)) return;

			if (!visible) continue;

			uint block;
			if (!packet.saferead_u32(block)) return;

			map.SetBlockInit(i, pos.x, pos.y, pos.z, block);

			pos.x++;
			if (pos.x == 0)
			{
				pos.z++;
				if (pos.y == 0)
				{
					pos.y++;
				}
			}
		}

		// Increment packets processed
		packetsSynced.set(username, count + 1);
	}
}
