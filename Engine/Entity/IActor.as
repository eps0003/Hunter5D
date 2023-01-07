#include "IEntity.as"

shared interface IActor : IEntity
{
	CPlayer@ getPlayer();
	CBlob@ getBlob();
	bool isMyActor();

	void SerializeTickClient(CBitStream@ bs);
	bool deserializeTickClient(CBitStream@ bs);
}
