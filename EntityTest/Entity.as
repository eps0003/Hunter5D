#include "Serializable.as"

shared class Entity : Serializable
{
	private u16 id = 0;

	Entity(u16 id)
	{
		this.id = id;
	}

	u16 getId()
	{
		return id;
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	bool deserialize(CBitStream@ bs)
	{
		return bs.saferead_u16(id);
	}
}
