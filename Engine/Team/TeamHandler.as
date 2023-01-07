#include "ITeamHandler.as"

shared class TeamHandler : ITeamHandler
{
	private u8 team = 0;

	TeamHandler(u8 team)
	{
		this.team = team;
	}

	u8 getTeamNum()
	{
		return team;
	}

	void SetTeamNum(u8 team)
	{
		this.team = team;
	}

	void SerializeInit(CBitStream@ bs)
	{

	}

	bool deserializeInit(CBitStream@ bs)
	{
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u8(team);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		return bs.saferead_u8(team);
	}
}
