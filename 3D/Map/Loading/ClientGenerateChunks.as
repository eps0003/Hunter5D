#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	float loadRate = 20.0f;

	MapRenderer@ mapRenderer = Map::getRenderer();
	CRules@ rules = getRules();

	float inverseChunkSize = 1.0f / Maths::Pow(mapRenderer.chunkSize, 3);
	uint index = 0;

	ClientGenerateChunks()
	{
		super("Generating chunks...");
	}

	void Load()
	{
		uint chunksThisTick = Maths::Ceil(getFPS() * inverseChunkSize * loadRate);
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
