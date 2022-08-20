#include "Map.as"

shared class ClientInitBlockFaces : ClientLoadStep
{
	uint loadRate = 20000;

	uint x = 0;
	uint y = 0;
	uint z = 0;
	uint index = 0;

	Map@ map = Map::getMap();
	MapRenderer@ mapRenderer = Map::getRenderer();

	ClientInitBlockFaces()
	{
		super("Initializing block faces...");
	}

	void Init()
	{
		mapRenderer.Init();
	}

	void Load()
	{
		uint blocksThisTick = Maths::Ceil(loadRate / getRenderSmoothDeltaTime());

		uint count = 0;

		progress = index / float(map.blockCount);

		for (; y < map.dimensions.y; y++)
		{
			for (; z < map.dimensions.z; z++)
			{
				for (; x < map.dimensions.x; x++)
				{
					mapRenderer.InitBlockFaces(index, x, y, z);

					index++;

					if (++count >= blocksThisTick)
					{
						return;
					}
				}
				x = 0;
			}
			z = 0;
		}

		complete = true;
		print("Initialized block faces!");
	}
}
