#include "Map.as"
#include "Utilities.as"

Map@ map;
ClientMapSyncer@ clientMapSyncer;

void onInit(CRules@ this)
{
	Command::Add("sync map");
	Command::Add("client set block");
	Command::Add("server set block");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = Map::getMap();
	@clientMapSyncer = Map::getClientSyncer();
}

void onTick(CRules@ this)
{
	if (isClient() && clientMapSyncer.isSynced())
	{
		clientMapSyncer.SetQueuedBlocks();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && Command::equals(cmd, "sync map"))
	{
		clientMapSyncer.ReceivePacket(params);
	}
	else if (isServer() && Command::equals(cmd, "server set block"))
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
			Command::Send("client set block", bs, player);
		}
	}
	else if (isClient() && Command::equals(cmd, "client set block"))
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

		clientMapSyncer.EnqueueBlock(index, block);
	}
}
