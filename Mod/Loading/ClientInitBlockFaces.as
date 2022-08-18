#include "Map.as"

shared class ClientInitBlockFaces : ClientLoadStep
{
	Map@ map = Map::getMap();
	MapRenderer@ mapRenderer = Map::getRenderer();

	ClientInitBlockFaces()
	{
		super("Initializing block faces...");
	}

	void Load()
	{
		mapRenderer.Initialize();

		uint index = 0;

		for (uint y = 0; y < map.dimensions.y; y++)
		for (uint z = 0; z < map.dimensions.z; z++)
		for (uint x = 0; x < map.dimensions.x; x++)
		{
			mapRenderer.InitBlockFaces(index++, x, y, z);
		}

		complete = true;
	}
}
