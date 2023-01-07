#include "Entity.as"
#include "IActor.as"
#include "PlayerTeamHandler.as"

shared class Actor : IActor
{
	private u16 id = 0;
	private CPlayer@ player;
	private ITeamHandler@ teamHandler;

	Actor(u16 id, CPlayer@ player)
	{
		this.id = id;
		@this.player = player;
		@teamHandler = PlayerTeamHandler();
	}

	u16 getId()
	{
		return id;
	}

	u8 getType()
	{
		error("Actor doesn't have a type set: " + id);
		return 0;
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

	void Init() {}
	void PreUpdate() {}
	void Update() {}
	void PostUpdate() {}
	void Render() {}
	void Draw() {}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u16(id);
		bs.write_netid(player.getNetworkID());
		teamHandler.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		@teamHandler = PlayerTeamHandler();

		if (!bs.saferead_u16(id)) return false;
		if (!saferead_player(bs, player)) return false;
		if (!teamHandler.deserializeInit(bs)) return false;
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u16(id);
		teamHandler.SerializeTick(bs);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return false;
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
