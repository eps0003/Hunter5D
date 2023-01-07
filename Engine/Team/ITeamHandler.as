#include "Serializable.as"

shared interface ITeamHandler : Serializable
{
	u8 getTeamNum();
	void SetTeamNum(u8 team);
}
