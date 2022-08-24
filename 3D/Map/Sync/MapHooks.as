#include "Map.as"
#include "Utilities.as"

Map@ map;
MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	this.addCommandID("init map");
	this.addCommandID("sync map");
	this.addCommandID("client set block");
	this.addCommandID("server set block");

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

		map.Init(dimensions);
	}
	else if (!isServer() && cmd == this.getCommandID("sync map"))
	{
		mapSyncer.ClientReceivePacket(params);
	}
	else if (isServer() && cmd == this.getCommandID("server set block"))
	{
		uint index;
		if (!params.saferead_u32(index)) return;

		uint block;
		if (!params.saferead_u32(block)) return;

		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		if (map.canSetBlock(index, block, player))
		{
			map.SetBlock(index, block, player);
		}
		else
		{
			// Revert block on player's client
			CBitStream bs;
			bs.write_u32(index);
			bs.write_u32(map.getBlock(index).color);
			this.SendCommand(this.getCommandID("client set block"), bs, player);
		}
	}
	else if (isClient() && cmd == this.getCommandID("client set block"))
	{
		uint index;
		if (!params.saferead_u32(index)) return;

		uint block;
		if (!params.saferead_u32(block)) return;

		if (!params.isBufferEnd())
		{
			u16 id;
			if (!params.saferead_netid(id)) return;

			if (getLocalPlayer().getNetworkID() == id) return;
		}

		map.SetBlock(index, block);
	}
}
