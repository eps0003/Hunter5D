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
}
