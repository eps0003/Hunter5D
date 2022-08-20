#include "Vec3f.as"

shared class MapGenerator
{
	private Vec3f dimensions;
	private bool emittedError = false;

	MapGenerator(uint x, uint y, uint z)
	{
		this.dimensions = Vec3f(x, y, z);
	}

	Vec3f getDimensions()
	{
		return dimensions;
	}

	SColor generateBlock(int x, int y, int z)
	{
		if (!emittedError)
		{
			error("Map generator hasn't overridden generateBlock(int x, int y, int z)");
			emittedError = true;
		}
		return 0;
	}
}
