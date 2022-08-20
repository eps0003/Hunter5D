#include "Loading.as"
#include "Map.as"
#include "MapGenerator.as"

shared class ServerGenerateMap : ServerLoadStep
{
	uint blocksPerTick = 10000;

	MapGenerator@ generator;

	uint x = 0;
	uint y = 0;
	uint z = 0;
	uint index = 0;

	Map@ map = Map::getMap();

	ServerGenerateMap(MapGenerator@ generator)
	{
		super("Generating map...");
		@this.generator = generator;
	}

	void Init()
	{
		map.Init(generator.getDimensions());
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
					if (++count > blocksPerTick)
					{
						return;
					}

					SColor color = generator.generateBlock(x, y, z);
					map.SetBlock(x, y, z, color);

					index++;
				}
				x = 0;
			}
			z = 0;
		}

		complete = true;
		print("Generated map!");
		getRules().AddScript("MapHooksServer.as");
	}
}
