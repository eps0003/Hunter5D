#include "ISerializable.as"

shared interface ITeamHandler : ISerializable
{
	u8 getTeamNum();
	void SetTeamNum(u8 team);
}
