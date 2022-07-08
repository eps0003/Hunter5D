shared interface Serializable
{
	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);
}
