#include "Map.as"

shared class ClientGenerateChunks : ClientLoadStep
{
	MapRenderer@ mapRenderer = Map::getRenderer();
	CRules@ rules = getRules();

	ClientGenerateChunks()
	{
		super("Generating chunks...");
	}

	void Load()
	{
		for (uint i = 0; i < mapRenderer.chunkCount; i++)
		{
			mapRenderer.SetChunk(i, Chunk(mapRenderer, i));
		}

		complete = true;
		print("Generated chunks!");

		rules.AddScript("Client.as");
	}
}
