#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	float loadRate = 80.0f;

	uint index = 0;
	float inverseChunkSize;

	MapRenderer@ mapRenderer = Map::getRenderer();
	CRules@ rules = getRules();

	ClientGenerateChunks()
	{
		super("Generating chunks...");
	}

	void Init()
	{
		inverseChunkSize = 1.0f / Maths::Pow(mapRenderer.chunkSize, 3);
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
