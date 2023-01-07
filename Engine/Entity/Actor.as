#include "Entity.as"
#include "Utilities.as"
#include "PlayerTeamHandler.as"

shared class Actor : Entity
{
	private CPlayer@ player;
	private ITeamHandler@ teamHandler;

	Actor(u16 id, CPlayer@ player)
	{
		super(id);
		@this.player = player;
		@teamHandler = PlayerTeamHandler();
	}

	CPlayer@ getPlayer()
	{
		return player;
	}

	CBlob@ getBlob()
	{
		return player.getBlob();
	}

	bool isMyActor()
	{
		return player.isMyPlayer();
	}

	void SerializeInit(CBitStream@ bs)
	{
		Entity::SerializeInit(bs);
		bs.write_netid(player.getNetworkID());
		teamHandler.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		@teamHandler = PlayerTeamHandler();

		if (!Entity::deserializeInit(bs)) return false;
		if (!saferead_player(bs, player)) return false;
		if (!teamHandler.deserializeInit(bs)) return false;
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{
		Entity::SerializeTick(bs);
		teamHandler.SerializeTick(bs);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!Entity::deserializeTick(bs)) return false;
		if (!teamHandler.deserializeTick(bs)) return false;
		return true;
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		return bs.saferead_u16(id);
	}
}
