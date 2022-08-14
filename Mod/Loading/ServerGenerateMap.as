#include "Loading.as"
#include "Map.as"

shared class ServerGenerateMap : ServerLoadStep
{
	ServerGenerateMap()
	{
		super("Generating map...");
	}

	void Load()
	{
		Map@ map = Map::getMap();
		map.Initialize(Vec3f(24, 8, 24));

		for (uint x = 0; x < map.dimensions.x; x++)
		for (uint z = 0; z < map.dimensions.z; z++)
		{
			SColor color = (x + z) % 2 == 0
				? SColor(255, 100, 100, 100)
				: SColor(255, 150, 150, 150);
			map.SetBlock(x, 0, z, color);
		}

		complete = true;
		print("Generated map!");

		getRules().AddScript("MapHooksServer.as");
	}
}
