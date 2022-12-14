#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	uint loadRate = 40000;

	uint startTick;

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
		startTick = getGameTime();
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

			@chunk = mapRenderer.InitChunk(index);

			count += chunk.getComplexity();
			index++;
		}

		mapRenderer.InitTree();

		complete = true;
		print("Generated chunks! " + formatDuration(getGameTime() - startTick, true));
	}
}
