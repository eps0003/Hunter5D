shared class ClientMapSyncer
{
	private uint blocksPerTick = 6000;

	private CBitStream mapData;
	private uint blockIndex;
	private uint blocksSynced = 0;

	private Map@ map = Map::getMap();
	private MapRenderer@ mapRenderer = Map::getRenderer();

	bool isSynced()
	{
		return map.blockCount > 0 && blocksSynced >= map.blockCount;
	}

	float getProgress()
	{
		if (map.blockCount > 0)
		{
			return blocksSynced / float(map.blockCount);
		}
		return 0.0f;
	}

	void ReceivePacket(CBitStream@ packet)
	{
		uint size;
		if (!packet.saferead_u32(size)) return;

		// Append packet to map data without the extra data from onCommand hook
		uint index = mapData.getBitIndex();
		mapData.SetBitIndex(mapData.getBitsUsed());
		mapData.writeBitStream(packet, packet.getBitIndex(), size);
		mapData.SetBitIndex(index);

	}

	void Sync()
	{
		// No more to process
		if (mapData.isBufferEnd()) return;

		// Local player doesn't exist yet
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;

		string username = player.getUsername();

		// Initialize map
		if (mapData.getBitIndex() == 0)
		{
			u16 x, y, z;
			if (!mapData.saferead_u16(x)) return;
			if (!mapData.saferead_u16(y)) return;
			if (!mapData.saferead_u16(z)) return;
			if (!mapData.saferead_u32(blockIndex)) return;

			map.Init(Vec3f(x, y, z));
		}

		uint count = 0;

		while (!mapData.isBufferEnd())
		{
			if (++count > blocksPerTick)
			{
				return;
			}

			bool visible;
			if (!mapData.saferead_bool(visible)) return;

			if (visible)
			{
				// Block
				uint block;
				if (!mapData.saferead_u32(block)) return;

				map.SetBlockInit(blockIndex, block);
				mapRenderer.InitBlockFaces(blockIndex);

				blockIndex++;
				blocksSynced++;
			}
			else
			{
				uint airCount;
				if (!mapData.saferead_u32(airCount)) return;

				blockIndex += airCount;
				blocksSynced += airCount;
			}

			if (blockIndex >= map.blockCount)
			{
				blockIndex -= map.blockCount;
			}
		}
	}
}
