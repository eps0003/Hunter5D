#include "MapGenerator.as"

shared class TestMapGenerator : MapGenerator
{
	TestMapGenerator(uint x, uint y, uint z)
	{
		super(x, y, z);
	}

	SColor generateBlock(int x, int y, int z)
	{
		return (x + y + z) % 2 == 0
			? SColor(255, 100, 100, 100)
			: 0;
	}
}
