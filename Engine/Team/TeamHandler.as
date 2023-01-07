#include "ITeamHandler.as"

shared class TeamHandler : ITeamHandler
{
	private u8 team = 0;

	u8 getTeamNum()
	{
		return team;
	}

	void SetTeamNum(u8 team)
	{
		this.team = team;
	}
}
