#include "Loading.as"
#include "Map.as"

shared class ServerGenerateMap : ServerLoadStep
{
	uint blocksPerTick = 20000;

	uint x = 0;
	uint y = 0;
	uint z = 0;
	uint index = 0;

	Map@ map = Map::getMap();

	ServerGenerateMap()
	{
		super("Generating map...");
	}

	void Init()
	{
		map.Initialize(Vec3f(24, 8, 24));
	}

	void Load()
	{
		uint count = 0;

		progress = index / float(map.blockCount);

		for (; y < map.dimensions.y; y++)
		{
			for (; z < map.dimensions.z; z++)
			{
				for (; x < map.dimensions.x; x++)
				{
					if (y == 0)
					{
						SColor color = (x + z) % 2 == 0
							? SColor(255, 100, 100, 100)
							: SColor(255, 150, 150, 150);
						map.SetBlock(x, y, z, color);
					}

					if (++index >= map.blockCount)
					{
						complete = true;
						print("Generated map!");
						getRules().AddScript("MapHooksServer.as");
						return;
					}
					else if (++count >= blocksPerTick)
					{
						return;
					}
				}
				x = 0;
			}
			z = 0;
		}
	}
}
