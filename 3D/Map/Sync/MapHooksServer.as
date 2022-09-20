// Script is added when when the map is generated

#include "Map.as"

#define SERVER_ONLY

ServerMapSyncer@ mapSyncer;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	@mapSyncer = Map::getServerSyncer();
}

void onTick(CRules@ this)
{
	mapSyncer.Sync();
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	mapSyncer.RemovePlayer(player);
}
