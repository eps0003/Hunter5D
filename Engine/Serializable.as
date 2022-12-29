shared interface Serializable
{
	void SerializeInit(CBitStream@ bs);
	bool deserializeInit(CBitStream@ bs);
	void SerializeTick(CBitStream@ bs);
	bool deserializeTick(CBitStream@ bs);
}
