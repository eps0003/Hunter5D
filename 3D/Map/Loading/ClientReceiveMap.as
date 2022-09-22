#include "Map.as"

shared class ClientReceiveMap : ClientLoadStep
{
	ClientMapSyncer@ mapSyncer = Map::getClientSyncer();

	uint startTick;

	ClientReceiveMap()
	{
		super("Receiving map...");
	}

	void Init()
	{
		startTick = getGameTime();
	}

	void Load()
	{
		CPlayer@ player = getLocalPlayer();
		if (player is null) return;

		mapSyncer.Sync();

		progress = mapSyncer.getProgress();
		complete = mapSyncer.isSynced();

		if (complete)
		{
			print("Received map! " + formatDuration(getGameTime() - startTick, true));
		}
	}
}
