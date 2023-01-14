shared interface IEntitySyncer
{
	void Sync();
	void Receive();
	void DeserializePacket(CBitStream@ bs);
}
