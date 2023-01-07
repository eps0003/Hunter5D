#include "ITeamHandler.as"

shared class PlayerTeamHandler : ITeamHandler
{
	private CPlayer@ player;

	PlayerTeamHandler(CPlayer@ player)
	{
		@this.player = player;
	}

	u8 getTeamNum()
	{
		return player.getTeamNum();
	}

	void SetTeamNum(u8 team)
	{
		player.server_setTeamNum(team);
	}

	// Player health is automatically synced
	void SerializeInit(CBitStream@ bs)
	{

	}

	bool deserializeInit(CBitStream@ bs)
	{
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{

	}

	bool deserializeTick(CBitStream@ bs)
	{
		return true;
	}
}
