shared class ClientMapSyncer
{
	private uint blocksPerTick = 8000;

	private CBitStream mapData;
	private uint blockIndex;
	private uint blocksSynced = 0;

	private Map@ map = Map::getMap();
	private MapRenderer@ mapRenderer = Map::getRenderer();

	private uint x = 0;
	private uint y = 0;
	private uint z = 0;

	private uint val;

	private int[] indicesToPlace;
	private SColor[] blocksToPlace;

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
			u16 width, height, depth;
			if (!mapData.saferead_u16(width)) return;
			if (!mapData.saferead_u16(height)) return;
			if (!mapData.saferead_u16(depth)) return;
			if (!mapData.saferead_u32(blockIndex)) return;

			map.Init(Vec3f(width, height, depth));

			Vec3f worldPos = map.indexToPos(blockIndex);
			x = worldPos.x;
			y = worldPos.y;
			z = worldPos.z;
		}

		uint count = 0;

		while (!mapData.isBufferEnd())
		{
			if (++count > blocksPerTick)
			{
				return;
			}

			if (!mapData.saferead_u32(val)) return;

			// Check if alpha is zero
			if (val & 4278190080 == 0)
			{
				// Air
				blockIndex += val;
				blocksSynced += val;
				x += val;
			}
			else
			{
				// Block
				map.SetBlockInit(blockIndex, val);
				mapRenderer.InitBlockFaces(blockIndex, x, y, z);

				blockIndex++;
				blocksSynced++;
				x++;
			}

			if (blockIndex >= map.blockCount)
			{
				blockIndex -= map.blockCount;
			}

			while (x >= map.dimensions.x)
			{
				x -= map.dimensions.x;
				z++;
				while (z >= map.dimensions.z)
				{
					z -= map.dimensions.z;
					y++;
					while (y >= map.dimensions.y)
					{
						y -= map.dimensions.y;
					}
				}
			}
		}
	}

	void EnqueueBlock(int index, SColor block)
	{
		indicesToPlace.push_back(index);
		blocksToPlace.push_back(block);
	}

	void SetQueuedBlocks()
	{
		for (uint i = 0; i < blocksToPlace.size(); i++)
		{
			map.SetBlock(indicesToPlace[i], blocksToPlace[i]);
		}

		indicesToPlace.clear();
		blocksToPlace.clear();
	}
}
