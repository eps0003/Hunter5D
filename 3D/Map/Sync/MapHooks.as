// Script is added when when the map is generated

#include "Map.as"

MapSyncer@ mapSyncer;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	this.addCommandID("sync map");

	@mapSyncer = Map::getSyncer();

	if (isServer())
	{
		mapSyncer.AddAllPlayers();
	}
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		mapSyncer.ServerSync();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		mapSyncer.AddPlayer(player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer() && mapSyncer.isSyncing(player))
	{
		mapSyncer.RemovePlayer(player);
	}
}
