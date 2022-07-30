#include "Entity.as"
#include "Utilities.as"

shared class Actor : Entity
{
	private CPlayer@ player;

	Actor(u16 id, CPlayer@ player)
	{
		super(id);
		@this.player = player;
	}

	CPlayer@ getPlayer()
	{
		return player;
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		return bs.saferead_u16(id);
	}

	void SerializeInit(CBitStream@ bs)
	{
		Entity::SerializeInit(bs);
		bs.write_netid(player.getNetworkID());
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Entity::deserializeInit(bs)) return false;
		if (!saferead_player(bs, player)) return false;
		return true;
	}
}
