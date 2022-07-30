#include "Entity.as"
#include "Utilities.as"

shared class Actor : Entity
{
	private CPlayer@ player;

	Actor(u16 id)
	{
		super(id);
	}

	Actor(u16 id, CPlayer@ player)
	{
		super(id);
		@this.player = player;
	}

	CPlayer@ getPlayer()
	{
		return player;
	}

	void SerializeInitClient(CBitStream@ bs)
	{
		SerializeTickClient(bs);
	}

	bool deserializeInitClient(CBitStream@ bs)
	{
		return deserializeTickClient(bs);
	}

	void SerializeTickClient(CBitStream@ bs)
	{

	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		return true;
	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_netid(player.getNetworkID());
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return saferead_player(bs, player);
	}
}
