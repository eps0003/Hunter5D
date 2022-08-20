#include "MapGenerator.as"

shared class TestMapGenerator : MapGenerator
{
	TestMapGenerator(uint x, uint y, uint z)
	{
		super(x, y, z);
	}

	SColor generateBlock(int x, int y, int z)
	{
		if (y != 0) return 0;
		return (x + z) % 2 == 0
			? SColor(255, 100, 100, 100)
			: SColor(255, 150, 150, 150);
	}
}
