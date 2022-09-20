#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	uint loadRate = 1500000;

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
		uint count = 0;

		progress = index / float(mapRenderer.chunkCount);

		Chunk@ chunk;

		while (index < mapRenderer.chunkCount)
		{
			if (count > 0 && count > loadRate)
			{
				return;
			}

			@chunk = Chunk(mapRenderer, index);
			mapRenderer.SetChunk(index, chunk);

			count += chunk.getComplexity();
			index++;
		}

		complete = true;
		print("Generated chunks!");
	}
}
