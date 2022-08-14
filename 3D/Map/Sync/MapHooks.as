// Script is added when when the map is generated

#include "Map.as"

Map@ map;
MapSyncer@ mapSyncer;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	this.addCommandID("init map");
	this.addCommandID("sync map");

	@map = Map::getMap();
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
	if (mapSyncer.isSyncing(player))
	{
		mapSyncer.RemovePlayer(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init map"))
	{
		Vec3f dimensions;
		if (!dimensions.deserialize(params)) return;

		map.Initialize(dimensions);
	}
	else if (!isServer() && cmd == this.getCommandID("sync map"))
	{
		mapSyncer.ClientReceivePacket(params);
	}
}
