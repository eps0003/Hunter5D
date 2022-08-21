#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	float loadRate = 0.01f;

	uint index = 0;

	MapRenderer@ mapRenderer = Map::getRenderer();
	CRules@ rules = getRules();

	ClientGenerateChunks()
	{
		super("Generating chunks...");
	}

	void Load()
	{
		uint chunksThisTick = Maths::Ceil(getFPS() * loadRate);
		uint count = 0;

		progress = index / float(mapRenderer.chunkCount);

		while (index < mapRenderer.chunkCount)
		{
			if (++count > chunksThisTick)
			{
				return;
			}

			mapRenderer.SetChunk(index, Chunk(mapRenderer, index));

			index++;
		}

		complete = true;
		print("Generated chunks!");
	}
}
