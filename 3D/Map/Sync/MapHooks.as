#include "Map.as"

Map@ map;
MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	this.addCommandID("init map");
	this.addCommandID("sync map");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = Map::getMap();
	@mapSyncer = Map::getSyncer();
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
