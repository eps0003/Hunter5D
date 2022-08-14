// Script is added when when the map is generated

#include "Map.as"

#define SERVER_ONLY

Map@ map;
MapSyncer@ mapSyncer;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	@map = Map::getMap();
	@mapSyncer = Map::getSyncer();

	mapSyncer.AddAllPlayers();
}

void onTick(CRules@ this)
{
	mapSyncer.ServerSync();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	mapSyncer.AddPlayer(player);
}
