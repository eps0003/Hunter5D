#include "Map.as"

shared class ClientReceiveMap : ClientLoadStep
{
	MapSyncer@ mapSyncer = Map::getSyncer();

	ClientReceiveMap()
	{
		super("Receiving map...");
	}

	void Load()
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;

		mapSyncer.ClientProcessPackets();

		progress = mapSyncer.getProgress(player);
		complete = mapSyncer.isSynced(player);

		if (complete)
		{
			print("Received map!");
		}
	}
}
